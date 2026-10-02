"""Read-only DE Luau (09 03) container reader for the post-update check.

Self-contained: the container grammar is the one recovered from the client's undump (documented in
archive/legacy-decompilers/transpiler-lab/_flat_loader.py and parse_luab.py, and used by the registrar's deluau.py);
the U44 opcode permutation is read from the toolchain's src/de_opcode_profile.h (the runtime keeps a byte-identical
copy, see uc_toolchain). Nothing here writes a file.

Terms used by the report:
  content key   FNV-1a 64 of the whole stock body (basis 1469598103934665603, prime 1099511628211), the key the
                loader uses for replacements, target addons and recipes.
  prototype     zero-based flat prototype index, the `luaCalls` key.
  logical index zero-based instruction index inside a prototype where an 8-byte (AUX) instruction counts once; the
                `nativeCalls` callsite numbering (the NAMECALL, not its CALL).
  fingerprint   SHA-256 (16 hex) of a prototype's content that does not depend on its flat index, on other prototypes
                or on line numbers: header bytes, canonical code, and constants with strings resolved to their text and
                closure constants reduced to a marker. Identical function => identical fingerprint after unrelated
                edits elsewhere in the module (the remap key for step 2).
  shape         SHA-256 (16 hex) of the canonical opcode sequence only (a weaker hint).
"""
from __future__ import annotations

import hashlib
import re
import struct
from dataclasses import dataclass, field
from pathlib import Path

FNV64_BASIS = 1469598103934665603
FNV64_PRIME = 1099511628211

# Canonical (U43 numbering) opcodes used by the checks (toolchain OPCODE_MAP.md).
OP_NAMECALL = 0x2D
OP_LOADN = 0x12
OP_GETGLOBAL = 0x17
OP_GETTABLEKS = 0x3D
OP_NEWCLOSURE = 0x16
OP_RETURN = 0x29
# Canonical 8-byte (AUX) set: toolchain de_opcode_profile.h canonical_has_aux.
CANONICAL_AUX = frozenset(int(x, 16) for x in (
    '02 03 0c 0f 15 17 1c 1e 20 21 23 26 27 2c 2d 33 34 36 37 3a 3d 3f 41 43 46 4a'.split()))


def content_key(data: bytes) -> str:
    x = FNV64_BASIS
    for v in data:
        x = ((x ^ v) * FNV64_PRIME) & 0xFFFFFFFFFFFFFFFF
    return f'{x:016x}'


def name_hash(name: str, seed: int) -> int:
    """DE native-name hash (FNV-1a 32 from `seed`, then not, rol 17)."""
    h = seed & 0xFFFFFFFF
    for c in name.encode('utf-8'):
        h ^= c
        h = (h * 16777619) & 0xFFFFFFFF
    h = (~h) & 0xFFFFFFFF
    return ((h << 17) | (h >> 15)) & 0xFFFFFFFF


def load_opcode_profile(header_text: str) -> list[int]:
    """u43_to_u44 table from de_opcode_profile.h(pp) text; returns u44_to_u43 (raw byte -> canonical)."""
    m = re.search(r'u43_to_u44\s*=\s*\{([^}]*)\}', header_text)
    if not m:
        raise ValueError('de_opcode_profile: u43_to_u44 table not found')
    table = [int(x, 16) for x in re.findall(r'0x[0-9a-fA-F]{2}', m.group(1))]
    if len(table) != 86 or sorted(table) != list(range(86)):
        raise ValueError(f'de_opcode_profile: u43_to_u44 is not a permutation of 0..85 (n={len(table)})')
    inverse = [0] * 86
    for canonical, raw in enumerate(table):
        inverse[raw] = canonical
    return inverse


class ContainerError(Exception):
    pass


def _vi(b: bytes, o: int) -> tuple[int, int]:
    r = sh = 0
    while True:
        if o >= len(b):
            raise ContainerError('varint runs past the end of the container')
        x = b[o]
        o += 1
        r |= (x & 0x7F) << sh
        if not x & 0x80:
            return r, o
        sh += 7
        if sh > 63:
            raise ContainerError('varint too long')


def _enc_vi(v: int) -> bytes:
    out = bytearray()
    while True:
        byte = v & 0x7F
        v >>= 7
        if v:
            out.append(byte | 0x80)
        else:
            out.append(byte)
            return bytes(out)


@dataclass
class Const:
    tag: int
    value: object
    start: int   # absolute offset of the tag byte
    end: int


@dataclass
class Proto:
    index: int
    start: int                 # record start (header byte 0)
    end: int                   # record end (exclusive)
    header: bytes              # 5 header bytes (maxstack, params, upvalues, vararg, flags)
    code_start: int
    sizecode: int              # 32-bit words
    raw_code: bytes
    consts: list[Const]
    consts_start: int          # offset of the sizek varint
    consts_end: int
    kids: list[int]
    kids_start: int            # offset of the nsub varint
    kids_end: int
    linedefined: int
    canonical_code: bytes = b''
    instructions: list[tuple[int, int, int]] = field(default_factory=list)  # (logical, byte offset in code, canonical op)
    walk_error: str = ''


class Module:
    """One DE 09 03 container. `opmap` maps raw opcode bytes to canonical ones (None = already canonical)."""

    def __init__(self, data: bytes, opmap: list[int] | None):
        self.data = bytes(data)
        self.key = content_key(self.data)
        self.sha256 = hashlib.sha256(self.data).hexdigest()
        self.opmap = opmap
        b = self.data
        if len(b) < 3 or b[0] != 0x09 or b[1] != 0x03:
            raise ContainerError('not a DE 09 03 container')
        o = 2
        nstr, o = _vi(b, o)
        self.pool: list[bytes] = []
        self.pool_spans: list[tuple[int, int]] = []
        for _ in range(nstr):
            ln, o = _vi(b, o)
            if o + ln > len(b):
                raise ContainerError('string pool entry runs past the end')
            self.pool.append(b[o:o + ln])
            self.pool_spans.append((o, o + ln))
            o += ln
        if o >= len(b):
            raise ContainerError('container ends inside the string pool')
        flag = b[o]
        o += 1
        if flag:
            while True:
                _, o = _vi(b, o)
                nb = b[o]
                o += 1
                if nb == 0:
                    break
        self.nps_offset = o
        nps, o = _vi(b, o)
        self.protos_start = o
        self.protos: list[Proto] = []
        for i in range(nps):
            p = self._read_proto(i, o)
            self.protos.append(p)
            o = p.end
        self.trailer_offset = o
        self.main_index, o2 = _vi(b, o)
        if o2 != len(b):
            raise ContainerError(f'{len(b) - o2} trailing bytes after the main prototype index')
        for p in self.protos:
            self._walk(p)

    # -- grammar -------------------------------------------------------------------------------------------------
    def _read_proto(self, index: int, o: int) -> Proto:
        b = self.data
        start = o
        if o + 6 > len(b):
            raise ContainerError(f'prototype {index}: header past the end')
        header = b[o:o + 5]
        p = o + 5
        slen, p = _vi(b, p)
        p += slen
        sizecode, co = _vi(b, p)
        if co + sizecode * 4 > len(b):
            raise ContainerError(f'prototype {index}: code past the end')
        raw_code = b[co:co + sizecode * 4]
        cs = co + sizecode * 4
        sizek, o = _vi(b, cs)
        consts: list[Const] = []
        for _ in range(sizek):
            t0 = o
            tag = b[o]
            o += 1
            if tag == 3:
                v, o = _vi(b, o)
            elif tag in (1, 4):
                v = struct.unpack_from('<I', b, o)[0]
                o += 4
            elif tag == 2:
                v = struct.unpack_from('<d', b, o)[0]
                o += 8
            elif tag == 7:
                v = b[o:o + 16]
                o += 16
            elif tag == 6:
                v, o = _vi(b, o)
            elif tag == 5:
                cnt, o = _vi(b, o)
                items = []
                for _ in range(cnt):
                    x, o = _vi(b, o)
                    items.append(x)
                v = tuple(items)
            elif tag == 8:
                cnt, o = _vi(b, o)
                items = []
                for _ in range(cnt):
                    x, o = _vi(b, o)
                    items.append((x, b[o:o + 4]))
                    o += 4
                v = tuple(items)
            elif tag == 9:
                sign = b[o]
                o += 1
                x, o = _vi(b, o)
                v = (sign, x)
            elif tag == 0:
                v = None
            else:
                raise ContainerError(f'prototype {index}: invalid constant tag {tag}')
            consts.append(Const(tag, v, t0, o))
        consts_end = o
        kids_start = o
        nsub, o = _vi(b, o)
        kids = []
        for _ in range(nsub):
            k, o = _vi(b, o)
            kids.append(k)
        kids_end = o
        linedefined, o = _vi(b, o)
        _, o = _vi(b, o)              # debug source name
        g1 = b[o]
        o += 1
        if g1:
            kk = b[o] & 0x3F
            o += 1
            o += sizecode
            o += 4 * ((((sizecode - 1) >> kk) + 1) if sizecode > 0 else 0)
        g2 = b[o]
        o += 1
        if g2:
            nloc, o = _vi(b, o)
            for _ in range(nloc):
                _, o = _vi(b, o)
                _, o = _vi(b, o)
                _, o = _vi(b, o)
                o += 1
            nup, o = _vi(b, o)
            for _ in range(nup):
                _, o = _vi(b, o)
        if o > len(b):
            raise ContainerError(f'prototype {index}: debug data past the end')
        return Proto(index, start, o, header, co, sizecode, raw_code, consts, cs, consts_end, kids, kids_start,
                     kids_end, linedefined)

    def _walk(self, p: Proto) -> None:
        code = bytearray(p.raw_code)
        off = 0
        logical = 0
        out = []
        while off < len(code):
            raw = code[off]
            if self.opmap is not None:
                if raw >= len(self.opmap):
                    p.walk_error = f'raw opcode 0x{raw:02x} at byte {off} is outside the opcode profile'
                    break
                op = self.opmap[raw]
                code[off] = op
            else:
                op = raw
            out.append((logical, off, op))
            off += 8 if op in CANONICAL_AUX else 4
            logical += 1
        if not p.walk_error and off != len(code):
            p.walk_error = f'instruction walk ends at byte {off}, code has {len(code)} bytes'
        p.canonical_code = bytes(code)
        p.instructions = out

    # -- queries -------------------------------------------------------------------------------------------------
    def string(self, index1: int) -> bytes | None:
        return self.pool[index1 - 1] if 1 <= index1 <= len(self.pool) else None

    def instruction(self, p: Proto, logical: int) -> tuple[int, int, int] | None:
        return p.instructions[logical] if 0 <= logical < len(p.instructions) else None

    def aux(self, p: Proto, byte_offset: int) -> int:
        return struct.unpack_from('<I', p.canonical_code, byte_offset + 4)[0]

    def namecall_name(self, p: Proto, logical: int) -> tuple[str, object]:
        """('hash', u32) or ('string', text) of a NAMECALL's method key; ('error', reason) otherwise."""
        ins = self.instruction(p, logical)
        if ins is None:
            return 'error', f'prototype {p.index} has {len(p.instructions)} instructions, no index {logical}'
        _, off, op = ins
        if op != OP_NAMECALL:
            return 'error', f'instruction {logical} of prototype {p.index} is opcode 0x{op:02x}, not NAMECALL'
        k = self.aux(p, off)
        if k >= len(p.consts):
            return 'error', f'NAMECALL constant index {k} outside the constant table ({len(p.consts)})'
        c = p.consts[k]
        if c.tag == 1:
            return 'hash', c.value
        if c.tag == 3:
            s = self.string(c.value)
            return 'string', (s or b'').decode('utf-8', 'replace')
        return 'error', f'NAMECALL constant has tag {c.tag}'

    def fingerprint(self, p: Proto) -> str:
        h = hashlib.sha256()
        h.update(p.header)
        h.update(struct.pack('<II', p.sizecode, len(p.kids)))
        h.update(p.canonical_code)
        for c in p.consts:
            h.update(bytes([c.tag]))
            if c.tag == 3:
                s = self.string(c.value) or b''
                h.update(struct.pack('<I', len(s)) + s)
            elif c.tag == 6:
                h.update(b'closure')
            elif c.tag in (1, 4):
                h.update(struct.pack('<I', c.value))
            elif c.tag == 2:
                h.update(struct.pack('<d', c.value))
            else:
                h.update(repr(c.value).encode())
        return h.hexdigest()[:16]

    def shape(self, p: Proto) -> str:
        return hashlib.sha256(bytes(op for _, _, op in p.instructions)).hexdigest()[:16]

    def constant_hashes(self) -> set[int]:
        """Every tag-1 native-name hash constant in the module."""
        return {c.value for p in self.protos for c in p.consts if c.tag == 1}

    def walk_errors(self) -> list[str]:
        return [f'prototype {p.index}: {p.walk_error}' for p in self.protos if p.walk_error]


# -- synthetic mutation helpers (used only by the mutation proof, on copies) -------------------------------------
def rebuild_with_protos(m: Module, order: list[int]) -> bytes:
    """Re-serialise `m` with the prototypes listed in `order` (old indices, new order; an index may repeat to insert a
    copy). References to an old prototype go to its first occurrence; references to dropped prototypes are removed
    from child lists and closure constants pointing at them are redirected to prototype 0. Used only to synthesise a
    shifted or removed function for the mutation proof."""
    new_index: dict[int, int] = {}
    for new, old in enumerate(order):
        new_index.setdefault(old, new)
    b = m.data
    out = bytearray(b[:m.nps_offset])
    out += _enc_vi(len(order))
    for old in order:
        p = m.protos[old]
        rec = bytearray(b[p.start:p.consts_start])
        rec += _enc_vi(len(p.consts))
        for c in p.consts:
            if c.tag == 6:
                rec.append(6)
                rec += _enc_vi(new_index.get(c.value, 0))
            else:
                rec += b[c.start:c.end]
        kids = [new_index[k] for k in p.kids if k in new_index]
        rec += _enc_vi(len(kids))
        for k in kids:
            rec += _enc_vi(k)
        rec += b[p.kids_end:p.end]
        out += rec
    out += _enc_vi(new_index.get(m.main_index, len(order) - 1))
    return bytes(out)


def read_module(path: Path, opmap: list[int] | None) -> Module:
    return Module(path.read_bytes(), opmap)
