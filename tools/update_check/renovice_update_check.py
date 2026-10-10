#!/usr/bin/env python3
"""RENOVICE post-update check (update resilience step 1).

After a Warframe update, re-verifies everything RENOVICE depends on against the INSTALLED client and reports
OK / BROKEN / UNKNOWN per item, grouped by area, with what changed and which user-facing feature it affects.

    python repos/apps/ability-editor/tools/update_check/renovice_update_check.py

Read-only towards the game: Warframe.x64.exe, Cache.Windows (B.Font.toc/.cache, H.Misc for Packages.bin),
OpenWF/Hotfix.owf and the script root are opened for reading only. The script root is the loader's choice
(uc_layout): OpenWF/LuaScripts (layout V2) when it exists, else OpenWF/CustomScripts (V1); --custom-scripts names one. Extracted modules, decompiled addons and the
throw-away verify-missions editor root go to <workspace>/work/temp/update-check; the report goes to
<workspace>/work/diagnostics/update-check/<build>_<time>/ (update_check_report.md + .json).

Exit code: 0 all OK, 1 at least one BROKEN, 2 no BROKEN but at least one UNKNOWN, 3 the tool itself failed.

Mutation proof and synthetic inputs: --exe, --custom-scripts, --stock-dir and --stock-overlay let the check run on
COPIES (tools/update_check/test_update_check_mutations.py); they never change what is read from the install.
"""
from __future__ import annotations

import argparse
import datetime
import hashlib
import json
import os
import subprocess
import sys
import time
import traceback
from collections import defaultdict
from pathlib import Path

TOOL_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(TOOL_DIR))

import uc_bytecode as B  # noqa: E402
import uc_cache  # noqa: E402
import uc_content  # noqa: E402
import uc_layout  # noqa: E402
import uc_missions  # noqa: E402
import uc_native  # noqa: E402
import uc_pe  # noqa: E402
import uc_toolchain  # noqa: E402
import uc_topmenu  # noqa: E402
import uc_runtime  # noqa: E402
import uc_report as R  # noqa: E402
from uc_report import OK, BROKEN, UNKNOWN  # noqa: E402

EDITOR = TOOL_DIR.parents[1]
STEAM_GAME = Path(r'C:\Program Files (x86)\Steam\steamapps\common\Warframe')  # what Steam updates: the update source
# 2026-10-09: the check reads the folder the RENOVICE set is INSTALLED in and played from (a copy of the Steam folder;
# the Steam folder keeps the unpatched executable and no proxy DLL, so checking it reports every native item BROKEN).
# RENOVICE_GAME overrides it.
DEFAULT_GAME = Path(os.environ.get('RENOVICE_GAME') or Path.home() / 'OneDrive' / 'Dokumenter' / 'Warframe')
BASELINES = TOOL_DIR / 'baselines'
BASELINE_FORMAT = 'RENOVICE_UPDATE_CHECK_BASELINE_V2'   # V2 (step 2): stock pack, literal-site and initialiser context
# decompile -> recompile -> const-identity probes: referenced modules whose U44 raw-hash round trip passes on 44.0.2
PROBE_MODULES = ['Lotus_Powersuits_Bard_Abilities_BardMusic.lua_B', 'Lotus_Interface_OmegaRerollSelection.lua_B',
                 'Lotus_Scripts_Modes_TerritoryMission.lua_B', 'Lotus_Interface_Libs_DuviriUtil.lua_B']


def workspace_root() -> Path:
    cur = EDITOR
    for _ in range(10):
        if (cur / 'WORKSPACE.json').is_file():
            return cur
        cur = cur.parent
    raise SystemExit('WORKSPACE.json not found above the ability editor')


def git_head(repo: Path) -> str:
    try:
        head = subprocess.run(['git', '-C', str(repo), 'rev-parse', '--short=9', 'HEAD'], capture_output=True,
                              text=True, check=True).stdout.strip()
        dirty = subprocess.run(['git', '-C', str(repo), 'status', '--porcelain', '--', 'tools/update_check'],
                               capture_output=True, text=True).stdout.strip()
        return head + ('+dirty' if dirty else '')
    except (OSError, subprocess.CalledProcessError):
        return 'unknown'


class Stock:
    """Current stock modules: a cached extraction (or a caller-supplied folder) plus an optional overlay folder whose
    files replace the same-named modules (mutation copies)."""

    def __init__(self, folder: Path, manifest: dict, opmap, overlay: Path | None = None, log=print):
        self.opmap = opmap
        self.records = {}
        for rec in manifest['modules']:
            if 'error' in rec:
                continue
            self.records[rec['file']] = dict(rec, disk=folder / rec['file'])
        if overlay:
            for f in sorted(overlay.glob('*.lua_B')):
                body = f.read_bytes()
                prior = self.records.get(f.name, {})
                self.records[f.name] = {'path': prior.get('path'), 'file': f.name, 'size': len(body),
                                        'sha256': hashlib.sha256(body).hexdigest(), 'key': B.content_key(body),
                                        'disk': f}
            log(f'stock: overlay {overlay} replaces {len(list(overlay.glob("*.lua_B")))} modules')
        self.by_key = defaultdict(list)
        for rec in self.records.values():
            self.by_key[rec['key']].append(rec)
        self._modules = {}

    def file(self, name: str) -> Path | None:
        rec = self.records.get(name)
        return rec['disk'] if rec else None

    def has_key(self, key: str) -> bool:
        return key in self.by_key

    def record_for_key(self, key: str):
        recs = self.by_key.get(key)
        return recs[0] if recs else None

    def module_file(self, name: str):
        if name not in self.records:
            return None
        if name not in self._modules:
            try:
                self._modules[name] = B.Module(self.records[name]['disk'].read_bytes(), self.opmap)
            except B.ContainerError as e:
                self._modules[name] = e
        m = self._modules[name]
        return None if isinstance(m, Exception) else m

    def module(self, key: str):
        rec = self.record_for_key(key)
        return self.module_file(rec['file']) if rec else None

    def bytes(self, key: str):
        rec = self.record_for_key(key)
        return rec['disk'].read_bytes() if rec else None


def default_cli(ws: Path, wsj: dict) -> Path:
    """RENOVICE_EDITOR_CLI (a private build, e.g. a worktree's), else the workspace's current editor build."""
    env = os.environ.get('RENOVICE_EDITOR_CLI')
    return Path(env) if env else ws / wsj['work']['builds'] / 'ability-editor' / 'current' / 'bin' / \
        'renovice_ability_editor_cli.exe'


def load_baseline(path: Path | None, build: str, log) -> tuple[dict, str]:
    if path:
        return json.loads(path.read_text(encoding='utf-8')), str(path)
    exact = BASELINES / f'{build}.json'
    if exact.is_file():
        return json.loads(exact.read_text(encoding='utf-8')), exact.name
    files = sorted(BASELINES.glob('*.json'))
    if files:
        log(f'baseline: no baseline for {build}; comparing with the last certified build {files[-1].stem}')
        return json.loads(files[-1].read_text(encoding='utf-8')), files[-1].name
    return {}, 'none'


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description=__doc__.split('\n\n')[0])
    ap.add_argument('--game', type=Path, default=DEFAULT_GAME, help='installed Warframe folder (read only; default: RENOVICE_GAME, else the Documents copy)')
    ap.add_argument('--exe', type=Path, help='Warframe.x64.exe to check (default: <game>/Warframe.x64.exe)')
    ap.add_argument('--dll', type=Path, help='installed proxy DLL (default: <game>/WTSAPI32.dll)')
    ap.add_argument('--custom-scripts', '--scripts-root', dest='custom_scripts', type=Path,
                    help='script root, OpenWF/LuaScripts (layout V2) or OpenWF/CustomScripts (V1) (default: the one the '
                         'loader uses: <game>/OpenWF/LuaScripts when it exists, else <game>/OpenWF/CustomScripts)')
    ap.add_argument('--stock-dir', type=Path, help='use this folder of extracted modules instead of the cache')
    ap.add_argument('--stock-overlay', type=Path, help='modules here replace the same-named stock modules')
    ap.add_argument('--bootstrapper-ref', default='main', help='bootstrapper git ref whose sources are checked')
    ap.add_argument('--baseline', type=Path, help='baseline JSON (default: tools/update_check/baselines/<build>.json '
                                                  'or the newest one)')
    ap.add_argument('--out', type=Path, help='report folder')
    ap.add_argument('--cli', type=Path, help='renovice_ability_editor_cli.exe (default: RENOVICE_EDITOR_CLI, else '
                                             'work/builds/ability-editor/current/bin)')
    ap.add_argument('--registry', type=Path, help='mission registry to verify (default: REGISTRIES/mission_build_u44.json; '
                                                  'the update tool passes its staged, rebased registry)')
    ap.add_argument('--no-verify-missions', action='store_true', help='skip the verify-missions CLI run')
    ap.add_argument('--write-baseline', action='store_true',
                    help='write tools/update_check/baselines/<build>.json from this run (refused when anything is '
                         'BROKEN)')
    ap.add_argument('--quiet', action='store_true')
    args = ap.parse_args(argv)
    log = (lambda *a, **k: None) if args.quiet else (lambda *a, **k: print(*a, **k, file=sys.stderr))

    t0 = time.time()
    ws = workspace_root()
    wsj = json.loads((ws / 'WORKSPACE.json').read_text(encoding='utf-8'))
    repos = {k: ws / v for k, v in wsj['repos'].items()}
    temp = ws / wsj['work']['temp'] / 'update-check'
    rep = R.Report()
    try:
        return run(args, ws, wsj, repos, temp, rep, log, t0)
    except Exception:  # noqa: BLE001 - the tool's own failure is exit code 3, with the trace
        traceback.print_exc()
        return R.EXIT_TOOL_ERROR


def run(args, ws, wsj, repos, temp, rep, log, t0) -> int:
    game = args.game
    exe_path = args.exe or game / 'Warframe.x64.exe'
    dll_path = args.dll or game / 'WTSAPI32.dll'
    layout = uc_layout.Layout.of(args.custom_scripts) if args.custom_scripts else uc_layout.Layout.for_game(game)
    custom = layout.root
    exe = exe_path.read_bytes()
    exe_sha = hashlib.sha256(exe).hexdigest()
    img = uc_pe.Image(exe)
    build = img.product_version() or 'unknown'
    log(f'client {build} sha256 {exe_sha[:16]} ({exe_path})')

    boot = uc_native.GitSource(repos['bootstrapper_runtime'], args.bootstrapper_ref)
    opmap = B.load_opcode_profile((repos['de_luau_toolchain'] / 'src' / 'de_opcode_profile.h').read_text())
    oodle = ws / wsj['vendor']['misc_tools'] / 'warframe-cache-tools' / 'lib' / 'oo2core_9.dll'

    # 1. stock modules ------------------------------------------------------------------------------------------------
    if args.stock_dir:
        folder, manifest = args.stock_dir, uc_cache.manifest_for_folder(args.stock_dir, log)
        stock_source = f'caller folder {args.stock_dir}'
    else:
        folder, manifest = uc_cache.extract_stock(game, temp, oodle, log)
        stock_source = f'cache {folder.name}'
    stock = Stock(folder, manifest, opmap, args.stock_overlay, log)
    if args.stock_overlay:
        stock_source += f' + overlay {args.stock_overlay}'
    baseline, baseline_name = load_baseline(args.baseline, build, log)
    registry_path = args.registry or EDITOR / 'REGISTRIES' / 'mission_build_u44.json'
    registry = json.loads(registry_path.read_text(encoding='utf-8'))
    seed_registry = int(registry['name_hash_seed'], 16)
    rep.meta.update(build=build, exe_sha256=exe_sha, game=str(game), toc_sha256=manifest.get('toc_sha256'),
                    stock_modules=len(stock.records), stock_source=stock_source, baseline=baseline_name,
                    bootstrapper_ref=args.bootstrapper_ref, bootstrapper_commit=boot.commit,
                    registry_build=registry['build'], tool_commit=git_head(EDITOR),
                    started=datetime.datetime.now().isoformat(timespec='seconds'),
                    custom_scripts=str(custom), script_layout=layout.version, exe=str(exe_path))

    # 2. bootstrapper: build, allowlists, per-build tables, native signatures --------------------------------------------
    native = uc_native.NativeChecks(rep, img, exe_sha, build, boot, baseline, game).run(dll_path)
    exe_seed = native.get('seed') or 0
    seed = exe_seed or seed_registry

    # 3. installed content -----------------------------------------------------------------------------------------------
    scripts = uc_content.inventory(layout)
    derecomp = repos['de_luau_toolchain'] / 'bin' / 'derecomp.exe'
    for s in scripts:
        if s.kind in ('target-addon', 'multi-target-addon') and s.keys:
            try:
                s.hooks = uc_content.extract_hooks(s, uc_content.decompile(derecomp, s.file, s.sha256, temp / 'addons'))
            except Exception as e:  # noqa: BLE001
                s.hook_error = str(e)

    # features per stock content key, and a file name per key for keys that vanished
    features = defaultdict(set)
    hint = {}
    for key, rec in registry['modules'].items():
        hint[key] = rec['file']
    for key, rec in baseline.get('modules', {}).items():
        hint.setdefault(key, rec['file'])
    for row in registry['tunables']:
        for k in uc_missions.row_keys(row):
            features[k].add(uc_missions.row_feature(row))
    pkg_missions = custom / 'Packages' / 'Missions'
    literals = _json(pkg_missions / 'literals.json')
    engine_params = _json(pkg_missions / 'engine_params.json')
    package_json = _json(pkg_missions / 'package.json')
    decls = {}
    for member in (package_json or {}).get('members', {}).values():
        decls.update(member.get('settings', {}).get('values', {}))
    for vid, v in (literals or {}).get('values', {}).items():
        decls.setdefault(vid, v.get('declaration', {}))
        for d in v.get('drives', []):
            features[d.get('module', v.get('module'))].add(uc_missions.decl_feature(v.get('declaration', {}), vid))
    for key, rec in (literals or {}).get('modules', {}).items():
        hint.setdefault(key, rec['file'])
    for ov in (engine_params or {}).get('overrides', []):
        features[ov['module']].add(uc_missions.decl_feature(decls.get(ov['value'], {}), ov['value']))
    for s in scripts:
        for k in s.keys:
            if s.kind != 'multi-target-addon' or not features.get(k):
                features[k].add(s.label)

    def now_module(key: str, file: str | None = None):
        """(module now, how) for a key: the same key, else the module of the same file name in this build."""
        if stock.has_key(key):
            return stock.module(key), 'same-key'
        name = file or hint.get(key)
        if name and stock.file(name):
            return stock.module_file(name), 'same-file'
        return None, 'gone'

    # scripts area: extraction, Packages.bin, every referenced content key
    errors = [r for r in manifest['modules'] if 'error' in r]
    rep.add('scripts', 'scripts.extraction', 'Stock DE Luau modules extracted from Cache.Windows B.Font.toc',
            BROKEN if errors or not stock.records else OK,
            f'{len(stock.records)} modules ({stock_source}); {len(errors)} unreadable'
            + (f': {errors[0]["path"]} {errors[0]["error"]}' if errors else ''), ['Every check of this tool'])
    pbin_sha = None
    try:
        pbin = uc_cache.extract_named(game, 'H.Misc.toc', '/Packages.bin', oodle)
        pbin_sha = hashlib.sha256(pbin).hexdigest() if pbin else None
    except Exception as e:  # noqa: BLE001
        log(f'Packages.bin: {e}')
    same_pbin = pbin_sha and pbin_sha.lower() == registry['packages_bin_sha256'].lower()
    rep.add('scripts', 'scripts.packages_bin', 'Packages.bin (metadata rows of the registry)',
            OK if same_pbin else (UNKNOWN if pbin_sha is None else BROKEN),
            f'sha256 {str(pbin_sha)[:16]} = registry' if same_pbin else
            ('Packages.bin not readable' if pbin_sha is None else
             f'sha256 {pbin_sha[:16]} != registry {registry["packages_bin_sha256"][:16]}: metadata rows need the '
             'metadata update path'), ['Missions: metadata values (game restart rows)'])
    corpus_dir = ws / registry['corpus']
    stale = [rec['file'] for rec in registry['modules'].values()
             if not (corpus_dir / rec['file']).is_file() or stock.file(rec['file']) is None
             or hashlib.sha256((corpus_dir / rec['file']).read_bytes()).hexdigest() !=
             stock.records[rec['file']]['sha256']]
    rep.add('scripts', 'scripts.authoring_corpus', f'Registry authoring corpus {registry["corpus"]} = this client',
            BROKEN if stale else OK, f'{len(registry["modules"]) - len(stale)}/{len(registry["modules"])} modules '
            'byte-identical' + (f'; differ: {", ".join(stale[:6])}' if stale else ''),
            ['Missions generator (build-missions reads the authoring corpus)'])
    # 2026-10-09: the Scripts menu attaches through a pinned TopMenu closure shape per TopMenu key (44.1.1 changed it and
    # the menu disappeared after install; nothing here checked it).
    status, reason, evidence = uc_topmenu.check(stock, boot)
    rep.add('native', 'native.scripts_menu', 'Scripts menu attaches to this TopMenu (bootstrapper layout row)', status, reason,
            ['Scripts menu (SCRIPTS and SCRIPT SETTINGS rows in ESC)'], **evidence)
    # 2026-10-09: what the loader reported in the newest game session (only a session after the last install counts).
    installed = [exe_path, dll_path] + sorted(p for p in (custom / 'Packages').rglob('*') if p.is_file())
    authored = _json(EDITOR / 'tools' / 'update_check' / 'authored_addons.json') or {}
    uc_runtime.check(rep, custom, installed, authored.get('not_rebuilt', {}), OK, BROKEN)

    module_status = {}
    for key in sorted(features):
        name = hint.get(key) or (stock.record_for_key(key) or {}).get('file') or '?'
        feats = sorted(features[key])
        if stock.has_key(key):
            rec = stock.record_for_key(key)
            module_status[key] = 'present'
            rep.add('scripts', 'scripts.content_key', f'{rec["file"]} ({key})', OK,
                    f'present, {rec["size"]} bytes', feats)
            continue
        now = stock.records.get(name) if name != '?' else None
        if now:
            module_status[key] = 'changed'
            rep.add('scripts', 'scripts.content_key', f'{name} ({key})', BROKEN,
                    f'content key changed: the module is now {now["key"]} ({now["size"]} bytes); the script changed',
                    feats, new_key=now['key'])
        else:
            module_status[key] = 'gone'
            rep.add('scripts', 'scripts.content_key', f'{name} ({key})', BROKEN,
                    'module not in this build' if name != '?' else
                    'content key not in this build and no file name is recorded for it (no baseline)', feats)

    # content area: each installed script
    for s in scripts:
        name = f'{s.rel} [{s.state}]'
        body = s.file.read_bytes()
        if s.kind != 'swf':
            try:
                m = B.Module(body, opmap)
                bad = m.walk_errors()
                rep.add('content', 'content.parse', f'{s.rel} parses with the U44 opcode profile',
                        UNKNOWN if bad else OK, bad[0] if bad else f'{len(m.protos)} prototypes', [s.label])
            except B.ContainerError as e:
                rep.add('content', 'content.parse', f'{s.rel} parses', BROKEN, str(e), [s.label])
        if s.kind == 'swf':
            rep.add('content', 'content.swf', name, UNKNOWN, 'SWF replacement keys are not checked by this tool',
                    [s.label])
        elif s.kind in ('replacement', 'target-addon', 'multi-target-addon'):
            missing = [k for k in s.keys if not stock.has_key(k)]
            what = {'replacement': 'replaces', 'target-addon': 'targets',
                    'multi-target-addon': f'{len(s.keys)} declared targets'}[s.kind]
            if not s.keys:
                rep.add('content', 'content.keys', name, BROKEN, 'no declared target key', [s.label])
            elif missing:
                detail = '; '.join(f'{k} ({hint.get(k, "?")}: {module_status.get(k, "gone")}'
                                   + (f' -> {stock.records[hint[k]]["key"]}' if hint.get(k) in stock.records else '')
                                   + ')' for k in missing[:6])
                feats = sorted({f for k in missing for f in features.get(k, [])}) or [s.label]
                rep.add('content', 'content.keys', f'{name} {what}', BROKEN,
                        f'{len(missing)}/{len(s.keys)} content keys not in this build: {detail}', feats)
            else:
                rep.add('content', 'content.keys', f'{name} {what}', OK,
                        f'{len(s.keys)} content key{"s" if len(s.keys) > 1 else ""} present', [s.label])
        else:
            rep.add('content', 'content.inventory', name, OK, f'{s.kind}: no content key', [s.label])
    for pkg in sorted(p for p in (custom / 'Packages').iterdir() if p.is_dir()) if (custom / 'Packages').is_dir() else []:
        pj = _json(pkg / 'package.json')
        labels = [(pj or {}).get('settings', {}).get('build')]
        for extra in ('literals.json', 'engine_params.json'):
            if (pkg / extra).is_file():
                labels.append((_json(pkg / extra) or {}).get('build'))
        labels = [x for x in labels if x]
        ok = labels and all(x == build for x in labels)
        rep.add('content', 'content.package_build', f'Packages/{pkg.name} built for client {", ".join(set(labels))}',
                OK if ok else UNKNOWN, 'matches the installed client' if ok else
                f'package files name build(s) {sorted(set(labels))}, the client is {build}: rebuild the package for '
                'this build once its owners are re-verified', [f'Package {pkg.name}'])

    # hooks area -------------------------------------------------------------------------------------------------------
    base_mods = baseline.get('modules', {})
    for s in scripts:
        if s.kind not in ('target-addon', 'multi-target-addon'):
            continue
        if s.hook_error:
            rep.add('hooks', 'hooks.extract', f'{s.rel} hook tables', UNKNOWN,
                    f'could not decompile the addon: {s.hook_error}', [s.label])
            continue
        for key in sorted(s.hooks):
            entry = s.hooks[key]
            feats = sorted(features.get(key, [])) or [s.label]
            m_now, how = now_module(key)
            fps = base_mods.get(key, {}).get('protos', [])
            for p in entry['luaCalls']:
                rep.add('hooks', 'hooks.lua_call', f'{s.rel}: {key} luaCalls[{p}]',
                        *_proto_status(m_now, how, p, fps, key, hint), feats)
            for method, info in sorted(entry['nativeCalls'].items()):
                if not info['callsites']:
                    rep.add('hooks', 'hooks.native_call', f'{s.rel}: {key} nativeCalls.{method}', UNKNOWN,
                            'callback has no recognisable (prototype, instruction) filter; not checked', feats)
                    continue
                for p, i in info['callsites']:
                    rep.add('hooks', 'hooks.native_call', f'{s.rel}: {key} nativeCalls.{method} P{p} i{i}',
                            *_callsite_status(m_now, how, p, i, method, seed, fps, key, hint), feats)
    rep.note('hooks', 'Hooks are read from the installed addon bytes (decompile-mod-u44) and checked on the current '
                      'stock module; prototype fingerprints come from the baseline of the last certified build.')

    # missions area ----------------------------------------------------------------------------------------------------
    cli = args.cli or default_cli(ws, wsj)
    if args.no_verify_missions:
        rep.add('missions', 'missions.verify_missions', 'verify-missions on the current stock bytes', UNKNOWN,
                'skipped (--no-verify-missions)')
    elif not cli.is_file():
        rep.add('missions', 'missions.verify_missions', 'verify-missions on the current stock bytes', UNKNOWN,
                f'CLI not built: {cli}')
    else:
        result, note, missing = uc_missions.run_verify_missions(cli, ws, registry_path, stock.file, pbin_sha, temp)
        uc_missions.check_registry(rep, registry, result, note, True, (ws / registry['server_root']).resolve())
    if literals:
        uc_missions.check_literals(rep, literals, now_module)
    if engine_params:
        uc_missions.check_engine_params(rep, engine_params, registry, now_module, seed, decls)

    # toolchain area ---------------------------------------------------------------------------------------------------
    fnv = uc_native.loads_jsonc(boot.read('OpenWF/vv/wf_fnv_2_initial.json'))
    gv_n = uc_native.gv2n(_gv_text(boot, build))
    fnv_seed, best = None, -1
    for ver, val in fnv.items():          # the bootstrapper's versioned lookup: highest version <= game version
        n = uc_native.gv2n(ver)
        if best < n <= gv_n:
            best, fnv_seed = n, val & 0xFFFFFFFF
    walk_file = folder / f'walk-{hashlib.sha256(bytes(opmap)).hexdigest()[:12]}.json'
    walk_cache = (_json(walk_file) or {}) if walk_file.is_file() else {}
    rewalk = sorted(f.name for f in args.stock_overlay.glob('*.lua_B')) if args.stock_overlay else []
    referenced_files = sorted({hint[k] for k in features if k in hint and stock.file(hint[k])}
                              | {stock.record_for_key(k)['file'] for k in features if stock.has_key(k)})
    tc = uc_toolchain.check(rep, repos['de_luau_toolchain'], boot.read('renovice/de_opcode_profile.hpp'), opmap,
                            {'modules': list(stock.records.values())}, stock.file, baseline, exe_seed, fnv_seed,
                            seed_registry, referenced_files, temp, walk_cache, PROBE_MODULES, rewalk)
    if not args.stock_overlay and not walk_file.is_file():
        try:
            walk_file.write_text(json.dumps(walk_cache), encoding='utf-8')
        except OSError:
            pass

    # report -----------------------------------------------------------------------------------------------------------
    rep.meta['seconds'] = round(time.time() - t0, 1)
    out = args.out or ws / wsj['work']['diagnostics'] / 'update-check' / \
        f'{build}_{datetime.datetime.now().strftime("%Y%m%d-%H%M%S")}'
    R.write(rep, out)
    c = rep.counts()
    print(f'RENOVICE UPDATE CHECK {build}: OK={c[OK]} BROKEN={c[BROKEN]} UNKNOWN={c[UNKNOWN]} '
          f'exit={rep.exit_code()} report={out / "update_check_report.md"}')
    for i in rep.items:
        if i.status != OK:
            print(f'  {i.status:7} {i.area}/{i.check}: {i.name} -- {i.reason}'[:400])

    if args.write_baseline:
        blocking = [i for i in rep.items if i.status == BROKEN and i.check != 'missions.registry_row.server']
        if blocking:
            print(f'baseline NOT written: {len(blocking)} BROKEN client-build items', file=sys.stderr)
        else:
            write_baseline(build, exe_sha, manifest, boot, native, stock, features, hint, scripts, tc,
                           ws=ws, wsj=wsj, registry=registry, literals=literals)
    return rep.exit_code()


def _gv_text(boot, build: str) -> str:
    versions = uc_native.loads_jsonc(boot.read('OpenWF/vv/game_versions.json'))
    gv = '0.0.0'
    for date, ver in sorted(versions.items()):
        if date <= build:
            gv = ver
    return gv


def _proto_status(m_now, how, p, fps, key, hint):
    base_fp = fps[p] if p < len(fps) else None
    if m_now is None:
        return BROKEN, f'target module {hint.get(key, key)} is not in this build'
    if p >= len(m_now.protos):
        where = '' if how == 'same-key' else f' (module now {m_now.key})'
        return BROKEN, f'prototype {p} missing: the module has {len(m_now.protos)} prototypes{where}'
    fp = m_now.fingerprint(m_now.protos[p])
    if how == 'same-key':
        if base_fp and fp != base_fp:
            return UNKNOWN, f'prototype {p} fingerprint {fp} != baseline {base_fp} on identical bytes (tool changed?)'
        return OK, f'prototype {p} present, fingerprint {fp}'
    # content key changed: compare with the baseline fingerprint
    if not base_fp:
        return BROKEN, f'content key changed (module now {m_now.key}); prototype {p} cannot be compared: no baseline fingerprint'
    if fp == base_fp:
        return BROKEN, (f'content key changed (module now {m_now.key}); prototype {p} itself is unchanged '
                        f'(fingerprint {fp}): re-key the target')
    moved = [q.index for q in m_now.protos if m_now.fingerprint(q) == base_fp]
    return BROKEN, (f'prototype {p} fingerprint mismatch ({fp} != baseline {base_fp}; module now {m_now.key}); '
                    + (f'the identical prototype is now {", ".join(map(str, moved))}' if moved else
                       'no prototype with the baseline fingerprint remains (function changed or removed)'))


def _callsite_status(m_now, how, p, i, method, seed, fps, key, hint):
    want = B.name_hash(method, seed)
    if m_now is None:
        return BROKEN, f'target module {hint.get(key, key)} is not in this build'
    q = p
    note = ''
    if how != 'same-key':
        base_fp = fps[p] if p < len(fps) else None
        moved = [x.index for x in m_now.protos if base_fp and m_now.fingerprint(x) == base_fp]
        if p < len(m_now.protos) and base_fp and m_now.fingerprint(m_now.protos[p]) == base_fp:
            note = f'content key changed (module now {m_now.key}); prototype {p} unchanged; '
        elif moved:
            q = moved[0]
            note = f'content key changed (module now {m_now.key}); prototype {p} is now {q}; '
        else:
            note = f'content key changed (module now {m_now.key}); prototype {p} changed; '
    if q >= len(m_now.protos):
        return BROKEN, note + f'prototype {q} missing ({len(m_now.protos)} prototypes)'
    proto = m_now.protos[q]
    kind, value = m_now.namecall_name(proto, i)
    hit = (kind == 'hash' and value == want) or (kind == 'string' and value == method)
    if hit and how == 'same-key':
        return OK, f'P{p} i{i} is NAMECALL :{method} (0x{want:08x})'
    if hit:
        return BROKEN, note + f'callsite P{q} i{i} is still NAMECALL :{method}: re-key the target' + \
            ('' if q == p else f' and move the callsite to P{q}')
    elsewhere = [ix for ix, _, op in proto.instructions if op == B.OP_NAMECALL
                 and m_now.namecall_name(proto, ix) in (('hash', want), ('string', method))]
    reason = value if kind == 'error' else f'P{q} i{i} is NAMECALL of another method ({kind} {value})'
    return BROKEN, note + f'callsite no longer NAMECALL :{method}: {reason}' + \
        (f'; NAMECALL :{method} in P{q} now at {", ".join(map(str, elsewhere))}' if elsewhere else
         f'; P{q} has no NAMECALL :{method}')


def write_baseline(build, exe_sha, manifest, boot, native, stock, features, hint, scripts, tc, ws=None, wsj=None,
                   registry=None, literals=None):
    mods = {}
    for key in sorted(features):
        rec = stock.record_for_key(key)
        m = stock.module(key) if rec else None
        if not rec or not m:
            continue
        mods[key] = {'file': rec['file'], 'path': rec.get('path'), 'size': rec['size'], 'sha256': rec['sha256'],
                     'protos': [m.fingerprint(p) for p in m.protos], 'shapes': [m.shape(p) for p in m.protos]}
    hooks = {}
    for s in scripts:
        if s.hooks:
            hooks[s.rel] = {'sha256': s.sha256, 'targets': s.hooks}
    data = {
        'format': BASELINE_FORMAT, 'build': build, 'exe_sha256': exe_sha, 'toc_sha256': manifest.get('toc_sha256'),
        'written': datetime.date.today().isoformat(), 'bootstrapper_commit': boot.commit,
        'fingerprint': 'uc_bytecode.Module.fingerprint (header, sizecode, child count, canonical code, constants with '
                       'strings resolved and closures as a marker; SHA-256 first 16 hex)',
        'signatures': {k: {'count': v['count'], 'file': v['file'], 'context': v['context'], 'pattern': v['pattern']}
                       for k, v in native['signatures'].items()},
        'natives': native['natives'], 'openwf_frame_profile': native['openwf_frame_profile'],
        'native_rvas': native['rvas'], 'seed': native.get('seed'), 'engine_damage': native.get('engine_damage'),
        'engine_params': native.get('engine_params'),
        'corpus_walk': tc.get('corpus_walk'), 'toolchain_probes': tc.get('probes', {}), 'modules': mods, 'hooks': hooks,
    }
    # V2 (update resilience step 2): the build-A bytes of every referenced module (the remap reads them after the update,
    # when the install has only build B), and the prototype/instruction context of every literal site and root-table
    # initialiser (a site can be found again by function + logical index instead of by byte offset).
    if ws is not None:
        pack_rel = f'{wsj["shared"]["de_luau_corpus"].rsplit("/", 1)[0]}/update-baseline-{build}'
        pack = ws / pack_rel
        pack.mkdir(parents=True, exist_ok=True)
        files = {}
        for key, rec in mods.items():
            body = stock.bytes(key)
            (pack / rec['file']).write_bytes(body)
            files[rec['file']] = rec['sha256']
        data['stock_pack'] = {'folder': pack_rel, 'files': dict(sorted(files.items()))}
        data['literal_sites'] = literal_context(literals or {}, stock)
        data['root_table_initialisers'] = initialiser_context(registry or {}, stock)
        data['format'] = BASELINE_FORMAT
    BASELINES.mkdir(exist_ok=True)
    path = BASELINES / f'{build}.json'
    path.write_text(json.dumps(data, indent=1, sort_keys=True) + '\n', encoding='utf-8', newline='\n')
    print(f'baseline written: {path} ({len(mods)} modules, {len(data["signatures"])} signature rows)')


def _site_context(m, offset: int, kind: str) -> dict:
    if kind == 'number_constant':
        hit = m.constant_at(offset)
        return {'prototype': hit[0], 'constant': hit[1]} if hit else {'unresolved': True}
    hit = m.logical_at(offset)
    if not hit:
        return {'unresolved': True}
    out = {'prototype': hit[0], 'instruction': hit[1]}
    if m.offset(m.protos[hit[0]], hit[1]) != offset:
        out['aux'] = True
    return out


def literal_context(literals: dict, stock) -> dict:
    """{value id: [{module, file, offset, kind, prototype, instruction | constant}]} of the installed literals.json."""
    out = {}
    mods = literals.get('modules', {})
    for vid, value in sorted(literals.get('values', {}).items()):
        sites = []
        for drive in value.get('drives', []):
            key = drive.get('module', value.get('module'))
            m = stock.module(key)
            for site in drive.get('sites', []):
                rec = {'module': key, 'file': mods.get(key, {}).get('file'), 'offset': site['offset'], 'kind': site['kind']}
                if m is not None:
                    rec.update(_site_context(m, site['offset'], site['kind']))
                sites.append(rec)
        out[vid] = sites
    return out


def initialiser_context(registry: dict, stock) -> dict:
    """{tunable id: [{module, table_id, value_kind, value_offset, prototype, instruction | constant}]} of every
    root-table field the registry owns."""
    out = {}
    for row in registry.get('tunables', []):
        fields = row.get('owner', {}).get('fields')
        if not fields:
            continue
        key = row['owner']['body_key']
        m = stock.module(key)
        recs = []
        for f in fields:
            rec = {'module': key, 'table_id': f['table_id'], 'value_kind': f['value_kind'], 'value_offset': f['value_offset']}
            if m is not None:
                rec.update(_site_context(m, f['value_offset'], f['value_kind']))
            recs.append(rec)
        out[row['tunable_id']] = recs
    return out


def _json(path: Path):
    try:
        return json.loads(path.read_text(encoding='utf-8'))
    except (OSError, ValueError, AttributeError):
        return None


if __name__ == '__main__':
    sys.exit(main())
