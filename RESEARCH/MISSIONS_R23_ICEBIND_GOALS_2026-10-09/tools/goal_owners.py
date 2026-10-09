# Read-only bytecode reachability for one module (44.1.1 stock pack): which global entry functions reach every
# string-keyed read of a field (default maxWaveNum), through closure creation, captured closures and calls by global
# name. Research tool for the Icebind goal rows (2026-10-09); same question as the R10 capture-graph proof
# (work/research/mission-owners-2026-09-30/tools/callers.py), answered on the bytecode instead of a render.
# Usage: python goal_owners.py <stock file name> [field] [candidate global name ...]
import struct
import sys
from collections import defaultdict, deque
from pathlib import Path

ROOT = Path(__file__).resolve().parent
while not (ROOT / 'WORKSPACE.json').exists():
    ROOT = ROOT.parent
TOOLS = ROOT / 'repos/apps/ability-editor/RESEARCH/UNIVERSAL_MISSION_REGISTRY_2026-09-29/tools'
sys.path.insert(0, str(TOOLS))
from addon_owner import RootTables  # noqa: E402
from deluau import body_key  # noqa: E402

STOCK = ROOT / 'work/temp/update-check/stock-726365cc81044d28'
SEED = 0x768e5ed0
GETGLOBAL, SETGLOBAL, GETTABLEKS, GETIMPORT = 0x17, 0x02, 0x3d, 0x46
NEWCLOSURE, DUPCLOSURE = 0x16, 0x42


def namehash(name):
    x = SEED
    for b in name.encode():
        x = ((x ^ b) * 0x01000193) & 0xFFFFFFFF
    x = (~x) & 0xFFFFFFFF
    return ((x << 17) | (x >> 15)) & 0xFFFFFFFF


def global_key(m, p, w):
    """Name or '#hash' of the key of a GETGLOBAL/SETGLOBAL/GETIMPORT(single) instruction, else None."""
    consts = m.protos[p][1]
    if w[0] in (GETGLOBAL, SETGLOBAL):
        k = struct.unpack_from('<I', w, 4)[0]
    elif w[0] == GETIMPORT:
        aux = struct.unpack_from('<I', w, 4)[0]
        if aux >> 30 != 1:
            return None
        k = (aux >> 20) & 1023
    else:
        return None
    c = consts[k] if k < len(consts) else None
    if c is None:
        return None
    if c[0] == 'str':
        return m.pool[c[1] - 1].decode('utf-8', 'replace')
    if c[0] == 1:
        return '#%08x' % struct.unpack('<I', c[1][:4])[0]
    return None


def main():
    file = sys.argv[1]
    field = sys.argv[2] if len(sys.argv) > 2 else 'maxWaveNum'
    names = {('#%08x' % namehash(n)): n for n in sys.argv[3:]}
    raw = (STOCK / file).read_bytes()
    m = RootTables(raw)
    print(f'{file} key={body_key(raw)} protos={len(m.protos)} root={m.root}')
    root_ins = m.protos[m.root][0]
    # root register -> closure prototype, as the root executes (closure sites are root-level instructions)
    site_at = {(par, i): (tgt, caps) for par, i, tgt, caps in m.sites}
    reg_closure = {}
    reg_at = {}            # (root instruction) -> snapshot of reg_closure before it
    reg_ever = defaultdict(set)  # root register -> every closure stored in it (a REF capture sees later stores)
    globals_ = {}          # global key -> prototype
    for i, (_, w) in enumerate(root_ins):
        reg_at[i] = dict(reg_closure)
        if (m.root, i) in site_at:
            reg_closure[w[1]] = site_at[(m.root, i)][0]
            reg_ever[w[1]].add(site_at[(m.root, i)][0])
        elif w[0] == SETGLOBAL and w[1] in reg_closure:
            globals_[global_key(m, m.root, w)] = reg_closure[w[1]]
    # upvalue binding of every prototype: prototype -> {upvalue index: {closure prototypes}}
    upv = defaultdict(lambda: defaultdict(set))
    edges = defaultdict(set)
    for par, i, tgt, caps in sorted(m.sites, key=lambda s: (s[0] != m.root, s[0], s[1])):
        edges[par].add(tgt)  # the creator may call what it creates
        for u, (mode, src) in caps.items():
            mode = mode.upper()
            qs = set()
            if src.startswith('R') and par == m.root:
                r = int(src[1:])
                if mode == 'REF':
                    qs = set(reg_ever[r])
                elif r in reg_at.get(i, {}):
                    qs = {reg_at[i][r]}
            elif src.startswith('U'):
                qs = set(upv[par][int(src[1:])])
            upv[tgt][u] |= qs
            edges[tgt] |= qs
    # calls by global name
    for p, (ins, _) in enumerate(m.protos):
        for _, w in ins:
            if w[0] in (GETGLOBAL, GETIMPORT):
                k = global_key(m, p, w)
                if k in globals_:
                    edges[p].add(globals_[k])
    readers = defaultdict(list)
    for p, (ins, _) in enumerate(m.protos):
        for i, (_, w) in enumerate(ins):
            if w[0] == GETTABLEKS and m.key_string(p, w) == field:
                readers[p].append(i)
    print('globals:', {names.get(k, k): v for k, v in globals_.items()})
    print(f'{field} readers:', dict(readers))
    reach = {}
    for g, p0 in globals_.items():
        seen, dq = {p0}, deque([p0])
        while dq:
            x = dq.popleft()
            for y in edges[x]:
                if y not in seen:
                    seen.add(y)
                    dq.append(y)
        reach[names.get(g, g)] = seen
    for p in sorted(readers):
        via = sorted(g for g, s in reach.items() if p in s)
        print(f'  reader P{p} {readers[p]} reached from: {via if via else "NO GLOBAL ENTRY (dead or root-only)"}')


if __name__ == '__main__':
    main()
