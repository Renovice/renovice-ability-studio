"""Offline regression for the Phase 2e root-table addon gate ROOT_TABLE_UPVALUE_V1 on the 44.0.2 stock corpus
(read-only). Writes test-results/phase2e_gates.json only.

* PASS: two fields that share one bytecode constant (Survival interval / killPlayerTime = 300) resolve to different tables
  and hook sets, so each is an independent control;
* PASS: a nested table (Purgatory difficulty 2) is reached through its root container path [2];
* PASS: an array element (Lantern numEnemies[3]) through the container field path;
* FAIL: a table whose captured identity is replaced by SETUPVAL (Disruption variant tables);
* FAIL: a field the root reads at module load (Void Cascade REWARD_INTERVAL);
* FAIL: a field no capturer reads (Survival alertPlayerDamagePercent);
* FAIL: a non-unique owner without a pinned table (Survival capsule interval = 90 exists in two tables).
"""
from pathlib import Path
import json, sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from addon_owner import RootTables  # noqa: E402
from deluau import ROOT  # noqa: E402

STOCK = ROOT / 'work/research/universal-mission-editor-2026-09-29/stock'
OUT = Path(__file__).resolve().parents[1] / 'test-results'
cache = {}


def mod(name):
    if name not in cache:
        cache[name] = RootTables((STOCK / name).read_bytes())
    return cache[name]


def expect_fail(fn, text):
    try:
        fn()
    except ValueError as e:
        if text in str(e):
            return str(e)
        raise AssertionError(f'wrong failure: {e}') from e
    raise AssertionError('gate did not fail: ' + text)


SURV = 'Lotus_Scripts_Modes_SurvivalMission.lua_B'
cases = []
interval, kill = mod(SURV).owner('interval', 300.0, 19), mod(SURV).owner('killPlayerTime', 300.0)
assert interval['table_id'] != kill['table_id'] and interval['field'] != kill['field']
assert any(h['prototype'] == 67 and h['upvalue'] == 70 for h in interval['hooks'])  # the Survival preset owner (live only on the pre-V107 VM-entry lane)
cases.append({'case': 'shared stock value 300: interval and killPlayerTime are separate table fields', 'result': 'PASS',
              'tables': [interval['table_id'], kill['table_id']]})
nested = mod('Lotus_Scripts_Modes_Purgatory.lua_B').owner('ghostLevel', 10.0, 80)
assert [h['path'] for h in nested['hooks']] == [[2]], nested['hooks']
cases.append({'case': 'nested root table (Purgatory difficulty 2) via container path [2]', 'result': 'PASS'})
element = mod('Lotus_Scripts_Modes_HalloweenLanternEndless.lua_B').element_owner(79, 25.0)
assert all(h['path'] == ['numEnemies'] for h in element['hooks']) and element['field'] == 3, element
cases.append({'case': 'array element (Lantern numEnemies[3]) via container field', 'result': 'PASS'})
for name, fn, text in [
    ('SETUPVAL replaces the captured table (Disruption)',
     lambda: mod('Lotus_Scripts_Modes_SentientArtifactMission.lua_B').owner('amalgamTierMin', 50.0, 363), 'replaces the captured table'),
    ('root reads the field at module load (Void Cascade REWARD_INTERVAL)',
     lambda: mod('Lotus_Scripts_Modes_ZarimanSurvivalMission.lua_B').owner('REWARD_INTERVAL', 4.0), 'at module load'),
    ('no capturer reads the field (alertPlayerDamagePercent)',
     lambda: mod(SURV).owner('alertPlayerDamagePercent', 0.02), 'no capturer reads'),
    ('owner not unique without a pinned table (capsule interval 90)',
     lambda: mod(SURV).owner('interval', 90.0), 'not unique'),
]:
    cases.append({'case': name, 'result': 'PASS (rejected)', 'reason': expect_fail(fn, text)})
OUT.mkdir(parents=True, exist_ok=True)
(OUT / 'phase2e_gates.json').write_text(json.dumps({'gate': 'ROOT_TABLE_UPVALUE_V1', 'cases': cases}, indent=2) + '\n')
print(f'PASS {len(cases)} Phase 2e gate cases')
