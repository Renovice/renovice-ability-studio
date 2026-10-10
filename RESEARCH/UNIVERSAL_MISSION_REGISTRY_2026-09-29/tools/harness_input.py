"""The pinned package build input of the harnesses, on the CURRENT registry build, and the package pins (2026-10-09).

The harnesses build `MISSIONS_R13_NATIVE_ENTRY_2026-10-01/inputs/rebuild_input.r12.json` (its LF content stays pinned).
That file names the build it was written for (44.0.2); the generator correctly refuses settings for another build. The
update tool rebuilds the installed package from the same input with the build label of the adopted registry and without
ids the registry no longer has (tools/update_check/uc_rebuild.py build_input); this does the same, so a harness tests the
package the current registry builds.

Package pins: the SHA-256 of the four package files that input builds on the current registry, in ONE file
(../test-results/package_pins.json, with the registry SHA-256 it belongs to). Every harness that pins the package reads
it; `python harness_input.py --repin` rebuilds and rewrites it (after an R step changes the registry, and by
`renovice_update.py --adopt` after a client update). A pin of another registry fails with that instruction.
"""
import hashlib
import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

EDITOR = Path(__file__).resolve().parents[3]
ROOT = EDITOR
while not (ROOT / 'WORKSPACE.json').exists():
    ROOT = ROOT.parent
REGISTRY = EDITOR / 'REGISTRIES/mission_build_u44.json'
INPUT = EDITOR / 'RESEARCH/MISSIONS_R13_NATIVE_ENTRY_2026-10-01/inputs/rebuild_input.r12.json'
PINS = Path(__file__).resolve().parents[1] / 'test-results' / 'package_pins.json'
PACKAGE_FILES = ('Missions.targets.addon.lua_B', 'package.json', 'literals.json', 'engine_params.json')
CLI = Path(os.environ.get('RENOVICE_EDITOR_CLI', ROOT / 'work/builds/ability-editor/current/bin/renovice_ability_editor_cli.exe'))


def current_spec(input_path: Path) -> dict:
    data = json.loads(Path(input_path).read_text(encoding='utf-8'))
    registry = json.loads(REGISTRY.read_text(encoding='utf-8'))
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


def staged_values(generation: Path, package_id: str = 'package:missions') -> dict:
    """The package's SCRIPT SETTINGS values a build staged (layout V2, 2026-10-10): its "values" entry in
    <generation>/ScriptStates.merge.json, the former Settings/<package>.json object unchanged."""
    fragment = json.loads((Path(generation) / 'ScriptStates.merge.json').read_text(encoding='utf-8'))
    assert fragment.get('schema') == 2 and package_id in fragment.get('values', {}), (generation, sorted(fragment))
    return fragment['values'][package_id]


def staged_values_file(generation: Path, out: Path, package_id: str = 'package:missions') -> Path:
    """staged_values written as a stand-alone values file (the input form of verify_addon_settings.ps1 -Settings)."""
    Path(out).write_text(json.dumps(staged_values(generation, package_id), indent=2) + '\n', encoding='utf-8')
    return Path(out)


def registry_sha256() -> str:
    return hashlib.sha256(REGISTRY.read_bytes()).hexdigest()


def package_pins() -> dict:
    """{package file: sha256} pinned for the current registry; exits with the re-pin instruction otherwise."""
    pins = json.loads(PINS.read_text(encoding='utf-8')) if PINS.exists() else {}
    if pins.get('registry_sha256') != registry_sha256():
        raise SystemExit(f'package pins in {PINS} belong to registry {str(pins.get("registry_sha256"))[:16]}, the current '
                         f'registry is {registry_sha256()[:16]}: re-pin with `python {Path(__file__).name} --repin`')
    return pins['files']


def repin(cli: Path = CLI) -> dict:
    """Builds the pinned input on the current registry and writes the package pins."""
    work = Path(tempfile.mkdtemp(prefix='renovice-repin-'))
    try:
        run = subprocess.run([str(cli), 'build-missions', str(current_input(INPUT, work)), '--staging', str(work / 'build'),
                              '--editor-root', str(EDITOR)], capture_output=True, text=True)
        generations = list((work / 'build').glob('missions/*/MISSION_SET_MANIFEST.json'))
        if run.returncode != 0 or len(generations) != 1:
            raise SystemExit(f'repin: build-missions failed: {(run.stderr or run.stdout).strip()[-400:]}')
        package = generations[0].parent / 'Packages' / 'Missions'
        files = {name: hashlib.sha256((package / name).read_bytes()).hexdigest() for name in PACKAGE_FILES}
    finally:
        shutil.rmtree(work, ignore_errors=True)
    registry = json.loads(REGISTRY.read_text(encoding='utf-8'))
    pins = {'format': 'RENOVICE_HARNESS_PACKAGE_PINS_V1', 'build': registry['build'], 'registry_sha256': registry_sha256(),
            'input': INPUT.relative_to(EDITOR).as_posix(),
            'input_lf_sha256': hashlib.sha256(INPUT.read_bytes().replace(b'\r\n', b'\n')).hexdigest(), 'files': files}
    PINS.parent.mkdir(parents=True, exist_ok=True)
    PINS.write_bytes((json.dumps(pins, indent=1) + '\n').encode('utf-8'))
    return pins


if __name__ == '__main__':
    if sys.argv[1:] == ['--repin']:
        pins = repin()
        print(f'package pins for registry {pins["registry_sha256"][:16]} (build {pins["build"]}): '
              + ', '.join(f'{k} {v[:8]}' for k, v in pins['files'].items()))
    else:
        raise SystemExit('usage: python harness_input.py --repin')
