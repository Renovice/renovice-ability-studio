"""Offline regression for the current mission registry: 12 preset builds through the registry path, 3 rejections per
preset, rebuilds of the Phase 2b/2d/2e sample settings with default settings and with the live-acceptance opt-in
(compared with their recorded manifests, folders left untouched) and the Phase 2f/2g sample group builds. Writes only to
work/staging and this tool's test-results and references folders.
No game or server folder is written. Requires the built CLI (RENOVICE_EDITOR_CLI, else work/builds/ability-editor/current).

Build-agnostic (2026-10-09): everything runs on the CURRENT registry build. The sample settings are kept in the repository
(../references/inputs, copied unchanged from the dated work/research/universal-mission-editor-2026-09-29/phase2*-sample
folders) and relabelled for the current build. The artifact SHA-256 of every sample build is the reference of its client
build (../references/<build>/samples.json): the first run on a build records it, every later run on that build must be
byte-identical. The byte comparisons with the dated sample folders and the staged full package (work/staging/
missions-full-package) were proven on client 2026.09.28.13.06 and are recorded as historical; the full package is pinned
by the harness package pins (harness_input.py, ../test-results/package_pins.json) instead."""
from pathlib import Path
import copy, hashlib, json, os, shutil, subprocess, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
import harness_input as HI  # noqa: E402

ROOT = Path(__file__).resolve().parents[6]
EDITOR = ROOT / 'repos/apps/ability-editor'
CLI = Path(os.environ.get('RENOVICE_EDITOR_CLI', ROOT / 'work/builds/ability-editor/current/bin/renovice_ability_editor_cli.exe'))
STAGING = ROOT / 'work/staging/aer44'  # short: generated names are long and Windows MAX_PATH applies
OUT = Path(__file__).resolve().parents[1] / 'test-results'  # results.json only (committed)
WORK = STAGING / 'inputs'  # generated projects and logs (not committed)
registry = json.loads((EDITOR / 'REGISTRIES/mission_build_u44.json').read_text(encoding='utf-8'))
REFS = Path(__file__).resolve().parents[1] / 'references'
INPUTS = REFS / 'inputs'  # sample settings of client 2026.09.28.13.06, relabelled per run (relabel)
SAMPLE_REFS = REFS / registry['build'] / 'samples.json'
DATED = 'work/research/universal-mission-editor-2026-09-29/phase2*-sample'
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
results = {'build': registry['build'], 'presets': [], 'rejections': 0,
           'historical': f'byte comparisons with the dated samples {DATED} and the staged full package '
                         'work/staging/missions-full-package proven on client 2026.09.28.13.06 (2026-09-29 .. '
                         '2026-10-02); not re-run on another build'}
# Preset artifacts must stay byte-identical to the previously recorded run (presets keep their established lanes).
# Only a run on the SAME client build is comparable: a new build changes the stock bodies the presets are built from
# (2026-10-09: the recorded 44.0.2 run made every 44.1.x run fail).
_previous = json.loads((OUT / 'results.json').read_text()) if (OUT / 'results.json').exists() else {}
previous_presets = {p['preset']: p['sha256'] for p in _previous.get('presets', [])} \
    if _previous.get('build') == registry['build'] else {}
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


def registry_row(tid):
    return next(r for r in registry['tunables'] if r['tunable_id'] == tid)


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


# The references belong to one registry (like the harness package pins): an R step that changes the registry changes the
# samples on purpose, so a reference of another registry fails with the re-record instruction (`--record`).
_stored = json.loads(SAMPLE_REFS.read_text(encoding='utf-8')) if SAMPLE_REFS.exists() else {}
if '--record' in sys.argv[1:]:
    _stored = {}
elif _stored and _stored.get('registry_sha256') != HI.registry_sha256():
    raise SystemExit(f'sample references in {SAMPLE_REFS} belong to registry {str(_stored.get("registry_sha256"))[:16]}, the '
                     f'current registry is {HI.registry_sha256()[:16]}: re-record with `python {Path(__file__).name} --record`')
_sample_refs = _stored.get('samples', {})
_sample_refs_changed = False


def relabel(settings):
    """A sample settings file of client 2026.09.28.13.06 for the current registry build (ids it no longer has dropped)."""
    ids = {r['tunable_id'] for r in registry['tunables']} | set(registry['ui_masters'])
    out = dict(settings, build=registry['build'], values={k: v for k, v in settings['values'].items() if k in ids})
    assert out['values'] == settings['values'], ('a sample value is no longer in the registry', set(settings['values']) - ids)
    return out


def reference(name, built):
    """`built` ({file: SHA-256}) is the reference of this client build: recorded by the first run on the build, compared
    byte for byte by every later run."""
    global _sample_refs_changed
    recorded = _sample_refs.get(name)
    if recorded is None:
        _sample_refs[name] = dict(sorted(built.items()))
        _sample_refs_changed = True
        return f'recorded as the {registry["build"]} reference'
    assert recorded == built, (name, f'differs from the {registry["build"]} reference',
                               sorted(k for k in set(recorded) | set(built) if recorded.get(k) != built.get(k)))
    return f'identical to the {registry["build"]} reference'


def artifact_hashes(generation):
    return {p.name: hashlib.sha256(p.read_bytes()).hexdigest().upper() for p in (generation / 'artifacts').iterdir()}


def sample(settings, name):
    generation, manifest = build(settings, name)
    assert generation is not None, manifest
    return manifest, reference(name, artifact_hashes(generation))


def summary(manifest):
    return [{'body_key': a['body_key'], 'tunables': a['tunables'], 'backend': a['backend'], 'sha256': a['sha256'],
             'multi_target_artifact': a.get('multi_target'), 'runtime_hook': a.get('runtime_hook')} for a in per_body(manifest)]


for name in ('sample2b', 'sample2d', 'sample2e'):
    settings = relabel(json.loads((INPUTS / f'phase{name[-2:]}.mission_settings.json').read_text(encoding='utf-8')))
    generation, default = build(settings, name)
    entry = {}
    if generation is None:
        assert 'NEEDS_BINDING' in default and LUA_CALL in default, default
        entry['default'] = {'result': 'REJECTED', 'reason': next(l for l in default.splitlines() if 'NEEDS_BINDING' in l).strip()}
    else:
        entry['default'] = {'result': 'PASS', 'artifacts': summary(default), 'state': reference(name, artifact_hashes(generation))}
        assert all(a['backend'] != 'TARGET_ADDON' for a in default['artifacts']), 'default build staged an unproven addon'
    generation, opted = build(probe(settings), name + '-probe')
    assert generation is not None, opted
    entry['opt_in_probe'] = {'artifacts': summary(opted), 'state': reference(name + '-probe', artifact_hashes(generation))}
    for a in opted['artifacts']:
        if a['backend'] == 'TARGET_ADDON':
            assert a['runtime_hook']['registry_status'] == 'OFFLINE_VERIFIED' and a['runtime_hook']['built_by_explicit_opt_in']
    results[name + '_rebuild'] = entry
    print('PASS', name, 'default:', entry['default']['result'], '| opt-in probe:', len(entry['opt_in_probe']['artifacts']),
          'bodies,', entry['opt_in_probe']['state'], flush=True)

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
manifest2f, state2f = sample(settings2f, 'sample2f')
assert [a['backend'] for a in manifest2f['artifacts']] == ['EXACT_LITERAL', 'EXACT_LITERAL'], manifest2f['artifacts']
assert sorted(t for a in manifest2f['artifacts'] for t in a['tunables']) == sorted(buildable)
results['phase2f_sample'] = {'values': buildable, 'artifacts': manifest2f['artifacts'], 'rejected': rejected,
                             'state': state2f}
print(f"PASS phase2f sample artifacts={len(manifest2f['artifacts'])} rejected={sorted(rejected)} ({state2f})")

# Phase 2g sample: the live-test set with the explicit opt-in. Every addon-lane body key goes into ONE multi-target addon
# (Inject/Missions.targets.addon.lua_B); the Void Flood fracture count stays a separate exact replacement.
PHASE2G_VALUES = {
    'survival.reward_interval': 150,               # Survival root table (shared constant with killPlayerTime), addon only
    'purgatory.difficulty1.warrior_level': 15,     # Purgatory nested difficulty table, addon only
    'lantern.tier_up_interval': 60,                # Lantern spawn config, addon lane (literal form exists)
    'void_flood.fractures_per_round.normal': 4,    # root local, exact replacement
}
settings2g = probe(dict(base_settings, values=PHASE2G_VALUES))
manifest2g, state2g = sample(settings2g, 'sample2g')
addons = [a for a in manifest2g['artifacts'] if a['backend'] == 'TARGET_ADDON']
literals = [a for a in manifest2g['artifacts'] if a['backend'] == 'EXACT_LITERAL']
assert len(addons) == 1 and len(literals) == 1 and len(manifest2g['artifacts']) == 2, manifest2g['artifacts']
assert addons[0]['path'] == 'artifacts/Missions.targets.addon.lua_B', addons[0]['path']
# The addon covers the bodies of the three addon-lane values; the Void Flood body is the exact replacement (keys from the
# registry: Survival's key changes with the client build).
assert sorted(addons[0]['target_keys']) == sorted({registry_row(t)['owner']['body_key'] for t in PHASE2G_VALUES
                                                   if t != 'void_flood.fractures_per_round.normal'}), addons[0]['target_keys']
assert addons[0]['runtime_hook']['registry_status'] == 'OFFLINE_VERIFIED' and addons[0]['runtime_hook']['built_by_explicit_opt_in']
VOID_FLOOD = registry_row('void_flood.fractures_per_round.normal')['owner']['body_key']
assert literals[0]['body_key'] == VOID_FLOOD
results['phase2g_sample'] = {'values': PHASE2G_VALUES, 'allow_unproven_hook_bindings': [LUA_CALL],
                             'artifacts': manifest2g['artifacts']}

# Phase 2h sample: the Phase 2g settings with "output_layout": "package". The same Lua artifacts, byte for byte, are also
# emitted as ONE optional bootstrapper folder package Packages/Missions/ (bootstrapper feat/script-packages-2026-09-29):
# package.json + Missions.targets.addon.lua_B + the Void Flood exact replacement; one Scripts row [PACKAGE] Missions.
settings2h = dict(settings2g, output_layout='package')
generation2h, manifest2h = build(settings2h, 'sample2h')
assert generation2h is not None, manifest2h
package2h = generation2h / 'Packages' / 'Missions'
members2h = sorted(p.name for p in package2h.iterdir() if p.name != 'package.json')
assert sorted(p.name for p in package2h.iterdir()) == sorted(members2h + ['package.json']), list(package2h.iterdir())
assert members2h == sorted(['Missions.targets.addon.lua_B', f'{VOID_FLOOD} (missions_exact-replacement).lua_B']), members2h
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
state2h = reference('sample2h', dict(package_hashes, **{'package.json': hashlib.sha256((package2h / 'package.json')
                                                                                    .read_bytes()).hexdigest().upper()}))
results['phase2h_sample'] = {'values': PHASE2G_VALUES, 'allow_unproven_hook_bindings': [LUA_CALL], 'output_layout': 'package',
                             'package': manifest2h['package'], 'state': state2h}
print(f"PASS phase2h sample: Packages/Missions with {len(members2h)} members, byte-identical to phase 2g ({state2h})")
# Phase 2i sample: the Phase 2h settings rebuilt with settings declarations. Packages/Missions/ is install-ready;
# CustomScripts/Settings/Missions.json is the hand-editable values file for the Phase 2 live test (Survival reward interval
# 150 enabled, Purgatory warrior level present but disabled, Lantern absent = stock, Void Flood replacement value kept
# enabled so its one-value member stays on).
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
state2i = reference('sample2i', {n: hashlib.sha256((package2i / n).read_bytes()).hexdigest().upper() for n in package_files2i})
# The live-test values file of client 2026.09.28.13.06 (ee4fa704, in ../references/inputs) is this example; Phase 2k
# rebuilds the full package from it, relabelled for the current build.
VALUES2I = json.loads((INPUTS / 'phase2i.Missions.json').read_text(encoding='utf-8'))
# (group ids may be renamed by later R steps, e.g. purgatory -> purgatory_advanced: every group is on in both files)
assert {k: v for k, v in VALUES2I.items() if k not in ('build', 'groups')} == {k: v for k, v in EXAMPLE2I.items()
                                                                              if k not in ('build', 'groups')} \
    and all(VALUES2I['groups'].values()) and all(EXAMPLE2I['groups'].values()), 'the recorded live-test values file is not the example'
(WORK / 'phase2i.Missions.json').write_text(json.dumps(EXAMPLE2I, indent=2) + '\n')
results['phase2i_sample'] = {'values': PHASE2G_VALUES, 'allow_unproven_hook_bindings': [LUA_CALL], 'output_layout': 'package',
                             'package': manifest2i['package'], 'example_settings': EXAMPLE2I,
                             'state': state2i}
print(f"PASS phase2i sample: {len(decl2i)} declarations in {len(groups2i)} groups, migration + example settings ({state2i})")
# Phase 2k: the FULL Missions package (package_scope all_addon_values) rebuilt from the installed live-test values file
# (phase2i CustomScripts/Settings/Missions.json, ee4fa704) through missions_settings_to_build.py. Compared with the staged
# install set when it exists (never rewritten here).
import missions_settings_to_build as REBUILD  # noqa: E402
PINS = HI.package_pins()  # the four package files the pinned harness input builds on the current registry
settings2k = REBUILD.convert(WORK / 'phase2i.Missions.json')
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
# This input has the values of the pinned harness input (MISSIONS_R13 rebuild_input.r12.json) built baked (the values
# file sets no literal_mode); the pins are its recipe build, so only engine_params.json is shared with them (its content
# is gated by test_engine_param_override_harness.py). The whole baked package is the per-build reference sample2k.
assert settings2k['values'] == HI.current_spec(HI.INPUT)['values'], 'the Phase 2k input no longer has the pinned values'
assert hashes2k['Packages/Missions/engine_params.json'].lower() == PINS['engine_params.json'], 'engine_params.json differs from its pin'
state2k = reference('sample2k', hashes2k)
results['phase2k_full_package'] = {'settings': settings2k, 'hook_plan': addon2k['hook_plan'],
                                   'declarations': manifest2k['package']['settings']['declarations'], 'files': hashes2k,
                                   'state': state2k}
assert manifest2k['package']['settings']['declarations']['masters'] > 0
print(f"PASS phase2k full package: {manifest2k['package']['settings']['declarations']['values']} declared values, "
      f"{addon2k['hook_plan']['hooked_targets']} hooked target(s), {addon2k['hook_plan']['hooks']} hooks ({state2k})")
results['phase2g_sample_state'] = state2g
results['phase2h_sample_state'] = state2h
if _sample_refs_changed:
    SAMPLE_REFS.parent.mkdir(parents=True, exist_ok=True)
    SAMPLE_REFS.write_bytes((json.dumps({'format': 'RENOVICE_SAMPLE_REFERENCES_V1', 'build': registry['build'],
                                         'registry_sha256': HI.registry_sha256(),
                                         'samples': dict(sorted(_sample_refs.items()))}, indent=1) + '\n').encode('utf-8'))
results['sample_references'] = SAMPLE_REFS.relative_to(EDITOR).as_posix()
# Committed file: workspace paths are written relative (<workspace>), never with the local user folder.
(OUT / 'results.json').write_bytes((json.dumps(results, indent=2) + '\n')
                                   .replace(json.dumps(str(ROOT))[1:-1], '<workspace>').encode('utf-8'))
print(f"PASS phase2g sample: 1 multi-target addon ({len(addons[0]['target_keys'])} targets) + {len(literals)} replacement ({state2g})")
print(f"PASS {len(results['presets'])} preset builds, {results['rejections']} rejections")
