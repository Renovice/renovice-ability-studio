#!/usr/bin/env python3
"""Regression test of uc_sideload (2026-10-04).

  sideloadify-identity  the original Steam 2026.09.30.14.45 executable (DependentLoadFlags 0x800, kept in
                        work/backups/steam-exe-2026.09.30.14.45-unsideloadified) patched by uc_sideload is
                        byte-identical to the Sideloadify 1.1.0 result (sha256 ab759d95..., the certified client)
  references            every stored reference image: a clean one is left byte-identical, a blocked one is fixed by
                        the one field
  synthetic             a copy with APPLICATION_DIR (0x200) or DEFAULT_DIRS (0x1000) set is not blocked; 0x800 is

Offline; reads only workspace copies. Cases whose input file is absent are reported SKIP.
    python repos/apps/ability-editor/tools/update_check/test_sideload.py
"""
from __future__ import annotations

import hashlib
import struct
import sys
from pathlib import Path

TOOL = Path(__file__).resolve().parent
sys.path.insert(0, str(TOOL))
import uc_sideload as SL  # noqa: E402

WS = TOOL.parents[4]
ORIGINAL = WS / 'work/backups/steam-exe-2026.09.30.14.45-unsideloadified/Warframe.x64.exe'
SIDELOADIFY_SHA = 'ab759d955ee56d08be6f27e2a4272914d64f216196ece8e994393f4a5c92db4d'
REFERENCES = sorted((WS / 'work/native-update/reference').glob('*/Warframe.x64.exe'))


def main() -> int:
    results = []

    def check(case, label, ok, detail=''):
        results.append(bool(ok))
        print(f'{"PASS" if ok else "FAIL"}  {case}: {label}' + (f'  [{detail}]' if detail and not ok else ''))

    if ORIGINAL.is_file():
        data = ORIGINAL.read_bytes()
        flags = SL.dependent_load_flags(data)
        check('sideloadify-identity', 'original blocks the proxy DLL (0x800)', flags == 0x800 and SL.blocks_proxy(flags),
              hex(flags))
        patched = SL.sideload(data)
        check('sideloadify-identity', 'patch == Sideloadify 1.1.0 output', hashlib.sha256(patched).hexdigest() == SIDELOADIFY_SHA,
              hashlib.sha256(patched).hexdigest())
        check('sideloadify-identity', 'exactly one field changed', sum(a != b for a, b in zip(data, patched)) == 1)
        check('sideloadify-identity', 'patched client loads the proxy', not SL.blocks_proxy(SL.dependent_load_flags(patched)))
        check('sideloadify-identity', 'idempotent', SL.sideload(patched) == patched)
        off = SL._field_offset(data)
        for flags_set, blocked in ((0x200, False), (0x1000, False), (0x800 | 0x200, False), (0x800, True)):
            buf = bytearray(data)
            struct.pack_into('<H', buf, off, flags_set)
            check('synthetic', f'flags 0x{flags_set:x} blocked={blocked}',
                  SL.blocks_proxy(SL.dependent_load_flags(bytes(buf))) == blocked)
    else:
        print(f'SKIP  sideloadify-identity: {ORIGINAL} not present')
    # the reference store also holds unpatched Steam images (e.g. the first 2026.09.30.14.45 run, the Ice blade copy)
    for ref in REFERENCES:
        data = ref.read_bytes()
        flags = SL.dependent_load_flags(data)
        if SL.blocks_proxy(flags):
            fixed = SL.sideload(data)
            check('references', f'{ref.parent.name} (0x{flags:x}) is fixed by one field',
                  not SL.blocks_proxy(SL.dependent_load_flags(fixed)) and sum(a != b for a, b in zip(data, fixed)) <= 2)
        else:
            check('references', f'{ref.parent.name} (0x{flags:x}) is left untouched', SL.sideload(data) == data)
    ok = all(results) and results
    print(f'\nSIDELOAD TEST {"PASS" if ok else "FAIL"}: {sum(results)}/{len(results)} expectations')
    return 0 if ok else 1


if __name__ == '__main__':
    sys.exit(main())
