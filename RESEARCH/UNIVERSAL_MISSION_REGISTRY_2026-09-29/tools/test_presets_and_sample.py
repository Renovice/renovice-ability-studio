"""Offline regression for the 44.0.2 mission registry: 12 preset builds through the registry path, 3 rejections per
preset, rebuilds of the Phase 2b/2d/2e sample settings with default settings and with the live-acceptance opt-in
(compared with their recorded manifests, folders left untouched) and the Phase 2f/2g sample group builds. Writes only to
work/staging and the Phase 1 research folder.
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
# Preset artifacts must stay byte-identical to the previously recorded run (presets keep their established lanes).
previous_presets = {p['preset']: p['sha256'] for p in json.loads((OUT / 'results.json').read_text())['presets']} \
    if (OUT / 'results.json').exists() else {}
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
    if pid in previous_presets:
        assert previous_presets[pid] == results['presets'][-1]['sha256'], (pid, 'preset artifact changed')
    results['presets'][-1]['identical_to_previous_run'] = pid in previous_presets
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

# Phase 2f (2026-09-29): target addons act only through hook binding renovice.target.lua_call, which is not
# LIVE_CONFIRMED (the 44.0.2 live test attached the Survival addon but no luaCalls.before ever ran). Default settings
# therefore use a row's exact literal form or fail closed with NEEDS_BINDING; the addon is staged only with the explicit
# live-acceptance opt-in. Earlier samples (Phase 2b, 2d, 2e) stay untouched as dated evidence: their settings are rebuilt
# into staging with the default settings (rejection recorded when NEEDS_BINDING) and with the opt-in, and every artifact
# is compared with the recorded manifest.
SAMPLE2E = ROOT / 'work/research/universal-mission-editor-2026-09-29/phase2e-sample'
SAMPLE2F = ROOT / 'work/research/universal-mission-editor-2026-09-29/phase2f-sample'
LUA_CALL = 'renovice.target.lua_call'
PHASE2E_VALUES = {
    'survival.reward_interval': 150,               # addon-only root-table field (constant shared with killPlayerTime)
    'void_flood.fractures_per_round.normal': 4,    # root local frame_83[33] (exact literal)
    'lantern.tier_up_interval': 60,                # Lantern root spawn config field (addon + literal form)
    'purgatory.difficulty1.warrior_level': 15,     # Purgatory difficulty table 1 (nested root table, addon-only)
}


def build(settings, name):
    path = WORK / f'{name}.settings.json'
    path.write_text(json.dumps(settings, indent=2) + '\n')
    r = run('build-missions', path, '--staging', STAGING / name)
    (WORK / f'{name}-build.log').write_text(r.stdout + r.stderr)
    if r.returncode != 0:
        return None, r.stdout + r.stderr
    generation = Path(next(l.split(': ', 1)[1] for l in r.stdout.splitlines() if l.startswith('Generation: ')))
    return generation, json.loads((generation / 'MISSION_SET_MANIFEST.json').read_text())


def probe(settings):
    return dict(settings, allow_unproven_hook_bindings=[LUA_CALL])


def per_body(manifest):
    """Per-body view of a set manifest. Phase 2g: one multi-target addon covers several body keys; each covered body is
    compared against its recorded single-key artifact (never byte-identical: the file format changed by design)."""
    rows = []
    for a in manifest['artifacts']:
        if a.get('target_keys'):
            for target in a['targets']:
                rows.append(dict(a, body_key=target['body_key'], tunables=target['tunables'], multi_target=a['path']))
        else:
            rows.append(a)
    return rows


def sample(folder, settings, name, extra_files):
    """Builds a sample into staging. A recorded sample folder is dated evidence and is never rewritten: its artifacts
    must be byte-identical to the rebuild. Only a missing folder is created (settings, extra files, generation, sums)."""
    generation, manifest = build(settings, name)
    assert generation is not None, manifest
    built = {p.name: hashlib.sha256(p.read_bytes()).hexdigest().upper() for p in (generation / 'artifacts').iterdir()}
    if (folder / 'SHA256SUMS.json').exists():
        recorded = json.loads((folder / 'SHA256SUMS.json').read_text())
        recorded = {k.split('/')[-1]: v for k, v in recorded.items() if k.startswith('generation/artifacts/')}
        assert recorded == built, (folder.name, 'rebuilt artifacts differ from the recorded sample', recorded, built)
        return manifest, 'identical to the recorded sample (folder untouched)'
    folder.mkdir(parents=True)
    (folder / 'mission_settings.json').write_text(json.dumps(settings, indent=2) + '\n')
    for file_name, value in extra_files.items():
        (folder / file_name).write_text(json.dumps(value, indent=2) + '\n')
    shutil.copytree(generation, folder / 'generation')
    hashes = {p.relative_to(folder).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest().upper()
              for p in sorted(folder.rglob('*')) if p.is_file()}
    (folder / 'SHA256SUMS.json').write_text(json.dumps(hashes, indent=2) + '\n')
    return manifest, 'created'


def compare(recorded, manifest):
    before = {a['body_key']: a for a in recorded['artifacts']}
    now = per_body(manifest)
    assert sorted(before) == sorted(a['body_key'] for a in now)
    return [{'body_key': a['body_key'], 'tunables': a['tunables'], 'backend_before': before[a['body_key']]['backend'],
             'backend_now': a['backend'], 'identical': before[a['body_key']]['sha256'] == a['sha256'], 'sha256_now': a['sha256'],
             'multi_target_artifact': a.get('multi_target'), 'runtime_hook': a.get('runtime_hook')} for a in now]


for folder, name in [(SAMPLE, 'sample2b'), (SAMPLE2D, 'sample2d'), (SAMPLE2E, 'sample2e')]:
    settings = json.loads((folder / 'mission_settings.json').read_text())
    recorded = json.loads((folder / 'generation/MISSION_SET_MANIFEST.json').read_text())
    generation, default = build(settings, name)
    entry = {}
    if generation is None:
        assert 'NEEDS_BINDING' in default and LUA_CALL in default, default
        entry['default'] = {'result': 'REJECTED', 'reason': next(l for l in default.splitlines() if 'NEEDS_BINDING' in l).strip()}
    else:
        entry['default'] = {'result': 'PASS', 'artifacts': compare(recorded, default)}
        assert all(a['backend'] != 'TARGET_ADDON' for a in default['artifacts']), 'default build staged an unproven addon'
    generation, opted = build(probe(settings), name + '-probe')
    assert generation is not None, opted
    entry['opt_in_probe'] = compare(recorded, opted)
    for a in opted['artifacts']:
        if a['backend'] == 'TARGET_ADDON':
            assert a['runtime_hook']['registry_status'] == 'OFFLINE_VERIFIED' and a['runtime_hook']['built_by_explicit_opt_in']
    results[name + '_rebuild'] = entry
    print('PASS', name, 'default:', entry['default']['result'], '| opt-in probe identical:',
          sum(c['identical'] for c in entry['opt_in_probe']), 'of', len(entry['opt_in_probe']), flush=True)

# Phase 2f sample: the Phase 2e values rebuilt with default settings. Survival reward interval and Purgatory warrior level
# have no exact literal form, so they are rejected with NEEDS_BINDING and left out; Void Flood and Lantern build as exact
# replacements (the Lantern tier-up row uses its literal form while the addon binding is unproven).
buildable = {k: v for k, v in PHASE2E_VALUES.items() if k not in ('survival.reward_interval', 'purgatory.difficulty1.warrior_level')}
base_settings = {'format': 'RENOVICE_MISSION_SETTINGS_V1', 'build': registry['build']}
rejected = {}
for tid in ('survival.reward_interval', 'purgatory.difficulty1.warrior_level'):
    generation, text = build(dict(base_settings, values={tid: PHASE2E_VALUES[tid]}), 'sample2f-reject-' + tid.split('.')[0])
    assert generation is None and 'NEEDS_BINDING' in text and tid in text and LUA_CALL in text, text
    rejected[tid] = next(l for l in text.splitlines() if 'NEEDS_BINDING' in l).strip()
settings2f = dict(base_settings, values=buildable)
manifest2f, state2f = sample(SAMPLE2F, settings2f, 'sample2f', {'rejected_rows.json': {'requested': PHASE2E_VALUES, 'rejected': rejected}})
assert [a['backend'] for a in manifest2f['artifacts']] == ['EXACT_LITERAL', 'EXACT_LITERAL'], manifest2f['artifacts']
assert sorted(t for a in manifest2f['artifacts'] for t in a['tunables']) == sorted(buildable)
results['phase2f_sample'] = {'values': buildable, 'artifacts': manifest2f['artifacts'], 'rejected': rejected,
                             'location': SAMPLE2F.relative_to(ROOT).as_posix()}
print(f"PASS phase2f sample artifacts={len(manifest2f['artifacts'])} rejected={sorted(rejected)} ({state2f})")

# Phase 2g sample: the live-test set with the explicit opt-in. Every addon-lane body key goes into ONE multi-target addon
# (Inject/Missions.targets.addon.lua_B); the Void Flood fracture count stays a separate exact replacement.
SAMPLE2G = ROOT / 'work/research/universal-mission-editor-2026-09-29/phase2g-sample'
PHASE2G_VALUES = {
    'survival.reward_interval': 150,               # Survival root table (shared constant with killPlayerTime), addon only
    'purgatory.difficulty1.warrior_level': 15,     # Purgatory nested difficulty table, addon only
    'lantern.tier_up_interval': 60,                # Lantern spawn config, addon lane (literal form exists)
    'void_flood.fractures_per_round.normal': 4,    # root local, exact replacement
}
settings2g = probe(dict(base_settings, values=PHASE2G_VALUES))
manifest2g, state2g = sample(SAMPLE2G, settings2g, 'sample2g', {})
addons = [a for a in manifest2g['artifacts'] if a['backend'] == 'TARGET_ADDON']
literals = [a for a in manifest2g['artifacts'] if a['backend'] == 'EXACT_LITERAL']
assert len(addons) == 1 and len(literals) == 1 and len(manifest2g['artifacts']) == 2, manifest2g['artifacts']
assert addons[0]['path'] == 'artifacts/Missions.targets.addon.lua_B', addons[0]['path']
assert sorted(addons[0]['target_keys']) == ['6fa60841c9e0f207', 'caec63d8e739b693', 'f10a043e7f825db2'], addons[0]['target_keys']
assert addons[0]['runtime_hook']['registry_status'] == 'OFFLINE_VERIFIED' and addons[0]['runtime_hook']['built_by_explicit_opt_in']
assert literals[0]['body_key'] == 'fc711ff621a75552'
results['phase2g_sample'] = {'values': PHASE2G_VALUES, 'allow_unproven_hook_bindings': [LUA_CALL],
                             'artifacts': manifest2g['artifacts'], 'location': SAMPLE2G.relative_to(ROOT).as_posix()}

# Phase 2h sample: the Phase 2g settings with "output_layout": "package". The same Lua artifacts, byte for byte, are also
# emitted as ONE optional bootstrapper folder package Packages/Missions/ (bootstrapper feat/script-packages-2026-09-29):
# package.json + Missions.targets.addon.lua_B + the Void Flood exact replacement; one Scripts row [PACKAGE] Missions.
SAMPLE2H = ROOT / 'work/research/universal-mission-editor-2026-09-29/phase2h-sample'
settings2h = dict(settings2g, output_layout='package')
generation2h, manifest2h = build(settings2h, 'sample2h')
assert generation2h is not None, manifest2h
package2h = generation2h / 'Packages' / 'Missions'
members2h = sorted(p.name for p in package2h.iterdir() if p.name != 'package.json')
assert sorted(p.name for p in package2h.iterdir()) == sorted(members2h + ['package.json']), list(package2h.iterdir())
assert members2h == sorted(['Missions.targets.addon.lua_B', 'fc711ff621a75552 (missions_exact-replacement).lua_B']), members2h
loose2g = {Path(a['path']).name: a['sha256'] for a in manifest2g['artifacts']}
package_hashes = {name: hashlib.sha256((package2h / name).read_bytes()).hexdigest().upper() for name in members2h}
assert package_hashes == {name: loose2g[name] for name in members2h}, ('package members differ from the loose build', package_hashes)
package_json = json.loads((package2h / 'package.json').read_text(encoding='utf-8'))
assert package_json['schema'] == 1 and package_json['name'] == 'Missions' and package_json['settings'] == {}
assert sorted(package_json['members']) == members2h
assert manifest2h['output_layout'] == 'package' and manifest2h['package']['scripts_menu']['policy_id'] == 'package:missions'
assert all(a['intended_live_relative_path'].startswith('OpenWF/CustomScripts/Packages/Missions/')
           for a in manifest2h['artifacts'] if a['backend'] in ('TARGET_ADDON', 'EXACT_LITERAL'))
if (SAMPLE2H / 'SHA256SUMS.json').exists():
    recorded = json.loads((SAMPLE2H / 'SHA256SUMS.json').read_text())
    recorded = {k.split('/')[-1]: v for k, v in recorded.items() if k.startswith('Packages/Missions/')}
    rebuilt = dict(package_hashes, **{'package.json': hashlib.sha256((package2h / 'package.json').read_bytes()).hexdigest().upper()})
    assert recorded == rebuilt, ('rebuilt package differs from the recorded Phase 2h sample', recorded, rebuilt)
    state2h = 'identical to the recorded sample (folder untouched)'
else:
    SAMPLE2H.mkdir(parents=True)
    (SAMPLE2H / 'mission_settings.json').write_text(json.dumps(settings2h, indent=2) + '\n')
    shutil.copytree(generation2h, SAMPLE2H / 'generation')
    shutil.copytree(generation2h / 'Packages', SAMPLE2H / 'Packages')  # install-ready: copy Packages\ into OpenWF\CustomScripts\
    sums = {p.relative_to(SAMPLE2H).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest().upper()
            for p in sorted(SAMPLE2H.rglob('*')) if p.is_file()}
    (SAMPLE2H / 'SHA256SUMS.json').write_text(json.dumps(sums, indent=2) + '\n')
    state2h = 'created'
results['phase2h_sample'] = {'values': PHASE2G_VALUES, 'allow_unproven_hook_bindings': [LUA_CALL], 'output_layout': 'package',
                             'package': manifest2h['package'], 'location': SAMPLE2H.relative_to(ROOT).as_posix()}
print(f"PASS phase2h sample: Packages/Missions with {len(members2h)} members, byte-identical to phase 2g ({state2h})")
(OUT / 'results.json').write_text(json.dumps(results, indent=2) + '\n')
print(f"PASS phase2g sample: 1 multi-target addon ({len(addons[0]['target_keys'])} targets) + {len(literals)} replacement ({state2g})")
print(f"PASS {len(results['presets'])} preset builds, {results['rejections']} rejections")
