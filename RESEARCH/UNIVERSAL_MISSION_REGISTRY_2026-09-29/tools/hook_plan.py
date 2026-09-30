"""Minimal luaCalls hook set per root table (Phase 2k; offline, read-only).

Gate ``ROOT_TABLE_UPVALUE_V1`` (``addon_owner.py``) hooks EVERY prototype that captures an owned root table, so no code
that can reach the table runs before the addon's write. Live evidence (bootstrapper
``RESEARCH/MULTI_TARGET_LIVE_RUN_FIX2_2026-09-29``) showed that this is expensive: SurvivalMission prototypes 67/68 were
entered at least 262,144 times in about 200 s, and every hooked call pays one protected leaf that builds an argument and
an upvalue view table. This module proves a SMALLER hook set with the same guarantee.

Gate ``ROOT_TABLE_MINIMAL_HOOKS_V1`` (all on the pinned stock bytes):

1. Value flow. A flow-sensitive may-analysis over every prototype tracks which registers and upvalues can hold each
   closure of the module and each owned root table (or its root container). Upvalue contents follow the closure-map
   capture contract (``VAL``/``REF`` register, ``UPVAL`` parent upvalue); a ``REF`` variable and every ``SETUPVAL``
   are merged flow-insensitively (sound over-approximation).
2. Call graph. A ``CALL`` whose function register may hold closure P is a call edge to P. A closure ESCAPES when a
   register that may hold it is used in any other way (argument, store, global, return, method self, concat, ...):
   code outside the module (the engine) may then call it at any time. A closure called directly by the module root
   runs at module load.
3. Reach. A capturer REACHES an owned table when it, or any closure nested in it that re-captures the table, reads or
   writes an owned field, indexes the table (or its container on the owned path) with a dynamic key, or lets the table
   escape. Reads of other fields, length and truthiness tests do not reach.
4. Coverage (nesting rule). A prototype is COVERED by the hook set H when it is in H, or it neither escapes nor is
   called by the root, and every call site that may call it lies in a covered prototype. The fixpoint starts from H
   only (a cycle without an H member is not covered). A covered prototype therefore runs only inside the dynamic
   extent of a call to an H member of the same module instance, whose ``before`` hook binds the table first. This holds
   at the first bind AND after every re-activation (F9, SCRIPT SETTINGS apply), because a rebind happens at the next
   entry of an H member. The weaker "an earlier sibling call dominates" rule is deliberately NOT used: it proves only
   the first bind, and a mid-mission re-activation would then leave the table at stock until the next mission.
5. H is valid when every reaching capturer is covered. Every H member is itself a capturer of the table (the hook
   needs the upvalue), so the full ROOT_TABLE_UPVALUE_V1 hook list is always valid and is the fallback.

Choice. Among valid H, the planner minimises the static call-frequency estimate (see ``frequency``), then |H|, then the
prototype ids. The estimate is a static heuristic (loop nesting of call sites), not a runtime measurement; the proof is
coverage, not frequency. Nothing here writes files.
"""
from pathlib import Path
from itertools import combinations
import struct, sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from addon_owner import RootTables, writes, GATE as OWNER_GATE  # noqa: E402
from anchors import BRANCH  # noqa: E402

GATE = 'ROOT_TABLE_MINIMAL_HOOKS_V1'
UNK = 'unknown'
CALL, NAMECALL, GETUPVAL, SETUPVAL, MOVE, CAPTURE = 0x54, 0x2d, 0x13, 0x53, 0x14, 0x35
NEWCLOSURE, DUPCLOSURE, GETVARARGS, RETURN = 0x16, 0x42, 0x4c, 0x29
GETTABLEKS, GETTABLEN, GETTABLE = 0x3d, 0x44, 0x01
SETTABLEKS, SETTABLEN, SETTABLE, SETLIST = 0x15, 0x2e, 0x2a, 0x3f
JUMP, JUMPBACK, LOADB = 0x40, 0x25, 0x04
FORNPREP, FORNLOOP, FORGPREP, FORGPREP_INEXT, FORGLOOP = 0x47, 0x0a, 0x30, 0x1b, 0x1e
FASTCALL = {0x10, 0x19, 0x26, 0x0c}
TESTS = {0x18, 0x4b, 0x3a, 0x34, 0x20, 0x41, 0x37, 0x27, 0x21, 0x1c, 0x23, 0x33}   # branch on a value; no escape
LENGTH = 0x4d
UNCONDITIONAL = {JUMP, JUMPBACK, FORGPREP, FORGPREP_INEXT}
LOOP_FACTOR = 100          # static weight of one loop level around a call site
EXTERNAL_WEIGHT = 1        # an escaping entry point (engine callback, global): frequency unknown, counted once
MAX_ADDED = 3              # search every combination of up to this many optional hooks on top of the forced ones


class Flow:
    """Value flow, call graph and reach events of one module (canonical bytecode)."""

    def __init__(self, m: RootTables, tables):
        """``tables``: {table_id: {'register': R, 'path': [keys...], 'fields': {key,...}}} for the root tables of
        interest; ``path`` is the container path from the captured root register to the owned table."""
        self.m = m
        self.tables = tables
        self.site = {(p, i): (t, caps) for p, i, t, caps in m.sites}
        self.parent = {}
        for p, _, t, _ in m.sites:
            self.parent.setdefault(t, set()).add(p)
        self.children = {}
        for p, i, t, _ in m.sites:
            self.children.setdefault(p, []).append((i, t))
        self.succ = [self._successors(p) for p in range(len(m.protos))]
        self.loop_depth = [self._loop_depth(p) for p in range(len(m.protos))]
        self._solve()

    # ------------------------------------------------------------------ CFG
    def _successors(self, p):
        ins = self.m.protos[p][0]
        index = {off: i for i, (off, _) in enumerate(ins)}
        out = []
        for i, (off, w) in enumerate(ins):
            nxt = [i + 1] if i + 1 < len(ins) else []
            op = w[0]
            if op == RETURN:
                out.append([])
                continue
            if op == LOADB and w[3] != 0:
                target = index.get(off + 4 + w[3] * 4)
                if target is None:
                    raise ValueError(f'prototype {p} LOADB at {i} skips to a non-instruction')
                out.append([target])
                continue
            if op in BRANCH:
                d = struct.unpack_from('<h', w, 2)[0]
                target = index.get(off + 4 + d * 4)
                if target is None:
                    raise ValueError(f'prototype {p} branch at {i} targets a non-instruction')
                out.append([target] if op in UNCONDITIONAL else sorted(set(nxt + [target])))
                continue
            out.append(nxt)
        return out

    def _loop_depth(self, p):
        loops = self.m.loops(p)
        n = len(self.m.protos[p][0])
        return [sum(1 for lo, hi in loops if lo <= i <= hi) for i in range(n)]

    # ------------------------------------------------------------------ value flow
    @staticmethod
    def _dests(w, nregs):
        """Registers (re)assigned by one instruction."""
        op, a = w[0], w[1]
        if op == CALL:
            return list(range(a, nregs)) if w[3] == 0 else list(range(a, a + w[3] - 1))
        if op == NAMECALL:
            return [a, a + 1]
        if op == GETVARARGS:
            return list(range(a, nregs)) if w[2] == 0 else list(range(a, a + w[2] - 1))
        if op == FORGLOOP:
            count = struct.unpack_from('<I', w, 4)[0] & 0xff
            return list(range(a + 3, a + 3 + max(count, 1)))
        if op in (FORNPREP, FORNLOOP):
            return [a + 2]
        return [a] if writes(w, a) else []

    def _nregs(self, p):
        top = 1
        for _, w in self.m.protos[p][0]:
            top = max(top, w[1] + 4, w[2] + 1, w[3] + 1)
        return min(top + 8, 256)

    def _solve(self):
        m = self.m
        n = len(m.protos)
        # Upvalue variables. var(p, k) is a canonical id; REF register variables and SETUPVAL writes are merged.
        self.upvar = {}
        for (parent, i), (target, caps) in self.site.items():
            for k, (mode, src) in caps.items():
                if mode == 'VAL':
                    self.upvar[(target, k)] = ('val', target, k)
                elif mode == 'REF':
                    self.upvar[(target, k)] = ('ref', parent, int(src[1:]))
                else:
                    self.upvar[(target, k)] = ('up', parent, int(src[1:]))

        def canon(v):
            seen = set()
            while v[0] == 'up' and v not in seen:
                seen.add(v)
                v = self.upvar.get((v[1], v[2]), ('val', v[1], v[2]))
            return v
        self.var = {key: canon(v) for key, v in self.upvar.items()}
        self.varset = {}                       # canonical var -> set of values
        self.ref_regs = {(v[1], v[2]) for v in self.var.values() if v[0] == 'ref'}
        self.regs_in = [None] * n
        # Seed: owned root tables are the only table values tracked (root registers at construction).
        changed = True
        rounds = 0
        while changed:
            rounds += 1
            if rounds > 50:
                raise ValueError('value flow did not converge')
            changed = False
            for p in self._order():
                if self._flow_proto(p):
                    changed = True

    def _order(self):
        out, stack, seen = [], [self.m.root], set()
        while stack:
            p = stack.pop()
            if p in seen:
                continue
            seen.add(p)
            out.append(p)
            stack.extend(t for _, t in sorted(self.children.get(p, []), reverse=True))
        out.extend(p for p in range(len(self.m.protos)) if p not in seen)
        return out

    def _reg(self, p, regs, r):
        """Values register r may hold; a REF-captured register also holds everything written through its variable."""
        values = regs.get(r, frozenset({UNK}))
        if (p, r) in self.ref_regs:
            # Owned tables are excluded: the owner gate rejects any SETUPVAL of a captured table, so only the owning
            # prototype's own (flow-sensitive) register state can hold one.
            values = values | frozenset(v for v in self.varset.get(('ref', p, r), ())
                                        if not (isinstance(v, tuple) and v[0] == 'T'))
        return values

    def _uv(self, p, k):
        v = self.var.get((p, k))
        return frozenset(self.varset.get(v, {UNK})) if v is not None else frozenset({UNK})

    def _add_var(self, v, values):
        cur = self.varset.setdefault(v, set())
        new = set(values) - cur
        if new:
            cur |= new
            return True
        return False

    def _flow_proto(self, p):
        """One forward pass to fixpoint inside prototype p; returns True when an upvalue variable changed."""
        m = self.m
        ins = m.protos[p][0]
        nregs = self._nregs(p)
        empty = {r: frozenset({UNK}) for r in range(nregs)}
        state = [None] * len(ins)
        state[0] = dict(empty)
        work = [0]
        var_changed = False
        is_root = p == m.root
        table_seed = {}
        if is_root:
            for tid, t in self.tables.items():
                # Several owned tables can share one root container (CoH Shrine Defense: 12 tables under R58).
                reg, values = table_seed.setdefault(t['construction'], (t['register'], set()))
                if reg != t['register']:
                    raise ValueError(f'root instruction {t["construction"]} seeds two registers')
                values.add(('T', tid, 0))
        while work:
            i = work.pop()
            regs = dict(state[i])
            w = ins[i][1]
            op = w[0]
            out = dict(regs)
            for r in self._dests(w, nregs):
                if r < nregs:
                    out[r] = frozenset({UNK})
            if op in (NEWCLOSURE, DUPCLOSURE) and (p, i) in self.site:
                out[w[1]] = frozenset({('C', self.site[(p, i)][0])})
            elif op == GETUPVAL:
                out[w[1]] = self._uv(p, w[2])
            elif op == MOVE:
                out[w[1]] = self._reg(p, regs, w[2])
            elif op in (GETTABLEKS, GETTABLEN):
                key = m.key_string(p, w) if op == GETTABLEKS else w[3] + 1
                derived = set()
                for v in self._reg(p, regs, w[2]):
                    if isinstance(v, tuple) and v[0] == 'T':
                        t = self.tables[v[1]]
                        if v[2] < len(t['path']) and t['path'][v[2]] == key:
                            derived.add(('T', v[1], v[2] + 1))
                if derived:
                    out[w[1]] = frozenset(derived | {UNK})
            elif op == NAMECALL:
                out[w[1] + 1] = self._reg(p, regs, w[2])
            if i in table_seed:
                reg, values = table_seed[i]
                out[reg] = frozenset(values)
            if op == SETUPVAL:
                v = self.var.get((p, w[2]))
                if v is not None and self._add_var(v, self._reg(p, regs, w[1])):
                    var_changed = True
            # REF-captured registers of this prototype: every assignment flows into the shared variable.
            for r in self._dests(w, nregs):
                if (p, r) in self.ref_regs and self._add_var(('ref', p, r), out.get(r, {UNK})):
                    var_changed = True
            if op == CAPTURE:
                pass
            for s in self.succ[p][i]:
                if state[s] is None:
                    state[s] = out
                    work.append(s)
                else:
                    merged = {r: state[s][r] | out.get(r, frozenset({UNK})) for r in state[s]}
                    if merged != state[s]:
                        state[s] = merged
                        work.append(s)
        # Captures: the value of the captured register at the NEWCLOSURE instruction.
        for i, (_, w) in enumerate(ins):
            if state[i] is None or w[0] not in (NEWCLOSURE, DUPCLOSURE) or (p, i) not in self.site:
                continue
            target, caps = self.site[(p, i)]
            for k, (mode, src) in caps.items():
                if mode == 'VAL':
                    if self._add_var(('val', target, k), self._reg(p, state[i], int(src[1:]))):
                        var_changed = True
                elif mode == 'REF':
                    if self._add_var(('ref', p, int(src[1:])), self._reg(p, state[i], int(src[1:]))):
                        var_changed = True
        if self.regs_in[p] != state:
            self.regs_in[p] = state
        return var_changed

    # ------------------------------------------------------------------ uses
    def events(self):
        """Call edges, closure escapes, root calls and table reach events of the whole module."""
        m = self.m
        calls, escapes, reach = {}, {}, {}
        for p in range(len(m.protos)):
            ins = m.protos[p][0]
            state = self.regs_in[p]
            for i, (_, w) in enumerate(ins):
                if state[i] is None:
                    continue
                regs = state[i]
                op = w[0]
                used = self._uses(p, i, w)
                for r, role in used:
                    for v in self._reg(p, regs, r):
                        if not isinstance(v, tuple):
                            continue
                        if v[0] == 'C':
                            if role == 'call':
                                calls.setdefault(v[1], set()).add((p, i))
                            elif role not in ('harmless', 'holder', 'table'):
                                escapes.setdefault(v[1], set()).add((p, i, role))
                        elif v[0] == 'T':
                            kind = self._table_use(p, w, r, role, v)
                            if kind:
                                reach.setdefault(v[1], set()).add((p, i, kind))
        return calls, escapes, reach

    def _uses(self, p, i, w):
        """[(register, role)] read by one instruction; role 'call' = function slot of a CALL."""
        op, a, b, c = w[0], w[1], w[2], w[3]
        if op == CALL:
            args = range(a + 1, self._nregs(p)) if b == 0 else range(a + 1, a + b)
            return [(a, 'call')] + [(r, 'argument') for r in args]
        if op == MOVE or op == CAPTURE:
            return [(b, 'holder')] if (op == MOVE or a in (0, 1)) else []
        if op == GETUPVAL or op in (NEWCLOSURE, DUPCLOSURE):
            return []
        if op in FASTCALL:
            return []                                      # the following CALL carries the arguments
        if op in TESTS or op == LENGTH:
            regs = [a] if op in TESTS else [b]
            if op in (0x37, 0x27, 0x21, 0x1c, 0x23, 0x33):
                aux = struct.unpack_from('<I', w, 4)[0]
                if not aux & 0x80000000:
                    regs.append(aux & 0xff)
            return [(r, 'harmless') for r in regs]
        if op in (GETTABLEKS, GETTABLEN):
            return [(b, 'table')]
        if op == GETTABLE:
            return [(b, 'table'), (c, 'key')]
        if op in (SETTABLEKS, SETTABLEN):
            return [(b, 'table'), (a, 'stored')]
        if op == SETTABLE:
            return [(b, 'table'), (c, 'key'), (a, 'stored')]
        if op == SETUPVAL:
            return [(a, 'holder')]
        if op == NAMECALL:
            return [(b, 'method-self')]
        if op == RETURN:
            return [(r, 'returned') for r in (range(a, self._nregs(p)) if b == 0 else range(a, a + b - 1))]
        if op == SETLIST:
            return [(a, 'table')] + [(r, 'stored') for r in (range(b, self._nregs(p)) if c == 0 else range(b, b + c - 1))]
        if op in (FORGPREP, FORGPREP_INEXT, FORGLOOP):
            return [(r, 'iterated') for r in (a, a + 1, a + 2)]
        from addon_owner import reads
        r = reads(w)
        if r is None:
            r = {a, b, c}
        return [(x, 'operand') for x in r]

    def _table_use(self, p, w, r, role, v):
        """Reach kind of one use of an owned table value, or None when it cannot touch an owned entry. Uses of a root
        CONTAINER on the owned table's path carry the prefix ``container:``; the ones that can put a different child
        table on the path (``container:replace-entry``, ``container:dynamic-write``, ``container:setlist``,
        ``container:escape:*``) make the table unsafe to retire a hook for (contract R3, obligation 2)."""
        t = self.tables[v[1]]
        depth, path = v[2], t['path']
        container = depth < len(path)
        prefix = 'container:' if container else ''
        op = w[0]
        if role == 'harmless':
            return None
        if role == 'holder':
            # MOVE/CAPTURE: tracked by the value flow. SETUPVAL stores the table into ANOTHER variable (the owner gate
            # rejects replacing the table's own upvalue): the table escapes from this capturer (SentientArtifactMission
            # proto 73 copies the Entrati config into the shared "current config" upvalue that proto 39 reads).
            return prefix + 'escape:setupval' if op == SETUPVAL else None
        if role == 'table' and op in (GETTABLEKS, GETTABLEN):
            key = self.m.key_string(p, w) if op == GETTABLEKS else w[3] + 1
            if container:
                return None                                 # container read; the owned child is tracked as a value
            return 'read' if key in t['fields'] else None
        if role == 'table' and op in (SETTABLEKS, SETTABLEN):
            key = self.m.key_string(p, w) if op == SETTABLEKS else w[3] + 1
            if container:
                return 'container:replace-entry' if key == path[depth] else None
            return 'write' if key in t['fields'] else None
        if role == 'table' and op == GETTABLE:
            return 'container:dynamic-read' if container else 'dynamic-key'
        if role == 'table' and op == SETTABLE:
            return 'container:dynamic-write' if container else 'dynamic-key'
        if role == 'table' and op == SETLIST:
            return prefix + 'setlist'
        return prefix + 'escape:' + role


def frequency(flow, calls, escapes, root_called):
    """Static call-frequency estimate per prototype: an escaping entry counts EXTERNAL_WEIGHT, a call site contributes
    its caller's estimate times LOOP_FACTOR per enclosing loop level. Recursion is cut (a prototype on the current
    path contributes nothing)."""
    memo = {}

    def f(p, path):
        if p in memo:
            return memo[p]
        if p in path:
            return 0
        total = 0
        if p in escapes or p == flow.m.root:
            total += EXTERNAL_WEIGHT
        for q, i in calls.get(p, ()):
            total += f(q, path | {p}) * LOOP_FACTOR ** flow.loop_depth[q][i]
        if not path:
            memo[p] = total
        return total
    return {p: f(p, frozenset()) for p in range(len(flow.m.protos))}


def covered_set(flow, calls, escapes, root_called, hooks):
    covered = set(hooks)
    n = len(flow.m.protos)
    changed = True
    while changed:
        changed = False
        for p in range(n):
            if p in covered or p in escapes or p in root_called or p == flow.m.root:
                continue
            sites = calls.get(p, set())
            if all(q in covered for q, _ in sites):
                covered.add(p)
                changed = True
    return covered


def top_capturer(flow, proto, capturers):
    """The capturer (direct root child in the hook list) whose closure tree contains ``proto``."""
    seen = set()
    x = proto
    while x not in capturers:
        parents = flow.parent.get(x, set())
        if len(parents) != 1 or x in seen:
            return None
        seen.add(x)
        x = next(iter(parents))
    return x


def plan_module(m: RootTables, root_tables, owned_fields):
    """Minimal hook plan per root table of one module.

    ``root_tables``: registry ``modules[body].root_tables`` ({table_id: {instruction, register, hooks[...]}}).
    ``owned_fields``: {table_id: set(field keys owned by registry rows)}. Returns {table_id: evidence}."""
    tables = {}
    for tid, record in root_tables.items():
        paths = {tuple(h['path']) for h in record['hooks']}
        if len(paths) != 1:
            raise ValueError(f'{tid}: hooks disagree on the container path {sorted(paths)}')
        path = list(next(iter(paths)))
        root_register = record['containers'][-1]['register'] if record.get('containers') else record['register']
        construction = record['containers'][-1]['instruction'] if record.get('containers') else record['instruction']
        tables[tid] = {'register': root_register, 'construction': construction, 'path': path,
                       'fields': set(owned_fields.get(tid, set()))}
    flow = Flow(m, tables)
    calls, escapes, reach = flow.events()
    root_called = {p for p, sites in calls.items() if any(q == m.root for q, _ in sites)}
    freq = frequency(flow, calls, escapes, root_called)
    out = {}
    for tid, record in root_tables.items():
        capturers = {h['prototype'] for h in record['hooks']}
        if not tables[tid]['fields']:
            out[tid] = {'gate': GATE, 'method': 'no-owned-field', 'hooks': [], 'full_hooks': sorted(capturers),
                        'reaching_capturers': [], 'note': 'no registry row owns a field of this table (it is only a '
                        'container on the path of other tables); it needs no hook of its own'}
            continue
        reachers, unattributed = set(), []
        for p, i, kind in sorted(reach.get(tid, ())):
            if p == m.root:
                # Root stores are the construction itself (the owner gate rejects a second store of an owned field);
                # anything else in the root would run at module load, before any hook.
                if kind not in ('write', 'setlist', 'container:replace-entry', 'container:setlist'):
                    raise ValueError(f'{tid}: root instruction {i} {kind} (gate {OWNER_GATE} should have rejected it)')
                continue
            top = top_capturer(flow, p, capturers)
            if top is None:
                unattributed.append((p, i, kind))
            else:
                reachers.add(top)
        escaped = any(kind.startswith('escape') and p != m.root and top_capturer(flow, p, capturers) is not None
                      for p, _, kind in reach.get(tid, ()))
        if unattributed and not escaped:
            raise ValueError(f'{tid}: reach events outside every capturer tree {unattributed[:4]}')
        # With an escape, code outside the capturer trees can hold the table only after an escaping capturer ran; that
        # capturer reaches, so it is covered and the table is bound before the escape. Those readers are recorded.
        if not reachers:
            raise ValueError(f'{tid}: no capturer reaches an owned field (nothing to hook)')
        forced = sorted(p for p in reachers if p in escapes or p in root_called)
        load_time = sorted(p for p in reachers if p in root_called)
        optional = sorted(capturers - set(forced))
        best = None
        # Candidate sets: every reaching capturer hooked (always valid: each reacher is then in H), plus the forced
        # hooks with every combination of up to MAX_ADDED optional capturers (a caller hook can cover several readers).
        candidates = [tuple(sorted(reachers - set(forced)))]
        for size in range(0, min(MAX_ADDED, len(optional)) + 1):
            candidates.extend(combinations(optional, size))
        for extra in candidates:
            hooks = set(forced) | set(extra)
            if not hooks:
                continue
            cov = covered_set(flow, calls, escapes, root_called, hooks)
            if not reachers <= cov:
                continue
            key = (sum(freq[h] for h in hooks), len(hooks), sorted(hooks))
            if best is None or key < best[0]:
                best = (key, sorted(hooks))
        full = sorted(capturers)
        if best is None:
            chosen, method = full, 'fallback-full-capturer-set'
        else:
            chosen, method = best[1], 'minimal-search'
        cov = covered_set(flow, calls, escapes, root_called, set(chosen))
        if not reachers <= cov:
            raise ValueError(f'{tid}: chosen hook set {chosen} does not cover the reaching capturers {sorted(reachers)}')
        def callers(p):
            return sorted({q for q, _ in calls.get(p, ())})
        # Contract R3 (bootstrapper feat/lua-call-retire-2026-09-30): a hook may return "RENOVICE_RETIRE" only from a
        # prototype the module root creates (root child) and only when the bound table cannot be swapped for another
        # table during the instance. A root table is fixed by ROOT_TABLE_UPVALUE_V1 (built once, no SETUPVAL, a REF
        # register never reassigned); a nested table is fixed only when no non-root code can replace a container entry
        # on its path or let a container escape.
        root_children = sorted(h for h in chosen if flow.parent.get(h) == {m.root})
        unsafe = sorted({f'{p}:{kind}' for p, _, kind in reach.get(tid, ()) if p != m.root and (
            kind in ('container:replace-entry', 'container:dynamic-write', 'container:setlist')
            or kind.startswith('container:escape'))})
        retire_safe = not unsafe and root_children == sorted(chosen)
        out[tid] = {
            'gate': GATE,
            'method': method,
            'hooks': chosen,
            'full_hooks': full,
            'reaching_capturers': sorted(reachers),
            'non_reaching_capturers': sorted(capturers - reachers),
            'forced': forced,
            'load_time_reachers': load_time,
            'coverage': {str(p): ('hooked' if p in chosen else ('called-only-inside-' + ','.join(map(str, callers(p)))
                                                                   if callers(p) else 'never-called'))
                         for p in sorted(reachers)},
            'reach_events': sorted({f'{p}:{kind}' for p, _, kind in reach.get(tid, ())}),
            'downstream_after_escape': sorted({p for p, _, _ in unattributed}),
            'escaping_capturers': sorted(p for p in capturers if p in escapes),
            'static_weight': {str(p): freq[p] for p in full},
            'static_weight_chosen': sum(freq[p] for p in chosen),
            'static_weight_full': sum(freq[p] for p in full),
            'root_children': root_children,
            'retire_safe': retire_safe,
            'retire_blockers': unsafe + [f'{h}:not-a-root-child' for h in chosen if h not in root_children],
        }
    return out, flow, (calls, escapes, reach, root_called, freq)


if __name__ == '__main__':
    # Exploration: python hook_plan.py <body key>
    import json
    from deluau import ROOT
    registry = json.loads((ROOT / 'repos/apps/ability-editor/REGISTRIES/mission_build_u44.json').read_text())
    corpus = ROOT / registry['corpus']['path'] if isinstance(registry.get('corpus'), dict) and 'path' in registry['corpus'] else ROOT / 'shared/corpus/de-luau-u44.0.2-authoring'
    for body in sys.argv[1:] or [k for k, v in registry['modules'].items() if 'root_tables' in v]:
        module = registry['modules'][body]
        owned = {}
        for row in registry['tunables']:
            if row['backend'] == 'TARGET_ADDON' and row['owner'].get('body_key') == body:
                for f in row['owner'].get('fields', []):
                    owned.setdefault(f['table_id'], set()).add(f['field'])
        m = RootTables((corpus / module['file']).read_bytes())
        plans, flow, (calls, escapes, reach, root_called, freq) = plan_module(m, module['root_tables'], owned)
        print(body, module['module_path'])
        for tid, ev in plans.items():
            print(f"  {tid:14s} {len(ev['full_hooks']):2d} -> {len(ev['hooks']):2d} {ev['hooks']} reach={ev['reaching_capturers']} "
                  f"forced={ev['forced']} w {ev['static_weight_full']} -> {ev['static_weight_chosen']} {ev['method']}")
