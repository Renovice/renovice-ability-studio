"""2026-10-31: Enemies > All missions > Spawn pacing / Intensity rows (OBJECT_FIELD_AT_ENTRY, locator ai_director).

Why: the bootstrapper publishes _T.RENOVICE.object (OBJECT_REFLECTION_V1, live-verified 2026-10-31 on the AI director:
get/set by metadata or engine field name). These rows write AI director fields that have no Lua setter through that API,
at the same ProceduralLevel entries the hard cap uses (P65 InitializeWithAIXpPool, P2 TrackTaggedEntities setup), host
only; written only when the live value is the stock (float32 tolerance), cleanup puts the stock back.

Stock values (44.1.3 exe, read-only; scratchpad director/ctor disassembly; /EE/Types/Npc/NpcAiDirector metadata):
  NpcAiDirector constructor stores (rbx = director): +0x158 IntensityMax 0x42c80000 = 100.0; +0x178
  IntensityPeakPercentage 0x3f733333 = 0.95; +0x17c IntensityHoldSpawnsPercentage 0x3f800000 = 1.0; +0x188 AfterPeakTime
  0x41a00000 = 20.0; +0x18c AfterHoldTime 20.0; +0x1c8 MaxEncounterXp 0x447a0000 = 1000.0; +0x2ac SpawnTimer 1.0;
  +0x2c8 EventTimer 0x40800000 = 4.0; +0x2d8 EventCountMax 6 (constructor 0x140e0c380.., 0x140e0c55c..0x140e0c6be).
  Metadata text overrides only SpawnTimer (=0.1) among these (live get: SpawnTimer 0.1). So stock = metadata where set,
  constructor default otherwise. Field names are the metadata spelling (engine name without the leading m).
Effect on gameplay of a changed value is NOT verified (OBJECT_REFLECTION_V1: derived/cached values are not recomputed).

Idempotent guard: refuses when a row id already exists. Usage: python add_director_field_rows.py
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

PROVENANCE = 'research:director-fields-2026-10-31'
CTOR = 'NpcAiDirector constructor (44.1.3 exe, 0x140e0c380..)'
# (id, field, type, stock, min, max, unit, label, stock source, aliases)
ROWS = [
    ('enemies.spawn_timer', 'SpawnTimer', 'float', 0.1, 0.01, 10, 's', 'AI director spawn tick (SpawnTimer)',
     'metadata SpawnTimer=0.1 (constructor 1.0 at +0x2ac); live get 0.1', ['spawn rate', 'spawn speed', 'spawn timer']),
    ('enemies.event_timer', 'EventTimer', 'float', 4, 0.1, 60, 's', 'AI director spawn event interval (EventTimer)',
     f'{CTOR}: +0x2c8 = 4.0; not in metadata', ['spawn event', 'event timer']),
    ('enemies.event_count_max', 'EventCountMax', 'int', 6, 1, 100, '', 'AI director spawn events at once (EventCountMax)',
     f'{CTOR}: +0x2d8 = 6; not in metadata', ['spawn events', 'event count']),
    ('enemies.max_encounter_xp', 'MaxEncounterXp', 'float', 1000, 1, 100000, 'XP', 'AI director spawn wave budget (MaxEncounterXp)',
     f'{CTOR}: +0x1c8 = 1000.0; not in metadata', ['spawn wave', 'encounter xp', 'wave budget']),
    ('enemies.intensity_max', 'IntensityMax', 'float', 100, 1, 10000, '', 'AI director intensity maximum (IntensityMax)',
     f'{CTOR}: +0x158 = 100.0; not in metadata', ['intensity']),
    ('enemies.intensity_peak_pct', 'IntensityPeakPercentage', 'float', 0.95, 0.05, 1, 'fraction',
     'AI director intensity peak fraction (IntensityPeakPercentage)', f'{CTOR}: +0x178 = 0.95; not in metadata', ['intensity peak']),
    ('enemies.intensity_hold_spawns_pct', 'IntensityHoldSpawnsPercentage', 'float', 1, 0, 1, 'fraction',
     'AI director hold-spawns fraction (IntensityHoldSpawnsPercentage)', f'{CTOR}: +0x17c = 1.0; not in metadata',
     ['hold spawns']),
    ('enemies.after_peak_time', 'AfterPeakTime', 'float', 20, 0, 600, 's', 'AI director calm time after peak (AfterPeakTime)',
     f'{CTOR}: +0x188 = 20.0; not in metadata', ['after peak']),
    ('enemies.after_hold_time', 'AfterHoldTime', 'float', 20, 0, 600, 's', 'AI director hold time (AfterHoldTime)',
     f'{CTOR}: +0x18c = 20.0; not in metadata', ['after hold']),
]


def director_rows(reg, ids):
    raw, key, rec = BASE.module_record(reg, BASE.LEVEL)
    seed = int(reg['name_hash_seed'], 16)

    class Ctx:
        @staticmethod
        def namehash(name):
            return BASE.namehash(name, seed)

    rows = []
    for tid, field, kind, stock, lo, hi, unit, label, source, aliases in ROWS:
        if tid in ids:
            raise SystemExit(f'{tid} is already a registry row')
        limits = {'minimum': lo, 'maximum': hi, 'integer': kind == 'int',
                  'basis': 'numeric guard only; gameplay-safe range not established offline'}
        d = {'stock': stock, 'limits': limits,
             'owner': {'template': SPECS.OBJECT_FIELD, 'locator': 'ai_director', 'field': field, 'value_type': kind,
                       'entries': [{'prototype': 65, 'function': 'InitializeWithAIXpPool', 'role': 'level entry'},
                                   {'prototype': 2, 'function': 'director TrackTaggedEntities setup',
                                    'role': 'called once by prototype 65 after npcMgr:CanFind() and GetAiDirector()'}],
                       'readers': [{'key': 'GetAiDirector', 'prototype': 65, 'instructions': [85]},
                                   {'key': 'GetAiDirector', 'prototype': 2, 'instructions': [3]}],
                       'write_rule': f'host only; _T.RENOVICE.object.set(director, "{field}", value) when get() is the '
                                     f'stock {stock} (float32 tolerance); nothing when it already holds the value; another '
                                     'value is left alone (one line); RENOVICE.object missing -> one line, nothing written; '
                                     'cleanup sets the stock back where the written value is still there',
                       'meaning': f'NpcAiDirector {field} ({kind}); gameplay effect of a change unverified',
                       'stock_precedent': source}}
        base = {'tunable_id': tid, 'phase1_tunable_id': None, 'label': label, 'mission_type': 'All procedural missions',
                'variant': 'all', 'shared_with': '', 'owner_kind': 'AI_DIRECTOR_VALUE', 'backend': 'TARGET_ADDON',
                'unit': unit, 'stock': stock,
                'confidence': 'CONFIRMED_STATIC (field and stock from the exe constructor / metadata; write path '
                              'RENOVICE.object live-verified on the director 2026-10-31); gameplay effect unverified',
                'provenance': PROVENANCE, 'research_draft_id': tid,
                'evidence': f'{field}: {source}. ProceduralLevel P65 obtains the director (i85) and calls P2 (i3).'}
        row = SPECS.entry_row(Ctx, RootTables(raw), key, rec, d, base, dict(limits), tid)
        row['ui'] = {'group': 'enemies', 'mt_codes': [], 'short_label': label, 'label_source': 'id', 'scope_text': label,
                     'aliases': aliases, 'lane': 'addon', 'applies': 'next_mission', 'type': kind,
                     'editor': 'INPUTCOUNT' if kind == 'int' else 'INPUTBOX', 'unit': unit, 'min': lo, 'max': hi,
                     'rank': 100000}
        rows.append(row)
    return rows


def main():
    reg = json.loads(BASE.REGISTRY.read_text(encoding='utf-8'))
    if reg['build'] != BASE.BUILD:
        raise SystemExit(f'registry build {reg["build"]} is not {BASE.BUILD}')
    ids = {r['tunable_id'] for r in reg['tunables']}
    rows = director_rows(reg, ids)
    reg['tunables'] += rows
    BASE.REGISTRY.write_bytes((json.dumps(reg, indent=2, ensure_ascii=False) + '\n').encode('utf-8'))
    print('added:', ', '.join(r['tunable_id'] for r in rows))


if __name__ == '__main__':
    main()
