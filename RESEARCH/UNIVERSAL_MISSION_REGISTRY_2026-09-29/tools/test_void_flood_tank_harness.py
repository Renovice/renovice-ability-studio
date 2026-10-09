"""Void Flood tank multipliers: Luau harness over the REAL generated addon (contract R14, 2026-10-01).

What it proves (offline):
  1. The pinned full-package build input builds; the addon is the pinned R14 addon and literals.json is unchanged.
  2. The registry rows are the scaled root-table rows (mode scale / scale_count, row stock 1, a stock per field).
  3. The generated Missions addon, run in plain Luau as the runtime calls it (activate(context) ->
     hooks.luaCalls[P].before(P, arguments, upvalues) -> cleanup()), against simulated ZarimanCorruptionMission root tables
     built like the module root builds them (config tables frame_83[18] / [34] / [45] / [168], readable L73-269), with
     the upvalue view of every hooked prototype taken from the registry capture evidence (`hooks`: prototype, upvalue,
     container path):
       - every array and field is scaled exactly once per instance (deposit rate x value, capacity x value rounded and at
         least 1, orb values x value, drain x value) and the hooks return the R3 retire signal;
       - calling every hook again, or re-activating without cleanup, never compounds;
       - a second instance (next mission) is written from the registered stock, the first instance keeps its numbers;
       - cleanup restores every written field of every instance; a new generation after cleanup writes from stock again;
       - a drifted field (another writer) leaves the table unchanged; values at their default write nothing and retire
         every hook of the target (R4).
  4. The stock gameplay rules, transcribed from the decompiled readers, give the expected effect:
     deposit (prototype 48, L9618-9662), carry cap (prototype 43, L8586-8604), drain (prototype 41, L7724-7840), orb
     value copy at mission start (prototype 68, L13336-13346).
  5. R5-C coexistence with the R8 Void Flood live literal (fractures per round): no recipe site of this module overlaps a
     scaled field's initialiser, and a module synthesized from the recipe still encodes every field stock (so the
     addon's stock check holds on the patched module).
Limits: the gameplay rules are transcriptions of the readable decompile, not the DE bytecode in the game VM; which
prototypes the runtime dispatches (Lua CALL and R13 native entry) is the bootstrapper's gate, not this one.

Paths: CLI = RENOVICE_EDITOR_CLI or work/builds/ability-editor/current; luau.exe from the DE Luau toolchain. Writes only to
work/temp/void-flood-tank-harness and this tool's test-results folder. Reads no game or server folder.
"""
from pathlib import Path
import hashlib, json, os, shutil, subprocess, sys
from harness_input import current_input, current_spec, package_pins  # noqa: E402  (same folder; 2026-10-09)
_PINS = package_pins()  # the package the current registry builds (test-results/package_pins.json; --repin)

EDITOR = Path(__file__).resolve().parents[3]
ROOT = EDITOR
while not (ROOT / 'WORKSPACE.json').exists():
    ROOT = ROOT.parent
CLI = Path(os.environ.get('RENOVICE_EDITOR_CLI', ROOT / 'work/builds/ability-editor/current/bin/renovice_ability_editor_cli.exe'))
LUAU = ROOT / 'repos/toolchains/de-luau-toolchain/bin/luau.exe'
INPUT = EDITOR / 'RESEARCH/MISSIONS_R13_NATIVE_ENTRY_2026-10-01/inputs/rebuild_input.r12.json'  # same input since R12
INPUT_LF_SHA = 'dccde5fddf2649c2be4c93789cecab4cc1d1759dc9d01d0117cba25f5a7ca4b6'
# R15 (2026-10-01): the same input builds 70fff0b6 (defense.waves_per_reward left the addon for the reader pin);
# R14 built 4c70b5ec200f9409ca034546aea37555c8f6081cd6661978c3a41e347b7ccbba.
# R17 (2026-10-01): the same input builds daab653a (Deepmines rows left the addon for reader pins, the Gas City row became
# the meltdown-time scale, the Railjack master was added); R15/R16 built 70fff0b6606e452e...
# R18 (2026-10-02): + the two Pontis tower entry rows (43cb89c3) and the R18 literal masters (786c7b94).
# R19 (2026-10-02): the Railjack master compiled without drives in its own target (fighter/crewship rows owned at the
# engine writer) (d8736450).
# R22 (2026-10-02): + the Void Cascade exolizer speed master (76c10eaa).
# 2026-10-09: pins read from test-results/package_pins.json (harness_input.py --repin; the R22 44.0.2 values were a943cd3e / fd89daca / 9beaa438 / 20323777).
R14_ADDON_SHA = _PINS['Missions.targets.addon.lua_B']
# R17 adds the Deepmines reader pins and the "All <type> missions" literal masters (028fdcd2); R15/R16 shipped a16b2520...,
# R11-R14 d9b3a764...
# R20 (2026-10-02): minimums of the Kela and Gas City factor literals (96a97899).
# R22 (2026-10-02): + the Void Cascade reward interval (9beaa438).
LITERALS_SHA = _PINS['literals.json']
KEY = 'fc711ff621a75552'
ROWS = {'void_flood.deposit_speed_scale': 'scale', 'void_flood.tank_capacity_scale': 'scale_count',
        'void_flood.orb_value_scale': 'scale', 'void_flood.drain_speed_scale': 'scale'}
WORK = ROOT / 'work/temp/void-flood-tank-harness'
OUT = Path(__file__).resolve().parents[1] / 'test-results'
results = {'checks': []}


def check(ok, name):
    results['checks'].append({'name': name, 'pass': bool(ok)})
    print(('PASS' if ok else 'FAIL') + '\t' + name)
    if not ok:
        OUT.mkdir(parents=True, exist_ok=True)
        (OUT / 'void_flood_tank_harness.json').write_text(json.dumps(results, indent=2) + '\n', encoding='utf-8')
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
run = subprocess.run([str(CLI), 'build-missions', str(current_input(INPUT, WORK)), '--staging', str(WORK / 'build'), '--editor-root', str(EDITOR)],
                     capture_output=True, text=True)
generations = list((WORK / 'build').glob('missions/*/MISSION_SET_MANIFEST.json'))
check(run.returncode == 0 and len(generations) == 1, 'full package build succeeds')
generation = generations[0].parent
package = generation / 'Packages/Missions'
check(sha(package / 'Missions.targets.addon.lua_B') == R14_ADDON_SHA, f'the built addon is the pinned R22 addon ({R14_ADDON_SHA[:8]}; R19-R21 d8736450, R18 43cb89c3, R17 daab653a, R15/R16 70fff0b6, R14 4c70b5ec)')
check(sha(package / 'literals.json') == LITERALS_SHA, 'literals.json is the pinned R22 recipe file (9beaa438; R20/R21 96a97899, R18/R19 786c7b94, R17 028fdcd2, R15/R16 a16b2520, R11-R14 d9b3a764)')
source = (generation / 'source/Missions.targets.addon.luau').read_text(encoding='utf-8')
declared = json.loads((package / 'package.json').read_text(encoding='utf-8'))['members']['Missions.targets.addon.lua_B']['settings']['values']
check(all(tid in declared and declared[tid]['stock'] == 1 and declared[tid]['type'] == 'float' and declared[tid]['unit'] == 'x'
          for tid in ROWS), 'package.json declares the four multipliers (stock 1, float, unit x)')

# 2. Registry rows and the capture evidence of the module.
registry = json.loads((EDITOR / 'REGISTRIES/mission_build_u44.json').read_text(encoding='utf-8'))
rows = {r['tunable_id']: r for r in registry['tunables'] if r['tunable_id'] in ROWS}
check(len(rows) == 4 and all(rows[t]['owner'].get('mode') == m and rows[t]['stock'] == 1 and
                             all('stock' in f for f in rows[t]['owner']['fields']) for t, m in ROWS.items()),
      'registry: 4 scaled root-table rows (mode, row stock 1, a stock per field)')
module = registry['modules'][KEY]
tables = module['root_tables']
# Upvalue view per prototype: the registry hook (prototype, upvalue, path). A path hook captures the outermost container.
views = {}
for tid, table in tables.items():
    holder = tid
    if table['containers']:
        outer = table['containers'][-1]
        holder = f'root:i{outer["instruction"]}:R{outer["register"]}'
    for hook in table['hooks']:
        views.setdefault(hook['prototype'], {})[hook['upvalue']] = holder
hooked = sorted({p for t in tables.values() for p in t['minimal_hooks']['prototypes']})
check(set(views) >= set(hooked), 'every hooked prototype has registry capture evidence for its upvalue view')

harness = r'''
local emit = print
print = function() end   -- the addon prints only for entry rows; keep the output clean
local failures, passes = 0, 0
local function ok(condition, name)
    if condition then passes = passes + 1 emit("PASS\t" .. name) else failures = failures + 1 emit("FAIL\t" .. name) end
end
local function near(a, b) return type(a) == "number" and math.abs(a - b) < 1e-9 end
local function same(list, want)
    if #list ~= #want then return false end
    for i = 1, #want do if not near(list[i], want[i]) then return false end end
    return true
end

-- ZarimanCorruptionMission root tables, as the root builds them per instance (readable L73-269).
local function fresh()
    local cfg18 = { depositRadius = 10, depositPctPerSecond = { 0.12, 0.09, 0.08, 0.07 }, numForFullVoidIntensity = 24,
        spawnDelay = { 10, 40, 60 }, xpAmount = 500, xpDivisor = 5, xpMultCap = 2, drainPercent = 0.08, drainInterval = 10,
        capacity = { 125, 250, 300, 350 } }
    local cfg34 = { smallAmt = 5, mediumAmt = 20, largeAmt = 60, SgBaseAmt = 100, SgLargeAmt = 75, SgMediumAmt = 50,
        SgSmallAmt = 25, groupSpawnRange = { 75, 80, 85, 90 }, groupSpawnInterval = { 16, 14, 12, 10 }, groupSpawnPerInterval = 4,
        largeRespawnTime = 75, lowEnemyRate = 0.35, highEnemyRate = 0.3, lowEnemyScale = 10, highEnemyScale = 25 }
    local cfg45 = { timeToFillMax = 200, curveScaleV = 0.92, timeToFillMin = 60, endTimer = {} }
    local cfg168 = { maxFractureActive = 3, fractureRadius = 4, playerCapacity = 100, fractureCapacity = { 200, 300, 500, 600 },
        curseCountNormal = 2, curseCountSteelPath = 4, escalationLevel = 0, sDepositCompleteTimer = 1 }
    local byId = { ["root:i25:R3"] = cfg18, ["root:i26:R4"] = cfg18.depositPctPerSecond, ["root:i39:R4"] = cfg18.capacity,
        ["root:i47:R5"] = cfg34, ["root:i62:R6"] = cfg45, ["root:i193:R88"] = cfg168 }
    return { cfg18 = cfg18, cfg34 = cfg34, cfg45 = cfg45, cfg168 = cfg168, byId = byId }
end
local function view(inst, prototype)
    local up = {}
    for upvalue, id in pairs(VIEWS[prototype] or {}) do up[upvalue] = inst.byId[id] end
    return up
end
-- One mission frame of the runtime: every hooked prototype of the target is entered once (Lua CALL or R13 native entry).
local function run_hooks(target, inst)
    local signals = {}
    for _, prototype in ipairs(HOOKED) do
        local hook = target.hooks.luaCalls[prototype]
        if hook ~= nil then
            local r1, r2 = hook.before(prototype, {}, view(inst, prototype), nil, {})
            signals[#signals + 1] = { prototype = prototype, r1 = r1, r2 = r2 }
        end
    end
    return signals
end
local function all_retire(signals, also_all)
    for _, s in ipairs(signals) do
        if s.r1 ~= "RENOVICE_RETIRE" or ((also_all == true) ~= (s.r2 == "RENOVICE_RETIRE_ALL")) then return false end
    end
    return #signals > 0
end
local function settings(values)
    local s = {}
    for id, v in pairs(values) do s[id] = { enabled = true, value = v, stock = 1 } end
    return { settings = s }
end
local function stock_state(inst)
    return same(inst.cfg18.depositPctPerSecond, { 0.12, 0.09, 0.08, 0.07 }) and same(inst.cfg18.capacity, { 125, 250, 300, 350 })
        and inst.cfg34.smallAmt == 5 and inst.cfg34.mediumAmt == 20 and inst.cfg34.largeAmt == 60 and inst.cfg18.drainPercent == 0.08
        and inst.cfg18.drainInterval == 10 and inst.cfg18.depositRadius == 10 and inst.cfg34.SgBaseAmt == 100
        and inst.cfg45.timeToFillMax == 200 and inst.cfg168.playerCapacity == 100 and same(inst.cfg168.fractureCapacity, { 200, 300, 500, 600 })
end
local function scaled_state(inst, deposit, capacity, small, medium, large, drain)
    return same(inst.cfg18.depositPctPerSecond, deposit) and same(inst.cfg18.capacity, capacity) and near(inst.cfg34.smallAmt, small)
        and near(inst.cfg34.mediumAmt, medium) and near(inst.cfg34.largeAmt, large) and near(inst.cfg18.drainPercent, drain)
        -- fields the rows do not own stay stock
        and inst.cfg18.drainInterval == 10 and inst.cfg18.depositRadius == 10 and inst.cfg34.SgBaseAmt == 100
        and inst.cfg45.timeToFillMax == 200 and inst.cfg168.playerCapacity == 100 and same(inst.cfg168.fractureCapacity, { 200, 300, 500, 600 })
end

local VALUES = { ["void_flood.deposit_speed_scale"] = 2, ["void_flood.tank_capacity_scale"] = 1.5,
    ["void_flood.orb_value_scale"] = 0.5, ["void_flood.drain_speed_scale"] = 0 }
local DEPOSIT2, CAPACITY15 = { 0.24, 0.18, 0.16, 0.14 }, { 188, 375, 450, 525 }

-- (a) one instance: scaled once, R3 retire.
local addon = ADDON_MODULE()
local target = addon.targets[KEY]
ok(target ~= nil and target.hooks ~= nil and target.hooks.luaCalls ~= nil, "target " .. KEY .. " declares luaCalls hooks")
for _, prototype in ipairs(HOOKED) do ok(target.hooks.luaCalls[prototype] ~= nil, "hook declared for prototype " .. prototype) end
local a = fresh()
ok(#run_hooks(target, a) > 0 and stock_state(a), "inactive (before activate): hooks write nothing")
target.activate(settings(VALUES))
local signals = run_hooks(target, a)
ok(scaled_state(a, DEPOSIT2, CAPACITY15, 2.5, 10, 30, 0), "deposit rate x2, capacity x1.5 (rounded: 188/375/450/525), orbs x0.5, drain x0 written")
ok(all_retire(signals, false), "every hooked prototype returns the R3 retire signal (no retire-all: values are enabled)")
-- (b) no compounding within the instance.
run_hooks(target, a)
run_hooks(target, a)
ok(scaled_state(a, DEPOSIT2, CAPACITY15, 2.5, 10, 30, 0), "calling every hook again does not compound")
target.activate(settings(VALUES))
run_hooks(target, a)
ok(scaled_state(a, DEPOSIT2, CAPACITY15, 2.5, 10, 30, 0), "re-activating without cleanup does not compound")
-- (c) a second instance (next mission) is written from the registered stock.
local b = fresh()
run_hooks(target, b)
ok(scaled_state(b, DEPOSIT2, CAPACITY15, 2.5, 10, 30, 0) and scaled_state(a, DEPOSIT2, CAPACITY15, 2.5, 10, 30, 0),
   "a second instance is scaled once; the first keeps its numbers")
-- (d) cleanup restores every instance.
target.cleanup()
ok(stock_state(a) and stock_state(b), "cleanup restores every written field in every instance")
run_hooks(target, a)
ok(stock_state(a), "after cleanup the hooks write nothing")
-- (e) a new generation (F9 / SCRIPT SETTINGS close) writes from stock, never from the old number.
target.activate(settings({ ["void_flood.deposit_speed_scale"] = 3 }))
local only = run_hooks(target, a)
ok(same(a.cfg18.depositPctPerSecond, { 0.36, 0.27, 0.24, 0.21 }) and same(a.cfg18.capacity, { 125, 250, 300, 350 }) and a.cfg34.smallAmt == 5,
   "new generation: deposit x3 = 0.36/0.27/0.24/0.21 from stock (not x6); other rows stay stock")
local idle, settled = 0, 0
for _, s in ipairs(only) do
    if s.r1 == "RENOVICE_RETIRE" then settled = settled + 1 end
end
ok(settled == #only and #only > 0, "with one row enabled every hook still retires (idle hooks at once, the deposit hook after its write)")
target.cleanup()
ok(stock_state(a), "second cleanup restores the stock deposit rates")
-- (f) values at their default: nothing written, R4 retire-all.
target.activate({ settings = {} })
local c = fresh()
ok(all_retire(run_hooks(target, c), true) and stock_state(c), "no enabled value: nothing written and every hook returns retire-all (R4)")
target.cleanup()
-- (g) drift: another writer changed a field first -> that table is left alone.
target.activate(settings({ ["void_flood.tank_capacity_scale"] = 2 }))
local d = fresh()
d.cfg18.capacity[1] = 999
local errors = 0
for _, prototype in ipairs(HOOKED) do
    local hook = target.hooks.luaCalls[prototype]
    local good = pcall(hook.before, prototype, {}, view(d, prototype), nil, {})
    if not good then errors = errors + 1 end
end
ok(errors == 1 and same(d.cfg18.capacity, { 999, 250, 300, 350 }), "a drifted capacity table is reported once and left unchanged")
target.cleanup()
-- (h) scale_count keeps at least 1; a fractional multiplier rounds half up.
target.activate(settings({ ["void_flood.tank_capacity_scale"] = 0.003 }))
local e = fresh()
run_hooks(target, e)
ok(same(e.cfg18.capacity, { 1, 1, 1, 1 }), "capacity x0.003 rounds to at least 1 per tank")
target.cleanup()
target.activate(settings({ ["void_flood.tank_capacity_scale"] = 0.05 }))
local f = fresh()
run_hooks(target, f)
ok(same(f.cfg18.capacity, { 6, 13, 15, 18 }), "capacity x0.05: 6/13/15/18 (6.25, 12.5 -> 13, 15, 17.5 -> 18)")
target.cleanup()

-- (i) gameplay rules transcribed from the readable decompile, run on tables the addon wrote.
-- Deposit (prototype 48 L9618-9662): per frame amount = min(capacity x pct[players] x dt, carried, capacity - deposited).
local function fill_seconds(inst, players, carried)
    local capacity = inst.cfg18.capacity[players]
    local pct = inst.cfg18.depositPctPerSecond[players]
    local deposited, t, dt = 0, 0, 1 / 60
    while deposited < capacity and t < 1000 do
        local amount = math.min(capacity * pct * dt, carried, capacity - deposited)
        if amount <= 0 then break end
        carried = carried - amount
        deposited = deposited + amount
        if capacity - 1 < deposited then deposited = capacity end   -- L9762-9775 snap to full
        t = t + dt
    end
    return t, deposited >= capacity
end
-- Expected: the tank snaps to full one unit early, so t = (capacity - 1) / (capacity x pct), within two frames.
local function about(t, capacity, pct) return math.abs(t - (capacity - 1) / (capacity * pct)) < 2 / 60 end
local g = fresh()
local solo, full = fill_seconds(g, 1, 1000)
local squad = fill_seconds(g, 4, 1000)
ok(full and about(solo, 125, 0.12) and about(squad, 350, 0.07), "stock: one player fills an empty tank in about 8.3 s solo, 14.2 s in a squad")
target.activate(settings({ ["void_flood.deposit_speed_scale"] = 2 }))
run_hooks(target, g)
ok(about(fill_seconds(g, 1, 1000), 125, 0.24), "Tank fill speed x2: about 4.1 s solo (twice as fast)")
target.cleanup()
local h = fresh()
target.activate(settings({ ["void_flood.tank_capacity_scale"] = 2 }))
run_hooks(target, h)
local t2, full2 = fill_seconds(h, 1, 1000)
-- Carry cap (prototype 43 L8586-8604, normal mode): _T.PlayerEnergyCap = capacity[#players].
ok(full2 and about(t2, 250, 0.12) and math.abs(t2 - solo) < 0.1 and h.cfg18.capacity[1] == 250,
   "Tank capacity x2: a tank needs 250 energy (also the carry cap); the standing time stays about 8.3 s")
local _, partial = fill_seconds(h, 1, 125)
ok(not partial, "Tank capacity x2: 125 carried energy fills half a tank")
target.cleanup()
-- Drain (prototype 41 L7724-7840): under the Decaying curse, nobody near, every drainInterval: deposited -= drainPercent x capacity.
local function drained(inst, seconds)
    local capacity, deposited, timer, dt = inst.cfg18.capacity[1], 100, inst.cfg18.drainInterval - 3, 1 / 60
    for _ = 1, math.floor(seconds / dt + 0.5) do
        if inst.cfg18.drainInterval <= timer then
            deposited = math.max(deposited - inst.cfg18.drainPercent * capacity, 0)
            timer = 0
        else
            timer = timer + dt
        end
    end
    return deposited
end
local k = fresh()
ok(math.abs(drained(k, 14) - 80) < 1e-6, "stock drain: 100/125 loses 10 after 3 s and 10 more after 13 s")
target.activate(settings({ ["void_flood.drain_speed_scale"] = 0 }))
run_hooks(target, k)
ok(drained(k, 60) == 100, "Tank drain speed x0: no drain")
target.cleanup()
-- Orb value (prototype 68 L13336-13346): _T.VoidPickupAmt = { smallAmt, mediumAmt, largeAmt } at mission start.
local m = fresh()
target.activate(settings({ ["void_flood.orb_value_scale"] = 1.5 }))
run_hooks(target, m)
local pickup = { m.cfg34.smallAmt, m.cfg34.mediumAmt, m.cfg34.largeAmt }
ok(same(pickup, { 7.5, 30, 90 }), "Void orb value x1.5: VoidPickupAmt = 7.5/30/90")
target.cleanup()
ok(stock_state(m), "orb values restored")
-- (j) R20 (2026-10-02): every row at its minimum (MINIMUMS: the registry minimums, 0.001 unless the R20 input records a floor).
ok(MINIMUMS["void_flood.deposit_speed_scale"] == 0.001 and MINIMUMS["void_flood.tank_capacity_scale"] == 0.001
    and MINIMUMS["void_flood.orb_value_scale"] == 0.06 and MINIMUMS["void_flood.drain_speed_scale"] == 0,
    "R20 minimums: fill speed 0.001, capacity 0.001, orb value 0.06 (floor), drain 0")
local q = fresh()
target.activate(settings({ ["void_flood.tank_capacity_scale"] = MINIMUMS["void_flood.tank_capacity_scale"] }))
run_hooks(target, q)
local tq, fullq = fill_seconds(q, 1, 1000)
ok(same(q.cfg18.capacity, { 1, 1, 1, 1 }) and fullq and tq <= 1 / 60 + 1e-9,
    "R20 capacity x0.001: every tank needs 1 (at least 1) and one frame at the tank fills it (snap at capacity - 1)")
target.cleanup()
local r = fresh()
target.activate(settings({ ["void_flood.deposit_speed_scale"] = MINIMUMS["void_flood.deposit_speed_scale"] }))
run_hooks(target, r)
local tr, fullr = fill_seconds(r, 1, 1000)
local depositedr = 125 * r.cfg18.depositPctPerSecond[1] * tr
ok(same(r.cfg18.depositPctPerSecond, { 0.00012, 0.00009, 0.00008, 0.00007 }) and not fullr and math.abs(depositedr - 15) < 0.1,
    "R20 fill speed x0.001: 0.00012/0.00009/0.00008/0.00007; a solo tank gains about 15 of 125 in 1000 s (no stall, about 2.3 h to fill)")
target.cleanup()
-- Downed-player drop (prototype 28 L4404-4425): floor(E/2 / mediumAmt) + ceil((E/2 % mediumAmt) / smallAmt) orbs in one loop,
-- E at most the squad capacity 350; the game keeps at most 150 pickups active (prototype 33 L5655, L5744).
local function drop_count(inst, carried)
    local half = carried * 0.5
    return math.floor(half / inst.cfg34.mediumAmt) + math.ceil((half % inst.cfg34.mediumAmt) / inst.cfg34.smallAmt)
end
local s = fresh()
ok(drop_count(s, 350) == 11, "stock: a downed squad player with 350 energy drops 11 orbs (8 medium, 3 small)")
target.activate(settings({ ["void_flood.orb_value_scale"] = MINIMUMS["void_flood.orb_value_scale"] }))
run_hooks(target, s)
ok(near(s.cfg34.smallAmt, 0.3) and near(s.cfg34.mediumAmt, 1.2) and near(s.cfg34.largeAmt, 3.6) and drop_count(s, 350) <= 150,
    "R20 orb value x0.06 (the floor): 0.3/1.2/3.6 and the largest downed drop is " .. drop_count(s, 350) .. " orbs (at most 150)")
target.cleanup()
local u = fresh()
target.activate(settings({ ["void_flood.orb_value_scale"] = 0.05 }))
run_hooks(target, u)
ok(drop_count(u, 350) > 150, "R20 control: orb value x0.05 lets one downed drop reach " .. drop_count(u, 350) .. " orbs (over 150)")
target.cleanup()
emit(failures == 0 and ("VOID FLOOD TANK HARNESS PASS checks=" .. passes) or "VOID FLOOD TANK HARNESS FAIL")
'''

script = WORK / 'void_flood_tank_harness.luau'
script.write_text('ADDON_MODULE = function(...)\n' + source + '\nend\n' + f'KEY = {lua(KEY)}\nHOOKED = {lua(hooked)}\n'
                  + 'VIEWS = ' + lua({p: views[p] for p in sorted(views)}) + '\n'
                  + 'MINIMUMS = ' + lua({tid: rows[tid]['limits']['minimum'] for tid in ROWS}) + '\n' + harness, encoding='utf-8')
check(LUAU.is_file(), 'toolchain luau.exe present')
run = subprocess.run([str(LUAU), str(script)], capture_output=True, text=True)
lines = run.stdout.splitlines()
for line in lines:
    print('HARNESS\t' + line)
if run.stderr.strip():
    print('HARNESS-STDERR\t' + run.stderr.strip())
check(run.returncode == 0 and any(l.startswith('VOID FLOOD TANK HARNESS PASS') for l in lines) and not any(l.startswith('FAIL') for l in lines),
      f'harness: {sum(l.startswith("PASS") for l in lines)} checks (generated addon, hooked prototypes {hooked})')

# 5. R5-C: the R8 Void Flood live literal and the scaled fields share the module without overlapping bytes.
literals = json.loads((package / 'literals.json').read_text(encoding='utf-8'))
stock = bytearray((ROOT / registry['corpus'] / module['file']).read_bytes())
sites = [s for v in literals['values'].values() if v['module'] == KEY for drive in v['drives'] for s in drive['sites']]
spans = [(f['value_offset'], 8 if f['value_kind'] == 'number_constant' else 4) for r in rows.values() for f in r['owner']['fields']]
overlap = [(s['offset'], o) for s in sites for o, w in spans if s['offset'] < o + w and o < s['offset'] + 4]
check(len(sites) >= 3 and not overlap, f'R5-C: {len(sites)} recipe sites of the Void Flood module and {len(spans)} scaled-field initialisers do not overlap')
patched = bytearray(stock)
for s in sites:
    if s['offset'] == 102969:   # fractures per round, normal: LOADN 3 -> 4 (the installed recipe value)
        patched[s['offset'] + 2:s['offset'] + 4] = (4).to_bytes(2, 'little', signed=True)
check(patched != stock and all(list(patched[f['value_offset']:f['value_offset'] + (8 if f['value_kind'] == 'number_constant' else 4)]) == f['expected']
                                for r in rows.values() for f in r['owner']['fields']),
      'R5-C: the module synthesized with fractures per round 4 still encodes every scaled-field stock (the addon stock check holds)')

OUT.mkdir(parents=True, exist_ok=True)
(OUT / 'void_flood_tank_harness.json').write_text(json.dumps(results, indent=2) + '\n', encoding='utf-8')
print('VOID FLOOD TANK HARNESS GATE PASS')
