"""Regression gate for the flow-sensitive ROOT_TABLE_UPVALUE_V1 consumer (contract R10, 2026-09-30).

addon_owner.RootTables._consumer is now a may-dataflow over each capturer's control-flow graph (research
work/research/mission-owners-2026-09-30, GATE-1/GATE-2, tools/flow_gate.py). This test re-runs, on the pinned 44.0.2
stock bytes, every addon field of the pre-R10 registry (ability editor 777618e) and every literal row whose addon gate
failed with "no capturer reads", once with the old straight-order consumer (reproduced here) and once with the new one:

  * no row that passed before may fail now (0 regressions);
  * the rows that newly pass are exactly the 20 Defense caps (regular, Infested and Duviri-min tables of WaveDefend);
  * the fail-both count is reported (their failures have other reasons).

Read-only: writes only test-results/flow_gate.json. No game or server folder is read or written.
"""
from pathlib import Path
import json, subprocess, sys

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import addon_owner as A  # noqa: E402
from deluau import ROOT  # noqa: E402

EDITOR = HERE.parents[2]
BASE_REVISION = '777618e'
STOCK = ROOT / 'work/research/universal-mission-editor-2026-09-29/stock'
STOCK_FULL = ROOT / 'repos/toolchains/de-luau-toolchain/work/u44-rawhash-2026-09-29/stock'
OUT = HERE.parent / 'test-results'
EXPECTED_FIXED = ({f'defense.simultaneous_enemies_{t}.p{k}' for t in ('max', 'min') for k in range(1, 5)}
                  | {f'defense.simultaneous_enemies_{t}.{e}.p{k}' for t in ('infested', 'duviri') for e in ('max', 'min')
                     for k in range(1, 5)}) - {f'defense.simultaneous_enemies_duviri.max.p{k}' for k in range(1, 5)}


class LinearRootTables(A.RootTables):
    """The pre-R10 consumer: one holder set in straight bytecode order (kept verbatim for this comparison)."""

    def _consumer(self, proto, up, key, seen):
        if (proto, up) in seen:
            return 0
        seen.add((proto, up))
        ins = self.protos[proto][0]
        count = 0
        holders = set()
        for i, (_, w) in enumerate(ins):
            if w[0] == A.SETUPVAL and w[2] == up:
                raise ValueError(f'prototype {proto} replaces the captured table (SETUPVAL {up})')
            if w[2] in holders and ((w[0] == A.GETTABLEKS and self.key_string(proto, w) == key) or
                                    (w[0] == A.GETTABLEN and w[3] + 1 == key) or w[0] == 0x01):
                count += 1
            holders = {r for r in holders if not A.writes(w, r)}
            if w[0] == A.GETUPVAL and w[2] == up:
                holders.add(w[1])
        for parent, _, target, caps in self.sites:
            if parent == proto:
                for n, (mode, src) in caps.items():
                    if mode == 'UPVAL' and src == f'U{up}':
                        count += self._consumer(target, n, key, seen)
        return count


def stock(file):
    path = STOCK / file
    return (path if path.exists() else STOCK_FULL / file).read_bytes()


def main():
    registry = json.loads(subprocess.run(['git', '-C', str(EDITOR), 'show', BASE_REVISION + ':REGISTRIES/mission_build_u44.json'],
                                         capture_output=True, text=True, encoding='utf-8', check=True).stdout)
    cache = {}

    def modules(file):
        if file not in cache:
            raw = stock(file)
            cache[file] = (LinearRootTables(raw), A.RootTables(raw))
        return cache[file]

    def check(m, field, stock_value):
        if isinstance(field['field'], int):
            ins = m.protos[m.root][0]
            vi = [i for i, (off, _) in enumerate(ins) if off == field['value_offset']]
            return m.element_owner(vi[0], stock_value)
        return m.owner(field['field'], stock_value, int(field['table_id'].split(':')[1][1:]))

    totals = {'both_pass': 0, 'both_fail': 0, 'fixed': 0, 'regressed': 0}
    fixed, regressed, both_fail = set(), set(), {}
    for row in registry['tunables']:
        owner = row['owner']
        if row['backend'] == 'TARGET_ADDON' and owner.get('gate') == 'ROOT_TABLE_UPVALUE_V1' and owner.get('fields'):
            literal = row.get('literal_owner')
            jobs = [('site', s) for s in literal['sites']] if literal else [('field', f) for f in owner['fields']]
        elif row['backend'] == 'EXACT_LITERAL' and 'no capturer reads' in row.get('addon_gate', ''):
            jobs = [('site', s) for s in owner['sites']]
        else:
            continue
        for kind, job in jobs:
            outcome = []
            for m in modules(owner['file']):
                try:
                    m.site_field(job, row['stock']) if kind == 'site' else check(m, job, row['stock'])
                    outcome.append(True)
                except (ValueError, IndexError, KeyError) as e:
                    outcome.append(False)
                    reason = str(e)[:160]
            key = {(True, True): 'both_pass', (False, False): 'both_fail', (False, True): 'fixed', (True, False): 'regressed'}[tuple(outcome)]
            totals[key] += 1
            if key == 'fixed':
                fixed.add(row['tunable_id'])
            elif key == 'regressed':
                regressed.add(row['tunable_id'])
            elif key == 'both_fail':
                both_fail[row['tunable_id']] = reason
    result = {'base_registry_revision': BASE_REVISION, 'totals': totals, 'fixed': sorted(fixed), 'regressed': sorted(regressed),
              'both_fail': both_fail}
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / 'flow_gate.json').write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
    problems = []
    if regressed:
        problems.append(f'regressions: {sorted(regressed)}')
    if fixed != EXPECTED_FIXED:
        problems.append(f'newly passing rows differ from the 20 Defense caps: extra {sorted(fixed - EXPECTED_FIXED)}, '
                        f'missing {sorted(EXPECTED_FIXED - fixed)}')
    if problems:
        raise SystemExit('FLOW GATE REGRESSION FAIL ' + '; '.join(problems))
    print(f"FLOW GATE REGRESSION PASS both_pass={totals['both_pass']} fixed={totals['fixed']} (rows {len(fixed)}) "
          f"both_fail={totals['both_fail']} regressed=0")


if __name__ == '__main__':
    main()
