"""Phase 2d metadata splits (client 44.0.2). Each entry is ONE control: one trigger owner type and one script parameter.

The registrar resolves every Scripts entry of the owner type that carries the parameter with the runtime
EeNotationParser rules (list separators are not elements, so the second entry is `Scripts.1`, not the
Phase 1 `Scripts.2`), requires all entries to hold the same stock value, and patches all of them together.
Phase 1 rows that named two trigger owners, several fields, or several Scripts entries are split here.
"""

_IC_1999 = '/Lotus/Types/Gameplay/1999Wf/Capture/InfestedCaptureModeScriptTrigger'
_IC_COH = '/Lotus/Types/Gameplay/DevilTower/LiteGameModes/CoHInfestedCaptureScriptTrigger'
_ALCH_LAB = '/Lotus/Types/Gameplay/EntratiLab/Alchemy/EntratiLabAlchemyStartTrigger'
_ALCH_COH = '/Lotus/Types/Gameplay/DevilTower/CoHAlchemyStartTrigger'
_MELT_LAB = '/Lotus/Types/Gameplay/EntratiLab/Alchemy/EntratiLabAlchemyDefendTrigger'
_MELT_COH = '/Lotus/Types/Gameplay/DevilTower/LiteGameModes/CoHMeltdownTrigger'
_ASC = '/Lotus/Types/Gameplay/JadeShadows/AscensionMode/AscensionModeScriptTrigger'
_COH_EXC = '/Lotus/Types/Gameplay/DevilTower/LiteGameModes/CoHExcavationScriptTrigger'
_HELL = '/Lotus/Types/Gameplay/DevilTower/LiteGameModes/HellDefenseTrigger'
_SHRINE = '/Lotus/Types/Gameplay/DevilTower/LiteGameModes/CoHShrineDefenseTrigger'


def _pair(phase1, suffix, param, unit, label, mode_1999, mode_coh, t1, t2, v1, v2, integer=False):
    return [
        {'tunable_id': f'{phase1}{suffix}.{v1}', 'phase1': phase1, 'type': t1, 'param': param, 'unit': unit,
         'label': label, 'mode': mode_1999, 'variant': v1, 'integer': integer},
        {'tunable_id': f'{phase1}{suffix}.{v2}', 'phase1': phase1, 'type': t2, 'param': param, 'unit': unit,
         'label': label, 'mode': mode_coh, 'variant': v2, 'integer': integer},
    ]


def _ic(phase1, suffix, param, unit, label, integer=False):
    return _pair(phase1, suffix, param, unit, label, 'Legacyte Harvest (1999)', 'Descendia: Legacyte Harvest',
                 _IC_1999, _IC_COH, 'wf1999', 'descendia', integer)


def _alch(phase1, param, unit, label, integer=False):
    return _pair(phase1, '', param, unit, label, 'Alchemy (Entrati lab)', 'Descendia: Alchemy',
                 _ALCH_LAB, _ALCH_COH, 'lab', 'descendia', integer)


def _melt(phase1, suffix, param, unit, label, integer=False):
    return _pair(phase1, suffix, param, unit, label, 'Meltdown (Entrati lab Alchemy defend)', 'Descendia: Meltdown',
                 _MELT_LAB, _MELT_COH, 'lab', 'descendia', integer)


def _one(tid, phase1, t, param, unit, label, mode, variant='', integer=False):
    return [{'tunable_id': tid, 'phase1': phase1, 'type': t, 'param': param, 'unit': unit, 'label': label,
             'mode': mode, 'variant': variant, 'integer': integer}]


METADATA = (
    _ic('infested_capture.search_time', '', '_searchTime', 's', 'Search progress duration before the Legacyte is found')
    + _ic('infested_capture.base_mutations', '', '_baseNumberOfMutations', 'count', 'Base number of Legacyte mutations (abilities)', True)
    + _ic('infested_capture.search_rounds_before_boss', '', '_searchingRoundsBeforeBoss', 'rounds', 'Search rounds before the boss round', True)
    + _ic('infested_capture.tentacle_health', '', '_baseTentacleHealth', 'HP', 'Base tentacle health')
    + _ic('infested_capture.wander', '.wander_time', '_wanderTime', 's', 'Kalymos wander time between search spots')
    + _ic('infested_capture.wander', '.wander_radius', '_wanderRadius', 'm', 'Kalymos wander radius')
    + _ic('infested_capture.search_spot_range', '', '_kalymosSearchSpotRange', 'm', 'Kalymos search spot range')
    + _alch('alchemy.mixtures_required_default', '_TRANSMUTER_GOAL', 'mixtures', 'Mixtures required when MissionInfo.maxWaveNum does not override it', True)
    + _alch('alchemy.reward_interval', '_rewardInterval', 'mixtures', 'Reward every N mixtures', True)
    + _alch('alchemy.crucible_remind_countdown', '_CRUCIBLE_REMIND_COUNTDOWN', 's', 'Crucible reminder countdown')
    + _melt('meltdown.heat_increase', '', '_HEAT_INCREASE', 'heat per tick', 'Heat added per tick')
    + _melt('meltdown.heat_decrease', '', '_heatDecreaseAmount', 'heat per tick', 'Heat removed per tick while venting')
    + _melt('meltdown.vents_to_reveal', '', '_VENTS_TO_REVEAL', 'count', 'Vents revealed per round', True)
    + _melt('meltdown.scan_rate', '.scan_rate', '_SCAN_RATE', 'rate', 'Vent scan rate')
    + _melt('meltdown.scan_rate', '.in_range_multiplier', '_inRangeMultiplier', 'x', 'Scan rate multiplier while in range')
    + _melt('meltdown.start_delay', '', '_startMissionDelay', 's', 'Delay before the meltdown starts')
    + _melt('meltdown.vent_search_distance', '', '_VENT_SEARCH_DISTANCE', 'm', 'Vent search distance')
    + _one('ascension.elevator_animation_time.elevator_animation_time', 'ascension.elevator_animation_time', _ASC,
           '_elevatorAnimationTime', 's', 'Elevator animation time (scaled by boostTimeModifier)', 'Ascension')
    + _one('ascension.elevator_animation_time.boost_time_modifier', 'ascension.elevator_animation_time', _ASC,
           '_boostTimeModifier', 'x', 'Elevator boost time modifier', 'Ascension')
    + _one('ascension.elevator_shield', 'ascension.elevator_shield', _ASC, '_elevatorShield', 'shield', 'Elevator shield', 'Ascension')
    + _one('ascension.fuel.adding_fuel_amount', 'ascension.fuel', _ASC, '_addingFuelAmmount', 'fuel', 'Fuel added per delivery', 'Ascension')
    + _one('ascension.fuel.max_default_capacity', 'ascension.fuel', _ASC, '_maxDefaultCapacity', 'fuel', 'Default fuel capacity', 'Ascension')
    + _one('ascension.fuel.elevator_boost_duration', 'ascension.fuel', _ASC, '_elevatorBoostDuration', 's', 'Elevator boost duration', 'Ascension')
    + _one('coh_excavation.base_health', 'coh_excavation.base_health', _COH_EXC, '_baseExcavatorHealth', 'HP',
           'Base excavator health (gameplay and HUD instances)', 'Descendia: Excavation')
    + _one('coh_excavation.base_shields', 'coh_excavation.base_shields', _COH_EXC, '_baseExcavatorShields', 'shield',
           'Base excavator shields (gameplay and HUD instances)', 'Descendia: Excavation')
    + _one('coh_excavation.spawn_invulnerability', 'coh_excavation.spawn_invulnerability', _COH_EXC,
           '_excavatorSpawnInvulnerabilityDuration', 's', 'Excavator spawn invulnerability', 'Descendia: Excavation')
    + _one('coh_excavation.health_level_power.squad', 'coh_excavation.health_level_power', _COH_EXC,
           '_sharedHealthPoolLevelPower', 'exponent', 'Shared health pool level exponent (squad)', 'Descendia: Excavation')
    + _one('coh_excavation.health_level_power.solo', 'coh_excavation.health_level_power', _COH_EXC,
           '_sharedHealthPoolLevelPowerSolo', 'exponent', 'Shared health pool level exponent (solo)', 'Descendia: Excavation')
    + _one('defense.target_level_falloff.point', 'defense.target_level_falloff', _HELL, '_targetMaxLevelFalloffPoint',
           'level', 'Target max level falloff point', 'Descendia: Defense')
    + _one('defense.target_level_falloff.intensity', 'defense.target_level_falloff', _HELL, '_targetMaxLevelFalloffIntensity',
           'level', 'Target max level falloff intensity', 'Descendia: Defense')
    + _one('defense.target_level_falloff.hardmode_bump', 'defense.target_level_falloff', _HELL, '_targetMaxLevelHardmodeBump',
           'level', 'Steel Path target max level bump', 'Descendia: Defense')
    + _one('shrine.offering_counts.num_offerings', 'shrine.offering_counts', _SHRINE, '_numOfferings', 'count',
           'Offerings per generation', 'Descendia: Shrine Defense', integer=True)
    + _one('shrine.offering_counts.defend_huts_offering_num', 'shrine.offering_counts', _SHRINE, '_defendHutsOfferingNum',
           'count', 'Offerings to deliver to finish the defend stage', 'Descendia: Shrine Defense', integer=True)
    + _one('shrine.offering_counts.boss_offering_num', 'shrine.offering_counts', _SHRINE, '_bossOfferingNum', 'count',
           'Boss offerings', 'Descendia: Shrine Defense', integer=True)
    + _one('shrine.pickup_and_spawn_misc.pickup_anim_play_rate', 'shrine.pickup_and_spawn_misc', _SHRINE, '_pickupAnimPlayRate',
           'rate', 'Offering pickup animation play rate', 'Descendia: Shrine Defense')
    + _one('shrine.pickup_and_spawn_misc.spawn_point_filter_distance', 'shrine.pickup_and_spawn_misc', _SHRINE,
           '_spawnPointFilterDistance', 'm', 'Spawn point filter distance', 'Descendia: Shrine Defense')
)

# Phase 1 metadata rows (or parts of them) that stay excluded after the Phase 2d split, with the exact reason.
EXCLUDED = [
    {'phase1': 'alchemy.variant_flags', 'reason': 'variant-switch flags (_isCircle / _isDuviriCircuit) select stock branches; not a tunable value'},
    {'phase1': 'defense.variant_flags', 'reason': 'variant-switch flags (_isDuviriDefense / _isCircle) select stock branches; not a tunable value'},
    {'phase1': 'defense.mover_schedule', 'reason': '_defenseMoverWaves is a list (not in the numeric snapshot); _defenseMoverLoop/_defenseMoverRandom are flags; '
                                                   '_defenseMoverRandomWaveInterval/_defenseMoverRandomChance are read only behind `if defenseMoverRandom` '
                                                   'whose runtime value type (number 0 is truthy in Lua, boolean false is not) is not established offline'},
    {'phase1': 'defense.rotation_resource_reward', 'reason': 'the named reward-amount fields are not present in the composed HellDefenseTrigger Scripts entry; owner type not established'},
    {'phase1': 'cohinterception.beacon_count', 'reason': '_targetBecons is not present in the composed MobileInterceptionScriptTrigger snapshot (list value); owner not established'},
    {'phase1': 'descendia.total_floor_count_metadata', 'reason': 'five Scripts entries of CoHMissionScriptTrigger hold different values (21 vs 30) and the authoritative owner is '
                                                            'CoHArenaLib.SetupCurrentDescent (Phase 1 PARTIAL); one control cannot own them'},
    {'phase1': 'shrine.offering_counts', 'part': '_randomizeOfferingSpawn / _offeringIndex', 'reason': 'flag / index values, not tunable amounts'},
    {'phase1': 'entrati_swarm.octopede_variation', 'reason': 'negative selector/index value; value domain not established'},
]
