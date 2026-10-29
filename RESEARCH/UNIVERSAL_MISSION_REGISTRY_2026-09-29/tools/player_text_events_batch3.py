"""Player text for Events batch 3 (2026-10-29, event literals): Water Fight and Hallowed Nightmares time attack.

HEADLINE: the literal rows a "literal_scope": "headline" package ships (literals.json), as player_text_r17.HEADLINE.
"""

HEADLINE = ['waterfight.score_limit', 'waterfight.score_limit_alt', 'waterfight.round_time',
            'hallowednightmares.timeattack_score']


def register(row, master):
    # Orphix Venom event (2026-10-29): a copy of the Orphix mission-type settings (same values; live test: every Orphix
    # Venom mission ends at the Orphix 36 limit, the script's 24 default is never reached, so it is not exposed).
    master('orphixvenom.round_limit_endurance', 'Round limit',
           'Orphix to destroy in Orphix Venom missions (normally 36); same value as Orphix > Event/Railjack rounds',
           [('orphix.max_rounds_railjack', 1)], group='orphixvenom', word=' orphix')
    master('orphixvenom.min_before_leave', 'Orphix before you can leave',
           'Orphix destroyed before extraction opens (normally 3); applies to every Orphix mission',
           [('orphix.reward_interval', 1)], group='orphixvenom', word=' orphix')
    row('waterfight.score_limit', 'Score limit',
        'Points a team needs to win a Water Fight round (normally 25); applies from the next run', word=' points')
    row('waterfight.score_limit_alt', 'Score limit (alt setup)',
        'Points to win on the alternate Water Fight setup (normally 60); which setup the event uses is untested',
        word=' points')
    row('waterfight.round_time', 'Round time',
        'Length of a Water Fight round in seconds (normally 300); applies from the next run', word=' s')
    row('hallowednightmares.timeattack_score', 'Time attack score base',
        'Hallowed Nightmares time attack: score = this minus seconds taken (normally 1000); applies from the next run',
        word=' points')
