"""Events batch 2 goal harness (GOAL_TAG rows incl. "from 0": Hallowed Flame, Purify, Orphix Venom, Nightwatch Bonus, 2026-10-29).
Stock-0 rows: the endless mission (field 0) gets the value; a mission already holding another number is left alone.

Runs the REAL generated Missions addon (a build of the current registry with all batch-2 rows set) in plain Luau, as
the R13 runtime calls it at a native entry (same frame as test_proxy_rebellion_harness.py). Cases come from the batch-2
drafts. Each row, with each of its goal tags: written once on its own mission; left alone on another stock (one line),
another mission type, a client and with the setting off; plus a normal node and another goal tag.
Writes only to work/temp/events-batch2-harness and this tool's test-results folder. Reads no game or server folder.
"""
from pathlib import Path
import json, os, shutil, subprocess, sys

EDITOR = Path(__file__).resolve().parents[3]
ROOT = EDITOR
while not (ROOT / 'WORKSPACE.json').exists():
    ROOT = ROOT.parent
CLI = Path(os.environ.get('RENOVICE_EDITOR_CLI', ROOT / 'work/builds/ability-editor/current/bin/renovice_ability_editor_cli.exe'))
LUAU = ROOT / 'repos/toolchains/de-luau-toolchain/bin/luau.exe'
WORK = ROOT / 'work/temp/events-batch2-harness'
OUT = Path(__file__).resolve().parents[1] / 'test-results'
results = {'checks': []}
DRAFTS = json.loads((EDITOR / 'RESEARCH/MISSIONS_EVENTS_BATCH2_2026-10-29/inputs/event_batch2_row_drafts.json')
                    .read_text(encoding='utf-8'))
CASES = []
EXPECTED_OWNER = {}
for d in DRAFTS['rows']:
    o = d['owner']
    stock = d['stock']
    CASES.append({'name': d['tunable_id'], 'row': d['tunable_id'], 'mtype': o['mission_type'], 'stock': stock,
                  'value': max(1, stock // 2), 'other_stock': stock + 1,
                  'tags': [o['goal_tag']] + o.get('goal_tag_aliases', [])})
    EXPECTED_OWNER[d['tunable_id']] = (o['body_key'], [e['prototype'] for e in o['entries']])


def check(ok, name):
    results['checks'].append({'name': name, 'pass': bool(ok)})
    print(('PASS' if ok else 'FAIL') + '\t' + name)
    if not ok:
        OUT.mkdir(parents=True, exist_ok=True)
        (OUT / 'events_batch2_harness.json').write_text(json.dumps(results, indent=2) + '\n', encoding='utf-8')
        sys.exit(1)


def lua(v):
    if isinstance(v, bool):
        return 'true' if v else 'false'
    if isinstance(v, (int, float)):
        return str(v)
    if isinstance(v, str):
        return json.dumps(v)
    if isinstance(v, list):
        return '{' + ', '.join(lua(x) for x in v) + '}'
    return '{' + ', '.join(f'[{json.dumps(k)}] = {lua(x)}' for k, x in v.items()) + '}'


registry = json.loads((EDITOR / 'REGISTRIES/mission_build_u44.json').read_text(encoding='utf-8'))
rows = {r['tunable_id']: r for r in registry['tunables']}
for c in CASES:
    o = rows[c['row']]['owner']
    check(o.get('variant') == 'GOAL_TAG' and [o.get('goal_tag')] + o.get('goal_tag_aliases', []) == c['tags'] and 'location' not in o
          and o['mission_type'] == c['mtype'] and o['variant_stock'] == c['stock'] and rows[c['row']]['stock'] == c['stock']
          and o['field'] == 'maxWaveNum', f"{c['row']}: GOAL_TAG variant {'/'.join(c['tags'])}, type {c['mtype']}, stock {c['stock']}")
    c['key'], c['entries'] = o['body_key'], [e['prototype'] for e in o['entries']]
    check((c['key'], c['entries']) == EXPECTED_OWNER[c['row']], f"{c['row']}: written at {c['key']} P{c['entries']}")
    ui = rows[c['row']]['ui']
    check(ui.get('path', [])[0] == 'Events' and 'hidden' not in ui and not any(
          d['tunable_id'] == c['row'] for m in registry['ui_masters'].values() for d in m['drives']),
          f"{c['row']}: shown on its Events page itself (no master over it, not hidden)")

# Build input: the pinned settings of the installed package plus both Clem rows set.
data = json.loads((EDITOR / 'RESEARCH/MISSIONS_R13_NATIVE_ENTRY_2026-10-01/inputs/rebuild_input.r12.json').read_text(encoding='utf-8'))
data['build'] = registry['build']
data['values'] = {k: v for k, v in data.get('values', {}).items() if k in rows or k in registry['ui_masters']}
for c in CASES:
    data['values'][c['row']] = c['value']
if 'disabled_values' in data:
    data['disabled_values'] = [k for k in data['disabled_values'] if k in data['values']]
shutil.rmtree(WORK, ignore_errors=True)
WORK.mkdir(parents=True)
(WORK / 'input.json').write_text(json.dumps(data, indent=1), encoding='utf-8')
run = subprocess.run([str(CLI), 'build-missions', str(WORK / 'input.json'), '--staging', str(WORK / 'build'), '--editor-root', str(EDITOR)],
                     capture_output=True, text=True)
generations = list((WORK / 'build').glob('missions/*/MISSION_SET_MANIFEST.json'))
check(run.returncode == 0 and len(generations) == 1, 'build with all batch-2 rows set succeeds')
source = (generations[0].parent / 'source/Missions.targets.addon.luau').read_text(encoding='utf-8')
check(source.count('local function missionInfoGoalTag_maxWaveNum(') == 1, 'one GOAL_TAG MissionInfo helper in the addon')

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
local function set_mission(goalTag, location, mtype, wave)
    mission = { goalTag = Symbol(goalTag), location = Symbol(location), missionType = mtype, maxWaveNum = wave,
        alertId = "", invasionId = "", goalId = "", sortieId = "", nightmare = false,
        syndicateTag = { IsValid = function() return false end } }
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
local function run(case, enabled, times)
    local addon = ADDON_MODULE()
    local target = addon.targets[case.key]
    target.activate({ settings = { [case.row] = { enabled = enabled, value = case.value, stock = case.stock } }, logging = true })
    writes, printed = 0, {}
    for _ = 1, times or 1 do
        for _, p in ipairs(case.entries) do
            local hook = target.hooks.luaCalls[p]
            if hook ~= nil then hook.before(p, {}, {}, nil, {}) end
        end
    end
    target.cleanup()
end

for _, c in ipairs(CASES) do
    local t = c.name .. " row"
    ok(ADDON_MODULE().targets[c.key] ~= nil, t .. ": its mode-script target exists")
    for _, tag in ipairs(c.tags) do
        local u = t .. " [" .. tag .. "]"
        master = true
        set_mission(tag, "EventNode18", c.mtype, c.stock)
        run(c, true, 2)
        ok(mission.maxWaveNum == c.value and writes == 1, u .. ": " .. c.stock .. " -> " .. c.value .. " written once")
        set_mission(tag, "EventNode18", c.mtype, c.other_stock)
        run(c, true)
        ok(mission.maxWaveNum == c.other_stock and writes == 0, u .. ": another stock (" .. c.other_stock .. ") is left alone")
        set_mission(tag, "EventNode18", c.mtype + 100, c.stock)
        run(c, true)
        ok(mission.maxWaveNum == c.stock and writes == 0, u .. ": another mission type is left alone")
        master = false
        set_mission(tag, "EventNode18", c.mtype, c.stock)
        run(c, true)
        ok(mission.maxWaveNum == c.stock and writes == 0, u .. ": a client (not host) writes nothing")
        master = true
        set_mission(tag, "EventNode18", c.mtype, c.stock)
        run(c, false)
        ok(mission.maxWaveNum == c.stock and writes == 0, u .. ": the setting switched off writes nothing")
    end
    set_mission("", "SolNode82", c.mtype, c.stock)
    run(c, true)
    ok(mission.maxWaveNum == c.stock and writes == 0, t .. ": a normal node (no goal tag) is left alone")
    set_mission("GetClem", "SolNode82", c.mtype, c.stock)
    run(c, true)
    ok(mission.maxWaveNum == c.stock and writes == 0, t .. ": another goal tag (GetClem) is left alone")
end
emit(failures == 0 and "EVENTS BATCH2 HARNESS PASS" or "EVENTS BATCH2 HARNESS FAIL")
'''

script = WORK / 'events_batch2_harness.luau'
script.write_text('ADDON_MODULE = function(...)\n' + source + '\nend\n' + 'CASES = ' + lua(CASES) + '\n' + harness,
                  encoding='utf-8')
check(LUAU.is_file(), 'toolchain luau.exe present')
run = subprocess.run([str(LUAU), str(script)], capture_output=True, text=True)
lines = run.stdout.splitlines()
for line in lines:
    print('HARNESS\t' + line)
if run.stderr.strip():
    print('HARNESS-STDERR\t' + run.stderr.strip())
check(run.returncode == 0 and 'EVENTS BATCH2 HARNESS PASS' in lines and not any(l.startswith('FAIL') for l in lines),
      f'harness: {sum(l.startswith("PASS") for l in lines)} checks over the batch-2 rows and their tags')
OUT.mkdir(parents=True, exist_ok=True)
(OUT / 'events_batch2_harness.json').write_text(json.dumps(results, indent=2) + '\n', encoding='utf-8')
print('EVENTS BATCH2 HARNESS GATE PASS')
