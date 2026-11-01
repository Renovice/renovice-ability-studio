"""2026-10-30: Survival enemies-at-once rows (24 root-table array elements) and the AI director hard cap row.

Why (scratchpad research cap35, director; decompiled stock 44.1.3): SurvivalMission's root builds the config table
(root i20 R10, already a registered root table) with six per-player count arrays, each NEWTABLE + 4 x LOADN + SETLIST,
stored as fields minNum / maxNum / minNumInfested / maxNumInfested / minNumEnemiesHardModeDuviri /
maxNumEnemiesHardModeDuviri. The count function (prototype 35) picks index max(players, 1) (4 on Steel Path / Kuva path),
clamps both ends with director:GetNpcHardCap() and lerps by enemy level; EndlessSpawnLib tops up to that count. The
director hard cap is HardMaxAICap (native default 40); stock Lua sets it with director:SetNpcHardCap(n) (Eidolon
EncounterManagerSetup, TauPrequel EscortMission).

A) 24 TARGET_ADDON ROOT_TABLE_FIELD rows, one per array element, each proven by addon_owner.RootTables.element_owner
   (gate ROOT_TABLE_UPVALUE_V1, container path [<field name>]); the hook plan (ROOT_TABLE_MINIMAL_HOOKS_V1) of each new
   table is computed by hook_plan.plan_module exactly as the registrar does.
B) enemies.hard_cap: AI_DIRECTOR_SETTER_AT_ENTRY on Lotus.Scripts.ProceduralLevel (every procedural level), entries
   P65 (InitializeWithAIXpPool, the level entry; obtains the director after npcMgr:CanFind()) and P2 (the director
   TrackTaggedEntities setup, called once by P65 after the director exists, before SetMaxAI). Both root children
   (mission_owner_specs.root_child); readers = their stock GetAiDirector uses (census).

Idempotent guard: refuses when a row id already exists. Usage: python add_survival_enemy_rows.py
"""
import hashlib
import json
import struct
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
EDITOR = HERE.parents[2]
ROOT = EDITOR
while not (ROOT / 'WORKSPACE.json').exists():
    ROOT = ROOT.parent
TOOLS = EDITOR / 'RESEARCH/UNIVERSAL_MISSION_REGISTRY_2026-09-29/tools'
sys.path.insert(0, str(TOOLS))
import mission_owner_specs as SPECS  # noqa: E402
import hook_plan as HOOK_PLAN  # noqa: E402
from addon_owner import RootTables, GATE as ADDON_GATE  # noqa: E402
from deluau import body_key  # noqa: E402

REGISTRY = EDITOR / 'REGISTRIES/mission_build_u44.json'
BUILD = '2026.10.08.13.05'
STOCK = ROOT / 'work/temp/update-check/stock-726365cc81044d28'
CURRENT = ROOT / 'work/temp/update-check/stock-fee493000964dd66'  # 44.1.3: bodies must be identical
SURVIVAL = 'Lotus_Scripts_Modes_SurvivalMission.lua_B'
LEVEL = 'Lotus_Scripts_ProceduralLevel.lua_B'
PROVENANCE = 'research:survival-enemies-2026-10-30'
# (id part, root field, first element LOADN instruction in the root, label part)
TABLES = [('min', 'minNum', 22, 'lowest levels'), ('max', 'maxNum', 29, 'level 30 and up'),
          ('infested_min', 'minNumInfested', 36, 'Infested, lowest levels'),
          ('infested_max', 'maxNumInfested', 43, 'Infested, level 30 and up'),
          ('duviri_min', 'minNumEnemiesHardModeDuviri', 50, 'Duviri hard mode, lowest levels'),
          ('duviri_max', 'maxNumEnemiesHardModeDuviri', 57, 'Duviri hard mode, level 30 and up')]
ROW_MAXIMUM = 100000  # numeric guard (master 1000 x the largest stock 35 fits); gameplay-safe range not established


def namehash(name, seed):
    x = seed
    for b in name.encode():
        x = ((x ^ b) * 0x01000193) & 0xFFFFFFFF
    x = (~x) & 0xFFFFFFFF
    return ((x << 17) | (x >> 15)) & 0xFFFFFFFF


def module_record(reg, file):
    raw = (STOCK / file).read_bytes()
    if raw != (CURRENT / file).read_bytes():
        raise SystemExit(f'{file}: 44.1.3 body differs from the registry build')
    key, sha = body_key(raw), hashlib.sha256(raw).hexdigest().upper()
    rec = reg['modules'].get(key)
    if rec is None or rec['sha256'] != sha or rec['file'] != file:
        raise SystemExit(f'{file}: registry module {key} missing or another body')
    target = ROOT / reg['corpus'] / file
    if hashlib.sha256(target.read_bytes()).hexdigest().upper() != sha:
        raise SystemExit(f'corpus file {target} is another body')
    return raw, key, rec


def addon_field(m, rec, ev):
    """register_registry.addon_field (same record shape): table record on the module, per-field owner entry."""
    tables = rec.setdefault('root_tables', {})
    c = ev['construction']
    table = {'gate': ADDON_GATE, 'prototype': c['prototype'], 'instruction': c['instruction'], 'register': c['register'],
             'op': c['op'].split('+')[0], 'containers': ev['containers'],
             'hooks': [{k: h[k] for k in ('prototype', 'upvalue', 'path', 'capture', 'closure_instruction')} for h in ev['hooks']]}
    old = tables.get(ev['table_id'])
    if old is not None and {k: v for k, v in old.items() if k != 'minimal_hooks'} != table:
        raise ValueError(f'table {ev["table_id"]} evidence differs between fields')
    if old is None:
        tables[ev['table_id']] = table
    off, kind = c['value_offset'], c['value_kind']
    width = 8 if kind == 'number_constant' else 4
    return {'field': ev['field'], 'table_id': ev['table_id'], 'value_kind': kind, 'value_offset': off,
            'expected': list(m.raw[off:off + width]), 'construction': c['op'], 'field_reads': ev['field_reads']}


def survival_rows(reg, ids):
    raw, key, rec = module_record(reg, SURVIVAL)
    m = RootTables(raw)
    ins = m.protos[m.root][0]
    rows, new_tables = [], set()
    for part, field, first, where in TABLES:
        for n in range(4):
            vi = first + n
            w = ins[vi][1]
            if w[0] != 0x12:
                raise SystemExit(f'{field}[{n + 1}]: root instruction {vi} is not LOADN')
            stock = struct.unpack_from('<h', w, 2)[0]
            ev = m.element_owner(vi, float(stock))
            if ev['field'] != n + 1 or [c['key'] for c in ev['containers']] != [field]:
                raise SystemExit(f'{field}[{n + 1}]: element proves as {ev["field"]} under {ev["containers"]}')
            entry = addon_field(m, rec, ev)
            new_tables.add(ev['table_id'])
            tid = f'survival.enemy_count.{part}.p{n + 1}'
            if tid in ids:
                raise SystemExit(f'{tid} is already a registry row')
            label = f'Survival enemies at once ({where}), {n + 1} player(s)'
            rows.append({
                'tunable_id': tid, 'phase1_tunable_id': None, 'label': label, 'mission_type': 'Survival', 'variant': 'all',
                'shared_with': '', 'owner_kind': 'LUA_ROOT_TABLE', 'backend': 'TARGET_ADDON',
                'owner': {'body_key': key, 'stock_sha256': rec['sha256'], 'file': rec['file'], 'module_path': rec['module_path'],
                          'template': 'ROOT_TABLE_FIELD', 'gate': ADDON_GATE, 'fields': [entry]},
                'unit': 'enemies', 'stock': stock,
                'limits': {'minimum': 1, 'maximum': ROW_MAXIMUM, 'integer': True,
                           'basis': 'numeric guard only; gameplay-safe range not established offline'},
                'applies': 'F9', 'confidence': 'CONFIRMED_STATIC (root-table element; count rule from the decompile)',
                'provenance': PROVENANCE,
                'evidence': f'SurvivalMission root i{vi}: LOADN {stock} -> SETLIST element {n + 1} of {field} (config table root '
                            'i20). Prototype 35 picks index max(players,1) (4 on Steel Path/Kuva path), clamps with '
                            'director:GetNpcHardCap() and lerps min..max by enemy level (level/30).',
                'backend_note': f'Root-table field {ev["table_id"]}.{n + 1} (container path {field}) written through the '
                                'target-addon lane (ROOT_TABLE_UPVALUE_V1).',
                'ui': {'group': 'survival', 'mt_codes': [], 'short_label': label, 'label_source': 'id', 'scope_text': label,
                       'aliases': ['enemy count', 'enemies at once', 'spawns'], 'lane': 'addon', 'applies': 'live_next_read',
                       'type': 'int', 'editor': 'INPUTCOUNT', 'unit': '', 'min': 1, 'max': ROW_MAXIMUM, 'rank': 100000}})
    # Hook plan for the new tables (registrar step, same inputs: every owned field of every TARGET_ADDON row of the body).
    owned = {}
    for r in reg['tunables'] + rows:
        if r['backend'] == 'TARGET_ADDON' and r['owner'].get('body_key') == key:
            for f in r['owner'].get('fields', []):
                owned.setdefault(f['table_id'], set()).add(f['field'])
    plans = HOOK_PLAN.plan_module(m, rec['root_tables'], owned)[0]
    for tid, table in rec['root_tables'].items():
        plan = plans[tid]
        record = {'gate': plan['gate'], 'method': plan['method'], 'prototypes': plan['hooks'],
                  'reaching_capturers': plan['reaching_capturers'], 'forced': plan['forced'], 'coverage': plan['coverage'],
                  'escaping_capturers': plan['escaping_capturers'], 'downstream_after_escape': plan['downstream_after_escape'],
                  'reach_events': plan['reach_events'],
                  'static_weight': {'chosen': plan['static_weight_chosen'], 'full': plan['static_weight_full']},
                  'root_children': plan['root_children'], 'retire_safe': plan['retire_safe'],
                  'retire_blockers': plan['retire_blockers']}
        if tid in new_tables:
            if not record['retire_safe'] or not record['prototypes']:
                raise SystemExit(f'{tid}: hook plan is not retire safe ({record["retire_blockers"]})')
            table['minimal_hooks'] = record
        elif table.get('minimal_hooks') != record:
            raise SystemExit(f'{tid}: recomputed hook plan of an existing table differs; refusing to continue')
    rec['root_tables'] = dict(sorted(rec['root_tables'].items(), key=lambda kv: int(kv[0].split(':')[1][1:])))
    return rows


def hard_cap_row(reg, ids):
    raw, key, rec = module_record(reg, LEVEL)
    tid = 'enemies.hard_cap'
    if tid in ids:
        raise SystemExit(f'{tid} is already a registry row')
    seed = int(reg['name_hash_seed'], 16)

    class Ctx:
        @staticmethod
        def namehash(name):
            return namehash(name, seed)

    d = {'stock': 40, 'limits': {'minimum': 1, 'maximum': 1000, 'integer': True,
                                 'basis': 'numeric guard only; gameplay-safe range not established offline'},
         'owner': {'template': SPECS.AI_DIRECTOR_SETTER, 'getter': 'GetNpcHardCap', 'setter': 'SetNpcHardCap',
                   'entries': [{'prototype': 65, 'function': 'InitializeWithAIXpPool', 'role': 'level entry'},
                               {'prototype': 2, 'function': 'director TrackTaggedEntities setup',
                                'role': 'called once by prototype 65 after npcMgr:CanFind() and GetAiDirector()'}],
                   'readers': [{'key': 'GetAiDirector', 'prototype': 65, 'instructions': [85]},
                               {'key': 'GetAiDirector', 'prototype': 2, 'instructions': [3]}],
                   'write_rule': 'host only; director:SetNpcHardCap(value) once when GetNpcHardCap() is the stock 40; '
                                 'skipped when it already holds the value; another number is left alone; cleanup restores stock '
                                 'where the written value is still there',
                   'meaning': 'AI director hard cap on enemies alive at once (HardMaxAICap, native default 40)',
                   'stock_precedent': 'Eidolon/EncounterManagerSetup.lua:36 director:SetNpcHardCap(25); '
                                      'Quests/TauPrequel/EscortMission.lua:2803,4964 director:SetNpcHardCap(npcCap)'}}
    base = {'tunable_id': tid, 'phase1_tunable_id': None, 'label': 'AI director hard cap (enemies alive at once)',
            'mission_type': 'All procedural missions', 'variant': 'all', 'shared_with': '',
            'owner_kind': 'AI_DIRECTOR_VALUE', 'backend': 'TARGET_ADDON', 'unit': 'enemies', 'stock': 40,
            'confidence': 'CONFIRMED_STATIC (entry and setter; native default 40 from the director constructor)',
            'provenance': PROVENANCE, 'research_draft_id': tid,
            'evidence': 'HardMaxAICap default 40 (director constructor, 44.1.3 exe). SurvivalMission P35 and P61 clamp the '
                        'enemies-at-once count with director:GetNpcHardCap(). ProceduralLevel P65 (InitializeWithAIXpPool, '
                        'every procedural level) obtains the director (i85) and calls P2 (GetAiDirector i3) before SetMaxAI.'}
    row = SPECS.entry_row(Ctx, RootTables(raw), key, rec, d, base, dict(d['limits']), tid)
    row['ui'] = {'group': 'enemies', 'mt_codes': [], 'short_label': 'Max enemies at once (hard cap)', 'label_source': 'id',
                 'scope_text': base['label'], 'aliases': ['enemy count', 'hard cap', 'enemies at once'], 'lane': 'addon',
                 'applies': 'next_mission', 'type': 'int', 'editor': 'INPUTCOUNT', 'unit': '', 'min': 1, 'max': 1000,
                 'rank': 100000}
    return row


def main():
    reg = json.loads(REGISTRY.read_text(encoding='utf-8'))
    if reg['build'] != BUILD:
        raise SystemExit(f'registry build {reg["build"]} is not {BUILD}')
    ids = {r['tunable_id'] for r in reg['tunables']}
    rows = survival_rows(reg, ids) + [hard_cap_row(reg, ids)]
    reg['tunables'] += rows
    REGISTRY.write_bytes((json.dumps(reg, indent=2, ensure_ascii=False) + '\n').encode('utf-8'))
    print('added:', ', '.join(r['tunable_id'] for r in rows))


if __name__ == '__main__':
    main()
