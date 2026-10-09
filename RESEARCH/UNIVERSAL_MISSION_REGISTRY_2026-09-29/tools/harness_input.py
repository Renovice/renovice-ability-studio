"""The pinned package build input of the harnesses, on the CURRENT registry build (2026-10-09).

The harnesses build `MISSIONS_R13_NATIVE_ENTRY_2026-10-01/inputs/rebuild_input.r12.json` (its LF content stays pinned).
That file names the build it was written for (44.0.2); the generator correctly refuses settings for another build. The
update tool rebuilds the installed package from the same input with the build label of the adopted registry and without
ids the registry no longer has (tools/update_check/uc_rebuild.py build_input); this does the same, so a harness tests the
package the current registry builds.
"""
import json
from pathlib import Path

EDITOR = Path(__file__).resolve().parents[3]


def current_spec(input_path: Path) -> dict:
    data = json.loads(Path(input_path).read_text(encoding='utf-8'))
    registry = json.loads((EDITOR / 'REGISTRIES/mission_build_u44.json').read_text(encoding='utf-8'))
    data['build'] = registry['build']
    ids = {r['tunable_id'] for r in registry['tunables']} | set(registry['ui_masters'])
    data['values'] = {k: v for k, v in data.get('values', {}).items() if k in ids}
    if 'disabled_values' in data:
        data['disabled_values'] = [k for k in data['disabled_values'] if k in data['values']]
    return data


def current_input(input_path: Path, work: Path) -> Path:
    out = Path(work) / 'build_input.current.json'
    out.write_text(json.dumps(current_spec(input_path), indent=1), encoding='utf-8')
    return out
