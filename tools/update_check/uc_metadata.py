"""Metadata snapshot for a new build (update resilience, 2026-10-04).

The registry's METADATA_PATCH rows are verified against METADATA_SNAPSHOT.json: per owner type, the composed metadata
text and the stock text of every registered field. After a Warframe update that snapshot belongs to the old build and,
when Packages.bin changed, to the old Packages.bin. This module builds the snapshot for build B:

- Packages.bin unchanged: the old snapshot's types, stamped with build B (same bytes, so the same texts).
- Packages.bin changed: the composed text of every snapshot type is decoded from the new Packages.bin with the metadata
  editor's own decoder (metadata_probe/, built on demand), and every registered field is re-read from that text with the
  runtime rule (bootstrapper EeNotationParser: a ',' only ends a value, it is never a list element).

The registrar's rebase then carries a row over only when its field still holds a value, its exact preimage line is in the
new composed text and its Scripts entry still names the same consumer script (rebase_registry.Rebase.metadata).
Read-only towards the game; writes only into the caller's work folder.
"""
from __future__ import annotations

import hashlib
import json
import re
import subprocess
from pathlib import Path

TOOL_DIR = Path(__file__).resolve().parent
PROBE_DIR = TOOL_DIR / 'metadata_probe'
FORMAT = 'RENOVICE_METADATA_SNAPSHOT_V1'


def parse(text: str) -> dict:
    """Composed metadata text (first line: the type header) -> nested dict / list, runtime parsing rule."""
    body = text.split('\n', 1)[1] if '\n' in text else ''
    tokens = re.findall(r'"[^"]*"|[{}=]|[^\s{}=,"]+', body)

    def value(i):
        if tokens[i] != '{':
            return tokens[i], i + 1
        i += 1
        items, obj, is_obj = [], {}, False
        while tokens[i] != '}':
            if i + 1 < len(tokens) and tokens[i + 1] == '=':
                k = tokens[i]
                v, i = value(i + 2)
                obj[k] = v
                is_obj = True
            else:
                v, i = value(i)
                items.append(v)
        return (obj if is_obj else items), i + 1

    top, i = {}, 0
    while i < len(tokens):
        if i + 1 < len(tokens) and tokens[i + 1] == '=':
            k = tokens[i]
            top[k], i = value(i + 2)
        else:
            i += 1
    return top


def resolve(tree, path: str):
    """'Scripts.1.Script._x' / 'OnFirstTouchedScript._duration' -> (value or None, the dict that holds it or None)."""
    node, parent = tree, None
    for seg in path.split('.'):
        parent = node
        if isinstance(node, list) and seg.isdigit() and int(seg) < len(node):
            node = node[int(seg)]
        elif isinstance(node, dict) and seg in node:
            node = node[seg]
        else:
            return None, None
    return (node if isinstance(node, str) else None), (parent if isinstance(parent, dict) else None)


def script_path(holder: dict | None, type_path: str) -> str | None:
    """The consumer script the field's holder names (a relative path resolves against the owning type's directory)."""
    if not holder or not isinstance(holder.get('Script'), str):
        return None
    s = holder['Script']
    return s if s.startswith('/') else type_path.rsplit('/', 1)[0] + '/' + s


def build_probe(ws: Path, wsj: dict, out_dir: Path, log=print) -> Path:
    core = ws / wsj['repos']['metadata_editor'] / 'editor' / 'Core' / 'Core.csproj'
    if not core.is_file():
        raise SystemExit(f'metadata probe: metadata editor Core project not found at {core}')
    exe = out_dir / 'metadata_probe.exe'
    stamp = out_dir / 'inputs.sha256'
    inputs = hashlib.sha256(b''.join(p.read_bytes() for p in sorted(PROBE_DIR.glob('*.cs*')))).hexdigest()
    if exe.is_file() and stamp.is_file() and stamp.read_text().strip() == inputs:
        return exe
    log('metadata probe: building (dotnet, warnings are errors)')
    r = subprocess.run(['dotnet', 'build', str(PROBE_DIR / 'metadata_probe.csproj'), '-c', 'Release', '-o', str(out_dir),
                        f'-p:MetadataEditorCore={core}', '-nologo', '-v', 'q'], capture_output=True, text=True)
    if r.returncode != 0 or not exe.is_file():
        raise SystemExit(f'metadata probe build failed:\n{(r.stdout + r.stderr)[-2000:]}')
    stamp.write_text(inputs)
    return exe


def compose(ws: Path, wsj: dict, packages_bin: bytes, types: list[str], work: Path, log=print) -> dict:
    """{'types': {path: {'parent', 'text'}}, 'missing': [...]} from Packages.bin bytes (decompressed)."""
    work.mkdir(parents=True, exist_ok=True)
    exe = build_probe(ws, wsj, ws / wsj['work']['builds'] / 'update-check-metadata-probe', log)
    pbin = work / 'Packages.bin'
    pbin.write_bytes(packages_bin)
    (work / 'types.json').write_text(json.dumps(sorted(types)), encoding='utf-8')
    r = subprocess.run([str(exe), 'compose', str(pbin), str(work / 'types.json'), str(work / 'composed.json')],
                       capture_output=True, text=True, timeout=900)
    if r.returncode != 0:
        raise SystemExit(f'metadata probe failed ({r.returncode}): {(r.stderr or r.stdout)[-1000:]}')
    log('metadata probe: ' + r.stdout.strip())
    return json.loads((work / 'composed.json').read_text(encoding='utf-8'))


def snapshot_for_build(old_snapshot: dict, *, build: str, packages_bin_sha256: str, packages_bin: bytes | None,
                       ws: Path, wsj: dict, work: Path, log=print) -> dict:
    """The snapshot of build B. Fields are re-read from the new composed text; a field the new text no longer holds is
    left out (its row goes to review in the rebase). `scripts` records each field holder's consumer script."""
    same = packages_bin_sha256.lower() == old_snapshot['packages_bin_sha256'].lower()
    if same:
        texts = {t: rec['text'] for t, rec in old_snapshot['types'].items()}
        missing = []
        source = f'carried over from the {old_snapshot["build"]} snapshot (Packages.bin unchanged)'
    else:
        if packages_bin is None:
            raise SystemExit('metadata snapshot: Packages.bin changed but its bytes are unavailable')
        composed = compose(ws, wsj, packages_bin, list(old_snapshot['types']), work, log)
        texts = {t: rec['text'] for t, rec in composed['types'].items()}
        missing = composed['missing']
        source = 'update tool metadata_probe (metadata editor PackagesBinDecoder) decode of the installed Packages.bin'
    types = {}
    for t, rec in old_snapshot['types'].items():
        if t not in texts:
            continue
        tree = parse(texts[t])
        fields, scripts = {}, {}
        for path in rec['fields']:
            v, holder = resolve(tree, path)
            if v is not None:
                fields[path] = v
                sp = script_path(holder, t)
                if sp:
                    scripts[path] = sp
        types[t] = {'text': texts[t], 'fields': fields, 'scripts': scripts}
    return {'format': FORMAT, 'build': build, 'packages_bin_sha256': packages_bin_sha256, 'source': source,
            'missing_types': missing, 'types': dict(sorted(types.items()))}
