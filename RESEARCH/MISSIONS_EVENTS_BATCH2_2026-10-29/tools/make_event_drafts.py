"""2026-10-29: Events batch 2 row drafts (GOAL_TAG variant; three rows use the new "from 0" form).

Owners (static research 2026-10-29, scratch events2/report.json; readers re-measured here with the registrar's census on
the registry's stock bytes, and again by entry_row when the rows are added):
- Lotus.Scripts.Modes.HalloweenLanternEndless (caec63d8e739b693): entry P35 `Mission` (root child); maxWaveNum read in
  P30 = the goal in SECONDS survived (0 = endless: extraction at the literal 300 s, row lantern.min_score).
- Lotus.Scripts.Modes.PurifyMission (b35d715b0f5aa1c9): entry P45 `PurifyMission` (root child); maxWaveNum read live in
  P24 (HUD) and P33 (round loop) = rounds to purify (0 on alerts/goals -> 2).
- Lotus.Scripts.Modes.MechSurvivalMission (721710696afea305): entry P34 `Mission` (root child); maxWaveNum read in P29/P30
  = Orphix to destroy (fixed length when > 0; 0 = endless, or 6 when the mission counts as an alert).
- Lotus.Scripts.Modes.SurvivalMission (a62aa7eea1c4f27b): the proven P70 owner (minutes; fixedLength = min(N x 60, 3600)).
Keys and stocks: Packages.bin 2026.10.22.13.12. Tags: OpenWF worldStateService (Halloween19 / Halloween19Endless, legacy
alias Anniversary2018TacAlert; MechSurvival / MechSurvivalA / MechSurvivalB; NightwatchTacAlert(Bonus), legacy alias
Anniversary2020TacAlert); every candidate tag is listed because which goal tag the MissionInfo carries for these keys is
not proven. The mission type and the stock still have to match, so rows sharing a tag cannot write each other's mission.
Not drafted (the mode script never reads maxWaveNum, or reads it only as a flag): Exterminate, Hive, Breeding Grounds,
Wolf Hunt, Halloween/Naberus, Water Fight, Galleon of Ghouls, Belly of the Beast, Atramentum; Eight Claw unresolved.
Usage: python make_event_drafts.py  (writes ../inputs/event_batch2_row_drafts.json)
"""
import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
EDITOR = HERE.parents[2]
ROOT = EDITOR
while not (ROOT / 'WORKSPACE.json').exists():
    ROOT = ROOT.parent
sys.path.insert(0, str(EDITOR / 'RESEARCH/UNIVERSAL_MISSION_REGISTRY_2026-09-29/tools'))
import mission_owner_specs as SPECS  # noqa: E402
from addon_owner import RootTables  # noqa: E402

reg = json.loads((EDITOR / 'REGISTRIES/mission_build_u44.json').read_text(encoding='utf-8'))
rows = {r['tunable_id']: r for r in reg['tunables']}
ACCESSOR = rows['clem.survival_minutes']['owner']['accessor']
STOCK = ROOT / 'work/temp/update-check/stock-726365cc81044d28'
SEED = int(reg['name_hash_seed'], 16)


def namehash(name):
    x = SEED
    for b in name.encode():
        x = ((x ^ b) * 0x01000193) & 0xFFFFFFFF
    x = (~x) & 0xFFFFFFFF
    return ((x << 17) | (x >> 15)) & 0xFFFFFFFF


# owner name -> (body key, entries [(prototype, function, role)], live reader prototypes)
OWNERS = {
    # 2026-10-29: the reader prototypes are entries too (Orphix did not apply from P34 alone), so the write lands right
    # before the game reads the goal.
    'lantern': ('caec63d8e739b693', [(35, 'Mission', 'Hallowed Flame level trigger'), (30, '', 'goal seconds reader')], [30]),
    'purify': ('b35d715b0f5aa1c9', [(45, 'PurifyMission', 'Purify level trigger')], [24, 33]),
    'mech': ('721710696afea305', [(34, 'Mission', 'Orphix Venom level trigger'), (29, '', 'Orphix goal setup reader'),
                                  (30, '', 'Orphix goal reader')], [29, 30]),
    'survival': ('a62aa7eea1c4f27b', [(70, 'Mission', 'Survival level trigger')], [61, 62]),
}
LANTERN = ['Halloween19', 'Anniversary2018TacAlert', 'Halloween19Endless']
LANTERN_D = ['Halloween19Endless', 'Halloween19', 'Anniversary2018TacAlert']
MECH = ['MechSurvival', 'MechSurvivalA', 'MechSurvivalB']
NIGHTWATCH_BONUS = ['NightwatchTacAlertBonus', 'NightwatchTacAlert', 'Anniversary2020TacAlert']
# id, group, submenu, owner, type name, type number, key(s), tags, stock, unit, max, field word
SPECS_ = [
    ('hallowedflame.lantern_a_seconds', 'hallowedflame', 'Lantern A', 'lantern', 'Survival', 2, 'LanternEndlessEventKeyA', LANTERN, 300, 's', 3600, 'seconds'),
    ('hallowedflame.lantern_b_seconds', 'hallowedflame', 'Lantern B', 'lantern', 'Survival', 2, 'LanternEndlessEventKeyB', LANTERN, 420, 's', 3600, 'seconds'),
    ('hallowedflame.lantern_c_seconds', 'hallowedflame', 'Lantern C', 'lantern', 'Survival', 2, 'LanternEndlessEventKeyC', LANTERN, 600, 's', 3600, 'seconds'),
    ('hallowedflame.lantern_d_seconds', 'hallowedflame', 'Lantern D (endless)', 'lantern', 'Survival', 2, 'LanternEndlessEventKeyD', LANTERN_D, 0, 's', 3600, 'seconds'),
    ('anniversary.2022j_purify_rounds', 'anniversary', '2022: Purify', 'purify', 'Purify', 21, 'TacAlertKeyAnniversary2022J', ['Anniversary2022TacAlert'], 3, '', 20, 'rounds'),
    # orphixvenom.orphix_to_destroy removed 2026-10-29: the event ignores maxWaveNum (P29 isMechEvent branch).
    ('nightwatch.bonus_survival_minutes', 'nightwatch', 'Bonus Survival (endless)', 'survival', 'Survival', 2, 'TacAlertKeyProjectNightwatchBonus', NIGHTWATCH_BONUS, 0, 'min', 60, 'minutes'),
]
EVENT = {'hallowedflame': 'Hallowed Flame', 'anniversary': 'Anniversary', 'orphixvenom': 'Orphix Venom',
         'nightwatch': 'The Long Shadow'}
out = []
for tid, group, sub, oname, tname, mtype, key, tags, stock, unit, maximum, word in SPECS_:
    body, entries, live = OWNERS[oname]
    mod = reg['modules'][body]
    raw = (STOCK / mod['file']).read_bytes()
    census = SPECS.census(RootTables(raw), 'maxWaveNum', namehash)  # {prototype: [instructions]}
    assert set(live) <= set(census), (tid, census)
    owner = {'body_key': body, 'stock_sha256': mod['sha256'], 'file': mod['file'],
             'module_path': '/' + mod['module_path'].replace('.', '/') + '.lua',
             'template': 'MISSION_INFO_FIELD_AT_ENTRY', 'gate': 'CAPTURE_GRAPH_ENTRY_V1', 'field': 'maxWaveNum',
             'variant': 'GOAL_TAG', 'mission_type': mtype, 'variant_stock': stock, 'accessor': ACCESSOR,
             'entries': [{'prototype': p, 'function': f, 'role': r} for p, f, r in entries],
             'readers': [{'key': 'maxWaveNum', 'prototype': p, 'instructions': census[p]} for p in live],
             'dead_readers': [{'key': 'maxWaveNum', 'prototype': p, 'instructions': i}
                              for p, i in sorted(census.items()) if p not in live],
             'write_rule': {'when': f'host and m.goalTag in ({", ".join(tags)}) and m.missionType == {mtype} '
                                    f'and m.maxWaveNum == {stock}; another number is left alone with one line',
                            'how': 'local m = gGameRules:GetMission(); m.maxWaveNum = N; gGameRules:SetMission(m)',
                            'once': 'idempotent: skip when already equal',
                            'cleanup': 'none (the MissionInfo is mission-scoped)'},
             'meaning': f'{EVENT[group]} {sub}: {word} ({key}: stock {stock}{", 0 = endless" if stock == 0 else ""})',
             'goal_tag': tags[0], 'goal_tag_aliases': tags[1:]}
    if not owner['goal_tag_aliases']:
        del owner['goal_tag_aliases']
    out.append({'tunable_id': tid, 'phase1_tunable_id': None, 'label': f'{sub} ({EVENT[group]})', 'mission_type': tname,
                'variant': f'{EVENT[group]} (goalTag {"/".join(tags)}, missionType {mtype})', 'shared_with': '',
                'owner_kind': 'MISSION_INFO_FIELD', 'backend': 'TARGET_ADDON', 'owner': owner, 'unit': unit,
                'stock': stock,
                'limits': {'minimum': 0 if stock == 0 else 1, 'maximum': maximum, 'integer': True,
                           'basis': ('0 = endless (game default); ' if stock == 0 else 'at least 1; ') + f'{maximum} as the editor range'},
                'confidence': 'CONFIRMED_STATIC (owner: research 2026-10-29 events2; live probe pending)',
                'evidence': f'{mod["module_path"]} ({body}): entry {[e[0] for e in entries]}, maxWaveNum readers {live}. '
                            f'Key data: Packages.bin 2026.10.22.13.12 {key}, stock {stock}. Tags: {", ".join(tags)}.',
                'ui_text': {'group': group, 'event': EVENT[group], 'sub': sub, 'word': word, 'key': key}})
(HERE.parent / 'inputs').mkdir(exist_ok=True)
(HERE.parent / 'inputs/event_batch2_row_drafts.json').write_text(json.dumps(
    {'schema': 'RENOVICE_MISSION_TUNABLE_REGISTRY_V2 tunables[] drafts (Events batch 2, GOAL_TAG incl. from 0)',
     'build': reg['build'], 'supersedes': {}, 'groups': EVENT, 'rows': out}, indent=1) + '\n', encoding='utf-8')
print('drafts:', len(out))
