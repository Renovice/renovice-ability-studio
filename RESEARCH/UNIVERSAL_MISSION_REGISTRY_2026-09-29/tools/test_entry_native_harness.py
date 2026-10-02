"""Native-entry harness for the R10-R12 entry-template rows (2026-10-01, contract R13).

Why: the live Defense "Waves per reward" test failed. Two causes (bootstrapper RESEARCH/NATIVE_ENTRY_AND_MEMBER_POLICY_R13):
  1. the Missions addon member was never staged (stale `member:` false, retired in R13);
  2. every entry prototype the R10 templates hook (WaveDefend `WaveDefense` P50 and the 21 other rows' entries) is a
     level-trigger / encounter function that the engine enters directly. The R11 luaCalls.before observer saw only Lua
     CALL instructions, so these hooks could never run. R13 dispatches the same hooks at the native VM-execute entry.

This gate runs the REAL generated addon source (the build of the pinned R12 input, byte-identical to the installed R12
addon 8e0e1871) in plain Luau, as the R13 runtime calls it at a native entry:
  activate(context) -> hooks.luaCalls[P].before(P, arguments, upvalues, trace, environment) -> cleanup().
For every entry-template row of the registry it asserts the environment write (SCRIPT_PARAM_GLOBAL_AT_ENTRY: absolute,
scale, scale_inverse, scale_count) or the MissionInfo write (MISSION_INFO_FIELD_AT_ENTRY), the R3 retire signal, no
compounding on a second entry, a fresh write for a second instance, and the cleanup restore.

R15 (2026-10-01): the R13 version of this harness also ran the Defense checkpoint rule against an environment table only
the addon writes, and passed; live, the same write had no effect because the engine re-applies the trigger's level
parameters into that environment (wrong owner). Defense "Waves per reward" is now a reader pin (live literal) gated by
test_defense_reader_pin_harness.py, which models the engine's re-application. Here only the remaining P50 hook is
checked not to write minWavesToComplete. The same limit applies to every remaining SCRIPT_PARAM_GLOBAL_AT_ENTRY row:
this harness proves the write at the entry, not that the value survives until its readers run.
Limit: the boundary itself (which native entries dispatch) is proven by the bootstrapper gate
verify_lua_call_retirement.ps1 section 15, not here.

Paths: CLI = RENOVICE_EDITOR_CLI or work/builds/ability-editor/current; luau.exe from the DE Luau toolchain. Writes only
to work/temp/entry-native-harness and this tool's test-results folder. Reads no game or server folder.
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
INPUT_LF_SHA = 'dccde5fddf2649c2be4c93789cecab4cc1d1759dc9d01d0117cba25f5a7ca4b6'  # LF content (checkout-independent)
# R14 (2026-10-01): the same input now also declares the four Void Flood tank multipliers (scaled root-table rows);
# the R12 build of this input was 8e0e187124379d78ab039bc283eb9963d9696d6f1d7c4a420af5a3d96c1ebb07 (installed 2026-10-01).
# R15 (2026-10-01): defense.waves_per_reward left the addon (reader pin, live literal; test_defense_reader_pin_harness.py);
# the R14 build of this input was 4c70b5ec200f9409ca034546aea37555c8f6081cd6661978c3a41e347b7ccbba (installed 2026-10-01).
# R17 (2026-10-01): the Deepmines rows left the addon (reader pins, live literals) and the Gas City row was replaced by the
# meltdown-time scale over hackTime and modeTimer; the R15/R16 build of this input was 70fff0b6606e452e... (installed).
R12_ADDON_SHA = 'd8736450cc81c2c03daaf219fbd5a046dad82b57e1d54fd8263fe2832a4d3c88'  # R19 build of the pinned input (R18 43cb89c3, R17 daab653a)
WORK = ROOT / 'work/temp/entry-native-harness'
OUT = Path(__file__).resolve().parents[1] / 'test-results'
results = {'checks': []}


def check(ok, name):
    results['checks'].append({'name': name, 'pass': bool(ok)})
    print(('PASS' if ok else 'FAIL') + '\t' + name)
    if not ok:
        OUT.mkdir(parents=True, exist_ok=True)
        (OUT / 'entry_native_harness.json').write_text(json.dumps(results, indent=2) + '\n', encoding='utf-8')
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
        return '{' + ', '.join(f'[{json.dumps(k)}] = {lua(v)}' for k, v in value.items()) + '}'
    raise TypeError(value)


def scaled_count(current, value):
    def one(n):
        if n < 1:
            return n
        r = n * value + 0.5
        r = r - r % 1
        return max(r, 1)
    return [one(n) for n in current] if isinstance(current, list) else one(current)


# 1. Build the pinned R12 input; the addon must be the installed R12 addon.
check(hashlib.sha256(INPUT.read_bytes().replace(b'\r\n', b'\n')).hexdigest() == INPUT_LF_SHA,
      'pinned R12 build input (LF content)')
shutil.rmtree(WORK, ignore_errors=True)
WORK.mkdir(parents=True)
run = subprocess.run([str(CLI), 'build-missions', str(INPUT), '--staging', str(WORK / 'build'), '--editor-root', str(EDITOR)],
                     capture_output=True, text=True)
generations = list((WORK / 'build').glob('missions/*/MISSION_SET_MANIFEST.json'))
check(run.returncode == 0 and len(generations) == 1, 'R12 build succeeds')
generation = generations[0].parent
check(sha(generation / 'Packages/Missions/Missions.targets.addon.lua_B') == R12_ADDON_SHA,
      'the built addon is the pinned R19 addon (d8736450; R18 43cb89c3, R17 daab653a, R15/R16 70fff0b6, R14 4c70b5ec, R12 8e0e1871)')
source = (generation / 'source/Missions.targets.addon.luau').read_text(encoding='utf-8')

# 2. One case per entry-template row of the registry.
registry = json.loads((EDITOR / 'REGISTRIES/mission_build_u44.json').read_text(encoding='utf-8'))
cases = []
for row in registry['tunables']:
    owner = row.get('owner') or {}
    template = owner.get('template') if isinstance(owner, dict) else None
    if template not in ('SCRIPT_PARAM_GLOBAL_AT_ENTRY', 'MISSION_INFO_FIELD_AT_ENTRY'):
        continue
    case = {'id': row['tunable_id'], 'key': owner['body_key'], 'stock': row['stock'],
            'prototypes': [e['prototype'] for e in owner['entries']]}
    if template == 'MISSION_INFO_FIELD_AT_ENTRY':
        case.update(kind='info', field=owner['field'], value=5, expect=5)
    else:
        mode = owner['mode']
        names = [g['name'] for g in owner['globals']]
        if mode == 'absolute':
            observed = row['stock']
            value = 1 if row['tunable_id'] == 'defense.waves_per_reward' else row['stock'] + 1
            expect = value
        elif mode in ('scale', 'scale_inverse'):
            observed, value = 100, 2
            expect = observed * value if mode == 'scale' else observed / value
        elif mode == 'scale_count':
            observed, value = [20, 35, 55], 2
            expect = scaled_count(observed, value)
        else:
            raise SystemExit('unknown mode ' + mode)
        case.update(kind='param', mode=mode, globals=names, observed=observed, value=value, expect=expect)
    cases.append(case)
check(len(cases) == 21 and sum(c['kind'] == 'param' for c in cases) == 13,
      f'registry: 21 entry-template rows (13 script parameters, 8 MissionInfo fields; R15 moved Defense waves per reward and '
      f'R17 the two Deepmines rows to reader pins, R18 added the two Pontis tower rows); found {len(cases)}')
# R20 (2026-10-02): every scaled parameter row again at its registry minimum (0.001 unless the R20 input records a floor):
# scale gives observed x minimum, scale_inverse observed / minimum, scale_count at least 1 for every count.
by_id = {r['tunable_id']: r for r in registry['tunables']}
minimum_cases = []
for case in [c for c in cases if c['kind'] == 'param' and c['mode'] != 'absolute']:
    low = by_id[case['id']]['limits']['minimum']
    observed = case['observed']
    expect = (observed * low if case['mode'] == 'scale' else observed / low if case['mode'] == 'scale_inverse'
              else scaled_count(observed, low))
    minimum_cases.append(dict(case, value=low, expect=expect, at_minimum=True))
# R20 floors: rows whose minimum stays above 0.001, with the decompile reason (RESEARCH/MISSIONS_R20_MULTIPLIER_MINIMUMS_2026-10-02).
R20_INPUT = EDITOR / 'RESEARCH/MISSIONS_R20_MULTIPLIER_MINIMUMS_2026-10-02/inputs/r20_minimums.json'
R20_FLOORS = {r['tunable_id']: r['minimum'] for r in json.loads(R20_INPUT.read_text(encoding='utf-8'))['rows'] if r['minimum'] > 0.001}
check(len(minimum_cases) == 10 and all(c['value'] <= 0.001 or R20_FLOORS.get(c['id']) == c['value'] for c in minimum_cases),
      'R20: the 10 scaled parameter rows (scale, scale_inverse, scale_count) get a case at their minimum; each accepts 0.001 '
      'except a recorded floor (' + ', '.join(f"{c['id']}={c['value']:g}" for c in minimum_cases) + ')')
check(all(c['expect'] == [1, 1, 1] for c in minimum_cases if c['mode'] == 'scale_count'),
      'R20: scale_count at its minimum writes 1 for every count (the at-least-1 rule)')
cases += minimum_cases

harness = r'''
local emit = print   -- Luau has no io library; the addon's own print is captured below
local printed = {}
print = function(...)
    local parts = {}
    for i = 1, select("#", ...) do parts[#parts + 1] = tostring(select(i, ...)) end
    printed[#printed + 1] = table.concat(parts, " ")
end
local mission
local function fresh_mission()
    mission = { maxWaveNum = 0, alertId = "", invasionId = "", goalId = "", sortieId = "", nightmare = false,
        syndicateTag = { IsValid = function() return false end } }
end
gRegion = { IsMaster = function() return true end }
gGameRules = {
    GetMission = function() local copy = {} for k, v in pairs(mission) do copy[k] = v end return copy end,
    SetMission = function(self, m) mission = m end,
}
local failures = 0
local function ok(condition, name)
    if condition then emit("PASS\t" .. name) else failures = failures + 1 emit("FAIL\t" .. name) end
end
local function same(a, b)
    if type(a) == "table" and type(b) == "table" then
        if #a ~= #b then return false end
        for i = 1, #a do if math.abs(a[i] - b[i]) > 1e-6 then return false end end
        return true
    end
    return type(a) == "number" and type(b) == "number" and math.abs(a - b) < 1e-6
end
local function copy(v)
    if type(v) ~= "table" then return v end
    local t = {} for i = 1, #v do t[i] = v[i] end return t
end
local function settings_for(case)
    return { settings = { [case.id] = { enabled = true, value = case.value, stock = case.stock } } }
end
local function environment_for(case)
    local env = { isDuviriDefense = false, isCircle = false }
    for _, name in ipairs(case.globals or {}) do env[name] = copy(case.observed) end
    return env
end
-- The R13 runtime call at a native entry of prototype P.
local function native_entry(target, prototype, env)
    local hook = target.hooks.luaCalls[prototype]
    if hook == nil then return "NO-HOOK" end
    local r1 = hook.before(prototype, {}, {}, nil, env)
    return r1
end

for _, case in ipairs(CASES) do
    local addon = ADDON_MODULE()
    local target = addon.targets[case.key]
    ok(target ~= nil and target.hooks ~= nil and target.hooks.luaCalls ~= nil, case.id .. ": target " .. case.key .. " declares luaCalls hooks")
    fresh_mission()
    target.activate(settings_for(case))
    local env = environment_for(case)
    local signals = {}
    for _, prototype in ipairs(case.prototypes) do signals[#signals + 1] = native_entry(target, prototype, env) end
    local retire = true
    for _, s in ipairs(signals) do retire = retire and s == "RENOVICE_RETIRE" end
    local tag = case.at_minimum and (case.id .. " at its minimum " .. tostring(case.value)) or case.id
    ok(retire, tag .. ": every entry hook ran and returned the R3 retire signal")
    if case.kind == "param" then
        local written = true
        for _, name in ipairs(case.globals) do written = written and same(env[name], case.expect) end
        ok(written, tag .. ": the native entry writes the parameter global(s) " .. case.mode)
        native_entry(target, case.prototypes[1], env)
        local stable = true
        for _, name in ipairs(case.globals) do stable = stable and same(env[name], case.expect) end
        ok(stable, tag .. ": a second entry of the same instance does not compound")
        local env2 = environment_for(case)
        native_entry(target, case.prototypes[1], env2)
        ok(same(env2[case.globals[1]], case.expect), tag .. ": a new instance (environment) is written again")
        target.cleanup()
        local restored = true
        for _, name in ipairs(case.globals) do restored = restored and same(env[name], case.observed) and same(env2[name], case.observed) end
        ok(restored, tag .. ": cleanup restores the level value in every instance")
    else
        ok(mission[case.field] == case.expect, case.id .. ": the native entry writes MissionInfo." .. case.field .. " through SetMission")
        target.cleanup()
    end
end

-- Defense (R15): Waves per reward is no longer an entry write. The WaveDefense hook (P50, kept for "Waves to finish")
-- must leave the level parameter alone; the decision path and its owner are gated by test_defense_reader_pin_harness.py.
do
    local target = ADDON_MODULE().targets["1a1354d153712f9d"]
    target.activate({ settings = { ["defense.waves_to_finish"] = { enabled = true, value = 5, stock = 0 } } })
    local env = { minWavesToComplete = 3, isDuviriDefense = false, isCircle = false }   -- level ScriptTrigger value
    fresh_mission()
    native_entry(target, 50, env)
    ok(env.minWavesToComplete == 3, "Defense R15: the WaveDefense entry hook does not write minWavesToComplete")
    target.cleanup()
end
-- R17: the Deepmines AreaDefense module is no longer an addon target (its two rows are reader pins, live literals).
ok(ADDON_MODULE().targets["e4bb611e00823d46"] == nil, "Deepmines R17: AreaDefense has no entry hook any more (reader pins)")
emit(failures == 0 and "ENTRY NATIVE HARNESS PASS" or "ENTRY NATIVE HARNESS FAIL")
'''

script = WORK / 'entry_native_harness.luau'
script.write_text('ADDON_MODULE = function(...)\n' + source + '\nend\n' + 'CASES = ' + lua(cases) + '\n' + harness,
                  encoding='utf-8')
check(LUAU.is_file(), 'toolchain luau.exe present')
run = subprocess.run([str(LUAU), str(script)], capture_output=True, text=True)
lines = run.stdout.splitlines()
for line in lines:
    print('HARNESS\t' + line)
if run.stderr.strip():
    print('HARNESS-STDERR\t' + run.stderr.strip())
check(run.returncode == 0 and 'ENTRY NATIVE HARNESS PASS' in lines and not any(l.startswith('FAIL') for l in lines),
      f'harness: {sum(l.startswith("PASS") for l in lines)} checks over 21 entry rows, the 10 scaled rows at their R20 minimum, '
      'the R15 Defense and R17 Deepmines checks')
OUT.mkdir(parents=True, exist_ok=True)
(OUT / 'entry_native_harness.json').write_text(json.dumps(results, indent=2) + '\n', encoding='utf-8')
print('ENTRY NATIVE HARNESS GATE PASS')
