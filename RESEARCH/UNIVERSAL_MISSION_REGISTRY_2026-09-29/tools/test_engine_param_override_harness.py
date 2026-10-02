"""Engine re-write gate for the R16 ENGINE_PARAM_OVERRIDE rows (2026-10-01, contract R16).

Why: R15 found that a level/encounter script parameter is owned by the engine's own parameter writer (44.0.2 apply_param
0x181CAE0, value push 0x191A010), which writes the level value into the script instance's environment and writes it
again on later engine paths. The R10 entry write of SCRIPT_PARAM_GLOBAL_AT_ENTRY is therefore lost for readers that run
after a yield of the same instance (EXPOSED rows). R16 moves those rows to the writer: the generator emits
Packages/Missions/engine_params.json, and the bootstrapper's native hook replaces the number the writer pushes
(stock x value, stock / value, value, or the R11 count rule) on EVERY write, while the R10 addon write stays as the
fallback for older DLLs. The bootstrapper withholds the overridden values from the addon's context.settings when its hook
is installed, so the addon writes nothing for them (no double application).

R17 (2026-10-01): one more admitted row (Gas City meltdown time: hackTime and modeTimer scaled together) and a master on
a natively owned row (Railjack kill goals over the Corpus fighter limit: engine_params.json names the master; the addon
leaves that row out of its master drives, the bootstrapper withholds only the row, never the master).

This gate:
  1. builds the pinned build input with the generator CLI: the addon, package.json, literals.json and engine_params.json
     are the pinned R17 build;
  2. re-checks engine_params.json against the registry: every override is an admitted ENGINE_PARAM_OVERRIDE_V1 row, one
     entry per parameter global, the U44 name hash, the row's own mode, the row's stock module key; the bootstrapper's
     gate fixture is byte-identical (when the R16 worktree is present);
  3. runs the REAL generated addon in plain Luau in the observed engine order
        engine writes the level values -> native entry hook(s) -> engine writes again (x3), a reader after each write
     for every R16 row and three runtimes:
        R16 DLL, hook installed  : the writer applies engine_params.json; the addon gets the values withheld
                                   -> every read sees the configured value, the addon writes nothing;
        R13/R15 DLL (no native)  : the addon gets the values -> the first read after the entry sees the value, the next
                                   engine write restores the level value (the R15 failure, reproduced as a control);
        R16 DLL, hook refused    : nothing withheld -> identical to R13/R15 (the R10 fallback stays alive);
     and the negative control "native + addon both apply" (what withholding prevents): a scaled row compounds.
The native arithmetic here is a Luau transcription of renovice/engine_params_core.hpp override_number; the same expected
numbers are asserted by the bootstrapper gate verify_engine_params.ps1 (B1) on the production C++.

Limits: the DE VM does not run here; the writer and the readers are modelled (the writer's exact contract is the
bootstrapper's byte-checked registration). Nothing here is live.

Paths: CLI = RENOVICE_EDITOR_CLI or work/builds/ability-editor/current; luau.exe from the DE Luau toolchain. Writes only
to work/temp/engine-param-override-harness and this tool's test-results folder. Reads no game or server folder.
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
# R18 build of the pinned input (R17: addon daab653a, package.json fb43906b, literals.json 028fdcd2, engine_params 26e56e26;
# R15/R16: addon 70fff0b6, package.json 44fc0b53, literals.json a16b2520, engine_params ae090c33).
R15 = {'Missions.targets.addon.lua_B': '43cb89c3a3f230c75d9fdb665a57418023d54d2c4d5d555c9faf539a192ebba7',
       'package.json': '150c0d1642d9208f97fc46df7a14ce411b60120cb4280d30f991aaf179978ff7',
       'literals.json': '786c7b94a7c296758b8c94d40c3fcd69cb1a5dcbcda661a2cc7f15093cc1cbe6'}
ENGINE_PARAMS_SHA = '13cb029064ef4c29141a0bbec37e3daf5888a5271fae141bc9282db9c07c0341'
# R18 needs no bootstrapper change: the bootstrapper's gate fixture stays the R17 build (its own gate runs on it); the R18
# package itself goes through the bootstrapper scanner in verify_addon_settings.ps1 -Package (staging evidence).
R17_FIXTURE = {'engine_params.json': '26e56e26775dfec42b0ca3aa725a5b23163b4671b2fa1128abf43b1538e3bf7c',
               'package.json': 'fb43906b7c6d1532fe550a4639bbcda85a0cd1c315996c3b3815be01a3cff9f3'}
# The bootstrapper gate fixture (R17; the R16 fixture stays in fixtures/Missions).
BOOTSTRAPPER_FIXTURE = ROOT / 'repos/runtime/bootstrapper-runtime-wt-r16/RENOVICE_TOOLCHAIN/engine_params/fixtures/MissionsR17'
WORK = ROOT / 'work/temp/engine-param-override-harness'
OUT = Path(__file__).resolve().parents[1] / 'test-results'
results = {'checks': []}

# Level values and test values (the same numbers as the bootstrapper gate B1).
CASES = {
    'exterminate.kills_scale': {'observed': {'metersPerEnemy': 12.5}, 'value': 0.1, 'expect': {'metersPerEnemy': 125}},
    'exterminate.archwing_kill_mult': {'observed': {'spaceBattleKillCountMultiplier': 0.5}, 'value': 0.8,
                                       'expect': {'spaceBattleKillCountMultiplier': 0.8}},
    'interception.score_goal_scale': {'observed': {'scoreGoal': 1450}, 'value': 0.5, 'expect': {'scoreGoal': 725}},
    'interception.scoring_speed': {'observed': {'scoreRatePerSecond': 1}, 'value': 2, 'expect': {'scoreRatePerSecond': 2}},
    'interception.round_end_timer': {'observed': {'roundEndTimer': 15}, 'value': 30, 'expect': {'roundEndTimer': 30}},
    'railjack.corpus_fighter_limit_scale': {'observed': {'minorKillGoals': [20, 35, 55, 85, 110], 'minorKillGoalsMax': [35, 55, 85, 110, 130]},
                                            'value': 0.5,
                                            'expect': {'minorKillGoals': [10, 18, 28, 43, 55], 'minorKillGoalsMax': [18, 28, 43, 55, 65]}},
    # R17: both level parameters scaled (the countdown is hackTime, recomputed from modeTimer by the script).
    'sabotage.gascity_meltdown_time_scale': {'observed': {'hackTime': 10, 'modeTimer': 60}, 'value': 2,
                                             'expect': {'hackTime': 20, 'modeTimer': 120}},
    # R18: the Pontis tower stage-1 space-enemy goals (H.AnimRetarget encounter lists), scale_count.
    'railjack.pontis_ash_enemies_scale': {'observed': {'spaceEnemyCountPerVariant': [4, 4, 5, 5, 6]}, 'value': 0.5,
                                          'expect': {'spaceEnemyCountPerVariant': [2, 2, 3, 3, 3]}},
    'railjack.pontis_garuda_enemies_scale': {'observed': {'spaceEnemyCountPerVariant': [4, 4, 5, 5, 6, 6, 7]}, 'value': 0.5,
                                             'expect': {'spaceEnemyCountPerVariant': [2, 2, 3, 3, 3, 3, 4]}},
}


def check(ok, name):
    results['checks'].append({'name': name, 'pass': bool(ok)})
    print(('PASS' if ok else 'FAIL') + '\t' + name)
    if not ok:
        OUT.mkdir(parents=True, exist_ok=True)
        (OUT / 'engine_param_override_harness.json').write_text(json.dumps(results, indent=2) + '\n', encoding='utf-8')
        sys.exit(1)


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def namehash(name):
    h = 0x768e5ed0
    for c in name.encode():
        h = ((h ^ c) * 0x01000193) & 0xffffffff
    h = ~h & 0xffffffff
    return ((h << 17) | (h >> 15)) & 0xffffffff


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


# 1. Build.
check(hashlib.sha256(INPUT.read_bytes().replace(b'\r\n', b'\n')).hexdigest() == INPUT_LF_SHA, 'pinned build input (LF content)')
shutil.rmtree(WORK, ignore_errors=True)
WORK.mkdir(parents=True)
run = subprocess.run([str(CLI), 'build-missions', str(INPUT), '--staging', str(WORK / 'build'), '--editor-root', str(EDITOR)],
                     capture_output=True, text=True)
generations = list((WORK / 'build').glob('missions/*/MISSION_SET_MANIFEST.json'))
check(run.returncode == 0 and len(generations) == 1, 'build succeeds')
generation = generations[0].parent
package = generation / 'Packages/Missions'
for name, digest in R15.items():
    check(sha(package / name) == digest, f'{name} is the pinned R18 build ({digest[:8]})')
check(sha(package / 'engine_params.json') == ENGINE_PARAMS_SHA, f'engine_params.json is the pinned R18 build ({ENGINE_PARAMS_SHA[:8]})')
manifest = json.loads(generations[0].read_text(encoding='utf-8'))
record = manifest['package'].get('engine_params') or {}
check(record.get('sha256', '').lower() == ENGINE_PARAMS_SHA and record.get('overrides') == 11 and record.get('modules') == 6
      and record.get('masters') == ['railjack.kill_goals_scale']
      and any(g['name'] == 'engine-param-overrides' and g['pass'] for g in manifest['package']['gates']),
      'manifest records engine_params.json (11 overrides, 6 modules, master railjack.kill_goals_scale) and the engine-param-overrides gate')

# 2. Re-check the declarations against the registry.
recipe = json.loads((package / 'engine_params.json').read_text(encoding='utf-8'))
registry = json.loads((EDITOR / 'REGISTRIES/mission_build_u44.json').read_text(encoding='utf-8'))
rows = {r['tunable_id']: r for r in registry['tunables']}
admitted = {tid for tid, r in rows.items() if isinstance(r.get('owner'), dict) and 'engine_override' in r['owner']}
check(admitted == set(CASES), f'registry: the six R15 EXPOSED rows, the R17 Gas City row and the two R18 Pontis rows are admitted ENGINE_PARAM_OVERRIDE_V1 ({sorted(admitted)})')
check(recipe['format'] == 'RENOVICE_ENGINE_PARAMS_V1' and recipe['package'] == 'package:missions'
      and recipe['build'] == registry['build'] and recipe['member'] == 'Missions.targets.addon.lua_B',
      'recipe header: format, package id, client build, addon member')
covered = {}
for item in recipe['overrides']:
    row = rows[item['value']]
    owner = row['owner']
    master = next((m for mid, m in registry['ui_masters'].items() if any(d['tunable_id'] == item['value'] for d in m['drives'])
                   and mid == item.get('master')), None)
    ok = (item['value'] in admitted and owner['template'] == 'SCRIPT_PARAM_GLOBAL_AT_ENTRY' and item['module'] == owner['body_key']
          and (('master' not in item and 'scale' not in item) or (master is not None and master['lane'] == 'addon' and item['scale'] == 1))
          and item['mode'] == owner['mode'] == owner['engine_override']['mode']
          and item['hash'] == f'{namehash(item["parameter"]):08x}'
          and {'name': item['parameter'], 'hash': item['hash']} in owner['globals'])
    check(ok, f'{item["value"]} {item["parameter"]}: admitted row, module {item["module"]}, hash {item["hash"]}, mode {item["mode"]}')
    covered.setdefault(item['value'], set()).add(item['parameter'])
check(all(covered.get(tid) == {g['name'] for g in rows[tid]['owner']['globals']} for tid in admitted),
      'every parameter global of every admitted row has exactly one override (no partial row)')
check([(o['value'], o['parameter']) for o in recipe['overrides'] if 'master' in o]
      == [('railjack.corpus_fighter_limit_scale', 'minorKillGoals'), ('railjack.corpus_fighter_limit_scale', 'minorKillGoalsMax'),
          ('railjack.pontis_ash_enemies_scale', 'spaceEnemyCountPerVariant'),
          ('railjack.pontis_garuda_enemies_scale', 'spaceEnemyCountPerVariant')],
      'R17/R18: only the natively owned rows the Railjack master drives (Corpus fighters, both Pontis rows) name a master')
if BOOTSTRAPPER_FIXTURE.is_dir():
    check(sha(BOOTSTRAPPER_FIXTURE / 'engine_params.json') == R17_FIXTURE['engine_params.json']
          and sha(BOOTSTRAPPER_FIXTURE / 'package.json') == R17_FIXTURE['package.json'],
          'the bootstrapper R17 gate fixture (fixtures/MissionsR17) is the R17 build (R18 adds no bootstrapper change)')
else:
    print('INFO\tbootstrapper worktree absent; fixture identity not compared')

# 3. The engine re-write order with the real addon.
source = (generation / 'source/Missions.targets.addon.luau').read_text(encoding='utf-8')
cases = []
for tid, case in CASES.items():
    owner = rows[tid]['owner']
    cases.append({'id': tid, 'key': owner['body_key'], 'stock': rows[tid]['stock'], 'mode': owner['mode'],
                  'prototypes': [e['prototype'] for e in owner['entries']], 'globals': [g['name'] for g in owner['globals']],
                  'observed': case['observed'], 'value': case['value'], 'expect': case['expect']})
harness = r'''
local emit = print
local printed = {}
print = function(...)
    local parts = {}
    for i = 1, select("#", ...) do parts[#parts + 1] = tostring(select(i, ...)) end
    printed[#printed + 1] = table.concat(parts, " ")
end
gRegion = { IsMaster = function() return true end }
gGameRules = { GetMission = function() return { maxWaveNum = 0, alertId = "", invasionId = "", goalId = "", sortieId = "",
    nightmare = false, syndicateTag = { IsValid = function() return false end } } end, SetMission = function() end }
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
-- renovice/engine_params_core.hpp override_number (R10/R11 arithmetic)
local function override(mode, n, v)
    if mode == "absolute" then return v end
    if mode == "scale" then return n * v end
    if mode == "scale_inverse" then return n / v end
    if n < 1 then return n end
    local r = n * v + 0.5
    r = r - r % 1
    if r < 1 then r = 1 end
    return r
end
-- The engine's parameter writer: every write stores the level value, through the native override when installed.
-- A list parameter is a NEW table on every write (lua_createtable + rawseti per element).
local function engine_write(env, case, native)
    for _, name in ipairs(case.globals) do
        local level = case.observed[name]
        if type(level) == "table" then
            local list = {}
            for i = 1, #level do list[i] = native and override(case.mode, level[i], case.value) or level[i] end
            env[name] = list
        else
            env[name] = native and override(case.mode, level, case.value) or level
        end
    end
end
local function reads(env, case, want)
    for _, name in ipairs(case.globals) do if not same(env[name], want[name]) then return false end end
    return true
end
local function entries(target, case, env)
    for _, prototype in ipairs(case.prototypes) do
        local hook = target.hooks.luaCalls[prototype]
        if hook ~= nil then hook.before(prototype, {}, {}, nil, env) end
    end
end
local function prints_for(id)
    local count = 0
    for _, line in ipairs(printed) do if string.find(line, id, 1, true) then count = count + 1 end end
    return count
end
local function run(case, runtime)
    -- runtime: "r16" (hook installed, values withheld), "old" (R13/R15 DLL), "refused" (R16 DLL, hook not installed),
    -- "both" (negative control: native AND the addon value).
    local native = runtime == "r16" or runtime == "both"
    local delivered = runtime ~= "r16"
    local addon = ADDON_MODULE()
    local target = addon.targets[case.key]
    local settings = {}
    if delivered then settings[case.id] = { enabled = true, value = case.value, stock = case.stock } end
    target.activate({ settings = settings })
    printed = {}
    local env = { isDuviriDefense = false, isCircle = false }
    local seen = {}
    engine_write(env, case, native)              -- the instance is created with the level values
    entries(target, case, env)                   -- engine enters the entry function (R13 native entry dispatch)
    seen[#seen + 1] = reads(env, case, case.expect)
    for _ = 1, 3 do                              -- the engine writes the parameters again (R15)
        engine_write(env, case, native)
        seen[#seen + 1] = reads(env, case, case.expect)
    end
    local writes = prints_for(case.id)
    target.cleanup()
    return seen, writes, env
end

for _, case in ipairs(CASES) do
    local seen, writes = run(case, "r16")
    local all = true
    for _, s in ipairs(seen) do all = all and s end
    ok(all, case.id .. ": R16 (hook installed): every read after the entry and after 3 engine re-writes sees the configured value")
    ok(writes == 0, case.id .. ": R16: the addon gets no value for the row and writes nothing (no double application)")

    local old, old_writes = run(case, "old")
    ok(old[1] and not old[2] and not old[3] and not old[4] and old_writes == #case.globals,
        case.id .. ": R13/R15 DLL: the entry write is seen once, the next engine write restores the level value (R15 failure, control)")
    local refused, refused_writes = run(case, "refused")
    ok(refused[1] and not refused[2] and refused_writes == #case.globals,
        case.id .. ": R16 DLL with the hook refused: nothing withheld, the R10 addon write stays the fallback")

    local both = run(case, "both")
    if case.mode == "absolute" then
        ok(both[1], case.id .. ": absolute value: native + addon would agree (idempotent)")
    else
        ok(not both[1], case.id .. ": native + addon on the same value compounds (" .. case.mode .. "): the withholding is required")
    end
end
-- R17: the Railjack master drives the Grineer rows in the addon and the Corpus row at the engine writer. With the hook
-- installed the bootstrapper withholds only the Corpus row; the master is delivered. The addon must scale the Grineer
-- fighters and write NOTHING for the Corpus row (else the native master value and the addon write would compound).
do
    local master = { ["railjack.kill_goals_scale"] = { enabled = true, value = 0.5, stock = 1 } }
    local addon = ADDON_MODULE()
    local corpus = addon.targets[CORPUS_KEY]
    corpus.activate({ settings = master })
    printed = {}
    local env = { minorKillGoals = { 20, 35, 55, 85, 110 }, minorKillGoalsMax = { 35, 55, 85, 110, 130 } }
    for _, prototype in ipairs(CORPUS_PROTOTYPES) do
        local hook = corpus.hooks.luaCalls[prototype]
        if hook ~= nil then hook.before(prototype, {}, {}, nil, env) end
    end
    ok(same(env.minorKillGoals, { 20, 35, 55, 85, 110 }) and prints_for("railjack.corpus_fighter_limit_scale") == 0,
        "R17: the master alone writes nothing into the natively owned Corpus row from the addon (no double application)")
    local native = { minorKillGoals = {}, minorKillGoalsMax = {} }
    for i, n in ipairs({ 20, 35, 55, 85, 110 }) do native.minorKillGoals[i] = override("scale_count", n, 0.5) end
    ok(same(native.minorKillGoals, { 10, 18, 28, 43, 55 }), "R17: the engine writer applies the master (0.5) to the Corpus row")
    corpus.cleanup()
    local fighters = addon.targets[FIGHTERS_KEY]
    fighters.activate({ settings = master })
    local fenv = { minorKillGoals = { 20, 35 }, minorKillGoalsMax = { 35, 55 }, kuvaLichKillGoalMin = 50, kuvaLichKillGoalMax = 60 }
    for _, prototype in ipairs(FIGHTERS_PROTOTYPES) do
        local hook = fighters.hooks.luaCalls[prototype]
        if hook ~= nil then hook.before(prototype, {}, {}, nil, fenv) end
    end
    ok(same(fenv.minorKillGoals, { 10, 18 }) and fenv.kuvaLichKillGoalMin == 25,
        "R17: the same master scales the Grineer fighter goals in the addon (another module)")
    fighters.cleanup()
end
emit(failures == 0 and "ENGINE PARAM OVERRIDE HARNESS PASS" or "ENGINE PARAM OVERRIDE HARNESS FAIL")
'''
script = WORK / 'engine_param_override_harness.luau'
corpus_row, fighters_row = rows['railjack.corpus_fighter_limit_scale'], rows['railjack.fighter_kills_scale']
extra = ('CORPUS_KEY = ' + lua(corpus_row['owner']['body_key']) + '\nCORPUS_PROTOTYPES = '
         + lua([e['prototype'] for e in corpus_row['owner']['entries']]) + '\nFIGHTERS_KEY = ' + lua(fighters_row['owner']['body_key'])
         + '\nFIGHTERS_PROTOTYPES = ' + lua([e['prototype'] for e in fighters_row['owner']['entries']]) + '\n')
script.write_text('ADDON_MODULE = function(...)\n' + source + '\nend\n' + 'CASES = ' + lua(cases) + '\n' + extra + harness,
                  encoding='utf-8')
check(LUAU.is_file(), 'toolchain luau.exe present')
run = subprocess.run([str(LUAU), str(script)], capture_output=True, text=True)
lines = run.stdout.splitlines()
for line in lines:
    print('HARNESS\t' + line)
if run.stderr.strip():
    print('HARNESS-STDERR\t' + run.stderr.strip())
check(run.returncode == 0 and 'ENGINE PARAM OVERRIDE HARNESS PASS' in lines and not any(l.startswith('FAIL') for l in lines),
      f'harness: {sum(l.startswith("PASS") for l in lines)} Luau checks over the six R16 rows, the R17 Gas City row and the R17 Railjack master')
OUT.mkdir(parents=True, exist_ok=True)
(OUT / 'engine_param_override_harness.json').write_text(json.dumps(results, indent=2) + '\n', encoding='utf-8')
print('ENGINE PARAM OVERRIDE HARNESS GATE PASS')
