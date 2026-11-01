"""2026-11-01: Enemies > All missions > Spawn point reuse (NATIVE_CALL_RETRY_AT_SPAWN_POINT, on/off, stock off).

Why (scratchpad research, 44.1.3 exe and stock bytecode, read-only): Lotus.Scripts.Libs.EndlessSpawnLib (body key
6f5169d34d076588; ~26 endless-spawn modes require it: Survival, Zariman/Mech survival, Lantern, Ascension, LoopDefend, ...)
spawns every enemy through ONE helper, prototype 9 (zero-based), NAMECALL at instruction 80:
director:CreateRandomAgent(nil, team, level, nil, eximusFlag). With a nil location the native spawn-point search runs and
skips any point that already holds a living agent (0x140d52569); when every nearby point is taken it returns nil and
nothing spawns. An explicit point as argument 1 skips that search (0x141836a9f), and CreateAgent has no occupancy check.
Director method 1ab54531 (no recovered name, no U43 alias: identity line in profiles/u44/name-map.tsv; binding
0x14207c110 -> wrapper 0x1419612c0 -> director vtable +0x2a0) takes (type, minRadius, maxRadius, bool, entity) and
returns the matching objects; stock use AristocratManagerSpawnScript keeps the points whose GetTag() == EMPTY_SYMBOL and
passes one as argument 1 of CreateRandomAgent / CreateAgent.

The row registers the module (it was not yet in the registry `modules` nor the registry corpus), copies the stock body
into the registry corpus (byte-identical in the registry build and 44.1.3) and appends the row. The search radii 10 m /
75 m are INFERRED choices (75 m = the stock ActiveAreaAhead/Behind default). Whether an explicit point keeps faction and
tier is INFERRED; visibility of the point is not checked. Live effect: pending.

Idempotent guard: refuses when the row already exists. Usage: python add_spawn_point_reuse_row.py
"""
import hashlib
import json
import shutil
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
EDITOR = HERE.parents[2]
sys.path.insert(0, str(EDITOR / 'RESEARCH/MISSIONS_SURVIVAL_ENEMIES_2026-10-30/tools'))
sys.path.insert(0, str(EDITOR / 'RESEARCH/UNIVERSAL_MISSION_REGISTRY_2026-09-29/tools'))
import add_survival_enemy_rows as BASE  # noqa: E402  (namehash, REGISTRY, BUILD, ROOT, STOCK, CURRENT)
from deluau import body_key, Module  # noqa: E402

TID = 'enemies.spawn_point_reuse'
FILE = 'Lotus_Scripts_Libs_EndlessSpawnLib.lua_B'
MODULE_PATH = 'Lotus.Scripts.Libs.EndlessSpawnLib'
KEY, SHA = '6f5169d34d076588', '986B39C756E2BDE5B44549832C553A0790E91EBF61F14D59A62397665B93CCBB'
PROTOTYPE, INSTRUCTION, METHOD = 9, 80, 'CreateRandomAgent'
QUERY_HASH = QUERY_ALIAS = '1ab54531'
TEMPLATE = 'NATIVE_CALL_RETRY_AT_SPAWN_POINT'
PROVENANCE = 'research:spawn-point-reuse-2026-11-01'


def check_alias():
    toolchain = BASE.ROOT / 'repos/toolchains/de-luau-toolchain/profiles/u44/name-map.tsv'
    pairs = [line.split() for line in toolchain.read_text(encoding='utf-8').splitlines() if line.strip()]
    targets = {b for a, b in pairs if a == QUERY_ALIAS}
    sources = {a for a, b in pairs if b == QUERY_HASH}
    if targets != {QUERY_HASH} or sources != {QUERY_ALIAS}:
        raise SystemExit(f'name-map: alias {QUERY_ALIAS} -> {targets}, sources of {QUERY_HASH}: {sources}')


def register_module(reg):
    """Module record + registry corpus copy (the stock body must be the same in the registry build and 44.1.3)."""
    raw = (BASE.STOCK / FILE).read_bytes()
    if raw != (BASE.CURRENT / FILE).read_bytes():
        raise SystemExit(f'{FILE}: 44.1.3 body differs from the registry build')
    if body_key(raw) != KEY or hashlib.sha256(raw).hexdigest().upper() != SHA:
        raise SystemExit(f'{FILE}: body key / SHA-256 is not the researched {KEY}')
    record = {'file': FILE, 'sha256': SHA, 'size': len(raw), 'module_path': MODULE_PATH}
    have = reg['modules'].get(KEY)
    if have is not None and have != record:
        raise SystemExit(f'registry module {KEY} exists with another record: {have}')
    reg['modules'][KEY] = record
    target = BASE.ROOT / reg['corpus'] / FILE
    if target.exists():
        if hashlib.sha256(target.read_bytes()).hexdigest().upper() != SHA:
            raise SystemExit(f'corpus file {target} is another body')
    else:
        shutil.copyfile(BASE.STOCK / FILE, target)
    return raw


def check_call(raw, seed):
    """The registered NAMECALL: prototype 9, instruction 80 names the hash of CreateRandomAgent (constant aux word)."""
    m = Module(raw)
    ins, consts = m.protos[PROTOTYPE]
    word = ins[INSTRUCTION][1]
    k = int.from_bytes(word[4:8], 'little') if len(word) == 8 else -1
    want = BASE.namehash(METHOD, seed).to_bytes(4, 'little')
    if not (0 <= k < len(consts) and consts[k][1] == want):
        raise SystemExit(f'prototype {PROTOTYPE} instruction {INSTRUCTION} is not a call of {METHOD}')
    sites = [(p, i) for p, (pins, pc) in enumerate(m.protos) for i, (_, w) in enumerate(pins)
             if len(w) == 8 and int.from_bytes(w[4:8], 'little') < len(pc) and pc[int.from_bytes(w[4:8], 'little')][1] == want]
    if sites != [(PROTOTYPE, INSTRUCTION)]:
        raise SystemExit(f'{METHOD} call sites are {sites}, expected only ({PROTOTYPE}, {INSTRUCTION})')


def main():
    reg = json.loads(BASE.REGISTRY.read_text(encoding='utf-8'))
    if reg['build'] != BASE.BUILD:
        raise SystemExit(f'registry build {reg["build"]} is not {BASE.BUILD}')
    if TID in {r['tunable_id'] for r in reg['tunables']}:
        raise SystemExit(f'{TID} is already a registry row')
    check_alias()
    seed = int(reg['name_hash_seed'], 16)
    raw = register_module(reg)
    check_call(raw, seed)
    label = 'Retry a failed endless spawn at a used spawn point (CreateRandomAgent)'
    limits = {'minimum': 0, 'maximum': 1, 'integer': True, 'basis': 'on/off: 0 = stock (off), 1 = on'}
    owner = {'body_key': KEY, 'stock_sha256': SHA, 'file': FILE, 'module_path': MODULE_PATH, 'template': TEMPLATE,
             'prototype': PROTOTYPE, 'instruction': INSTRUCTION, 'function': 'shared spawn-one-enemy helper (SpawnReinforcements and others)',
             'method': METHOD, 'method_hash': f'{BASE.namehash(METHOD, seed):08x}', 'argument_count': 5, 'location_argument': 2,
             'stock_call': 'director:CreateRandomAgent(nil, team, level, nil, eximusFlag)',
             'point_query': {'method': 'Name__' + QUERY_ALIAS, 'hash': QUERY_HASH, 'alias': QUERY_ALIAS,
                             'point_type': 'gNpcSpawnPointType', 'free_tag': 'EMPTY_SYMBOL', 'player': 'GetLeadPlayer',
                             'min_radius': 10, 'max_radius': 75,
                             'radii_basis': 'INFERRED choice: 75 m = stock ActiveAreaAhead/Behind default; 10 m keeps the spawn off the player',
                             'stock_precedent': 'AristocratManagerSpawnScript: director:Name__1ab54531(gNpcSpawnPointType, min, max, true, '
                                                'player), keeps GetTag() == EMPTY_SYMBOL, passes a point as argument 1 of CreateRandomAgent'},
             'host_only': True,
             'write_rule': 'host only; hooks.nativeCalls.CreateRandomAgent.after: only when the row is on, the caller is prototype 9, '
                           'the stock result is nil and stock passed no location: one more CreateRandomAgent at a random free-tag '
                           'spawn point near the lead player (pcall); a non-null agent replaces the nil result; nothing is cached',
             'meaning': 'stock nil location: the engine skips occupied spawn points (0x140d52569) and returns nil when all are taken; '
                        'an explicit point skips that search (0x141836a9f)'}
    row = {'tunable_id': TID, 'phase1_tunable_id': None, 'label': label, 'mission_type': 'All endless-spawn missions (EndlessSpawnLib)',
           'variant': 'all', 'shared_with': None, 'owner_kind': 'NATIVE_CALL_RETRY', 'backend': 'TARGET_ADDON', 'unit': 'bool',
           'stock': 0,
           'confidence': 'CONFIRMED_STATIC (call site from the stock bytecode; occupancy skip and explicit-point path from the exe); '
                         'faction/tier of an explicit-point spawn and the in-game effect INFERRED, under live test',
           'provenance': PROVENANCE, 'research_draft_id': TID,
           'evidence': 'EndlessSpawnLib P9 i80 NAMECALL CreateRandomAgent(nil, team, level, nil, eximus); nil location -> spawn '
                       'point search skips occupied points (0x140d52569); explicit point skips it (0x141836a9f); director method '
                       '1ab54531: binding 0x14207c110 -> wrapper 0x1419612c0 -> vtable +0x2a0 (44.1.3 exe).',
           'owner': owner, 'limits': limits, 'applies': 'F9',
           'backend_note': f'{TEMPLATE}: hooks.nativeCalls.{METHOD}.after at prototype {PROTOTYPE} (instruction {INSTRUCTION}).'}
    row['ui'] = {'group': 'enemies', 'mt_codes': [], 'short_label': label, 'label_source': 'id', 'scope_text': label,
                 'aliases': ['spawn point', 'spawn limit', 'more enemies'], 'lane': 'addon', 'applies': 'live_next_read',
                 'type': 'enum', 'editor': 'TOGGLE', 'unit': '', 'min': 0, 'max': 1,
                 'options': [{'label': 'Off', 'value': 0}, {'label': 'On', 'value': 1}], 'rank': 100000}
    reg['tunables'].append(row)
    BASE.REGISTRY.write_bytes((json.dumps(reg, indent=2, ensure_ascii=False) + '\n').encode('utf-8'))
    print('added:', TID, 'module', KEY)


if __name__ == '__main__':
    main()
