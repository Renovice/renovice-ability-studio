"""Bootstrapper side of the post-update check: build allowlists, per-build tables and native signatures.

The bootstrapper's facts are read from its git repository at a pinned ref (`git show`), never from its worktree, so
the check does not depend on which branch that worktree has checked out. The executable is read, never written.
Every check mirrors an existing runtime rule or offline gate:

  allowlist          main.cpp build gate (supported_builds_44 / supported_client_sha256_44 in tunables.json, as the
                     installed OpenWF/Hotfix.owf carries it and as the source carries it) and the certified table of
                     RENOVICE_TOOLCHAIN/version44/verify_client_44.ps1
  per-build tables   renovice/engine_damage_builds.hpp (admit_codec + verify_engine_damage_codec.cpp checks) and
                     renovice/engine_params_builds.hpp (admit_image byte ranges, name-hash seed)
  DE_VM_AUTHORITY    de_vm_authority_core.hpp lock identity (verify_client_44.cpp verify_de_vm_authority)
  luaCalls boundary  injected_interrupt_budget.hpp leaf + owner callback (resolve_unique in injection.cpp)
  RunScript/natives  wf_hash names the runtime resolves (SWIG method hash rows, verify_client_44 native rows)
  OpenWF frame       application_frame_profile.hpp select_unique_profile
  undump             verify_client_44 "DE Luau undump" row and its registered raw offset
  WTS proxy          verify_client_44 "WTS proxy export coverage"
  census             every hex-pattern literal in main.cpp and renovice/*.{cpp,hpp} plus OpenWF/vv/sig/*.json (the
                     DE_VM_AUTHORITY 44.0.2 census method), compared with the baseline counts of the last certified build
"""
from __future__ import annotations

import hashlib
import json
import re
import struct
import subprocess
import zlib
from pathlib import Path

from uc_bytecode import name_hash
from uc_pe import pattern_regex
from uc_report import OK, BROKEN, UNKNOWN

# Census rows: file prefix -> user-facing feature.
FILE_FEATURES = [
    ('renovice/de_vm_authority', 'DE Lua API: VM capture, Scripts menu, Inject/addons, F9 reload'),
    ('renovice/injection_core', 'DE Lua injection: module loader, addons, replacements'),
    ('renovice/injected_interrupt_budget', 'luaCalls before-hooks (Missions, mission addons)'),
    ('renovice/vm_memory_evidence', 'VM memory diagnostics'),
    ('renovice/vm_stack_write', 'Addon hooks: argument/result write-back (luaCalls, nativeCalls)'),
    ('renovice/riven_core', 'Riven lock UI'),
    ('renovice/swf_core', 'SWF replacements'),
    ('renovice/engine_damage', 'ENGINE_DAMAGE observer (battle log, Mallet Overguard numbers)'),
    ('renovice/replacements', 'Replacement lane (loose .lua_B replacements)'),
    ('renovice/application_frame_profile', 'OpenWF frame tick (hotkeys F9/F10, safe runtime tick)'),
    ('renovice/', 'RENOVICE runtime'),
    ('main.cpp', 'OpenWF bootstrapper'),
    ('OpenWF/vv/sig/', 'OpenWF bootstrapper (versioned signature)'),
]
LUA_STACK_FEATURE = 'DE Lua API (every script, addon and package)'
HEX_LITERAL = re.compile(r'"((?:[0-9A-Fa-f]{2}|\?\??)(?: +(?:[0-9A-Fa-f]{2}|\?\??)){3,})"')
NAME_HASH_FUNCTION = ('B8 ? ? ? ? 48 85 D2 74 ? 66 0F 1F 44 00 00 44 0F B6 01 48 8D 49 01 44 33 C0 41 69 C0 '
                      '93 01 00 01 48 83 EA 01 75 ? F7 D0 C1 C0 11 C3')


def feature_for(path: str) -> str:
    for prefix, feature in FILE_FEATURES:
        if path.replace('\\', '/').startswith(prefix):
            return feature
    return 'RENOVICE runtime'


def loads_jsonc(text: str):
    """JSON with // comments and trailing commas (the OpenWF data files)."""
    out, i, n, in_str = [], 0, len(text), False
    while i < n:
        c = text[i]
        if in_str:
            out.append(c)
            if c == '\\':
                out.append(text[i + 1])
                i += 1
            elif c == '"':
                in_str = False
        elif c == '"':
            in_str = True
            out.append(c)
        elif text.startswith('//', i):
            while i < n and text[i] != '\n':
                i += 1
            continue
        else:
            out.append(c)
        i += 1
    cleaned = re.sub(r',(\s*[}\]])', r'\1', ''.join(out))
    cleaned = re.sub(r'"(?:[^"\\]|\\.)*"|\b0x[0-9a-fA-F]+\b',
                     lambda m: m.group(0) if m.group(0).startswith('"') else str(int(m.group(0), 16)), cleaned)
    return json.loads(cleaned)


def gv2n(ver: str) -> int:
    parts = [int(x) for x in ver.split('.')] + [0, 0]
    return parts[0] * 10000 + parts[1] * 100 + parts[2]


def joaat(text: str | bytes) -> int:
    h = 0
    for c in (text.encode() if isinstance(text, str) else text):
        h = (h + c) & 0xFFFFFFFF
        h = (h + (h << 10)) & 0xFFFFFFFF
        h ^= h >> 6
    h = (h + (h << 3)) & 0xFFFFFFFF
    h ^= h >> 11
    return (h + (h << 15)) & 0xFFFFFFFF


class GitSource:
    """Files of a repository at one ref, read with git (no checkout)."""

    def __init__(self, repo: Path, ref: str):
        self.repo, self.ref = repo, ref
        self.commit = self._git('rev-parse', ref).strip()
        self._files = self._git('ls-tree', '-r', '--name-only', self.commit).splitlines()

    def _git(self, *args) -> str:
        return subprocess.run(['git', '-C', str(self.repo), *args], capture_output=True, text=True, check=True,
                              encoding='utf-8', errors='replace').stdout

    def files(self, prefix: str = '') -> list[str]:
        return [f for f in self._files if f.startswith(prefix)]

    def read(self, path: str) -> str:
        return self._git('show', f'{self.commit}:{path}')

    def has(self, path: str) -> bool:
        return path in self._files


# -- small decoders ------------------------------------------------------------------------------------------------------
def u64_dyn_bp(b: bytes, o: int) -> tuple[int, int]:
    first = b[o]
    prefix = 0
    while prefix < 8 and first & (0x80 >> prefix):
        prefix += 1
    length = prefix + 1
    value_bits = 8 - length if length < 8 else 0
    v = 0
    for idx in range(1, length):
        v |= b[o + idx] << ((idx - 1) * 8)
    v = (v << value_bits) | (first & ((1 << value_bits) - 1))
    bias = 0
    for _ in range(length - 1):
        bias = (bias + 1) << 7
    return v + bias, o + length


def msgpack(b: bytes, o: int = 0):
    t = b[o]
    if t <= 0x7F:
        return t, o + 1
    if 0x80 <= t <= 0x8F or t in (0xDE, 0xDF):
        if t <= 0x8F:
            n, o = t & 0x0F, o + 1
        elif t == 0xDE:
            n, o = struct.unpack_from('>H', b, o + 1)[0], o + 3
        else:
            n, o = struct.unpack_from('>I', b, o + 1)[0], o + 5
        out = {}
        for _ in range(n):
            k, o = msgpack(b, o)
            v, o = msgpack(b, o)
            out[k] = v
        return out, o
    if 0x90 <= t <= 0x9F or t in (0xDC, 0xDD):
        if t <= 0x9F:
            n, o = t & 0x0F, o + 1
        elif t == 0xDC:
            n, o = struct.unpack_from('>H', b, o + 1)[0], o + 3
        else:
            n, o = struct.unpack_from('>I', b, o + 1)[0], o + 5
        out = []
        for _ in range(n):
            v, o = msgpack(b, o)
            out.append(v)
        return out, o
    if 0xA0 <= t <= 0xBF or t in (0xD9, 0xDA, 0xDB):
        if t <= 0xBF:
            n, o = t & 0x1F, o + 1
        else:
            w = {0xD9: 1, 0xDA: 2, 0xDB: 4}[t]
            n, o = int.from_bytes(b[o + 1:o + 1 + w], 'big'), o + 1 + w
        return b[o:o + n].decode('utf-8', 'replace'), o + n
    if t == 0xC0:
        return None, o + 1
    if t in (0xC2, 0xC3):
        return t == 0xC3, o + 1
    if t >= 0xE0:
        return t - 0x100, o + 1
    fmt = {0xCC: '>B', 0xCD: '>H', 0xCE: '>I', 0xCF: '>Q', 0xD0: '>b', 0xD1: '>h', 0xD2: '>i', 0xD3: '>q',
           0xCA: '>f', 0xCB: '>d'}.get(t)
    if fmt:
        return struct.unpack_from(fmt, b, o + 1)[0], o + 1 + struct.calcsize(fmt)
    raise ValueError(f'msgpack type 0x{t:02x} not supported')


def decode_hotfix(data: bytes) -> tuple[int, dict[int, bytes]]:
    """(title hash, {joaat(path): bytes}) of an OpenWF Hotfix.owf (owf_repo.cpp loadHotfix/loadArchive)."""
    title = struct.unpack_from('<I', data, 0)[0]
    o = 5                                           # u32 title hash + u8 hotfix number
    _ts, o = u64_dyn_bp(data, o)
    size, o = u64_dyn_bp(data, o)
    payload = None
    for wbits in (-15, 15, 31):
        try:
            d = zlib.decompressobj(wbits)
            payload = d.decompress(data[o:])
            if len(payload) == size:
                break
        except zlib.error:
            payload = None
    if payload is None or len(payload) != size:
        raise ValueError('Hotfix.owf payload did not inflate to its declared size')
    files, p = {}, 0
    while p < len(payload):
        key = struct.unpack_from('<I', payload, p)[0]
        n, p = u64_dyn_bp(payload, p + 4)
        files[key] = payload[p:p + n]
        p += n
    return title, files


# -- C++ table parsers -------------------------------------------------------------------------------------------------------
_TOKEN = re.compile(r'"((?:[^"\\]|\\.)*)"|(0x[0-9a-fA-F]+|\b\d+\b)')


def _tokens(text: str, anchor: str) -> list:
    start = text.index(anchor)
    end = text.index('}};', start)
    body = re.sub(r'"\s*\n\s*"', '', text[start + len(anchor):end])     # adjacent string literals
    body = re.sub(r'//[^\n]*', '', body)
    out = []
    for m in _TOKEN.finditer(body):
        out.append(m.group(1) if m.group(1) is not None else int(m.group(2), 0))
    return out


def parse_engine_damage_builds(text: str) -> list[dict]:
    t = _tokens(text, 'registered_builds{{')
    builds, i = [], 0
    while i < len(t):
        label, d1, d2 = t[i], t[i + 1], t[i + 2]
        i += 3
        nums = []
        while i < len(t) and isinstance(t[i], int):
            nums.append(t[i])
            i += 1
        if len(nums) != 21:
            raise ValueError(f'engine_damage_builds: {label}: expected 21 numbers, found {len(nums)}')
        names = ['control_target', 'target_health_slot', 'control_shield_slot', 'control_overguard_slot',
                 'packet_fractions', 'packet_value', 'value_encoded', 'value_addition', 'value_override',
                 'value_cached', 'value_flags', 'value_override_flag', 'value_cached_flag']
        builds.append({'label': label, 'digests': [d for d in (d1, d2) if d], 'handlers': nums[0:3],
                       'evaluator': nums[3], 'integer_codec': tuple(nums[4:6]), 'float_codec': tuple(nums[6:8]),
                       'layout': dict(zip(names, nums[8:21]))})
    return builds


def parse_engine_params_builds(text: str) -> list[dict]:
    t = _tokens(text, 'registered_builds{{')
    builds, i = [], 0
    while i < len(t):
        label, d1, d2 = t[i], t[i + 1], t[i + 2]
        i += 3
        nums = []
        while i < len(t) and isinstance(t[i], int) and not (i + 1 < len(t) and isinstance(t[i + 1], str)):
            nums.append(t[i])
            i += 1
        checks = []
        while i + 2 < len(t) and isinstance(t[i], int) and isinstance(t[i + 1], str) and isinstance(t[i + 2], str):
            checks.append({'rva': t[i], 'hex': t[i + 1], 'reason': t[i + 2]})
            i += 3
        builds.append({'label': label, 'digests': [d for d in (d1, d2) if d], 'push_value_rva': nums[0],
                       'seed': nums[1], 'layout': nums[2:], 'checks': checks})
    return builds


def parse_certified_clients(ps1: str) -> list[dict]:
    out = []
    for block in re.findall(r'@\{(.*?)\}', ps1, re.S):
        fields = dict(re.findall(r'(\w+)\s*=\s*"([^"]*)"', block))
        if 'Sha256' in fields:
            out.append(fields)
    return out


def cpp_string(text: str, name: str) -> str:
    m = re.search(name + r'\[\]\s*=\s*((?:\s*"[^"]*")+)\s*;', text) or \
        re.search(name + r'\s*=\s*((?:\s*"[^"]*")+)\s*;', text)
    if not m:
        raise ValueError(f'string constant {name} not found')
    return ''.join(re.findall(r'"([^"]*)"', m.group(1)))


def cpp_int(text: str, name: str) -> int:
    m = re.search(name + r'\s*=\s*(0x[0-9a-fA-F]+|\d+)', text)
    if not m:
        raise ValueError(f'integer constant {name} not found')
    return int(m.group(1), 0)


# -- census --------------------------------------------------------------------------------------------------------------------
def census_rows(src: GitSource, game_version: int) -> list[dict]:
    rows = []
    files = ['main.cpp'] + sorted(f for f in src.files('renovice/') if f.endswith(('.cpp', '.hpp')))
    for f in files:
        text = src.read(f)
        joined = re.sub(r'"(\s*(?://[^\n]*)?\s*)"', lambda m: ' ' if m.group(1).strip() == '' else m.group(0), text)
        seen = {}
        for m in HEX_LITERAL.finditer(joined):
            line_start = joined.rfind('\n', 0, m.start()) + 1
            line_end = joined.find('\n', m.end())
            context = joined[line_start:line_end].strip()
            if context.startswith('"') or len(context) < 12:
                prev = joined.rfind('\n', 0, line_start - 1) + 1
                context = joined[prev:line_start].strip() + ' ' + context
            pattern = ' '.join(m.group(1).split()).upper()
            ordinal = seen.get(pattern, 0)
            seen[pattern] = ordinal + 1
            first = text.find(m.group(1)[:23])        # line in the original text (joining literals moves lines)
            rows.append({'id': f'{f}#{hashlib.sha1(pattern.encode()).hexdigest()[:10]}#{ordinal}', 'file': f,
                         'line': text.count('\n', 0, first) + 1 if first >= 0 else 0, 'context': context[:110],
                         'pattern': pattern, 'commented': context.lstrip().startswith('//')})
    for f in sorted(src.files('OpenWF/vv/sig/')):
        if not f.endswith('.json'):
            continue
        table = loads_jsonc(src.read(f))
        best = None
        for ver, pattern in table.items():
            if gv2n(ver) <= game_version and (best is None or gv2n(ver) > gv2n(best[0])):
                best = (ver, pattern)
        if best and best[1]:
            pattern = ' '.join(best[1].split()).upper()
            rows.append({'id': f'{f}@{best[0]}', 'file': f, 'line': 0, 'context': f'{Path(f).stem} (version {best[0]})',
                         'pattern': pattern, 'commented': False})
    return rows


# -- checks ---------------------------------------------------------------------------------------------------------------------
class NativeChecks:
    def __init__(self, report, img, exe_sha: str, build: str, src: GitSource, baseline: dict, game: Path):
        self.r, self.img, self.sha, self.build, self.src, self.base, self.game = \
            report, img, exe_sha, build, src, baseline, game
        self.collected: dict = {'signatures': {}, 'natives': {}, 'rvas': {}}
        self.game_version = None

    def run(self, dll_path: Path):
        self.build_identity()
        self.allowlists()
        self.engine_damage()
        self.engine_params()
        self.de_vm_authority()
        self.lua_call_boundary()
        self.native_names()
        self.openwf_frame()
        self.undump()
        self.wts_proxy(dll_path)
        self.census()
        return self.collected

    # build identity and allowlists -------------------------------------------------------------------------------------
    def build_identity(self):
        versions = loads_jsonc(self.src.read('OpenWF/vv/game_versions.json'))
        gv = None
        for date, ver in sorted(versions.items()):
            if date <= self.build:
                gv = ver
        self.game_version = gv2n(gv) if gv else 0
        tun = loads_jsonc(self.src.read('OpenWF/tunables.json'))
        toonew = gv2n(tun.get('toonew', {}).get('$gv', '0'))
        ok = gv is not None and self.game_version < toonew
        self.r.add('build', 'build.game_version', f'Game version of client {self.build}',
                   OK if ok else BROKEN,
                   f'game_versions.json -> {gv}; toonew {tun.get("toonew", {}).get("$gv")}' if ok else
                   f'game version {gv} is not below the toonew cutoff {tun.get("toonew", {}).get("$gv")} '
                   '(the bootstrapper refuses to start)',
                   [LUA_STACK_FEATURE, 'OpenWF bootstrapper start'], game_version=gv)

    def allowlists(self):
        family = 44 if self.game_version >= 440000 else 43
        lists = (f'supported_builds_{family}', f'supported_client_sha256_{family}')
        feats = ['OpenWF bootstrapper start (unsupported build = refuses to start)', LUA_STACK_FEATURE]
        # installed Hotfix.owf
        hotfix_path = self.game / 'OpenWF' / 'Hotfix.owf'
        main_hpp = self.src.read('main.hpp')
        title = re.search(r'#define BOOTSTRAPPER_TITLE "([^"]+)"', main_hpp).group(1)
        try:
            htitle, files = decode_hotfix(hotfix_path.read_bytes())
            tunables, _ = msgpack(files[joaat('OpenWF/tunables.json')])
            title_ok = htitle == joaat(title)
            for name, value in ((lists[0], self.build), (lists[1], self.sha)):
                arr = tunables.get(joaat(name))
                present = isinstance(arr, list) and joaat(value) in arr
                self.r.add('build', 'build.allowlist.hotfix', f'Installed OpenWF/Hotfix.owf {name}',
                           OK if present else BROKEN,
                           f'{value[:16]} listed ({len(arr)} entries)' if present else
                           f'{value} is not in the installed Hotfix.owf {name}', feats)
            self.r.add('build', 'build.allowlist.hotfix_title', 'Installed Hotfix.owf belongs to this bootstrapper',
                       OK if title_ok else UNKNOWN,
                       f'title hash = joaat("{title}")' if title_ok else
                       f'Hotfix.owf title hash 0x{htitle:08x} != joaat("{title}") 0x{joaat(title):08x}: the DLL ignores '
                       'it and uses its built-in tunables', feats)
        except Exception as e:  # noqa: BLE001
            self.r.add('build', 'build.allowlist.hotfix', 'Installed OpenWF/Hotfix.owf tunables', UNKNOWN,
                       f'could not decode {hotfix_path}: {e}', feats)
        # source tunables.json (what the next DLL / Hotfix build ships)
        tun = loads_jsonc(self.src.read('OpenWF/tunables.json'))
        for name, value in ((lists[0], self.build), (lists[1], self.sha)):
            present = value in (tun.get(name) or [])
            self.r.add('build', 'build.allowlist.source', f'Bootstrapper source OpenWF/tunables.json {name}',
                       OK if present else BROKEN, 'listed' if present else f'{value} missing from {name}', feats)
        # certified table of the offline verifier
        clients = parse_certified_clients(self.src.read('RENOVICE_TOOLCHAIN/version44/verify_client_44.ps1'))
        hit = [c for c in clients if c.get('Sha256', '').lower() == self.sha]
        self.r.add('build', 'build.allowlist.verifier', 'verify_client_44.ps1 certified client table',
                   OK if hit else BROKEN,
                   f'certified as {hit[0].get("Version")}' if hit else
                   f'sha256 {self.sha[:16]} is not certified (verify_client_44.ps1 refuses to scan)',
                   ['Offline client certification gate'])
        self.collected['certified_undump'] = hit[0] if hit else None
        self.collected['allowlisted'] = bool(hit)

    # per-build tables ---------------------------------------------------------------------------------------------------
    def engine_damage(self):
        feats = ['ENGINE_DAMAGE observer (battle log, Mallet Overguard/health/shield numbers)']
        builds = parse_engine_damage_builds(self.src.read('renovice/engine_damage_builds.hpp'))
        reg = next((b for b in builds if self.sha in b['digests']), None)
        self.r.add('build', 'build.table.engine_damage', 'renovice/engine_damage_builds.hpp registration',
                   OK if reg else BROKEN, f'registered as {reg["label"]}' if reg else
                   f'digest {self.sha[:16]} has no registration: ENGINE_DAMAGE installs nothing on this client',
                   feats)
        probe = reg or builds[-1]
        tag = '' if reg else f' (probe with the latest registration {probe["label"]})'
        img = self.img
        text = next(s for s in img.sections if s[0] == '.text')
        rdata = next(s for s in img.sections if s[0] == '.rdata')
        rot, key = probe['integer_codec']
        acc = re.compile(re.escape(bytes([0x48, 0x81, 0xC1])) + b'....' + re.escape(
            bytes([0x8B, 0x01, 0xC1, 0xC0, rot, 0x48, 0xC1, 0xF9, 0x03, 0x33, 0xC1, 0x35]) + struct.pack('<I', key)
            + b'\xc3'), re.S)
        mem = img.mem
        accessors = {m.start() for m in acc.finditer(mem, text[1], text[1] + text[2])}
        lay = probe['layout']
        frot, fkey = probe['float_codec']
        b = lambda v: v & 0xFF  # noqa: E731
        evaluator = bytes([0x44, 0x0f, 0xb6, 0x41, b(lay['value_flags']), 0x48, 0x8b, 0xd1, 0x41, 0xf6, 0xc0,
                           lay['value_override_flag'], 0x74, 0x06, 0xf3, 0x0f, 0x10, 0x41, b(lay['value_override']), 0xc3,
                           0xf3, 0x0f, 0x10, 0x49, 0x1c, 0x41, 0xf6, 0xc0, lay['value_cached_flag'], 0x74, 0x0c,
                           0xf3, 0x0f, 0x10, 0x41, b(lay['value_cached']), 0xf3, 0x0f, 0x58, 0x41, b(lay['value_addition']),
                           0xeb, 0x1f, 0x48, 0x8d, 0x41, b(lay['value_encoded']), 0x8b, 0x49, b(lay['value_encoded']),
                           0xc1, 0xc1, frot, 0x48, 0xc1, 0xf8, 0x03, 0x33, 0xc8, 0x81, 0xf1]) + struct.pack('<I', fkey) + \
            bytes([0x66, 0x0f, 0x6e, 0xc1, 0xf3, 0x0f, 0x58, 0x42, b(lay['value_addition'])])
        eval_ok = img.bytes_at(probe['evaluator'], len(evaluator)) == evaluator
        eval_hits = img.scan(' '.join(f'{x:02X}' for x in evaluator), limit=4)
        self.r.add('build', 'build.table.engine_damage.codec', f'ENGINE_DAMAGE codec admission{tag}',
                   OK if accessors and eval_ok and reg else (UNKNOWN if not reg else BROKEN),
                   f'{len(accessors)} integer accessors rol{rot}/0x{key:08x}; evaluator at 0x{probe["evaluator"]:x} '
                   f'{"matches" if eval_ok else "DIFFERS"} (exact evaluator found at '
                   f'{", ".join(hex(h) for h in eval_hits) or "nowhere"})', feats,
                   accessors=len(accessors), evaluator_rva=probe['evaluator'], evaluator_hits=eval_hits)
        # vtables: handler0 at +0xf8 must have registered-codec accessors at the shield/Overguard slots
        base = struct.unpack_from('<Q', img.file, struct.unpack_from('<I', img.file, 0x3C)[0] + 24 + 24)[0]
        words = memoryview(mem)[rdata[1]:rdata[1] + (rdata[2] // 8) * 8].cast('Q')
        handler0 = base + probe['handlers'][0]
        tables = good = 0
        acc_va = {base + a for a in accessors}
        for idx in range(len(words)):
            if words[idx] == handler0 and idx * 8 >= 0xF8:
                t = idx - 0xF8 // 8
                tables += 1
                s = words[t + lay['control_shield_slot'] // 8]
                g = words[t + lay['control_overguard_slot'] // 8]
                good += s in acc_va and g in acc_va
        health = 0
        tlo, thi = base + text[1], base + text[1] + text[2]
        for idx in range(len(words)):
            if words[idx] in acc_va:
                start = idx
                while start > 0 and tlo <= words[start - 1] < thi:
                    start -= 1
                health += (idx - start) * 8 == lay['target_health_slot']
        ok = tables > 0 and good == tables and health > 0
        self.r.add('build', 'build.table.engine_damage.slots', f'ENGINE_DAMAGE vtable slots{tag}',
                   OK if ok and reg else (UNKNOWN if not reg else BROKEN),
                   f'{tables} DamageControl vtables hold handler0 0x{probe["handlers"][0]:x}, {good} with codec accessors '
                   f'at shield 0x{lay["control_shield_slot"]:x}/Overguard 0x{lay["control_overguard_slot"]:x}; '
                   f'{health} vtables with an accessor at health 0x{lay["target_health_slot"]:x}', feats)
        self.collected['engine_damage'] = {'registered': bool(reg), 'accessors': len(accessors),
                                           'evaluator_hits': eval_hits, 'damagecontrol_vtables': tables}

    def engine_params(self):
        feats = ['Missions: engine-parameter overrides (Railjack kill goals, Interception, Spy, Sabotage, Exterminate)']
        builds = parse_engine_params_builds(self.src.read('renovice/engine_params_builds.hpp'))
        reg = next((b for b in builds if self.sha in b['digests']), None)
        self.r.add('build', 'build.table.engine_params', 'renovice/engine_params_builds.hpp registration',
                   OK if reg else BROKEN, f'registered as {reg["label"]}' if reg else
                   f'digest {self.sha[:16]} has no registration: ENGINE_PARAM_OVERRIDE installs nothing '
                   '(addon entry lane keeps the values)', feats)
        probe = reg or builds[-1]
        tag = '' if reg else f' (probe with {probe["label"]})'
        for c in probe['checks']:
            want = bytes.fromhex(c['hex'])
            have = self.img.bytes_at(c['rva'], len(want))
            ok = have == want
            moved = [] if ok else self.img.scan(' '.join(f'{x:02X}' for x in want), limit=3)
            self.r.add('native', 'native.engine_params.range', f'engine param writer byte range 0x{c["rva"]:x} '
                       f'({len(want)} B){tag}', OK if ok else BROKEN,
                       'identical' if ok else f'{c["reason"]}: {sum(x != y for x, y in zip(have, want))} bytes differ'
                       + (f'; the exact bytes now sit at {", ".join(hex(m) for m in moved)}' if moved else
                          '; the exact bytes occur nowhere in the image'), feats, rva=c['rva'], moved=moved)
        self.collected['engine_params'] = {'registered': bool(reg), 'push_value_rva': probe['push_value_rva']}

    # signatures with structure -----------------------------------------------------------------------------------------
    def de_vm_authority(self):
        core = self.src.read('renovice/de_vm_authority_core.hpp')
        thunk_sig = cpp_string(core, 'signature_lock_thunk')
        slot_disp = cpp_int(core, 'lock_thunk_slot_displacement')
        capacity = cpp_int(core, 'lock_thunk_scan_capacity')
        module = cpp_string(core, 'lock_import_module')
        imports = (cpp_string(core, 'signature_lock_enter_import'), cpp_string(core, 'signature_lock_leave_import'))
        disp_sig = cpp_string(core, 'signature_locked_dispatcher')
        enter_disp = cpp_int(core, 'locked_dispatcher_enter_displacement')
        epi_sig = cpp_string(core, 'signature_locked_dispatcher_epilogue')
        window = cpp_int(core, 'locked_dispatcher_epilogue_window')
        leave_disp = cpp_int(core, 'locked_dispatcher_leave_displacement')
        feats = ['DE Lua API: VM capture, Scripts menu, Inject/addons, target addons, F9 reload (whole DE Lua lane)']
        thunks = self.img.scan(thunk_sig)
        resolved = []
        for label, imp in zip(('lock-enter', 'lock-leave'), imports):
            slot = self.img.import_slot(module, imp)
            hits = [t for t in thunks if slot and self.img.rel32_target(t + slot_disp) == slot]
            ok = slot != 0 and len(thunks) < capacity and len(hits) == 1
            resolved.append(hits[0] if len(hits) == 1 else 0)
            self.r.add('native', 'native.de_vm_authority', f'DE_VM_AUTHORITY {label}', OK if ok else BROKEN,
                       f'matches={len(hits)} thunks={len(thunks)} import={module}!{imp} '
                       f'slot={"0x%x" % slot if slot else "missing"} rva=0x{resolved[-1]:x}', feats)
        disp = self.img.scan(disp_sig)
        detail = f'matches={len(disp)}'
        ok = len(disp) == 1
        if ok:
            d = disp[0]
            enter = self.img.rel32_target(d + enter_disp)
            win = self.img.mem[d:d + window]
            epis = [m.start() for m in pattern_regex(epi_sig).finditer(win)]
            leave = self.img.rel32_target(d + epis[0] + leave_disp) if len(epis) == 1 else 0
            ok = len(epis) == 1 and enter == resolved[0] != 0 and leave == resolved[1] != 0
            detail += f' epilogues={len(epis)} rva=0x{d:x} enter=0x{enter:x} leave=0x{leave:x}'
            if not ok:
                detail += ' (cross-check with the lock thunks failed)'
            self.collected['rvas'].update(locked_dispatcher=d, lock_enter=resolved[0], lock_leave=resolved[1])
        self.r.add('native', 'native.de_vm_authority', 'DE_VM_AUTHORITY locked-dispatcher', OK if ok else BROKEN,
                   detail, feats)

    def lua_call_boundary(self):
        src = self.src.read('renovice/injected_interrupt_budget.hpp')
        inc = cpp_string(src, 'signature_interrupt_increment_u43')
        guard = cpp_string(src, 'signature_interrupt_guard_u43')
        feats = ['luaCalls before-hooks: Missions values, mission target addons (every luaCalls hook)']
        a, g = self.img.scan(inc), self.img.scan(guard)
        ok = len(a) == 1 and len(g) == 1
        self.r.add('native', 'native.lua_calls.boundary', 'luaCalls boundary: interrupt counter leaf',
                   OK if len(a) == 1 else BROKEN, f'matches={len(a)}' + (f' rva=0x{a[0]:x}' if a else ''), feats)
        detail = f'matches={len(g)}' + (f' rva=0x{g[0]:x}' if g else '')
        status = OK if len(g) == 1 else BROKEN
        if ok:
            call = g[0] + guard.split().index('E8') + 1
            target = self.img.rel32_target(call)
            if target != a[0]:
                status = UNKNOWN
                detail += f'; its call goes to 0x{target:x}, not the leaf 0x{a[0]:x}'
            else:
                detail += f'; calls the leaf 0x{a[0]:x}'
            self.collected['rvas'].update(interrupt_leaf=a[0], interrupt_owner_callback=g[0])
            label = re.search(r'boundary=DE-interrupt-counter-leaf-0x([0-9A-Fa-f]+) owner-callback=0x([0-9A-Fa-f]+)',
                              self.src.read('renovice/injection.cpp'))
            if label:
                self.r.note('native', f'The runtime\'s `luaCalls before observer` log line prints the fixed text '
                                      f'leaf 0x{label.group(1)} / owner-callback 0x{label.group(2)}; on this client '
                                      f'the signatures resolve to leaf 0x{a[0]:X} / callback 0x{g[0]:X}. Resolution '
                                      'is by signature, so the label is cosmetic.')
        self.r.add('native', 'native.lua_calls.boundary', 'luaCalls boundary: owner callback (interrupt guard)',
                   status, detail, feats)

    def native_names(self):
        """Names the runtime resolves through the game's own name hash at run time (SWIG method tables)."""
        inj = self.src.read('renovice/injection.cpp')
        names = sorted(set(re.findall(r'wf_hash\("([A-Za-z0-9_]+)"\)', inj)))
        seed = self.collected.get('seed') or self._seed()
        base_rows = self.base.get('natives', {})
        for n in names:
            h = name_hash(n, seed)
            pattern = ' '.join(f'{x:02X}' for x in struct.pack('<I', h)) + ' 00 00 00 00'
            count = len(self.img.scan(pattern, limit=64))
            self.collected['natives'][n] = count
            expected = base_rows.get(n)
            feat = {'RunScript': 'RunScript observer: ability-card rows (Mallet, Ice Wave cards)',
                    'PushFloatArg': 'nativeCalls float transform (Mallet threat level)',
                    'SetDamageCallback': 'afterDamage hooks (Mallet Overguard)',
                    'SetSourceObject': 'afterDamage hooks (damage source)',
                    'GetAbilityUpgradeLevelInfo': 'ability-card compatibility path'}.get(n, 'RENOVICE runtime native binding')
            if expected is None:
                status, why = UNKNOWN, f'{count} method-table rows (no baseline count)'
            elif expected == 0:
                continue                      # not a static method-table name (globals); nothing to compare
            elif count == expected:
                status, why = OK, f'{count} method-table rows (baseline {expected})'
            elif count == 0:
                status, why = BROKEN, f'hash 0x{h:08x} has 0 method-table rows (baseline {expected})'
            else:
                status, why = UNKNOWN, f'{count} method-table rows (baseline {expected}): review the binding'
            self.r.add('native', 'native.name', f'native name {n}', status, why, [feat], hash=f'{h:08x}')

    def _seed(self) -> int:
        hits = self.img.scan(NAME_HASH_FUNCTION, limit=4)
        seeds = sorted({self.img.u32(h + 1) for h in hits})
        self.collected['seed_hits'] = hits
        self.collected['seed'] = seeds[0] if len(seeds) == 1 else 0
        return self.collected['seed']

    def openwf_frame(self):
        prof = self.src.read('renovice/application_frame_profile.hpp')
        legacy = cpp_string(prof, 'legacy_pattern')
        current = cpp_string(prof, 'current_u43_pattern')
        lc, cc = len(self.img.scan(legacy, limit=4)), len(self.img.scan(current, limit=4))
        certified = self.collected.get('allowlisted', False)
        if not certified:
            profile = 'legacy' if lc == 1 else 'rejected'
        elif lc == 1 and cc == 0:
            profile = 'legacy'
        elif lc == 0 and cc == 1:
            profile = 'current_u43'
        else:
            profile = 'rejected'
        expected = self.base.get('openwf_frame_profile', 'current_u43')
        status = OK if profile == expected else BROKEN
        self.r.add('native', 'native.openwf_frame', 'OpenWF frame (application frame loop profile)', status,
                   f'legacy matches={lc} current matches={cc} certified={certified} -> profile {profile}'
                   + ('' if status == OK else f' (expected {expected})'),
                   ['OpenWF frame tick: hotkeys F9/F10, safe runtime tick, Pluto UI'])
        self.collected['openwf_frame_profile'] = profile

    def undump(self):
        pattern = '40 53 55 56 57 41 55 41 56 41 57 48 81 EC F0 01 00 00 48 8B 05 ? ? ? ? 48 33'
        hits = self.img.scan_file(pattern)
        cert = self.collected.get('certified_undump')
        raw = int(cert['UndumpRaw'], 16) if cert else None
        ok = len(hits) == 1 and (raw is None or hits[0] == raw)
        status = OK if ok and raw is not None else (BROKEN if not ok else UNKNOWN)
        self.r.add('native', 'native.undump', 'DE Luau undump (verify_client_44 row)', status,
                   f'matches={len(hits)}' + (f' raw=0x{hits[0]:x}' if hits else '')
                   + (f' registered raw=0x{raw:x}' if raw is not None else ' (no registered offset for this client)'),
                   ['Replacement lane and DE Lua loader (module undump)'])

    def wts_proxy(self, dll_path: Path):
        from uc_pe import Image
        need = sorted({fn for name, entries in self.img.imports().items() if name.lower() == 'wtsapi32.dll'
                       for fn, _ in entries if fn})
        try:
            have = set(Image(dll_path.read_bytes()).exports())
        except Exception as e:  # noqa: BLE001
            self.r.add('native', 'native.wts_proxy', 'WTSAPI32.dll proxy export coverage', UNKNOWN, str(e))
            return
        missing = [n for n in need if n not in have]
        self.r.add('native', 'native.wts_proxy', 'WTSAPI32.dll proxy export coverage', BROKEN if missing else OK,
                   f'missing {", ".join(missing)}' if missing else f'{len(need)} client imports exported',
                   ['Bootstrapper load (the game loads the proxy DLL)'])

    def census(self):
        rows = census_rows(self.src, self.game_version)
        base = self.base.get('signatures', {})
        skipped = unbaselined = 0
        for row in rows:
            count = len(self.img.scan(row['pattern'], limit=1024))
            self.collected['signatures'][row['id']] = {'count': count, 'file': row['file'], 'context': row['context'],
                                                       'pattern': row['pattern']}
            b = base.get(row['id'])
            expected = b['count'] if b else None
            name = f'{row["file"]}:{row["line"]} {row["context"]}'
            feats = [feature_for(row['file'])]
            if expected is None:
                unbaselined += 1
                status = OK if count == 1 else UNKNOWN
                why = f'{count} matches (no baseline row; new signature)'
            elif expected == 0:
                skipped += 1
                if count == 0:
                    continue
                status, why = UNKNOWN, f'{count} matches where the baseline had 0 (inactive/legacy row now matches)'
            elif expected == 1:
                status = OK if count == 1 else BROKEN
                why = f'{count} matches' + ('' if count == 1 else ' (baseline 1: the signature is no longer unique)')
            else:
                status = OK if count == expected else UNKNOWN
                why = f'{count} matches (baseline {expected})' + ('' if count == expected else
                                                                   ': multi-hit row changed, review first-match use')
            self.r.add('native', 'native.signature', name, status, why, feats, pattern=row['pattern'], count=count)
        self.r.note('native', f'Signature census: {len(rows)} hex-pattern rows from main.cpp, renovice/*.cpp/hpp and '
                              f'OpenWF/vv/sig at `{self.src.ref}`; {skipped} rows had 0 matches on the baseline build '
                              f'(version-gated, legacy or commented) and are listed only if they match now; '
                              f'{unbaselined} rows had no baseline entry.')
