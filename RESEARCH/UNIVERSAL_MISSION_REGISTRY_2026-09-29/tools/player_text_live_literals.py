"""Player text for the headline literal-lane mission values (LIVE_LITERALS_V1, 2026-09-30, contract R8).

These are the "fixed numbers in script code" rows of the R5 headline matrix
(RESEARCH/MISSION_SETTINGS_PLAYER_TEXT_R5_2026-09-30.md): values that no root table
owns, so the addon lane cannot write them. With LIVE_LITERALS_V1 the bootstrapper
synthesizes the module from its captured stock bytes and a declarative recipe at each
apply, so they become typeable in SCRIPT SETTINGS (applies at the next mission).

`register()` is called by player_text.py (same conventions: labels <= 33 characters,
one-sentence descriptions with the stock value, sections main / adv, masters first).
HEADLINE lists every value (row or master) the Missions package declares as a live
literal when the build input sets "literal_scope": "headline" (generator
src/mission_profiles.inl). Meaning comes from the registry evidence of each row (44.0.2
decompile line references); where the code does not establish the effect, the text says so.
Nothing here reads or writes a game or server folder.
"""

HEADLINE = []


def register(row, master, players, master_rule, variant_rule):
    def live(tid, *args, **kwargs):
        row(tid, *args, **kwargs)
        HEADLINE.append(tid)

    def live_master(mid, *args, **kwargs):
        master(mid, *args, **kwargs)
        HEADLINE.append(mid)

    # Rows that already have player text (R5) become live literals too.
    HEADLINE.extend(['mobiledefense.time_per_terminal', 'mobiledefense.total_time.maximum', 'mobiledefense.total_time.minimum',
                     'excavation.dig_time', 'excavation.dig_duration', 'excavation.dig_duration_elite_alert',
                     'excavation.dig_duration_old_world_salvage', 'control_area_plains.duration', 'control_area_deimos.duration',
                     'void_flood.fractures_per_round.normal'])

    # ---- Survival
    live('survival.duviri_fixed_length', 'Duviri: Survival length',
         'Length of endless Duviri Survival (missions flagged EndlessDuviri, The Circuit)')

    # ---- Defense: enemies at once (regular and Infested tables; both ends of the level range), waves, timers
    for key, short, long in players:
        live_master(f'defense.max_enemies.{key}', f'Max enemies at once ({short})',
                    f'Defense enemies alive at once with {long}, regular and Infested, all levels; {master_rule}',
                    [(f'defense.simultaneous_enemies_max.{key}', 1), (f'defense.simultaneous_enemies_min.{key}', 1),
                     (f'defense.simultaneous_enemies_infested.max.{key}', 1),
                     (f'defense.simultaneous_enemies_infested.min.{key}', 1)],
                    note='(fewer below level 30)')
    for key, short, long in players:
        live(f'defense.simultaneous_enemies_max.{key}', f'Level 30+: max enemies ({short})',
             f'Defense enemies alive at once at enemy level 30 and above with {long}, regular enemies; {variant_rule}', 'adv')
    for key, short, long in players:
        live(f'defense.simultaneous_enemies_infested.max.{key}', f'Infested: max enemies ({short})',
             f'Defense enemies alive at once at enemy level 30 and above with {long}, Infested; {variant_rule}', 'adv')
    live('defense.first_wave_delay', 'Delay before the first wave', 'Seconds before the first Defense wave starts')
    live('defense.inter_wave_sleep', 'Time between waves', 'Seconds of intermission between Defense waves')
    live('defense.special_mission_default_waves', 'Alert missions: waves to finish',
         'Waves in alert, invasion and syndicate Defense when the mission sets none', word=' waves')
    live('defense.nightmare_wave_count', 'Nightmare: waves to finish', 'Waves in Nightmare Defense', word=' waves')
    live('defense.duviri_wave_count', 'Duviri: waves to finish', 'Waves in Duviri Defense', word=' waves')
    live('defense.circle_wave_count', 'Descendia: waves to finish', 'Waves in Descendia (circle) Defense', word=' waves')

    # ---- Mobile Defense
    live('mobiledefense.console_count', 'Terminals per mission',
         'Terminals to defend in Mobile Defense (fewer when the tile has fewer)')

    # ---- 1999 Exterminate (Escalation)
    live('escalation.crate_timer', 'Supply crate timer',
         'Countdown of the supply crate in 1999 Exterminate Escalation (Escalate Now adds 60 s)')

    # ---- Excavation
    live('excavation.duviri_excavation_count', 'Duviri: excavations', 'Excavations to finish Duviri Excavation',
         word=' excavations')

    # ---- Disruption
    live('disruption.default_round_count', 'Rounds to finish',
         'Disruption rounds when the node sets no round count (not Sorties)', word=' rounds')
    live('disruption.sortie_round_count', 'Sortie: rounds to finish',
         'Disruption rounds in Sorties when the node sets no round count', word=' rounds')
    live('disruption.round_timeout', 'Round time-out timer',
         'Time-out timer a Disruption round shows after 900 s without a conduit defense (fail effect not traced)')
    live('disruption.interval_between_rounds', 'Time between rounds', 'Seconds between Disruption rounds')
    live('disruption.interval_between_rounds.relic', 'Relics: time between rounds',
         'Seconds between Disruption rounds on relic missions; wins over Time between rounds there')
    for key, short, long in players:
        live_master(f'disruption.max_enemies.{key}', f'Max enemies at once ({short})',
                    f'Disruption enemies alive at once with {long}, standard, Sentient and Entrati lab, both ends of '
                    f'the range; {master_rule}',
                    [(f'disruption.max_enemies_by_players.standard.{key}', 1),
                     (f'disruption.min_enemies_by_players.standard.{key}', 1),
                     (f'disruption.max_enemies_by_players.sentient.{key}', 1),
                     (f'disruption.min_enemies_by_players.sentient.{key}', 1),
                     (f'disruption.max_enemies_by_players.entrati_lab.{key}', 1),
                     (f'disruption.min_enemies_by_players.entrati_lab.{key}', 1)])
    for key, short, long in players:
        live(f'disruption.max_enemies_by_players.standard.{key}', f'Standard: max enemies ({short})',
             f'Upper enemy count of standard Disruption with {long}; {variant_rule}', 'adv')
    for key, short, long in players:
        live(f'disruption.max_enemies_by_players.sentient.{key}', f'Sentient: max enemies ({short})',
             f'Upper enemy count of Sentient Disruption with {long}; {variant_rule}', 'adv')
    for key, short, long in players:
        live(f'disruption.max_enemies_by_players.entrati_lab.{key}', f'Lab: max enemies ({short})',
             f'Upper enemy count of Entrati lab Disruption with {long}; {variant_rule}', 'adv')

    # ---- Void Flood
    live('void_flood.fractures_per_round.duviri', 'Duviri: fractures per round',
         'Void fractures opened per round in Duviri Void Flood', word=' fractures')

    # ---- Capture
    live('capture.bleedout_timer.grace', 'Downed target: grace time',
         'Seconds a downed Capture target waits before its escape timer starts')
    live('capture.bleedout_timer.fail_timer', 'Downed target: escape timer',
         'Seconds on the escape timer of a downed Capture target; the mission fails at 0')

    # ---- Defection
    live('defection.squads_required', 'Squads to rescue', 'Defector squads to rescue when the node sets none',
         word=' squads')
    live('defection.squads_required.sortie', 'Sortie: squads to rescue', 'Defector squads to rescue in Sorties',
         word=' squads')

    # ---- Mirror Defense (LoopDefend)
    live('loopdefend.phase_duration', 'Time per phase', 'Defend timer of each Mirror Defense phase')
    live('loopdefend.phase_duration_jade', 'Jade: time per phase',
         'Defend timer of each phase when the Jade level override is active')

    # ---- Lantern
    live('lantern.min_score', 'Score to win', 'Seconds a Lantern run must last before extraction opens; less fails')
    live('lantern.extraction_limit', 'Time to reach extraction', 'Seconds to reach extraction once it opens in Lantern')
    live('lantern.boss_spawn_time', 'Boss arrives after', 'Seconds into a Lantern run before the boss spawns')

    # ---- Purgatory
    live('purgatory.initial_time', 'Starting time', 'Seconds on the Purgatory timer at the start')
    live('purgatory.pickup_time_bonus', 'Time per pickup', 'Seconds a time pickup adds in Purgatory')
    live('purgatory.enemy_cap', 'Max enemies at once', 'Purgatory enemies alive at once (Protea quest stages lower it)')
    live_master('purgatory.spawn_interval', 'Time between spawns',
                f'Seconds between Purgatory spawn batches (sets the random range to this value); {master_rule}',
                [('purgatory.spawn_interval.max', 1), ('purgatory.spawn_interval.min', 1)], note='(random 3 to 5)')
    live('purgatory.spawn_interval.min', 'Shortest time between spawns',
         f'Low end of the random time between Purgatory spawn batches; {variant_rule}', 'adv')
    live('purgatory.spawn_interval.max', 'Longest time between spawns',
         f'High end of the random time between Purgatory spawn batches; {variant_rule}', 'adv')

    # ---- Descendia
    live('coh_excavation.dig_duration', 'Excavation: dig time', 'Seconds each excavator digs on a Descendia Excavation floor')
    live('coh_nemesis.spawn_interval', 'Nemesis: time between spawns', 'Seconds between Nemesis spawns on a Descendia floor')

    # ---- 1999 Defense
    live('wf1999def.drone_count.spawn_interval', 'Time between drone spawns',
         'Seconds between chemical-noise drone launches in 1999 Defense')

    # ---- Orphix Venom
    live('orphix.sortie_rounds', 'Sortie: rounds to finish',
         'Orphix Venom rounds in Sorties (the single reward comes at the last round)', word=' rounds')

    # ---- Sentient Mobile Defense
    live('sentientmd.defend_time', 'Defend time per area', 'Seconds to defend the drone in each Sentient Defense area')
    live('sentientmd.area_count', 'Areas to complete', 'Areas to complete in Sentient Mobile Defense', word=' areas')

    # ---- Hack-Station Defense (MultiDefend)
    live_master('multidefend.defend_time', 'Defend time per station',
                f'Seconds to defend each hack station, all node levels (sets the random range); {master_rule}',
                [('multidefend.defend_time.max_d1', 1), ('multidefend.defend_time.min_d1', 1),
                 ('multidefend.defend_time.max_d0', 1), ('multidefend.defend_time.min_d0', 1)],
                note='(random 30 to 240 by node level)')
    live('multidefend.defend_time.min_d0', 'Easy nodes: shortest defend time',
         f'Low end of the random station defend time on the easiest nodes; {variant_rule}', 'adv')
    live('multidefend.defend_time.max_d0', 'Easy nodes: longest defend time',
         f'High end of the random station defend time on the easiest nodes; {variant_rule}', 'adv')
    live('multidefend.defend_time.min_d1', 'Hard nodes: shortest defend time',
         f'Low end of the random station defend time on the hardest nodes; {variant_rule}', 'adv')
    live('multidefend.defend_time.max_d1', 'Hard nodes: longest defend time',
         f'High end of the random station defend time on the hardest nodes; {variant_rule}', 'adv')
    live('multidefend.station_count', 'Stations to defend', 'Hack stations to defend in Hack-Station Defense',
         word=' stations')

    # ---- Netracell (Entrati void vaults)
    live('netracell.power_required.base', 'Power required', 'Power to charge a Netracell with 1 player')
    live('netracell.power_required.per_extra_player', 'Power per extra player',
         'Extra Netracell power needed per additional player (up to 3)')

    # ---- Deep and Temporal Archimedea (new mission chains)
    live('archimedea.eda_survival_minutes', 'Deep: Survival minutes',
         'Survival length in newly generated Deep Archimedea chains')
    live('archimedea.eta_survival_minutes', 'Temporal: Survival minutes',
         'Survival length in newly generated Temporal Archimedea chains')
    live('archimedea.eta_defense_waves', 'Temporal: Defense waves',
         'Defense waves in newly generated Temporal Archimedea chains', word=' waves')
    live('archimedea.eda_alchemy', 'Deep: Alchemy mixtures',
         'Alchemy mixtures in newly generated Deep Archimedea chains', word=' mixtures')
    live('archimedea.eda_disruption', 'Deep: Disruption conduits',
         'Disruption conduits in newly generated Deep Archimedea chains', word=' conduits')
    live('archimedea.eda_mirror_defense_waves', 'Deep: Mirror Defense phases',
         'Mirror Defense phases in newly generated Deep Archimedea chains', word=' phases')

    # ---- Pursuit and Archwing (Balor Fomorian)
    live('pursuit.phase_timer', 'Defend-ship phase time', 'Seconds of the defend-the-ship phase in Pursuit; it succeeds at 0')
    live('archwing.fomorian_emp_timer', 'EMP countdown', 'Seconds on the Balor Fomorian EMP countdown')

    # ---- Entrati Swarm (tears per stage)
    for n in range(1, 6):
        live(f'entrati_swarm.tears_per_stage.stage{n}', f'Tears for stage {n}',
             f'Tears to collect in stage {n} of Entrati Swarm', word=' tears')
    for n in range(1, 6):
        live(f'entrati_swarm.tears_per_stage_challenge.stage{n}', f'Challenge: tears for stage {n}',
             f'Tears to collect in stage {n} of Entrati Swarm with the collect-tears challenge', 'adv', word=' tears')

    # ---- Purge (no star-chart nodes)
    live('purge.max_enemy_count', 'Enemies to kill', 'Enemy population to kill in a Purge mission', word=' enemies')

    # ---- Arbitration
    live('arbitration.resurrection_score_cap', 'Max resurrection score',
         'Highest Arbitration resurrection score, also the most buff stacks it gives', word=' points')

    # ---- Hijack
    live('hijack.payload_health', 'Payload health', 'Health of the Hijack payload (Steel Path scales it)')
    live('hijack.payload_health.goal_mission', 'Goal missions: payload health',
         'Health of the Hijack payload on goal missions; wins over Payload health there')
