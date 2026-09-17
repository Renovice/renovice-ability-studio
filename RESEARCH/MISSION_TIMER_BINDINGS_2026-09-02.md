# Mission timer/scoring bindings — 2026-09-02

> **Superseded on 2026-09-09:** The stock-value findings below remain evidence,
> but the full-replacement delivery path is retired. All four presets now emit
> exact target addons documented in `MISSION_TIMER_TARGET_ADDONS_2026-09-09.md`.
>
> **2026-09-11 correction:** The Excavation target addon was falsified live and
> is superseded by the hash-pinned, three-operand exact replacement documented
> in `MISSION_TIMER_CRASH_RECOVERY_2026-09-11.md`.
> The Interception target reached prototype 35 but its type guard failed before
> assignment; the fail-closed guard correction is documented in
> `INTERCEPTION_SCORING_RECOVERY_2026-09-11.md`.
> Plains and Deimos Control Area nested callbacks were later falsified by the
> same exported-boundary limitation and now use exact root-duration operand
> replacements. See `CONTROL_AREA_LIVE_RECOVERY_2026-09-11/README.md`.
>
> **2026-09-12 correction:** Mobile Defense's prototype-22 addon was also
> falsified live when datamass insertion reached stock `DefenseStage(910)` with
> an invalid captured value. It now uses a hash-pinned exact replacement that
> changes only the stock 180/240-second LOADN operands. See
> `MOBILE_DEFENSE_TIMER_LIVE_RECOVERY_2026-09-12.md`.

## H1 — Interception is a fixed timer like Survival

**Result: FALSE.** Standard Interception is
`Lotus.Scripts.Modes.TerritoryMission`. Round progress is generated from
`scoreRatePerSecond`, tower ownership, and existing variant multipliers. The
editor therefore exposes a **tower scoring-speed multiplier**, not a fictional
round-duration field. A value of 2 roughly halves scoring time only when tower
ownership remains equivalent.

- corpus: `Lotus_Scripts_Modes_TerritoryMission.lua_B`
- exact body key: `a51e98a1833bd8c1`
- patch order: the custom multiplier is applied once before the module's
  existing mode-specific `x4` and quest `x2.25` multipliers.

## H2 — Excavation has one universal dig timer

**Result: FALSE.** `Lotus.Scripts.Modes.ExcavationMission` owns three verified
production durations:

| Control | Stock | Faster example |
|---|---:|---:|
| Standard Excavation | 100 s | 50 s |
| Old World Salvage override | 60 s | 30 s |
| Elite Alert override | 140 s | 70 s |

`frame_49[70]` is reward/score data and is intentionally not edited. The
separate developer FastDig assignment (`frame_49[69] = 20`) is also preserved.

- corpus: `Lotus_Scripts_Modes_ExcavationMission.lua_B`
- exact body key: `303f809a05c1fbaa`

## H3 — These controls require a runtime loop

**Result: FALSE.** All four presets (Survival, Mobile Defense, Interception,
and Excavation) now create body-key-gated exact target addons at verified stock
owners or callsites. They do not install a timer watcher, repeated setter, or
polling loop.

Each structural binding must match exactly once or no patch is emitted.

## Verification

- Ability Studio Release build: 0 warnings, 0 errors.
- Focused dev harness: 43/43.
- Full patched sources for Survival, Mobile Defense, Interception, and
  Excavation compile, transcode, and reparse through the authoritative
  `derecomp` toolchain.
- Interception and Excavation full fixtures are preserved under
  `RESEARCH/MISSION_TIMERS_2026-09-02/GENERATED/`.
