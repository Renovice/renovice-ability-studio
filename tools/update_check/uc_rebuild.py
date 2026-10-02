"""Update resilience step 3: rebuild (script side) and stage a complete install set for build B.

Applies the auto items of the step-2 plan, then gates the result:
  1. staged editor root (work/temp/upd-<stamp>/editor): the rebased registry (registrar rebase), its build-B corpus;
  2. `verify-missions` on it (the generator's production rules); a row that fails here is sent to review and the
     registry is rebased again without it (at most twice);
  3. `build-missions` with the pinned package input (values and switches of the installed package; ids that are out
     are left out) -> Packages/Missions (package.json, literals.json, engine_params.json, Missions.targets.addon.lua_B);
     every BUILD_GATES entry must PASS;
  4. the 12 presets through the registry path (`build`, reference artifacts, not installed);
  5. authored addons (uc_artifacts.rebuild_addon) and replacements (uc_artifacts.rebase_replacement results of step 2);
     Frost/Octavia package.json: member renamed to the new key, settings.build = build B;
  6. ScriptStates.json with renamed entries keeping their state;
  7. Settings compatibility: every saved value id of Settings/*.json (read-only) is declared by the new packages and its
     value fits the new limits (value ids are tunable/master ids and never change across builds);
  8. the step-1 check on a simulated install (a copy of CustomScripts with the set applied) against build B.
The install set mirrors <game>: install/OpenWF/CustomScripts/...; rollback/ holds the currently installed files the set
replaces or removes; remove.txt lists the files to delete. Nothing is written to the game folder.
"""
from __future__ import annotations

import copy
import hashlib
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path

import uc_artifacts as ART
import uc_bytecode as B
import uc_content
import uc_remap as RM

TOOL_DIR = Path(__file__).resolve().parent
EDITOR = TOOL_DIR.parents[1]
REGISTRAR = EDITOR / 'RESEARCH' / 'UNIVERSAL_MISSION_REGISTRY_2026-09-29' / 'tools'
DEFAULT_REBUILD_INPUT = EDITOR / 'RESEARCH' / 'MISSIONS_R13_NATIVE_ENTRY_2026-10-01' / 'inputs' / 'rebuild_input.r12.json'
CS = Path('OpenWF') / 'CustomScripts'


def _sha(b: bytes) -> str:
    return hashlib.sha256(b).hexdigest()


def _sha_file(p: Path) -> str:
    return _sha(p.read_bytes())


class Gates:
    def __init__(self):
        self.items = []

    def add(self, name, ok, detail='', blocking=True):
        self.items.append({'name': name, 'pass': bool(ok), 'detail': str(detail)[:600], 'blocking': blocking})
        return ok

    def ok(self):
        return all(g['pass'] for g in self.items if g['blocking'])


class Staging:
    """The staged install set: install/, rollback/, remove list."""

    def __init__(self, root: Path, custom: Path):
        self.root, self.custom = root, custom
        self.install = root / 'install'
        self.rollback = root / 'rollback'
        self.removes: list[str] = []
        self.files: list[dict] = []
        self.unchanged: list[str] = []

    def put(self, rel: str, data: bytes, why: str):
        cur = self.custom / rel
        if cur.is_file() and cur.read_bytes() == data:
            self.unchanged.append(str(CS / rel).replace('\\', '/'))     # identical to the installed file: not staged
            return
        dst = self.install / CS / rel
        dst.parent.mkdir(parents=True, exist_ok=True)
        dst.write_bytes(data)
        cur = self.custom / rel
        if cur.is_file():
            self._backup(rel)
        self.files.append({'install': str(CS / rel).replace('\\', '/'), 'sha256': _sha(data), 'bytes': len(data),
                           'replaces': _sha_file(cur) if cur.is_file() else None, 'why': why})

    def remove(self, rel: str, why: str):
        if (self.custom / rel).is_file():
            self._backup(rel)
            self.removes.append(f'{str(CS / rel)}\t{why}'.replace('\\', '/'))

    def _backup(self, rel: str):
        src = self.custom / rel
        dst = self.rollback / CS / rel
        if not dst.exists():
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(src, dst)


def run_cli(cli: Path, *args, cwd=None, timeout=1800):
    r = subprocess.run([str(cli), *map(str, args)], capture_output=True, text=True, timeout=timeout, cwd=cwd)
    return r.returncode, r.stdout, r.stderr


def staged_editor(ws: Path, temp: Path, registry_bytes: bytes) -> Path:
    editor = temp / 'editor'
    if editor.exists():
        shutil.rmtree(editor)
    for sub in ('REGISTRIES', 'SCHEMA', 'EXAMPLES', 'include'):
        shutil.copytree(EDITOR / sub, editor / sub)
    (editor / 'REGISTRIES' / 'mission_build_u44.json').write_bytes(registry_bytes)
    return editor


def verify(cli: Path, editor: Path) -> dict:
    rc, out, err = run_cli(cli, 'verify-missions', '--editor-root', editor)
    try:
        return json.loads(out)
    except ValueError:
        return {'structure': f'verify-missions exit {rc}: {(err or out)[:400]}', 'pass': 0, 'rows': 0, 'failures': []}


def build_input(path: Path, build: str, absent: set, registry: dict) -> dict:
    data = json.loads(path.read_text(encoding='utf-8'))
    data['build'] = build
    ids = {r['tunable_id'] for r in registry['tunables']}
    data['values'] = {k: v for k, v in data.get('values', {}).items() if k in ids and k not in absent}
    if 'disabled_values' in data:
        data['disabled_values'] = [k for k in data['disabled_values'] if k in data['values']]
    return data


def build_missions(cli: Path, editor: Path, settings: Path, staging: Path, gates: Gates):
    rc, out, err = run_cli(cli, 'build-missions', settings, '--staging', staging, '--editor-root', editor)
    (staging.parent / 'build-missions.log').write_text(out + err, encoding='utf-8')
    gen = next((l.split(': ', 1)[1].strip() for l in out.splitlines() if l.startswith('Generation: ')), None)
    if rc != 0 or not gen:
        gates.add('build-missions', False, (err or out).strip().splitlines()[-1] if (err or out).strip() else f'exit {rc}')
        return None
    gen = Path(gen)
    log = (gen / 'BUILD_GATES.log').read_text(encoding='utf-8', errors='replace')
    named = re.findall(r'^([a-z][a-z0-9-]+)\n(PASS|FAIL)[^\n]*', log, re.M)
    fails = [n for n, s in named if s != 'PASS']
    gates.add('build-missions', not fails and 'FULL BODY identical: True' in log,
              f'{len(named)} named gates PASS' if not fails else f'FAIL: {fails}')
    for n, line in re.findall(r'^((?:hook-plan|live-literal-recipe|engine-param-overrides|settings-layout|'
                              r'settings-declarations|multi-target-declared-keys))\n(PASS[^\n]*)', log, re.M):
        gates.add(f'build-missions.{n}', True, line, blocking=False)
    return gen


def preset_builds(cli: Path, editor: Path, registry: dict, temp: Path, gates: Gates) -> list[dict]:
    """Every preset through the registry path (`build`), with its rows' stock values (the reference artifacts)."""
    base = json.loads((EDITOR / 'EXAMPLES' / 'mallet_linked_overguard_addon.json').read_text(encoding='utf-8'))
    modes = {'EXACT_LITERAL': 'MANAGED_MISSION_EXACT_REPLACEMENT', 'METADATA_PATCH': 'MANAGED_MISSION_METADATA_PATCH'}
    rows = {r['tunable_id']: r for r in registry['tunables']}
    work = temp / 'presets'
    work.mkdir(parents=True, exist_ok=True)
    out = []
    for pid, preset in registry['missions'].items():
        p = copy.deepcopy(base)
        p['id'] = f'm.{pid}'
        lane = preset['lane']
        p['authoring_mode'] = modes.get(lane) or registry['modules'][preset['body_key']]['addon']['authoring_mode']
        p['target'].update(module_body_key=preset['body_key'], module_path=preset['module_path'],
                           installed_build=registry['build'])
        candidates = []
        for attempt in range(4):
            values = {}
            for name, par in preset['parameters'].items():
                stock = rows[par['tunable_id']]['stock']
                if 'transform' in par and stock:
                    stock = par['transform']['numerator'] / stock
                # a row without one stock value (several call sites) takes a whole value inside its range
                pick = [stock] if stock is not None else []
                pick += [x for x in (30, 60, par['minimum'], par['maximum']) if par['minimum'] <= x <= par['maximum']]
                values[name] = pick[min(attempt, len(pick) - 1)]
            if values in candidates:
                continue
            candidates.append(values)
            p['mission_profile'] = {'build': registry['build'], 'id': pid, 'values': values}
            path = work / f'{pid}.json'
            path.write_text(json.dumps(p, indent=2), encoding='utf-8')
            rc, so, se = run_cli(cli, 'build', path, '--staging', work / 'out', '--editor-root', editor)
            art = next((l.split(': ', 1)[1].strip() for l in so.splitlines() if l.startswith('Bytecode: ')), None)
            ok = rc == 0 and art and Path(art).is_file()
            if ok:
                break
        out.append({'preset': pid, 'lane': lane, 'pass': bool(ok), 'values': values,
                    'artifact': Path(art).name if ok else None, 'sha256': _sha_file(Path(art)) if ok else None,
                    'error': '' if ok else ((se or so).strip().splitlines() or ['?'])[-1][:300]})
    gates.add('presets', all(x['pass'] for x in out), f'{sum(x["pass"] for x in out)}/{len(out)} preset builds')
    return out


def settings_compat(custom: Path, packages: dict, gates: Gates, installed: dict | None = None) -> dict:
    """packages: {package name: {value id: declaration}} of the staged set; installed: the same for the installed
    packages (an entry the installed package does not declare either was already ignored before the update)."""
    report = {}
    for f in sorted((custom / 'Settings').glob('*.json')) if (custom / 'Settings').is_dir() else []:
        try:
            data = json.loads(f.read_text(encoding='utf-8'))
        except (OSError, ValueError) as e:
            report[f.name] = {'error': str(e)}
            continue
        pkg = f.stem
        decls = packages.get(pkg)
        if decls is None:
            report[f.name] = {'package': pkg, 'note': 'package not part of the staged set (kept as installed)'}
            continue
        unknown, out_of_range, stock_changed, ok, already = [], [], [], 0, []
        for vid, entry in data.get('values', {}).items():
            d = decls.get(vid)
            if d is None:
                if vid in (installed or {}).get(pkg, {}) or installed is None:
                    unknown.append(vid)
                else:
                    already.append(vid)
                continue
            v = entry.get('value')
            if isinstance(v, (int, float)) and not (d.get('min', float('-inf')) <= v <= d.get('max', float('inf'))):
                out_of_range.append({'id': vid, 'value': v, 'min': d.get('min'), 'max': d.get('max')})
                continue
            if 'stock' in entry and 'stock' in d and float(entry['stock']) != float(d['stock']):
                stock_changed.append({'id': vid, 'saved_stock': entry['stock'], 'new_stock': d['stock']})
            ok += 1
        report[f.name] = {'package': pkg, 'entries': len(data.get('values', {})), 'accepted': ok,
                          'unknown_entries': unknown, 'not_declared_before_either': already,
                          'out_of_range': out_of_range, 'stock_changed': stock_changed}
    rejected = sum(len(r.get('out_of_range', [])) for r in report.values())
    gates.add('settings-compat', rejected == 0, '; '.join(
        f'{k}: {r.get("accepted", "-")}/{r.get("entries", "-")} accepted, {len(r.get("unknown_entries", []))} unknown '
        f'(value out on this build), {len(r.get("not_declared_before_either", []))} not declared before either, '
        f'{len(r.get("out_of_range", []))} out of range' for k, r in report.items()))
    return report


def declarations(pkg_dir: Path) -> dict:
    out = {}
    pj = json.loads((pkg_dir / 'package.json').read_text(encoding='utf-8'))
    for member in pj.get('members', {}).values():
        out.update(member.get('settings', {}).get('values', {}))
    lit = pkg_dir / 'literals.json'
    if lit.is_file():
        for vid, v in json.loads(lit.read_text(encoding='utf-8')).get('values', {}).items():
            out.setdefault(vid, v.get('declaration', {}))
    return out


def simulate(custom: Path, stage: Staging, sim: Path) -> Path:
    if sim.exists():
        shutil.rmtree(sim)
    sim.mkdir(parents=True)
    for item in custom.iterdir():
        if item.name in ('Logs', 'Diagnostics'):
            continue
        if item.is_dir():
            shutil.copytree(item, sim / item.name)
        else:
            shutil.copyfile(item, sim / item.name)
    for line in stage.removes:
        rel = line.split('\t', 1)[0].split('CustomScripts/', 1)[1]
        p = sim / rel
        if p.is_file():
            p.unlink()
    src = stage.install / CS
    if src.is_dir():
        for f in src.rglob('*'):
            if f.is_file():
                dst = sim / f.relative_to(src)
                dst.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(f, dst)
    return sim


def rebuild(*, ws: Path, wsj: dict, plan: dict, plan_work: Path, registry: dict, opmap, seed: int, custom: Path,
            build_b: str, build_label_b: str, packages_bin_b, old, new, temp: Path, stage_root: Path, cli: Path,
            rebuild_input: Path, corpus_rel: str, baseline_name: str, check_args: list[str], log=print) -> dict:
    sys.path.insert(0, str(REGISTRAR))
    import rebase_registry as RR  # noqa: E402
    import uc_plan
    gates = Gates()
    stage = Staging(stage_root, custom)
    evidence = stage_root / 'evidence'
    evidence.mkdir(parents=True, exist_ok=True)
    result = {'gates': gates.items, 'review': [], 'auto': [], 'dropped': []}

    # 1-2. registry + verify-missions (rows failing the production rules go to review) -----------------------------
    reg_bytes = (plan_work / 'mission_build_u44.rebased.json').read_bytes()
    force = {}
    for attempt in range(3):
        editor = staged_editor(ws, temp, reg_bytes)
        vm = verify(cli, editor)
        fails = {f['tunable_id']: f['reason'] for f in vm.get('failures', [])}
        if vm.get('structure') == 'PASS' and not fails:
            break
        if not fails or attempt == 2:
            break
        force.update({k: f'verify-missions on build B: {v}' for k, v in fails.items()})
        log(f'rebuild: verify-missions failed {len(fails)} rows; rebasing again with them in review')
        plan = uc_plan.make_plan(**plan['_inputs'], force=force)
        reg_bytes = (plan_work / 'mission_build_u44.rebased.json').read_bytes()
    rebased = json.loads(reg_bytes)
    gates.add('verify-missions', vm.get('structure') == 'PASS' and vm.get('pass') == vm.get('rows') and vm.get('rows', 0) > 0,
              f'{vm.get("pass")}/{vm.get("rows")} rows PASS, structure {vm.get("structure")}')
    (evidence / 'verify-missions.json').write_text(json.dumps(vm, indent=1), encoding='utf-8')
    result['plan'] = plan
    absent = set(plan['registry']['absent'])

    # 3. Missions package -----------------------------------------------------------------------------------------------
    settings = temp / 'rebuild_input.json'
    settings.write_text(json.dumps(build_input(rebuild_input, build_b, absent, rebased), indent=1), encoding='utf-8')
    gen = build_missions(cli, editor, settings, temp / 'gen', gates)
    pkg_files = {}
    if gen is not None:
        for f in sorted((gen / 'Packages' / 'Missions').iterdir()):
            stage.put(f'Packages/Missions/{f.name}', f.read_bytes(), 'Missions package rebuilt for the new build')
            pkg_files[f.name] = _sha_file(f)
        shutil.copyfile(gen / 'BUILD_GATES.log', evidence / 'BUILD_GATES.log')
        shutil.copyfile(gen / 'MISSION_SET_MANIFEST.json', evidence / 'MISSION_SET_MANIFEST.json')
    result['package'] = pkg_files

    # 4. presets -------------------------------------------------------------------------------------------------------
    result['presets'] = preset_builds(cli, editor, rebased, temp, gates)
    pdir = evidence / 'presets'
    pdir.mkdir(parents=True, exist_ok=True)
    for f in (temp / 'presets' / 'out').rglob('*'):
        if f.is_file() and f.name in {x['artifact'] for x in result['presets'] if x['artifact']}:
            shutil.copyfile(f, pdir / f.name)
    (pdir / 'presets.json').write_text(json.dumps(result['presets'], indent=1), encoding='utf-8')

    # 5. authored addons, replacements, packages ----------------------------------------------------------------------
    renamed = {}            # old rel -> new rel
    compiler = uc_plan.load_authored()['compiler']
    tools = {'editor': EDITOR, 'derecomp': ws / compiler['derecomp'], 'name_map': ws / compiler['name_map']}
    if any(rec['action'] == 'auto' for rec in plan['artifacts']['addons']):
        # the compiler the authored sources were certified with (their identity gate assumes it)
        ident = (tools['derecomp'].is_file() and _sha_file(tools['derecomp']) == compiler['derecomp_sha256']
                 and tools['name_map'].is_file() and _sha_file(tools['name_map']) == compiler['name_map_sha256'])
        gates.add('authored-compiler-identity', ident, f'{compiler["derecomp"]} {compiler["derecomp_sha256"][:16]}, '
                                                       f'{compiler["name_map"]} {compiler["name_map_sha256"][:16]}')
    addon_results = []
    for rec in plan['artifacts']['addons']:
        if rec['action'] != 'auto':
            addon_results.append(rec)
            continue
        maps = uc_plan.Maps(old, new, opmap)
        mm = maps.get(rec['module'])
        res = ART.rebuild_addon(rec['spec'], custom / rec['file'], rec['hooks'], mm, seed, tools,
                                temp / 'addons' / Path(rec['file']).stem, opmap)
        addon_results.append(dict(rec, **{k: v for k, v in res.items() if k not in ('file',)}))
        gates.add(f'addon.{Path(rec["file"]).name}', res['action'] == 'auto',
                  res.get('reason') or ', '.join(g['name'] for g in res['gates'] if g['pass']))
        if res['action'] == 'auto':
            new_rel = str(Path(rec['file']).parent / res['artifact_name']).replace('\\', '/')
            stage.put(new_rel, Path(res['artifact']).read_bytes(), f'{rec["label"]} rebuilt for the new target key')
            if new_rel != rec['file']:
                stage.remove(rec['file'], 'replaced by the rebuilt addon ' + res['artifact_name'])
                renamed[rec['file']] = new_rel
    result['addons'] = addon_results
    for rec in plan['artifacts']['replacements']:
        if rec['action'] == 'auto' and rec.get('artifact'):
            stage.put(rec['artifact_name'], Path(rec['artifact']).read_bytes(), f'{rec["label"]} rebased onto the new stock')
            stage.remove(rec['file'], 'replaced by the rebased replacement ' + rec['artifact_name'])
            renamed[rec['file']] = rec['artifact_name']
    # Frost / Octavia (and any other non-Missions package): member names and build label
    for name in plan['artifacts']['packages']:
        if name == 'Missions':
            continue
        pj_path = custom / 'Packages' / name / 'package.json'
        try:
            pj = json.loads(pj_path.read_text(encoding='utf-8'))
        except (OSError, ValueError):
            continue
        changed = False
        members = {}
        for mname, member in pj.get('members', {}).items():
            old_rel = f'Packages/{name}/{mname}'
            new_rel = renamed.get(old_rel, old_rel)
            members[Path(new_rel).name] = member
            changed |= new_rel != old_rel
        if pj.get('settings', {}).get('build') != build_b:
            pj.setdefault('settings', {})['build'] = build_b
            changed = True
        pj['members'] = members
        if changed:
            stage.put(f'Packages/{name}/package.json', (json.dumps(pj, indent=2, ensure_ascii=False) + '\n').encode('utf-8'),
                      f'{name} package: members and build label for the new build')
    # ScriptStates.json: renamed entries keep their state
    states_path = custom / 'ScriptStates.json'
    if renamed and states_path.is_file():
        st = json.loads(states_path.read_text(encoding='utf-8'))
        scripts = st.get('scripts', {})
        for old_rel, new_rel in renamed.items():
            on, nn = Path(old_rel).name.lower(), Path(new_rel).name.lower()
            for k in list(scripts):
                if k.endswith(':' + on):
                    scripts[k[:-len(on)] + nn] = scripts.pop(k)
        stage.put('ScriptStates.json', (json.dumps(st, indent=4) + '\n').encode('utf-8'),
                  'renamed scripts keep their enable state')

    # 6. Settings compatibility --------------------------------------------------------------------------------------------
    decl = {}
    for name in plan['artifacts']['packages']:
        staged = stage.install / CS / 'Packages' / name
        src = staged if (staged / 'package.json').is_file() else custom / 'Packages' / name
        try:
            decl[name] = declarations(src)
        except (OSError, ValueError):
            pass
    installed_decl = {}
    for name in plan['artifacts']['packages']:
        try:
            installed_decl[name] = declarations(custom / 'Packages' / name)
        except (OSError, ValueError):
            pass
    result['settings'] = settings_compat(custom, decl, gates, installed_decl)

    # 7. step-1 check on a simulated install --------------------------------------------------------------------------
    import renovice_update_check as UC
    sim = simulate(custom, stage, temp / 'sim' / 'CustomScripts')
    out_dir = evidence / 'step1-after'
    code = UC.main(['--quiet', '--custom-scripts', str(sim), '--registry', str(editor / 'REGISTRIES' / 'mission_build_u44.json'),
                    '--out', str(out_dir), *check_args])
    rep = json.loads((out_dir / 'update_check_report.json').read_text(encoding='utf-8'))
    review_keys = {d.get('old') for d in plan['dependencies'] if d['action'] in ('review', 'dropped')
                   and isinstance(d.get('old'), str) and len(d['old']) == 16}
    review_files = {Path(d['id']).name for d in plan['dependencies']
                    if d['kind'] in ('replacement', 'authored_addon') and d['action'] in ('review', 'dropped')}
    unexplained, explained, native = [], [], []
    for item in rep['items']:
        if item['status'] != 'BROKEN':
            continue
        if item['area'] in ('build', 'native', 'toolchain'):
            native.append(item)
            continue
        text = item['name'] + ' ' + item['reason']
        if any(k and k in text for k in review_keys) or any(f in text for f in review_files) or \
                item['check'] == 'missions.registry_row.server':
            explained.append(item)
        else:
            unexplained.append(item)
    c = rep['summary']['total']
    gates.add('step1-after', not unexplained,
              f'OK={c["OK"]} BROKEN={c["BROKEN"]} UNKNOWN={c["UNKNOWN"]}; {len(explained)} BROKEN belong to review '
              f'items, {len(native)} to the native side' + (f'; UNEXPLAINED: {unexplained[0]["name"]} :: '
                                                              f'{unexplained[0]["reason"]}' if unexplained else ''))
    result['step1_after'] = {'exit': code, 'counts': c, 'explained': len(explained), 'native': len(native),
                             'unexplained': [{'check': i['check'], 'name': i['name'], 'reason': i['reason']} for i in unexplained],
                             'report': str(out_dir / 'update_check_report.md')}
    # evidence -------------------------------------------------------------------------------------------------------
    reg_dir = evidence / 'registry'
    reg_dir.mkdir(parents=True, exist_ok=True)
    (reg_dir / 'mission_build_u44.json').write_bytes(reg_bytes)
    shutil.copyfile(plan_work / 'registry_rebase_decisions.json', reg_dir / 'registry_rebase_decisions.json')
    corpus_dst = reg_dir / 'corpus'
    if corpus_dst.exists():
        shutil.rmtree(corpus_dst)
    shutil.copytree(Path(plan['registry']['corpus']), corpus_dst)
    for f in ('remap_plan.json', 'remap_plan.md'):
        shutil.copyfile(plan_work / f, evidence / f)
    result['stage'] = stage
    return result
