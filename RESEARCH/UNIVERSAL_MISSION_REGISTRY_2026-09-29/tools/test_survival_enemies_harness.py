"""Survival enemies-at-once rows + AI director hard cap harness (2026-10-30).

Runs the REAL generated Missions addon (a build of the current registry with the 24 Survival count rows, the
survival.enemy_multiplier master and enemies.hard_cap declared) in plain Luau, calling the hooks the way the runtime does
(luaCalls[P].before(prototype, arguments, upvalues)), with mocked gRegion / NpcMgr / AI director.

Hard cap (AI_DIRECTOR_SETTER_AT_ENTRY on ProceduralLevel P65 and P2): host with the cap at stock 40 -> one SetNpcHardCap
(value), repeated entries write nothing more; a client, no director (CanFind false / IsNull), a non-stock cap (another
writer) and the setting switched off write nothing; cleanup puts 40 back where the written value is still there.
Survival tables (ROOT_TABLE_FIELD on the root config arrays, hook P35): a row value is written into its array element; the
master writes element stock x master into every array; a ticked row wins over the master; cleanup restores every stock;
the master switched off writes nothing.
Writes only to work/temp/survival-enemies-harness and this tool's test-results folder. Reads no game or server folder.
"""
from pathlib import Path
import json, os, shutil, subprocess, sys

EDITOR = Path(__file__).resolve().parents[3]
ROOT = EDITOR
while not (ROOT / 'WORKSPACE.json').exists():
    ROOT = ROOT.parent
CLI = Path(os.environ.get('RENOVICE_EDITOR_CLI', ROOT / 'work/builds/ability-editor/current/bin/renovice_ability_editor_cli.exe'))
LUAU = ROOT / 'repos/toolchains/de-luau-toolchain/bin/luau.exe'
WORK = ROOT / 'work/temp/survival-enemies-harness'
OUT = Path(__file__).resolve().parents[1] / 'test-results'
results = {'checks': []}
STOCKS = {'min': [7, 15, 25, 30], 'max': [10, 25, 30, 35], 'infested_min': [8, 15, 25, 30],
          'infested_max': [12, 25, 30, 35], 'duviri_min': [15, 23, 27, 30], 'duviri_max': [20, 28, 32, 35]}
FIELDS = {'min': 'minNum', 'max': 'maxNum', 'infested_min': 'minNumInfested', 'infested_max': 'maxNumInfested',
          'duviri_min': 'minNumEnemiesHardModeDuviri', 'duviri_max': 'maxNumEnemiesHardModeDuviri'}
MASTER = 'survival.enemy_multiplier'
CAP = 'enemies.hard_cap'


def check(ok, name):
    results['checks'].append({'name': name, 'pass': bool(ok)})
    print(('PASS' if ok else 'FAIL') + '\t' + name)
    if not ok:
        OUT.mkdir(parents=True, exist_ok=True)
        (OUT / 'survival_enemies_harness.json').write_text(json.dumps(results, indent=2) + '\n', encoding='utf-8')
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
masters = registry['ui_masters']

# ---- registry shape
cap = rows[CAP]
o = cap['owner']
check(cap['backend'] == 'TARGET_ADDON' and o['template'] == 'AI_DIRECTOR_SETTER_AT_ENTRY' and o['getter'] == 'GetNpcHardCap'
      and o['setter'] == 'SetNpcHardCap' and o['host_only'] and cap['stock'] == 40
      and [e['prototype'] for e in o['entries']] == [65, 2] and all(e['root_child'] for e in o['entries'])
      and o['module_path'] == 'Lotus.Scripts.ProceduralLevel',
      f'{CAP}: AI director setter on ProceduralLevel P65/P2, stock 40, host only')
check(cap['ui'].get('path') == ['Enemies', 'All missions'] and not any(d['tunable_id'] == CAP for m in masters.values() for d in m['drives']),
      f'{CAP}: on Enemies > All missions, driven by no master')
survival_key = None
for part, stocks in STOCKS.items():
    for n, stock in enumerate(stocks, start=1):
        r = rows[f'survival.enemy_count.{part}.p{n}']
        f = r['owner']['fields']
        survival_key = r['owner']['body_key']
        check(r['owner']['template'] == 'ROOT_TABLE_FIELD' and r['stock'] == stock and len(f) == 1 and f[0]['field'] == n
              and r['ui']['path'][:2] == ['Enemies', 'Survival'],
              f'survival.enemy_count.{part}.p{n}: element {n} of {FIELDS[part]}, stock {stock}, Survival > Enemies')
drives = {d['tunable_id']: d['scale'] for d in masters[MASTER]['drives']}
check(len(drives) == 24 and all(drives[f'survival.enemy_count.{p}.p{n}'] == s for p, st in STOCKS.items()
                                for n, s in enumerate(st, start=1))
      and masters[MASTER]['stock'] == 1 and masters[MASTER]['min'] == 1 and masters[MASTER]['max'] == 1000,
      f'{MASTER}: drives all 24 rows with scale = row stock, stock 1, limits 1..1000')
check(masters['enemies.multiplier']['short_label'].startswith('Wave size'), 'enemies.multiplier is the Wave size multiplier (MaxAI per encounter)')
module = registry['modules'][survival_key]
hook_upvalue = {}
for part in STOCKS:
    tid = rows[f'survival.enemy_count.{part}.p1']['owner']['fields'][0]['table_id']
    t = module['root_tables'][tid]
    check(t['minimal_hooks']['prototypes'] == [35], f'{FIELDS[part]}: hooked at P35 (the count function) only')
    h = [x for x in t['hooks'] if x['prototype'] == 35][0]
    check(h['path'] == [FIELDS[part]], f'{FIELDS[part]}: reached through the config table field {FIELDS[part]}')
    hook_upvalue[part] = h['upvalue']
check(len(set(hook_upvalue.values())) == 1, 'every count table is reached through one P35 upvalue (the config table)')
UPVALUE = next(iter(hook_upvalue.values()))

# ---- build: every new value declared (rows off -> master drives; the master and the cap set)
data = json.loads((EDITOR / 'RESEARCH/MISSIONS_R13_NATIVE_ENTRY_2026-10-01/inputs/rebuild_input.r12.json').read_text(encoding='utf-8'))
data['build'] = registry['build']
data['values'] = {k: v for k, v in data.get('values', {}).items() if k in rows or k in masters}
for part, stocks in STOCKS.items():
    for n, stock in enumerate(stocks, start=1):
        data['values'][f'survival.enemy_count.{part}.p{n}'] = stock
data['values'][MASTER] = 1
data['values'][CAP] = 40
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
check(run.returncode == 0 and len(generations) == 1, 'build with the Survival rows, master and hard cap succeeds')
source = (generations[0].parent / 'source/Missions.targets.addon.luau').read_text(encoding='utf-8')
check(source.count('local function aiDirector_SetNpcHardCap(') == 1, 'one AI director setter helper in the addon')
check('director:SetNpcHardCap(value)' in source and 'director:GetNpcHardCap()' in source, 'helper uses the game method pair')

CASE = {'cap_key': o['body_key'], 'survival_key': survival_key, 'upvalue': UPVALUE, 'stocks': STOCKS, 'fields': FIELDS}
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
local cap, sets = 40, 0
local director = {
    GetNpcHardCap = function(self) return cap end,
    SetNpcHardCap = function(self, n) sets = sets + 1 cap = n end,
}
local npcs = {
    CanFind = function(self) return findable end,
    GetAiDirector = function(self) if hasDirector then return director end return nil end,
}
gRegion = { IsMaster = function() return master end, GetNpcMgr = function() return npcs end }

local function capRun(enabled, value, times, keep)
    local target = ADDON_MODULE().targets[CASE.cap_key]
    target.activate({ settings = { ["enemies.hard_cap"] = { enabled = enabled, value = value, stock = 40 } }, logging = true })
    sets, printed = 0, {}
    for _ = 1, times or 1 do
        for _, p in ipairs({ 65, 2 }) do
            local hook = target.hooks.luaCalls[p]
            if hook ~= nil then hook.before(p, {}, {}) end
        end
    end
    local before = sets
    if not keep then target.cleanup() end
    return before, target
end

ok(ADDON_MODULE().targets[CASE.cap_key] ~= nil, "ProceduralLevel target exists")
ok(ADDON_MODULE().targets[CASE.cap_key].hooks.luaCalls[65] ~= nil and ADDON_MODULE().targets[CASE.cap_key].hooks.luaCalls[2] ~= nil,
   "hard cap hooks at P65 and P2")
-- host, stock cap: written once, repeated entries do not write again; cleanup restores 40
cap = 40
local n, target = capRun(true, 80, 3, true)
ok(n == 1 and cap == 80, "host, cap 40 -> 80 written once over 3 x (P65, P2)")
local logged = false
for _, line in ipairs(printed) do if line:find("enemies.hard_cap SetNpcHardCap 40 -> 80", 1, true) then logged = true end end
ok(logged, "one missions log line: enemies.hard_cap SetNpcHardCap 40 -> 80")
target.cleanup()
ok(cap == 40, "cleanup restores the stock 40 where the written value is still there")
-- cleanup leaves another writer's value alone
cap = 40
n, target = capRun(true, 80, 1, true)
cap = 55
target.cleanup()
ok(cap == 55, "cleanup leaves a value another writer set afterwards")
-- client
master, cap = false, 40
n = capRun(true, 80)
ok(n == 0 and cap == 40, "client (not host) writes nothing")
master = true
-- no director yet at P65 but at P2: written at P2 (the second entry)
cap = 40
do
    local t = ADDON_MODULE().targets[CASE.cap_key]
    t.activate({ settings = { ["enemies.hard_cap"] = { enabled = true, value = 70, stock = 40 } }, logging = true })
    sets, findable = 0, false
    t.hooks.luaCalls[65].before(65, {}, {})
    ok(sets == 0 and cap == 40, "NpcMgr not findable at P65: nothing written there")
    findable = true
    t.hooks.luaCalls[2].before(2, {}, {})
    ok(sets == 1 and cap == 70, "director available at P2: 40 -> 70 written there")
    t.cleanup()
end
-- no director at all
hasDirector, cap = false, 40
n = capRun(true, 80)
ok(n == 0 and cap == 40, "no AI director: nothing written")
hasDirector = true
nulls[director] = true
n = capRun(true, 80)
ok(n == 0 and cap == 40, "a null (destroyed) director: nothing written")
nulls[director] = nil
-- another writer (non-stock cap)
cap = 60
n = capRun(true, 80)
ok(n == 0 and cap == 60, "cap 60 (not the stock 40): left unchanged")
local said = false
for _, line in ipairs(printed) do if line:find("not the stock 40", 1, true) then said = true end end
ok(said, "non-stock cap: one 'left unchanged' log line")
-- disabled
cap = 40
n = capRun(false, 80)
ok(n == 0 and cap == 40, "setting switched off writes nothing")

-- ---- Survival count tables
local function config()
    local c = {}
    for part, field in pairs(CASE.fields) do
        local t = {}
        for i, v in ipairs(CASE.stocks[part]) do t[i] = v end
        c[field] = t
    end
    return c
end
local function survival(settings)
    local target = ADDON_MODULE().targets[CASE.survival_key]
    target.activate({ settings = settings, logging = true })
    local c = config()
    local upvalues = {}
    upvalues[CASE.upvalue] = c
    local hook = target.hooks.luaCalls[35]
    ok(hook ~= nil, "Survival count function P35 is hooked")
    hook.before(35, {}, upvalues)
    return target, c
end
local function rowSettings(extra)
    local s = { ["survival.enemy_multiplier"] = { enabled = false, value = 1, stock = 1 } }
    for part, stocks in pairs(CASE.stocks) do
        for i, v in ipairs(stocks) do
            s["survival.enemy_count." .. part .. ".p" .. i] = { enabled = false, value = v, stock = v }
        end
    end
    for k, v in pairs(extra or {}) do s[k] = v end
    return s
end
-- one row
do
    local target, c = survival(rowSettings({ ["survival.enemy_count.max.p4"] = { enabled = true, value = 60, stock = 35 } }))
    ok(c.maxNum[4] == 60 and c.maxNum[1] == 10 and c.minNum[4] == 30, "row survival.enemy_count.max.p4 = 60 writes maxNum[4] only")
    target.cleanup()
    ok(c.maxNum[4] == 35, "cleanup restores maxNum[4] = 35")
end
-- master x3 drives every element (stock x 3); a ticked row wins
do
    local target, c = survival(rowSettings({ ["survival.enemy_multiplier"] = { enabled = true, value = 3, stock = 1 },
                                             ["survival.enemy_count.min.p1"] = { enabled = true, value = 9, stock = 7 } }))
    local all = true
    for part, field in pairs(CASE.fields) do
        for i, v in ipairs(CASE.stocks[part]) do
            local want = (part == "min" and i == 1) and 9 or v * 3
            if c[field][i] ~= want then all = false emit("  " .. field .. "[" .. i .. "] = " .. tostring(c[field][i]) .. ", want " .. want) end
        end
    end
    ok(all, "master 3: every one of the 24 elements = stock x 3; the ticked row min.p1 = 9 wins")
    target.cleanup()
    local restored = true
    for part, field in pairs(CASE.fields) do
        for i, v in ipairs(CASE.stocks[part]) do if c[field][i] ~= v then restored = false end end
    end
    ok(restored, "cleanup restores all 24 stocks")
end
-- nothing enabled
do
    local target, c = survival(rowSettings())
    local same = true
    for part, field in pairs(CASE.fields) do
        for i, v in ipairs(CASE.stocks[part]) do if c[field][i] ~= v then same = false end end
    end
    ok(same, "master and rows off: no table changed")
    target.cleanup()
end
emit(failures == 0 and "SURVIVAL ENEMIES HARNESS PASS" or "SURVIVAL ENEMIES HARNESS FAIL")
'''

script = WORK / 'survival_enemies_harness.luau'
script.write_text('ADDON_MODULE = function(...)\n' + source + '\nend\n' + 'CASE = ' + lua(CASE) + '\n' + harness,
                  encoding='utf-8')
check(LUAU.is_file(), 'toolchain luau.exe present')
run = subprocess.run([str(LUAU), str(script)], capture_output=True, text=True)
lines = run.stdout.splitlines()
for line in lines:
    print('HARNESS\t' + line)
if run.stderr.strip():
    print('HARNESS-STDERR\t' + run.stderr.strip())
check(run.returncode == 0 and 'SURVIVAL ENEMIES HARNESS PASS' in lines and not any(l.startswith('FAIL') for l in lines),
      f'harness: {sum(l.startswith("PASS") for l in lines)} checks over the hard cap and the Survival tables')
OUT.mkdir(parents=True, exist_ok=True)
(OUT / 'survival_enemies_harness.json').write_text(json.dumps(results, indent=2) + '\n', encoding='utf-8')
print('SURVIVAL ENEMIES HARNESS GATE PASS')
