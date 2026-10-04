#!/usr/bin/env python3
"""RENOVICE update: one command after a Warframe update (update resilience steps 1-3 + the native side).

    python repos/apps/ability-editor/tools/update_check/renovice_update.py

1. Step 1, the post-update check (renovice_update_check.py) on the installed client: what broke and why.
2. Step 2, the script remap (uc_plan.py): every script-level dependency mapped from the last certified build A (the
   baseline and its stock pack) to the installed build B, with auto / review / dropped and the reason.
3. Step 3, the script rebuild (uc_rebuild.py): rebased registry -> verify-missions -> Missions package, presets,
   authored addons, rebased replacements, package labels, script states; Settings compatibility; step 1 again on a
   simulated install of the result.
4. The native side through work/research/update-resilience/NATIVE_INTERFACE.md (bootstrapper repository): signature and
   per-build table update and, with --native-build, the DLL. Missing = pending, the script set stays complete.
5. One staged install set: work/staging/update-<build>-<time>/ with README.md (install, rollback), UPDATE_REPORT.md,
   install/ (mirrors the game folder), rollback/, remove.txt, SHA256SUMS, evidence/.

The game folder is only read. Nothing is installed, pushed or committed. After the live test, --adopt <stage folder>
makes the rebased registry and its corpus the repository's current ones (then write the new baseline with
renovice_update_check.py --write-baseline and commit).

Exit code: 0 everything auto and every gate PASS; 1 staged, some items need review (they stay at the game's values);
2 a gate failed (do not install); 3 the tool failed.
"""
from __future__ import annotations

import argparse
import datetime
import hashlib
import json
import os
import shutil
import sys
import time
import traceback
from pathlib import Path

TOOL_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(TOOL_DIR))

import renovice_update_check as UC  # noqa: E402
import uc_bytecode as B  # noqa: E402
import uc_cache  # noqa: E402
import uc_native_iface as NATIVE  # noqa: E402
import uc_pe  # noqa: E402
import uc_plan  # noqa: E402
import uc_rebuild  # noqa: E402

EDITOR = TOOL_DIR.parents[1]
REPORT_FORMAT = 'RENOVICE_UPDATE_RESULT_V1'


def sha_file(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description=__doc__.split('\n\n')[0])
    ap.add_argument('--game', type=Path, default=UC.DEFAULT_GAME, help='installed Warframe folder (read only)')
    ap.add_argument('--exe', type=Path, help='client executable (default <game>/Warframe.x64.exe)')
    ap.add_argument('--custom-scripts', type=Path, help='installed CustomScripts (default <game>/OpenWF/CustomScripts)')
    ap.add_argument('--stock-dir', type=Path, help='build-B modules folder instead of the Cache.Windows extraction')
    ap.add_argument('--stock-overlay', type=Path, help='modules here replace the same-named build-B modules')
    ap.add_argument('--baseline', type=Path, help='baseline of build A (default: the newest in tools/update_check/baselines)')
    ap.add_argument('--out', type=Path, help='stage folder (default work/staging/update-<build>-<time>)')
    ap.add_argument('--rebuild-input', type=Path, default=uc_rebuild.DEFAULT_REBUILD_INPUT,
                    help='pinned Missions package input (values and switches of the installed package)')
    ap.add_argument('--bootstrapper-root', type=Path, help='bootstrapper tree holding the native entry (default: WORKSPACE.json)')
    ap.add_argument('--bootstrapper-ref', default='main')
    ap.add_argument('--native-build', action='store_true', help='let the native side apply its auto items and build the DLL')
    ap.add_argument('--skip-native', action='store_true')
    ap.add_argument('--skip-step1', action='store_true', help='do not run the step-1 check before the remap')
    ap.add_argument('--adopt', type=Path, help='adopt a staged set\'s rebased registry and corpus into the repository')
    ap.add_argument('--keep-temp', action='store_true', help='keep work/temp/upd-<time> (staged editor root, generator, '
                                                            'simulated install) after the run')
    ap.add_argument('--quiet', action='store_true')
    args = ap.parse_args(argv)
    log = (lambda *a, **k: None) if args.quiet else (lambda *a, **k: print(*a, **k, file=sys.stderr))
    try:
        if args.adopt:
            return adopt(args.adopt, log)
        return run(args, log)
    except SystemExit:
        raise
    except Exception:  # noqa: BLE001
        traceback.print_exc()
        return 3


def run(args, log) -> int:
    t0 = time.time()
    ws = UC.workspace_root()
    wsj = json.loads((ws / 'WORKSPACE.json').read_text(encoding='utf-8'))
    game = args.game
    exe = args.exe or game / 'Warframe.x64.exe'
    custom = args.custom_scripts or game / 'OpenWF' / 'CustomScripts'
    img = uc_pe.Image(exe.read_bytes())
    build_b = img.product_version() or 'unknown'
    stamp = datetime.datetime.now().strftime('%Y%m%d-%H%M%S')
    temp = ws / wsj['work']['temp'] / f'upd-{stamp}'
    stage = args.out or ws / wsj['work']['staging'] / f'update-{build_b}-{stamp}'
    if str(stage.resolve()).lower().startswith(str(game.resolve()).lower()):
        raise SystemExit('refusing to stage inside the game folder')
    stage.mkdir(parents=True, exist_ok=True)
    temp.mkdir(parents=True, exist_ok=True)
    opmap = B.load_opcode_profile((ws / wsj['repos']['de_luau_toolchain'] / 'src' / 'de_opcode_profile.h').read_text())
    oodle = ws / wsj['vendor']['misc_tools'] / 'warframe-cache-tools' / 'lib' / 'oo2core_9.dll'
    cache = ws / wsj['work']['temp'] / 'update-check'
    if args.stock_dir:
        folder = args.stock_dir
    else:
        folder, _ = uc_cache.extract_stock(game, cache, oodle, log)
    new = uc_plan.NewStock(folder, args.stock_overlay)
    baseline, baseline_name = UC.load_baseline(args.baseline, build_b, log)
    baseline_path = args.baseline or UC.BASELINES / baseline_name
    if not baseline.get('stock_pack'):
        raise SystemExit(f'baseline {baseline_name} has no stock pack (format V1): rewrite it with --write-baseline on the '
                         'certified build first')
    registry_path = EDITOR / 'REGISTRIES' / 'mission_build_u44.json'
    registry = json.loads(registry_path.read_text(encoding='utf-8'))
    old = uc_plan.OldStock(ws, baseline, registry)
    try:
        pbin = uc_cache.extract_named(game, 'H.Misc.toc', '/Packages.bin', oodle)
        packages_bin = hashlib.sha256(pbin).hexdigest() if pbin else None
    except Exception:  # noqa: BLE001
        pbin, packages_bin = None, None
    build_label = registry['build_label'] if build_b == registry['build'] else f'client {build_b}'
    seed = int(registry['name_hash_seed'], 16)
    check_args = ['--game', str(game), '--exe', str(exe), '--baseline', str(baseline_path),
                  '--bootstrapper-ref', args.bootstrapper_ref]
    if args.stock_dir:
        check_args += ['--stock-dir', str(args.stock_dir)]
    if args.stock_overlay:
        check_args += ['--stock-overlay', str(args.stock_overlay)]
    evidence = stage / 'evidence'
    report = {'format': REPORT_FORMAT, 'build_old': registry['build'], 'build_new': build_b, 'stage': str(stage),
              'exe_sha256': sha_file(exe), 'baseline': baseline_name, 'registry_sha256': sha_file(registry_path),
              'packages_bin_sha256': packages_bin, 'started': datetime.datetime.now().isoformat(timespec='seconds'),
              'tool_commit': UC.git_head(EDITOR)}

    # 1. step 1 -----------------------------------------------------------------------------------------------------------
    if not args.skip_step1:
        log('step 1: post-update check')
        code = UC.main(['--quiet', '--out', str(evidence / 'step1-before'), '--custom-scripts', str(custom), *check_args])
        rep = json.loads((evidence / 'step1-before' / 'update_check_report.json').read_text(encoding='utf-8'))
        report['step1_before'] = {'exit': code, 'counts': rep['summary']['total'],
                                  'report': str(evidence / 'step1-before' / 'update_check_report.md')}

    # 2. step 2 -----------------------------------------------------------------------------------------------------------
    log('step 2: remap plan')
    plan_work = temp / 'plan'
    corpus_rel = os.path.relpath(plan_work / 'corpus', ws).replace('\\', '/')
    inputs = dict(ws=ws, wsj=wsj, baseline=baseline, baseline_name=baseline_name, registry=registry, old=old, new=new,
                  custom=custom, opmap=opmap, seed=seed, build_b=build_b, build_label_b=build_label,
                  packages_bin_b=packages_bin, packages_bin_data=pbin, work=plan_work, corpus_rel=corpus_rel, temp=cache,
                  log=log)
    plan = uc_plan.make_plan(**inputs)
    plan['_inputs'] = inputs

    # 3. step 3 -----------------------------------------------------------------------------------------------------------
    log('step 3: rebuild')
    cli = ws / wsj['work']['builds'] / 'ability-editor' / 'current' / 'bin' / 'renovice_ability_editor_cli.exe'
    result = uc_rebuild.rebuild(ws=ws, wsj=wsj, plan=plan, plan_work=plan_work, registry=registry, opmap=opmap, seed=seed,
                                custom=custom, build_b=build_b, build_label_b=build_label, packages_bin_b=packages_bin,
                                old=old, new=new, temp=temp, stage_root=stage, cli=cli, rebuild_input=args.rebuild_input,
                                corpus_rel=corpus_rel, baseline_name=baseline_name, check_args=check_args, log=log)
    plan = result['plan']
    staging = result['stage']

    # 4. native side ------------------------------------------------------------------------------------------------------
    native = {'status': 'SKIPPED'}
    if not args.skip_native:
        repo = args.bootstrapper_root or ws / wsj['repos']['bootstrapper_runtime']
        native = NATIVE.run(ws, repo, game, exe, evidence / 'native', args.native_build, log)
        for f in native.get('files', []):
            dst = staging.root / 'install' / f['install_path']
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(f['source'], dst)
            cur = game / f['install_path']
            if cur.is_file():
                rb = staging.root / 'rollback' / f['install_path']
                rb.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(cur, rb)
            staging.files.append({'install': f['install_path'].replace('\\', '/'), 'sha256': f['sha256'],
                                  'bytes': f['bytes'], 'replaces': sha_file(cur) if cur.is_file() else None,
                                  'why': 'native side (bootstrapper)'})

    # 5. combined set and report ------------------------------------------------------------------------------------------
    deps = plan['dependencies']
    review = [d for d in deps if d['action'] in ('review', 'dropped')]
    report.update(
        seconds=round(time.time() - t0, 1),
        plan={'summary': plan['summary'], 'json': str(evidence / 'remap_plan.json'), 'md': str(evidence / 'remap_plan.md')},
        gates=result['gates'], package=result.get('package'), presets=result.get('presets'),
        addons=[{k: v for k, v in a.items() if k not in ('spec', 'hooks')} for a in result.get('addons', [])],
        replacements=plan['artifacts']['replacements'], settings=result.get('settings'),
        step1_after=result.get('step1_after'), native=native, files=staging.files, remove=staging.removes,
        review=review)
    gates_ok = all(g['pass'] for g in result['gates'] if g['blocking'])
    report['result'] = 'GATE FAILED' if not gates_ok else ('REVIEW' if review else 'ALL AUTO')
    exit_code = 2 if not gates_ok else (1 if review else 0)
    report['exit_code'] = exit_code
    (stage / 'remove.txt').write_text(''.join(l + '\n' for l in staging.removes), encoding='utf-8')
    (stage / 'UPDATE_REPORT.json').write_text(json.dumps(report, indent=1, default=str), encoding='utf-8')
    (stage / 'UPDATE_REPORT.md').write_text(report_markdown(report, plan), encoding='utf-8')
    (stage / 'README.md').write_text(readme(report, game), encoding='utf-8')
    sums = []
    for f in sorted(p for p in stage.rglob('*') if p.is_file() and p.name != 'SHA256SUMS'):
        sums.append(f'{sha_file(f)}  {f.relative_to(stage).as_posix()}')
    (stage / 'SHA256SUMS').write_text('\n'.join(sums) + '\n', encoding='utf-8')
    if not args.keep_temp:
        shutil.rmtree(temp, ignore_errors=True)       # everything the set needs is in the stage (evidence folder)
    a = plan['summary']['actions']
    print(f'RENOVICE UPDATE {registry["build"]} -> {build_b}: {report["result"]} (exit {exit_code}); '
          f'dependencies unchanged={a.get("unchanged", 0)} auto={a.get("auto", 0)} review={a.get("review", 0)} '
          f'dropped={a.get("dropped", 0)}; gates {sum(g["pass"] for g in result["gates"])}/{len(result["gates"])} PASS; '
          f'native {native.get("status")}; stage {stage}')
    return exit_code


def report_markdown(r: dict, plan: dict) -> str:
    s = plan['summary']
    a = s['actions']
    L = [f'# RENOVICE update report: {r["build_old"]} -> {r["build_new"]}', '',
         f'**{r["result"]}** (exit {r["exit_code"]}). Stage `{r["stage"]}`. Baseline `{r["baseline"]}`, tool `{r["tool_commit"]}`, '
         f'{r["seconds"]} s.', '']
    if r.get('step1_before'):
        c = r['step1_before']['counts']
        L += [f'- Step 1 before the rebuild (installed set on the new client): OK={c["OK"]} BROKEN={c["BROKEN"]} '
              f'UNKNOWN={c["UNKNOWN"]} ([report]({r["step1_before"]["report"]})).']
    if r.get('step1_after'):
        c = r['step1_after']['counts']
        L += [f'- Step 1 on a simulated install of this set: OK={c["OK"]} BROKEN={c["BROKEN"]} UNKNOWN={c["UNKNOWN"]}; '
              f'{r["step1_after"]["explained"]} BROKEN belong to review items, {r["step1_after"]["native"]} to the native side, '
              f'{len(r["step1_after"]["unexplained"])} unexplained.']
    L += [f'- Script dependencies: unchanged {a.get("unchanged", 0)}, auto {a.get("auto", 0)}, review {a.get("review", 0)}, '
          f'dropped {a.get("dropped", 0)}; stock values changed: {s["stock_changes"]}; value ids not in this set: '
          f'{len(s["absent_value_ids"])}.',
          f'- Native side: {r["native"].get("status")} {r["native"].get("reason", "")}', '',
          '## Gates', '', '| Gate | Result | Detail |', '|---|---|---|']
    for g in r['gates']:
        L.append(f'| {g["name"]} | {"PASS" if g["pass"] else ("FAIL" if g["blocking"] else "note")} | {_md(g["detail"])} |')
    L += ['', '## Auto-fixed', '', '| Kind | Item | Old -> new | Note |', '|---|---|---|---|']
    for d in plan['dependencies']:
        if d['action'] != 'auto' or d['kind'] in ('literals.value', 'engine_param', 'addon.lua_call', 'module'):
            continue
        move = f'stock {d["stock"]["old"]} -> {d["stock"]["new"]}; ' if d.get('stock') else ''
        move += d.get('moves') or (f'{d.get("old")} -> {d.get("new")}' if d.get('old') is not None else '')
        note = '; '.join(d.get('notes') or ([d['note']] if d.get('note') else []))
        L.append(f'| {d["kind"]} | {_md(d["id"])} | {_md(move)} | {_md(note[:240])} |')
    regen = sum(1 for d in plan['dependencies'] if d['kind'] in ('literals.value', 'engine_param', 'addon.lua_call')
                and d['action'] == 'auto')
    L += ['', f'Regenerated from the rebased registry (literals.json values, engine_params.json overrides, luaCalls of the '
              f'Missions addon): {regen} items, listed in the plan.', '',
          '## Needs review (not carried over; these stay at the game\'s own values)', '',
          '| Kind | Item | Action | Reason |', '|---|---|---|---|']
    for d in r['review']:
        L.append(f'| {d["kind"]} | {_md(d["id"])} | **{d["action"]}** | {_md(d.get("reason", ""))} |')
    L += ['', '## Settings compatibility', '']
    for name, s2 in (r.get('settings') or {}).items():
        L.append(f'- `{name}`: {s2.get("accepted", "-")}/{s2.get("entries", "-")} accepted; unknown (value out on this '
                 f'build): {", ".join(s2.get("unknown_entries", [])) or "none"}; out of range: '
                 f'{len(s2.get("out_of_range", []))}; saved stock differs: {len(s2.get("stock_changed", []))}.')
    L += ['', '## Files', '', '| Install path | Bytes | SHA-256 | Replaces | Why |', '|---|---:|---|---|---|']
    for f in r['files']:
        L.append(f'| `{f["install"]}` | {f["bytes"]} | `{f["sha256"][:16]}…` | {("`" + f["replaces"][:16] + "…`") if f["replaces"] else "new"} | {_md(f["why"])} |')
    if r['remove']:
        L += ['', 'Remove (superseded by a renamed file):', ''] + [f'- `{x.split(chr(9))[0]}` ({x.split(chr(9))[1]})' for x in r['remove']]
    return '\n'.join(L) + '\n'


def readme(r: dict, game: Path) -> str:
    rel = r['stage']
    L = [f'# RENOVICE update set for client {r["build_new"]} (staged, not installed)', '',
         f'Made by `renovice_update.py` from build `{r["build_old"]}`. Result: **{r["result"]}**. Full report: '
         '`UPDATE_REPORT.md`; the remap plan: `evidence/remap_plan.md`. Nothing was written to the game folder.', '']
    if r['result'] == 'GATE FAILED':
        L += ['**Do not install this set: a gate failed (see UPDATE_REPORT.md).**', '']
    if r['review']:
        L += [f'{len(r["review"])} items need review and are NOT in this set. Their values stay at the game\'s own values '
              '(the runtime fails closed on anything not re-pinned); your saved settings for them are kept and ignored '
              'until the owner is re-derived.', '']
    nat = r['native']
    if nat.get('files'):
        L += [f'**Native side:** {nat.get("status")}; the DLL and Hotfix.owf of this set are listed below.', '']
    elif nat.get('status') == 'OK':
        L += ['**Native side:** OK, nothing to rebuild (the installed DLL accepts this client; native report in '
              '`evidence\\native\\`).', '']
    else:
        L += ['**Native side:** no DLL in this set (' + str(nat.get('reason') or nat.get('status')) +
              '). The bootstrapper must accept this client before anything here runs: run with `--native-build` '
              '(and `--bootstrapper-root <native worktree>`) or see the native report.', '']
    L += ['## Install (game closed)', '',
          f'Paths are relative to `<game>` = `{game}`.', '',
          '1. Close the game. Keep your Steam-folder backup copy (made before the update).',
          '2. Copy everything under `install\\` over `<game>\\` (same relative paths, replace).',
          '3. Delete the files listed in `remove.txt` (old file names of renamed scripts).',
          '4. Optional check: `Get-FileHash` of each copied file equals the SHA-256 in the table below.', '',
          '| Install path | SHA-256 |', '|---|---|']
    for f in r['files']:
        L.append(f'| `{f["install"]}` | `{f["sha256"]}` |')
    L += ['', '## Rollback (game closed)', '',
          '1. Delete the files this set added (the rows above whose "Replaces" column in UPDATE_REPORT.md is "new").',
          '2. Copy everything under `rollback\\` back over `<game>\\` (the files as installed before).', '',
          '## Short live test', '',
          '1. Start the game; `<game>\\OpenWF\\CustomScripts\\Logs\\renovice_source.log` shows the packages accepted '
          '(`SETTINGS PACKAGE … rejected=0`, `LIVE LITERALS RECIPE ACCEPT`, `ENGINE PARAMS RECIPE ACCEPT`, `PACKAGE ACCEPT`).',
          '2. Play one mission of a type whose script changed (UPDATE_REPORT.md, "Auto-fixed") with one value set; check it '
          'applies; check one adjacent stock behaviour.',
          '3. Octavia Mallet / Ice Wave / Elite Sanctuary, if rebuilt: one cast / one Onslaught launch.',
          '4. Send both logs (`renovice_source.log`, `%LOCALAPPDATA%\\Warframe\\EE.log`).', '',
          '## After the live test passes', '',
          f'`python repos\\apps\\ability-editor\\tools\\update_check\\renovice_update.py --adopt "{rel}"` makes the rebased '
          'registry and its corpus the repository\'s current ones; then '
          '`renovice_update_check.py --write-baseline` stores the new baseline; commit both.', '']
    return '\n'.join(L) + '\n'


def adopt(stage: Path, log) -> int:
    """Copy a staged set's rebased registry (and its build-B corpus) into the repository. Never touches the game."""
    sys.path.insert(0, str(uc_plan.REGISTRAR))
    import rebase_registry as RR
    ws = UC.workspace_root()
    report = json.loads((stage / 'UPDATE_REPORT.json').read_text(encoding='utf-8'))
    if report['result'] == 'GATE FAILED':
        raise SystemExit('adopt: the staged set failed a gate')
    reg_path = EDITOR / 'REGISTRIES' / 'mission_build_u44.json'
    if sha_file(reg_path) != report['registry_sha256']:
        raise SystemExit('adopt: the repository registry changed since this set was made; run the update again')
    reg = json.loads((stage / 'evidence' / 'registry' / 'mission_build_u44.json').read_text(encoding='utf-8'))
    corpus_rel = f'shared/corpus/de-luau-{reg["build"]}-authoring'
    dst = ws / corpus_rel
    if dst.exists() and any(dst.iterdir()):
        raise SystemExit(f'adopt: {corpus_rel} exists already')
    shutil.copytree(stage / 'evidence' / 'registry' / 'corpus', dst)
    reg['corpus'] = corpus_rel
    reg_path.write_bytes(RR.dump(reg))
    print(f'adopted: {reg_path} (build {reg["build"]}), corpus {corpus_rel}; next: renovice_update_check.py --write-baseline')
    return 0


def _md(t) -> str:
    return str(t).replace('|', '\\|').replace('\n', ' ')


if __name__ == '__main__':
    sys.exit(main())
