"""Player text for the contract R23 Icebind goals (2026-10-09, client 44.1.1 2026.10.08.13.05).

User request (2026-10-09): Icebind's own mission goals (KuvaKeysLib MISSIONS: Disruption 8 conduits, Excavation 6
excavators, Survival 10 minutes) as values under each mission type. Each goal is one MissionInfo field (maxWaveNum) read
by two scripts: the mission type's script and the Icebind script (KuvaPath). One master per type drives the row pair
(the same value written at both scripts' entries, whichever starts first); the two rows sit in the type's advanced
section. `register()` is called by player_text.py with its `row` and `master` helpers.
"""


def register(row, master):
    pairs = (
        ('disruption', 'icebind_conduits', 'Icebind: conduits to finish', 'Icebind conduits',
         'Conduits to complete in an Icebind Disruption run', ' conduits'),
        ('excavation', 'icebind_excavators', 'Icebind: excavators to finish', 'Icebind excavators',
         'Excavators to complete in an Icebind Excavation run', ' excavators'),
        ('survival', 'icebind_minutes', 'Icebind: minutes to finish', 'Icebind minutes',
         'Minutes to survive in an Icebind Survival run', ' min'),
    )
    for family, name, label, short, text, word in pairs:
        mission_row, icebind_row = f'{family}.{name}', f'{family}.{name}_kuvapath'
        master(f'{family}.icebind_goal', label, text + '; applies from the next run',
               [(mission_row, 1), (icebind_row, 1)], group=family, word=word)
        row(mission_row, short + ' (mode)', text + ', read by the mode script; the Icebind master sets both rows', 'adv',
            word=word)
        row(icebind_row, short + ' (Icebind)', text + ', read by the Icebind script; the Icebind master sets both rows',
            'adv', word=word)
