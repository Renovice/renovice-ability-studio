"""Read-only extraction of the installed client's stock DE Luau modules (Cache.Windows B.Font.toc/.cache).

Same reader as de-luau-toolchain RESEARCH/U44_RAW_HASH_RECOMPILE_2026-09-29/tools/extract_u44_stock.py (TOC records,
SHCC blocks, Oodle). The game folder is opened read-only. Output goes to a cache folder keyed by the TOC's SHA-256, so a
second run on the same build reads the cached modules and their recorded content keys instead of decompressing again.
"""
from __future__ import annotations

import ctypes
import hashlib
import json
import struct
from pathlib import Path

from uc_bytecode import content_key

MANIFEST = 'manifest.json'
MANIFEST_FORMAT = 'RENOVICE_UPDATE_CHECK_STOCK_V1'
_oodle = None


def _oodle_lib(dll: Path):
    global _oodle
    if _oodle is None:
        lib = ctypes.CDLL(str(dll))
        lib.OodleLZ_Decompress.argtypes = [ctypes.c_void_p, ctypes.c_size_t, ctypes.c_void_p, ctypes.c_size_t] \
            + [ctypes.c_int] * 3 + [ctypes.c_size_t] * 6 + [ctypes.c_int]
        lib.OodleLZ_Decompress.restype = ctypes.c_int
        _oodle = lib
    return _oodle


def _oodle_decompress(dll: Path, data: bytes, dec_size: int) -> bytes:
    if len(data) == dec_size:
        return bytes(data)
    lib = _oodle_lib(dll)
    src = ctypes.create_string_buffer(bytes(data), len(data))
    dst = ctypes.create_string_buffer(dec_size)
    n = lib.OodleLZ_Decompress(src, len(data), dst, dec_size, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3)
    if n <= 0:
        raise RuntimeError(f'Oodle decompress failed ret={n}')
    return dst.raw[:n]


def toc_entries(toc: bytes):
    i, entries = 8, []
    while i + 96 <= len(toc):
        co, _ts, comp, dec, _res, par = struct.unpack_from('<QQIIII', toc, i)
        name = toc[i + 32:i + 96].split(b'\x00', 1)[0].decode('utf-8', 'replace')
        entries.append((co, comp, dec, par, name))
        i += 96
    cache = {0: ''}

    def get(idx):
        # iterative parent walk (deep trees exceed the recursion limit on large TOCs)
        chain = []
        while idx not in cache:
            chain.append(idx)
            idx = entries[idx - 1][3]
        path = cache[idx]
        for j in reversed(chain):
            path = path + '/' + entries[j - 1][4]
            cache[j] = path
        return cache[chain[0]] if chain else path

    return entries, [get(i + 1) for i in range(len(entries))]


def read_entry(cache_file: Path, co: int, comp: int, dec: int, dll: Path) -> bytes:
    with open(cache_file, 'rb') as f:
        f.seek(co)
        raw = f.read(comp)
    if comp == dec:
        return raw[:dec]
    out, i = bytearray(), 0
    while len(out) < dec and i + 8 <= len(raw):
        bi = raw[i:i + 8]
        i += 8
        if bi[0] != 0x80 or (bi[7] & 0x0F) != 0x01:
            raise RuntimeError(f'bad SHCC block header at {i - 8}')
        bcs = (int.from_bytes(bi[0:4], 'big') >> 2) & 0xFFFFFF
        bds = (int.from_bytes(bi[4:8], 'big') >> 5) & 0xFFFFFF
        out += _oodle_decompress(dll, raw[i:i + bcs], bds)
        i += bcs
    return bytes(out[:dec])


def module_file_name(path: str) -> str:
    return path.strip('/').replace('/', '_') + '_B'


def extract_stock(game: Path, cache_root: Path, dll: Path, log=print) -> tuple[Path, dict]:
    """Returns (folder, manifest). The folder holds every .lua module of B.Font.toc as <A_B_C.lua_B>."""
    toc_path = game / 'Cache.Windows' / 'B.Font.toc'
    toc = toc_path.read_bytes()
    toc_sha = hashlib.sha256(toc).hexdigest()
    folder = cache_root / f'stock-{toc_sha[:16]}'
    manifest_path = folder / MANIFEST
    if manifest_path.is_file():
        manifest = json.loads(manifest_path.read_text(encoding='utf-8'))
        if manifest.get('format') == MANIFEST_FORMAT and manifest.get('toc_sha256') == toc_sha:
            log(f'stock: cached extraction {folder} ({len(manifest["modules"])} modules)')
            return folder, manifest
    log(f'stock: extracting B.Font.toc {toc_sha[:16]} into {folder} (read-only source)')
    folder.mkdir(parents=True, exist_ok=True)
    entries, paths = toc_entries(toc)
    lua: dict[str, int] = {}
    duplicates = []
    for k, p in enumerate(paths):
        if p.endswith('.lua') and entries[k][2] > 0:
            if p in lua:
                duplicates.append(p)
            lua[p] = k
    modules = []
    cache_file = toc_path.with_suffix('.cache')
    for p in sorted(lua):
        co, comp, dec, _par, _name = entries[lua[p]]
        rec = {'path': p, 'file': module_file_name(p)}
        try:
            body = read_entry(cache_file, co, comp, dec, dll)
        except Exception as e:  # noqa: BLE001 - recorded per module
            rec['error'] = str(e)
            modules.append(rec)
            continue
        (folder / rec['file']).write_bytes(body)
        rec.update(size=len(body), sha256=hashlib.sha256(body).hexdigest(), key=content_key(body))
        modules.append(rec)
    manifest = {'format': MANIFEST_FORMAT, 'toc': str(toc_path), 'toc_sha256': toc_sha,
                'duplicates_last_wins': sorted(set(duplicates)), 'modules': modules}
    manifest_path.write_text(json.dumps(manifest, indent=1), encoding='utf-8')
    return folder, manifest


def manifest_for_folder(folder: Path, log=print) -> dict:
    """Manifest for a caller-supplied stock folder (mutation copies): keys are computed from the bytes on disk."""
    cached = folder / MANIFEST
    old = {}
    if cached.is_file():
        try:
            old = {m['file']: m for m in json.loads(cached.read_text(encoding='utf-8')).get('modules', []) if 'file' in m}
        except (ValueError, KeyError):
            old = {}
    modules = []
    for f in sorted(folder.glob('*.lua_B')):
        body = f.read_bytes()
        sha = hashlib.sha256(body).hexdigest()
        prior = old.get(f.name)
        key = prior['key'] if prior and prior.get('sha256') == sha and 'key' in prior else content_key(body)
        modules.append({'path': prior['path'] if prior else None, 'file': f.name, 'size': len(body),
                        'sha256': sha, 'key': key})
    log(f'stock: caller-supplied folder {folder} ({len(modules)} modules)')
    return {'format': MANIFEST_FORMAT, 'toc': None, 'toc_sha256': None, 'modules': modules}


def extract_named(game: Path, toc_name: str, wanted_path: str, dll: Path) -> bytes | None:
    toc_path = game / 'Cache.Windows' / toc_name
    if not toc_path.is_file():
        return None
    entries, paths = toc_entries(toc_path.read_bytes())
    hit = None
    for k, p in enumerate(paths):
        if p == wanted_path and entries[k][2] > 0:
            hit = k
    if hit is None:
        return None
    co, comp, dec, _par, _name = entries[hit]
    return read_entry(toc_path.with_suffix('.cache'), co, comp, dec, dll)
