"""Offline regression for LIVE_LITERALS_V1 recipe emission (2026-09-30, contract CONTRACT_PHASE1.md Revision R8).

1. Baked mode is unchanged: the rebuild input of the staged full package (work/staging/missions-full-package) builds a
   byte-identical package and values file (the exact-replacement builder now runs on the shared patch core).
2. Recipe mode ("literal_mode": "recipe", "literal_scope": "headline"): literals.json instead of baked members; every
   registry headline literal value declared; the generator's own synthesis of the five built literal values reproduces the
   staged baked replacements byte for byte; R5-C: no addon value is excluded because its module carries a literal value;
   the values file ships the literal values off except Void Flood (as before).
3. Build-input rejections for the new fields.
4. Older bootstrappers: the recipe package is admitted unchanged by the base bootstrapper b5a120b (no LIVE_LITERALS_V1):
   verify_script_packages -AdmitPackage and verify_addon_settings -Package/-Settings (git archive export, read-only).

Paths: the editor is this checkout; the CLI is RENOVICE_EDITOR_CLI or work/builds/ability-editor/current. Writes only to
work/temp/live-literals-tests and this tool's test-results folder. No game or server folder is read or written.
"""
from pathlib import Path
import hashlib, json, os, shutil, subprocess, sys, tarfile, io

EDITOR = Path(__file__).resolve().parents[3]
ROOT = EDITOR
while not (ROOT / 'WORKSPACE.json').exists():
    ROOT = ROOT.parent
CLI = Path(os.environ.get('RENOVICE_EDITOR_CLI', ROOT / 'work/builds/ability-editor/current/bin/renovice_ability_editor_cli.exe'))
STAGED = ROOT / 'work/staging/missions-full-package'
WORK = ROOT / 'work/temp/live-literals-tests'
BOOTSTRAPPER = ROOT / 'repos/runtime/bootstrapper-runtime'
OLD_REVISION = 'b5a120b'
OUT = Path(__file__).resolve().parents[1] / 'test-results'
BAKED = {'a807aae359ffc1eb': 'fff653e0efb3e6a4074b668d1ec3050a3fa1ae0a0ed3c06f7614521e3ad0e847',
         'fc711ff621a75552': 'e979f5e7906f0d88e49c42b4191eca6afdc1237fddd91d52cbf427db3fa9f6d2',
         'f7444e3c621ff018': '66b4f9349c0ec7fb45a457dfc2eed5d49c102c7b79e0c1183a6a874e8e7830e7',
         'b3a5a18d68d61e16': 'e2e8bb2f5b67aec1540245b18ac1786a4ab3ebe485d51faafc27ecb6add27e57',
         '8a0b0819de60df01': 'f0436757c021bdd7c9121dd57031791d0f8eb9aada9939727e488c783c1e134b'}
results = {'checks': []}


def check(ok, name):
    results['checks'].append({'name': name, 'pass': bool(ok)})
    print(('PASS' if ok else 'FAIL') + '\t' + name)
    if not ok:
        OUT.mkdir(parents=True, exist_ok=True)
        (OUT / 'live_literals.json').write_text(json.dumps(results, indent=2) + '\n', encoding='utf-8')
        sys.exit(1)


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def build(settings, name):
    target = WORK / name
    shutil.rmtree(target, ignore_errors=True)
    target.mkdir(parents=True)
    source = WORK / (name + '.json')
    source.write_text(json.dumps(settings, indent=2), encoding='utf-8')
    run = subprocess.run([str(CLI), 'build-missions', str(source), '--staging', str(target), '--editor-root', str(EDITOR)],
                         capture_output=True, text=True)
    manifests = list(target.glob('missions/*/MISSION_SET_MANIFEST.json'))
    return run, (manifests[0].parent if manifests else None)


WORK.mkdir(parents=True, exist_ok=True)
base = json.loads((STAGED / 'evidence/rebuild_input.mission_settings.json').read_text(encoding='utf-8'))

# 1. Baked mode unchanged.
run, generation = build(base, 'baked')
check(run.returncode == 0 and generation is not None, 'baked build succeeds')
staged_members = {p.name: sha(p) for p in (STAGED / 'Packages/Missions').iterdir()}
built_members = {p.name: sha(p) for p in (generation / 'Packages/Missions').iterdir()}
check(staged_members == built_members, f'baked package byte-identical to the staged set ({len(built_members)} files)')
check(sha(generation / 'Settings/Missions.json') == sha(STAGED / 'Settings/Missions.json'), 'baked values file byte-identical')

# 2. Recipe mode.
recipe_input = dict(base, literal_mode='recipe', literal_scope='headline')
run, generation = build(recipe_input, 'recipe')
check(run.returncode == 0 and generation is not None, 'recipe build succeeds')
package = generation / 'Packages/Missions'
check(sorted(p.name for p in package.iterdir()) == ['Missions.targets.addon.lua_B', 'literals.json', 'package.json'],
      'recipe package: addon + package.json + literals.json, no baked replacement member')
recipe = json.loads((package / 'literals.json').read_text(encoding='utf-8'))
registry = json.loads((EDITOR / 'REGISTRIES/mission_build_u44.json').read_text(encoding='utf-8'))
headline = registry['ui_player_text']['live_literal_headline']
check(set(recipe['values']) == set(headline), f'every registry headline literal value is declared ({len(headline)})')
check(all(v['declaration']['lane'] == 'literal' and v['declaration']['applies'] == 'next_mission' for v in recipe['values'].values()),
      'recipe declarations are literal lane, applies next_mission')
for body, digest in BAKED.items():
    synthesized = generation / 'live-literals' / f'{body}.synthesized.lua_B'
    check(synthesized.exists() and sha(synthesized) == digest, f'recipe synthesis of {body} equals the staged baked replacement')
manifest = json.loads((generation / 'MISSION_SET_MANIFEST.json').read_text(encoding='utf-8'))
excluded = manifest['package']['settings']['declarations']['excluded_values']
check(not any('is built as an exact replacement' in e['reason'] for e in excluded),
      'R5-C: no addon value is excluded because its module carries a literal value')
declared = json.loads((package / 'package.json').read_text(encoding='utf-8'))
addon_values = declared['members']['Missions.targets.addon.lua_B']['settings']['values']
check(all(f'mobiledefense.enemy_counts.max.p{n}' in addon_values for n in range(1, 5)),
      'R5-C: Mobile Defense enemy counts are declared next to its live literal timer')
values = json.loads((generation / 'Settings/Missions.json').read_text(encoding='utf-8'))['values']
on = sorted(k for k, v in values.items() if v['enabled'])
check(on == ['survival.reward_interval', 'void_flood.fractures_per_round.normal'] and values['mobiledefense.time_per_terminal'] == {'enabled': False, 'value': 20},
      'values file: shipped choices unchanged (Survival 150 on, Void Flood 4 on, the other built literals off)')
gates = (generation / 'BUILD_GATES.log').read_text(encoding='utf-8')
check('live-literal-core\nPASS' in gates and 'live-literal-recipe\nPASS' in gates, 'generator gates live-literal-core and live-literal-recipe PASS')
check('Script-literal values (literals.json) need the LIVE_LITERALS_V1 bootstrapper' in declared['description'],
      'package description names the requirement (older DLLs: those values stay stock)')
results['recipe'] = {'values': len(recipe['values']), 'modules': len(recipe['modules']),
                     'masters': sum(1 for k, v in recipe['values'].items() if len(v['drives']) != 1 or v['drives'][0]['row'] != k),
                     'literals_json_sha256': sha(package / 'literals.json'), 'package_json_sha256': sha(package / 'package.json'),
                     'generation': str(generation.relative_to(ROOT))}

# 3. Rejections.
for bad, reason in ((dict(base, literal_mode='recipe', output_layout='loose'), 'recipe without package layout'),
                    (dict(base, literal_scope='headline'), 'headline scope without recipe mode'),
                    (dict(base, literal_mode='live'), 'unknown literal_mode')):
    run, _ = build(bad, 'reject')
    check(run.returncode != 0, f'reject: {reason}')

# 4. The base bootstrapper (no LIVE_LITERALS_V1) admits the recipe package unchanged.
# The old gates resolve the DE Luau toolchain as ..\..\toolchains from their repository folder: export to
# WORK/bsv/<rev> and give WORK a directory junction `toolchains` -> repos/toolchains (read-only use).
old = WORK / 'bsv' / OLD_REVISION
if not (WORK / 'toolchains').exists():
    subprocess.run(['cmd', '/c', 'mklink', '/J', str(WORK / 'toolchains'), str(ROOT / 'repos/toolchains')], check=True,
                   capture_output=True)
if not (old / 'RENOVICE_TOOLCHAIN').exists():
    shutil.rmtree(old, ignore_errors=True)
    old.mkdir(parents=True)
    archive = subprocess.run(['git', '-C', str(BOOTSTRAPPER), 'archive', '--format=tar', OLD_REVISION], capture_output=True)
    check(archive.returncode == 0, f'git archive {OLD_REVISION}')
    with tarfile.open(fileobj=io.BytesIO(archive.stdout)) as tar:
        tar.extractall(old, filter='tar')
admit = subprocess.run(['powershell', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File',
                        str(old / 'RENOVICE_TOOLCHAIN/injection/verify_script_packages.ps1'), '-AdmitPackage', str(package)],
                       capture_output=True, text=True)
check(admit.returncode == 0 and 'PACKAGE ACCEPT' in admit.stdout, f'{OLD_REVISION}: verify_script_packages -AdmitPackage PACKAGE ACCEPT')
accept_line = [line for line in admit.stdout.splitlines() if 'PACKAGE ACCEPT' in line]
settings = subprocess.run(['powershell', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File',
                           str(old / 'RENOVICE_TOOLCHAIN/settings/verify_addon_settings.ps1'), '-Package', str(package),
                           '-Settings', str(generation / 'Settings/Missions.json')], capture_output=True, text=True)
check(settings.returncode == 0 and 'ADDON SETTINGS GATES PASS' in settings.stdout,
      f'{OLD_REVISION}: verify_addon_settings -Package/-Settings ADDON SETTINGS GATES PASS (literals.json ignored)')
results['old_bootstrapper'] = {'revision': OLD_REVISION, 'admit': accept_line[:1],
                               'settings_tail': [l for l in settings.stdout.splitlines() if 'DELIVERY' in l or 'unknown' in l.lower()][:4]}
OUT.mkdir(parents=True, exist_ok=True)
(OUT / 'live_literals.json').write_text(json.dumps(results, indent=2) + '\n', encoding='utf-8')
print(f"LIVE LITERALS GENERATOR TESTS PASS checks={len(results['checks'])}")
