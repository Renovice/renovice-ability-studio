"""Phase 2e registry specs for client 44.0.2 (2026-09-29; offline, read-only inputs).

ADDON    root-table fields owned through the target-addon lane (gate ROOT_TABLE_UPVALUE_V1 in addon_owner.py). The addon
         writes the live table field, so a shared bytecode constant does not matter: every field is its own control.
         `fields` lists (field, stock[, root table instruction]) - one row may own the same field of several tables.
LUA      exact literal rows in the Phase 2d spec format (resolved and gated by phase2d.py): Void Flood fracture counts,
         Lantern and Purgatory literals.
PHASE1   rows added to the Phase 1 study (mission_tunables.json) for modes Phase 1 analysed but did not tabulate.
RESOLVES Phase 2d exclusions that Phase 2e registers (matched on the exact `phase1` string and `part`).
ADDON_FAILED  Phase 2d shared-constant exclusions whose tables also fail the addon gate (reason appended, row stays excluded).

`confidence`: CONFIRMED_STATIC comes from Phase 1. CONFIRMED_STATIC_PHASE2E marks a Phase 1 PARTIAL row, or a row Phase
1 did not tabulate, whose owner Phase 2e proved on the 44.0.2 bytes (for addon rows the gate itself is that proof: the
field is in a table the root builds once, the table only leaves the root by closure capture, every capturer is hooked,
and a capturer reads the field).
"""

SURVIVAL = ('Lotus_Scripts_Modes_SurvivalMission.lua_B', '/Lotus/Scripts/Modes/SurvivalMission.lua', 'Survival')
ORPHIX = ('Lotus_Scripts_Modes_MechSurvivalMission.lua_B', '/Lotus/Scripts/Modes/MechSurvivalMission.lua', 'Orphix Venom')
FLOOD = ('Lotus_Scripts_Modes_ZarimanCorruptionMission.lua_B', '/Lotus/Scripts/Modes/ZarimanCorruptionMission.lua', 'Void Flood')
LOOP = ('Lotus_Scripts_LoopDefend.lua_B', '/Lotus/Scripts/LoopDefend.lua', 'Mirror Defense')
FACEOFF = ('Lotus_Scripts_Modes_WF99PvPvEMission.lua_B', '/Lotus/Scripts/Modes/WF99PvPvEMission.lua', 'Faceoff')
FATES = ('Lotus_Scripts_Modes_FiveFatesMission.lua_B', '/Lotus/Scripts/Modes/FiveFatesMission.lua', 'Five Fates (Cetus invasion)')
LANTERN = ('Lotus_Scripts_Modes_HalloweenLanternEndless.lua_B', '/Lotus/Scripts/Modes/HalloweenLanternEndless.lua', 'Lantern')
PURGATORY = ('Lotus_Scripts_Modes_Purgatory.lua_B', '/Lotus/Scripts/Modes/Purgatory.lua', 'Purgatory')


def addon(tid, phase1, where, label, unit, fields, confidence='CONFIRMED_STATIC', integer=False, variant='all'):
    module, path, mode = where
    return {'tunable_id': tid, 'phase1': phase1, 'module': module, 'module_path': path, 'mode': mode, 'variant': variant,
            'label': label, 'unit': unit, 'integer': integer, 'confidence': confidence, 'fields': fields}


P2E = 'CONFIRMED_STATIC_PHASE2E'
ADDON = [
    # Survival: reward, life support (capsule + personal pickups), drops, levels, damage at zero life support.
    addon('survival.alert_interval', 'survival.alert_interval', SURVIVAL, 'Seconds per reward rotation (alert Survival)', 's',
          [('alertInterval', 600)], variant='alert'),
    addon('survival.capsule_max_time', 'survival.capsule_max_time', SURVIVAL, 'Life-support capsule maximum time', 's',
          [('maxTimeAvailable', 150)]),
    addon('survival.capsule_initial_time', 'survival.capsule_initial_time', SURVIVAL, 'Life support at mission start', 's',
          [('initialTimeLeft', 150)], P2E),
    addon('survival.capsule_time_added', 'survival.capsule_time_added', SURVIVAL, 'Life support added by an activated capsule', 's',
          [('timeAdded', 45)], P2E),
    addon('survival.capsule_interval', 'survival.capsule_interval', SURVIVAL, 'Seconds between life-support capsule spawns', 's',
          [('interval', 90, 10)], P2E),
    addon('survival.capsule_incoming_time', 'survival.capsule_incoming_time', SURVIVAL, 'Capsule incoming warning time', 's',
          [('incomingTime', 30)], P2E),
    addon('survival.pickup_drop_low_high_mult.lowSpawnThreshold', 'survival.pickup_drop_low_high_mult', SURVIVAL,
          'Life-support fraction below which pickups drop more often', 'fraction', [('lowSpawnThreshold', 0.05)]),
    addon('survival.duviri_drop_mults.duviriQuestMultiplier', 'survival.duviri_drop_mults', SURVIVAL,
          'Life-support pickup drop multiplier, Duviri quest', 'x', [('duviriQuestMultiplier', 2)], variant='Duviri quest'),
    addon('survival.duviri_drop_mults.duviriSurvivalMultiplier', 'survival.duviri_drop_mults', SURVIVAL,
          'Life-support pickup drop multiplier, Duviri Survival', 'x', [('duviriSurvivalMultiplier', 1.2)], variant='Duviri'),
    addon('survival.wf99_drop_mults.wf99SurvivalQuestMultiplier', 'survival.wf99_drop_mults', SURVIVAL,
          'Life-support pickup drop multiplier, 1999 quest', 'x', [('wf99SurvivalQuestMultiplier', 1.2)], variant='1999 quest'),
    addon('survival.level_up_enrage.enrageIntervalMin', 'survival.level_up_enrage', SURVIVAL, 'Minimum enrage interval', 's',
          [('enrageIntervalMin', 3)]),
    addon('survival.level_max_boost.alertLevelMaxBoost', 'survival.level_max_boost', SURVIVAL, 'Maximum level boost in alerts',
          'levels', [('alertLevelMaxBoost', 5)], integer=True, variant='alert'),
    addon('survival.level_max_boost.sortieLevelMaxBoost', 'survival.level_max_boost', SURVIVAL, 'Maximum level boost in sorties',
          'levels', [('sortieLevelMaxBoost', 15)], integer=True, variant='sortie'),
    addon('survival.kuva_level_enrage.levelUpTime', 'survival.kuva_level_enrage', SURVIVAL, 'Kuva Survival level-up time', 's',
          [('levelUpTime', 600)], variant='Kuva'),
    addon('survival.kuva_level_enrage.enrageTime', 'survival.kuva_level_enrage', SURVIVAL, 'Kuva Survival enrage time', 's',
          [('enrageTime', 600)], variant='Kuva'),
    addon('survival.player_damage_at_zero_ls.killPlayerTime', 'survival.player_damage_at_zero_ls', SURVIVAL,
          'Seconds at zero life support before players are killed', 's', [('killPlayerTime', 300)], P2E),
    addon('survival.player_damage_at_zero_ls.playerDamagePercent', 'survival.player_damage_at_zero_ls', SURVIVAL,
          'Damage per tick at zero life support (fraction of health)', 'fraction', [('playerDamagePercent', 0.05)], P2E),
    # Orphix Venom.
    addon('orphix.reward_interval', 'orphix.reward_interval', ORPHIX, 'Rounds per reward', 'rounds', [('interval', 3, 17)],
          integer=True),
    addon('orphix.orphix_interval.interval', 'orphix.orphix_interval', ORPHIX, 'Seconds between Orphix spawns', 's',
          [('interval', 50, 16)]),
    addon('orphix.orphix_interval.condrixCap', 'orphix.orphix_interval', ORPHIX, 'Maximum simultaneous Orphix', 'count',
          [('condrixCap', 3)], integer=True),
    addon('orphix.score_add_per_round', 'orphix.score_add_per_round', ORPHIX, 'Score added per round', 'score',
          [('scoreAddPerRound', 50)]),
    # Void Flood: fill timer, curses, Shadowgrapher fractures per round, player void capacity.
    addon('void_flood.fill_timer.timeToFillMin', 'void_flood.fill_timer', FLOOD, 'Minimum tank fill time', 's',
          [('timeToFillMin', 60)]),
    addon('void_flood.curse_count.curseCountNormal', 'void_flood.curse_count', FLOOD, 'Curses, normal', 'count',
          [('curseCountNormal', 2)], integer=True, variant='normal'),
    addon('void_flood.curse_count.curseCountSteelPath', 'void_flood.curse_count', FLOOD, 'Curses, Steel Path', 'count',
          [('curseCountSteelPath', 4)], integer=True, variant='Steel Path'),
    addon('void_flood.fractures_per_round.shadowgrapher', 'void_flood.curse_count', FLOOD,
          'Fractures per round (Shadowgrapher: maxFractureActive)', 'fractures', [('maxFractureActive', 3)], integer=True,
          variant='Shadowgrapher'),
    addon('void_flood.curse_count.playerCapacity', 'void_flood.curse_count', FLOOD, 'Player void-energy capacity', 'energy',
          [('playerCapacity', 100)]),
    # Mirror Defense (LoopDefend).
    addon('loopdefend.level_and_enrage.alertLevelMaxBoost', 'loopdefend.level_and_enrage', LOOP, 'Maximum level boost in alerts',
          'levels', [('alertLevelMaxBoost', 5, 66)], integer=True, variant='alert'),
    addon('loopdefend.crystal_cluster.groupsToSpawnAtWaveStart', 'loopdefend.crystal_cluster', LOOP,
          'Crystal groups spawned at wave start', 'count', [('groupsToSpawnAtWaveStart', 5, 481)], integer=True),
    addon('loopdefend.crystal_cluster.flashingTimeBeforeDespawn', 'loopdefend.crystal_cluster', LOOP,
          'Crystal flashing time before despawn', 's', [('flashingTimeBeforeDespawn', 5, 481)]),
    addon('loopdefend.crystal_cluster.enemyKillOnTunnelInterval', 'loopdefend.crystal_cluster', LOOP,
          'Enemy kill interval in the tunnel', 's', [('enemyKillOnTunnelInterval', 2, 481)]),
    addon('loopdefend.crystal_cluster.groupsToSpawnPerKillThreshold', 'loopdefend.crystal_cluster', LOOP,
          'Crystal groups per kill threshold', 'count', [('groupsToSpawnPerKillThreshold', 1, 481)], integer=True),
    addon('loopdefend.objective_dot.pickupThresholdModifier', 'loopdefend.objective_dot', LOOP, 'Pickup threshold modifier', 'x',
          [('pickupThresholdModifier', 2, 1)]),
    addon('loopdefend.objective_dot.pickupSpawnRateModifier', 'loopdefend.objective_dot', LOOP, 'Pickup spawn-rate modifier', 'x',
          [('pickupSpawnRateModifier', 1, 1)]),
    # Faceoff (1999 PvPvE).
    *[addon(f'faceoff.excavation.{f.lower()}', 'faceoff.excavation', FACEOFF, f'Excavation {f}', u, [(f, v, 547)], integer=i)
      for f, v, u, i in [('MAX_POWER', 100, 'power', False), ('POWER_PER_CELL', 15, 'power', False),
                         ('POWER_DRAIN_RATE', 1, 'power/s', False), ('DECREASED_TIME_PER_CELL', 10, 's', False),
                         ('EXCAVATION_TIME', 150, 's', False), ('CARRIER_SPAWN_TIME', 20, 's', False),
                         ('MAX_NUM_CELLS_AVAILABLE', 5, 'count', True)]],
    *[addon(f'faceoff.defense_escort.{f.lower()}', 'faceoff.defense_escort', FACEOFF, f'Defense/escort {f}', u, [(f, v, 598)],
            integer=i)
      for f, v, u, i in [('INITIAL_ESCORT_TIME', 150, 's', False), ('CATALYSTS_SPAWN_TIME', 15, 's', False),
                         ('MIN_CATALYSTS', 3, 'count', True), ('MAX_CATALYSTS', 5, 'count', True),
                         ('CATALYST_BONUS_TIME_PCT', 0.05, 'fraction', False)]],
    *[addon(f'faceoff.delivery.{f.lower()}', 'faceoff.delivery', FACEOFF, f'Delivery {f}', u, [(f, v, 668)], integer=i)
      for f, v, u, i in [('TARGET_GOAL_KEYS', 5, 'keys', True), ('KEY_SELF_DESTRUCTION_TIME', 15, 's', False),
                         ('EXIMUS_CHANCE', 0.25, 'chance', False)]],
    addon('faceoff.assassination.kill_goal', 'faceoff.assassination', FACEOFF, 'Assassination kill goal', 'kills',
          [('KILL_GOAL', 3, 717)], integer=True),
    *[addon(f'faceoff.spawn_params.{t}', 'faceoff.spawn_params', FACEOFF, f'Spawn {f}', u, [(f, v, 102)], integer=i)
      for t, f, v, u, i in [('max_spawn_dist', 'maxSpawnDist', 100, 'm', False),
                            ('tier_up_interval', 'tierUpInterval', 1, 's', False), ('max_tier', 'maxTier', 5, 'tier', True)]],
    # Five Fates state times: one table per state, stored in the state array (nested path [state]).
    *[addon(f'fivefates.state_times.state{n}', 'fivefates.state_times', FATES, f'Five Fates state {n} duration', 's',
            [('OverallStateTime', v, i)]) for n, v, i in [(2, 3600, 145), (3, 180, 168), (5, 180, 214)]],
    *[addon(f'fivefates.state_times_sp.state{n}', 'fivefates.state_times_sp', FATES, f'Five Fates Steel Path state {n} duration',
            's', [('OverallStateTime', v, i)], variant='Steel Path') for n, v, i in [(2, 3600, 261), (3, 180, 284), (4, 180, 307),
                                                                                    (5, 180, 330)]],
    # Purgatory difficulty tables (root array of three DUPTABLEs; nested path [difficulty]).
    *[addon(f'purgatory.difficulty{d}.{t}', 'purgatory.difficulty', PURGATORY, f'Purgatory difficulty {d} {t.replace("_", " ")}', u,
            [(f, v, i)], P2E, integer=integer)
      for d, i, vals in [(1, 79, (10, 5, 1)), (2, 80, (25, 10, 2)), (3, 81, (50, 15, 5))]
      for (t, f, u, integer), v in zip([('warrior_level', 'warriorLevel', 'level', True), ('ghost_level', 'ghostLevel', 'level', True),
                                        ('damage_mult', 'damageMult', 'x', False)], vals)],
]


def lua(tid, phase1, where, label, unit, stock, specs, evidence, integer=True, confidence=P2E, owner_kind='LUA_PROTO_LITERAL',
        variant='all'):
    module, path, mode = where
    return {'tunable_id': tid, 'phase1': phase1, 'owner_kind': owner_kind, 'module': module, 'module_path': path, 'mode': mode,
            'variant': variant, 'label': label, 'stock': stock, 'unit': unit, 'integer': integer, 'confidence': confidence,
            'specs': specs, 'evidence': evidence}


def pat(value, owner, count=1, before=None, after=None, protos=None):
    spec = {'kind': 'pattern', 'value': value, 'count': count, 'owner': owner}
    if before:
        spec['before'] = before
    if after:
        spec['after'] = after
    if protos:
        spec['protos'] = protos
    return spec


def const(value, proto, uses, owner):
    return {'kind': 'constant', 'value': value, 'proto': proto, 'uses': uses, 'owner': owner}


def tmpl(value, field, owner, template=None):
    spec = {'kind': 'template', 'value': value, 'field': field, 'owner': owner}
    if template is not None:
        spec['template'] = template
    return spec


LUA = [
    # Void Flood fractures per round: root local frame_83[33] = 3 (normal); protos 68/69 set 5 for Duviri.
    lua('void_flood.fractures_per_round.normal', 'void_flood.fractures_per_round', FLOOD, 'Fractures per round (normal)',
        'fractures', 3, [pat(3, 'root local frame_83[33] = 3 (fractures per round; also the fill-timer round divisor)',
                             protos=['root'], before=['SETTABLEKS:capacity'], after=['DUPTABLE'])],
        'readable L112 frame_83[33] = 3; read by protos 12/21/26/33/34/37/38/39/40/41/68/69 (fracture spawn loop, round '
        'counter and fill-timer floor(n/3)). Protos 68 (L12903) and 69 (L13654) overwrite it with 5 for Duviri and with '
        'maxFractureActive for Shadowgrapher, so this is the normal-mode value only.', owner_kind='LUA_ROOT_TABLE',
        variant='normal'),
    lua('void_flood.fractures_per_round.duviri', 'void_flood.fractures_per_round', FLOOD, 'Fractures per round (Duviri)',
        'fractures', 5, [pat(5, 'frame_83[33] = 5 in the isDuviriVoidFlood branch (mission setup and host-migration copy)',
                             count=2, protos=[68, 69], before=['LOADB', 'SETUPVAL'], after=['SETUPVAL'])],
        'readable L12901-12903 (proto 68) and L13652-13654 (proto 69): frame_83[110] = true; frame_83[33] = 5. Both copies '
        'are the same assignment (setup and host migration) and are patched together.', variant='Duviri'),
    # Lantern (HalloweenLanternEndless).
    lua('lantern.min_score', 'lantern.min_score', LANTERN, 'Minimum score (seconds survived) for success', 's', 300,
        [pat(300, 'goal check: extraction enabled at score >= 300 (P32) and failure below 300 (P34)', count=2,
             after=['*', 'GETIMPORT:#0811edde'])],
        'readable L4461 (proto 32 i400, "Mission goal reached, enabling extraction") and L4896 (proto 34 i197, "Goal score '
        'not reached, mission failed"). The third LOADN 300 (proto 32 i103) is the exploit timer and is not owned.'),
    lua('lantern.extraction_limit', 'lantern.extraction_limit', LANTERN, 'Time limit to reach extraction', 's', 180,
        [pat(180, 'SetObjTimer(180, ...) and SetNetPersistentVar(ReachExtractionTimer, 180)', count=2, protos=[32])],
        'readable L4587 and L4590 (proto 32 i492/i502). The template value scalingTimeInterval = 180 is a separate constant.'),
    lua('lantern.boss_spawn_time', 'lantern.boss_spawn_time', LANTERN, 'Elapsed time before the boss spawns', 's', 900,
        [pat(900, 'if 900 <= elapsed (proto 32 i297)')], 'readable L4321 (proto 32): if not (900 <= elapsed). Only LOADN 900.'),
    *[lua(f'lantern.num_enemies.p{n}', 'lantern.num_enemies', LANTERN, f'Enemy cap, {n} player(s)', 'enemies', v,
          [pat(v, f'root numEnemies[{n}] (SETLIST element {n})', protos=['root'], before=b, after=a)],
          f'readable L90-93 frame_38[75][{n}] = {v} -> frame_38[74].numEnemies; root instruction {77 + n - 1}.',
          owner_kind='LUA_ROOT_TABLE')
      for n, v, b, a in [(1, 10, ['DUPTABLE', 'NEWTABLE'], ['LOADN:20']), (2, 20, ['NEWTABLE', 'LOADN:10'], ['LOADN:25']),
                         (3, 25, ['LOADN:10', 'LOADN:20'], ['LOADN:30']), (4, 30, ['LOADN:20', 'LOADN:25'], ['SETLIST'])]],
    lua('lantern.tier_up_interval', 'lantern.tier_up_interval', LANTERN, 'Seconds between enemy tier increases', 's', 90,
        [tmpl(90, 'tierUpInterval', 'root spawn config tierUpInterval (single-use template)')],
        'readable L88 frame_38[74].tierUpInterval = 90.', integer=False, owner_kind='LUA_ROOT_TABLE'),
    lua('lantern.max_tier', 'lantern.max_tier', LANTERN, 'Maximum enemy tier', 'tier', 5,
        [tmpl(5, 'maxTier', 'root spawn config maxTier (single-use template)')],
        'readable L88 frame_38[74].maxTier = 5.', integer=False, owner_kind='LUA_ROOT_TABLE'),
    lua('lantern.radius_per_kill.p1', 'lantern.radius_per_kill', LANTERN, 'Lamp radius gained per kill, 1 player', 'm', 3.75,
        [const(3.75, 'root', ['LOADK:3.75'], 'root radius-per-kill array element 1')],
        'readable L96 frame_38[80][1] = 3.75 (root i84).', integer=False, owner_kind='LUA_ROOT_TABLE'),
    lua('lantern.radius_per_kill.p2', 'lantern.radius_per_kill', LANTERN, 'Lamp radius gained per kill, 2 players', 'm', 2,
        [pat(2, 'root radius-per-kill array element 2', protos=['root'], before=['NEWTABLE', 'LOADK:3.75'], after=['LOADK:1.75'])],
        'readable L97 frame_38[80][2] = 2 (root i85).', owner_kind='LUA_ROOT_TABLE'),
    lua('lantern.radius_per_kill.p3', 'lantern.radius_per_kill', LANTERN, 'Lamp radius gained per kill, 3 players', 'm', 1.75,
        [const(1.75, 'root', ['LOADK:1.75'], 'root radius-per-kill array element 3')],
        'readable L98 frame_38[80][3] = 1.75 (root i86).', integer=False, owner_kind='LUA_ROOT_TABLE'),
    lua('lantern.radius_per_kill.p4', 'lantern.radius_per_kill', LANTERN, 'Lamp radius gained per kill, 4 players', 'm', 1.5,
        [const(1.5, 'root', ['LOADK:1.5'], 'root radius-per-kill array element 4')],
        'readable L99 frame_38[80][4] = 1.5 (root i87; protos 23/32 hold their own 1.5 constants).', integer=False,
        owner_kind='LUA_ROOT_TABLE'),
    *[lua(f'lantern.lamp_decay.{f}', 'lantern.lamp_decay', LANTERN, f'Lamp decay curve constant {f}', 'x', v,
          [tmpl(v, f, f'root lamp decay table {f} (single-use template)')],
          f'readable L104 frame_38[88].{f} = {v}; consumer proto 23 currentRate formula.', integer=False,
          owner_kind='LUA_ROOT_TABLE') for f, v in [('b', 2.2), ('v', 0.3), ('m', 0.04), ('p', 1.7)]],
    lua('lantern.lamp_min_radius', 'lantern.lamp_min_radius', LANTERN, 'Lamp minimum radius', 'm', 7,
        [pat(7, 'math.max(7, radius) (P23 i562) and radius <= 7 expiry checks (P23 i586, P32 i165)', count=3),
         const(7, 23, ['FASTCALL2K:7', 'LOADK:7', 'SUBK:7', 'SUBK:7'], 'P23 K10: math.max(radius, 7) and clampedRadius - 7'),
         const(7, 31, ['FASTCALL2K:7', 'LOADK:7'], 'P31 K21: math.max(radius, 7)')],
        'Every 7 in the module is the lamp minimum radius: clamps (L1844, L2588, L3896), expiry checks (L2613, P32) and the '
        'offsets clampedRadius - 7 (L2557, L2775). The light lerps divide by 25 (= 32 - 7) and 9; those divisors are not '
        'owned, so they stay stock (visual light intensity only).'),
    lua('lantern.lamp_max_radius', 'lantern.lamp_max_radius', LANTERN, 'Lamp maximum radius', 'm', 32,
        [pat(32, 'math.min(32, radius) (P23 i450)'),
         const(32, 23, ['DIVK:32'], 'P23 clampedRadius / 32 (light)'),
         const(32, 28, ['DIVK:32'], 'P28 radius / 32 * 100 (HUD percent)'),
         const(32, 32, ['DIVK:32'], 'P32 radius / 32 * 100 (HUD percent)')],
        'Every 32 in the module is the lamp maximum radius: the clamp (L2446) and the three normalisations radius / 32 '
        '(L3045, L3475, L4155). The lerp divisor 25 (= 32 - 7) is not owned and stays stock.'),
    # Purgatory.
    lua('purgatory.initial_time', 'purgatory.initial_time', PURGATORY, 'Purgatory starting time', 's', 60,
        [pat(60, '_T.Purgatory.timeRemaining = 60 (proto 27)', after=['SETTABLEKS:timeRemaining'])],
        'readable proto 27: Purgatory.timeRemaining = 60. Only LOADN 60 in the module; the 60 constants are minute/second '
        'conversions.'),
    lua('purgatory.pickup_time_bonus', 'purgatory.pickup_time_bonus', PURGATORY, 'Seconds added per time pickup', 's', 5,
        [const(5, 0, ['ADDK:5'], 'proto 0: timeRemaining = timeRemaining + 5')],
        'readable L119-133 (proto 0): _T.Purgatory.timeRemaining + 5.', integer=False),
    lua('purgatory.pickup_drop_chance', 'purgatory.pickup_drop_chance', PURGATORY, 'Time pickup drop chance per kill', 'chance', 0.1,
        [const(0.1, 8, ['LOADK:0.1'], 'proto 8: if FRand() <= 0.1 then drop')],
        'readable L899-901 (proto 8): FRand() <= 0.1.', integer=False),
    lua('purgatory.initial_pickups', 'purgatory.initial_pickups', PURGATORY, 'Time pickups placed at start', 'count', 5,
        [pat(5, 'root frame_40[108] = 5 (min(#points, 5) pickups spawned in proto 26)', protos=['root'],
             before=['LOADNIL', 'LOADNIL', 'LOADNIL'], after=['LOADN:3'])],
        'readable L92 frame_40[108] = 5; proto 26 L3543-3549 spawns min(#points, frame_40[108]).', owner_kind='LUA_ROOT_TABLE'),
    *[lua(f'purgatory.reward_kill_threshold.t{n}', 'purgatory.reward_kill_threshold', PURGATORY, f'Reward tier {n} kill threshold',
          'kills', v, [pat(v, f'root kill-threshold array element {n}', protos=['root'], before=b, after=a)],
          f'readable L70-75 frame_40[81][{n}] = {v} (root i{83 + n}); consumers protos 2, 11, 30, 31.', owner_kind='LUA_ROOT_TABLE')
      for n, v, b, a in [(1, 25, ['SETLIST', 'NEWTABLE'], ['LOADN:50']), (2, 50, ['NEWTABLE', 'LOADN:25'], ['LOADN:75']),
                         (3, 75, ['LOADN:25', 'LOADN:50'], ['LOADN:100']), (4, 100, ['LOADN:50', 'LOADN:75'], ['LOADN:125']),
                         (5, 125, ['LOADN:75', 'LOADN:100'], ['LOADN:150']), (6, 150, ['LOADN:100', 'LOADN:125'], ['SETLIST'])]],
    lua('purgatory.enemy_cap', 'purgatory.enemy_cap', PURGATORY, 'Enemy cap', 'enemies', 10,
        [pat(10, 'root frame_40[97] = 10', protos=['root'], before=['LOADK:4.5', 'LOADN:0'], after=['GETIMPORT:#cef5d9d1'])],
        'readable L83 frame_40[97] = 10; proto 12 lowers it to 2/5 only in Protea quest branches.', owner_kind='LUA_ROOT_TABLE'),
    lua('purgatory.spawn_interval.min', 'purgatory.spawn_interval', PURGATORY, 'Spawn interval minimum', 's', 3,
        [pat(3, 'root frame_40[94] = Range(3, 5) minimum', protos=['root'], before=['GETIMPORT:#cef5d9d1'], after=['LOADN:5', 'CALL'])],
        'readable L80 frame_40[94] = Range(3, 5).', owner_kind='LUA_ROOT_TABLE'),
    lua('purgatory.spawn_interval.max', 'purgatory.spawn_interval', PURGATORY, 'Spawn interval maximum', 's', 5,
        [pat(5, 'root frame_40[94] = Range(3, 5) maximum', protos=['root'], before=['LOADN:3'], after=['CALL', 'LOADK:4.5'])],
        'readable L80 frame_40[94] = Range(3, 5).', owner_kind='LUA_ROOT_TABLE'),
    lua('purgatory.spawn_batch.min', 'purgatory.spawn_batch', PURGATORY, 'Enemies per spawn batch, minimum', 'enemies', 2,
        [pat(2, 'root frame_40[101] = Range(2, 4) minimum', protos=['root'], before=['GETIMPORT:#cef5d9d1'], after=['LOADN:4', 'CALL'])],
        'readable L85 frame_40[101] = Range(2, 4); proto 12 edits min/max only in the Protea quest branch.',
        owner_kind='LUA_ROOT_TABLE'),
    lua('purgatory.spawn_batch.max', 'purgatory.spawn_batch', PURGATORY, 'Enemies per spawn batch, maximum', 'enemies', 4,
        [pat(4, 'root frame_40[101] = Range(2, 4) maximum', protos=['root'], before=['LOADN:2'], after=['CALL', 'LOADNIL'])],
        'readable L85 frame_40[101] = Range(2, 4).', owner_kind='LUA_ROOT_TABLE'),
]


def phase1(tid, where, description, stock, unit, owner_kind, detail, notes, variant='all'):
    module, path, mode = where
    return {'mission_type': mode, 'variant': variant, 'tunable_id': tid, 'description': description, 'stock_value': stock,
            'unit': unit, 'owner_kind': owner_kind, 'owner_detail': path + ' ' + detail, 'shared_with': '', 'notes': notes,
            'confidence': 'CONFIRMED_STATIC', 'source_group': 'phase2e', 'ability_editor': 'not covered',
            'source_label': mode, 'mt_code': '', 'added_by': 'Phase 2e 2026-09-29 (analysed in Phase 1, not tabulated)'}


PHASE1 = [
    phase1('void_flood.fractures_per_round', FLOOD, 'Void fractures opened per round', 'normal 3; Duviri 5; Shadowgrapher '
           'maxFractureActive=3', 'fractures', 'LUA_ROOT_TABLE', 'root frame_83[33] = 3 (L112); proto 68 L12903 / proto 69 '
           'L13654 = 5 (Duviri); frame_83[168].maxFractureActive (Shadowgrapher)', 'Read by the fracture spawn loop and the '
           'fill-timer divisor floor(n/frame_83[33]).'),
    phase1('lantern.min_score', LANTERN, 'Minimum score (seconds survived) for success', '300', 's', 'LUA_PROTO_LITERAL',
           'proto 32 L4461 / proto 34 L4896 (300 <= score)', 'Extraction enabled at 300; mission fails below 300.'),
    phase1('lantern.extraction_limit', LANTERN, 'Time limit to reach extraction', '180', 's', 'LUA_PROTO_LITERAL',
           'proto 32 L4587/L4590', 'SetObjTimer and ReachExtractionTimer net var.'),
    phase1('lantern.boss_spawn_time', LANTERN, 'Elapsed time before the boss spawns', '900', 's', 'LUA_PROTO_LITERAL',
           'proto 32 L4321', ''),
    phase1('lantern.num_enemies', LANTERN, 'Enemy cap by player count', '{10,20,25,30}', 'enemies', 'LUA_ROOT_TABLE',
           'root frame_38[74].numEnemies = frame_38[75] (L88-94)', ''),
    phase1('lantern.tier_up_interval', LANTERN, 'Seconds between enemy tier increases', '90', 's', 'LUA_ROOT_TABLE',
           'root frame_38[74].tierUpInterval (L88)', ''),
    phase1('lantern.max_tier', LANTERN, 'Maximum enemy tier', '5', 'tier', 'LUA_ROOT_TABLE', 'root frame_38[74].maxTier (L88)', ''),
    phase1('lantern.radius_per_kill', LANTERN, 'Lamp radius gained per kill by player count', '{3.75,2,1.75,1.5}', 'm',
           'LUA_ROOT_TABLE', 'root frame_38[80] (L95-99)', ''),
    phase1('lantern.lamp_decay', LANTERN, 'Lamp decay curve constants', 'b=2.2; v=0.3; m=0.04; p=1.7', 'x', 'LUA_ROOT_TABLE',
           'root frame_38[88] (L104)', 'currentRate formula in proto 23.'),
    phase1('lantern.lamp_min_radius', LANTERN, 'Lamp minimum radius', '7', 'm', 'LUA_PROTO_LITERAL',
           'protos 23/31/32 (math.max(radius, 7), radius <= 7, clampedRadius - 7)', 'Light lerps also use 25 (= 32 - 7) and 9.'),
    phase1('lantern.lamp_max_radius', LANTERN, 'Lamp maximum radius', '32', 'm', 'LUA_PROTO_LITERAL',
           'proto 23 L2446 math.min(32, r); radius / 32 in protos 23/28/32', ''),
    phase1('purgatory.initial_time', PURGATORY, 'Purgatory starting time', '60', 's', 'LUA_PROTO_LITERAL',
           'proto 27 Purgatory.timeRemaining = 60', ''),
    phase1('purgatory.pickup_time_bonus', PURGATORY, 'Seconds added per time pickup', '5', 's', 'LUA_PROTO_LITERAL',
           'proto 0 L119-133 timeRemaining + 5', ''),
    phase1('purgatory.pickup_drop_chance', PURGATORY, 'Time pickup drop chance per kill', '0.1', 'chance', 'LUA_PROTO_LITERAL',
           'proto 8 L899-901 FRand() <= 0.1', ''),
    phase1('purgatory.initial_pickups', PURGATORY, 'Time pickups placed at start', '5', 'count', 'LUA_ROOT_TABLE',
           'root frame_40[108] = 5 (L92); proto 26 L3543-3549', ''),
    phase1('purgatory.difficulty', PURGATORY, 'Warrior level / ghost level / damage multiplier per difficulty',
           '{10/5/1, 25/10/2, 50/15/5}', 'level / x', 'LUA_ROOT_TABLE', 'root frame_40[77][1..3] = frame_40[78..80] (L62-68)',
           'Consumer proto 37 (difficulty index).'),
    phase1('purgatory.reward_kill_threshold', PURGATORY, 'Kill thresholds of the reward tiers', '{25,50,75,100,125,150}',
           'kills', 'LUA_ROOT_TABLE', 'root frame_40[81] (L69-75)', ''),
    phase1('purgatory.enemy_cap', PURGATORY, 'Enemy cap', '10', 'enemies', 'LUA_ROOT_TABLE', 'root frame_40[97] = 10 (L83)',
           'Protea quest branches lower it to 2/5 (proto 12).'),
    phase1('purgatory.spawn_interval', PURGATORY, 'Spawn interval range', 'Range(3,5)', 's', 'LUA_ROOT_TABLE',
           'root frame_40[94] = Range(3, 5) (L80)', ''),
    phase1('purgatory.spawn_batch', PURGATORY, 'Enemies per spawn batch', 'Range(2,4)', 'enemies', 'LUA_ROOT_TABLE',
           'root frame_40[101] = Range(2, 4) (L85)', ''),
]

# (P2D `phase1` string, `part` or None) -> resolved by Phase 2e.
RESOLVES = [
    ('loopdefend.level_and_enrage.alertLevelMaxBoost; loopdefend.crystal_cluster.groupsToSpawnAtWaveStart, '
     '.flashingTimeBeforeDespawn', None),
    ('loopdefend.objective_dot.pickupThresholdModifier; loopdefend.crystal_cluster.enemyKillOnTunnelInterval', None),
    ('loopdefend.objective_dot.pickupSpawnRateModifier; loopdefend.crystal_cluster.groupsToSpawnPerKillThreshold', None),
    ('survival.alert_interval', None), ('survival.capsule_max_time', None),
    ('survival.pickup_drop_low_high_mult', 'lowSpawnThreshold only'), ('survival.duviri_drop_mults', None),
    ('survival.wf99_drop_mults', 'wf99SurvivalQuestMultiplier only'), ('survival.level_up_enrage', 'enrageIntervalMin only'),
    ('survival.level_max_boost', None), ('survival.kuva_level_enrage', None),
    ('orphix.reward_interval', None), ('orphix.orphix_interval', 'interval, condrixCap'), ('orphix.score_add_per_round', None),
    ('void_flood.fill_timer', 'timeToFillMin'), ('void_flood.fill_timer', 'divisor frame_83[33]=3'),
    ('void_flood.curse_count', None), ('void_flood.curse_count', 'maxFractureActive, playerCapacity'),
    ('fivefates.state_times', 'state 2 = 3600'), ('fivefates.state_times', 'states 3,5 = 180'),
    ('fivefates.state_times_sp', 'state 2 = 3600; states 3,4,5 = 180'),
    ('faceoff.excavation', 'MAX_POWER, POWER_PER_CELL, POWER_DRAIN_RATE, DECREASED_TIME_PER_CELL, EXCAVATION_TIME, '
                           'CARRIER_SPAWN_TIME, MAX_NUM_CELLS_AVAILABLE'),
    ('faceoff.defense_escort', 'INITIAL_ESCORT_TIME, CATALYSTS_SPAWN_TIME, MIN_CATALYSTS, MAX_CATALYSTS, CATALYST_BONUS_TIME_PCT'),
    ('faceoff.delivery', 'TARGET_GOAL_KEYS, KEY_SELF_DESTRUCTION_TIME, EXIMUS_CHANCE'),
    ('faceoff.assassination', 'KILL_GOAL 3'), ('faceoff.spawn_params', 'maxSpawnDist 100, tierUpInterval 1, maxTier 5'),
]

# Parts of Phase 1 rows Phase 2e touched but did not register.
EXCLUDED_PARTS = [
    {'phase1': 'survival.player_damage_at_zero_ls', 'part': 'alertPlayerDamagePercent',
     'reason': 'addon gate FAIL: no capturer reads alertPlayerDamagePercent (unread field)'},
    {'phase1': 'survival.player_damage_at_zero_ls', 'part': 'playerDamageCurve, playerDamageMult',
     'reason': 'addon gate FAIL: no capturer reads the field through the captured table upvalue (consumer not proven)'},
]

# Phase 2d shared-constant exclusions whose tables also fail the addon gate (appended to the exclusion reason).
ADDON_FAILED = {
    'disruption.demolyst_tier_min': 'Phase 2e addon gate FAIL: the active variant table is swapped by SETUPVAL in prototype 73 '
                                    '(the captured table identity is not fixed); the other two variant tables are never read '
                                    'through a capture.',
    'disruption.leader_spawn_curve': 'Phase 2e addon gate FAIL: variant table swapped by SETUPVAL in prototype 73.',
    'disruption.demolyst_spawn_radius_range': 'Phase 2e addon gate FAIL: variant table swapped by SETUPVAL in prototype 73.',
    'archimedea.eta_enemy_levels': 'Phase 2e addon gate not applicable: ConquestLib is a library; its tables leave the module '
                                   'through exports, not closure captures.',
    'archimedea.eda_enemy_levels': 'Phase 2e addon gate not applicable: ConquestLib library table (exported).',
    'sentientcapture.swarm': 'Phase 2e addon gate not applicable: the table is built in prototype 15, not by the module root.',
}
