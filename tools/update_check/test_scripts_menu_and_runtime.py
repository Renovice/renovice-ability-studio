"""Regression test for the Scripts-menu layout check (uc_topmenu) and the newest-session runtime check (uc_runtime)
(2026-10-09). Offline: the two stock TopMenu bodies of the update-check cache and synthetic loader logs in a temp folder.
Usage: python test_scripts_menu_and_runtime.py
"""
import os
import shutil
import sys
import tempfile
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import uc_bytecode as B  # noqa: E402
import uc_report as R  # noqa: E402
import uc_runtime as U  # noqa: E402
import uc_topmenu as T  # noqa: E402

ROOT = HERE
while not (ROOT / 'WORKSPACE.json').exists():
    ROOT = ROOT.parent
failures = 0


def check(ok, name):
    global failures
    print(('PASS' if ok else 'FAIL') + '\t' + name)
    failures += 0 if ok else 1


class Stock:
    def __init__(self, folder, opmap):
        self.folder, self.opmap = folder, opmap

    def module_file(self, name):
        path = self.folder / name
        return B.Module(path.read_bytes(), self.opmap) if path.exists() else None


class Boot:
    def __init__(self, text):
        self.text = text

    def has(self, path):
        return True

    def read(self, path):
        return self.text


opmap = B.load_opcode_profile((ROOT / 'repos/toolchains/de-luau-toolchain/src/de_opcode_profile.h').read_text())
source = (ROOT / 'repos/runtime/bootstrapper-runtime/renovice/injection_core.hpp').read_text(encoding='utf-8')
cache = ROOT / 'work/temp/update-check'
packs = {'44.1.0': cache / 'stock-a71c700d9520b4a5', '44.1.1': cache / 'stock-726365cc81044d28'}
ROW_4411 = '{0x9b533c41f2294d14ull, 24, 15, 59, 58},'
if all((p / T.TOPMENU_FILE).exists() for p in packs.values()) and ROW_4411 in source:
    for label, pack in packs.items():
        check(T.check(Stock(pack, opmap), Boot(source))[0] == 'OK', f'TopMenu {label}: layout row matches the stock shape')
    status, reason, _ = T.check(Stock(packs['44.1.1'], opmap), Boot(source.replace(ROW_4411, '')))
    check(status == 'BROKEN' and 'no layout row' in reason and '[15]' in reason,
          'TopMenu 44.1.1 without its row: BROKEN, names the builder candidate (the 2026-10-09 install failure)')
    status, _, _ = T.check(Stock(packs['44.1.1'], opmap), Boot(source.replace(ROW_4411, ROW_4411.replace(' 15,', ' 14,'))))
    check(status == 'BROKEN', 'TopMenu 44.1.1 with the 44.1.0 builder index: BROKEN')
    status, _, _ = T.check(Stock(packs['44.1.1'], opmap), Boot(source.replace(ROW_4411, ROW_4411.replace(' 24,', ' 23,'))))
    check(status == 'BROKEN', 'TopMenu 44.1.1 with the 44.1.0 capture count: BROKEN')
else:
    print('SKIP\tTopMenu cases: stock packs or the 44.1.1 layout row are not available')

LINES = {
    'start': 'RENOVICE source configuration initialized\n',
    'menu_pass': 'RENOVICE Scripts UI attach PASS source=published-TopMenu-environment owner=Initialize.U15.Builder.U58\n',
    'menu_fail': 'RENOVICE Scripts UI attach FAIL reason=published-Initialize-owner source=vm-exact-root-return upvalues=24\n',
    'packages_ok': 'RENOVICE PACKAGES scan PASS trigger=startup packages=4 accepted=4 disabled=0 rejected=0\n',
    'packages_bad': 'RENOVICE PACKAGES scan PASS trigger=startup packages=4 accepted=3 disabled=0 rejected=1\n',
    'addon_fail': 'RENOVICE addon lifecycle FAIL aaaaaaaaaaaaaaaa.Example.target.addon.lua_B field=activate reason=x error_tag=6 error="BOOM"\n',
    'dropped_fail': 'RENOVICE addon lifecycle FAIL 95ef5b82a8400944.CircuitProgressPreviewX5.target.addon.lua_B field=activate error="X"\n',
}
DROPPED = {'Inject/95ef5b82a8400944.CircuitProgressPreviewX5.target.addon.lua_B': 'dropped'}


def run(files, stale=False):
    tmp = Path(tempfile.mkdtemp(prefix='uc-runtime-'))
    try:
        (tmp / 'Logs').mkdir()
        for name, keys in files.items():
            (tmp / 'Logs' / name).write_text(''.join(LINES[k] for k in keys), encoding='utf-8')
        installed = tmp / 'installed.dll'
        installed.write_text('x')
        now = time.time()
        for p in (tmp / 'Logs').iterdir():
            os.utime(p, (now - 100, now - 100) if stale else (now + 100, now + 100))
        rep = R.Report()
        U.check(rep, tmp, [installed], DROPPED, R.OK, R.BROKEN)
        return {i.check: i.status for i in rep.items}, rep.notes['runtime']
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


items, _ = run({'renovice_source.log': ['start', 'menu_pass', 'packages_ok']})
check(items == {'runtime.scripts_menu': 'OK', 'runtime.packages': 'OK'}, 'clean session: menu and packages OK')
items, _ = run({'renovice_source.log': ['start', 'menu_fail', 'packages_ok']})
check(items['runtime.scripts_menu'] == 'BROKEN', 'menu attach FAIL only: BROKEN')
items, _ = run({'renovice_source.log': ['start', 'menu_pass', 'packages_bad', 'addon_fail', 'dropped_fail']})
check(items['runtime.packages'] == 'BROKEN' and items['runtime.addon:aaaaaaaaaaaaaaaa.Example.target.addon.lua_B'] == 'BROKEN'
      and items['runtime.addon:95ef5b82a8400944.CircuitProgressPreviewX5.target.addon.lua_B'] == 'OK',
      'rejected package and a failing addon: BROKEN; a dropped addon: listed as known')
items, _ = run({'renovice_source.log.1': ['start', 'menu_fail'], 'renovice_source.log': ['start', 'menu_pass', 'packages_ok']})
check(items['runtime.scripts_menu'] == 'OK', 'only the newest session counts (an older session failed)')
items, _ = run({'renovice_source.log.1': ['start', 'packages_ok'], 'renovice_source.log': ['menu_fail']})
check(items['runtime.scripts_menu'] == 'BROKEN', 'a session spanning a log rotation is read across files')
items, notes = run({'renovice_source.log': ['start', 'menu_fail']}, stale=True)
check(items == {} and notes and 'start the game' in notes[0], 'a session older than the install: a note, no item')

print('SCRIPTS MENU AND RUNTIME CHECKS ' + ('PASS' if failures == 0 else f'FAIL ({failures})'))
sys.exit(1 if failures else 0)
