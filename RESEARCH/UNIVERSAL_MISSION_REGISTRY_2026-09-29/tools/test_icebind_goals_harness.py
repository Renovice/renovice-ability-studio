"""Icebind goal harness (contract R23, 2026-10-09, client 44.1.1 2026.10.08.13.05).

Runs the REAL generated Missions addon source (a build of the R23 registry with the three Icebind masters on) in plain
Luau, as the R13 runtime calls it at a native entry: activate(context) -> hooks.luaCalls[P].before(...) -> cleanup().
The MissionInfo is a table copied by GetMission and replaced by SetMission (the game's own setter), with `location` a
Symbol and `missionType` / `maxWaveNum` as BuildMissionInfo sets them for an Icebind key.

Asserts, per mission type (Disruption 33/8, Excavation 17/6, Survival 2/10):
  * the master value reaches both rows: the mode script entry and the Icebind script entry (KuvaPath P73) each write it,
    in either start order, and the second entry finds the value already there (no second write, one line printed);
  * a mission of another Icebind type, a normal node (location not KuvaPathMission, maxWaveNum 0), a field that does not
    hold the Icebind stock (fail closed, one line), a client (not host) and a switched-off master write nothing.
The normal-node rows keep their R10 helper (missionInfo_maxWaveNum, unchanged text); this harness does not re-test them.
Limit: the entry dispatch itself is proven by the bootstrapper (R13 native entry); the in-game effect is a live check.
Writes only to work/temp/icebind-goals-harness and this tool's test-results folder. Reads no game or server folder.
"""
from pathlib import Path
import json, os, shutil, subprocess, sys

EDITOR = Path(__file__).resolve().parents[3]
ROOT = EDITOR
while not (ROOT / 'WORKSPACE.json').exists():
    ROOT = ROOT.parent
CLI = Path(os.environ.get('RENOVICE_EDITOR_CLI', ROOT / 'work/builds/ability-editor/current/bin/renovice_ability_editor_cli.exe'))
LUAU = ROOT / 'repos/toolchains/de-luau-toolchain/bin/luau.exe'
WORK = ROOT / 'work/temp/icebind-goals-harness'
OUT = Path(__file__).resolve().parents[1] / 'test-results'
results = {'checks': []}
TYPES = [  # family, master, mode-script row, its module key and entry prototypes, mission type, Icebind stock
    ('disruption', 'disruption.icebind_goal', 'disruption.icebind_conduits', 33, 8),
    ('excavation', 'excavation.icebind_goal', 'excavation.icebind_excavators', 17, 6),
    ('survival', 'survival.icebind_goal', 'survival.icebind_minutes', 2, 10),
]
KUVAPATH = '248d54e0074e52c2'


def check(ok, name):
    results['checks'].append({'name': name, 'pass': bool(ok)})
    print(('PASS' if ok else 'FAIL') + '\t' + name)
    if not ok:
        OUT.mkdir(parents=True, exist_ok=True)
        (OUT / 'icebind_goals_harness.json').write_text(json.dumps(results, indent=2) + '\n', encoding='utf-8')
        sys.exit(1)


registry = json.loads((EDITOR / 'REGISTRIES/mission_build_u44.json').read_text(encoding='utf-8'))
check(registry['build'] == '2026.10.08.13.05', 'registry is the 44.1.1 build')
rows = {r['tunable_id']: r for r in registry['tunables']}
cases = []
for family, master, mode_row, mtype, stock in TYPES:
    icebind_row = mode_row + '_kuvapath'
    for tid in (mode_row, icebind_row):
        o = rows[tid]['owner']
        check(o.get('variant') == 'KUVA_PATH_MISSION' and o['mission_type'] == mtype and o['variant_stock'] == stock
              and rows[tid]['stock'] == stock and o['field'] == 'maxWaveNum', f'{tid}: Icebind variant, type {mtype}, stock {stock}')
    check(rows[icebind_row]['owner']['body_key'] == KUVAPATH and [e['prototype'] for e in rows[icebind_row]['owner']['entries']] == [73],
          f'{icebind_row}: written at the KuvaPath entry (P73)')
    m = registry['ui_masters'][master]
    check([d['tunable_id'] for d in m['drives']] == [mode_row, icebind_row] and all(d['scale'] == 1 for d in m['drives'])
          and m['stock'] == stock, f'{master}: drives the row pair at scale 1, stock {stock}')
    o = rows[mode_row]['owner']
    cases.append({'family': family, 'master': master, 'mode_key': o['body_key'],
                  'mode_entries': [e['prototype'] for e in o['entries']], 'mtype': mtype, 'stock': stock,
                  'value': {33: 4, 17: 3, 2: 5}[mtype]})

# Build input: the pinned settings of the installed package plus the three Icebind masters on.
data = json.loads((EDITOR / 'RESEARCH/MISSIONS_R13_NATIVE_ENTRY_2026-10-01/inputs/rebuild_input.r12.json').read_text(encoding='utf-8'))
data['build'] = registry['build']
data['values'] = {k: v for k, v in data.get('values', {}).items() if k in rows or k in registry['ui_masters']}
for c in cases:
    data['values'][c['master']] = c['value']
if 'disabled_values' in data:
    data['disabled_values'] = [k for k in data['disabled_values'] if k in data['values']]
shutil.rmtree(WORK, ignore_errors=True)
WORK.mkdir(parents=True)
(WORK / 'input.json').write_text(json.dumps(data, indent=1), encoding='utf-8')
run = subprocess.run([str(CLI), 'build-missions', str(WORK / 'input.json'), '--staging', str(WORK / 'build'), '--editor-root', str(EDITOR)],
                     capture_output=True, text=True)
generations = list((WORK / 'build').glob('missions/*/MISSION_SET_MANIFEST.json'))
check(run.returncode == 0 and len(generations) == 1, 'R23 build with the three Icebind masters on succeeds')
generation = generations[0].parent
source = (generation / 'source/Missions.targets.addon.luau').read_text(encoding='utf-8')
check(source.count('local function missionInfoKuvaPath_maxWaveNum(') == 1, 'one Icebind MissionInfo helper in the addon')

harness = r'''
local emit = print
local printed = {}
print = function(...)
    local parts = {}
    for i = 1, select("#", ...) do parts[#parts + 1] = tostring(select(i, ...)) end
    printed[#printed + 1] = table.concat(parts, " ")
end
local symbols = {}
Symbol = function(name) local s = symbols[name] if s == nil then s = { symbol = name } symbols[name] = s end return s end
local mission, master = nil, true
local function set_mission(location, mtype, wave)
    mission = { location = Symbol(location), missionType = mtype, maxWaveNum = wave, alertId = "", invasionId = "",
        goalId = "", sortieId = "", nightmare = false, syndicateTag = { IsValid = function() return false end } }
end
gRegion = { IsMaster = function() return master end }
local writes = 0
gGameRules = {
    GetMission = function() local copy = {} for k, v in pairs(mission) do copy[k] = v end return copy end,
    SetMission = function(self, m) writes = writes + 1 mission = m end,
}
local failures = 0
local function ok(condition, name)
    if condition then emit("PASS\t" .. name) else failures = failures + 1 emit("FAIL\t" .. name) end
end
local function settings_for(case, enabled)
    return { settings = { [case.master] = { enabled = enabled, value = case.value, stock = case.stock } } }
end
local function enter(target, prototypes)
    for _, p in ipairs(prototypes) do
        local hook = target.hooks.luaCalls[p]
        if hook ~= nil then hook.before(p, {}, {}, nil, {}) end
    end
end
local function run(case, order, enabled)
    local addon = ADDON_MODULE()
    local mode, kuva = addon.targets[case.mode_key], addon.targets[KUVAPATH]
    mode.activate(settings_for(case, enabled))
    if kuva ~= mode then kuva.activate(settings_for(case, enabled)) end
    writes, printed = 0, {}
    if order == "mode-first" then enter(mode, case.mode_entries) enter(kuva, { 73 })
    else enter(kuva, { 73 }) enter(mode, case.mode_entries) end
    mode.cleanup()
    if kuva ~= mode then kuva.cleanup() end
end

for _, case in ipairs(CASES) do
    local t = case.family
    ok(ADDON_MODULE().targets[case.mode_key] ~= nil and ADDON_MODULE().targets[KUVAPATH] ~= nil, t .. ": mode and KuvaPath targets exist")
    for _, order in ipairs({ "mode-first", "kuvapath-first" }) do
        master = true
        set_mission("KuvaPathMission", case.mtype, case.stock)
        run(case, order, true)
        ok(mission.maxWaveNum == case.value and writes == 1, t .. " (" .. order .. "): the master value is written once ("
            .. case.stock .. " -> " .. case.value .. "), the second script finds it already there")
    end
    for _, other in ipairs(CASES) do
        if other.mtype ~= case.mtype then
            set_mission("KuvaPathMission", other.mtype, other.stock)
            run(case, "mode-first", true)
            ok(mission.maxWaveNum == other.stock and writes == 0, t .. ": an Icebind " .. other.family .. " mission is left alone")
        end
    end
    set_mission("SolNode", case.mtype, 0)
    run(case, "mode-first", true)
    ok(mission.maxWaveNum == 0 and writes == 0, t .. ": a normal node (not KuvaPathMission) is left alone")
    set_mission("KuvaPathMission", case.mtype, case.stock + 1)
    run(case, "mode-first", true)
    local said = false
    for _, line in ipairs(printed) do if string.find(line, "not the Icebind stock", 1, true) then said = true end end
    ok(mission.maxWaveNum == case.stock + 1 and writes == 0 and said, t .. ": a field without the Icebind stock is left alone (one line)")
    master = false
    set_mission("KuvaPathMission", case.mtype, case.stock)
    run(case, "mode-first", true)
    ok(mission.maxWaveNum == case.stock and writes == 0, t .. ": a client (not host) writes nothing")
    master = true
    set_mission("KuvaPathMission", case.mtype, case.stock)
    run(case, "mode-first", false)
    ok(mission.maxWaveNum == case.stock and writes == 0, t .. ": the master switched off writes nothing")
end
emit(failures == 0 and "ICEBIND GOALS HARNESS PASS" or "ICEBIND GOALS HARNESS FAIL")
'''


def lua(value):
    if isinstance(value, bool):
        return 'true' if value else 'false'
    if isinstance(value, (int, float)):
        return str(value)
    if isinstance(value, str):
        return json.dumps(value)
    if isinstance(value, list):
        return '{' + ', '.join(lua(v) for v in value) + '}'
    if isinstance(value, dict):
        return '{' + ', '.join(f'[{json.dumps(k)}] = {lua(v)}' for k, v in value.items()) + '}'
    raise TypeError(value)


script = WORK / 'icebind_goals_harness.luau'
script.write_text('ADDON_MODULE = function(...)\n' + source + '\nend\n' + f'KUVAPATH = {json.dumps(KUVAPATH)}\n'
                  + 'CASES = ' + lua(cases) + '\n' + harness, encoding='utf-8')
check(LUAU.is_file(), 'toolchain luau.exe present')
run = subprocess.run([str(LUAU), str(script)], capture_output=True, text=True)
lines = run.stdout.splitlines()
for line in lines:
    print('HARNESS\t' + line)
if run.stderr.strip():
    print('HARNESS-STDERR\t' + run.stderr.strip())
check(run.returncode == 0 and 'ICEBIND GOALS HARNESS PASS' in lines and not any(l.startswith('FAIL') for l in lines),
      f'harness: {sum(l.startswith("PASS") for l in lines)} checks over the three Icebind mission types')
OUT.mkdir(parents=True, exist_ok=True)
(OUT / 'icebind_goals_harness.json').write_text(json.dumps(results, indent=2) + '\n', encoding='utf-8')
print('ICEBIND GOALS HARNESS GATE PASS')
