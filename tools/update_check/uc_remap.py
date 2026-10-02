"""Update resilience step 2: map one DE Luau module of build A onto the same module of build B.

Read-only and self-contained (standard library + uc_bytecode). Used by the remap plan (uc_plan.py), the registry rebase
(registrar tools/rebase_registry.py), the replacement rebase and the authored-addon rebuild.

Matching, per module (same file name in both builds):

1. Module identity: same content key = unchanged (every index is kept as is); same file, other key = changed; no file =
   removed.
2. Prototypes of a changed module, in this order:
   a. exact: the step-1 fingerprint (header, size, canonical code, constants with strings resolved, closures as a marker)
      is equal and unique on both sides. Identical copies of one function are told apart by their creation site: the
      mapped parent and the position among that parent's children with the same fingerprint (a dead copy inserted by an
      update has no parent and does not match).
   b. similar: the remaining prototypes are scored (features below). A pair is mapped when it is the mutual best, its
      score is at least AUTO_SCORE and it leads the runner-up by at least AUTO_MARGIN (auto with a note).
   c. ambiguous: the best candidate scores at least REVIEW_SCORE but fails (b): proposed, not mapped (needs review).
   d. unmatched: nothing scores REVIEW_SCORE: the function was removed or rewritten (needs review).
   Features: parameter count, upvalue count, vararg flag, constant multiset (strings as text, numbers, native-name hashes,
   import paths, closure targets by fingerprint), NAMECALL method set, opcode histogram, CFG shape (branches, back edges,
   calls, returns), instruction count, child count, debug name (when present) and parent consistency with the map.
3. Instructions of a mapped prototype: identical prototypes map index to index. A similar prototype is aligned on
   instruction tokens (opcode, registers, resolved constants; branch offsets and child indices are left out because an
   insertion changes them) with difflib; equal runs map one to one ("equal") and a replaced run of the same length maps
   position by position ("modified": same place, different operands, e.g. a changed number).
4. Constants: identical prototypes keep indices; otherwise a constant maps through the aligned instruction that uses it,
   else through a unique equal value.
"""
from __future__ import annotations

import difflib
import struct
from collections import Counter, defaultdict
from dataclasses import dataclass, field

import uc_bytecode as B

AUTO_SCORE = 0.86
AUTO_MARGIN = 0.08
REVIEW_SCORE = 0.55

# Canonical opcode classes (registrar tools/anchors.py, same numbering). Kept here so the update tools stay standalone.
K_BX = {0x4e, 0x4f, 0x42, 0x46}                       # LOADK, DUPTABLE, DUPCLOSURE, GETIMPORT: constant in D
K_C = {0x38, 0x09, 0x32, 0x3c, 0x08, 0x24, 0x3e, 0x31}
K_B = {0x06, 0x3b}
K_AUX = {0x02, 0x15, 0x17, 0x3d, 0x2d, 0x0c}          # constant in the AUX word
K_AUX_FLAG = {0x1c, 0x21, 0x23, 0x27, 0x33, 0x37}     # AUX is a register, or a constant when bit 31 is set
K_AUX_MASK = {0x20, 0x41}                             # JUMPXEQKN/KS: K[aux & 0xffffff]
JUMP_D = {0x18, 0x4b, 0x40, 0x25, 0x1c, 0x21, 0x23, 0x27, 0x33, 0x37, 0x20, 0x41, 0x34, 0x3a, 0x47, 0x0a, 0x30,
          0x1b, 0x1e, 0x0b}
BACK = {0x25, 0x0a, 0x1e}
CALLS = {0x54, 0x2d}
FASTCALLS = {0x10, 0x19, 0x26, 0x0c}
OP_LOADN, OP_LOADK, OP_NEWCLOSURE, OP_DUPCLOSURE, OP_GETIMPORT, OP_DUPTABLE = 0x12, 0x4e, 0x16, 0x42, 0x46, 0x4f
OP_RETURN, OP_NAMECALL = 0x29, 0x2d


def _d(w: bytes) -> int:
    return struct.unpack_from('<h', w, 2)[0]


def _aux(w: bytes) -> int | None:
    return struct.unpack_from('<I', w, 4)[0] if len(w) == 8 else None


@dataclass
class ProtoMatch:
    a: int
    b: int | None
    kind: str            # exact | similar | ambiguous | unmatched
    score: float = 1.0
    runner_up: float = 0.0
    candidate: int | None = None   # proposed B prototype of an ambiguous match
    note: str = ''

    def as_json(self) -> dict:
        out = {'old': self.a, 'new': self.b, 'kind': self.kind, 'score': round(self.score, 3)}
        if self.kind != 'exact':
            out['runner_up'] = round(self.runner_up, 3)
        if self.candidate is not None:
            out['candidate'] = self.candidate
        if self.note:
            out['note'] = self.note
        return out


class Features:
    """Per-module prototype features (fingerprints, resolved constants, tokens)."""

    def __init__(self, m: B.Module):
        self.m = m
        self.fp = [m.fingerprint(p) for p in m.protos]
        self.parents = m.parents()
        self._consts: dict[int, list] = {}
        self._tokens: dict[int, list] = {}
        self._vec: dict[int, dict] = {}

    # resolved constant (a hashable, index-free value)
    def const(self, p: B.Proto, k: int, depth: int = 0):
        if not 0 <= k < len(p.consts):
            return ('?', k)
        c = p.consts[k]
        if c.tag == 3:
            return ('s', (self.m.string(c.value) or b'').decode('utf-8', 'replace'))
        if c.tag == 2:
            return ('n', c.value)
        if c.tag == 1:
            return ('h', c.value)
        if c.tag == 6:
            return ('c', self.fp[c.value] if 0 <= c.value < len(self.fp) else '?')
        if c.tag == 4:
            ids = [(c.value >> 20) & 1023, (c.value >> 10) & 1023, c.value & 1023][:c.value >> 30]
            return ('i', tuple(self.const(p, i, depth + 1) if depth < 2 else ('?', i) for i in ids))
        if c.tag == 5:
            return ('t', tuple(self.const(p, i, depth + 1) if depth < 2 else ('?', i) for i in c.value))
        if c.tag == 8:
            return ('T', tuple(self.const(p, i, depth + 1) if depth < 2 else ('?', i) for i, _ in c.value))
        return (str(c.tag), repr(c.value))

    def consts(self, p: B.Proto) -> list:
        if p.index not in self._consts:
            self._consts[p.index] = [self.const(p, k) for k in range(len(p.consts))]
        return self._consts[p.index]

    def token(self, p: B.Proto, logical: int):
        w = self.m.word(p, logical)
        op, a, b_, c = w[0], w[1], w[2], w[3]
        cs = self.consts(p)
        k = lambda i: cs[i] if 0 <= i < len(cs) else ('?', i)  # noqa: E731
        aux = _aux(w)
        if op == OP_NEWCLOSURE:
            d = _d(w) & 0xFFFF
            kid = p.kids[d] if d < len(p.kids) else None
            return (op, a, ('c', self.fp[kid] if kid is not None and kid < len(self.fp) else '?'))
        if op in K_AUX_MASK:
            return (op, a, k(aux & 0xFFFFFF), aux >> 31)
        if op in K_AUX_FLAG:
            return (op, a, k(aux & 0xFFFFFF) if aux >> 31 else ('r', aux))
        if op in JUMP_D:
            return (op, a) + ((aux,) if aux is not None else ())
        if op in K_BX:
            return (op, a, k(_d(w) & 0xFFFF))
        if op in K_AUX:
            if op == 0x3d or op == 0x15 or op == OP_NAMECALL:      # GETTABLEKS/SETTABLEKS/NAMECALL: C is a cache slot
                return (op, a, b_, k(aux))
            return (op, a, k(aux))
        if op in K_C:
            return (op, a, b_, k(c))
        if op in K_B:
            return (op, a, k(b_), c)
        if op == OP_LOADN:
            return (op, a, _d(w))
        if op in FASTCALLS:
            return (op, a)
        return (op, w[1:4]) + ((aux,) if aux is not None else ())

    def tokens(self, p: B.Proto) -> list:
        if p.index not in self._tokens:
            self._tokens[p.index] = [self.token(p, i) for i in range(len(p.instructions))]
        return self._tokens[p.index]

    def vector(self, p: B.Proto) -> dict:
        if p.index in self._vec:
            return self._vec[p.index]
        ops = Counter(op for _, _, op in p.instructions)
        methods = set()
        for i, (_, _, op) in enumerate(p.instructions):
            if op == OP_NAMECALL:
                methods.add(self.consts(p)[_aux(self.m.word(p, i))] if _aux(self.m.word(p, i)) < len(p.consts) else '?')
        cfg = (sum(ops[o] for o in JUMP_D), sum(ops[o] for o in BACK), sum(ops[o] for o in CALLS), ops[OP_RETURN])
        v = {'params': p.header[1], 'ups': p.header[2], 'vararg': p.header[3], 'n': len(p.instructions),
             'kids': len(p.kids), 'consts': Counter(self.consts(p)), 'methods': methods, 'ops': ops, 'cfg': cfg,
             'name': self.m.name(p)}
        self._vec[p.index] = v
        return v


def _jaccard_multiset(a: Counter, b: Counter) -> float:
    if not a and not b:
        return 1.0
    inter = sum((a & b).values())
    union = sum((a | b).values())
    return inter / union if union else 1.0


def _jaccard(a: set, b: set) -> float:
    if not a and not b:
        return 1.0
    return len(a & b) / len(a | b)


def similarity(va: dict, vb: dict, parent_ok: float) -> float:
    """0..1 similarity of two prototype feature vectors (see the module docstring)."""
    header = ((va['params'] == vb['params']) + (va['ups'] == vb['ups']) + (va['vararg'] == vb['vararg'])) / 3
    na, nb = va['n'], vb['n']
    l1 = sum(((va['ops'] - vb['ops']) + (vb['ops'] - va['ops'])).values())
    ops = 1 - l1 / (na + nb) if na + nb else 1.0
    cfg = 1 - sum(abs(x - y) for x, y in zip(va['cfg'], vb['cfg'])) / max(1, sum(va['cfg']) + sum(vb['cfg']))
    size = min(na, nb) / max(na, nb) if max(na, nb) else 1.0
    kids = 1.0 if va['kids'] == vb['kids'] else 0.5 if abs(va['kids'] - vb['kids']) <= 1 else 0.0
    score = (0.12 * header + 0.28 * _jaccard_multiset(va['consts'], vb['consts']) + 0.10 * _jaccard(va['methods'], vb['methods'])
             + 0.20 * ops + 0.06 * cfg + 0.06 * size + 0.06 * kids + 0.12 * parent_ok)
    if va['name'] and vb['name']:
        score = score * 0.85 + (0.15 if va['name'] == vb['name'] else 0.0)
    return score


@dataclass
class Alignment:
    pairs: dict = field(default_factory=dict)      # old logical -> (new logical, 'equal' | 'modified')
    ratio: float = 1.0


class ModuleMap:
    """The A -> B map of one module (see the module docstring)."""

    def __init__(self, ma: B.Module, mb: B.Module | None, file: str = ''):
        self.file = file
        self.ma, self.mb = ma, mb
        self.status = 'removed' if mb is None else ('unchanged' if ma.key == mb.key else 'changed')
        self.fa = Features(ma)
        self.fb = Features(mb) if mb is not None else None
        self.protos: dict[int, ProtoMatch] = {}
        self._align: dict[int, Alignment] = {}
        if self.status == 'unchanged':
            self.protos = {p.index: ProtoMatch(p.index, p.index, 'exact') for p in ma.protos}
        elif self.status == 'changed':
            self._match()
        else:
            self.protos = {p.index: ProtoMatch(p.index, None, 'unmatched', 0.0, note='module removed') for p in ma.protos}

    # -- prototype matching ------------------------------------------------------------------------------------------
    def _match(self) -> None:
        ma, mb, fa, fb = self.ma, self.mb, self.fa, self.fb
        mapped: dict[int, int] = {}
        taken: set[int] = set()

        def put(a, b, kind, score=1.0, runner=0.0, note=''):
            mapped[a] = b
            taken.add(b)
            self.protos[a] = ProtoMatch(a, b, kind, score, runner, note=note)

        ga, gb = defaultdict(list), defaultdict(list)
        for p in ma.protos:
            ga[fa.fp[p.index]].append(p.index)
        for p in mb.protos:
            gb[fb.fp[p.index]].append(p.index)
        for f, la in ga.items():
            lb = gb.get(f, [])
            if len(la) == 1 and len(lb) == 1:
                put(la[0], lb[0], 'exact')
        if ma.main_index not in mapped and mb.main_index not in taken:
            # the main chunk is the module root in both builds; scored below like any other changed prototype
            pass
        # identical copies: creation site (mapped parent, rank among that parent's same-fingerprint children)
        changed = True
        while changed:
            changed = False
            for f, la in ga.items():
                free_a = [a for a in la if a not in mapped]
                free_b = [b for b in gb.get(f, []) if b not in taken]
                if not free_a or not free_b:
                    continue
                for a in free_a:
                    pa = fa.parents[a]
                    if pa is None or pa not in mapped:
                        continue
                    sib_a = [k for k in ma.protos[pa].kids if fa.fp[k] == f]
                    sib_b = [k for k in mb.protos[mapped[pa]].kids if fb.fp[k] == f]
                    rank = sib_a.index(a) if a in sib_a else -1
                    if 0 <= rank < len(sib_b) and len(sib_a) == len(sib_b) and sib_b[rank] not in taken:
                        put(a, sib_b[rank], 'exact', note=f'identical copies told apart by creation site (parent '
                                                          f'{pa} -> {mapped[pa]}, child rank {rank})')
                        changed = True
        # similarity rounds
        for _ in range(4):
            free_a = [p.index for p in ma.protos if p.index not in mapped]
            free_b = [p.index for p in mb.protos if p.index not in taken]
            if not free_a or not free_b:
                break
            scores = {}
            for a in free_a:
                va = fa.vector(ma.protos[a])
                for b in free_b:
                    vb = fb.vector(mb.protos[b])
                    pa, pb = fa.parents[a], fb.parents[b]
                    parent_ok = 0.5 if pa is None or pa not in mapped else (1.0 if mapped[pa] == pb else 0.0)
                    if a == ma.main_index or b == mb.main_index:
                        parent_ok = 1.0 if (a == ma.main_index) == (b == mb.main_index) else 0.0
                    scores[a, b] = similarity(va, vb, parent_ok)
            best_a = {a: sorted(((scores[a, b], b) for b in free_b), reverse=True) for a in free_a}
            best_b = {b: max((scores[a, b], a) for a in free_a) for b in free_b}
            progress = False
            for a in free_a:
                ranked = best_a[a]
                s, b = ranked[0]
                runner = ranked[1][0] if len(ranked) > 1 else 0.0
                if s >= AUTO_SCORE and s - runner >= AUTO_MARGIN and best_b[b][1] == a and b not in taken:
                    put(a, b, 'similar', s, runner, note=f'unique high-similarity match (score {s:.2f}, runner-up '
                                                         f'{runner:.2f})')
                    progress = True
            if not progress:
                break
        for p in ma.protos:
            a = p.index
            if a in mapped:
                continue
            free_b = [q.index for q in mb.protos if q.index not in taken]
            va = fa.vector(p)
            ranked = sorted(((similarity(va, fb.vector(mb.protos[b]),
                                         0.5 if fa.parents[a] not in mapped else
                                         (1.0 if mapped[fa.parents[a]] == fb.parents[b] else 0.0)), b) for b in free_b),
                            reverse=True)
            if ranked and ranked[0][0] >= REVIEW_SCORE:
                runner = ranked[1][0] if len(ranked) > 1 else 0.0
                self.protos[a] = ProtoMatch(a, None, 'ambiguous', ranked[0][0], runner, candidate=ranked[0][1],
                                            note=f'best candidate {ranked[0][1]} scores {ranked[0][0]:.2f} (runner-up '
                                                 f'{runner:.2f}); below the auto rule')
            else:
                self.protos[a] = ProtoMatch(a, None, 'unmatched', ranked[0][0] if ranked else 0.0,
                                            note='no prototype of the new build resembles it (removed or rewritten)')

    # -- queries -----------------------------------------------------------------------------------------------------
    def proto(self, a: int) -> ProtoMatch:
        return self.protos.get(a) or ProtoMatch(a, None, 'unmatched', 0.0, note=f'prototype {a} not in the old module')

    def alignment(self, a: int) -> Alignment | None:
        pm = self.proto(a)
        if pm.b is None:
            return None
        if a in self._align:
            return self._align[a]
        pa, pb = self.ma.protos[a], self.mb.protos[pm.b]
        if pm.kind == 'exact':
            al = Alignment({i: (i, 'equal') for i in range(len(pa.instructions))}, 1.0)
        else:
            ta, tb = self.fa.tokens(pa), self.fb.tokens(pb)
            sm = difflib.SequenceMatcher(None, ta, tb, autojunk=False)
            al = Alignment(ratio=sm.ratio())
            for tag, i1, i2, j1, j2 in sm.get_opcodes():
                if tag == 'equal':
                    for n in range(i2 - i1):
                        al.pairs[i1 + n] = (j1 + n, 'equal')
                elif tag == 'replace' and i2 - i1 == j2 - j1:
                    for n in range(i2 - i1):
                        if ta[i1 + n][0] == tb[j1 + n][0]:      # same opcode in the same place: operands changed
                            al.pairs[i1 + n] = (j1 + n, 'modified')
        self._align[a] = al
        return al

    def instruction(self, a: int, i: int) -> tuple[int, int, str] | None:
        """(new prototype, new logical index, 'equal' | 'modified') or None."""
        pm = self.proto(a)
        al = self.alignment(a)
        if al is None or i not in al.pairs:
            return None
        j, how = al.pairs[i]
        return pm.b, j, how

    def constant(self, a: int, k: int) -> int | None:
        """New constant index of constant k of old prototype a (None when it cannot be mapped)."""
        pm = self.proto(a)
        if pm.b is None:
            return None
        if pm.kind == 'exact':
            return k
        pa, pb = self.ma.protos[a], self.mb.protos[pm.b]
        # through an aligned instruction that names the constant
        for i, (_, _, op) in enumerate(pa.instructions):
            ref = operand_constant(self.ma, pa, i)
            if ref == k:
                hit = self.instruction(a, i)
                if hit:
                    kb = operand_constant(self.mb, pb, hit[1])
                    if kb is not None:
                        return kb
        want = self.fa.consts(pa)[k]
        same = [j for j, v in enumerate(self.fb.consts(pb)) if v == want]
        if len(same) == 1 and self.fa.consts(pa).count(want) == 1:
            return same[0]
        return None

    def summary(self) -> dict:
        kinds = Counter(pm.kind for pm in self.protos.values())
        return {'file': self.file, 'status': self.status, 'old_key': self.ma.key,
                'new_key': self.mb.key if self.mb is not None else None,
                'old_protos': len(self.ma.protos), 'new_protos': len(self.mb.protos) if self.mb is not None else 0,
                'kinds': dict(sorted(kinds.items())),
                'moved': sum(1 for pm in self.protos.values() if pm.b is not None and pm.b != pm.a)}


def operand_constant(m: B.Module, p: B.Proto, i: int) -> int | None:
    """Constant index named by instruction i (K operand), else None."""
    w = m.word(p, i)
    op = w[0]
    if op in K_BX:
        return _d(w) & 0xFFFF
    if op in K_AUX:
        return _aux(w)
    if op in K_C:
        return w[3]
    if op in K_B:
        return w[2]
    if op in K_AUX_MASK:
        return _aux(w) & 0xFFFFFF
    if op in K_AUX_FLAG and _aux(w) >> 31:
        return _aux(w) & 0xFFFFFF
    return None


def namecalls(m: B.Module, p: B.Proto, method: str, seed: int) -> list[int]:
    """Logical indices of every NAMECALL of `method` (U44 name hash or plain string) in prototype p."""
    want = B.name_hash(method, seed)
    return [i for i, _, op in p.instructions if op == OP_NAMECALL
            and m.namecall_name(p, i) in (('hash', want), ('string', method))]
