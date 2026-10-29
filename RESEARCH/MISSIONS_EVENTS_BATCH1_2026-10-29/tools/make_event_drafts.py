"""2026-10-29: Events batch 1 row drafts (GOAL_TAG variant), built from the proven count rows of each mission type.

Events (OpenWF worldStateService, config worldState.anniversary / worldState.longShadow): each mission key carries the
goal Tag the server sends (checked against worldStateService.ts). The Long Shadow goal can instead carry
"Anniversary2020TacAlert" when unfaithfulBugFixes.useAnniversaryTagForOldGoals is on; both are listed.
Keys and stocks: Packages.bin 2026.10.22.13.12 (probe.exe meta, parents resolved): Mission.missionType, maxWaveNum.
Type numbers: ExportMissionTypes index (MT_SURVIVAL 2, MT_DEFENSE 8, MT_MOBILE_DEFENSE 9, MT_TERRITORY 13,
MT_EXCAVATE 17, MT_ARTIFACT 33; 2, 8, 9 and 13 are live-proven by Clem and Proxy Rebellion).
Tags shared by two rows are told apart by mission type and stock (the write happens only when both match), e.g.
Anniversary2019TacAlert: Proxy Rebellion alias (Defense 10/20, Interception 3, Survival 20) vs 2019E (Defense 6).
Not drafted (no proven write point for the field or no stock length): Exterminate 2017A/2025B/2025D, Hive 2020H,
Purify 2022J, endless keys (Orphix Venom, Nightwatch Bonus, Lantern D), special modes; Hallowed Flame Lantern A-C
(Survival stock 300/420/600 is not the Survival minutes meaning) is held for a separate check.
Usage: python make_event_drafts.py  (writes ../inputs/event_batch1_row_drafts.json)
"""
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
EDITOR = HERE.parents[2]
reg = json.loads((EDITOR / 'REGISTRIES/mission_build_u44.json').read_text(encoding='utf-8'))
rows = {r['tunable_id']: r for r in reg['tunables']}
ACCESSOR = rows['clem.survival_minutes']['owner']['accessor']

# type name -> (proven count row whose owner is reused, type number, unit, maximum, editor word)
TYPES = {
    'Defense': ('defense.waves_to_finish', 8, '', 100, 'waves'),
    'Interception': ('interception.rounds_to_finish', 13, '', 20, 'rounds'),
    'Survival': ('clem.survival_minutes', 2, 'min', 60, 'min'),
    'Mobile Defense': ('clem.mobiledefense_seconds', 9, 's', 3600, 's'),
    'Disruption': ('disruption.icebind_conduits', 33, '', 50, 'conduits'),
    'Excavation': ('excavation.icebind_excavators', 17, '', 50, 'excavators'),
}
NIGHTWATCH = ['NightwatchTacAlert', 'Anniversary2020TacAlert']
# id, group, group label, mission label, type, key, tags, stock
SPECS = [
    ('anniversary.2017b_defense_waves', 'anniversary', '2017: Defense', 'Defense', 'TacAlertKeyAnniversary2017B', ['Anniversary2018TacAlert'], 6),
    ('anniversary.2017c_interception_rounds', 'anniversary', '2017: Interception', 'Interception', 'TacAlertKeyAnniversary2017C', ['Anniversary2018TacAlert'], 2),
    ('anniversary.2018d_survival_minutes', 'anniversary', '2018: Survival', 'Survival', 'TacAlertKeyAnniversary2018D', ['Anniversary2018TacAlert'], 10),
    ('anniversary.2019e_defense_waves', 'anniversary', '2019: Defense', 'Defense', 'TacAlertKeyAnniversary2019E', ['Anniversary2019TacAlert'], 6),
    ('anniversary.2020f_disruption_conduits', 'anniversary', '2020: Disruption', 'Disruption', 'TacAlertKeyAnniversary2020F', ['Anniversary2020TacAlert'], 8),
    ('anniversary.2020g_mobiledefense_seconds', 'anniversary', '2020: Mobile Defense', 'Mobile Defense', 'TacAlertKeyAnniversary2020G', ['Anniversary2020TacAlert'], 540),
    ('anniversary.2021i_excavation_excavators', 'anniversary', '2021: Excavation', 'Excavation', 'TacAlertKeyAnniversary2021I', ['Anniversary2021TacAlert'], 8),
    ('anniversary.2024l_survival_minutes', 'anniversary', '2024: Survival', 'Survival', 'TacAlertKeyAnniversary2024L', ['Anniversary2024TacAlert'], 10),
    ('anniversary.2024cma_survival_minutes', 'anniversary', '2024: Challenge A Survival', 'Survival', 'TacAlertKeyAnniversary2024ChallengeModeA', ['Anniversary2024TacAlertCMA'], 10),
    ('anniversary.2024cmb_survival_minutes', 'anniversary', '2024: Challenge B Survival', 'Survival', 'TacAlertKeyAnniversary2024ChallengeModeB', ['Anniversary2024TacAlertCMB'], 10),
    ('anniversary.2025cmb_survival_minutes', 'anniversary', '2025: Challenge B Survival', 'Survival', 'TacAlertKeyAnniversary2025ChallengeModeB', ['Anniversary2025TacAlertCMB'], 10),
    ('nightwatch.defense_waves', 'nightwatch', 'Defense', 'Defense', 'TacAlertKeyProjectNightwatch', NIGHTWATCH, 10),
    ('nightwatch.interception_rounds', 'nightwatch', 'Interception', 'Interception', 'TacAlertKeyProjectNightwatchEasy', NIGHTWATCH, 2),
    ('nightwatch.survival_minutes', 'nightwatch', 'Hard Survival', 'Survival', 'TacAlertKeyProjectNightwatchHard', NIGHTWATCH, 20),
]
EVENT = {'anniversary': 'Anniversary', 'nightwatch': 'The Long Shadow'}
out = []
for tid, group, sub, tname, key, tags, stock in SPECS:
    src, mtype, unit, maximum, word = TYPES[tname]
    o = rows[src]['owner']
    mod = reg['modules'][o['body_key']]
    owner = {'body_key': o['body_key'], 'stock_sha256': o['stock_sha256'], 'file': o['file'],
             'module_path': '/' + mod['module_path'].replace('.', '/') + '.lua',
             'template': 'MISSION_INFO_FIELD_AT_ENTRY', 'gate': 'CAPTURE_GRAPH_ENTRY_V1', 'field': 'maxWaveNum',
             'variant': 'GOAL_TAG', 'mission_type': mtype, 'variant_stock': stock, 'accessor': ACCESSOR,
             'entries': [{'prototype': e['prototype'], 'function': e['function'], 'role': e['role']} for e in o['entries']],
             'readers': o['readers'], 'dead_readers': o.get('dead_readers', []),
             'write_rule': {'when': f'host and m.goalTag in ({", ".join(tags)}) and m.missionType == {mtype} '
                                    f'and m.maxWaveNum == {stock}; another number is left alone with one line',
                            'how': 'local m = gGameRules:GetMission(); m.maxWaveNum = N; gGameRules:SetMission(m)',
                            'once': 'idempotent: skip when already equal',
                            'cleanup': 'none (the MissionInfo is mission-scoped)'},
             'meaning': f'{EVENT[group]} {sub}: {tname} maxWaveNum (key {key}: {stock})', 'goal_tag': tags[0]}
    if tags[1:]:
        owner['goal_tag_aliases'] = tags[1:]
    out.append({'tunable_id': tid, 'phase1_tunable_id': None, 'label': f'{sub} ({EVENT[group]})',
                'mission_type': tname, 'variant': f'{EVENT[group]} (goalTag {"/".join(tags)}, missionType {mtype})',
                'shared_with': '', 'owner_kind': 'MISSION_INFO_FIELD', 'backend': 'TARGET_ADDON', 'owner': owner,
                'unit': unit, 'stock': stock,
                'limits': {'minimum': 1, 'maximum': maximum, 'integer': True, 'basis': f'at least 1; {maximum} as the editor range'},
                'confidence': 'CONFIRMED_STATIC (owner: proven row ' + src + '; live probe pending)',
                'evidence': f'Owner as {src}. Key data: Packages.bin 2026.10.22.13.12 {key}, missionType {tname}, '
                            f'maxWaveNum {stock}. Tag from OpenWF worldStateService ({", ".join(tags)}).',
                'ui_text': {'group': group, 'event': EVENT[group], 'sub': sub, 'word': word, 'key': key}})
(HERE.parent / 'inputs').mkdir(exist_ok=True)
(HERE.parent / 'inputs/event_batch1_row_drafts.json').write_text(json.dumps(
    {'schema': 'RENOVICE_MISSION_TUNABLE_REGISTRY_V2 tunables[] drafts (Events batch 1, GOAL_TAG)',
     'build': reg['build'], 'supersedes': {}, 'groups': EVENT, 'rows': out}, indent=1) + '\n', encoding='utf-8')
print('drafts:', len(out))
