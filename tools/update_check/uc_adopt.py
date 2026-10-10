"""Stage additions and the complete adoption of an update set (2026-10-09).

Before: files added to a staged set by hand (a re-derived review item, a new package member) were in no report, and after
--adopt the authored-artifact registrations, the harness package pins and the update-check baseline were updated by hand.

  add_to_stage(): copies one file into <stage>/install/, records it in <stage>/manual_additions.json (sha256, the file it
      replaces, its source project, a note, optional "ships disabled"), appends remove.txt, sets the script's own switch off,
      rewrites SHA256SUMS and the README section "Manual additions". Install paths are layout V2 (OpenWF/LuaScripts/...;
      a V1 path is mapped, uc_layout). A Settings/<Package>.json is not copied: it becomes that package's "values" entry
      and, like a switch, is merged into the staged Config/ScriptStates.json (the user's file with the stage's changes;
      <stage>/ScriptStates.merge.json keeps the changes for a later re-merge).
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

import uc_content
import uc_layout as LAY

TOOL_DIR = Path(__file__).resolve().parent
EDITOR = TOOL_DIR.parents[1]
AUTHORED = TOOL_DIR / 'authored_addons.json'
MANUAL = 'manual_additions.json'
SCRIPTS = LAY.TARGET_PREFIX         # staged script root (layout V2)
CUSTOM = SCRIPTS                    # pre-V2 name of the same prefix
README_HEAD = '## Manual additions (renovice_update.py --add-to-stage)'
_REPLACED = re.compile(r'replaced by (?:the rebased replacement )?(.+?\.lua_B)')


def _sha(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def write_sums(stage: Path) -> None:
    """The stage's SHA256SUMS, the same form renovice_update.py writes."""
    sums = [f'{_sha(f)}  {f.relative_to(stage).as_posix()}'
            for f in sorted(p for p in stage.rglob('*') if p.is_file() and p.name != 'SHA256SUMS')]
    (stage / 'SHA256SUMS').write_text('\n'.join(sums) + '\n', encoding='utf-8')


def script_switch(install_rel: str, file: Path) -> str:
    """The Scripts-menu switch of a loose script (Addons/<file> or Replacements/<file>), as the loader names it
    (script_control_core.hpp stable_id, uc_content inventory). A package member has no switch of its own: member
    switches are retired since contract R13 (packages.cpp stages every member with its package and only reports a
    stored `member:` entry), so a member cannot ship disabled and is refused with that reason."""
    rel = LAY.install_canonical(install_rel)
    parts = rel.split('/') if rel else []
    if len(parts) == 3 and parts[0] == 'Packages':
        raise SystemExit('add-to-stage: --ships-disabled cannot switch off a package member: member switches are '
                         'ignored by the loader since contract R13 (the package row is the only switch). Ship it as a '
                         'loose script (Addons/ or Replacements/) or leave it out of the package')
    if len(parts) == 2 and parts[0] == 'Replacements' and uc_content.KEY.match(parts[1]):
        return 'replacement:' + parts[1].lower()
    if len(parts) == 2 and parts[0] == 'Addons':
        ids = []
        uc_content._classify(Path(file), rel, '', lambda key: ids.append(key.lower()) or 'unlisted')
        return ids[0]
    raise SystemExit('add-to-stage: --ships-disabled needs a loose script (Addons/<file> or Replacements/<key> ...)')


def stage_states(stage: Path, scripts: dict | None = None, values: dict | None = None) -> Path:
    """Merges switch / values changes into the stage: <stage>/ScriptStates.merge.json (all changes of the stage) and the
    staged Config/ScriptStates.json (the installed file of UPDATE_REPORT.json "scripts_root" when none is staged yet)."""
    frag_path = stage / LAY.FRAGMENT_NAME
    fragment = json.loads(frag_path.read_text(encoding='utf-8')) if frag_path.exists() else {'schema': 2}
    change = LAY.fragment_add({'schema': 2}, scripts, values)
    staged = stage / 'install' / SCRIPTS / LAY.STATES
    if staged.exists():
        base, errors = LAY.read_states_file(staged)
    else:
        report = json.loads((stage / 'UPDATE_REPORT.json').read_text(encoding='utf-8'))
        if not report.get('scripts_root'):
            raise SystemExit('add-to-stage: no staged Config/ScriptStates.json and the stage does not name the installed '
                             'script root (UPDATE_REPORT.json "scripts_root")')
        base, errors = LAY.Layout.of(Path(report['scripts_root'])).read_states()
    if errors:
        raise SystemExit(f'add-to-stage: the ScriptStates to merge into cannot be read: {"; ".join(errors)}')
    LAY.write_states_atomic(staged, LAY.merge_states(base, change))
    frag_path.write_bytes(LAY.dump_fragment(LAY.fragment_add(fragment, scripts, values)))
    return staged


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
    install_rel = LAY.target_install_path(install_rel)
    replaces = LAY.target_install_path(replaces) if replaces else replaces
    if not (stage / 'UPDATE_REPORT.json').exists():
        raise SystemExit(f'add-to-stage: {stage} is not an update set (no UPDATE_REPORT.json)')
    rel = LAY.install_canonical(install_rel)
    if rel == LAY.STATES:
        raise SystemExit('add-to-stage: Config/ScriptStates.json is merged, never copied: stage a switch with '
                         '--ships-disabled or values as Settings/<Package>.json')
    switch = script_switch(install_rel, file) if ships_disabled else None     # refused before anything is written
    if rel and rel.startswith('Settings/') and rel.count('/') == 1 and rel.lower().endswith('.json'):
        # a former Settings/<Package>.json: that package's values entry (the object unchanged)
        data = json.loads(Path(file).read_text(encoding='utf-8'))
        pid = LAY.package_id(Path(rel).stem)
        if not isinstance(data, dict) or data.get('package', pid) != pid:
            raise SystemExit(f'add-to-stage: {file} is not the values file of {pid}')
        stage_states(stage, values={pid: data})
        install_rel = f'{SCRIPTS}{LAY.STATES} values["{pid}"]'
        sha = hashlib.sha256(Path(file).read_bytes()).hexdigest()
    else:
        target = stage / 'install' / install_rel
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(file, target)
        sha = _sha(target)
    entry = {'install': install_rel, 'sha256': sha, 'replaces': replaces, 'source_project': source_project,
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
    if switch:
        stage_states(stage, scripts={switch: False})
    _readme_section(stage, entries)
    write_sums(stage)
    log(f'add-to-stage: {install_rel} ({entry["sha256"][:16]})' + (f', replaces {replaces}' if replaces else '')
        + (', ships disabled' if ships_disabled else ''))
    return entry


def renames(stage: Path) -> dict:
    """{old canonical id (uc_layout): new one} from remove.txt (lines of either layout)."""
    out = {}
    remove = stage / 'remove.txt'
    for line in (remove.read_text(encoding='utf-8').splitlines() if remove.exists() else []):
        if '\t' not in line:
            continue
        old, why = line.split('\t', 1)
        m = _REPLACED.search(why)
        rel = LAY.install_canonical(old)
        if m and rel:
            out[rel] = str(Path(rel).parent.as_posix() + '/' + m.group(1)).lstrip('./')
    return out


def update_authored(stage: Path, log=print) -> list[str]:
    """Renames replaced entries and registers recorded additions in authored_addons.json; returns what changed."""
    data = json.loads(AUTHORED.read_text(encoding='utf-8'))
    for section in ('addons', 'replacements'):          # registrations of either layout compare as canonical ids
        for e in data[section]:
            e['installed'] = LAY.canonical(e['installed'])
    data['not_rebuilt'] = {LAY.canonical(k): v for k, v in data.get('not_rebuilt', {}).items()}
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
        rel = LAY.install_canonical(e['install'])
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
