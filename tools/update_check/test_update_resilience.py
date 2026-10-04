#!/usr/bin/env python3
"""Regression test of update resilience steps 2-3 (script side): a synthetic "new build" made from COPIES of the
installed 44.0.2 stock modules must be remapped, rebuilt and gated by the one command (renovice_update.py).

No old game build is used (workspace rule) and the game folder is only read: every mutation is made from the current
build's own bytes and served through --stock-overlay from <workspace>/work/temp/update-resilience-test/.

Cases (one synthetic build holding all of them, plus a control run on the unchanged install):
  control              no mutation: every dependency unchanged, every gate PASS, nothing to install (exit 0)
  inserted-prototypes  SurvivalMission: 3 new functions inserted first (every prototype +3, like U44 Survival 64 -> 67):
                       root-table rows, hook plans and the Survival preset template follow (auto, exact)
                       IceSpike: 2 new functions first: the Ice Wave addon callsites move P7 -> P9 (rebuilt, auto)
                       BardAmplify: 1 new function first: the Amp replacement's edit moves P11 -> P12 (rebased, auto)
  moved-literal        Arbitration: a new pool string moves every byte offset (same values, prototypes and indices):
                       the resurrection score cap's 10 sites are re-pinned at their new offsets (auto, exact)
  changed-default      Rescue P8 i20 LOADN 90 -> 100 with the code around it unchanged: the registry stock of
                       rescue.hostage_timer.easy becomes 100 (auto, STOCK_CHANGED)
  changed-context      WaveDefend: one of the 15 Duviri wave-count copies 3 -> 4: the sites disagree (review)
  moved-callsite       BardMusic P16: 3 instructions inserted before i560: the Mallet PushFloatArg callsite i596 -> i599
                       (addon rebuilt from its source, renamed to the new key) and the No Cover replacement edits
                       i568/i570 -> i571/i573 (rebased)
  removed-function     TerritoryMission without P35: the Interception score-rate row and preset and every owner read
                       in P35 are dropped
  ambiguous            CaptureNew P17 changed (one number) and a near copy added as another child of the root: two
                       candidates score alike (review)
  full-rewrite         OmegaRerollSelection changed: the Riven lock replacement is a full rewrite (review, source project)
  unchanged            every other module, e.g. MissionRequirementUtilities (Elite Sanctuary addon stays as installed)

    python repos/apps/ability-editor/tools/update_check/test_update_resilience.py
Exit code 0 when every expectation holds.
"""
from __future__ import annotations

import json
import shutil
import sys
from pathlib import Path

TOOL = Path(__file__).resolve().parent
sys.path.insert(0, str(TOOL))
import renovice_update as RU  # noqa: E402
import renovice_update_check as UC  # noqa: E402
import uc_bytecode as B  # noqa: E402
import uc_cache  # noqa: E402
import uc_pe  # noqa: E402
import uc_synthetic as S  # noqa: E402

GAME = UC.DEFAULT_GAME


def main() -> int:
    ws = UC.workspace_root()
    wsj = json.loads((ws / 'WORKSPACE.json').read_text(encoding='utf-8'))
    oodle = ws / wsj['vendor']['misc_tools'] / 'warframe-cache-tools' / 'lib' / 'oo2core_9.dll'
    stock, _ = uc_cache.extract_stock(GAME, ws / wsj['work']['temp'] / 'update-check', oodle, lambda *a: None)
    opmap = B.load_opcode_profile((ws / wsj['repos']['de_luau_toolchain'] / 'src' / 'de_opcode_profile.h').read_text())
    registry = json.loads((TOOL.parents[1] / 'REGISTRIES' / 'mission_build_u44.json').read_text(encoding='utf-8'))
    rows = {r['tunable_id']: r for r in registry['tunables']}
    # Every expectation is relative to the certified build: the installed client must be the registry's build. After a
    # Warframe update that holds again once the update set is adopted (renovice_update.py --adopt, after the live test).
    installed = uc_pe.Image((GAME / 'Warframe.x64.exe').read_bytes()).product_version()
    if installed != registry['build']:
        print(f'NOT APPLICABLE: the installed client is {installed}, the registry is certified for {registry["build"]}; '
              'adopt the update set first (renovice_update.py --adopt <stage>) and rerun')
        return 2
    root = ws / wsj['work']['temp'] / 'update-resilience-test'
    if root.exists():
        shutil.rmtree(root)
    overlay = root / 'overlay'
    overlay.mkdir(parents=True)
    results = []

    def check(case, label, ok, detail=''):
        results.append((case, label, bool(ok)))
        print(f'{"PASS" if ok else "FAIL"}  {case}: {label}' + (f'  [{detail}]' if detail and not ok else ''))

    def module(name):
        return B.Module((stock / name).read_bytes(), opmap)

    def write(name, data):
        (overlay / name).write_bytes(data)
        B.Module(data, opmap)                         # every synthetic module must parse

    # -- synthetic build B ------------------------------------------------------------------------------------------
    m = module('Lotus_Scripts_Modes_SurvivalMission.lua_B')
    write('Lotus_Scripts_Modes_SurvivalMission.lua_B', S.insert_protos(m, 0, [10, 11, 12], opmap))
    m = module('Lotus_Powersuits_Frost_Abilities_IceSpike.lua_B')
    write('Lotus_Powersuits_Frost_Abilities_IceSpike.lua_B', S.insert_protos(m, 0, [1, 2], opmap))
    m = module('Lotus_Powersuits_Bard_Abilities_BardAmplify.lua_B')
    write('Lotus_Powersuits_Bard_Abilities_BardAmplify.lua_B', S.insert_protos(m, 0, [1], opmap))
    m = module('Lotus_Scripts_Arbitration.lua_B')
    pool_text = 'RENOVICE_SYNTHETIC_NEW_STRING'
    write('Lotus_Scripts_Arbitration.lua_B', S.add_pool_string(m, pool_text))
    site = rows['rescue.hostage_timer.easy']['owner']['sites'][0]
    m = module('Lotus_Scripts_Rescue.lua_B')
    write('Lotus_Scripts_Rescue.lua_B', S.set_loadn(m, site['prototype'], site['instruction'], 100))
    duviri = rows['defense.duviri_wave_count']['owner']['sites'][0]
    m = module('Lotus_Scripts_WaveDefend.lua_B')
    write('Lotus_Scripts_WaveDefend.lua_B', S.set_loadn(m, duviri['prototype'], duviri['instruction'], 4))
    m = module('Lotus_Powersuits_Bard_Abilities_BardMusic.lua_B')
    write('Lotus_Powersuits_Bard_Abilities_BardMusic.lua_B', S.insert_moves(m, 16, 560, 3, opmap))
    m = module('Lotus_Scripts_Modes_TerritoryMission.lua_B')
    write('Lotus_Scripts_Modes_TerritoryMission.lua_B', B.rebuild_with_protos(m, [i for i in range(len(m.protos)) if i != 35]))
    m = module('Lotus_Scripts_CaptureNew.lua_B')
    loadn = [i for i, _, op in m.protos[17].instructions if op == 0x12]
    changed = B.Module(S.set_loadn(m, 17, loadn[-1], 7), opmap)
    copied = B.Module(S.insert_protos(changed, len(changed.protos) - 1, [17], opmap), opmap)
    write('Lotus_Scripts_CaptureNew.lua_B', S.adopt_child(copied, copied.main_index, copied.main_index - 1))
    m = module('Lotus_Interface_OmegaRerollSelection.lua_B')
    write('Lotus_Interface_OmegaRerollSelection.lua_B', S.add_pool_string(m, pool_text))

    # -- control -----------------------------------------------------------------------------------------------------
    code = RU.main(['--out', str(root / 'control'), '--skip-native', '--skip-step1', '--quiet'])
    rep = json.loads((root / 'control' / 'UPDATE_REPORT.json').read_text(encoding='utf-8'))
    a = rep['plan']['summary']['actions']
    check('control', 'exit 0, ALL AUTO, every gate PASS', code == 0 and rep['result'] == 'ALL AUTO', rep['result'])
    check('control', 'every dependency unchanged', set(a) == {'unchanged'}, a)
    check('control', 'nothing to install (every rebuilt file equals the installed one)', not rep['files'], rep['files'][:1])
    reb = (root / 'control' / 'evidence' / 'registry' / 'mission_build_u44.json').read_bytes()
    check('control', 'the rebased registry is byte-identical to the repository registry (registrar fixed point)',
          reb.replace(b'\r\n', b'\n').split(b'"corpus"')[0] ==
          (TOOL.parents[1] / 'REGISTRIES' / 'mission_build_u44.json').read_bytes().split(b'"corpus"')[0])

    # -- synthetic build ----------------------------------------------------------------------------------------------
    code = RU.main(['--stock-overlay', str(overlay), '--out', str(root / 'synthetic'), '--skip-native', '--quiet'])
    out = root / 'synthetic'
    rep = json.loads((out / 'UPDATE_REPORT.json').read_text(encoding='utf-8'))
    plan = json.loads((out / 'evidence' / 'remap_plan.json').read_text(encoding='utf-8'))
    deps = {(d['kind'], d['id']): d for d in plan['dependencies']}
    rebased = json.loads((out / 'evidence' / 'registry' / 'mission_build_u44.json').read_text(encoding='utf-8'))
    rrows = {r['tunable_id']: r for r in rebased['tunables']}
    gates = {g['name']: g for g in rep['gates']}

    def row(tid):
        return deps.get(('registry.row', tid), {})

    check('synthetic', 'exit 1 (staged, review items listed), every blocking gate PASS',
          code == 1 and rep['result'] == 'REVIEW' and all(g['pass'] for g in rep['gates'] if g['blocking']),
          [(g['name'], g['detail']) for g in rep['gates'] if not g['pass']])
    for name in ('verify-missions', 'build-missions', 'presets', 'settings-compat', 'step1-after'):
        check('synthetic', f'gate {name} PASS', gates.get(name, {}).get('pass'), gates.get(name, {}).get('detail'))
    # inserted prototypes
    surv = [t for t in rrows if t.startswith('survival.')]
    check('inserted-prototypes', 'every Survival row carried over (auto, exact)',
          surv and all(row(t).get('action') == 'auto' and row(t).get('confidence') == 'exact' for t in surv),
          [(t, row(t).get('action'), row(t).get('reason')) for t in surv if row(t).get('action') != 'auto'][:3])
    skey = rrows['survival.reward_interval']['owner']['body_key']
    hooks = sorted({p for t in rebased['modules'][skey]['root_tables'].values() for p in t['minimal_hooks']['prototypes']})
    check('inserted-prototypes', 'Survival hook plan follows the shift (P67 -> P70)', 70 in hooks and 67 not in hooks, hooks)
    check('inserted-prototypes', 'Survival preset template rewrites prototype 64 -> 70',
          ['prototype == 64', 'prototype == 70'] in rebased['modules'][skey]['addon']['source_rewrites']
          and rebased['modules'][skey]['addon']['current_prototype'] == 70)
    ice = next((x for x in rep['addons'] if 'IceWave' in x['file']), {})
    check('inserted-prototypes', 'Ice Wave addon rebuilt: callsites P7 -> P9, gates PASS',
          ice.get('action') == 'auto' and all(c['new'][0] == 9 for c in ice.get('callsites', [])), ice.get('reason'))
    amp = next((x for x in rep['replacements'] if 'Amp buff' in x['file']), {})
    check('inserted-prototypes', 'Amp replacement rebased: P11 i339 -> P12 i339 (exact)',
          amp.get('action') == 'auto' and amp.get('edits') == [{'old': 'P11 i339', 'new': 'P12 i339'}], amp)
    # moved literal
    arb_old = rows['arbitration.resurrection_score_cap']['owner']['sites']
    arb_new = rrows['arbitration.resurrection_score_cap']['owner']['sites']
    shift = len(pool_text) + 1
    check('moved-literal', 'arbitration.resurrection_score_cap: every site re-pinned at offset + %d (auto, exact)' % shift,
          row('arbitration.resurrection_score_cap').get('action') == 'auto'
          and [s['offset'] - o['offset'] for s, o in zip(arb_new, arb_old)] == [shift] * len(arb_old)
          and [s['instruction'] for s in arb_new] == [s['instruction'] for s in arb_old])
    # changed default
    r = row('rescue.hostage_timer.easy')
    check('changed-default', 'rescue.hostage_timer.easy stock 90 -> 100 (auto, STOCK_CHANGED)',
          r.get('action') == 'auto' and r.get('stock') == {'old': 90, 'new': 100} and rrows['rescue.hostage_timer.easy']['stock'] == 100, r)
    check('changed-default', 'player text re-applied: the description states stock 100',
          'stock 100' in rrows['rescue.hostage_timer.easy']['ui'].get('r5_scope_text', rrows['rescue.hostage_timer.easy']['ui']['scope_text']))
    # changed context
    r = row('defense.duviri_wave_count')
    check('changed-context', 'defense.duviri_wave_count goes to review (sites disagree)',
          r.get('action') == 'review' and 'different stock values' in r.get('reason', ''), r.get('reason'))
    # moved callsite
    mal = next((x for x in rep['addons'] if 'Mallet' in x['file']), {})
    check('moved-callsite', 'Mallet addon rebuilt: PushFloatArg P16 i596 -> P16 i599, renamed to the new key',
          mal.get('action') == 'auto' and mal.get('changes') == [{'old': 'P16 i596', 'new': 'P16 i599'}]
          and mal.get('artifact_name', '').startswith(mal.get('new_key', '?')), mal.get('reason'))
    nc = next((x for x in rep['replacements'] if 'No Cover' in x['file']), {})
    check('moved-callsite', 'No Cover replacement rebased: edits i568/i570 -> i571/i573',
          nc.get('action') == 'auto' and nc.get('edits') == [{'old': 'P16 i568', 'new': 'P16 i571'},
                                                            {'old': 'P16 i570', 'new': 'P16 i573'}], nc)
    staged = {f['install'] for f in rep['files']}
    check('moved-callsite', 'install set: renamed Mallet member, Octavia package.json, old file in remove.txt',
          any(p.endswith(mal.get('artifact_name', '?')) for p in staged)
          and 'OpenWF/CustomScripts/Packages/Octavia/package.json' in staged
          and any('ec368d4901690a15.MalletOverguardAndCard' in x for x in rep['remove']))
    # removed function
    r = row('interception.score_rate')
    check('removed-function', 'interception.score_rate dropped (prototype 35 removed) and the preset with it',
          r.get('action') == 'dropped' and 'interception' not in rebased['missions'], r.get('reason'))
    # ambiguous
    amb = [d for d in plan['dependencies'] if d['kind'] == 'registry.row' and d['action'] == 'review'
           and 'Lotus_Scripts_CaptureNew.lua_B' in ''.join(d.get('modules', [])) and 'ambiguous' in d.get('reason', '')]
    check('ambiguous', 'CaptureNew rows hooked in P17 go to review (ambiguous match)', amb,
          [d.get('reason') for d in plan['dependencies'] if 'CaptureNew' in ''.join(d.get('modules', []))][:2])
    # full rewrite
    rv = next((x for x in rep['replacements'] if 'Riven' in x['file']), {})
    check('full-rewrite', 'Riven lock replacement: review (full rewrite, source project named)',
          rv.get('action') == 'review' and 'full rewrite' in rv.get('reason', '') and 'riven-multilock' in rv.get('reason', ''),
          rv.get('reason'))
    # unchanged
    el = next((x for x in rep['addons'] if 'EliteSanctuary' in x['file']), {})
    check('unchanged', 'Elite Sanctuary addon unchanged (its module did not change)', el.get('action') == 'unchanged', el)
    met = next((x for x in rep['replacements'] if 'Metrone' in x['file']), {})
    check('unchanged', 'Metrone replacement unchanged', met.get('action') == 'unchanged', met)
    # value ids stay stable
    absent = set(plan['summary']['absent_value_ids'])
    kept = set(rrows) | set(rebased.get('ui_masters', {}))
    check('settings', 'value ids are stable: every id of the old registry is kept or listed as out',
          {r['tunable_id'] for r in registry['tunables']} <= kept | absent)
    failed = [x for x in results if not x[2]]
    print(f'\nUPDATE RESILIENCE TEST {"PASS" if not failed else "FAIL"}: {len(results) - len(failed)}/{len(results)} expectations')
    return 1 if failed else 0


if __name__ == '__main__':
    sys.exit(main())
