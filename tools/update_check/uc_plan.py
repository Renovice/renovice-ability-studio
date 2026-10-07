"""Update resilience step 2: the remap plan (script side).

Given the baseline of the last certified build A (tools/update_check/baselines/<A>.json and its stock pack) and the newly
installed build B (stock modules extracted from Cache.Windows, or a caller-supplied folder/overlay), map every
script-level dependency of RENOVICE onto build B and decide, per dependency, auto / review / dropped with the reason.

Dependencies covered:
  modules            every content key the baseline records (registry modules, addon targets, replacement targets)
  registry rows      every row of REGISTRIES/mission_build_u44.json (literal sites + preimages, root-table owners and
                     their hook plans, entry hooks, readers, metadata consumers), through the registrar's rebase
                     (RESEARCH/UNIVERSAL_MISSION_REGISTRY_2026-09-29/tools/rebase_registry.py)
  luaCalls           the prototypes of the installed Missions multi-target addon (regenerated from the registry)
  nativeCalls        the callsites of the installed authored addons (NAMECALL of the same method in the mapped function)
  literals.json      the installed recipe values (regenerated from the rebased rows)
  engine_params.json the installed engine-parameter overrides (hash + readers of the rebased rows)
  replacements       the installed full-module replacements (instruction-level edit rebase, or review)
  authored addons    the installed authored target addons (source rewrite + rebuild in step 3)

Read-only towards the game. Writes only into the caller's work folder.
"""
from __future__ import annotations

import hashlib
import json
import shutil
import sys
from collections import Counter
from pathlib import Path

import uc_bytecode as B
import uc_content
import uc_remap as RM
import uc_artifacts as ART
import uc_metadata as UM

TOOL_DIR = Path(__file__).resolve().parent
EDITOR = TOOL_DIR.parents[1]
REGISTRAR = EDITOR / 'RESEARCH' / 'UNIVERSAL_MISSION_REGISTRY_2026-09-29' / 'tools'
PLAN_FORMAT = 'RENOVICE_UPDATE_REMAP_PLAN_V1'
AUTHORED = TOOL_DIR / 'authored_addons.json'
ORDER = {'unchanged': 0, 'auto': 1, 'review': 2, 'dropped': 3}


def _sha(b: bytes) -> str:
    return hashlib.sha256(b).hexdigest()


class OldStock:
    """Build-A module bytes: the baseline stock pack, else the registry authoring corpus (both SHA-pinned)."""

    def __init__(self, ws: Path, baseline: dict, registry: dict):
        pack = baseline.get('stock_pack') or {}
        self.pack = ws / pack['folder'] if pack.get('folder') else None
        self.pack_files = pack.get('files', {})
        self.corpus = ws / registry['corpus']
        self.corpus_sha = {rec['file']: rec['sha256'].lower() for rec in registry['modules'].values()}
        self.by_file = {rec['file']: (key, rec['sha256'].lower()) for key, rec in baseline.get('modules', {}).items()}

    def bytes(self, file: str) -> bytes | None:
        for folder, pins in ((self.pack, self.pack_files), (self.corpus, self.corpus_sha)):
            if folder is None or file not in pins:
                continue
            path = folder / file
            if path.is_file():
                data = path.read_bytes()
                if _sha(data) == pins[file].lower():
                    return data
        return None


class NewStock:
    """Build-B module bytes by file name: an overlay folder first, then the extraction/caller folder."""

    def __init__(self, folder: Path, overlay: Path | None = None):
        self.folder, self.overlay = folder, overlay

    def path(self, file: str) -> Path | None:
        for d in (self.overlay, self.folder):
            if d is not None and (d / file).is_file():
                return d / file
        return None

    def bytes(self, file: str) -> bytes | None:
        p = self.path(file)
        return p.read_bytes() if p else None

    def files(self) -> set[str]:
        out = {f.name for f in self.folder.glob('*.lua_B')}
        if self.overlay:
            out |= {f.name for f in self.overlay.glob('*.lua_B')}
        return out

    def file_for_key(self, key: str) -> str | None:
        """Build-B file whose content key is `key` (extraction manifest.json; overlay files keyed from their bytes)."""
        if not hasattr(self, '_by_key'):
            self._by_key = {}
            manifest = self.folder / 'manifest.json'
            if manifest.is_file():
                for rec in json.loads(manifest.read_text(encoding='utf-8')).get('modules', []):
                    if rec.get('key') and rec.get('file'):
                        self._by_key[rec['key']] = rec['file']
            if self.overlay:
                for f in self.overlay.glob('*.lua_B'):
                    self._by_key = {k: v for k, v in self._by_key.items() if v != f.name}
                    self._by_key[B.content_key(f.read_bytes())] = f.name
        return self._by_key.get(key)


class Maps:
    """ModuleMap per file (A from OldStock, B from NewStock); a module whose file vanished is looked up by its base
    name among the files that are new in build B (a moved script)."""

    def __init__(self, old: OldStock, new: NewStock, opmap):
        self.old, self.new, self.opmap = old, new, opmap
        self.cache: dict[str, RM.ModuleMap] = {}
        self.moved: dict[str, str] = {}
        self._new_files = None

    def get(self, file: str) -> RM.ModuleMap | None:
        if file in self.cache:
            return self.cache[file]
        a = self.old.bytes(file)
        if a is None:
            return None
        b = self.new.bytes(file)
        if b is None:
            alt = self._moved(file)
            if alt:
                self.moved[file] = alt
                b = self.new.bytes(alt)
        mm = RM.ModuleMap(B.Module(a, self.opmap), B.Module(b, self.opmap) if b is not None else None, file)
        self.cache[file] = mm
        return mm

    def _moved(self, file: str) -> str | None:
        if self._new_files is None:
            known = set(self.old.by_file) | set(self.old.corpus_sha)
            self._new_files = sorted(self.new.files() - known)
        base = file.split('_')[-1]
        hits = [f for f in self._new_files if f.endswith('_' + base)]
        return hits[0] if len(hits) == 1 else None


def load_authored() -> dict:
    return json.loads(AUTHORED.read_text(encoding='utf-8'))


def make_plan(*, ws: Path, wsj: dict, baseline: dict, baseline_name: str, registry: dict, old: OldStock, new: NewStock,
              custom: Path, opmap, seed: int, build_b: str, build_label_b: str, packages_bin_b: str | None,
              work: Path, corpus_rel: str, temp: Path, log=print, force: dict | None = None,
              packages_bin_data: bytes | None = None) -> dict:
    """Step 2. Returns the plan dict; writes the rebased registry candidate and the build-B corpus into `work`."""
    sys.path.insert(0, str(REGISTRAR))
    import rebase_registry as RR  # noqa: E402 - registrar tools (deluau, anchors, addon_owner, hook_plan, ...)
    work.mkdir(parents=True, exist_ok=True)
    maps = Maps(old, new, opmap)
    deps: list[dict] = []

    def dep(kind, ident, action, **kw):
        d = {'kind': kind, 'id': ident, 'action': action}
        d.update({k: v for k, v in kw.items() if v not in (None, '', [], {})})
        deps.append(d)
        return d

    # 1. module identity ------------------------------------------------------------------------------------------------
    files = {rec['file'] for rec in baseline.get('modules', {}).values()} | {rec['file'] for rec in registry['modules'].values()}
    modules = []
    for f in sorted(files):
        mm = maps.get(f)
        if mm is None:
            modules.append({'file': f, 'status': 'unknown', 'reason': 'no build-A bytes (stock pack or authoring corpus)'})
            continue
        s = mm.summary()
        if f in maps.moved:
            s['moved_to'] = maps.moved[f]
        s['prototypes'] = [pm.as_json() for pm in mm.protos.values() if pm.kind != 'exact' or pm.a != pm.b] \
            if mm.status == 'changed' else []
        modules.append(s)
        moved = maps.moved.get(f)
        dep('module', f, 'review' if moved else {'unchanged': 'unchanged', 'changed': 'auto', 'removed': 'dropped'}[mm.status],
            old=mm.ma.key, new=mm.mb.key if mm.mb else None,
            confidence='exact' if mm.status != 'changed' or all(p.kind == 'exact' for p in mm.protos.values()) else 'mixed',
            reason=(f'the script moved to {moved}: its owners are not carried over automatically (re-register)' if moved
                    else 'module not in the new build' if mm.status == 'removed' else ''),
            note=f'{s["kinds"]}, {s["moved"]} prototypes renumbered' if mm.status == 'changed' else '')

    # 2. registry rows (registrar rebase) ---------------------------------------------------------------------------------
    corpus = work / 'corpus'
    corpus.mkdir(parents=True, exist_ok=True)
    old_dir = work / 'corpus-old'
    old_dir.mkdir(parents=True, exist_ok=True)
    for rec in registry['modules'].values():
        a = old.bytes(rec['file'])
        if a is None:
            raise SystemExit(f'plan: build-A bytes of {rec["file"]} are missing (authoring corpus)')
        (old_dir / rec['file']).write_bytes(a)
        b = new.bytes(rec['file'])          # a moved module is not carried over automatically (review)
        if b is not None:
            (corpus / rec['file']).write_bytes(b)
    # metadata snapshot of build B (uc_metadata): re-stamped when Packages.bin is unchanged, else re-decoded from it
    snap_name = registry['metadata_snapshot']['file']
    snap_a_path = ws / registry['corpus'] / snap_name
    if hashlib.sha256(snap_a_path.read_bytes()).hexdigest().upper() != registry['metadata_snapshot']['sha256'].upper():
        raise SystemExit(f'plan: {snap_a_path} does not have the registry SHA-256')
    snap_b = None
    if packages_bin_b:
        snap_b = UM.snapshot_for_build(json.loads(snap_a_path.read_text(encoding='utf-8')), build=build_b,
                                       packages_bin_sha256=packages_bin_b, packages_bin=packages_bin_data, ws=ws,
                                       wsj=wsj, work=work / 'metadata', log=log)
    rb = RR.Rebase(registry, old_dir, corpus, opmap, build=build_b, build_label=build_label_b,
                   packages_bin_sha256=packages_bin_b, corpus_rel=corpus_rel, log=log, force=force,
                   metadata_snapshot_b=snap_b)
    rebased, decisions, absent = rb.run()
    for d in decisions:
        items = d.get('items', [])
        moved = [x for x in items if next(iter(x.values())) != x.get('new')]
        dep('registry.row', d['tunable_id'], d['action'], confidence=d.get('confidence'), reason=d.get('reason'),
            notes=d.get('notes'), stock=d.get('stock'), items=items,
            moves=((f'{len(moved)}/{len(items)} pins moved: ' + ', '.join(
                f'{next(iter(x.values()))} -> {x["new"]}' for x in moved[:2]) + (' ...' if len(moved) > 2 else ''))
                   if moved else f're-keyed, {len(items)} pins at the same place') if items else '',
            modules=[m['file'] for m in d.get('modules', []) if m['status'] != 'unchanged'])
    # keep only the corpus files the rebased registry names, plus the build-B metadata snapshot
    keep = {rec['file'] for rec in rebased['modules'].values()}
    for f in corpus.glob('*.lua_B'):
        if f.name not in keep:
            f.unlink()
    if snap_b is not None:
        (corpus / snap_name).write_text(json.dumps(snap_b, indent=1, ensure_ascii=False) + '\n', encoding='utf-8')
        rebased['metadata_snapshot'] = {'file': snap_name,
                                        'sha256': hashlib.sha256((corpus / snap_name).read_bytes()).hexdigest().upper()}
    else:                       # Packages.bin unreadable: the old snapshot as is (metadata rows verify only on build A)
        shutil.copyfile(snap_a_path, corpus / snap_name)
    (work / 'mission_build_u44.rebased.json').write_bytes(RR.dump(rebased))
    (work / 'registry_rebase_decisions.json').write_text(json.dumps({'format': RR.FORMAT, 'absent': absent,
                                                                     'decisions': decisions}, indent=1), encoding='utf-8')
    row_action = {d['tunable_id']: d['action'] for d in decisions}
    masters = registry.get('ui_masters', {})

    def value_action(vid):
        if vid in row_action:
            return row_action[vid]
        if vid in masters:
            acts = [row_action.get(dd['tunable_id'], 'unchanged') for dd in masters[vid]['drives']]
            return 'dropped' if all(a in ('review', 'dropped') for a in acts) else max(acts, key=ORDER.get)
        return 'unchanged'

    # 3. installed content: inventory and hooks (read from the installed bytes, step-1 rules) ----------------------------
    scripts = uc_content.inventory(custom)
    derecomp = ws / wsj['repos']['de_luau_toolchain'] / 'bin' / 'derecomp.exe'
    by_key_file = {rec['file']: key for key, rec in baseline.get('modules', {}).items()}
    key_file = {key: rec['file'] for key, rec in baseline.get('modules', {}).items()}
    key_file.update({key: rec['file'] for key, rec in registry['modules'].items()})
    authored = load_authored()
    authored_by_file = {a['installed']: a for a in authored['addons']}
    replacement_specs = {r['installed']: r for r in authored.get('replacements', [])}
    artifacts = {'replacements': [], 'addons': [], 'packages': []}
    for s in scripts:
        if s.kind in ('target-addon', 'multi-target-addon') and s.keys:
            try:
                s.hooks = uc_content.extract_hooks(s, uc_content.decompile(derecomp, s.file, s.sha256, temp / 'addons'))
            except Exception as e:  # noqa: BLE001
                s.hook_error = str(e)
    for s in scripts:
        if s.kind == 'replacement':
            key = s.keys[0]
            file = key_file.get(key)
            mm = maps.get(file) if file else None
            spec = replacement_specs.get(s.rel, {})
            rec = {'file': s.rel, 'key': key, 'module': file, 'source_project': spec.get('source_project'),
                   'label': s.label}
            if mm is None and new.file_for_key(key):
                # installed after the baseline was written: the exact target is still in build B, so it still applies
                rec.update(action='unchanged', module=new.file_for_key(key),
                           notes='target not in the baseline; build B holds the same content key')
            elif mm is None:
                rec.update(action='review', reason='target module unknown to the baseline (no build-A bytes)')
            elif mm.status == 'unchanged':
                rec.update(action='unchanged')
            elif mm.status == 'removed':
                rec.update(action='dropped', reason=f'{file} is not in the new build')
            else:
                r = ART.rebase_replacement(mm.ma, B.Module(s.file.read_bytes(), opmap), mm.mb, mm)
                rec.update({k: v for k, v in r.items() if k != 'bytes'})
                if r['action'] == 'auto':
                    out = work / 'replacements' / f'{r["new_key"]} ({s.label.split(": ", 1)[-1]}).lua_B'
                    out.parent.mkdir(parents=True, exist_ok=True)
                    out.write_bytes(r['bytes'])
                    rec.update(artifact=str(out), artifact_name=out.name, sha256=_sha(r['bytes']), size=len(r['bytes']))
                elif spec.get('source_project'):
                    rec['reason'] = rec.get('reason', '') + f' (source project: {spec["source_project"]})'
            artifacts['replacements'].append(rec)
            dep('replacement', s.rel, rec['action'], old=key, new=rec.get('new_key') or (mm.mb.key if mm and mm.mb else None),
                confidence=rec.get('confidence'), reason=rec.get('reason'), notes=rec.get('notes'), feature=s.label)
        elif s.kind == 'target-addon' and s.keys:
            key = s.keys[0]
            file = key_file.get(key)
            mm = maps.get(file) if file else None
            spec = authored_by_file.get(s.rel)
            rec = {'file': s.rel, 'key': key, 'module': file, 'label': s.label, 'package': s.package,
                   'hooks': s.hooks.get(key, {}) if s.hooks else {}, 'spec': spec}
            if mm is None and new.file_for_key(key):
                rec.update(action='unchanged', module=new.file_for_key(key),
                           notes='target not in the baseline; build B holds the same content key')
            elif mm is None:
                rec.update(action='review', reason='target module unknown to the baseline (no build-A bytes)')
            elif mm.status == 'unchanged':
                rec.update(action='unchanged')
            elif mm.status == 'removed':
                rec.update(action='dropped', reason=f'{file} is not in the new build')
            elif spec is None:
                rec.update(action='review', reason=authored.get('not_rebuilt', {}).get(s.rel) or
                           'no source recorded in tools/update_check/authored_addons.json')
            else:
                calls = []
                worst = 'auto'
                for method, info in sorted(rec['hooks'].get('nativeCalls', {}).items()):
                    for p, i in info.get('callsites', []):
                        m = ART.map_callsite(mm, method, p, i, seed)
                        calls.append(dict(m, method=method, old=[p, i]))
                        dep('addon.native_call', f'{s.rel}: {method} P{p} i{i}', m['action'],
                            old=f'P{p} i{i}', new=f'P{m["new"][0]} i{m["new"][1]}' if m.get('new') else None,
                            confidence=m.get('confidence'), reason=m.get('reason'), note=m.get('note'), feature=s.label)
                        if ORDER[m['action']] > ORDER[worst]:
                            worst = m['action']
                rec.update(action=worst, callsites=calls, new_key=mm.mb.key)
                if worst != 'auto':
                    rec['reason'] = next(c['reason'] for c in calls if c['action'] == worst)
            artifacts['addons'].append(rec)
            dep('authored_addon', s.rel, rec['action'], old=key, new=rec.get('new_key'), reason=rec.get('reason'),
                feature=s.label)
        elif s.kind == 'multi-target-addon':
            for key, entry in sorted((s.hooks or {}).items()):
                file = key_file.get(key)
                mm = maps.get(file) if file else None
                for p in entry.get('luaCalls', []):
                    if mm is None or mm.status == 'unchanged':
                        act, new_p, why, conf = ('unchanged' if mm else 'review'), p, ('' if mm else 'unknown module'), 'exact'
                    else:
                        pm = mm.proto(p)
                        act = 'auto' if pm.b is not None else ('review' if pm.kind == 'ambiguous' else 'dropped')
                        new_p, why, conf = pm.b, pm.note if pm.b is None else '', pm.kind
                    dep('addon.lua_call', f'{s.rel}: {key} luaCalls[{p}]', act, old=p, new=new_p, confidence=conf,
                        reason=why, note='regenerated by build-missions from the rebased registry')
    # 4. installed recipes: literals.json and engine_params.json (regenerated from the rebased rows) -------------------
    pkg = custom / 'Packages' / 'Missions'
    for name, kind in (('literals.json', 'literals.value'), ('engine_params.json', 'engine_param')):
        try:
            data = json.loads((pkg / name).read_text(encoding='utf-8'))
        except (OSError, ValueError):
            continue
        items = data.get('values', {}).keys() if kind == 'literals.value' else [o['value'] for o in data.get('overrides', [])]
        for vid in sorted(set(items)):
            act = value_action(vid)
            dep(kind, vid, act, note='regenerated by build-missions from the rebased registry',
                reason='' if act in ('auto', 'unchanged') else f'its registry row is {act}')
    for p in sorted(x for x in (custom / 'Packages').iterdir() if x.is_dir()) if (custom / 'Packages').is_dir() else []:
        artifacts['packages'].append(p.name)

    counts = Counter(d['action'] for d in deps)
    by_kind = {}
    for d in deps:
        by_kind.setdefault(d['kind'], Counter())[d['action']] += 1
    stock_changes = [d for d in deps if d['kind'] == 'registry.row' and d.get('stock')]
    plan = {'format': PLAN_FORMAT, 'build_old': baseline.get('build'), 'build_new': build_b, 'baseline': baseline_name,
            'summary': {'actions': dict(counts), 'by_kind': {k: dict(v) for k, v in sorted(by_kind.items())},
                        'stock_changes': len(stock_changes), 'absent_value_ids': absent},
            'modules': modules, 'dependencies': deps, 'artifacts': artifacts,
            'registry': {'rebased': str(work / 'mission_build_u44.rebased.json'), 'corpus': str(corpus),
                         'decisions': str(work / 'registry_rebase_decisions.json'), 'absent': absent},
            'matching': {'auto_score': RM.AUTO_SCORE, 'auto_margin': RM.AUTO_MARGIN, 'review_score': RM.REVIEW_SCORE}}
    (work / 'remap_plan.json').write_text(json.dumps(plan, indent=1, default=str), encoding='utf-8')
    (work / 'remap_plan.md').write_text(plan_markdown(plan), encoding='utf-8')
    return plan


def plan_markdown(plan: dict) -> str:
    s = plan['summary']
    lines = ['# RENOVICE update remap plan (step 2)', '',
             f'Build `{plan["build_old"]}` -> `{plan["build_new"]}` (baseline `{plan["baseline"]}`).', '',
             '| Action | Dependencies |', '|---|---:|']
    for a in ('unchanged', 'auto', 'review', 'dropped'):
        lines.append(f'| {a} | {s["actions"].get(a, 0)} |')
    lines += ['', '| Kind | unchanged | auto | review | dropped |', '|---|---:|---:|---:|---:|']
    for k, c in s['by_kind'].items():
        lines.append(f'| {k} | {c.get("unchanged", 0)} | {c.get("auto", 0)} | {c.get("review", 0)} | {c.get("dropped", 0)} |')
    lines += ['', '## Changed modules', '', '| File | Status | Old key | New key | Prototypes |', '|---|---|---|---|---|']
    for m in plan['modules']:
        if m.get('status') != 'unchanged':
            lines.append(f'| {m["file"]} | {m.get("status")} | `{m.get("old_key")}` | `{m.get("new_key")}` | {m.get("kinds", "")} |')
    lines += ['', '## Needs review or dropped', '', '| Kind | Item | Action | Reason |', '|---|---|---|---|']
    for d in plan['dependencies']:
        if d['action'] in ('review', 'dropped'):
            lines.append(f'| {d["kind"]} | {_md(d["id"])} | **{d["action"]}** | {_md(d.get("reason", ""))} |')
    lines += ['', '## Auto with a note (similar match, moved site, stock change)', '',
              '| Kind | Item | Old -> new | Note |', '|---|---|---|---|']
    for d in plan['dependencies']:
        notes = d.get('notes') or ([d['note']] if d.get('note') and d['kind'] not in ('literals.value', 'engine_param',
                                                                                       'addon.lua_call') else [])
        if d['action'] == 'auto' and (d.get('confidence') not in (None, 'exact') or d.get('stock') or notes):
            move = f'{d.get("old", "")} -> {d.get("new", "")}' if d.get('old') is not None else ''
            if d.get('stock'):
                move = f'stock {d["stock"]["old"]} -> {d["stock"]["new"]}'
            lines.append(f'| {d["kind"]} | {_md(d["id"])} | {_md(move)} | {_md("; ".join(notes)[:300])} |')
    return '\n'.join(lines) + '\n'


def _md(t) -> str:
    return str(t).replace('|', '\\|').replace('\n', ' ')
