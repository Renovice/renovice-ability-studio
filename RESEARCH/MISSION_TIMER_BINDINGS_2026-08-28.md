# Mission timer bindings — 2026-08-28

> **2026-09-09 correction:** Live testing rejected the generated Survival full
> replacement: the keypad pointed to the start console but the mission did not
> start. A closure-map audit also proved the old reward-progress insertion wrote
> root R32/remaining life support, not the elapsed reward clock. Survival now
> uses the exact V60 target addon documented in
> `SURVIVAL_TARGET_ADDON_V60_2026-09-09.md`. The original statements below are
> corrected to preserve both the negative result and the exact replacement.
> The later owner audit also retired automatic full replacements for Mobile
> Defense, Interception, and Excavation. Current bindings are in
> `MISSION_TIMER_TARGET_ADDONS_2026-09-09.md`.
>
> **2026-09-11 correction:** Live evidence then falsified Excavation's runtime
> capture. Its current delivery is the three-operand exact replacement in
> `MISSION_TIMER_CRASH_RECOVERY_2026-09-11.md`.
>
> **2026-09-12 correction:** Live datamass insertion falsified Mobile Defense's
> prototype-22 addon with a stock `DefenseStage(910)` nil-index failure. Mobile
> Defense now uses the hash-pinned two-operand exact replacement documented in
> `MOBILE_DEFENSE_TIMER_LIVE_RECOVERY_2026-09-12.md`.

## Scope

Initial zero-code timer presets for exact stock modules in the pinned corpus.
Every edit is body-key locked and anchored to one proven source expression.

## H1 — Survival rotation time, life-support refill, and reward progress are one value

**Result: FALSE.** They are separate mechanics:

| Control | Stock | Proven owner |
|---|---:|---|
| Reward rotation interval | 300 s | root R9 reward table `interval`, exposed as prototype 64 capture 70; compared against root R42 elapsed reward clock, exposed as capture 19 |
| Life-support refill per enemy pickup | 7 s | `frame_76[15].pickupTimeAdded`, accumulated into `_T.SurvivalTimeAdded` |
| Reward-clock progress per pickup | 0 s | root R42, exposed to stock update prototype 64 as one-based capture 19 |

The V60 addon consumes only the positive change in the stock aggregated pickup
count before the stock function resets it, then adds the selected value to
prototype 64 capture 19. It does not replace the life-support refill, does not
replace the stock module, and does not run an independent polling loop.

Exact target:

- module: `Lotus.Scripts.Modes.SurvivalMission`
- corpus: `Lotus_Scripts_Modes_SurvivalMission.lua_B`
- body key: `1e3647332a578b78`

## H2 — Mobile Defense uses one fixed timer

**Result: FALSE.** The stock module interpolates total time between 180 and 240
seconds by mission difficulty, then divides total time across active consoles.
Mission overrides such as persistent `CustomMissionTime` remain native and take
precedence where stock code already permits them.

Exact target:

- module: `Lotus.Scripts.MobileDefense`
- corpus: `Lotus_Scripts_MobileDefense.lua_B`
- body key: `89329f85c8575b84`
- anchor: `Lerp(180, 240, difficulty)` in the verified Semantic IR render

## H3 — text replacement is safe enough

**Result: FALSE.** Each preset requires the exact body key and exactly one
structural match for every changed expression. Zero or multiple matches abort
without emitting a patch. Existing RENOVICE timer markers are also rejected to
prevent accidental double application.

## Verification

- Focused Core/Dev assertions cover stock values, each exact anchor, insertion
  order, invalid ranges, and body-key rejection.
- The historical patched Survival source compiled and round-tripped, but live
  keypad/start behavior failed. Compiler closure did not prove runtime lifecycle
  parity.
- Survival, Mobile Defense, Interception, and Excavation are exact target addons
  because their requested changes have verified owners or callsites reachable
  through the stock module lifecycle.

## Deliberate boundary

No additional timer-based mode is inferred from similar-looking constants.
Each new mode must be added only after its exact timer owner, overrides,
authority, reset behavior, and body key are mapped and tested.
