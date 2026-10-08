#!/usr/bin/env python3
"""Regression test: root replacements that are PACKAGE MEMBERS (2026-10-08, Icebind Solo package).

The runtime (bootstrapper renovice/packages_core.hpp classify_member) admits an ordinary `<16-hex key> (label).lua_B`
file inside Packages/<folder>/ as a root replacement of that content key, and keys the package row as
`package:<folder lowercased>` (script_control.cpp). The update tool must see the same thing, or it cannot rebase the
member after an update. Offline only: a small module is compiled with the workspace toolchain into a temporary folder;
no game folder is read.

Checks:
  inventory     a package member `<key> (label).lua_B` is kind `replacement` with that key; the package state is read
                from the FOLDER id; a loose Inject file with a key prefix stays a one-shot (`inject`); a package member
                without a key prefix stays `inject` (the runtime rejects it as one-shot-inject-not-allowed-in-package)
  rebase        an instruction-level edit of the module, rebased onto a synthetic shifted build (one new function
                first), is AUTO and keeps the edit at the moved prototype

    python repos/apps/ability-editor/tools/update_check/test_package_replacements.py
Exit code 0 when every expectation holds.
"""
from __future__ import annotations

import json
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

TOOL = Path(__file__).resolve().parent
sys.path.insert(0, str(TOOL))
import renovice_update_check as UC  # noqa: E402
import uc_artifacts as ART  # noqa: E402
import uc_bytecode as B  # noqa: E402
import uc_content  # noqa: E402
import uc_remap as RM  # noqa: E402
import uc_synthetic as S  # noqa: E402

SOURCE = '''function Gate(count, max)
  if count ~= max then return 1 end
  return 2
end
function Other(a)
  return a + 1
end
'''


def main() -> int:
    ws = UC.workspace_root()
    wsj = json.loads((ws / 'WORKSPACE.json').read_text(encoding='utf-8'))
    tc = ws / wsj['repos']['de_luau_toolchain']
    opmap = B.load_opcode_profile((tc / 'src' / 'de_opcode_profile.h').read_text())
    results = []

    def check(label, ok, detail=''):
        results.append(bool(ok))
        print(f'{"PASS" if ok else "FAIL"}  {label}' + (f'  [{detail}]' if detail and not ok else ''))

    tmp = Path(tempfile.mkdtemp(prefix='renovice-pkg-repl-'))
    try:
        src = tmp / 'm.luau'
        src.write_text(SOURCE, encoding='utf-8')
        mod = tmp / 'm.lua_B'
        r = subprocess.run([str(tc / 'bin' / 'derecomp.exe'), 'recompile-u44', str(src), str(mod)],
                           capture_output=True, text=True, timeout=300)
        if r.returncode or not mod.is_file():
            print('FAIL  fixture compile: ' + (r.stdout + r.stderr).strip()[-300:])
            return 1
        stock = B.Module(mod.read_bytes(), opmap)
        # the edit: the `count ~= max` branch of Gate (JUMPIFEQ, canonical 0x37) becomes JUMPIFNOTLE (0x33)
        raw_of = {c: raw for raw, c in enumerate(opmap)}
        data = bytearray(stock.data)
        gate = next(p for p in stock.protos if any(op == 0x37 for _, _, op in p.instructions))
        logical, off, _ = next(x for x in gate.instructions if x[2] == 0x37)
        data[gate.code_start + off] = raw_of[0x33]
        repl = B.Module(bytes(data), opmap)

        custom = tmp / 'CustomScripts'
        pkg = custom / 'Packages' / 'SoloPkg'
        pkg.mkdir(parents=True)
        (custom / 'Inject').mkdir()
        member = f'{stock.key} (solo gate).lua_B'
        (pkg / member).write_bytes(repl.data)
        (pkg / 'Loose one-shot.lua_B').write_bytes(repl.data)
        (custom / 'Inject' / f'{stock.key}.oneshot.lua_B').write_bytes(repl.data)
        (pkg / 'package.json').write_text(json.dumps({'schema': 1, 'name': 'Solo Package', 'members': {
            member: {'label': 'Gate'}}, 'settings': {}}), encoding='utf-8')
        (custom / 'ScriptStates.json').write_text(json.dumps({'schema': 1, 'scripts': {'package:solopkg': False}}),
                                                  encoding='utf-8')
        inv = {s.rel: s for s in uc_content.inventory(custom)}
        s = inv.get(f'Packages/SoloPkg/{member}')
        check('package member <key> (label).lua_B is a replacement of its key',
              s is not None and s.kind == 'replacement' and s.keys == [stock.key], s and (s.kind, s.keys))
        check('package state is read from the folder id (package:solopkg = false)',
              s is not None and s.state == 'package disabled', s and s.state)
        check('package label is the manifest name and the member label', s is not None and s.label == 'Solo Package: Gate',
              s and s.label)
        o = inv.get('Packages/SoloPkg/Loose one-shot.lua_B')
        check('package member without a key prefix stays a one-shot (runtime rejects it)', o is not None and o.kind == 'inject',
              o and o.kind)
        i = inv.get(f'Inject/{stock.key}.oneshot.lua_B')
        check('loose Inject file with a key prefix stays a one-shot', i is not None and i.kind == 'inject', i and i.kind)

        shifted = B.Module(S.insert_protos(stock, 0, [len(stock.protos) - 1], opmap), opmap)
        res = ART.rebase_replacement(stock, repl, shifted, RM.ModuleMap(stock, shifted, 'm.lua_B'))
        ok = res['action'] == 'auto'
        if ok:
            out = B.Module(res['bytes'], opmap)
            q = out.protos[gate.index + 1]
            ok = q.instructions[logical][2] == 0x33 and res['new_key'] == shifted.key
        check('instruction-level package replacement rebases onto a shifted build (auto, edit kept)', ok,
              res.get('reason') or res.get('edits'))
        check('rebased artifact keeps the file label after the new key',
              (res.get('new_key', '') + member[16:]) == f'{shifted.key} (solo gate).lua_B')
    finally:
        shutil.rmtree(tmp, ignore_errors=True)
    print(f'{sum(results)}/{len(results)} PASS')
    return 0 if all(results) else 1


if __name__ == '__main__':
    sys.exit(main())
