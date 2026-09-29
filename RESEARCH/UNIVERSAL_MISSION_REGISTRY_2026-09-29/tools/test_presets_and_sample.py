"""Offline regression for the 44.0.2 mission registry: 12 preset builds through the registry path, 3 rejections per
preset, and one sample mission_settings.json group build. Writes only to work/staging and the Phase 1 research folder.
No game or server folder is written. Requires the built CLI (work/builds/ability-editor/current)."""
from pathlib import Path
import copy, hashlib, json, shutil, subprocess

ROOT = Path(__file__).resolve().parents[6]
EDITOR = ROOT / 'repos/apps/ability-editor'
CLI = ROOT / 'work/builds/ability-editor/current/bin/renovice_ability_editor_cli.exe'
STAGING = ROOT / 'work/staging/aer44'  # short: generated names are long and Windows MAX_PATH applies
OUT = Path(__file__).resolve().parents[1] / 'test-results'  # results.json only (committed)
WORK = STAGING / 'inputs'  # generated projects and logs (not committed)
SAMPLE = ROOT / 'work/research/universal-mission-editor-2026-09-29/phase2b-sample'
registry = json.loads((EDITOR / 'REGISTRIES/mission_build_u44.json').read_text(encoding='utf-8'))
base = json.loads((EDITOR / 'EXAMPLES/mallet_linked_overguard_addon.json').read_text(encoding='utf-8'))
MODES = {'EXACT_LITERAL': 'MANAGED_MISSION_EXACT_REPLACEMENT', 'METADATA_PATCH': 'MANAGED_MISSION_METADATA_PATCH'}
FASTER = {
    'survival': {'reward_interval': 150, 'pickup_life_support': 7, 'pickup_reward_progress': 5},
    'mobile_defense': {'minimum_total_time': 90, 'maximum_total_time': 120},
    'interception': {'scoring_speed_multiplier': 2},
    'excavation': {'standard_dig_time': 50, 'old_world_salvage_dig_time': 30, 'elite_alert_dig_time': 70},
    'control_area_plains': {'control_area_duration': 30}, 'control_area_deimos': {'control_area_duration': 30},
    'control_area_nokko': {'control_area_duration': 30}, 'void_cascade': {'exolizer_speed_multiplier': 2},
    'netracells': {'power_per_kill': 2}, 'descendia_shrine': {'offering_generation_time': 15},
    'descendia_excavation': {'dig_duration': 15},
    'archimedea': {'eta_survival_minutes': 5, 'eta_defense_waves': 3, 'eda_survival_minutes': 5, 'eda_mirror_defenses': 2,
                   'eda_alchemy_mixtures': 1, 'eda_disruption_conduits': 4},
}
SAMPLE2D = ROOT / 'work/research/universal-mission-editor-2026-09-29/phase2d-sample'
PHASE2D_VALUES = {  # new modes; every Phase 2d owner mechanism in one settings file
    'disruption.default_round_count': 6,           # one tunable, 7 LOADN sites (fixedLength + Ternary fallbacks)
    'disruption.boss_health_multiplier': 0.5,      # root config table template f64 (single-use template gate)
    'disruption.round_timeout': 120,
    'excavation.resource_goal_default': 300,       # one tunable, 3 LOADN sites (Phase 2d re-derived owner)
    'void_flood.fill_timer.timeToFillMax': 150,    # root config table template
    'orphix.sortie_rounds': 8,                     # one tunable, 2 sites (reward interval + round limit)
    'hijack.payload_health': 20000,
    'netracell.power_required.base': 100,
    'survival.elite_alert_pickup_mult': 1,         # instruction-used f64 constant (exclusive MULK)
    'defense.inter_wave_sleep': 3,
    'infested_capture.search_time.wf1999': 50,     # metadata, 1999 Legacyte Harvest owner type
    'meltdown.heat_increase.descendia': 0.0125,    # metadata, Descendia Meltdown owner type
    'coh_excavation.base_health': 3000,            # metadata, two runtime Scripts entries patched together
}


def run(*args):
    return subprocess.run([str(CLI), *map(str, args), '--editor-root', str(EDITOR)], capture_output=True, text=True)


OUT.mkdir(parents=True, exist_ok=True)
WORK.mkdir(parents=True, exist_ok=True)
results = {'build': registry['build'], 'presets': [], 'rejections': 0}
for pid, preset in registry['missions'].items():
    p = copy.deepcopy(base)
    p['id'] = f'm.{pid}'
    lane = preset['lane']
    p['authoring_mode'] = MODES.get(lane) or registry['modules'][preset['body_key']]['addon']['authoring_mode']
    p['target'].update(module_body_key=preset['body_key'], module_path=preset['module_path'], installed_build=registry['build'])
    p['mission_profile'] = {'build': registry['build'], 'id': pid, 'values': FASTER[pid]}
    path = WORK / f'{pid}.json'
    path.write_text(json.dumps(p, indent=2))
    r = run('build', path, '--staging', STAGING)
    (WORK / f'{pid}.log').write_text(r.stdout + r.stderr)
    assert r.returncode == 0, (pid, r.stdout, r.stderr)
    artifact = Path(next(l.split(': ', 1)[1] for l in r.stdout.splitlines() if l.startswith('Bytecode: ')))
    results['presets'].append({'preset': pid, 'lane': lane, 'artifact': artifact.name,
                               'sha256': hashlib.sha256(artifact.read_bytes()).hexdigest().upper()})
    for name, mutate in [('wrong-body', lambda q: q['target'].update(module_body_key='0000000000000000')),
                         ('wrong-build', lambda q: q['mission_profile'].update(build='2026.09.24.13.29')),
                         ('out-of-range', lambda q: q['mission_profile']['values'].update({next(iter(FASTER[pid])): -1}))]:
        q = copy.deepcopy(p)
        mutate(q)
        bad = WORK / f'{pid}-{name}.json'
        bad.write_text(json.dumps(q))
        assert run('validate', bad).returncode != 0, (pid, name)
        results['rejections'] += 1
    print('PASS', pid, lane, artifact.name, flush=True)

# Sample group build: metadata, literal, root-table (addon), server, two literal rows in one module, ConquestLib.
settings = {'format': 'RENOVICE_MISSION_SETTINGS_V1', 'build': registry['build'], 'values': {
    'netracell.enemy_power_fill': 2,
    'shrine.offering_generation_time': 15,
    'mobiledefense.total_time.minimum': 90,
    'mobiledefense.total_time.maximum': 120,
    'survival.reward_interval': 150,
    'server.credit_boost_multiplier': 2,
    'excavation.dig_duration': 50,
    'excavation.dig_duration_elite_alert': 70,
    'archimedea.eta_survival_minutes': 5,
}}
if SAMPLE.exists():
    shutil.rmtree(SAMPLE)
SAMPLE.mkdir(parents=True)
(SAMPLE / 'mission_settings.json').write_text(json.dumps(settings, indent=2) + '\n')
staging = STAGING / 'sample'
r = run('build-missions', SAMPLE / 'mission_settings.json', '--staging', staging)
(WORK / 'sample-build.log').write_text(r.stdout + r.stderr)
assert r.returncode == 0, (r.stdout, r.stderr)
generation = Path(next(l.split(': ', 1)[1] for l in r.stdout.splitlines() if l.startswith('Generation: ')))
shutil.copytree(generation, SAMPLE / 'generation')
manifest = json.loads((SAMPLE / 'generation/MISSION_SET_MANIFEST.json').read_text())
assert len({a['body_key'] for a in manifest['artifacts']}) == len(manifest['artifacts'])
hashes = {str(p.relative_to(SAMPLE)).replace('\\', '/'): hashlib.sha256(p.read_bytes()).hexdigest().upper()
          for p in sorted(SAMPLE.rglob('*')) if p.is_file()}
(SAMPLE / 'SHA256SUMS.json').write_text(json.dumps(hashes, indent=2) + '\n')
results['sample'] = {'artifacts': manifest['artifacts'], 'server_config_diff': manifest['server_config_diff'],
                     'location': str(SAMPLE.relative_to(ROOT)).replace('\\', '/')}

# Phase 2d sample group build (research folder only, hashed).
settings2d = {'format': 'RENOVICE_MISSION_SETTINGS_V1', 'build': registry['build'], 'values': PHASE2D_VALUES}
if SAMPLE2D.exists():
    shutil.rmtree(SAMPLE2D)
SAMPLE2D.mkdir(parents=True)
(SAMPLE2D / 'mission_settings.json').write_text(json.dumps(settings2d, indent=2) + '\n')
r = run('build-missions', SAMPLE2D / 'mission_settings.json', '--staging', STAGING / 'sample2d')
(WORK / 'sample2d-build.log').write_text(r.stdout + r.stderr)
assert r.returncode == 0, (r.stdout, r.stderr)
generation = Path(next(l.split(': ', 1)[1] for l in r.stdout.splitlines() if l.startswith('Generation: ')))
shutil.copytree(generation, SAMPLE2D / 'generation')
manifest2d = json.loads((SAMPLE2D / 'generation/MISSION_SET_MANIFEST.json').read_text())
assert len({a['body_key'] for a in manifest2d['artifacts']}) == len(manifest2d['artifacts'])
assert sorted(t for a in manifest2d['artifacts'] for t in a['tunables']) == sorted(PHASE2D_VALUES)
hashes = {str(p.relative_to(SAMPLE2D)).replace('\\', '/'): hashlib.sha256(p.read_bytes()).hexdigest().upper()
          for p in sorted(SAMPLE2D.rglob('*')) if p.is_file()}
(SAMPLE2D / 'SHA256SUMS.json').write_text(json.dumps(hashes, indent=2) + '\n')
results['phase2d_sample'] = {'values': PHASE2D_VALUES, 'artifacts': manifest2d['artifacts'],
                             'location': str(SAMPLE2D.relative_to(ROOT)).replace('\\', '/')}
(OUT / 'results.json').write_text(json.dumps(results, indent=2) + '\n')
print(f"PASS phase2d sample artifacts={len(manifest2d['artifacts'])}")
print(f"PASS {len(results['presets'])} preset builds, {results['rejections']} rejections, sample artifacts={len(manifest['artifacts'])}")
