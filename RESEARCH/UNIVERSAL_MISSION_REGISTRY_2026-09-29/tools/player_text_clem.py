"""Player text for Clem's weekly goal (2026-10-28, GOAL_TAG variant).

User request (2026-10-28): edit Clem's weekly mission ("Help Clem") from the Missions settings, under Events > Clem.
The mission rotates weekly between Survival versions (maxWaveNum 10 = minutes to finish) and Mobile Defense versions
(maxWaveNum 540 = total defense time in seconds, split over the terminals). Each version is one row written at its mode
script's entry when goalTag == GetClem; a single row needs no master (a master over one row only duplicated it).
`register()` is called by player_text.py with its helpers.
"""


def register(row, master):
    row('clem.survival_minutes', 'Survival: minutes to finish',
        "Minutes to survive when Clem's weekly mission is a Survival; applies from the next run", word=' min')
    row('clem.mobiledefense_seconds', 'Mobile Defense: defense time',
        "Total defense time when Clem's weekly mission is a Mobile Defense, split over the terminals; applies from the "
        "next run", word=' s')
