"""Player text for Events batch 2 (2026-10-29, GOAL_TAG incl. "from 0"): Hallowed Flame, Anniversary 2022 Purify,
Orphix Venom and The Long Shadow Bonus Survival.

Endless missions (stock 0) stay endless at 0; any other value gives them a fixed length.
Generated from MISSIONS_EVENTS_BATCH2_2026-10-29/inputs/event_batch2_row_drafts.json.
"""


def register(row, master):
    row('hallowedflame.lantern_a_seconds', 'Lantern A: seconds',
        'Seconds to survive in the Hallowed Flame Lantern A mission (normally 300); applies from the next run', word=' s')
    row('hallowedflame.lantern_b_seconds', 'Lantern B: seconds',
        'Seconds to survive in the Hallowed Flame Lantern B mission (normally 420); applies from the next run', word=' s')
    row('hallowedflame.lantern_c_seconds', 'Lantern C: seconds',
        'Seconds to survive in the Hallowed Flame Lantern C mission (normally 600); applies from the next run', word=' s')
    row('hallowedflame.lantern_d_seconds', 'Lantern D: seconds',
        'Seconds to survive in the Hallowed Flame Lantern D mission (endless; 0 keeps it endless); applies from the next run', word=' s')
    row('anniversary.2022j_purify_rounds', '2022 Purify: rounds',
        'Rounds to win in the Anniversary 2022: Purify mission (normally 3); applies from the next run', word=' rounds')
    row('nightwatch.bonus_survival_minutes', 'Bonus Survival: minutes',
        'Minutes to survive in the The Long Shadow Bonus Survival mission (endless; 0 keeps it endless); applies from the next run', word=' min')
