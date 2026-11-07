"""R24 (2026-11-07): Descendia script-parameter rows as reader pins (IMPORT_READ_PIN_V1).

The registry already lists these values as METADATA_PATCH rows (trigger-type script parameters), which SCRIPT SETTINGS
cannot reach. Each one is read by its consumer module only through single-name GETIMPORTs of the hashed global, so the
R15 reader pin owns it live (next mission, no restart). This tool writes the R24 draft rows from the registry rows and the
stock bytecode (every GETIMPORT of the hash, by prototype and instruction). New tunable ids under `descendia.*`; the
METADATA_PATCH rows stay as they are (they never reach SCRIPT SETTINGS).

Excluded: WaveDefend (every Defense mission reads it, not only Descendia), non-integer stock values (LOADN cannot hold
them), and parameters with no GETIMPORT read in the consumer module.
"""
import json
import re
import subprocess
import sys
from pathlib import Path

EDITOR = Path(__file__).resolve().parents[3]
REGISTRY = EDITOR / 'REGISTRIES/mission_build_u44.json'
REPOS = EDITOR.parents[1]
EXE = REPOS / 'toolchains/de-luau-toolchain-multiexit/bin/derecomp.exe'
STOCK = REPOS / 'toolchains/de-luau-toolchain/work/failure-clusters-2026-11-02/stock-2026.10.22.13.12'
OUT = Path(__file__).resolve().parents[1] / 'inputs/r24_row_drafts.json'

EXCLUDED_FILES = {'Lotus_Scripts_WaveDefend.lua_B'}
MODE_SLUG = {
    'Alchemy': 'alchemy', 'Excavation': 'excavation', 'Mobile Interception': 'mobile_interception',
    'Legacyte Harvest': 'legacyte_harvest', 'Meltdown': 'meltdown', 'Shrine Defense': 'shrine_defense',
}
SHARED = {  # consumer modules that non-Descendia variants also run
    'Lotus_Scripts_Modes_EntratiLabAlchemy.lua_B': 'Entrati Lab Alchemy (same script)',
    'Lotus_Scripts_Modes_MeltdownMode.lua_B': 'Entrati Lab Meltdown (same script)',
    'Lotus_Scripts_Modes_InfestedCapture.lua_B': '1999 Legacyte Harvest (same script)',
}


def snake(name):
    if name.upper() == name:
        return name.lower()
    return re.sub(r'(?<!^)(?=[A-Z])', '_', name).lower().strip('_')


def getimport_sites(file, name_hash):
    text = subprocess.run([str(EXE), 'ir-u44', str(STOCK / file)], capture_output=True, text=True,
                          errors='replace').stdout
    proto, sites, other = -1, [], []
    for line in text.splitlines():
        m = re.match(r'== proto\[(\d+)\]', line)
        if m:
            proto = int(m.group(1))
            continue
        m = re.match(r'\s*\[\s*(\d+)\]\s+(\S+)', line)
        if m and name_hash in line.lower():
            (sites if m.group(2) == 'GETIMPORT' else other).append((proto, int(m.group(1)), m.group(2)))
    return sites, other


def main():
    reg = json.loads(REGISTRY.read_text(encoding='utf-8'))
    rows, skipped = [], []
    for t in reg['tunables']:
        if t['backend'] != 'METADATA_PATCH' or not t['mission_type'].startswith('Descendia: '):
            continue
        mode = t['mission_type'].split(': ', 1)[1]
        c = t['owner'].get('consumer') or {}
        file, name, h = c.get('file'), c.get('global'), (c.get('name_hash') or '').lower()
        stock = float(t['owner']['stock_text'])
        why = None
        if file in EXCLUDED_FILES:
            why = 'consumer module is shared by every Defense mission'
        elif not stock.is_integer() or not (-32768 <= stock <= 32767):
            why = 'stock value is not a LOADN whole number'
        sites, other = getimport_sites(file, h) if not why else ([], [])
        if not why and (not sites or other):
            why = 'no GETIMPORT read' if not sites else f'non-GETIMPORT use {other}'
        if why:
            skipped.append({'from': t['tunable_id'], 'global': name, 'reason': why})
            continue
        tid = f"descendia.{MODE_SLUG[mode]}.{snake(name)}"
        lim = t['limits']
        rows.append({
            'tunable_id': tid,
            'phase1_tunable_id': None,
            'label': t['label'],
            'mission_type': t['mission_type'],
            'variant': t.get('variant', ''),
            'shared_with': SHARED.get(file, ''),
            'owner_kind': 'SCRIPT_PARAM_GLOBAL',
            'backend': 'EXACT_LITERAL',
            'owner': {
                'body_key': c['body_key'], 'stock_sha256': c['stock_sha256'], 'file': file,
                'module_path': c['module_path'],
                'sites': [{'kind': 'import_pin', 'global': name, 'hash': h, 'prototype': p, 'instruction': i,
                           'owner': f'P{p} i{i} GETIMPORT {name} -> LOADN (trigger parameter '
                                    f'{t["owner"]["field"]} of {t["owner"]["type"].rsplit("/", 1)[-1]}, stock {int(stock)})'}
                          for p, i, _ in sites],
            },
            'unit': t['unit'],
            'stock': int(stock),
            'limits': {'minimum': max(0, int(lim.get('minimum', 0))), 'maximum': min(32767, int(lim.get('maximum', 32767))),
                       'integer': True,
                       'basis': 'LOADN domain; gameplay-safe range not established offline'},
            'applies': 'next_mission',
            'confidence': 'CONFIRMED_STATIC (reader pin, IMPORT_READ_PIN_V1; live pending)',
            'evidence': (f'{file} reads the trigger parameter {t["owner"]["field"].rsplit(".", 1)[-1]} only as single-name '
                         f'GETIMPORT #{h} at {len(sites)} site(s); the trigger metadata row {t["tunable_id"]} '
                         f'({t["owner"]["preimage"]}) stays METADATA_PATCH. With the row off the module is stock.'),
        })
    OUT.parent.mkdir(parents=True, exist_ok=True)
    data = {'schema': 'RENOVICE_MISSION_TUNABLE_REGISTRY_V2 tunables[] drafts (contract R24)',
            'build': reg['build'], 'supersedes': {}, 'rows': rows, 'skipped': skipped}
    OUT.write_text(json.dumps(data, indent=1) + '\n', encoding='utf-8', newline='\n')
    print(f'{len(rows)} rows, {len(skipped)} skipped -> {OUT}')
    for r in rows:
        print(' ', r['tunable_id'], 'stock', r['stock'], 'sites', len(r['owner']['sites']))
    for s in skipped:
        print('  skip', s['from'], '-', s['reason'])


if __name__ == '__main__':
    sys.exit(main())
