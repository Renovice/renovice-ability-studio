"""Phase 2k gate cases for ROOT_TABLE_MINIMAL_HOOKS_V1 (hook_plan.py) on the pinned 44.0.2 stock bytes (offline, read-only).

1. Survival reward table root:i19:R9: plan {31, 61, 67, 69}; 31 and 69 escape (forced), 67 reads the table itself, 61
   reads and writes it; 33/55/60 are covered only because every call to them lies inside 67; 58 is a dead closure (never
   called, never escapes); 62 and 68 capture the table but never read an owned field.
2. Mutation: without 67 the reward check 33 is no longer covered, so {31, 61, 69} is rejected.
3. SentientArtifactMission root:i421:R44: prototype 73 copies the table into another upvalue (SETUPVAL) that prototype 39
   reads; the copy is an escape of 73 and 39 is recorded as a downstream reader.
4. CoH Shrine Defense nested tables: the recorded container path is in access order (upvalue[1].RespawnDelay).
5. Reproducibility and subset rule over the whole registry: every table's recorded plan equals a fresh computation and is a
   non-empty subset of its ROOT_TABLE_UPVALUE_V1 capturer hooks.
"""
from pathlib import Path
import json, sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from addon_owner import RootTables  # noqa: E402
from deluau import ROOT  # noqa: E402
import hook_plan as HP  # noqa: E402

registry = json.loads((ROOT / 'repos/apps/ability-editor/REGISTRIES/mission_build_u44.json').read_text(encoding='utf-8'))
corpus = ROOT / registry['corpus']
cases = 0


def key_of(file):
    """Module body key by stock file name: keys change with every client build (2026-10-09; the 44.0.2 Survival key
    f10a043e7f825db2 is a62aa7eea1c4f27b on 44.1.1, where the hook plan facts below are unchanged)."""
    keys = [k for k, m in registry['modules'].items() if m['file'] == file]
    assert len(keys) == 1, (file, keys)
    return keys[0]


SURVIVAL = key_of('Lotus_Scripts_Modes_SurvivalMission.lua_B')
DISRUPTION = key_of('Lotus_Scripts_Modes_SentientArtifactMission.lua_B')
SHRINE_LITE = key_of('Lotus_Types_Gameplay_DevilTower_LiteGameModes_CoHShrineDefenseLite.lua_B')


def plan(body):
    module = registry['modules'][body]
    owned = {}
    for row in registry['tunables']:
        if row['backend'] == 'TARGET_ADDON' and row['owner'].get('body_key') == body:
            for f in row['owner'].get('fields', []):
                owned.setdefault(f['table_id'], set()).add(f['field'])
    m = RootTables((corpus / module['file']).read_bytes())
    return module, HP.plan_module(m, module['root_tables'], owned)


# 1 + 2: Survival
module, (plans, flow, (calls, escapes, reach, root_called, freq)) = plan(SURVIVAL)
p = plans['root:i19:R9']
assert p['hooks'] == [31, 61, 67, 69], p['hooks']
assert p['forced'] == [31, 69] and 31 in escapes and 69 in escapes, p['forced']
assert 68 not in p['reaching_capturers'] and 62 not in p['reaching_capturers'], p['reaching_capturers']
assert p['coverage']['33'] == 'called-only-inside-67' and p['coverage']['58'] == 'never-called', p['coverage']
assert 58 not in calls and 58 not in escapes, 'proto 58 is a dead closure'
cases += 1
cov = HP.covered_set(flow, calls, escapes, root_called, {31, 61, 69})
assert 33 not in cov and 67 not in cov, 'without 67 the reward check is uncovered'
cov = HP.covered_set(flow, calls, escapes, root_called, {31, 61, 67, 69})
assert set(p['reaching_capturers']) <= cov
cases += 1

# 3: SETUPVAL escape
module, (plans, *_ignored) = plan(DISRUPTION)
p = plans['root:i421:R44']
assert '73:escape:setupval' in p['reach_events'] and p['downstream_after_escape'] == [39] and p['hooks'] == [73], p
cases += 1

# 4: nested access order
module = registry['modules'][SHRINE_LITE]
assert all(h['path'] == [1, 'RespawnDelay'] for h in module['root_tables']['root:i145:R60']['hooks'])
assert all(h['path'] == [5, 'MaxEnemies'] for h in module['root_tables']['root:i182:R60']['hooks'])
assert all(h['path'] == [1] for h in module['root_tables']['root:i144:R59']['hooks'])
cases += 1

# 5: reproducibility + subset over every table
tables = full = minimal = 0
for body, module in registry['modules'].items():
    if 'root_tables' not in module:
        continue
    _, (fresh, *_rest) = plan(body)
    for tid, table in module['root_tables'].items():
        recorded = table['minimal_hooks']
        capturers = {h['prototype'] for h in table['hooks']}
        assert recorded['gate'] == HP.GATE and recorded['prototypes'] == fresh[tid]['hooks'], (body, tid)
        assert recorded['prototypes'] and set(recorded['prototypes']) <= capturers, (body, tid)
        tables += 1
        full += len(capturers)
        minimal += len(recorded['prototypes'])
cases += 1
# 6: contract R3 retire evidence. Survival root:i19:R9 hooks are root children of a fixed root table (retire-safe); a
# container write on a nested table's path is classified as a retire blocker, a container read is not.
module, (plans, flow, *_rest) = plan(SURVIVAL)
p = plans['root:i19:R9']
assert p['retire_safe'] and p['root_children'] == p['hooks'] and not p['retire_blockers'], p
module, (plans, flow, *_rest) = plan(SHRINE_LITE)
tid = 'root:i145:R60'
SETTABLE, GETTABLE = 0x2a, 0x01
assert flow._table_use(20, bytes([SETTABLE, 1, 2, 3]), 2, 'table', ('T', tid, 0)) == 'container:dynamic-write'
assert flow._table_use(20, bytes([GETTABLE, 1, 2, 3]), 2, 'table', ('T', tid, 0)) == 'container:dynamic-read'
assert flow._table_use(20, bytes([GETTABLE, 1, 2, 3]), 2, 'table', ('T', tid, 2)) == 'dynamic-key'
assert plans[tid]['retire_safe'] and plans[tid]['hooks'] == [20], plans[tid]
retire_safe = sum(1 for m in registry['modules'].values() for t in m.get('root_tables', {}).values() if t['minimal_hooks']['retire_safe'])
cases += 1
print(f'PASS {cases} Phase 2k hook-plan cases; tables={tables} capturer_hooks={full} minimal_hooks={minimal} retire_safe={retire_safe}')
