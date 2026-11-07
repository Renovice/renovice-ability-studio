"""R24 (2026-11-07): add the Descendia reader-pin rows (inputs/r24_row_drafts.json) to the current registry.

Each draft site is turned into the two LIVE_LITERALS_V1 instruction sites of IMPORT_READ_PIN_V1 by the R15 functions in
mission_owner_specs.py (import_pin_sites: raw U44 GETIMPORT, single-name aux, hashed name == namehash(global); then
import_pin_complete: the whole-module census of the hash equals the pinned reads). The consumer bodies must be identical
in the registry build and 44.1.3. Rows land under SCRIPT SETTINGS > Descendia > <mode>, lane literal, applies next mission.

Idempotent: ids already in the registry are skipped. Usage: python add_r24_rows.py
"""
import hashlib
import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
R24 = HERE.parent
EDITOR = HERE.parents[2]
sys.path.insert(0, str(EDITOR / 'RESEARCH/MISSIONS_SURVIVAL_ENEMIES_2026-10-30/tools'))
sys.path.insert(0, str(EDITOR / 'RESEARCH/UNIVERSAL_MISSION_REGISTRY_2026-09-29/tools'))
import add_survival_enemy_rows as BASE  # noqa: E402  (namehash, REGISTRY, BUILD, ROOT, STOCK, CURRENT)
from deluau import body_key, Module  # noqa: E402
import mission_owner_specs as SPECS  # noqa: E402

DRAFTS = R24 / 'inputs/r24_row_drafts.json'
PROVENANCE = 'research:descendia-pins-2026-11-07 (contract R24)'
GROUP = {  # mode slug -> (registry ui group, settings page label)
    'alchemy': ('alchemy', 'Alchemy'),
    'excavation': ('coh_excavation', 'Excavation'),
    'mobile_interception': ('cohinterception', 'Mobile Interception'),
    'legacyte_harvest': ('infested_capture', 'Legacyte Harvest'),
    'meltdown': ('meltdown', 'Meltdown'),
    'shrine_defense': ('shrine', 'Shrine Defense'),
}
SHORT = {  # player-facing row names (the registry labels stay the research text)
    'crucible_remind_countdown': 'Crucible reminder time',
    'transmuter_goal': 'Mixtures required',
    'base_excavator_health': 'Excavator health',
    'base_excavator_shields': 'Excavator shields',
    'beacon_chase_target_time': 'Beacon progress time',
    'base_number_of_mutations': 'Legacyte mutations',
    'searching_rounds_before_boss': 'Search rounds before boss',
    'kalymos_search_spot_range': 'Kalymos search spot range',
    'base_tentacle_health': 'Tentacle health',
    'wander_radius': 'Kalymos wander radius',
    'wander_time': 'Kalymos wander time',
    'in_range_multiplier': 'Scan speed in range (x)',
    'start_mission_delay': 'Meltdown start delay',
    'vent_search_distance': 'Vent search distance',
    'vents_to_reveal': 'Vents revealed per round',
    'boss_offering_num': 'Boss stage offerings',
    'defend_huts_offering_num': 'Defend stage offerings',
    'offering_generation_time': 'Offering generation time',
    'spawn_point_filter_distance': 'Enemy spawn spacing',
}
DESC = {  # one-sentence player descriptions (no code names)
    'crucible_remind_countdown': 'Seconds before the reminder to use the crucible appears',
    'transmuter_goal': 'Mixtures to complete before the floor ends',
    'base_excavator_health': 'Health of each excavator before level scaling',
    'base_excavator_shields': 'Shields of each excavator before level scaling',
    'beacon_chase_target_time': 'Seconds you must stay with the moving beacon to complete it',
    'base_number_of_mutations': 'Abilities the Legacyte starts with',
    'searching_rounds_before_boss': 'Search rounds before the Legacyte appears',
    'kalymos_search_spot_range': 'Distance Kalymos searches for its next spot',
    'base_tentacle_health': 'Health of each tentacle before level scaling',
    'wander_radius': 'Radius Kalymos wanders in at a search spot',
    'wander_time': 'Seconds Kalymos wanders before moving on',
    'in_range_multiplier': 'Vent scan speed multiplier while you stand in range',
    'start_mission_delay': 'Seconds before the meltdown starts',
    'vent_search_distance': 'Distance within which vents are chosen',
    'vents_to_reveal': 'Vents revealed each round',
    'boss_offering_num': 'Offerings needed in the boss stage',
    'defend_huts_offering_num': 'Offerings needed to finish the defend stage',
    'offering_generation_time': 'Seconds to generate one offering',
    'spawn_point_filter_distance': 'Minimum distance between enemy spawn points and players',
}
EDITOR_KIND = {'s': 'INPUTBOX', 'm': 'INPUTBOX'}


def main():
    reg = json.loads(BASE.REGISTRY.read_text(encoding='utf-8'))
    if reg['build'] != BASE.BUILD:
        raise SystemExit(f'registry build {reg["build"]} is not {BASE.BUILD}')
    drafts = json.loads(DRAFTS.read_text(encoding='utf-8'))
    have = {r['tunable_id'] for r in reg['tunables']}
    seed = int(reg['name_hash_seed'], 16)
    namehash = lambda name: BASE.namehash(name, seed)  # noqa: E731
    added = []
    for d in drafts['rows']:
        # Registry rule: a row's ui group is its tunable_id family, so the draft id descendia.<mode>.<name> becomes
        # <group>.descendia_<name>.
        slug, key = d['tunable_id'].split('.')[1], d['tunable_id'].split('.', 2)[2]
        group, page = GROUP[slug]
        tid = f'{group}.descendia_{key}'
        if tid in have:
            print('  already a registry row:', tid)
            continue
        o = d['owner']
        raw = (BASE.STOCK / o['file']).read_bytes()
        if raw != (BASE.CURRENT / o['file']).read_bytes():
            raise SystemExit(f'{o["file"]}: 44.1.3 body differs from the registry build')
        if body_key(raw) != o['body_key'] or hashlib.sha256(raw).hexdigest().upper() != o['stock_sha256'].upper():
            raise SystemExit(f'{o["file"]}: body key / SHA-256 differs from the draft')
        if o['body_key'] not in reg['modules']:
            raise SystemExit(f'{o["file"]}: module {o["body_key"]} is not a registry module')
        m = Module(raw)
        sites = []
        for s in o['sites']:
            sites += SPECS.import_pin_sites(m, s, namehash, tid)
        pins = SPECS.import_pin_complete(m, sites, namehash, tid)
        lim = d['limits']
        unit = d['unit'] if d['unit'] and d['unit'] != '-' else ''
        row = {
            'tunable_id': tid, 'phase1_tunable_id': None, 'label': d['label'], 'mission_type': d['mission_type'],
            'variant': d['variant'], 'shared_with': d['shared_with'], 'owner_kind': 'SCRIPT_PARAM_GLOBAL',
            'backend': 'EXACT_LITERAL',
            'owner': {k: o[k] for k in ('body_key', 'stock_sha256', 'file', 'module_path')} | {'sites': sites},
            'unit': d['unit'], 'stock': d['stock'], 'limits': lim, 'applies': 'next_mission',
            'confidence': d['confidence'], 'provenance': PROVENANCE, 'evidence': d['evidence'],
            'research_draft_id': d['tunable_id'],
            'backend_note': f'{len(o["sites"])} pinned GETIMPORT read(s) (IMPORT_READ_PIN_V1): {json.dumps(pins)}',
        }
        short = SHORT.get(key, d['label'])
        scope = (f'{DESC[key]} on a Descendia {page} floor, default {d["stock"]}.'
                 + (f' Also applies to {d["shared_with"]}.' if d['shared_with'] else ''))
        row['ui'] = {'group': group, 'mt_codes': ['MT_DESCENT'], 'short_label': short,
                     'label_source': 'player_text', 'scope_text': scope, 'aliases': ['Descendia', page],
                     'lane': 'literal', 'applies': 'next_mission', 'type': 'int', 'editor': 'INPUTCOUNT',
                     'unit': unit, 'min': lim['minimum'], 'max': lim['maximum'], 'rank': 100000,
                     'path': ['Descendia', page], 'row': short, 'r5_scope_text': scope}
        reg['tunables'].append(row)
        added.append(tid)
    BASE.REGISTRY.write_bytes((json.dumps(reg, indent=2, ensure_ascii=False) + '\n').encode('utf-8'))
    print(f'added {len(added)} rows:')
    for tid in added:
        print(' ', tid)


if __name__ == '__main__':
    main()
