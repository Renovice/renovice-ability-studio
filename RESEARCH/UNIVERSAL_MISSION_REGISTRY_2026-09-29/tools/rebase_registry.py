"""Update resilience step 2/3 (registry side): rebase REGISTRIES/mission_build_u44.json from build A onto build B.

The registrar (register_registry.py) derives every owner from its specs on the 44.0.2 bytes. After a Warframe update the
specs still name 44.0.2 positions, so the rebase carries every pinned owner of the CURRENT registry over to the new build
and re-proves it there with the registrar's own gates:

  * module identity and prototype/instruction/constant maps: tools/update_check/uc_remap.py (fingerprint, then scored
    similarity, then instruction alignment);
  * literal sites (EXACT_LITERAL owners and the `literal_owner` of root-table rows): every LOADN site is re-read on the new
    bytes (U44 LOADN byte, register, immediate = stock x num / den); a pattern anchor is resolved again by phase2d.py in the
    mapped prototypes and must give exactly the mapped sites; a number constant gets its K_CONSTANT_EXCLUSIVE_V1 gate
    recomputed (anchors.Analysis.exclusive_constant / template_field); an IMPORT_READ_PIN_V1 pair is rebuilt by
    mission_owner_specs.import_pin_sites and its census by import_pin_complete;
  * root-table fields (ROOT_TABLE_UPVALUE_V1): addon_owner.RootTables.owner / element_owner on the new bytes; the result
    must have the mapped structure (capturing prototypes, upvalues, access paths, containers, field reads); the minimal
    hook plan (ROOT_TABLE_MINIMAL_HOOKS_V1) is recomputed by hook_plan.plan_module exactly as the registrar does;
  * entry templates (CAPTURE_GRAPH_ENTRY_V1): mission_owner_specs.root_child for every entry and the census of every
    reader (mission_owner_specs.census) must equal the mapped instructions;
  * the Survival/Interception templates: the capture contract is re-read from the toolchain closure map;
  * metadata rows: the consumer module is re-keyed and must still reference the hashed global; a changed Packages.bin
    sends the row to review (metadata update path).

Stock values: when every site of a row reads the same new number and the code around each site is unchanged (aligned
neighbours equal, anchor pattern still exact), the row's stock is updated (STOCK_CHANGED, auto with a note); otherwise
the row goes to review. The player text and layout are then re-applied (player_text.apply, player_layout.apply) as
`python player_text.py` does.

Per row the result is one action:
  unchanged  every module the row names has the same content key in build B (nothing is touched);
  auto       re-pinned and re-proven (confidence exact, or similar with a note);
  review     not carried over: a match is ambiguous or weak, or the code around the owner changed;
  dropped    the owner no longer exists in build B (module or function removed).
Review and dropped rows are left out of the rebased registry (listed in `excluded` with the reason), so the generator
never pins an unproven owner; their value ids return when the row is re-derived. Nothing here writes outside the paths
the caller passes (the staged editor root); the game folder is never touched.
"""
from __future__ import annotations

import copy
import hashlib
import json
import re
import struct
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
from deluau import ROOT, EDITOR, RAW_LOADN  # noqa: E402
from addon_owner import RootTables, GATE as ADDON_GATE  # noqa: E402
import phase2d  # noqa: E402
import hook_plan as HOOK_PLAN  # noqa: E402
import mission_owner_specs as MOS  # noqa: E402
import player_text as PT  # noqa: E402

sys.path.insert(0, str(EDITOR / 'tools' / 'update_check'))
import uc_bytecode as UB  # noqa: E402
import uc_remap as RM  # noqa: E402

FORMAT = 'RENOVICE_REGISTRY_REBASE_V1'
UNCHANGED, AUTO, REVIEW, DROPPED = 'unchanged', 'auto', 'review', 'dropped'
RANK = {UNCHANGED: 0, AUTO: 1, REVIEW: 2, DROPPED: 3}
IMPORT_PIN = 'IMPORT_READ_PIN_V1'


class Problem(Exception):
    def __init__(self, action, reason):
        super().__init__(reason)
        self.action = action
        self.reason = reason


def sha_upper(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest().upper()


def _num(x):
    return int(x) if float(x).is_integer() else x


class Outcome:
    """Decision for one registry row."""

    def __init__(self, row):
        self.tid = row['tunable_id']
        self.action = UNCHANGED
        self.confidence = 'exact'
        self.notes: list[str] = []
        self.items: list[dict] = []
        self.reason = ''
        self.stock = None          # (old, new) when the stock value changed

    def worse(self, action, reason=''):
        if RANK[action] > RANK[self.action]:
            self.action = action
            if reason:
                self.reason = reason

    def as_json(self, modules):
        out = {'tunable_id': self.tid, 'action': self.action, 'confidence': self.confidence}
        if modules:
            out['modules'] = modules
        if self.reason:
            out['reason'] = self.reason
        if self.stock:
            out['stock'] = {'old': self.stock[0], 'new': self.stock[1]}
        if self.notes:
            out['notes'] = self.notes
        if self.items:
            out['items'] = self.items
        return out


class Rebase:
    def __init__(self, registry: dict, old_dir: Path, new_dir: Path, opmap, *, build: str, build_label: str,
                 packages_bin_sha256: str | None, corpus_rel: str, log=print, force: dict | None = None):
        self.reg = registry
        self.force = dict(force or {})              # tunable id -> reason: sent to review by a later gate (verify-missions)
        self.old_dir, self.new_dir = Path(old_dir), Path(new_dir)
        self.opmap = opmap
        self.build, self.build_label = build, build_label
        self.packages_bin = packages_bin_sha256
        self.corpus_rel = corpus_rel
        self.log = log
        self.seed = int(registry['name_hash_seed'], 16)
        self.maps: dict[str, RM.ModuleMap] = {}       # old body key -> map
        self._rt: dict[tuple, RootTables] = {}
        self.new_file: dict[str, str] = {}            # old body key -> file name in build B

    # -- helpers -----------------------------------------------------------------------------------------------------
    def namehash(self, name: str) -> int:
        return UB.name_hash(name, self.seed)

    def old_bytes(self, key):
        rec = self.reg['modules'][key]
        data = (self.old_dir / rec['file']).read_bytes()
        if sha_upper(data) != rec['sha256'].upper():
            raise SystemExit(f'rebase: old module {rec["file"]} does not have the registry SHA-256 (wrong build-A corpus)')
        return data

    def map(self, key) -> RM.ModuleMap:
        if key not in self.maps:
            rec = self.reg['modules'][key]
            a = UB.Module(self.old_bytes(key), self.opmap)
            path = self.new_dir / rec['file']
            b = UB.Module(path.read_bytes(), self.opmap) if path.is_file() else None
            self.maps[key] = RM.ModuleMap(a, b, rec['file'])
            self.new_file[key] = rec['file']
        return self.maps[key]

    def rt(self, key, side):
        """Registrar analysis (RootTables = Analysis + closure map) of one module on side 'A' or 'B'."""
        if (key, side) not in self._rt:
            mm = self.map(key)
            self._rt[key, side] = RootTables(mm.ma.data if side == 'A' else mm.mb.data)
        return self._rt[key, side]

    @staticmethod
    def _prose(text, moves):
        """Rewrite 'P<a> i<b>' / 'proto <a>' references in an owner text for the positions that moved."""
        if not isinstance(text, str):
            return text
        for (pa, ia), (pb, ib) in moves.items():
            text = re.sub(rf'\bP{pa} i{ia}\b', f'P{pb} i{ib}', text)
        return text

    def _proto(self, mm: RM.ModuleMap, p: int, out: Outcome, what: str) -> int:
        pm = mm.proto(p)
        if pm.b is None:
            if pm.kind == 'unmatched':
                raise Problem(DROPPED, f'{what}: prototype {p} of {mm.file} has no counterpart in the new build ({pm.note})')
            raise Problem(REVIEW, f'{what}: prototype {p} of {mm.file} is {pm.kind}: {pm.note}')
        if pm.kind == 'similar':
            out.confidence = 'similar'
            note = f'{mm.file} P{p} -> P{pm.b}: {pm.note}'
            if note not in out.notes:
                out.notes.append(note)
        return pm.b

    def _ins(self, mm, p, i, out, what):
        pb = self._proto(mm, p, out, what)
        hit = mm.instruction(p, i)
        if hit is None:
            raise Problem(REVIEW, f'{what}: instruction {i} of prototype {p} has no aligned instruction in P{pb} '
                                  '(the code around it changed)')
        return hit

    def _context_same(self, mm, p, i, radius=3):
        """The aligned neighbours of instruction i (radius on each side) are unchanged."""
        al = mm.alignment(p)
        if al is None:
            return False
        n = len(mm.ma.protos[p].instructions)
        j0 = al.pairs.get(i, (None,))[0]
        for d in range(-radius, radius + 1):
            if d == 0 or not 0 <= i + d < n:
                continue
            hit = al.pairs.get(i + d)
            if hit is None or hit[1] != 'equal' or hit[0] != j0 + d:
                return False
        return True

    # -- literal owners ----------------------------------------------------------------------------------------------
    def literal(self, lit: dict, row: dict, out: Outcome) -> tuple[dict, float | None, set]:
        """Rebased copy of a literal owner, the stock its sites encode in build B (None if no site encodes it) and the
        set of changed sites (for the context rule)."""
        key = lit['body_key']
        mm = self.map(key)
        if mm.status == 'removed':
            raise Problem(DROPPED, f'module {lit["file"]} is not in the new build')
        an = self.rt(key, 'B')
        raw = mm.mb.data
        new = copy.deepcopy(lit)
        stocks, changed, moves = set(), [], {}
        pins = []
        for n, (old, site) in enumerate(zip(lit['sites'], new['sites'])):
            what = f'site {n} (P{old["prototype"]})'
            num, den = site.get('numerator', 1), site.get('denominator', 1)
            if site['kind'] == 'number_constant':
                pa, ka = old['prototype'], old['constant']
                pb = self._proto(mm, pa, out, what)
                kb = mm.constant(pa, ka)
                if kb is None:
                    raise Problem(REVIEW, f'{what}: constant {ka} has no counterpart in P{pb}')
                gate = old.get('gate', {})
                uses = gate.get('uses', [])
                try:
                    if uses and 'template' in uses[0]:
                        tb = mm.constant(pa, uses[0]['template'])
                        if tb is None:
                            raise Problem(REVIEW, f'{what}: template constant {uses[0]["template"]} has no counterpart')
                        v, new_gate = an.template_field(pb, tb, uses[0]['field'])
                        if v != kb:
                            raise Problem(REVIEW, f'{what}: template {tb}.{uses[0]["field"]} names constant {v}, mapped {kb}')
                    else:
                        declared = [self._ins(mm, pa, u['instruction'], out, what)[1] for u in uses]
                        new_gate = an.exclusive_constant(pb, kb, declared)
                except ValueError as e:
                    raise Problem(REVIEW, f'{what}: K_CONSTANT_EXCLUSIVE_V1 fails on the new bytes: {e}')
                off = an.constant_offset(pb, kb)
                site.update(prototype=pb, constant=kb, offset=off, expected=list(raw[off:off + 8]), gate=new_gate)
                out.items.append({'site': f'P{pa} K{ka} @{old["offset"]}', 'new': f'P{pb} K{kb} @{off}'})
                value = struct.unpack('<d', raw[off:off + 8])[0]
                if raw[off:off + 8] != bytes(old['expected']):
                    changed.append((pa, None))
            else:
                pa, ia = old['prototype'], old['instruction']
                pb, ib, how = self._ins(mm, pa, ia, out, what)
                proto_b = mm.mb.protos[pb]
                off = mm.mb.offset(proto_b, ib) + (4 if 'aux_of' in old else 0)
                word = raw[off:off + 4]
                moves[(pa, ia)] = (pb, ib)
                out.items.append({'site': f'P{pa} i{ia} @{old["offset"]}', 'new': f'P{pb} i{ib} @{off}'})
                site.update(prototype=pb, instruction=ib, offset=off, expected=list(word))
                if 'aux_of' in old:
                    site['aux_of'] = ib
                if old.get('gate') == IMPORT_PIN:
                    pins.append((n, old, site))
                    continue
                if old.get('rewrites_instruction'):
                    if word != bytes(old['expected']):
                        raise Problem(REVIEW, f'{what}: the instruction a carried-over rewrite replaces changed '
                                              f'({bytes(old["expected"]).hex()} -> {word.hex()})')
                    continue
                if word[0] != RAW_LOADN or word[1] != old['register']:
                    raise Problem(REVIEW, f'{what}: P{pb} i{ib} is no longer a LOADN of r{old["register"]} ({word.hex()})')
                value = struct.unpack('<h', word[2:4])[0]
                if word != bytes(old['expected']):
                    changed.append((pa, ia))
                if how == 'modified' and word == bytes(old['expected']):
                    out.notes.append(f'{what}: aligned instruction has other operands but the same bytes')
            if not site.get('inverse'):
                stocks.add(value * den / num - site.get('value_offset', 0))
        # IMPORT_READ_PIN_V1 pairs: rebuilt by the registrar function, then the census completeness
        by_ins = {}
        for n, old, site in pins:
            by_ins.setdefault((site['prototype'], site['instruction']), []).append((n, old, site))
        try:
            for (pb, ib), group in by_ins.items():
                old = group[0][1]
                base = re.sub(r' \((instruction|aux) word\)$', '', old.get('owner', ''))
                built = MOS.import_pin_sites(an, {'prototype': pb, 'instruction': ib, 'global': old['global'],
                                                  'hash': old['hash'], 'owner': base}, self.namehash, row['tunable_id'])
                for _, o, site in group:
                    src = built[1] if 'aux_of' in o else built[0]
                    site.update(prototype=src['prototype'], instruction=src['instruction'], offset=src['offset'],
                                expected=src['expected'], register=src['register'])
            if pins:
                MOS.import_pin_complete(an, new['sites'], self.namehash, row['tunable_id'])
        except ValueError as e:
            raise Problem(REVIEW, f'IMPORT_READ_PIN_V1 does not hold on the new bytes: {e}')
        if len(stocks) > 1:
            raise Problem(REVIEW, f'the sites now encode different stock values {sorted(stocks)}; one control would '
                                  'edit several values (the owner changed)')
        # pattern anchors: re-resolved in the mapped prototypes, must give exactly the mapped sites
        groups = {}
        for old, site in zip(lit['sites'], new['sites']):
            if old.get('anchor', {}).get('kind') == 'pattern':
                k = json.dumps({x: old['anchor'][x] for x in ('value', 'before', 'after') if x in old['anchor']}, sort_keys=True)
                groups.setdefault(k, []).append((old, site))
        for k, members in groups.items():
            a0 = members[0][0]['anchor']
            value = struct.unpack('<h', bytes(members[0][1]['expected'])[2:4])[0]
            spec = {'value': value, 'before': a0.get('before', []), 'after': a0.get('after', []), 'count': len(members),
                    'protos': sorted({s['prototype'] for _, s in members}), 'owner': members[0][0].get('owner', '')}
            try:
                got = {(s['prototype'], s['instruction']) for s in phase2d.resolve_pattern(an, spec)}
            except ValueError as e:
                raise Problem(REVIEW, f'anchor pattern no longer resolves exactly in the mapped prototypes: {e}')
            want = {(s['prototype'], s['instruction']) for _, s in members}
            if got != want:
                raise Problem(REVIEW, f'anchor pattern resolves {sorted(got)}, the mapped sites are {sorted(want)}')
            for _, s in members:
                s['anchor']['value'] = value
        for site in new['sites']:
            if 'owner' in site:
                site['owner'] = self._prose(site['owner'], moves)
        if len(stocks) > 1:
            raise Problem(REVIEW, f'the sites now encode different stock values {sorted(stocks)}; one control would '
                                  'edit several values (the owner changed)')
        rec = mm.mb
        new.update(body_key=rec.key, stock_sha256=rec.sha256.upper())
        return new, (stocks.pop() if stocks else None), changed

    def stock_rule(self, row, new_stock, changed_sites, out, owner_key):
        """Stock value change: accepted when every changed site keeps its neighbours (meaning unchanged)."""
        old = row.get('stock')
        if new_stock is None or old is None or float(new_stock) == float(old):
            return
        mm = self.map(owner_key)
        for pa, ia in changed_sites:
            if ia is not None and not self._context_same(mm, pa, ia):
                raise Problem(REVIEW, f'stock changed {old} -> {_num(new_stock)} and the code around P{pa} i{ia} changed '
                                      '(the context changed: re-derive the owner)')
        out.stock = (old, _num(new_stock))
        out.notes.append(f'STOCK_CHANGED {old} -> {_num(new_stock)}: every site reads the new value in unchanged '
                         'context; registry stock updated')

    # -- root-table fields -------------------------------------------------------------------------------------------
    def _value_instruction(self, m: UB.Module, root: int, f: dict):
        proto = m.protos[root]
        if f['value_kind'] == 'instruction':
            hit = m.logical_at(f['value_offset'])
            return hit[1] if hit and hit[0] == root else None
        k = f.get('value_constant')
        for i, _, op in proto.instructions:
            if op == RM.OP_LOADK and RM.operand_constant(m, proto, i) == k:
                return i
        return None

    def _derive_field(self, rt: RootTables, f, table_instruction, value_instruction, stock):
        if f['construction'] == 'NEWTABLE+SETLIST':
            return rt.element_owner(value_instruction, stock)
        return rt.owner(f['field'], stock, table_instruction)

    def root_field(self, key, f, stock_a, out, what):
        """(evidence on B, new stock) for one owned field; raises Problem."""
        mm = self.map(key)
        rta, rtb = self.rt(key, 'A'), self.rt(key, 'B')
        root_a, root_b = mm.ma.main_index, mm.mb.main_index
        table = self.reg['modules'][key]['root_tables'][f['table_id']]
        via_a = self._value_instruction(mm.ma, root_a, f)
        try:
            ev_a = self._derive_field(rta, f, table['instruction'], via_a, stock_a)
        except ValueError as e:
            raise SystemExit(f'rebase: {what} does not re-derive on the build-A bytes ({e}); the registry is not the '
                             'registrar output for this corpus')
        d = mm.instruction(root_a, ev_a['construction']['instruction'])
        if d is None:
            raise Problem(REVIEW, f'{what}: the table construction (root i{ev_a["construction"]["instruction"]}) has no '
                                  'aligned instruction')
        vi = mm.instruction(root_a, via_a) if via_a is not None else None
        # the stock value in build B, read at the mapped initialiser
        if f['value_kind'] == 'instruction':
            if vi is None:
                raise Problem(REVIEW, f'{what}: the initialiser (root i{via_a}) has no aligned instruction')
            w = mm.mb.word(mm.mb.protos[root_b], vi[1])
            stock_b = struct.unpack_from('<h', w, 2)[0] if w[0] == RM.OP_LOADN else None
            if stock_b is None:
                raise Problem(REVIEW, f'{what}: the initialiser is no longer a LOADN')
        else:
            kb = mm.constant(root_a, f['value_constant'])
            if kb is None:
                raise Problem(REVIEW, f'{what}: the value constant {f["value_constant"]} has no counterpart')
            c = mm.mb.protos[root_b].consts[kb]
            if c.tag != 2:
                raise Problem(REVIEW, f'{what}: the value constant is no longer a number')
            stock_b = c.value
        try:
            ev_b = self._derive_field(rtb, f, d[1], vi[1] if vi else None, stock_b)
        except ValueError as e:
            raise Problem(REVIEW, f'{what}: ROOT_TABLE_UPVALUE_V1 fails on the new bytes: {e}')
        # structure must be the mapped one
        def mapped_hooks(ev, side_map):
            out_ = []
            for h in ev['hooks']:
                p = side_map(h['prototype'])
                out_.append((p, h['upvalue'], tuple(h['path']), h['capture'].split(':')[0]))
            return sorted(out_)
        try:
            want = mapped_hooks(ev_a, lambda p: self._proto(mm, p, out, what))
        except Problem:
            raise
        got = mapped_hooks(ev_b, lambda p: p)
        if want != got:
            raise Problem(REVIEW, f'{what}: the capturing prototypes changed (mapped {want}, now {got}); the context '
                                  'changed')
        if ev_a['field_reads'] != ev_b['field_reads'] or len(ev_a['containers']) != len(ev_b['containers']):
            raise Problem(REVIEW, f'{what}: field reads {ev_a["field_reads"]} -> {ev_b["field_reads"]} or containers '
                                  f'{len(ev_a["containers"])} -> {len(ev_b["containers"])} changed')
        return ev_b, stock_b

    @staticmethod
    def table_record(ev):
        c = ev['construction']
        return {'gate': ADDON_GATE, 'prototype': c['prototype'], 'instruction': c['instruction'], 'register': c['register'],
                'op': c['op'].split('+')[0], 'containers': ev['containers'],
                'hooks': [{k: h[k] for k in ('prototype', 'upvalue', 'path', 'capture', 'closure_instruction')}
                          for h in ev['hooks']]}

    def field_entry(self, f, ev, raw):
        c = ev['construction']
        off, kind = c['value_offset'], c['value_kind']
        width = 8 if kind == 'number_constant' else 4
        e = dict(f)
        e.update(table_id=ev['table_id'], value_kind=kind, value_offset=off, expected=list(raw[off:off + width]),
                 construction=c['op'], field_reads=ev['field_reads'])
        if kind == 'number_constant':
            e['value_constant'] = c['value_constant']
        else:
            e.pop('value_constant', None)
        return e

    def root_fields(self, row, out, tables):
        owner = row['owner']
        key = owner['body_key']
        mm = self.map(key)
        if mm.status == 'removed':
            raise Problem(DROPPED, f'module {owner["file"]} is not in the new build')
        mode = owner.get('mode')
        fields, stocks = [], set()
        for n, f in enumerate(owner['fields']):
            what = f'field {f["field"]} of {f["table_id"]}'
            stock_a = f['stock'] if mode else row['stock']
            ev, stock_b = self.root_field(key, f, stock_a, out, what)
            e = self.field_entry(f, ev, mm.mb.data)
            if mode:
                if float(stock_b) != float(stock_a):
                    out.notes.append(f'STOCK_CHANGED {what}: {stock_a} -> {_num(stock_b)} (scaled row: the field stock '
                                     'is updated, the row stays a multiplier)')
                    e['stock'] = _num(stock_b)
            else:
                stocks.add(float(stock_b))
            fields.append(e)
            out.items.append({'field': f'{f["table_id"]}.{f["field"]} @{f["value_offset"]}',
                              'new': f'{e["table_id"]}.{e["field"]} @{e["value_offset"]}',
                              'hooks': sorted({h['prototype'] for h in ev['hooks']})})
            tables.setdefault(ev['table_id'], self.table_record(ev))
        new_stock = None
        if stocks:
            if len(stocks) > 1:
                raise Problem(REVIEW, f'the owned fields now hold different values {sorted(stocks)}')
            new_stock = stocks.pop()
            if float(new_stock) != float(row['stock']):
                out.stock = (row['stock'], _num(new_stock))
                out.notes.append(f'STOCK_CHANGED {row["stock"]} -> {_num(new_stock)}: the table initialiser holds the new '
                                 'value with the same capture structure; registry stock updated')
        return fields, new_stock

    # -- entry templates ---------------------------------------------------------------------------------------------
    def readers(self, key, readers, out, what, census=True):
        mm = self.map(key)
        rtb = self.rt(key, 'B')
        new = []
        for r in readers:
            pa = r['prototype']
            pb = self._proto(mm, pa, out, f'{what} reader {r["key"]}')
            ins = [self._ins(mm, pa, i, out, f'{what} reader {r["key"]}')[1] for i in r['instructions']]
            if census:
                got = MOS.census(rtb, r['key'], self.namehash).get(pb)
                if got != sorted(ins):
                    raise Problem(REVIEW, f'{what}: census of {r["key"]} in prototype {pb} is {got}, the mapped readers '
                                          f'are {sorted(ins)} (a reader was added or removed)')
            nr = dict(r)
            nr.update(prototype=pb, instructions=ins)
            new.append(nr)
        return new

    def entry(self, row, out):
        owner = row['owner']
        key = owner['body_key']
        mm = self.map(key)
        if mm.status == 'removed':
            raise Problem(DROPPED, f'module {owner["file"]} is not in the new build')
        rtb = self.rt(key, 'B')
        new = copy.deepcopy(owner)
        for e in new['entries']:
            pb = self._proto(mm, e['prototype'], out, 'entry')
            try:
                rc = MOS.root_child(rtb, pb)
            except ValueError as err:
                raise Problem(REVIEW, f'entry prototype {pb}: {err}')
            out.items.append({'entry': f'P{e["prototype"]}', 'new': f'P{pb}'})
            e.update(prototype=pb, closure_instruction=rc['closure_instruction'])
        new['readers'] = self.readers(key, owner['readers'], out, 'entry')
        new['dead_readers'] = self.readers(key, owner.get('dead_readers', []), out, 'dead', census=False)
        for g in owner.get('globals', []):
            if struct.pack('<I', int(g['hash'], 16)) not in mm.mb.data:
                raise Problem(DROPPED, f'the module no longer references the hashed global {g["name"]}')
        if owner['template'] == MOS.MISSION_INFO:
            for r in new['readers']:
                ins = rtb.protos[r['prototype']][0]
                if any(rtb.key_string(r['prototype'], ins[i][1]) != owner['field'] for i in r['instructions']):
                    raise Problem(REVIEW, f'a {owner["field"]} reader is no longer a string-keyed field read')
        new.update(body_key=mm.mb.key, stock_sha256=mm.mb.sha256.upper())
        return new

    # -- Survival / Interception templates ---------------------------------------------------------------------------
    def capture(self, key, proto_b, upvalue, field, stock):
        """register_registry.capture_evidence on build B (closure map of the toolchain)."""
        rtb = self.rt(key, 'B')
        sites = [s for s in rtb.sites if s[2] == proto_b and s[0] == rtb.root]
        if len(sites) != 1:
            raise Problem(REVIEW, f'prototype {proto_b} is not created exactly once by the root')
        _, closure_i, _, caps = sites[0]
        if upvalue - 1 not in caps:
            raise Problem(REVIEW, f'prototype {proto_b} has no upvalue {upvalue}')
        mode, reg = caps[upvalue - 1]
        if not reg.startswith('R'):
            raise Problem(REVIEW, 'capture is not a root register')
        reg = int(reg[1:])
        ins, consts = rtb.protos[rtb.root]
        writes = [i for i in range(closure_i) if ins[i][1][1] == reg]
        ev = {'closure_instruction': closure_i, 'capture': f'{mode}:R{reg}', 'root_register': reg}
        if field is None:
            return ev
        last = ins[writes[-1]][1]
        if last[0] != 0x4f:
            raise Problem(REVIEW, 'captured register is not initialised by a DUPTABLE template')
        template = struct.unpack_from('<H', last, 2)[0]
        tag, items = consts[template]
        entries = [(consts[k], struct.unpack('<I', fix)[0]) for k, fix in items]
        hits = [v for kc, v in entries if kc[0] == 'str' and rtb.pool[kc[1] - 1].decode() == field]
        if len(hits) != 1:
            raise Problem(REVIEW, f'template {template} has {len(hits)} entries for {field}')
        vtag, vbytes = consts[hits[0]]
        if vtag != 2:
            raise Problem(REVIEW, f'template value for {field} is not a number')
        value = struct.unpack('<d', vbytes)[0]
        ev.update(duptable_instruction=writes[-1], template_constant=template, value_constant=hits[0], value=_num(value))
        return ev

    def template(self, row, out, tables):
        owner = row['owner']
        key = owner['body_key']
        mm = self.map(key)
        if mm.status == 'removed':
            raise Problem(DROPPED, f'module {owner["file"]} is not in the new build')
        new = copy.deepcopy(owner)
        pb = self._proto(mm, owner['prototype'], out, 'template hook')
        a, b = mm.ma.protos[owner['prototype']], mm.mb.protos[pb]
        if a.header[1:3] != b.header[1:3]:
            raise Problem(REVIEW, f'template prototype {owner["prototype"]} -> {pb}: parameter/upvalue count changed')
        new['prototype'] = pb
        out.items.append({'template_hook': f'P{owner["prototype"]}', 'new': f'P{pb}'})
        stock_b = None
        if 'capture_evidence' in owner:
            old = owner['capture_evidence']
            ev = self.capture(key, pb, owner['upvalue'], owner['field'], row['stock'])
            if ev['capture'].split(':')[0] != old['capture'].split(':')[0]:
                raise Problem(REVIEW, f'capture mode changed {old["capture"]} -> {ev["capture"]}')
            if 'value' in ev:
                stock_b = ev['value']
            new['capture_evidence'] = {k: ev[k] for k in old if k in ev}
        if 'fields' in owner:
            fields, fstock = self.root_fields(row, out, tables)
            new['fields'] = fields
            stock_b = fstock if fstock is not None else stock_b
        if stock_b is not None and float(stock_b) != float(row['stock']) and not out.stock:
            out.stock = (row['stock'], _num(stock_b))
            out.notes.append(f'STOCK_CHANGED {row["stock"]} -> {_num(stock_b)} (template capture value)')
        new.update(body_key=mm.mb.key, stock_sha256=mm.mb.sha256.upper())
        return new

    # -- metadata ----------------------------------------------------------------------------------------------------
    def metadata(self, row, out):
        owner = row['owner']
        if self.packages_bin and self.packages_bin.lower() != owner['packages_bin_sha256'].lower():
            raise Problem(REVIEW, f'Packages.bin changed ({owner["packages_bin_sha256"][:16]} -> {self.packages_bin[:16]}): '
                                  'metadata rows follow the metadata update path (re-derive the snapshot)')
        c = owner['consumer']
        mm = self.map(c['body_key'])
        if mm.status == 'removed':
            raise Problem(DROPPED, f'consumer module {c["file"]} is not in the new build')
        if mm.status == 'unchanged':
            return owner
        new = copy.deepcopy(owner)
        if struct.pack('<I', int(c['name_hash'], 16)) not in mm.mb.data:
            raise Problem(DROPPED, f'the consumer no longer references the hashed global {c["global"]}')
        if 'readers' in c:
            new['consumer']['readers'] = self.readers(c['body_key'], c['readers'], out, 'consumer')
        new['consumer'].update(body_key=mm.mb.key, stock_sha256=mm.mb.sha256.upper())
        return new

    # -- driver ------------------------------------------------------------------------------------------------------
    def row_keys(self, row):
        o = row['owner']
        keys = []
        for ref in (o, row.get('literal_owner') or {}, o.get('consumer') or {}):
            if ref.get('body_key') and ref['body_key'] not in keys:
                keys.append(ref['body_key'])
        return keys

    def run(self):
        reg = self.reg
        rows, outcomes = [], []
        new_tables: dict[str, dict] = {}       # old key -> {table_id: record} rebuilt for changed modules
        for row in reg['tunables']:
            out = Outcome(row)
            tables = {}
            keys = self.row_keys(row)
            maps = [self.map(k) for k in keys]
            mods = [{'file': m.file, 'old_key': m.ma.key, 'new_key': m.mb.key if m.mb else None, 'status': m.status}
                    for m in maps]
            if row['tunable_id'] in self.force:
                out.worse(REVIEW, self.force[row['tunable_id']])
                outcomes.append(out.as_json(mods))
                continue
            new_row = row
            try:
                if row['backend'] == 'SERVER_CONFIG':
                    pass
                elif row['backend'] == 'METADATA_PATCH':
                    owner = self.metadata(row, out)
                    if owner is not row['owner']:
                        new_row = dict(row, owner=owner)
                        out.worse(AUTO)
                elif all(m.status == 'unchanged' for m in maps):
                    pass
                else:
                    new_row = copy.deepcopy(row)
                    out.worse(AUTO)
                    key = row['owner']['body_key']
                    tables = {}            # this row's tables; merged only when the row is kept
                    lit_stock = None
                    if 'literal_owner' in row:
                        lo, lit_stock, changed = self.literal(row['literal_owner'], row, out)
                        new_row['literal_owner'] = lo
                        if lit_stock is not None and float(lit_stock) != float(row['stock']):
                            self.stock_rule(row, lit_stock, changed, out, row['literal_owner']['body_key'])
                    if row['backend'] == 'EXACT_LITERAL':
                        owner, st, changed = self.literal(row['owner'], row, out)
                        new_row['owner'] = owner
                        self.stock_rule(row, st, changed, out, key)
                    elif MOS.ENTRY_GATE == row['owner'].get('gate'):
                        new_row['owner'] = self.entry(row, out)
                    elif row['owner'].get('template') == 'ROOT_TABLE_FIELD':
                        stock_before = out.stock
                        fields, st = self.root_fields(row, out, tables)
                        new_row['owner']['fields'] = fields
                        new_row['owner'].update(body_key=self.map(key).mb.key,
                                                stock_sha256=self.map(key).mb.sha256.upper())
                        if lit_stock is not None and st is not None and float(lit_stock) != float(st):
                            raise Problem(REVIEW, f'the literal form reads {lit_stock}, the table field {st}')
                        if stock_before and out.stock and stock_before != out.stock:
                            raise Problem(REVIEW, 'literal and table stock changes disagree')
                    else:
                        new_row['owner'] = self.template(row, out, tables)
                    if out.stock:
                        new_row['stock'] = out.stock[1]
                    if 'backend_note' in new_row and row['owner'].get('entries'):
                        new_row['backend_note'] = re.sub(
                            r'prototype\(s\) [0-9, ]+', 'prototype(s) ' + ', '.join(
                                str(e['prototype']) for e in new_row['owner']['entries']) + ' ', new_row['backend_note'])
                        new_row['backend_note'] = new_row['backend_note'].replace('  (gate', ' (gate')
            except Problem as p:
                out.worse(p.action, p.reason)
            if out.action in (REVIEW, DROPPED):
                outcomes.append(out.as_json(mods))
                continue
            if out.stock and out.stock[1] is not None:
                lim = new_row['limits']
                if not (lim['minimum'] <= float(out.stock[1]) <= lim['maximum']):
                    out.worse(REVIEW, f'the new stock {out.stock[1]} is outside the limits {lim["minimum"]}..{lim["maximum"]}')
                    outcomes.append(out.as_json(mods))
                    continue
            if new_row is not row and row['backend'] == 'TARGET_ADDON' and 'fields' in new_row['owner']:
                merged = new_tables.setdefault(row['owner']['body_key'], {})
                for tid, rec in tables.items():
                    if merged.setdefault(tid, rec) != rec:
                        out.worse(REVIEW, f'table {tid} evidence differs between rows')
                if out.action == REVIEW:
                    outcomes.append(out.as_json(mods))
                    continue
            rows.append(new_row)
            outcomes.append(out.as_json(mods))
        return self.assemble(rows, outcomes, new_tables)

    def assemble(self, rows, outcomes, new_tables):
        reg = self.reg
        kept = {r['tunable_id'] for r in rows}
        absent = {o['tunable_id'] for o in outcomes if o['action'] in (REVIEW, DROPPED)}
        # module records
        modules = {}
        for key, rec in reg['modules'].items():
            mm = self.map(key)
            if mm.status == 'unchanged':
                modules[key] = rec
                continue
            used = any(key in self.row_keys(r) or self._new_key_of(key) in self.row_keys(r) for r in rows)
            if mm.status == 'removed' or not used:
                continue
            nrec = copy.deepcopy(rec)
            nrec.update(sha256=mm.mb.sha256.upper(), size=len(mm.mb.data))
            if 'addon' in nrec:
                self._addon_record(key, nrec['addon'])
            if 'root_tables' in rec:
                tables = new_tables.get(key, {})
                nrec['root_tables'] = dict(sorted(tables.items(), key=lambda kv: int(kv[0].split(':')[1][1:])))
                if not nrec['root_tables']:
                    nrec.pop('root_tables')
            modules[mm.mb.key] = nrec
        # minimal hook plans of the rebuilt tables (registrar code, unchanged semantics)
        for new_key, rec in modules.items():
            old_key = next((k for k in reg['modules'] if self.map(k).mb is not None and self.map(k).mb.key == new_key
                            and self.map(k).status == 'changed'), None)
            if old_key is None or 'root_tables' not in rec:
                continue
            owned = {}
            for r in rows:
                if r['backend'] == 'TARGET_ADDON' and r['owner'].get('body_key') == new_key:
                    for f in r['owner'].get('fields', []):
                        owned.setdefault(f['table_id'], set()).add(f['field'])
            plans = HOOK_PLAN.plan_module(self.rt(old_key, 'B'), rec['root_tables'], owned)[0]
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
                                   'root_children': plan['root_children'], 'retire_safe': plan['retire_safe'],
                                   'retire_blockers': plan['retire_blockers']})
                else:
                    record['note'] = plan['note']
                table['minimal_hooks'] = record
        # presets
        presets = {}
        for pid, preset in reg['missions'].items():
            ids = [p['tunable_id'] for p in preset['parameters'].values()]
            if any(t in absent for t in ids):
                continue
            mm = self.map(preset['body_key']) if preset['body_key'] in reg['modules'] else None
            if mm is None or mm.status == 'unchanged':
                presets[pid] = preset
                continue
            np_ = dict(preset)
            np_.update(body_key=mm.mb.key, sha256=mm.mb.sha256.upper())
            presets[pid] = np_
        out = dict(reg)
        out.update(build=self.build, build_label=self.build_label, corpus=self.corpus_rel, modules=dict(sorted(modules.items())),
                   tunables=sorted(rows, key=lambda r: r['tunable_id']), missions=presets)
        if self.packages_bin:
            out['packages_bin_sha256'] = self.packages_bin
        if absent:
            excluded = [e for e in reg['excluded'] if e['tunable_id'] not in absent]
            by = {o['tunable_id']: o for o in outcomes}
            for tid in sorted(absent):
                row = next(r for r in reg['tunables'] if r['tunable_id'] == tid)
                excluded.append({'tunable_id': tid, 'owner_kind': row['owner_kind'], 'confidence': row.get('confidence', ''),
                                 'reason': f'UPDATE {self.build} {by[tid]["action"]}: {by[tid].get("reason", "")}'})
            out['excluded'] = sorted(excluded, key=lambda r: r['tunable_id'])
        # player text and layout (python player_text.py), tolerating the rows left out
        masters_all = reg.get('ui_masters', {})
        absent_masters = {mid for mid, m in masters_all.items()
                          if all(d['tunable_id'] in absent for d in m['drives'])}
        skip = frozenset(absent | absent_masters)
        changed_any = any(o['action'] != UNCHANGED for o in outcomes)
        if changed_any:
            masters, meta = PT.apply(out['tunables'], out['ui_groups'], skip)
            out['ui_layout'] = PT.LAYOUT.apply(out['tunables'], out['ui_groups'], masters, skip)
            out['ui_groups'] = dict(sorted(out['ui_groups'].items(), key=lambda kv: kv[1]['order']))
            out['ui_masters'] = masters
            out['ui_player_text'] = meta
        return out, outcomes, sorted(skip)

    def _new_key_of(self, key):
        mm = self.map(key)
        return mm.mb.key if mm.mb is not None else None

    def _addon_record(self, key, addon):
        mm = self.map(key)
        cur = addon['current_prototype']
        pm = mm.proto(cur)
        if pm.b is None:
            return
        pb = pm.b
        gen = addon['generation']['prototype']
        if addon['source_rewrites']:
            addon['source_rewrites'] = [[lhs, re.sub(rf'(?<!\d){cur}(?!\d)', str(pb), rhs)] for lhs, rhs in addon['source_rewrites']]
        elif pb != gen:
            addon['source_rewrites'] = [[f'prototype == {gen}', f'prototype == {pb}'], [f'[{gen}] =', f'[{pb}] ='],
                                        [f'proto{gen}', f'proto{pb}'], [f'prototype {gen}', f'prototype {pb}']]
        addon['current_prototype'] = pb


def dump(registry: dict) -> bytes:
    """The registrar's serialisation (register_registry.py / player_text.py): indent 2, UTF-8, LF."""
    return (json.dumps(registry, indent=2, ensure_ascii=False) + '\n').encode('utf-8')


def corpus_files(registry: dict) -> list[str]:
    return sorted({rec['file'] for rec in registry['modules'].values()})


if __name__ == '__main__':
    import argparse
    ap = argparse.ArgumentParser(description='Rebase the mission registry onto a new build (offline).')
    ap.add_argument('--old', type=Path, required=True, help='build-A modules (the registry authoring corpus)')
    ap.add_argument('--new', type=Path, required=True, help='build-B stock modules (same file names)')
    ap.add_argument('--out', type=Path, required=True, help='output registry JSON (never the repository file)')
    ap.add_argument('--decisions', type=Path, required=True)
    ap.add_argument('--build', required=True)
    ap.add_argument('--build-label', default='')
    ap.add_argument('--packages-bin-sha256')
    ap.add_argument('--corpus-rel', required=True)
    args = ap.parse_args()
    registry = json.loads((EDITOR / 'REGISTRIES/mission_build_u44.json').read_text(encoding='utf-8'))
    opmap = UB.load_opcode_profile((ROOT / 'repos/toolchains/de-luau-toolchain/src/de_opcode_profile.h').read_text())
    if args.out.resolve() == (EDITOR / 'REGISTRIES/mission_build_u44.json').resolve():
        raise SystemExit('rebase never writes the repository registry; stage it and adopt it after review')
    rb = Rebase(registry, args.old, args.new, opmap, build=args.build, build_label=args.build_label or registry['build_label'],
                packages_bin_sha256=args.packages_bin_sha256, corpus_rel=args.corpus_rel)
    new, decisions, absent = rb.run()
    args.out.write_bytes(dump(new))
    args.decisions.write_text(json.dumps({'format': FORMAT, 'decisions': decisions, 'absent': absent}, indent=1), encoding='utf-8')
