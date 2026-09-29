"""Bounded cached-source coverage and generated-artifact checks; no live edits."""
from pathlib import Path
import hashlib
import json
import re
import subprocess

editor = Path(__file__).resolve().parents[3]
root = editor.parents[2]
out = Path(__file__).resolve().parents[1] / 'artifacts/automatic-tests'
out.mkdir(parents=True, exist_ok=True)
cli = root / 'work/builds/ability-editor/current/bin/renovice_ability_editor_cli.exe'
compiler = root / 'repos/toolchains/de-luau-toolchain/bin/derecomp.exe'
results = []
for source in sorted((root / 'work/rendered-source/ability-editor').glob('*.luau')):
    if not re.fullmatch('[0-9a-f]{16}', source.stem):
        continue
    run = subprocess.run([str(cli), 'card-stats', '--source', str(source), '--body-key', source.stem,
                          '--names', str(root / 'work/catalogs/Names.en.json'), '--editor-root', str(editor)],
                         capture_output=True, text=True, encoding='utf-8')
    assert run.returncode == 0, run.stderr
    report = json.loads(run.stdout)
    (out / (source.stem + '.json')).write_text(run.stdout, encoding='utf-8')
    controls = [c for c in report['controls'] if c.get('operation') == 'scale']
    record = dict(body=source.stem, source_sha256=hashlib.sha256(source.read_bytes()).hexdigest(),
                  automatic_controls=[c['label'] for c in controls], checks=[])
    results.append(record)
    if not controls:
        continue
    original = source.read_bytes()
    data = original
    inputs = [i for c in controls for i in c['inputs']]
    assert len({i['offset'] for i in inputs}) == len(inputs), 'overlapping controls'
    previous = len(data)
    for item in sorted(inputs, key=lambda i: i['offset'], reverse=True):
        start, end = item['offset'], item['offset'] + item['length']
        assert end <= previous and float(data[start:end]) == item['original']
        data = data[:start] + format(item['original'] * 2, '.16g').encode() + data[end:]
        previous = start
    assert data != original
    edited = out / (source.stem + '.scaled.luau')
    edited.write_bytes(data)
    binary = edited.with_suffix('.lua_B')
    for name, args, marker in [
        ('compile', ['recompile', str(edited), str(binary)], 're-parses=yes'),
        ('plan', ['plan-verify', str(binary)], 'failures=0'),
        ('container', ['de-roundtrip', str(binary)], 'FULL BODY identical: True')]:
        run = subprocess.run([str(compiler), *args], capture_output=True, text=True, encoding='utf-8')
        (out / (source.stem + '.' + name + '.log')).write_text(run.stdout + run.stderr, encoding='utf-8')
        passed = run.returncode == 0 and marker in run.stdout
        record['checks'].append(dict(check=name, passed=passed))
        if not passed:
            break
    print(source.stem, record['automatic_controls'], record['checks'], flush=True)
(out / 'summary.json').write_text(json.dumps(results, indent=2), encoding='utf-8')
print('Cached modules:', len(results), 'Automatic controls:', sum(len(r['automatic_controls']) for r in results))
assert all(c['passed'] for r in results for c in r['checks']), 'See per-module compiler logs'
