"""Read-only PE32+ helpers: section-mapped image, pattern scans, import/export names, version string."""
from __future__ import annotations

import functools
import re
import struct


class Image:
    """A PE file mapped at its section RVAs (RVA == offset), like the in-process module the runtime scans."""

    def __init__(self, data: bytes):
        self.file = data
        nt = struct.unpack_from('<I', data, 0x3C)[0]
        if data[nt:nt + 4] != b'PE\0\0':
            raise ValueError('not a PE image')
        sections = struct.unpack_from('<H', data, nt + 6)[0]
        opt_size = struct.unpack_from('<H', data, nt + 20)[0]
        opt = nt + 24
        if struct.unpack_from('<H', data, opt)[0] != 0x20B:
            raise ValueError('not PE32+')
        image_size = struct.unpack_from('<I', data, opt + 56)[0]
        headers = struct.unpack_from('<I', data, opt + 60)[0]
        mem = bytearray(image_size)
        mem[:headers] = data[:headers]
        self.sections = []
        for i in range(sections):
            h = opt + opt_size + i * 40
            name = data[h:h + 8].rstrip(b'\0').decode('ascii', 'replace')
            vsize, va, rsize, roff = struct.unpack_from('<IIII', data, h + 8)
            copy = rsize if (rsize < vsize or vsize == 0) else vsize
            if copy:
                mem[va:va + copy] = data[roff:roff + copy]
            self.sections.append((name, va, vsize, roff, rsize))
        self.mem = bytes(mem)
        self.data_dirs = [struct.unpack_from('<II', data, opt + 112 + 8 * i) for i in range(16)]

    # -- scans -------------------------------------------------------------------------------------------------------
    def scan(self, pattern: str, limit: int | None = None) -> list[int]:
        rx = pattern_regex(pattern)
        hits = []
        pos = 0
        while True:
            m = rx.search(self.mem, pos)
            if not m:
                return hits
            hits.append(m.start())
            if limit is not None and len(hits) >= limit:
                return hits
            pos = m.start() + 1

    def scan_file(self, pattern: str) -> list[int]:
        rx = pattern_regex(pattern)
        hits, pos = [], 0
        while True:
            m = rx.search(self.file, pos)
            if not m:
                return hits
            hits.append(m.start())
            pos = m.start() + 1

    def u32(self, rva: int) -> int:
        return struct.unpack_from('<I', self.mem, rva)[0]

    def rel32_target(self, displacement_rva: int) -> int:
        return displacement_rva + 4 + struct.unpack_from('<i', self.mem, displacement_rva)[0]

    def bytes_at(self, rva: int, n: int) -> bytes:
        return self.mem[rva:rva + n]

    # -- imports / exports ---------------------------------------------------------------------------------------------
    def _cstr(self, rva: int) -> str:
        end = self.mem.index(b'\0', rva)
        return self.mem[rva:end].decode('ascii', 'replace')

    def imports(self) -> dict[str, list[tuple[str | None, int]]]:
        """{dll (as written): [(function name or None for ordinal, IAT slot RVA)]}"""
        rva, size = self.data_dirs[1]
        out: dict[str, list[tuple[str | None, int]]] = {}
        if not rva:
            return out
        off = rva
        while True:
            ilt, _ts, _fw, name_rva, iat = struct.unpack_from('<IIIII', self.mem, off)
            if not (ilt or name_rva or iat):
                return out
            dll = self._cstr(name_rva)
            entries = out.setdefault(dll, [])
            table = ilt or iat
            k = 0
            while True:
                thunk = struct.unpack_from('<Q', self.mem, table + 8 * k)[0]
                if thunk == 0:
                    break
                fn = None if thunk & (1 << 63) else self._cstr((thunk & 0x7FFFFFFF) + 2)
                entries.append((fn, iat + 8 * k))
                k += 1
            off += 20

    def import_slot(self, dll: str, function: str) -> int:
        """IAT slot bound by name, 0 when missing or ambiguous (mirrors de_vm_authority find_import_slot_rva)."""
        slots = [slot for name, entries in self.imports().items() if name.lower() == dll.lower()
                 for fn, slot in entries if fn == function]
        return slots[0] if len(slots) == 1 else 0

    def exports(self) -> list[str]:
        rva, size = self.data_dirs[0]
        if not rva:
            return []
        n_names = struct.unpack_from('<I', self.mem, rva + 24)[0]
        names_rva = struct.unpack_from('<I', self.mem, rva + 32)[0]
        return [self._cstr(struct.unpack_from('<I', self.mem, names_rva + 4 * i)[0]) for i in range(n_names)]

    # -- version resource ------------------------------------------------------------------------------------------------
    def product_version(self) -> str | None:
        """StringFileInfo ProductVersion (the build label the bootstrapper reads, e.g. 2026.09.28.13.06)."""
        key = 'ProductVersion'.encode('utf-16-le') + b'\0\0'
        rva, size = self.data_dirs[2]
        blob = self.mem[rva:rva + size] if rva else self.file
        i = blob.find(key)
        if i < 0:
            return None
        j = i + len(key)
        j += (-j) % 4 if rva else 0
        while j < len(blob) and blob[j:j + 2] == b'\0\0':
            j += 2
        end = blob.find(b'\0\0', j)
        while end != -1 and (end - j) % 2:
            end = blob.find(b'\0\0', end + 1)
        return blob[j:end].decode('utf-16-le', 'replace') if end != -1 else None


@functools.lru_cache(None)
def pattern_regex(pattern: str):
    parts = []
    for t in pattern.split():
        parts.append(b'.' if t in ('?', '??') else re.escape(bytes([int(t, 16)])))
    return re.compile(b''.join(parts), re.S)
