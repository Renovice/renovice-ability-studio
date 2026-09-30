"""Phase 2i: in-game settings editor fields for the mission registry (INGAME_EDITOR_DESIGN.md, Phase 1).

Called by register_registry.py after every row is registered. Adds to each row a `ui` object and to the registry the
`ui_groups` table plus `ui_sources` (the pinned inputs). Nothing here reads or writes a game or server folder except the
read-only node exports named in SOURCES.

Row `ui` fields:
  group        tunable_id family (first dotted segment); ui_groups[group] holds the readable mission-type title
  mt_codes     mission-type codes (MT_*) of the group, or of the Phase 1 row when it names its own
  short_label  native-UI-length label (budget: LABEL_BUDGET, composed rows below)
  scope_text   where the value applies (group node coverage + the registry variant), <= SCOPE_MAX
  aliases      search keywords found in the row's label / variant (Steel Path, Sortie, Duviri, ...)
  applies      apply timing derived from the lane: live_next_read (target addon), next_mission (exact replacement),
               restart (metadata patch), server_reload (server config; never part of a script package)
  lane         addon | literal | metadata | server
  type         int | float | enum          (limits.integer; bool/flag units are enums Off/On)
  editor       INPUTCOUNT (int, min >= 0, max set) | INPUTBOX (float or min < 0) | TOGGLE (enum)
  unit         compact display unit used in the composed editor label ("s", "m", "x", "HP", "XP", "min" or "")
  min, max     from limits
  options      enums only: [{label, value}]

Composed labels checked against the budget (design section 4.6 item 3; the bootstrapper bridge renders these forms):
  CHECKBOX   "Custom " + short_label with its first letter lower-cased (proper nouns and acronyms keep their case)
  editor     short_label + " (stock " + <stock><unit> + ")"   (unit "x" is written without a space, others with one)
  TITLE      group label upper-cased <= TITLE_BUDGET; group BUTTON label <= LABEL_BUDGET
"""
from pathlib import Path
import hashlib, json, re

LABEL_BUDGET = 40
TITLE_BUDGET = 48
SCOPE_MAX = 256
# Phase 2k: SCRIPT SETTINGS builds the value tooltip as 'Off: the stock value is used. Stock .. Range .. <scope>. Applies: ..'
# plus the live-stock sentence and cuts it at 300 characters (bootstrapper settings_ui_core.hpp maximum_tooltip). An
# addon row's scope therefore stays within this budget so the sentence is never cut (a longer scope is compacted by
# dropping the parenthetical notes of its case text; the registrar fails if it is still too long).
ADDON_SCOPE_TOOLTIP_MAX = 140
VARIANT_MAX = 120

EXPORT_PUBLIC_REL = 'work/research/U44.0.2-2026-09-29/public-export/ExportRegions_en.json'  # official 44.0.2 export
EXPORT_PLUS_REL = 'node_modules/warframe-public-export-plus'  # under the registry server_root (read-only)

# Readable mission-type title and node coverage per tunable_id family. `nodes` selects star-chart nodes of the current
# public export by mission-type code (missionIndex joined to export-plus missionType), optionally narrowed by export-plus
# mission name, system name or node name. `aliases` are informal search names that no export carries.
GROUPS = {
    'alchemy': {'label': 'Alchemy', 'nodes': {'mt': ['MT_ALCHEMY', 'MT_DESCENT']}, 'aliases': ['Descendia']},
    'arbitration': {'label': 'Arbitration', 'aliases': ['Elite Alert']},
    'archimedea': {'label': 'Deep and Temporal Archimedea',
                   'aliases': ['Archimedea', 'Deep Archimedea', 'Temporal Archimedea', 'EDA', 'ETA']},
    'archwing': {'label': 'Archwing (Balor Fomorian)', 'aliases': ['Fomorian', 'Balor Fomorian']},
    'ascension': {'label': 'Ascension', 'nodes': {'mt': ['MT_ASCENSION']}},
    'capture': {'label': 'Capture', 'nodes': {'mt': ['MT_CAPTURE']}},
    'circuit': {'label': 'The Circuit', 'nodes': {'mt': ['MT_ENDLESS_DUVIRI']}, 'aliases': ['Duviri']},
    'coh_destroy_targets': {'label': 'Descendia: Destroy Targets', 'nodes': {'mt': ['MT_DESCENT']}, 'aliases': ['Descendia']},
    'coh_excavation': {'label': 'Descendia: Excavation', 'nodes': {'mt': ['MT_DESCENT']}, 'aliases': ['Descendia']},
    'coh_nemesis': {'label': 'Descendia: Nemesis', 'nodes': {'mt': ['MT_DESCENT']}, 'aliases': ['Descendia']},
    'cohinterception': {'label': 'Descendia: Mobile Interception', 'nodes': {'mt': ['MT_DESCENT']}, 'aliases': ['Descendia']},
    'colonistdoor': {'label': 'Colonist Door Defense'},
    'control_area_deimos': {'label': 'Control Area (Cambion Drift)', 'nodes': {'mt': ['MT_LANDSCAPE'], 'names': ['Cambion Drift']},
                            'aliases': ['Bounty', 'Free Roam']},
    'control_area_nokko': {'label': 'Control Area (Orb Vallis)', 'nodes': {'mt': ['MT_LANDSCAPE'], 'names': ['Orb Vallis']},
                           'aliases': ['Bounty', 'Free Roam', 'Nokko']},
    'control_area_plains': {'label': 'Control Area (Plains)', 'nodes': {'mt': ['MT_LANDSCAPE'], 'names': ['Plains of Eidolon']},
                            'aliases': ['Bounty', 'Free Roam', 'Cetus']},
    'defection': {'label': 'Defection', 'nodes': {'mt': ['MT_EVACUATION']}},
    'defense': {'label': 'Defense', 'nodes': {'mt': ['MT_DEFENSE', 'MT_DESCENT'], 'exclude_mission_names': ['Mirror Defense']},
                'aliases': ['Descendia']},
    'disruption': {'label': 'Disruption', 'nodes': {'mt': ['MT_ARTIFACT']}, 'aliases': ['Demolyst', 'Conduit']},
    'entrati_swarm': {'label': 'Entrati Swarm', 'aliases': ['Tears']},
    'escalation': {'label': 'Exterminate (1999 Escalation)',
                   'nodes': {'mt': ['MT_EXTERMINATION'], 'systems': ['Höllvania']}, 'aliases': ['1999', 'Hollvania']},
    'excavation': {'label': 'Excavation', 'nodes': {'mt': ['MT_EXCAVATE']}, 'aliases': ['Excavator']},
    'faceoff': {'label': 'Faceoff', 'nodes': {'mt': ['MT_PVPVE']}, 'aliases': ['1999', 'Hollvania']},
    'fivefates': {'label': 'Five Fates (Cetus)', 'aliases': ['Five Fates', 'Cetus invasion']},
    'gamerules': {'label': 'All Missions (Game Rules)', 'aliases': ['All missions', 'Game rules']},
    'hijack': {'label': 'Hijack', 'nodes': {'mt': ['MT_RETRIEVAL']}},
    'infested_capture': {'label': 'Legacyte Harvest', 'nodes': {'mt': ['MT_ENDLESS_CAPTURE', 'MT_DESCENT']},
                         'aliases': ['Legacyte', 'Kalymos', 'Descendia', '1999']},
    'infested_salvage': {'label': 'Infested Salvage', 'nodes': {'mt': ['MT_PURIFY']}},
    'interception': {'label': 'Interception', 'nodes': {'mt': ['MT_TERRITORY']}},
    'lantern': {'label': 'Lantern', 'aliases': ['Halloween']},
    'loopdefend': {'label': 'Mirror Defense', 'nodes': {'mt': ['MT_DEFENSE'], 'mission_names': ['Mirror Defense']}},
    'meltdown': {'label': 'Meltdown', 'nodes': {'mt': ['MT_ALCHEMY', 'MT_DESCENT']}, 'aliases': ['Descendia']},
    'mobiledefense': {'label': 'Mobile Defense', 'nodes': {'mt': ['MT_MOBILE_DEFENSE']}},
    'multidefend': {'label': 'Hack-Station Defense', 'aliases': ['MultiDefend']},
    'netracell': {'label': 'Netracell', 'nodes': {'mt': ['MT_VAULTS']}, 'aliases': ['Archon Hunt']},
    'orphix': {'label': 'Orphix Venom', 'aliases': ['Orphix', 'Railjack']},
    'purgatory': {'label': 'Purgatory'},
    'purge': {'label': 'Purge', 'nodes': {'mt': ['MT_PURGE']}},
    'pursuit': {'label': 'Pursuit', 'nodes': {'mt': ['MT_PURSUIT']}},
    'raid': {'label': 'Raid'},
    'rescue': {'label': 'Rescue', 'nodes': {'mt': ['MT_RESCUE']}},
    'sentientcapture': {'label': 'Sentient Swarm Capture', 'aliases': ['Sentient']},
    'sentientmd': {'label': 'Sentient Mobile Defense', 'aliases': ['Sentient']},
    'server': {'label': 'Server', 'aliases': ['Server config']},
    'shrine': {'label': 'Descendia: Shrine Defense', 'nodes': {'mt': ['MT_OFFERING', 'MT_DESCENT']}, 'aliases': ['Descendia']},
    'spy': {'label': 'Spy', 'nodes': {'mt': ['MT_INTEL']}},
    'survival': {'label': 'Survival', 'nodes': {'mt': ['MT_SURVIVAL']}, 'aliases': ['Hellscrubber']},
    'void_cascade': {'label': 'Void Cascade', 'nodes': {'mt': ['MT_VOID_CASCADE']}, 'aliases': ['Zariman', 'Exolizer']},
    'void_flood': {'label': 'Void Flood', 'nodes': {'mt': ['MT_CORRUPTION']}, 'aliases': ['Zariman']},
    'wf1999def': {'label': 'Defense (1999)', 'nodes': {'mt': ['MT_DEFENSE'], 'systems': ['Höllvania']},
                  'aliases': ['1999', 'Hollvania']},
}

# Row keywords (searchable through the scope text). Matched case-insensitively as whole words in label + variant + id.
KEYWORDS = [('Steel Path', r'steel path|\bsp\b|hard ?mode'), ('Sortie', r'sortie'), ('Elite Alert', r'elite ?alert'),
            ('Alert', r'(?<!elite )\balert'), ('Duviri', r'duviri'), ('Circuit', r'circuit|\bcircle\b'),
            ('Nightmare', r'nightmare'), ('Railjack', r'railjack'), ('Kuva', r'kuva'), ('Arbitration', r'arbitration'),
            ('Archimedea', r'archimedea'), ('Descendia', r'descendia|circuit of hell'), ('1999', r'1999|wf1999'),
            ('Infested', r'infest'), ('Sentient', r'sentient'), ('Entrati lab', r'entrati.?lab|\blab\b'),
            ('Protea', r'protea'), ('Invasion', r'invasion'), ('Quest', r'quest'), ('Jade', r'\bjade\b'),
            ('Shadowgrapher', r'shadowgrapher'), ('Old World Salvage', r'old ?world ?salvage')]

UNIT_DISPLAY = {'s': 's', 's (inferred)': 's', 'virtual s': 's', 's per cell': 's', 's/interval': 's', 'minutes': 'min',
                'm': 'm', 'x': 'x', 'multiplier': 'x', 'x stock rate': 'x', 'HP': 'HP', 'XP': 'XP'}
ENUM_UNITS = {'bool', 'flag'}

# Words kept capitalised when a label is sentence-cased or its first letter is lowered for "Custom <label>".
PROPER = ['Steel Path', 'Duviri', 'Eximus', 'Protea', 'Kuva', 'Sentient', 'Infested', 'Entrati', 'Shadowgrapher', 'Orphix',
          'Railjack', 'Demolyst', 'Kalymos', 'Legacyte', 'Netracell', 'Archimedea', 'Descendia', 'Circuit', 'Grineer', 'Corpus',
          'Orokin', 'Lotus', 'Jade', 'Nokko', 'Fomorian', 'Balor', 'Cetus', 'Scaldra', 'Techrot', 'Zariman', 'Void', 'Mirror',
          'Nightmare', 'Sortie', 'Tyana', 'Exolizer', 'Arbitration', 'Hollvania', 'Circle', 'Old World Salvage']
ACRONYMS = {'ai': 'AI', 'sp': 'SP', 'xp': 'XP', 'hp': 'HP', 'ls': 'LS', 'eda': 'EDA', 'eta': 'ETA', 'emp': 'EMP', 'md': 'MD',
            'npc': 'NPC', 'pct': '%', 'ui': 'UI', 'hud': 'HUD', 'eximus': 'Eximus', 'duviri': 'Duviri', 'kuva': 'Kuva'}

# Curated short labels for rows whose id and prose label both miss the budget or collide inside their group (the gate
# lists every row that still fails; nothing is truncated automatically).
VARIANT_TAGS = {'descendia': 'Descendia', 'lab': 'Lab', 'wf1999': '1999'}

OVERRIDES = {
    # Phase 2k: labels are unique across the whole registry (a SCRIPT SETTINGS package shows many sections on one page and
    # the stock search box matches labels only), so the rows below carry their mission or variant.
    'mobiledefense.enemy_counts.max.p1': 'MD max sim. enemies, 1 player',
    'mobiledefense.enemy_counts.max.p2': 'MD max sim. enemies, 2 players',
    'mobiledefense.enemy_counts.max.p3': 'MD max sim. enemies, 3 players',
    'mobiledefense.enemy_counts.max.p4': 'MD max sim. enemies, 4 players',
    'mobiledefense.enemy_counts.min.p1': 'MD min sim. enemies, 1 player',
    'mobiledefense.enemy_counts.min.p2': 'MD min sim. enemies, 2 players',
    'mobiledefense.enemy_counts.min.p3': 'MD min sim. enemies, 3 players',
    'mobiledefense.enemy_counts.min.p4': 'MD min sim. enemies, 4 players',
    'loopdefend.level_and_enrage.alertLevelMaxBoost': 'Max alert level boost (Mirror)',
    'control_area_deimos.duration': 'Control-area duration (Deimos)',
    'control_area_nokko.duration': 'Control-area duration (Nokko)',
    'control_area_plains.duration': 'Control-area duration (Plains)',
    'purge.spawnlib_params.min_spawn_distance': 'Min enemy spawn distance',
    'survival.duviri_fixed_length': 'Duviri fixed length (Survival)',
    'void_flood.duviri_fixed_length': 'Duviri fixed length (Void Flood)',
    'alchemy.crucible_remind_countdown.descendia': 'Crucible reminder (Descendia)',
    'alchemy.crucible_remind_countdown.lab': 'Crucible reminder (Lab)',
    'alchemy.mixtures_required_default.descendia': 'Mixtures required (Descendia)',
    'alchemy.mixtures_required_default.lab': 'Mixtures required (Lab)',
    'infested_capture.search_rounds_before_boss.descendia': 'Boss search rounds (Descendia)',
    'infested_capture.search_rounds_before_boss.wf1999': 'Boss search rounds (1999)',
    'meltdown.scan_rate.in_range_multiplier.descendia': 'In-range scan rate (Descendia)',
    'meltdown.scan_rate.in_range_multiplier.lab': 'In-range scan rate (Lab)',
    'defense.eximus_chance_curve.end_wave_offset': 'Eximus ramp end wave offset',
    'defense.total_spawn_per_wave_duviri_circle': 'Enemies per wave (Duviri Circle)',
    'disruption.demolyst_health_scale_by_players.entrati_lab.p1': 'Demolyst health, Entrati lab 1P',
    'disruption.demolyst_health_scale_by_players.entrati_lab.p3': 'Demolyst health, Entrati lab 3P',
    'disruption.demolyst_health_scale_by_players.entrati_lab.p4': 'Demolyst health, Entrati lab 4P',
    'disruption.demolyst_health_scale_by_players.sentient.p1': 'Demolyst health, Sentient 1P',
    'disruption.demolyst_health_scale_by_players.sentient.p3': 'Demolyst health, Sentient 3P',
    'disruption.demolyst_health_scale_by_players.sentient.p4': 'Demolyst health, Sentient 4P',
    'disruption.demolyst_health_scale_by_players.standard.p1': 'Demolyst health 1P',
    'disruption.demolyst_health_scale_by_players.standard.p3': 'Demolyst health 3P',
    'disruption.demolyst_health_scale_by_players.standard.p4': 'Demolyst health 4P',
    'escalation.crate_timer.escalate_immediately_bonus': 'Crate time bonus, Escalate Now',
    'escalation.keys_per_players.spare_keys': 'Spare keys',
    'escalation.keys_per_players.spare_keys_faction8': 'Spare keys (Scaldra)',
    'faceoff.assassination.enemy_health_mult_p1': 'Assassination target HP, 1 player',
    'faceoff.assassination.enemy_health_mult_p2': 'Assassination target HP 2P',
    'faceoff.assassination.enemy_health_mult_p3': 'Assassination target HP 3P',
    'faceoff.assassination.enemy_health_mult_p4': 'Assassination target HP 4P',
    'faceoff.defense_escort.catalyst_bonus_time_pct': 'Escort catalyst bonus time %',
    'faceoff.defense_escort.catalysts_spawn_time': 'Escort catalyst spawn time',
    'faceoff.defense_escort.initial_defense_time': 'Escort initial defense time',
    'faceoff.defense_escort.initial_escort_time': 'Escort initial escort time',
    'faceoff.delivery.key_self_destruction_time': 'Delivery key self-destruct time',
    'faceoff.excavation.decreased_time_per_cell': 'Excavation time cut per cell',
    'faceoff.excavation.max_num_cells_available': 'Excavation max cells available',
    'gamerules.arbitration_drone_cap.players_per_drone': 'Players per Arbitration drone',
    'raid.level_bonus_players.default_max': 'Fallback max enemy level',
    'raid.level_bonus_players.default_max_gated': 'Fallback max enemy level (gated)',
    'raid.level_bonus_players.default_min': 'Fallback min enemy level',
    'raid.level_bonus_players.default_min_gated': 'Fallback min enemy level (gated)',
    'survival.reward_interval': 'Reward interval',
    'survival.pickup_time_added': 'Pickup time added',
    'survival.wf99_drop_mults.wf99SurvivalMultiplier': 'LS drop mult. (1999)',
    'survival.wf99_drop_mults.wf99SurvivalQuestMultiplier': 'LS drop mult. (1999 quest)',
    'survival.duviri_drop_mults.duviriQuestMultiplier': 'LS drop mult. (Duviri quest)',
    'survival.duviri_drop_mults.duviriSurvivalMultiplier': 'LS drop mult. (Duviri)',
    'survival.player_damage_at_zero_ls.killPlayerTime': 'Zero-LS kill time',
    'survival.player_damage_at_zero_ls.playerDamagePercent': 'Zero-LS damage percent',
    'cohinterception.is_descent': 'Zone beacon filter',
    'faceoff.cd_burn': 'CD burn switch',
    'defense.eximus_sortie.lite_sortie_chance_per_player': 'Lite Sortie Eximus chance/player',
    'defense.enemy_tier_by_wave.waves_per_tier': 'Waves per enemy tier',
    'defense.total_spawn_per_wave.start_factor': 'Wave spawn factor, start',
    'defense.total_spawn_per_wave.end_factor': 'Wave spawn factor, end',
    'circuit.enemy_level_formula.base_normal': 'Enemy level base',
    'circuit.enemy_level_formula.base_steel_path': 'Enemy level base (SP)',
    'circuit.enemy_level_formula.exponent_normal': 'Enemy level exponent',
    'circuit.enemy_level_formula.exponent_steel_path': 'Enemy level exponent (SP)',
    'shrine.offering_counts.defend_huts_offering_num': 'Defend-stage offerings',
    'orphix.orphix_interval.eventInterval': 'Orphix interval (event)',
    'faceoff.spawn_params.max_spawn_dist': 'Max spawn distance',
    'faceoff.spawn_params.min_spawn_dist': 'Min spawn distance',
    'faceoff.spawn_params.max_tier': 'Max enemy tier',
    'faceoff.spawn_params.tier_up_interval': 'Enemy tier-up interval',
    'rescue.timer_moon_fort_mult': 'Timer mult. (Moon / fort)',
    'rescue.timer_quest_mult': 'Timer mult. (quest)',
    'spy.vault_timer_quest.railjack_bonus': 'Quest vault alarm bonus',
    'mobiledefense.hardmode_enemy_row.max_p4': 'Max sim. enemies (SP), 4 players',
    'mobiledefense.hardmode_enemy_row.min_p4': 'Min sim. enemies (SP), 4 players',
    'loopdefend.enemy_level_ramp.phase_virtual_seconds': 'Level ramp time per phase',
    **{f'colonistdoor.navbridge_thresholds.b{n}': f'Nav bridge {n} threshold' for n in (1, 2, 3)},
    **{f'fivefates.state_times.state{n}': f'State {n} duration' for n in range(1, 6)},
    **{f'fivefates.state_times_sp.state{n}': f'State {n} duration (SP)' for n in range(1, 6)},
    **{f'purge.alert_tiers.tier{n}_progress': f'Alert tier {n} progress' for n in (2, 3)},
    **{f'faceoff.spawn_params.{k}enemies_p{n}': f'{k.title()} enemies, {n} player' + ('s' if n > 1 else '')
       for k in ('max', 'min') for n in range(1, 5)},
    **{f'raid.level_bonus_players.p{n}_{k}': f'{k.title()} level bonus, {n}{"+" if n == 4 else ""} players'
       for k in ('max', 'min') for n in (2, 3, 4)},
    'shrine.pickup_and_spawn_misc.pickup_anim_play_rate': 'Offering pickup anim speed',
}


def _sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest().upper()


def fmt(x):
    """Display form of a stock value: whole numbers without a decimal point, others with up to 6 significant digits."""
    x = float(x)
    if x.is_integer():
        return str(int(x))
    return format(x, '.6g')


def stock_text(stock, unit):
    s = fmt(stock)
    if not unit:
        return s
    return s + unit if unit == 'x' else s + ' ' + unit


def lower_first(label):
    """First letter lowered for "Custom <label>" unless the first word is an acronym or a proper noun."""
    first = label.split(' ', 1)[0]
    if first.isupper() or any(label.startswith(p) for p in PROPER) or re.match(r'\d', first):
        return label
    return label[:1].lower() + label[1:]


def composed(label, stock, unit):
    return {'checkbox': 'Custom ' + lower_first(label), 'editor': f'{label} (stock {stock_text(stock, unit)})'}


def budget_problems(label, stock, unit):
    problems = []
    if not label or label != label.strip() or '  ' in label:
        problems.append('label is empty or has leading/trailing/double spaces')
    if not all(0x20 <= ord(c) < 0x7f for c in label):
        problems.append('label is not printable ASCII')
    if re.search(r'[\[\]{}_|<>\\=]', label):
        problems.append('label holds code punctuation')
    if not label[:1].isupper() and not label[:1].isdigit():
        problems.append('label is not sentence case')
    text = composed(label, stock, unit)['checkbox']
    if len(text) > LABEL_BUDGET:
        problems.append(f'checkbox label "{text}" is {len(text)} > {LABEL_BUDGET} characters')
    return problems


# ---------------------------------------------------------------- short labels
def _words(segment):
    segment = re.sub(r'([a-z])([A-Z])', r'\1_\2', segment)
    return [w for w in re.split(r'[_\s]+', segment) if w]


def _humanize_word(w):
    lw = w.lower()
    if lw in ACRONYMS:
        return ACRONYMS[lw]
    m = re.fullmatch(r'p(\d)', lw)
    if m:
        n = int(m.group(1))
        return f'{n} player' + ('s' if n != 1 else '')
    m = re.fullmatch(r'd(\d)', lw)
    if m:
        return f'diff {m.group(1)}'
    m = re.fullmatch(r'([a-z]+)(\d+)', lw)
    if m:
        return f'{m.group(1)} {m.group(2)}'
    return lw


FILLER = {'by', 'params', 'misc', 'caps', 'mults', 'lib', 'spawnlib', 'formula', 'counts', 'times', 'table', 'and'}
QUALIFIER = re.compile(r'p\d|d\d|sp|normal|standard|regular|lab|descendia|sentient|entrati_lab|wf1999|min|max|solo|squad|'
                       r'(stage|area|state|spawn|t|b|tier|round|wave)\d+|elite|alert|sortie|duviri|infested|circle|default|'
                       r'(min|max|sp_min|sp_max|steel_path_min|steel_path_max)(_p\d)?')


def _render(words):
    out = []
    for w in words:
        h = _humanize_word(w)
        if out and out[-1].lower() == h.lower():
            continue
        out.append(h)
    # "<word> N" qualifiers (stage 2, area 1, state 3) whose word already appears move to the end as ", <word> N" and
    # the earlier "[per] <word>" is dropped: "tears per stage stage 1" -> "Tears, stage 1".
    tail = []
    for i, w in enumerate(out):
        m = re.fullmatch(r'([a-z]+) (\d+)', w)
        if m and m.group(1) in [x.lower() for x in out[:i]]:
            tail.append(w)
    if tail:
        words_in_tail = {t.split(' ')[0] for t in tail}
        kept = []
        for i, w in enumerate(out):
            if w in tail or w.lower() in words_in_tail:
                continue
            if w.lower() == 'per' and i + 1 < len(out) and out[i + 1].lower() in words_in_tail:
                continue
            kept.append(w)
        out = kept or out
    players = [w for w in out if re.fullmatch(r'\d players?', w)]
    rest = [w for w in out if w not in players]
    text = ' '.join(rest)
    for t in tail:
        text += ', ' + t
    if players:
        text += ', ' + players[0]
    return sentence(text)


def _segments(tid, family):
    seen, segs = set(), []
    for part in tid.split('.')[1:]:
        if part in seen or part == family:
            continue
        seen.add(part)
        part = re.sub(r'_by_players?(_count)?$', '', part)
        m = re.fullmatch(r'(.+?)_(p\d)', part)
        segs += [m.group(1), m.group(2)] if m else [part]
    return segs


def humanize_id(tid, family, leaf_only=False):
    segs = _segments(tid, family)
    if leaf_only:
        body = [s for s in segs if not QUALIFIER.fullmatch(s.lower())]
        if len(body) < 2 or not re.search(r'[a-z][A-Z]', body[-1]):
            return None  # only a camelCase Lua field name is descriptive on its own
        segs = [s for s in segs if QUALIFIER.fullmatch(s.lower()) or s == body[-1]]
    words = []
    for s in segs:
        words += [w for w in _words(s) if w.lower() not in FILLER]
    return _render(words) if words else None


def sentence(text):
    text = re.sub(r'\s+', ' ', text).strip()
    if not text:
        return text
    for p in PROPER:
        text = re.sub(r'\b' + re.escape(p.lower()) + r'\b', p, text)
    return text[:1].upper() + text[1:]


def clean_prose(label):
    """The registry prose label without explanations: parenthetical/bracketed text and anything after ; : = ->."""
    t = re.sub(r'\b1 player\(s\)', '1 player', label)
    t = re.sub(r'player\(s\)', 'players', t)
    t = re.sub(r'\([^()]*\)', '', t)
    t = re.sub(r'\[[^\]]*\]', '', t)
    t = re.split(r'[;:=]| -> | - ', t)[0]
    t = re.sub(r'\s+', ' ', t).strip(' ,.')
    t = t.replace(' ,', ',')
    if re.search(r'[A-Za-z]+[a-z][A-Z][a-z]|_|[()\[\]]|\bLerp\b|\bframe\b|MissionInfo|\bNpc|\bnetvar|\bSet[A-Z]', t):
        return None  # carries code identifiers or unbalanced text
    if len(t.split()) < 2:
        return None
    return sentence(t)


COMPACT_STEPS = [(r'\bsimultaneous enem', 'sim. enem'), (r'\bSimultaneous enem', 'Sim. enem'), (r'\bmaximum\b', 'max'),
                 (r'\bminimum\b', 'min'), (r'\bMaximum\b', 'Max'), (r'\bMinimum\b', 'Min'), (r'\bdifficulty\b', 'diff'),
                 (r'\bmultiplier\b', 'mult.'), (r'\bSteel Path\b', 'SP'), (r'\bnumber of\b', 'num.'),
                 (r'\bNumber of\b', 'Num.'), (r' (normal|standard|regular)\b', ''), (r', (\d) players?\b', r' \1P')]


def compact_levels(label):
    """Cumulative shortening levels 0..len(COMPACT_STEPS); a level that changes nothing repeats the previous label."""
    out = [label]
    for pattern, repl in COMPACT_STEPS:
        label = sentence(re.sub(pattern, repl, label)) if label else label
        out.append(label)
    return out


FORMS = ('variant-prose', 'variant-id', 'prose', 'id', 'id-leaf')


def recipes(row, family):
    """Fixed-shape candidate table: one entry per (form, compaction level), None where a form does not exist. Rows of one
    id stem share the recipe index, so siblings (player counts, stages, variants) get labels of the same shape."""
    tid = row['tunable_id']
    idl = humanize_id(tid, family)
    leaf = humanize_id(tid, family, leaf_only=True)
    prose = clean_prose(row.get('label') or '')
    qualifiers = re.findall(r'\d players?|diff \d', idl or '')
    if prose and not all(q in prose for q in qualifiers):
        prose = None  # a prose label must name the qualifiers the id carries
    group_label = GROUPS[family]['label'].lower() + ' '

    def unprefixed(text):
        # the group title is shown above every row, so a label does not repeat it ("Purgatory diff 1 ..." -> "Diff 1 ...")
        if text and text.lower().startswith(group_label) and len(text[len(group_label):].split()) >= 2:
            return sentence(text[len(group_label):])
        return text

    idl, leaf, prose = unprefixed(idl), unprefixed(leaf), unprefixed(prose)
    tag = VARIANT_TAGS.get(tid.rsplit('.', 1)[-1])
    base = unprefixed(humanize_id(tid.rsplit('.', 1)[0], family)) if tag else None
    forms = {'variant-prose': (unprefixed(clean_prose(row.get('label') or '')) if tag else None, tag), 'variant-id': (base, tag),
             'prose': (None if tag else prose, None), 'id': (idl, None), 'id-leaf': (leaf, None)}
    table = []
    for name in FORMS:
        text, suffix = forms[name]
        for level in (compact_levels(text) if text else [None] * (len(COMPACT_STEPS) + 1)):
            table.append((f'{level} ({suffix})' if level and suffix else level, name))
    return table


def stem_of(tid):
    """Rows that differ only in a trailing qualifier (player count, stage, min/max, variant) share a stem."""
    if '.' not in tid:
        return tid
    head, last = tid.rsplit('.', 1)
    if QUALIFIER.fullmatch(last.lower()) or last in VARIANT_TAGS:
        return head
    m = re.fullmatch(r'(.+?)_?(p\d|\d+)', last)
    return head + '.' + m.group(1) if m else tid


def assign_labels(rows, unit_of):
    """One short label per row: an override, else the first recipe index at which every row of the id stem fits the budget
    with a label unique in the stem; stems whose labels clash inside the group move on to their next index."""
    stock = {r['tunable_id']: (r['stock'] if r['stock'] is not None else 0) for r in rows}
    by_group = {}
    for r in rows:
        by_group.setdefault(r['tunable_id'].split('.')[0], []).append(r)
    chosen, source, failures = {}, {}, []
    for family, group_rows in by_group.items():
        stems = {}
        for r in group_rows:
            if r['tunable_id'] in OVERRIDES:
                chosen[r['tunable_id']], source[r['tunable_id']] = OVERRIDES[r['tunable_id']], 'override'
            else:
                stems.setdefault(stem_of(r['tunable_id']), []).append(r)
        tables = {r['tunable_id']: recipes(r, family) for rs in stems.values() for r in rs}
        size = len(FORMS) * (len(COMPACT_STEPS) + 1)

        def ok(tid, i):
            label = tables[tid][i][0]
            return label is not None and not budget_problems(label, stock[tid], unit_of[tid])

        def first_fit(rs, i):
            while i < size:
                labels = [tables[r['tunable_id']][i][0] for r in rs]
                if all(ok(r['tunable_id'], i) for r in rs) and len({l.lower() for l in labels}) == len(labels):
                    return i
                i += 1
            return i

        start = {stem: 0 for stem in stems}
        picked = {}
        for _ in range(size * 4):
            picked = {stem: first_fit(rs, start[stem]) for stem, rs in stems.items()}
            owners = {}
            for tid, label in chosen.items():
                if tid.split('.')[0] == family:
                    owners.setdefault(label.lower(), set()).add('override:' + tid)
            for stem, i in picked.items():
                if i < size:
                    for r in stems[stem]:
                        owners.setdefault(tables[r['tunable_id']][i][0].lower(), set()).add(stem)
            clash = {stem for names in owners.values() if len(names) > 1 for stem in names if not stem.startswith('override:')}
            if not clash:
                break
            # move the stem with the most rows last: small stems (single rows) give way first
            mover = min(clash, key=lambda st: (len(stems[st]), st))
            start[mover] = picked[mover] + 1
        for stem, i in picked.items():
            for r in stems[stem]:
                tid = r['tunable_id']
                if i >= size:
                    failures.append(tid)
                else:
                    chosen[tid], source[tid] = tables[tid][i]
        seen = {}
        for r in group_rows:
            tid = r['tunable_id']
            if tid in chosen:
                if chosen[tid].lower() in seen or budget_problems(chosen[tid], stock[tid], unit_of[tid]):
                    failures.append(tid)
                seen[chosen[tid].lower()] = tid
    return chosen, source, sorted(set(failures))


def candidates(row, family):
    if row['tunable_id'] in OVERRIDES:
        return [(OVERRIDES[row['tunable_id']], 'override')]
    seen, out = set(), []
    for c in recipes(row, family):
        if c[0] and c[0] not in seen:
            seen.add(c[0])
            out.append(c)
    return out


# ---------------------------------------------------------------- nodes and aliases
def load_nodes(workspace, server_root):
    public_path = workspace / EXPORT_PUBLIC_REL
    plus_dir = (workspace / server_root / EXPORT_PLUS_REL).resolve()
    public = json.loads(public_path.read_text(encoding='utf-8'))['ExportRegions']
    plus = json.loads((plus_dir / 'ExportRegions.json').read_text(encoding='utf-8'))
    names = json.loads((plus_dir / 'dict.en.json').read_text(encoding='utf-8'))
    version = json.loads((plus_dir / 'package.json').read_text(encoding='utf-8'))['version']
    index_to_type = {}
    for r in public:
        p = plus.get(r['uniqueName'])
        if p is None:
            continue
        known = index_to_type.setdefault(r['missionIndex'], p['missionType'])
        if known != p['missionType']:
            raise SystemExit(f'missionIndex {r["missionIndex"]} maps to {known} and {p["missionType"]}')
    nodes = []
    for r in public:
        p = plus.get(r['uniqueName'], {})
        nodes.append({'node': r['uniqueName'], 'name': r['name'], 'system': r['systemName'],
                      'mt': index_to_type.get(r['missionIndex']),
                      'mission_name': names.get(p.get('missionName', ''), '')})
    sources = {'public_export_regions': {'path': EXPORT_PUBLIC_REL, 'sha256': _sha(public_path), 'nodes': len(public)},
               'export_plus': {'path': (Path(server_root) / EXPORT_PLUS_REL).as_posix(), 'version': version,
                               'regions_sha256': _sha(plus_dir / 'ExportRegions.json'),
                               'dict_en_sha256': _sha(plus_dir / 'dict.en.json'),
                               'use': 'missionIndex -> missionType join (every joined node agrees) and mission display names'}}
    return nodes, sources


def select_nodes(spec, nodes):
    if not spec:
        return []
    out = []
    for n in nodes:
        if n['mt'] not in spec['mt']:
            continue
        if 'names' in spec and n['name'] not in spec['names']:
            continue
        if 'systems' in spec and n['system'] not in spec['systems']:
            continue
        if 'mission_names' in spec and n['mission_name'].lower() not in {m.lower() for m in spec['mission_names']}:
            continue
        if n['mission_name'].lower() in {m.lower() for m in spec.get('exclude_mission_names', [])}:
            continue
        out.append(n)
    return out


def title(text):
    return ' '.join(w[:1].upper() + w[1:].lower() if w.isupper() and len(w) > 2 else w for w in text.split())


def ascii_fold(text):
    return text.replace('ö', 'o').replace('Ö', 'O')


def group_record(gid, spec, nodes, order):
    selected = sorted(select_nodes(spec.get('nodes'), nodes), key=lambda n: n['node'])
    star = [n for n in selected if n['mt'] != 'MT_DESCENT']
    aliases = []

    def add(a):
        a = ascii_fold(a).strip()
        if a and a.lower() not in {x.lower() for x in aliases} and a.lower() != spec['label'].lower():
            aliases.append(a)

    for a in spec.get('aliases', []):
        add(a)
    for mt in (spec.get('nodes') or {}).get('mt', []):
        add(mt)
    for n in selected:
        if n['mission_name']:
            add(title(n['mission_name']))
    for n in selected:
        if ':' in n['name']:
            add(n['name'].split(':', 1)[0])
        add(n['name'])
    # The most common mission name names the node set; other mission names and "Prefix: ..." node families are listed.
    counts = {}
    for n in star:
        counts[title(n['mission_name'])] = counts.get(title(n['mission_name']), 0) + 1
    common = max(sorted(counts), key=lambda k: counts[k]) if counts else ''
    special = []
    for n in star:
        mission = title(n['mission_name'])
        if mission and mission.lower() != common.lower() and mission not in special:
            special.append(mission)
        if ':' in n['name']:
            prefix = ascii_fold(n['name'].split(':', 1)[0])
            if prefix.lower() not in {common.lower(), spec['label'].lower()} and prefix not in special:
                special.append(prefix)
    return {'label': spec['label'], 'order': order, 'mt_codes': list((spec.get('nodes') or {}).get('mt', [])),
            'aliases': aliases, 'nodes': [n['node'] for n in selected], 'node_names': [ascii_fold(n['name']) for n in star],
            'node_count': len(star), 'common_mission_name': common, 'special_nodes': special,
            'includes_descendia': any(n['mt'] == 'MT_DESCENT' for n in selected)}


def clean_variant(text):
    t = re.sub(r'frame_\d+(\[[^\]]*\])*', '', text or '')
    t = re.sub(r'Name__[0-9A-Fa-f]+', 'a hashed flag', t)
    t = re.sub(r'\s+', ' ', t).strip(' ;,')
    if t.lower() in ('', 'all', '-'):
        return ''
    t = VARIANT_TAGS.get(t, t)
    if len(t) > VARIANT_MAX:
        t = t[:VARIANT_MAX].rsplit(' ', 1)[0].rstrip(' ;,(') + '...'
    return t


def scope_for(row, group):
    if group['node_count'] > 3:
        base = f"All {group['common_mission_name']} nodes ({group['node_count']})"
        if group['special_nodes']:
            base += ' incl. ' + ', '.join(group['special_nodes'])
    elif group['node_count']:
        base = 'Nodes: ' + ', '.join(group['node_names'])
    else:
        base = row.get('mission_type') or group['label']
        if base.startswith('Lotus.') or base.startswith('/Lotus'):
            base = group['label']
    if group['includes_descendia'] and 'descendia' not in base.lower():
        base += '; Descendia stages'
    variant = clean_variant(row.get('variant', ''))
    return base + (f'. Case: {variant}' if variant else '')


def keywords(row):
    hay = ' '.join([row.get('label') or '', row.get('variant') or '', row['tunable_id'].replace('_', ' ').replace('.', ' ')]).lower()
    return [name for name, pattern in KEYWORDS if re.search(pattern, hay)]


# ---------------------------------------------------------------- entry point
def apply(rows, workspace, server_root, phase1_rows):
    nodes, sources = load_nodes(workspace, server_root)
    families = sorted({r['tunable_id'].split('.')[0] for r in rows})
    unknown = [f for f in families if f not in GROUPS]
    if unknown:
        raise SystemExit('ui: no GROUPS entry for tunable families ' + ', '.join(unknown))
    ordered = sorted(families, key=lambda f: GROUPS[f]['label'].lower())
    groups = {f: group_record(f, GROUPS[f], nodes, (i + 1) * 10) for i, f in enumerate(ordered)}
    problems = []
    for f, g in groups.items():
        if len(g['label']) > LABEL_BUDGET or len(g['label'].upper()) > TITLE_BUDGET:
            problems.append(f'group {f} label over budget')
        for text in [g['label']] + g['aliases']:
            if not text or len(text) > 64 or not all(0x20 <= ord(c) < 0x7f for c in text):
                problems.append(f'group {f}: label/alias {text!r} is empty, over 64 characters or not printable ASCII')
        if GROUPS[f].get('nodes') and GROUPS[f]['nodes']['mt'] and not g['nodes'] and f not in ('ascension', 'netracell', 'purge'):
            problems.append(f'group {f} selects no current node')

    lane = {'TARGET_ADDON': 'addon', 'EXACT_LITERAL': 'literal', 'METADATA_PATCH': 'metadata', 'SERVER_CONFIG': 'server'}
    applies = {'addon': 'live_next_read', 'literal': 'next_mission', 'metadata': 'restart', 'server': 'server_reload'}
    unit_of = {r['tunable_id']: UNIT_DISPLAY.get(r['unit'], '') for r in rows}
    labels, label_source, failures = assign_labels(rows, unit_of)
    for tid in failures:
        r = next(x for x in rows if x['tunable_id'] == tid)
        c = list(candidates(r, tid.split('.')[0]))
        problems.append(f'{tid}: no short label inside the budget and unique in its group; candidates: '
                        + ' | '.join(f'{x[0]} ({"; ".join(budget_problems(x[0], r["stock"] or 0, unit_of[tid])) or "clash"})' for x in c[:3]))
    for r in rows:
        f = r['tunable_id'].split('.')[0]
        lim = r['limits']
        enum = r['unit'] in ENUM_UNITS
        kind = 'enum' if enum else ('int' if lim.get('integer') else 'float')
        editor = 'TOGGLE' if enum else ('INPUTCOUNT' if kind == 'int' and lim['minimum'] >= 0 else 'INPUTBOX')
        p1 = phase1_rows.get(r.get('phase1_tunable_id') or '', {})
        own_mt = [c for c in (p1.get('mt_code') or '').split('/') if c.startswith('MT_')]
        g = groups[f]
        kw = keywords(r)
        scope = scope_for(r, g)
        missing = [k for k in kw if k.lower() not in scope.lower()]
        if missing:
            scope += '. Also: ' + ', '.join(missing)
        if r['backend'] == 'TARGET_ADDON' and len(scope) > ADDON_SCOPE_TOOLTIP_MAX:
            head, sep, case = scope.partition('. Case: ')
            scope = head + sep + re.sub(r'\s*\([^()]*\)', '', case) if sep else scope
            if len(scope) > ADDON_SCOPE_TOOLTIP_MAX:
                problems.append(f'{r["tunable_id"]}: addon scope text is over {ADDON_SCOPE_TOOLTIP_MAX} characters after compaction')
        if len(scope) > SCOPE_MAX or not all(0x20 <= ord(c) < 0x7f for c in scope):
            problems.append(f'{r["tunable_id"]}: scope text is over {SCOPE_MAX} characters or not printable ASCII')
        ui = {'group': f, 'mt_codes': own_mt or g['mt_codes'], 'short_label': labels.get(r['tunable_id'], ''),
              'label_source': label_source.get(r['tunable_id'], ''), 'scope_text': scope, 'aliases': kw,
              'lane': lane[r['backend']], 'applies': applies[lane[r['backend']]], 'type': kind, 'editor': editor,
              'unit': unit_of[r['tunable_id']], 'min': lim['minimum'], 'max': lim['maximum']}
        if enum:
            ui['options'] = [{'label': 'Off', 'value': 0}, {'label': 'On', 'value': 1}]
        r['ui'] = ui
    registry_labels = {}
    for r in rows:
        registry_labels.setdefault(r['ui']['short_label'].lower(), []).append(r['tunable_id'])
    for label, ids in sorted(registry_labels.items()):
        if len(ids) > 1:
            problems.append(f'short label {label!r} is not unique in the registry: {", ".join(ids)}')
    if problems:
        raise SystemExit('ui field gate failures:\n  ' + '\n  '.join(problems))
    fits = sum(1 for r in rows if len(composed(r['ui']['short_label'], r['stock'] if r['stock'] is not None else 0,
                                               r['ui']['unit'])['editor']) <= LABEL_BUDGET)
    rules = {'label_budget': LABEL_BUDGET, 'title_budget': TITLE_BUDGET, 'scope_max': SCOPE_MAX,
             'checkbox_label': '"Custom " + short_label; must fit label_budget (the first letter may be lower-cased for display, '
                               'which does not change the length)',
             'editor_label': 'short_label + " (stock " + stock_display + unit_suffix + ")" when that fits label_budget; otherwise '
                             'short_label alone, and the tooltip starts with the stock value',
             'stock_display': 'whole numbers without a decimal point; otherwise up to 6 significant digits (%.6g)',
             'unit_suffix': 'unit "x" appended without a space; any other non-empty unit after one space; empty unit: nothing',
             'title_label': 'group label upper-cased, <= title_budget',
             'editor_rule': 'TOGGLE for enum; INPUTCOUNT for int with min >= 0 (max always set); INPUTBOX otherwise',
             'applies_rule': 'addon live_next_read; literal next_mission; metadata restart; server server_reload',
             'editor_label_with_stock_rows': fits}
    return groups, sources, rules
