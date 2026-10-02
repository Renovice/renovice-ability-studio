"""Build REGISTRIES/mission_build_u44.json (schema 2) for client 44.0.2 = 2026.09.28.13.06.

Inputs (read-only):
  * Phase 1 study   work/research/universal-mission-editor-2026-09-29/ (mission_tunables.json, stock/, meta/)
    - stock/ was re-compared byte-for-byte with the live 44.0.2 Cache.Windows B.Font.toc (311/311 identical).
  * previous registry (build 2026.09.24.13.29) from git revision 01c9651, for the 12 preset rows to carry over
  * OpenWF server source (read-only) for SERVER rows

Outputs:
  * REGISTRIES/mission_build_u44.json
  * shared/corpus/de-luau-u44.0.2-authoring/  (only the stock bodies the registry names + METADATA_SNAPSHOT.json
    + CORPUS_MANIFEST.json)
  * RESEARCH/UNIVERSAL_MISSION_REGISTRY_2026-09-29/registry_build_report.json

Admission rule: a row is written only when it is CONFIRMED_STATIC in Phase 1 (or is a carried-over preset row), its
owner kind has an existing back end in src/mission_profiles.inl, and its exact owner verifies against the 44.0.2 stock
bytes (SHA-256 + exact preimage). Every other Phase 1 row is written to `excluded` with the exact reason.
Phase 2e: every LUA_ROOT_TABLE row that passes ROOT_TABLE_UPVALUE_V1 (addon_owner.py) is routed to the target-addon
lane (its literal form is kept as `literal_owner`); phase2e_specs.py adds addon-only fields (shared constants) and the
Void Flood / Lantern / Purgatory rows (run add_phase1_rows.py once first).
Phase 2i: editor_fields.py adds the in-game settings editor fields (row `ui`, `ui_groups`, `ui_sources`, `ui_rules`) from
the rows plus the current build's ExportRegions (read-only); see INGAME_EDITOR_DESIGN.md Phase 1.
2026-09-30 (contract R5): player_text.py then sets the player-facing labels/descriptions, the `<family>_advanced` sections,
`ui_masters` (master knobs) and `ui_player_text`; `python player_text.py` applies the same fields to the current registry.
Nothing here writes into a game or server folder.
"""
from pathlib import Path
import hashlib, json, re, struct, subprocess, sys, tempfile

sys.path.insert(0, str(Path(__file__).resolve().parent))
from deluau import ROOT, EDITOR, Module, body_key, sha256, SETTABLE, LOADN, RAW_LOADN  # noqa: E402
from anchors import Analysis  # noqa: E402
from addon_owner import RootTables, GATE as ADDON_GATE  # noqa: E402
import phase2d  # noqa: E402
import phase2e_specs as P2E  # noqa: E402
import phase2d_lua_specs as P2D_LUA  # noqa: E402
import phase2d_metadata_specs as P2D_META  # noqa: E402
import editor_fields as UI  # noqa: E402
import player_text as PT  # noqa: E402
import hook_plan as HOOK_PLAN  # noqa: E402
import mission_owner_specs as R10_SPECS  # noqa: E402

BUILD = '2026.09.28.13.06'
BUILD_LABEL = 'Hotfix 44.0.2'
PHASE1 = ROOT / 'work/research/universal-mission-editor-2026-09-29'
STOCK = PHASE1 / 'stock'
# Contract R10 (2026-09-30): modules outside the Phase 1 extraction come from the full U44 extraction of the same client
# (de-luau-toolchain RESEARCH/U44_RAW_HASH_RECOMPILE_2026-09-29.md: 5,473 modules read from Cache.Windows B.Font.toc).
# All 311 files present in both folders are byte-identical (checked 2026-09-30); a file is taken from Phase 1 when present.
STOCK_U44_FULL = ROOT / 'repos/toolchains/de-luau-toolchain/work/u44-rawhash-2026-09-29/stock'
CORPUS_REL = 'shared/corpus/de-luau-u44.0.2-authoring'
CORPUS = ROOT / CORPUS_REL
SERVER_REL = '../OpenWF Server 23.09.2026/SpaceNinjaServer'
SERVER = (ROOT / SERVER_REL).resolve()
PREVIOUS_REVISION = '01c9651'
REPORT = Path(__file__).resolve().parents[1] / 'registry_build_report.json'
NAME_SEED = 0x768E5ED0

phase1 = json.loads((PHASE1 / 'mission_tunables.json').read_text(encoding='utf-8'))
PACKAGES_SHA = phase1['packages_bin_sha256']
p1rows = {r['tunable_id']: r for r in phase1['tunables']}
missing_p1 = [r['tunable_id'] for r in P2E.PHASE1 if r['tunable_id'] not in p1rows]
if missing_p1:
    raise SystemExit('Phase 1 study lacks the Phase 2e rows; run tools/add_phase1_rows.py first: ' + ', '.join(missing_p1))
previous = json.loads(subprocess.run(['git', '-C', str(EDITOR), 'show', PREVIOUS_REVISION + ':REGISTRIES/mission_build_u44.json'],
                                     capture_output=True, text=True, check=True).stdout)
assert previous['build'] == '2026.09.24.13.29'

# Contract R20 (2026-10-02): multiplier minimums (record RESEARCH/MISSIONS_R20_MULTIPLIER_MINIMUMS_2026-10-02). The input
# names, per row, the limits it replaces (`was`, checked exactly so a changed upstream draft cannot be overwritten
# silently), the new minimum, an optional type change (`integer`: false makes a whole-number multiplier fractional) and the
# decompile evidence (`basis`, kept in the row's limits). Pinned by its LF content.
R20_MINIMUMS = EDITOR / 'RESEARCH/MISSIONS_R20_MULTIPLIER_MINIMUMS_2026-10-02/inputs/r20_minimums.json'
R20_MINIMUMS_PIN = 'CAB91F54CCD259A1C2E01EE09D5302629ED7BD276BB844CB72088AC96452773A'  # LF-normalized content


def apply_minimums(rows):
    raw = R20_MINIMUMS.read_bytes().replace(b'\r\n', b'\n')
    digest = hashlib.sha256(raw).hexdigest().upper()
    if digest != R20_MINIMUMS_PIN:
        raise SystemExit(f'R20: {R20_MINIMUMS.name} LF SHA-256 {digest} is not the pinned {R20_MINIMUMS_PIN}')
    spec = json.loads(raw)
    if spec.get('format') != 'RENOVICE_MISSION_MINIMUMS_V1' or spec.get('build') != BUILD:
        raise SystemExit('R20: minimums input has another format or build')
    by_id = {r['tunable_id']: r for r in rows}
    done = []
    for item in spec['rows']:
        tid = item['tunable_id']
        row = by_id.get(tid)
        if row is None:
            raise SystemExit(f'R20: {tid} is not a registry row')
        lim = row['limits']
        was = item['was']
        if lim['minimum'] != was['minimum'] or bool(lim.get('integer')) != was['integer']:
            raise SystemExit(f'R20: {tid} limits are {lim["minimum"]}/{lim.get("integer")}, the input expects {was}')
        integer = item.get('integer', was['integer'])
        minimum = item['minimum']
        if integer and float(minimum) != int(minimum):
            raise SystemExit(f'R20: {tid} keeps a whole-number type with a fractional minimum')
        if not (0 <= minimum <= lim['maximum']) or (row.get('stock') is not None and row['stock'] < minimum):
            raise SystemExit(f'R20: {tid} minimum {minimum} is outside 0..maximum or above the stock')
        if not item.get('basis'):
            raise SystemExit(f'R20: {tid} carries no evidence')
        lim['minimum'] = minimum
        lim['integer'] = integer
        lim['basis'] = item['basis']
        done.append(tid)
    if len(done) != len(set(done)):
        raise SystemExit('R20: a row is named twice')
    return {'input': R20_MINIMUMS.relative_to(EDITOR).as_posix(), 'sha256_lf': R20_MINIMUMS_PIN, 'rows': len(done)}


def namehash(name):
    x = NAME_SEED
    for b in name.encode():
        x = ((x ^ b) * 0x01000193) & 0xFFFFFFFF
    x = (~x) & 0xFFFFFFFF
    return ((x << 17) | (x >> 15)) & 0xFFFFFFFF


modules = {}      # body_key -> module record
module_objs = {}  # file -> Module
used_files = set()


def stock_path(file):
    path = STOCK / file
    if path.exists():
        return path
    full = STOCK_U44_FULL / file
    if not full.exists():
        raise ValueError(f'stock module {file} is in neither extraction')
    return full


def module(file):
    if file not in module_objs:
        module_objs[file] = RootTables(stock_path(file).read_bytes())
    return module_objs[file]


def register_module(file, module_path):
    raw = stock_path(file).read_bytes()
    key = body_key(raw)
    rec = modules.setdefault(key, {'file': file, 'sha256': sha256(raw), 'size': len(raw), 'module_path': module_path})
    assert rec['file'] == file
    used_files.add(file)
    return key, rec


def dotted(path):
    return path.strip('/').removesuffix('.lua').replace('/', '.')


def stock_number(text):
    t = str(text).strip()
    return float(t) if re.fullmatch(r'-?\d+(\.\d+)?', t) else None


def num(x):
    return int(x) if float(x).is_integer() else x


def site_from_patch(raw, patch, numerator=None, denominator=None, file=None):
    """Verify one carried-over exact site on the 44.0.2 bytes and return the registry site."""
    off = patch['offset']
    kind = patch.get('kind', 'instruction')
    width = 8 if kind == 'number_constant' else 4
    got = list(raw[off:off + width])
    if got != patch['expected']:
        raise ValueError(f'preimage changed at offset {off}: {got} != {patch["expected"]}')
    site = {'kind': kind, 'prototype': patch['prototype'], 'offset': off, 'expected': got}
    if kind == 'number_constant':
        if raw[off - 1] != 2:
            raise ValueError('number constant tag changed')
        site['constant'] = patch['constant']
        m = module(file)
        if m.constant_offset(patch['prototype'], patch['constant']) != off:
            raise ValueError('carried-over number constant offset disagrees with the constant table')
        uses = [u[1] for u in m.uses(patch['prototype']).get(patch['constant'], []) if u[0] == 'ins']
        site['gate'] = m.exclusive_constant(patch['prototype'], patch['constant'], uses)
    else:
        site.update(instruction=patch['instruction'], register=patch['register'])
        if raw[off] != RAW_LOADN:
            # Carried-over linked-result site: the verified build rewrites this instruction into LOADN of the derived value.
            site['rewrites_instruction'] = True
    site['numerator'] = numerator if numerator is not None else patch['numerator']
    site['denominator'] = denominator if denominator is not None else patch['denominator']
    if patch.get('owner'):
        site['owner'] = patch['owner']
    return site


def lua_row(tid, phase1_id, owner_kind, key, rec, sites, stock, limits, unit, applies, provenance, extra=None):
    p = p1rows.get(phase1_id, {})
    row = {
        'tunable_id': tid,
        'phase1_tunable_id': phase1_id,
        'label': p.get('description', ''),
        'mission_type': p.get('mission_type', ''),
        'variant': p.get('variant', ''),
        'shared_with': p.get('shared_with', ''),
        'owner_kind': owner_kind,
        'backend': 'EXACT_LITERAL',
        'owner': {'body_key': key, 'stock_sha256': rec['sha256'], 'file': rec['file'], 'module_path': rec['module_path'],
                  'sites': sites},
        'unit': unit,
        'stock': stock,
        'limits': limits,
        'applies': applies,
        'confidence': p.get('confidence', 'CARRIED_OVER'),
        'provenance': provenance,
    }
    if extra:
        row.update(extra)
    # Offline sanity: a plain LOADN site must encode stock*numerator/denominator exactly.
    raw = (STOCK / rec['file']).read_bytes()
    for s in sites:
        if s['kind'] == 'instruction' and raw[s['offset']] == RAW_LOADN and stock is not None:
            imm = struct.unpack_from('<h', raw, s['offset'] + 2)[0]
            want = stock * s['numerator'] / s['denominator']
            if imm != want:
                raise ValueError(f'{tid}: LOADN immediate {imm} != stock-derived {want}')
    return row


rows, excluded, presets, report = [], [], {}, {'carried_over': [], 'reregistered': []}

# ---------------------------------------------------------------- carried-over preset rows (12 presets)
CARRY = {
    'mobile_defense': ('Mobile Defense', 'EXACT_LITERAL', {
        'minimum_total_time': ('mobiledefense.total_time.minimum', 'mobiledefense.total_time', 180),
        'maximum_total_time': ('mobiledefense.total_time.maximum', 'mobiledefense.total_time', 240)}),
    'excavation': ('Excavation', 'EXACT_LITERAL', {
        'standard_dig_time': ('excavation.dig_duration', 'excavation.dig_duration', 100),
        'old_world_salvage_dig_time': ('excavation.dig_duration_old_world_salvage', 'excavation.dig_duration_old_world_salvage', 60),
        'elite_alert_dig_time': ('excavation.dig_duration_elite_alert', 'excavation.dig_duration_elite_alert', 140)}),
    'control_area_plains': ('Control Area (Plains)', 'EXACT_LITERAL', {
        'control_area_duration': ('control_area_plains.duration', 'control_area_plains.duration', 90)}),
    'control_area_deimos': ('Control Area (Deimos)', 'EXACT_LITERAL', {
        'control_area_duration': ('control_area_deimos.duration', 'control_area_deimos.duration', 90)}),
    'control_area_nokko': ('Control Area (Venus/Nokko)', 'EXACT_LITERAL', {
        'control_area_duration': ('control_area_nokko.duration', 'control_area_nokko.duration', None)}),
    'void_cascade': ('Void Cascade (Exolizers)', 'EXACT_LITERAL', {
        'exolizer_speed_multiplier': ('void_cascade.pillar_duration', 'void_cascade.pillar_duration', 90)}),
    'descendia_excavation': ('Descendia · Excavation', 'EXACT_LITERAL', {
        'dig_duration': ('coh_excavation.dig_duration', 'coh_excavation.dig_duration', 45)}),
}
APPLIES_LITERAL = 'next_mission'
for pid, (title, lane, params) in CARRY.items():
    old = previous['missions'][pid]
    raw = (STOCK / old['file']).read_bytes()
    if sha256(raw) != old['sha256']:
        raise SystemExit(f'{pid}: body drifted; re-register explicitly')
    key, rec = register_module(old['file'], dotted(old['module_path']))
    pparams = {}
    for pname, (tid, p1id, stock) in params.items():
        patches = [p for p in old['patches'] if p['value'] == pname]
        transform = None
        if pid == 'void_cascade':
            # The preset control is a speed multiplier; the owner is the stock 90-second duration.
            sites = [site_from_patch(raw, p, 1, 1, old['file']) for p in patches]
            transform = {'kind': 'inverse', 'numerator': 90}
            limits = {'minimum': 1, 'maximum': 32767, 'integer': True}
            unit = 's'
        else:
            sites = [site_from_patch(raw, p, file=old['file']) for p in patches]
            lim = old['parameters'][pname]
            limits = {'minimum': lim['minimum'], 'maximum': lim['maximum'], 'integer': True}
            unit = p1rows.get(p1id, {}).get('unit') or 's'
        kind = p1rows[p1id]['owner_kind'] if p1id in p1rows else 'LUA_PROTO_LITERAL'
        if kind != 'LUA_PROTO_LITERAL':
            extra = {'backend_note': 'Owner is the literal that initialises the ' + kind + ' value; edited in place.'}
        else:
            extra = None
        rows.append(lua_row(tid, p1id, kind, key, rec, sites, stock, limits, unit, APPLIES_LITERAL,
                            'carried_over:' + pid, extra))
        entry = {'tunable_id': tid}
        if transform:
            entry['transform'] = transform
            entry['minimum'], entry['maximum'] = old['parameters'][pname]['minimum'], old['parameters'][pname]['maximum']
        else:
            entry['minimum'], entry['maximum'] = limits['minimum'], limits['maximum']
        pparams[pname] = entry
    presets[pid] = {'title': title, 'lane': lane, 'body_key': key, 'file': old['file'], 'sha256': rec['sha256'],
                    'module_path': old['module_path'], 'parameters': pparams}
    if 'legacy_body_key' in old:
        presets[pid]['legacy_body_key'] = old['legacy_body_key']
    report['carried_over'].append({'preset': pid, 'body_key': key, 'identical_sha256': True,
                                   'sites': sum(len(r['owner']['sites']) for r in rows if r['provenance'] == 'carried_over:' + pid)})

# ConquestLib: re-register on 44.0.2 (body changed). Same six LOADN->SETTABLE sequences, verified structurally.
old = previous['missions']['archimedea']
file = old['file']
m = module(file)
key, rec = register_module(file, 'Lotus.Scripts.Libs.ConquestLib')
root = m.root
ins = m.protos[root][0]
waves = [i for i, (_, w) in enumerate(ins) if w[0] == 0x15 and m.key_string(root, w) == 'waveOverrides']
assert len(waves) == 2, waves
regions = {'HEX': (0, waves[0]), 'LAB': (waves[0] + 1, waves[1])}
SPECS = [('archimedea.eta_survival_minutes', 'eta_survival_minutes', 'HEX', 2, 10, 60, 'minutes'),
         ('archimedea.eta_defense_waves', 'eta_defense_waves', 'HEX', 8, 6, 6, 'waves'),
         ('archimedea.eda_survival_minutes', 'eda_survival_minutes', 'LAB', 2, 10, 60, 'minutes'),
         ('archimedea.eda_mirror_defense_waves', 'eda_mirror_defenses', 'LAB', 8, 4, 4, 'defenses'),
         ('archimedea.eda_alchemy', 'eda_alchemy_mixtures', 'LAB', 38, 2, 2, 'mixtures'),
         ('archimedea.eda_disruption', 'eda_disruption_conduits', 'LAB', 33, 8, 8, 'conduits')]
pparams = {}
for tid, pname, region, mission_type, stock, maximum, unit in SPECS:
    lo, hi = regions[region]
    found = []
    for i in range(max(lo, 1), min(hi, len(ins) - 1)):
        a, b, c = ins[i - 1][1], ins[i][1], ins[i + 1][1]
        la, lb = Module.loadn(a), Module.loadn(b)
        if la and lb and la == (8, mission_type) and lb == (9, stock) and c == bytes([SETTABLE, 9, 7, 8]):
            found.append(i)
    if len(found) != 1:
        raise SystemExit(f'{tid}: expected one exact sequence, found {found}')
    i = found[0]
    off = ins[i][0]
    assert m.raw[off] == RAW_LOADN
    prev = next(p for p in old['patches'] if p['value'] == pname)
    site = {'kind': 'instruction', 'prototype': root, 'instruction': i, 'offset': off, 'expected': list(m.raw[off:off + 4]),
            'register': 9, 'numerator': 1, 'denominator': 1, 'owner': f'{region}_CONFIGURATION.waveOverrides[{mission_type}]'}
    report['reregistered'].append({'tunable_id': tid, 'old_offset': prev['offset'], 'new_offset': off,
                                   'delta': off - prev['offset'], 'old_instruction': prev['instruction'], 'new_instruction': i,
                                   'old_expected': prev['expected'], 'new_expected': site['expected']})
    rows.append(lua_row(tid, tid, 'LUA_ROOT_TABLE', key, rec, [site], stock, {'minimum': 1, 'maximum': maximum, 'integer': True},
                        unit, APPLIES_LITERAL, 'reregistered:archimedea:44.0.2',
                        {'backend_note': 'Owner is the ConquestLib root-prototype literal that fills waveOverrides; '
                                         'applies to newly generated EDA/ETA mission chains.'}))
    pparams[pname] = {'tunable_id': tid, 'minimum': 1, 'maximum': maximum}
presets['archimedea'] = {'title': 'EDA / ETA objectives', 'lane': 'EXACT_LITERAL', 'body_key': key, 'file': file,
                         'sha256': rec['sha256'], 'module_path': old['module_path'], 'parameters': pparams}

# Survival and Interception target addons: bodies identical on 44.0.2; capture contracts carried over unchanged.
ADDONS = {
    'survival': {
        'template': 'MISSION_SURVIVAL_TIMERS_LUA_CALL', 'authoring_mode': 'MANAGED_LUA_CALL_ADDON',
        'ability_identifier': 'SURVIVAL_TIMER_PATCH', 'hook_binding': 'renovice.target.lua_call',
        'hook_evidence_id': 'WF-SURVIVAL-PROTO64-CAPTURES-2026-09-09',
        'generation': {'prototype': 64, 'elapsed_reward_upvalue': 19, 'pickup_config_upvalue': 22, 'reward_config_upvalue': 70},
        'current_prototype': 67,
        'source_rewrites': [['prototype == 64', 'prototype == 67'], ['[64] =', '[67] ='], ['proto64', 'proto67'],
                            ['prototype 64', 'prototype 67']],
        'values': {'reward_interval_seconds': 'survival.reward_interval',
                   'life_support_per_pickup_seconds': 'survival.pickup_time_added',
                   'reward_progress_per_pickup_seconds': 'survival.pickup_reward_progress'},
    },
    'interception': {
        'template': 'MISSION_INTERCEPTION_SCORING_TARGET', 'authoring_mode': 'MANAGED_MISSION_ADDON',
        'ability_identifier': 'INTERCEPTION_SCORING_PATCH', 'hook_binding': 'renovice.target.lua_call',
        'hook_evidence_id': 'WF-TERRITORY-PROTO35-SCORE-RATE-2026-09-09',
        'generation': {'prototype': 35, 'stock_score_rate': 1},
        'current_prototype': 35, 'source_rewrites': [],
        'values': {'scoring_speed_multiplier': 'interception.score_rate'},
    },
}
ADDON_ROWS = {
    'survival': [
        ('reward_interval', 'survival.reward_interval', 'survival.reward_interval', 'LUA_ROOT_TABLE', 300, 's',
         {'minimum': 1, 'maximum': 32767, 'integer': False}, {'prototype': 67, 'upvalue': 70, 'field': 'interval'}),
        ('pickup_life_support', 'survival.pickup_time_added', 'survival.pickup_time_added', 'LUA_ROOT_TABLE', 7, 's',
         {'minimum': 0, 'maximum': 32767, 'integer': False}, {'prototype': 67, 'upvalue': 22, 'field': 'pickupTimeAdded'}),
        ('pickup_reward_progress', 'survival.pickup_reward_progress', None, 'ADDON_EXTENSION', 0, 's',
         {'minimum': 0, 'maximum': 32767, 'integer': False}, {'prototype': 67, 'upvalue': 19, 'field': None}),
    ],
    'interception': [
        ('scoring_speed_multiplier', 'interception.score_rate', 'interception.score_rate', 'METADATA_PARAM', 1, 'x stock rate',
         {'minimum': 0.01, 'maximum': 100, 'integer': False}, {'prototype': 35, 'upvalue': None, 'field': 'scoreRatePerSecond'}),
    ],
}
DERECOMP = ROOT / 'repos/toolchains/de-luau-toolchain/bin/derecomp.exe'


def capture_evidence(file, proto, upvalue, field, stock):
    """Prove prototype+upvalue+field on the 44.0.2 bytes with the toolchain's closure-map capture contract.

    The capture (one-based `upvalue`) of `proto` must come from a root register whose last write before the closure is a
    DUPTABLE; for a table field, the template entry `field` must point at a number constant equal to `stock`."""
    mo = module(file)
    with tempfile.TemporaryDirectory() as tmp:
        canon, out = Path(tmp) / 'module.canonical', Path(tmp) / 'closures.tsv'
        canon.write_bytes(mo.canonical)
        run = subprocess.run([str(DERECOMP), 'closure-map', str(canon), str(out)], capture_output=True, text=True)
        if run.returncode != 0 or 'failures=0' not in run.stdout:
            raise ValueError('closure-map failed: ' + run.stdout + run.stderr)
        lines = [l.split('\t') for l in out.read_text().splitlines()]
    head = lines[0]
    sites = [dict(zip(head, l)) for l in lines[1:] if l[head.index('target_proto')] == str(proto)
             and l[head.index('parent_proto')] == str(mo.root)]
    if len(sites) != 1:
        raise ValueError(f'prototype {proto} is not created exactly once by the root prototype')
    site = sites[0]
    caps = dict(c.split('=', 1) for c in site['captures'].split(';'))
    cap = caps[str(upvalue - 1)]
    mode, reg = cap.split(':')
    if not reg.startswith('R'):
        raise ValueError('capture is not a root register')
    reg = int(reg[1:])
    closure_i = int(site['instruction'])
    ins, consts = mo.protos[mo.root]
    writes = [i for i in range(closure_i) if ins[i][1][1] == reg]
    ev = {'closure_instruction': closure_i, 'capture': cap, 'root_register': reg}
    if field is None:
        return ev
    last = ins[writes[-1]][1]
    if last[0] != 0x4f:
        raise ValueError('captured register is not initialised by a DUPTABLE template')
    template = struct.unpack_from('<H', last, 2)[0]
    tag, items = consts[template]
    assert tag == 8
    entries = [(consts[k], struct.unpack('<I', fix)[0]) for k, fix in items]
    hits = [v for kc, v in entries if kc[0] == 'str' and mo.pool[kc[1] - 1].decode() == field]
    if len(hits) != 1:
        raise ValueError(f'template {template} has {len(hits)} entries for {field}')
    vtag, vbytes = consts[hits[0]]
    if vtag != 2 or struct.unpack('<d', vbytes)[0] != stock:
        raise ValueError(f'template value for {field} is not the stock number {stock}')
    ev.update(duptable_instruction=writes[-1], template_constant=template, value_constant=hits[0], value=stock)
    return ev


for pid, addon in ADDONS.items():
    old = previous['missions'][pid]
    raw = (STOCK / old['file']).read_bytes()
    if sha256(raw) != old['sha256']:
        raise SystemExit(f'{pid}: addon target body drifted')
    key, rec = register_module(old['file'], old['module_path'])
    rec['addon'] = dict(addon, legacy_body_key=old['legacy_body_key'])
    pparams = {}
    for pname, tid, p1id, kind, stock, unit, limits, owner in ADDON_ROWS[pid]:
        p = p1rows.get(p1id or '', {})
        if owner['upvalue'] is not None:
            owner = dict(owner, capture_evidence=capture_evidence(old['file'], owner['prototype'], owner['upvalue'],
                                                                  owner['field'], stock))
        note = {
            'survival.reward_interval': 'Reward config table (root frame_79[16]) captured as upvalue 70 of prototype 67.',
            'survival.pickup_time_added': 'Pickup config table (root frame_79[15]) captured as upvalue 22 of prototype 67.',
            'survival.pickup_reward_progress': 'Carried-over preset behaviour, not a stock owner: advances the elapsed reward clock '
                                               '(upvalue 19) per collected pickup; 0 = stock (disabled).',
            'interception.score_rate': 'Carried-over preset owner: global scoreRatePerSecond set once at prototype 35 entry; '
                                       'Phase 1 classifies the owner as PARTIAL (possible metadata origin).',
        }[tid]
        row = {'tunable_id': tid, 'phase1_tunable_id': p1id, 'label': p.get('description', note), 'mission_type': p.get('mission_type', old['module_path']),
               'variant': p.get('variant', ''), 'shared_with': p.get('shared_with', ''), 'owner_kind': kind, 'backend': 'TARGET_ADDON',
               'owner': {'body_key': key, 'stock_sha256': rec['sha256'], 'file': rec['file'], 'module_path': rec['module_path'],
                         'template': addon['template'], 'prototype': owner['prototype'], 'upvalue': owner['upvalue'],
                         'field': owner['field'], 'generation_field': next(k for k, v in addon['values'].items() if v == tid),
                         **({'capture_evidence': owner['capture_evidence']} if 'capture_evidence' in owner else {})},
               'unit': unit, 'stock': stock, 'limits': limits, 'applies': 'F9',
               'confidence': p.get('confidence', 'CARRIED_OVER'), 'provenance': 'carried_over:' + pid, 'backend_note': note}
        rows.append(row)
        pparams[pname] = {'tunable_id': tid, 'minimum': limits['minimum'], 'maximum': limits['maximum']}
    presets[pid] = {'title': pid.title(), 'lane': 'TARGET_ADDON', 'body_key': key, 'file': old['file'], 'sha256': rec['sha256'],
                    'module_path': old['module_path'], 'legacy_body_key': old['legacy_body_key'], 'parameters': pparams}
    report['carried_over'].append({'preset': pid, 'body_key': key, 'identical_sha256': True, 'sites': 0})

# ---------------------------------------------------------------- metadata evidence (44.0.2 Packages.bin snapshot)
tsv = [l.split('\t') for l in (PHASE1 / 'meta/trigger_params.tsv').read_text(encoding='utf-8').splitlines()[1:] if l.strip()]
composed = json.loads((PHASE1 / 'meta/triggers_composed.json').read_text(encoding='utf-8'))
types = sorted({t[0] for t in tsv})
snapshot = {}


def runtime_script_entries(text):
    """Scripts entries of a composed type in runtime order. Mirrors the bootstrapper EeNotationParser: a ',' only
    ends a value, it is never a list element (Phase 1 trigger_params.py counted separators, so its Scripts.N index is
    2 x the runtime ordinal for every entry after the first)."""
    tokens = re.findall(r'"[^"]*"|[{}=]|[^\s{}=,"]+', text.split('\n', 1)[1])

    def parse(i):
        if tokens[i] != '{':
            return tokens[i], i + 1
        i += 1
        items, obj, is_obj = [], {}, False
        while tokens[i] != '}':
            if i + 1 < len(tokens) and tokens[i + 1] == '=':
                k = tokens[i]
                v, i = parse(i + 2)
                obj[k] = v
                is_obj = True
            else:
                v, i = parse(i)
                items.append(v)
        return (obj if is_obj else items), i + 1

    i = 0
    top = {}
    while i < len(tokens):
        k = tokens[i]
        if i + 1 < len(tokens) and tokens[i + 1] == '=':
            v, i = parse(i + 2)
            top[k] = v
        else:
            i += 1
    scripts = top.get('Scripts', [])
    return [e.get('Script', {}) if isinstance(e, dict) else {} for e in (scripts if isinstance(scripts, list) else [])]


def metadata_row(tid, p1id, type_path, field_path, provenance, limits, unit):
    matches = [t for t in tsv if t[0] == type_path and t[3] == field_path]
    if len(matches) != 1:
        raise ValueError(f'{len(matches)} snapshot rows for {type_path} {field_path}')
    if not field_path.startswith('Scripts.0.'):
        raise ValueError('Phase 1 Scripts index counts list separators; only Scripts.0 is identical at runtime (use a Phase 2d split)')
    _, script, function, _, value = matches[0]
    if not script.startswith('/'):
        # DE metadata resolves a relative Script path against the owning type's directory.
        script = type_path.rsplit('/', 1)[0] + '/' + script
    stock = stock_number(value)
    if stock is None:
        raise ValueError(f'non-numeric metadata stock value {value!r}')
    consumer = script.strip('/').replace('/', '_') + '_B'
    if not (STOCK / consumer).exists():
        raise ValueError(f'consumer module {script} not in the 44.0.2 extraction')
    global_name = field_path.rsplit('._', 1)[1]
    h = namehash(global_name)
    craw = (STOCK / consumer).read_bytes()
    if craw.count(struct.pack('<I', h)) < 1:
        raise ValueError(f'consumer {script} does not reference hashed global {global_name} ({h:08x}); unread parameter')
    ckey, crec = register_module(consumer, script)
    line = field_path.rsplit('.', 1)[1] + '=' + value
    if line not in composed[type_path]['text'].splitlines():
        raise ValueError('composed metadata text lacks exact preimage line ' + line)
    snapshot.setdefault(type_path, {'text': composed[type_path]['text'], 'fields': {}})['fields'][field_path] = value
    p = p1rows.get(p1id, {})
    return {'tunable_id': tid, 'phase1_tunable_id': p1id, 'label': p.get('description', ''), 'mission_type': p.get('mission_type', ''),
            'variant': p.get('variant', ''), 'shared_with': p.get('shared_with', ''), 'owner_kind': 'METADATA_PARAM', 'backend': 'METADATA_PATCH',
            'owner': {'type': type_path, 'field': field_path, 'stock_text': value, 'preimage': line,
                      'packages_bin_sha256': PACKAGES_SHA,
                      'consumer': {'body_key': ckey, 'stock_sha256': crec['sha256'], 'file': consumer, 'module_path': script,
                                   'function': function, 'global': global_name, 'name_hash': f'{h:08x}'}},
            'unit': unit, 'stock': num(stock), 'limits': limits, 'applies': 'restart',
            'confidence': p.get('confidence', 'CARRIED_OVER'), 'provenance': provenance}


def metadata_param_row(spec, provenance):
    """One control = one trigger owner type + one script parameter, patched in EVERY runtime Scripts entry that carries
    it. All entries must hold the same stock text and each entry's consumer must read the hashed global."""
    type_path, param = spec['type'], spec['param']
    text = composed[type_path]['text']
    entries = [(n, e) for n, e in enumerate(runtime_script_entries(text)) if param in e]
    if not entries:
        raise ValueError(f'{param} not present in any runtime Scripts entry of {type_path}')
    values = {e[param] for _, e in entries}
    if len(values) != 1:
        raise ValueError(f'{param} holds different values across Scripts entries {sorted(values)}; not one control')
    value = values.pop()
    stock = stock_number(value)
    if stock is None:
        raise ValueError(f'non-numeric metadata stock value {value!r}')
    line = param + '=' + value
    if line not in text.splitlines():
        raise ValueError('composed metadata text lacks exact preimage line ' + line)
    global_name = param[1:]
    h = namehash(global_name)
    fields, consumers = [], []
    for n, e in entries:
        script = e.get('Script', '')
        if not script.startswith('/'):
            script = type_path.rsplit('/', 1)[0] + '/' + script
        consumer = script.strip('/').replace('/', '_') + '_B'
        if not (STOCK / consumer).exists():
            raise ValueError(f'consumer module {script} not in the 44.0.2 extraction')
        if (STOCK / consumer).read_bytes().count(struct.pack('<I', h)) < 1:
            raise ValueError(f'consumer {script} does not reference hashed global {global_name} ({h:08x}); unread parameter')
        fields.append((f'Scripts.{n}.Script.{param}', e.get('Function', ''), script, consumer))
    ckey, crec = register_module(fields[0][3], fields[0][2])
    if any(f[3] != fields[0][3] for f in fields):
        raise ValueError('Scripts entries name different consumer modules; one control per consumer')
    rec = snapshot.setdefault(type_path, {'text': text, 'fields': {}})
    for path, *_ in fields:
        rec['fields'][path] = value
    p = p1rows.get(spec['phase1'], {})
    integer = spec.get('integer', False)
    limits = {'minimum': 0 if stock == 0 or not integer else 1, 'maximum': max(32767, stock * 10), 'integer': integer,
              'basis': 'numeric guard only; gameplay-safe range not established offline'}
    owner = {'type': type_path, 'field': fields[0][0], 'stock_text': value, 'preimage': line, 'packages_bin_sha256': PACKAGES_SHA,
             'consumer': {'body_key': ckey, 'stock_sha256': crec['sha256'], 'file': fields[0][3], 'module_path': fields[0][2],
                          'function': fields[0][1], 'global': global_name, 'name_hash': f'{h:08x}'},
             'runtime_index_rule': 'EeNotationParser: list separators are not elements'}
    if len(fields) > 1:
        owner['also'] = [{'field': path, 'stock_text': value, 'preimage': line, 'function': fn} for path, fn, *_ in fields[1:]]
    return {'tunable_id': spec['tunable_id'], 'phase1_tunable_id': spec['phase1'], 'label': spec['label'],
            'mission_type': spec['mode'], 'variant': spec.get('variant', ''), 'shared_with': p.get('shared_with', ''),
            'owner_kind': 'METADATA_PARAM', 'backend': 'METADATA_PATCH', 'owner': owner, 'unit': spec['unit'], 'stock': num(stock),
            'limits': limits, 'applies': 'restart', 'confidence': p.get('confidence', 'CONFIRMED_STATIC'), 'provenance': provenance}


for pid, tid, pname, maximum in [('netracells', 'netracell.enemy_power_fill', 'power_per_kill', 100),
                                 ('descendia_shrine', 'shrine.offering_generation_time', 'offering_generation_time', 32767)]:
    old = previous['missions'][pid]
    b = old['metadata']
    row = metadata_row(tid, tid, b['owner'], b['field'], 'carried_over:' + pid,
                       {'minimum': old['parameters'][pname]['minimum'], 'maximum': maximum, 'integer': False},
                       p1rows[tid]['unit'])
    assert row['stock'] == b['stock'], (row['stock'], b['stock'])
    rows.append(row)
    presets[pid] = {'title': pid, 'lane': 'METADATA_PATCH', 'body_key': old['body_key'], 'file': old['file'], 'sha256': old['sha256'],
                    'module_path': old['module_path'],
                    'parameters': {pname: {'tunable_id': tid, 'minimum': old['parameters'][pname]['minimum'], 'maximum': maximum}}}
    report['carried_over'].append({'preset': pid, 'body_key': old['body_key'], 'identical_sha256': True, 'sites': 0})

# ---------------------------------------------------------------- Phase 2d exact owners (literal, table template, constant, metadata splits)
report['phase2d'] = {'lua_rows': 0, 'metadata_rows': 0, 'site_kinds': {}, 'gates': {'template_single_use_pass': 0,
                     'constant_exclusive_pass': 0, 'pattern_complete_pass': 0}, 'failures': []}
phase2d_ids = set()
for spec in P2D_LUA.TUNABLES + P2E.LUA:
    stage = 'phase2e' if spec in P2E.LUA else 'phase2d'
    try:
        m = module(spec['module'])
        sites = phase2d.resolve(m, spec['specs'])
        for s_ in sites:
            got = (struct.unpack_from('<h', m.raw, s_['offset'] + 2)[0] if s_['kind'] == 'instruction'
                   else struct.unpack_from('<d', m.raw, s_['offset'])[0])
            if got != spec['stock']:
                raise ValueError(f'site {s_["prototype"]}@{s_["offset"]} stock {got} != {spec["stock"]}')
        key, rec = register_module(spec['module'], dotted(spec['module_path']))
        constant = any(s_['kind'] == 'number_constant' for s_ in sites)
        loadn = any(s_['kind'] == 'instruction' for s_ in sites)
        if loadn:
            limits = {'minimum': 1, 'maximum': 32767, 'integer': True}
        else:
            limits = {'minimum': 0, 'maximum': max(1000, abs(spec['stock']) * 100), 'integer': bool(spec.get('integer'))}
        limits['basis'] = 'operand domain guard only; gameplay-safe range not established offline'
        kinds = sorted({a['kind'] for a in spec['specs']})
        row = lua_row(spec['tunable_id'], spec['phase1'], spec['owner_kind'], key, rec, sites, num(spec['stock']), limits,
                      spec['unit'], APPLIES_LITERAL, stage + ':' + '+'.join(kinds),
                      {'label': spec['label'], 'mission_type': spec['mode'], 'variant': spec.get('variant', ''),
                       'confidence': spec['confidence'], 'evidence': spec['evidence'],
                       'backend_note': f'{len(sites)} exact site(s) patched together: ' + '; '.join(a['owner'] for a in spec['specs'])})
        rows.append(row)
        phase2d_ids.add(spec['phase1'])
        if stage == 'phase2e':
            continue
        report['phase2d']['lua_rows'] += 1
        for s_ in sites:
            report['phase2d']['site_kinds'][s_['kind']] = report['phase2d']['site_kinds'].get(s_['kind'], 0) + 1
        for a in spec['specs']:
            report['phase2d']['gates'][{'template': 'template_single_use_pass', 'constant': 'constant_exclusive_pass',
                                        'pattern': 'pattern_complete_pass'}[a['kind']]] += 1
    except (ValueError, KeyError) as e:
        report['phase2d']['failures'].append({'tunable_id': spec['tunable_id'], 'reason': str(e)})
for spec in P2D_META.METADATA:
    try:
        rows.append(metadata_param_row(spec, 'phase2d:metadata-split'))
        phase2d_ids.add(spec['phase1'])
        report['phase2d']['metadata_rows'] += 1
    except (ValueError, KeyError) as e:
        report['phase2d']['failures'].append({'tunable_id': spec['tunable_id'], 'reason': str(e)})
if report['phase2d']['failures']:
    raise SystemExit('Phase 2d spec failures: ' + json.dumps(report['phase2d']['failures'], indent=1))

# ---------------------------------------------------------------- Phase 2e: root-table fields on the target-addon lane
# Every LUA_ROOT_TABLE row whose owner is a numeric field of a table the module root builds is routed through the proven
# target-addon lane (luaCalls[P].before: check stock once, write once, restore in cleanup). The addon writes the live
# table field, so constant sharing in the bytecode is irrelevant. A row that also has an exact literal form keeps it as
# `literal_owner` (used when the same body must be built as one merged replacement). Rows whose table fails the gate stay
# on the literal lane with the exact reason in `addon_gate`.
report['phase2e'] = {'converted_to_addon': 0, 'addon_gate_fail': 0, 'addon_rows_new': 0, 'template_rows_with_fields': 0,
                     'literal_rows_new': sum(1 for r in rows if r['provenance'].startswith('phase2e:')), 'gate_failures': []}
ADDON_TEMPLATE = 'ROOT_TABLE_FIELD'
ZERO_OK_UNITS = {'x', 'fraction', 'chance', 'x stock rate'}


def addon_field(m, key, ev):
    """Registers the table record on the module and returns the per-field owner entry."""
    rec = modules[key]
    tables = rec.setdefault('root_tables', {})
    c = ev['construction']
    table = {'gate': ADDON_GATE, 'prototype': c['prototype'], 'instruction': c['instruction'], 'register': c['register'],
             'op': c['op'].split('+')[0], 'containers': ev['containers'],
             'hooks': [{k: h[k] for k in ('prototype', 'upvalue', 'path', 'capture', 'closure_instruction')} for h in ev['hooks']]}
    if tables.setdefault(ev['table_id'], table) != table:
        raise ValueError(f'table {ev["table_id"]} evidence differs between fields')
    off, kind = c['value_offset'], c['value_kind']
    width = 8 if kind == 'number_constant' else 4
    entry = {'field': ev['field'], 'table_id': ev['table_id'], 'value_kind': kind, 'value_offset': off,
             'expected': list(m.raw[off:off + width]), 'construction': c['op'], 'field_reads': ev['field_reads']}
    if kind == 'number_constant':
        entry['value_constant'] = c['value_constant']
    return entry


def addon_owner(m, key, rec, fields):
    return {'body_key': key, 'stock_sha256': rec['sha256'], 'file': rec['file'], 'module_path': rec['module_path'],
            'template': ADDON_TEMPLATE, 'gate': ADDON_GATE, 'fields': fields}


for spec in P2E.ADDON:
    try:
        m = module(spec['module'])
        key, rec = register_module(spec['module'], dotted(spec['module_path']))
        fields = []
        for f in spec['fields']:
            ev = m.owner(f[0], float(f[1]), f[2] if len(f) > 2 else None)
            fields.append(addon_field(m, key, ev))
        stock = spec['fields'][0][1]
        if any(f[1] != stock for f in spec['fields']):
            raise ValueError('one row must own fields with one stock value')
        minimum = 0 if spec['unit'] in ZERO_OK_UNITS else min(1, stock)
        p = p1rows.get(spec['phase1'], {})
        rows.append({'tunable_id': spec['tunable_id'], 'phase1_tunable_id': spec['phase1'], 'label': spec['label'],
                     'mission_type': spec['mode'], 'variant': spec['variant'], 'shared_with': p.get('shared_with', ''),
                     'owner_kind': 'LUA_ROOT_TABLE', 'backend': 'TARGET_ADDON', 'owner': addon_owner(m, key, rec, fields),
                     'unit': spec['unit'], 'stock': num(stock),
                     'limits': {'minimum': minimum, 'maximum': max(1000, abs(stock) * 100), 'integer': spec['integer'],
                                'basis': 'numeric guard only; gameplay-safe range not established offline'},
                     'applies': 'F9', 'confidence': spec['confidence'], 'provenance': 'phase2e:root-table-addon',
                     'backend_note': 'Root-table field(s) ' + ', '.join(f'{f["table_id"]}.{f["field"]}' for f in fields) +
                                     ' written through the target-addon lane (ROOT_TABLE_UPVALUE_V1). No literal form: the '
                                     'value constant is shared or the owner is not a unique literal.'})
        report['phase2e']['addon_rows_new'] += 1
    except (ValueError, KeyError) as e:
        report['phase2e']['gate_failures'].append({'tunable_id': spec['tunable_id'], 'reason': str(e)})
if report['phase2e']['gate_failures']:
    raise SystemExit('Phase 2e addon spec failures: ' + json.dumps(report['phase2e']['gate_failures'], indent=1))


# ---------------------------------------------------------------- contract R10: mission-owner research rows
class _R10Context:
    module = staticmethod(module)
    register_module = staticmethod(lambda file, path: register_module(file, dotted(path)))
    addon_field = staticmethod(addon_field)
    addon_owner = staticmethod(addon_owner)
    namehash = staticmethod(namehash)
    snapshot = snapshot
    packages_sha = PACKAGES_SHA


r10_rows, r10_excluded, report['r10'] = R10_SPECS.rows(_R10Context)
rows += r10_rows
for key, rec in modules.items():
    if 'root_tables' in rec:
        rec['root_tables'] = dict(sorted(rec['root_tables'].items(), key=lambda kv: int(kv[0].split(':')[1][1:])))

resolved = {(a, b) for a, b in P2E.RESOLVES}
p2d_lua_excluded = [e for e in P2D_LUA.EXCLUDED if (e['phase1'], e.get('part')) not in resolved]
unmatched = resolved - {(e['phase1'], e.get('part')) for e in P2D_LUA.EXCLUDED}
if unmatched:
    raise SystemExit(f'Phase 2e RESOLVES entries match no Phase 2d exclusion: {sorted(unmatched)}')
for e in p2d_lua_excluded:
    if e['phase1'] in P2E.ADDON_FAILED:
        e['reason'] += ' | ' + P2E.ADDON_FAILED[e['phase1']]
phase2d_excluded = {}
for e in p2d_lua_excluded + P2D_META.EXCLUDED + P2E.EXCLUDED_PARTS + R10_SPECS.EXCLUDED_PARTS:  # R14 parts
    phase2d_excluded.setdefault(e['phase1'], []).append(e)
excluded_parts = []

carried_ids = {r['phase1_tunable_id'] for r in rows}
carried_ids |= {'mobiledefense.total_time', 'coh_excavation.shared_constant_90'}
BACKENDS = {'LUA_PROTO_LITERAL', 'LUA_ROOT_TABLE', 'METADATA_PARAM', 'SERVER'}
INTEGER_UNITS = {'bool', 'flag', 'count', 'targets', 'mixtures', 'rounds', 'beacons', 'floors', 'enemies', 'waves', 'index'}
stock_files = sorted(p.name for p in STOCK.iterdir())


def resolve_module(detail):
    mm = re.search(r'(/Lotus/[A-Za-z0-9_/]+)\.lua', detail)
    if mm:
        f = mm.group(1).strip('/').replace('/', '_') + '.lua_B'
        return (f, mm.group(1) + '.lua') if f in stock_files else (None, None)
    tok = re.match(r'\s*([A-Za-z0-9_]+)', detail).group(1)
    c = [f for f in stock_files if f.endswith('_' + tok + '.lua_B')]
    return (c[0], '/' + c[0][:-2].replace('_', '/')) if len(c) == 1 else (None, None)


def exclude(r, reason):
    excluded.append({'tunable_id': r['tunable_id'], 'owner_kind': r['owner_kind'], 'confidence': r['confidence'], 'reason': reason})


previous_type = None
for r in phase1['tunables']:
    tid, kind, conf, detail = r['tunable_id'], r['owner_kind'], r['confidence'], r['owner_detail']
    if kind == 'METADATA_PARAM':
        cur_types = [t for t in types if t in detail] or [t for t in types if re.search(r'\b' + re.escape(t.rsplit('/', 1)[1]) + r'\b', detail)]
        if detail.startswith('Same trigger') and previous_type:
            cur_types = [previous_type]
        if len(cur_types) == 1:
            previous_type = cur_types[0]
    if tid in carried_ids:
        for e in phase2d_excluded.get(tid, []):
            excluded_parts.append({'tunable_id': tid, 'owner_kind': kind, 'part': e.get('part', e.get('field', '')), 'reason': e['reason']})
        continue
    if tid in phase2d_excluded:
        exclude(r, 'Phase 2d: ' + ' | '.join((e.get('part') or e.get('field') or 'row') + ': ' + e['reason'] if (e.get('part') or e.get('field'))
                                              else e['reason'] for e in phase2d_excluded[tid]))
        continue
    if kind not in BACKENDS:
        exclude(r, {'MISSIONINFO': 'MissionInfo producer: no generator back end in mission_profiles.inl (only the ConquestLib '
                                   'producer literals are registered, as archimedea.*).',
                    'NATIVE_OR_UNKNOWN': 'Owner not established (native or level data); editor must stay read-only.'}[kind])
        continue
    if conf != 'CONFIRMED_STATIC':
        exclude(r, f'Phase 1 confidence {conf}; only CONFIRMED_STATIC rows are admitted.')
        continue
    try:
        if kind == 'SERVER':
            if tid != 'server.credit_boost_multiplier':
                raise ValueError({'server.affinity_resource_moddrop_boosts': 'compound row (three config keys); needs one row per key',
                                  'server.circuit_game_modes': 'list-valued config key; settings file accepts numeric values only',
                                  'server.mission_type_reward_multiplier': 'per-account privateServerTuning (database), not config.json',
                                  }.get(tid, 'server code, not a config.json key; no config back end'))
            schema, consumer = 'src/services/configService.ts', 'src/services/missionInventoryUpdateService.ts'
            pre_schema, pre_consumer = 'creditBoostMultiplier?: number;', 'if (config.worldState?.creditBoostMultiplier) {'
            # Update resilience (2026-10-02): the pin is the SHA-256 of the LF-normalized text (`sha256_text: LF`), so a git
            # checkout that only rewrites line endings keeps it; the generator's verify-missions hashes the same way.
            s_text = (SERVER / schema).read_bytes().replace(b'\r\n', b'\n')
            c_text = (SERVER / consumer).read_bytes().replace(b'\r\n', b'\n')
            if s_text.count(pre_schema.encode()) != 1 or pre_consumer.encode() not in c_text:
                raise ValueError('server preimage not found')
            rows.append({'tunable_id': tid, 'phase1_tunable_id': tid, 'label': r['description'], 'mission_type': r['mission_type'],
                         'variant': r['variant'], 'shared_with': r['shared_with'], 'owner_kind': 'SERVER', 'backend': 'SERVER_CONFIG',
                         'owner': {'config_key': 'worldState.creditBoostMultiplier', 'server_root': SERVER_REL,
                                   'schema_file': schema, 'schema_sha256': hashlib.sha256(s_text).hexdigest().upper(), 'schema_preimage': pre_schema,
                                   'consumer_file': consumer, 'consumer_sha256': hashlib.sha256(c_text).hexdigest().upper(),
                                   'consumer_preimage': pre_consumer, 'sha256_text': 'LF'},
                         'unit': 'x', 'stock': 0, 'limits': {'minimum': 0, 'maximum': 100, 'integer': False},
                         'applies': 'immediate', 'confidence': conf, 'provenance': 'auto:server-config-key',
                         'backend_note': 'Absent/0 = disabled (stock). Written only as a config diff; never applied by the generator.'})
            continue
        if kind == 'METADATA_PARAM':
            if len(cur_types) != 1:
                raise ValueError(f'{len(cur_types)} trigger owner types named (row spans several owners); needs one row per owner type' if cur_types else 'owner trigger type not named in the Phase 1 owner text (refers to sibling rows or both triggers)')
            t = cur_types[0]
            fields = sorted({f for f in re.findall(r'(?<![A-Za-z0-9])(_[A-Za-z][A-Za-z0-9_]*)', detail)
                             if any(x[0] == t and x[3].endswith('._' + f[1:]) for x in tsv)})
            if len(fields) != 1:
                raise ValueError('no metadata field of the owner type is named in the Phase 1 owner text' if not fields else f'compound row ({len(fields)} metadata fields); needs one row per field')
            paths = [x[3] for x in tsv if x[0] == t and x[3].endswith('.' + fields[0])]
            if len(paths) != 1:
                raise ValueError(f'field present in {len(paths)} Scripts entries of the owner type; one control would edit several consumers')
            if re.search(r'\band\b.*Trigger', detail) and 'both' in detail:
                raise ValueError('two trigger owners; needs one row per owner type')
            value = next(x[4] for x in tsv if x[0] == t and x[3] == paths[0])
            stock = stock_number(value)
            if stock is None:
                raise ValueError('non-numeric metadata value')
            if stock < 0:
                raise ValueError('negative selector/index value; value domain not established')
            p1stock = r['stock_value']
            if stock_number(p1stock) is not None and stock_number(p1stock) != stock:
                raise ValueError(f'Phase 1 stock {p1stock} disagrees with snapshot {value}')
            unit = r['unit'] or '-'
            integer = unit in INTEGER_UNITS
            limits = ({'minimum': 0, 'maximum': 1, 'integer': True} if unit in {'bool', 'flag'} else
                      {'minimum': 0 if stock == 0 else (1 if integer else 0), 'maximum': max(32767, stock * 10), 'integer': integer})
            limits['basis'] = 'numeric guard only; gameplay-safe range not established offline'
            rows.append(metadata_row(tid, tid, t, paths[0], 'auto:metadata-snapshot', limits, unit))
            continue
        # Lua literal / root-table field: exact LOADN -> SETTABLEKS "field" anchor, unique in the declared prototype.
        f, script = resolve_module(detail)
        if not f:
            raise ValueError('module not uniquely resolvable from the Phase 1 owner text')
        fields = sorted(set(re.findall(r'frame_(\d+)\[\d+\]\.([A-Za-z_]\w*)', detail)))
        if len(fields) != 1:
            raise ValueError('no single field-anchored owner (frame_P[..].field) in the Phase 1 owner text')
        stock = stock_number(r['stock_value'])
        if stock is None or not float(stock).is_integer() or not (1 <= stock <= 32767):
            raise ValueError('stock value is not a LOADN-representable whole number (float/table/formula values need a '
                             'constant-exclusivity gate that does not exist yet)')
        proto, field = int(fields[0][0]), fields[0][1]
        mo = module(f)
        sites = mo.field_literal_sites(proto, field, int(stock))
        if len(sites) != 1:
            if len(sites) == 0:
                tmpl = [c for c in mo.protos[proto][1] if c[0] == 8] if proto < len(mo.protos) else []
                raise ValueError('no LOADN->SETTABLEKS site; value is held in a DUPTABLE template constant (tag-8 fixup) '
                                 'whose exclusivity is not gated yet' if tmpl else 'no LOADN->SETTABLEKS site in the declared prototype')
            raise ValueError(f'{len(sites)} identical LOADN->SETTABLEKS sites in prototype {proto}; not uniquely anchored')
        i, off, reg = sites[0]
        key, rec = register_module(f, dotted(script))
        site = {'kind': 'instruction', 'prototype': proto, 'instruction': i, 'offset': off, 'expected': list(mo.raw[off:off + 4]),
                'register': reg, 'numerator': 1, 'denominator': 1, 'owner': f'{field} (LOADN->SETTABLEKS)'}
        rows.append(lua_row(tid, tid, kind, key, rec, [site], int(stock), {'minimum': 1, 'maximum': 32767, 'integer': True},
                            r['unit'] or '-', APPLIES_LITERAL, 'auto:loadn-settableks-anchor',
                            {'backend_note': 'Exact unique LOADN->SETTABLEKS "' + field + '" site in prototype ' + str(proto) + '.'}))
    except (ValueError, KeyError) as e:
        exclude(r, str(e))

# Phase 2e conversion runs after every Lua row (Phase 2d specs, carried-over and auto-anchored rows) is registered.
for row in rows:
    if row['owner_kind'] != 'LUA_ROOT_TABLE':
        continue
    owner = row['owner']
    if 'fields' in owner:
        continue  # Phase 2e addon-only row (already a root-table owner)
    m = module(owner['file'])
    try:
        if row['backend'] == 'TARGET_ADDON':
            # Carried-over Survival template rows: also expressible by the generic generator (same table fields).
            ev = m.owner(owner['field'], row['stock'], owner['capture_evidence']['duptable_instruction'])
            owner['fields'] = [addon_field(m, owner['body_key'], ev)]
            owner['gate'] = ADDON_GATE
            report['phase2e']['template_rows_with_fields'] += 1
            continue
        evs = []
        for site in owner['sites']:
            ev = m.site_field(site, row['stock'])
            if all(e['table_id'] != ev['table_id'] or e['field'] != ev['field'] for e in evs):
                evs.append(ev)
        fields = [addon_field(m, owner['body_key'], ev) for ev in evs]
        row['literal_owner'] = owner
        row['owner'] = addon_owner(m, owner['body_key'], modules[owner['body_key']], fields)
        row['backend'] = 'TARGET_ADDON'
        row['applies'] = 'F9'
        row['backend_note'] = ('Root-table field(s) ' + ', '.join(f'{f["table_id"]}.{f["field"]}' for f in fields) +
                               ' written through the target-addon lane (ROOT_TABLE_UPVALUE_V1); exact literal form kept in '
                               'literal_owner for merged replacements.')
        report['phase2e']['converted_to_addon'] += 1
    except (ValueError, KeyError) as e:
        row['addon_gate'] = 'FAIL: ' + str(e)
        report['phase2e']['addon_gate_fail'] += 1

# ---------------------------------------------------------------- invariants
ids = [r['tunable_id'] for r in rows]
assert len(ids) == len(set(ids)), 'duplicate tunable ids'
seen = {}
for r in rows:
    for s in r['owner'].get('sites', []) + r.get('literal_owner', {}).get('sites', []):
        k = (r['owner']['body_key'], s['offset'])
        assert k not in seen or seen[k] == r['tunable_id'], f'competing owners at {k}: {seen.get(k)} / {r["tunable_id"]}'
        seen[k] = r['tunable_id']
addon_fields = {}
for r in rows:
    for f in r['owner'].get('fields', []):
        k = (r['owner']['body_key'], f['table_id'], f['field'])
        assert k not in addon_fields, f'competing addon owners of {k}: {addon_fields[k]} / {r["tunable_id"]}'
        addon_fields[k] = r['tunable_id']
rows.sort(key=lambda r: r['tunable_id'])
excluded.sort(key=lambda r: r['tunable_id'])
# Phase 2k: minimal luaCalls hook set per root table (hook_plan.py, gate ROOT_TABLE_MINIMAL_HOOKS_V1). The generator
# hooks only `minimal_hooks.prototypes` (a subset of `hooks`); the full capturer list stays as the owner evidence.
report['phase2k'] = {'tables': 0, 'tables_without_owned_fields': 0, 'hooks_full': 0, 'hooks_minimal': 0,
                     'downstream_after_escape': 0, 'by_method': {}}
for key, rec in modules.items():
    if 'root_tables' not in rec:
        continue
    owned = {}
    for r in rows:
        if r['backend'] == 'TARGET_ADDON' and r['owner'].get('body_key') == key:
            for f in r['owner'].get('fields', []):
                owned.setdefault(f['table_id'], set()).add(f['field'])
    plans = HOOK_PLAN.plan_module(module(rec['file']), rec['root_tables'], owned)[0]
    for tid, table in rec['root_tables'].items():
        plan = plans[tid]
        record = {'gate': plan['gate'], 'method': plan['method'], 'prototypes': plan['hooks'],
                  'reaching_capturers': plan['reaching_capturers']}
        if plan['method'] != 'no-owned-field':
            record.update({'forced': plan['forced'], 'coverage': plan['coverage'],
                           'escaping_capturers': plan['escaping_capturers'],
                           'downstream_after_escape': plan['downstream_after_escape'],
                           'reach_events': plan['reach_events'],
                           'static_weight': {'chosen': plan['static_weight_chosen'], 'full': plan['static_weight_full']},
                           # Contract R3: the generator may return "RENOVICE_RETIRE" from these hooks only when true.
                           'root_children': plan['root_children'], 'retire_safe': plan['retire_safe'],
                           'retire_blockers': plan['retire_blockers']})
            report['phase2k']['retire_safe_tables'] = report['phase2k'].get('retire_safe_tables', 0) + (1 if plan['retire_safe'] else 0)
            report['phase2k']['downstream_after_escape'] += len(plan['downstream_after_escape'])
        else:
            record['note'] = plan['note']
            report['phase2k']['tables_without_owned_fields'] += 1
        table['minimal_hooks'] = record
        report['phase2k']['tables'] += 1
        report['phase2k']['hooks_full'] += len(table['hooks'])
        report['phase2k']['hooks_minimal'] += len(plan['hooks'])
        report['phase2k']['by_method'][plan['method']] = report['phase2k']['by_method'].get(plan['method'], 0) + 1
# Contract R20 (2026-10-02): multiplier minimums. Every "x" multiplier the package declares accepts values down to
# 0.001 unless the decompiled reader shows a smaller value is unsafe; the per-row decision (minimum, type, evidence) is
# the pinned input below, applied after every row is built and before the editor fields are derived from the limits.
report['r20_minimums'] = apply_minimums(rows)
# Phase 2i: in-game settings editor fields (group, short label, scope, apply timing, editor, limits, search aliases).
ui_groups, ui_sources, ui_rules = UI.apply(rows, ROOT, SERVER_REL, p1rows)
# 2026-09-30 (contract R5): player-facing labels, descriptions, advanced sections and master knobs (player_text.py).
ui_masters, ui_player_text = PT.apply(rows, ui_groups)
# 2026-09-30 (contract R7): page tree, rows, quick values, defaults and short descriptions (player_layout.py).
ui_layout = PT.LAYOUT.apply(rows, ui_groups, ui_masters)

# ---------------------------------------------------------------- corpus
CORPUS.mkdir(parents=True, exist_ok=True)
manifest = []
for file in sorted(used_files):
    data = stock_path(file).read_bytes()
    (CORPUS / file).write_bytes(data)
    manifest.append({'file': file, 'sha256': sha256(data), 'body_key': body_key(data), 'size': len(data)})
snap = {'format': 'RENOVICE_METADATA_SNAPSHOT_V1', 'build': BUILD, 'packages_bin_sha256': PACKAGES_SHA,
        'source': 'work/research/universal-mission-editor-2026-09-29/meta (package-probe decode of Packages-44.0.2.bin)',
        'types': dict(sorted(snapshot.items()))}
(CORPUS / 'METADATA_SNAPSHOT.json').write_text(json.dumps(snap, indent=1, ensure_ascii=False) + '\n', encoding='utf-8')
snapshot_sha = hashlib.sha256((CORPUS / 'METADATA_SNAPSHOT.json').read_bytes()).hexdigest().upper()
(CORPUS / 'CORPUS_MANIFEST.json').write_text(json.dumps({
    'format': 'RENOVICE_STOCK_CORPUS_V1', 'build': BUILD, 'build_label': BUILD_LABEL,
    'source': 'Steam Cache.Windows/B.Font.toc via work/research/universal-mission-editor-2026-09-29/tools/extract_stock.py '
              '(byte-identical re-check 311/311 on 2026-09-29)',
    'files': manifest, 'metadata_snapshot': {'file': 'METADATA_SNAPSHOT.json', 'sha256': snapshot_sha}}, indent=2) + '\n')

owner_counts = {}
for r in rows:
    owner_counts.setdefault(r['owner_kind'], 0)
    owner_counts[r['owner_kind']] += 1
registry = {
    'schema': 2,
    'format': 'RENOVICE_MISSION_TUNABLE_REGISTRY_V2',
    'build': BUILD,
    'build_label': BUILD_LABEL,
    'packages_bin_sha256': PACKAGES_SHA,
    'corpus': CORPUS_REL,
    'metadata_snapshot': {'file': 'METADATA_SNAPSHOT.json', 'sha256': snapshot_sha},
    'server_root': SERVER_REL,
    'name_hash_seed': f'{NAME_SEED:08x}',
    'phase1_source': 'work/research/universal-mission-editor-2026-09-29/mission_tunables.json',
    'applies_values': {'restart': 'game restart (metadata patch)', 'next_mission': 'next module load / new mission (F9 refreshes '
                       'replacement bodies for captured contexts)', 'F9': 'next dispatch after an F9 generation commit',
                       'immediate': 'server config reload; nothing is applied by the generator'},
    'modules': dict(sorted(modules.items())),
    'tunables': rows,
    'missions': presets,
    # Phase 1 exclusions plus the R10 research drafts that were not admitted (reason prefixed "R10:").
    'excluded': sorted(excluded + r10_excluded, key=lambda r: r['tunable_id']),
    'excluded_parts': sorted(excluded_parts, key=lambda e: (e['tunable_id'], e['part'])),
    'ui_format': 'RENOVICE_MISSION_UI_FIELDS_V1',
    'ui_rules': ui_rules,
    'ui_sources': ui_sources,
    'ui_groups': dict(sorted(ui_groups.items(), key=lambda kv: kv[1]['order'])),
    'ui_masters': ui_masters,
    'ui_player_text': ui_player_text,
    'ui_layout': ui_layout,
}
(EDITOR / 'REGISTRIES/mission_build_u44.json').write_text(json.dumps(registry, indent=2, ensure_ascii=False) + '\n', encoding='utf-8',
                                                          newline='\n')  # LF on every OS (R10: stable file hash)

phase1_counts = {}
for r in phase1['tunables']:
    phase1_counts.setdefault(r['owner_kind'], 0)
    phase1_counts[r['owner_kind']] += 1
excl_counts = {}
for r in excluded:
    excl_counts.setdefault(r['owner_kind'], 0)
    excl_counts[r['owner_kind']] += 1
by_mode, by_backend = {}, {}
for r in rows:
    by_mode.setdefault(r['mission_type'] or '-', {}).setdefault(r['owner_kind'], 0)
    by_mode[r['mission_type'] or '-'][r['owner_kind']] += 1
    by_backend[r['backend']] = by_backend.get(r['backend'], 0) + 1
covered = {r['phase1_tunable_id'] for r in rows if r['phase1_tunable_id']} | {'coh_excavation.shared_constant_90'}
partial = sorted({e['tunable_id'] for e in excluded_parts})
report['phase1_accounting'] = {'denominator': len(phase1['tunables']), 'registered_fully': len(covered) - len(set(partial) & covered),
                               'registered_partially': len(set(partial) & covered), 'excluded': len(excluded),
                               'excluded_parts': len(excluded_parts)}
assert report['phase1_accounting']['registered_fully'] + report['phase1_accounting']['registered_partially'] + len(excluded) == len(phase1['tunables'])
report.update({'rows_by_mode': dict(sorted(by_mode.items())), 'rows_by_backend': by_backend})
report.update({'build': BUILD, 'rows': len(rows), 'rows_by_owner_kind': owner_counts, 'excluded': len(excluded),
               'excluded_by_owner_kind': excl_counts, 'phase1_rows': len(phase1['tunables']), 'phase1_by_owner_kind': phase1_counts,
               'phase1_ids_covered': sorted({r['phase1_tunable_id'] for r in rows if r['phase1_tunable_id']} | {'coh_excavation.shared_constant_90'}),
               'modules': len(modules), 'corpus_files': len(manifest), 'metadata_snapshot_sha256': snapshot_sha,
               'registry_sha256': hashlib.sha256((EDITOR / 'REGISTRIES/mission_build_u44.json').read_bytes()).hexdigest().upper()})
report['ui'] = {'groups': len(ui_groups), 'editors': {e: sum(1 for r in rows if r['ui']['editor'] == e) for e in ('INPUTCOUNT', 'INPUTBOX', 'TOGGLE')},
                'label_sources': {k: sum(1 for r in rows if r['ui']['label_source'] == k) for k in sorted({r['ui']['label_source'] for r in rows})},
                'applies': {k: sum(1 for r in rows if r['ui']['applies'] == k) for k in sorted({r['ui']['applies'] for r in rows})},
                'sources': ui_sources}
REPORT.write_text(json.dumps(report, indent=2) + '\n', newline='\n')
print(json.dumps({k: report[k] for k in ('ui', 'rows', 'rows_by_owner_kind', 'rows_by_backend', 'excluded', 'excluded_by_owner_kind', 'modules', 'phase2k',
                                         'phase1_accounting', 'phase2d', 'phase2e')}, indent=1))
