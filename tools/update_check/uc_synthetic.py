"""Synthetic "new build" mutations for the update-resilience regression test (copies only).

Every helper takes a parsed stock module of the CURRENT build and returns new container bytes; nothing reads or writes the
game folder. The mutations model what a Warframe update does to a script, in a form the U44 container still parses:

  insert_protos       new functions inserted before existing ones (every later prototype index shifts, like U44 Survival
                      64 -> 67); an inserted copy can be made unique by changing one LOADN immediate
  add_pool_string     a new string in the module string pool (every byte offset after the pool moves; prototype and
                      instruction indices stay)
  insert_moves        k no-op `MOVE rA, rA` instructions inserted inside one prototype (every later instruction index of
                      that function shifts; branch offsets, fast-call skips and LOADB skips across the insertion are
                      corrected; the function's line info is dropped)
  set_loadn           one LOADN immediate changed in place (a changed stock default)
"""
from __future__ import annotations

import struct

import uc_bytecode as B
import uc_remap as RM

OP_MOVE, OP_LOADB = 0x14, 0x04
FAST_BASE = {0x10: 1, 0x19: 1, 0x26: 2, 0x0c: 2}


def _raw_of(opmap: list[int]) -> dict[int, int]:
    """canonical -> raw U44 byte."""
    return {canonical: raw for raw, canonical in enumerate(opmap)}


def insert_protos(m: B.Module, at: int, sources: list[int], opmap: list[int] | None = None,
                  unique: bool = True) -> bytes:
    """Insert copies of `sources` (old indices) before old prototype `at`. With `unique`, each copy's first LOADN gets its
    immediate + 1 (new function, own fingerprint)."""
    n = len(m.protos)
    order = list(range(at)) + list(sources) + list(range(at, n))
    data = bytearray(B.rebuild_with_protos(m, order))
    if not unique:
        return bytes(data)
    new = B.Module(bytes(data), opmap)
    for k in range(len(sources)):
        p = new.protos[at + k]
        for logical, off, op in p.instructions:
            if op == RM.OP_LOADN:
                pos = p.code_start + off + 2
                imm = struct.unpack_from('<h', data, pos)[0]
                struct.pack_into('<h', data, pos, imm + 1 if imm < 32000 else imm - 1)
                break
    return bytes(data)


def add_pool_string(m: B.Module, text: str) -> bytes:
    b = m.data
    o = 2
    nstr, o2 = B._vi(b, o)
    end = m.pool_spans[-1][1] if m.pool_spans else o2
    s = text.encode('utf-8')
    return b[:2] + B._enc_vi(nstr + 1) + b[o2:end] + B._enc_vi(len(s)) + s + b[end:]


def set_loadn(m: B.Module, proto: int, logical: int, value: int) -> bytes:
    p = m.protos[proto]
    _, off, op = p.instructions[logical]
    if op != RM.OP_LOADN:
        raise ValueError(f'P{proto} i{logical} is not a LOADN')
    data = bytearray(m.data)
    struct.pack_into('<h', data, p.code_start + off + 2, value)
    return bytes(data)


def insert_moves(m: B.Module, proto: int, before: int, count: int, opmap: list[int]) -> bytes:
    """Insert `count` no-op MOVE instructions before logical instruction `before` of prototype `proto`."""
    p = m.protos[proto]
    raw_of = _raw_of(opmap)
    words = []                                   # (canonical op, raw bytes of the instruction incl. aux)
    for logical, off, op in p.instructions:
        width = 8 if op in B.CANONICAL_AUX else 4
        words.append((op, bytearray(p.raw_code[off:off + width])))
    pos = [0]
    for op, w in words:
        pos.append(pos[-1] + len(w) // 4)
    at_word = pos[before]
    # a fast call whose skip range covers the insertion point, or an unknown branch form, makes the edit unsafe
    for i, (op, w) in enumerate(words):
        if op not in RM.JUMP_D and op not in FAST_BASE and op != OP_LOADB:
            continue
        here = pos[i]
        if op in RM.JUMP_D:
            target = here + 1 + struct.unpack_from('<h', w, 2)[0]
        elif op in FAST_BASE:
            target = here + FAST_BASE[op] + w[3]
        else:
            target = here + 1 + w[3]
        new_here = here + (count if here >= at_word else 0)
        new_target = target + (count if target >= at_word else 0)
        if op in RM.JUMP_D:
            struct.pack_into('<h', w, 2, new_target - new_here - 1)
        elif op in FAST_BASE:
            skip = new_target - new_here - FAST_BASE[op]
            if not 0 <= skip <= 255:
                raise ValueError('fast-call skip out of range')
            w[3] = skip
        else:
            if w[3]:
                w[3] = new_target - new_here - 1
    target_reg = words[before][1][1] if before < len(words) else 0
    move = bytes([raw_of[OP_MOVE], target_reg, target_reg, 0])
    code = bytearray()
    for i, (op, w) in enumerate(words):
        if i == before:
            code += move * count
        # store the raw opcode back (the canonical op was only used to classify)
        code += w
    if before >= len(words):
        code += move * count
    b = m.data
    rec = bytearray(b[p.start:p.start + 5])
    o = p.start + 5
    slen, o2 = B._vi(b, o)
    rec += b[o:o2 + slen]
    rec += B._enc_vi(p.sizecode + count) + code
    rec += b[p.consts_start:p.kids_end]
    o = p.kids_end
    _, o3 = B._vi(b, o)          # linedefined
    _, o4 = B._vi(b, o3)         # debugname
    rec += b[o:o4]
    g1 = b[o4]
    o5 = o4 + 1
    if g1:
        kk = b[o5] & 0x3F
        o5 += 1 + p.sizecode + 4 * ((((p.sizecode - 1) >> kk) + 1) if p.sizecode > 0 else 0)
    rec.append(0)                # line info dropped (synthetic edit)
    rec += b[o5:p.end]
    return b[:p.start] + bytes(rec) + b[p.end:]


def adopt_child(m: B.Module, parent: int, child: int) -> bytes:
    """Append `child` to the child list of prototype `parent` (a second function created by the same parent; with a
    near copy this makes two equally plausible candidates for one function)."""
    p = m.protos[parent]
    b = m.data
    kids = list(p.kids) + [child]
    rec = b[p.start:p.kids_start] + B._enc_vi(len(kids)) + b''.join(B._enc_vi(k) for k in kids) + b[p.kids_end:p.end]
    return b[:p.start] + rec + b[p.end:]
