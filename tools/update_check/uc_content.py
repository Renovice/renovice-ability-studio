"""Installed RENOVICE content (OpenWF/LuaScripts, or OpenWF/CustomScripts before layout V2) and the hooks its addons declare.

Inventory rules mirror the runtime (bootstrapper renovice/injection_core.hpp, replacements_core.hpp, packages). Paths are
the canonical ids of uc_layout (the V2 path; the V1 folder is in brackets):
  Replacements/<16-hex key> (name).lua_B [root]       full-module replacement of that content key
  Addons/<16-hex key>.<name>.target.addon.lua_B [Inject] target addon of that key
  Addons/<name>.targets.addon.lua_B                   multi-target addon: every lowercase 16-hex string in the
                                                         bytecode string pool is a declared target key
  Packages/<name>/[package.json] + members             the same lanes inside a package (packages_core.hpp
                                                         classify_member: an ordinary `<16-hex key>...lua_B` member is
                                                         a root replacement; the row state is package:<folder>)
  Packages/<name>/literals.json / engine_params.json   recipe modules (checked in the missions area)
Switches come from Config/ScriptStates.json (V1: ScriptStates.json).

Hooks are read from the installed addon bytes themselves: the addon is decompiled with the toolchain
(`derecomp decompile-mod-u44`, the documented U44 path) into a cache folder and its returned hook tables are parsed:
luaCalls prototype keys per target, nativeCalls methods and the (prototype, instruction) callsite filters of their
callbacks (`transformFloatArgument` is the PushFloatArg adapter).
"""
from __future__ import annotations

import hashlib
import json
import re
import shutil
import subprocess
from dataclasses import dataclass, field
from pathlib import Path

import uc_layout

KEY = re.compile(r'^([0-9a-fA-F]{16})')


@dataclass
class Script:
    kind: str                       # replacement | target-addon | multi-target-addon | managed-addon | inject | swf
    file: Path
    rel: str
    keys: list[str] = field(default_factory=list)
    label: str = ''
    package: str = ''
    state: str = 'unlisted'
    sha256: str = ''
    hooks: dict = field(default_factory=dict)      # key -> {'luaCalls': [p], 'nativeCalls': [{method, callsites}]}
    hook_error: str = ''


def multi_target_keys(data: bytes) -> list[str]:
    """bootstrapper injection_core.hpp discover_multi_target_keys."""
    if len(data) < 3 or data[0] != 9 or data[1] != 3:
        raise ValueError('not-de-bytecode-container')
    o, keys = 2, []

    def vi(o):
        v = sh = 0
        while True:
            b = data[o]
            o += 1
            v |= (b & 0x7F) << sh
            if not b & 0x80:
                return v, o
            sh += 7
    count, o = vi(o)
    for _ in range(count):
        ln, o = vi(o)
        s = data[o:o + ln]
        o += ln
        if ln == 16 and re.fullmatch(rb'[0-9a-f]{16}', s):
            keys.append(s.decode())
    return sorted(set(keys))


def _states(layout: uc_layout.Layout) -> dict:
    doc, _ = layout.read_states()
    return doc.get('scripts', {})


def _label(name: str) -> str:
    m = re.search(r'\(([^)]*)\)', name)
    if m:
        return m.group(1)
    parts = name.split('.')
    return parts[1] if len(parts) > 2 and KEY.match(parts[0]) else parts[0]


def inventory(custom) -> list[Script]:
    """custom: the script root (a Path; its layout is detected with uc_layout.Layout.of) or a uc_layout.Layout."""
    layout = custom if isinstance(custom, uc_layout.Layout) else uc_layout.Layout.of(Path(custom))
    states = _states(layout)
    out: list[Script] = []

    def state(key: str) -> str:
        v = states.get(key.lower())
        return 'unlisted' if v is None else ('enabled' if v else 'disabled')

    loose = layout.replacements
    for f in sorted(loose.glob('*.lua_B')) if loose.is_dir() else []:
        m = KEY.match(f.name)
        if m:
            out.append(Script('replacement', f, f'Replacements/{f.name}', [m.group(1).lower()],
                              f'Replacement: {_label(f.name)}', state=state('replacement:' + f.name)))
    for f in sorted(loose.glob('*.swf')) if loose.is_dir() else []:
        out.append(Script('swf', f, f'Replacements/{f.name}', label=f'SWF replacement: {f.stem}'))
    inject = layout.addons
    for f in sorted(inject.glob('*.lua_B')) if inject.is_dir() else []:
        out.append(_classify(f, f'Addons/{f.name}', '', state))
    packages = layout.packages
    for pkg in sorted(p for p in packages.iterdir() if p.is_dir()) if packages.is_dir() else []:
        try:
            manifest = json.loads((pkg / 'package.json').read_text(encoding='utf-8'))
        except (OSError, ValueError):
            manifest = {}
        pname = manifest.get('name', pkg.name)
        pstate = state('package:' + pkg.name)      # script_control.cpp: one policy ID per package FOLDER
        for f in sorted(pkg.glob('*.lua_B')):
            member = manifest.get('members', {}).get(f.name, {})
            s = _classify(f, f'Packages/{pkg.name}/{f.name}', pname, state, in_package=True)
            s.label = f'{pname}: {member.get("label") or s.label}'
            s.state = f'package {pstate}'      # member switches are retired since contract R13 (ignored by the DLL)
            out.append(s)
    for s in out:
        s.sha256 = hashlib.sha256(s.file.read_bytes()).hexdigest()
    return out


def _classify(f: Path, rel: str, package: str, state, in_package: bool = False) -> Script:
    name = f.name.lower()
    m = KEY.match(f.name)
    if '.targets.addon' in name:
        try:
            keys = multi_target_keys(f.read_bytes())
        except ValueError:
            keys = []
        return Script('multi-target-addon', f, rel, keys, f'Addon: {_label(f.name)}', package,
                      state('target-addon:' + f.name))
    if '.target.addon' in name and m:
        return Script('target-addon', f, rel, [m.group(1).lower()], f'Addon: {_label(f.name)}', package,
                      state('target-addon:' + f.name))
    if '.addon' in name:
        return Script('managed-addon', f, rel, [], f'Managed addon: {f.stem}', package, state('addon:' + f.name))
    if in_package and m and int(m.group(1), 16):
        # packages_core.hpp classify_member: an ordinary package member with a nonzero 16-hex prefix is a root
        # replacement of that content key (a one-shot Inject chunk is not admissible in a package)
        return Script('replacement', f, rel, [m.group(1).lower()], f'Replacement: {_label(f.name)}', package,
                      state('replacement:' + f.name))
    # script_control_core.hpp stable_id: an ordinary (one-shot) script's switch is `oneshot:<file>`
    return Script('inject', f, rel, [], f'Inject: {f.stem}', package, state('oneshot:' + f.name))


# -- hook extraction from the decompiled addon --------------------------------------------------------------------------------
def decompile(derecomp: Path, addon: Path, sha: str, cache: Path) -> str:
    cache.mkdir(parents=True, exist_ok=True)
    out = cache / f'{sha[:16]}.luau'
    if out.is_file() and out.stat().st_size:
        return out.read_text(encoding='utf-8', errors='replace')
    src = cache / f'{sha[:16]}.lua_B'
    shutil.copyfile(addon, src)
    r = subprocess.run([str(derecomp), 'decompile-mod-u44', str(src), str(out)], capture_output=True, text=True,
                       timeout=300)
    if r.returncode != 0 or not out.is_file():
        raise RuntimeError(f'decompile-mod-u44 exit {r.returncode}: {(r.stderr or r.stdout).strip()[:200]}')
    return out.read_text(encoding='utf-8', errors='replace')


TOP = re.compile(r'^  (v\d+) = function\(([^)]*)\)\s*$')


def _top_functions(text: str) -> dict[str, tuple[list[str], list[str]]]:
    """{vN: (params, body lines)} for every top-level local function of the decompiled chunk."""
    lines = text.splitlines()
    out, i = {}, 0
    while i < len(lines):
        m = TOP.match(lines[i])
        if m:
            name, params = m.group(1), [p.strip() for p in m.group(2).split(',') if p.strip()]
            j = i + 1
            while j < len(lines) and lines[j] != '  end':
                j += 1
            out[name] = (params, lines[i + 1:j])
            i = j + 1
        else:
            i += 1
    return out


def _callsite_pairs(fname: str, funcs: dict, depth: int = 0) -> list[tuple[int, int]]:
    """(prototype, instruction) pairs a callback compares its first two parameters with."""
    if fname not in funcs or depth > 2:
        return []
    params, body = funcs[fname]
    if len(params) < 2:
        return []
    alias = {params[0]: 0, params[1]: 1}
    number: dict[str, int] = {}
    found: list[tuple[int, int]] = []
    pending: int | None = None
    for line in body:
        s = line.strip()
        m = re.match(r'^(?:local )?([\w]+) = (-?\d+)$', s)
        if m:
            number[m.group(1)] = int(m.group(2))
            alias.pop(m.group(1), None)
            continue
        m = re.match(r'^(?:local )?([\w]+) = ([\w]+)$', s)
        if m:
            if m.group(2) in alias:
                alias[m.group(1)] = alias[m.group(2)]
            else:
                alias.pop(m.group(1), None)
            number.pop(m.group(1), None)
            continue
        m = re.match(r'^if \(?([\w]+) (==|~=) ([\w]+)', s)
        if m:
            a, b = m.group(1), m.group(3)
            if a in alias and b in number:
                which, value = alias[a], number[b]
            elif b in alias and a in number:
                which, value = alias[b], number[a]
            else:
                continue
            if which == 0:
                pending = value
            elif which == 1 and pending is not None:
                found.append((pending, value))
                pending = None
            continue
        # a helper called with the same first two parameters: c3v4 = v2 ... c3v4(c3v0, c3v1, ...)
        m = re.match(r'^[\w]+ = ([\w]+)\(([\w]+), ([\w]+)', s)
        if m and alias.get(m.group(2)) == 0 and alias.get(m.group(3)) == 1:
            callee = m.group(1)
            resolved = callee if callee in funcs else None
            if resolved is None:
                for prev in body:
                    mm = re.match(r'^\s*' + re.escape(callee) + r' = (v\d+)$', prev)
                    if mm:
                        resolved = mm.group(1)
            if resolved:
                found += _callsite_pairs(resolved, funcs, depth + 1)
    return found


def _hook_tables(lines: list[str], funcs: dict) -> dict:
    """luaCalls keys and nativeCalls callbacks assigned anywhere in `lines`."""
    luacalls, native = [], {}
    assign_num = {}
    method_tables: dict[str, dict[str, str]] = {}     # table var -> {method: entry var}
    entry_callbacks: dict[str, dict[str, str]] = {}   # entry var -> {before/after: callback}
    for line in lines:
        s = line.strip()
        m = re.match(r'^([\w]+) = \{', s)
        if m:                                   # a register is reused for a fresh table: forget its old fields
            entry_callbacks.pop(m.group(1), None)
            method_tables.pop(m.group(1), None)
            assign_num.pop(m.group(1), None)
        m = re.match(r'^([\w]+)\[(\d+)\] = ([\w]+)$', s)
        if m:
            assign_num.setdefault(m.group(1), []).append(int(m.group(2)))
        m = re.match(r'^([\w]+)\.luaCalls = ([\w]+)$', s)
        if m:
            luacalls += assign_num.get(m.group(2), [])
        m = re.match(r'^([\w]+)\.(before|after) = ([\w]+)$', s)
        if m:
            entry_callbacks.setdefault(m.group(1), {})[m.group(2)] = m.group(3)
        m = re.match(r'^([\w]+)\.([A-Z]\w*) = ([\w]+)$', s)
        if m:                                   # snapshot the entry's callbacks at the method assignment
            method_tables.setdefault(m.group(1), {})[m.group(2)] = dict(entry_callbacks.get(m.group(3), {}))
        m = re.match(r'^([\w]+)\.nativeCalls = ([\w]+)$', s)
        if m:
            for method, cbs in method_tables.get(m.group(2), {}).items():
                pairs = sorted({p for cb in cbs.values() for p in _callsite_pairs(cb, funcs)})
                native[method] = {'callbacks': sorted(cbs), 'callsites': [list(p) for p in pairs]}
        m = re.match(r'^([\w]+)\.transformFloatArgument = ([\w]+)$', s)
        if m:
            pairs = sorted(set(_callsite_pairs(m.group(2), funcs)))
            native['PushFloatArg'] = {'callbacks': ['transformFloatArgument'], 'callsites': [list(p) for p in pairs]}
    return {'luaCalls': sorted(set(luacalls)), 'nativeCalls': native}


def extract_hooks(script: Script, text: str) -> dict:
    funcs = _top_functions(text)
    if script.kind == 'target-addon':
        return {script.keys[0]: _hook_tables(text.splitlines(), funcs)}
    # multi-target: targets[key] = vN() at the chunk's end
    lines = text.splitlines()
    result, last_call = {}, {}
    for line in lines:
        s = line.strip()
        m = re.match(r'^([\w]+) = (v\d+)\(\)$', s)
        if m:
            last_call[m.group(1)] = m.group(2)
            continue
        m = re.match(r'^[\w]+(?:\["([0-9a-f]{16})"\]|\.([0-9a-f]{16})) = ([\w]+)$', s)
        if m and m.group(3) in last_call:
            key = m.group(1) or m.group(2)
            fn = last_call[m.group(3)]
            body = funcs.get(fn, ([], []))[1]
            result[key] = _hook_tables(body, funcs)
    return result
