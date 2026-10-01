"""Defense "Waves per reward": wrong-owner gate (2026-10-01, contract R15).

Why: R13 made the WaveDefense entry hook run live (EE 581.400 "minWavesToComplete 3 -> 1"), yet no reward /
continue-or-extract checkpoint opened after waves 1 and 2. The R13 harness passed because it modelled the instance
environment as a table only the addon writes. In the game the engine owns that table's script-parameter keys: its
script-parameter applier (44.0.2 RVA 0x181CAE0, `getfenv(fn)[FNV(name)] = level value`, driven by ApplyScriptParams
0x175C710 / 0x1280F60 and the generic script call 0x0C6DD40) writes the ScriptTrigger's `_minWavesToComplete=3` into the
instance environment, and the script-run loop 0x0A77E90 re-applies it to an existing instance before running it, with no
busy check. GETIMPORT never caches the value (the loader thread's globals are never safeenv, so import constants stay nil
and every read is the live environment lookup), so the decision reads whatever the engine wrote last.

This gate executes the decision path in the observed order (engine applies the level values -> native entry hook ->
engine re-applies the level values -> wave loop) for two owners:
  * R14 (installed, addon 4c70b5ec): the decision input is the environment. Expected (and asserted): the hook prints
    "3 -> 1" and the checkpoints stay 3, 6, 9, 12 = the live result. Without the re-application step the same code
    gives every wave, which is exactly what the R13 harness checked and why it did not catch the wrong owner.
  * R15: the decision input is the pinned reader. The real recipe is synthesized by the generator for N = 1, 2, 5; the
    synthesized WaveDefend bytes are decoded: each of the four reads (P48 i960/i1122, P36 i238/i307) is `LOADN A, N`
    twice in the 8 bytes of the former GETIMPORT, every other byte is stock, and no instruction names the hash 69d6d911
    any more. The readable render (derecomp, pinned toolchain) shows the decision `(wave - 1) % N`. The checkpoint
    waves then follow N whatever the engine writes into the environment.

Limits: the checkpoint rule is the decompiled reader (L9236-9240) evaluated in plain Luau with the pinned value read
from the synthesized bytes; the DE VM itself does not run here. Which engine call re-applied the value in the live
session is not identified (the gate covers any re-application).

Paths: CLI = RENOVICE_EDITOR_CLI or work/builds/ability-editor/current; luau.exe and derecomp.exe from the DE Luau
toolchain. Writes only to work/temp/defense-reader-pin-harness and this tool's test-results folder. Reads no game or
server folder.
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
STOCK = ROOT / 'shared/corpus/de-luau-u44.0.2-authoring/Lotus_Scripts_WaveDefend.lua_B'
STOCK_SHA = '0fb53a2c0946acc3476df7e16c5a3aaeea1b6384a2d4efa2d7360f4c155dbf10'
KEY = '1a1354d153712f9d'
# The installed R14 addon source (staged evidence, built from the pinned R12 input; artifact 4c70b5ec...).
R14_SOURCE = ROOT / 'work/staging/combined-r14/evidence/generator/Missions.targets.addon.luau'
R14_SOURCE_LF_SHA = '51c76862eae9bc15f582b3521523b194e415f9f49b75f3297cc65393e57f55ed'  # LF content
SITES = [(48, 1122), (48, 960), (36, 238), (36, 307)]   # (prototype, instruction) of the four readers
WORK = ROOT / 'work/temp/defense-reader-pin-harness'
OUT = HERE.parent / 'test-results'
results = {'checks': []}


def check(ok, name):
    results['checks'].append({'name': name, 'pass': bool(ok)})
    print(('PASS' if ok else 'FAIL') + '\t' + name)
    if not ok:
        OUT.mkdir(parents=True, exist_ok=True)
        (OUT / 'defense_reader_pin_harness.json').write_text(json.dumps(results, indent=2) + '\n', encoding='utf-8')
        sys.exit(1)


def sha(data):
    return hashlib.sha256(data).hexdigest()


def namehash(name):
    h = 0x768e5ed0
    for c in name.encode():
        h = ((h ^ c) * 0x01000193) & 0xffffffff
    h = ~h & 0xffffffff
    return ((h << 17) | (h >> 15)) & 0xffffffff


H = namehash('minWavesToComplete')
check(H == 0x69d6d911, 'U44 name hash of minWavesToComplete is 69d6d911 (seed 768e5ed0)')
stock = STOCK.read_bytes()
check(sha(stock) == STOCK_SHA, 'stock WaveDefend 44.0.2 body (SHA-256 0fb53a2c...)')
stock_m = Module(stock)


def readers(m):
    """Every instruction of the module that names the hash (GETIMPORT single name, or hashed key operand)."""
    out = []
    for p, (ins, consts) in enumerate(m.protos):
        for i, (off, w) in enumerate(ins):
            if len(w) != 8:
                continue
            aux = struct.unpack_from('<I', w, 4)[0]
            if w[0] == 0x46 and aux >> 30 == 1:
                c = consts[(aux >> 20) & 1023]
            elif w[0] in (0x17, 0x02, 0x3d, 0x15, 0x2d):
                c = consts[aux] if aux < len(consts) else None
            else:
                continue
            if c and c[0] == 1 and struct.unpack('<I', c[1][:4])[0] == H:
                out.append((p, i))
    return sorted(out)


check(readers(stock_m) == sorted(SITES), f'stock: the hash is named only by the four GETIMPORT readers {sorted(SITES)}')
stock_offsets = {}
for p, i in SITES:
    off, w = stock_m.protos[p][0][i]
    stock_offsets[(p, i)] = (off, w[1])
    check(stock[off] == 0x35 and w[0] == 0x46, f'stock P{p} i{i} at {off} is U44 GETIMPORT (raw 0x35) into R{w[1]}')

# 1. Synthesize the real recipe through the generator for several values.
shutil.rmtree(WORK, ignore_errors=True)
WORK.mkdir(parents=True)
pinned = {}
for n in (1, 2, 5):
    spec = {'format': 'RENOVICE_MISSION_SETTINGS_V1', 'build': '2026.09.28.13.06', 'values': {'defense.waves_per_reward': n},
            'allow_unproven_hook_bindings': ['renovice.target.lua_call'], 'output_layout': 'package',
            'package_scope': 'all_addon_values', 'literal_mode': 'recipe', 'literal_scope': 'headline'}
    (WORK / f'input_{n}.json').write_text(json.dumps(spec, indent=2) + '\n', encoding='utf-8')
    run = subprocess.run([str(CLI), 'build-missions', str(WORK / f'input_{n}.json'), '--staging', str(WORK / f'build_{n}'),
                          '--editor-root', str(EDITOR)], capture_output=True, text=True)
    synth = list((WORK / f'build_{n}').glob(f'missions/*/live-literals/{KEY}.synthesized.lua_B'))
    check(run.returncode == 0 and len(synth) == 1, f'N={n}: build succeeds and synthesizes WaveDefend from the recipe')
    body = synth[0].read_bytes()
    check(len(body) == len(stock), f'N={n}: synthesized body keeps the stock size ({len(stock)} bytes)')
    allowed = set()
    for p, i in SITES:
        off, reg = stock_offsets[(p, i)]
        word = bytes([0x08, reg, n & 0xFF, (n >> 8) & 0xFF])
        check(body[off:off + 4] == word and body[off + 4:off + 8] == word,
              f'N={n}: P{p} i{i} is LOADN R{reg}, {n} twice (instruction word and former aux word)')
        allowed.update(range(off, off + 8))
    diff = [k for k in range(len(stock)) if stock[k] != body[k]]
    check(set(diff) <= allowed and diff, f'N={n}: {len(diff)} changed bytes, all inside the 4 x 8 pinned bytes')
    m = Module(body)
    check(readers(m) == [], f'N={n}: no instruction names the hash 69d6d911 (the decision never reads the environment)')
    for p in (36, 48):
        check(sum(len(w) for _, w in m.protos[p][0]) == sum(len(w) for _, w in stock_m.protos[p][0]),
              f'N={n}: P{p} code size unchanged (same instruction slots, same jump targets)')
    pinned[n] = body

# 2. Readable proof (pinned toolchain render) of the decision line in stock and pinned N=1.
def render(body, stem):
    canon = WORK / (stem + '.canonical')
    canon.write_bytes(NORMALIZE(body))
    r = subprocess.run([str(DERECOMP), 'semantic-ir-render-module-readable', str(canon), str(WORK / (stem + '.fidelity.luau')),
                        str(WORK / (stem + '.readable.luau')), str(WORK / (stem + '.names.tsv')), '--semantic-sdk', str(SDK)],
                       capture_output=True, text=True, encoding='utf-8', errors='replace')
    check(r.returncode == 0, f'render {stem} (derecomp {sha(DERECOMP.read_bytes())[:8]})')
    return (WORK / (stem + '.readable.luau')).read_text(encoding='utf-8').splitlines()


stock_lines = render(stock, 'stock')
pin_lines = render(pinned[1], 'pinned1')
check(sum('Name__69d6d911' in l for l in stock_lines) == 4, 'stock render: 4 reads of the global 69d6d911')
check(sum('Name__69d6d911' in l for l in pin_lines) == 0, 'pinned render: no read of the global 69d6d911')
state = next(k for k, l in enumerate(pin_lines) if l.strip() == 'elseif cfg_48 == 299 then')
block = [l.strip() for l in pin_lines[state + 1:state + 6]]
check(block[:2] == ['frame_48[915] = 1', 'frame_48[916] = 1'] and block[3] == 'frame_48[918] = (frame_48[917] % frame_48[916])'
      and block[2] == 'frame_48[917] = (frame_48[28] - 1)',
      'pinned render: the checkpoint test (P48 state 299, stock L9236) is (wave - 1) % 1')
results['pinned_decision_block'] = block

# 3. The decision path in the observed order, for the installed R14 addon and the R15 addon.
r14_source = R14_SOURCE.read_text(encoding='utf-8')
check(sha(r14_source.replace('\r\n', '\n').encode()) == R14_SOURCE_LF_SHA, 'installed R14 addon source (staged evidence, LF content pinned)')
check('environment.minWavesToComplete = value' in r14_source, 'R14 addon writes environment.minWavesToComplete at the P50 entry')
r15_build = list((WORK / 'build_1').glob('missions/*/source/Missions.targets.addon.luau'))
check(len(r15_build) == 1, 'R15 addon source built')
r15_source = r15_build[0].read_text(encoding='utf-8')
check('minWavesToComplete' not in r15_source, 'R15 addon no longer names minWavesToComplete')
pinned_value = {n: struct.unpack_from('<h', pinned[n], stock_offsets[(48, 1122)][0] + 2)[0] for n in pinned}

harness = r'''
local emit = print
local printed = {}
print = function(...)
    local parts = {}
    for i = 1, select("#", ...) do parts[#parts + 1] = tostring(select(i, ...)) end
    printed[#printed + 1] = table.concat(parts, " ")
end
local mission = { maxWaveNum = 0, alertId = "", invasionId = "", goalId = "", sortieId = "", nightmare = false,
    syndicateTag = { IsValid = function() return false end } }
gRegion = { IsMaster = function() return true end }
gGameRules = { GetMission = function() return mission end, SetMission = function(self, m) mission = m end }
local failures = 0
local function ok(condition, name)
    if condition then emit("PASS\t" .. name) else failures = failures + 1 emit("FAIL\t" .. name) end
end
-- Engine model (native evidence): the script-parameter applier writes the trigger's level values into the instance
-- environment before a script run of that instance (first run and every later run request of the same instance).
local LEVEL = { minWavesToComplete = 3, isDuviriDefense = false, isCircle = false }
local function engine_apply(env) for k, v in pairs(LEVEL) do env[k] = v end end
-- WaveDefend P48 after each wave (readable L9060, L9228-9240): counter + 1, then the checkpoint test. `read` is the
-- decision input: the environment (stock / R14) or the pinned reader (R15).
local function checkpoints(env, read, waves, reapply_each_wave)
    local out, counter = {}, 1
    for wave = 1, waves do
        if reapply_each_wave then engine_apply(env) end
        counter = counter + 1
        if not env.isDuviriDefense and not env.isCircle and (counter - 1) % read(env) == 0 then out[#out + 1] = wave end
    end
    return table.concat(out, ",")
end
local function run(addon_module, value, reapply_once, reapply_each_wave, read)
    local target = addon_module().targets["1a1354d153712f9d"]
    local settings = {}
    if value ~= nil then settings["defense.waves_per_reward"] = { enabled = true, value = value, stock = 3 } end
    target.activate({ settings = settings })
    local env = {}
    engine_apply(env)                                   -- before the first run of the WaveDefense instance
    local hook = target.hooks.luaCalls[50]
    if hook ~= nil then hook.before(50, {}, {}, nil, env) end   -- R13 native-entry dispatch of WaveDefense
    local after_hook = env.minWavesToComplete
    if reapply_once then engine_apply(env) end          -- a later run request of the same instance
    local result = checkpoints(env, read, 12, reapply_each_wave)
    target.cleanup()
    return result, after_hook
end
local from_env = function(env) return env.minWavesToComplete end

-- R14 (installed): the decision input is the environment.
local cps, after = run(R14_ADDON, 1, false, false, from_env)
ok(after == 1 and cps == "1,2,3,4,5,6,7,8,9,10,11,12", "R14 without engine re-application: every wave (what the R13 harness checked)")
cps, after = run(R14_ADDON, 1, true, false, from_env)
ok(after == 1 and cps == "3,6,9,12", "R14 in the observed order (hook writes 1, engine re-applies 3): checkpoints 3,6,9,12 = live 2026-10-01 (no checkpoint after waves 1, 2)")
local line = false
for _, text in ipairs(printed) do line = line or text == "RENOVICE Missions: defense.waves_per_reward minWavesToComplete 3 -> 1" end
ok(line, "R14 prints the live line 'minWavesToComplete 3 -> 1' although the decision does not see it")

-- R15: the decision input is the pinned reader (value decoded from the synthesized bytes).
for n, expect in pairs(EXPECT) do
    local pin = function() return PINNED[n] end
    local a, after15 = run(R15_ADDON, nil, true, true, pin)
    ok(after15 == 3 and a == expect, "R15 N=" .. n .. " with re-application before every wave: checkpoints " .. expect .. " (environment left at the level value 3)")
end
local a = run(R15_ADDON, nil, false, false, function() return PINNED[1] end)
ok(a == EXPECT[1], "R15 N=1 without re-application: same result (the environment is not the owner any more)")
emit(failures == 0 and "DEFENSE READER PIN HARNESS PASS" or "DEFENSE READER PIN HARNESS FAIL")
'''


def series(n):
    return ','.join(str(w) for w in range(1, 13) if w % n == 0)


expect = {n: series(n) for n in pinned}
script = WORK / 'defense_reader_pin_harness.luau'
script.write_text('R14_ADDON = function(...)\n' + r14_source + '\nend\n'
                  + 'R15_ADDON = function(...)\n' + r15_source + '\nend\n'
                  + 'PINNED = {' + ', '.join(f'[{n}] = {v}' for n, v in pinned_value.items()) + '}\n'
                  + 'EXPECT = {' + ', '.join(f'[{n}] = "{e}"' for n, e in expect.items()) + '}\n' + harness, encoding='utf-8')
check(LUAU.is_file(), 'toolchain luau.exe present')
run = subprocess.run([str(LUAU), str(script)], capture_output=True, text=True)
lines = run.stdout.splitlines()
for line in lines:
    print('HARNESS\t' + line)
if run.stderr.strip():
    print('HARNESS-STDERR\t' + run.stderr.strip())
check(run.returncode == 0 and 'DEFENSE READER PIN HARNESS PASS' in lines and not any(l.startswith('FAIL') for l in lines),
      f'harness: {sum(l.startswith("PASS") for l in lines)} Luau checks (R14 observed order reproduces live; R15 pinned reader)')
results['pinned_values'] = {str(k): v for k, v in pinned_value.items()}
results['expected_checkpoints'] = {str(k): v for k, v in expect.items()}
OUT.mkdir(parents=True, exist_ok=True)
(OUT / 'defense_reader_pin_harness.json').write_text(json.dumps(results, indent=2) + '\n', encoding='utf-8')
print('DEFENSE READER PIN HARNESS GATE PASS')
