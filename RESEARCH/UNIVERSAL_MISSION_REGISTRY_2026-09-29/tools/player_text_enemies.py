"""Player text for the Enemies page (2026-10-30): ProceduralLevel MaxAI (npcMgr:SetMaxAI) per level difficulty.

HEADLINE: the literal rows a "literal_scope": "headline" package ships (literals.json).
"""

HEADLINE = ['enemies.max_ai.high', 'enemies.max_ai.mid', 'enemies.max_ai.low',
            'enemies.multiplier', 'purgatory.enemy_multiplier', 'purge.enemy_multiplier']  # literal-lane masters


def register(row, master):
    row('enemies.max_ai.high', 'Wave size: high level tier',
        'Enemy limit the level script sets on high-difficulty procedural missions (normally 8); effect under live test', word=' enemies')
    row('enemies.max_ai.mid', 'Wave size: mid level tier',
        'Enemy limit the level script sets on mid-difficulty procedural missions (normally 6); effect under live test', word=' enemies')
    row('enemies.max_ai.low', 'Wave size: low level tier',
        'Enemy limit the level script sets on low-difficulty procedural missions (normally 4); effect under live test', word=' enemies')


    # ---- Enemy multipliers (2026-10-30, user): masters with scale = each driven row's stock, so master 1 = stock and
    # master N = N x stock on every driven count. Only enemy counts/caps; kill objectives are left out. Families whose
    # count rows already have a per-player master (Disruption, Shrine, Defense, Mobile Defense, Mirror Defense, Defection,
    # Face Off) are not here: a row has one master (needs a master-over-masters primitive).
    def multiplier(mid, rows, family, text, high):
        master(mid, 'Enemies on the map', text + '', [(r, s) for r, s in rows], group=family,
               word=' times the normal enemy count', limits=(1, high))
    # 2026-10-30 rename (id kept): MaxAI is the per-encounter spawn burst (npcMgr:SetMaxAI), not the enemies-at-once count.
    master('enemies.multiplier', 'Wave size multiplier',
           'Multiplies the enemies per spawn wave on procedural missions; not the enemies alive at once (hard cap)',
           [('enemies.max_ai.high', 8), ('enemies.max_ai.mid', 6), ('enemies.max_ai.low', 4)], group='enemies',
           word=' times the normal spawn wave', limits=(1, 1000))

    # ---- 2026-10-30 enemy director hard cap (AI_DIRECTOR_SETTER_AT_ENTRY on the level script, host only).
    row('enemies.hard_cap', 'Enemy cap (absolute)',
        'Cap on enemies alive at once, set by the host at mission start; keep it at or above the Survival counts', word=' enemies')

    # ---- 2026-10-31 spawn area (AI director method 4f77b69c, AI_DIRECTOR_SETTER_AT_ENTRY NO_GETTER; both rows feed one call).
    row('enemies.active_area_ahead', 'Spawn distance ahead',
        'How far ahead of the players enemies spawn and stay active (normally 75 m); set by the host at mission start')
    row('enemies.active_area_behind', 'Spawn distance behind',
        'How far behind the players enemies spawn and stay active (normally 75 m); set by the host at mission start')

    # ---- 2026-10-31 per-area enemy limit scale (AI director method 5904fb7a, NO_GETTER; float +0x6c4, stock 1.0).
    row('enemies.area_limit_scale', 'Enemies per area',
        'Scales how many enemies each map area may hold; host only, effect under live test', word='x')

    # ---- 2026-11-01 relocate-instead-of-create fraction (AI director method 0a7324fb, NO_GETTER; f32 +0x6b4, stock 0.75).
    row('enemies.relocate_fraction', 'Relocate at',
        'Share of the enemy cap after which enemies are moved, not spawned; host only, under test')

    # ---- 2026-11-01 spawn point reuse (NATIVE_CALL_RETRY_AT_SPAWN_POINT on EndlessSpawnLib; CreateRandomAgent, on/off).
    row('enemies.spawn_point_reuse', 'Spawn point reuse',
        'When all nearby spawn points are taken, spawn at a used one near a player so more can spawn; host only in '
        'endless modes; under live test', word=' (off)')

    # ---- 2026-10-31 AI director fields (OBJECT_FIELD_AT_ENTRY via RENOVICE.object; host only, at mission start).
    note = 'host only; effect under live test'
    row('enemies.spawn_timer', 'Spawn check interval',
        f'Spawn tick: how often the director processes spawns (lower = faster); {note}')
    row('enemies.event_timer', 'Time between spawn groups',
        f'Time between enemy spawn events (lower = more often); {note}')
    row('enemies.event_count_max', 'Spawn groups at once',
        f'Most enemy spawn events running at the same time; {note}', word=' events')
    row('enemies.max_encounter_xp', 'Spawn group size',
        f'Spawn wave budget: enemy value spent on one wave; {note}')
    row('enemies.intensity_max', 'Pressure limit',
        f'Top of the combat intensity scale; {note}', word=' points')
    row('enemies.intensity_peak_pct', 'Peak trigger point',
        f'Share of max intensity that counts as a peak (spawns ease off); {note}')
    row('enemies.intensity_hold_spawns_pct', 'Hold spawns point',
        f'Share of max intensity at which new spawns are held; {note}')
    row('enemies.after_peak_time', 'Breather length',
        f'Calm time after an intensity peak; {note}')
    row('enemies.after_hold_time', 'Peak hold time',
        f'How long spawns stay held before building up again; {note}')

    # ---- 2026-10-30 Survival enemies at once: SurvivalMission root count tables, one row per squad size. Index = players
    # (Steel Path and Kuva Survival always use the 4-player column); the count goes from the lowest-level value to the
    # level-30 value with enemy level and is cut to the hard cap.
    sp_rule = 'Steel Path/Kuva use 4 players'
    for part, label, text in (('max', 'Level 30+ at once', 'Alive at once, level 30+'),
                              ('min', 'Low levels at once', 'Alive at once, lowest levels'),
                              ('infested_max', 'Infested 30+ at once',
                               'Infested alive at once, level 30+'),
                              ('infested_min', 'Infested low at once',
                               'Infested alive at once, lowest levels'),
                              ('duviri_max', 'Duviri 30+ at once',
                               'Duviri hard mode alive at once, level 30+'),
                              ('duviri_min', 'Duviri low at once',
                               'Duviri hard mode alive at once, lowest levels')):
        for key, short, long in (('p1', 'solo', '1 player'), ('p2', 'duo', '2 players'), ('p3', 'trio', '3 players'),
                                 ('p4', 'squad', '4 players')):
            row(f'survival.enemy_count.{part}.{key}', f'{label} ({short})', f'{text} with {long}; {sp_rule}')
    multiplier('survival.enemy_multiplier',
               [(f'survival.enemy_count.{part}.p{n}', v) for part, values in (
                   ('min', (7, 15, 25, 30)), ('max', (10, 25, 30, 35)), ('infested_min', (8, 15, 25, 30)),
                   ('infested_max', (12, 25, 30, 35)), ('duviri_min', (15, 23, 27, 30)), ('duviri_max', (20, 28, 32, 35)))
                for n, v in zip((1, 2, 3, 4), values)],
               'survival', 'Multiplies every Survival enemies-at-once count; the Enemies page hard cap still limits it', 1000)
    multiplier('infested_salvage.enemy_multiplier',
               [(f'infested_salvage.spawn_caps_by_players.{k}.p{n}', v) for k in ('max_ai', 'max_source_ai')
                for n, v in ((1, 15), (2, 20), (3, 25), (4, 30))],
               'infested_salvage', 'Multiplies the Infested Salvage enemy caps for every squad size', 1000)
    multiplier('lantern.enemy_multiplier', [(f'lantern.num_enemies.p{n}', v) for n, v in ((1, 10), (2, 20), (3, 25), (4, 30))],
               'lantern', 'Multiplies the Lantern enemy cap for every squad size', 1000)
    multiplier('void_armageddon.enemy_multiplier',
               [(f'void_armageddon.max_enemies.p{n}', v) for n, v in ((1, 12), (2, 14), (3, 16), (4, 18))],
               'void_armageddon', 'Multiplies the Void Armageddon enemy cap for every squad size (kills per wave unchanged)', 1000)
    multiplier('purgatory.enemy_multiplier',
               [('purgatory.enemy_cap', 10), ('purgatory.spawn_batch.min', 2), ('purgatory.spawn_batch.max', 4)],
               'purgatory', 'Multiplies the Purgatory enemy cap and spawn batch size', 1000)
    multiplier('purge.enemy_multiplier',
               [('purge.spawnlib_params.max_ai', 15), ('purge.spawnlib_params.max_source_ai', 15)],
               'purge', 'Multiplies the Purge enemy caps (total population to kill unchanged)', 1000)
