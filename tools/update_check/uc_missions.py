"""Mission registry and Missions package checks against the CURRENT stock bytes.

1. `verify-missions` (the ability editor CLI, unchanged) runs on a throw-away editor root whose registry copy points its
   `corpus` at the current client's modules (same file names) instead of the authoring corpus. Every registry row is
   re-verified by the production C++ rules: literal sites and preimages, root-table initialisers and stock values,
   entry owners (MissionInfo fields, hashed script parameters), metadata consumers, server preimages.
   METADATA_SNAPSHOT.json is carried over only when the installed Packages.bin has the registry's SHA-256.
2. The installed `literals.json` recipes (LIVE_LITERALS_V1, incl. coupled sites and reader pins) are re-checked with the
   runtime's rules (bootstrapper live_literal_patch_core.hpp verify + stock_error, live_literals_core stock size/SHA).
3. The installed `engine_params.json` overrides (RENOVICE_ENGINE_PARAMS_V1): module key, U44 name hash of the parameter,
   and that the module still reads that hash at the registry's recorded reader instructions.
"""
from __future__ import annotations

import hashlib
import json
import shutil
import struct
import subprocess
from pathlib import Path

from uc_bytecode import name_hash, CANONICAL_AUX
from uc_report import OK, BROKEN, UNKNOWN

LOADN_U44 = 0x08
OP_GETIMPORT = 0x46


def row_feature(row: dict) -> str:
    ui = row.get('ui') or {}
    path = ' > '.join(ui.get('path') or [row.get('mission_type', '?')])
    return f'Missions: {path} > {ui.get("row") or row.get("label")}'


def decl_feature(decl: dict, vid: str) -> str:
    path = ' > '.join(decl.get('path') or [decl.get('group', '?')])
    return f'Missions: {path} > {decl.get("row") or decl.get("label") or vid}'


def row_keys(row: dict) -> set[str]:
    keys = set()
    o = row.get('owner', {})
    for ref in (o, row.get('literal_owner') or {}, o.get('consumer') or {}):
        if ref.get('body_key'):
            keys.add(ref['body_key'])
    return keys


def run_verify_missions(cli: Path, workspace: Path, registry_path: Path, stock_file, packages_bin_sha: str | None,
                        work: Path) -> tuple[dict | None, str, list[str]]:
    """Returns (verify-missions JSON or None, note, files missing from the current build)."""
    registry = json.loads(registry_path.read_text(encoding='utf-8'))
    root = work / 'verify-root'
    if root.exists():
        shutil.rmtree(root)
    corpus = root / 'corpus'
    corpus.mkdir(parents=True)
    shutil.copyfile(workspace / 'WORKSPACE.json', root / 'WORKSPACE.json')
    missing = []
    for rec in registry['modules'].values():
        src = stock_file(rec['file'])
        if src is None:
            missing.append(rec['file'])
        else:
            shutil.copyfile(src, corpus / rec['file'])
    note = ''
    snapshot = workspace / registry['corpus'] / registry['metadata_snapshot']['file']
    if packages_bin_sha and packages_bin_sha.lower() == registry['packages_bin_sha256'].lower():
        shutil.copyfile(snapshot, corpus / registry['metadata_snapshot']['file'])
        note = 'METADATA_SNAPSHOT.json carried over (installed Packages.bin has the registry SHA-256)'
    else:
        note = (f'installed Packages.bin {str(packages_bin_sha)[:16]} differs from the registry '
                f'{registry["packages_bin_sha256"][:16]}: metadata rows cannot verify')
    registry['corpus'] = str(corpus.resolve())
    registry['server_root'] = str((workspace / registry['server_root']).resolve())
    editor = root / 'editor'
    (editor / 'REGISTRIES').mkdir(parents=True)
    (editor / 'REGISTRIES' / 'mission_build_u44.json').write_text(json.dumps(registry), encoding='utf-8')
    r = subprocess.run([str(cli), 'verify-missions', '--editor-root', str(editor)], capture_output=True, text=True,
                       timeout=600)
    try:
        return json.loads(r.stdout), note, missing
    except ValueError:
        return None, f'verify-missions exit {r.returncode}: {(r.stderr or r.stdout)[:300]}', missing


def server_detail(owner: dict, server_root: Path) -> str:
    """Why a SERVER_CONFIG pin failed: line endings only, preimages still present, or a preimage gone."""
    notes = []
    for f, sha, pre in (('schema_file', 'schema_sha256', 'schema_preimage'),
                        ('consumer_file', 'consumer_sha256', 'consumer_preimage')):
        path = server_root / owner[f]
        if not path.is_file():
            notes.append(f'{owner[f]} missing')
            continue
        raw = path.read_bytes()
        pinned = raw.replace(b'\r\n', b'\n') if owner.get('sha256_text') == 'LF' else raw   # LF-normalized pin (2026-10-02)
        if hashlib.sha256(pinned).hexdigest().lower() == owner[sha].lower():
            continue
        lf = raw.replace(b'\r\n', b'\n')
        variants = {'LF': lf, 'CRLF': lf.replace(b'\n', b'\r\n')}
        same = [k for k, v in variants.items() if hashlib.sha256(v).hexdigest().lower() == owner[sha].lower()]
        if same:
            notes.append(f'{owner[f]}: only the line endings differ (pinned as {same[0]}); the content is unchanged')
        elif owner[pre] in raw.decode('utf-8', 'replace'):
            notes.append(f'{owner[f]}: content changed, the preimage is still present')
        else:
            notes.append(f'{owner[f]}: the preimage is gone (re-derive the server owner)')
    return ('; ' + '; '.join(notes)) if notes else ''


def check_registry(rep, registry: dict, result: dict | None, note: str, cli_ok: bool, server_root: Path | None = None):
    rows = registry['tunables']
    if result is None:
        rep.add('missions', 'missions.verify_missions', 'verify-missions on the current stock bytes', UNKNOWN,
                note if not cli_ok else 'verify-missions produced no JSON: ' + note)
        return
    rep.note('missions', f'verify-missions (CLI, current stock corpus): {result.get("pass")}/{result.get("rows")} rows '
                          f'PASS, structure {result.get("structure")}; {note}.')
    rep.add('missions', 'missions.registry_structure', 'Mission registry structure', OK if result.get('structure') == 'PASS'
            else BROKEN, str(result.get('structure')), ['Missions package generator'])
    failures = {f['tunable_id']: f['reason'] for f in result.get('failures', [])}
    for row in rows:
        tid = row['tunable_id']
        backend = row['backend']
        kind = row['owner'].get('template', row.get('owner_kind'))
        name = f'{tid} ({backend} {kind})'
        # SERVER_CONFIG rows pin the OpenWF server source, a separate product: own check id, not a client-build fact
        check = 'missions.registry_row.server' if backend == 'SERVER_CONFIG' else 'missions.registry_row'
        if tid in failures:
            reason = failures[tid]
            if backend == 'SERVER_CONFIG' and server_root is not None:
                reason += server_detail(row['owner'], server_root)
            rep.add('missions', check, name, BROKEN, reason, [row_feature(row)], keys=sorted(row_keys(row)))
        else:
            rep.add('missions', check, name, OK, 'verify-missions PASS', [row_feature(row)])


def site_check(site: dict, body: bytes, stock: float | None) -> str:
    """'' when the site verifies, else the reason (bootstrapper live_literal_patch_core verify/stock_error)."""
    kind = site['kind']
    width = 8 if kind == 'number_constant' else 4
    off = site['offset']
    expected = bytes.fromhex(site['expected'])
    if off + width > len(body):
        return f'site offset {off} outside the module ({len(body)} bytes)'
    if kind == 'number_constant' and (off == 0 or body[off - 1] != 2):
        return f'no number-constant tag before offset {off}'
    have = body[off:off + width]
    if have != expected:
        return f'preimage changed at offset {off}: expected {expected.hex()} found {have.hex()}'
    if kind == 'loadn':
        if expected[0] == LOADN_U44:
            if expected[1] != site.get('register'):
                return f'LOADN at {off} loads r{expected[1]}, recipe names r{site.get("register")}'
        elif not site.get('rewrites_instruction'):
            return f'preimage at {off} is not a LOADN and the site is not a flagged rewrite'
    if stock is None or site.get('inverse'):
        return ''
    if kind == 'number_constant':
        encoded = struct.unpack('<d', expected)[0]
    elif expected[0] == LOADN_U44:
        encoded = float(struct.unpack('<h', expected[2:4])[0])
    else:
        return ''
    value = (stock + site.get('value_offset', 0.0)) * site['numerator'] / site['denominator']
    if encoded != value:
        return f'stock operand {encoded:g} at offset {off} disagrees with the recipe stock {stock:g}'
    return ''


def check_literals(rep, literals: dict, now_module) -> None:
    """now_module(key, file) -> (module or None, 'same-key' | 'same-file' | 'gone')."""
    mods = literals.get('modules', {})
    for vid, value in sorted(literals.get('values', {}).items()):
        decl = value.get('declaration', {})
        feat = [decl_feature(decl, vid)]
        problems, sites = [], 0
        for drive in value.get('drives', []):
            key = drive.get('module', value.get('module'))
            rec = mods.get(key, {})
            m, how = now_module(key, rec.get('file'))
            if m is None:
                problems.append(f'module {key} ({rec.get("file", "?")}) is not in this build')
                continue
            body = m.data
            if how != 'same-key':
                problems.append(f'content key {key} changed (module now {m.key}): the recipe is pinned to the old '
                                'stock size/SHA-256 and fails closed')
            elif len(body) != rec.get('stock_size') or hashlib.sha256(body).hexdigest() != rec.get('stock_sha256', '').lower():
                problems.append(f'module {key}: stock size/SHA-256 differ from the recipe')
            for site in drive.get('sites', []):
                sites += 1
                why = site_check(site, body, drive.get('stock'))
                if why:
                    problems.append(f'{key}: {why}')
        rep.add('missions', 'missions.literal_recipe', f'literals.json {vid} ({sites} sites)', BROKEN if problems else OK,
                '; '.join(problems[:4]) + (f' (+{len(problems) - 4} more)' if len(problems) > 4 else '') if problems else
                f'{sites} sites: preimages and stock operands match', feat)


def key_use(m, proto, i: int, h: int) -> bool:
    """Instruction i of `proto` is an AUX instruction keyed by the tag-1 name hash h (GETGLOBAL/SETGLOBAL/GETTABLEKS/
    SETTABLEKS/NAMECALL: aux = constant index; GETIMPORT: aux = count<<30 | id0<<20 | id1<<10 | id2)."""
    ins = m.instruction(proto, i)
    if not ins or ins[2] not in CANONICAL_AUX:
        return False
    aux = m.aux(proto, ins[1])
    ids = [(aux >> 20) & 1023, (aux >> 10) & 1023, aux & 1023][:aux >> 30] if ins[2] == OP_GETIMPORT else [aux]
    return any(k < len(proto.consts) and proto.consts[k].tag == 1 and proto.consts[k].value == h for k in ids)


def check_engine_params(rep, ep: dict, registry: dict, now_module, seed: int, decls: dict) -> None:
    rows = {r['tunable_id']: r for r in registry['tunables']}
    for ov in ep.get('overrides', []):
        vid, key, param = ov['value'], ov['module'], ov['parameter']
        decl = decls.get(vid, {})
        feat = [decl_feature(decl, vid) if decl else f'Missions: {vid}']
        problems = []
        h = name_hash(param, seed)
        if f'{h:08x}' != ov['hash']:
            problems.append(f'hash {ov["hash"]} != name hash 0x{h:08x} of {param} (seed 0x{seed:08x})')
        m, how = now_module(key, None)
        readers_ok = 0
        if m is not None and how != 'same-key':
            problems.append(f'module {key} is not in this build: content key changed (module now {m.key}), the '
                            'override does not match')
        if m is None:
            problems.append(f'module {key} is not in this build')
        else:
            if h not in m.constant_hashes():
                problems.append(f'module no longer references {param} (0x{h:08x})')
            row = rows.get(vid)
            for reader in (row or {}).get('owner', {}).get('readers', []):
                if reader.get('key') != param:
                    continue
                p = reader['prototype']
                if p >= len(m.protos):
                    problems.append(f'reader prototype {p} missing ({len(m.protos)} prototypes)')
                    continue
                proto = m.protos[p]
                for i in reader.get('instructions', []):     # recorded key uses (reads and the module's own writes)
                    if key_use(m, proto, i, h):
                        readers_ok += 1
                    else:
                        problems.append(f'P{p} i{i} no longer uses {param}')
        rep.add('missions', 'missions.engine_param', f'engine_params.json {vid}: {param} in {key}',
                BROKEN if problems else OK, '; '.join(problems) if problems else
                f'hash {ov["hash"]} ok; module reads it ({readers_ok} recorded reader instructions verified)', feat)
