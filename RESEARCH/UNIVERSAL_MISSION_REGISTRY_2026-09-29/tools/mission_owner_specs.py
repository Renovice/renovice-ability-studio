"""Contract R10 (2026-09-30): registry rows admitted from the mission-owner research.

Input: RESEARCH/MISSION_OWNERS_R10_2026-09-30/inputs/row_drafts.json, a copy of
work/research/mission-owners-2026-09-30/row_drafts.json (65 verified drafts, 8 rejected; the research file has CRLF line
ends, SHA-256 8b94d678...12e8a4dd; the copy is LF). The pin below is the SHA-256 of the content with LF line ends, so any
checkout verifies whatever its line-end setting. The drafts are proposals: nothing
is copied into the registry on trust. register_registry.py calls rows() and every row is re-derived from the pinned 44.0.2
stock bytes here:

  * EXACT_LITERAL: every LOADN site is re-read (offset, raw U44 LOADN byte, register, immediate = stock x num / den);
    every number constant is re-read (value, constant offset, native tag) and its K_CONSTANT_EXCLUSIVE_V1 use set is
    recomputed with anchors.Analysis.exclusive_constant.
  * TARGET_ADDON ROOT_TABLE_FIELD (Void Armageddon): the field or array element is re-proven with the registrar's own
    ROOT_TABLE_UPVALUE_V1 gate (addon_owner.RootTables, flow-sensitive consumer since R10) and registered through the
    same addon_field() path as every other root-table row; the hook plan is computed by hook_plan.py afterwards.
  * TARGET_ADDON MISSION_INFO_FIELD_AT_ENTRY / SCRIPT_PARAM_GLOBAL_AT_ENTRY (gate CAPTURE_GRAPH_ENTRY_V1): every entry
    prototype must be created exactly once, by the module root (a direct root child: retire-safe under contract R3),
    and every recorded reader must match a bytecode census of the key (a string-keyed field for MissionInfo, the U44
    native-name hash for a script-parameter global). A parameter global's hash is recomputed from its name.
  * METADATA_PATCH: the preimage line is found inside the named script struct of the composed type text captured
    read-only from the installed 44.0.2 Packages.bin (inputs/*.inspect-type.txt), and the consumer module must reference
    the parameter's hashed global.

Ids: drafts whose family already exists in the registry use it (Mirror Defense = loopdefend, Legacyte Harvest =
infested_capture, All missions = gamerules); the Sabotage variants share the family `sabotage`. ID_MAP lists every rename.
EXCLUDED lists the drafts that are not admitted, with the reason. Nothing here reads or writes a game or server folder.
"""
from pathlib import Path
import hashlib, json, re, struct

HERE = Path(__file__).resolve().parent
EDITOR = HERE.parents[2]
R10 = EDITOR / 'RESEARCH/MISSION_OWNERS_R10_2026-09-30'
DRAFTS = R10 / 'inputs/row_drafts.json'
DRAFTS_SHA256 = '5C5470E04DAAE7BB4D505B9346867D5915613F194E18D5A80AF7B96AE0D33531'  # LF-normalized content
METADATA_INPUTS = {'/Lotus/Types/LevelObjects/ExtractionTrigger': R10 / 'inputs/ExtractionTrigger.inspect-type.txt',
                   '/Lotus/Types/PickUps/DuviriArenaBoonPickup': R10 / 'inputs/DuviriArenaBoonPickup.inspect-type.txt'}
PROVENANCE = 'research:mission-owners-2026-09-30 (contract R10)'
# Contract R11 (2026-09-30): Railjack kill goals (research work/research/railjack-kills-2026-09-30). Same admission path; the
# drafts are pinned by their LF content like the R10 drafts.
R11 = EDITOR / 'RESEARCH/MISSIONS_R11_RAILJACK_OROKIN_2026-09-30'
R11_DRAFTS = R11 / 'inputs/r11_row_drafts.json'
R11_DRAFTS_SHA256 = 'B60EDD6E051D2A51D9AB6C95EB16BDD528A4E32B681A0C44AC64D47089A18544'  # LF-normalized content
R11_PROVENANCE = 'research:railjack-kills-2026-09-30 (contract R11)'
ENTRY_GATE = 'CAPTURE_GRAPH_ENTRY_V1'
MISSION_INFO = 'MISSION_INFO_FIELD_AT_ENTRY'
SCRIPT_PARAM = 'SCRIPT_PARAM_GLOBAL_AT_ENTRY'
ENTRY_TEMPLATES = (MISSION_INFO, SCRIPT_PARAM)
# R11: scale_count = a whole-number count or a plain list of counts, each x value, rounded, at least 1.
PARAM_MODES = ('scale', 'scale_inverse', 'absolute', 'scale_count')
SCALE_MODES = ('scale', 'scale_inverse', 'scale_count')
RAW_LOADN = 0x08
GETTABLEKS, SETTABLEKS, GETGLOBAL, SETGLOBAL, NAMECALL, GETIMPORT = 0x3d, 0x15, 0x17, 0x02, 0x2d, 0x46

ID_MAP = {
    'legacyte_harvest.required_captures.high_scaling': 'infested_capture.required_captures.high_scaling',
    'legacyte_harvest.required_captures.mutated': 'infested_capture.required_captures.mutated',
    'legacyte_harvest.required_captures.double': 'infested_capture.required_captures.double',
    'legacyte_harvest.required_captures.descendia': 'infested_capture.required_captures.descendia',
    'sabotage_orokin.portal_charge_time': 'sabotage.orokin_charge_time',
    'sabotage_forest.defend_time': 'sabotage.forest_defend_time',
    'gascity.meltdown_scale_easy': 'sabotage.gascity_meltdown_scale.easy',
    'gascity.meltdown_scale_hard': 'sabotage.gascity_meltdown_scale.hard',
    'gascity.hack_time': 'sabotage.gascity_hack_time',
    'extraction.countdown_endless': 'gamerules.extraction_countdown_endless',
    'extraction.countdown': 'gamerules.extraction_countdown',
    'mirror_defense.phases_to_finish': 'loopdefend.phases_to_finish',
    'sabotage_orokin.escape_timer': 'sabotage.orokin_escape_timer',  # R11
}
# R11 (2026-09-30): the Orokin escape timer is admitted. Its coupled site (the host-migration restore threshold 27 = 30 - 3,
# SabotageOrokin prototype 17 instruction 17) uses the `value_offset` site form of the shared live-literal patch core
# (operand = row value + value_offset), so both literals move together and each keeps its own preimage check.
EXCLUDED = {}
# Registry units the player text and the settings editor know (the drafts used a few informal spellings).
UNIT_MAP = {'lv': 'levels'}
# Names the MissionInfo template calls; recorded with their U44 hashes (seed 768e5ed0) as evidence.
MISSION_INFO_ACCESSOR = ('gGameRules', 'GetMission', 'SetMission', 'gRegion', 'IsMaster', 'IsValid', 'print')
MISSION_INFO_IDENTITY_FIELDS = ('alertId', 'invasionId', 'syndicateTag', 'goalId', 'sortieId', 'nightmare')


def sha256(data):
    return hashlib.sha256(data).hexdigest().upper()


def load_drafts(path=DRAFTS, pinned=DRAFTS_SHA256, label='R10'):
    raw = path.read_bytes().replace(b'\r\n', b'\n')
    if sha256(raw) != pinned:
        raise SystemExit(f'{label} drafts changed: {path} SHA-256 {sha256(raw)} != pinned {pinned}')
    return json.loads(raw.decode('utf-8'))


def num(x):
    return int(x) if float(x).is_integer() else x


def census(m, name, namehash):
    """{prototype: [instruction, ...]} of every string-keyed or hashed use of `name` (GETTABLEKS, SETTABLEKS, GETGLOBAL,
    SETGLOBAL, NAMECALL aux constants and single-name GETIMPORT)."""
    h = namehash(name)
    out = {}
    for p, (ins, consts) in enumerate(m.protos):
        for i, (_, w) in enumerate(ins):
            hit = m.key_string(p, w) == name
            if not hit and len(w) == 8 and w[0] in (GETGLOBAL, SETGLOBAL, GETTABLEKS, SETTABLEKS, NAMECALL):
                k = struct.unpack_from('<I', w, 4)[0]
                c = consts[k] if k < len(consts) else None
                hit = bool(c) and c[0] == 1 and struct.unpack('<I', c[1][:4])[0] == h
            if not hit and len(w) == 8 and w[0] == GETIMPORT:
                aux = struct.unpack_from('<I', w, 4)[0]
                if aux >> 30 == 1:
                    c = consts[(aux >> 20) & 1023]
                    hit = c[0] == 1 and struct.unpack('<I', c[1][:4])[0] == h
            if hit:
                out.setdefault(p, []).append(i)
    return out


def hashed_only(m, name, namehash, prototype, instructions):
    """True when every listed use is a hashed (tag-1) key, never the string."""
    ins, consts = m.protos[prototype]
    for i in instructions:
        if m.key_string(prototype, ins[i][1]) == name:
            return False
    return True


def root_child(m, prototype):
    """Closure-map evidence that `prototype` is created exactly once, by the module root."""
    sites = [s for s in m.sites if s[2] == prototype]
    if len(sites) != 1:
        raise ValueError(f'entry prototype {prototype} is created {len(sites)} times; it is not one root function')
    parent, instruction, _, _ = sites[0]
    if parent != m.root:
        raise ValueError(f'entry prototype {prototype} is created by prototype {parent}, not by the module root {m.root}')
    return {'prototype': prototype, 'created_by': 'root', 'closure_instruction': instruction, 'root_child': True}


def literal_site(m, site, stock, where):
    p, off = site['prototype'], site['offset']
    num_, den = site.get('numerator', 1), site.get('denominator', 1)
    # R11 coupled site: the operand is (row value + value_offset) x numerator / denominator (shared patch core).
    offset = site.get('value_offset', 0)
    if not isinstance(offset, (int, float)) or offset != offset:
        raise ValueError(f'{where}: invalid value_offset {offset!r}')
    want = (stock + offset) * num_ / den
    if site['kind'] == 'instruction':
        i = site['instruction']
        off_i, w = m.protos[p][0][i]
        if off_i != off:
            raise ValueError(f'{where}: instruction {p}:{i} is at offset {off_i}, not {off}')
        got = list(m.raw[off:off + 4])
        if got != site['expected'] or m.raw[off] != RAW_LOADN:
            raise ValueError(f'{where}: preimage at {off} is {got}, not the drafted LOADN {site["expected"]}')
        imm = struct.unpack_from('<h', m.raw, off + 2)[0]
        if imm != want:
            raise ValueError(f'{where}: LOADN immediate {imm} != stock-derived {want}')
        out = {'kind': 'instruction', 'prototype': p, 'instruction': i, 'offset': off, 'expected': got,
               'register': m.raw[off + 1], 'numerator': num_, 'denominator': den, 'owner': site.get('owner', '')}
        if offset:
            out['value_offset'] = offset
        return out
    if site['kind'] != 'number_constant':
        raise ValueError(f'{where}: unknown site kind {site["kind"]}')
    k = site['constant']
    if m.number(p, k) != want:
        raise ValueError(f'{where}: constant {p}:{k} is {m.number(p, k)}, not {want}')
    if m.constant_offset(p, k) != off:
        raise ValueError(f'{where}: constant {p}:{k} is at {m.constant_offset(p, k)}, not {off}')
    declared = [u['instruction'] for u in site['gate']['uses']]
    gate = m.exclusive_constant(p, k, declared)
    out = {'kind': 'number_constant', 'prototype': p, 'constant': k, 'offset': off, 'expected': list(m.raw[off:off + 8]),
           'numerator': num_, 'denominator': den, 'owner': site.get('owner', ''), 'gate': gate}
    if offset:
        out['value_offset'] = offset
    return out


def composed_blocks(text):
    """{struct name: [lines]} of the top-level `Name={ ... }` blocks of an inspect-type composed dump."""
    body = text.split('[inspect-type] composed metadata:\n', 1)[1]
    blocks, current, depth = {}, None, 0
    for line in body.splitlines():
        if current is None:
            m = re.fullmatch(r'([A-Za-z_][A-Za-z0-9_]*)=\{', line)
            if m:
                current, depth = m.group(1), 1
                blocks[current] = []
            continue
        depth += line.count('{') - line.count('}')
        if depth <= 0:
            current = None
            continue
        if depth == 1:
            blocks[current].append(line)
    return body, blocks


def rows(ctx):
    """Returns (rows, excluded, report). `ctx` supplies the registrar's own helpers: module(file) -> RootTables,
    register_module(file, module_path) -> (key, rec), addon_field(m, key, ev), addon_owner(m, key, rec, fields),
    namehash(name), snapshot (dict, updated in place) and packages_sha."""
    drafts = load_drafts()
    r11 = load_drafts(R11_DRAFTS, R11_DRAFTS_SHA256, 'R11')
    out, excluded = [], []
    report = {'drafts': len(drafts['rows']), 'drafts_rejected_by_research': len(drafts['rejected']), 'admitted': 0,
              'excluded': [], 'renamed': {}, 'by_backend': {}, 'by_template': {}, 'r11_drafts': len(r11['rows'])}
    for d in drafts['rows'] + [dict(x, _r11=True) for x in r11['rows']]:
        old = d['tunable_id']
        if old in EXCLUDED:
            excluded.append({'tunable_id': old, 'owner_kind': d['owner_kind'], 'confidence': d['confidence'],
                             'reason': 'R10: ' + EXCLUDED[old]})
            report['excluded'].append(old)
            continue
        tid = ID_MAP.get(old, old)
        if tid != old:
            report['renamed'][old] = tid
        o = d['owner']
        where = f'{tid} (draft {old})' if tid != old else tid
        base = {'tunable_id': tid, 'phase1_tunable_id': None, 'label': d['label'], 'mission_type': d['mission_type'],
                'variant': d['variant'], 'shared_with': d.get('shared_with', ''), 'owner_kind': d['owner_kind'],
                'backend': d['backend'], 'unit': UNIT_MAP.get(d['unit'], d['unit']), 'stock': num(d['stock']),
                'confidence': d['confidence'], 'provenance': R11_PROVENANCE if d.get('_r11') else PROVENANCE,
                'evidence': d.get('evidence', ''), 'research_draft_id': old}
        lim = dict(d['limits'])
        if d['backend'] == 'METADATA_PATCH':
            row = metadata_row(ctx, d, base, lim, where)
        else:
            m = ctx.module(o['file'])
            key, rec = ctx.register_module(o['file'], o['module_path'])
            if key != o['body_key'] or rec['sha256'] != o['stock_sha256']:
                raise ValueError(f'{where}: stock identity {key}/{rec["sha256"][:16]} != drafted {o["body_key"]}/{o["stock_sha256"][:16]}')
            if d['backend'] == 'EXACT_LITERAL':
                sites = [literal_site(m, s, d['stock'], where) for s in o['sites']]
                if any(s['kind'] == 'instruction' for s in sites):
                    # A LOADN immediate holds a whole number in 1..32767 (shared live-literal patch core domain).
                    lim['minimum'] = max(1, lim['minimum'])
                    lim['maximum'] = min(32767, lim['maximum'])
                    lim['integer'] = True
                row = dict(base, owner={'body_key': key, 'stock_sha256': rec['sha256'], 'file': rec['file'],
                                        'module_path': rec['module_path'], 'sites': sites},
                           limits=lim, applies='next_mission',
                           backend_note=f'{len(sites)} exact site(s) patched together: ' + '; '.join(s['owner'] for s in sites))
            elif o.get('template') == 'ROOT_TABLE_FIELD':
                fields = []
                for f in o['fields']:
                    if isinstance(f['field'], int):
                        ins = m.protos[m.root][0]
                        vi = [i for i, (off, _) in enumerate(ins) if off == f['value_offset']]
                        if len(vi) != 1:
                            raise ValueError(f'{where}: no root instruction at value offset {f["value_offset"]}')
                        ev = m.element_owner(vi[0], float(d['stock']))
                    else:
                        table_instruction = int(f['table_id'].split(':')[1][1:])
                        ev = m.owner(f['field'], float(d['stock']), table_instruction)
                    if ev['table_id'] != f['table_id']:
                        raise ValueError(f'{where}: field proves on {ev["table_id"]}, drafted {f["table_id"]}')
                    fields.append(ctx.addon_field(m, key, ev))
                row = dict(base, owner=ctx.addon_owner(m, key, rec, fields), limits=lim, applies='F9',
                           backend_note='Root-table field(s) ' + ', '.join(f'{x["table_id"]}.{x["field"]}' for x in fields) +
                                        ' written through the target-addon lane (ROOT_TABLE_UPVALUE_V1).')
            elif o.get('template') in ENTRY_TEMPLATES:
                row = entry_row(ctx, m, key, rec, d, base, lim, where)
            else:
                raise ValueError(f'{where}: unsupported draft owner {o.get("template")}')
        out.append(row)
        report['admitted'] += 1
        report['by_backend'][row['backend']] = report['by_backend'].get(row['backend'], 0) + 1
        template = row['owner'].get('template', row['backend'])
        report['by_template'][template] = report['by_template'].get(template, 0) + 1
    return out, excluded, report


def entry_row(ctx, m, key, rec, d, base, lim, where):
    o = d['owner']
    template = o['template']
    entries = [dict(root_child(m, e['prototype']), function=e.get('function', ''), role=e.get('role', ''))
               for e in o['entries']]
    readers = []
    for r in o['readers']:
        got = census(m, r['key'], ctx.namehash).get(r['prototype'])
        if got != r['instructions']:
            raise ValueError(f'{where}: census of {r["key"]} in prototype {r["prototype"]} is {got}, drafted {r["instructions"]}')
        readers.append({'key': r['key'], 'prototype': r['prototype'], 'instructions': got})
    owner = {'body_key': key, 'stock_sha256': rec['sha256'], 'file': rec['file'], 'module_path': rec['module_path'],
             'template': template, 'gate': ENTRY_GATE, 'entries': entries, 'readers': readers,
             'dead_readers': o.get('dead_readers', [])}
    if template == MISSION_INFO:
        field = o['field']
        if not re.fullmatch(r'[A-Za-z_][A-Za-z0-9_]*', field):
            raise ValueError(f'{where}: invalid MissionInfo field {field!r}')
        for r in readers:
            ins = m.protos[r['prototype']][0]
            if any(m.key_string(r['prototype'], ins[i][1]) != field for i in r['instructions']):
                raise ValueError(f'{where}: a {field} reader is not a string-keyed field read (MissionInfo fields are strings)')
        owner.update(field=field, host_only=True,
                     identity_fields=list(MISSION_INFO_IDENTITY_FIELDS),
                     accessor={n: f'{ctx.namehash(n):08x}' for n in MISSION_INFO_ACCESSOR},
                     write_rule=o['write_rule'], meaning=o.get('meaning', ''),
                     stock_precedent=o['accessor'].get('stock_precedent', ''))
        # The stock value is the MissionInfo default 0 (endless on normal nodes); 0 is also "no write" (the default).
        if d['stock'] != 0:
            raise ValueError(f'{where}: a MissionInfo count row must have stock 0 (normal nodes)')
        lim['minimum'] = 0
        lim['basis'] = '0 = the game default (endless on normal nodes); range from the research draft'
    else:
        mode = o['mode']
        if mode not in PARAM_MODES:
            raise ValueError(f'{where}: unknown parameter mode {mode!r}')
        globals_ = []
        for g in o['globals']:
            h = f'{ctx.namehash(g["name"]):08x}'
            if h != g['hash']:
                raise ValueError(f'{where}: hash of {g["name"]} is {h}, drafted {g["hash"]}')
            if struct.pack('<I', int(h, 16)) not in m.raw:
                raise ValueError(f'{where}: module does not reference the hashed global {g["name"]} ({h})')
            globals_.append({'name': g['name'], 'hash': h})
        names = {g['name'] for g in globals_}
        for r in readers:
            if r['key'] not in names:
                raise ValueError(f'{where}: reader of {r["key"]} is not one of the parameter globals')
            if not hashed_only(m, r['key'], ctx.namehash, r['prototype'], r['instructions']):
                raise ValueError(f'{where}: a {r["key"]} reader is string-keyed; parameter globals are hashed')
        if mode in SCALE_MODES and (d['stock'] != 1 or lim['minimum'] <= 0):
            raise ValueError(f'{where}: a scale row must have stock 1 and a positive minimum')
        owner.update(globals=globals_, mode=mode, observed=o.get('observed', {}), write_rule=o['write_rule'])
    row = dict(base, owner=owner, limits=lim, applies='next_mission',
               backend_note=f'{template}: written at the entry of prototype(s) ' +
                            ', '.join(str(e['prototype']) for e in entries) + ' (gate ' + ENTRY_GATE + ').')
    return row


def metadata_row(ctx, d, base, lim, where):
    o = d['owner']
    type_path, field = o['type'], o['field']
    struct_name, param = field.split('.')
    if not re.fullmatch(r'[A-Za-z]+Script', struct_name) or not re.fullmatch(r'_[A-Za-z0-9_]+', param):
        raise ValueError(f'{where}: metadata field {field!r} is not <Name>Script._parameter')
    text = METADATA_INPUTS[type_path].read_text(encoding='utf-8')
    if f'>{type_path}\n' not in text:
        raise ValueError(f'{where}: captured composed text is not {type_path}')
    body, blocks = composed_blocks(text)
    line = f'{param}={o["stock_text"]}'
    if line != o['preimage'] or line not in blocks.get(struct_name, []):
        raise ValueError(f'{where}: preimage {line!r} is not a line of {struct_name} in the composed {type_path}')
    consumer = o['consumer']
    ckey, crec = ctx.register_module(consumer['file'], consumer['module_path'])
    if ckey != consumer['body_key']:
        raise ValueError(f'{where}: consumer body key {ckey} != drafted {consumer["body_key"]}')
    global_name = param[1:]
    h = ctx.namehash(global_name)
    if struct.pack('<I', h) not in ctx.module(consumer['file']).raw:
        raise ValueError(f'{where}: consumer does not reference the hashed global {global_name}')
    if o['packages_bin_sha256'] != ctx.packages_sha:
        raise ValueError(f'{where}: drafted Packages.bin {o["packages_bin_sha256"][:16]} != registry {ctx.packages_sha[:16]}')
    # Same text form as the Phase 1 snapshot types: the composed dump from its `>/Lotus/...` header line on.
    record = ctx.snapshot.setdefault(type_path, {'text': body.rstrip('\n'), 'fields': {}})
    record['fields'][field] = o['stock_text']
    owner = {'type': type_path, 'field': field, 'stock_text': o['stock_text'], 'preimage': line,
             'packages_bin_sha256': ctx.packages_sha,
             'consumer': {'body_key': ckey, 'stock_sha256': crec['sha256'], 'file': crec['file'],
                          'module_path': crec['module_path'], 'function': consumer.get('function', ''),
                          'global': global_name, 'name_hash': f'{h:08x}', 'readers': consumer.get('readers', [])},
             'source': METADATA_INPUTS[type_path].relative_to(EDITOR).as_posix() +
                       ' (openwf-metadata-updater inspect-type, read-only, installed 44.0.2)'}
    return dict(base, owner=owner, limits=lim, applies='restart')
