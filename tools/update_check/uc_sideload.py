"""Proxy-DLL loadability of Warframe.x64.exe (2026-10-04).

The bootstrapper is a proxy DLL (WTSAPI32.dll) in the game folder, loaded as a static import of the client. A client
whose load-config DependentLoadFlags restrict import resolution (2026.09.30.14.45 ships 0x800,
LOAD_LIBRARY_SEARCH_SYSTEM32) never loads it: no hook runs and the game stops with "Please run Warframe from the
Launcher". Upstream OpenWF's Download Latest DLL.ps1 runs Sideloadify 1.1.0 after every update; on this client it
changes exactly the two DependentLoadFlags bytes to 0. `sideload` does the same in Python (no downloaded binary runs),
and the update tool stages the patched executable with the original as rollback.
"""
from __future__ import annotations

import struct

LOAD_CONFIG_DIR = 10
DEPENDENT_LOAD_FLAGS = 0x4E              # IMAGE_LOAD_CONFIG_DIRECTORY64.DependentLoadFlags (WORD)
# flags that still search the folder of the executable for its static imports
APP_DIR_FLAGS = 0x100 | 0x200 | 0x1000   # DLL_LOAD_DIR, APPLICATION_DIR, DEFAULT_DIRS


def _field_offset(data: bytes) -> int | None:
    nt = struct.unpack_from('<I', data, 0x3C)[0]
    sections = struct.unpack_from('<H', data, nt + 6)[0]
    opt_size = struct.unpack_from('<H', data, nt + 20)[0]
    opt = nt + 24
    rva, size = struct.unpack_from('<II', data, opt + 112 + 8 * LOAD_CONFIG_DIR)
    if not rva:
        return None
    for i in range(sections):
        h = opt + opt_size + i * 40
        vsize, va, rsize, roff = struct.unpack_from('<IIII', data, h + 8)
        if va <= rva < va + max(vsize, rsize):
            off = rva - va + roff
            declared = struct.unpack_from('<I', data, off)[0]
            return off + DEPENDENT_LOAD_FLAGS if declared >= DEPENDENT_LOAD_FLAGS + 2 else None
    return None


def dependent_load_flags(data: bytes) -> int:
    off = _field_offset(data)
    return struct.unpack_from('<H', data, off)[0] if off is not None else 0


def blocks_proxy(flags: int) -> bool:
    """True when the client's static imports are not searched in its own folder."""
    return flags != 0 and not flags & APP_DIR_FLAGS


def sideload(data: bytes) -> bytes:
    """The executable with DependentLoadFlags cleared (Sideloadify's change); unchanged when nothing to clear."""
    off = _field_offset(data)
    if off is None or struct.unpack_from('<H', data, off)[0] == 0:
        return data
    out = bytearray(data)
    struct.pack_into('<H', out, off, 0)
    return bytes(out)
