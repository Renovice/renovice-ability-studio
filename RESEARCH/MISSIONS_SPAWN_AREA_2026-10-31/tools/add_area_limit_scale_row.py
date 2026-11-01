"""2026-10-31: Enemies > All missions > Enemies per area multiplier (AI_DIRECTOR_SETTER_AT_ENTRY, variant NO_GETTER).

Why (scratchpad research throughput/report.json, 44.1.3 exe, read-only): CreateRandomAgent (0x141836930) asks the director's
spawn-point search (vtable +0x280, 0x1415bb2d0), which filters areas through vtable +0x150 (0x14136c8a0): an area whose
active count is at or over its block-type limit (Connector/Intermediate/Objective) x 100 x NumPlayerLimitScales x f32
+0x6c4 x f32 +0x60c is not a spawn location. Director method 5904fb7a(float) writes +0x6c4 (0x141231e60); constructor
default 1.0; no stock Lua caller and no Lua getter, so NO_GETTER, stock argument [1]. It has no U43 alias: it is spelled
Name__5904fb7a (identity line 5904fb7a 5904fb7a in profiles/u44/name-map.tsv, 2026-10-31). Whether this limit sets the ~200 Survival
plateau is INFERRED; this row is the live test. Same entries as the spawn area rows (ProceduralLevel P65/P2), host only;
cleanup calls it with 1.0.

Idempotent guard: refuses when the row id already exists. Usage: python add_area_limit_scale_row.py
"""
import json

import add_spawn_area_rows as AREA  # noqa: E402  (sets sys.path)
from add_spawn_area_rows import BASE, SPECS, RootTables  # noqa: E402

TID = 'enemies.area_limit_scale'
HASH = '5904fb7a'


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

    label = 'AI director per-area enemy limit scale (+0x6c4)'
    limits = {'minimum': 0.1, 'maximum': 100, 'integer': False,
              'basis': 'numeric guard only; no stock caller, gameplay-safe range not established offline'}
    d = {'stock': 1, 'limits': limits,
         'owner': {'template': SPECS.AI_DIRECTOR_SETTER, 'variant': SPECS.AI_DIRECTOR_NO_GETTER,
                   'setter': 'Name__' + HASH, 'setter_hash': HASH, 'setter_alias': HASH,
                   'stock_arguments': [1], 'argument': 1,
                   'entries': [{'prototype': 65, 'function': 'InitializeWithAIXpPool', 'role': 'level entry'},
                               {'prototype': 2, 'function': 'director TrackTaggedEntities setup',
                                'role': 'called once by prototype 65 after npcMgr:CanFind() and GetAiDirector()'}],
                   'readers': [{'key': 'GetAiDirector', 'prototype': 65, 'instructions': [85]},
                               {'key': 'GetAiDirector', 'prototype': 2, 'instructions': [3]}],
                   'write_rule': 'host only; no Lua getter: director method 5904fb7a(scale) once per director at the level '
                                 'entry; nothing is written at stock 1.0; cleanup calls it with 1.0',
                   'meaning': 'f32 +0x6c4, a factor of every area block-type spawn limit (area filter vtable +0x150)',
                   'stock_precedent': 'none (no stock Lua caller; constructor default 1.0)'}}
    base = {'tunable_id': TID, 'phase1_tunable_id': None, 'label': label, 'mission_type': 'All procedural missions',
            'variant': 'all', 'shared_with': None,
            'owner_kind': 'AI_DIRECTOR_VALUE', 'backend': 'TARGET_ADDON', 'unit': 'x', 'stock': 1,
            'confidence': 'CONFIRMED_STATIC (setter write and area-filter read from the exe; default 1.0 from the constructor); '
                          'effect on the Survival plateau INFERRED, under live test',
            'provenance': 'research:area-limit-2026-10-31', 'research_draft_id': TID,
            'evidence': 'Binding 5904fb7a -> 0x141231e60 writes director f32 +0x6c4; area filter 0x14136c8a0 (vtable +0x150, '
                        'called from +0x280 at 0x1415bb363) multiplies each block-type limit by it (44.1.3 exe).'}
    row = SPECS.entry_row(Ctx, RootTables(raw), key, rec, d, base, dict(limits), TID)
    row['ui'] = {'group': 'enemies', 'mt_codes': [], 'short_label': label, 'label_source': 'id', 'scope_text': label,
                 'aliases': ['area limit', 'enemies per area', 'spawn limit'], 'lane': 'addon', 'applies': 'next_mission',
                 'type': 'float', 'editor': 'INPUTBOX', 'unit': 'x', 'min': 0.1, 'max': 100, 'rank': 100000}
    reg['tunables'].append(row)
    BASE.REGISTRY.write_bytes((json.dumps(reg, indent=2, ensure_ascii=False) + '\n').encode('utf-8'))
    print('added:', TID)


if __name__ == '__main__':
    main()
