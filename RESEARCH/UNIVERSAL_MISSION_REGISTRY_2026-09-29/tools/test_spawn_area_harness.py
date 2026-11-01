"""Spawn area rows harness (2026-10-31): AI_DIRECTOR_SETTER_AT_ENTRY variant NO_GETTER.

Runs the REAL generated Missions addon (a build of the current registry with enemies.active_area_ahead, _behind and
enemies.hard_cap declared) in plain Luau, calling the hooks the way the runtime does (luaCalls[P].before(prototype,
arguments, upvalues)), with mocked gRegion / NpcMgr / AI director that records every call of the director method
4f77b69c (spelled Name__b37ce12d in source; the build gate director-setter-alias proves the compiled hash).

Checks: host writes once with the configured (ahead, behind, false, false) over repeated entries; only one row on ->
the other passes its stock 75; both at stock -> nothing; client / no director / null director / both off -> nothing;
cleanup restores (75, 75, false, false) once on the written director; cleanup without a write calls nothing; the hard
cap row on the same module still works alongside.
Writes only to work/temp/spawn-area-harness and this tool's test-results folder. Reads no game or server folder.
"""
from pathlib import Path
import json, os, shutil, subprocess, sys

EDITOR = Path(__file__).resolve().parents[3]
ROOT = EDITOR
while not (ROOT / 'WORKSPACE.json').exists():
    ROOT = ROOT.parent
CLI = Path(os.environ.get('RENOVICE_EDITOR_CLI', ROOT / 'work/builds/ability-editor/current/bin/renovice_ability_editor_cli.exe'))
LUAU = ROOT / 'repos/toolchains/de-luau-toolchain/bin/luau.exe'
WORK = ROOT / 'work/temp/spawn-area-harness'
OUT = Path(__file__).resolve().parents[1] / 'test-results'
results = {'checks': []}
AHEAD, BEHIND, CAP = 'enemies.active_area_ahead', 'enemies.active_area_behind', 'enemies.hard_cap'
SETTER = 'Name__b37ce12d'


def check(ok, name):
    results['checks'].append({'name': name, 'pass': bool(ok)})
    print(('PASS' if ok else 'FAIL') + '\t' + name)
    if not ok:
        OUT.mkdir(parents=True, exist_ok=True)
        (OUT / 'spawn_area_harness.json').write_text(json.dumps(results, indent=2) + '\n', encoding='utf-8')
        sys.exit(1)


registry = json.loads((EDITOR / 'REGISTRIES/mission_build_u44.json').read_text(encoding='utf-8'))
rows = {r['tunable_id']: r for r in registry['tunables']}

# ---- registry shape
for tid, arg in ((AHEAD, 1), (BEHIND, 2)):
    r = rows[tid]
    o = r['owner']
    check(r['backend'] == 'TARGET_ADDON' and o['template'] == 'AI_DIRECTOR_SETTER_AT_ENTRY' and o['variant'] == 'NO_GETTER'
          and 'getter' not in o and o['setter'] == SETTER and o['setter_hash'] == '4f77b69c' and o['setter_alias'] == 'b37ce12d'
          and o['stock_arguments'] == [75, 75, False, False] and o['argument'] == arg and o['host_only'] and r['stock'] == 75
          and r['limits']['minimum'] == 10 and r['limits']['maximum'] == 1000 and r['unit'] == 'm'
          and [e['prototype'] for e in o['entries']] == [65, 2] and o['module_path'] == 'Lotus.Scripts.ProceduralLevel',
          f'{tid}: NO_GETTER director setter 4f77b69c argument {arg}, stock 75 m, 10..1000, ProceduralLevel P65/P2')
    check(r['ui'].get('path') == ['Enemies', 'All missions', 'Spawn distance']
          and r['ui'].get('row') == ('Ahead' if arg == 1 else 'Behind'),
          f'{tid}: Enemies > All missions > Spawn distance')
check(rows[AHEAD]['owner']['body_key'] == rows[CAP]['owner']['body_key'], 'spawn area and hard cap share the level module')

# ---- build
data = json.loads((EDITOR / 'RESEARCH/MISSIONS_R13_NATIVE_ENTRY_2026-10-01/inputs/rebuild_input.r12.json').read_text(encoding='utf-8'))
data['build'] = registry['build']
data['values'] = {k: v for k, v in data.get('values', {}).items() if k in rows or k in registry['ui_masters']}
data['values'].update({AHEAD: 75, BEHIND: 75, CAP: 40})
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
check(run.returncode == 0 and len(generations) == 1, 'build with the spawn area rows and the hard cap succeeds')
gen = generations[0].parent
source = (gen / 'source/Missions.targets.addon.luau').read_text(encoding='utf-8')
check(source.count('local function aiDirectorCall(') == 1, 'one aiDirectorCall helper in the addon')
check(source.count(f'director:{SETTER}(a[1], a[2], a[3], a[4])') == 1, 'one shared setter call with four arguments')
check(source.count('"director 4f77b69c"') == 1, 'the two rows share one call (one helper use for 4f77b69c)')
# 2026-10-31: enemies.area_limit_scale adds a second NO_GETTER setter (5904fb7a) with its own call
check(source.count('aiDirectorCall(') == 4, 'one helper definition + one call per setter (4f77b69c, 5904fb7a, 0a7324fb)')
gate_log = (gen / 'BUILD_GATES.log').read_text(encoding='utf-8', errors='replace').replace('\r\n', '\n')
check('director-setter-alias\nPASS setters=3\n' in gate_log,
      'build gate director-setter-alias: PASS setters=3 (b37ce12d -> 4f77b69c, 5904fb7a identity; hashes in the artifact)')

CASE = {'key': rows[AHEAD]['owner']['body_key']}
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
local master, findable, hasDirector = true, true, true
local calls, cap = {}, 40
local director = {
    Name__b37ce12d = function(self, a, b, c, d) calls[#calls + 1] = { a, b, c, d, n = select("#", a, b, c, d) } end,
    GetNpcHardCap = function(self) return cap end,
    SetNpcHardCap = function(self, n) cap = n end,
}
local npcs = {
    CanFind = function(self) return findable end,
    GetAiDirector = function(self) if hasDirector then return director end return nil end,
}
gRegion = { IsMaster = function() return master end, GetNpcMgr = function() return npcs end }

local function same(call, a, b, c, d)
    return call ~= nil and call[1] == a and call[2] == b and call[3] == c and call[4] == d
end
local function settings(aOn, aValue, bOn, bValue, capOn)
    return {
        ["enemies.active_area_ahead"] = { enabled = aOn, value = aValue, stock = 75 },
        ["enemies.active_area_behind"] = { enabled = bOn, value = bValue, stock = 75 },
        ["enemies.hard_cap"] = { enabled = capOn == true, value = 80, stock = 40 },
    }
end
local function run(s, times, keep)
    local target = ADDON_MODULE().targets[CASE.key]
    target.activate({ settings = s, logging = true })
    calls, printed = {}, {}
    for _ = 1, times or 1 do
        for _, p in ipairs({ 65, 2 }) do
            local hook = target.hooks.luaCalls[p]
            if hook ~= nil then hook.before(p, {}, {}) end
        end
    end
    local n = #calls
    if not keep then target.cleanup() end
    return n, target
end

ok(ADDON_MODULE().targets[CASE.key].hooks.luaCalls[65] ~= nil and ADDON_MODULE().targets[CASE.key].hooks.luaCalls[2] ~= nil,
   "ProceduralLevel hooks at P65 and P2")
-- host, both rows on: one call over 3 x (P65, P2)
local n, target = run(settings(true, 150, true, 100), 3, true)
ok(n == 1 and same(calls[1], 150, 100, false, false), "host, both rows: one call (150, 100, false, false) over 3 x (P65, P2)")
local logged = false
for _, line in ipairs(printed) do
    if line:find("RENOVICE Missions: enemies.active_area_ahead+enemies.active_area_behind director 4f77b69c (75, 75, false, false) -> (150, 100, false, false)", 1, true) then logged = true end
end
ok(logged and #printed == 1, "one missions log line: ... director 4f77b69c (75, 75, false, false) -> (150, 100, false, false)")
calls = {}
target.cleanup()
ok(#calls == 1 and same(calls[1], 75, 75, false, false), "cleanup restores (75, 75, false, false) once")
calls = {}
target.cleanup()
ok(#calls == 0, "a second cleanup calls nothing")
-- only one row on: the other passes its stock
n = run(settings(true, 200, false, 120))
ok(n == 1 and same(calls[1], 200, 75, false, false), "only ahead on (200): (200, 75, false, false)")
n = run(settings(false, 200, true, 120))
ok(n == 1 and same(calls[1], 75, 120, false, false), "only behind on (120): (75, 120, false, false)")
-- both rows at stock: nothing
n = run(settings(true, 75, true, 75))
ok(n == 0, "both rows on at stock 75: nothing written")
-- both off
n = run(settings(false, 200, false, 120))
ok(n == 0, "both rows off: nothing written")
do
    local t = ADDON_MODULE().targets[CASE.key]
    t.activate({ settings = settings(false, 200, false, 120), logging = true })
    calls = {}
    t.cleanup()
    ok(#calls == 0, "cleanup without a write calls nothing")
end
-- client
master = false
n = run(settings(true, 150, true, 100))
ok(n == 0 and #calls == 0, "client (not host) writes nothing, cleanup calls nothing")
master = true
-- no director yet at P65, director at P2
do
    local t = ADDON_MODULE().targets[CASE.key]
    t.activate({ settings = settings(true, 150, false, 0), logging = true })
    calls, findable = {}, false
    t.hooks.luaCalls[65].before(65, {}, {})
    ok(#calls == 0, "NpcMgr not findable at P65: nothing written there")
    findable = true
    t.hooks.luaCalls[2].before(2, {}, {})
    ok(#calls == 1 and same(calls[1], 150, 75, false, false), "director available at P2: written there")
    t.cleanup()
end
hasDirector = false
n = run(settings(true, 150, true, 100))
ok(n == 0, "no AI director: nothing written")
hasDirector = true
nulls[director] = true
n = run(settings(true, 150, true, 100))
ok(n == 0, "a null (destroyed) director: nothing written")
nulls[director] = nil
-- the hard cap row on the same module still works alongside
cap = 40
n = run(settings(true, 150, true, 100, true), 1, true)
ok(n == 1 and cap == 80, "hard cap and spawn area in one level entry: both written")
emit(failures == 0 and "SPAWN AREA HARNESS PASS" or "SPAWN AREA HARNESS FAIL")
'''

script = WORK / 'spawn_area_harness.luau'
script.write_text('ADDON_MODULE = function(...)\n' + source + '\nend\n' + 'CASE = { key = ' + json.dumps(CASE['key']) + ' }\n' + harness,
                  encoding='utf-8')
check(LUAU.is_file(), 'toolchain luau.exe present')
run = subprocess.run([str(LUAU), str(script)], capture_output=True, text=True)
lines = run.stdout.splitlines()
for line in lines:
    print('HARNESS\t' + line)
if run.stderr.strip():
    print('HARNESS-STDERR\t' + run.stderr.strip())
check(run.returncode == 0 and 'SPAWN AREA HARNESS PASS' in lines and not any(l.startswith('FAIL') for l in lines),
      f'harness: {sum(l.startswith("PASS") for l in lines)} checks over the spawn area rows')
OUT.mkdir(parents=True, exist_ok=True)
(OUT / 'spawn_area_harness.json').write_text(json.dumps(results, indent=2) + '\n', encoding='utf-8')
print('SPAWN AREA HARNESS GATE PASS')
