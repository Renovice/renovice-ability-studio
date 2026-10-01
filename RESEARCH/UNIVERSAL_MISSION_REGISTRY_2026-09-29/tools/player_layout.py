"""SCRIPT SETTINGS navigation for the Missions package (contract CONTRACT_PHASE1.md Revision R7, 2026-09-30).

Live feedback on R5: the package page was a long flat list of sections ("Control Area: 1 value" twice, "Disruption::",
"X: advanced" next to "X"), tooltips listed node names and MT codes, every value took two rows ("Custom X" and "X: value")
and the page carried package and member switches. R7 replaces the section list with a page tree:

    Missions -> mission type (variants and locations merged, alphabetical; Descendia modes under "Descendia")
             -> category (Timers, Objectives, Enemies, Rewards / drops, Advanced; only those that exist, Advanced last;
                the level is dropped by the generator when a page would hold one category only)
             -> value rows, or a set page (per-player-count values: Solo, Duo, Trio, Squad; named variants after them)
             -> value page (editor, "Reset to default")

This module owns, for every registry row and master knob:
  * ui.path: the pages below the package page (category included; the generator collapses single-category levels);
  * ui.row: the row text on the last page ("Squad", "Time between rewards");
  * ui.quick: the label on the Quick settings page (headline value per mission type, one on/off each);
  * ui.default_label: the default as the player sees it when the game value is a range or formula ("60-80 s");
  * ui.scope_text: one or two short plain sentences (no node lists, no MT_ codes, no internal ids);
  * ui.group: `<family>` for every category except Advanced, `<family>_advanced` for Advanced (sort order only);
  * ui.rank: the display order;
  * ui_groups[*].order: mission types alphabetical (Capture and Sentient Swarm Capture together, and so on).

Rows without an entry here (never shown in a full package) get [mission type, (sub-entry,) "Advanced"] and their label.
Run through player_text.py (it calls apply() after the R5 text); nothing here reads or writes a game or server folder.
"""
import re

LAYOUT_FORMAT = 'RENOVICE_MISSION_LAYOUT_V1'
CATEGORIES = ['Timers', 'Objectives', 'Enemies', 'Rewards / drops', 'Advanced']
PATH_MAX = 40
ROW_MAX = 33
QUICK_MAX = 40
DEFAULT_LABEL_MAX = 20
ROW_BUDGET = 40          # "<row>: <default> (default)" on the value row
DESCRIPTION_MAX = 200
PLAYERS = [('p1', 'Solo'), ('p2', 'Duo'), ('p3', 'Trio'), ('p4', 'Squad')]

# family -> (mission type, sub-entry or None, merged rank). Player-facing names only (never module names).
TYPES = {
    'alchemy': ('Alchemy', None), 'arbitration': ('Arbitration', None), 'archimedea': ('Archimedea', None),
    'archwing': ('Archwing', None), 'ascension': ('Ascension', None), 'capture': ('Capture', None),
    'circuit': ('The Circuit', None), 'coh_destroy_targets': ('Descendia', 'Destroy Targets'),
    'coh_excavation': ('Descendia', 'Excavation'), 'coh_nemesis': ('Descendia', 'Nemesis'),
    'cohinterception': ('Descendia', 'Mobile Interception'), 'colonistdoor': ('Colonist Door Defense', None),
    'control_area_plains': ('Control Area', 'Plains of Eidolon (Cetus)'),
    'control_area_deimos': ('Control Area', 'Cambion Drift (Deimos)'),
    'control_area_nokko': ('Control Area', 'Deepmines (below Fortuna)'),
    'defection': ('Defection', None), 'defense': ('Defense', None), 'disruption': ('Disruption', None),
    'entrati_swarm': ('Entrati Swarm', None), 'escalation': ('Exterminate', None), 'excavation': ('Excavation', None),
    'faceoff': ('Faceoff', None), 'fivefates': ('Five Fates', None), 'gamerules': ('All missions', None),
    'hijack': ('Hijack', None), 'infested_capture': ('Legacyte Harvest', None),
    'infested_salvage': ('Infested Salvage', None), 'interception': ('Interception', None), 'lantern': ('Lantern', None),
    'loopdefend': ('Mirror Defense', None), 'meltdown': ('Meltdown', None), 'mobiledefense': ('Mobile Defense', None),
    'multidefend': ('Hack-Station Defense', None), 'netracell': ('Netracell', None), 'orphix': ('Orphix Venom', None),
    'purgatory': ('Purgatory', None), 'purge': ('Purge', None), 'pursuit': ('Pursuit', None), 'raid': ('Raid', None),
    'rescue': ('Rescue', None), 'sentientcapture': ('Capture', None), 'sentientmd': ('Mobile Defense', None),
    'server': ('Server', None), 'shrine': ('Descendia', 'Shrine Defense'), 'spy': ('Spy', None),
    'survival': ('Survival', None), 'void_cascade': ('Void Cascade', None), 'void_flood': ('Void Flood', None),
    'wf1999def': ('Defense', None),
    # Contract R10 families (mission-owner research)
    'exterminate': ('Exterminate', None), 'sabotage': ('Sabotage', None), 'rush': ('Rush', None),
    'void_armageddon': ('Void Armageddon', None), 'assassination': ('Assassination', None),
    'onslaught': ('Sanctuary Onslaught', None),
    # Contract R11 (Railjack kill goals)
    'railjack': ('Railjack', None),
}
# Families merged into another family's mission type sort right after it.
# R10: the 1999 Escalation rows come first on the Exterminate page (its Timers category), the R10 kill-count rows follow.
MERGED = {'sentientcapture', 'sentientmd', 'wf1999def', 'exterminate'}

L = {}        # id -> {'path': [...], 'row': str, 'quick': str|None}
ORDER = []    # display order (rank)


def put(tid, path, row, quick=None):
    if tid in L:
        raise SystemExit(f'player_layout: {tid} placed twice')
    L[tid] = {'path': list(path), 'row': row, 'quick': quick}
    ORDER.append(tid)


def players(fmt, path, ids=None):
    for key, name in PLAYERS:
        put(ids[key] if ids else fmt.format(key), path, name)


# ---- Capture (+ Sentient Swarm Capture)
put('capture.bleedout_timer.grace', ['Capture', 'Timers'], 'Downed target grace time')  # R8 live literal
put('capture.bleedout_timer.fail_timer', ['Capture', 'Timers'], 'Escape timer when downed')  # R8 live literal
players('capture.target_health_player_mult.{}', ['Capture', 'Objectives', 'Target health'])
put('sentientcapture.swarm.area_swarm_size', ['Capture', 'Enemies'], 'Sentient swarm per area')

# ---- Colonist Door Defense
for n in (1, 2, 3):
    put(f'colonistdoor.navbridge_thresholds.b{n}', ['Colonist Door Defense', 'Advanced'], f'Bridge {n} trigger')

# ---- Control Area, by location
put('control_area_plains.duration', ['Control Area', 'Plains of Eidolon (Cetus)', 'Timers'], 'Hold-zone time',
    quick='Control Area (Plains): hold time')
put('control_area_deimos.duration', ['Control Area', 'Cambion Drift (Deimos)', 'Timers'], 'Hold-zone time',
    quick='Control Area (Cambion): hold time')
# R10: the Deepmines hold time is the encounter parameter `defendTime` (default 90 s); the old literal-rewrite row
# control_area_nokko.duration has no stock and is never declared (it stays the preset owner). Orb Vallis has no Control Area
# stage.
put('control_area_nokko.hold_time', ['Control Area', 'Deepmines (below Fortuna)', 'Timers'], 'Hold-zone time',
    quick='Control Area (Deepmines): hold time')
put('control_area_nokko.bonus_threshold', ['Control Area', 'Deepmines (below Fortuna)', 'Advanced'], 'Bonus control threshold')

# ---- Defection
put('defection.squads_required', ['Defection', 'Objectives'], 'Squads to rescue')  # R8 live literal
put('defection.squads_required.sortie', ['Defection', 'Objectives'], 'Sortie: squads to rescue')  # R8 live literal
players('defection.max_enemies.{}', ['Defection', 'Enemies', 'Max enemies at once'])
players('defection.max_sim_ai.max_{}', ['Defection', 'Enemies', 'Max enemies at once', 'Hard nodes'],
        ids={k: f'defection.max_sim_ai.max_{k}' for k, _ in PLAYERS})
players('defection.max_sim_ai.min_{}', ['Defection', 'Enemies', 'Max enemies at once', 'Easy nodes'],
        ids={k: f'defection.max_sim_ai.min_{k}' for k, _ in PLAYERS})

# ---- Defense
# R8 live literals: timers, waves to finish, the enemy-count masters (regular and Infested, both level ends) and their
# level 30+ rows; 1999 Defense drones (merged family).
put('defense.first_wave_delay', ['Defense', 'Timers'], 'Delay before first wave')
put('defense.inter_wave_sleep', ['Defense', 'Timers'], 'Time between waves')
put('wf1999def.drone_count.spawn_interval', ['Defense', 'Timers'], '1999: time between drones')
# R10: "Waves to finish" is the normal-node count (MissionInfo, written at mission start); the special-mission counts
# (fixed numbers in the Defense script) sit on their own page next to it.
put('defense.waves_to_finish', ['Defense', 'Objectives'], 'Waves to finish', quick='Defense: waves to finish')
# R12: the reward / extraction checkpoint interval (level parameter minWavesToComplete, written at the WaveDefense entry).
put('defense.waves_per_reward', ['Defense', 'Rewards / drops'], 'Waves per reward', quick='Defense: waves per reward')
for _tid, _row in (('special_mission_default_waves', 'Alert missions'), ('nightmare_wave_count', 'Nightmare'),
                   ('duviri_wave_count', 'Duviri'), ('circle_wave_count', 'Descendia')):
    put(f'defense.{_tid}', ['Defense', 'Objectives', 'Special-mission waves'], _row)
# R10: the regular, Infested and Duviri-min caps are addon values (flow-sensitive gate); every end of the level range shows.
players('defense.max_enemies.{}', ['Defense', 'Enemies', 'Max enemies at once'])
players('defense.simultaneous_enemies_max.{}', ['Defense', 'Enemies', 'Max enemies at once', 'Level 30 and up'])
players('defense.simultaneous_enemies_min.{}', ['Defense', 'Enemies', 'Max enemies at once', 'Lowest levels'])
players('defense.simultaneous_enemies_infested.max.{}', ['Defense', 'Enemies', 'Max enemies at once', 'Infested, level 30 and up'])
players('defense.simultaneous_enemies_infested.min.{}', ['Defense', 'Enemies', 'Max enemies at once', 'Infested, lowest levels'])
players('defense.simultaneous_enemies_duviri.max.{}', ['Defense', 'Enemies', 'Duviri: max enemies at once'])
players('defense.simultaneous_enemies_duviri.min.{}', ['Defense', 'Enemies', 'Duviri: max enemies at once', 'Lowest levels'])

# ---- Descendia: Destroy Targets, Shrine Defense
players('coh_destroy_targets.required_by_players.{}', ['Descendia', 'Destroy Targets', 'Objectives', 'Targets to destroy'])
put('coh_excavation.dig_duration', ['Descendia', 'Excavation', 'Timers'], 'Excavator dig time')  # R8 live literal
put('coh_nemesis.spawn_interval', ['Descendia', 'Nemesis', 'Timers'], 'Time between spawns')  # R8 live literal
put('shrine.stage_time.offering', ['Descendia', 'Shrine Defense', 'Timers'], 'Offering stage time')
SHRINE_STAGES = (('normal', 'offering', 'Offering stage'), ('normal', 'boss_part_2', 'Boss stage'),
                 ('sp', 'offering', 'Steel Path offering'), ('sp', 'boss_part_2', 'Steel Path boss'))
players('shrine.max_enemies.{}', ['Descendia', 'Shrine Defense', 'Enemies', 'Max enemies at once'])
for tier, stage, name in SHRINE_STAGES:
    for key, short in PLAYERS:
        put(f'shrine.max_enemies.{tier}.{stage}.{key}',
            ['Descendia', 'Shrine Defense', 'Enemies', 'Max enemies at once', name], f'Most at once ({short.lower()})')
    for key, short in PLAYERS:
        put(f'shrine.min_enemies.{tier}.{stage}.{key}',
            ['Descendia', 'Shrine Defense', 'Enemies', 'Max enemies at once', name], f'Refill below ({short.lower()})')
players('shrine.respawn_delay.{}', ['Descendia', 'Shrine Defense', 'Enemies', 'Time between waves'])
for tier, stage, name in SHRINE_STAGES:
    players(f'shrine.respawn_delay.{tier}.{stage}.{{}}', ['Descendia', 'Shrine Defense', 'Enemies', 'Time between waves', name])

# ---- Disruption
# R8 live literals: round timers and counts, the enemy-count masters and their per-variant upper counts.
put('disruption.round_timeout', ['Disruption', 'Timers'], 'Round time-out timer')
put('disruption.interval_between_rounds', ['Disruption', 'Timers'], 'Time between rounds')
put('disruption.interval_between_rounds.relic', ['Disruption', 'Timers'], 'Relics: between rounds')
put('disruption.default_round_count', ['Disruption', 'Objectives'], 'Rounds to finish')
put('disruption.sortie_round_count', ['Disruption', 'Objectives'], 'Sortie: rounds to finish')
players('disruption.max_enemies.{}', ['Disruption', 'Enemies', 'Max enemies at once'])
for _variant, _name in (('standard', 'Standard'), ('sentient', 'Sentient'), ('entrati_lab', 'Entrati lab')):
    players(f'disruption.max_enemies_by_players.{_variant}.{{}}', ['Disruption', 'Enemies', 'Max enemies at once', _name])
put('disruption.initial_spawn_delay', ['Disruption', 'Enemies'], 'First spawn delay')
put('disruption.boss_health_multiplier', ['Disruption', 'Advanced'], 'Boss health multiplier')
put('disruption.treasure_goblin.tier', ['Disruption', 'Advanced'], 'Lab: Demolyst tier')  # hidden (HIDE)

# ---- Entrati Swarm
for i in range(1, 6):  # R8 live literals
    put(f'entrati_swarm.tears_per_stage.stage{i}', ['Entrati Swarm', 'Objectives', 'Tears per stage'], f'Stage {i}')
for i in range(1, 6):
    put(f'entrati_swarm.tears_per_stage_challenge.stage{i}', ['Entrati Swarm', 'Objectives', 'Challenge: tears per stage'],
        f'Stage {i}')
for i in (1, 2, 3, 4):
    put(f'entrati_swarm.eximus_by_scale.cap.area{i}', ['Entrati Swarm', 'Advanced', 'Max Eximus at once'], f'Area {i}')
for i in (1, 2, 3, 4):
    put(f'entrati_swarm.eximus_by_scale.chance.area{i}', ['Entrati Swarm', 'Advanced', 'Eximus chance'], f'Area {i}')

# ---- Excavation (the master drives the three variants; the literal rows are built from it, never declared)
put('excavation.dig_time', ['Excavation', 'Timers'], 'Excavator dig time', quick='Excavation: dig time')
put('excavation.excavators_to_finish', ['Excavation', 'Objectives'], 'Excavators to finish')  # R10
put('excavation.dig_duration', ['Excavation', 'Timers', 'Dig time by variant'], 'Standard')
put('excavation.dig_duration_elite_alert', ['Excavation', 'Timers', 'Dig time by variant'], 'Elite Alert')
put('excavation.dig_duration_old_world_salvage', ['Excavation', 'Timers', 'Dig time by variant'], 'Old World Salvage')
put('excavation.duviri_excavation_count', ['Excavation', 'Objectives'], 'Duviri: excavations')  # R8 live literal

# ---- Exterminate (R10 kill count parameters) and 1999 Escalation
put('exterminate.kills_scale', ['Exterminate', 'Objectives'], 'Kills needed', quick='Exterminate: kills needed')
put('exterminate.archwing_kill_mult', ['Exterminate', 'Advanced'], 'Archwing kill factor')
put('escalation.crate_timer', ['Exterminate', 'Timers'], 'Escalation: crate timer')  # R8 live literal
players('escalation.keys_per_players.{}', ['Exterminate', 'Objectives', '1999 Escalation: keys needed'])

# ---- Faceoff
put('faceoff.defense_escort.initial_defense_time', ['Faceoff', 'Timers'], 'Defense timer')
put('faceoff.defense_escort.initial_escort_time', ['Faceoff', 'Timers'], 'Escort timer')
put('faceoff.excavation.excavation_time', ['Faceoff', 'Timers'], 'Excavation timer')
put('faceoff.exterminate_kills', ['Faceoff', 'Objectives', 'Exterminate: kills needed'], 'Fixed number')
put('faceoff.exterminate_kill_goal.max', ['Faceoff', 'Objectives', 'Exterminate: kills needed'], 'Random range: highest')
put('faceoff.exterminate_kill_goal.min', ['Faceoff', 'Objectives', 'Exterminate: kills needed'], 'Random range: lowest')
put('faceoff.delivery.target_goal_keys', ['Faceoff', 'Objectives'], 'Delivery: keys to deliver')
put('faceoff.delivery.enemy_kill_goal', ['Faceoff', 'Objectives'], 'Delivery: kills per key')
put('faceoff.assassination.kill_goal', ['Faceoff', 'Objectives'], 'Assassination: targets')
players('faceoff.max_enemies.{}', ['Faceoff', 'Enemies', 'Max enemies at once'])
players('faceoff.spawn_params.maxenemies_{}', ['Faceoff', 'Enemies', 'Max enemies at once', 'Level 30 and up'],
        ids={k: f'faceoff.spawn_params.maxenemies_{k}' for k, _ in PLAYERS})
players('faceoff.spawn_params.minenemies_{}', ['Faceoff', 'Enemies', 'Max enemies at once', 'Lowest level'],
        ids={k: f'faceoff.spawn_params.minenemies_{k}' for k, _ in PLAYERS})
players('faceoff.assassination.enemy_health_mult_{}', ['Faceoff', 'Advanced', 'Assassination target health'],
        ids={k: f'faceoff.assassination.enemy_health_mult_{k}' for k, _ in PLAYERS})
for page, tid, row in (('Escort objective', 'faceoff.defense_escort.catalysts_spawn_time', 'Catalyst spawn time'),
                       ('Escort objective', 'faceoff.defense_escort.min_catalysts', 'Fewest catalysts'),
                       ('Escort objective', 'faceoff.defense_escort.max_catalysts', 'Most catalysts'),
                       ('Escort objective', 'faceoff.defense_escort.catalyst_bonus_time_pct', 'Catalyst time bonus'),
                       ('Delivery objective', 'faceoff.delivery.max_keys', 'Keys at once'),
                       ('Delivery objective', 'faceoff.delivery.key_self_destruction_time', 'Key self-destruct time'),
                       ('Delivery objective', 'faceoff.delivery.eximus_chance', 'Eximus chance'),
                       ('Excavation objective', 'faceoff.excavation.carrier_spawn_time', 'Carrier spawn time'),
                       ('Excavation objective', 'faceoff.excavation.decreased_time_per_cell', 'Time cut per cell'),
                       ('Excavation objective', 'faceoff.excavation.max_num_cells_available', 'Cells at once'),
                       ('Excavation objective', 'faceoff.excavation.max_power', 'Most power'),
                       ('Excavation objective', 'faceoff.excavation.power_drain_rate', 'Power drain per second'),
                       ('Excavation objective', 'faceoff.excavation.power_per_cell', 'Power per cell'),
                       ('Enemy spawns', 'faceoff.spawn_params.tier_up_interval', 'Tiers per objective step'),
                       ('Enemy spawns', 'faceoff.spawn_params.max_tier', 'Highest enemy tier'),
                       ('Enemy spawns', 'faceoff.spawn_params.min_spawn_dist', 'Nearest spawn distance'),
                       ('Enemy spawns', 'faceoff.spawn_params.max_spawn_dist', 'Farthest spawn distance')):
    put(tid, ['Faceoff', 'Advanced', page], row)

# ---- Five Fates (Cetus)
for n, name in ((1, 'Offering'), (2, 'Defend huts'), (3, 'Swarm'), (4, 'Boss part 1'), (5, 'Boss part 2')):
    put(f'fivefates.state_times.state{n}', ['Five Fates', 'Timers'], f'{name} stage time')

# ---- Infested Salvage
players('infested_salvage.spawn_caps_by_players.max_ai.{}', ['Infested Salvage', 'Enemies', 'Max enemies at once'])
players('infested_salvage.spawn_caps_by_players.spawn_delay.{}', ['Infested Salvage', 'Enemies', 'Time between spawns'])
players('infested_salvage.spawn_caps_by_players.max_source_ai.{}', ['Infested Salvage', 'Advanced', 'Enemies per spawn point'])

# ---- Lantern
put('lantern.tier_up_interval', ['Lantern', 'Timers'], 'Enemy tier-up time')
put('lantern.extraction_limit', ['Lantern', 'Timers'], 'Time to extract')  # R8 live literal
put('lantern.boss_spawn_time', ['Lantern', 'Timers'], 'Boss arrives after')  # R8 live literal
put('lantern.min_score', ['Lantern', 'Objectives'], 'Score to win')  # R8 live literal
players('lantern.num_enemies.{}', ['Lantern', 'Enemies', 'Max enemies at once'])
players('lantern.radius_per_kill.{}', ['Lantern', 'Advanced', 'Lamp radius per kill'])
put('lantern.max_tier', ['Lantern', 'Advanced'], 'Highest enemy tier')
for c in ('b', 'm', 'p', 'v'):
    put(f'lantern.lamp_decay.{c}', ['Lantern', 'Advanced', 'Lamp fade curve'], f'Value {c}')

# ---- Mirror Defense
put('loopdefend.phase_duration', ['Mirror Defense', 'Timers'], 'Time per phase')  # R8 live literal
put('loopdefend.phase_duration_jade', ['Mirror Defense', 'Timers'], 'Jade: time per phase')  # R8 live literal
put('loopdefend.phases_to_finish', ['Mirror Defense', 'Objectives'], 'Phases to finish')  # R10
players('loopdefend.max_enemies.{}', ['Mirror Defense', 'Enemies', 'Max enemies at once'])
for key, name in (('maxNum', 'Most (regular)'), ('minNum', 'Fewest (regular)'), ('maxNumInfested', 'Most (Infested)'),
                  ('minNumInfested', 'Fewest (Infested)')):
    players(f'loopdefend.enemy_counts.{key}.{{}}', ['Mirror Defense', 'Enemies', 'Max enemies at once', name])
CRYSTAL = ['Mirror Defense', 'Advanced', 'Crystal clusters']
for key, short in PLAYERS:
    put(f'loopdefend.crystal_cluster.enemyKillCountThreshold.{key}', CRYSTAL, f'Kills per cluster ({short.lower()})')
for tid, row in (('groupsToSpawnAtWaveStart', 'Groups at phase start'), ('groupsToSpawnPerKillThreshold', 'Groups per kill goal'),
                 ('clusterSpawnCooldown', 'Cluster cooldown'), ('flashingTimeBeforeDespawn', 'Flash before despawn'),
                 ('enemyKillOnTunnelInterval', 'Tunnel kill interval')):
    put(f'loopdefend.crystal_cluster.{tid}', CRYSTAL, row)
TARGET = ['Mirror Defense', 'Advanced', 'Target damage and pickups']
for tid, row in (('objectiveDamage', 'Base damage over time'), ('pauseDotTime', 'Pause after pickup'),
                 ('damagePerPickup', 'Damage per pickup'), ('healPercentage', 'Pickup heal fraction'),
                 ('pickupSpawnRateModifier', 'Pickup spawn rate'), ('pickupThresholdModifier', 'Pickup threshold')):
    put(f'loopdefend.objective_dot.{tid}', TARGET, row)
LEVEL = ['Mirror Defense', 'Advanced', 'Enemy level']
for tid, row in (('levelUpTime', 'Time to reach max level'), ('enrageTime', 'Extra levels start at'),
                 ('enrageInterval', 'Seconds per extra level'), ('enrageIntervalMin', 'Fastest seconds per level'),
                 ('enrageIntervalScale', 'Extra level speed-up'), ('alertLevelMaxBoost', 'Alert missions: level boost'),
                 ('sortieLevelMaxBoost', 'Sortie: level boost')):
    put(f'loopdefend.level_and_enrage.{tid}', LEVEL, row)
EXIMUS = ['Mirror Defense', 'Advanced', 'Eximus']
for tid, row in (('exStartTime', 'Ramp start'), ('exPeakTime', 'Ramp peak'), ('exMinChance', 'Chance at start'),
                 ('exMaxChance', 'Chance at peak'), ('override_exPeakTime', 'Event: ramp peak'),
                 ('override_exMinChance', 'Event: chance at start'), ('override_exMaxChance', 'Event: chance at peak')):
    put(f'loopdefend.eximus.{tid}', EXIMUS, row)
players('loopdefend.eximus.override_ex_max_spawn.{}', EXIMUS + ['Event: max Eximus at once'])

# ---- Mobile Defense (+ Sentient Mobile Defense)
put('mobiledefense.time_per_terminal', ['Mobile Defense', 'Timers'], 'Time per terminal',
    quick='Mobile Defense: time per terminal')
put('mobiledefense.total_time.maximum', ['Mobile Defense', 'Timers', 'Total terminal time'], 'Hard nodes')
put('mobiledefense.total_time.minimum', ['Mobile Defense', 'Timers', 'Total terminal time'], 'Easy nodes')
put('sentientmd.defend_time', ['Mobile Defense', 'Timers'], 'Sentient: time per area')  # R8 live literal
put('mobiledefense.console_count', ['Mobile Defense', 'Objectives'], 'Terminals per mission')  # R8 live literal
put('sentientmd.area_count', ['Mobile Defense', 'Objectives'], 'Sentient: areas to defend')  # R8 live literal
players('mobiledefense.max_enemies.{}', ['Mobile Defense', 'Enemies', 'Max enemies at once'])
players('mobiledefense.enemy_counts.max.{}', ['Mobile Defense', 'Enemies', 'Max enemies at once', 'Hard nodes'])
players('mobiledefense.enemy_counts.min.{}', ['Mobile Defense', 'Enemies', 'Max enemies at once', 'Easy nodes'])
players('sentientmd.max_sim_ai.{}', ['Mobile Defense', 'Enemies', 'Sentient Anomaly: max enemies'])

# ---- Orphix Venom
put('orphix.spawn_interval', ['Orphix Venom', 'Timers', 'Time between Orphix spawns'], 'All variants',
    quick='Orphix Venom: time between spawns')
put('orphix.orphix_interval.interval', ['Orphix Venom', 'Timers', 'Time between Orphix spawns'], 'Normal')
put('orphix.orphix_interval.eventInterval', ['Orphix Venom', 'Timers', 'Time between Orphix spawns'], 'Orphix event')
put('orphix.max_rounds_railjack', ['Orphix Venom', 'Objectives'], 'Railjack: round limit')
put('orphix.sortie_rounds', ['Orphix Venom', 'Objectives'], 'Sortie: rounds to finish')  # R8 live literal
put('orphix.orphix_interval.condrixCap', ['Orphix Venom', 'Enemies'], 'Max Orphix at once')
put('orphix.reward_interval', ['Orphix Venom', 'Rewards / drops'], 'Rounds per reward')
put('orphix.score_add_per_round', ['Orphix Venom', 'Advanced'], 'Score per round')

# ---- Purgatory
# R8 live literals: timers, enemy cap, and the spawn-interval master over its random range.
put('purgatory.initial_time', ['Purgatory', 'Timers'], 'Starting time')
put('purgatory.pickup_time_bonus', ['Purgatory', 'Timers'], 'Time per pickup')
put('purgatory.enemy_cap', ['Purgatory', 'Enemies'], 'Max enemies at once')
put('purgatory.spawn_interval', ['Purgatory', 'Enemies'], 'Time between spawns')
put('purgatory.spawn_interval.min', ['Purgatory', 'Enemies', 'Spawn time range'], 'Shortest')
put('purgatory.spawn_interval.max', ['Purgatory', 'Enemies', 'Spawn time range'], 'Longest')
for i in range(1, 7):
    put(f'purgatory.reward_kill_threshold.t{i}', ['Purgatory', 'Rewards / drops', 'Kills for reward tier'], f'Tier {i}')
for i in (1, 2, 3):
    for tid, row in (('warrior_level', 'Warrior level'), ('ghost_level', 'Ghost level'), ('damage_mult', 'Enemy damage')):
        put(f'purgatory.difficulty{i}.{tid}', ['Purgatory', 'Advanced', f'Difficulty {i}'], row)

# ---- Purge
put('purge.max_enemy_count', ['Purge', 'Objectives'], 'Enemies to kill')  # R8 live literal
for i in (1, 2, 3):
    put(f'purge.alert_tiers.tier{i}_multiplier', ['Purge', 'Advanced', 'Alert missions: spawn speed'], f'Tier {i}')

# ---- Survival
put('survival.reward_interval', ['Survival', 'Timers'], 'Time between rewards', quick='Survival: time between rewards')
put('survival.alert_interval', ['Survival', 'Timers'], 'Alert mission length')
put('survival.fixed_length_minutes', ['Survival', 'Timers'], 'Fixed length')  # R10
put('survival.duviri_fixed_length', ['Survival', 'Timers'], 'Duviri: Survival length')  # R8 live literal
LIFE = ['Survival', 'Timers', 'Life support']
for tid, row in (('capsule_initial_time', 'At mission start'), ('capsule_max_time', 'Capacity at 100%'),
                 ('capsule_time_added', 'Added per capsule'), ('pickup_time_added', 'Added per pickup'),
                 ('capsule_interval', 'Time between capsules'), ('capsule_incoming_time', 'Capsule warning time'),
                 ('player_damage_at_zero_ls.killPlayerTime', 'Time at 0% before death')):
    put(f'survival.{tid}', LIFE, row)
DROPS = ['Survival', 'Rewards / drops']
for tid, row in (('pickup_drop_low_high_mult.lowDropMultiplier', 'Pickup drops when low'),
                 ('pickup_drop_low_high_mult.lowSpawnThreshold', 'Low life support mark'),
                 ('pickup_drop_low_high_mult.highDropMultiplier', 'Pickup drops when high'),
                 ('pickup_drop_low_high_mult.highSpawnThreshold', 'High life support mark'),
                 ('alert_ls_drop_mult', 'Alert: pickup drops'), ('duviri_drop_mults.duviriSurvivalMultiplier', 'Duviri: pickup drops'),
                 ('duviri_drop_mults.duviriQuestMultiplier', 'Duviri quest: drops'),
                 ('wf99_drop_mults.wf99SurvivalMultiplier', '1999: pickup drops'),
                 ('wf99_drop_mults.wf99SurvivalQuestMultiplier', '1999 quest: pickup drops')):
    put(f'survival.{tid}', DROPS, row)
put('survival.pickup_reward_progress', ['Survival', 'Advanced'], 'Reward clock per pickup')
put('survival.player_damage_at_zero_ls.playerDamagePercent', ['Survival', 'Advanced'], 'Damage at 0%')
SLEVEL = ['Survival', 'Advanced', 'Enemy level']
for tid, row in (('level_up_enrage.levelUpTime', 'Time to reach max level'),
                 ('level_up_enrage.enrageTime', 'Extra levels start at'),
                 ('level_up_enrage.enrageInterval', 'Seconds per extra level'),
                 ('level_up_enrage.enrageIntervalMin', 'Fastest seconds per level'),
                 ('level_up_enrage.enrageIntervalScale', 'Extra level speed-up'),
                 ('kuva_level_enrage.levelUpTime', 'Kuva: time to max level'),
                 ('kuva_level_enrage.enrageTime', 'Kuva: extra levels at'),
                 ('level_max_boost.alertLevelMaxBoost', 'Alert missions: level boost'),
                 ('level_max_boost.sortieLevelMaxBoost', 'Sortie: level boost')):
    put(f'survival.{tid}', SLEVEL, row)

# ---- Void Cascade
put('void_cascade.pillar_duration', ['Void Cascade', 'Timers'], 'Exolizer defense time',
    quick='Void Cascade: exolizer defense time')
put('void_cascade.exolizers_to_finish', ['Void Cascade', 'Objectives'], 'Exolizers to finish')  # R10
players('void_cascade.circle_fixed_length.{}', ['Void Cascade', 'Objectives', 'The Circuit: exolizers to finish'])
put('void_cascade.alert_reward_interval', ['Void Cascade', 'Rewards / drops'], 'Alert: reward interval')

# ---- Void Flood
# R14: the fill_timer values time the corruption meter, not the tanks (rows renamed; ids unchanged).
put('void_flood.fill_timer.timeToFillMax', ['Void Flood', 'Timers'], 'Corruption meter time')
put('void_flood.fill_timer.timeToFillMin', ['Void Flood', 'Timers'], 'Shortest meter time')
put('void_flood.fractures_per_round.normal', ['Void Flood', 'Objectives'], 'Fractures per round',
    quick='Void Flood: fractures per round')
put('void_flood.tanks_to_finish', ['Void Flood', 'Objectives'], 'Tanks to finish')  # R10
# R14: tank multipliers (scaled root-table fields of the Void Flood config tables).
put('void_flood.deposit_speed_scale', ['Void Flood', 'Objectives'], 'Tank fill speed', quick='Void Flood: tank fill speed')
put('void_flood.tank_capacity_scale', ['Void Flood', 'Objectives'], 'Tank capacity')
put('void_flood.orb_value_scale', ['Void Flood', 'Objectives'], 'Void orb value')
put('void_flood.drain_speed_scale', ['Void Flood', 'Objectives'], 'Tank drain speed')
put('void_flood.fill_timer.curveScaleV', ['Void Flood', 'Advanced'], 'Meter time shrink')
put('void_flood.curse_count.curseCountNormal', ['Void Flood', 'Advanced'], 'Curses')
put('void_flood.curse_count.curseCountSteelPath', ['Void Flood', 'Advanced'], 'Steel Path: curses')
put('void_flood.curse_count.playerCapacity', ['Void Flood', 'Advanced'], 'Void energy capacity')
put('void_flood.fractures_per_round.shadowgrapher', ['Void Flood', 'Advanced'], 'Shadowgrapher: fractures')

put('void_flood.fractures_per_round.duviri', ['Void Flood', 'Objectives'], 'Duviri: fractures per round')  # R8 live literal

# ---- R8 live literals of mission types without an addon value (contract R8/R9, merged 2026-09-30)
put('arbitration.resurrection_score_cap', ['Arbitration', 'Advanced'], 'Max resurrection score')
for _tid, _row in (('eda_survival_minutes', 'Survival length'), ('eda_alchemy', 'Alchemy mixtures'),
                   ('eda_disruption', 'Disruption conduits'), ('eda_mirror_defense_waves', 'Mirror Defense phases')):
    put(f'archimedea.{_tid}', ['Archimedea', 'Objectives', 'Deep Archimedea'], _row)
for _tid, _row in (('eta_survival_minutes', 'Survival length'), ('eta_defense_waves', 'Defense waves')):
    put(f'archimedea.{_tid}', ['Archimedea', 'Objectives', 'Temporal Archimedea'], _row)
put('archwing.fomorian_emp_timer', ['Archwing', 'Timers'], 'Fomorian EMP countdown')
put('multidefend.defend_time', ['Hack-Station Defense', 'Timers'], 'Time per station')
for _tid, _row in (('min_d0', 'Easy nodes: shortest'), ('max_d0', 'Easy nodes: longest'),
                   ('min_d1', 'Hard nodes: shortest'), ('max_d1', 'Hard nodes: longest')):
    put(f'multidefend.defend_time.{_tid}', ['Hack-Station Defense', 'Timers', 'Time per station by node'], _row)
put('multidefend.station_count', ['Hack-Station Defense', 'Objectives'], 'Stations to defend')
put('hijack.payload_health', ['Hijack', 'Objectives'], 'Payload health')
put('hijack.payload_health.goal_mission', ['Hijack', 'Objectives'], 'Goal missions: health')
put('netracell.power_required.base', ['Netracell', 'Objectives'], 'Power required')
put('netracell.power_required.per_extra_player', ['Netracell', 'Objectives'], 'Power per extra player')
put('pursuit.phase_timer', ['Pursuit', 'Timers'], 'Defend-ship phase time')

# ---- Contract R10 (mission-owner research, 2026-09-30)
put('interception.round_end_timer', ['Interception', 'Timers'], 'Time between rounds')
put('interception.score_goal_scale', ['Interception', 'Objectives'], 'Score to win',
    quick='Interception: score to win')
put('interception.rounds_to_finish', ['Interception', 'Objectives'], 'Rounds to finish')
put('interception.scoring_speed', ['Interception', 'Advanced'], 'Scoring speed')
put('spy.vault_alarm_scale', ['Spy', 'Timers'], 'Alarm time', quick='Spy: vault alarm time')
put('spy.vaults_required', ['Spy', 'Advanced'], 'Vaults required')
put('rescue.hostage_timer.easy', ['Rescue', 'Timers', 'Hostage timer'], 'Easiest nodes')
put('rescue.hostage_timer.hard', ['Rescue', 'Timers', 'Hostage timer'], 'Hardest nodes')
for _tid, _row in (('high_scaling', 'High scaling'), ('mutated', 'Mutated enemies'), ('double', 'Double trouble'),
                   ('descendia', 'Descendia')):
    put(f'infested_capture.required_captures.{_tid}', ['Legacyte Harvest', 'Objectives', 'Captures to finish'], _row)
put('sabotage.reactor_extract_timer', ['Sabotage', 'Timers'], 'Ship escape timer')
put('sabotage.gascity_hack_time', ['Sabotage', 'Timers'], 'Gas City: meltdown time')
put('sabotage.orokin_charge_time', ['Sabotage', 'Timers'], 'Orokin: charge time')
put('sabotage.orokin_escape_timer', ['Sabotage', 'Timers'], 'Orokin: escape timer')  # R11 coupled literal
put('sabotage.forest_defend_time', ['Sabotage', 'Timers'], 'Forest: injector time')
put('sabotage.trenchrun_timer', ['Sabotage', 'Timers'], 'Archwing: time limit')
put('sabotage.trenchrun_enemy_cap', ['Sabotage', 'Enemies'], 'Archwing: enemies')
put('sabotage.gascity_meltdown_scale.easy', ['Sabotage', 'Advanced', 'Gas City meltdown factor'], 'Easiest nodes')
put('sabotage.gascity_meltdown_scale.hard', ['Sabotage', 'Advanced', 'Gas City meltdown factor'], 'Hardest nodes')
put('sabotage.random_extraction_timer', ['Sabotage', 'Advanced'], 'Surprise extraction')
put('rush.pace_speed', ['Rush', 'Timers'], 'Pace speed')
put('void_armageddon.wave_time', ['Void Armageddon', 'Timers'], 'Wave time', quick='Void Armageddon: wave time')
put('void_armageddon.pre_wave_time', ['Void Armageddon', 'Timers'], 'Time before a wave')
put('void_armageddon.post_wave_time', ['Void Armageddon', 'Timers'], 'Time after a wave')
put('void_armageddon.prepare_time', ['Void Armageddon', 'Timers'], 'Round prepare time')
put('void_armageddon.round_complete_time', ['Void Armageddon', 'Timers'], 'Time between rounds')
put('void_armageddon.waves_per_round', ['Void Armageddon', 'Objectives'], 'Waves per round')
players('void_armageddon.kills_per_wave.{}', ['Void Armageddon', 'Objectives', 'Kills per wave'])
players('void_armageddon.max_enemies.{}', ['Void Armageddon', 'Enemies', 'Max enemies at once'])
put('void_armageddon.reward_interval', ['Void Armageddon', 'Rewards / drops'], 'Rounds per reward')
put('void_armageddon.angel_channel_time', ['Void Armageddon', 'Advanced'], 'Angel channel time')
put('gamerules.extraction_countdown_endless', ['All missions', 'Timers'], 'Extraction (endless)')
put('onslaught.zone_time', ['Sanctuary Onslaught', 'Timers'], 'Zone time')
put('onslaught.efficiency_per_kill', ['Sanctuary Onslaught', 'Objectives', 'Efficiency gained'], 'Normal kill')
put('onslaught.efficiency_per_special_kill', ['Sanctuary Onslaught', 'Objectives', 'Efficiency gained'], 'Special kill')
put('onslaught.efficiency_per_pickup', ['Sanctuary Onslaught', 'Objectives', 'Efficiency gained'], 'Time pickup')
put('onslaught.zones_per_reward', ['Sanctuary Onslaught', 'Rewards / drops'], 'Zones per reward')
put('onslaught.efficiency_max', ['Sanctuary Onslaught', 'Advanced'], 'Efficiency for 100%')
for _key, _row in (('p2', 'Duo'), ('p3', 'Trio'), ('p4', 'Squad')):
    put(f'assassination.kela_health.{_key}', ['Assassination', 'Enemies', 'Kela De Thaym health'], _row)
put('assassination.boss_level_bonus', ['Assassination', 'Enemies'], 'Boss level bonus')
put('assassination.hard_mode_level_base', ['Assassination', 'Advanced'], 'Hard-mode boss level')
put('assassination.hard_mode_level_per_player', ['Assassination', 'Advanced'], 'Hard-mode level per player')
put('assassination.ambulas_level_per_player', ['Assassination', 'Advanced'], 'Ambulas level per player')

# ---- Contract R11 (2026-09-30): Railjack kill goals (encounter parameters scaled at the objective / patrol entry)
put('railjack.fighter_kills_scale', ['Railjack', 'Objectives'], 'Fighters to kill', quick='Railjack: fighters to kill')
put('railjack.crewship_kills_scale', ['Railjack', 'Objectives'], 'Crewships to kill')
put('railjack.corpus_fighter_limit_scale', ['Railjack', 'Objectives'], 'Corpus fighters')

# ------------------------------------------------------------------------------------------------ descriptions
# R7 tooltips: one or two short plain sentences; no stock number (the row shows the default), no precedence jargon, no
# script constant names, node lists or MT codes. Built from the R5 text (player_text.py) with these rules, then OVERRIDE.
MASTER_SENTENCE = 'the variants below override it'
# R9 (contract CONTRACT_PHASE1.md Revision R9, merged R7 + R8): a live literal master whose driven rows hold different
# numbers (a range or formula default, "60-80 s") sets every driven row to (typed value x scale): one number replaces
# the whole range. At its declared stock the module stays stock (the range), so the row shows the range as its default.
RANGE_SENTENCE = 'a number you type replaces the whole range'
VARIANT_SENTENCE = 'overrides the value above for this case'
UNTRACED = 'its exact effect is not confirmed in the game code'
OVERRIDE = {    # id -> full description
    'survival.pickup_reward_progress': 'Old preset option, not a game value: seconds added to the reward clock per pickup '
                                       '(0 = off).',
    'disruption.boss_health_multiplier': 'Health multiplier of the Disruption boss in the Double Trouble variant.',
    'survival.reward_interval': 'Seconds between rewards in endless Survival, including Steel Path, Kuva and Void Eclipse. '
                                'Alert missions end at the alert mission length instead.',
    'faceoff.exterminate_kills': 'Kills to finish the Faceoff Exterminate objective (the game picks a random number between '
                                 'the two ends below). This sets both ends; an end you change keeps its value.',
    'mobiledefense.time_per_terminal': 'Upload time of each Mobile Defense terminal. The default depends on node difficulty '
                                       '(78-104 s on Archwing against Grineer); a number you type applies on every node.',
    'excavation.dig_time': 'Seconds each excavator digs in every Excavation variant. The default is 100 s (140 s on Elite '
                           'Alerts and 60 s in Old World Salvage); a number you type applies to all three.',
    'faceoff.spawn_params.tier_up_interval': 'Enemy tiers gained per Faceoff objective step (the highest tier is 5).',
    'void_cascade.pillar_duration': 'Seconds each exolizer must be defended in Void Cascade. The Circuit uses its own timer.',
    'purgatory.reward_kill_threshold.t1': 'Kills for reward tier 1 in the Granum Void. Solo earns at tiers 1 to 3; each extra '
                                          'player moves the rewards up one tier.',
    # R12 (user wording, 2026-10-01). The editor tooltip adds "Default 3." itself, so the description does not repeat it.
    'defense.waves_to_finish': '0 / Endless = keep going as long as you like; a number ends the mission after that wave. '
                               'Alerts, sorties and other special missions keep their own count.',
    'defense.waves_per_reward': 'Waves between each reward and extraction choice.',
    # R14 (2026-10-01): Void Flood tanks. The editor tooltip adds "Default x1 (...)." itself.
    'void_flood.deposit_speed_scale': 'How fast a tank fills while a player stands at it with Void energy: x2 fills it twice '
                                      'as fast. One player fills an empty tank in 8 to 14 s at the default (longer in bigger squads).',
    'void_flood.tank_capacity_scale': 'Void energy each tank needs and the most energy a player can carry (125 solo up to 350 '
                                      'in a squad). The standing time per tank stays the same.',
    'void_flood.orb_value_scale': 'Void energy each small, medium and large Void orb gives (5 to 60 at the default). Applies '
                                  'from the next mission.',
    'void_flood.drain_speed_scale': 'Energy a partly filled tank loses every 10 s while nobody is at it, only under the '
                                    'Decaying curse (8% of the tank at the default). 0 = no drain.',
    # R14: these time the corruption meter (it rises while a tank is open; full = eruption countdown), not the tanks.
    'void_flood.fill_timer.timeToFillMax': 'Seconds for the corruption meter to fill while a tank is open; when it is full '
                                           'the eruption countdown starts. It shrinks every 3 fractures down to the shortest '
                                           'meter time.',
    'void_flood.fill_timer.timeToFillMin': 'Shortest time the corruption meter can take to fill.',
    'void_flood.fill_timer.curveScaleV': 'Factor applied to the corruption meter time every 3 fractures.',
    'void_flood.curse_count.playerCapacity': 'Void energy a player can carry in the Shadowgrapher variant. Normal Void Flood '
                                             'uses the tank capacity instead.',
}
for _i in range(2, 7):
    OVERRIDE[f'purgatory.reward_kill_threshold.t{_i}'] = OVERRIDE['purgatory.reward_kill_threshold.t1'].replace('tier 1 in', f'tier {_i} in')
# Registry fields corrected by the 2026-09-30 defaults audit (meaning, unit).
UNIT = {'faceoff.spawn_params.tier_up_interval': ''}
# Values the audit found unsafe to offer: never declared (reason recorded in ui.hidden).
HIDE = {'disruption.treasure_goblin.tier': 'defaults audit 2026-09-30: an id the game matches against the mission enemy list, '
                                           'not a strength; any other value switches treasure Demolysts off'}
# R10: control_area_nokko.duration (the carried-over literal-rewrite preset row, no registered stock, never declared) stays
# the owner of the 'control_area_nokko' preset; SCRIPT SETTINGS shows control_area_nokko.hold_time (encounter parameter
# defendTime, default 90 s) on that page instead.
# Defaults audit (2026-09-30, 294 values against the 44.0.2 decompile: 262 single numbers, 32 ranges or formulas, no
# stock wrong). `label`: the default as the player sees it (the row shows it instead of the one stock number); `note`:
# the phrase the tooltip adds.
DEFAULTS = {}
for _key, _label in (('p1', '7-10'), ('p2', '12-16'), ('p3', '17-22'), ('p4', '22-28')):
    DEFAULTS[f'defection.max_enemies.{_key}'] = {'label': _label, 'note': 'Depends on node difficulty'}
for _key in ('p1', 'p2', 'p3', 'p4'):
    DEFAULTS[f'defense.simultaneous_enemies_duviri.max.{_key}'] = {
        'label': None, 'note': 'Fewer below enemy level 30; Steel Path uses the squad value'}
for _key, _label in (('p1', '7-20'), ('p2', '9-25'), ('p3', '14-30'), ('p4', '19-35')):
    DEFAULTS[f'shrine.max_enemies.{_key}'] = {'label': _label, 'note': 'Depends on the stage and Steel Path'}
for _key, _label in (('p1', '9-15 s'), ('p2', '9-14 s'), ('p3', '8-13 s'), ('p4', '7-12 s')):
    DEFAULTS[f'shrine.respawn_delay.{_key}'] = {'label': _label, 'note': 'Depends on the stage and Steel Path'}
DEFAULTS['excavation.dig_time'] = {'label': '60-140 s', 'note': '100 s normally, 140 s on Elite Alerts and 60 s in Old World Salvage'}
DEFAULTS['faceoff.exterminate_kills'] = {'label': '130-160', 'note': 'The game picks a random number in this range'}
for _key in ('p1', 'p2', 'p3'):
    DEFAULTS[f'faceoff.max_enemies.{_key}'] = {'label': None, 'note': 'Steel Path uses the squad value'}
for _key, _label in (('p1', '8-18'), ('p2', '15-25'), ('p3', '25-30'), ('p4', '30-35')):
    DEFAULTS[f'loopdefend.max_enemies.{_key}'] = {'label': _label, 'note': 'Steel Path uses the squad value'}
DEFAULTS['mobiledefense.time_per_terminal'] = {'label': '60-80 s', 'note': 'Depends on node difficulty (78-104 s on Archwing against Grineer)'}
DEFAULTS['orphix.spawn_interval'] = {'label': None, 'note': 'The default is 50 s, 90 s during the Orphix Venom event'}
DEFAULTS['survival.alert_interval'] = {'label': None, 'note': 'Used only when the mission sets no length (then mission minutes x 60)'}

DEFAULTS['survival.capsule_interval'] = {'label': None, 'note': 'Duviri Survival likely uses its own value'}
DEFAULTS['survival.pickup_time_added'] = {'label': None, 'note': 'Duviri Survival likely uses its own value'}
DEFAULTS['void_flood.fractures_per_round.normal'] = {'label': None, 'note': 'Duviri Void Flood uses 5'}
DEFAULTS['control_area_plains.duration'] = {'label': None, 'note': 'Cetus and Narmer bounties on the Plains'}
DEFAULTS['control_area_deimos.duration'] = {'label': None, 'note': 'Necralisk bounties, including endless Area Defense'}

# Contract R10 defaults. Counts written into the mission info: the default 0 keeps the game's own rule (endless on normal
# nodes). Script-parameter scales: x1 keeps the value the map or encounter passes.
_SPECIAL = 'Alerts, sorties and other special missions keep their own count'
for _tid in ('defense.waves_to_finish', 'interception.rounds_to_finish', 'excavation.excavators_to_finish',
             'loopdefend.phases_to_finish', 'void_flood.tanks_to_finish', 'void_cascade.exolizers_to_finish'):
    DEFAULTS[_tid] = {'label': 'Endless', 'note': _SPECIAL}
DEFAULTS['survival.fixed_length_minutes'] = {'label': 'Endless', 'note': 'At most 60 minutes; alerts, sorties and other special missions keep their own length'}
DEFAULTS['spy.vaults_required'] = {'label': 'Game rule', 'note': None}
DEFAULTS['interception.score_goal_scale'] = {'label': 'x1 (map value)', 'note': None}
DEFAULTS['interception.scoring_speed'] = {'label': 'x1 (map value)', 'note': None}
DEFAULTS['spy.vault_alarm_scale'] = {'label': 'x1 (30-120 s)', 'note': None}
DEFAULTS['exterminate.kills_scale'] = {'label': 'x1 (formula)', 'note': None}
DEFAULTS['exterminate.archwing_kill_mult'] = {'label': '0.5-0.8x', 'note': 'A number you type applies on every Archwing map'}
for _key, _label in (('p1', '7-10'), ('p2', '13-20'), ('p3', '22-26'), ('p4', '25-29')):
    DEFAULTS[f'defense.max_enemies.{_key}'] = {'label': _label, 'note': 'Depends on enemy level (fewer below level 30)'}
# Contract R11: Railjack kill goals, x1 keeps the encounter's own numbers (picked by node level).
DEFAULTS['railjack.fighter_kills_scale'] = {'label': 'x1 (20-130)', 'note': None}
DEFAULTS['railjack.crewship_kills_scale'] = {'label': 'x1 (2-10)', 'note': None}
DEFAULTS['railjack.corpus_fighter_limit_scale'] = {'label': 'x1 (20-130)', 'note': None}
# Contract R14: Void Flood tank multipliers; x1 keeps the game's numbers (per squad size).
DEFAULTS['void_flood.deposit_speed_scale'] = {'label': 'x1 (8-14 s)', 'note': None}
DEFAULTS['void_flood.tank_capacity_scale'] = {'label': 'x1 (125-350)', 'note': None}
DEFAULTS['void_flood.orb_value_scale'] = {'label': 'x1 (5-60)', 'note': None}
DEFAULTS['void_flood.drain_speed_scale'] = {'label': 'x1', 'note': None}


def _strip(text):
    text = re.sub(r'\s*\((script constant [A-Z_]+|constant name[^)]*)\)', '', text)
    untraced = bool(re.search(r'not (fully )?traced|not decoded|inferred|exact use', text))
    text = re.sub(r'\s*\((?:[^()]*?)(effect not traced|exact use not traced|use not traced|unit inferred from the code|'
                  r'warning use inferred|constant name)[^()]*\)', '', text)
    text = re.sub(r';\s*(effect of the trigger not traced|which boss types use it is not fully traced|'
                  r'the exact formula is not decoded)', '', text)
    for rule in ('a ticked Advanced row wins', 'wins over the main knob'):
        text = text.replace('; ' + rule, '').replace(', ' + rule, '')
    text = text.replace('; not Alert missions', ' (not Alert missions)')
    text = text.replace(';', ',').strip().rstrip(',')
    return text, untraced


def describe(tid, r5_text, master=False, variant=False, has_variants=True, replaces_range=False):
    if tid in OVERRIDE:
        return OVERRIDE[tid]
    text, untraced = _strip(r5_text)
    first = text[0].upper() + text[1:]
    extra = []
    if tid in DEFAULTS and DEFAULTS[tid].get('note'):
        extra.append(DEFAULTS[tid]['note'])
    if replaces_range:
        extra.append(RANGE_SENTENCE)
    if master and has_variants:
        extra.append(MASTER_SENTENCE)
    elif variant:
        extra.append(VARIANT_SENTENCE)
    elif untraced:
        extra.append(UNTRACED)
    out = first.rstrip('.') + '.'
    if extra:
        second = '; '.join(extra)
        out += ' ' + second[0].upper() + second[1:] + '.'
    return out


# ------------------------------------------------------------------------------------------------ gates
BANNED_TOKENS = re.compile(r'\bMT_[A-Z_]+|\b[A-Z][A-Z0-9]*_[A-Z0-9_]+\b|\b[a-z0-9_]+\.[a-z0-9_]+\b|SolNode|frame_|proto')
CAMEL = re.compile(r'\b[a-z]+[A-Z][A-Za-z]*\b')


def text_ok(text, maximum, slash=True):
    return bool(text) and len(text) <= maximum and all(0x20 <= ord(c) < 0x7f for c in text) and text == text.strip() \
        and '::' not in text and (slash or '/' not in text) and not text.endswith(':')


def safe_row(label):
    label = ' '.join(label.split())
    if len(label) <= ROW_MAX:
        return label
    cut = label[:ROW_MAX + 1].rsplit(' ', 1)[0].rstrip(' ,;:(-/')
    return cut or label[:ROW_MAX]


def description_problems(where, text):
    problems = []
    if not text or len(text) > DESCRIPTION_MAX or not all(0x20 <= ord(c) < 0x7f for c in text):
        problems.append(f'{where}: description empty, not printable ASCII or over {DESCRIPTION_MAX} characters: {text!r}')
    sentences = [s for s in re.split(r'(?<=[.!?])\s+', text.strip()) if s]
    if len(sentences) > 2:
        problems.append(f'{where}: description has {len(sentences)} sentences (at most 2): {text!r}')
    if BANNED_TOKENS.search(text) or CAMEL.search(text):
        problems.append(f'{where}: description carries an internal id, code token or MT code: {text!r}')
    if text.count(',') > 3:
        problems.append(f'{where}: description reads like a list ({text.count(",")} commas): {text!r}')
    if 'stock' in text.lower():
        problems.append(f'{where}: description says "stock" (the UI says Default): {text!r}')
    return problems


def fmt(x):
    return str(int(x)) if float(x).is_integer() else f'{x:.6g}'


def with_unit(value, unit):
    return fmt(value) + (unit if unit == 'x' else (' ' + unit if unit else ''))


def family_order(groups):
    """Mission types alphabetical; merged families right after their host; advanced group = main + 5."""
    families = sorted({gid[:-len('_advanced')] if gid.endswith('_advanced') else gid for gid in groups},
                      key=lambda f: (TYPES.get(f, (groups.get(f, {}).get('label', f), None))[0].lower(),
                                     (TYPES.get(f, (None, None))[1] or '').lower(), f in MERGED, f))
    return {f: 10 * (i + 1) for i, f in enumerate(families)}


def apply(rows, groups, masters):
    """R7 layout onto registry rows (list), ui_groups (dict) and ui_masters (dict), in place. Returns meta."""
    by_id = {r['tunable_id']: r for r in rows}
    problems = []
    shown = {r['tunable_id'] for r in rows if r['ui'].get('label_source') == 'player_text'} | set(masters)
    for tid in shown:
        if tid not in L:
            problems.append(f'{tid}: shown value without an R7 layout entry')
    for tid in L:
        if tid not in by_id and tid not in masters:
            problems.append(f'{tid}: layout entry for an unknown value')
    orders = family_order(groups)
    for gid, group in groups.items():
        family = gid[:-len('_advanced')] if gid.endswith('_advanced') else gid
        group['order'] = orders[family] + (5 if gid.endswith('_advanced') else 0)
    rank = {tid: n for n, tid in enumerate(ORDER)}
    uis = [(r['tunable_id'], r['ui'], r.get('stock'), False) for r in rows] + \
          [(mid, m, m['stock'], True) for mid, m in masters.items()]
    drivers = {d['tunable_id']: mid for mid, m in masters.items() for d in m['drives']}
    # R9: the range a master's driven rows hold at stock, per unit of the master (row stock / scale).
    row_stock = {r['tunable_id']: r.get('stock') for r in rows}
    master_range = {}
    for mid, m in masters.items():
        ends = [row_stock[d['tunable_id']] / d['scale'] for d in m['drives'] if row_stock.get(d['tunable_id']) is not None]
        if ends and min(ends) != max(ends):
            master_range[mid] = (min(ends), max(ends))
    for tid, ui, stock, is_master in uis:
        family = tid.split('.')[0]
        mission, sub = TYPES.get(family, (family, None))
        entry = L.get(tid)
        if entry is None:
            # Never in a full package (player text only); a small build may still declare it.
            path = [mission] + ([sub] if sub else []) + ['Advanced']
            row, quick = safe_row(ui['short_label']), None
        else:
            path, row, quick = entry['path'], entry['row'], entry['quick']
        category = next((p for p in path if p in CATEGORIES), 'Advanced')
        ui['path'] = path
        ui['row'] = row
        if quick:
            ui['quick'] = quick
        else:
            ui.pop('quick', None)
        # Rows without a layout entry sort after every placed row; idempotent over repeated runs (R10 fix: the offset was
        # added again on every run of player_text.py).
        ui['rank'] = rank.get(tid, 100000 + (ui.get('rank') or 0) % 100000)
        base_group = ui['group'][:-len('_advanced')] if ui['group'].endswith('_advanced') else ui['group']
        want = base_group + ('_advanced' if category == 'Advanced' and not is_master else '')
        if want not in groups:
            base = groups[base_group]
            groups[want] = {k: v for k, v in base.items()}
            groups[want].update({'label': base['label'] + ': advanced', 'order': base['order'] + 5, 'advanced_of': base_group})
        ui['group'] = want
        label = DEFAULTS.get(tid, {}).get('label')
        replaces_range = False
        if is_master and ui.get('lane') == 'literal' and tid in master_range:
            # R9: a live literal master with a range default shows the range its rows hold at stock.
            low, high = master_range[tid]
            derived = f'{fmt(low)}-{with_unit(high, ui["unit"])}'
            if label and label != derived:
                problems.append(f'{tid}: default label {label!r} is not the range its rows hold ({derived!r})')
            label = label or derived
            replaces_range = True
        if label:
            ui['default_label'] = label
        else:
            ui.pop('default_label', None)
        if tid in UNIT:
            ui['unit'] = UNIT[tid]
        if tid in HIDE:
            ui['hidden'] = HIDE[tid]
        # player_text.apply() has just rewritten scope_text with the R5 sentence; keep it for the record.
        if ui.get('label_source') == 'player_text':
            ui['r5_scope_text'] = ui['scope_text']
        r5 = ui.get('r5_scope_text', ui['scope_text'])
        r5_text = r5[:r5.rfind('; stock ')] if '; stock ' in r5 else r5
        if ui.get('label_source') == 'player_text':
            ui['scope_text'] = describe(tid, r5_text, master=is_master, variant=tid in drivers,
                                        has_variants=is_master and (ui.get('lane') == 'addon' or any(
                                            d['tunable_id'] in shown for d in ui.get('drives', []))),
                                        replaces_range=replaces_range and tid not in OVERRIDE)
        # gates
        where = tid
        for i, element in enumerate(path):
            if not text_ok(element, PATH_MAX, slash=element == 'Rewards / drops'):
                problems.append(f'{where}: path element {element!r} is empty, padded, over {PATH_MAX}, has "::" or "/"')
        if not text_ok(row, ROW_MAX):
            problems.append(f'{where}: row {row!r} is empty, padded, over {ROW_MAX} or has "::"')
        if quick and not text_ok(quick, QUICK_MAX):
            problems.append(f'{where}: quick label {quick!r} over budget')
        if ui.get('label_source') == 'player_text' and stock is not None:
            shown_default = ui.get('default_label') or with_unit(stock, ui['unit'])
            if len(f'{row}: {shown_default} (default)') > ROW_BUDGET:
                problems.append(f'{where}: value row "{row}: {shown_default} (default)" is over {ROW_BUDGET} characters')
            problems += description_problems(where, ui['scope_text'])
        if ui.get('default_label') and not text_ok(ui['default_label'], DEFAULT_LABEL_MAX):
            problems.append(f'{where}: default label over budget')
    # (path, row) unique; a page never holds a value row and a page of the same name
    seen = {}
    for tid, ui, _, _ in uis:
        if ui.get('label_source') != 'player_text' and tid not in masters:
            continue
        key = (tuple(ui['path']), ui['row'].lower())
        if key in seen:
            problems.append(f'{tid}: row {ui["row"]!r} on page {" > ".join(ui["path"])} also used by {seen[key]}')
        seen[key] = tid
    pages = {tuple(ui['path'][:i]) for tid, ui, _, _ in uis for i in range(1, len(ui['path']) + 1)}
    for tid, ui, _, _ in uis:
        if tuple(ui['path']) + (ui['row'],) in pages:
            problems.append(f'{tid}: row {ui["row"]!r} has the same name as a page next to it')
    if problems:
        raise SystemExit('R7 layout gate failures:\n  ' + '\n  '.join(problems[:60]))
    return {'format': LAYOUT_FORMAT, 'categories': CATEGORIES, 'path_max': PATH_MAX, 'row_max': ROW_MAX,
            'quick_max': QUICK_MAX, 'default_label_max': DEFAULT_LABEL_MAX, 'row_budget': ROW_BUDGET,
            'description_max': DESCRIPTION_MAX, 'placed': len(L), 'types': TYPES}
