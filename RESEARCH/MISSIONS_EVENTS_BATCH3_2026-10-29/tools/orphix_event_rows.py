"""2026-10-29: Orphix / Orphix Venom split (user request).

SUPERSEDED the same day: live test showed every Orphix Venom mission ends at the 36 limit; the 24 default is never
reached, so orphix.round_limit_default was removed again (and its refresh was the last log line before a game crash
during repeated settings saves; not proven causal). This tool now refuses to run.

- Removes `orphixvenom.orphix_to_destroy` (GOAL_TAG on maxWaveNum): live EE.log showed the write (maxWaveNum 0 -> 1), but
  MechSurvivalMission P29 skips the maxWaveNum branch whenever the goal tag contains "MechSurvival" (the event), so the
  value is never read on the event. A row that cannot act is not kept.
- Adds `orphix.round_limit_default` (literal lane): the root default round cap v40 = 24 (root LOADN, the only LOADN 24 in
  the module; static research scratch orphix/report.json). The user reports event missions 1-2 end at 24 and Endurance
  at 36; the code sends every MechSurvival-tagged key to v9.maxRounds (36), so which cap a live mission uses is not
  proven: both caps get a setting.
The Events > Orphix Venom page itself is masters over the Orphix rows (player_text_events_batch3.py), not new owners.
Idempotent. Usage: python orphix_event_rows.py
"""
import json
import struct
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
EDITOR = HERE.parents[2]
ROOT = EDITOR
while not (ROOT / 'WORKSPACE.json').exists():
    ROOT = ROOT.parent
sys.path.insert(0, str(EDITOR / 'RESEARCH/UNIVERSAL_MISSION_REGISTRY_2026-09-29/tools'))
import phase2d  # noqa: E402
from addon_owner import RootTables  # noqa: E402
from deluau import body_key, sha256, RAW_LOADN  # noqa: E402

REGISTRY = EDITOR / 'REGISTRIES/mission_build_u44.json'
STOCK = ROOT / 'work/temp/update-check/stock-726365cc81044d28'
FILE = 'Lotus_Scripts_Modes_MechSurvivalMission.lua_B'


def main():
    raise SystemExit('superseded 2026-10-29: orphix.round_limit_default is not exposed (no mission reaches the 24)')
    reg = json.loads(REGISTRY.read_text(encoding='utf-8'))
    before = len(reg['tunables'])
    reg['tunables'] = [t for t in reg['tunables'] if t['tunable_id'] != 'orphixvenom.orphix_to_destroy']
    if len(reg['tunables']) != before:
        print('removed orphixvenom.orphix_to_destroy')
    if not any(t['tunable_id'] == 'orphix.round_limit_default' for t in reg['tunables']):
        raw = (STOCK / FILE).read_bytes()
        m = RootTables(raw)
        sites = phase2d.resolve(m, [{'kind': 'pattern', 'value': 24, 'count': 1, 'protos': ['root'],
                                     'owner': 'root default round cap v40 = 24'}])
        for s in sites:
            if raw[s['offset']] != RAW_LOADN or struct.unpack_from('<h', raw, s['offset'] + 2)[0] != 24:
                raise SystemExit('site is not LOADN 24')
        key = body_key(raw)
        rec = reg['modules'][key]
        if rec['sha256'] != sha256(raw):
            raise SystemExit('registry module is another body')
        reg['tunables'].append({
            'tunable_id': 'orphix.round_limit_default', 'phase1_tunable_id': None,
            'label': 'Default round limit (Orphix)', 'mission_type': 'Orphix', 'variant': 'all', 'shared_with': '',
            'owner_kind': 'LUA_PROTO_LITERAL', 'backend': 'EXACT_LITERAL',
            'owner': {'body_key': key, 'stock_sha256': rec['sha256'], 'file': FILE, 'module_path': rec['module_path'],
                      'sites': sites},
            'unit': '', 'stock': 24,
            'limits': {'minimum': 1, 'maximum': 32767, 'integer': True,
                       'basis': 'operand domain guard only; gameplay-safe range not established offline'},
            'applies': 'next_mission', 'confidence': 'CONFIRMED_STATIC (site; live probe pending)',
            'provenance': 'research:orphix-event-2026-10-29 (literal)',
            'evidence': 'MechSurvivalMission root LOADN 24 -> v40 (round cap) when the mission is not an event, Railjack, '
                        'sortie or fixed length (P29). The only LOADN 24 in the module. User: Orphix Venom missions 1-2 end '
                        'at 24.',
            'backend_note': '1 exact site: root default round cap v40 = 24',
            'ui': {'group': 'orphix', 'mt_codes': [], 'short_label': 'Default round limit', 'label_source': 'id',
                   'scope_text': 'Default round limit', 'aliases': ['Orphix Venom', 'rounds'], 'lane': 'literal',
                   'applies': 'next_mission', 'type': 'int', 'editor': 'INPUTCOUNT', 'unit': '', 'min': 1, 'max': 32767,
                   'rank': 100000}})
        print('added orphix.round_limit_default (1 site)')
    REGISTRY.write_bytes((json.dumps(reg, indent=2, ensure_ascii=False) + '\n').encode('utf-8'))


if __name__ == '__main__':
    main()
