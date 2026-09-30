"""Rebuild input for the full Missions package from an in-game values file (Phase 2k; offline).

The full package (package_scope "all_addon_values") declares every multi-instance-safe addon value, but it hooks only the
root tables that hold a value enabled at BUILD time (performance rule: a target without an enabled value installs no
luaCalls hook). A value enabled later in SCRIPT SETTINGS whose table has no hook makes that target's activation fail with
"... has no hook in this build; rebuild Packages/Missions from Settings/Missions.json". This tool turns the current
CustomScripts/Settings/Missions.json (RENOVICE_SCRIPT_SETTINGS_V1) into the build input for that rebuild:

    python missions_settings_to_build.py <OpenWF/CustomScripts/Settings/Missions.json> <out mission_settings.json>
    renovice_ability_editor_cli build-missions <out mission_settings.json> --staging <short folder>

Effective rule (same as the runtime, INGAME_EDITOR_DESIGN.md section 3.4): nothing when use_stock is true; otherwise a
value whose group is not switched off and whose entry is enabled with a number. Only TARGET_ADDON and EXACT_LITERAL rows of
the registry are package values; any other id is reported and skipped. Read-only except for the output file.
"""
from pathlib import Path
import json, sys

EDITOR = Path(__file__).resolve().parents[3]
BINDING = 'renovice.target.lua_call'


def convert(values_file: Path) -> dict:
    registry = json.loads((EDITOR / 'REGISTRIES/mission_build_u44.json').read_text(encoding='utf-8'))
    rows = {r['tunable_id']: r for r in registry['tunables']}
    state = json.loads(values_file.read_text(encoding='utf-8'))
    if state.get('format') != 'RENOVICE_SCRIPT_SETTINGS_V1' or state.get('package') != 'package:missions':
        raise SystemExit('not a RENOVICE_SCRIPT_SETTINGS_V1 file of package:missions')
    if state.get('build') != registry['build']:
        raise SystemExit(f'values file build {state.get("build")} is not the registry build {registry["build"]}')
    values, skipped = {}, []
    if not state.get('use_stock', False):
        groups = state.get('groups', {})
        for tid, entry in sorted(state.get('values', {}).items()):
            if not isinstance(entry, dict) or entry.get('enabled') is not True or not isinstance(entry.get('value'), (int, float)):
                continue
            row = rows.get(tid)
            if row is None or row['backend'] not in ('TARGET_ADDON', 'EXACT_LITERAL'):
                skipped.append(tid)
                continue
            if groups.get(row['ui']['group'], True) is False:
                continue
            values[tid] = entry['value']
    for tid in skipped:
        print(f'skipped {tid}: not a Missions package value (unknown id, metadata or server row)', file=sys.stderr)
    return {'format': 'RENOVICE_MISSION_SETTINGS_V1', 'build': registry['build'], 'values': values,
            'allow_unproven_hook_bindings': [BINDING], 'output_layout': 'package', 'package_scope': 'all_addon_values'}


if __name__ == '__main__':
    if len(sys.argv) != 3:
        raise SystemExit(__doc__)
    result = convert(Path(sys.argv[1]))
    Path(sys.argv[2]).write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
    print(f'enabled values: {len(result["values"])} -> {sys.argv[2]}')
