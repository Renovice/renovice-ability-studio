"""Pluggable call of the NATIVE side of the update (bootstrapper repository; owned by the native update tool).

The contract is read from <workspace>/work/research/update-resilience/NATIVE_INTERFACE.md: the first fenced block tagged
`renovice-native-interface` (JSON). Keys used here:
  entry          path of the native entry point, relative to the bootstrapper repository root
  runner         "python" or "powershell"
  args           argument list; "{game}", "{out}", "{exe}", "{repo}" are substituted
  build_args     extra arguments that also apply the auto items to the bootstrapper tree and rebuild/stage the DLL
                 (passed only with renovice_update.py --native-build)
  result         result JSON file name inside {out}
  exit_codes     {"0": "OK", "1": "REVIEW", "2": "BUILD FAILED", "3": "TOOL ERROR"}
  staged_files   optional key of the result JSON listing [{path, install_path, sha256}] (paths: relative to {out} and to
                 <game>); without it, a stage folder is scanned for WTSAPI32.dll and Hotfix.owf.
If the file or the block is missing, the expectation below (DEFAULT) is used and the call is skipped when its entry does
not exist: the script side is complete on its own and the report says the native set is pending.
"""
from __future__ import annotations

import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

DEFAULT = {
    'format': 'RENOVICE_NATIVE_INTERFACE_V1',
    'entry': 'RENOVICE_TOOLCHAIN/native_update/renovice_native_update.py',
    'runner': 'python',
    'args': ['--game', '{game}', '--exe', '{exe}', '--out', '{out}'],
    'build_args': ['--apply', '--build'],
    'result': 'native_update_report.json',
    'exit_codes': {'0': 'OK', '1': 'REVIEW', '2': 'BUILD FAILED', '3': 'TOOL ERROR'},
    'staged_files': 'staged_files',
}
KNOWN_INSTALL = {'WTSAPI32.dll': 'WTSAPI32.dll', 'Hotfix.owf': 'OpenWF/Hotfix.owf'}


def contract(ws: Path) -> tuple[dict, str]:
    path = ws / 'work' / 'research' / 'update-resilience' / 'NATIVE_INTERFACE.md'
    if not path.is_file():
        return dict(DEFAULT), 'NATIVE_INTERFACE.md missing: script-side expectation used'
    text = path.read_text(encoding='utf-8', errors='replace')
    m = re.search(r'```(?:json)?\s*renovice-native-interface\s*\n(.*?)```', text, re.S) or \
        re.search(r'```renovice-native-interface\s*\n(.*?)```', text, re.S)
    if not m:
        return dict(DEFAULT), 'NATIVE_INTERFACE.md has no renovice-native-interface block: script-side expectation used'
    try:
        data = json.loads(m.group(1))
    except ValueError as e:
        return dict(DEFAULT), f'NATIVE_INTERFACE.md block is not JSON ({e}): script-side expectation used'
    out = dict(DEFAULT)
    out.update(data)
    return out, f'contract {path}'


def run(ws: Path, repo: Path, game: Path, exe: Path, out: Path, build: bool, log=print) -> dict:
    c, source = contract(ws)
    repo, game, exe, out = (Path(x).resolve() for x in (repo, game, exe, out))
    entry = repo / c['entry']
    res = {'contract': source, 'entry': str(entry), 'status': 'NOT RUN', 'files': []}
    if not entry.is_file():
        res['reason'] = f'native entry {c["entry"]} not found in {repo}: the native set is pending (keep the installed DLL)'
        return res
    out.mkdir(parents=True, exist_ok=True)
    subst = {'{game}': str(game), '{out}': str(out), '{exe}': str(exe), '{repo}': str(repo)}
    args = [subst.get(a, a) for a in c['args'] + (c.get('build_args', []) if build else [])]
    cmd = ([sys.executable, str(entry)] if c.get('runner', 'python') == 'python' else
           ['powershell', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', str(entry)]) + args
    log(f'native: {" ".join(cmd)}')
    r = subprocess.run(cmd, capture_output=True, text=True, timeout=7200, cwd=str(repo))
    (out / 'native_call.log').write_text(r.stdout + r.stderr, encoding='utf-8')
    res['exit'] = r.returncode
    res['status'] = c['exit_codes'].get(str(r.returncode), f'exit {r.returncode}')
    result_path = out / c['result']
    report = {}
    if result_path.is_file():
        try:
            report = json.loads(result_path.read_text(encoding='utf-8'))
        except ValueError:
            report = {}
    res['report'] = str(result_path) if result_path.is_file() else None
    res['summary'] = {k: report.get(k) for k in ('result', 'build', 'exe_sha256', 'counts', 'allowlist') if k in report}
    files = report.get(c.get('staged_files') or '', []) if isinstance(report, dict) else []
    if not files:
        for name, install in KNOWN_INSTALL.items():
            for f in out.rglob(name):
                files.append({'path': str(f.relative_to(out)), 'install_path': install})
    for f in files:
        p = out / f['path']
        if p.is_file():
            data = p.read_bytes()
            res['files'].append({'source': str(p), 'install_path': f['install_path'],
                                 'sha256': hashlib.sha256(data).hexdigest(), 'bytes': len(data)})
    return res
