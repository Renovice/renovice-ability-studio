"""Contract R20 gate (2026-10-02): every "x" multiplier of the Missions package accepts values down to 0.001.

Record: RESEARCH/MISSIONS_R20_MULTIPLIER_MINIMUMS_2026-10-02/README.md; input (pinned by the registrar):
RESEARCH/MISSIONS_R20_MULTIPLIER_MINIMUMS_2026-10-02/inputs/r20_minimums.json.

What it proves (offline):
  1. The pinned full-package build input builds; package.json and literals.json are the pinned R20 files; the addon and
     engine_params.json are byte-identical to R19 (a minimum is a declaration, never compiled into the addon).
  2. Declarations: every declared value with unit "x" (package.json and literals.json) is fractional and accepts 0.001,
     except a floor the R20 input records with its decompile reason; every R20 input row is what the package declares
     (minimum and type); a master's minimum is the largest minimum of its driven rows (the registry rule).
  3. Tooltips: every count multiplier (scale_count, and a master over count rows) says "at least 1"; every floor says why
     ("minimum"); descriptions stay within the R7 rules (checked by the build's settings-layout gate).
  4. The real generated addon in plain Luau: every named-setting (root-table) multiplier row of the R20 input that is not a
     scaled row is written at its minimum (0.001, or the floor) exactly, no rounding and no whole-number conversion, and
     cleanup restores the game value. The scaled rows are covered by test_void_flood_tank_harness.py (root table),
     test_entry_native_harness.py (entry write) and test_engine_param_override_harness.py (engine writer), each with a case
     at the minimum; the live literals at 0.001 by the bootstrapper render gate (synthesis on the real stock bytes).
Limits: the DE VM (float32 numbers) does not run here; plain Luau uses doubles. The minimum crosses the DLL as float32
(settings_ui_core -> SettingsRowView.minimum) and the bridge validator compares it with tonumber() of the typed text in the
same float32 VM: both are float32(0.001). Nothing is live.

Paths: CLI = RENOVICE_EDITOR_CLI or work/builds/ability-editor/current; luau.exe from the DE Luau toolchain. Writes only to
work/temp/r20-minimums-gate and this tool's test-results folder. Reads no game or server folder.
"""
from pathlib import Path
import hashlib, json, os, shutil, subprocess, sys

EDITOR = Path(__file__).resolve().parents[3]
ROOT = EDITOR
while not (ROOT / 'WORKSPACE.json').exists():
    ROOT = ROOT.parent
CLI = Path(os.environ.get('RENOVICE_EDITOR_CLI', ROOT / 'work/builds/ability-editor/current/bin/renovice_ability_editor_cli.exe'))
LUAU = ROOT / 'repos/toolchains/de-luau-toolchain/bin/luau.exe'
INPUT = EDITOR / 'RESEARCH/MISSIONS_R13_NATIVE_ENTRY_2026-10-01/inputs/rebuild_input.r12.json'
INPUT_LF_SHA = 'dccde5fddf2649c2be4c93789cecab4cc1d1759dc9d01d0117cba25f5a7ca4b6'
R20_INPUT = EDITOR / 'RESEARCH/MISSIONS_R20_MULTIPLIER_MINIMUMS_2026-10-02/inputs/r20_minimums.json'
PINS = {'Missions.targets.addon.lua_B': 'd8736450cc81c2c03daaf219fbd5a046dad82b57e1d54fd8263fe2832a4d3c88',  # = R19
        'engine_params.json': 'eafd2ddf3b3916aad7a0dd4d1b09090a2a6ca74192dde69dd0e3afbf72aa259b',            # = R19
        'package.json': 'acc2256eb4a76f6782af1aa51534a5387c065ae1323da36daa45dfbbd06f6d71',                  # R19 150c0d16
        'literals.json': '96a97899889b6a5f5357a4c0ae0024d0afe9a214c398784fdcc834f401f0fd03'}                 # R19 786c7b94
TARGET = 0.001
WORK = ROOT / 'work/temp/r20-minimums-gate'
OUT = Path(__file__).resolve().parents[1] / 'test-results'
results = {'checks': []}


def check(ok, name):
    results['checks'].append({'name': name, 'pass': bool(ok)})
    print(('PASS' if ok else 'FAIL') + '\t' + name)
    if not ok:
        OUT.mkdir(parents=True, exist_ok=True)
        (OUT / 'r20_multiplier_minimums.json').write_text(json.dumps(results, indent=2) + '\n', encoding='utf-8')
        sys.exit(1)


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def lua(value):
    if isinstance(value, bool):
        return 'true' if value else 'false'
    if isinstance(value, (int, float)):
        return repr(float(value)) if isinstance(value, float) and not float(value).is_integer() else str(int(value))
    if isinstance(value, str):
        return json.dumps(value)
    if isinstance(value, list):
        return '{' + ', '.join(lua(v) for v in value) + '}'
    if isinstance(value, dict):
        return '{' + ', '.join(f'[{lua(k)}] = {lua(v)}' for k, v in value.items()) + '}'
    raise TypeError(value)


# 1. Build.
check(hashlib.sha256(INPUT.read_bytes().replace(b'\r\n', b'\n')).hexdigest() == INPUT_LF_SHA, 'pinned full-package build input (LF content)')
shutil.rmtree(WORK, ignore_errors=True)
WORK.mkdir(parents=True)
run = subprocess.run([str(CLI), 'build-missions', str(INPUT), '--staging', str(WORK / 'build'), '--editor-root', str(EDITOR)],
                     capture_output=True, text=True)
generations = list((WORK / 'build').glob('missions/*/MISSION_SET_MANIFEST.json'))
check(run.returncode == 0 and len(generations) == 1, 'build succeeds')
generation = generations[0].parent
package = generation / 'Packages/Missions'
for name, digest in PINS.items():
    check(sha(package / name) == digest, f'{name} is the pinned R20 build ({digest[:8]})')

# 2. Declarations.
spec = json.loads(R20_INPUT.read_text(encoding='utf-8'))
registry = json.loads((EDITOR / 'REGISTRIES/mission_build_u44.json').read_text(encoding='utf-8'))
rows = {r['tunable_id']: r for r in registry['tunables']}
masters = registry['ui_masters']
declared = dict(json.loads((package / 'package.json').read_text(encoding='utf-8'))['members']['Missions.targets.addon.lua_B']['settings']['values'])
for vid, value in json.loads((package / 'literals.json').read_text(encoding='utf-8'))['values'].items():
    declared[vid] = value['declaration']
multipliers = {vid: d for vid, d in declared.items() if d.get('unit') == 'x'}
floors = {r['tunable_id']: r['minimum'] for r in spec['rows'] if r['minimum'] > TARGET}
check(len(multipliers) == 51, f'the package declares 51 values with unit x (46 in package.json, 5 in literals.json): {len(multipliers)}')
bad_type = sorted(vid for vid, d in multipliers.items() if d['type'] != 'float')
check(not bad_type, f'every x value is fractional (type float): {bad_type or "all"}')
bad_min = sorted(f'{vid}={d["min"]}' for vid, d in multipliers.items() if d['min'] > TARGET and floors.get(vid) != d['min'])
check(not bad_min, f'every x value accepts {TARGET} unless the R20 input records a floor: {bad_min or "all"}')
check(sorted(floors) == ['interception.scoring_speed', 'purge.alert_tiers.tier1_multiplier', 'purge.alert_tiers.tier2_multiplier',
                         'purge.alert_tiers.tier3_multiplier', 'void_flood.orb_value_scale']
      and floors['interception.scoring_speed'] == 0.1 and floors['void_flood.orb_value_scale'] == 0.06
      and all(floors[f'purge.alert_tiers.tier{n}_multiplier'] == 0.134 for n in (1, 2, 3)),
      'R20 floors: Interception scoring speed 0.1 (float32 score stall), Void Flood orb value 0.06 (downed drop within the '
      "game's 150 pickups), Alert Purge tiers 0.134 (spawn cap away from players)")
mismatch = []
for item in spec['rows']:
    d = declared.get(item['tunable_id'])
    want_type = 'int' if item.get('integer', item['was']['integer']) else 'float'
    if d is None or d['min'] != item['minimum'] or d['type'] != want_type or rows[item['tunable_id']]['limits']['minimum'] != item['minimum']:
        mismatch.append(item['tunable_id'])
check(not mismatch and len(spec['rows']) == 31, f'all 31 R20 input rows are declared with their minimum and type (registry and package): {mismatch or "all"}')
zero = sorted(vid for vid, d in multipliers.items() if d['min'] == 0)
check(all(vid in rows for vid in zero), f'{len(zero)} x values keep minimum 0 (they already accept {TARGET}; R20 audit: no division by them)')
for mid, master in masters.items():
    if mid in multipliers:
        low = max(rows[d['tunable_id']]['limits']['minimum'] / d['scale'] for d in master['drives'])
        check(multipliers[mid]['min'] == low == master['min'], f'master {mid}: minimum {master["min"]} = the largest minimum of its driven rows')

# 3. Tooltips (descriptions; the editor tooltip adds "Default ... Range <min> to <max>." itself).
count_rows = {vid for vid in multipliers if vid in rows and rows[vid]['owner'].get('mode') == 'scale_count'}
count_rows |= {mid for mid in multipliers if mid in masters
               and all(rows[d['tunable_id']]['owner'].get('mode') == 'scale_count' for d in masters[mid]['drives'])}
check(len(count_rows) == 7, f'7 count multipliers (5 Railjack rows, the Railjack master, Void Flood tank capacity): {sorted(count_rows)}')
missing = sorted(vid for vid in count_rows if 'at least 1' not in multipliers[vid]['scope'])
check(not missing, f'every count multiplier says that each count stays at least 1: {missing or "all"}')
missing = sorted(vid for vid in floors if 'minimum' not in multipliers[vid]['scope'].lower())
check(not missing, f'every floor says why its minimum is above {TARGET}: {missing or "all"}')
check('15 kills' in multipliers['exterminate.kills_scale']['scope'],
      'Exterminate kills needed (a divisor of the map path) names the game floor of about 15 kills')

# 4. Named-setting multipliers at their minimum, through the real generated addon.
source = (generation / 'source/Missions.targets.addon.luau').read_text(encoding='utf-8')
plain = [item['tunable_id'] for item in spec['rows'] if rows[item['tunable_id']]['owner'].get('template') == 'ROOT_TABLE_FIELD'
         and rows[item['tunable_id']]['owner'].get('mode') is None]
check(len(plain) == 12, f'12 named-setting multiplier rows without a scale mode in the R20 input: {plain}')
modules = {}
for tid in plain:
    modules.setdefault(rows[tid]['owner']['body_key'], []).append(tid)
cases = []
for key, ids in sorted(modules.items()):
    tables = registry['modules'][key]['root_tables']
    owned = {}
    for r in registry['tunables']:
        o = r.get('owner') or {}
        if r['backend'] != 'TARGET_ADDON' or o.get('body_key') != key:
            continue
        for f in o.get('fields', []):
            owned.setdefault(f['table_id'], {})[f['field']] = f.get('stock', r['stock'])
    used = {f['table_id'] for tid in ids for f in rows[tid]['owner']['fields']}
    built = {}
    views = {}
    for table_id in sorted(used):
        table = tables[table_id]
        check(len(table['containers']) <= 1, f'{key} {table_id}: at most one container level (harness model)')
        holder = {'fields': owned[table_id]}
        if table['containers']:
            holder = {'container': table['containers'][0]['key'], 'fields': owned[table_id]}
        built[table_id] = holder
        for hook in table['hooks']:
            views.setdefault(hook['prototype'], {})[hook['upvalue']] = table_id
    hooked = sorted({p for t in used for p in tables[t]['minimal_hooks']['prototypes']})
    for tid in ids:
        (field,) = [(f['table_id'], f['field']) for f in rows[tid]['owner']['fields']]
        cases.append({'id': tid, 'key': key, 'stock': rows[tid]['stock'], 'value': rows[tid]['limits']['minimum'],
                      'table': field[0], 'field': field[1], 'tables': built, 'views': {str(p): v for p, v in views.items()},
                      'hooked': hooked})
harness = r'''
local emit = print
print = function() end
local failures, passes = 0, 0
local function ok(condition, name)
    if condition then passes = passes + 1 emit("PASS\t" .. name) else failures = failures + 1 emit("FAIL\t" .. name) end
end
local function instance(case)
    local byId, holders = {}, {}
    for id, spec in pairs(case.tables) do
        local t = {}
        for field, stock in pairs(spec.fields) do t[field] = stock end
        byId[id] = t
        if spec.container ~= nil then holders[id] = { [spec.container] = t } else holders[id] = t end
    end
    return byId, holders
end
local function run(target, case, holders)
    for _, prototype in ipairs(case.hooked) do
        local hook = target.hooks.luaCalls[prototype]
        local up = {}
        for upvalue, id in pairs(case.views[tostring(prototype)] or {}) do up[upvalue] = holders[id] end
        if hook ~= nil then hook.before(prototype, {}, up, nil, {}) end
    end
end
for _, case in ipairs(CASES) do
    local addon = ADDON_MODULE()
    local target = addon.targets[case.key]
    local byId, holders = instance(case)
    target.activate({ settings = { [case.id] = { enabled = true, value = case.value, stock = case.stock } } })
    run(target, case, holders)
    local written = byId[case.table][case.field]
    ok(written == case.value, case.id .. ": written at its minimum " .. tostring(case.value) .. " exactly (got " .. tostring(written) .. ")")
    target.cleanup()
    ok(byId[case.table][case.field] == case.stock, case.id .. ": cleanup restores the game value " .. tostring(case.stock))
end
emit(failures == 0 and ("R20 MINIMUMS HARNESS PASS checks=" .. passes) or "R20 MINIMUMS HARNESS FAIL")
'''
script = WORK / 'r20_minimums_harness.luau'
script.write_text('ADDON_MODULE = function(...)\n' + source + '\nend\n' + 'CASES = ' + lua(cases) + '\n' + harness, encoding='utf-8')
check(LUAU.is_file(), 'toolchain luau.exe present')
run = subprocess.run([str(LUAU), str(script)], capture_output=True, text=True)
lines = run.stdout.splitlines()
for line in lines:
    print('HARNESS\t' + line)
if run.stderr.strip():
    print('HARNESS-STDERR\t' + run.stderr.strip())
check(run.returncode == 0 and any(l.startswith('R20 MINIMUMS HARNESS PASS') for l in lines) and not any(l.startswith('FAIL') for l in lines),
      f'harness: {sum(l.startswith("PASS") for l in lines)} Luau checks (the real addon writes each named-setting multiplier at its minimum)')
OUT.mkdir(parents=True, exist_ok=True)
(OUT / 'r20_multiplier_minimums.json').write_text(json.dumps(results, indent=2) + '\n', encoding='utf-8')
print('R20 MULTIPLIER MINIMUMS GATE PASS')
