"""Stage additions and the complete adoption of an update set (2026-10-09).

Before: files added to a staged set by hand (a re-derived review item, a new package member) were in no report, and after
--adopt the authored-artifact registrations, the harness package pins and the update-check baseline were updated by hand.

  add_to_stage(): copies one file into <stage>/install/, records it in <stage>/manual_additions.json (sha256, the file it
      replaces, its source project, a note, optional "ships disabled"), appends remove.txt, sets the ScriptStates.json
      member switch, rewrites SHA256SUMS and the README section "Manual additions".
  complete_adoption(): after the registry and corpus are adopted, renames authored_addons.json entries the stage
      replaced (remove.txt), registers the recorded additions, re-pins the harness package pins and writes the
      update-check baseline from the installed game (only when that check has no BROKEN item).
Nothing here writes the game folder.
"""
from __future__ import annotations

import datetime
import hashlib
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path

TOOL_DIR = Path(__file__).resolve().parent
EDITOR = TOOL_DIR.parents[1]
AUTHORED = TOOL_DIR / 'authored_addons.json'
MANUAL = 'manual_additions.json'
CUSTOM = 'OpenWF/CustomScripts/'
README_HEAD = '## Manual additions (renovice_update.py --add-to-stage)'
_REPLACED = re.compile(r'replaced by (?:the rebased replacement )?(.+?\.lua_B)')


def _sha(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def write_sums(stage: Path) -> None:
    """The stage's SHA256SUMS, the same form renovice_update.py writes."""
    sums = [f'{_sha(f)}  {f.relative_to(stage).as_posix()}'
            for f in sorted(p for p in stage.rglob('*') if p.is_file() and p.name != 'SHA256SUMS')]
    (stage / 'SHA256SUMS').write_text('\n'.join(sums) + '\n', encoding='utf-8')


def member_switch(install_rel: str) -> str | None:
    """ScriptStates.json id of a package member (Packages/<package>/<file>), else None."""
    parts = install_rel.split('/')
    if install_rel.startswith(CUSTOM + 'Packages/') and len(parts) == 5:
        return f'member:{parts[3].lower()}/{parts[4].lower()}'
    return None


def _readme_section(stage: Path, entries: list) -> None:
    readme = stage / 'README.md'
    text = readme.read_text(encoding='utf-8') if readme.exists() else ''
    text = text.split('\n' + README_HEAD)[0].rstrip('\n') + '\n'
    rows = [f'| `{e["install"]}` | `{e["sha256"]}` | {e["replaces"] or "new"} | '
            f'{"off" if e["ships_disabled"] else "-"} | {e["note"]} |' for e in entries]
    text += ('\n' + README_HEAD + '\n\nFiles added to this set after the tool run (recorded in `manual_additions.json`; '
             '`--adopt` registers the authored ones).\n\n| Install path | SHA-256 | Replaces | Ships | Note |\n'
             '|---|---|---|---|---|\n' + '\n'.join(rows) + '\n')
    readme.write_text(text, encoding='utf-8')


def add_to_stage(stage: Path, file: Path, install_rel: str, replaces: str | None, source_project: str | None, note: str,
                 ships_disabled: bool, log=print) -> dict:
    install_rel = install_rel.replace('\\', '/').lstrip('/')
    if not (stage / 'UPDATE_REPORT.json').exists():
        raise SystemExit(f'add-to-stage: {stage} is not an update set (no UPDATE_REPORT.json)')
    target = stage / 'install' / install_rel
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(file, target)
    entry = {'install': install_rel, 'sha256': _sha(target), 'replaces': replaces, 'source_project': source_project,
             'note': note, 'ships_disabled': ships_disabled, 'added': datetime.datetime.now().isoformat(timespec='seconds')}
    manual_path = stage / MANUAL
    entries = json.loads(manual_path.read_text(encoding='utf-8')) if manual_path.exists() else []
    entries = [e for e in entries if e['install'] != install_rel] + [entry]
    manual_path.write_text(json.dumps(entries, indent=1) + '\n', encoding='utf-8')
    if replaces:
        line = f'{replaces}\treplaced by {Path(install_rel).name} (manual addition)'
        remove = stage / 'remove.txt'
        lines = remove.read_text(encoding='utf-8').splitlines() if remove.exists() else []
        lines = [l for l in lines if not l.startswith(replaces + '\t')] + [line]
        remove.write_text('\n'.join(lines) + '\n', encoding='utf-8')
    if ships_disabled:
        switch = member_switch(install_rel)
        states = stage / 'install' / CUSTOM / 'ScriptStates.json'
        if switch is None or not states.exists():
            raise SystemExit('add-to-stage: --ships-disabled needs a package member and a staged ScriptStates.json')
        data = json.loads(states.read_text(encoding='utf-8'))
        data['scripts'][switch] = False
        data['scripts'] = dict(sorted(data['scripts'].items()))
        states.write_bytes((json.dumps(data, indent=4) + '\n').encode('utf-8'))
    _readme_section(stage, entries)
    write_sums(stage)
    log(f'add-to-stage: {install_rel} ({entry["sha256"][:16]})' + (f', replaces {replaces}' if replaces else '')
        + (', ships disabled' if ships_disabled else ''))
    return entry


def renames(stage: Path) -> dict:
    """{old installed path under CustomScripts: new one} from remove.txt."""
    out = {}
    remove = stage / 'remove.txt'
    for line in (remove.read_text(encoding='utf-8').splitlines() if remove.exists() else []):
        if '\t' not in line:
            continue
        old, why = line.split('\t', 1)
        m = _REPLACED.search(why)
        if m and old.startswith(CUSTOM):
            rel = old[len(CUSTOM):]
            out[rel] = str(Path(rel).parent.as_posix() + '/' + m.group(1)).lstrip('./')
    return out


def update_authored(stage: Path, log=print) -> list[str]:
    """Renames replaced entries and registers recorded additions in authored_addons.json; returns what changed."""
    data = json.loads(AUTHORED.read_text(encoding='utf-8'))
    moved = renames(stage)
    changed = []
    for section in ('addons', 'replacements'):
        for e in data[section]:
            if e['installed'] in moved:
                changed.append(f'renamed {e["installed"]} -> {moved[e["installed"]]}')
                e['installed'] = moved[e['installed']]
    known = {e['installed'] for s in ('addons', 'replacements') for e in data[s]}
    manual_path = stage / MANUAL
    for e in (json.loads(manual_path.read_text(encoding='utf-8')) if manual_path.exists() else []):
        rel = e['install'][len(CUSTOM):] if e['install'].startswith(CUSTOM) else None
        if rel and rel.endswith('.lua_B') and e.get('source_project') and rel not in known:
            data['replacements'].append({'installed': rel, 'source_project': e['source_project'],
                                         'note': e['note'] + (' (ships disabled)' if e.get('ships_disabled') else '')})
            changed.append(f'registered {rel}')
    if changed:
        AUTHORED.write_bytes(_authored_text(data).encode('utf-8'))
    for c in changed:
        log(f'adopt: authored_addons.json {c}')
    return changed


def _authored_text(d: dict) -> str:
    """authored_addons.json in its one-entry-per-line layout."""
    def line(o):
        return json.dumps(o, ensure_ascii=False)
    out = ['{'] + [f' "{k}": {line(d[k])},' for k in d if k not in ('addons', 'replacements', 'not_rebuilt')]
    for section in ('addons', 'replacements'):
        out += [f' "{section}": ['] + [f'  {line(a)}' + (',' if i < len(d[section]) - 1 else '')
                                       for i, a in enumerate(d[section])] + [' ],']
    out += [f' "not_rebuilt": {line(d.get("not_rebuilt", {}))}', '}']
    return '\n'.join(out) + '\n'


def complete_adoption(stage: Path, game: Path | None, log=print) -> int:
    update_authored(stage, log)
    sys.path.insert(0, str(EDITOR / 'RESEARCH' / 'UNIVERSAL_MISSION_REGISTRY_2026-09-29' / 'tools'))
    import harness_input as HI
    pins = HI.repin()
    log(f'adopt: harness package pins re-pinned for registry {pins["registry_sha256"][:16]}')
    if game is None:
        log('adopt: no --game given: the update-check baseline was NOT written (run renovice_update_check.py --game '
            '<installed game> --write-baseline after installing the set)')
        return 0
    check = TOOL_DIR / 'renovice_update_check.py'
    run = subprocess.run([sys.executable, str(check), '--game', str(game)], capture_output=True, text=True)
    log((run.stdout + run.stderr).strip().splitlines()[-1] if (run.stdout + run.stderr).strip() else 'check: no output')
    if run.returncode != 0:
        log('adopt: the update check of the installed game is not clean: the baseline was NOT written (see its report)')
        return 1
    run = subprocess.run([sys.executable, str(check), '--game', str(game), '--write-baseline'], capture_output=True, text=True)
    log((run.stdout + run.stderr).strip().splitlines()[-1] if (run.stdout + run.stderr).strip() else 'baseline: no output')
    return run.returncode
