"""Contract R17 gate (2026-10-01): the four R10 entry rows R15 left unclassified, and the "All <mission type> missions"
masters that span several modules.

Why: R15 showed that a level/encounter parameter written once at the trigger entry (R10 SCRIPT_PARAM_GLOBAL_AT_ENTRY) is
lost when its reader runs after a yield of the same instance, because the engine's parameter writer writes the level
value again. R15 classified nine of the thirteen R10 parameter rows. R17 classifies the remaining four with the same
method (does every reader run in the entry call, before control can return to the engine?) and moves the exposed ones:

  * Gas City meltdown time: WRONG OWNER. SabotageMission (P15) calls P5 in its first run slice; P5 SETGLOBALs
    hackTime = modeTimer x Lerp(1.8, 1.2, difficulty) before any reader, and the reader P3 (SetObjTimer) runs at stage 5 or
    after a host migration. The R10 row wrote hackTime at the entry and was always overwritten. R17 row: both parameters
    scaled at the engine writer (R16 lane), which scales the countdown in both engine write orders.
  * Sabotage surprise extraction: REACHES. reactorDestroyedFunction (P11) reads `duration` once, in the entry call, before
    any yield of the path that reads it. Unchanged (R10 lane). R21 (2026-10-02): REACHES is the class R19 refuted live, so
    the row is owned at the engine writer; the R10 entry write is its fallback.
  * Deepmines hold time and bonus threshold: EXPOSED. DefendStart (P9) first runs P6, which busy-waits Sleep(1) before
    reading defendTime; the threshold is read in P9's loop, a 1 s timer (P0) and a callback (P5). Every read is a
    single-name GETIMPORT and nothing writes the names, so both rows are reader pins (IMPORT_READ_PIN_V1, live literals).

This gate:
  1. re-derives the reader census of the four parameters from the pinned 44.0.2 stock bytes;
  2. renders the stock modules (derecomp, pinned toolchain) and checks the order facts the classification rests on;
  3. builds a package with the R17 values on (Control Area master 45, bonus threshold 25, Gas City x2, surprise extraction
     120, Railjack kill goals x0.5) and checks the synthesized modules: the Control Area master patches the Plains,
     Cambion Drift and Deepmines scripts (three modules, one value), the Deepmines reads are LOADN constants;
  4. runs the REAL generated addon in plain Luau in the engine write order (engine write -> native entry -> script ->
     engine write again -> reader) for Gas City (R17 native lane, the R10 fallback, and the old R10 row as the
     wrong-owner control) and for the surprise extraction (REACHES).

Limits: the DE VM does not run; the engine writer, P5 and the readers are modelled from the decompile. Which engine path
re-writes parameters (R15 F6) is not identified, so the Gas City model runs both orders. Nothing here is live.
Paths: CLI = RENOVICE_EDITOR_CLI or work/builds/ability-editor/current; luau.exe and derecomp.exe from the DE Luau toolchain.
Writes only to work/temp/r17-type-masters-harness and this tool's test-results folder. Reads no game or server folder.
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
CURRENT_BUILD = __import__('json').loads((Path(__file__).resolve().parents[3] / 'REGISTRIES/mission_build_u44.json').read_text(encoding='utf-8'))['build']  # 2026-10-09: current registry build

CLI = Path(os.environ.get('RENOVICE_EDITOR_CLI', ROOT / 'work/builds/ability-editor/current/bin/renovice_ability_editor_cli.exe'))
LUAU = ROOT / 'repos/toolchains/de-luau-toolchain/bin/luau.exe'
DERECOMP = ROOT / 'repos/toolchains/de-luau-toolchain/bin/derecomp.exe'
SDK = ROOT / 'shared/semantic-sdk/symbols.tsv'
NORMALIZE = runpy.run_path(str(EDITOR / 'RESEARCH/U44_AUTHORING_2026-09-27/scripts/inspect_current.py'))['normalize']
CORPUS = ROOT / 'shared/corpus/de-luau-u44.0.2-authoring'
WORK = ROOT / 'work/temp/r17-type-masters-harness'
OUT = HERE.parent / 'test-results'
MODULES = {  # key -> (file, stock SHA-256)
    '5b59e2968c1ec7bf': ('Lotus_Scripts_Modes_GasCitySabotage.lua_B', '64f1281d3c81ec76e5051406172c23bbbab29d62d51697ad2666744628c13e08'),
    '7e0adf2d83f7a086': ('Lotus_Scripts_Sabotage.lua_B', '0f1e3d2d0a2becb2a4cc662981e7d0595d391cd466573c551f5fd9cd913f7190'),
    'e4bb611e00823d46': ('Lotus_Scripts_Venus_NokkoColony_Encounters_AreaDefense.lua_B',
                         '2c7bb67b50c245a0d9b10e680b18b54503abdbf546eeeb2b85a3d98de80aa4c6'),
}
GETIMPORT, GETGLOBAL, SETGLOBAL = 0x46, 0x17, 0x02
results = {'checks': []}


def check(ok, name):
    results['checks'].append({'name': name, 'pass': bool(ok)})
    print(('PASS' if ok else 'FAIL') + '\t' + name)
    if not ok:
        OUT.mkdir(parents=True, exist_ok=True)
        (OUT / 'r17_type_masters_harness.json').write_text(json.dumps(results, indent=2) + '\n', encoding='utf-8')
        sys.exit(1)


def sha(data):
    return hashlib.sha256(data).hexdigest()


def namehash(name):
    h = 0x768e5ed0
    for c in name.encode():
        h = ((h ^ c) * 0x01000193) & 0xffffffff
    h = ~h & 0xffffffff
    return ((h << 17) | (h >> 15)) & 0xffffffff


def uses(m, name):
    """{(prototype, instruction): opcode} of every instruction that names the hashed global (GETIMPORT single name,
    GETGLOBAL, SETGLOBAL)."""
    h = namehash(name)
    out = {}
    for p, (ins, consts) in enumerate(m.protos):
        for i, (_, w) in enumerate(ins):
            if len(w) != 8:
                continue
            aux = struct.unpack_from('<I', w, 4)[0]
            if w[0] == GETIMPORT and aux >> 30 == 1:
                c = consts[(aux >> 20) & 1023]
            elif w[0] in (GETGLOBAL, SETGLOBAL):
                c = consts[aux] if aux < len(consts) else None
            else:
                continue
            if c and c[0] == 1 and struct.unpack('<I', c[1][:4])[0] == h:
                out[(p, i)] = {GETIMPORT: 'GETIMPORT', GETGLOBAL: 'GETGLOBAL', SETGLOBAL: 'SETGLOBAL'}[w[0]]
    return out


shutil.rmtree(WORK, ignore_errors=True)
WORK.mkdir(parents=True)
stock = {}
for key, (file, digest) in MODULES.items():
    stock[key] = (CORPUS / file).read_bytes()
    check(sha(stock[key]) == digest, f'stock {file} is the 44.0.2 body ({digest[:8]})')
m_gas, m_sab, m_area = (Module(stock[k]) for k in MODULES)

# 1. Reader census from the stock bytes.
check(uses(m_gas, 'hackTime') == {(3, 33): 'GETGLOBAL', (3, 36): 'SETGLOBAL', (3, 59): 'GETGLOBAL', (5, 112): 'SETGLOBAL'}
      and uses(m_gas, 'modeTimer') == {(5, 105): 'GETIMPORT'},
      'Gas City: hackTime is read only by P3 (i33 restore, i59 SetObjTimer) and written by P3 i36 and P5 i112; modeTimer is '
      'read only by P5 i105')
check(uses(m_sab, 'duration') == {(11, 223): 'GETIMPORT'}, 'Sabotage: the surprise extraction `duration` has one reader, P11 i223')
defend = {(5, 74), (6, 102), (6, 105), (6, 109), (6, 110)}
bonus = {(0, 43), (0, 54), (0, 73), (5, 68), (9, 172), (9, 198)}
check(uses(m_area, 'defendTime') == {k: 'GETIMPORT' for k in defend}
      and uses(m_area, 'bonusControlLevelThreshold') == {k: 'GETIMPORT' for k in bonus},
      'Deepmines: defendTime (5 reads) and bonusControlLevelThreshold (6 reads) are single-name GETIMPORT reads, never written')


# 2. Order facts from the readable render of the stock bytes.
def render(body, stem):
    canon = WORK / (stem + '.canonical')
    canon.write_bytes(NORMALIZE(body))
    r = subprocess.run([str(DERECOMP), 'semantic-ir-render-module-readable', str(canon), str(WORK / (stem + '.fidelity.luau')),
                        str(WORK / (stem + '.readable.luau')), str(WORK / (stem + '.names.tsv')), '--semantic-sdk', str(SDK)],
                       capture_output=True, text=True, encoding='utf-8', errors='replace')
    check(r.returncode == 0, f'render {stem} (derecomp {sha(DERECOMP.read_bytes())[:8]})')
    return (WORK / (stem + '.readable.luau')).read_text(encoding='utf-8').splitlines()


def function_body(lines, name):
    """Lines of the module function bound to the global `name` (from its `= function` line to the binding line)."""
    end = next(k for k, l in enumerate(lines) if l.startswith(name + ' = '))
    slot = lines[end].split(' = ', 1)[1].strip()
    start = max(k for k in range(end) if lines[k].startswith(slot + ' = function') or lines[k].startswith(name + ' = function'))
    return lines[start:end + 1]


def first(lines, needle, after=0):
    return next((k for k, l in enumerate(lines) if k >= after and needle in l), None)


SLEEP = 'Name__daf81ef9'   # the script wait the decompile names in every mission script here (Sleep(n))
gas = render(stock['5b59e2968c1ec7bf'], 'gascity')
mission = function_body(gas, 'SabotageMission')
p5_call = first(mission, '"cap_23_239_4"]()') or first(mission, 'cap_23_239_4')
check(p5_call is not None and first(mission, SLEEP) is not None and p5_call < first(mission, SLEEP),
      'Gas City: SabotageMission calls P5 (the hackTime computation) before its first Sleep (same entry call)')
p5 = next(k for k, l in enumerate(gas) if 'Name__d37f0aaf = ' in l and 'v5_' in l)
check('Name__ac8ee271' in ''.join(gas[max(0, p5 - 8):p5]) and '1.8, 1.2' in ''.join(gas[max(0, p5 - 8):p5]),
      'Gas City: P5 sets hackTime from modeTimer x Lerp(1.8, 1.2, difficulty) (it replaces whatever the entry wrote)')
sab = render(stock['7e0adf2d83f7a086'], 'sabotage')
reactor = function_body(sab, 'ReactorDestroyed')
read = first(reactor, 'Name__f4de5c39')
check(read is not None and (first(reactor, SLEEP) is None or read < first(reactor, SLEEP)),
      'Sabotage: reactorDestroyedFunction reads duration before any Sleep of its body (the read runs in the entry call)')
area = render(stock['e4bb611e00823d46'], 'areadefense')
p6_wait = first(area, SLEEP + '(1)') or first(area, SLEEP)
p6_read = first(area, 'Name__1d1539a9', after=p6_wait or 0)
p6_start = max(k for k in range(p6_wait or 0) if area[k].rstrip().endswith('= function(p6_0)'))
check(p6_wait is not None and p6_read is not None and p6_start < p6_wait < p6_read
      and not any(area[k].rstrip().endswith('= function') or ' = function(' in area[k] for k in range(p6_wait, p6_read)),
      'Deepmines: the hold-time setup (P6) waits in its Sleep loop before its defendTime reads, in the same function (EXPOSED)')
defend_start = function_body(area, 'DefendStart')
check(first(defend_start, 'Name__186dbec4') is not None and first(defend_start, SLEEP) is not None,
      'Deepmines: DefendStart reads the bonus threshold inside its loop, which sleeps (EXPOSED)')

# 3. A build with the R17 values on, and its synthesized modules.
spec = {'format': 'RENOVICE_MISSION_SETTINGS_V1', 'build': CURRENT_BUILD,
        'values': {'control_area.hold_time': 45, 'control_area_nokko.bonus_threshold': 25,
                   'sabotage.gascity_meltdown_time_scale': 2, 'sabotage.random_extraction_timer': 120,
                   'railjack.kill_goals_scale': 0.5},
        'allow_unproven_hook_bindings': ['renovice.target.lua_call'], 'output_layout': 'package',
        'package_scope': 'all_addon_values', 'literal_mode': 'recipe', 'literal_scope': 'headline'}
(WORK / 'input.json').write_text(json.dumps(spec, indent=2) + '\n', encoding='utf-8')
run = subprocess.run([str(CLI), 'build-missions', str(WORK / 'input.json'), '--staging', str(WORK / 'build'), '--editor-root', str(EDITOR)],
                     capture_output=True, text=True)
generations = list((WORK / 'build').glob('missions/*/MISSION_SET_MANIFEST.json'))
check(run.returncode == 0 and len(generations) == 1, 'build with the R17 values succeeds' + ('' if run.returncode == 0 else ': ' + run.stdout[-400:]))
generation = generations[0].parent
recipe = json.loads((generation / 'Packages/Missions/literals.json').read_text(encoding='utf-8'))
ca = recipe['values']['control_area.hold_time']
modules = [ca['module']] + [d['module'] for d in ca['drives'] if 'module' in d]
check(sorted(modules) == sorted(['8a0b0819de60df01', 'e4bb611e00823d46', 'b3a5a18d68d61e16']),
      'Control Area master: one value, drives in the Cambion Drift, Deepmines and Plains scripts')
for drive in ca['drives']:
    key = drive.get('module', ca['module'])
    body = (generation / 'live-literals' / f'{key}.synthesized.lua_B').read_bytes()
    original = (CORPUS / recipe['modules'][key]['file']).read_bytes()
    ok_sites = all(body[s['offset']] == 0x08 and body[s['offset'] + 1] == s['register']
                   and struct.unpack_from('<h', body, s['offset'] + 2)[0] == 45 for s in drive['sites'])
    sites = set()
    for v in recipe['values'].values():
        for d in v['drives']:
            if d.get('module', v['module']) == key:
                for s in d['sites']:
                    sites.update(range(s['offset'], s['offset'] + 4))
    diff = {k for k in range(len(original)) if original[k] != body[k]}
    check(ok_sites and diff and diff <= sites and len(body) == len(original),
          f'Control Area master 45 in {key}: {len(drive["sites"])} site(s) of {drive["row"]} are LOADN 45; '
          f'{len(diff)} changed bytes, all inside recipe sites')
area_body = (generation / 'live-literals' / 'e4bb611e00823d46.synthesized.lua_B').read_bytes()
m_pinned = Module(area_body)
check(uses(m_pinned, 'defendTime') == {} and uses(m_pinned, 'bonusControlLevelThreshold') == {},
      'Deepmines synthesized: no instruction names defendTime or the bonus threshold (no environment read is left)')
area_pinned = render(area_body, 'areadefense_pinned')
check(sum('Name__1d1539a9' in l for l in area_pinned) == 0 and sum('Name__186dbec4' in l for l in area_pinned) == 0,
      'Deepmines synthesized render: the reads are constants (45 hold time, 25 bonus threshold)')
off = {(p, i): m_area.protos[p][0][i][0] for p, i in defend | bonus}
check(all(struct.unpack_from('<h', area_body, off[k] + 2)[0] == 45 for k in defend)
      and all(struct.unpack_from('<h', area_body, off[k] + 2)[0] == 25 for k in bonus),
      'Deepmines synthesized: every defendTime read loads 45 and every threshold read loads 25 (master + own row)')

# 4. The engine write order with the real addon.
source = (generation / 'source/Missions.targets.addon.luau').read_text(encoding='utf-8')
registry = json.loads((EDITOR / 'REGISTRIES/mission_build_u44.json').read_text(encoding='utf-8'))
rows = {r['tunable_id']: r for r in registry['tunables']}
gas_row, sab_row = rows['sabotage.gascity_meltdown_time_scale'], rows['sabotage.random_extraction_timer']
# R21 (2026-10-02): the surprise extraction is owned at the engine writer too (its REACHES class is the one R19 refuted live
# for the Railjack goals); the entry write below is its fallback for a DLL without the hook (test_engine_param_override_harness
# replays the R19 failure order for it).
check(gas_row['owner'].get('engine_override', {}).get('gate') == 'ENGINE_PARAM_OVERRIDE_V1'
      and sab_row['owner'].get('engine_override', {}).get('gate') == 'ENGINE_PARAM_OVERRIDE_V1',
      'registry: the Gas City row and (R21) the surprise extraction are owned at the engine writer')
harness = r'''
local emit = print
local printed = {}
print = function(...)
    local parts = {}
    for i = 1, select("#", ...) do parts[#parts + 1] = tostring(select(i, ...)) end
    printed[#printed + 1] = table.concat(parts, " ")
end
gRegion = { IsMaster = function() return true end }
local failures = 0
local function ok(condition, name)
    if condition then emit("PASS\t" .. name) else failures = failures + 1 emit("FAIL\t" .. name) end
end
local function near(a, b) return type(a) == "number" and math.abs(a - b) < 1e-6 end
local function lerp(a, b, t) return a + (b - a) * t end
local DIFFICULTY = 0.5                 -- node difficulty 0..1: factor Lerp(1.8, 1.2, 0.5) = 1.5
local LEVEL = { hackTime = 10, modeTimer = 60 }   -- the SabotageMission trigger's level parameters
-- The engine's parameter writer (R16 native lane: x value on every write).
local function engine_write(env, native, value)
    for name, level in pairs(LEVEL) do env[name] = native and level * value or level end
end
-- GasCitySabotage P15 SabotageMission: native entry (R13 dispatch), then P5 in the same run slice; P3 reads later.
local function gas_city(runtime, reapply, old_row_value)
    local addon = ADDON_MODULE()
    local target = addon.targets[GAS_KEY]
    local native = runtime == "r17"
    local settings = {}
    if runtime == "fallback" then settings[GAS_ID] = { enabled = true, value = 2, stock = 1 } end
    target.activate({ settings = settings })
    local env = {}
    engine_write(env, native, 2)                                -- the instance gets the level values
    target.hooks.luaCalls[GAS_ENTRY].before(GAS_ENTRY, {}, {}, nil, env)   -- the entry hook
    if old_row_value ~= nil then env.hackTime = old_row_value end         -- the R10 row (wrong owner): hackTime at the entry
    env.hackTime = env.modeTimer * lerp(1.8, 1.2, DIFFICULTY)  -- P5 (first run slice of the entry)
    if reapply then engine_write(env, native, 2) end            -- an engine re-write before stage 5 (R15 F6)
    local countdown = env.hackTime                              -- P3 SetObjTimer(hackTime) at stage 5
    target.cleanup()
    return countdown
end
local stockA = LEVEL.modeTimer * lerp(1.8, 1.2, DIFFICULTY)   -- 90 s without a later engine write
local stockB = LEVEL.hackTime                                  -- 10 s if the engine re-writes before stage 5
ok(near(gas_city("r17", false), 2 * stockA), "Gas City R17 (native writer, value withheld from the addon): x2 doubles the countdown without a later engine write (180 s)")
ok(near(gas_city("r17", true), 2 * stockB), "Gas City R17: x2 doubles it too when the engine re-writes before stage 5 (20 s)")
ok(near(gas_city("fallback", false), 2 * stockA), "Gas City R10 fallback (older DLL): the entry write of modeTimer reaches P5 (180 s)")
ok(near(gas_city("fallback", true), stockB), "Gas City R10 fallback: an engine re-write before stage 5 restores the level value (limit, as R15)")
ok(near(gas_city("old", false, 30), stockA) and near(gas_city("old", true, 30), stockB),
    "Gas City control: the R10 row's entry write of hackTime (30) never reaches the countdown (P5 overwrites it): wrong owner")
-- Sabotage reactorDestroyedFunction (P11): the native entry writes, the read is in the same call (REACHES).
do
    local addon = ADDON_MODULE()
    local target = addon.targets[SAB_KEY]
    target.activate({ settings = { [SAB_ID] = { enabled = true, value = 120, stock = 300 } } })
    local env = { duration = 300 }                               -- engine write (level _duration=300)
    target.hooks.luaCalls[SAB_ENTRY].before(SAB_ENTRY, {}, {}, nil, env)
    local read = env.duration                                    -- P11 i223 GETIMPORT duration, before any yield
    env.duration = 300                                           -- a later engine re-write: no reader left
    ok(read == 120, "Sabotage surprise extraction, R10 fallback (DLL without the writer hook): the reader in the entry call sees 120 (REACHES model; R21 owns the row at the writer)")
    target.cleanup()
end
emit(failures == 0 and "R17 HARNESS PASS" or "R17 HARNESS FAIL")
'''
extra = (f'GAS_KEY = "{gas_row["owner"]["body_key"]}"\nGAS_ID = "{gas_row["tunable_id"]}"\nGAS_ENTRY = {gas_row["owner"]["entries"][0]["prototype"]}\n'
         f'SAB_KEY = "{sab_row["owner"]["body_key"]}"\nSAB_ID = "{sab_row["tunable_id"]}"\nSAB_ENTRY = {sab_row["owner"]["entries"][0]["prototype"]}\n')
script = WORK / 'r17_harness.luau'
script.write_text('ADDON_MODULE = function(...)\n' + source + '\nend\n' + extra + harness, encoding='utf-8')
check(LUAU.is_file(), 'toolchain luau.exe present')
run = subprocess.run([str(LUAU), str(script)], capture_output=True, text=True)
lines = run.stdout.splitlines()
for line in lines:
    print('HARNESS\t' + line)
if run.stderr.strip():
    print('HARNESS-STDERR\t' + run.stderr.strip())
check(run.returncode == 0 and 'R17 HARNESS PASS' in lines and not any(l.startswith('FAIL') for l in lines),
      f'harness: {sum(l.startswith("PASS") for l in lines)} Luau checks (Gas City in both engine orders and three runtimes, '
      'surprise extraction)')
OUT.mkdir(parents=True, exist_ok=True)
(OUT / 'r17_type_masters_harness.json').write_text(json.dumps(results, indent=2) + '\n', encoding='utf-8')
print('R17 TYPE MASTERS HARNESS GATE PASS')
