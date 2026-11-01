"""AI director field rows harness (2026-10-31): OBJECT_FIELD_AT_ENTRY, locator ai_director, via _T.RENOVICE.object.

Runs the REAL generated Missions addon (a build of the current registry with the nine director-field rows, the hard cap
and the spawn-area rows declared) in plain Luau, calling the hooks the way the runtime does (luaCalls[P].before), with
mocked gRegion / NpcMgr / AI director and a mocked _T.RENOVICE.object whose get/set record every call and store numbers
as 32-bit floats (string.pack "f"), as the DE VM does.

Checks: host writes once at stock over repeated entries (float tolerance: stored 0.1f equals stock 0.1); one log line
"<id> <field> <old> -> <new>"; cleanup restores the stock once; non-stock left alone with one line; client / no director
/ null director / API missing / disabled row write nothing (API missing: one line); enabled at stock writes nothing;
cleanup leaves a value another writer changed; a refused set logs its reason; int field; all nine rows together; the hard
cap still works alongside. Writes only to work/temp/director-fields-harness and this tool's test-results folder.
"""
from pathlib import Path
import json, os, shutil, subprocess, sys

EDITOR = Path(__file__).resolve().parents[3]
ROOT = EDITOR
while not (ROOT / 'WORKSPACE.json').exists():
    ROOT = ROOT.parent
CLI = Path(os.environ.get('RENOVICE_EDITOR_CLI', ROOT / 'work/builds/ability-editor/current/bin/renovice_ability_editor_cli.exe'))
LUAU = ROOT / 'repos/toolchains/de-luau-toolchain/bin/luau.exe'
WORK = ROOT / 'work/temp/director-fields-harness'
OUT = Path(__file__).resolve().parents[1] / 'test-results'
results = {'checks': []}
FIELDS = {  # id -> (field, type, stock, min, max, path leaf)
    'enemies.spawn_timer': ('SpawnTimer', 'float', 0.1, 0.01, 10, 'Spawn pacing'),
    'enemies.event_timer': ('EventTimer', 'float', 4, 0.1, 60, 'Spawn pacing'),
    'enemies.event_count_max': ('EventCountMax', 'int', 6, 1, 100, 'Spawn pacing'),
    'enemies.max_encounter_xp': ('MaxEncounterXp', 'float', 1000, 1, 100000, 'Spawn pacing'),
    'enemies.intensity_max': ('IntensityMax', 'float', 100, 1, 10000, 'Breather (intensity)'),
    'enemies.intensity_peak_pct': ('IntensityPeakPercentage', 'float', 0.95, 0.05, 1, 'Breather (intensity)'),
    'enemies.intensity_hold_spawns_pct': ('IntensityHoldSpawnsPercentage', 'float', 1, 0, 1, 'Breather (intensity)'),
    'enemies.after_peak_time': ('AfterPeakTime', 'float', 20, 0, 600, 'Breather (intensity)'),
    'enemies.after_hold_time': ('AfterHoldTime', 'float', 20, 0, 600, 'Breather (intensity)'),
}
CAP, AHEAD, BEHIND = 'enemies.hard_cap', 'enemies.active_area_ahead', 'enemies.active_area_behind'


def check(ok, name):
    results['checks'].append({'name': name, 'pass': bool(ok)})
    print(('PASS' if ok else 'FAIL') + '\t' + name)
    if not ok:
        OUT.mkdir(parents=True, exist_ok=True)
        (OUT / 'director_fields_harness.json').write_text(json.dumps(results, indent=2) + '\n', encoding='utf-8')
        sys.exit(1)


registry = json.loads((EDITOR / 'REGISTRIES/mission_build_u44.json').read_text(encoding='utf-8'))
rows = {r['tunable_id']: r for r in registry['tunables']}

# ---- registry shape
for tid, (field, kind, stock, lo, hi, leaf) in FIELDS.items():
    r = rows[tid]
    o = r['owner']
    check(r['backend'] == 'TARGET_ADDON' and o['template'] == 'OBJECT_FIELD_AT_ENTRY' and o['locator'] == 'ai_director'
          and o['field'] == field and o['value_type'] == kind and o['host_only'] and r['stock'] == stock
          and r['limits']['minimum'] == lo and r['limits']['maximum'] == hi and r['limits']['integer'] == (kind == 'int')
          and [e['prototype'] for e in o['entries']] == [65, 2] and all(x['key'] == 'GetAiDirector' for x in o['readers'])
          and o['module_path'] == 'Lotus.Scripts.ProceduralLevel' and o['body_key'] == rows[CAP]['owner']['body_key'],
          f'{tid}: OBJECT_FIELD_AT_ENTRY ai_director {field} {kind}, stock {stock}, {lo}..{hi}, ProceduralLevel P65/P2')
    check(r['ui'].get('path') == ['Enemies', 'All missions', leaf], f'{tid}: Enemies > All missions > {leaf}')

# ---- build
data = json.loads((EDITOR / 'RESEARCH/MISSIONS_R13_NATIVE_ENTRY_2026-10-01/inputs/rebuild_input.r12.json').read_text(encoding='utf-8'))
data['build'] = registry['build']
data['values'] = {k: v for k, v in data.get('values', {}).items() if k in rows or k in registry['ui_masters']}
data['values'].update({tid: spec[2] for tid, spec in FIELDS.items()})
data['values'].update({CAP: 40, AHEAD: 75, BEHIND: 75})
if 'disabled_values' in data:
    data['disabled_values'] = [k for k in data['disabled_values'] if k in data['values']]
shutil.rmtree(WORK, ignore_errors=True)
WORK.mkdir(parents=True)
(WORK / 'input.json').write_text(json.dumps(data, indent=1), encoding='utf-8')
run = subprocess.run([str(CLI), 'build-missions', str(WORK / 'input.json'), '--staging', str(WORK / 'build'), '--editor-root', str(EDITOR)],
                     capture_output=True, text=True)
generations = list((WORK / 'build').glob('missions/*/MISSION_SET_MANIFEST.json'))
if run.returncode != 0:
    print(run.stdout[-3000:], run.stderr[-3000:])
check(run.returncode == 0 and len(generations) == 1, 'build with the director field rows succeeds')
gen = generations[0].parent
source = (gen / 'source/Missions.targets.addon.luau').read_text(encoding='utf-8')
check(source.count('local function objectField(') == 1 and source.count('local function objectLocator_ai_director(') == 1,
      'one objectField helper and one ai_director locator in the addon')
check(source.count('objectField(') == 1 + len(FIELDS), f'{len(FIELDS)} objectField rows')
check('renovice.object' in source and 'api.get(object, field)' in source and 'api.set(object, field, value)' in source,
      'the addon reads and writes through _T.RENOVICE.object get/set')
for tid, spec in FIELDS.items():
    check(f'objectField("{tid}", objectLocator_ai_director, "{spec[0]}", ' in source, f'{tid}: objectField row for {spec[0]}')

CASE = {'key': rows[CAP]['owner']['body_key']}
harness = r'''
local emit = print
local printed = {}
print = function(...)
    local parts = {}
    for i = 1, select("#", ...) do parts[#parts + 1] = tostring(select(i, ...)) end
    printed[#printed + 1] = table.concat(parts, " ")
end
local failures = 0
local function ok(condition, name)
    if condition then emit("PASS\t" .. name) else failures = failures + 1 emit("FAIL\t" .. name) end
end
local function f32(v) return (string.unpack("f", string.pack("f", v))) end
local nulls = {}
IsNull = function(object) return object == nil or nulls[object] == true end
local master, findable, hasDirector = true, true, true
local cap = 40
local director = {
    GetNpcHardCap = function(self) return cap end,
    SetNpcHardCap = function(self, n) cap = n end,
    Name__b37ce12d = function() end,
}
local STOCK = { SpawnTimer = 0.1, EventTimer = 4, EventCountMax = 6, MaxEncounterXp = 1000, IntensityMax = 100,
    IntensityPeakPercentage = 0.95, IntensityHoldSpawnsPercentage = 1, AfterPeakTime = 20, AfterHoldTime = 20 }
local values = {}
local function reset() for k, v in pairs(STOCK) do values[k] = f32(v) end end
reset()
local gets, sets, refuse = {}, {}, nil
local api = {
    get = function(obj, name)
        gets[#gets + 1] = name
        if obj ~= director then return nil, "not-object" end
        if values[name] == nil then return nil, "unknown-field" end
        return values[name]
    end,
    set = function(obj, name, value)
        sets[#sets + 1] = { name = name, value = value }
        if refuse then return nil, refuse end
        values[name] = f32(value)
        return { name }
    end,
}
-- 2026-10-31: the runtime hands the API to target addons as context.renovice (their module _T is that script's own
-- table); _T.RENOVICE is only the fallback.
CONTEXT_API = { version = 1, object = api }
_T = {}
local npcs = {
    CanFind = function(self) return findable end,
    GetAiDirector = function(self) if hasDirector then return director end return nil end,
}
gRegion = { IsMaster = function() return master end, GetNpcMgr = function() return npcs end }

local IDS = { SpawnTimer = "enemies.spawn_timer", EventTimer = "enemies.event_timer", EventCountMax = "enemies.event_count_max",
    MaxEncounterXp = "enemies.max_encounter_xp", IntensityMax = "enemies.intensity_max",
    IntensityPeakPercentage = "enemies.intensity_peak_pct", IntensityHoldSpawnsPercentage = "enemies.intensity_hold_spawns_pct",
    AfterPeakTime = "enemies.after_peak_time", AfterHoldTime = "enemies.after_hold_time" }
local function settings(on, capOn)
    local s = {
        ["enemies.hard_cap"] = { enabled = capOn == true, value = 80, stock = 40 },
        ["enemies.active_area_ahead"] = { enabled = false, value = 75, stock = 75 },
        ["enemies.active_area_behind"] = { enabled = false, value = 75, stock = 75 },
    }
    for field, id in pairs(IDS) do
        local v = on[field]
        s[id] = { enabled = v ~= nil, value = v or STOCK[field], stock = STOCK[field] }
    end
    return s
end
local function enterAll(target, times)
    for _ = 1, times or 1 do
        for _, p in ipairs({ 65, 2 }) do
            local hook = target.hooks.luaCalls[p]
            if hook ~= nil then hook.before(p, {}, {}) end
        end
    end
end
local function start(on, capOn)
    local target = ADDON_MODULE().targets[CASE.key]
    target.activate({ settings = settings(on, capOn), logging = true, renovice = CONTEXT_API })
    gets, sets, printed = {}, {}, {}
    return target
end
local function count(text)
    local n = 0
    for _, line in ipairs(printed) do if line:find(text, 1, true) then n = n + 1 end end
    return n
end

-- host, SpawnTimer 0.05: one set over 3 x (P65, P2), float32 stock 0.1 matches the registered 0.1
local t = start({ SpawnTimer = 0.05 })
enterAll(t, 3)
ok(#sets == 1 and sets[1].name == "SpawnTimer" and sets[1].value == 0.05, "host: one set SpawnTimer 0.05 over 3 x (P65, P2)")
ok(values.SpawnTimer == f32(0.05), "director SpawnTimer now 0.05 (float32)")
ok(#printed == 1 and count("RENOVICE Missions: enemies.spawn_timer SpawnTimer ") == 1 and count("-> 0.05") == 1,
   "one log line: RENOVICE Missions: enemies.spawn_timer SpawnTimer <stock> -> 0.05")
sets = {}
t.cleanup()
ok(#sets == 1 and sets[1].name == "SpawnTimer" and sets[1].value == 0.1 and values.SpawnTimer == f32(0.1),
   "cleanup sets the stock 0.1 back once")
sets = {}
t.cleanup()
ok(#sets == 0, "a second cleanup sets nothing")

-- int field
t = start({ EventCountMax = 12 })
enterAll(t, 2)
ok(#sets == 1 and sets[1].name == "EventCountMax" and values.EventCountMax == 12, "int field EventCountMax 6 -> 12 once")
t.cleanup()
ok(values.EventCountMax == 6, "cleanup restores EventCountMax 6")

-- non-stock value is left alone with one line
reset()
values.SpawnTimer = f32(0.5)
t = start({ SpawnTimer = 0.05 })
enterAll(t, 3)
ok(#sets == 0 and values.SpawnTimer == f32(0.5), "SpawnTimer 0.5 (not stock): left unchanged")
ok(#printed == 1 and count("enemies.spawn_timer SpawnTimer is ") == 1 and count("left unchanged") == 1,
   "one left-unchanged line over 3 x (P65, P2)")
t.cleanup()
ok(#sets == 0, "cleanup without a write sets nothing")
reset()

-- already holds the value / enabled at stock
values.EventTimer = f32(8)
t = start({ EventTimer = 8 })
enterAll(t)
ok(#sets == 0 and #printed == 0, "field already holds the value: nothing written, no line")
t.cleanup()
reset()
t = start({ EventTimer = 4 })
enterAll(t)
ok(#sets == 0, "row enabled at the stock value: nothing written")
t.cleanup()

-- disabled rows
t = start({})
enterAll(t)
ok(#sets == 0 and #gets == 0, "all rows off: no get, no set")
t.cleanup()

-- client
master = false
t = start({ SpawnTimer = 0.05, EventTimer = 2 })
enterAll(t)
t.cleanup()
ok(#sets == 0 and #gets == 0, "client (not host): no get, no set, cleanup nothing")
master = true

-- no director / null director / NpcMgr not findable then findable
hasDirector = false
t = start({ SpawnTimer = 0.05 })
enterAll(t)
ok(#sets == 0 and #gets == 0 and count("no AI director at this entry") >= 1, "no AI director: nothing written, line")
t.cleanup()
hasDirector = true
nulls[director] = true
t = start({ SpawnTimer = 0.05 })
enterAll(t)
ok(#sets == 0, "a null (destroyed) director: nothing written")
t.cleanup()
nulls[director] = nil
t = start({ SpawnTimer = 0.05 })
findable = false
t.hooks.luaCalls[65].before(65, {}, {})
ok(#sets == 0, "NpcMgr not findable at P65: nothing written there")
findable = true
t.hooks.luaCalls[2].before(2, {}, {})
ok(#sets == 1, "director available at P2: written there")
t.cleanup()
reset()

-- API missing: one line, nothing written, other rows (hard cap) still work
local saved = CONTEXT_API
CONTEXT_API = nil
cap = 40
t = start({ SpawnTimer = 0.05, EventTimer = 2 }, true)
enterAll(t, 2)
ok(#sets == 0 and count("enemies.spawn_timer RENOVICE.object unavailable; nothing written") == 1
   and count("enemies.event_timer RENOVICE.object unavailable; nothing written") == 1,
   "RENOVICE.object missing: one line per row, nothing written")
ok(cap == 80, "hard cap still written when RENOVICE.object is missing")
t.cleanup()
ok(cap == 40, "hard cap restored")
CONTEXT_API = { version = 1 }
t = start({ SpawnTimer = 0.05 })
enterAll(t)
ok(#sets == 0 and count("RENOVICE.object unavailable") == 1, "RENOVICE without object: unavailable line, nothing written")
t.cleanup()
_T = nil
t = start({ SpawnTimer = 0.05 })
enterAll(t)
ok(#sets == 0 and count("RENOVICE.object unavailable") == 1, "_T missing: unavailable line, nothing written")
t.cleanup()
-- fallback: no context.renovice, API published on the module _T
CONTEXT_API = nil
_T = { RENOVICE = saved }
t = start({ SpawnTimer = 0.05 })
enterAll(t)
ok(#sets == 1, "_T.RENOVICE fallback still works without context.renovice")
t.cleanup()
reset()
CONTEXT_API = saved
_T = {}

-- set refused
refuse = "wrong-type"
t = start({ SpawnTimer = 0.05 })
enterAll(t, 2)
ok(#sets == 1 and count("SpawnTimer not written: wrong-type") == 1 and values.SpawnTimer == f32(0.1),
   "refused set: one line with the reason, value unchanged (no retry spam)")
refuse = nil
sets = {}
t.cleanup()
ok(#sets == 0, "cleanup after a refused set sets nothing")

-- another writer changed the value after our write: cleanup leaves it
t = start({ AfterPeakTime = 5 })
enterAll(t)
values.AfterPeakTime = f32(33)
sets = {}
t.cleanup()
ok(#sets == 0 and values.AfterPeakTime == f32(33), "cleanup leaves a value another writer changed")
reset()

-- float tolerance: fractional stock 0.95 stored as float32
t = start({ IntensityPeakPercentage = 0.8 })
enterAll(t)
ok(#sets == 1 and values.IntensityPeakPercentage == f32(0.8), "IntensityPeakPercentage f32(0.95) == stock 0.95 -> 0.8")
t.cleanup()
ok(values.IntensityPeakPercentage == f32(0.95), "cleanup restores 0.95")

-- all nine rows together, plus the hard cap
local all = { SpawnTimer = 0.05, EventTimer = 2, EventCountMax = 10, MaxEncounterXp = 2000, IntensityMax = 200,
    IntensityPeakPercentage = 0.5, IntensityHoldSpawnsPercentage = 0.75, AfterPeakTime = 5, AfterHoldTime = 6 }
cap = 40
t = start(all, true)
enterAll(t, 2)
local okAll = #sets == 9
for field, v in pairs(all) do if values[field] ~= f32(v) then okAll = false end end
ok(okAll and cap == 80, "all nine fields written once each, hard cap alongside")
t.cleanup()
local back = true
for field, v in pairs(STOCK) do if values[field] ~= f32(v) then back = false end end
ok(back and cap == 40, "cleanup restores every field and the hard cap")
emit(failures == 0 and "DIRECTOR FIELDS HARNESS PASS" or "DIRECTOR FIELDS HARNESS FAIL")
'''

script = WORK / 'director_fields_harness.luau'
script.write_text('ADDON_MODULE = function(...)\n' + source + '\nend\n' + 'CASE = { key = ' + json.dumps(CASE['key']) + ' }\n' + harness,
                  encoding='utf-8')
check(LUAU.is_file(), 'toolchain luau.exe present')
run = subprocess.run([str(LUAU), str(script)], capture_output=True, text=True)
lines = run.stdout.splitlines()
for line in lines:
    print('HARNESS\t' + line)
if run.stderr.strip():
    print('HARNESS-STDERR\t' + run.stderr.strip())
check(run.returncode == 0 and 'DIRECTOR FIELDS HARNESS PASS' in lines and not any(l.startswith('FAIL') for l in lines),
      f'harness: {sum(l.startswith("PASS") for l in lines)} checks over the director field rows')
OUT.mkdir(parents=True, exist_ok=True)
(OUT / 'director_fields_harness.json').write_text(json.dumps(results, indent=2) + '\n', encoding='utf-8')
print('DIRECTOR FIELDS HARNESS GATE PASS')
