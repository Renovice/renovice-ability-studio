"""Read-only DE Luau (09 03) prototype walker for registry anchoring (offline analysis only).

Normalises the U44 dispatch opcodes to the canonical map with the pinned U44 dispatch table
(RESEARCH/U44_AUTHORING_2026-09-27/scripts/inspect_current.py) and walks every prototype with the
legacy flat loader. Offsets are file offsets and are identical in raw and canonical bytes; only
opcode bytes differ. Nothing here writes files.
"""
from pathlib import Path
import hashlib, runpy, struct, sys

ROOT = Path(__file__).resolve().parents[6]
EDITOR = ROOT / 'repos/apps/ability-editor'
sys.path.insert(0, str(ROOT / 'archive/legacy-decompilers/transpiler-lab'))
import _flat_loader as F  # noqa: E402
import parse_luab as P    # noqa: E402

normalize = runpy.run_path(str(EDITOR / 'RESEARCH/U44_AUTHORING_2026-09-27/scripts/inspect_current.py'))['normalize']
WIDE = {int(x, 16) for x in '02 03 0c 0f 15 17 1c 1e 20 21 23 26 27 2c 2d 33 34 36 37 3a 3d 3f 41 43 46 4a'.split()}
LOADN, SETTABLEKS, SETTABLE = 0x12, 0x15, 0x2a
RAW_LOADN = 0x08  # U44 dispatch byte for LOADN (verified opcode profile; mission_profiles.inl writes the same byte)


def body_key(data):
    x = 1469598103934665603
    for v in data:
        x = ((x ^ v) * 1099511628211) & 0xffffffffffffffff
    return f'{x:016x}'


def sha256(data):
    return hashlib.sha256(data).hexdigest().upper()


class Module:
    def __init__(self, raw):
        self.raw = bytes(raw)
        self.canonical = bytes(normalize(raw))
        self.pool, _, _ = F.parse_pool_and_nps(self.canonical)
        _, entries = F.load_flat(self.canonical)
        self.protos = []
        for header, *_ in entries:
            co, ln, _ = F.header_at(self.canonical, header)
            _, consts, _ = P.parse_consts(self.canonical, co + ln)
            ins, off = [], co
            while off < co + ln:
                width = 8 if self.canonical[off] in WIDE else 4
                ins.append((off, self.canonical[off:off + width]))
                off += width
            assert off == co + ln
            self.protos.append((ins, consts))
        self.root = len(self.protos) - 1

    def key_string(self, proto, word):
        if len(word) != 8:
            return None
        k = struct.unpack_from('<I', word, 4)[0]
        consts = self.protos[proto][1]
        if k < len(consts) and consts[k][0] == 'str':
            return self.pool[consts[k][1] - 1].decode('utf-8', 'replace')
        return None

    @staticmethod
    def loadn(word):
        """(register, signed immediate) for a canonical LOADN word, else None."""
        if len(word) == 4 and word[0] == LOADN:
            return word[1], struct.unpack_from('<h', word, 2)[0]
        return None

    def field_literal_sites(self, proto, field, value):
        """Every `LOADN rX, value` immediately stored by `SETTABLEKS rX, t, "field"` in one prototype."""
        ins = self.protos[proto][0]
        out = []
        for i in range(len(ins) - 1):
            load = self.loadn(ins[i][1])
            if not load or load[1] != value:
                continue
            nxt = ins[i + 1][1]
            if nxt[0] == SETTABLEKS and nxt[1] == load[0] and self.key_string(proto, nxt) == field:
                out.append((i, ins[i][0], load[0]))
        return out
