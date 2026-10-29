"""Player text for Events batch 1 (2026-10-29, GOAL_TAG variant): Anniversary and The Long Shadow tactical alerts.

User request (2026-10-28/29): event tac alerts under Events, one submenu per event and per mission. Each row is written
at its mode script's entry when the mission's goal tag (and type and stock length) matches its event key.
Generated from MISSIONS_EVENTS_BATCH1_2026-10-29/inputs/event_batch1_row_drafts.json.
"""


def register(row, master):
    row('anniversary.2017b_defense_waves', '2017 Defense: waves',
        'Waves to finish in the Anniversary 2017: Defense mission (normally 6); applies from the next run', word=' waves')
    row('anniversary.2017c_interception_rounds', '2017 Interception: rounds',
        'Rounds to finish in the Anniversary 2017: Interception mission (normally 2); applies from the next run', word=' rounds')
    row('anniversary.2018d_survival_minutes', '2018 Survival: minutes',
        'Minutes to finish in the Anniversary 2018: Survival mission (normally 10); applies from the next run', word=' min')
    row('anniversary.2019e_defense_waves', '2019 Defense: waves',
        'Waves to finish in the Anniversary 2019: Defense mission (normally 6); applies from the next run', word=' waves')
    row('anniversary.2020f_disruption_conduits', '2020 Disruption: conduits',
        'Conduits to finish in the Anniversary 2020: Disruption mission (normally 8); applies from the next run', word=' conduits')
    row('anniversary.2020g_mobiledefense_seconds', '2020 Mobile Defense: defense time',
        'Seconds of defense to finish in the Anniversary 2020: Mobile Defense mission (normally 540); applies from the next run', word=' s')
    row('anniversary.2021i_excavation_excavators', '2021 Excavation: excavators',
        'Excavators to finish in the Anniversary 2021: Excavation mission (normally 8); applies from the next run', word=' excavators')
    row('anniversary.2024l_survival_minutes', '2024 Survival: minutes',
        'Minutes to finish in the Anniversary 2024: Survival mission (normally 10); applies from the next run', word=' min')
    row('anniversary.2024cma_survival_minutes', '2024 Ch.A Survival: minutes',
        'Minutes to finish in the Anniversary 2024: Challenge A Survival mission (normally 10); applies from the next run', word=' min')
    row('anniversary.2024cmb_survival_minutes', '2024 Ch.B Survival: minutes',
        'Minutes to finish in the Anniversary 2024: Challenge B Survival mission (normally 10); applies from the next run', word=' min')
    row('anniversary.2025cmb_survival_minutes', '2025 Ch.B Survival: minutes',
        'Minutes to finish in the Anniversary 2025: Challenge B Survival mission (normally 10); applies from the next run', word=' min')
    row('nightwatch.defense_waves', 'Defense: waves',
        'Waves to finish in the The Long Shadow Defense mission (normally 10); applies from the next run', word=' waves')
    row('nightwatch.interception_rounds', 'Interception: rounds',
        'Rounds to finish in the The Long Shadow Interception mission (normally 2); applies from the next run', word=' rounds')
    row('nightwatch.survival_minutes', 'Hard Survival: minutes',
        'Minutes to finish in the The Long Shadow Hard Survival mission (normally 20); applies from the next run', word=' min')
