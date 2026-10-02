"""Contract R10 (2026-09-30): registry rows admitted from the mission-owner research.

Input: RESEARCH/MISSION_OWNERS_R10_2026-09-30/inputs/row_drafts.json, a copy of
work/research/mission-owners-2026-09-30/row_drafts.json (65 verified drafts, 8 rejected; the research file has CRLF line
ends, SHA-256 8b94d678...12e8a4dd; the copy is LF). The pin below is the SHA-256 of the content with LF line ends, so any
checkout verifies whatever its line-end setting. The drafts are proposals: nothing
is copied into the registry on trust. register_registry.py calls rows() and every row is re-derived from the pinned 44.0.2
stock bytes here:

  * EXACT_LITERAL: every LOADN site is re-read (offset, raw U44 LOADN byte, register, immediate = stock x num / den);
    every number constant is re-read (value, constant offset, native tag) and its K_CONSTANT_EXCLUSIVE_V1 use set is
    recomputed with anchors.Analysis.exclusive_constant.
  * TARGET_ADDON ROOT_TABLE_FIELD (Void Armageddon): the field or array element is re-proven with the registrar's own
    ROOT_TABLE_UPVALUE_V1 gate (addon_owner.RootTables, flow-sensitive consumer since R10) and registered through the
    same addon_field() path as every other root-table row; the hook plan is computed by hook_plan.py afterwards.
  * TARGET_ADDON MISSION_INFO_FIELD_AT_ENTRY / SCRIPT_PARAM_GLOBAL_AT_ENTRY (gate CAPTURE_GRAPH_ENTRY_V1): every entry
    prototype must be created exactly once, by the module root (a direct root child: retire-safe under contract R3),
    and every recorded reader must match a bytecode census of the key (a string-keyed field for MissionInfo, the U44
    native-name hash for a script-parameter global). A parameter global's hash is recomputed from its name.
  * METADATA_PATCH: the preimage line is found inside the named script struct of the composed type text captured
    read-only from the installed 44.0.2 Packages.bin (inputs/*.inspect-type.txt), and the consumer module must reference
    the parameter's hashed global.

Ids: drafts whose family already exists in the registry use it (Mirror Defense = loopdefend, Legacyte Harvest =
infested_capture, All missions = gamerules); the Sabotage variants share the family `sabotage`. ID_MAP lists every rename.
EXCLUDED lists the drafts that are not admitted, with the reason. Nothing here reads or writes a game or server folder.
"""
from pathlib import Path
import hashlib, json, re, struct

HERE = Path(__file__).resolve().parent
EDITOR = HERE.parents[2]
R10 = EDITOR / 'RESEARCH/MISSION_OWNERS_R10_2026-09-30'
DRAFTS = R10 / 'inputs/row_drafts.json'
DRAFTS_SHA256 = '5C5470E04DAAE7BB4D505B9346867D5915613F194E18D5A80AF7B96AE0D33531'  # LF-normalized content
METADATA_INPUTS = {'/Lotus/Types/LevelObjects/ExtractionTrigger': R10 / 'inputs/ExtractionTrigger.inspect-type.txt',
                   '/Lotus/Types/PickUps/DuviriArenaBoonPickup': R10 / 'inputs/DuviriArenaBoonPickup.inspect-type.txt'}
PROVENANCE = 'research:mission-owners-2026-09-30 (contract R10)'
# Contract R11 (2026-09-30): Railjack kill goals (research work/research/railjack-kills-2026-09-30). Same admission path; the
# drafts are pinned by their LF content like the R10 drafts.
R11 = EDITOR / 'RESEARCH/MISSIONS_R11_RAILJACK_OROKIN_2026-09-30'
R11_DRAFTS = R11 / 'inputs/r11_row_drafts.json'
R11_DRAFTS_SHA256 = 'B60EDD6E051D2A51D9AB6C95EB16BDD528A4E32B681A0C44AC64D47089A18544'  # LF-normalized content
R11_PROVENANCE = 'research:railjack-kills-2026-09-30 (contract R11)'
# Contract R12 (2026-10-01): Defense waves per reward, the trigger parameter `_minWavesToComplete` read as the hashed global
# minWavesToComplete by WaveDefend (research record RESEARCH/MISSIONS_R12_DEFENSE_REWARD_2026-10-01). Same admission path.
R12 = EDITOR / 'RESEARCH/MISSIONS_R12_DEFENSE_REWARD_2026-10-01'
R12_DRAFTS = R12 / 'inputs/r12_row_drafts.json'
R12_DRAFTS_SHA256 = 'B6410C68BBC946019DE2C863F6AEADC9DD69C43133E73203EEA0C57F055EF4C4'  # LF-normalized content
R12_PROVENANCE = 'research:defense-reward-interval-2026-10-01 (contract R12)'
# Contract R14 (2026-10-01): Void Flood tank multipliers (fill speed, capacity, orb value, drain). Scaled ROOT_TABLE_FIELD
# rows: the row value is a multiplier (stock 1); every field keeps its own stock and is proven against it. Record
# RESEARCH/MISSIONS_R14_VOID_FLOOD_TANKS_2026-10-01. Same admission path; drafts pinned by their LF content.
R14 = EDITOR / 'RESEARCH/MISSIONS_R14_VOID_FLOOD_TANKS_2026-10-01'
R14_DRAFTS = R14 / 'inputs/r14_row_drafts.json'
R14_DRAFTS_SHA256 = 'CF23C919BFD7D6E8D8A364B742BA832722ABA81028F6E8B9C8AE367CF5C4E6E3'  # LF-normalized content
R14_PROVENANCE = 'research:void-flood-tanks-2026-10-01 (contract R14)'
# Contract R15 (2026-10-01): live follow-up of R12/R13. The entry-time environment write of defense.waves_per_reward ran
# live but did not reach the checkpoint reader: the WaveDefense instance environment is written natively by the engine's
# script-parameter applier (record RESEARCH/MISSIONS_R15_DEFENSE_READER_PIN_2026-10-01). R15 drafts supersede R12 drafts
# with the same id; the row pins the four readers (IMPORT_READ_PIN_V1) through the existing live-literal lane.
R15 = EDITOR / 'RESEARCH/MISSIONS_R15_DEFENSE_READER_PIN_2026-10-01'
R15_DRAFTS = R15 / 'inputs/r15_row_drafts.json'
R15_DRAFTS_SHA256 = '56C3990CF62BC3A0FC81071A6585A759324FD2BEBDB0003460C61C677A3F8D99'  # LF-normalized content
R15_PROVENANCE = 'research:defense-reward-interval-2026-10-01 (contract R15)'
# Contract R16 (2026-10-01): ENGINE_PARAM_OVERRIDE. The SCRIPT_PARAM_GLOBAL_AT_ENTRY rows whose readers run after a yield of
# the same instance (EXPOSED in the R15 classification) are also owned natively: the bootstrapper's ENGINE_PARAM_OVERRIDE
# hook adjusts the value inside the engine's own parameter writer (44.0.2 push_value 0x191A010, called by apply_param
# 0x181CAE0) on every write. The registrar records the admission on the row owner (`engine_override`); the generator
# emits Packages/Missions/engine_params.json for it. The R10 entry write stays in the addon as the fallback (older DLLs).
# Record RESEARCH/MISSIONS_R16_ENGINE_PARAM_OVERRIDE_2026-10-01. Input pinned by its LF content.
R16 = EDITOR / 'RESEARCH/MISSIONS_R16_ENGINE_PARAM_OVERRIDE_2026-10-01'
R16_OVERRIDES = R16 / 'inputs/r16_engine_overrides.json'
R16_OVERRIDES_SHA256 = 'EF03BA27AE9D3B2B964BF1D9DD2F00FF74FF9D7E4B942220075B8AB59BDFEB14'  # LF-normalized content
ENGINE_OVERRIDE_GATE = 'ENGINE_PARAM_OVERRIDE_V1'
# Contract R17 (2026-10-01): the four R10 entry rows R15 did not classify, by the R15 method (does every reader run before
# the engine can write the parameter again?). Deepmines hold time and bonus threshold: EXPOSED, pinned like R15 (their
# drafts supersede the R10 drafts). Gas City: the R10 row wrote hackTime, which the script itself recomputes from modeTimer
# before its first reader (WRONG OWNER); the R10 draft is excluded and a scaled row over both parameters, owned at the
# engine writer (R16 gate), replaces it. Sabotage surprise extraction: REACHES (read in the entry call before any yield),
# unchanged. Record RESEARCH/MISSIONS_R17_TYPE_MASTERS_2026-10-01; inputs pinned by their LF content.
R17 = EDITOR / 'RESEARCH/MISSIONS_R17_TYPE_MASTERS_2026-10-01'
R17_DRAFTS = R17 / 'inputs/r17_row_drafts.json'
R17_DRAFTS_SHA256 = '653D94A864D7A32CE43AAA48A97F3377EC40BB06E9DFCDF8177AD956B7B7BFD3'  # LF-normalized content
R17_PROVENANCE = 'research:mission-settings-r17-2026-10-01 (contract R17)'
R17_OVERRIDES = R17 / 'inputs/r17_engine_overrides.json'
R17_OVERRIDES_SHA256 = '4110FEA49865FE313122C8CE0F834AC1F4F69A61677D3BBB726F342A8E276CB4'  # LF-normalized content
# Contract R18 (2026-10-02, mission coverage audit): the Jade Shadows "Pontis tower" Railjack missions (The Kuva Wytch, Scoria's
# Angel) count their stage-1 space-enemy goal in their own modules (AS1Space / GS1Space, parameter spaceEnemyCountPerVariant from
# H.AnimRetarget encounters), which no Railjack row reached. Two SCRIPT_PARAM_GLOBAL_AT_ENTRY rows (scale_count), EXPOSED
# (the reader waits in a Sleep(0) loop first), so also owned at the engine writer (R16 gate). Record
# RESEARCH/MISSIONS_R18_COVERAGE_AUDIT_2026-10-02; research work/research/mission-coverage-audit-2026-10-02; inputs pinned by
# their LF content.
R18 = EDITOR / 'RESEARCH/MISSIONS_R18_COVERAGE_AUDIT_2026-10-02'
R18_DRAFTS = R18 / 'inputs/r18_row_drafts.json'
R18_DRAFTS_SHA256 = '7CF89970AF76936B735306B13BB1EA028A97F574444EEB0230BC897D960BC7E8'  # LF-normalized content
R18_PROVENANCE = 'research:mission-coverage-audit-2026-10-02 (contract R18)'
R18_OVERRIDES = R18 / 'inputs/r18_engine_overrides.json'
R18_OVERRIDES_SHA256 = '6BE472F4DA39F41A2DE09446E1B96E1FAC261D0132D1A547D1695E7BDE8BE773'  # LF-normalized content
# Contract R19 (2026-10-02, live Railjack report): the Grineer Railjack fighter and crewship goals (KillFighters /
# KillCrewShips encounter parameters) were classed REACHES by R15, but the live session pid 7128 logged the entry write and
# the objective still used the stock goal. Both rows are owned at the engine writer (R16 gate) like the other Railjack rows;
# the entry write stays the fallback for a DLL without the hook. Record RESEARCH/MISSIONS_R19_RAILJACK_ENGINE_OWNER_2026-10-02;
# input pinned by its LF content.
R19 = EDITOR / 'RESEARCH/MISSIONS_R19_RAILJACK_ENGINE_OWNER_2026-10-02'
R19_OVERRIDES = R19 / 'inputs/r19_engine_overrides.json'
R19_OVERRIDES_SHA256 = 'AD86E8EC77FDB11BAF4033436E72961C26170BC65D1717A1765A418E12580A38'  # LF-normalized content
# Contract R21 (2026-10-02, class audit after R19): the last two rows on the plain R10 entry write (Spy vault alarm, Sabotage
# surprise extraction) are level ScriptTrigger parameters whose only producer is the engine's parameter writer; their REACHES
# class is the one R19 refuted live. Both are owned at the writer (R16 gate); the entry write stays the fallback for a DLL
# without the hook. Record RESEARCH/MISSIONS_R21_PARAM_LANE_AUDIT_2026-10-02; input pinned by its LF content.
R21 = EDITOR / 'RESEARCH/MISSIONS_R21_PARAM_LANE_AUDIT_2026-10-02'
R21_OVERRIDES = R21 / 'inputs/r21_engine_overrides.json'
R21_OVERRIDES_SHA256 = '91518C83D34A8E311C2A9EE349DA7F19454C1814B820E403589C0CD680517F90'  # LF-normalized content
# Contract R22 (2026-10-02, Void Cascade exolizer progress): the normal Void Cascade reward interval REWARD_INTERVAL (4
# exolizers per reward). Phase 1 left it PARTIAL because the root copies the table field into a root local at module load
# (the addon root-table lane cannot reach that read); its only reader is that copy, so the live-literal lane owns the
# initialiser (EXACT_LITERAL, one LOADN site). Record RESEARCH/MISSIONS_R22_EXOLIZER_PROGRESS_2026-10-02; research
# work/research/void-cascade-exolizer-progress-2026-10-02; drafts pinned by their LF content.
R22 = EDITOR / 'RESEARCH/MISSIONS_R22_EXOLIZER_PROGRESS_2026-10-02'
R22_DRAFTS = R22 / 'inputs/r22_row_drafts.json'
R22_DRAFTS_SHA256 = '936F0EDD3137B48C9DE1CBEABD8E33815C8ACB20B56B16434E82028286A2D1C1'  # LF-normalized content
R22_PROVENANCE = 'research:void-cascade-exolizer-progress-2026-10-02 (contract R22)'
# R15 IMPORT_READ_PIN_V1: a single-name GETIMPORT of a hashed global (U44 dispatch byte 0x35, canonical 0x46) is rewritten
# into `LOADN A, value` twice (the instruction word and its aux word), through two LIVE_LITERALS_V1 instruction sites flagged
# `rewrites_instruction`. Admissible only when every instruction of the module that names the hash is one of the pinned
# reads (no SETGLOBAL/GETGLOBAL/field use left), so the decision input never comes from the environment.
RAW_GETIMPORT = 0x35
IMPORT_PIN_GATE = 'IMPORT_READ_PIN_V1'
# R14: a ROOT_TABLE_FIELD row with `mode` writes (field stock x row value) into every field; `scale_count` rounds each
# result and keeps it at least 1 (the R11 count rule applied to root-table fields). Without `mode` the row value is
# written as is (every row before R14).
ROOT_FIELD_MODES = ('scale', 'scale_count')
# R14: Phase 1 rows the R14 rows cover only in part; the remaining parts stay unregistered with this reason.
EXCLUDED_PARTS = [
    {'phase1': 'void_flood.deposit_and_drain',
     'part': 'depositRadius, drainInterval, numForFullVoidIntensity, spawnDelay, xpAmount, xpDivisor, xpMultCap',
     'reason': 'R14: owner proven (ROOT_TABLE_UPVALUE_V1 PASS on root:i25:R3) but not admitted: not a tank-fill setting the '
               'player asked for; deposit rate and drain amount are registered as void_flood.deposit_speed_scale and '
               'void_flood.drain_speed_scale'},
    {'phase1': 'void_flood.pickup_amounts',
     'part': 'SgBaseAmt, SgLargeAmt, SgMediumAmt, SgSmallAmt, groupSpawnInterval, groupSpawnPerInterval, groupSpawnRange, '
             'largeRespawnTime, lowEnemyRate, highEnemyRate, lowEnemyScale, highEnemyScale',
     'reason': 'R14: not admitted (Shadowgrapher amounts and orb/enemy spawning, not orb value in normal Void Flood); '
               'smallAmt, mediumAmt and largeAmt are registered as void_flood.orb_value_scale'},
]
ENTRY_GATE = 'CAPTURE_GRAPH_ENTRY_V1'
MISSION_INFO = 'MISSION_INFO_FIELD_AT_ENTRY'
SCRIPT_PARAM = 'SCRIPT_PARAM_GLOBAL_AT_ENTRY'
ENTRY_TEMPLATES = (MISSION_INFO, SCRIPT_PARAM)
# R11: scale_count = a whole-number count or a plain list of counts, each x value, rounded, at least 1.
PARAM_MODES = ('scale', 'scale_inverse', 'absolute', 'scale_count')
SCALE_MODES = ('scale', 'scale_inverse', 'scale_count')
RAW_LOADN = 0x08
GETTABLEKS, SETTABLEKS, GETGLOBAL, SETGLOBAL, NAMECALL, GETIMPORT = 0x3d, 0x15, 0x17, 0x02, 0x2d, 0x46

ID_MAP = {
    'legacyte_harvest.required_captures.high_scaling': 'infested_capture.required_captures.high_scaling',
    'legacyte_harvest.required_captures.mutated': 'infested_capture.required_captures.mutated',
    'legacyte_harvest.required_captures.double': 'infested_capture.required_captures.double',
    'legacyte_harvest.required_captures.descendia': 'infested_capture.required_captures.descendia',
    'sabotage_orokin.portal_charge_time': 'sabotage.orokin_charge_time',
    'sabotage_forest.defend_time': 'sabotage.forest_defend_time',
    'gascity.meltdown_scale_easy': 'sabotage.gascity_meltdown_scale.easy',
    'gascity.meltdown_scale_hard': 'sabotage.gascity_meltdown_scale.hard',
    'gascity.hack_time': 'sabotage.gascity_hack_time',
    'extraction.countdown_endless': 'gamerules.extraction_countdown_endless',
    'extraction.countdown': 'gamerules.extraction_countdown',
    'mirror_defense.phases_to_finish': 'loopdefend.phases_to_finish',
    'sabotage_orokin.escape_timer': 'sabotage.orokin_escape_timer',  # R11
}
# R11 (2026-09-30): the Orokin escape timer is admitted. Its coupled site (the host-migration restore threshold 27 = 30 - 3,
# SabotageOrokin prototype 17 instruction 17) uses the `value_offset` site form of the shared live-literal patch core
# (operand = row value + value_offset), so both literals move together and each keeps its own preimage check.
EXCLUDED = {
    # R17 (2026-10-01): wrong owner. SabotageMission (P15) runs P5 in the first slice of its entry call, and P5 SETGLOBALs
    # hackTime = modeTimer x Lerp(1.8, 1.2, difficulty) before any reader (P3 runs at stage 5 or after a host migration),
    # so the entry write of hackTime never reached the countdown. Replaced by sabotage.gascity_meltdown_time_scale (R17
    # drafts: hackTime and modeTimer scaled together, owned at the engine writer).
    'gascity.hack_time': 'R17: wrong owner: the script recomputes hackTime from modeTimer (P5 i105/i112) before its first '
                         'reader, so the entry write never reaches the countdown; replaced by '
                         'sabotage.gascity_meltdown_time_scale',
}
# Registry units the player text and the settings editor know (the drafts used a few informal spellings).
UNIT_MAP = {'lv': 'levels'}
# Names the MissionInfo template calls; recorded with their U44 hashes (seed 768e5ed0) as evidence.
MISSION_INFO_ACCESSOR = ('gGameRules', 'GetMission', 'SetMission', 'gRegion', 'IsMaster', 'IsValid', 'print')
MISSION_INFO_IDENTITY_FIELDS = ('alertId', 'invasionId', 'syndicateTag', 'goalId', 'sortieId', 'nightmare')


def sha256(data):
    return hashlib.sha256(data).hexdigest().upper()


def load_drafts(path=DRAFTS, pinned=DRAFTS_SHA256, label='R10'):
    raw = path.read_bytes().replace(b'\r\n', b'\n')
    if sha256(raw) != pinned:
        raise SystemExit(f'{label} drafts changed: {path} SHA-256 {sha256(raw)} != pinned {pinned}')
    return json.loads(raw.decode('utf-8'))


def num(x):
    return int(x) if float(x).is_integer() else x


def census(m, name, namehash):
    """{prototype: [instruction, ...]} of every string-keyed or hashed use of `name` (GETTABLEKS, SETTABLEKS, GETGLOBAL,
    SETGLOBAL, NAMECALL aux constants and single-name GETIMPORT)."""
    h = namehash(name)
    out = {}
    for p, (ins, consts) in enumerate(m.protos):
        for i, (_, w) in enumerate(ins):
            hit = m.key_string(p, w) == name
            if not hit and len(w) == 8 and w[0] in (GETGLOBAL, SETGLOBAL, GETTABLEKS, SETTABLEKS, NAMECALL):
                k = struct.unpack_from('<I', w, 4)[0]
                c = consts[k] if k < len(consts) else None
                hit = bool(c) and c[0] == 1 and struct.unpack('<I', c[1][:4])[0] == h
            if not hit and len(w) == 8 and w[0] == GETIMPORT:
                aux = struct.unpack_from('<I', w, 4)[0]
                if aux >> 30 == 1:
                    c = consts[(aux >> 20) & 1023]
                    hit = c[0] == 1 and struct.unpack('<I', c[1][:4])[0] == h
            if hit:
                out.setdefault(p, []).append(i)
    return out


def hashed_only(m, name, namehash, prototype, instructions):
    """True when every listed use is a hashed (tag-1) key, never the string."""
    ins, consts = m.protos[prototype]
    for i in instructions:
        if m.key_string(prototype, ins[i][1]) == name:
            return False
    return True


def root_child(m, prototype):
    """Closure-map evidence that `prototype` is created exactly once, by the module root."""
    sites = [s for s in m.sites if s[2] == prototype]
    if len(sites) != 1:
        raise ValueError(f'entry prototype {prototype} is created {len(sites)} times; it is not one root function')
    parent, instruction, _, _ = sites[0]
    if parent != m.root:
        raise ValueError(f'entry prototype {prototype} is created by prototype {parent}, not by the module root {m.root}')
    return {'prototype': prototype, 'created_by': 'root', 'closure_instruction': instruction, 'root_child': True}


def literal_site(m, site, stock, where):
    p, off = site['prototype'], site['offset']
    num_, den = site.get('numerator', 1), site.get('denominator', 1)
    # R11 coupled site: the operand is (row value + value_offset) x numerator / denominator (shared patch core).
    offset = site.get('value_offset', 0)
    if not isinstance(offset, (int, float)) or offset != offset:
        raise ValueError(f'{where}: invalid value_offset {offset!r}')
    want = (stock + offset) * num_ / den
    if site['kind'] == 'instruction':
        i = site['instruction']
        off_i, w = m.protos[p][0][i]
        if off_i != off:
            raise ValueError(f'{where}: instruction {p}:{i} is at offset {off_i}, not {off}')
        got = list(m.raw[off:off + 4])
        if got != site['expected'] or m.raw[off] != RAW_LOADN:
            raise ValueError(f'{where}: preimage at {off} is {got}, not the drafted LOADN {site["expected"]}')
        imm = struct.unpack_from('<h', m.raw, off + 2)[0]
        if imm != want:
            raise ValueError(f'{where}: LOADN immediate {imm} != stock-derived {want}')
        out = {'kind': 'instruction', 'prototype': p, 'instruction': i, 'offset': off, 'expected': got,
               'register': m.raw[off + 1], 'numerator': num_, 'denominator': den, 'owner': site.get('owner', '')}
        if offset:
            out['value_offset'] = offset
        return out
    if site['kind'] != 'number_constant':
        raise ValueError(f'{where}: unknown site kind {site["kind"]}')
    k = site['constant']
    if m.number(p, k) != want:
        raise ValueError(f'{where}: constant {p}:{k} is {m.number(p, k)}, not {want}')
    if m.constant_offset(p, k) != off:
        raise ValueError(f'{where}: constant {p}:{k} is at {m.constant_offset(p, k)}, not {off}')
    declared = [u['instruction'] for u in site['gate']['uses']]
    gate = m.exclusive_constant(p, k, declared)
    out = {'kind': 'number_constant', 'prototype': p, 'constant': k, 'offset': off, 'expected': list(m.raw[off:off + 8]),
           'numerator': num_, 'denominator': den, 'owner': site.get('owner', ''), 'gate': gate}
    if offset:
        out['value_offset'] = offset
    return out


def import_pin_sites(m, site, namehash, where):
    """R15 IMPORT_READ_PIN_V1: the two LIVE_LITERALS_V1 instruction sites that rewrite one single-name GETIMPORT of a
    hashed global into `LOADN A, value` (instruction word, then its aux word). Every check is made on the pinned stock
    bytes: raw U44 dispatch byte, canonical GETIMPORT, aux count 1, aux id0 -> tag-1 hashed name == namehash(global),
    an aux word that is not itself a LOADN preimage (the shared core would then demand its register)."""
    p, i, name = site['prototype'], site['instruction'], site['global']
    h = namehash(name)
    if f'{h:08x}' != site['hash']:
        raise ValueError(f'{where}: hash of {name} is {h:08x}, drafted {site["hash"]}')
    off, w = m.protos[p][0][i]
    raw = m.raw[off:off + 8]
    if len(w) != 8 or w[0] != GETIMPORT or raw[0] != RAW_GETIMPORT:
        raise ValueError(f'{where}: {p}:{i} at {off} is not a U44 GETIMPORT ({raw.hex()})')
    reg = w[1]
    aux = struct.unpack_from('<I', w, 4)[0]
    if aux >> 30 != 1:
        raise ValueError(f'{where}: {p}:{i} imports a {aux >> 30}-level path; only a single global name can be pinned')
    consts = m.protos[p][1]
    k = (aux >> 20) & 1023
    c = consts[k] if k < len(consts) else None
    if not c or c[0] != 1 or struct.unpack('<I', c[1][:4])[0] != h:
        raise ValueError(f'{where}: {p}:{i} aux id0 constant {k} is not the hashed name {name} ({h:08x})')
    if raw[4] == RAW_LOADN:
        raise ValueError(f'{where}: {p}:{i} aux word starts with the LOADN byte; the shared core would read it as a LOADN preimage')
    common = {'kind': 'instruction', 'prototype': p, 'register': reg, 'rewrites_instruction': True,
              'numerator': 1, 'denominator': 1, 'gate': IMPORT_PIN_GATE, 'global': name, 'hash': site['hash']}
    return [dict(common, instruction=i, offset=off, expected=list(raw[:4]),
                 owner=site['owner'] + ' (instruction word)'),
            dict(common, instruction=i, aux_of=i, offset=off + 4, expected=list(raw[4:8]),
                 owner=site['owner'] + ' (aux word)')]


def import_pin_complete(m, sites, namehash, where):
    """IMPORT_READ_PIN_V1 completeness: for every pinned global, the census of the hash in the whole module (reads and
    writes, hashed and string keys) is exactly the pinned GETIMPORT set."""
    pinned = {}
    for s in sites:
        if s.get('gate') == IMPORT_PIN_GATE and 'aux_of' not in s:
            pinned.setdefault(s['global'], {}).setdefault(s['prototype'], []).append(s['instruction'])
    for name, want in pinned.items():
        got = census(m, name, namehash)
        want = {p: sorted(v) for p, v in want.items()}
        if {p: sorted(v) for p, v in got.items()} != want:
            raise ValueError(f'{where}: census of {name} is {got}; the pin covers {want} (every use must be a pinned read)')
    return {name: {str(p): v for p, v in sorted(w.items())} for name, w in pinned.items()}


def composed_blocks(text):
    """{struct name: [lines]} of the top-level `Name={ ... }` blocks of an inspect-type composed dump."""
    body = text.split('[inspect-type] composed metadata:\n', 1)[1]
    blocks, current, depth = {}, None, 0
    for line in body.splitlines():
        if current is None:
            m = re.fullmatch(r'([A-Za-z_][A-Za-z0-9_]*)=\{', line)
            if m:
                current, depth = m.group(1), 1
                blocks[current] = []
            continue
        depth += line.count('{') - line.count('}')
        if depth <= 0:
            current = None
            continue
        if depth == 1:
            blocks[current].append(line)
    return body, blocks


def rows(ctx):
    """Returns (rows, excluded, report). `ctx` supplies the registrar's own helpers: module(file) -> RootTables,
    register_module(file, module_path) -> (key, rec), addon_field(m, key, ev), addon_owner(m, key, rec, fields),
    namehash(name), snapshot (dict, updated in place) and packages_sha."""
    drafts = load_drafts()
    r11 = load_drafts(R11_DRAFTS, R11_DRAFTS_SHA256, 'R11')
    r12 = load_drafts(R12_DRAFTS, R12_DRAFTS_SHA256, 'R12')
    r14 = load_drafts(R14_DRAFTS, R14_DRAFTS_SHA256, 'R14')
    r15 = load_drafts(R15_DRAFTS, R15_DRAFTS_SHA256, 'R15')
    r17 = load_drafts(R17_DRAFTS, R17_DRAFTS_SHA256, 'R17')
    r18 = load_drafts(R18_DRAFTS, R18_DRAFTS_SHA256, 'R18')
    r22 = load_drafts(R22_DRAFTS, R22_DRAFTS_SHA256, 'R22')
    out, excluded = [], []
    report = {'drafts': len(drafts['rows']), 'drafts_rejected_by_research': len(drafts['rejected']), 'admitted': 0,
              'excluded': [], 'renamed': {}, 'by_backend': {}, 'by_template': {}, 'r11_drafts': len(r11['rows']),
              'r12_drafts': len(r12['rows']), 'r14_drafts': len(r14['rows']), 'r15_drafts': len(r15['rows']),
              'r17_drafts': len(r17['rows']), 'r18_drafts': len(r18['rows']), 'r22_drafts': len(r22['rows']),
              'superseded': dict(r15['supersedes'], **r17['supersedes'], **r18['supersedes'], **r22['supersedes']),
              'import_pins': {}}
    # R15/R17: a later draft with the same id replaces the earlier one (the reason is recorded in the report). A later set
    # may also add new ids (R17: the Gas City row); each reason must name one of its own drafts and an earlier draft.
    earlier = [d for d in (drafts['rows'] + [dict(x, _provenance=R11_PROVENANCE) for x in r11['rows']]
                           + [dict(x, _provenance=R12_PROVENANCE) for x in r12['rows']]
                           + [dict(x, _provenance=R14_PROVENANCE) for x in r14['rows']])]
    for label, later, provenance in (('R15', r15, R15_PROVENANCE), ('R17', r17, R17_PROVENANCE), ('R18', r18, R18_PROVENANCE),
                                     ('R22', r22, R22_PROVENANCE)):
        superseded = set(later['supersedes'])
        own = {x['tunable_id'] for x in later['rows']}
        if label == 'R15' and superseded != own:
            raise ValueError('R15: every superseding draft needs a reason and every reason a draft')
        if not superseded <= own:
            raise ValueError(f'{label}: a supersede reason names no draft of its own set')
        if not superseded <= {d['tunable_id'] for d in earlier}:
            raise ValueError(f'{label}: a superseding draft names no earlier draft')
        if (own - superseded) & {d['tunable_id'] for d in earlier}:
            raise ValueError(f'{label}: a draft repeats an earlier id without a supersede reason')
        earlier = [d for d in earlier if d['tunable_id'] not in superseded] + [dict(x, _provenance=provenance)
                                                                             for x in later['rows']]
    for d in earlier:
        old = d['tunable_id']
        if old in EXCLUDED:
            excluded.append({'tunable_id': old, 'owner_kind': d['owner_kind'], 'confidence': d['confidence'],
                             'reason': 'R10: ' + EXCLUDED[old]})
            report['excluded'].append(old)
            continue
        tid = ID_MAP.get(old, old)
        if tid != old:
            report['renamed'][old] = tid
        o = d['owner']
        where = f'{tid} (draft {old})' if tid != old else tid
        # R14: a draft may cover a Phase 1 row (its Phase 1 exclusion is then resolved; uncovered parts: EXCLUDED_PARTS).
        base = {'tunable_id': tid, 'phase1_tunable_id': d.get('phase1_tunable_id'), 'label': d['label'], 'mission_type': d['mission_type'],
                'variant': d['variant'], 'shared_with': d.get('shared_with', ''), 'owner_kind': d['owner_kind'],
                'backend': d['backend'], 'unit': UNIT_MAP.get(d['unit'], d['unit']), 'stock': num(d['stock']),
                'confidence': d['confidence'], 'provenance': d.get('_provenance', PROVENANCE),
                'evidence': d.get('evidence', ''), 'research_draft_id': old}
        lim = dict(d['limits'])
        if d['backend'] == 'METADATA_PATCH':
            row = metadata_row(ctx, d, base, lim, where)
        else:
            m = ctx.module(o['file'])
            key, rec = ctx.register_module(o['file'], o['module_path'])
            if key != o['body_key'] or rec['sha256'] != o['stock_sha256']:
                raise ValueError(f'{where}: stock identity {key}/{rec["sha256"][:16]} != drafted {o["body_key"]}/{o["stock_sha256"][:16]}')
            if d['backend'] == 'EXACT_LITERAL':
                sites = []
                for s in o['sites']:
                    if s['kind'] == 'import_pin':
                        sites += import_pin_sites(m, s, ctx.namehash, where)
                    else:
                        sites.append(literal_site(m, s, d['stock'], where))
                if any(s.get('gate') == IMPORT_PIN_GATE for s in sites):
                    report['import_pins'][tid] = import_pin_complete(m, sites, ctx.namehash, where)
                if any(s['kind'] == 'instruction' for s in sites):
                    # A LOADN immediate holds a whole number in 1..32767 (shared live-literal patch core domain).
                    lim['minimum'] = max(1, lim['minimum'])
                    lim['maximum'] = min(32767, lim['maximum'])
                    lim['integer'] = True
                row = dict(base, owner={'body_key': key, 'stock_sha256': rec['sha256'], 'file': rec['file'],
                                        'module_path': rec['module_path'], 'sites': sites},
                           limits=lim, applies='next_mission',
                           backend_note=f'{len(sites)} exact site(s) patched together: ' + '; '.join(s['owner'] for s in sites))
            elif o.get('template') == 'ROOT_TABLE_FIELD':
                mode = o.get('mode')
                if mode is not None:
                    # R14: a scaled row is a multiplier; each field is proven against its own stock and keeps it.
                    if mode not in ROOT_FIELD_MODES:
                        raise ValueError(f'{where}: unknown root-table field mode {mode!r}')
                    if d['stock'] != 1 or lim['minimum'] < 0 or lim.get('integer'):
                        raise ValueError(f'{where}: a scaled root-table row needs stock 1, a minimum >= 0 and a fractional value')
                fields = []
                for f in o['fields']:
                    stock = float(f['stock'] if mode is not None else d['stock'])
                    if mode is None and 'stock' in f:
                        raise ValueError(f'{where}: a field stock is allowed only on a scaled row')
                    if mode == 'scale_count' and (stock < 1 or not stock.is_integer()):
                        raise ValueError(f'{where}: a scale_count field must hold a whole number >= 1 (field {f["field"]!r})')
                    if isinstance(f['field'], int):
                        ins = m.protos[m.root][0]
                        if 'value_instruction' in f:  # R14: the element's root LOADN/LOADK instruction index
                            vi = [f['value_instruction']] if 0 <= f['value_instruction'] < len(ins) else []
                        else:
                            vi = [i for i, (off, _) in enumerate(ins) if off == f['value_offset']]
                        if len(vi) != 1:
                            raise ValueError(f'{where}: no root instruction for array element {f["field"]}')
                        ev = m.element_owner(vi[0], stock)
                        if ev['field'] != f['field']:
                            raise ValueError(f'{where}: instruction {vi[0]} fills element {ev["field"]}, drafted {f["field"]}')
                    else:
                        table_instruction = int(f['table_id'].split(':')[1][1:])
                        ev = m.owner(f['field'], stock, table_instruction)
                    if ev['table_id'] != f['table_id']:
                        raise ValueError(f'{where}: field proves on {ev["table_id"]}, drafted {f["table_id"]}')
                    entry = ctx.addon_field(m, key, ev)
                    if mode is not None:
                        entry['stock'] = num(stock)
                    fields.append(entry)
                owner = ctx.addon_owner(m, key, rec, fields)
                if mode is not None:
                    owner['mode'] = mode
                row = dict(base, owner=owner, limits=lim, applies='F9',
                           backend_note='Root-table field(s) ' + ', '.join(f'{x["table_id"]}.{x["field"]}' for x in fields) +
                                        ' written through the target-addon lane (ROOT_TABLE_UPVALUE_V1)' +
                                        (f'; mode {mode}: each field = its stock x the row value' +
                                         (', rounded, at least 1' if mode == 'scale_count' else '') if mode else '') + '.')
            elif o.get('template') in ENTRY_TEMPLATES:
                row = entry_row(ctx, m, key, rec, d, base, lim, where)
            else:
                raise ValueError(f'{where}: unsupported draft owner {o.get("template")}')
        out.append(row)
        report['admitted'] += 1
        report['by_backend'][row['backend']] = report['by_backend'].get(row['backend'], 0) + 1
        template = row['owner'].get('template', row['backend'])
        report['by_template'][template] = report['by_template'].get(template, 0) + 1
    engine_overrides(out, report)
    return out, excluded, report


def engine_overrides(out, report):
    """R16: marks the admitted EXPOSED script-parameter rows as natively owned (ENGINE_PARAM_OVERRIDE_V1)."""
    specs = [load_drafts(R16_OVERRIDES, R16_OVERRIDES_SHA256, 'R16'),
             load_drafts(R17_OVERRIDES, R17_OVERRIDES_SHA256, 'R17'),  # R17: same gate, one more row
             load_drafts(R18_OVERRIDES, R18_OVERRIDES_SHA256, 'R18'),  # R18: the two Pontis tower rows
             load_drafts(R19_OVERRIDES, R19_OVERRIDES_SHA256, 'R19'),  # R19: Grineer fighter and crewship goals (live-refuted entry route)
             load_drafts(R21_OVERRIDES, R21_OVERRIDES_SHA256, 'R21')]  # R21: Spy vault alarm, Sabotage surprise extraction (R19 class)
    if any(spec.get('gate') != ENGINE_OVERRIDE_GATE for spec in specs):
        raise ValueError('R16: engine override input names another gate')
    by_id = {r['tunable_id']: r for r in out}
    report['engine_overrides'] = {}
    for item in [item for spec in specs for item in spec['rows']]:
        tid = item['tunable_id']
        row = by_id.get(tid)
        if row is None:
            raise ValueError(f'R16: {tid} is not an admitted row')
        if tid in report['engine_overrides']:
            raise ValueError(f'R16: {tid} is admitted twice')
        owner = row['owner']
        if row['backend'] != 'TARGET_ADDON' or owner.get('template') != SCRIPT_PARAM:
            raise ValueError(f'R16: {tid} is not a SCRIPT_PARAM_GLOBAL_AT_ENTRY row')
        if not item.get('exposure', '').startswith('EXPOSED') or not item.get('evidence'):
            raise ValueError(f'R16: {tid} carries no EXPOSED classification with evidence')
        owner['engine_override'] = {'gate': ENGINE_OVERRIDE_GATE, 'exposure': item['exposure'], 'evidence': item['evidence'],
                                    'parameters': [{'name': g['name'], 'hash': g['hash']} for g in owner['globals']],
                                    'mode': owner['mode']}
        report['engine_overrides'][tid] = [g['name'] for g in owner['globals']]


def entry_row(ctx, m, key, rec, d, base, lim, where):
    o = d['owner']
    template = o['template']
    entries = [dict(root_child(m, e['prototype']), function=e.get('function', ''), role=e.get('role', ''))
               for e in o['entries']]
    readers = []
    for r in o['readers']:
        got = census(m, r['key'], ctx.namehash).get(r['prototype'])
        if got != r['instructions']:
            raise ValueError(f'{where}: census of {r["key"]} in prototype {r["prototype"]} is {got}, drafted {r["instructions"]}')
        readers.append({'key': r['key'], 'prototype': r['prototype'], 'instructions': got})
    owner = {'body_key': key, 'stock_sha256': rec['sha256'], 'file': rec['file'], 'module_path': rec['module_path'],
             'template': template, 'gate': ENTRY_GATE, 'entries': entries, 'readers': readers,
             'dead_readers': o.get('dead_readers', [])}
    if template == MISSION_INFO:
        field = o['field']
        if not re.fullmatch(r'[A-Za-z_][A-Za-z0-9_]*', field):
            raise ValueError(f'{where}: invalid MissionInfo field {field!r}')
        for r in readers:
            ins = m.protos[r['prototype']][0]
            if any(m.key_string(r['prototype'], ins[i][1]) != field for i in r['instructions']):
                raise ValueError(f'{where}: a {field} reader is not a string-keyed field read (MissionInfo fields are strings)')
        owner.update(field=field, host_only=True,
                     identity_fields=list(MISSION_INFO_IDENTITY_FIELDS),
                     accessor={n: f'{ctx.namehash(n):08x}' for n in MISSION_INFO_ACCESSOR},
                     write_rule=o['write_rule'], meaning=o.get('meaning', ''),
                     stock_precedent=o['accessor'].get('stock_precedent', ''))
        # The stock value is the MissionInfo default 0 (endless on normal nodes); 0 is also "no write" (the default).
        if d['stock'] != 0:
            raise ValueError(f'{where}: a MissionInfo count row must have stock 0 (normal nodes)')
        lim['minimum'] = 0
        lim['basis'] = '0 = the game default (endless on normal nodes); range from the research draft'
    else:
        mode = o['mode']
        if mode not in PARAM_MODES:
            raise ValueError(f'{where}: unknown parameter mode {mode!r}')
        globals_ = []
        for g in o['globals']:
            h = f'{ctx.namehash(g["name"]):08x}'
            if h != g['hash']:
                raise ValueError(f'{where}: hash of {g["name"]} is {h}, drafted {g["hash"]}')
            if struct.pack('<I', int(h, 16)) not in m.raw:
                raise ValueError(f'{where}: module does not reference the hashed global {g["name"]} ({h})')
            globals_.append({'name': g['name'], 'hash': h})
        names = {g['name'] for g in globals_}
        for r in readers:
            if r['key'] not in names:
                raise ValueError(f'{where}: reader of {r["key"]} is not one of the parameter globals')
            if not hashed_only(m, r['key'], ctx.namehash, r['prototype'], r['instructions']):
                raise ValueError(f'{where}: a {r["key"]} reader is string-keyed; parameter globals are hashed')
        if mode in SCALE_MODES and (d['stock'] != 1 or lim['minimum'] <= 0):
            raise ValueError(f'{where}: a scale row must have stock 1 and a positive minimum')
        owner.update(globals=globals_, mode=mode, observed=o.get('observed', {}), write_rule=o['write_rule'])
    row = dict(base, owner=owner, limits=lim, applies='next_mission',
               backend_note=f'{template}: written at the entry of prototype(s) ' +
                            ', '.join(str(e['prototype']) for e in entries) + ' (gate ' + ENTRY_GATE + ').')
    return row


def metadata_row(ctx, d, base, lim, where):
    o = d['owner']
    type_path, field = o['type'], o['field']
    struct_name, param = field.split('.')
    if not re.fullmatch(r'[A-Za-z]+Script', struct_name) or not re.fullmatch(r'_[A-Za-z0-9_]+', param):
        raise ValueError(f'{where}: metadata field {field!r} is not <Name>Script._parameter')
    text = METADATA_INPUTS[type_path].read_text(encoding='utf-8')
    if f'>{type_path}\n' not in text:
        raise ValueError(f'{where}: captured composed text is not {type_path}')
    body, blocks = composed_blocks(text)
    line = f'{param}={o["stock_text"]}'
    if line != o['preimage'] or line not in blocks.get(struct_name, []):
        raise ValueError(f'{where}: preimage {line!r} is not a line of {struct_name} in the composed {type_path}')
    consumer = o['consumer']
    ckey, crec = ctx.register_module(consumer['file'], consumer['module_path'])
    if ckey != consumer['body_key']:
        raise ValueError(f'{where}: consumer body key {ckey} != drafted {consumer["body_key"]}')
    global_name = param[1:]
    h = ctx.namehash(global_name)
    if struct.pack('<I', h) not in ctx.module(consumer['file']).raw:
        raise ValueError(f'{where}: consumer does not reference the hashed global {global_name}')
    if o['packages_bin_sha256'] != ctx.packages_sha:
        raise ValueError(f'{where}: drafted Packages.bin {o["packages_bin_sha256"][:16]} != registry {ctx.packages_sha[:16]}')
    # Same text form as the Phase 1 snapshot types: the composed dump from its `>/Lotus/...` header line on.
    record = ctx.snapshot.setdefault(type_path, {'text': body.rstrip('\n'), 'fields': {}})
    record['fields'][field] = o['stock_text']
    owner = {'type': type_path, 'field': field, 'stock_text': o['stock_text'], 'preimage': line,
             'packages_bin_sha256': ctx.packages_sha,
             'consumer': {'body_key': ckey, 'stock_sha256': crec['sha256'], 'file': crec['file'],
                          'module_path': crec['module_path'], 'function': consumer.get('function', ''),
                          'global': global_name, 'name_hash': f'{h:08x}', 'readers': consumer.get('readers', [])},
             'source': METADATA_INPUTS[type_path].relative_to(EDITOR).as_posix() +
                       ' (openwf-metadata-updater inspect-type, read-only, installed 44.0.2)'}
    return dict(base, owner=owner, limits=lim, applies='restart')
