"""Phase 2e root-table field owners for the target-addon lane (offline, read-only).

A root config table field does not need a byte patch: the proven target-addon lane (``luaCalls[P].before``) can write
the field on the live table once, check the stock value first, and restore it in cleanup (the Survival preset has
done this since 2026-09-09). Because the addon writes the *table field*, constant sharing in the bytecode is
irrelevant: every field is an independent control.

Gate ``ROOT_TABLE_UPVALUE_V1`` (all conditions must hold on the pinned 44.0.2 bytes):

1. The table is built by the module root prototype, exactly once and outside any loop, either by ``DUPTABLE`` of a
   tag-8 template whose ``field`` entry is a number constant equal to the stock value, or by ``NEWTABLE`` followed by
   exactly one ``SETTABLEKS field`` whose value register was last loaded by ``LOADN``/``LOADK`` of the stock number.
   The root never writes the field again (no dead initialiser) and never reads it (a root read happens at module load,
   before any hook can run).
2. The table does not escape the root other than by closure capture: until the register is reassigned, the root uses
   it only as the table operand of stores (``SETTABLEKS``/``SETTABLEN``/``SETTABLE``/``SETLIST``), as the source of
   ``GETTABLEKS`` reads of *other* fields, and in ``CAPTURE VAL/REF``. Any other use (MOVE, call argument, method
   call, global/table store, return) fails. A ``REF`` capture additionally requires that the root never reassigns
   the register.
3. Every capturing prototype is created exactly once in the module, by the root. Every one of them is hooked
   (``before``), so no code that can reach the table runs before the write. No capturer, and no closure nested in a
   capturer that re-captures the upvalue, executes ``SETUPVAL`` on it (the table identity is fixed).
4. At least one capturer (or a nested re-capture) reads the field through the upvalue (the field is consumed).

The evidence is recorded per row and pinned by the module SHA-256. Nothing here writes files outside a temp folder.
"""
from pathlib import Path
import struct, subprocess, sys, tempfile

sys.path.insert(0, str(Path(__file__).resolve().parent))
from anchors import Analysis, A_NOT_WRITTEN, BRANCH  # noqa: E402
from deluau import ROOT  # noqa: E402

GATE = 'ROOT_TABLE_UPVALUE_V1'
DERECOMP = ROOT / 'repos/toolchains/de-luau-toolchain/bin/derecomp.exe'
LOADN, LOADK, NEWTABLE, DUPTABLE, SETTABLEKS, GETTABLEKS = 0x12, 0x4e, 0x2c, 0x4f, 0x15, 0x3d
SETTABLE, SETTABLEN, SETLIST, CAPTURE, GETUPVAL, SETUPVAL = 0x2a, 0x2e, 0x3f, 0x35, 0x13, 0x53
NEWCLOSURE, DUPCLOSURE, GETTABLEN = 0x16, 0x42, 0x44
NO_READS = {0x04, 0x0d, 0x12, 0x4e, 0x46, 0x17, 0x13, 0x2c, 0x4f, 0x16, 0x42, 0x11, 0x4c, 0x40, 0x25, 0x39, 0x10}


def reads(w):
    """Registers read by one canonical instruction, or None when the operand semantics are not classified."""
    op, a, b, c = w[0], w[1], w[2], w[3]
    if op in NO_READS:
        return set()
    if op in (0x14, 0x0e, 0x50, 0x4d, 0x44, 0x3d, 0x2d, 0x19, 0x0c):   # MOVE MINUS NOT LENGTH GETTABLEN GETTABLEKS NAMECALL FASTCALL1/2K
        return {b}
    if op in (0x38, 0x09, 0x32, 0x3c, 0x08, 0x24, 0x31, 0x3e):         # arithmetic-K
        return {b}
    if op in (0x06, 0x3b):                                             # SUBRK DIVRK
        return {c}
    if op in (0x49, 0x07, 0x22, 0x1a, 0x55, 0x45, 0x01, 0x2b, 0x2f, 0x00):  # reg-reg arithmetic, GETTABLE, OR, AND
        return {b, c}
    if op in (0x15, 0x2e):                                             # SETTABLEKS SETTABLEN: value A, table B
        return {a, b}
    if op == 0x2a:                                                     # SETTABLE
        return {a, b, c}
    if op in (0x02, 0x53, 0x18, 0x4b, 0x20, 0x41, 0x34, 0x3a):         # SETGLOBAL SETUPVAL JUMPIF(NOT) JUMPXEQK*
        return {a}
    if op in (0x37, 0x27, 0x21, 0x1c, 0x23, 0x33):                     # fused compares: rhs register unless bit31
        aux = struct.unpack_from('<I', w, 4)[0]
        return {a} if aux & 0x80000000 else {a, aux & 0xff}
    if op == 0x26:                                                     # FASTCALL2: B and aux register
        return {b, struct.unpack_from('<I', w, 4)[0] & 0xff}
    if op == 0x54:                                                     # CALL A B: function + args
        return None if b == 0 else set(range(a, a + b))
    if op == 0x29:                                                     # RETURN A B
        return None if b == 0 else set(range(a, a + b - 1))
    if op == 0x28:                                                     # CONCAT A B C
        return set(range(b, c + 1))
    if op == 0x3f:                                                     # SETLIST A B C
        return None if c == 0 else {a} | set(range(b, b + c - 1))
    if op == 0x35:                                                     # CAPTURE type, source
        return {b} if a in (0, 1) else set()
    if op in (0x47, 0x0a):                                             # FORNPREP FORNLOOP
        return {a, a + 1, a + 2}
    if op in (0x30, 0x1b, 0x1e):                                       # generic for
        return {a, a + 1, a + 2}
    if op == 0x51:                                                     # TESTSET
        return {b}
    return None


def writes(w, reg):
    """True when the instruction (re)assigns register ``reg``."""
    op = w[0]
    if op == 0x54:                                  # CALL A B C: results R[A .. A+C-2]; C == 0 = open range
        return reg >= w[1] if w[3] == 0 else w[1] <= reg <= w[1] + w[3] - 2
    if op == 0x2d:                                  # NAMECALL writes A (method) and A+1 (self)
        return reg in (w[1], w[1] + 1)
    if op == 0x4c:                                  # GETVARARGS
        return reg >= w[1]
    return op not in A_NOT_WRITTEN and w[1] == reg


def closure_map(m):
    """[(parent, instruction, target, {capture_index0: (mode, source)})] from the toolchain closure-map contract."""
    with tempfile.TemporaryDirectory() as tmp:
        canon, out = Path(tmp) / 'module.canonical', Path(tmp) / 'closures.tsv'
        canon.write_bytes(m.canonical)
        run = subprocess.run([str(DERECOMP), 'closure-map', str(canon), str(out)], capture_output=True, text=True)
        if run.returncode != 0 or 'failures=0' not in run.stdout:
            raise ValueError('closure-map failed: ' + run.stdout + run.stderr)
        lines = [l.split('\t') for l in out.read_text().splitlines()]
    head = lines[0]
    sites = []
    for l in lines[1:]:
        d = dict(zip(head, l))
        caps = {}
        if d['captures']:
            for c in d['captures'].split(';'):
                k, v = c.split('=', 1)
                mode, src = v.split(':')
                caps[int(k)] = (mode, src)
        sites.append((int(d['parent_proto']), int(d['instruction']), int(d['target_proto']), caps))
    return sites


class RootTables(Analysis):
    def __init__(self, raw):
        super().__init__(raw)
        self._sites = None
        self._loops = self.loops(self.root)

    @property
    def sites(self):
        if self._sites is None:
            self._sites = closure_map(self)
        return self._sites

    def in_loop(self, i):
        return any(lo <= i <= hi for lo, hi in self._loops)

    def constructions(self, field, stock):
        """Root sites that build a table holding ``field`` = ``stock``: [(instruction, register, detail)]."""
        ins, consts = self.protos[self.root]
        out = []
        for i, (off, w) in enumerate(ins):
            if w[0] == DUPTABLE:
                t = w[2] | (w[3] << 8)
                if consts[t][0] != 8:
                    continue
                for e, (_, key, v) in enumerate(self.template(self.root, t)):
                    if key == field and v is not None and self.number(self.root, v) == stock:
                        out.append((i, w[1], {'op': 'DUPTABLE', 'template': t, 'entry': e, 'value_constant': v,
                                              'value_kind': 'number_constant',
                                              'value_offset': self.constant_offset(self.root, v)}))
            elif w[0] == SETTABLEKS and self.key_string(self.root, w) == field:
                val, tab = w[1], w[2]
                j = i - 1
                while j >= 0 and not writes(ins[j][1], val):
                    j -= 1
                if j < 0:
                    continue
                lw = ins[j][1]
                num = struct.unpack_from('<h', lw, 2)[0] if lw[0] == LOADN else (
                    self.number(self.root, lw[2] | (lw[3] << 8)) if lw[0] == LOADK else None)
                if num != stock:
                    continue
                k = i - 1
                while k >= 0 and not writes(ins[k][1], tab):
                    k -= 1
                if k >= 0 and ins[k][1][0] in (NEWTABLE, DUPTABLE):
                    detail = {'op': 'NEWTABLE+SETTABLEKS' if ins[k][1][0] == NEWTABLE else 'DUPTABLE+SETTABLEKS',
                              'table_instruction': k, 'store_instruction': i, 'value_instruction': j,
                              'value_op': 'LOADN' if lw[0] == LOADN else 'LOADK', 'value_kind': 'instruction',
                              'value_offset': ins[j][0]}
                    if lw[0] == LOADK:
                        detail['value_constant'] = lw[2] | (lw[3] << 8)
                        detail['value_kind'] = 'number_constant'
                        detail['value_offset'] = self.constant_offset(self.root, detail['value_constant'])
                    out.append((k, tab, detail))
        return out

    def owner(self, field, stock, table_instruction=None):
        """Gate ROOT_TABLE_UPVALUE_V1 for one field; returns the evidence or raises with the exact reason."""
        cands = self.constructions(field, stock)
        if table_instruction is not None:
            cands = [c for c in cands if c[0] == table_instruction]
        if len(cands) != 1:
            raise ValueError(f'{len(cands)} root tables hold {field}={stock:g}; the table owner is not unique '
                             f'({[c[0] for c in cands]})')
        d, reg, detail = cands[0]
        return self._gate(d, reg, field, stock, detail)

    def element_owner(self, value_instruction, stock):
        """Gate for one array element of a root table built by NEWTABLE + SETLIST (key = one-based array index)."""
        ins = self.protos[self.root][0]
        lw = ins[value_instruction][1]
        if lw[0] not in (LOADN, LOADK):
            raise ValueError(f'root instruction {value_instruction} is not a LOADN/LOADK element value')
        vreg = lw[1]
        for j in range(value_instruction + 1, len(ins)):
            w = ins[j][1]
            if w[0] == SETLIST and w[3] != 0 and w[2] <= vreg < w[2] + w[3] - 1:
                treg, index = w[1], struct.unpack_from('<I', w, 4)[0] + vreg - w[2]
                d = j - 1
                while d >= 0 and not writes(ins[d][1], treg):
                    d -= 1
                if d < 0 or ins[d][1][0] != NEWTABLE:
                    raise ValueError('array is not built by NEWTABLE in the root')
                detail = {'op': 'NEWTABLE+SETLIST', 'store_instruction': j, 'value_instruction': value_instruction,
                          'value_op': 'LOADN' if lw[0] == LOADN else 'LOADK'}
                if lw[0] == LOADN:
                    detail.update(value_kind='instruction', value_offset=ins[value_instruction][0])
                else:
                    k = lw[2] | (lw[3] << 8)
                    detail.update(value_kind='number_constant', value_constant=k, value_offset=self.constant_offset(self.root, k))
                return self._gate(d, treg, index, stock, detail)
            r = reads(w)
            if writes(w, vreg) or vreg in (r if r is not None else {vreg}):
                break
        raise ValueError(f'root instruction {value_instruction} is not stored into a table field or array element '
                         '(root local or call argument); it stays on the literal lane')

    def _gate(self, d, reg, field, stock, detail):
        if self.in_loop(d) or ('store_instruction' in detail and self.in_loop(detail['store_instruction'])):
            raise ValueError(f'table construction at root instruction {d} is inside a loop')
        hooks, chain = self._table(d, reg, field, detail.get('store_instruction'), [])
        reads_field = 0
        for h in hooks:
            reads_field += self._consumer(h['prototype'], h['upvalue'] - 1, (h['path'] + [field])[0], set())
        if reads_field == 0:
            raise ValueError(f'no capturer reads {field} through the captured upvalue')
        hooks.sort(key=lambda h: (h['prototype'], h['upvalue']))
        if len({h['prototype'] for h in hooks}) != len(hooks):
            raise ValueError('one prototype captures the table twice')
        return {'gate': GATE, 'construction': dict(detail, prototype=self.root, instruction=d, register=reg),
                'field': field, 'stock': stock, 'hooks': hooks, 'field_reads': reads_field, 'containers': chain,
                'table_id': f'root:i{d}:R{reg}'}

    def _table(self, d, reg, key, skip, chain):
        """Uses of the root table built at ``d`` in ``reg`` whose owned entry is ``key`` (a field name, or the child key
        when this table is a container). Returns (hooks with paths, container chain)."""
        ins = self.protos[self.root][0]
        captures, parents, end, ref = [], [], len(ins), False
        for i in range(d + 1, len(ins)):
            w = ins[i][1]
            if i == skip:
                continue
            r = reads(w)
            if r is None:
                if reg >= w[1] and w[0] in (0x54, 0x29, 0x3f):
                    raise ValueError(f'root instruction {i} ({w[0]:#04x}) may use the table register R{reg} (open range)')
                r = {w[1], w[2], w[3]}
            if reg in r:
                op = w[0]
                if op in (SETTABLEKS, SETTABLEN) and w[1] == reg and w[2] != reg:
                    parents.append(i)                    # the table is stored into another table (nested config)
                elif op == SETLIST and w[1] != reg and w[2] <= reg < w[2] + w[3] - 1:
                    parents.append(i)                    # array element of another table
                elif op == SETTABLEKS and w[2] == reg:
                    if self.key_string(self.root, w) == key:
                        raise ValueError(f'root instruction {i} writes {key} again after construction (dead initialiser)')
                elif op == SETTABLEN and w[2] == reg:
                    if w[3] + 1 == key:
                        raise ValueError(f'root instruction {i} writes [{key}] again after construction')
                elif op == SETTABLE and w[2] == reg and w[1] != reg and w[3] != reg:
                    raise ValueError(f'root instruction {i} stores a dynamic key into the table (may be {key})')
                elif op == SETLIST and w[1] == reg and not (w[2] <= reg < w[2] + w[3] - 1):
                    if isinstance(key, int):
                        raise ValueError(f'root instruction {i} fills the array part of a container')
                elif op == GETTABLEKS and w[2] == reg:
                    if self.key_string(self.root, w) == key:
                        raise ValueError(f'root instruction {i} reads {key} at module load, before any hook can run')
                elif op == GETTABLEN and w[2] == reg:
                    if w[3] + 1 == key:
                        raise ValueError(f'root instruction {i} reads [{key}] at module load, before any hook can run')
                elif op == CAPTURE and w[1] in (0, 1):
                    captures.append(i)
                    ref |= w[1] == 1
                else:
                    raise ValueError(f'root instruction {i} ({op:#04x}) lets the table escape other than by capture')
            if writes(w, reg):
                end = i
                break
        if ref and end != len(ins):
            raise ValueError(f'REF-captured register R{reg} is reassigned at root instruction {end}')
        hooks = []
        for ci in captures:
            k = ci                                       # CAPTUREs follow their NEWCLOSURE; closure-map names that instruction
            while ins[k][1][0] == CAPTURE:
                k -= 1
            site = [s for s in self.sites if s[0] == self.root and s[1] == k]
            if len(site) != 1:
                raise ValueError(f'closure at root instruction {k} not in the closure map')
            _, _, target, caps = site[0]
            idx = [n for n, (mode, src) in caps.items() if src == f'R{reg}' and mode in ('VAL', 'REF')]
            if len(idx) != 1:
                raise ValueError(f'closure {target} captures R{reg} {len(idx)} times')
            created = [s for s in self.sites if s[2] == target]
            if len(created) != 1:
                raise ValueError(f'capturing prototype {target} is created {len(created)} times; its upvalue is not one table')
            hooks.append({'prototype': target, 'upvalue': idx[0] + 1, 'capture': f'{caps[idx[0]][0]}:R{reg}',
                          'closure_instruction': k, 'path': []})
        if len(parents) > 1:
            raise ValueError(f'the table is stored into {len(parents)} other tables')
        if parents:
            i = parents[0]
            if self.in_loop(i):
                raise ValueError(f'nested store at root instruction {i} is inside a loop')
            w = ins[i][1]
            if w[0] == SETLIST:
                child_key, preg = struct.unpack_from('<I', w, 4)[0] + reg - w[2], w[1]
            else:
                child_key, preg = (self.key_string(self.root, w) if w[0] == SETTABLEKS else w[3] + 1), w[2]
            pd = i - 1
            while pd >= 0 and not writes(ins[pd][1], preg):
                pd -= 1
            if pd < 0 or ins[pd][1][0] not in (NEWTABLE, DUPTABLE) or self.in_loop(pd):
                raise ValueError(f'container of the table (R{preg}) is not built once by NEWTABLE/DUPTABLE in the root')
            chain = chain + [{'instruction': pd, 'register': preg, 'store_instruction': i, 'key': child_key}]
            parent_hooks, chain = self._table(pd, preg, child_key, i, chain)
            hooks += [dict(h, path=[child_key] + h['path']) for h in parent_hooks]
        if not hooks:
            raise ValueError('the table is never captured by a closure; no consumer prototype to hook')
        return hooks, chain

    def site_field(self, site, stock):
        """Root-table field owned by one registered literal site (Phase 2d), as addon evidence; raises when the site is
        not a numeric field of a root table (function literal, array element, library constant)."""
        if site['prototype'] != self.root:
            raise ValueError(f'site in prototype {site["prototype"]} is not a root table initialiser')
        ins = self.protos[self.root][0]
        if site['kind'] == 'number_constant':
            uses = site.get('gate', {}).get('uses', [])
            tuses = site.get('gate', {}).get('template_uses', [])
            if len(uses) == 1 and 'template' in uses[0] and len(tuses) == 1:
                return self.owner(uses[0]['field'], stock, tuses[0]['instruction'])
            if len(uses) == 1 and uses[0].get('op') == 'LOADK':
                i = uses[0]['instruction']
                reg = ins[i][1][1]
            else:
                raise ValueError('root constant is not a single table-template field or one LOADK element')
        else:
            i, reg = site['instruction'], site['register']
        for j in range(i + 1, len(ins)):
            w = ins[j][1]
            if w[0] == SETTABLEKS and w[1] == reg:
                field = self.key_string(self.root, w)
                cands = [c for c in self.constructions(field, stock) if c[2].get('value_instruction') == i]
                if len(cands) != 1:
                    raise ValueError(f'LOADN at root instruction {i} does not initialise one table field')
                return self.owner(field, stock, cands[0][0])
            if w[0] == SETLIST and w[2] <= reg < w[2] + w[3] - 1:
                return self.element_owner(i, stock)
            r = reads(w)
            if writes(w, reg) or reg in (r if r is not None else {reg}):
                break
        raise ValueError(f'root instruction {i} is not stored into a table field or array element (root local or call '
                         'argument); it stays on the literal lane')

    def _consumer(self, proto, up, key, seen):
        """Reads of ``key`` (field name or array index; a dynamic GETTABLE counts) through upvalue ``up`` of ``proto``
        and of nested re-captures; raises when any of them replaces the captured value (SETUPVAL)."""
        if (proto, up) in seen:
            return 0
        seen.add((proto, up))
        ins = self.protos[proto][0]
        count = 0
        holders = set()
        for i, (_, w) in enumerate(ins):
            if w[0] == SETUPVAL and w[2] == up:
                raise ValueError(f'prototype {proto} replaces the captured table (SETUPVAL {up})')
            if w[2] in holders and ((w[0] == GETTABLEKS and self.key_string(proto, w) == key) or
                                    (w[0] == GETTABLEN and w[3] + 1 == key) or w[0] == 0x01):
                count += 1
            holders = {r for r in holders if not writes(w, r)}
            if w[0] == GETUPVAL and w[2] == up:
                holders.add(w[1])
        for parent, _, target, caps in self.sites:
            if parent == proto:
                for n, (mode, src) in caps.items():
                    if mode == 'UPVAL' and src == f'U{up}':
                        count += self._consumer(target, n, key, seen)
        return count


if __name__ == '__main__':
    # Exploration: python addon_owner.py <stock file> field=stock [field=stock ...]
    stock = ROOT / 'work/research/universal-mission-editor-2026-09-29/stock'
    m = RootTables((stock / sys.argv[1]).read_bytes())
    for arg in sys.argv[2:]:
        f, v = arg.split('=')
        try:
            ev = m.owner(f, float(v))
            print('PASS', f, v, ev['table_id'], [(h['prototype'], h['upvalue'], *h['path']) for h in ev['hooks']], 'reads', ev['field_reads'])
        except ValueError as e:
            print('FAIL', f, v, e)
