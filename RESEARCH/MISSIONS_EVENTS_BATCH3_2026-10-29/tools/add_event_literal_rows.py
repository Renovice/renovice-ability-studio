"""2026-10-29: Events batch 3, literal-lane rows (LUA_PROTO_LITERAL / EXACT_LITERAL) for event modes whose goal numbers
are script literals, not MissionInfo fields.

Same row format and site resolver as the registrar's phase 2d/2e literal rows (register_registry.py lua_row,
phase2d.resolve: exact pattern/constant sites, every expected byte recorded, overlapping sites refused), applied to the
CURRENT registry (client 2026.10.08.13.05 rows, rebased by the update pipeline). Sites from the static research of
2026-10-29 (scratch events2/report2.json), re-resolved here on the stock bytes; a count mismatch fails closed.
- Water Fight (Lotus.Scripts.Modes.PveDeathMatch): team score limit 25 (root, both teams), the 60 limit on the other
  setup path (P17/P30; which path the event takes is not proven, so both are rows), round time 300 s (root, the clamp in
  P21 and the default in P30, patched together).
- Hallowed Nightmares time attack (Lotus.Scripts.HalloweenGameRules): score base 1000 (score = 1000 - elapsed seconds):
  number constant K (single use) plus the two LOADN 1000 (clamp max and net-var default), patched together.
Literal rows change the whole module; both modules are used only by these event modes (inferred from the research).
Idempotent guard: refuses when a row id already exists. Usage: python add_event_literal_rows.py
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
TOOLS = EDITOR / 'RESEARCH/UNIVERSAL_MISSION_REGISTRY_2026-09-29/tools'
sys.path.insert(0, str(TOOLS))
import phase2d  # noqa: E402
from addon_owner import RootTables  # noqa: E402
from deluau import body_key, sha256, RAW_LOADN  # noqa: E402

REGISTRY = EDITOR / 'REGISTRIES/mission_build_u44.json'
BUILD = '2026.10.08.13.05'
STOCK = ROOT / 'work/temp/update-check/stock-726365cc81044d28'
PROVENANCE = 'research:events-batch3-2026-10-29 (event literals)'


def pat(value, owner, count, protos):
    return {'kind': 'pattern', 'value': value, 'count': count, 'owner': owner, 'protos': protos}


PVE = ('Lotus_Scripts_Modes_PveDeathMatch.lua_B', 'Lotus.Scripts.Modes.PveDeathMatch')
HAL = ('Lotus_Scripts_HalloweenGameRules.lua_B', 'Lotus.Scripts.HalloweenGameRules')
# id, group, event, submenu, label, module, stock, unit, specs, evidence
ROWS = [
    ('waterfight.score_limit', 'waterfight', 'Water Fight', 'Match', 'Score limit (both teams)', PVE, 25, '',
     [pat(25, 'team score limits v24/v25 (root)', 2, ['root'])],
     'PveDeathMatch root i67/i68: the two team score limits (P11 ends the match at score >= limit). The other LOADN 25 '
     '(P22, P28) are not owned.'),
    ('waterfight.score_limit_alt', 'waterfight', 'Water Fight', 'Match', 'Score limit (alternate setup)', PVE, 60, '',
     [pat(60, 'score limit 60 on the second setup path (P17, P30)', 4, [17, 30])],
     'PveDeathMatch P17 i253/i255 and P30 i48/i50: score limit 60 on the setup path next to the Greed waypoints; which '
     'path the Water Fight event takes is not proven, so it is its own row.'),
    ('waterfight.round_time', 'waterfight', 'Water Fight', 'Match', 'Round time', PVE, 300, 's',
     [pat(300, 'round seconds: root start, P21 clamp max, P30 default', 4, ['root', 21, 30])],
     'PveDeathMatch root i72 (round seconds left), P21 i14 (Clamp 0..300) and P30 i111/i118 (net-var default): all '
     'copies of the round length, patched together.'),
    ('hallowednightmares.timeattack_score', 'hallowednightmares', 'Hallowed Nightmares', 'Time Attack',
     'Time attack score base', HAL, 1000, '',
     [pat(1000, 'score base: Clamp max and net-var default (P2)', 2, [2])],
     'HalloweenGameRules P2: time-attack score = 1000 - elapsed s, clamped 1..1000 (LOADN i164, net-var default i168). '
     'The subtraction uses number constant K50 = 1000 (single use), added as a constant site below.'),
]


def main():
    reg = json.loads(REGISTRY.read_text(encoding='utf-8'))
    if reg['build'] != BUILD:
        raise SystemExit(f'registry build {reg["build"]} is not {BUILD}')
    ids = {r['tunable_id'] for r in reg['tunables']}
    corpus = ROOT / reg['corpus']
    added = []
    for tid, group, event, sub, label, (file, mpath), stock, unit, specs, evidence in ROWS:
        if tid in ids:
            raise SystemExit(f'{tid} is already a registry row')
        raw = (STOCK / file).read_bytes()
        m = RootTables(raw)
        sites = phase2d.resolve(m, specs)
        if tid == 'hallowednightmares.timeattack_score':
            # the subtraction's number constant 1000 in P2 (single use: SUBRK); exclusive-use gate as the registrar's const().
            ks = [k for k, (tag, _) in enumerate(m.const_records[2]) if tag == 2 and m.number(2, k) == 1000]
            if len(ks) != 1:
                raise SystemExit(f'{tid}: {len(ks)} number constants 1000 in P2')
            uses = [u[1] for u in m.uses(2).get(ks[0], []) if u[0] == 'ins']
            sites += phase2d.resolve(m, [{'kind': 'constant', 'value': 1000, 'proto': 2, 'owner': 'score base constant (SUBRK)',
                                          'uses': [phase2d.signature(m, 2, i) for i in uses]}])
        for s in sites:
            got = (struct.unpack_from('<h', raw, s['offset'] + 2)[0] if s['kind'] == 'instruction'
                   else struct.unpack_from('<d', raw, s['offset'])[0])
            if got != stock:
                raise SystemExit(f'{tid}: site {s["prototype"]}@{s["offset"]} holds {got}, not {stock}')
            if s['kind'] == 'instruction' and raw[s['offset']] != RAW_LOADN:
                raise SystemExit(f'{tid}: site {s["prototype"]}@{s["offset"]} is not a LOADN')
        key = body_key(raw)
        rec = reg['modules'].get(key)
        if rec is None:
            rec = reg['modules'][key] = {'file': file, 'sha256': sha256(raw), 'size': len(raw), 'module_path': mpath}
        elif rec['sha256'] != sha256(raw) or rec['file'] != file:
            raise SystemExit(f'{tid}: registry module {key} is another body')
        target = corpus / file
        if not target.exists():
            target.write_bytes(raw)
        elif sha256(target.read_bytes()) != rec['sha256']:
            raise SystemExit(f'corpus file {target} is another body')
        row = {'tunable_id': tid, 'phase1_tunable_id': None, 'label': f'{label} ({event})', 'mission_type': event,
               'variant': event, 'shared_with': '', 'owner_kind': 'LUA_PROTO_LITERAL', 'backend': 'EXACT_LITERAL',
               'owner': {'body_key': key, 'stock_sha256': rec['sha256'], 'file': file, 'module_path': mpath, 'sites': sites},
               'unit': unit, 'stock': stock,
               'limits': {'minimum': 1, 'maximum': 32767, 'integer': True,
                          'basis': 'operand domain guard only; gameplay-safe range not established offline'},
               'applies': 'next_mission', 'confidence': 'CONFIRMED_STATIC (sites; live probe pending)',
               'provenance': PROVENANCE, 'evidence': evidence,
               'backend_note': f'{len(sites)} exact site(s) patched together: ' + '; '.join(a['owner'] for a in specs),
               'ui': {'group': group, 'mt_codes': [], 'short_label': label, 'label_source': 'id', 'scope_text': label,
                      'aliases': [event, sub], 'lane': 'literal', 'applies': 'next_mission', 'type': 'int',
                      'editor': 'INPUTCOUNT', 'unit': unit, 'min': 1, 'max': 32767, 'rank': 100000}}
        reg['tunables'].append(row)
        added.append(f'{tid} ({len(sites)} sites)')
    import editor_fields  # noqa: E402
    for order, group in enumerate(('waterfight', 'hallowednightmares'), start=5):  # after batch 1/2 groups
        if group not in reg['ui_groups']:
            reg['ui_groups'][group] = editor_fields.group_record(group, editor_fields.GROUPS[group], [], 98 + order)
    REGISTRY.write_bytes((json.dumps(reg, indent=2, ensure_ascii=False) + '\n').encode('utf-8'))
    print('literal rows added:', ', '.join(added))


if __name__ == '__main__':
    main()
