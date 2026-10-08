#!/usr/bin/env python3
"""Re-pin the mission registry's SERVER_CONFIG rows after a server code change (2026-10-08).

A SERVER_CONFIG row pins whole server source files (LF-normalized SHA-256) plus the exact line that reads its config
key. Server work elsewhere in those files (e.g. the Icebind mission-end code in missionInventoryUpdateService.ts)
changes the hash although the owner is untouched. This re-pins a file only when its preimage line still occurs exactly
once (rebase_registry.server_repin), runs the production verify-missions on the candidate, and writes
REGISTRIES/mission_build_u44.json only when every row passes. Anything else stops with the reason; nothing is written.

    python repos/apps/ability-editor/tools/update_check/repin_server_rows.py [--dry-run]
"""
from __future__ import annotations

import argparse
import json
import sys
import tempfile
from pathlib import Path

TOOL = Path(__file__).resolve().parent
EDITOR = TOOL.parents[1]
sys.path.insert(0, str(TOOL))
sys.path.insert(0, str(EDITOR / 'RESEARCH' / 'UNIVERSAL_MISSION_REGISTRY_2026-09-29' / 'tools'))
import uc_missions  # noqa: E402
import rebase_registry as RR  # noqa: E402


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.split('\n\n')[0])
    ap.add_argument('--dry-run', action='store_true')
    a = ap.parse_args()
    ws = EDITOR.parents[2]
    wsj = json.loads((ws / 'WORKSPACE.json').read_text(encoding='utf-8'))
    path = EDITOR / 'REGISTRIES' / 'mission_build_u44.json'
    registry = json.loads(path.read_text(encoding='utf-8'))
    server_root = RR.ROOT / registry['server_root']
    changed, notes = 0, []
    for i, row in enumerate(registry['tunables']):
        if row['backend'] != 'SERVER_CONFIG':
            continue
        try:
            owner = RR.server_repin(row['owner'], server_root, notes)
        except RR.Problem as p:
            print(f'REVIEW {row["tunable_id"]}: {p.reason}')
            return 1
        if owner is not row['owner']:
            registry['tunables'][i] = dict(row, owner=owner)
            changed += 1
    for n in notes:
        print(n)
    if not changed:
        print('server rows: nothing to re-pin')
        return 0
    cli = ws / wsj['work']['builds'] / 'ability-editor' / 'current' / 'bin' / 'renovice_ability_editor_cli.exe'
    with tempfile.TemporaryDirectory() as tmp:
        cand = Path(tmp) / 'mission_build_u44.json'
        cand.write_bytes(RR.dump(registry))
        corpus = ws / registry['corpus']
        result, note, missing = uc_missions.run_verify_missions(
            cli, ws, cand, lambda f: (corpus / f) if (corpus / f).is_file() else None,
            registry['packages_bin_sha256'], Path(tmp))
    if result is None or missing or result.get('structure') != 'PASS' or result.get('pass') != result.get('rows'):
        print(f'verify-missions on the candidate FAILED: {note} missing={missing} '
              f'{json.dumps({k: result.get(k) for k in ("pass", "rows", "structure")}) if result else ""}')
        for f in (result or {}).get('failures', [])[:10]:
            print('  ', f.get('tunable_id'), f.get('reason'))
        return 2
    print(f'verify-missions on the candidate: {result["pass"]}/{result["rows"]} PASS, structure PASS')
    if a.dry_run:
        print('dry run: registry not written')
        return 0
    path.write_bytes(RR.dump(registry))
    print(f're-pinned {changed} server row(s): {path}')
    return 0


if __name__ == '__main__':
    sys.exit(main())
