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


# Phase 2i (2026-09-29): the multi-target addon reads context.settings (ADDON_SETTINGS_V1) and package.json carries the
# settings declarations, so these two files differ from samples recorded before Phase 2i BY DESIGN. Every other artifact
# must stay byte-identical; the recorded folders are never rewritten.
INTENTIONAL_2I = {'Missions.targets.addon.lua_B', 'package.json'}


def sample(folder, settings, name, extra_files, intentional=frozenset()):
    """Builds a sample into staging. A recorded sample folder is dated evidence and is never rewritten: its artifacts
    must be byte-identical to the rebuild, except the files named in `intentional` (recorded as intentional changes). Only
    a missing folder is created (settings, extra files, generation, sums)."""
    generation, manifest = build(settings, name)
    assert generation is not None, manifest
    built = {p.name: hashlib.sha256(p.read_bytes()).hexdigest().upper() for p in (generation / 'artifacts').iterdir()}
    if (folder / 'SHA256SUMS.json').exists():
        recorded = json.loads((folder / 'SHA256SUMS.json').read_text())
        recorded = {k.split('/')[-1]: v for k, v in recorded.items() if k.startswith('generation/artifacts/')}
        assert sorted(recorded) == sorted(built), (folder.name, 'artifact set changed', recorded, built)
        changed = sorted(k for k in built if built[k] != recorded[k])
        assert set(changed) <= set(intentional), (folder.name, 'rebuilt artifacts differ from the recorded sample', changed)
        if changed:
            return manifest, 'identical except the intentional Phase 2i change of ' + ', '.join(changed) + ' (folder untouched)'
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
manifest2g, state2g = sample(SAMPLE2G, settings2g, 'sample2g', {}, INTENTIONAL_2I)
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
assert package_json['schema'] == 1 and package_json['name'] == 'Missions'
assert package_json['settings']['format'] == 'RENOVICE_SETTINGS_DECL_V1' and package_json['settings']['build'] == registry['build']
assert sorted(package_json['members']) == members2h
assert manifest2h['output_layout'] == 'package' and manifest2h['package']['scripts_menu']['policy_id'] == 'package:missions'
assert all(a['intended_live_relative_path'].startswith('OpenWF/CustomScripts/Packages/Missions/')
           for a in manifest2h['artifacts'] if a['backend'] in ('TARGET_ADDON', 'EXACT_LITERAL'))
if (SAMPLE2H / 'SHA256SUMS.json').exists():
    recorded = json.loads((SAMPLE2H / 'SHA256SUMS.json').read_text())
    recorded = {k.split('/')[-1]: v for k, v in recorded.items() if k.startswith('Packages/Missions/')}
    rebuilt = dict(package_hashes, **{'package.json': hashlib.sha256((package2h / 'package.json').read_bytes()).hexdigest().upper()})
    assert sorted(recorded) == sorted(rebuilt), ('package member set changed', recorded, rebuilt)
    changed2h = sorted(k for k in rebuilt if rebuilt[k] != recorded[k])
    assert set(changed2h) <= INTENTIONAL_2I, ('rebuilt package differs from the recorded Phase 2h sample', changed2h)
    state2h = ('identical except the intentional Phase 2i change of ' + ', '.join(changed2h) if changed2h else 'identical') + \
        ' to the recorded sample (folder untouched)'
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
# Phase 2i sample: the Phase 2h settings rebuilt with settings declarations. Packages/Missions/ is install-ready;
# CustomScripts/Settings/Missions.json is the hand-editable values file for the Phase 2 live test (Survival reward interval
# 150 enabled, Purgatory warrior level present but disabled, Lantern absent = stock, Void Flood replacement value kept
# enabled so its one-value member stays on).
SAMPLE2I = ROOT / 'work/research/universal-mission-editor-2026-09-29/phase2i-sample'
generation2i, manifest2i = build(settings2h, 'sample2i')
assert generation2i is not None, manifest2i
package2i = generation2i / 'Packages' / 'Missions'
pkg2i = json.loads((package2i / 'package.json').read_text(encoding='utf-8'))
decl2i = {vid: (member, d) for member, m in pkg2i['members'].items() for vid, d in m['settings']['values'].items()}
groups2i = {g['id']: g for g in pkg2i['settings']['groups']}
assert sorted(decl2i) == sorted(PHASE2G_VALUES), sorted(decl2i)
for vid, (member, d) in decl2i.items():
    row = next(r for r in registry['tunables'] if r['tunable_id'] == vid)
    assert d['stock'] == row['stock'] and d['label'] == row['ui']['short_label'] and d['group'] in groups2i, vid
    assert len('Custom ' + d['label']) <= 40 and len(groups2i[d['group']]['label'].upper()) <= 48, vid
    assert d['lane'] == ('addon' if member.endswith('.targets.addon.lua_B') else 'literal'), vid
# Package members other than the addon and package.json are byte-identical to Phase 2h (the Void Flood replacement).
for name in members2h:
    if name not in INTENTIONAL_2I:
        assert hashlib.sha256((package2i / name).read_bytes()).hexdigest().upper() == package_hashes[name], name
migration2i = json.loads((generation2i / 'Settings' / 'Missions.json').read_text(encoding='utf-8'))
assert migration2i['values'] == {k: {'enabled': True, 'value': v} for k, v in PHASE2G_VALUES.items()}, migration2i
EXAMPLE2I = {'format': 'RENOVICE_SCRIPT_SETTINGS_V1', 'package': 'package:missions', 'build': registry['build'], 'use_stock': False,
             'groups': {g: True for g in sorted(groups2i)},
             'values': {'survival.reward_interval': {'enabled': True, 'value': 150},
                        'purgatory.difficulty1.warrior_level': {'enabled': False, 'value': 15},
                        'void_flood.fractures_per_round.normal': {'enabled': True, 'value': 4}}}
for vid, entry in EXAMPLE2I['values'].items():  # the example must validate against the declarations
    d = decl2i[vid][1]
    assert set(entry) == {'enabled', 'value'} and isinstance(entry['enabled'], bool) and d['min'] <= entry['value'] <= d['max'], vid
    assert d['type'] != 'int' or float(entry['value']).is_integer(), vid
assert set(EXAMPLE2I['groups']) <= set(groups2i)
package_files2i = sorted(p.name for p in package2i.iterdir())
if (SAMPLE2I / 'SHA256SUMS.json').exists():
    recorded = json.loads((SAMPLE2I / 'SHA256SUMS.json').read_text())
    recorded = {k.split('/')[-1]: v for k, v in recorded.items() if k.startswith('Packages/Missions/')}
    rebuilt = {n: hashlib.sha256((package2i / n).read_bytes()).hexdigest().upper() for n in package_files2i}
    # Phase 2j changed the member labels in package.json and Phase 2k the addon (minimal hooks, compiled enabled flag);
    # every other file (the Void Flood replacement) must stay byte-identical.
    assert sorted(recorded) == sorted(rebuilt), ('package file set changed', recorded, rebuilt)
    changed2i = sorted(k for k in rebuilt if rebuilt[k] != recorded[k])
    assert set(changed2i) <= INTENTIONAL_2I, ('rebuilt package differs from the recorded Phase 2i sample', changed2i)
    state2i = ('identical except the intentional Phase 2j/2k change of ' + ', '.join(changed2i) if changed2i else 'identical') + \
        ' to the recorded sample (folder untouched)'
else:
    SAMPLE2I.mkdir(parents=True)
    (SAMPLE2I / 'mission_settings.json').write_text(json.dumps(settings2h, indent=2) + '\n')
    shutil.copytree(generation2i, SAMPLE2I / 'generation')
    shutil.copytree(generation2i / 'Packages', SAMPLE2I / 'Packages')
    (SAMPLE2I / 'CustomScripts' / 'Settings').mkdir(parents=True)
    (SAMPLE2I / 'CustomScripts' / 'Settings' / 'Missions.json').write_text(json.dumps(EXAMPLE2I, indent=2) + '\n')
    sums = {p.relative_to(SAMPLE2I).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest().upper()
            for p in sorted(SAMPLE2I.rglob('*')) if p.is_file()}
    (SAMPLE2I / 'SHA256SUMS.json').write_text(json.dumps(sums, indent=2) + '\n')
    state2i = 'created'
results['phase2i_sample'] = {'values': PHASE2G_VALUES, 'allow_unproven_hook_bindings': [LUA_CALL], 'output_layout': 'package',
                             'package': manifest2i['package'], 'example_settings': EXAMPLE2I,
                             'location': SAMPLE2I.relative_to(ROOT).as_posix()}
print(f"PASS phase2i sample: {len(decl2i)} declarations in {len(groups2i)} groups, migration + example settings ({state2i})")
# Phase 2k: the FULL Missions package (package_scope all_addon_values) rebuilt from the installed live-test values file
# (phase2i CustomScripts/Settings/Missions.json, ee4fa704) through missions_settings_to_build.py. Compared with the staged
# install set when it exists (never rewritten here).
import missions_settings_to_build as REBUILD  # noqa: E402
ENGINE_PARAMS_R17 = '26E56E26775DFEC42B0CA3AA725A5B23163B4671B2FA1128ABF43B1538E3BF7C'
# R17: the registry layout of R16 (c48c819) tells the R17 "All <type> missions" layout changes from anything else.
R16_REGISTRY = json.loads(subprocess.run(['git', '-C', str(EDITOR), 'show', 'c48c819:REGISTRIES/mission_build_u44.json'],
                                         capture_output=True, check=True).stdout.decode('utf-8'))
CURRENT_REGISTRY = json.loads((EDITOR / 'REGISTRIES/mission_build_u44.json').read_text(encoding='utf-8'))


def _layout(registry, tid):
    ui = registry['ui_masters'].get(tid) or next((r['ui'] for r in registry['tunables'] if r['tunable_id'] == tid), {})
    return {f: ui.get(f) for f in ('path', 'row', 'quick', 'quick_on_page', 'scope_text', 'default_label', 'short_label')}


def _r17_explained(old_values, new_values, changed):
    """R17 changes: a layout that differs between the R16 and the current registry, or a category level a type page drops
    because it now holds its "All <type> missions" master (r7_collapse_paths)."""
    layout = {k for k in changed if _layout(R16_REGISTRY, k) != _layout(CURRENT_REGISTRY, k)}
    master_types = {d['path'][0] for d in new_values.values() if d.get('quick_on_page')}
    collapse = {k for k in changed - layout if new_values[k]['path'][0] in master_types
                and len(new_values[k]['path']) == len(old_values[k]['path']) - 1
                and {f: v for f, v in old_values[k].items() if f != 'path'} == {f: v for f, v in new_values[k].items() if f != 'path'}}
    return layout | collapse
STAGE2K = ROOT / 'work/staging/missions-full-package'
settings2k = REBUILD.convert(SAMPLE2I / 'CustomScripts' / 'Settings' / 'Missions.json')
assert settings2k['values'] == {'survival.reward_interval': 150, 'void_flood.fractures_per_round.normal': 4}, settings2k['values']
# Contract R5 (2026-09-30): the staged package also carries the literal headline timers with the user's earlier choices,
# built but shipped off (Mobile Defense 20 s per terminal, Excavation 50 s dig, Control Area 30 s). The staged
# evidence/rebuild_input.mission_settings.json is exactly this input.
R5_LITERAL = {'mobiledefense.time_per_terminal': 20, 'excavation.dig_time': 50, 'control_area_plains.duration': 30,
              'control_area_deimos.duration': 30}
settings2k['values'].update(R5_LITERAL)
settings2k['disabled_values'] = list(R5_LITERAL)
generation2k, manifest2k = build(settings2k, 'sample2k')
assert generation2k is not None, manifest2k
package2k = generation2k / 'Packages' / 'Missions'
addon2k = next(a for a in manifest2k['artifacts'] if a['backend'] == 'TARGET_ADDON')
# Every declared table is hooked (idle hooks retire at once under R3): every target is hooked, every hook has the idle path.
assert addon2k['hook_plan']['hooked_targets'] == len(addon2k['target_keys']), addon2k['hook_plan']
assert addon2k['hook_plan']['idle_retire_hooks'] == addon2k['hook_plan']['hooks'] == addon2k['hook_plan']['retiring_hooks'], addon2k['hook_plan']
# Contract R4 / S5: every hook also opens with retire-all (no enabled value of its target -> retire every hook of it).
assert addon2k['hook_plan']['retire_all_hooks'] == addon2k['hook_plan']['hooks'], addon2k['hook_plan']
assert addon2k['hook_plan']['retire_all_sentinel'] == 'RENOVICE_RETIRE_ALL', addon2k['hook_plan']
assert (package2k / 'package.json').stat().st_size <= 512 * 1024
files2k = {'Packages/Missions/' + p.name: p for p in package2k.iterdir()}
files2k['Settings/Missions.json'] = generation2k / 'Settings' / 'Missions.json'
hashes2k = {k: hashlib.sha256(p.read_bytes()).hexdigest().upper() for k, p in files2k.items()}
# Contract R16 (2026-10-01): engine_params.json (ENGINE_PARAM_OVERRIDE declarations, not a member) is new; the staged install
# set predates it. Its content is gated by test_engine_param_override_harness.py (same recipe as the package build).
# R17 (2026-10-01): + the Gas City meltdown row (2 parameters) and the Railjack master on the Corpus row (R16 AE090C33).
engine_params2k = hashes2k.pop('Packages/Missions/engine_params.json', None)
assert engine_params2k == ENGINE_PARAMS_R17, engine_params2k
if (STAGE2K / 'SHA256SUMS.json').exists():
    staged = json.loads((STAGE2K / 'SHA256SUMS.json').read_text())
    staged = {k: v for k, v in staged.items() if k in hashes2k}
    # Merged R7 + R8 (contract R9, 2026-09-30): the two literal masters with a range default say that a typed number
    # replaces the whole range. That description is the only intentional change of the baked package.json.
    R9_TEXT = {'mobiledefense.time_per_terminal', 'excavation.dig_time'}
    differing = {k for k in hashes2k if staged.get(k) != hashes2k[k]}
    if differing == {'Packages/Missions/package.json'}:
        def _values(path):
            manifest = json.loads(Path(path).read_text(encoding='utf-8'))
            return manifest, {k: v for m in manifest['members'].values() for k, v in m.get('settings', {}).get('values', {}).items()}
        old_manifest, old_values = _values(STAGE2K / 'Packages/Missions/package.json')
        new_manifest, new_values = _values(package2k / 'package.json')
        changed = {k for k in old_values if old_values[k] != new_values.get(k)}
        assert old_values.keys() == new_values.keys() and changed == R9_TEXT and all(
            {f: v for f, v in old_values[k].items() if f != 'scope'} == {f: v for f, v in new_values[k].items() if f != 'scope'}
            for k in changed) and old_manifest['settings'] == new_manifest['settings'], \
            ('rebuilt full package.json differs from the staged one beyond the R9 descriptions', changed)
        state2k = 'identical to the staged install set except the intentional R9 description change of package.json (folder untouched)'
    elif differing == {'Packages/Missions/Missions.targets.addon.lua_B', 'Packages/Missions/package.json', 'Settings/Missions.json'}:
        # Contract R10 (2026-09-30): the addon member gains the R10 addon values (mission-owner research rows and the Defense
        # caps unlocked by the flow-sensitive gate). Every staged declaration and values-file entry is unchanged except the R9
        # descriptions and the category level two set pages keep now that their mission type has more categories; every
        # exact-replacement member is byte-identical.
        def _values(path):
            manifest = json.loads(Path(path).read_text(encoding='utf-8'))
            return manifest, {k: v for m in manifest['members'].values() for k, v in m.get('settings', {}).get('values', {}).items()}
        old_manifest, old_values = _values(STAGE2K / 'Packages/Missions/package.json')
        new_manifest, new_values = _values(package2k / 'package.json')
        R10_PATH = {f'defense.simultaneous_enemies_duviri.max.p{k}' for k in range(1, 5)} | {f'escalation.keys_per_players.p{k}' for k in range(1, 5)}
        changed = {k for k in old_values if old_values[k] != new_values.get(k)}
        added = set(new_values) - set(old_values)
        old_file = json.loads((STAGE2K / 'Settings/Missions.json').read_text(encoding='utf-8'))['values']
        new_file = json.loads((generation2k / 'Settings' / 'Missions.json').read_text(encoding='utf-8'))['values']
        r17 = _r17_explained(old_values, new_values, changed)  # R17 (2026-10-01)
        assert not set(old_values) - set(new_values) and changed <= R9_TEXT | R10_PATH | r17 and all(
            {f: v for f, v in old_values[k].items() if f not in ('scope', 'path')} ==
            {f: v for f, v in new_values[k].items() if f not in ('scope', 'path')} for k in changed - r17),             ('rebuilt full package.json differs from the staged one beyond R9, R10 and R17', changed - r17)
        assert all(new_file.get(k) == v for k, v in old_file.items()) and set(new_file) - set(old_file) == added and             not any(new_file[k]['enabled'] for k in added), 'values file: staged entries changed or R10 entries enabled'
        state2k = (f'staged exact replacements identical; R10/R17 add {len(added)} addon values (all off); R9/R10 description and '
                   f'category-level changes and {len(r17)} R17 layout changes only (folder untouched)')
    else:
        assert staged == hashes2k, ('rebuilt full package differs from the staged install set', staged, hashes2k)
        state2k = 'identical to the staged install set (folder untouched)'
else:
    state2k = 'no staged install set to compare'
results['phase2k_full_package'] = {'settings': settings2k, 'hook_plan': addon2k['hook_plan'],
                                   'declarations': manifest2k['package']['settings']['declarations'], 'files': hashes2k,
                                   'state': state2k}
assert manifest2k['package']['settings']['declarations']['masters'] > 0
print(f"PASS phase2k full package: {manifest2k['package']['settings']['declarations']['values']} declared values, "
      f"{addon2k['hook_plan']['hooked_targets']} hooked target(s), {addon2k['hook_plan']['hooks']} hooks ({state2k})")
results['phase2g_sample_state'] = state2g
results['phase2h_sample_state'] = state2h
(OUT / 'results.json').write_text(json.dumps(results, indent=2) + '\n')
print(f"PASS phase2g sample: 1 multi-target addon ({len(addons[0]['target_keys'])} targets) + {len(literals)} replacement ({state2g})")
print(f"PASS {len(results['presets'])} preset builds, {results['rejections']} rejections")
