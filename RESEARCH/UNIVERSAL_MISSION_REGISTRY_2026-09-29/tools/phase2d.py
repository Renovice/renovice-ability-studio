"""Phase 2d exact-owner resolution for registry rows (offline, read-only).

A Phase 2d spec names an owner declaratively; this module resolves it against the 44.0.2 stock bytes and
returns exact registry sites. Every spec kind fails closed:

* ``pattern``  - every ``LOADN <value>`` in the module (or the listed prototypes) whose neighbouring
  instruction signatures match ``before``/``after``. The number of matches must equal ``count``; the
  row therefore owns the complete set of sites of that structural owner (no partial coverage).
* ``template`` - a number in a tag-8 table template (root config table). K_CONSTANT_EXCLUSIVE_V1 must
  prove the template is consumed by exactly one DUPTABLE outside any loop, the value constant has no
  other use, and the constructing prototype does not overwrite the field.
* ``constant`` - a number constant used by instructions only. K_CONSTANT_EXCLUSIVE_V1 must prove the
  complete use set equals the declared instruction signatures.

Signatures: ``OP`` or ``OP:detail`` where detail is the SETTABLEKS/GETTABLEKS/NAMECALL key string or
hash, the LOADN immediate, or the number constant of a K operand. ``*`` matches any instruction.
"""
from pathlib import Path
import struct, sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from anchors import Analysis, NAMES, K_AUX, K_BX, K_C, K_B  # noqa: E402
from deluau import RAW_LOADN  # noqa: E402


def signature(m, p, i):
    w = m.protos[p][0][i][1]
    op = w[0]
    name = NAMES.get(op, f'op_{op:02x}')
    if op == 0x12:
        return f'{name}:{struct.unpack_from("<h", w, 2)[0]}'
    k = None
    if op == 0x46:  # GETIMPORT: dotted path from the packed import descriptor
        consts = m.protos[p][1]
        c = consts[w[2] | (w[3] << 8)]
        if c[0] == 4:
            d = struct.unpack('<I', c[1])[0]
            parts = []
            for j in range(d >> 30):
                idx = (d >> (20 - 10 * j)) & 0x3ff
                s = m.string(p, idx) if idx < len(consts) else None
                parts.append(s if s is not None else (f'#{struct.unpack("<I", consts[idx][1])[0]:08x}'
                                                      if idx < len(consts) and consts[idx][0] == 1 else '?'))
            return f'{name}:{".".join(parts)}'
        return name
    if op in K_AUX:
        k = m.aux(w)
    elif op in K_BX and op != 0x4f and op != 0x46:
        k = w[2] | (w[3] << 8)
    elif op in K_C:
        k = w[3]
    elif op in K_B:
        k = w[2]
    if k is not None:
        consts = m.protos[p][1]
        if k < len(consts):
            s = m.string(p, k)
            if s is not None:
                return f'{name}:{s}'
            n = m.number(p, k)
            if n is not None:
                return f'{name}:{n:g}'
            if consts[k][0] == 1:
                return f'{name}:#{struct.unpack("<I", consts[k][1])[0]:08x}'
    return name


def _match(m, p, i, sigs, direction):
    ins = m.protos[p][0]
    for n, want in enumerate(sigs, 1):
        j = i - n if direction < 0 else i + n
        if not 0 <= j < len(ins):
            return False
        if want != '*' and signature(m, p, j) != want:
            return False
    return True


def resolve_pattern(m, spec):
    value = spec['value']
    protos = spec.get('protos') or range(len(m.protos))
    before = list(reversed(spec.get('before', [])))  # nearest first
    after = spec.get('after', [])
    hits = []
    for p in protos:
        p = m.root if p == 'root' else p
        for i, (off, w) in enumerate(m.protos[p][0]):
            if w[0] == 0x12 and struct.unpack_from('<h', w, 2)[0] == value and \
                    _match(m, p, i, before, -1) and _match(m, p, i, after, 1):
                hits.append((p, i, off, w[1]))
    if len(hits) != spec['count']:
        raise ValueError(f'pattern {spec.get("owner")} matched {len(hits)} sites, spec requires exactly {spec["count"]}: '
                         f'{[(p, i) for p, i, *_ in hits]}')
    sites = []
    for p, i, off, reg in hits:
        if m.raw[off] != RAW_LOADN:
            raise ValueError(f'site {p}:{i} raw opcode is not the U44 LOADN byte')
        sites.append({'kind': 'instruction', 'prototype': p, 'instruction': i, 'offset': off,
                      'expected': list(m.raw[off:off + 4]), 'register': reg, 'numerator': 1, 'denominator': 1,
                      'owner': spec['owner'],
                      'anchor': {'kind': 'pattern', 'value': value, 'before': spec.get('before', []),
                                 'after': after, 'module_matches': len(hits)}})
    return sites


def resolve_template(m, spec):
    p = m.root if spec.get('proto', 'root') == 'root' else spec['proto']
    field = spec['field']
    cands = [(t, v) for (q, t, v) in m.templates_with(field) if q == p and v is not None and m.number(p, v) == spec['value']]
    if 'template' in spec:
        cands = [c for c in cands if c[0] == spec['template']]
    if len(cands) != 1:
        raise ValueError(f'{len(cands)} templates in prototype {p} hold {field}={spec["value"]}; the owner is not unique')
    t, _ = cands[0]
    v, gate = m.template_field(p, t, field)
    off = m.constant_offset(p, v)
    return [{'kind': 'number_constant', 'prototype': p, 'constant': v, 'offset': off, 'expected': list(m.raw[off:off + 8]),
             'numerator': 1, 'denominator': 1, 'owner': spec['owner'], 'gate': gate}]


def resolve_constant(m, spec):
    p = m.root if spec.get('proto') == 'root' else spec['proto']
    ks = [k for k, (tag, _) in enumerate(m.const_records[p]) if tag == 2 and m.number(p, k) == spec['value']]
    if len(ks) != 1:
        raise ValueError(f'{len(ks)} number constants equal {spec["value"]} in prototype {p}')
    k = ks[0]
    uses = [u for u in m.uses(p).get(k, []) if u[0] == 'ins']
    got = sorted(signature(m, p, u[1]) for u in uses)
    if got != sorted(spec['uses']):
        raise ValueError(f'constant {k} instruction uses {got} != declared {sorted(spec["uses"])}')
    gate = m.exclusive_constant(p, k, [u[1] for u in uses])
    off = m.constant_offset(p, k)
    return [{'kind': 'number_constant', 'prototype': p, 'constant': k, 'offset': off, 'expected': list(m.raw[off:off + 8]),
             'numerator': 1, 'denominator': 1, 'owner': spec['owner'], 'gate': gate}]


RESOLVERS = {'pattern': resolve_pattern, 'template': resolve_template, 'constant': resolve_constant}


def resolve(m, specs):
    sites = []
    for spec in specs:
        sites += RESOLVERS[spec['kind']](m, spec)
    seen = set()
    for s in sites:
        width = 8 if s['kind'] == 'number_constant' else 4
        span = set(range(s['offset'], s['offset'] + width))
        if span & seen:
            raise ValueError('two specs resolve to overlapping bytes')
        seen |= span
    return sites


def context(m, p, i, radius=3):
    """Exploration helper: signatures around one instruction."""
    ins = m.protos[p][0]
    return [signature(m, p, j) for j in range(max(0, i - radius), min(len(ins), i + radius + 1))]


if __name__ == '__main__':
    # Check a spec list offline: python phase2d.py <specs.json|specs.py> ; prints every resolved site or the exact failure.
    import json, runpy
    from deluau import ROOT
    stock = ROOT / 'work/research/universal-mission-editor-2026-09-29/stock'
    src = Path(sys.argv[1])
    rows = runpy.run_path(str(src))['TUNABLES'] if src.suffix == '.py' else json.loads(src.read_text(encoding='utf-8'))
    cache, bad = {}, 0
    for row in rows:
        f = row['module']
        if f not in cache:
            cache[f] = Analysis((stock / f).read_bytes())
        try:
            sites = resolve(cache[f], row['specs'])
            for s in sites:
                got = struct.unpack_from('<h', cache[f].raw, s['offset'] + 2)[0] if s['kind'] == 'instruction' else \
                    struct.unpack_from('<d', cache[f].raw, s['offset'])[0]
                if got != row['stock']:
                    raise ValueError(f'site {s["prototype"]}@{s["offset"]} stock {got} != row stock {row["stock"]}')
            print('PASS', row['tunable_id'], [(s['kind'][0], s['prototype'], s.get('instruction', s.get('constant')), s['offset']) for s in sites])
        except Exception as e:  # noqa: BLE001 - report every failure
            bad += 1
            print('FAIL', row['tunable_id'], e)
    print(f'{len(rows) - bad} PASS / {bad} FAIL')
