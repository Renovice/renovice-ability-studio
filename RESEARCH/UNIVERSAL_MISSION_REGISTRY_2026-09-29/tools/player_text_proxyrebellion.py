"""Player text for the Proxy Rebellion event (2026-10-28, GOAL_TAG variant with an alias tag).

User request (2026-10-28): event tac alerts under Events, one submenu per event and per mission type. Proxy Rebellion
(OpenWF worldState.proxyRebellion) has four missions: Defense (10 waves), Interception (3 rounds), Survival (20 minutes),
Defense (20 waves). Each row is written at its mode script's entry when the goal tag is ProxyRebellion or its
Anniversary2019TacAlert alias; no masters (one row per mission).
"""


def register(row, master):
    row('proxyrebellion.defense_one_waves', 'Defense (first): waves',
        'Waves to finish in the first Proxy Rebellion mission (Defense, normally 10); applies from the next run', word=' waves')
    row('proxyrebellion.defense_four_waves', 'Defense (last): waves',
        'Waves to finish in the last Proxy Rebellion mission (Defense, normally 20); applies from the next run', word=' waves')
    row('proxyrebellion.interception_rounds', 'Interception: rounds',
        'Rounds to win in the Proxy Rebellion Interception (normally 3); applies from the next run', word=' rounds')
    row('proxyrebellion.survival_minutes', 'Survival: minutes to finish',
        'Minutes to survive in the Proxy Rebellion Survival (normally 20); applies from the next run', word=' min')
