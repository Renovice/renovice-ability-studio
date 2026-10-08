"""Update resilience step 2/3: installed full-module replacements and authored target addons on a new build.

Replacements (`<16-hex key> (<name>).lua_B`, a whole stock module with edits):
  The edit script is the difference between the replacement and the build-A stock module of its key. A replacement is
  rebased automatically when it is an instruction-level edit of that stock module (same prototype count, string pool,
  headers, constants and code sizes; only instruction words differ): every edited instruction is found again in build B
  through the module map (uc_remap), the build-B stock word there must equal the build-A stock word (the same
  instruction), branch targets of edited jumps are re-aimed through the map, and the new words are written into a copy
  of the build-B stock module. A changed NUMBER constant (same table size and index, tag 2 on both sides) is an edit too:
  the mapped build-B prototype must hold the same build-A value at that index, and the new value is written there.
  Proof: the result parses, differs from build-B stock exactly in the edited prototypes, and every edited prototype that
  maps exactly has the fingerprint of the replacement's own prototype. Anything else (a full rewrite, new functions,
  string or other constant edits, an edited instruction or constant that changed in build B) is REVIEW with the exact
  reason: rebuild it from its source project.

Authored target addons (`<key>.<Name>.target.addon.lua_B`, built from a source by `derecomp recompile-u44`):
  The source is named by authored_addons.json and must rebuild the installed bytes exactly (identity gate). Its target
  dependencies are the nativeCalls callsites read from the installed bytes (step 1 hook extraction) and luaCalls keys.
  Each callsite is mapped (prototype map, then the NAMECALL of the same method: the aligned instruction, else the only
  NAMECALL of that method in the mapped prototype); the source numbers are rewritten at the exact comparison sites,
  the source recompiled, and the result accepted only when its decompiled hook table equals the mapped one and it
  differs from the installed addon only in number constants and immediates (no string, hash or structure change). The
  file is renamed to the new target key.
"""
from __future__ import annotations

import hashlib
import re
import shutil
import struct
import subprocess
from pathlib import Path

import uc_bytecode as B
import uc_content
import uc_remap as RM

AUTO, REVIEW, DROPPED, UNCHANGED = 'auto', 'review', 'dropped', 'unchanged'


def _sha(b: bytes) -> str:
    return hashlib.sha256(b).hexdigest()


# -- replacements ---------------------------------------------------------------------------------------------------
def edit_script(stock: B.Module, repl: B.Module, constants: list | None = None) -> tuple[list, str]:
    """[(prototype, logical, old raw word, new raw word)] or ([], reason why it is not an instruction-level edit).

    With `constants` (a list), changed number constants are accepted and appended to it as
    (prototype, constant index, old value, new value); without it any constant change is refused."""
    if len(stock.protos) != len(repl.protos):
        return [], f'prototype count {len(stock.protos)} -> {len(repl.protos)} (a full rewrite, not an instruction edit)'
    if stock.pool != repl.pool:
        return [], 'the string pool differs (a full rewrite or a string edit)'
    edits = []
    for a, b in zip(stock.protos, repl.protos):
        if a.header != b.header or a.sizecode != b.sizecode or len(a.consts) != len(b.consts) or a.kids != b.kids:
            return [], f'prototype {a.index} header, size, constants or children differ (not an instruction edit)'
        for k, (x, y) in enumerate(zip(a.consts, b.consts)):
            if (x.tag, x.value) == (y.tag, y.value):
                continue
            if constants is None or x.tag != 2 or y.tag != 2:
                return [], f'prototype {a.index} constants differ (only number constant edits are rebased automatically)'
            constants.append((a.index, k, x.value, y.value))
        if len(a.instructions) != len(b.instructions) or \
                [len(stock.word(a, i)) for i in range(len(a.instructions))] != \
                [len(repl.word(b, i)) for i in range(len(b.instructions))]:
            return [], f'prototype {a.index} instruction layout differs'
        for (la, oa, _), (lb, ob, _) in zip(a.instructions, b.instructions):
            wa = a.raw_code[oa:oa + len(stock.word(a, la))]
            wb = b.raw_code[ob:ob + len(repl.word(b, lb))]
            if wa != wb:
                edits.append((a.index, la, bytes(wa), bytes(wb)))
    return edits, ''


def _word_index(p: B.Proto, m: B.Module) -> tuple[list[int], dict[int, int]]:
    pos, at = [], 0
    for i in range(len(p.instructions)):
        pos.append(at)
        at += len(m.word(p, i)) // 4
    return pos, {w: i for i, w in enumerate(pos)}


def rebase_replacement(stock_a: B.Module, repl: B.Module, stock_b: B.Module, mm: RM.ModuleMap) -> dict:
    """Result dict: action, reason/notes, bytes (when auto), edits."""
    constants: list = []
    edits, why = edit_script(stock_a, repl, constants)
    if why:
        return {'action': REVIEW, 'reason': why + '; rebuild it from its source project against the new stock'}
    if not edits and not constants:
        return {'action': REVIEW, 'reason': 'the replacement equals its stock module (nothing to rebase)'}
    data = bytearray(stock_b.data)
    notes, confidence, moved = [], 'exact', []
    for p, k, old, new in constants:
        pm = mm.proto(p)
        if pm.b is None:
            return {'action': REVIEW if pm.kind == 'ambiguous' else DROPPED,
                    'reason': f'edited prototype {p} is {pm.kind} in the new build: {pm.note}'}
        if pm.kind == 'similar':
            confidence = 'similar'
        qb = stock_b.protos[pm.b]
        if k >= len(qb.consts) or qb.consts[k].tag != 2 or qb.consts[k].value != old:
            cur = qb.consts[k].value if k < len(qb.consts) else 'missing'
            return {'action': REVIEW, 'reason': f'the stock constant the replacement edits changed at P{p} K{k} '
                                                f'({old!r} -> {cur!r})'}
        start = stock_b.constant_offset(qb, k)
        data[start:start + 8] = struct.pack('<d', new)
        moved.append({'old': f'P{p} K{k}', 'new': f'P{pm.b} K{k}'})
        if p != pm.b:
            notes.append(f'constant P{p} K{k} -> P{pm.b} K{k}')
    for p, i, old, new in edits:
        pm = mm.proto(p)
        if pm.b is None:
            return {'action': REVIEW if pm.kind == 'ambiguous' else DROPPED,
                    'reason': f'edited prototype {p} is {pm.kind} in the new build: {pm.note}'}
        if pm.kind == 'similar':
            confidence = 'similar'
        hit = mm.instruction(p, i)
        if hit is None or hit[2] != 'equal':
            return {'action': REVIEW, 'reason': f'edited instruction P{p} i{i} has no unchanged counterpart in the new build'}
        pb, ib, _ = hit
        qa, qb = stock_a.protos[p], stock_b.protos[pb]
        _, oa, op = qa.instructions[i]
        _, ob, _ = qb.instructions[ib]
        width = len(old)
        cur = bytes(qb.raw_code[ob:ob + width])
        if cur != old and not (op in RM.JUMP_D and cur[:2] == old[:2] and cur[4:] == old[4:]):
            return {'action': REVIEW, 'reason': f'the stock instruction the replacement edits changed at P{p} i{i} '
                                                f'({old.hex()} -> {cur.hex()})'}
        word = bytearray(new)
        if op in RM.JUMP_D:
            pos_a, at_a = _word_index(qa, stock_a)
            pos_b, at_b = _word_index(qb, stock_b)
            target_a = pos_a[i] + 1 + struct.unpack_from('<h', new, 2)[0]
            ta = at_a.get(target_a)
            tb = mm.instruction(p, ta) if ta is not None else None
            if ta is None or tb is None or tb[0] != pb:
                return {'action': REVIEW, 'reason': f'the edited branch at P{p} i{i} targets an instruction without a '
                                                    'counterpart'}
            struct.pack_into('<h', word, 2, pos_b[tb[1]] - pos_b[ib] - 1)
        start = qb.code_start + ob
        data[start:start + width] = word
        moved.append({'old': f'P{p} i{i}', 'new': f'P{pb} i{ib}'})
        if (p, i) != (pb, ib):
            notes.append(f'edit P{p} i{i} -> P{pb} i{ib}')
    result = B.Module(bytes(data), stock_a.opmap)
    if result.walk_errors() or len(result.protos) != len(stock_b.protos):
        return {'action': REVIEW, 'reason': 'the rebased module does not parse'}
    edited_a = {p for p, *_ in edits} | {p for p, *_ in constants}
    edited = {mm.proto(p).b for p in edited_a}
    for q in result.protos:
        same = result.fingerprint(q) == stock_b.fingerprint(stock_b.protos[q.index])
        if (q.index in edited) == same:
            return {'action': REVIEW, 'reason': f'prototype {q.index} differs from the new stock where no edit was mapped'}
    for p in edited_a:
        pm = mm.proto(p)
        if pm.kind == 'exact' and result.fingerprint(result.protos[pm.b]) != repl.fingerprint(repl.protos[p]):
            return {'action': REVIEW, 'reason': f'edited prototype {p} -> {pm.b} is not identical to the replacement\'s'}
    # the file is named by the content key of the stock module it replaces (the loader's match key)
    return {'action': AUTO, 'confidence': confidence, 'bytes': bytes(data), 'edits': moved, 'notes': notes,
            'new_key': stock_b.key}


# -- authored addons --------------------------------------------------------------------------------------------------
NUM_ASSIGN = re.compile(r'^\s*(?:local\s+)?(\w+)\s*=\s*(-?\d+)\s*$')


def source_sites(text: str, p: int, i: int) -> list[tuple[int, int]]:
    """Line pairs (line of P, line of I) where a callback compares its (prototype, instruction) with P and I."""
    lines = text.splitlines()
    out = []
    direct = re.compile(rf'\b\w+\s*==\s*{p}\s+and\s+\w+\s*==\s*{i}\b')
    for n, line in enumerate(lines):
        if direct.search(line) and not line.lstrip().startswith('--'):
            out.append((n, n))
    # decompiled style: X = P; ...; if Y ~= X ... ; X = I; ...; if Z ~= X
    def compare_after(n, var):
        for k in range(n + 1, min(n + 4, len(lines))):
            if re.search(rf'^\s*if \(?\w+ (?:~=|==) {re.escape(var)}\b', lines[k]):
                return k
        return None
    for n, line in enumerate(lines):
        m = NUM_ASSIGN.match(line)
        if not m or int(m.group(2)) != p:
            continue
        k = compare_after(n, m.group(1))
        if k is None:
            continue
        for n2 in range(k + 1, min(k + 6, len(lines))):
            m2 = NUM_ASSIGN.match(lines[n2])
            if m2:
                if int(m2.group(2)) == i and compare_after(n2, m2.group(1)) is not None:
                    out.append((n, n2))
                break
    return out


def rewrite_source(text: str, changes: list[tuple[int, int, int, int]], expect: dict | None = None) -> tuple[str, list[str]]:
    """changes: [(P, I, P', I')]; expect: {(P, I): number of callback filters with that pair in the INSTALLED addon
    (counted on its decompiled text)}. Every comparison site is rewritten, and their number must equal the installed
    filters, so no unrelated comparison is touched. Returns (new text, problems)."""
    lines = text.splitlines(keepends=True)
    problems = []
    for p, i, pb, ib in changes:
        sites = source_sites(text, p, i)
        want = (expect or {}).get((p, i), 1)
        if not sites or len(sites) != want:
            problems.append(f'callsite P{p} i{i}: {len(sites)} comparison sites in the source, the installed addon '
                            f'filters it in {want} callbacks')
            continue
        for lp, li in sites:
            if lp == li:
                lines[lp] = re.sub(rf'(\b\w+\s*==\s*){p}(\s+and\s+\w+\s*==\s*){i}\b', rf'\g<1>{pb}\g<2>{ib}',
                                   lines[lp], count=1)
            else:
                lines[lp] = re.sub(rf'=\s*{p}(\s*)$', f'= {pb}\\1', lines[lp], count=1)
                lines[li] = re.sub(rf'=\s*{i}(\s*)$', f'= {ib}\\1', lines[li], count=1)
    new = ''.join(lines)
    # comment prose: "p16 i596" / "P16 i596"
    for p, i, pb, ib in changes:
        new = re.sub(rf'\b([pP]){p} i{i}\b', rf'\g<1>{pb} i{ib}', new)
    return new, problems


def map_callsite(mm: RM.ModuleMap, method: str, p: int, i: int, seed: int) -> dict:
    """Map one nativeCalls callsite. Returns {action, new: [P', I'], confidence, note|reason}."""
    pm = mm.proto(p)
    if pm.b is None:
        return {'action': REVIEW if pm.kind == 'ambiguous' else DROPPED,
                'reason': f'prototype {p} is {pm.kind} in the new build ({pm.note})'}
    proto_b = mm.mb.protos[pm.b]
    calls = RM.namecalls(mm.mb, proto_b, method, seed)
    hit = mm.instruction(p, i)
    conf = 'exact' if pm.kind == 'exact' else 'similar'
    if hit and hit[1] in calls:
        note = '' if (pm.b, hit[1]) == (p, i) else f'NAMECALL :{method} found at the aligned instruction'
        return {'action': AUTO, 'new': [pm.b, hit[1]], 'confidence': conf, 'note': note}
    if len(calls) == 1:
        return {'action': AUTO, 'new': [pm.b, calls[0]], 'confidence': 'similar',
                'note': f'the only NAMECALL :{method} in P{pm.b} (alignment did not pin it)'}
    if not calls:
        return {'action': DROPPED, 'reason': f'P{pm.b} no longer calls :{method}'}
    return {'action': REVIEW, 'reason': f'P{pm.b} has {len(calls)} NAMECALL :{method} ({calls}) and the alignment does '
                                        'not pick one'}


def structural_delta(old: B.Module, new: B.Module) -> list[str]:
    """Differences between two addon builds other than number constants and LOADN immediates."""
    out = []
    if old.pool != new.pool:
        out.append('string pool differs')
    if len(old.protos) != len(new.protos):
        return out + ['prototype count differs']
    for a, b in zip(old.protos, new.protos):
        if a.header != b.header or len(a.consts) != len(b.consts) or a.kids != b.kids:
            out.append(f'prototype {a.index} header/constants/children differ')
            continue
        for x, y in zip(a.consts, b.consts):
            if x.tag != y.tag or (x.tag != 2 and x.value != y.value):
                out.append(f'prototype {a.index} constant other than a number differs')
                break
        if len(a.instructions) != len(b.instructions):
            out.append(f'prototype {a.index} instruction count differs')
            continue
        for la, _, opa in a.instructions:
            wa, wb = old.word(a, la), new.word(b, la)
            if wa == wb:
                continue
            if opa == RM.OP_LOADN and wa[:2] == wb[:2]:
                continue
            out.append(f'prototype {a.index} instruction {la} differs ({wa.hex()} -> {wb.hex()})')
            break
    return out


def compile_u44(derecomp: Path, source: Path, out: Path, name_map: Path | None) -> tuple[bool, str]:
    args = [str(derecomp), 'recompile-u44', str(source), str(out)] + ([str(name_map)] if name_map else [])
    r = subprocess.run(args, capture_output=True, text=True, timeout=300)
    text = (r.stdout + r.stderr).strip()
    return r.returncode == 0 and 're-parses=yes' in text and out.is_file(), text.splitlines()[-1] if text else ''


def rebuild_addon(spec: dict, installed: Path, hooks: dict, mm: RM.ModuleMap, seed: int, tools: dict,
                  work: Path, opmap) -> dict:
    """Rebuild one authored addon for the new target. hooks = step-1 hook table of the installed addon for its key."""
    work.mkdir(parents=True, exist_ok=True)
    src = tools['editor'] / spec['source']
    name_map = tools['name_map'] if spec.get('alias_map') else None
    res = {'file': spec['installed'], 'source': spec['source'], 'gates': []}

    def gate(name, ok, detail=''):
        res['gates'].append({'name': name, 'pass': bool(ok), 'detail': detail})
        return ok
    if not src.is_file():
        return dict(res, action=REVIEW, reason=f'source {spec["source"]} not found')
    base = work / 'baseline.lua_B'
    ok, line = compile_u44(tools['derecomp'], src, base, name_map)
    if not gate('source-reproduces-installed', ok and base.read_bytes() == installed.read_bytes(),
                f'{_sha(base.read_bytes())[:16] if base.is_file() else "-"} vs installed {_sha(installed.read_bytes())[:16]}'):
        return dict(res, action=REVIEW, reason='the recorded source does not rebuild the installed addon exactly')
    changes, callsites = [], []
    for method, info in sorted(hooks.get('nativeCalls', {}).items()):
        for p, i in info.get('callsites', []):
            m = map_callsite(mm, method, p, i, seed)
            callsites.append(dict(m, method=method, old=[p, i]))
            if m['action'] != AUTO:
                return dict(res, action=m['action'], reason=f'nativeCalls.{method} P{p} i{i}: {m["reason"]}',
                            callsites=callsites)
            if m['new'] != [p, i]:
                changes.append((p, i, m['new'][0], m['new'][1]))
    if hooks.get('luaCalls'):
        return dict(res, action=REVIEW, reason='authored luaCalls hooks are not rewritten automatically', callsites=callsites)
    res['callsites'] = callsites
    text = src.read_text(encoding='utf-8')
    dec_installed = uc_content.decompile(tools['derecomp'], installed, _sha(installed.read_bytes()), work / 'decompiled')
    expect = {(p, i): len(source_sites(dec_installed, p, i)) for p, i, _, _ in changes}
    new_text, problems = rewrite_source(text, changes, expect)
    old_key, new_key = mm.ma.key, mm.mb.key
    new_text = new_text.replace(old_key, new_key)
    if problems:
        return dict(res, action=REVIEW, reason='; '.join(problems))
    cand_src = work / Path(spec['source']).name
    cand_src.write_text(new_text, encoding='utf-8', newline='\n')
    name = re.sub(r'^[0-9a-f]{16}', new_key, Path(spec['installed']).name)
    cand = work / name
    cand2 = work / ('repeat.' + name)
    ok1, line1 = compile_u44(tools['derecomp'], cand_src, cand, name_map)
    ok2, _ = compile_u44(tools['derecomp'], cand_src, cand2, name_map)
    gate('recompile-u44', ok1, line1)
    gate('deterministic', ok1 and ok2 and cand.read_bytes() == cand2.read_bytes())
    if not (ok1 and ok2):
        return dict(res, action=REVIEW, reason='the rewritten source does not compile')
    rt = subprocess.run([str(tools['derecomp']), 'de-roundtrip', str(cand)], capture_output=True, text=True, timeout=300)
    gate('de-roundtrip', rt.returncode == 0 and 'FULL BODY identical: True' in rt.stdout)
    delta = structural_delta(B.Module(installed.read_bytes(), opmap), B.Module(cand.read_bytes(), opmap))
    gate('only-numbers-changed', not delta, '; '.join(delta[:3]))
    dec = uc_content.decompile(tools['derecomp'], cand, _sha(cand.read_bytes()), work / 'decompiled')
    script = uc_content.Script('target-addon', cand, name, [new_key])
    got = uc_content.extract_hooks(script, dec).get(new_key, {})
    want = {meth: sorted(c['new'] for c in callsites if c['method'] == meth) for meth in hooks.get('nativeCalls', {})}
    have = {meth: sorted(v['callsites']) for meth, v in got.get('nativeCalls', {}).items()}
    gate('hook-table-equals-plan', have == want, f'{have}')
    if not all(g['pass'] for g in res['gates']):
        failed = [g['name'] for g in res['gates'] if not g['pass']]
        return dict(res, action=REVIEW, reason=f'rebuild gates failed: {failed}')
    conf = 'similar' if any(c.get('confidence') == 'similar' for c in callsites) else 'exact'
    return dict(res, action=AUTO, confidence=conf, artifact=str(cand), artifact_name=name, new_key=new_key,
                sha256=_sha(cand.read_bytes()), size=cand.stat().st_size, rewritten_source=str(cand_src),
                changes=[{'old': f'P{p} i{i}', 'new': f'P{pb} i{ib}'} for p, i, pb, ib in changes])
