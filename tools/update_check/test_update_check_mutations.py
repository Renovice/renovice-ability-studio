#!/usr/bin/env python3
"""Mutation proof for the post-update check: synthetic breakage on COPIES must come out BROKEN with the right reason.

Every mutation is written under <workspace>/work/temp/update-check/mutations/<case>/ (copied stock modules served
through --stock-overlay, or a copied Warframe.x64.exe passed with --exe). The installed game is only read.
No old game build is used: the mutations are made from the current build's own bytes.

    python repos/apps/ability-editor/tools/update_check/test_update_check_mutations.py

Cases:
  control            no mutation: no BROKEN client-build item (the server-source row is a separate product)
  shifted-prototype  SurvivalMission with a copy of prototype 0 inserted first (every later prototype +1)
  shifted-callsite   BardMusic (Mallet) shifted the same way: the PushFloatArg callsite moves to P17
  literal-preimage   the extraction-countdown LOADN 60 -> 61 at its recipe offset
  removed-function   TerritoryMission without prototype 35 (a hooked entry and engine-parameter reader)
  exe-signature      Warframe.x64.exe copy: one byte of the ScriptMgr lock-enter thunk and of the engine
                     parameter writer push_value prologue changed
  content-key        OmegaRerollSelection (the Riven lock replacement's target) with one string byte changed
Exit code 0 when every expectation holds.
"""
from __future__ import annotations

import json
import shutil
import sys
from pathlib import Path

TOOL = Path(__file__).resolve().parent
sys.path.insert(0, str(TOOL))
import renovice_update_check as UC  # noqa: E402
import uc_bytecode as B  # noqa: E402
import uc_cache  # noqa: E402
import uc_pe  # noqa: E402

GAME = UC.DEFAULT_GAME


def setup():
    ws = UC.workspace_root()
    wsj = json.loads((ws / 'WORKSPACE.json').read_text(encoding='utf-8'))
    temp = ws / wsj['work']['temp'] / 'update-check'
    oodle = ws / wsj['vendor']['misc_tools'] / 'warframe-cache-tools' / 'lib' / 'oo2core_9.dll'
    folder, _ = uc_cache.extract_stock(GAME, temp, oodle, lambda *a: None)
    opmap = B.load_opcode_profile((ws / wsj['repos']['de_luau_toolchain'] / 'src' / 'de_opcode_profile.h').read_text())
    return ws, temp / 'mutations', folder, opmap


def run_case(name: str, out_root: Path, extra: list[str]) -> dict:
    out = out_root / name / 'report'
    code = UC.main(['--quiet', '--out', str(out), *extra])
    report = json.loads((out / 'update_check_report.json').read_text(encoding='utf-8'))
    report['exit'] = code
    return report


def find(report: dict, status: str, check: str, name_part: str = '', reason_part: str = '', feature_part: str = ''):
    return [i for i in report['items'] if i['status'] == status and i['check'] == check and name_part in i['name']
            and reason_part in i['reason'] and (not feature_part or any(feature_part in f for f in i['features']))]


def main() -> int:
    ws, root, stock, opmap = setup()
    if root.exists():
        shutil.rmtree(root)
    results = []

    def expect(case: str, report: dict, label: str, hits: list):
        ok = bool(hits)
        results.append((case, label, ok))
        print(f'{"PASS" if ok else "FAIL"}  {case}: {label}')
        if hits:
            print(f'        -> [{hits[0]["status"]}] {hits[0]["name"]} :: {hits[0]["reason"][:230]}')
            if hits[0]['features']:
                print(f'           affects: {"; ".join(hits[0]["features"][:2])}')

    def overlay(case: str, files: dict[str, bytes]) -> list[str]:
        d = root / case / 'overlay'
        d.mkdir(parents=True, exist_ok=True)
        for name, data in files.items():
            (d / name).write_bytes(data)
        return ['--stock-overlay', str(d)]

    def module(name: str) -> B.Module:
        return B.Module((stock / name).read_bytes(), opmap)

    # control -----------------------------------------------------------------------------------------------------------
    rep = run_case('control', root, [])
    blocking = [i for i in rep['items'] if i['status'] == 'BROKEN' and i['check'] != 'missions.registry_row.server']
    results.append(('control', 'no BROKEN client-build item', not blocking))
    print(f'{"PASS" if not blocking else "FAIL"}  control: no BROKEN client-build item '
          f'({rep["summary"]["total"]})' + (f' first: {blocking[0]["name"]} {blocking[0]["reason"]}' if blocking else ''))

    # shifted prototype (luaCalls) ---------------------------------------------------------------------------------------
    m = module('Lotus_Scripts_Modes_SurvivalMission.lua_B')
    data = B.rebuild_with_protos(m, [0] + list(range(len(m.protos))))
    rep = run_case('shifted-prototype', root, overlay('shifted-prototype', {'Lotus_Scripts_Modes_SurvivalMission.lua_B': data}))
    expect('shifted-prototype', rep, 'SurvivalMission content key changed',
           find(rep, 'BROKEN', 'scripts.content_key', 'SurvivalMission', 'content key changed', 'Missions: Survival'))
    expect('shifted-prototype', rep, 'luaCalls[67] fingerprint mismatch, identical prototype now 68',
           find(rep, 'BROKEN', 'hooks.lua_call', 'f10a043e7f825db2 luaCalls[67]', 'prototype 67 fingerprint mismatch',
                'Missions: Survival') and
           find(rep, 'BROKEN', 'hooks.lua_call', 'f10a043e7f825db2 luaCalls[67]', 'identical prototype is now 68'))
    expect('shifted-prototype', rep, 'verify-missions rows on SurvivalMission fail on the stock SHA-256',
           find(rep, 'BROKEN', 'missions.registry_row', 'survival.', 'stock SHA-256 mismatch'))

    # shifted callsite (nativeCalls PushFloatArg) -----------------------------------------------------------------------
    m = module('Lotus_Powersuits_Bard_Abilities_BardMusic.lua_B')
    data = B.rebuild_with_protos(m, [0] + list(range(len(m.protos))))
    rep = run_case('shifted-callsite', root, overlay('shifted-callsite', {'Lotus_Powersuits_Bard_Abilities_BardMusic.lua_B': data}))
    expect('shifted-callsite', rep, 'Mallet PushFloatArg P16 i596: prototype 16 is now 17, callsite still NAMECALL',
           find(rep, 'BROKEN', 'hooks.native_call', 'nativeCalls.PushFloatArg P16 i596', 'prototype 16 is now 17'))
    expect('shifted-callsite', rep, 'Octavia Mallet No Cover replacement target changed',
           find(rep, 'BROKEN', 'content.keys', 'ec368d4901690a15 (Octavia Mallet No Cover', 'content keys not in this build'))

    # literal preimage ---------------------------------------------------------------------------------------------------
    lit = json.loads((GAME / 'OpenWF/CustomScripts/Packages/Missions/literals.json').read_text(encoding='utf-8'))
    value = lit['values']['gamerules.extraction_countdown_endless']
    site = value['drives'][0]['sites'][0]
    fname = lit['modules'][value['module']]['file']
    data = bytearray((stock / fname).read_bytes())
    assert data[site['offset']:site['offset'] + 4].hex() == site['expected']
    data[site['offset'] + 2] += 1                                     # LOADN immediate 60 -> 61
    rep = run_case('literal-preimage', root, overlay('literal-preimage', {fname: bytes(data)}))
    want = site['expected'][:4] + f'{int(site["expected"][4:6], 16) + 1:02x}' + site['expected'][6:]
    expect('literal-preimage', rep, f'recipe site preimage changed at offset {site["offset"]}',
           find(rep, 'BROKEN', 'missions.literal_recipe', 'gamerules.extraction_countdown_endless',
                f'preimage changed at offset {site["offset"]}: expected {site["expected"]} found {want}',
                'Extraction (endless)'))

    # removed function ---------------------------------------------------------------------------------------------------
    m = module('Lotus_Scripts_Modes_TerritoryMission.lua_B')
    data = B.rebuild_with_protos(m, [i for i in range(len(m.protos)) if i != 35])
    rep = run_case('removed-function', root, overlay('removed-function', {'Lotus_Scripts_Modes_TerritoryMission.lua_B': data}))
    expect('removed-function', rep, 'luaCalls[35]: no prototype with the baseline fingerprint remains',
           find(rep, 'BROKEN', 'hooks.lua_call', 'c9605470a8c47d8d luaCalls[35]', 'function changed or removed',
                'Missions: Interception'))
    expect('removed-function', rep, 'luaCalls[37]: identical prototype is now 36',
           find(rep, 'BROKEN', 'hooks.lua_call', 'c9605470a8c47d8d luaCalls[37]', 'identical prototype is now 36'))
    expect('removed-function', rep, 'engine_params.json override on TerritoryMission broken',
           find(rep, 'BROKEN', 'missions.engine_param', 'c9605470a8c47d8d', 'not in this build'))

    # executable signature range ----------------------------------------------------------------------------------------
    exe = bytearray((GAME / 'Warframe.x64.exe').read_bytes())
    img = uc_pe.Image(bytes(exe))

    def file_offset(rva: int) -> int:
        for _name, va, vsize, roff, rsize in img.sections:
            if va <= rva < va + max(vsize, rsize):
                return rva - va + roff
        raise ValueError(hex(rva))
    thunks = img.scan('48 8B 09 48 8B 09 48 FF 25 ? ? ? ?')
    slot = img.import_slot('KERNEL32.dll', 'EnterCriticalSection')
    enter = next(t for t in thunks if img.rel32_target(t + 9) == slot)
    exe[file_offset(enter) + 1] ^= 0x01                               # mov rcx,[rcx] -> another opcode byte
    exe[file_offset(0x191A010) + 4] ^= 0x01                           # push_value prologue
    d = root / 'exe-signature'
    d.mkdir(parents=True, exist_ok=True)
    (d / 'Warframe.x64.exe').write_bytes(bytes(exe))
    rep = run_case('exe-signature', root, ['--exe', str(d / 'Warframe.x64.exe')])
    expect('exe-signature', rep, 'DE_VM_AUTHORITY lock-enter: 0 matches',
           find(rep, 'BROKEN', 'native.de_vm_authority', 'lock-enter', 'matches=0', 'DE Lua API'))
    expect('exe-signature', rep, 'engine param push_value range mismatch',
           find(rep, 'BROKEN', 'native.engine_params.range', '0x191a010', 'push-value-prologue-or-type-dispatch-mismatch'))
    expect('exe-signature', rep, 'changed executable is not in the supported-build allowlist',
           find(rep, 'BROKEN', 'build.allowlist.hotfix', 'supported_client_sha256_44', 'is not in the installed'))
    expect('exe-signature', rep, 'per-build ENGINE_DAMAGE table has no registration',
           find(rep, 'BROKEN', 'build.table.engine_damage', '', 'has no registration'))

    # content key ---------------------------------------------------------------------------------------------------------
    name = 'Lotus_Interface_OmegaRerollSelection.lua_B'
    m = module(name)
    data = bytearray(m.data)
    s, e = next((s, e) for s, e in m.pool_spans if e - s > 4 and bytes(data[s:e]).isascii())
    data[s] = ord('A') if data[s] != ord('A') else ord('B')
    rep = run_case('content-key', root, overlay('content-key', {name: bytes(data)}))
    expect('content-key', rep, 'Riven lock replacement: replaced content key gone',
           find(rep, 'BROKEN', 'content.keys', '477479ee5209dc94 (Riven Lock script)',
                '477479ee5209dc94 (Lotus_Interface_OmegaRerollSelection.lua_B: changed ->', 'Riven Lock'))
    expect('content-key', rep, 'OmegaRerollSelection content key changed',
           find(rep, 'BROKEN', 'scripts.content_key', 'OmegaRerollSelection', 'content key changed', 'Riven Lock'))

    failed = [r for r in results if not r[2]]
    print(f'\nMUTATION PROOF {"PASS" if not failed else "FAIL"}: {len(results) - len(failed)}/{len(results)} expectations')
    return 1 if failed else 0


if __name__ == '__main__':
    sys.exit(main())
