"""Regression test for uc_adopt (2026-10-09): --add-to-stage records a by-hand addition completely, and the adoption
renames replaced registrations (remove.txt) and registers recorded additions in authored_addons.json. Synthetic stage and
a temporary copy of authored_addons.json; the real files are not written. Usage: python test_adopt_flow.py
"""
import json
import shutil
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import uc_adopt as A  # noqa: E402

failures = 0


def check(ok, name):
    global failures
    print(('PASS' if ok else 'FAIL') + '\t' + name)
    failures += 0 if ok else 1


tmp = Path(tempfile.mkdtemp(prefix='uc-adopt-'))
try:
    stage = tmp / 'stage'
    (stage / 'install' / A.CUSTOM / 'Config').mkdir(parents=True)
    (stage / 'UPDATE_REPORT.json').write_text('{}', encoding='utf-8')
    (stage / 'README.md').write_text('# set\n', encoding='utf-8')
    (stage / 'remove.txt').write_text(A.CUSTOM + 'Packages/Pkg/1111111111111111 (Pkg old).lua_B\treplaced by the rebased '
                                      'replacement 2222222222222222 (Pkg old).lua_B\n', encoding='utf-8')
    (stage / 'install' / A.CUSTOM / 'Config' / 'ScriptStates.json').write_text(
        json.dumps({'schema': 2, 'scripts': {'package:pkg': True}, 'values': {}}), encoding='utf-8')
    member = tmp / '3333333333333333 (Pkg new).lua_B'
    member.write_bytes(b'\x09\x03member')
    rel = A.CUSTOM + 'Packages/Pkg/3333333333333333 (Pkg new).lua_B'
    replaced = A.CUSTOM + 'Packages/Pkg/4444444444444444 (Pkg gone).lua_B'
    A.add_to_stage(stage, member, rel, replaced, 'repos/x/Scripts/Pkg', 'new member', False, lambda *a: None)
    entries = json.loads((stage / A.MANUAL).read_text(encoding='utf-8'))
    check(len(entries) == 1 and entries[0]['install'] == rel and not entries[0]['ships_disabled'], 'addition recorded in manual_additions.json')
    check((stage / 'install' / rel).read_bytes() == member.read_bytes(), 'file copied into install/')
    remove = (stage / 'remove.txt').read_text(encoding='utf-8')
    check(f'{replaced}\treplaced by 3333333333333333 (Pkg new).lua_B (manual addition)' in remove, 'remove.txt names the replaced file')
    states = json.loads((stage / 'install' / A.CUSTOM / 'Config' / 'ScriptStates.json').read_text(encoding='utf-8'))['scripts']
    check(not any(k.startswith('member:') for k in states), 'no member switch written (retired since R13)')
    try:
        A.add_to_stage(stage, member, rel, None, None, 'member off', True, lambda *a: None)
        refused = False
    except SystemExit as e:
        refused = 'R13' in str(e)
    check(refused and len(json.loads((stage / A.MANUAL).read_text(encoding='utf-8'))) == 1,
          'ships disabled: a package member is refused before anything is written (no member switch since R13)')
    addon = tmp / '5555555555555555.Solo.target.addon.lua_B'
    addon.write_bytes(b'	addon')
    A.add_to_stage(stage, addon, A.CUSTOM + 'Addons/' + addon.name, None, None, 'untested addon', True, lambda *a: None)
    states = json.loads((stage / 'install' / A.CUSTOM / 'Config' / 'ScriptStates.json').read_text(encoding='utf-8'))['scripts']
    check(states.get('target-addon:5555555555555555.solo.target.addon.lua_b') is False and states.get('package:pkg') is True,
          'ships disabled: a loose addon gets its own switch off, other switches kept')
    entries = [e for e in json.loads((stage / A.MANUAL).read_text(encoding='utf-8')) if e['install'] == rel]
    sums = (stage / 'SHA256SUMS').read_text(encoding='utf-8')
    check(f'{entries[0]["sha256"]}  install/{rel}' in sums and 'manual_additions.json' in sums, 'SHA256SUMS covers the addition')
    readme = (stage / 'README.md').read_text(encoding='utf-8')
    check(A.README_HEAD in readme and rel in readme and readme.count(A.README_HEAD) == 1, 'README section written once')
    A.add_to_stage(stage, member, rel, replaced, 'repos/x/Scripts/Pkg', 'new member', False, lambda *a: None)
    check(len(json.loads((stage / A.MANUAL).read_text(encoding='utf-8'))) == 2      # the member and the addon
          and (stage / 'README.md').read_text(encoding='utf-8').count(A.README_HEAD) == 1
          and (stage / 'remove.txt').read_text(encoding='utf-8').count(replaced) == 1, 'adding the same file again is idempotent')

    authored = tmp / 'authored_addons.json'
    data = json.loads(A.AUTHORED.read_text(encoding='utf-8'))
    data['replacements'].append({'installed': 'Packages/Pkg/1111111111111111 (Pkg old).lua_B', 'source_project': 'p', 'note': 'n'})
    authored.write_text(A._authored_text(data), encoding='utf-8')
    real = A.AUTHORED
    A.AUTHORED = authored
    try:
        changed = A.update_authored(stage, lambda *a: None)
        after = json.loads(authored.read_text(encoding='utf-8'))
        installed = [e['installed'] for e in after['replacements']]
        check('Packages/Pkg/2222222222222222 (Pkg old).lua_B' in installed
              and 'Packages/Pkg/1111111111111111 (Pkg old).lua_B' not in installed, 'replaced registration renamed from remove.txt')
        check('Packages/Pkg/3333333333333333 (Pkg new).lua_B' in installed, 'recorded addition registered with its source project')
        check(len(changed) == 2 and A.update_authored(stage, lambda *a: None) == [], 'adoption is idempotent')
    finally:
        A.AUTHORED = real
    check(json.loads(real.read_text(encoding='utf-8')) == json.loads(A._authored_text(json.loads(real.read_text(encoding='utf-8')))),
          'the real authored_addons.json is untouched and round-trips')
finally:
    shutil.rmtree(tmp, ignore_errors=True)
print('ADOPT FLOW ' + ('PASS' if failures == 0 else f'FAIL ({failures})'))
sys.exit(1 if failures else 0)
