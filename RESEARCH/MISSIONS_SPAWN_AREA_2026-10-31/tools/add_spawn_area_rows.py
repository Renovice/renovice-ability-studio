"""2026-10-31: Enemies > All missions > Spawn area rows (AI_DIRECTOR_SETTER_AT_ENTRY, variant NO_GETTER).

Why (scratchpad research dirsetters + director, 44.1.3 exe, read-only): the AI director's Lua method with name hash
4f77b69c (U44; no recovered name, U43 alias b37ce12d in profiles/u44/name-map.tsv) takes (ahead, behind, zoneAhead,
zoneBehind) and writes ActiveAreaAhead +0x6c / ActiveAreaBehind +0x70 (f32) and ActiveZoneAhead/Behind +0x74/+0x75 (u8)
(wrapper 0x1419b57d0 -> vtable +0xa20 -> 0x1403c6410). /EE/Types/Npc/NpcAiDirector metadata: ActiveAreaAhead=75,
ActiveAreaBehind=75 (defaults, IsSet false). Stock Lua callers: HalloweenSalvage and ArchWing call it with
(250, 150, false, false). There is no Lua getter, so the rows use the NO_GETTER variant: written once per director at the
ProceduralLevel entries the hard cap uses (P65 InitializeWithAIXpPool, P2 TrackTaggedEntities setup), host only; both
rows feed ONE call (a row that is off passes its stock); cleanup calls the setter with the stock (75, 75, false, false).
The ActiveZone stock (false, false) is INFERRED from the stock callers (no metadata default was found).

Idempotent guard: refuses when a row id already exists. Usage: python add_spawn_area_rows.py
"""
import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
EDITOR = HERE.parents[2]
sys.path.insert(0, str(EDITOR / 'RESEARCH/MISSIONS_SURVIVAL_ENEMIES_2026-10-30/tools'))
sys.path.insert(0, str(EDITOR / 'RESEARCH/UNIVERSAL_MISSION_REGISTRY_2026-09-29/tools'))
import add_survival_enemy_rows as BASE  # noqa: E402  (module_record, namehash, REGISTRY, BUILD, LEVEL)
import mission_owner_specs as SPECS  # noqa: E402
from addon_owner import RootTables  # noqa: E402

PROVENANCE = 'research:spawn-area-2026-10-31'
SETTER_HASH, SETTER_ALIAS = '4f77b69c', 'b37ce12d'
STOCK_ARGUMENTS = [75, 75, False, False]
ROWS = [('enemies.active_area_ahead', 1, 'AI director active area ahead of players (ActiveAreaAhead)', 'ActiveAreaAhead +0x6c'),
        ('enemies.active_area_behind', 2, 'AI director active area behind players (ActiveAreaBehind)', 'ActiveAreaBehind +0x70')]


def check_alias():
    toolchain = BASE.ROOT / 'repos/toolchains/de-luau-toolchain/profiles/u44/name-map.tsv'
    pairs = [line.split() for line in toolchain.read_text(encoding='utf-8').splitlines() if line.strip()]
    targets = {b for a, b in pairs if a == SETTER_ALIAS}
    sources = {a for a, b in pairs if b == SETTER_HASH}
    if targets != {SETTER_HASH} or sources != {SETTER_ALIAS}:
        raise SystemExit(f'name-map: alias {SETTER_ALIAS} -> {targets}, sources of {SETTER_HASH}: {sources}')


def spawn_rows(reg, ids):
    raw, key, rec = BASE.module_record(reg, BASE.LEVEL)
    seed = int(reg['name_hash_seed'], 16)

    class Ctx:
        @staticmethod
        def namehash(name):
            return BASE.namehash(name, seed)

    rows = []
    for tid, argument, label, field in ROWS:
        if tid in ids:
            raise SystemExit(f'{tid} is already a registry row')
        limits = {'minimum': 10, 'maximum': 1000, 'integer': False,
                  'basis': 'numeric guard only (stock callers use 150..250); gameplay-safe range not established offline'}
        d = {'stock': 75, 'limits': limits,
             'owner': {'template': SPECS.AI_DIRECTOR_SETTER, 'variant': SPECS.AI_DIRECTOR_NO_GETTER,
                       'setter': 'Name__' + SETTER_ALIAS, 'setter_hash': SETTER_HASH, 'setter_alias': SETTER_ALIAS,
                       'stock_arguments': STOCK_ARGUMENTS, 'argument': argument,
                       'entries': [{'prototype': 65, 'function': 'InitializeWithAIXpPool', 'role': 'level entry'},
                                   {'prototype': 2, 'function': 'director TrackTaggedEntities setup',
                                    'role': 'called once by prototype 65 after npcMgr:CanFind() and GetAiDirector()'}],
                       'readers': [{'key': 'GetAiDirector', 'prototype': 65, 'instructions': [85]},
                                   {'key': 'GetAiDirector', 'prototype': 2, 'instructions': [3]}],
                       'write_rule': 'host only; no Lua getter: director method 4f77b69c(ahead, behind, false, false) once per '
                                     'director at the level entry, before the mode scripts run (a mode script that sets its '
                                     'own area, HalloweenSalvage/ArchWing (250,150,false,false), runs later and wins); both '
                                     'rows feed one call, a row that is off passes its stock 75; nothing is written when '
                                     'both are stock; cleanup calls it with the stock (75, 75, false, false)',
                       'meaning': f'{field} (f32, metres); the same call writes ActiveZoneAhead/Behind +0x74/+0x75 = false',
                       'stock_precedent': 'HalloweenSalvage and ArchWing call director:Name__4f77b69c(250, 150, false, false)'}}
        base = {'tunable_id': tid, 'phase1_tunable_id': None, 'label': label, 'mission_type': 'All procedural missions',
                'variant': 'all', 'shared_with': 'enemies.active_area_ahead/behind share one setter call',
                'owner_kind': 'AI_DIRECTOR_VALUE', 'backend': 'TARGET_ADDON', 'unit': 'm', 'stock': 75,
                'confidence': 'CONFIRMED_STATIC (setter field writes from the exe; stock 75 from NpcAiDirector metadata); '
                              'ActiveZone stock false INFERRED from the stock callers',
                'provenance': PROVENANCE, 'research_draft_id': tid,
                'evidence': 'Director method 4f77b69c: wrapper 0x1419b57d0 -> vtable +0xa20 -> 0x1403c6410 writes +0x6c, +0x70 '
                            '(f32) and +0x74, +0x75 (u8) (44.1.3 exe). /EE/Types/Npc/NpcAiDirector ActiveAreaAhead=75, '
                            'ActiveAreaBehind=75. ProceduralLevel P65 obtains the director (i85) and calls P2 (i3).'}
        row = SPECS.entry_row(Ctx, RootTables(raw), key, rec, d, base, dict(limits), tid)
        row['ui'] = {'group': 'enemies', 'mt_codes': [], 'short_label': label, 'label_source': 'id', 'scope_text': label,
                     'aliases': ['spawn area', 'spawn distance', 'active area'], 'lane': 'addon', 'applies': 'next_mission',
                     'type': 'float', 'editor': 'INPUTBOX', 'unit': 'm', 'min': 10, 'max': 1000, 'rank': 100000}
        rows.append(row)
    return rows


def main():
    check_alias()
    reg = json.loads(BASE.REGISTRY.read_text(encoding='utf-8'))
    if reg['build'] != BASE.BUILD:
        raise SystemExit(f'registry build {reg["build"]} is not {BASE.BUILD}')
    ids = {r['tunable_id'] for r in reg['tunables']}
    rows = spawn_rows(reg, ids)
    reg['tunables'] += rows
    BASE.REGISTRY.write_bytes((json.dumps(reg, indent=2, ensure_ascii=False) + '\n').encode('utf-8'))
    print('added:', ', '.join(r['tunable_id'] for r in rows))


if __name__ == '__main__':
    main()
