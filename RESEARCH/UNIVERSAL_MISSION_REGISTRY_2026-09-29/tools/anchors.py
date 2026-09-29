"""Read-only DE Luau (09 03) constant/owner analysis for exact registry anchors (Phase 2d; offline only).

Adds three things on top of deluau.Module:

* constant records with their file offsets (tag, payload offset, value), so a number constant can be
  pinned as an exact 8-byte `number_constant` site;
* a complete per-prototype constant-use census: every instruction K operand (LOADK/DUPTABLE/DUPCLOSURE/
  GETIMPORT Bx, arithmetic-K C/B, name aux, FASTCALL2K aux, fused compare aux with the constant bit,
  JUMPXEQKN/KS aux), every table-template key/value fixup, every import descriptor, plus a conservative
  "possible use" for any opcode whose operand semantics are not classified (fail closed);
* the K_CONSTANT_EXCLUSIVE_V1 gate: a number constant may be edited only when its complete use set equals
  the declared owner use set. For a root config table this means the value constant is used by exactly one
  entry of exactly one tag-8 template, that template is consumed by exactly one DUPTABLE, the DUPTABLE is
  not inside a loop, and the constructing prototype does not overwrite the field before the register is
  reassigned (a dead stock initialiser is rejected).

Opcode semantics come from repos/toolchains/de-luau-toolchain/OPCODE_MAP.md (canonical DE 09 03 bytes after
the pinned U44 dispatch normalisation). Nothing here writes files.
"""
from pathlib import Path
import struct, sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from deluau import Module, F, P, LOADN, SETTABLEKS  # noqa: E402

vi = P.vi
GATE = 'K_CONSTANT_EXCLUSIVE_V1'

NAMES = {0x00: 'MODR', 0x01: 'GETTABLE', 0x02: 'SETGLOBAL', 0x04: 'LOADB', 0x06: 'SUBRK', 0x07: 'SUB', 0x08: 'POWK',
         0x09: 'MULK', 0x0a: 'FORNLOOP', 0x0c: 'FASTCALL2K', 0x0d: 'LOADNIL', 0x0e: 'MINUS', 0x10: 'FASTCALL',
         0x11: 'PREPVARARGS', 0x12: 'LOADN', 0x13: 'GETUPVAL', 0x14: 'MOVE', 0x15: 'SETTABLEKS', 0x16: 'NEWCLOSURE',
         0x17: 'GETGLOBAL', 0x18: 'JUMPIFNOT', 0x19: 'FASTCALL1', 0x1a: 'DIV', 0x1b: 'FORGPREP_INEXT', 0x1c: 'JUMPIFNOTLT',
         0x1e: 'FORGLOOP', 0x20: 'JUMPXEQKN', 0x21: 'JUMPIFLT', 0x22: 'MUL', 0x23: 'JUMPIFLE', 0x24: 'IDIVK',
         0x25: 'JUMPBACK', 0x26: 'FASTCALL2', 0x27: 'JUMPIFNOTEQ', 0x28: 'CONCAT', 0x29: 'RETURN', 0x2a: 'SETTABLE',
         0x2b: 'OR', 0x2c: 'NEWTABLE', 0x2d: 'NAMECALL', 0x2e: 'SETTABLEN', 0x2f: 'AND', 0x30: 'FORGPREP', 0x31: 'ANDK',
         0x32: 'DIVK', 0x33: 'JUMPIFNOTLE', 0x34: 'JUMPXEQKB', 0x35: 'CAPTURE', 0x37: 'JUMPIFEQ', 0x38: 'ADDK',
         0x39: 'CLOSEUPVALS', 0x3a: 'JUMPXEQKNIL', 0x3b: 'DIVRK', 0x3c: 'MODK', 0x3d: 'GETTABLEKS', 0x3e: 'SUBK',
         0x3f: 'SETLIST', 0x40: 'JUMP', 0x41: 'JUMPXEQKS', 0x42: 'DUPCLOSURE', 0x44: 'GETTABLEN', 0x45: 'POW',
         0x46: 'GETIMPORT', 0x47: 'FORNPREP', 0x49: 'ADD', 0x4b: 'JUMPIF', 0x4c: 'GETVARARGS', 0x4d: 'LENGTH',
         0x4e: 'LOADK', 0x4f: 'DUPTABLE', 0x50: 'NOT', 0x51: 'TESTSET', 0x53: 'SETUPVAL', 0x54: 'CALL', 0x55: 'MOD'}
K_BX = {0x4e, 0x4f, 0x42, 0x46}
K_C = {0x38, 0x09, 0x32, 0x3c, 0x08, 0x24, 0x3e, 0x31}
K_B = {0x06, 0x3b}
K_AUX = {0x02, 0x15, 0x17, 0x3d, 0x2d, 0x0c}
K_AUX_FLAG = {0x1c, 0x21, 0x23, 0x27, 0x33, 0x37}   # constant rhs when aux bit31 is set
K_AUX_MASK = {0x20, 0x41}                           # K[aux & 0xffffff]; bit31 = polarity
NO_K = {0x00, 0x01, 0x04, 0x07, 0x0a, 0x0d, 0x0e, 0x10, 0x11, 0x12, 0x13, 0x14, 0x16, 0x18, 0x19, 0x1a, 0x1b, 0x22,
        0x25, 0x28, 0x29, 0x2a, 0x2b, 0x2e, 0x2f, 0x30, 0x35, 0x39, 0x40, 0x44, 0x45, 0x47, 0x49, 0x4b, 0x4c, 0x4d,
        0x50, 0x51, 0x53, 0x54, 0x55, 0x1e, 0x26, 0x2c, 0x34, 0x3a, 0x3f}
BRANCH = {0x18, 0x4b, 0x40, 0x25, 0x1c, 0x21, 0x23, 0x27, 0x33, 0x37, 0x20, 0x41, 0x34, 0x3a, 0x47, 0x0a, 0x30, 0x1b, 0x1e}
# Ops whose A operand is not a destination register (stores, branches, calls handled separately, returns).
A_NOT_WRITTEN = {0x02, 0x15, 0x2a, 0x2e, 0x53, 0x29, 0x35, 0x39, 0x3f, 0x10, 0x19, 0x26, 0x0c, 0x4a} | BRANCH


class Analysis(Module):
    """Module plus constant offsets and the constant-use census."""

    def __init__(self, raw):
        super().__init__(raw)
        info, entries = F.load_flat(self.canonical)
        if info.get('main_idx') != self.root:
            raise ValueError(f'main prototype index {info.get("main_idx")} is not the last prototype {self.root}')
        self.const_records = []
        for header, *_ in entries:
            co, ln, _ = F.header_at(self.canonical, header)
            self.const_records.append(self._const_offsets(co + ln))
        for p, (ins, consts) in enumerate(self.protos):
            assert len(self.const_records[p]) == len(consts), p

    def _const_offsets(self, o):
        b = self.canonical
        sizek, o = vi(b, o)
        out = []
        for _ in range(sizek):
            tag = b[o]
            start = o + 1
            o = start
            if tag == 3 or tag == 6:
                _, o = vi(b, o)
            elif tag in (1, 4):
                o += 4
            elif tag == 2:
                o += 8
            elif tag == 7:
                o += 16
            elif tag == 5:
                n, o = vi(b, o)
                for _ in range(n):
                    _, o = vi(b, o)
            elif tag == 8:
                n, o = vi(b, o)
                for _ in range(n):
                    _, o = vi(b, o)
                    o += 4
            elif tag == 9:
                o += 1
                _, o = vi(b, o)
            elif tag != 0:
                raise ValueError(f'invalid constant tag {tag}')
            out.append((tag, start))
        return out

    # ------------------------------------------------------------------ helpers
    def number(self, proto, k):
        tag, payload = self.protos[proto][1][k]
        return struct.unpack('<d', payload)[0] if tag == 2 else None

    def string(self, proto, k):
        c = self.protos[proto][1][k]
        return self.pool[c[1] - 1].decode('utf-8', 'replace') if c[0] == 'str' else None

    def constant_offset(self, proto, k):
        tag, start = self.const_records[proto][k]
        if tag != 2 or self.raw[start - 1] != 2:
            raise ValueError(f'constant {k} of prototype {proto} is not a native number constant')
        return start

    def template(self, proto, t):
        """[(key_const, key_string, value_const_or_None)] for a tag-8 template."""
        tag, items = self.protos[proto][1][t]
        if tag != 8:
            raise ValueError(f'constant {t} of prototype {proto} is not a tag-8 table template')
        consts = self.protos[proto][1]
        out = []
        for key, fix in items:
            v = struct.unpack('<I', fix)[0]
            out.append((key, self.string(proto, key), v if v < len(consts) else None))
        return out

    @staticmethod
    def aux(word):
        return struct.unpack_from('<I', word, 4)[0] if len(word) == 8 else None

    # ------------------------------------------------------------------ census
    def uses(self, proto):
        """{constant index: [use, ...]} over every instruction and constant of one prototype."""
        ins, consts = self.protos[proto]
        out = {}

        def add(k, use):
            out.setdefault(k, []).append(use)

        for i, (_, w) in enumerate(ins):
            op = w[0]
            bx = w[2] | (w[3] << 8)
            if op in K_BX:
                add(bx, ('ins', i, NAMES[op], 'Bx'))
            elif op in K_C:
                add(w[3], ('ins', i, NAMES[op], 'C'))
            elif op in K_B:
                add(w[2], ('ins', i, NAMES[op], 'B'))
            elif op in K_AUX:
                add(self.aux(w), ('ins', i, NAMES[op], 'aux'))
            elif op in K_AUX_FLAG:
                a = self.aux(w)
                if a & 0x80000000:
                    add(a & 0x7fffffff, ('ins', i, NAMES[op], 'auxK'))
            elif op in K_AUX_MASK:
                a = self.aux(w)
                if a & 0x7f000000:
                    for k in {a & 0x7fffffff, a & 0xffffff}:
                        add(k, ('possible', i, NAMES[op], 'aux-unclassified'))
                else:
                    add(a & 0xffffff, ('ins', i, NAMES[op], 'auxK'))
            elif op not in NO_K:
                # Unclassified operand semantics: every field that could be a constant index is a possible use.
                cands = {w[2], w[3], bx}
                if len(w) == 8:
                    a = self.aux(w)
                    cands |= {a, a & 0xffffff, a & 0x3ff, (a >> 10) & 0x3ff, (a >> 20) & 0x3ff}
                for k in cands:
                    add(k, ('possible', i, f'op_{op:02x}', 'unclassified'))
        for t, c in enumerate(consts):
            if c[0] == 8:
                for e, (key, fix) in enumerate(c[1]):
                    add(key, ('template-key', t, e))
                    v = struct.unpack('<I', fix)[0]
                    if v < len(consts):
                        add(v, ('template-value', t, e, self.string(proto, key)))
            elif c[0] == 5:
                for e, key in enumerate(c[1]):
                    add(key, ('template-key', t, e))
            elif c[0] == 4:
                d = struct.unpack('<I', c[1])[0]
                n = d >> 30
                for j in range(n):
                    add((d >> (20 - 10 * j)) & 0x3ff, ('import', t, j))
        return out

    def loops(self, proto):
        """[(target, source)] for every backward branch."""
        ins = self.protos[proto][0]
        index = {off: i for i, (off, _) in enumerate(ins)}
        out = []
        for i, (off, w) in enumerate(ins):
            if w[0] in BRANCH:
                d = struct.unpack_from('<h', w, 2)[0]
                target = index.get(off + 4 + d * 4)
                if target is not None and target <= i:
                    out.append((target, i))
        return out

    # ------------------------------------------------------------------ gates
    def exclusive_constant(self, proto, k, declared):
        """K_CONSTANT_EXCLUSIVE_V1 for an instruction-used number constant: the complete use set equals `declared`
        (a list of instruction indices). Returns gate evidence or raises with the exact reason."""
        if self.number(proto, k) is None:
            raise ValueError(f'constant {k} of prototype {proto} is not a number')
        uses = self.uses(proto).get(k, [])
        possible = [u for u in uses if u[0] == 'possible']
        if possible:
            raise ValueError(f'constant {k} has unclassified possible uses {possible}')
        got = sorted(u[1] for u in uses if u[0] == 'ins')
        other = [u for u in uses if u[0] != 'ins']
        if other or got != sorted(declared):
            raise ValueError(f'constant {k} use set {uses} != declared instructions {sorted(declared)}')
        return {'gate': GATE, 'prototype': proto, 'constant': k,
                'uses': [{'instruction': u[1], 'op': u[2], 'operand': u[3]} for u in sorted(uses, key=lambda u: u[1])]}

    def template_field(self, proto, t, field):
        """K_CONSTANT_EXCLUSIVE_V1 for a root/config table template field (single-use template gate)."""
        entries = [(e, v) for e, (_, key, v) in enumerate(self.template(proto, t)) if key == field]
        if len(entries) != 1 or entries[0][1] is None:
            raise ValueError(f'template {t} has {len(entries)} valued entries for {field}')
        e, v = entries[0]
        if self.number(proto, v) is None:
            raise ValueError(f'template {t}.{field} value constant {v} is not a number')
        census = self.uses(proto)
        vuses = census.get(v, [])
        if vuses != [('template-value', t, e, field)]:
            raise ValueError(f'value constant {v} of {field} is shared: {vuses}')
        tuses = census.get(t, [])
        dups = [u for u in tuses if u[0] == 'ins' and u[2] == 'DUPTABLE']
        if len(dups) != 1 or len(tuses) != 1:
            raise ValueError(f'template {t} is consumed by {len(dups)} DUPTABLE sites and {len(tuses) - len(dups)} other uses')
        d = dups[0][1]
        covering = [l for l in self.loops(proto) if l[0] <= d <= l[1]]
        if covering:
            raise ValueError(f'DUPTABLE {d} is inside a loop {covering}; one template would build several tables')
        ins = self.protos[proto][0]
        reg = ins[d][1][1]
        dead = None
        for i in range(d + 1, len(ins)):
            w = ins[i][1]
            if w[0] == SETTABLEKS and w[2] == reg and self.key_string(proto, w) == field:
                dead = i
                break
            if w[0] not in A_NOT_WRITTEN and w[1] == reg:
                break
            if w[0] in BRANCH:
                break  # stop at the first control-flow split; later writes are variant logic, not the initialiser
        if dead is not None:
            raise ValueError(f'{field} is overwritten by SETTABLEKS at instruction {dead} before the register is reassigned')
        return v, {'gate': GATE, 'prototype': proto, 'constant': v,
                   'uses': [{'template': t, 'entry': e, 'field': field}],
                   'template_uses': [{'instruction': d, 'op': 'DUPTABLE', 'register': reg}],
                   'loop_free': True, 'initialiser_live': True}

    def templates_with(self, field):
        """Every (proto, template, entry value const) whose tag-8 template has `field`."""
        out = []
        for p, (_, consts) in enumerate(self.protos):
            for t, c in enumerate(consts):
                if c[0] == 8:
                    for _, key, v in self.template(p, t):
                        if key == field:
                            out.append((p, t, v))
        return out

    def duptable_register(self, proto, t):
        ins = self.protos[proto][0]
        return [(i, w[1]) for i, (_, w) in enumerate(ins) if w[0] == 0x4f and (w[2] | (w[3] << 8)) == t]

    # ------------------------------------------------------------------ exploration (not used by the registrar)
    def dis(self, proto, lo=0, hi=None):
        ins, consts = self.protos[proto]
        lines = []
        for i, (off, w) in enumerate(ins[lo:hi], lo):
            op = w[0]
            name = NAMES.get(op, f'op_{op:02x}')
            a, b, c = w[1], w[2], w[3]
            bx = b | (c << 8)
            note = ''
            if op == LOADN:
                note = str(struct.unpack_from('<h', w, 2)[0])
            elif op in K_BX:
                note = self.describe(proto, bx)
            elif op in K_C:
                note = f'R{b} , K{c}={self.describe(proto, c)}'
            elif op in K_B:
                note = f'K{b}={self.describe(proto, b)} , R{c}'
            elif op in K_AUX:
                note = f'R{b} [{self.describe(proto, self.aux(w))}]'
            elif op in K_AUX_FLAG | K_AUX_MASK:
                x = self.aux(w)
                note = f'd={struct.unpack_from("<h", w, 2)[0]} ' + (self.describe(proto, x & 0xffffff) if (x & 0x80000000 or op in K_AUX_MASK) else f'R{x}')
            elif op in BRANCH:
                note = f'd={struct.unpack_from("<h", w, 2)[0]}'
            lines.append(f'{i:5d} @{off:6d} {name:12s} A={a:3d} B={b:3d} C={c:3d} {note}')
        return '\n'.join(lines)

    def describe(self, proto, k):
        consts = self.protos[proto][1]
        if k is None or k >= len(consts):
            return f'?{k}'
        c = consts[k]
        if c[0] == 'str':
            return repr(self.string(proto, k))
        if c[0] == 2:
            return f'{self.number(proto, k):g}'
        if c[0] == 8:
            return 'T{' + ', '.join(f'{key}={self.describe(proto, v) if v is not None else "nil"}' for _, key, v in self.template(proto, k)) + '}'
        if c[0] == 1:
            return f'#{struct.unpack("<I", c[1])[0]:08x}'
        return f'<{c[0]}>'


if __name__ == '__main__':
    # Exploration: python anchors.py <stock file> <proto> [lo hi]
    from deluau import ROOT
    stock = ROOT / 'work/research/universal-mission-editor-2026-09-29/stock'
    m = Analysis((stock / sys.argv[1]).read_bytes())
    p = m.root if sys.argv[2] == 'root' else int(sys.argv[2])
    lo = int(sys.argv[3]) if len(sys.argv) > 3 else 0
    hi = int(sys.argv[4]) if len(sys.argv) > 4 else None
    print(m.dis(p, lo, hi))
