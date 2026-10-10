#!/usr/bin/env python3
"""RENOVICE script folder layout V1 / V2 (work/agents/LAYOUT_V2_SPEC.md, user-approved 2026-10-10).

    V2  OpenWF/LuaScripts/               V1  OpenWF/CustomScripts/
          Addons/                              Inject/
          Replacements/                        <root replacement files>
          Packages/<Name>/                     Packages/<Name>/
          Config/Logs.cfg                      renovice.cfg
          Config/ScriptStates.json (schema 2)  ScriptStates.json (schema 1) + Settings/<Package>.json
          Logs/  Logs/Dumps/                   Logs/  Diagnostics/

Root selection is the loader's: OpenWF/LuaScripts when that folder exists, otherwise OpenWF/CustomScripts (never both).

Canonical ids. Every tool names an installed file by its V2 path relative to the root ("Addons/<file>",
"Replacements/<file>", "Packages/<Name>/<file>", "Config/ScriptStates.json"); `canonical()` turns a V1 path
("Inject/<file>", a loose root file, "renovice.cfg", "Diagnostics/...") into that id and `Layout.path()` turns the id
back into the file of either layout. Registrations written before V2 (authored_addons.json, remove.txt lines of older
stages) keep working through `canonical()`.

ScriptStates schema 2: {"schema": 2, "scripts": {switch id: bool}, "values": {package id: <the former
Settings/<Package>.json object, unchanged>}}. The one generic write operation is `merge_states(base, fragment)`: every
`scripts` entry of the fragment sets (or, with null, removes) that switch, every `values` entry replaces (or, with null,
removes) that package's whole values object; everything else of the base, including keys this tool does not know, is
kept. `write_states_atomic` writes temp + replace.

Command line (offline; the user runs them on the game folder, the tools never do):
    python uc_layout.py merge-states --fragment <ScriptStates.merge.json> --into <.../Config/ScriptStates.json> [--dry-run]
The one-time migration of an installed folder is the loader repository's
RENOVICE_TOOLCHAIN/layout/migrate_layout_v2.py (dry run, copy-only, byte-verified).
"""
from __future__ import annotations

import argparse
import copy
import json
import os
import re
import shutil
import sys
from dataclasses import dataclass, field
from pathlib import Path

V1, V2 = 1, 2
V1_DIR, V2_DIR = 'CustomScripts', 'LuaScripts'
TARGET_PREFIX = f'OpenWF/{V2_DIR}/'          # every staged install path (the tools produce V2)
LEGACY_PREFIX = f'OpenWF/{V1_DIR}/'
STATES = 'Config/ScriptStates.json'
LOGS_CFG = 'Config/Logs.cfg'
SETTINGS_FORMAT = 'RENOVICE_SCRIPT_SETTINGS_V1'
FRAGMENT_NAME = 'ScriptStates.merge.json'    # a staged schema-2 fragment; merged into Config/ScriptStates.json
KEY = re.compile(r'^[0-9a-fA-F]{16}')
_REPLACEMENT_SUFFIXES = ('.lua_b', '.swf', '.swf.toc')
_V1_TO_V2_DIRS = {'Inject': 'Addons', 'Diagnostics': 'Logs/Dumps'}
_V1_TO_V2_FILES = {'renovice.cfg': LOGS_CFG, 'ScriptStates.json': STATES}


def _norm(rel: str) -> str:
    return str(rel).replace('\\', '/').lstrip('/')


def is_replacement_file(name: str) -> bool:
    """A loose root file the V1 loader treats as a replacement (`<16-hex key>[ (description)].lua_B`, *.swf, *.swf.toc)."""
    low = name.lower()
    return low.endswith(_REPLACEMENT_SUFFIXES) and (not low.endswith('.lua_b') or bool(KEY.match(name)))


def canonical(rel: str) -> str:
    """The V2 id of a path relative to either root ("Inject/x" -> "Addons/x", "<key> (x).lua_B" -> "Replacements/...")."""
    rel = _norm(rel)
    first, _, rest = rel.partition('/')
    if rest:
        return f'{_V1_TO_V2_DIRS[first]}/{rest}' if first in _V1_TO_V2_DIRS else rel
    if rel in _V1_TO_V2_FILES:
        return _V1_TO_V2_FILES[rel]
    return f'Replacements/{rel}' if is_replacement_file(rel) else rel


def v1_rel(rel: str) -> str:
    """The V1 path (relative to CustomScripts) of a canonical id."""
    rel = canonical(rel)
    for old, new in _V1_TO_V2_DIRS.items():
        if rel.startswith(new + '/'):
            return f'{old}/{rel[len(new) + 1:]}'
    for old, new in _V1_TO_V2_FILES.items():
        if rel == new:
            return old
    if rel.startswith('Replacements/'):
        return rel[len('Replacements/'):]
    return rel


def install_canonical(install_path: str) -> str | None:
    """Canonical id of a game-relative install path under either root (`OpenWF/LuaScripts/...` or
    `OpenWF/CustomScripts/...`), else None."""
    p = _norm(install_path)
    if p.startswith(TARGET_PREFIX):
        return canonical(p[len(TARGET_PREFIX):])
    if p.startswith(LEGACY_PREFIX):
        return canonical(p[len(LEGACY_PREFIX):])
    return None


def target_install_path(install_path: str) -> str:
    """The V2 game-relative path of an install path of either layout; any other path is returned unchanged."""
    c = install_canonical(install_path)
    return TARGET_PREFIX + c if c is not None else _norm(install_path)


def package_id(folder: str) -> str:
    return 'package:' + folder.lower()


@dataclass
class Layout:
    root: Path
    version: int

    @classmethod
    def find(cls, openwf: Path) -> 'Layout':
        """The loader's choice under <game>/OpenWF: LuaScripts when it exists, else CustomScripts."""
        v2 = Path(openwf) / V2_DIR
        return cls(v2, V2) if v2.is_dir() else cls(Path(openwf) / V1_DIR, V1)

    @classmethod
    def for_game(cls, game: Path) -> 'Layout':
        return cls.find(Path(game) / 'OpenWF')

    @classmethod
    def of(cls, root: Path) -> 'Layout':
        """An explicitly named script root: V2 when it is called LuaScripts or holds a V2 folder, else V1."""
        root = Path(root)
        if root.name.lower() == V2_DIR.lower():
            return cls(root, V2)
        if root.name.lower() == V1_DIR.lower():
            return cls(root, V1)
        if any((root / d).is_dir() for d in ('Addons', 'Replacements', 'Config')):
            return cls(root, V2)
        return cls(root, V1)

    # folders and files ------------------------------------------------------------------------------------------------
    def path(self, rel: str) -> Path:
        """The file of a canonical (or V1) id in this layout."""
        rel = canonical(rel)
        return self.root / (rel if self.version == V2 else v1_rel(rel))

    def canonical_of(self, file: Path) -> str:
        return canonical(Path(file).relative_to(self.root).as_posix()) if self.version == V1 else \
            Path(file).relative_to(self.root).as_posix()

    @property
    def addons(self) -> Path:
        return self.path('Addons/x').parent

    @property
    def replacements(self) -> Path:
        return self.root / 'Replacements' if self.version == V2 else self.root

    @property
    def packages(self) -> Path:
        return self.root / 'Packages'

    @property
    def logs(self) -> Path:
        return self.root / 'Logs'

    @property
    def dumps(self) -> Path:
        return self.path('Logs/Dumps/x').parent

    @property
    def logs_cfg(self) -> Path:
        return self.path(LOGS_CFG)

    @property
    def states(self) -> Path:
        return self.path(STATES)

    @property
    def settings(self) -> Path | None:
        """V1 only: the folder of Settings/<Package>.json."""
        return self.root / 'Settings' if self.version == V1 else None

    @property
    def install_prefix(self) -> str:
        return TARGET_PREFIX if self.version == V2 else LEGACY_PREFIX

    def describe(self) -> str:
        return f'layout V{self.version} ({self.root})'

    # ScriptStates -----------------------------------------------------------------------------------------------------
    def read_states(self) -> tuple[dict, list[str]]:
        """The schema-2 view of the installed states (V2: Config/ScriptStates.json; V1: ScriptStates.json + every
        Settings/<Package>.json) and the per-entry errors. A bad entry fails only itself."""
        if self.version == V2:
            return read_states_file(self.states)
        return states_from_v1(self.root)


# -- ScriptStates schema 2 -------------------------------------------------------------------------------------------------
def empty_states() -> dict:
    return {'schema': 2, 'scripts': {}, 'values': {}}


def read_states_file(path: Path) -> tuple[dict, list[str]]:
    """A schema-2 file (missing -> empty). A broken file or a broken `scripts`/`values` map is an error, never guessed."""
    if not Path(path).is_file():
        return empty_states(), []
    try:
        doc = json.loads(Path(path).read_text(encoding='utf-8'))
    except (OSError, ValueError) as e:
        return empty_states(), [f'{path.name}: {e}']
    errors = []
    if not isinstance(doc, dict):
        return empty_states(), [f'{path.name}: not a JSON object']
    if doc.get('schema') != 2:
        errors.append(f'{path.name}: schema {doc.get("schema")!r} is not 2')
    for k in ('scripts', 'values'):
        if not isinstance(doc.get(k, {}), dict):
            errors.append(f'{path.name}: "{k}" is not an object')
            doc[k] = {}
        doc.setdefault(k, {})
    for pid, entry in list(doc['values'].items()):
        if not isinstance(entry, dict):
            errors.append(f'{path.name}: values["{pid}"] is not an object')
    return doc, errors


def settings_entry(path: Path) -> tuple[str, dict]:
    """(package id, object) of a V1 Settings/<Package>.json file; raises ValueError naming the defect."""
    data = json.loads(Path(path).read_text(encoding='utf-8'))
    if not isinstance(data, dict):
        raise ValueError(f'{Path(path).name}: not a JSON object')
    pid = package_id(Path(path).stem)
    if data.get('package', pid) != pid:      # the V1 loader's values-file-package-mismatch rule
        raise ValueError(f'{Path(path).name}: package {data.get("package")!r} != {pid}')
    return pid, data


def states_from_v1(root: Path) -> tuple[dict, list[str]]:
    doc, errors = empty_states(), []
    path = Path(root) / 'ScriptStates.json'
    if path.is_file():
        try:
            old = json.loads(path.read_text(encoding='utf-8'))
            scripts = old.get('scripts', {}) if isinstance(old, dict) else None
            if not isinstance(scripts, dict):
                raise ValueError('"scripts" is not an object')
            doc['scripts'] = dict(scripts)
        except (OSError, ValueError, AttributeError) as e:
            errors.append(f'ScriptStates.json: {e}')
    settings = Path(root) / 'Settings'
    for f in sorted(settings.glob('*.json')) if settings.is_dir() else []:
        try:
            pid, data = settings_entry(f)
            doc['values'][pid] = data
        except (OSError, ValueError) as e:
            errors.append(f'Settings/{f.name}: {e}')
    return doc, errors


def merge_states(base: dict, fragment: dict) -> dict:
    """base with the fragment applied (see the module text). Neither input is modified."""
    out = copy.deepcopy(base) if isinstance(base, dict) else {}
    out['schema'] = 2
    for k in ('scripts', 'values'):
        if not isinstance(out.get(k), dict):
            out[k] = {}
        part = (fragment or {}).get(k, {}) or {}
        if not isinstance(part, dict):
            raise ValueError(f'fragment "{k}" is not an object')
        for ident, value in part.items():
            if value is None:
                out[k].pop(ident, None)
            elif k == 'scripts' and not isinstance(value, bool):
                raise ValueError(f'fragment scripts["{ident}"] is not true/false')
            elif k == 'values' and not isinstance(value, dict):
                raise ValueError(f'fragment values["{ident}"] is not an object')
            else:
                out[k][ident] = copy.deepcopy(value)
    return out


def fragment_add(fragment: dict, scripts: dict | None = None, values: dict | None = None) -> dict:
    """Accumulates switch / values changes into a fragment (later changes of the same id win)."""
    fragment.setdefault('schema', 2)
    for k, part in (('scripts', scripts), ('values', values)):
        if part:
            fragment.setdefault(k, {}).update(copy.deepcopy(part))
    return fragment


def fragment_empty(fragment: dict) -> bool:
    return not (fragment or {}).get('scripts') and not (fragment or {}).get('values')


def _indent_value(body: str) -> str:
    """compose_state_file_v2's canonical indentation: the continuation lines' common leading spaces removed, +4, CRLF."""
    lines = body.replace('\r', '').rstrip('\n ').split('\n')
    rest = [line for line in lines[1:] if line.strip(' ')]
    common = min((len(line) - len(line.lstrip(' ')) for line in rest), default=0)
    return '\r\n    '.join([lines[0]] + [line[common:] if len(line) >= common else '' for line in lines[1:]])


def dump_states(doc: dict) -> bytes:
    """A complete schema-2 ScriptStates.json, byte for byte what the loader writes for the same switches and values
    (bootstrapper renovice/script_control_core.hpp compose_state_file_v2; gate RENOVICE_TOOLCHAIN/layout/verify_layout_v2
    with the file as argument): switches and values sorted by id, CRLF, each values entry as JSON text."""
    scripts = sorted(doc.get('scripts', {}).items())
    values = sorted(doc.get('values', {}).items())
    out = '{\r\n  "schema": 2,\r\n  "scripts": {'
    out += ''.join((',\r\n    ' if n else '\r\n    ') + json.dumps(k, ensure_ascii=False) + ': '
                   + ('true' if v else 'false') for n, (k, v) in enumerate(scripts))
    out += '\r\n  },\r\n' if scripts else '},\r\n'
    out += '  "values": {'
    out += ''.join((',\r\n    ' if n else '\r\n    ') + json.dumps(k, ensure_ascii=False) + ': '
                   + _indent_value(json.dumps(v, indent=2, ensure_ascii=False)) for n, (k, v) in enumerate(values))
    out += '\r\n  }\r\n}\r\n' if values else '}\r\n}\r\n'
    return out.encode('utf-8')


def dump_fragment(fragment: dict) -> bytes:
    """A staged ScriptStates.merge.json fragment (changes only; null removes a switch): plain JSON."""
    return (json.dumps(fragment, indent=4, ensure_ascii=False) + '\n').encode('utf-8')


def write_states_atomic(path: Path, doc: dict) -> None:
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_name(path.name + '.renovice.tmp')
    tmp.write_bytes(dump_states(doc))
    if json.loads(tmp.read_text(encoding='utf-8')) != doc:
        tmp.unlink()
        raise RuntimeError(f'{tmp}: readback mismatch')
    os.replace(tmp, path)


def merge_into_file(path: Path, fragment: dict, dry_run: bool = False) -> dict:
    """Merges a fragment into a schema-2 file (created when missing) atomically; refuses a broken or schema-1 file."""
    base, errors = read_states_file(Path(path))
    if errors:
        raise SystemExit(f'merge-states: {path} is not a valid schema-2 ScriptStates.json: {"; ".join(errors)}')
    merged = merge_states(base, fragment)
    if not dry_run:
        write_states_atomic(Path(path), merged)
    return merged


# -- migration V1 -> V2 plan (used by renovice_update.py to stage a V2 set from a V1 install) ---------------------------------
@dataclass
class MigrationPlan:
    old_root: Path
    copies: list = field(default_factory=list)        # (source file, canonical id, kind)
    states: dict = field(default_factory=empty_states)
    state_errors: list = field(default_factory=list)
    reported: list = field(default_factory=list)      # (old relative path, reason)


def migration_plan(old_root: Path, include_logs: bool = True) -> MigrationPlan:
    """What a V1 tree becomes in V2 (same mapping as the loader repository's migrate_layout_v2.py). Logs and Diagnostics
    are copied only with include_logs; anything the spec does not place is reported, never guessed. The retired `member:`
    switches (ignored by the loader since contract R13) are dropped and reported, as migrate_layout_v2.py does."""
    old_root = Path(old_root)
    plan = MigrationPlan(old_root)
    plan.states, plan.state_errors = states_from_v1(old_root)
    for key in sorted(k for k in plan.states['scripts'] if k.startswith('member:')):
        plan.reported.append((f'ScriptStates.json scripts["{key}"]', 'retired member switch (ignored since R13): dropped'))
        del plan.states['scripts'][key]
    for item in sorted(old_root.iterdir()) if old_root.is_dir() else []:
        name = item.name
        if item.is_file():
            if name == 'ScriptStates.json':
                continue                                   # becomes Config/ScriptStates.json (schema 2)
            if name == 'renovice.cfg' or is_replacement_file(name):
                plan.copies.append((item, canonical(name), 'config' if name == 'renovice.cfg' else 'replacement'))
            else:
                plan.reported.append((name, 'not part of the V2 layout: left in the old folder'))
            continue
        if name == 'Settings':
            for f in sorted(p for p in item.rglob('*') if p.is_file()):
                if f.parent != item or f.suffix.lower() != '.json':
                    plan.reported.append((f.relative_to(old_root).as_posix(), 'not a Settings/<Package>.json file'))
            continue                                       # the .json files are Config/ScriptStates.json values
        if name in ('Inject', 'Packages') or (include_logs and name in ('Logs', 'Diagnostics')):
            for f in sorted(p for p in item.rglob('*') if p.is_file()):
                rel = f.relative_to(old_root).as_posix()
                if name == 'Inject' and f.parent != item:
                    plan.reported.append((rel, 'sub-folder of Inject: the loader never read it'))
                    continue
                plan.copies.append((f, canonical(rel), {'Inject': 'addon', 'Packages': 'package'}.get(name, 'log')))
            continue
        plan.reported.append((name + '/', 'folder not part of the V2 layout' if name not in ('Logs', 'Diagnostics')
                              else 'runtime output: left in the old folder'))
    return plan


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description=__doc__.split('\n\n')[0])
    sub = ap.add_subparsers(dest='cmd', required=True)
    m = sub.add_parser('merge-states', help='merge a staged ScriptStates fragment into a schema-2 ScriptStates.json')
    m.add_argument('--fragment', type=Path, required=True)
    m.add_argument('--into', type=Path, required=True)
    m.add_argument('--dry-run', action='store_true')
    args = ap.parse_args(argv)
    if args.cmd == 'merge-states':
        fragment = json.loads(args.fragment.read_text(encoding='utf-8'))
        merged = merge_into_file(args.into, fragment, args.dry_run)
        print(f'{"would write" if args.dry_run else "wrote"} {args.into}: {len(merged["scripts"])} switches, '
              f'{len(merged["values"])} values entries ({len(fragment.get("scripts", {}))} switch and '
              f'{len(fragment.get("values", {}))} values changes from the fragment)')
        return 0
    return 2


if __name__ == '__main__':
    sys.exit(main())
