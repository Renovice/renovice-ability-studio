"""2026-10-28: Proxy Rebellion row drafts (GOAL_TAG variant with an alias tag), built from the proven count rows.

Event (OpenWF worldStateService, config worldState.proxyRebellion): goal Tag "ProxyRebellion", or
"Anniversary2019TacAlert" when unfaithfulBugFixes.useAnniversaryTagForOldGoals is on; both are listed.
Keys (Packages.bin 2026.10.22.13.12, probe.exe meta): TacAlertKeyProxyRebellionOne MT_DEFENSE maxWaveNum 10,
Two MT_TERRITORY 3, Three MT_SURVIVAL 20, Four (inherits One) MT_DEFENSE 20. Type numbers: ExportMissionTypes index
(MT_DEFENSE 8, MT_TERRITORY 13, MT_SURVIVAL 2; the same list gives the proven 9/17/33).
Each row reuses the owner (module, entry prototypes, reader census) of the proven count row of its type.
Usage: python make_drafts.py  (writes ../inputs/proxy_rebellion_row_drafts.json)
"""
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
EDITOR = HERE.parents[2]
reg = json.loads((EDITOR / 'REGISTRIES/mission_build_u44.json').read_text(encoding='utf-8'))
rows = {r['tunable_id']: r for r in reg['tunables']}
TAGS = ('ProxyRebellion', ['Anniversary2019TacAlert'])
SPECS = [  # id, source count row, type name, type number, stock, unit, max, label, meaning
    ('proxyrebellion.defense_one_waves', 'defense.waves_to_finish', 'Defense', 8, 10, '', 100,
     'Waves to finish (Proxy Rebellion, Defense One)', 'WaveDefend waves to finish (key One: 10)'),
    ('proxyrebellion.defense_four_waves', 'defense.waves_to_finish', 'Defense', 8, 20, '', 100,
     'Waves to finish (Proxy Rebellion, Defense Four)', 'WaveDefend waves to finish (key Four: 20)'),
    ('proxyrebellion.interception_rounds', 'interception.rounds_to_finish', 'Interception', 13, 3, '', 20,
     'Rounds to finish (Proxy Rebellion, Interception)', 'TerritoryMission rounds to finish (key Two: 3)'),
    ('proxyrebellion.survival_minutes', 'clem.survival_minutes', 'Survival', 2, 20, 'min', 60,
     'Minutes to finish (Proxy Rebellion, Survival)', 'SurvivalMission fixedLength = min(maxWaveNum x 60, 3600) s (key Three: 20)'),
]
out = []
for tid, src, tname, mtype, stock, unit, maximum, label, meaning in SPECS:
    o = rows[src]['owner']
    mod = reg['modules'][o['body_key']]
    owner = {'body_key': o['body_key'], 'stock_sha256': o['stock_sha256'], 'file': o['file'],
             'module_path': '/' + mod['module_path'].replace('.', '/') + '.lua',
             'template': 'MISSION_INFO_FIELD_AT_ENTRY', 'gate': 'CAPTURE_GRAPH_ENTRY_V1', 'field': 'maxWaveNum',
             'variant': 'GOAL_TAG', 'mission_type': mtype, 'variant_stock': stock,
             'accessor': o.get('accessor') or rows['clem.survival_minutes']['owner']['accessor'],
             'entries': [{'prototype': e['prototype'], 'function': e['function'], 'role': e['role']} for e in o['entries']],
             'readers': o['readers'], 'dead_readers': o.get('dead_readers', []),
             'write_rule': {'when': f'host and m.goalTag in ({TAGS[0]}, {", ".join(TAGS[1])}) and m.missionType == {mtype} '
                                    f'and m.maxWaveNum == {stock}; another number is left alone with one line',
                            'how': 'local m = gGameRules:GetMission(); m.maxWaveNum = N; gGameRules:SetMission(m)',
                            'once': 'idempotent: skip when already equal',
                            'cleanup': 'none (the MissionInfo is mission-scoped)'},
             'meaning': 'Proxy Rebellion ' + meaning, 'goal_tag': TAGS[0], 'goal_tag_aliases': TAGS[1]}
    out.append({'tunable_id': tid, 'phase1_tunable_id': None, 'label': label, 'mission_type': tname,
                'variant': f'Proxy Rebellion (goalTag {TAGS[0]} / {TAGS[1][0]}, missionType {mtype})', 'shared_with': '',
                'owner_kind': 'MISSION_INFO_FIELD', 'backend': 'TARGET_ADDON', 'owner': owner, 'unit': unit,
                'stock': stock, 'limits': {'minimum': 1, 'maximum': maximum, 'integer': True,
                                           'basis': f'at least 1; {maximum} as the editor range'},
                'confidence': 'CONFIRMED_STATIC (owner: proven row ' + src + '; live probe pending)',
                'evidence': f'Owner as {src}. Key data: Packages.bin 2026.10.22.13.12 TacAlertKeyProxyRebellion*, '
                            f'maxWaveNum {stock}. Tag from OpenWF worldStateService (ProxyRebellion / Anniversary2019TacAlert).'})
(HERE.parent / 'inputs/proxy_rebellion_row_drafts.json').write_text(json.dumps(
    {'schema': 'RENOVICE_MISSION_TUNABLE_REGISTRY_V2 tunables[] drafts (Proxy Rebellion, GOAL_TAG with alias)',
     'build': reg['build'], 'supersedes': {}, 'group': 'proxyrebellion', 'rows': out}, indent=1) + '\n', encoding='utf-8')
print('drafts:', ', '.join(r['tunable_id'] for r in out))
