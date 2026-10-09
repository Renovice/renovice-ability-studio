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

R19 (2026-10-02): the Grineer Railjack fighter and crewship goals move to the writer too. R15 classed their reads REACHES
(read inside the entry call), but the live session pid 7128 logged the addon's entry write ({20/35/55/70/85/95} ->
{2/4/6/7/9/10}) and the objective still ran to a stock-size goal. Every Railjack row the master drives is now natively owned:
the addon keeps the master compiled (no drives) and writes nothing with the hook installed; the exact live numbers are the
expected writer output (master + rows at 0.1, a row on at x1 wins, a master at its stock writes nothing).

R21 (2026-10-02): class audit after R19. The last two rows on the plain R10 entry write, Spy "vault alarm time"
(Intel P43, intelTimerDurationMax/Min) and Sabotage "surprise extraction" (Sabotage P11, duration), are level ScriptTrigger
parameters whose only producer is the engine writer, read in the entry call (REACHES): the class R19 refuted live. Both move
to the writer. New section "R19 failure order": game writer first, then the addon's Lua entry write, then the read, under
the three mechanisms R19 left open (H1d: a re-write between the entry write and the read; a reader environment other than
the callee environment; a value resolved before the entry write). The R10 lane alone reproduces the live signature (the
write is logged, the read sees the level value); the writer lane gives the configured value under all three.

This gate:
  1. builds the pinned build input with the generator CLI: the addon, package.json, literals.json and engine_params.json
     are the pinned R21 build;
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
from harness_input import current_input, current_spec  # noqa: E402  (same folder; 2026-10-09 current build)

EDITOR = Path(__file__).resolve().parents[3]
ROOT = EDITOR
while not (ROOT / 'WORKSPACE.json').exists():
    ROOT = ROOT.parent
CLI = Path(os.environ.get('RENOVICE_EDITOR_CLI', ROOT / 'work/builds/ability-editor/current/bin/renovice_ability_editor_cli.exe'))
LUAU = ROOT / 'repos/toolchains/de-luau-toolchain/bin/luau.exe'
INPUT = EDITOR / 'RESEARCH/MISSIONS_R13_NATIVE_ENTRY_2026-10-01/inputs/rebuild_input.r12.json'
INPUT_LF_SHA = 'dccde5fddf2649c2be4c93789cecab4cc1d1759dc9d01d0117cba25f5a7ca4b6'  # LF content (checkout-independent)
# R19 build of the pinned input (R18: addon 43cb89c3, engine_params 13cb0290, package.json and literals.json unchanged;
# R17: addon daab653a, package.json fb43906b, literals.json 028fdcd2, engine_params 26e56e26;
# R15/R16: addon 70fff0b6, package.json 44fc0b53, literals.json a16b2520, engine_params ae090c33).
# R20 (2026-10-02): the multiplier minimums change only package.json and literals.json (minimums, types, descriptions);
# R19 package.json 150c0d16, literals.json 786c7b94 (also the bootstrapper R19 fixture's package.json).
# R22 (2026-10-02): the Void Cascade exolizer speed master (inverse drive, addon) and the reward-interval live literal;
# R20/R21 built d8736450 / acc2256e / 96a97899. engine_params.json is unchanged (R21).
# 2026-10-09: re-pinned to the 44.1.1 registry with R23 (addon 76c10eaa, package f577faa0, literals 0de8885a, engine params 731029cf; R22 on 44.0.2 was a943cd3e / fd89daca / 9beaa438 / 20323777).
R15 = {'Missions.targets.addon.lua_B': '76c10eaa1df91ad71e86afe27147694beb28045957e3785b39ed0b7b64df88a0',
       'package.json': 'f577faa0283988151a0c1a6defa58e87e9b2b15c256b4320c6cf7b873e8ff25f',
       'literals.json': '0de8885a1bbb4a550a72491f37ee33b14ed442b60d8d87552011e4cbf2a01b90'}
R19_FIXTURE_PACKAGE = '150c0d1642d9208f97fc46df7a14ce411b60120cb4280d30f991aaf179978ff7'
# R21 (2026-10-02): only engine_params.json changes (R19/R20 eafd2ddf: 17 overrides, 8 modules); addon, package.json and
# literals.json are the R20 files byte for byte.
ENGINE_PARAMS_SHA = '731029cf03071416ae4bfb379dc7e801155f570d01ab527567e9cf695d48c472'
# The bootstrapper gate fixture of this build (R21, fixtures/MissionsR21: engine_params.json and the R20 package.json; the
# R16, R17 and R19 fixtures stay in their folders).
BOOTSTRAPPER_FIXTURE = ROOT / 'repos/runtime/bootstrapper-runtime-wt-r19/RENOVICE_TOOLCHAIN/engine_params/fixtures/MissionsR21'
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
    # R19: the Grineer Railjack Exterminate goals, with the lists the engine wrote in the live session pid 7128 (Steel Path,
    # six tiers). Fighters at x0.1 are the exact live entry-write numbers; crewships at x0.5 (x0.1 floors every tier at 1,
    # which would hide the compounding negative control below).
    'railjack.fighter_kills_scale': {'observed': {'minorKillGoals': [20, 35, 55, 70, 85, 95], 'minorKillGoalsMax': [35, 55, 85, 90, 95, 105],
                                                  'kuvaLichKillGoalMin': 50, 'kuvaLichKillGoalMax': 60},
                                     'value': 0.1,
                                     'expect': {'minorKillGoals': [2, 4, 6, 7, 9, 10], 'minorKillGoalsMax': [4, 6, 9, 9, 10, 11],
                                                'kuvaLichKillGoalMin': 5, 'kuvaLichKillGoalMax': 6}},
    'railjack.crewship_kills_scale': {'observed': {'majorKillGoals': [2, 4, 6, 7, 8, 9], 'kuvaLichKillGoal': 3}, 'value': 0.5,
                                      'expect': {'majorKillGoals': [1, 2, 3, 4, 4, 5], 'kuvaLichKillGoal': 2}},
    # R21: the Spy vault alarm (most common level pair 35/55; both globals scaled together) and the Sabotage surprise
    # extraction (300 on all 9 Sabotage.lua triggers; absolute).
    'spy.vault_alarm_scale': {'observed': {'intelTimerDurationMax': 55, 'intelTimerDurationMin': 35}, 'value': 0.5,
                              'expect': {'intelTimerDurationMax': 27.5, 'intelTimerDurationMin': 17.5}},
    'sabotage.random_extraction_timer': {'observed': {'duration': 300}, 'value': 120, 'expect': {'duration': 120}},
}
# R21: the rows this revision moved from the plain R10 entry write to the writer.
R21_MIGRATED = ['spy.vault_alarm_scale', 'sabotage.random_extraction_timer']


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
run = subprocess.run([str(CLI), 'build-missions', str(current_input(INPUT, WORK)), '--staging', str(WORK / 'build'), '--editor-root', str(EDITOR)],
                     capture_output=True, text=True)
generations = list((WORK / 'build').glob('missions/*/MISSION_SET_MANIFEST.json'))
check(run.returncode == 0 and len(generations) == 1, 'build succeeds')
generation = generations[0].parent
package = generation / 'Packages/Missions'
for name, digest in R15.items():
    check(sha(package / name) == digest, f'{name} is the pinned R22 build ({digest[:8]}; R20/R21 d8736450 / acc2256e / 96a97899)')
check(sha(package / 'engine_params.json') == ENGINE_PARAMS_SHA, f'engine_params.json is the pinned R21 build ({ENGINE_PARAMS_SHA[:8]})')
manifest = json.loads(generations[0].read_text(encoding='utf-8'))
record = manifest['package'].get('engine_params') or {}
check(record.get('sha256', '').lower() == ENGINE_PARAMS_SHA and record.get('overrides') == 20 and record.get('modules') == 10
      and record.get('masters') == ['railjack.kill_goals_scale'] and len(record.get('rows', [])) == 13
      and any(g['name'] == 'engine-param-overrides' and g['pass'] for g in manifest['package']['gates']),
      'manifest records engine_params.json (20 overrides, 13 values, 10 modules, master railjack.kill_goals_scale) and the engine-param-overrides gate')

# 2. Re-check the declarations against the registry.
recipe = json.loads((package / 'engine_params.json').read_text(encoding='utf-8'))
registry = json.loads((EDITOR / 'REGISTRIES/mission_build_u44.json').read_text(encoding='utf-8'))
rows = {r['tunable_id']: r for r in registry['tunables']}
admitted = {tid for tid, r in rows.items() if isinstance(r.get('owner'), dict) and 'engine_override' in r['owner']}
check(admitted == set(CASES), f'registry: the six R15 EXPOSED rows, the R17 Gas City row, the two R18 Pontis rows, the two R19 Grineer Railjack rows and the two R21 rows are admitted ENGINE_PARAM_OVERRIDE_V1 ({sorted(admitted)})')
# R21 class audit: no SCRIPT_PARAM_GLOBAL_AT_ENTRY row is left on the plain R10 entry write (every one is writer-owned, the
# entry write only its fallback), and every MissionInfo row stays on its own template (MISSION_INFO_FIELD_AT_ENTRY).
plain_r10 = sorted(tid for tid, r in rows.items() if isinstance(r.get('owner'), dict)
                   and r['owner'].get('template') == 'SCRIPT_PARAM_GLOBAL_AT_ENTRY' and 'engine_override' not in r['owner'])
check(plain_r10 == [], f'R21: no level/encounter parameter row is left on the plain R10 entry write ({plain_r10})')
mission_info = sorted(tid for tid, r in rows.items() if isinstance(r.get('owner'), dict) and r['owner'].get('template') == 'MISSION_INFO_FIELD_AT_ENTRY')
# R23 (2026-10-09): + 6 Icebind rows (variant KUVA_PATH_MISSION) on the same template; 8 normal-node rows as before.
normal_info = [t for t in mission_info if 'variant' not in rows[t]['owner']]
icebind_info = [t for t in mission_info if rows[t]['owner'].get('variant') == 'KUVA_PATH_MISSION']
check(len(normal_info) == 8 and len(icebind_info) == 6 and len(mission_info) == 14
      and all(rows[t]['owner'].get('field') == 'maxWaveNum' and 'engine_override' not in rows[t]['owner'] for t in mission_info),
      f'R21: the 8 normal-node and 6 Icebind (R23) MissionInfo rows stay on MISSION_INFO_FIELD_AT_ENTRY (maxWaveNum, not a level parameter) ({mission_info})')
for tid in R21_MIGRATED:
    owner = rows[tid]['owner']
    check(owner['engine_override']['exposure'].startswith('EXPOSED (R19 class)')
          and [g['name'] for g in owner['engine_override']['parameters']] == [g['name'] for g in owner['globals']],
          f'R21 {tid}: admitted with the R19-class exposure, every parameter global covered')
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
          ('railjack.pontis_garuda_enemies_scale', 'spaceEnemyCountPerVariant'),
          ('railjack.crewship_kills_scale', 'majorKillGoals'), ('railjack.crewship_kills_scale', 'kuvaLichKillGoal'),
          ('railjack.fighter_kills_scale', 'minorKillGoals'), ('railjack.fighter_kills_scale', 'minorKillGoalsMax'),
          ('railjack.fighter_kills_scale', 'kuvaLichKillGoalMin'), ('railjack.fighter_kills_scale', 'kuvaLichKillGoalMax')],
      'R17/R18/R19: exactly the natively owned rows the Railjack master drives (Corpus fighters, both Pontis rows, Grineer crewships '
      'and fighters) name a master')
master_row = registry['ui_masters']['railjack.kill_goals_scale']
check({d['tunable_id'] for d in master_row['drives']} == {o['value'] for o in recipe['overrides'] if o.get('master') == 'railjack.kill_goals_scale'},
      'R19: every row the Railjack master drives is owned at the engine writer (no addon drive left)')
addon_source = (generation / 'source/Missions.targets.addon.luau').read_text(encoding='utf-8')
check(addon_source.count('["railjack.kill_goals_scale"] = { value = ') == 1 and '["railjack.fighter_kills_scale"] = { master =' not in addon_source
      and '["railjack.crewship_kills_scale"] = { master =' not in addon_source,
      'R19: the addon compiles the Railjack master once (its own module, no drives) and drives neither Grineer row')
if BOOTSTRAPPER_FIXTURE.is_dir():
    # R22: engine_params.json is unchanged, so the R21 fixture still holds this build's file; its package.json stays the R20/R21
    # one (acc2256e). The R22 package.json is checked against engine_params.json by verify_addon_settings -Package
    # (ENGINE PARAMS RECIPE ACCEPT), recorded in the R22 staging evidence.
    check(sha(BOOTSTRAPPER_FIXTURE / 'engine_params.json') == ENGINE_PARAMS_SHA
          and sha(BOOTSTRAPPER_FIXTURE / 'package.json') == 'acc2256eb4a76f6782af1aa51534a5387c065ae1323da36daa45dfbbd06f6d71',
          'the bootstrapper R21 gate fixture (fixtures/MissionsR21) holds the engine_params.json of this build (unchanged since R21) '
          'and the R20/R21 package.json')
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
# R20 (2026-10-02): every writer-owned row again at its registry minimum (0.001 unless the R20 input records a floor), with
# the expected writer output transcribed from engine_params_core.hpp override_number (float32 there; the expected numbers
# below are exact in both precisions within the harness tolerance).
def override(mode, n, v):
    if mode == 'absolute':
        return v
    if mode == 'scale':
        return n * v
    if mode == 'scale_inverse':
        return n / v
    if n < 1:
        return n
    return max(1, int(n * v + 0.5))


minimum_cases = []
for case in cases:
    low = rows[case['id']]['limits']['minimum']
    expect = {name: ([override(case['mode'], n, low) for n in level] if isinstance(level, list) else override(case['mode'], level, low))
              for name, level in case['observed'].items()}
    minimum_cases.append(dict(case, value=low, expect=expect, at_minimum=True))
# R20 floors: rows whose minimum stays above 0.001, with the decompile reason (RESEARCH/MISSIONS_R20_MULTIPLIER_MINIMUMS_2026-10-02).
R20_INPUT = EDITOR / 'RESEARCH/MISSIONS_R20_MULTIPLIER_MINIMUMS_2026-10-02/inputs/r20_minimums.json'
R20_FLOORS = {r['tunable_id']: r['minimum'] for r in json.loads(R20_INPUT.read_text(encoding='utf-8'))['rows'] if r['minimum'] > 0.001}
check(all(c['value'] <= 0.001 or R20_FLOORS.get(c['id']) == c['value'] for c in minimum_cases if c['mode'] != 'absolute' or c['value'] < 1),
      'R20: every writer-owned multiplier accepts 0.001 except a recorded floor (' + ', '.join(f"{c['id']}={c['value']:g}" for c in minimum_cases) + ')')
check(all(all(n == 1 for n in (v if isinstance(v, list) else [v])) for c in minimum_cases if c['mode'] == 'scale_count'
          for v in c['expect'].values()),
      'R20: scale_count at its minimum: the writer stores 1 for every count (at least one)')
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

-- R20: each writer-owned row at its minimum: with the hook every read sees the minimum's result; the addon writes nothing.
for _, case in ipairs(MINIMUM_CASES) do
    local seen, writes = run(case, "r16")
    local all = true
    for _, s in ipairs(seen) do all = all and s end
    ok(all and writes == 0, case.id .. ": R20 at its minimum " .. tostring(case.value) .. " (" .. case.mode
        .. "): every read after the entry and 3 engine re-writes sees the writer's result; the addon writes nothing")
    local old = run(case, "old")
    ok(old[1], case.id .. ": R20 at its minimum: the R10 entry fallback writes the same result")
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
-- R21: the R19 failure order. Game writer first, then the addon's Lua entry write, then the read, under each mechanism R19
-- left open (H1d): "rewrite" = the engine writes again between the entry write and the read (R15 shape, H1d c); "reader_env"
-- = the reader resolves the global in an instance environment the writer filled but the entry hook was not handed (H1d b);
-- "early" = the reader holds the value it resolved before the entry write (an import resolved at load, H1d a).
local function r19_order(case, runtime, mechanism)
    local native = runtime == "r16"
    local addon = ADDON_MODULE()
    local target = addon.targets[case.key]
    local settings = {}
    if not native then settings[case.id] = { enabled = true, value = case.value, stock = case.stock } end
    target.activate({ settings = settings })
    printed = {}
    local callee = { isDuviriDefense = false, isCircle = false }
    local reader = callee
    engine_write(callee, case, native)                                -- 1. the game's parameter writer
    local early = {}
    for _, name in ipairs(case.globals) do early[name] = callee[name] end
    if mechanism == "reader_env" then
        reader = { isDuviriDefense = false, isCircle = false }
        engine_write(reader, case, native)
    end
    entries(target, case, callee)                                     -- 2. our Lua write at the entry
    local logged = prints_for(case.id)
    if mechanism == "rewrite" then engine_write(callee, case, native) end
    local view = mechanism == "early" and early or reader             -- 3. the read
    local seen, stock = reads(view, case, case.expect), reads(view, case, case.observed)
    target.cleanup()
    return seen, stock, logged
end
local migrated = {}
for _, id in ipairs(R21_MIGRATED) do migrated[id] = true end
for _, case in ipairs(CASES) do
    local tag = migrated[case.id] and "R21 (migrated) " or "R21 "
    for _, mechanism in ipairs({ "rewrite", "reader_env", "early" }) do
        local seen, _, logged = r19_order(case, "r16", mechanism)
        ok(seen and logged == 0, tag .. case.id .. ": R19 order (writer, Lua entry write, read; " .. mechanism
            .. "): with the writer hook the read sees the configured value and the addon writes nothing")
        local old_seen, old_stock, old_logged = r19_order(case, "old", mechanism)
        ok(not old_seen and old_stock and old_logged == #case.globals, tag .. case.id .. ": R19 order (" .. mechanism
            .. "): the R10 entry write alone is logged and the read still sees the level value (the live R19 signature, control)")
    end
end
-- R17/R19: the Railjack master drives the Corpus, Pontis and (R19) Grineer rows at the engine writer only. With the hook
-- installed the bootstrapper withholds the rows and delivers the master; the addon must write NOTHING for any of them (else
-- the native master value and the addon write would compound).
do
    local master = { ["railjack.kill_goals_scale"] = { enabled = true, value = 0.1, stock = 1 } }
    local addon = ADDON_MODULE()
    for _, item in ipairs(MASTER_TARGETS) do
        local target = addon.targets[item.key]
        target.activate({ settings = master })
        printed = {}
        local env = {}
        for name, level in pairs(item.observed) do env[name] = level end
        for _, prototype in ipairs(item.prototypes) do
            local hook = target.hooks.luaCalls[prototype]
            if hook ~= nil then hook.before(prototype, {}, {}, nil, env) end
        end
        local untouched = true
        for name, level in pairs(item.observed) do untouched = untouched and env[name] == level end
        ok(untouched and prints_for(item.id) == 0,
            "R19: the master alone writes nothing from the addon into " .. item.id .. " (owned at the writer, no double application)")
        target.cleanup()
    end
end
-- R19: the writer's plan (renovice/engine_params_core.hpp resolve_entries) and its output for the live lists.
-- A row's own delivered value wins; else master x scale when the master is not at its stock; else the level value stays.
local function resolve(row, master, scale)
    if row ~= nil then return row end
    if master ~= nil and master.value ~= master.stock then return master.value * scale end
    return nil
end
local function written(list, v)
    local out = {}
    for i, n in ipairs(list) do out[i] = v == nil and n or override("scale_count", n, v) end
    return out
end
local SP_MINOR, SP_MINOR_MAX, SP_MAJOR = { 20, 35, 55, 70, 85, 95 }, { 35, 55, 85, 90, 95, 105 }, { 2, 4, 6, 7, 8, 9 }
local m01, m1 = { value = 0.1, stock = 1 }, { value = 1, stock = 1 }
local v = resolve(0.1, m01, 1)
ok(same(written(SP_MINOR, v), { 2, 4, 6, 7, 9, 10 }) and same(written(SP_MINOR_MAX, v), { 4, 6, 9, 9, 10, 11 })
    and override("scale_count", 50, v) == 5 and override("scale_count", 60, v) == 6,
    "R19 master 0.1 + fighters 0.1: the writer stores {2/4/6/7/9/10}, {4/6/9/9/10/11}, 5, 6 (the live entry-write numbers)")
ok(same(written(SP_MAJOR, resolve(0.1, m01, 1)), { 1, 1, 1, 1, 1, 1 }) and override("scale_count", 3, resolve(0.1, m01, 1)) == 1,
    "R19 master 0.1 + crewships 0.1: the writer stores {1/1/1/1/1/1} and 1 (at least one)")
ok(same(written(SP_MAJOR, resolve(nil, m01, 1)), { 1, 1, 1, 1, 1, 1 }) and same(written(SP_MINOR, resolve(nil, m01, 1)), { 2, 4, 6, 7, 9, 10 }),
    "R19 master 0.1 alone (rows off): the master drives both Grineer rows at the writer")
ok(resolve(nil, m1, 1) == nil and same(written(SP_MAJOR, resolve(nil, m1, 1)), SP_MAJOR),
    "R19 master on at its stock x1, rows off (the R17 live run 1 settings): no override, the level lists stay (stock goal)")
ok(same(written(SP_MAJOR, resolve(1, m01, 1)), SP_MAJOR) and same(written(SP_MAJOR, resolve(0.5, m01, 1)), { 1, 2, 3, 4, 4, 5 }),
    "R19 a row that is on wins over the master (x1 keeps the level list, x0.5 halves it)")
emit(failures == 0 and "ENGINE PARAM OVERRIDE HARNESS PASS" or "ENGINE PARAM OVERRIDE HARNESS FAIL")
'''
script = WORK / 'engine_param_override_harness.luau'
master_targets = [{'id': d['tunable_id'], 'key': rows[d['tunable_id']]['owner']['body_key'],
                   'prototypes': [e['prototype'] for e in rows[d['tunable_id']]['owner']['entries']],
                   'observed': CASES[d['tunable_id']]['observed']} for d in master_row['drives']]
extra = ('MASTER_TARGETS = ' + lua(master_targets) + '\n' + 'MINIMUM_CASES = ' + lua(minimum_cases) + '\n'
         + 'R21_MIGRATED = ' + lua(R21_MIGRATED) + '\n')
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
      f'harness: {sum(l.startswith("PASS") for l in lines)} Luau checks over the six R16 rows, the R17 Gas City row, the R18 Pontis rows, '
      'the R19 Grineer Railjack rows, the R21 Spy and Sabotage rows and the Railjack master (writer-owned, live numbers, R19 failure order)')
check(sum(l.startswith('PASS') and 'R19 order' in l for l in lines) == 6 * len(CASES)
      and all(sum(l.startswith('PASS') and f'R21 (migrated) {tid}:' in l for l in lines) == 6 for tid in R21_MIGRATED),
      f'R21: the R19 failure order replayed for all {len(CASES)} writer-owned rows (3 mechanisms x hook/no hook), 6 checks per migrated row')
OUT.mkdir(parents=True, exist_ok=True)
(OUT / 'engine_param_override_harness.json').write_text(json.dumps(results, indent=2) + '\n', encoding='utf-8')
print('ENGINE PARAM OVERRIDE HARNESS GATE PASS')
