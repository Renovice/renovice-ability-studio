"""Spawn point reuse harness (2026-11-01): NATIVE_CALL_RETRY_AT_SPAWN_POINT on Lotus.Scripts.Libs.EndlessSpawnLib.

Runs the REAL generated Missions addon (a full package build of the current registry with enemies.spawn_point_reuse
declared) in plain Luau, calling hooks.nativeCalls.CreateRandomAgent.after(prototype, instruction, arguments, results)
the way the runtime does (arguments[1] = the receiver, results a one-based table), with mocked gRegion, AI director
(CreateRandomAgent, GetLeadPlayer, point query Name__1ab54531) and spawn points (GetTag).

Checks: registry shape; build gates (native-call-alias, hook-plan native_hooks=1, director-setter-alias unchanged);
off (or enabled at Off) -> nothing; on + stock nil location + nil result -> exactly one CreateRandomAgent with a free point from the query
and the stock arguments 3..6, the agent replaces the nil result, one log line per generation; a null (IsNull) stock result
is retried too; non-null result, explicit location, wrong prototype, client, no lead player, no free point, a failing
retry (pcall) -> nothing changes; cleanup -> callback inert; a second generation logs again.
Writes only to work/temp/spawn-point-reuse-harness and this tool's test-results folder. Reads no game or server folder.
"""
from pathlib import Path
import json, os, shutil, subprocess, sys

EDITOR = Path(__file__).resolve().parents[3]
ROOT = EDITOR
while not (ROOT / 'WORKSPACE.json').exists():
    ROOT = ROOT.parent
CLI = Path(os.environ.get('RENOVICE_EDITOR_CLI', ROOT / 'work/builds/ability-editor/current/bin/renovice_ability_editor_cli.exe'))
LUAU = ROOT / 'repos/toolchains/de-luau-toolchain/bin/luau.exe'
WORK = ROOT / 'work/temp/spawn-point-reuse-harness'
OUT = Path(__file__).resolve().parents[1] / 'test-results'
results = {'checks': []}
TID = 'enemies.spawn_point_reuse'
KEY = '6f5169d34d076588'


def check(ok, name):
    results['checks'].append({'name': name, 'pass': bool(ok)})
    print(('PASS' if ok else 'FAIL') + '\t' + name)
    if not ok:
        OUT.mkdir(parents=True, exist_ok=True)
        (OUT / 'spawn_point_reuse_harness.json').write_text(json.dumps(results, indent=2) + '\n', encoding='utf-8')
        sys.exit(1)


registry = json.loads((EDITOR / 'REGISTRIES/mission_build_u44.json').read_text(encoding='utf-8'))
rows = {r['tunable_id']: r for r in registry['tunables']}

# ---- registry shape
r = rows[TID]
o = r['owner']
q = o['point_query']
check(r['backend'] == 'TARGET_ADDON' and o['template'] == 'NATIVE_CALL_RETRY_AT_SPAWN_POINT' and o['body_key'] == KEY
      and o['module_path'] == 'Lotus.Scripts.Libs.EndlessSpawnLib' and o['prototype'] == 9 and o['instruction'] == 80
      and o['method'] == 'CreateRandomAgent' and o['argument_count'] == 5 and o['location_argument'] == 2 and o['host_only']
      and q['method'] == 'Name__1ab54531' and q['hash'] == q['alias'] == '1ab54531' and q['min_radius'] == 10
      and q['max_radius'] == 75 and r['stock'] == 0 and r['limits']['minimum'] == 0 and r['limits']['maximum'] == 1,
      f'{TID}: EndlessSpawnLib P9 CreateRandomAgent retry, location argument 2, query 1ab54531 10..75 m, on/off stock 0')
check(registry['modules'][KEY]['file'] == 'Lotus_Scripts_Libs_EndlessSpawnLib.lua_B'
      and (ROOT / registry['corpus'] / 'Lotus_Scripts_Libs_EndlessSpawnLib.lua_B').is_file(),
      'EndlessSpawnLib registered as a module and present in the registry corpus')
check(r['ui'].get('path') == ['Enemies', 'All missions'] and r['ui'].get('row') == 'Spawn point reuse'
      and r['ui']['editor'] == 'TOGGLE' and len('Spawn point reuse: 0') <= 40,
      f'{TID}: Enemies > All missions > Spawn point reuse (toggle)')

# ---- build (full package; the row on)
data = json.loads((EDITOR / 'RESEARCH/MISSIONS_R13_NATIVE_ENTRY_2026-10-01/inputs/rebuild_input.r12.json').read_text(encoding='utf-8'))
data['build'] = registry['build']
data['values'] = {k: v for k, v in data.get('values', {}).items() if k in rows or k in registry['ui_masters']}
data['values'][TID] = 1
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
check(run.returncode == 0 and len(generations) == 1, 'full package build with the spawn point reuse row succeeds')
gen = generations[0].parent
source = (gen / 'source/Missions.targets.addon.luau').read_text(encoding='utf-8')
check(source.count('CreateRandomAgent = { after = nativeAfter') == 1 and source.count(':Name__1ab54531(') == 1,
      'one nativeCalls.CreateRandomAgent.after hook and one point query call in the addon')
check(source.count('hooks = { nativeCalls = {') == 1, 'the EndlessSpawnLib target declares only the nativeCalls hook')
gate_log = (gen / 'BUILD_GATES.log').read_text(encoding='utf-8', errors='replace').replace('\r\n', '\n')
check('native-call-alias\nPASS queries=1\n' in gate_log, 'build gate native-call-alias: PASS queries=1 (identity alias, hash in the artifact)')
check('director-setter-alias\nPASS setters=3\n' in gate_log, 'build gate director-setter-alias unchanged: PASS setters=3')
check('hook-plan\nPASS ' in gate_log and ' native_hooks=1\n' in gate_log, 'build gate hook-plan: PASS with native_hooks=1')
manifest = json.loads((gen / 'MISSION_SET_MANIFEST.json').read_text(encoding='utf-8'))
check(TID in json.dumps(manifest), 'the row is declared in the package manifest')

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
local nulls = {}
IsNull = function(object) return object == nil or nulls[object] == true end
EMPTY_SYMBOL = { symbol = "EMPTY" }
local TAKEN = { symbol = "Taken" }
gNpcSpawnPointType = { type = "NpcSpawnPoint" }
local function point(tag) return { tag = tag, GetTag = function(self) return self.tag end } end
local master, lead, failRetry = true, { name = "lead" }, false
local points = { point(TAKEN), point(EMPTY_SYMBOL), point(EMPTY_SYMBOL) }
local creates, queries = {}, {}
local agent = { name = "agent" }
local director = {
    CreateRandomAgent = function(self, ...)
        creates[#creates + 1] = { n = select("#", ...), ... }
        if failRetry then error("spawn failed") end
        return agent
    end,
    GetLeadPlayer = function(self) return lead end,
    Name__1ab54531 = function(self, ...)
        queries[#queries + 1] = { ... }
        return points
    end,
}
gRegion = { IsMaster = function() return master end }

local function settings(on, value)
    return { ["enemies.spawn_point_reuse"] = { enabled = on, value = value or 1, stock = 0 } }
end
local target = ADDON_MODULE().targets[CASE.key]
local hook = target.hooks.nativeCalls and target.hooks.nativeCalls.CreateRandomAgent
ok(hook ~= nil and type(hook.after) == "function" and hook.before == nil and target.hooks.luaCalls == nil,
   "EndlessSpawnLib declares nativeCalls.CreateRandomAgent.after only")
local TEAM, LEVEL, EXIMUS = { team = 1 }, 37, true
local function stockArguments(location) return { director, location, TEAM, LEVEL, nil, EXIMUS } end
local function call(prototype, arguments, result)
    creates, queries, printed = {}, {}, {}
    local r = { result }
    hook.after(prototype, 80, arguments, r)
    return r
end

-- off
target.activate({ settings = settings(false), logging = true })
local r = call(9, stockArguments(nil), nil)
ok(#creates == 0 and #queries == 0 and r[1] == nil, "row off: no query, no spawn, result unchanged")
target.cleanup()
target.activate({ settings = settings(true, 0), logging = true })
r = call(9, stockArguments(nil), nil)
ok(#creates == 0 and #queries == 0 and r[1] == nil, "row enabled with the value Off (0): nothing")
target.cleanup()

-- on: stock nil location, nil result
target.activate({ settings = settings(true), logging = true })
r = call(9, stockArguments(nil), nil)
local c = creates[1]
local free = c ~= nil and (c[1] == points[2] or c[1] == points[3])
ok(#creates == 1 and free and c[2] == TEAM and c[3] == LEVEL and c[4] == nil and c[5] == EXIMUS and c.n == 5,
   "on: exactly one CreateRandomAgent(free point, team, level, nil, eximus)")
ok(#queries == 1 and queries[1][1] == gNpcSpawnPointType and queries[1][2] == 10 and queries[1][3] == 75 and queries[1][4] == true
   and queries[1][5] == lead, "point query (gNpcSpawnPointType, 10, 75, true, lead player)")
ok(r[1] == agent, "the spawned agent replaces the nil stock result")
-- 2026-11-01: plus one bounded diagnosis line ("called after an empty spawn") before the first reuse line
ok(#printed == 2 and printed[1]:find("enemies.spawn_point_reuse called after an empty spawn", 1, true) ~= nil
   and printed[2]:find("RENOVICE Missions: enemies.spawn_point_reuse active", 1, true) ~= nil,
   "one diagnosis line, then one log line at the first reuse")
r = call(9, stockArguments(nil), nil)
ok(#creates == 1 and #printed == 0, "second reuse: spawns again, no second log line")
for _ = 1, 20 do
    call(9, stockArguments(nil), nil)
    ok(creates[1][1] ~= points[1], "never the taken point")
end
-- a null (destroyed) stock result counts as nil
local dead = { name = "dead" }
nulls[dead] = true
r = call(9, stockArguments(nil), dead)
ok(#creates == 1 and r[1] == agent, "a null stock result is retried")
-- non-null stock result
local stockAgent = { name = "stock" }
r = call(9, stockArguments(nil), stockAgent)
ok(#creates == 0 and #queries == 0 and r[1] == stockAgent, "stock spawned an agent: no extra call")
-- explicit location from stock
r = call(9, stockArguments(points[1]), nil)
ok(#creates == 0 and #queries == 0 and r[1] == nil, "stock passed a location: no extra call")
-- wrong prototype
r = call(8, stockArguments(nil), nil)
ok(#creates == 0 and #queries == 0 and r[1] == nil, "another prototype: nothing")
-- client
master = false
r = call(9, stockArguments(nil), nil)
ok(#creates == 0 and #queries == 0 and r[1] == nil, "not the host: nothing")
master = true
-- no lead player
local saved = lead
lead = nil
r = call(9, stockArguments(nil), nil)
ok(#creates == 0 and r[1] == nil, "no lead player: nothing")
lead = saved
-- no free point
local savedPoints = points
points = { point(TAKEN), point(TAKEN) }
r = call(9, stockArguments(nil), nil)
ok(#creates == 0 and #queries == 1 and r[1] == nil, "no EMPTY-tag point: nothing")
points = {}
r = call(9, stockArguments(nil), nil)
ok(#creates == 0 and r[1] == nil, "empty query result: nothing")
points = savedPoints
-- a failing retry is contained
failRetry = true
local fine = pcall(function() r = call(9, stockArguments(nil), nil) end)
ok(fine and #creates == 1 and r[1] == nil, "a failing retry is caught (pcall): result unchanged, no error")
failRetry = false
-- cleanup
target.cleanup()
r = call(9, stockArguments(nil), nil)
ok(#creates == 0 and #queries == 0 and r[1] == nil, "after cleanup the callback is inert")
-- a new generation logs once again
target.activate({ settings = settings(true), logging = true })
r = call(9, stockArguments(nil), nil)
ok(#creates == 1 and #printed == 2, "a new generation reuses and logs once again (diagnosis + active line)")
target.cleanup()
-- the stock compiled value (no context.settings): the package ships the row as built
target.activate({ logging = true })
r = call(9, stockArguments(nil), nil)
ok(#creates == CASE.compiled_on, "without context.settings the compiled choice applies")
target.cleanup()
emit(failures == 0 and "SPAWN POINT REUSE HARNESS PASS" or "SPAWN POINT REUSE HARNESS FAIL")
'''

compiled_on = 1 if f'["{TID}"] = {{ value = 1, stock = 0, enabled = true }}' in source else 0
check(compiled_on == 1, 'the build compiles the row on (value 1, enabled)')
script = WORK / 'spawn_point_reuse_harness.luau'
script.write_text('ADDON_MODULE = function(...)\n' + source + '\nend\n' + 'CASE = { key = ' + json.dumps(KEY) +
                  ', compiled_on = ' + str(compiled_on) + ' }\n' + harness, encoding='utf-8')
check(LUAU.is_file(), 'toolchain luau.exe present')
run = subprocess.run([str(LUAU), str(script)], capture_output=True, text=True)
lines = run.stdout.splitlines()
for line in lines:
    print('HARNESS\t' + line)
if run.stderr.strip():
    print('HARNESS-STDERR\t' + run.stderr.strip())
check(run.returncode == 0 and 'SPAWN POINT REUSE HARNESS PASS' in lines and not any(l.startswith('FAIL') for l in lines),
      f'harness: {sum(l.startswith("PASS") for l in lines)} checks over the spawn point reuse row')
OUT.mkdir(parents=True, exist_ok=True)
(OUT / 'spawn_point_reuse_harness.json').write_text(json.dumps(results, indent=2) + '\n', encoding='utf-8')
print('SPAWN POINT REUSE HARNESS GATE PASS')
