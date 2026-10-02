"""Toolchain sanity on the current build: opcode profile, name-hash seed, round trip on a sample.

  profile identity   toolchain src/de_opcode_profile.h == bootstrapper renovice/de_opcode_profile.hpp (the U44 README
                     requires byte-identical tables)
  corpus walk        every current stock module walks cleanly with the pinned opcode permutation (each prototype's
                     instructions tile its code exactly). A reshuffled dispatch table breaks this on most modules.
                     Modules that already failed on the baseline build (stale U43-format debug modules) are excluded.
  name-hash seed     the seed in the executable's name-hash function == OpenWF wf_fnv_2_initial.json for this game
                     version == registry name_hash_seed == toolchain NAMEHASH_SEED_U44; the native names in the runtime
                     resolve with it (native area)
  derecomp           u44-rawhash-selftest; de-roundtrip-batch on the referenced modules (byte-exact re-emit);
                     decompile-mod-u44 -> recompile-u44 -> const-identity --u44 on a small sample
"""
from __future__ import annotations

import re
import shutil
import subprocess
from pathlib import Path

from uc_bytecode import Module, ContainerError
from uc_report import OK, BROKEN, UNKNOWN

FEATURE = 'Toolchain: decompile/recompile of U44 scripts (authoring, Missions generator, step-2 remap)'


def _run(args, cwd=None, timeout=300):
    r = subprocess.run([str(a) for a in args], capture_output=True, text=True, cwd=cwd, timeout=timeout)
    return r.returncode, (r.stdout or '') + (r.stderr or '')


def check(rep, toolchain: Path, boot_profile_text: str, opmap, manifest: dict, stock_file, baseline: dict,
          exe_seed: int, fnv_seed: int | None, registry_seed: int, sample_files: list[str], work: Path,
          walk_cache: dict, probe_files: list[str], rewalk: list[str] = ()) -> dict:
    out = {}
    tool_profile = (toolchain / 'src' / 'de_opcode_profile.h').read_text(encoding='utf-8')
    same = re.search(r'u43_to_u44\s*=\s*\{([^}]*)\}', tool_profile).group(1).split() == \
        re.search(r'u43_to_u44\s*=\s*\{([^}]*)\}', boot_profile_text).group(1).split()
    rep.add('toolchain', 'toolchain.profile_identity', 'U44 opcode profile: toolchain == runtime copy',
            OK if same else BROKEN, 'u43_to_u44 tables identical' if same else
            'toolchain src/de_opcode_profile.h and bootstrapper renovice/de_opcode_profile.hpp differ', [FEATURE])

    # full-corpus opcode walk (cached per stock manifest + profile)
    known_bad = set(baseline.get('corpus_walk', {}).get('failing', []))

    def walks(name: str) -> bool:
        try:
            return not Module(stock_file(name).read_bytes(), opmap).walk_errors()
        except ContainerError:
            return False
    cached = walk_cache.get('failing')
    if cached is None:
        failing = [rec['file'] for rec in manifest['modules'] if 'error' not in rec and not walks(rec['file'])]
        walk_cache['failing'] = failing
    else:                       # cached walk of the extraction; re-walk only the modules an overlay replaced
        failing = [f for f in cached if f not in rewalk] + [f for f in rewalk if not walks(f)]
    total = sum(1 for r in manifest['modules'] if 'error' not in r)
    new_bad = sorted(set(failing) - known_bad)
    if known_bad:
        status = OK if not new_bad else BROKEN
    else:   # no baseline yet: tolerate the 13 documented stale U43-format modules (U44_RAW_HASH_RECOMPILE note)
        status = OK if len(failing) <= 13 else BROKEN
        new_bad = [] if status == OK else new_bad
    rep.add('toolchain', 'toolchain.opcode_walk', 'Opcode permutation walks every current stock module',
            status, f'{total - len(failing)}/{total} modules tile cleanly; {len(failing)} fail '
            f'({len(set(failing) & known_bad)} known stale U43-format modules)'
            + (f'; NEW failures: {", ".join(new_bad[:8])}' + (f' (+{len(new_bad) - 8})' if len(new_bad) > 8 else '')
               if new_bad else ''), [FEATURE, 'Hook and literal checks of this tool'])
    out['corpus_walk'] = {'modules': total, 'failing': sorted(failing)}

    # seeds
    tool_seed_text = (toolchain / 'src' / 'de_namehash.h').read_text(encoding='utf-8')
    m = re.search(r'NAMEHASH_SEED_U44\s*=\s*(0x[0-9A-Fa-f]+)', tool_seed_text)
    tool_seed = int(m.group(1), 16) if m else None
    seeds = {'executable': exe_seed, 'OpenWF wf_fnv_2_initial.json': fnv_seed, 'registry': registry_seed,
             'toolchain': tool_seed}
    agree = exe_seed and all(v == exe_seed for v in seeds.values())
    rep.add('toolchain', 'toolchain.name_hash_seed', 'Native name-hash seed', OK if agree else BROKEN,
            ', '.join(f'{k} {("0x%08x" % v) if isinstance(v, int) else v}' for k, v in seeds.items())
            + ('' if agree else ' (disagree: rehash names, regenerate the registry hashes)'),
            [FEATURE, 'Missions: hashed parameters and globals', 'Addon RENOVICE_HASH_FIELD names'])

    derecomp = toolchain / 'bin' / 'derecomp.exe'
    if not derecomp.is_file():
        rep.add('toolchain', 'toolchain.derecomp', 'derecomp.exe present', UNKNOWN, f'missing {derecomp}', [FEATURE])
        return out
    code, text = _run([derecomp, 'u44-rawhash-selftest'])
    m = re.search(r'checks=(\d+) failed=(\d+)', text)
    rep.add('toolchain', 'toolchain.selftest', 'derecomp u44-rawhash-selftest',
            OK if code == 0 and m and m.group(2) == '0' else BROKEN, m.group(0) if m else text.strip()[-200:], [FEATURE])

    sample_dir = work / 'toolchain-sample'
    if sample_dir.exists():
        shutil.rmtree(sample_dir)
    sample_dir.mkdir(parents=True)
    copied = []
    for name in sample_files:
        f = stock_file(name)
        if f is not None:
            shutil.copyfile(f, sample_dir / name)
            copied.append(name)
    code, text = _run([derecomp, 'de-roundtrip-batch', sample_dir])
    m = re.search(r'(\d+) files \(09 03\) \| byte-exact=(\d+)\s+mismatch=(\d+)\s+walk-error=(\d+)', text)
    ok = code == 0 and m and m.group(1) == m.group(2)
    rep.add('toolchain', 'toolchain.roundtrip', f'de-roundtrip-batch on the {len(copied)} referenced stock modules',
            OK if ok else BROKEN, m.group(0) if m else text.strip()[-200:], [FEATURE])

    known = baseline.get('toolchain_probes', {})
    out['probes'] = {}
    for name in [n for n in probe_files if n in copied]:
        f = sample_dir / name
        src, cand = f.with_suffix('.luau'), f.with_name(f.stem + '.re.lua_B')
        c1, t1 = _run([derecomp, 'decompile-mod-u44', f, src])
        c2, t2 = _run([derecomp, 'recompile-u44', src, cand]) if c1 == 0 else (1, '')
        c3, t3 = _run([derecomp, 'const-identity', f, cand, '--u44']) if c2 == 0 else (1, '')
        m = re.search(r'CONST_IDENTITY .*verdict=(\w+)', t3)
        swaps = re.search(r'hash_string_class_swaps=(\d+)', t3)
        line = m.group(0) if m else f'decompile exit {c1}, recompile exit {c2}: {(t1 + t2)[-160:]}'
        out['probes'][name] = line
        if m and m.group(1) == 'PASS':
            status = OK
        elif m and swaps and swaps.group(1) == '0' and known.get(name) == line:
            status, line = OK, line + ' (known decompiler residual, identical on the baseline build)'
        else:
            status = BROKEN
        rep.add('toolchain', 'toolchain.raw_hash_roundtrip', f'decompile-mod-u44 -> recompile-u44 -> const-identity: '
                f'{name}', status, line + (f'; class swaps {swaps.group(1)}' if swaps else ''), [FEATURE])
    return out
