"""2026-10-30: Enemies page, first rows: ProceduralLevel MaxAI (npcMgr:SetMaxAI) by level difficulty.

Why: the user wants an enemy multiplier (master + per mission type) editable in game. A live A/B with the native AI
director's IntermediateLimits at x10 (metadata patch, confirmed active through get_effective_metadata: 200/40) showed no
visible change in Survival, so those limits are not the alive-count gate. Lotus.Scripts.ProceduralLevel (every
procedural level) sets _T.MaxAI = 8 (difficulty >= 4), 6 (< 4), 4 (< 2) and calls npcMgr:SetMaxAI(_T.MaxAI) at entry
(P65 i781/i787/i793, each LOADN immediately followed by SETTABLEKS MaxAI). Whether MaxAI is the enemies-alive cap is
the live test these rows make possible (literal lane: applies from the next mission, no restart).
Rows: one per difficulty tier, each one exact site (pattern anchored on the following SETTABLEKS:MaxAI).
Idempotent guard. Usage: python add_maxai_rows.py
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
BUILD = '2026.10.08.13.05'
STOCK = ROOT / 'work/temp/update-check/stock-726365cc81044d28'
FILE = 'Lotus_Scripts_ProceduralLevel.lua_B'
MODULE = 'Lotus.Scripts.ProceduralLevel'
ROWS = [  # id, stock, label
    ('enemies.max_ai.high', 8, 'Max AI (level difficulty 4+)'),
    ('enemies.max_ai.mid', 6, 'Max AI (level difficulty 2-3)'),
    ('enemies.max_ai.low', 4, 'Max AI (level difficulty 0-1)'),
]


def main():
    reg = json.loads(REGISTRY.read_text(encoding='utf-8'))
    if reg['build'] != BUILD:
        raise SystemExit(f'registry build {reg["build"]} is not {BUILD}')
    ids = {r['tunable_id'] for r in reg['tunables']}
    raw = (STOCK / FILE).read_bytes()
    m = RootTables(raw)
    key = body_key(raw)
    rec = reg['modules'].get(key)
    if rec is None:
        rec = reg['modules'][key] = {'file': FILE, 'sha256': sha256(raw), 'size': len(raw), 'module_path': MODULE}
    elif rec['sha256'] != sha256(raw):
        raise SystemExit('registry module is another body')
    target = ROOT / reg['corpus'] / FILE
    if not target.exists():
        target.write_bytes(raw)
    added = []
    for tid, stock, label in ROWS:
        if tid in ids:
            raise SystemExit(f'{tid} is already a registry row')
        sites = phase2d.resolve(m, [{'kind': 'pattern', 'value': stock, 'count': 1, 'protos': [65],
                                     'after': ['SETTABLEKS:MaxAI'], 'owner': f'_T.MaxAI = {stock} (P65)'}])
        for s in sites:
            if raw[s['offset']] != RAW_LOADN or struct.unpack_from('<h', raw, s['offset'] + 2)[0] != stock:
                raise SystemExit(f'{tid}: site is not LOADN {stock}')
        reg['tunables'].append({
            'tunable_id': tid, 'phase1_tunable_id': None, 'label': label, 'mission_type': 'All procedural missions',
            'variant': 'all', 'shared_with': '', 'owner_kind': 'LUA_PROTO_LITERAL', 'backend': 'EXACT_LITERAL',
            'owner': {'body_key': key, 'stock_sha256': rec['sha256'], 'file': FILE, 'module_path': MODULE, 'sites': sites},
            'unit': '', 'stock': stock,
            'limits': {'minimum': 1, 'maximum': 32767, 'integer': True,
                       'basis': 'operand domain guard only; gameplay-safe range not established offline'},
            'applies': 'next_mission', 'confidence': 'CONFIRMED_STATIC (site; meaning of MaxAI pending live test)',
            'provenance': 'research:enemies-maxai-2026-10-30 (literal)',
            'evidence': f'ProceduralLevel P65: _T.MaxAI = {stock} by _T.difficulty, then npcMgr:SetMaxAI(_T.MaxAI) at level '
                        'entry (i795-797).',
            'backend_note': f'1 exact site: _T.MaxAI = {stock}',
            'ui': {'group': 'enemies', 'mt_codes': [], 'short_label': label, 'label_source': 'id', 'scope_text': label,
                   'aliases': ['enemy count', 'max AI', 'spawns'], 'lane': 'literal', 'applies': 'next_mission',
                   'type': 'int', 'editor': 'INPUTCOUNT', 'unit': '', 'min': 1, 'max': 32767, 'rank': 100000}})
        added.append(f'{tid} @ P{sites[0]["prototype"]} i{sites[0]["instruction"]}')
    import editor_fields  # noqa: E402
    if 'enemies' not in reg['ui_groups']:
        reg['ui_groups']['enemies'] = editor_fields.group_record('enemies', editor_fields.GROUPS['enemies'], [], 5)
    REGISTRY.write_bytes((json.dumps(reg, indent=2, ensure_ascii=False) + '\n').encode('utf-8'))
    print('added:', ', '.join(added))


if __name__ == '__main__':
    main()
