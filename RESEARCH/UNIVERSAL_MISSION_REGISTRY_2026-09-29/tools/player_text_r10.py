"""Player text for the contract R10 rows (mission-owner research, 2026-09-30).

`register()` is called by player_text.py with the same helpers as the R5 and R8 text (labels <= 33 characters, one
sentence with the default value, sections main / adv). HEADLINE lists the new literal-lane rows that a
"literal_scope": "headline" build declares as typeable live literals (LIVE_LITERALS_V1). Meaning comes from the research
evidence of each row (work/research/mission-owners-2026-09-30/README.md, rounds 1 and 2); where the code does not settle
the effect, the text says so. Nothing here reads or writes a game or server folder.
"""

HEADLINE = []


def register(row, master, per_player, players):
    def live(tid, *args, **kwargs):
        row(tid, *args, **kwargs)
        HEADLINE.append(tid)

    # ---- Objective counts written into the mission info at mission start (MISSION_INFO_FIELD_AT_ENTRY).
    # The default 0 means the game's own rule (endless on normal nodes); alerts, sorties and other special missions keep
    # their own count.
    row('defense.waves_to_finish', 'Waves to finish',
        'Waves on normal Defense nodes; the mission ends after the last wave instead of offering rotations', word=' waves')
    row('interception.rounds_to_finish', 'Rounds to finish',
        'Rounds on normal Interception nodes; the mission ends after the last round', word=' rounds')
    row('excavation.excavators_to_finish', 'Excavators to finish',
        'Excavators on normal Excavation nodes; the cryotic goal becomes 100 per excavator', word=' excavators')
    row('loopdefend.phases_to_finish', 'Phases to finish',
        'Phases on normal Mirror Defense nodes; the mission ends after the last phase', word=' phases')
    row('void_flood.tanks_to_finish', 'Tanks to finish', 'Tanks to fill on normal Void Flood nodes', word=' tanks')
    row('void_cascade.exolizers_to_finish', 'Exolizers to finish', 'Exolizers to defend on normal Void Cascade nodes',
        word=' exolizers')
    row('survival.fixed_length_minutes', 'Fixed length',
        'Turns normal Survival into a fixed-length mission of this many minutes with one reward at the end', word=' min')
    row('spy.vaults_required', 'Vaults required',
        'Vaults to hack on normal Spy nodes; losing more vaults than allowed fails the mission (success rule not traced)',
        'adv', word=' vaults')

    # ---- Level and encounter parameters written at the trigger entry (SCRIPT_PARAM_GLOBAL_AT_ENTRY).
    row('interception.score_goal_scale', 'Score to win a round',
        'Multiplies the score needed to win each Interception round; the map sets the base (1450 on most maps)')
    row('interception.round_end_timer', 'Time between rounds', 'Seconds between Interception rounds')
    row('interception.scoring_speed', 'Scoring speed',
        'Multiplies how fast held towers add score in Interception; the map sets the base', 'adv')
    row('spy.vault_alarm_scale', 'Vault alarm time',
        'Multiplies the countdown after a Spy vault alarm; each vault has its own base of 30 to 120 seconds')
    row('exterminate.kills_scale', 'Kills needed',
        'Multiplies the Exterminate kill count; the base is about one kill per 15 m of map path times faction and '
        'difficulty factors')
    row('exterminate.archwing_kill_mult', 'Archwing kill factor',
        'Extra factor on the Exterminate kill count on Archwing maps (higher on three space maps)', 'adv')
    row('sabotage.gascity_hack_time', 'Gas City: meltdown time',
        'Base time of the Gas City meltdown countdown; node difficulty stretches it by 20 to 80 percent')
    row('sabotage.random_extraction_timer', 'Surprise extraction timer',
        'Countdown of the occasional timed extraction after the reactor is destroyed (about 1 in 3 missions above level 10)',
        'adv')
    row('control_area_nokko.hold_time', 'Hold-zone time',
        'Seconds to hold the zone in Deepmines Control Area bounties below Fortuna')
    row('control_area_nokko.bonus_threshold', 'Bonus control threshold',
        'Control level the Deepmines bonus objective requires', 'adv', word=' percent')

    # ---- Void Armageddon (root CFG table, target-addon lane, live).
    row('void_armageddon.wave_time', 'Wave time', 'Length of each Void Armageddon wave')
    row('void_armageddon.prepare_time', 'Prepare time', 'Pause before the first wave of a Void Armageddon round')
    row('void_armageddon.pre_wave_time', 'Time before a wave', 'Warning time before each Void Armageddon wave starts')
    row('void_armageddon.post_wave_time', 'Time after a wave', 'Pause after each Void Armageddon wave ends')
    row('void_armageddon.round_complete_time', 'Time between rounds', 'Pause between Void Armageddon rounds')
    row('void_armageddon.waves_per_round', 'Waves per round', 'Waves in one Void Armageddon round', word=' waves')
    row('void_armageddon.reward_interval', 'Rounds per reward', 'Void Armageddon rounds between rewards', word=' rounds')
    per_player('void_armageddon.kills_per_wave', 'Kills per wave', 'Kills needed to clear a Void Armageddon wave',
               word=' kills', rule='the Circle variant doubles it')
    per_player('void_armageddon.max_enemies', 'Max enemies at once', 'Void Armageddon enemies alive at once',
               rule='halved during the angel phase')
    row('void_armageddon.angel_channel_time', 'Angel channel time',
        'Seconds an angel channels before it resolves in Void Armageddon', 'adv')

    # ---- Fixed numbers in script code (literal lane; typeable with LIVE_LITERALS_V1).
    live('rescue.hostage_timer.easy', 'Hostage timer (easy nodes)',
         'Seconds before the hostage dies on the easiest Rescue nodes; harder nodes blend toward the hard-node timer')
    live('rescue.hostage_timer.hard', 'Hostage timer (hard nodes)',
         'Seconds before the hostage dies on the hardest Rescue nodes (Moon and fortress tiles add 20 percent)')
    live('infested_capture.required_captures.high_scaling', 'High scaling: captures',
         'Legacytes to capture in the high-scaling Legacyte Harvest variant', word=' captures')
    live('infested_capture.required_captures.mutated', 'Mutated enemies: captures',
         'Legacytes to capture in the mutated-enemies Legacyte Harvest variant', word=' captures')
    live('infested_capture.required_captures.double', 'Double trouble: captures',
         'Legacytes to capture in the double-trouble Legacyte Harvest variant', word=' captures')
    live('infested_capture.required_captures.descendia', 'Descendia: captures',
         'Legacytes to capture on a Descendia Legacyte Harvest floor', word=' captures')
    live('sabotage.reactor_extract_timer', 'Ship escape timer',
         'Escape countdown after the reactor is destroyed on Corpus and Grineer ships')
    live('sabotage.trenchrun_timer', 'Archwing: time limit', 'Time limit of the Archwing trench-run Sabotage')
    live('sabotage.trenchrun_enemy_cap', 'Archwing: enemies', 'Enemy population of the Archwing trench-run Sabotage')
    live('sabotage.orokin_charge_time', 'Orokin: portal charge time',
         'Seconds to charge each half of the portal power in Orokin Sabotage')
    # R11: the escape timer and its host-migration restore threshold (timer - 3) are one coupled literal row.
    live('sabotage.orokin_escape_timer', 'Orokin: escape timer',
         'Escape countdown after the portal device is sabotaged in Orokin Sabotage')
    live('sabotage.forest_defend_time', 'Forest: injector defend time',
         'Seconds to defend each injector in Grineer Forest Sabotage')
    live('sabotage.gascity_meltdown_scale.easy', 'Gas City: easy-node factor',
         'Multiplier on the Gas City meltdown time on the easiest nodes', 'adv')
    live('sabotage.gascity_meltdown_scale.hard', 'Gas City: hard-node factor',
         'Multiplier on the Gas City meltdown time on the hardest nodes', 'adv')
    live('rush.pace_speed', 'Pace speed',
         'Expected flight speed that sets the Rush timer (map path length divided by this speed plus the node '
         'difficulty)', word=' m/s')
    live('gamerules.extraction_countdown_endless', 'Extraction timer (endless)',
         'Countdown after the first player reaches extraction in an endless mission')
    live('onslaught.zone_time', 'Zone time',
         'Seconds in each Sanctuary Onslaught zone before the conduit opens (normal and Elite)')
    live('onslaught.zones_per_reward', 'Zones per reward', 'Sanctuary Onslaught zones per reward rotation', word=' zones')
    live('onslaught.efficiency_max', 'Efficiency for 100%',
         'Efficiency units that make 100 percent in Sanctuary Onslaught; kills and pickups add units and time drains them',
         'adv', word=' efficiency units')
    live('onslaught.efficiency_per_kill', 'Efficiency per kill', 'Efficiency units gained per normal kill in Sanctuary Onslaught',
         word=' efficiency units')
    live('onslaught.efficiency_per_special_kill', 'Efficiency per special kill',
         'Efficiency units gained per special enemy kill in Sanctuary Onslaught', word=' efficiency units')
    live('onslaught.efficiency_per_pickup', 'Efficiency per time pickup',
         'Efficiency units gained per time pickup in Sanctuary Onslaught', word=' efficiency units')
    for key, short, long in players[1:]:
        live(f'assassination.kela_health.{key}', f'Kela De Thaym health ({short})',
             f'Multiplier on Kela De Thaym health with {long}' + (' or more' if key == 'p4' else ''), word='x')
    live('assassination.boss_level_bonus', 'Boss level bonus',
         'Levels added to the node maximum for most star-chart bosses (the native use of the value is not confirmed live)',
         word=' levels')
    live('assassination.hard_mode_level_base', 'Hard-mode boss level',
         'Boss level in the hard-mode boss variant before the per-player bonus', 'adv', word=' (boss level)')
    live('assassination.hard_mode_level_per_player', 'Hard-mode level per player',
         'Boss levels added per player in the hard-mode boss variant', 'adv', word=' levels')
    live('assassination.ambulas_level_per_player', 'Ambulas level per player',
         'Levels added to Ambulas units for each extra player', 'adv', word=' levels')

    # ---- Contract R11 (2026-09-30): Railjack kill goals, encounter parameters scaled at the objective or patrol entry
    # (SCRIPT_PARAM_GLOBAL_AT_ENTRY, mode scale_count: whole numbers, at least 1).
    row('railjack.fighter_kills_scale', 'Fighters to kill',
        'Multiplies the fighters to destroy in Grineer Railjack Exterminate (20 to 130 by node level)')
    row('railjack.crewship_kills_scale', 'Crewships to kill',
        'Multiplies the crewships to destroy in Grineer Railjack Exterminate (2 to 10 by node level)')
    row('railjack.corpus_fighter_limit_scale', 'Corpus fighters',
        'Multiplies the Corpus fighter kills after which no new fighter squadrons come (no on-screen counter)')

    # ---- Contract R12 (2026-10-01): Defense waves per reward, the level parameter minWavesToComplete written at the
    # WaveDefense entry (SCRIPT_PARAM_GLOBAL_AT_ENTRY, mode absolute).
    row('defense.waves_per_reward', 'Waves per reward',
        'Defense waves between each reward and extraction choice', word=' waves')

    # ---- Contract R14 (2026-10-01): Void Flood tank multipliers, scaled root-table fields (mode scale / scale_count).
    row('void_flood.deposit_speed_scale', 'Tank fill speed',
        'Multiplies how fast a Void Flood tank fills while a player stands at it with Void energy')
    row('void_flood.tank_capacity_scale', 'Tank capacity',
        'Multiplies the Void energy each Void Flood tank needs and the most a player can carry')
    row('void_flood.orb_value_scale', 'Void orb value',
        'Multiplies the Void energy from small, medium and large Void orbs in Void Flood')
    row('void_flood.drain_speed_scale', 'Tank drain speed',
        'Multiplies the energy a Void Flood tank loses under the Decaying curse while nobody is at it')
