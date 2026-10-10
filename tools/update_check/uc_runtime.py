"""Runtime evidence of the newest game session (2026-10-09).

What the loader reported the last time the game started, read from <script root>/Logs/renovice_source.log (the same
folder in both layouts: OpenWF/LuaScripts/Logs, before layout V2 OpenWF/CustomScripts/Logs) and its rotated copies
(.1 .. .9, 64 MiB each; a session can span several). Only a session that started after the installed loader, client
and packages were last written is judged; an older session gives a note ("start the game once"), never a stale PASS.
Read only.

Reported (each line names the log text it comes from):
  * the Scripts menu attached (`Scripts UI attach PASS`) or failed (`Scripts UI attach FAIL reason=...`);
  * every addon whose activation failed (`addon lifecycle FAIL <file> ... error="..."`), deduplicated; an addon the
    user dropped (authored_addons.json "not_rebuilt") is listed as known, not as broken;
  * packages, settings values and live-literal recipes the loader rejected.
"""
import re
from pathlib import Path

START = 'RENOVICE source configuration initialized'
_ADDON_FAIL = re.compile(r'RENOVICE addon lifecycle FAIL (\S+) .*?error="([^"]*)"')
_MENU = re.compile(r'RENOVICE Scripts UI attach (PASS|FAIL)(?: reason=(\S+))?')
_PACKAGES = re.compile(r'RENOVICE PACKAGES scan \w+ .*?rejected=(\d+)')
_SETTINGS = re.compile(r'RENOVICE SETTINGS PACKAGE .*?package=(\S+) .*?rejected=(\d+)')
_LITERAL_BAD = re.compile(r'RENOVICE LIVE LITERALS (RECIPE REJECT|PLAN REJECT|SYNTHESIZE FAIL)\b.*')


def log_files(logs: Path) -> list[Path]:
    """Oldest first: renovice_source.log.9 .. .1, then renovice_source.log."""
    rotated = sorted((p for p in logs.glob('renovice_source.log.*') if p.suffix[1:].isdigit()),
                     key=lambda p: -int(p.suffix[1:]))
    current = logs / 'renovice_source.log'
    return rotated + ([current] if current.exists() else [])


def newest_session(logs: Path) -> dict | None:
    """The relevant lines of the newest session, or None when no session start is in the logs."""
    session = None
    for path in log_files(logs):
        with path.open('r', encoding='utf-8', errors='replace') as fh:
            for line in fh:
                if START in line:
                    session = {'start_file': path.name, 'menu': [], 'addon_fail': {}, 'packages_rejected': None,
                               'settings_rejected': {}, 'literal_bad': [], 'last_file': path}
                    continue
                if session is None or 'RENOVICE ' not in line:
                    continue
                session['last_file'] = path
                if (m := _MENU.search(line)):
                    session['menu'].append((m.group(1), m.group(2) or ''))
                elif (m := _ADDON_FAIL.search(line)):
                    session['addon_fail'].setdefault(m.group(1), m.group(2))
                elif (m := _PACKAGES.search(line)):
                    session['packages_rejected'] = int(m.group(1))
                elif (m := _SETTINGS.search(line)):
                    session['settings_rejected'][m.group(1)] = int(m.group(2))
                elif (m := _LITERAL_BAD.search(line)):
                    session['literal_bad'].append(m.group(0)[:200])
    return session


def check(rep, custom: Path, installed: list[Path], dropped: dict, OK, BROKEN) -> None:
    logs = custom / 'Logs'
    if not logs.is_dir():
        rep.note('runtime', f'no loader logs in {logs}; start the game once after an install, then run this check again')
        return
    session = newest_session(logs)
    newest_install = max((p.stat().st_mtime for p in installed if p.exists()), default=0)
    if session is None:
        rep.note('runtime', 'no game session in the loader logs; start the game once, then run this check again')
        return
    if session['last_file'].stat().st_mtime < newest_install:
        rep.note('runtime', 'the newest game session ran before the last install; start the game once, then run this check '
                 'again')
        return
    where = f'session from {session["start_file"]}'
    passes = [r for s, r in session['menu'] if s == 'PASS']
    fails = sorted({r for s, r in session['menu'] if s == 'FAIL'})
    rep.add('runtime', 'runtime.scripts_menu', 'The Scripts menu attached in the newest game session',
            OK if passes else (BROKEN if fails else 'UNKNOWN'),
            f'{len(passes)} attach PASS ({where})' if passes else
            (f'attach FAIL reason={", ".join(fails)} ({where})' if fails else f'the menu was not opened ({where})'),
            ['Scripts menu (SCRIPTS and SCRIPT SETTINGS rows in ESC)'])
    for file, error in sorted(session['addon_fail'].items()):
        known = next((why for name, why in dropped.items() if Path(name).name == file), None)
        rep.add('runtime', f'runtime.addon:{file}', f'Addon {file} activates', OK if known else BROKEN,
                (f'activation fails ({error}); known: {known}' if known else f'activation fails: {error} ({where})'),
                [file])
    rejected = session['packages_rejected']
    bad_settings = {k: v for k, v in session['settings_rejected'].items() if v}
    rep.add('runtime', 'runtime.packages', 'Packages, settings values and live-literal recipes accepted',
            BROKEN if (rejected or bad_settings or session['literal_bad']) else (OK if rejected == 0 else 'UNKNOWN'),
            f'packages rejected={rejected}; settings rejected {bad_settings or 0}; live-literal rejects '
            f'{len(session["literal_bad"])}' + (f': {session["literal_bad"][0]}' if session['literal_bad'] else '')
            + f' ({where})', ['Every package'])
