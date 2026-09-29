"""Offline regression for the Phase 2d owner gates on the 44.0.2 stock corpus (read-only).

* K_CONSTANT_EXCLUSIVE_V1 / single-use template gate: positive and negative cases on real stock modules;
* corpus census of the template gate over every numeric table-template field of all extracted modules
  (the denominator reported in the research note);
* pattern completeness: an under-constrained pattern that matches two owners is refused;
* constant use sets: declaring a subset of a constant's uses is refused.

Writes test-results/phase2d_gates.json only.
"""
from pathlib import Path
import json, sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from anchors import Analysis  # noqa: E402
from deluau import ROOT  # noqa: E402
import phase2d  # noqa: E402

STOCK = ROOT / 'work/research/universal-mission-editor-2026-09-29/stock'
OUT = Path(__file__).resolve().parents[1] / 'test-results'
cache = {}


def mod(name):
    if name not in cache:
        cache[name] = Analysis((STOCK / name).read_bytes())
    return cache[name]


def expect_fail(fn, text):
    try:
        fn()
    except ValueError as e:
        if text in str(e):
            return str(e)
        raise AssertionError(f'wrong failure: {e}') from e
    raise AssertionError('gate did not fail: ' + text)


SURV = 'Lotus_Scripts_Modes_SurvivalMission.lua_B'
cases = []
m = mod(SURV)
v, gate = m.template_field(m.root, 33, 'lowDropMultiplier')
assert gate['template_uses'] == [{'instruction': 18, 'op': 'DUPTABLE', 'register': 8}] and m.number(m.root, v) == 1.5
cases.append({'case': 'template single-use PASS: Survival frame_79[15].lowDropMultiplier', 'result': 'PASS', 'gate': gate})
cases.append({'case': 'template shared value FAIL: Survival interval 300 (shared with killPlayerTime)', 'result': 'FAIL as expected',
              'reason': expect_fail(lambda: m.template_field(m.root, 39, 'interval'), 'is shared')})
mech = mod('Lotus_Scripts_Modes_MechSurvivalMission.lua_B')
cases.append({'case': 'template in a loop FAIL: MechSurvival proto 21 template 21', 'result': 'FAIL as expected',
              'reason': expect_fail(lambda: mech.template_field(21, 21, 'points'), 'inside a loop')})
gen = mod('Lotus_Interface_Libs_SyndicateMissionGenerator.lua_B')
cases.append({'case': 'template consumed by two DUPTABLE sites FAIL: SyndicateMissionGenerator proto 4 template 56', 'result': 'FAIL as expected',
              'reason': expect_fail(lambda: gen.template_field(4, 56, 'xpAmount'), 'consumed by 2 DUPTABLE')})
cases.append({'case': 'pattern completeness FAIL: fixedLength 300 without the EndlessDuviri context matches two owners', 'result': 'FAIL as expected',
              'reason': expect_fail(lambda: phase2d.resolve(m, [{'kind': 'pattern', 'value': 300, 'after': ['SETTABLEKS:fixedLength'],
                                                                   'count': 1, 'owner': 'x'}]), 'matched 2 sites')})
coh = mod('Lotus_Types_Gameplay_DevilTower_LiteGameModes_CoHExcavationLite.lua_B')
cases.append({'case': 'constant use-set FAIL: declaring 1 of the 4 uses of the Descendia 45 constant', 'result': 'FAIL as expected',
              'reason': expect_fail(lambda: phase2d.resolve(coh, [{'kind': 'constant', 'proto': 23, 'value': 45, 'uses': ['SUBRK:45'],
                                                                     'owner': 'x'}]), 'declared')})
full = phase2d.resolve(coh, [{'kind': 'constant', 'proto': 23, 'value': 45, 'uses': ['SUBRK:45', 'SUBRK:45', 'SUBRK:45', 'DIVK:45'], 'owner': 'x'}])
cases.append({'case': 'constant use-set PASS: Descendia 45 constant with its complete use set (3 SUBRK + 1 DIVK)', 'result': 'PASS',
              'gate': full[0]['gate']})

# Corpus census of the single-use template gate (denominator for the research note).
census = {'modules': 0, 'numeric_template_fields': 0, 'pass': 0, 'fail': {}}
for f in sorted(p.name for p in STOCK.iterdir()):
    a = mod(f)
    census['modules'] += 1
    for p, (_, consts) in enumerate(a.protos):
        for t, c in enumerate(consts):
            if c[0] != 8:
                continue
            for _, key, val in a.template(p, t):
                if val is None or a.number(p, val) is None:
                    continue
                census['numeric_template_fields'] += 1
                try:
                    a.template_field(p, t, key)
                    census['pass'] += 1
                except ValueError as e:
                    msg = str(e)
                    reason = ('value constant shared' if 'is shared' in msg else 'several DUPTABLE sites' if 'DUPTABLE sites' in msg
                              else 'inside a loop' if 'loop' in msg else 'initialiser overwritten' if 'overwritten' in msg
                              else 'duplicate key' if 'valued entries' in msg else 'other')
                    census['fail'][reason] = census['fail'].get(reason, 0) + 1
    cache.pop(f, None)
OUT.mkdir(parents=True, exist_ok=True)
(OUT / 'phase2d_gates.json').write_text(json.dumps({'cases': cases, 'template_gate_census': census}, indent=2) + '\n')
print(f'PASS {len(cases)} gate cases; template census {census}')
