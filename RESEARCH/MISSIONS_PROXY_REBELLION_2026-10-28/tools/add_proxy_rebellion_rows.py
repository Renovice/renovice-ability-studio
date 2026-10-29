"""2026-10-28: add the Proxy Rebellion goal rows (GOAL_TAG variant, alias tag) to the CURRENT registry
(client 2026.10.08.13.05 rows, rebased by the update pipeline). Same steps as MISSIONS_CLEM_GOAL_2026-10-28/add_clem_rows.py.

The registrar (register_registry.py) is pinned to its 44.0.2 corpus; later builds carry rows by the update rebase. New
rows on a later build are therefore built here with the registrar's own row function (mission_owner_specs.entry_row:
root-child entry evidence, reader census, MissionInfo field rule, R23 Icebind and GOAL_TAG variants) on the stock bytes of the current
build, appended to REGISTRIES/mission_build_u44.json, and their modules and stock bodies registered in the registry and
its corpus. Player text, layout and masters are applied afterwards by `python player_text.py` (twice, fixed point).

Idempotent guard: refuses when a Proxy Rebellion id is already a registry row. Usage: python add_proxy_rebellion_rows.py
"""
import hashlib
import json
import shutil
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
EDITOR = HERE.parents[2]
ROOT = EDITOR
while not (ROOT / 'WORKSPACE.json').exists():
    ROOT = ROOT.parent
TOOLS = EDITOR / 'RESEARCH/UNIVERSAL_MISSION_REGISTRY_2026-09-29/tools'
sys.path.insert(0, str(TOOLS))
import mission_owner_specs as SPECS  # noqa: E402
from addon_owner import RootTables  # noqa: E402
from deluau import body_key  # noqa: E402

REGISTRY = EDITOR / 'REGISTRIES/mission_build_u44.json'
DRAFTS = HERE.parent / 'inputs/proxy_rebellion_row_drafts.json'
BUILD = '2026.10.08.13.05'
STOCK = ROOT / 'work/temp/update-check/stock-726365cc81044d28'
PROVENANCE = 'research:proxy-rebellion-2026-10-28 (GOAL_TAG variant, alias tag)'


def namehash(name, seed):
    x = seed
    for b in name.encode():
        x = ((x ^ b) * 0x01000193) & 0xFFFFFFFF
    x = (~x) & 0xFFFFFFFF
    return ((x << 17) | (x >> 15)) & 0xFFFFFFFF


def main():
    reg = json.loads(REGISTRY.read_text(encoding='utf-8'))
    if reg['build'] != BUILD:
        raise SystemExit(f'registry build {reg["build"]} is not {BUILD}')
    drafts = json.loads(DRAFTS.read_text(encoding='utf-8'))
    if drafts['build'] != BUILD:
        raise SystemExit('Proxy Rebellion drafts name another build')
    ids = {r['tunable_id'] for r in reg['tunables']}
    if any(d['tunable_id'] in ids for d in drafts['rows']):
        raise SystemExit('a Proxy Rebellion row is already in the registry')
    seed = int(reg['name_hash_seed'], 16)
    corpus = ROOT / reg['corpus']

    class Ctx:
        @staticmethod
        def namehash(name):
            return namehash(name, seed)

    added = []
    for d in drafts['rows']:
        o = d['owner']
        raw = (STOCK / o['file']).read_bytes()
        key, sha = body_key(raw), hashlib.sha256(raw).hexdigest().upper()
        if key != o['body_key'] or sha != o['stock_sha256']:
            raise SystemExit(f'{d["tunable_id"]}: stock identity {key}/{sha[:16]} != drafted {o["body_key"]}/{o["stock_sha256"][:16]}')
        rec = reg['modules'].get(key)
        if rec is None:
            rec = {'file': o['file'], 'sha256': sha, 'size': len(raw), 'module_path': SPECS.dotted(o['module_path'])
                   if hasattr(SPECS, 'dotted') else o['module_path'].strip('/').removesuffix('.lua').replace('/', '.')}
            reg['modules'][key] = rec
        elif rec['sha256'] != sha or rec['file'] != o['file']:
            raise SystemExit(f'{d["tunable_id"]}: registry module {key} is another body')
        target = corpus / o['file']
        if target.exists():
            if hashlib.sha256(target.read_bytes()).hexdigest().upper() != sha:
                raise SystemExit(f'corpus file {target} is another body')
        else:
            shutil.copyfile(STOCK / o['file'], target)
        base = {'tunable_id': d['tunable_id'], 'phase1_tunable_id': None, 'label': d['label'],
                'mission_type': d['mission_type'], 'variant': d['variant'], 'shared_with': d['shared_with'],
                'owner_kind': d['owner_kind'], 'backend': d['backend'], 'unit': d['unit'], 'stock': d['stock'],
                'confidence': d['confidence'], 'provenance': PROVENANCE, 'evidence': d['evidence'],
                'research_draft_id': d['tunable_id']}
        row = SPECS.entry_row(Ctx, RootTables(raw), key, rec, d, base, dict(d['limits']), d['tunable_id'])
        # ui: the generic fields every registry row carries; player_text.py sets the player-facing ones.
        family = d['tunable_id'].split('.')[0]
        row['ui'] = {'group': family, 'mt_codes': [], 'short_label': d['label'], 'label_source': 'id',
                     'scope_text': d['label'], 'aliases': ['Proxy Rebellion', 'Perrin Sequence'], 'lane': 'addon', 'applies': 'next_mission',
                     'type': 'int', 'editor': 'INPUTCOUNT', 'unit': d['unit'] if d['unit'] == 'min' else '',
                     'min': d['limits']['minimum'], 'max': d['limits']['maximum'], 'rank': 100000}
        reg['tunables'].append(row)
        added.append(d['tunable_id'])
    # The registry's ui_groups were generated by the (pinned) registrar; a new family needs its group record, built by
    # the registrar's own editor_fields.group_record. Proxy Rebellion has no node set of its own (EventNode keys).
    # Order 98: after Clem (97).
    # Order 97: alphabetical between Capture (80-95) and Colonist Door Defense (100).
    import editor_fields  # noqa: E402  (registrar tools folder, on sys.path)
    if 'proxyrebellion' not in reg['ui_groups']:
        reg['ui_groups']['proxyrebellion'] = editor_fields.group_record('proxyrebellion', editor_fields.GROUPS['proxyrebellion'], [], 98)
    REGISTRY.write_bytes((json.dumps(reg, indent=2, ensure_ascii=False) + '\n').encode('utf-8'))
    print('Proxy Rebellion rows added:', ', '.join(added))


if __name__ == '__main__':
    main()
