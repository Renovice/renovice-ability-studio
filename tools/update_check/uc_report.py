"""Result model and the Markdown/JSON report of the post-update check."""
from __future__ import annotations

import json
from dataclasses import dataclass, field

OK, BROKEN, UNKNOWN = 'OK', 'BROKEN', 'UNKNOWN'
AREAS = [
    ('build', 'Build and allowlists'),
    ('native', 'Bootstrapper native signatures'),
    ('scripts', 'Game scripts (stock modules)'),
    ('content', 'Installed RENOVICE content'),
    ('hooks', 'Addon hooks'),
    ('missions', 'Mission registry and Missions package'),
    ('toolchain', 'Toolchain sanity'),
    ('runtime', 'Newest game session (loader log)'),
]
EXIT_OK, EXIT_BROKEN, EXIT_UNKNOWN, EXIT_TOOL_ERROR = 0, 1, 2, 3


@dataclass
class Item:
    area: str
    check: str          # stable check id, e.g. "native.signature", "missions.literal_site"
    name: str           # what was checked
    status: str
    reason: str = ''    # what changed / why (BROKEN, UNKNOWN); short evidence (OK)
    features: list[str] = field(default_factory=list)
    evidence: dict = field(default_factory=dict)


class Report:
    def __init__(self):
        self.items: list[Item] = []
        self.meta: dict = {}
        self.notes: dict[str, list[str]] = {a: [] for a, _ in AREAS}

    def add(self, area, check, name, status, reason='', features=None, **evidence) -> Item:
        item = Item(area, check, name, status, reason, list(features or []), evidence)
        self.items.append(item)
        return item

    def note(self, area: str, text: str) -> None:
        self.notes[area].append(text)

    def counts(self, area: str | None = None) -> dict[str, int]:
        out = {OK: 0, BROKEN: 0, UNKNOWN: 0}
        for i in self.items:
            if area is None or i.area == area:
                out[i.status] += 1
        return out

    def exit_code(self) -> int:
        c = self.counts()
        if c[BROKEN]:
            return EXIT_BROKEN
        if c[UNKNOWN]:
            return EXIT_UNKNOWN
        return EXIT_OK

    # -- output ------------------------------------------------------------------------------------------------------
    def to_json(self) -> dict:
        return {
            'format': 'RENOVICE_UPDATE_CHECK_V1',
            'meta': self.meta,
            'summary': {'total': self.counts(), 'exit_code': self.exit_code(),
                        'areas': {a: self.counts(a) for a, _ in AREAS}},
            'notes': self.notes,
            'items': [i.__dict__ for i in self.items],
        }

    def to_markdown(self, ok_detail: bool = False) -> str:
        c = self.counts()
        m = self.meta
        verdict = {EXIT_OK: 'ALL OK', EXIT_BROKEN: 'BROKEN ITEMS FOUND',
                   EXIT_UNKNOWN: 'NO BROKEN ITEM, SOME UNKNOWN'}[self.exit_code()]
        lines = [
            '# RENOVICE post-update check',
            '',
            f'**{verdict}**: {c[OK]} OK, {c[BROKEN]} BROKEN, {c[UNKNOWN]} UNKNOWN (exit code {self.exit_code()}).',
            '',
            f'- Client: `{m.get("build")}` (`Warframe.x64.exe` `{str(m.get("exe_sha256"))[:16]}…`), '
            f'game folder `{m.get("game")}` (read only).',
            f'- Stock modules: {m.get("stock_modules")} from `B.Font.toc` `{str(m.get("toc_sha256"))[:16]}…` '
            f'({m.get("stock_source")}).',
            f'- Baseline: `{m.get("baseline")}`; bootstrapper source `{m.get("bootstrapper_ref")}` '
            f'(`{str(m.get("bootstrapper_commit"))[:9]}`); registry `{m.get("registry_build")}`.',
            f'- Run: {m.get("started")}, {m.get("seconds")} s, tool `{m.get("tool_commit")}`.',
            '',
            '| Area | OK | BROKEN | UNKNOWN |',
            '|---|---:|---:|---:|',
        ]
        for a, title in AREAS:
            ac = self.counts(a)
            lines.append(f'| {title} | {ac[OK]} | {ac[BROKEN]} | {ac[UNKNOWN]} |')
        lines.append('')
        for a, title in AREAS:
            items = [i for i in self.items if i.area == a]
            ac = self.counts(a)
            lines += [f'## {title}', '', f'{ac[OK]} OK, {ac[BROKEN]} BROKEN, {ac[UNKNOWN]} UNKNOWN.', '']
            for n in self.notes[a]:
                lines.append(f'- {n}')
            if self.notes[a]:
                lines.append('')
            bad = [i for i in items if i.status != OK]
            if bad:
                lines += ['| Status | Check | Item | What changed | Affects |', '|---|---|---|---|---|']
                for i in bad:
                    feats = '; '.join(i.features[:6]) + (f' (+{len(i.features) - 6} more)' if len(i.features) > 6 else '')
                    lines.append(f'| **{i.status}** | `{i.check}` | {_md(i.name)} | {_md(i.reason)} | {_md(feats)} |')
                lines.append('')
            if ok_detail:
                oks = [i for i in items if i.status == OK]
                if oks:
                    lines += ['<details><summary>OK items</summary>', '', '| Check | Item | Evidence |', '|---|---|---|']
                    for i in oks:
                        lines.append(f'| `{i.check}` | {_md(i.name)} | {_md(i.reason)} |')
                    lines += ['', '</details>', '']
        return '\n'.join(lines) + '\n'


def _md(text: str) -> str:
    return str(text).replace('|', '\\|').replace('\n', ' ')


def write(report: Report, out_dir, ok_detail: bool = True):
    out_dir.mkdir(parents=True, exist_ok=True)
    (out_dir / 'update_check_report.json').write_text(json.dumps(report.to_json(), indent=1), encoding='utf-8')
    (out_dir / 'update_check_report.md').write_text(report.to_markdown(ok_detail), encoding='utf-8')
