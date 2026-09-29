"""Append the Phase 2e rows (modes Phase 1 analysed but did not tabulate) to the Phase 1 study mission_tunables.json.

Idempotent: rows already present (same tunable_id) are left unchanged. Writes only the research study file in
work/research/universal-mission-editor-2026-09-29 (never a game or server folder)."""
from pathlib import Path
import json, sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from deluau import ROOT  # noqa: E402
import phase2e_specs as P2E  # noqa: E402

path = ROOT / 'work/research/universal-mission-editor-2026-09-29/mission_tunables.json'
study = json.loads(path.read_text(encoding='utf-8'))
have = {r['tunable_id'] for r in study['tunables']}
added = [r for r in P2E.PHASE1 if r['tunable_id'] not in have]
study['tunables'].extend(added)
if added:
    study.setdefault('phase2e_additions', []).append({'date': '2026-09-29', 'rows': [r['tunable_id'] for r in added],
                                                     'note': 'Lantern, Purgatory and Void Flood fracture counts were '
                                                             'analysed in Phase 1 but not tabulated.'})
    path.write_text(json.dumps(study, indent=1, ensure_ascii=False), encoding='utf-8')  # the study has no final newline
print(f'added {len(added)} rows; total {len(study["tunables"])}')
