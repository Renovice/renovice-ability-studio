#!/usr/bin/env python3
"""Regression test of the metadata rows across a Packages.bin change (2026-10-04).

Builds a "new" snapshot from the registry's own METADATA_SNAPSHOT.json with uc_metadata's parser, mutates the composed
text of one owner type per case, and checks the registrar rebase decision for the affected METADATA_PATCH rows:

  unchanged        new Packages.bin, same text: every metadata row carried over (auto), packages_bin re-pinned
  parser identity  the parser re-reads every registered field of the snapshot to its recorded stock text
  changed-number   CoHMeltdownTrigger _VENTS_TO_REVEAL 3 -> 4: auto, STOCK_CHANGED, stock/stock_text/preimage = 4
  removed-field    CoHMeltdownTrigger without _SCAN_RATE: that row goes to review
  other-consumer   CoHShrineDefenseTrigger Script path changed: its rows go to review
  missing-type     HellDefenseTrigger absent from the new Packages.bin: its rows go to review
  same-packages    Packages.bin unchanged, new build: rows unchanged, snapshot re-stamped with the new build
  no-snapshot      Packages.bin changed and no build-B snapshot: review (previous behaviour)

Offline: reads only the registry, its corpus snapshot and the build-A corpus modules. No game files.
    python repos/apps/ability-editor/tools/update_check/test_metadata_rebase.py
"""
from __future__ import annotations

import copy
import json
import sys
from pathlib import Path

TOOL = Path(__file__).resolve().parent
EDITOR = TOOL.parents[1]
sys.path.insert(0, str(TOOL))
sys.path.insert(0, str(EDITOR / 'RESEARCH' / 'UNIVERSAL_MISSION_REGISTRY_2026-09-29' / 'tools'))
import uc_bytecode as B  # noqa: E402
import uc_metadata as UM  # noqa: E402
import rebase_registry as RR  # noqa: E402

NEW_PBIN = 'f' * 64
BUILD_B = 'synthetic.metadata.build'


def main() -> int:
    ws = EDITOR.parents[2]
    wsj = json.loads((ws / 'WORKSPACE.json').read_text(encoding='utf-8'))
    registry = json.loads((EDITOR / 'REGISTRIES' / 'mission_build_u44.json').read_text(encoding='utf-8'))
    corpus = ws / registry['corpus']
    snap_a = json.loads((corpus / registry['metadata_snapshot']['file']).read_text(encoding='utf-8'))
    opmap = B.load_opcode_profile((ws / wsj['repos']['de_luau_toolchain'] / 'src' / 'de_opcode_profile.h').read_text())
    meta_rows = {r['tunable_id']: r for r in registry['tunables'] if r['backend'] == 'METADATA_PATCH'}
    by_type: dict[str, list[str]] = {}
    for tid, r in meta_rows.items():
        by_type.setdefault(r['owner']['type'], []).append(tid)
    results = []

    def check(case, label, ok, detail=''):
        results.append(bool(ok))
        print(f'{"PASS" if ok else "FAIL"}  {case}: {label}' + (f'  [{detail}]' if detail and not ok else ''))

    def snapshot(texts: dict, pbin=NEW_PBIN) -> dict:
        """snapshot_for_build's field re-read on given texts (no probe: the texts stand in for the decode)."""
        types = {}
        for t, rec in snap_a['types'].items():
            if t not in texts:
                continue
            tree = UM.parse(texts[t])
            fields, scripts = {}, {}
            for path in rec['fields']:
                v, holder = UM.resolve(tree, path)
                if v is not None:
                    fields[path] = v
                    if UM.script_path(holder, t):
                        scripts[path] = UM.script_path(holder, t)
            types[t] = {'text': texts[t], 'fields': fields, 'scripts': scripts}
        return {'format': UM.FORMAT, 'build': BUILD_B, 'packages_bin_sha256': pbin, 'types': types}

    def rebase(snap, pbin=NEW_PBIN):
        rb = RR.Rebase(registry, corpus, corpus, opmap, build=BUILD_B, build_label=BUILD_B, packages_bin_sha256=pbin,
                       corpus_rel=registry['corpus'], log=lambda *a: None, metadata_snapshot_b=snap)
        new, decisions, _ = rb.run()
        return {r['tunable_id']: r for r in new['tunables']}, {d['tunable_id']: d for d in decisions}

    texts_a = {t: rec['text'] for t, rec in snap_a['types'].items()}

    # parser identity
    bad = [(t, p) for t, rec in snap_a['types'].items() for p, v in rec['fields'].items()
           if UM.resolve(UM.parse(rec['text']), p)[0] != v]
    check('parser identity', f'{sum(len(r["fields"]) for r in snap_a["types"].values())} registered fields re-read exactly',
          not bad, bad[:3])

    # unchanged
    rows, dec = rebase(snapshot(texts_a))
    acts = {dec[t]['action'] for t in meta_rows}
    check('unchanged', f'{len(meta_rows)} metadata rows carried over (auto)', acts == {'auto'}, acts)
    check('unchanged', 'owners re-pinned to the new Packages.bin, stock text unchanged',
          all(rows[t]['owner']['packages_bin_sha256'] == NEW_PBIN and
              rows[t]['owner']['stock_text'] == meta_rows[t]['owner']['stock_text'] for t in meta_rows))

    # changed-number
    melt = '/Lotus/Types/Gameplay/DevilTower/LiteGameModes/CoHMeltdownTrigger'
    vents = next(t for t in by_type[melt] if meta_rows[t]['owner']['field'].endswith('_VENTS_TO_REVEAL'))
    texts = dict(texts_a, **{melt: texts_a[melt].replace('_VENTS_TO_REVEAL=3', '_VENTS_TO_REVEAL=4')})
    rows, dec = rebase(snapshot(texts))
    o = rows.get(vents, {}).get('owner', {})
    check('changed-number', f'{vents}: auto, STOCK_CHANGED 3 -> 4',
          dec[vents]['action'] == 'auto' and dec[vents].get('stock') == {'old': 3, 'new': 4} and rows[vents]['stock'] == 4
          and o.get('stock_text') == '4' and o.get('preimage') == '_VENTS_TO_REVEAL=4', dec[vents])

    # removed-field
    scan = next(t for t in by_type[melt] if meta_rows[t]['owner']['field'].endswith('_SCAN_RATE'))
    texts = dict(texts_a, **{melt: '\n'.join(l for l in texts_a[melt].split('\n') if not l.startswith('_SCAN_RATE='))})
    rows, dec = rebase(snapshot(texts))
    check('removed-field', f'{scan}: review', dec[scan]['action'] == 'review' and scan not in rows, dec[scan])
    others = [t for t in by_type[melt] if t != scan]
    check('removed-field', 'the other rows of the type stay auto', all(dec[t]['action'] == 'auto' for t in others))

    # other-consumer
    shrine = '/Lotus/Types/Gameplay/DevilTower/LiteGameModes/CoHShrineDefenseTrigger'
    old_script = UM.script_path(UM.resolve(UM.parse(texts_a[shrine]), 'Scripts.0.Script.Script')[1], shrine)
    assert old_script, 'shrine trigger has no Scripts.0 consumer'
    name = old_script.rsplit('/', 1)[1]
    texts = dict(texts_a, **{shrine: texts_a[shrine].replace(name, 'RenamedConsumer.lua', 1)})
    rows, dec = rebase(snapshot(texts))
    check('other-consumer', f'{len(by_type[shrine])} shrine rows: review',
          all(dec[t]['action'] == 'review' for t in by_type[shrine]), [dec[t]['action'] for t in by_type[shrine]])

    # missing-type
    hell = '/Lotus/Types/Gameplay/DevilTower/LiteGameModes/HellDefenseTrigger'
    texts = {t: v for t, v in texts_a.items() if t != hell}
    rows, dec = rebase(snapshot(texts))
    check('missing-type', f'{len(by_type[hell])} defense rows: review',
          all(dec[t]['action'] == 'review' for t in by_type[hell]))

    # same-packages: Packages.bin unchanged across the build change
    same = registry['packages_bin_sha256']
    rows, dec = rebase(snapshot(texts_a, same), same)
    check('same-packages', 'rows unchanged (nothing to re-pin)',
          all(dec[t]['action'] in ('unchanged', 'auto') and rows[t]['owner'] == meta_rows[t]['owner'] for t in meta_rows))
    snap = UM.snapshot_for_build(snap_a, build=BUILD_B, packages_bin_sha256=same, packages_bin=None, ws=ws, wsj=wsj,
                                 work=Path('.'), log=lambda *a: None)
    check('same-packages', 'snapshot re-stamped with the new build, same texts and fields',
          snap['build'] == BUILD_B and all(snap['types'][t]['text'] == r['text'] and snap['types'][t]['fields'] == r['fields']
                                           for t, r in snap_a['types'].items()))

    # no-snapshot
    rows, dec = rebase(None)
    check('no-snapshot', 'Packages.bin changed without a build-B snapshot: every metadata row to review',
          all(dec[t]['action'] == 'review' for t in meta_rows))

    ok = all(results)
    print(f'\nMETADATA REBASE TEST {"PASS" if ok else "FAIL"}: {sum(results)}/{len(results)} expectations')
    return 0 if ok else 1


if __name__ == '__main__':
    sys.exit(main())
