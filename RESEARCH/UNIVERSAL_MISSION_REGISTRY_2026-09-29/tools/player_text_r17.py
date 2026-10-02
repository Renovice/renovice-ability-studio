"""Player text for the contract R17 "All <mission type> missions" masters (2026-10-01).

User request (2026-10-01): at the very top of each mission type's page, one value row with an on/off switch that drives
the type's headline value for every variant ("All Survival missions" etc.), the same value as its Quick settings entry.
Where the headline is already one value (Survival time between rewards, Defense waves per reward, Interception score
to win, ...) that value itself is the master (player_layout.py places it at the top of the page, `quick_on_page`). Where
the headline is several rows of the same meaning, a master knob is added here:

  * single module, literal lane (existing R5/R9 master machinery): Mirror Defense phase time, Rescue hostage timer,
    Legacyte Harvest captures, Defection squads, Disruption rounds, Hijack payload health, Archimedea Survival length;
  * several modules (contract R17): Control Area hold time (Plains, Cambion Drift and Deepmines scripts, literal lane;
    the bootstrapper recipe names a module per drive) and Railjack kill goals (Grineer fighters and crewships on the addon
    lane, the Corpus fighter limit owned at the engine writer: engine_params.json carries the master for that row).

A variant row that is on (and not at its default) wins over the master for that variant (R5-3, R9-4). `register()` is
called by player_text.py with its `row` and `master` helpers; HEADLINE lists the literal masters a "literal_scope":
"headline" build declares as live literals. Nothing here reads or writes a game or server folder.
"""

HEADLINE = []


def register(row, master):
    def live_master(mid, *args, **kwargs):
        master(mid, *args, **kwargs)
        HEADLINE.append(mid)

    # ---- Several modules (contract R17).
    live_master('control_area.hold_time', 'Hold-zone time (all areas)',
                'Seconds to hold the zone in every Control Area bounty on the Plains, in Cambion Drift and in the Deepmines',
                [('control_area_deimos.duration', 1), ('control_area_nokko.hold_time', 1), ('control_area_plains.duration', 1)],
                group='control_area_deimos')
    # R18 (coverage audit 2026-10-02): + the Pontis tower space-enemy goals (two more modules, owned at the engine writer).
    master('railjack.kill_goals_scale', 'Kill goals',
           'Multiplies every Railjack kill goal: Grineer fighters and crewships, the Corpus fighter limit and the Pontis '
           'tower space enemies',
           [('railjack.fighter_kills_scale', 1), ('railjack.crewship_kills_scale', 1),
            ('railjack.corpus_fighter_limit_scale', 1), ('railjack.pontis_ash_enemies_scale', 1),
            ('railjack.pontis_garuda_enemies_scale', 1)], group='railjack')

    # ---- Contract R22 (2026-10-02): "All Void Cascade missions" = exolizer progress speed, an inverse master over the
    # exolizer duration (PILLAR_DURATION and PILLAR_DURATION_CIRCLE, one addon row): duration = 90 / speed. Floor 0.006:
    # the game's timer adds the frame time to a float32 sum and stops moving once the frame time is below half a float32
    # step of that sum; 90 / 0.006 = 15000 s keeps the sum below 16384, which moves up to 2048 fps (R20 rule).
    master('void_cascade.exolizer_speed', 'Exolizer progress speed',
           'How fast every exolizer fills in Void Cascade and The Circuit, x2 = half the time per exolizer',
           [('void_cascade.pillar_duration', 90, 'inverse')], unit='x', limits=(0.006, 90))

    # ---- One module, literal lane (R5/R9 masters).
    live_master('loopdefend.phase_time', 'Time per phase (all)',
                'Seconds each Mirror Defense phase lasts in normal and Jade missions',
                [('loopdefend.phase_duration', 1), ('loopdefend.phase_duration_jade', 1)], note='(Jade 60)')
    live_master('rescue.hostage_timer', 'Hostage timer (all nodes)',
                'Seconds before the hostage dies on every Rescue node',
                [('rescue.hostage_timer.easy', 1), ('rescue.hostage_timer.hard', 1)], note='(hardest nodes 60)')
    live_master('infested_capture.required_captures', 'Captures to finish (all)',
                'Legacytes to capture in every Legacyte Harvest variant with a capture count',
                [('infested_capture.required_captures.high_scaling', 1), ('infested_capture.required_captures.mutated', 1),
                 ('infested_capture.required_captures.double', 1), ('infested_capture.required_captures.descendia', 1)],
                word=' captures', note='(double trouble 6, Descendia 1)')
    live_master('defection.squads_to_rescue', 'Squads to rescue (all)',
                'Squads to rescue in every Defection mission including sorties',
                [('defection.squads_required', 1), ('defection.squads_required.sortie', 1)], word=' squads',
                note='(sortie 5)')
    live_master('disruption.rounds_to_finish', 'Rounds to finish (all)',
                'Conduit rounds to finish in every Disruption mission including sorties',
                [('disruption.default_round_count', 1), ('disruption.sortie_round_count', 1)], note='(sortie 8)')
    live_master('hijack.payload_health_all', 'Payload health (all)',
                'Health of the Hijack payload in every mission including goal missions',
                [('hijack.payload_health', 1), ('hijack.payload_health.goal_mission', 1)], note='(goal missions 3000)')
    live_master('archimedea.survival_minutes', 'Survival length (all)',
                'Minutes of the Survival stage in Deep and Temporal Archimedea',
                [('archimedea.eda_survival_minutes', 1), ('archimedea.eta_survival_minutes', 1)])

    # ---- R18 (coverage audit 2026-10-02): mission types whose headline has several rows of one meaning but had no master.
    # Entrati Swarm: tears per stage, five stages, normal and collect-tears challenge (one module, literal lane).
    live_master('entrati_swarm.tears_per_stage_all', 'Tears per stage (all)',
                'Tears to collect in every Entrati Swarm stage, with or without the tears challenge',
                [(f'entrati_swarm.tears_per_stage.stage{n}', 1) for n in range(1, 6)]
                + [(f'entrati_swarm.tears_per_stage_challenge.stage{n}', 1) for n in range(1, 6)],
                word=' tears', note='(stage 1; up to 20 later)')
    # Sabotage: the escape countdown after the sabotage, Corpus/Grineer ships (SabotageModular) and Orokin (SabotageOrokin,
    # coupled site): two modules, literal lane. The Gas City meltdown is a multiplier owned at the engine writer (its own row).
    live_master('sabotage.escape_timer', 'Escape timer (all)',
                'Escape countdown after the sabotage on Corpus and Grineer ships and in Orokin Sabotage',
                [('sabotage.reactor_extract_timer', 1), ('sabotage.orokin_escape_timer', 1)],
                group='sabotage', note='(Orokin 30)')
