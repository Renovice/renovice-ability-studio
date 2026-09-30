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
the registry and its master knobs (`ui_masters`, contract R5) are package values; any other id is reported and skipped.
R5: a literal-lane value (replacement member) is fixed at build time, so every literal entry with a number is rebuilt with
its value; one that is not effective is listed in `disabled_values` (built, shipped off). Read-only except for the output
file.
"""
from pathlib import Path
import json, sys

EDITOR = Path(__file__).resolve().parents[3]
BINDING = 'renovice.target.lua_call'


def convert(values_file: Path) -> dict:
    registry = json.loads((EDITOR / 'REGISTRIES/mission_build_u44.json').read_text(encoding='utf-8'))
    rows = {r['tunable_id']: r for r in registry['tunables']}
    masters = registry.get('ui_masters', {})
    state = json.loads(values_file.read_text(encoding='utf-8'))
    if state.get('format') != 'RENOVICE_SCRIPT_SETTINGS_V1' or state.get('package') != 'package:missions':
        raise SystemExit('not a RENOVICE_SCRIPT_SETTINGS_V1 file of package:missions')
    if state.get('build') != registry['build']:
        raise SystemExit(f'values file build {state.get("build")} is not the registry build {registry["build"]}')
    values, skipped, disabled = {}, [], []
    groups = state.get('groups', {})
    for tid, entry in sorted(state.get('values', {}).items()):
        if not isinstance(entry, dict) or not isinstance(entry.get('value'), (int, float)):
            continue
        row, master = rows.get(tid), masters.get(tid)
        if master is None and (row is None or row['backend'] not in ('TARGET_ADDON', 'EXACT_LITERAL')):
            skipped.append(tid)
            continue
        lane = master['lane'] if master is not None else ('literal' if row['backend'] == 'EXACT_LITERAL' else 'addon')
        group = master['group'] if master is not None else row['ui']['group']
        effective = (not state.get('use_stock', False) and entry.get('enabled') is True
                     and groups.get(group, True) is not False)
        if lane == 'literal':
            values[tid] = entry['value']
            if not effective:
                disabled.append(tid)
        elif effective:
            values[tid] = entry['value']
    for tid in skipped:
        print(f'skipped {tid}: not a Missions package value (unknown id, metadata or server row)', file=sys.stderr)
    result = {'format': 'RENOVICE_MISSION_SETTINGS_V1', 'build': registry['build'], 'values': values,
              'allow_unproven_hook_bindings': [BINDING], 'output_layout': 'package', 'package_scope': 'all_addon_values'}
    if disabled:
        result['disabled_values'] = disabled
    return result


if __name__ == '__main__':
    if len(sys.argv) != 3:
        raise SystemExit(__doc__)
    result = convert(Path(sys.argv[1]))
    Path(sys.argv[2]).write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
    print(f'enabled values: {len(result["values"])} -> {sys.argv[2]}')
