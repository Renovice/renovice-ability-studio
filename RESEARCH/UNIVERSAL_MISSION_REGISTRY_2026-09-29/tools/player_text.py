"""Player-facing text for the in-game SCRIPT SETTINGS Missions page (2026-09-30, contract CONTRACT_PHASE1.md Revision R5).

Owns, for every value the Missions package can show:
  * a plain-English label (<= 33 characters, so the CHECKBOX row "Custom <label>" fits the 40-character row, and
    "<label>: <stock>" fits the value BUTTON row);
  * a one-sentence description (the declaration `scope`, shown in the tooltip) that says what the value changes in game,
    when it applies and its stock value with the unit;
  * the section: the mission type's main section (headline values: timers, reward intervals, objective counts, enemy
    counts) or its "<Mission>: advanced" section (everything else), and the order inside the section;
  * master knobs ("all variants"): one value that drives several registry rows of one module at once (every variant, both
    ends of a level range). A variant row that is also ticked wins over its master (the generated addon resolves it).

Meaning comes from the 44.0.2 decompile (work/research/universal-mission-editor-2026-09-29/decomp) and the registry
evidence; where the code does not establish the meaning the description says so and the row is placed in Advanced.

Run `python player_text.py` to apply the text to REGISTRIES/mission_build_u44.json in place (idempotent; only `ui` fields,
`ui_groups` advanced entries, `ui_masters` and `ui_player_text` change). editor_fields.apply() calls apply() as well, so a
full registrar run reproduces the same fields. Nothing here reads or writes a game or server folder.
"""
from pathlib import Path
import hashlib, json, re, sys
import player_layout as LAYOUT  # contract R7: page tree, rows, quick values, defaults, short descriptions

FORMAT = 'RENOVICE_MISSION_PLAYER_TEXT_V1'
LABEL_MAX = 33          # "Custom " + label <= 40 (bootstrapper settings_ui_core.hpp maximum_row_label)
ROW_MAX = 40            # "<label>: <stock>" on the value BUTTON row
TOOLTIP_MAX = 300       # bootstrapper settings_ui_core.hpp maximum_tooltip (text beyond it is cut)
DESCRIPTION_MAX = 256   # declaration scope limit
ADVANCED_SUFFIX = '_advanced'
ADVANCED_ORDER_OFFSET = 5

# Abbreviations and code tokens a player cannot read. Matched as whole words (case-sensitive unless noted); camelCase
# identifiers are rejected separately.
BANNED = ['LS', 'MD', 'SP', 'AI', 'HP', 'DoT', 'sim', 'Sim', 'mult', 'Mult', 'pct', 'dist', 'num', 'Num', 'lvl', 'req',
          'thr', 'cfg', 'max.', 'min.', 'sim.', 'mult.', '1P', '2P', '3P', '4P', 'P1', 'P2', 'P3', 'P4', 'p1', 'p2', 'p3', 'p4',
          'Lerp', 'proto', 'upvalue', 'frame_', 'cap_', 'Name__', 'maxWaveNum', 'NpcHardCap', 'fixedLength']
BANNED_RE = [re.compile(r'(?<![A-Za-z0-9_])' + re.escape(word) + (r'(?![A-Za-z0-9_])' if word[-1].isalnum() else ''))
             for word in BANNED]
CAMEL_RE = re.compile(r'\b[a-z]+[A-Z][A-Za-z]*\b')

PLAYERS = [('p1', 'solo', '1 player'), ('p2', 'duo', '2 players'), ('p3', 'trio', '3 players'), ('p4', 'squad', '4 players')]

# Registry unit -> the words that follow the stock number in a description ("stock 300 s", "stock 1.5x", ...).
UNIT_WORDS = {'s': ' s', 's (inferred)': ' s', 'virtual s': ' s', 's per cell': ' s', 's/interval': ' s', 'minutes': ' min',
              'x': 'x', 'multiplier': 'x', 'x stock rate': 'x', 'm': ' m', 'HP': ' health', 'XP': ' XP',
              'enemies': ' enemies', 'agents': ' enemies', 'kills': ' kills', 'keys': ' keys', 'targets': ' targets',
              'rounds': ' rounds', 'levels': ' levels', 'level': ' (enemy level)', 'tier': ' (enemy tier)',
              'fractures': ' fractures', 'pillars': ' exolizers', 'pillars (inferred)': ' exolizers', 'score': ' points',
              'power': ' power', 'power/s': ' power per second', 'consoles': ' terminals'}
PERCENT_UNITS = {'fraction', 'ratio', 'chance'}


def fmt(x):
    return str(int(x)) if float(x).is_integer() else f'{x:.6g}'


def singular(stock, words):
    if fmt(stock) != '1' or not words.endswith('s') or words in (' s', ' levels'):
        return words
    return words[:-3] + 'y' if words.endswith('ies') else words[:-1]


def stock_phrase(stock, unit, word=None):
    if word is not None:
        return f'stock {fmt(stock)}{singular(stock, word)}'
    if unit in PERCENT_UNITS:
        return f'stock {fmt(stock)} ({fmt(round(stock * 100, 6))}%)'
    if unit not in UNIT_WORDS:
        raise SystemExit(f'player_text: no unit word for registry unit {unit!r}; pass word=')
    return f'stock {fmt(stock)}{singular(stock, UNIT_WORDS[unit])}'


# ------------------------------------------------------------------------------------------------------------------ data
# Row entry: (tunable_id, label, text, section, extra) where the rendered description is "<text>; <stock phrase>[ <note>]"
# and extra = {'word': unit words, 'note': text after the stock phrase}. Sections: 'main' or 'adv'. List order = rank.
R = []


def row(tid, label, text, section='main', word=None, note=None):
    R.append({'id': tid, 'label': label, 'text': text, 'section': section, 'word': word, 'note': note})


def per_player(prefix, label, text, section='main', word=None, ids=None, note=None, rule=None):
    """Four rows p1..p4: label '<label> (solo)', text '<text> with 1 player[; rule]'. `ids` maps p1..p4 to tunable ids."""
    for key, short, long in PLAYERS:
        tid = ids[key] if ids else f'{prefix}.{key}'
        row(tid, f'{label} ({short})', f'{text} with {long}' + (f'; {rule}' if rule else ''), section, word, note)


MASTERS = []  # {'id','group','label','text','drives':[(row, scale)],'note'}; stock = drives[0] stock / scale


def master(mid, label, text, drives, note=None, group=None, word=None, unit=None, limits=None):
    """`group`: contract R17, for a master whose id names no section of its own (a mission-type master over several
    locations, "All Control Area missions"): the main section of its first driven row's family. Default: the id's family.
    `word`: the unit words of the stock phrase when the registry unit has none (as for rows).
    Contract R22: a drive (row, scale, 'inverse') makes the master a speed over a duration row (row = scale / master; every
    drive of such a master is inverse, the master is fractional). `unit` names the master's own unit (default: the first
    row's) and `limits` = (minimum, maximum) narrows the range the rows allow (a floor with a code reason)."""
    MASTERS.append({'id': mid, 'label': label, 'text': text, 'drives': drives, 'note': note, 'group': group, 'word': word,
                    'unit': unit, 'limits': limits})


HIDDEN = {}  # tunable_id -> reason (never declared in the package; kept in the registry)

MASTER_RULE = 'a ticked Advanced row wins'
VARIANT_RULE = 'wins over the main knob'

# ---- Capture
per_player('capture.target_health_player_mult', 'Target health', 'Multiplies the Capture target health and shields',
           word='x')

# ---- Colonist Door Defense (quest/event): progress fractions that fire the door navigation-bridge triggers
for n, frac in (('b1', 1), ('b2', 2), ('b3', 3)):
    row(f'colonistdoor.navbridge_thresholds.{n}', f'Door progress for bridge {frac}',
        f'Door progress at which navigation bridge trigger {frac} fires (Colonist Door Defense); effect of the trigger not '
        'traced', 'adv')

# ---- Defection
for key, short, long in PLAYERS:
    master(f'defection.max_enemies.{key}', f'Max enemies at once ({short})',
           f'Defection enemies alive at once with {long}, easy and hard nodes; {MASTER_RULE}',
           [(f'defection.max_sim_ai.max_{key}', 1), (f'defection.max_sim_ai.min_{key}', 1)])
for key, short, long in PLAYERS:
    row(f'defection.max_sim_ai.max_{key}', f'Hard nodes: max enemies ({short})',
        f'Defection enemies alive at once on the hardest nodes with {long}; {VARIANT_RULE}', 'adv')
for key, short, long in PLAYERS:
    row(f'defection.max_sim_ai.min_{key}', f'Easy nodes: max enemies ({short})',
        f'Defection enemies alive at once on the easiest nodes with {long}; {VARIANT_RULE}', 'adv')

# ---- Defense (regular caps are on the literal lane; only the Duviri caps are live)
per_player('defense.simultaneous_enemies_duviri.max', 'Duviri: max enemies',
           'Duviri Defense enemies alive at once at enemy level 30+ (The Circuit: all levels)')

# ---- Descendia: Destroy Targets
per_player('coh_destroy_targets.required_by_players', 'Targets to destroy',
           'Targets to destroy to finish a Descendia Destroy Targets floor')

# ---- Disruption
row('disruption.initial_spawn_delay', 'Delay before enemies spawn',
    'Seconds before the first enemies spawn in Disruption')
row('disruption.boss_health_multiplier', 'Boss health multiplier',
    'Health multiplier applied to the Disruption boss spawn; which boss types use it is not fully traced', 'adv')
row('disruption.treasure_goblin.tier', 'Lab: treasure Demolyst tier',
    'Spawn tier of the treasure Demolyst in Entrati lab Disruption', 'adv')

# ---- Entrati Swarm (tears per stage are literal-only; the live values are Eximus limits per area)
for i in (1, 2, 3, 4):
    row(f'entrati_swarm.eximus_by_scale.cap.area{i}', f'Area {i}: max Eximus',
        f'Most Eximus enemies alive at once in area {i} of Entrati Swarm', 'adv', word=' Eximus')
for i in (1, 2, 3, 4):
    row(f'entrati_swarm.eximus_by_scale.chance.area{i}', f'Area {i}: Eximus chance',
        f'Chance that a spawned enemy is Eximus in area {i} of Entrati Swarm', 'adv')

# ---- Exterminate (1999 Escalation)
per_player('escalation.keys_per_players', 'Keys needed',
           'Keys to collect in 1999 Exterminate Escalation (spare keys also spawn)')

# ---- Faceoff (1999 PvPvE): objective values first, then enemy caps
master('faceoff.exterminate_kills', 'Exterminate: kills needed',
       'Kills to finish the Faceoff Exterminate objective (sets the random range to this value)',
       [('faceoff.exterminate_kill_goal.max', 1), ('faceoff.exterminate_kill_goal.min', 1)], note='(random 130 to 160)')
row('faceoff.defense_escort.initial_defense_time', 'Defense objective time',
    'Timer of the Faceoff Defense objective')
row('faceoff.defense_escort.initial_escort_time', 'Escort objective time',
    'Starting timer of the Faceoff Escort objective (script constant INITIAL_ESCORT_TIME)')
row('faceoff.excavation.excavation_time', 'Excavation objective time',
    'Excavation timer of the Faceoff Excavation objective (script constant EXCAVATION_TIME)')
row('faceoff.delivery.target_goal_keys', 'Delivery: keys to deliver',
    'Keys to deliver to finish the Faceoff Delivery objective (script constant TARGET_GOAL_KEYS)')
row('faceoff.delivery.enemy_kill_goal', 'Delivery: kills per key',
    'Kills needed to spawn each delivery key in the Faceoff Delivery objective')
row('faceoff.assassination.kill_goal', 'Assassination: targets to kill',
    'Targets to kill to finish the Faceoff Assassination objective (script constant KILL_GOAL)', word=' kills')
for key, short, long in PLAYERS:
    master(f'faceoff.max_enemies.{key}', f'Max enemies at once ({short})',
           f'Faceoff enemies alive at once with {long}, all enemy levels; {MASTER_RULE}',
           [(f'faceoff.spawn_params.maxenemies_{key}', 1), (f'faceoff.spawn_params.minenemies_{key}', 1)])
for key, short, long in PLAYERS:
    row(f'faceoff.spawn_params.maxenemies_{key}', f'Level 30+: max enemies ({short})',
        f'Faceoff enemies alive at once at enemy level 30+ with {long}; {VARIANT_RULE}', 'adv')
for key, short, long in PLAYERS:
    row(f'faceoff.spawn_params.minenemies_{key}', f'Low level: max enemies ({short})',
        f'Faceoff enemies alive at once at the lowest enemy level with {long}; {VARIANT_RULE}', 'adv')
row('faceoff.exterminate_kill_goal.max', 'Exterminate: most kills',
    f'Upper end of the random kill goal of the Faceoff Exterminate objective; {VARIANT_RULE}', 'adv')
row('faceoff.exterminate_kill_goal.min', 'Exterminate: fewest kills',
    f'Lower end of the random kill goal of the Faceoff Exterminate objective; {VARIANT_RULE}', 'adv')
per_player('faceoff.assassination.enemy_health_mult', 'Assassination health',
           'Health multiplier of the Faceoff Assassination targets', 'adv', word='x',
           ids={k: f'faceoff.assassination.enemy_health_mult_{k}' for k, _, _ in PLAYERS})
row('faceoff.defense_escort.catalysts_spawn_time', 'Escort: catalyst spawn time',
    'Seconds between catalyst spawns in the Faceoff Defense and Escort objectives (constant name; effect not traced)', 'adv')
row('faceoff.defense_escort.min_catalysts', 'Escort: fewest catalysts',
    'Lowest catalyst count in the Faceoff Defense and Escort objectives (constant name; effect not traced)', 'adv',
    word=' catalysts')
row('faceoff.defense_escort.max_catalysts', 'Escort: most catalysts',
    'Highest catalyst count in the Faceoff Defense and Escort objectives (constant name; effect not traced)', 'adv',
    word=' catalysts')
row('faceoff.defense_escort.catalyst_bonus_time_pct', 'Escort: catalyst time bonus',
    'Time bonus per catalyst as a fraction in the Faceoff Escort objective (constant name; effect not traced)', 'adv')
row('faceoff.delivery.max_keys', 'Delivery: keys at once',
    'Most delivery keys spawned at the same time in the Faceoff Delivery objective', 'adv')
row('faceoff.delivery.key_self_destruction_time', 'Delivery: key self-destruct time',
    'Seconds before a dropped delivery key self-destructs (constant name; effect not traced)', 'adv')
row('faceoff.delivery.eximus_chance', 'Delivery: Eximus chance',
    'Chance of Eximus enemies during the Faceoff Delivery objective (constant name; effect not traced)', 'adv')
row('faceoff.excavation.carrier_spawn_time', 'Excavation: carrier spawn time',
    'Seconds between power carrier spawns in the Faceoff Excavation objective (constant name)', 'adv')
row('faceoff.excavation.decreased_time_per_cell', 'Excavation: time cut per cell',
    'Seconds removed from the excavation timer per power cell in Faceoff (constant name; effect not traced)', 'adv')
row('faceoff.excavation.max_num_cells_available', 'Excavation: cells at once',
    'Most power cells available at once in the Faceoff Excavation objective (constant name)', 'adv', word=' cells')
row('faceoff.excavation.max_power', 'Excavation: max power',
    'Maximum excavator power in the Faceoff Excavation objective (constant name; effect not traced)', 'adv')
row('faceoff.excavation.power_drain_rate', 'Excavation: power drain',
    'Excavator power lost per second in the Faceoff Excavation objective (constant name; effect not traced)', 'adv')
row('faceoff.excavation.power_per_cell', 'Excavation: power per cell',
    'Excavator power added per power cell in the Faceoff Excavation objective (constant name; effect not traced)', 'adv')
row('faceoff.spawn_params.tier_up_interval', 'Enemy tier-up interval',
    'Seconds between enemy tier increases in Faceoff (constant name; effect not traced)', 'adv')
row('faceoff.spawn_params.max_tier', 'Highest enemy tier',
    'Highest enemy tier the Faceoff spawner reaches (constant name; effect not traced)', 'adv')
row('faceoff.spawn_params.min_spawn_dist', 'Nearest spawn distance',
    'Minimum distance from players for Faceoff reinforcement spawns', 'adv')
row('faceoff.spawn_params.max_spawn_dist', 'Farthest spawn distance',
    'Maximum distance from players for Faceoff spawns (constant name; effect not traced)', 'adv')

# ---- Five Fates (Cetus): stage timers. The Steel Path copies of these timers have no reader in 44.0.2.
for n, name in ((1, 'Offering'), (2, 'Defend huts'), (3, 'Swarm'), (4, 'Boss part 1'), (5, 'Boss part 2')):
    row(f'fivefates.state_times.state{n}', f'{name} stage time',
        f'Stage timer of the Five Fates {name.lower()} stage (Steel Path too)')
    HIDDEN[f'fivefates.state_times_sp.state{n}'] = ('no reader in 44.0.2: the Five Fates script reads OverallStateTime only '
                                                    'from the normal stage table (frame_84[114]); the Steel Path table '
                                                    '(frame_84[195]) is read only for enemy counts, so this value has no '
                                                    'effect')

# ---- Infested Salvage
per_player('infested_salvage.spawn_caps_by_players.max_ai', 'Max enemies at once',
           'Infested Salvage enemies alive at once')
per_player('infested_salvage.spawn_caps_by_players.spawn_delay', 'Time between spawns',
           'Infested Salvage seconds between enemy spawns')
per_player('infested_salvage.spawn_caps_by_players.max_source_ai', 'Enemies per spawn point',
           'Infested Salvage spawn budget, divided across the spawn points plus 5 each,', 'adv')

# ---- Lantern
per_player('lantern.num_enemies', 'Max enemies at once', 'Lantern enemies alive at once')
row('lantern.tier_up_interval', 'Time between enemy tier-ups', 'Seconds between enemy tier increases in Lantern')
per_player('lantern.radius_per_kill', 'Lamp radius per kill', 'Lamp light radius gained per kill in Lantern', 'adv')
row('lantern.max_tier', 'Highest enemy tier', 'Highest enemy tier Lantern reaches', 'adv')
for c in ('b', 'm', 'p', 'v'):
    row(f'lantern.lamp_decay.{c}', f'Lamp fade curve value {c}',
        f'Constant {c} of the Lantern lamp fade formula; the exact formula is not decoded', 'adv')

# ---- Mirror Defense (LoopDefend): phase timer and phase count are not live values (see the headline matrix)
for key, short, long in PLAYERS:
    master(f'loopdefend.max_enemies.{key}', f'Max enemies at once ({short})',
           f'Mirror Defense enemies alive at once with {long}, regular and Infested; {MASTER_RULE}',
           [(f'loopdefend.enemy_counts.maxNum.{key}', 1), (f'loopdefend.enemy_counts.minNum.{key}', 1),
            (f'loopdefend.enemy_counts.maxNumInfested.{key}', 1), (f'loopdefend.enemy_counts.minNumInfested.{key}', 1)])
per_player('loopdefend.enemy_counts.maxNum', 'Most enemies',
           'Mirror Defense upper enemy count (not Infested)', 'adv', rule=VARIANT_RULE)
per_player('loopdefend.enemy_counts.minNum', 'Fewest enemies',
           'Mirror Defense lower enemy count (not Infested)', 'adv', rule=VARIANT_RULE)
per_player('loopdefend.enemy_counts.maxNumInfested', 'Infested: most enemies',
           'Mirror Defense upper enemy count against Infested', 'adv', rule=VARIANT_RULE)
per_player('loopdefend.enemy_counts.minNumInfested', 'Infested: fewest enemies',
           'Mirror Defense lower enemy count against Infested', 'adv', rule=VARIANT_RULE)
per_player('loopdefend.crystal_cluster.enemyKillCountThreshold', 'Kills per crystal cluster',
           'Kills needed for the next crystal cluster pickup in Mirror Defense', 'adv')
row('loopdefend.crystal_cluster.groupsToSpawnAtWaveStart', 'Crystal groups at phase start',
    'Crystal cluster groups spawned when a Mirror Defense phase starts', 'adv', word=' groups')
row('loopdefend.crystal_cluster.groupsToSpawnPerKillThreshold', 'Crystal groups per kill goal',
    'Crystal cluster groups spawned each time the kill goal is reached in Mirror Defense', 'adv', word=' groups')
row('loopdefend.crystal_cluster.clusterSpawnCooldown', 'Crystal cluster cooldown',
    'Seconds between crystal cluster spawns in Mirror Defense', 'adv')
row('loopdefend.crystal_cluster.flashingTimeBeforeDespawn', 'Crystal flash before despawn',
    'Seconds a crystal cluster flashes before it disappears in Mirror Defense', 'adv')
row('loopdefend.crystal_cluster.enemyKillOnTunnelInterval', 'Tunnel kill interval',
    'Seconds between enemy kills in the Mirror Defense tunnel (constant name; effect not traced)', 'adv')
row('loopdefend.objective_dot.objectiveDamage', 'Target damage over time',
    'Base damage over time on the Mirror Defense target', 'adv')
row('loopdefend.objective_dot.pauseDotTime', 'Damage pause after pickup',
    'Seconds the target damage over time pauses after a pickup in Mirror Defense', 'adv')
row('loopdefend.objective_dot.damagePerPickup', 'Damage per pickup',
    'Damage value per crystal pickup in Mirror Defense (exact use not traced)', 'adv')
row('loopdefend.objective_dot.healPercentage', 'Pickup heal fraction',
    'Fraction of target health a pickup heals in Mirror Defense (exact use not traced)', 'adv')
row('loopdefend.objective_dot.pickupSpawnRateModifier', 'Pickup spawn rate',
    'Multiplier on crystal pickup spawns in Mirror Defense (effect not traced)', 'adv')
row('loopdefend.objective_dot.pickupThresholdModifier', 'Pickup threshold',
    'Multiplier on the crystal pickup threshold in Mirror Defense (effect not traced)', 'adv')
row('loopdefend.level_and_enrage.levelUpTime', 'Time to reach max level',
    'Mission seconds over which enemy level rises from minimum to maximum in Mirror Defense', 'adv')
row('loopdefend.level_and_enrage.enrageTime', 'Time before extra levels',
    'Mission seconds after which enemies gain levels past the maximum in Mirror Defense', 'adv')
row('loopdefend.level_and_enrage.enrageInterval', 'Seconds per extra level',
    'Starting seconds per extra enemy level after that point in Mirror Defense', 'adv')
row('loopdefend.level_and_enrage.enrageIntervalMin', 'Fastest seconds per level',
    'Shortest seconds per extra enemy level in Mirror Defense', 'adv')
row('loopdefend.level_and_enrage.enrageIntervalScale', 'Extra level speed-up',
    'How fast the seconds per extra enemy level shrink over time in Mirror Defense', 'adv', word=' s per step')
row('loopdefend.level_and_enrage.alertLevelMaxBoost', 'Alert missions: level boost',
    'Levels added to the maximum enemy level in Alert Mirror Defense missions', 'adv')
row('loopdefend.level_and_enrage.sortieLevelMaxBoost', 'Sortie: level boost',
    'Levels added to the minimum enemy level to form the maximum in Sortie Mirror Defense', 'adv')
row('loopdefend.eximus.exStartTime', 'Eximus ramp start',
    'Mission seconds when the Eximus chance starts to rise in Mirror Defense', 'adv')
row('loopdefend.eximus.exPeakTime', 'Eximus ramp peak',
    'Mission seconds when the Eximus chance reaches its peak in Mirror Defense', 'adv')
row('loopdefend.eximus.exMinChance', 'Eximus chance at start',
    'Chance that an enemy is Eximus at the ramp start in Mirror Defense', 'adv')
row('loopdefend.eximus.exMaxChance', 'Eximus chance at peak',
    'Chance that an enemy is Eximus at the ramp peak in Mirror Defense', 'adv')
row('loopdefend.eximus.override_exPeakTime', 'Event: Eximus ramp peak',
    'Eximus ramp peak seconds in Jade and event Mirror Defense (non-empty goal tag)', 'adv')
row('loopdefend.eximus.override_exMinChance', 'Event: Eximus chance at start',
    'Eximus chance at the ramp start in Jade and event Mirror Defense', 'adv')
row('loopdefend.eximus.override_exMaxChance', 'Event: Eximus chance at peak',
    'Eximus chance at the ramp peak in Jade and event Mirror Defense', 'adv')
per_player('loopdefend.eximus.override_ex_max_spawn', 'Event: max Eximus',
           'Most Eximus alive at once in Jade and event Mirror Defense', 'adv', word=' Eximus')

# ---- Mobile Defense: terminal timer (literal lane, one knob for both ends of the level range); enemy caps (addon lane)
# R18 (coverage audit 2026-10-02): the Sentient Anomaly area timer is the same "time per terminal" in another module
# (SentientMobileDefense, literal lane): the type master drives it too (contract R17 cross-module literal drive).
master('mobiledefense.time_per_terminal', 'Time per terminal',
       'Defense time of each Mobile Defense terminal on every node (total = 3 x this) and Sentient Anomaly area',
       [('mobiledefense.total_time.maximum', 3), ('mobiledefense.total_time.minimum', 3), ('sentientmd.defend_time', 1)],
       note='(easy nodes 60, Sentient 120)', group='mobiledefense')
for key, short, long in PLAYERS:
    master(f'mobiledefense.max_enemies.{key}', f'Max enemies at once ({short})',
           f'Mobile Defense enemies alive at once with {long}, easy and hard nodes; {MASTER_RULE}',
           [(f'mobiledefense.enemy_counts.max.{key}', 1), (f'mobiledefense.enemy_counts.min.{key}', 1)])
for key, short, long in PLAYERS:
    row(f'mobiledefense.enemy_counts.max.{key}', f'Hard nodes: max enemies ({short})',
        f'Mobile Defense enemies alive at once on the hardest nodes with {long}; {VARIANT_RULE}', 'adv')
for key, short, long in PLAYERS:
    row(f'mobiledefense.enemy_counts.min.{key}', f'Easy nodes: max enemies ({short})',
        f'Mobile Defense enemies alive at once on the easiest nodes with {long}; {VARIANT_RULE}', 'adv')
row('mobiledefense.total_time.maximum', 'Hard nodes: total terminal time',
    'Total terminal defense time on the hardest Mobile Defense nodes, split over the terminals', 'adv')
row('mobiledefense.total_time.minimum', 'Easy nodes: total terminal time',
    'Total terminal defense time on the easiest Mobile Defense nodes, split over the terminals', 'adv')

# ---- Orphix Venom
row('orphix.reward_interval', 'Rounds per reward', 'Orphix Venom rounds per reward (Sortie uses 12)')
master('orphix.spawn_interval', 'Time between Orphix spawns',
       f'Seconds between Orphix spawns, normal and event; {MASTER_RULE}',
       [('orphix.orphix_interval.interval', 1), ('orphix.orphix_interval.eventInterval', 1)], note='(event 90 s)')
row('orphix.orphix_interval.condrixCap', 'Max Orphix at once', 'Most Orphix alive at once in Orphix Venom',
    word=' Orphix')
row('orphix.max_rounds_railjack', 'Railjack: round limit', 'Round limit of Railjack and event Orphix Venom')
row('orphix.orphix_interval.interval', 'Normal: time between spawns',
    f'Seconds between Orphix spawns outside the Orphix event; {VARIANT_RULE}', 'adv')
row('orphix.orphix_interval.eventInterval', 'Event: time between spawns',
    f'Seconds between Orphix spawns during the Orphix event; {VARIANT_RULE}', 'adv')
row('orphix.score_add_per_round', 'Score per round', 'Score added per completed round in Orphix Venom (use not traced)',
    'adv')

# ---- Purgatory
for i in range(1, 7):
    row(f'purgatory.reward_kill_threshold.t{i}', f'Kills for reward tier {i}',
        f'Kills needed to reach reward tier {i} in Purgatory')
for i in (1, 2, 3):
    row(f'purgatory.difficulty{i}.warrior_level', f'Difficulty {i}: warrior level',
        f'Level of warrior enemies at Purgatory difficulty {i}', 'adv')
    row(f'purgatory.difficulty{i}.ghost_level', f'Difficulty {i}: ghost level',
        f'Level of ghost enemies at Purgatory difficulty {i}', 'adv')
    row(f'purgatory.difficulty{i}.damage_mult', f'Difficulty {i}: enemy damage',
        f'Enemy damage multiplier at Purgatory difficulty {i}', 'adv')

# ---- Purge (no star-chart nodes)
for i in (1, 2, 3):
    row(f'purge.alert_tiers.tier{i}_multiplier', f'Alert tier {i}: spawn speed',
        f'Spawn rate multiplier at Alert Purge tier {i} (spawn delay 4 s divided by it, spawn budget times it)', 'adv')

# ---- Sentient Swarm Capture / Sentient Mobile Defense
row('sentientcapture.swarm.area_swarm_size', 'Swarm size per area',
    'Sentient swarm agents spawned per area (2 defenders, 2 attackers, rest normal)')
per_player('sentientmd.max_sim_ai', 'Max enemies at once', 'Sentient Mobile Defense enemies alive at once')

# ---- Descendia: Shrine Defense
row('shrine.stage_time.offering', 'Offering stage time',
    'Timer of the Descendia Shrine Defense offering stage (Steel Path too)')
for key, short, long in PLAYERS:
    drives = []
    for tier in ('normal', 'sp'):
        for stage in ('offering', 'boss_part_2'):
            drives += [(f'shrine.max_enemies.{tier}.{stage}.{key}', 1), (f'shrine.min_enemies.{tier}.{stage}.{key}', 1)]
    master(f'shrine.max_enemies.{key}', f'Max enemies at once ({short})',
           f'Shrine Defense enemies alive at once with {long}, all stages and Steel Path; {MASTER_RULE}', drives)
for key, short, long in PLAYERS:
    master(f'shrine.respawn_delay.{key}', f'Time between waves ({short})',
           f'Shrine Defense seconds between enemy waves with {long}, all stages and Steel Path; {MASTER_RULE}',
           [(f'shrine.respawn_delay.{tier}.{stage}.{key}', 1) for tier in ('normal', 'sp')
            for stage in ('offering', 'boss_part_2')])
SHRINE_TABLES = (('normal', 'offering', 'Offering', 'offering stage'), ('normal', 'boss_part_2', 'Boss', 'boss stage'),
                 ('sp', 'offering', 'Steel Path', 'Steel Path offering stage'),
                 ('sp', 'boss_part_2', 'Steel Path boss', 'Steel Path boss stage'))
for tier, stage, prefix, where in SHRINE_TABLES:
    per_player(f'shrine.max_enemies.{tier}.{stage}', f'{prefix}: enemies',
               f'Enemies topped up to this in the {where}', 'adv', rule=VARIANT_RULE)
for tier, stage, prefix, where in SHRINE_TABLES:
    per_player(f'shrine.min_enemies.{tier}.{stage}', f'{prefix}: refill',
               f'Top-up starts at this many alive or fewer, {where}', 'adv', rule=VARIANT_RULE)
for tier, stage, prefix, where in SHRINE_TABLES:
    per_player(f'shrine.respawn_delay.{tier}.{stage}', f'{prefix}: waves',
               f'Seconds between enemy waves in the {where}', 'adv', rule=VARIANT_RULE)

# ---- Survival
row('survival.reward_interval', 'Time between rewards',
    'Seconds per reward rotation in normal endless Survival (also Steel Path, Kuva, Void Eclipse); not Alert missions')
row('survival.alert_interval', 'Alert missions: reward time',
    'Alert, invasion and syndicate Survival: seconds until the single reward and extraction (mission length)')
row('survival.capsule_initial_time', 'Life support at start', 'Life support seconds when a Survival mission starts')
row('survival.capsule_max_time', 'Life support at 100%', 'Life support seconds that count as 100% in Survival')
row('survival.capsule_time_added', 'Life support per capsule', 'Life support seconds an activated capsule adds')
row('survival.capsule_interval', 'Time between capsules',
    'Seconds between life support capsule spawns in Survival (not a reward timer)')
row('survival.capsule_incoming_time', 'Capsule warning time',
    'Seconds of lead time before a life support capsule spawns (warning use inferred)')
row('survival.pickup_time_added', 'Life support per pickup',
    'Life support seconds each personal life support pickup adds')
row('survival.player_damage_at_zero_ls.killPlayerTime', 'Time at 0% before death',
    'Seconds at 0% life support before players are killed in Survival')
row('survival.player_damage_at_zero_ls.playerDamagePercent', 'Damage at 0% life support',
    'Health fraction players lose per damage tick at 0% life support', 'adv')
row('survival.pickup_drop_low_high_mult.lowSpawnThreshold', 'Low life support mark',
    'Life support fraction at or below which pickups drop more often', 'adv')
row('survival.pickup_drop_low_high_mult.lowDropMultiplier', 'Pickup drops when low',
    'Pickup drop rate multiplier at or below the low life support mark', 'adv')
row('survival.pickup_drop_low_high_mult.highSpawnThreshold', 'High life support mark',
    'Life support fraction at or above which pickups drop less often', 'adv')
row('survival.pickup_drop_low_high_mult.highDropMultiplier', 'Pickup drops when high',
    'Pickup drop rate multiplier at or above the high life support mark', 'adv')
row('survival.alert_ls_drop_mult', 'Alert missions: pickup drop rate',
    'Life support pickup drop rate multiplier in Alert and other fixed-length Survival', 'adv')
row('survival.duviri_drop_mults.duviriSurvivalMultiplier', 'Duviri: pickup drop rate',
    'Life support pickup drop rate multiplier in Duviri Survival', 'adv')
row('survival.duviri_drop_mults.duviriQuestMultiplier', 'Duviri quest: pickup drop rate',
    'Life support pickup drop rate multiplier in the Duviri quest Survival', 'adv')
row('survival.wf99_drop_mults.wf99SurvivalMultiplier', '1999: pickup drop rate',
    'Life support pickup drop rate multiplier in 1999 Survival (not the quest)', 'adv')
row('survival.wf99_drop_mults.wf99SurvivalQuestMultiplier', '1999 quest: pickup drop rate',
    'Life support pickup drop rate multiplier in the 1999 quest Survival', 'adv')
row('survival.level_up_enrage.levelUpTime', 'Time to reach max level',
    'Seconds over which enemy level rises from minimum to maximum in endless Survival', 'adv')
row('survival.level_up_enrage.enrageTime', 'Time before extra levels',
    'Seconds after which enemies gain levels past the maximum in endless Survival', 'adv')
row('survival.level_up_enrage.enrageInterval', 'Seconds per extra level',
    'Starting seconds per extra enemy level after that point in Survival', 'adv')
row('survival.level_up_enrage.enrageIntervalMin', 'Fastest seconds per level',
    'Shortest seconds per extra enemy level in Survival', 'adv')
row('survival.level_up_enrage.enrageIntervalScale', 'Extra level speed-up',
    'How fast the seconds per extra enemy level shrink over time in Survival', 'adv')
row('survival.kuva_level_enrage.levelUpTime', 'Kuva: time to max level',
    'Seconds over which enemy level rises from minimum to maximum in Kuva Survival', 'adv')
row('survival.kuva_level_enrage.enrageTime', 'Kuva: time before extra levels',
    'Seconds after which enemies gain levels past the maximum in Kuva Survival', 'adv')
row('survival.level_max_boost.alertLevelMaxBoost', 'Alert missions: level boost',
    'Levels added to the maximum enemy level in Alert Survival', 'adv')
row('survival.level_max_boost.sortieLevelMaxBoost', 'Sortie: level boost',
    'Levels added to the minimum enemy level to form the maximum in Sortie Survival', 'adv')
row('survival.pickup_reward_progress', 'Reward clock per pickup',
    'Old preset option, not a stock value: seconds added to the reward clock per pickup (0 = off)', 'adv')

# ---- Void Cascade
row('void_cascade.pillar_duration', 'Exolizer defense time',
    'Seconds each exolizer must be defended in Void Cascade (normal and The Circuit)')
# R22: the unit is confirmed (ZarimanSurvivalMission proto 28: reward tiers = floor(finished exolizers / interval)).
row('void_cascade.alert_reward_interval', 'Alert missions: reward interval',
    'Exolizers that must finish for each reward in Alert Void Cascade missions')
per_player('void_cascade.circle_fixed_length', 'Circuit: exolizers',
           'Exolizers to finish Void Cascade in The Circuit', 'adv')

# ---- Void Flood. The fracture count is a literal (replacement member); the tank fill timer and curse counts are addon rows
# of the same module, so they are declared only in builds without the Void Flood replacement (one artifact per module).
row('void_flood.fractures_per_round.normal', 'Fractures per round',
    'Void fractures opened per round in Void Flood (not Duviri)')
# R14 (2026-10-01): these three values time the Void corruption meter (netvar CorruptionMeterLevel: it rises while a tank is
# open and starts the eruption countdown when full, ZarimanCorruptionMission prototypes 26/44/45), not how fast a tank fills.
# The tank fill speed is void_flood.deposit_speed_scale (player_text_r10.py).
row('void_flood.fill_timer.timeToFillMax', 'Corruption meter time',
    'Seconds for the Void Flood corruption meter to fill while a tank is open; shrinks every 3 fractures')
row('void_flood.fill_timer.timeToFillMin', 'Shortest meter time', 'Shortest seconds for the Void Flood corruption meter to fill')
row('void_flood.fill_timer.curveScaleV', 'Meter time shrink',
    'Multiplier applied to the Void Flood corruption meter time every 3 fractures', 'adv')
row('void_flood.curse_count.curseCountNormal', 'Curses', 'Curses in Void Flood', 'adv', word=' curses')
row('void_flood.curse_count.curseCountSteelPath', 'Steel Path: curses', 'Curses in Steel Path Void Flood', 'adv', word=' curses')
row('void_flood.curse_count.playerCapacity', 'Player Void energy capacity',
    'Void energy a player can carry in the Shadowgrapher variant of Void Flood (normal Void Flood uses the tank capacity)',
    'adv', word=' energy')
row('void_flood.fractures_per_round.shadowgrapher', 'Shadowgrapher: fractures at once',
    'Most fractures open at once in the Shadowgrapher variant of Void Flood', 'adv')

# ---- Excavation (exact replacement member: one knob drives the standard, Elite Alert and Old World Salvage dig times)
# R18 (coverage audit 2026-10-02): the Descendia Excavation floor digs with the same per-excavator time in its own module
# (CoHExcavationLite, literal lane): the type master drives it too (contract R17 cross-module literal drive).
master('excavation.dig_time', 'Dig time per excavator',
       'Seconds each excavator digs in every Excavation variant, Descendia included',
       [('excavation.dig_duration', 1), ('excavation.dig_duration_elite_alert', 1),
        ('excavation.dig_duration_old_world_salvage', 1), ('coh_excavation.dig_duration', 1)],
       note='(Elite Alert 140, Old World 60, Descendia 45)', group='excavation')
row('excavation.dig_duration', 'Standard dig time',
    'Seconds each excavator digs in standard Excavation', 'adv')
row('excavation.dig_duration_elite_alert', 'Elite Alert: dig time',
    'Seconds each excavator digs in Elite Alert Excavation', 'adv')
row('excavation.dig_duration_old_world_salvage', 'Old World Salvage: dig time',
    'Seconds each excavator digs in Old World Salvage Excavation', 'adv')

# ---- Control Area bounties (exact replacement members)
row('control_area_plains.duration', 'Hold-zone time',
    'Seconds to hold the zone in Plains of Eidolon Control Area bounties')
row('control_area_deimos.duration', 'Hold-zone time (Cambion)',
    'Seconds to hold the zone in Cambion Drift Control Area bounties')

# ---- LIVE_LITERALS_V1 (contract R8): headline literal values, typeable in game (player_text_live_literals.py)
import player_text_live_literals  # noqa: E402  (same folder)
player_text_live_literals.register(row, master, PLAYERS, MASTER_RULE, VARIANT_RULE)
LIVE_LITERAL_HEADLINE = list(player_text_live_literals.HEADLINE)

# ---- Contract R10 (2026-09-30): mission-owner research rows (player_text_r10.py); its literal rows are live literals too.
import player_text_r10  # noqa: E402  (same folder)
player_text_r10.register(row, master, per_player, PLAYERS)
LIVE_LITERAL_HEADLINE += player_text_r10.HEADLINE

# ---- Contract R17 (2026-10-01): "All <mission type> missions" masters (player_text_r17.py).
import player_text_r17  # noqa: E402  (same folder)
player_text_r17.register(row, master)
LIVE_LITERAL_HEADLINE += player_text_r17.HEADLINE

# Group labels (sections). Existing ui_groups labels stay; advanced sections are "<label>: advanced" or the short form.
ADVANCED_LABELS = {'escalation': '1999 Escalation: advanced', 'shrine': 'Shrine Defense: advanced',
                   'coh_destroy_targets': 'Destroy Targets: advanced', 'fivefates': 'Five Fates: advanced',
                   'colonistdoor': 'Colonist Door: advanced', 'sentientcapture': 'Sentient Capture: advanced',
                   'sentientmd': 'Sentient Defense: advanced'}


# ------------------------------------------------------------------------------------------------------------ gates
def text_problems(text, where, maximum):
    problems = []
    if not text or len(text) > maximum or not all(0x20 <= ord(c) < 0x7f for c in text) or text != text.strip():
        problems.append(f'{where}: empty, over {maximum} characters, not printable ASCII or padded: {text!r}')
    for word, pattern in zip(BANNED, BANNED_RE):
        if pattern.search(text):
            problems.append(f'{where}: unexplained abbreviation or code token {word!r} in {text!r}')
    for match in CAMEL_RE.finditer(text):
        problems.append(f'{where}: code identifier {match.group(0)!r} in {text!r}')
    return problems


def tooltip(stock, unit, low, high, description, lane):
    """Mirror of bootstrapper settings_ui_core.hpp value_tooltip + the CHECKBOX prefix (longest variant)."""
    with_unit = fmt(stock) + (unit if unit == 'x' else (' ' + unit if unit else ''))
    text = 'Off: the stock value is used. Stock ' + with_unit + '.'
    text += f' Range {fmt(low)} to {fmt(high)}.'
    text += ' ' + description + '.'
    if lane == 'literal':
        text += ' Edited in Ability Studio; this switch applies the edited script at the next mission.'
    else:
        text += ' Applies: live, at the next read. Custom value applies only where the live value equals stock.'
    return text


def description_problems(description, stock, unit_display, where):
    problems = text_problems(description, where + ' description', DESCRIPTION_MAX)
    words = {'s': [' s'], 'x': ['x'], 'm': [' m'], 'HP': [' health'], 'XP': [' XP'], 'min': [' min']}.get(unit_display)
    head = 'stock ' + fmt(stock)
    at = description.find(head)
    if at < 0:
        problems.append(f'{where}: description does not state the stock value ({head!r}): {description!r}')
    else:
        tail = description[at + len(head):]
        if words is not None and not any(tail.startswith(w) for w in words):
            problems.append(f'{where}: stock value is not followed by its unit {words}: {description!r}')
        if words is None and not re.match(r' [A-Za-z(]|%', tail):
            problems.append(f'{where}: stock value of a unitless value is not followed by what it counts: {description!r}')
    return problems


# ------------------------------------------------------------------------------------------------------------- apply
def data_digest():
    blob = json.dumps({'rows': R, 'masters': MASTERS, 'hidden': HIDDEN, 'advanced': ADVANCED_LABELS,
                       'live_literals': LIVE_LITERAL_HEADLINE}, sort_keys=True)
    return hashlib.sha256(blob.encode()).hexdigest().upper()


def apply(rows, groups):
    """Applies the player text to registry rows (list) and ui_groups (dict, in place). Returns (masters, meta)."""
    by_id = {r['tunable_id']: r for r in rows}
    problems = []
    seen = set()
    rank = {}
    for n, entry in enumerate(R):
        tid = entry['id']
        if tid in seen:
            problems.append(f'{tid}: listed twice')
        seen.add(tid)
        if tid not in by_id:
            problems.append(f'{tid}: not a registry row')
            continue
        r = by_id[tid]
        ui = r['ui']
        family = tid.split('.')[0]
        if r['stock'] is None:
            problems.append(f'{tid}: registry stock is unknown; the row cannot be shown')
            continue
        description = entry['text'] + '; ' + stock_phrase(r['stock'], r['unit'], entry['word'])
        if entry['note']:
            description += ' ' + entry['note']
        ui['short_label'] = entry['label']
        ui['label_source'] = 'player_text'
        ui['scope_text'] = description
        ui['group'] = family + (ADVANCED_SUFFIX if entry['section'] == 'adv' else '')
        ui['rank'] = n
        if tid in HIDDEN:
            problems.append(f'{tid}: both hidden and shown')
    for tid, reason in HIDDEN.items():
        if tid not in by_id:
            problems.append(f'{tid}: hidden row is not a registry row')
            continue
        by_id[tid]['ui']['hidden'] = reason
    # Advanced sections
    for family in sorted({r['ui']['group'][:-len(ADVANCED_SUFFIX)] for r in rows if r['ui']['group'].endswith(ADVANCED_SUFFIX)}):
        base = groups[family]
        label = ADVANCED_LABELS.get(family, base['label'] + ': advanced')
        groups[family + ADVANCED_SUFFIX] = {'label': label, 'order': base['order'] + ADVANCED_ORDER_OFFSET, 'mt_codes': base['mt_codes'],
                                            'aliases': list(base['aliases']) + [base['label']], 'nodes': base['nodes'],
                                            'node_names': base['node_names'], 'node_count': base['node_count'],
                                            'common_mission_name': base['common_mission_name'],
                                            'special_nodes': base['special_nodes'], 'includes_descendia': base['includes_descendia'],
                                            'advanced_of': family}
    for gid, g in groups.items():
        if len(g['label']) > 40 or len(g['label'].upper()) > 48:
            problems.append(f'group {gid}: label over budget')
    # Masters
    masters = {}
    for n, m in enumerate(MASTERS):
        mid = m['id']
        family = mid.split('.')[0]
        if mid in by_id or mid in masters:
            problems.append(f'master {mid}: id collides with a tunable or another master')
            continue
        driven, inverse = [], set()
        for drive in m['drives']:
            tid, scale = drive[0], drive[1]
            if len(drive) == 3:
                if drive[2] != 'inverse':
                    problems.append(f'master {mid}: unknown drive form {drive[2]!r}')
                    continue
                inverse.add(tid)
            if tid not in by_id:
                problems.append(f'master {mid}: drives unknown row {tid}')
                continue
            driven.append((by_id[tid], scale))
        if not driven:
            continue
        if inverse and len(inverse) != len(driven):
            problems.append(f'master {mid}: every drive of an inverse master must be inverse (R22)')
        first, first_scale = driven[0]
        lanes = {r['backend'] for r, _ in driven}
        bodies = {r['owner']['body_key'] for r, _ in driven}
        types = {r['ui']['type'] for r, _ in driven}
        if len(lanes) != 1:
            problems.append(f'master {mid}: drives rows of several lanes')
        # R17: a mission-type master may drive rows of several modules (Control Area: three location scripts; Railjack:
        # three objective scripts). Its group is the main section of its first driven row's family.
        if m['group'] is not None:
            family = m['group']
            if family != first['tunable_id'].split('.')[0] or family not in groups:
                problems.append(f'master {mid}: group {family} is not the main section of its first driven row')
        elif len(bodies) != 1:
            problems.append(f'master {mid}: drives rows of several modules without naming its group (contract R17)')
        if inverse:  # R22: row = scale / master
            stock = first_scale / first['stock']
            low = max(s / r['limits']['maximum'] for r, s in driven)
            high = min(s / r['limits']['minimum'] for r, s in driven)
            kind = 'float'
        else:
            stock = first['stock'] / first_scale
            low = max(r['limits']['minimum'] / s for r, s in driven)
            high = min(r['limits']['maximum'] / s for r, s in driven)
            kind = 'int' if 'int' in types else first['ui']['type']
        if m['limits'] is not None:  # R22: a narrower range with a recorded reason
            want_low, want_high = m['limits']
            if not (low <= want_low <= stock <= want_high <= high):
                problems.append(f'master {mid}: limits {m["limits"]} are not inside {low}..{high} around the stock {stock}')
            low, high = want_low, want_high
        unit = m['unit'] if m['unit'] is not None else first['unit']
        ui_unit = m['unit'] if m['unit'] is not None else first['ui']['unit']
        if kind == 'int':
            low, high = float(int(-(-low // 1))), float(int(high // 1))
            if any(float(s) != int(s) for _, s in driven):
                problems.append(f'master {mid}: an int master needs whole scales')
        description = m['text'] + '; ' + stock_phrase(stock, unit, m.get('word'))
        if m['note']:
            description += ' ' + m['note']
        number = (lambda v: int(v)) if kind == 'int' else (lambda v: int(v) if float(v).is_integer() else v)
        masters[mid] = {'group': family, 'short_label': m['label'], 'label_source': 'player_text', 'scope_text': description,
                        'rank': -len(MASTERS) + n, 'lane': first['ui']['lane'], 'applies': first['ui']['applies'],
                        'type': kind, 'editor': 'INPUTBOX' if kind != 'int' or low < 0 else 'INPUTCOUNT',
                        'unit': ui_unit, 'stock': number(stock), 'min': number(low), 'max': number(high),
                        'body_key': first['owner']['body_key'],
                        'drives': [dict({'tunable_id': r['tunable_id'], 'scale': int(s) if float(s).is_integer() else s},
                                        **({'inverse': True} if r['tunable_id'] in inverse else {})) for r, s in driven]}
        if len(bodies) > 1:  # R17 cross-module master: every module it drives, first driven row's module first
            masters[mid]['body_keys'] = [first['owner']['body_key']] + sorted(bodies - {first['owner']['body_key']})
        if not (low <= stock <= high):
            problems.append(f'master {mid}: stock {stock} outside {low}..{high}')
    driven_by = {}
    for mid, m in masters.items():
        for d in m['drives']:
            if d['tunable_id'] in driven_by:
                problems.append(f'{d["tunable_id"]}: driven by two masters ({driven_by[d["tunable_id"]]}, {mid})')
            driven_by[d['tunable_id']] = mid
    # Gates over everything shown: labels, descriptions, rendered tooltip, per-section uniqueness
    shown = [(r['tunable_id'], r['ui'], r['stock']) for r in rows if r['ui'].get('label_source') == 'player_text']
    shown += [(mid, m, m['stock']) for mid, m in masters.items()]
    labels = {}
    curated = {e['id'] for e in R}
    for r in rows:  # labels of rows without player text still occupy their section
        if r['tunable_id'] not in curated:
            labels[(r['tunable_id'].split('.')[0], r['ui']['short_label'].lower())] = r['tunable_id']
    for tid, ui, stock in shown:
        where = tid
        problems += text_problems(ui['short_label'], where + ' label', LABEL_MAX)
        button = ui['short_label'] + ': ' + fmt(stock) + (ui['unit'] if ui['unit'] == 'x' else (' ' + ui['unit'] if ui['unit'] else ''))
        if len(button) > ROW_MAX:
            problems.append(f'{where}: value row "{button}" is over {ROW_MAX} characters')
        problems += description_problems(ui['scope_text'], stock, ui['unit'], where)
        tip = tooltip(stock, ui['unit'], ui['min'], ui['max'], ui['scope_text'], ui['lane'])
        if len(tip) > TOOLTIP_MAX:
            problems.append(f'{where}: rendered tooltip is {len(tip)} characters (> {TOOLTIP_MAX}); shorten the description')
        family = tid.split('.')[0]
        key = (family, ui['short_label'].lower())
        if key in labels:
            problems.append(f'{where}: label {ui["short_label"]!r} is not unique in its mission section (also {labels[key]})')
        labels[key] = tid
    if problems:
        raise SystemExit('player text gate failures:\n  ' + '\n  '.join(problems))
    meta = {'format': FORMAT, 'tool': 'RESEARCH/UNIVERSAL_MISSION_REGISTRY_2026-09-29/tools/player_text.py',
            'data_sha256': data_digest(), 'label_max': LABEL_MAX, 'row_max': ROW_MAX, 'tooltip_max': TOOLTIP_MAX,
            'banned_abbreviations': BANNED, 'rows': len(R), 'masters': len(masters), 'hidden': len(HIDDEN),
            'advanced_suffix': ADVANCED_SUFFIX}
    # LIVE_LITERALS_V1: the headline literal values (rows and literal masters) a "literal_scope": "headline" build declares.
    shown_ids = {r['tunable_id'] for r in rows if r['ui'].get('label_source') == 'player_text'} | set(masters)
    for tid in LIVE_LITERAL_HEADLINE:
        lane = masters[tid]['lane'] if tid in masters else (by_id[tid]['ui']['lane'] if tid in by_id else None)
        if tid not in shown_ids or lane != 'literal':
            problems.append(f'live literal {tid}: not a literal row or master with player text')
    if len(set(LIVE_LITERAL_HEADLINE)) != len(LIVE_LITERAL_HEADLINE):
        problems.append('live literal headline list names a value twice')
    if problems:
        raise SystemExit('player text gate failures:\n  ' + '\n  '.join(problems))
    meta['live_literal_headline'] = list(LIVE_LITERAL_HEADLINE)
    return masters, meta


def main():
    editor = Path(__file__).resolve().parents[3]
    path = editor / 'REGISTRIES/mission_build_u44.json'
    registry = json.loads(path.read_text(encoding='utf-8'))
    masters, meta = apply(registry['tunables'], registry['ui_groups'])
    registry['ui_layout'] = LAYOUT.apply(registry['tunables'], registry['ui_groups'], masters)
    registry['ui_groups'] = dict(sorted(registry['ui_groups'].items(), key=lambda kv: kv[1]['order']))
    registry['ui_masters'] = masters
    registry['ui_player_text'] = meta
    path.write_text(json.dumps(registry, indent=2, ensure_ascii=False) + '\n', encoding='utf-8', newline='\n')  # LF on every OS
    print(f"player text: {meta['rows']} rows, {meta['masters']} masters, {meta['hidden']} hidden; data {meta['data_sha256'][:16]}")


if __name__ == '__main__':
    sys.exit(main())
