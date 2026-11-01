"""2026-11-01: Enemies > All missions > Relocate instead of spawn at (AI_DIRECTOR_SETTER_AT_ENTRY, variant NO_GETTER).

Why (scratchpad research ceiling/report.json, 44.1.3 exe, read-only): CreateRandomAgent (0x141836930) calls 0x1418b3dc0
(at 0x141836983), which relocates an existing agent instead of creating a new one when director +0x120 exceeds
hard cap x f32 +0x6b4 while byte +0x6b8 is set. Director method 0a7324fb(float) writes +0x6b4 clamped to [0, 1.0]
(0x140f27630: minss 1.0, maxss 0); constructor default 0.75; no Lua getter, so NO_GETTER, stock argument [0.75].
No U43 alias: identity line 0a7324fb 0a7324fb in profiles/u44/name-map.tsv (2026-11-01). Whether this gate sets the
flat ~260 Survival plateau (live 2026-11-01 00:24 run) is INFERRED; this row is the live test. Same entries as the spawn
area rows (ProceduralLevel P65/P2), host only; cleanup calls it with 0.75.

Idempotent guard: refuses when the row id already exists. Usage: python add_relocate_fraction_row.py
"""
import json

import add_spawn_area_rows as AREA  # noqa: E402  (sets sys.path)
from add_spawn_area_rows import BASE, SPECS, RootTables  # noqa: E402

TID = 'enemies.relocate_fraction'
HASH = '0a7324fb'


def main():
    reg = json.loads(BASE.REGISTRY.read_text(encoding='utf-8'))
    if reg['build'] != BASE.BUILD:
        raise SystemExit(f'registry build {reg["build"]} is not {BASE.BUILD}')
    if TID in {r['tunable_id'] for r in reg['tunables']}:
        raise SystemExit(f'{TID} is already a registry row')
    raw, key, rec = BASE.module_record(reg, BASE.LEVEL)
    seed = int(reg['name_hash_seed'], 16)

    class Ctx:
        @staticmethod
        def namehash(name):
            return BASE.namehash(name, seed)

    label = 'AI director relocate-instead-of-create fraction of the hard cap (+0x6b4)'
    limits = {'minimum': 0.05, 'maximum': 1, 'integer': False,
              'basis': 'the setter clamps to [0, 1.0] (0x140f27630); 0.05 floor is a numeric guard'}
    d = {'stock': 0.75, 'limits': limits,
         'owner': {'template': SPECS.AI_DIRECTOR_SETTER, 'variant': SPECS.AI_DIRECTOR_NO_GETTER,
                   'setter': 'Name__' + HASH, 'setter_hash': HASH, 'setter_alias': HASH,
                   'stock_arguments': [0.75], 'argument': 1,
                   'entries': [{'prototype': 65, 'function': 'InitializeWithAIXpPool', 'role': 'level entry'},
                               {'prototype': 2, 'function': 'director TrackTaggedEntities setup',
                                'role': 'called once by prototype 65 after npcMgr:CanFind() and GetAiDirector()'}],
                   'readers': [{'key': 'GetAiDirector', 'prototype': 65, 'instructions': [85]},
                               {'key': 'GetAiDirector', 'prototype': 2, 'instructions': [3]}],
                   'write_rule': 'host only; no Lua getter: director method 0a7324fb(fraction) once per director at the level '
                                 'entry; nothing is written at stock 0.75; cleanup calls it with 0.75',
                   'meaning': 'f32 +0x6b4: above hard cap x this, CreateRandomAgent relocates an agent instead of creating one (0x1418b3dc0)',
                   'stock_precedent': 'none found (constructor default 0.75)'}}
    base = {'tunable_id': TID, 'phase1_tunable_id': None, 'label': label, 'mission_type': 'All procedural missions',
            'variant': 'all', 'shared_with': None,
            'owner_kind': 'AI_DIRECTOR_VALUE', 'backend': 'TARGET_ADDON', 'unit': 'fraction', 'stock': 0.75,
            'confidence': 'CONFIRMED_STATIC (setter write+clamp and gate read from the exe; default 0.75 from the constructor); '
                          'effect on the Survival plateau INFERRED, under live test',
            'provenance': 'research:ceiling-2026-11-01', 'research_draft_id': TID,
            'evidence': 'Binding 0a7324fb -> 0x140f27630 writes director f32 +0x6b4 clamped [0,1]; gate 0x1418b3dc0 called '
                        'from CreateRandomAgent at 0x141836983 compares +0x120 with hard cap x +0x6b4 (44.1.3 exe).'}
    row = SPECS.entry_row(Ctx, RootTables(raw), key, rec, d, base, dict(limits), TID)
    row['ui'] = {'group': 'enemies', 'mt_codes': [], 'short_label': label, 'label_source': 'id', 'scope_text': label,
                 'aliases': ['relocate', 'teleport enemies', 'spawn limit'], 'lane': 'addon', 'applies': 'next_mission',
                 'type': 'float', 'editor': 'INPUTBOX', 'unit': 'fraction', 'min': 0.05, 'max': 1, 'rank': 100000}
    reg['tunables'].append(row)
    BASE.REGISTRY.write_bytes((json.dumps(reg, indent=2, ensure_ascii=False) + '\n').encode('utf-8'))
    print('added:', TID)


if __name__ == '__main__':
    main()
