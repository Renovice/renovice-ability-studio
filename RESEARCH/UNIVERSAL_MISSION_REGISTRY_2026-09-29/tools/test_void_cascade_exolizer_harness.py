"""Void Cascade exolizer progress speed and reward interval: offline gate (contract R22, 2026-10-02).

Record: RESEARCH/MISSIONS_R22_EXOLIZER_PROGRESS_2026-10-02/README.md; research
work/research/void-cascade-exolizer-progress-2026-10-02/README.md.

What it proves (offline):
  1. The pinned full-package build input builds the pinned R22 package (addon, package.json, literals.json);
     engine_params.json is the R21 file (nothing here reaches the engine writer).
  2. Registry: the master void_cascade.exolizer_speed is an inverse drive (row = 90 / master) of the one addon row that owns
     PILLAR_DURATION and PILLAR_DURATION_CIRCLE (float, x1, 0.006 to 90, addon lane, applies at the next read); the row
     void_cascade.reward_interval is a live literal (one LOADN site, P97 i80, offset 88710, 4 -> N).
  3. Owner order (the R19 lesson for this lane): every prototype that reads PILLAR_DURATION or PILLAR_DURATION_CIRCLE is
     one of the hooked prototypes of that root table, so the hook writes the live table before any read; REWARD_INTERVAL
     is read only by the module root (copied into a root local at load, P97 i237), which only a literal can reach.
  4. The real generated addon in plain Luau (activate -> luaCalls[P].before -> cleanup) on the simulated root tables:
     master x2 / x0.5 / x3 / x7 / minimum / maximum write 90 / value into both fields; an enabled "Exolizer defense time"
     wins; a disabled or stock-mismatched master writes nothing (R4 retire-all); no compounding across re-entry,
     re-activation and a new generation; cleanup restores; a non-positive master value (never delivered by the validated
     settings path) leaves the row at stock.
  5. Progress replay: the 44.0.2 exolizer rules transcribed from the readable decompile, reading the table the addon wrote:
     TimerMgr (U44 render: Delta += dt, expires at Duration <= Delta, time left = Duration - Delta), spawn P46
     (AddTimer(PILLAR_DURATION or _CIRCLE), net var = duration), corruption P38 (RemoveTimer; the net var keeps the floored
     time left), cleanse P42 (AddTimer(net var)), host update P79 (marker progress time left / duration; expiry calls P45:
     exolizers used + 1, state EMPTY, 240 s slot cooldown), reward P28 (tiers = floor(used / interval)). Checked: the run
     time follows 90 / speed in normal and Circuit mode, the marker progress, a corruption pause, the row-wins case, and
     the reward cadence with the game's arrival rule (one corrupted exolizer every 30 s below the active cap).
  6. Float32 floor of the master minimum: the TimerMgr sum stays below 16384 at 0.006 (moves up to 2048 fps); at 0.005
     the sum crosses 16384 and stops moving above 1024 fps (why 0.006 and not 0.005 or 0.001).
  7. Live literal: the generator synthesizes the module from the recipe for N = 1, 2, 10; exactly the immediate bytes of
     the one site change, the readable render (pinned derecomp) shows REWARD_INTERVAL = N, and every addon-owned field
     initialiser of the same module still encodes its stock (R5-C: the addon stock check holds on the synthesized module).
Limits: the DE VM does not run here (plain Luau doubles; the float32 statement is struct-packed arithmetic); the arrival
cadence model fixes the active cap, slot count and cleanse time (the real ones depend on difficulty, players and play);
nothing is live.

Paths: CLI = RENOVICE_EDITOR_CLI or work/builds/ability-editor/current; luau.exe and derecomp.exe from the DE Luau toolchain.
Writes only to work/temp/void-cascade-exolizer-harness and this tool's test-results folder. Reads no game or server folder.
"""
from pathlib import Path
import hashlib, json, os, runpy, shutil, struct, subprocess, sys

HERE = Path(__file__).resolve().parent
EDITOR = Path(__file__).resolve().parents[3]
ROOT = EDITOR
while not (ROOT / 'WORKSPACE.json').exists():
    ROOT = ROOT.parent
sys.path.insert(0, str(HERE))
from deluau import Module  # noqa: E402

CLI = Path(os.environ.get('RENOVICE_EDITOR_CLI', ROOT / 'work/builds/ability-editor/current/bin/renovice_ability_editor_cli.exe'))
LUAU = ROOT / 'repos/toolchains/de-luau-toolchain/bin/luau.exe'
DERECOMP = ROOT / 'repos/toolchains/de-luau-toolchain/bin/derecomp.exe'
SDK = ROOT / 'shared/semantic-sdk/symbols.tsv'
NORMALIZE = runpy.run_path(str(EDITOR / 'RESEARCH/U44_AUTHORING_2026-09-27/scripts/inspect_current.py'))['normalize']
INPUT = EDITOR / 'RESEARCH/MISSIONS_R13_NATIVE_ENTRY_2026-10-01/inputs/rebuild_input.r12.json'
INPUT_LF_SHA = 'dccde5fddf2649c2be4c93789cecab4cc1d1759dc9d01d0117cba25f5a7ca4b6'
PINS = {'Missions.targets.addon.lua_B': 'a943cd3e5ca053368fd3604cd96d6cbde768090f283ac2ee33db60d0f1ad9340',
        'package.json': 'fd89dacae8cfd9cec10af9c06af22dcd2835a6e8c88a2842206fdb8c3904eda0',
        'literals.json': '9beaa4385ee3efe39daf0f3788bcf19b41aa500af1cd7705b03e3ab4df0392e8',
        'engine_params.json': '20323777391827278dea4494f6f123ac0ba2846cf2b65f4a886c4eaed61e1bad'}  # R21, unchanged
KEY = '32c344afa33be174'
STOCK_SHA = '15ce88bf63c0a721bc978997ad7e7fba39ea4fadee00da8ce5d66e2df6319d50'
MASTER, ROW, REWARD, ALERT = 'void_cascade.exolizer_speed', 'void_cascade.pillar_duration', 'void_cascade.reward_interval', \
    'void_cascade.alert_reward_interval'
TABLE = 'root:i16:R5'
WORK = ROOT / 'work/temp/void-cascade-exolizer-harness'
OUT = HERE.parent / 'test-results'
results = {'checks': []}


def check(ok, name):
    results['checks'].append({'name': name, 'pass': bool(ok)})
    print(('PASS' if ok else 'FAIL') + '\t' + name)
    if not ok:
        OUT.mkdir(parents=True, exist_ok=True)
        (OUT / 'void_cascade_exolizer_harness.json').write_text(json.dumps(results, indent=2) + '\n', encoding='utf-8')
        sys.exit(1)


def sha(data):
    return hashlib.sha256(data).hexdigest()


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


def build(values, tag):
    spec = json.loads(INPUT.read_text(encoding='utf-8'))
    if values is not None:
        spec = {'format': 'RENOVICE_MISSION_SETTINGS_V1', 'build': '2026.09.28.13.06', 'values': values,
                'allow_unproven_hook_bindings': ['renovice.target.lua_call'], 'output_layout': 'package',
                'package_scope': 'all_addon_values', 'literal_mode': 'recipe', 'literal_scope': 'headline'}
    path = WORK / f'input_{tag}.json'
    path.write_text(json.dumps(spec, indent=2) + '\n', encoding='utf-8')
    run = subprocess.run([str(CLI), 'build-missions', str(path), '--staging', str(WORK / f'build_{tag}'), '--editor-root', str(EDITOR)],
                         capture_output=True, text=True)
    generations = list((WORK / f'build_{tag}').glob('missions/*/MISSION_SET_MANIFEST.json'))
    return run, (generations[0].parent if len(generations) == 1 else None)


# 1. Build the pinned input.
check(hashlib.sha256(INPUT.read_bytes().replace(b'\r\n', b'\n')).hexdigest() == INPUT_LF_SHA, 'pinned full-package build input (LF content)')
shutil.rmtree(WORK, ignore_errors=True)
WORK.mkdir(parents=True)
run, generation = build(None, 'pinned')
check(run.returncode == 0 and generation is not None, 'full package build succeeds')
package = generation / 'Packages/Missions'
for name, digest in PINS.items():
    got = sha((package / name).read_bytes())
    check(got == digest, f'{name} is the pinned R22 build ({digest[:8]}; got {got[:8]})')
source = (generation / 'source/Missions.targets.addon.luau').read_text(encoding='utf-8')
declared = json.loads((package / 'package.json').read_text(encoding='utf-8'))['members']['Missions.targets.addon.lua_B']['settings']['values']
literals = json.loads((package / 'literals.json').read_text(encoding='utf-8'))
d = declared.get(MASTER, {})
check(d.get('type') == 'float' and d.get('unit') == 'x' and d.get('stock') == 1 and d.get('min') == 0.006 and d.get('max') == 90
      and d.get('lane') == 'addon' and d.get('applies') == 'live_next_read' and d.get('quick_on_page') is True
      and d.get('path') == ['Void Cascade'] and d.get('quick') == 'Void Cascade: exolizer progress speed'
      and 'minimum' in d.get('scope', '').lower(),
      'package.json declares "Exolizer progress speed" (float x1, 0.006 to 90, addon, live, "All Void Cascade missions" + Quick)')
check(declared.get(ROW, {}).get('path') == ['Void Cascade', 'Timers'] and 'quick' not in declared.get(ROW, {}),
      '"Exolizer defense time" stays a declared row (Void Cascade > Timers), no longer the Quick entry')
lv = literals['values'].get(REWARD, {})
sites = [s for drive in lv.get('drives', []) for s in drive['sites']]
check(lv.get('module') == KEY and lv['declaration']['type'] == 'int' and lv['declaration']['stock'] == 4
      and lv['declaration']['min'] == 1 and lv['declaration']['applies'] == 'next_mission'
      and sites == [{'kind': 'loadn', 'offset': 88710, 'expected': '08060400', 'register': 6, 'numerator': 1, 'denominator': 1}],
      'literals.json declares "Exolizers per reward" (int 4, from 1, next mission) with the one LOADN site 88710 (08 06 04 00)')
check(source.count('["void_cascade.pillar_duration"] = { master = "void_cascade.exolizer_speed", scale = 90, inverse = true }') == 1
      and 'value = drive.scale / chosen[drive.master]' in source,
      'the addon compiles the inverse drive (row = 90 / master) in the Void Cascade target')

# 2. Registry.
registry = json.loads((EDITOR / 'REGISTRIES/mission_build_u44.json').read_text(encoding='utf-8'))
rows = {r['tunable_id']: r for r in registry['tunables']}
master = registry['ui_masters'][MASTER]
check(master['drives'] == [{'tunable_id': ROW, 'scale': 90, 'inverse': True}] and master['type'] == 'float' and master['stock'] == 1
      and master['min'] == 0.006 and master['max'] == 90 and master['lane'] == 'addon' and master['body_key'] == KEY,
      'registry master: one inverse drive of the exolizer duration row (scale 90 = the stock seconds), float, 0.006 to 90')
row = rows[ROW]
check([f['field'] for f in row['owner']['fields']] == ['PILLAR_DURATION', 'PILLAR_DURATION_CIRCLE'] and row['stock'] == 90
      and row['owner']['template'] == 'ROOT_TABLE_FIELD' and all(f['table_id'] == TABLE for f in row['owner']['fields']),
      'the driven row owns PILLAR_DURATION and PILLAR_DURATION_CIRCLE (root table root:i16:R5, stock 90)')
reward = rows[REWARD]
check(reward['backend'] == 'EXACT_LITERAL' and reward['applies'] == 'next_mission' and reward['stock'] == 4
      and reward['limits']['minimum'] == 1 and reward['limits']['integer'] is True and reward['phase1_tunable_id'] == REWARD
      and [(s['prototype'], s['instruction'], s['offset'], s['expected']) for s in reward['owner']['sites']] == [(97, 80, 88710, [8, 6, 4, 0])]
      and not any(e['tunable_id'] == REWARD for e in registry['excluded']),
      'registry row void_cascade.reward_interval: live literal P97 i80 (offset 88710), 1..32767; the Phase 1 exclusion is resolved')
module = registry['modules'][KEY]
table = module['root_tables'][TABLE]
hooked = sorted(table['minimal_hooks']['prototypes'])

# 3. Owner order from the stock bytes.
stock = (ROOT / registry['corpus'] / module['file']).read_bytes()
check(sha(stock) == STOCK_SHA, 'stock ZarimanSurvivalMission 44.0.2 (SHA-256 15ce88bf...)')
m = Module(stock)


def uses(key):
    out = {}
    for p, (ins, _) in enumerate(m.protos):
        for i, (_, w) in enumerate(ins):
            if m.key_string(p, w) == key:
                out.setdefault(p, []).append((i, w[0]))
    return out


GETTABLEKS, SETTABLEKS = 0x3d, 0x15
for key in ('PILLAR_DURATION', 'PILLAR_DURATION_CIRCLE'):
    found = uses(key)
    readers = sorted(p for p, items in found.items() if any(op == GETTABLEKS for _, op in items))
    writers = [(p, i) for p, items in found.items() for i, op in items if op == SETTABLEKS]
    check(writers == [(97, {'PILLAR_DURATION': 57, 'PILLAR_DURATION_CIRCLE': 141}[key])] and readers and set(readers) <= set(hooked),
          f'{key}: written once by the root, read by prototypes {readers}, every one a hooked prototype {hooked} (the hook binds '
          'the live table before the read)')
found = uses('REWARD_INTERVAL')
check(found == {97: [(81, SETTABLEKS), (237, GETTABLEKS)]},
      'REWARD_INTERVAL: only the root uses it (i81 write, i237 read into the root local that the reward check reads); the '
      'root-table addon lane cannot reach a read at module load, the live literal can')
check(m.field_literal_sites(97, 'REWARD_INTERVAL', 4) == [(80, 88710, 6)], 'REWARD_INTERVAL = 4 is LOADN R6 at P97 i80, offset 88710')

# 4 + 5. The real addon and the progress replay in Luau.
views = {}
for hook in table['hooks']:
    views.setdefault(hook['prototype'], {})[hook['upvalue']] = 'R5'
circle = module['root_tables']['root:i144:R6']
for hook in circle['hooks']:
    if hook['path']:
        views.setdefault(hook['prototype'], {}).setdefault(hook['upvalue'], 'R5')
all_hooked = sorted(set(hooked) | set(circle['minimal_hooks']['prototypes']))

harness = r'''
local emit = print
print = function() end
local failures, passes = 0, 0
local function ok(condition, name)
    if condition then passes = passes + 1 emit("PASS\t" .. name) else failures = failures + 1 emit("FAIL\t" .. name) end
end
local function near(a, b, eps) return type(a) == "number" and math.abs(a - b) < (eps or 1e-9) end

-- ZarimanSurvivalMission root table frame_97[15] (readable L49-146), as the root builds it per mission instance.
local function fresh()
    local r5 = { INITIAL_SPAWN_TIME = 20, REALITY_RATE = 0.5, MAX_DIFFICULTY = 3, PILLAR_INVUL_COOLDOWN = 15,
        PILLAR_DURATION = 90, DIFFICULTY_INTERVAL = 4, PILLAR_COOLDOWN = 240, CORRUPTED_PILLAR_FREQUENCY = 30,
        REWARD_INTERVAL = 4, ALERT_REWARD_INTERVAL = 10, POSITIVE_REALITY_RATE_CIRCLE = 0.25, NEGATIVE_REALITY_RATE_CIRCLE = 1,
        PILLAR_DURATION_CIRCLE = 90, MAX_PILLARS_CIRCLE = { 1, 1, 1, 1 } }
    return r5
end
local function view(r5, prototype)
    local up = {}
    for upvalue, _ in pairs(VIEWS[prototype] or {}) do up[upvalue] = r5 end
    return up
end
local function run_hooks(target, r5)
    local signals = {}
    for _, prototype in ipairs(HOOKED) do
        local hook = target.hooks.luaCalls[prototype]
        if hook ~= nil then
            local a, b = hook.before(prototype, {}, view(r5, prototype), nil, {})
            signals[#signals + 1] = { a = a, b = b }
        end
    end
    return signals
end
local function retire_all(signals)
    for _, s in ipairs(signals) do if s.a ~= "RENOVICE_RETIRE" or s.b ~= "RENOVICE_RETIRE_ALL" then return false end end
    return #signals > 0
end
local function speed(value, extra)
    local s = { [MASTER] = { enabled = true, value = value, stock = 1 } }
    for id, entry in pairs(extra or {}) do s[id] = entry end
    return { settings = s }
end
local function durations(r5) return r5.PILLAR_DURATION, r5.PILLAR_DURATION_CIRCLE end
local function stock_state(r5)
    return r5.PILLAR_DURATION == 90 and r5.PILLAR_DURATION_CIRCLE == 90 and r5.ALERT_REWARD_INTERVAL == 10
        and r5.REWARD_INTERVAL == 4 and r5.PILLAR_COOLDOWN == 240 and r5.CORRUPTED_PILLAR_FREQUENCY == 30
end

local addon = ADDON_MODULE()
local target = addon.targets[KEY]
ok(target ~= nil, "target " .. KEY .. " (ZarimanSurvivalMission) is declared")
for _, prototype in ipairs(HOOKED) do ok(target.hooks.luaCalls[prototype] ~= nil, "hook declared for prototype " .. prototype) end

-- (a) master values: both duration fields = 90 / value; nothing else changes.
for _, case in ipairs({ { 2, 45 }, { 0.5, 180 }, { 3, 30 }, { 7, 90 / 7 }, { MIN, 90 / MIN }, { MAX, 1 } }) do
    local r5 = fresh()
    target.activate(speed(case[1]))
    local signals = run_hooks(target, r5)
    local d, c = durations(r5)
    local others = r5.ALERT_REWARD_INTERVAL == 10 and r5.REWARD_INTERVAL == 4 and r5.PILLAR_COOLDOWN == 240
    local retired = true
    for _, s in ipairs(signals) do retired = retired and s.a == "RENOVICE_RETIRE" and s.b == nil end
    ok(near(d, case[2]) and near(c, case[2]) and others and retired,
       "progress speed x" .. case[1] .. ": exolizer duration 90 / " .. case[1] .. " = " .. string.format("%.6g", d) ..
       " s in normal and Circuit mode, other fields stock, every hook retires (R3)")
    target.cleanup()
    ok(stock_state(r5), "cleanup restores 90 s after x" .. case[1])
end
-- (b) no compounding; a new generation writes from the stock 90.
local r5 = fresh()
target.activate(speed(2))
run_hooks(target, r5)
run_hooks(target, r5)
target.activate(speed(2))
run_hooks(target, r5)
ok(near(r5.PILLAR_DURATION, 45), "x2: hooks again and re-activation without cleanup keep 45 s (no 22.5)")
local second = fresh()
run_hooks(target, second)
ok(near(second.PILLAR_DURATION, 45) and near(r5.PILLAR_DURATION, 45), "a second mission instance gets 45 s; the first keeps it")
target.cleanup()
ok(stock_state(r5) and stock_state(second), "cleanup restores both instances")
target.activate(speed(3))
run_hooks(target, r5)
ok(near(r5.PILLAR_DURATION, 30), "new generation x3 after x2: 30 s from the stock 90 (not 15)")
target.cleanup()
-- (c) the explicit seconds row wins over the master.
local w = fresh()
target.activate(speed(2, { [ROW] = { enabled = true, value = 60, stock = 90 } }))
run_hooks(target, w)
ok(w.PILLAR_DURATION == 60 and w.PILLAR_DURATION_CIRCLE == 60, "Exolizer defense time 60 s on + speed x2: 60 s (the row wins)")
target.cleanup()
-- (d) inert cases.
for _, case in ipairs({ { "disabled", { settings = { [MASTER] = { enabled = false, value = 2, stock = 1 } } } },
                        { "stock mismatch", { settings = { [MASTER] = { enabled = true, value = 2, stock = 2 } } } },
                        { "no settings for this target", { settings = {} } } }) do
    local z = fresh()
    target.activate(case[2])
    ok(retire_all(run_hooks(target, z)) and stock_state(z), "master " .. case[1] .. ": nothing written, every hook retires all (R4)")
    target.cleanup()
end
for _, bad in ipairs({ 0, -1 }) do
    local z = fresh()
    target.activate(speed(bad))
    run_hooks(target, z)
    ok(stock_state(z), "a master value of " .. bad .. " (never delivered: the settings minimum is " .. MIN .. ") leaves 90 s")
    target.cleanup()
end
local plain = ADDON_MODULE().targets[KEY]
local q = fresh()
plain.activate()
run_hooks(plain, q)
ok(stock_state(q), "without context.settings the stock-compiled master writes nothing")
plain.cleanup()

-- (e) progress replay: 44.0.2 rules on the table the addon wrote.
-- TimerMgr (Lotus.Interface.Libs.TimerMgr, U44 render): AddTimer(d) -> {Delta = 0, Duration = d}; Update(dt): Delta += dt,
-- removed when Duration <= Delta; GetTimeLeft = Duration - Delta (nil once removed).
local function timers()
    local t = { list = {}, n = 0 }
    function t.add(d) t.n = t.n + 1; t.list[t.n] = { Delta = 0, Duration = d }; return t.n end
    function t.update(dt)
        for id, timer in pairs(t.list) do
            timer.Delta = timer.Delta + dt
            if timer.Duration <= timer.Delta then t.list[id] = nil end
        end
    end
    function t.left(id) local timer = id and t.list[id]; if timer == nil then return nil end return timer.Duration - timer.Delta end
    function t.remove(id) if id then t.list[id] = nil end end
    return t
end
-- One exolizer, host side. P46 spawn: timer = AddTimer(isCircle and PILLAR_DURATION_CIRCLE or PILLAR_DURATION), net var =
-- that duration; every new exolizer arrives corrupted (P79 cfg 77 calls P46 then P38: RemoveTimer, state CORRUPTED).
-- P42 cleanse: AddTimer(net var), state SPAWNED. P79 each frame: Update(dt); time left; marker = Clamp(left / duration);
-- net var = floor(left) when lower; SPAWNED with no timer or 0 left -> P45: used + 1, EMPTY, slot cooldown 240 s.
-- `corrupt_at` / `pause`: a Thrax corrupts it again after that many running seconds for that many seconds.
local function exolizer(tab, is_circle, cleanse_after, corrupt_at, pause)
    local t, dt = timers(), 1 / 60
    local duration = is_circle and tab.PILLAR_DURATION_CIRCLE or tab.PILLAR_DURATION
    local timer = t.add(duration)
    local net = duration
    t.remove(timer); timer = nil                      -- P38: arrives corrupted
    local clock, state, ran, half_mark = 0, "CORRUPTED", 0, nil
    local corrupted_until = cleanse_after
    local paused_once = false
    while clock < 100000 do
        clock = clock + dt
        if state == "CORRUPTED" and clock >= corrupted_until then
            timer = t.add(net); state = "SPAWNED"      -- P42 cleanse
        end
        t.update(dt)
        local left = t.left(timer)
        if left ~= nil then
            local progress = math.max(0, math.min(1, left / (is_circle and tab.PILLAR_DURATION_CIRCLE or tab.PILLAR_DURATION)))
            if half_mark == nil and progress <= 0.5 then half_mark = ran end
            if math.floor(left) < net then net = math.floor(left) end
        else
            timer = nil
        end
        if state == "SPAWNED" then
            ran = ran + dt
            if timer == nil or left == 0 then return ran, half_mark, clock end   -- P45: used up
            if corrupt_at and not paused_once and ran >= corrupt_at then
                t.remove(timer); timer = nil; state = "CORRUPTED"; corrupted_until = clock + pause; paused_once = true
            end
        end
    end
    return nil
end
local frame = 1 / 60 + 1e-9
local s0 = fresh()
local base = exolizer(s0, false, 10)
ok(base and math.abs(base - 90) <= frame, "stock: a cleansed exolizer runs " .. string.format("%.3f", base) .. " s (90 s)")
for _, case in ipairs({ { 2, false }, { 0.5, false }, { 4, false }, { 2, true } }) do
    local tab = fresh()
    target.activate(speed(case[1]))
    run_hooks(target, tab)
    local ran, half = exolizer(tab, case[2], 10)
    local want = 90 / case[1]
    ok(ran and math.abs(ran - want) <= frame and half and math.abs(half - want / 2) <= 2 * frame,
       "x" .. case[1] .. (case[2] and " (The Circuit)" or "") .. ": runs " .. string.format("%.3f", ran) .. " s (" ..
       string.format("%.6g", want) .. "), marker at half after " .. string.format("%.3f", half) .. " s")
    target.cleanup()
end
-- A corruption pause keeps the game's rule: the timer stops while corrupted and resumes from the floored time left.
local tab = fresh()
target.activate(speed(2))
run_hooks(target, tab)
local ran, _, clock = exolizer(tab, false, 10, 20.5, 30)
ok(ran and ran <= 45 and ran >= 44 and clock and math.abs(clock - (10 + 30 + ran)) <= 2 * frame,
   "x2 with a 30 s corruption after 20.5 s: " .. string.format("%.3f", ran) .. " s of running (45 s minus the floored 0.5 s), "
   .. "finished at " .. string.format("%.3f", clock) .. " s")
target.cleanup()
local rw = fresh()
target.activate(speed(2, { [ROW] = { enabled = true, value = 60, stock = 90 } }))
run_hooks(target, rw)
local rran = exolizer(rw, false, 10)
ok(rran and math.abs(rran - 60) <= frame, "row 60 s + master x2: the exolizer runs 60 s")
target.cleanup()

-- Reward cadence (P79 cfg 69-78 arrivals, P304 slot choice, P45 used count and slot cooldown, P28 tiers). The game starts a
-- CORRUPTED_PILLAR_FREQUENCY (30 s) countdown whenever running + corrupted exolizers are below the active cap and no
-- countdown runs; at 0 it spawns a corrupted exolizer in an EMPTY slot whose PILLAR_COOLDOWN (240 s) is over (none: nothing
-- spawns). Model inputs (not game data): the cap, the slot count and the time players take to cleanse each arrival.
local function reward_time(tab, n, interval, cap, slots, cleanse)
    local dt, clock, used, countdown = 0.05, 0, 0, nil
    local ready = {}
    for i = 1, slots do ready[i] = 0 end
    local active = {}
    while clock < 20000 do
        clock = clock + dt
        if countdown == nil and #active < cap then countdown = tab.CORRUPTED_PILLAR_FREQUENCY end
        if countdown ~= nil then
            countdown = countdown - dt
            if countdown <= 0 then
                countdown = nil
                for i = 1, slots do
                    if ready[i] ~= nil and ready[i] <= clock then
                        ready[i] = nil
                        active[#active + 1] = { slot = i, done = clock + cleanse + tab.PILLAR_DURATION }
                        break
                    end
                end
            end
        end
        for k = #active, 1, -1 do
            if active[k].done <= clock then
                used = used + 1
                ready[active[k].slot] = clock + tab.PILLAR_COOLDOWN
                table.remove(active, k)
                if math.floor(used / interval) >= n then return clock end
            end
        end
    end
    return nil
end
local times = {}
for _, v in ipairs({ 1, 2, 4, 90 }) do
    local tab2 = fresh()
    if v ~= 1 then target.activate(speed(v)); run_hooks(target, tab2) end
    times[v] = { reward_time(tab2, 1, tab2.REWARD_INTERVAL, 3, 6, 10), reward_time(tab2, 3, tab2.REWARD_INTERVAL, 3, 6, 10) }
    if v ~= 1 then target.cleanup() end
end
ok(times[1][1] and times[2][1] < times[1][1] and times[4][1] < times[2][1] and times[90][1] <= times[4][1],
   string.format("first reward (model: cap 3, 6 slots, cleanse 10 s): x1 %.0f s, x2 %.0f s, x4 %.0f s, x90 %.0f s",
                 times[1][1], times[2][1], times[4][1], times[90][1]))
ok(times[90][1] >= 4 * 30 + 10 + 1 - 0.2,
   "faster exolizers cannot beat the arrivals: the 4th exolizer arrives at 120 s (30 s apart), so even x90 rewards after " ..
   string.format("%.0f", times[90][1]) .. " s")
ok(times[2][2] < times[1][2], string.format("third reward: x1 %.0f s, x2 %.0f s", times[1][2], times[2][2]))
-- Reward interval (live literal; the table field the root copies): floor(used / interval) tiers.
local function tiers(used, interval) return math.floor(used / interval) end
ok(tiers(4, 4) == 1 and tiers(7, 4) == 1 and tiers(8, 4) == 2 and tiers(3, 1) == 3 and tiers(9, 10) == 0,
   "reward tiers = floor(exolizers used / interval): 4 -> 1, 8 -> 2 at the default 4; interval 1 -> a tier per exolizer")
emit(failures == 0 and ("VOID CASCADE EXOLIZER HARNESS PASS checks=" .. passes) or "VOID CASCADE EXOLIZER HARNESS FAIL")
'''

script = WORK / 'void_cascade_exolizer_harness.luau'
script.write_text('ADDON_MODULE = function(...)\n' + source + '\nend\n' + f'KEY = {lua(KEY)}\nHOOKED = {lua(all_hooked)}\n'
                  + 'VIEWS = ' + lua({p: views[p] for p in sorted(views)}) + '\n'
                  + f'MASTER = {lua(MASTER)}\nROW = {lua(ROW)}\nMIN = {lua(master["min"])}\nMAX = {lua(master["max"])}\n' + harness,
                  encoding='utf-8')
check(LUAU.is_file(), 'toolchain luau.exe present')
run = subprocess.run([str(LUAU), str(script)], capture_output=True, text=True)
lines = run.stdout.splitlines()
for line in lines:
    print('HARNESS\t' + line)
if run.stderr.strip():
    print('HARNESS-STDERR\t' + run.stderr.strip())
check(run.returncode == 0 and any(l.startswith('VOID CASCADE EXOLIZER HARNESS PASS') for l in lines) and not any(l.startswith('FAIL') for l in lines),
      f'harness: {sum(l.startswith("PASS") for l in lines)} Luau checks (generated addon, hooked prototypes {all_hooked})')


# 6. Float32 floor of the master minimum (TimerMgr adds the frame time to Delta in the float32 DE VM).
def f32(x):
    return struct.unpack('<f', struct.pack('<f', x))[0]


def below(x):
    bits = struct.unpack('<I', struct.pack('<f', f32(x)))[0]
    return struct.unpack('<f', struct.pack('<I', bits - 1))[0]


def moves(duration, fps):
    delta = below(f32(duration))          # the last float32 step before the timer ends: the worst case of the sum
    return f32(delta + f32(1 / fps)) > delta


d006 = f32(90 / f32(0.006))
d005 = f32(90 / f32(0.005))
check(d006 < 16384 and moves(d006, 2000) and not moves(d006, 5000),
      f'x0.006: duration {d006:.4f} s < 16384; the float32 timer still moves at 2000 fps (stops only above 2048 fps)')
check(d005 >= 16384 and not moves(d005, 1100) and moves(d005, 1000),
      f'control x0.005: duration {d005:.1f} s >= 16384; the timer stops moving above 1024 fps (why the floor is 0.006, '
      'R20 rule: no stall below about 1600 fps)')
check(not moves(f32(90 / f32(0.001)), 300), 'control x0.001: 90000 s; the timer stops moving above 256 fps')

# 7. Live literal: synthesis through the generator for N = 1, 2, 10.
GEN_ROW = {f['value_offset']: f['expected'] for r in rows.values() if r['owner'].get('body_key') == KEY
           and r['backend'] == 'TARGET_ADDON' and 'fields' in r['owner'] for f in r['owner']['fields']}
check(len(GEN_ROW) == 7, f'{len(GEN_ROW)} addon-owned field initialisers in the module (2 durations, alert interval, 4 Circuit counts)')
for n in (1, 2, 10):
    run_n, gen_n = build({REWARD: n}, f'n{n}')
    synth = list(gen_n.glob(f'live-literals/{KEY}.synthesized.lua_B')) if gen_n else []
    check(run_n.returncode == 0 and len(synth) == 1, f'N={n}: build succeeds and synthesizes ZarimanSurvivalMission from the recipe')
    body = synth[0].read_bytes()
    diff = [k for k in range(len(stock)) if stock[k] != body[k]]
    check(len(body) == len(stock) and diff and set(diff) <= {88712, 88713} and body[88710:88714] == bytes([8, 6, n & 255, n >> 8]),
          f'N={n}: only the immediate of P97 i80 changes (LOADN R6, {n}); {len(diff)} byte(s)')
    check(all(list(body[o:o + 4]) == e for o, e in GEN_ROW.items()),
          f'N={n}: every addon-owned initialiser keeps its stock bytes (R5-C: the addon stock check holds)')
    if n == 1:
        canon = WORK / 'synth1.canonical'
        canon.write_bytes(NORMALIZE(body))
        r = subprocess.run([str(DERECOMP), 'semantic-ir-render-module-readable', str(canon), str(WORK / 'synth1.fidelity.luau'),
                            str(WORK / 'synth1.readable.luau'), str(WORK / 'synth1.names.tsv'), '--semantic-sdk', str(SDK)],
                           capture_output=True, text=True, encoding='utf-8', errors='replace')
        text = (WORK / 'synth1.readable.luau').read_text(encoding='utf-8') if r.returncode == 0 else ''
        check('frame_97[15].REWARD_INTERVAL = 1\n' in text and 'frame_97[177] = (frame_97[15]).REWARD_INTERVAL\n' in text
              and 'frame_97[15].PILLAR_DURATION = 90\n' in text,
              'N=1: the readable render (pinned derecomp) shows REWARD_INTERVAL = 1 copied into the reward-check local; '
              'PILLAR_DURATION stays 90')

OUT.mkdir(parents=True, exist_ok=True)
(OUT / 'void_cascade_exolizer_harness.json').write_text(json.dumps(results, indent=2) + '\n', encoding='utf-8')
print('VOID CASCADE EXOLIZER HARNESS GATE PASS')
