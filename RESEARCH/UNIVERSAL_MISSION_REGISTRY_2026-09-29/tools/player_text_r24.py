"""Player text for the contract R24 Descendia reader pins (2026-11-07, client 44.1.3 2026.10.22.13.12).

User request (2026-11-07): a Descendia settings tab with the per-mode progress values (timers, counts, rates). The rows are
Descendia trigger script parameters pinned at their readers (IMPORT_READ_PIN_V1, live literal lane, next mission); see
RESEARCH/MISSIONS_R24_DESCENDIA_PINS_2026-11-07. Rows of a script that another mode also runs say so in their text.
`register()` is called by player_text.py with its `row` helper.
"""

ROWS = (
    # (tunable id, label, description without the stock phrase, unit word when the registry unit has none)
    ('cohinterception.descendia_beacon_chase_target_time', 'Beacon progress time',
     'Seconds you must stay with the moving beacon to complete it', None),
    ('coh_excavation.descendia_base_excavator_health', 'Excavator health',
     'Health of each excavator before level scaling', None),
    ('coh_excavation.descendia_base_excavator_shields', 'Excavator shields',
     'Shields of each excavator before level scaling', ' shields'),
    ('shrine.descendia_offering_generation_time', 'Offering generation time',
     'Seconds to generate one offering', None),
    ('shrine.descendia_defend_huts_offering_num', 'Defend offerings',
     'Offerings needed to finish the defend stage', ' offerings'),
    ('shrine.descendia_boss_offering_num', 'Boss stage offerings',
     'Offerings needed in the boss stage', ' offerings'),
    ('shrine.descendia_spawn_point_filter_distance', 'Enemy spawn spacing',
     'Minimum distance between enemy spawn points and players', ' m'),
    ('meltdown.descendia_start_mission_delay', 'Meltdown start delay',
     'Seconds before the meltdown starts, Descendia and Entrati lab', None),
    ('meltdown.descendia_vents_to_reveal', 'Vents per round',
     'Vents revealed each round, Descendia and Entrati lab', ' vents'),
    ('meltdown.descendia_in_range_multiplier', 'Scan speed in range',
     'Vent scan speed multiplier while you stand in range, Descendia and Entrati lab', 'x'),
    ('meltdown.descendia_vent_search_distance', 'Vent search distance',
     'Distance within which vents are chosen, Descendia and Entrati lab', ' m'),
    ('alchemy.descendia_transmuter_goal', 'Mixtures required',
     'Mixtures to complete before the floor ends, Descendia and Entrati lab', ' mixtures'),
    ('alchemy.descendia_crucible_remind_countdown', 'Crucible reminder time',
     'Seconds before the reminder to use the crucible appears, Descendia and Entrati lab', None),
    ('infested_capture.descendia_searching_rounds_before_boss', 'Rounds before boss',
     'Search rounds before the Legacyte appears, Descendia and 1999', ' rounds'),
    ('infested_capture.descendia_base_number_of_mutations', 'Legacyte mutations',
     'Abilities the Legacyte starts with, Descendia and 1999', ' abilities'),
    ('infested_capture.descendia_base_tentacle_health', 'Tentacle health',
     'Health of each tentacle before level scaling, Descendia and 1999', None),
    ('infested_capture.descendia_kalymos_search_spot_range', 'Kalymos search range',
     'Distance Kalymos searches for its next spot, Descendia and 1999', ' m'),
    ('infested_capture.descendia_wander_radius', 'Kalymos wander radius',
     'Radius Kalymos wanders in at a search spot, Descendia and 1999', ' m'),
    ('infested_capture.descendia_wander_time', 'Kalymos wander time',
     'Seconds Kalymos wanders before moving on, Descendia and 1999', None),
)


def register(row, master):
    for tid, label, text, word in ROWS:
        row(tid, label, text + '; applies from the next mission', 'adv', word=word)
