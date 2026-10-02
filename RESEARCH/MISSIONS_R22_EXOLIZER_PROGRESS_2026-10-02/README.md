# Missions R22: Void Cascade exolizer progress speed (inverse master) and exolizers per reward (2026-10-02)

- **Build:** client 44.0.2 (`2026.09.28.13.06`), U44 name-hash seed `768e5ed0`.
- **Branch:** ability editor `fix/missions-r22-exolizer-progress-2026-10-02`, from R21 `17b94e9`.
- **Runtime:** no change. Installed R17 DLL `304b57de…`; bootstrapper gates from `fix/r21-param-lane-audit-2026-10-02` `f97215c`
  (worktree `repos/runtime/bootstrapper-runtime-wt-r19`), unchanged.
- **Research:** `work/research/void-cascade-exolizer-progress-2026-10-02/README.md` (how an exolizer works, H1-H8).
  Contract `CONTRACT_PHASE1.md` R22.
- **Status:** every offline gate PASS. **Nothing is live.** Staged `work/staging/combined-r22/` (3 files). Nothing deployed or
  pushed.

## Request

A Void Cascade "exolizer progress x": how fast each exolizer's progress fills and so how fast rewards come; confirm and add
the normal reward interval (4) if safe. Earlier work (U44 authoring preset "Void Cascade (Exolizers)", 2026-09-27) already
found that the exolizer time is `PILLAR_DURATION` / `PILLAR_DURATION_CIRCLE` = 90 / speed; it shipped as a whole-second
literal replacement. R22 reuses the finding on the live addon lane.

## Hypotheses

| # | Hypothesis | Result | Evidence |
|---|---|---|---|
| H1 | Exolizer progress is only its TimerMgr timer (no per-event progress, no presence or kill rate). | **TRUE (static)** | U44 TimerMgr render: `Delta += dt`, expiry `Duration <= Delta`; P46 creates it from `PILLAR_DURATION(_CIRCLE)`; P38 removes it while corrupted, P42 resumes it from the net var; the marker is left / duration (P20, P42, P79). Soul absorption feeds the meter (`_T.AddReality`), not the timer. |
| H2 | Reward = every `REWARD_INTERVAL` used exolizers. | **TRUE (static)** | P45 `pillarsUsed += 1` at timer end; P28 tiers = `floor(pillarsUsed / frame_97[177])`, `OnTieredRewardRoundOver(n - 1)`, host reward on endless nodes. |
| H3 | The speed belongs on the addon root-table lane (inverse over the two duration fields). | **TRUE** | Root never reads the fields (one SETTABLEKS each); every reader (P2, P20, P42, P46, P73, P79) is a hooked prototype of `root:i16:R5` (gate in the new harness). Not a level parameter (R16/R19/R21 writer lane n/a), not read at load (R15 pin n/a). |
| H4 | A new generic primitive is needed (two rows cannot own one field; a speed divides). | **TRUE** | Registry verification rejects competing owners; R5 masters only multiply. Added: inverse master drive (contract R22), addon lane only. |
| H5 | Normal reward interval can use the addon lane. | **FALSE** | Root P97 i237 copies the field into `frame_97[177]` at load; that local is the only reader input. |
| H6 | Normal reward interval on the live-literal lane is safe and complete. | **TRUE** | One LOADN (P97 i80, offset 88710); key census = i81 write + i237 read; minimum 1 (divisor). Synthesis gate: one byte changes, render shows `REWARD_INTERVAL = N`, addon-owned initialisers unchanged. |
| H7 | Faster exolizers make rewards proportionally faster. | **PARTIALLY TRUE** | Exolizers arrive 30 s apart below the active cap, with a 240 s slot cooldown, and must be cleansed; model (cap 3, 6 slots, 10 s cleanse) first reward x1 260 s, x2 175 s, x4 153 s, x90 131 s. |
| H8 | The master can go down to 0.001 (R20 target). | **FALSE** | Float32 TimerMgr sum: 0.001 = 90000 s stalls above 256 fps, 0.005 = 18000 s above 1024 fps; 0.006 = 15000 s moves up to 2048 fps (R20 rule: no stall below about 1600 fps). Floor **0.006**, reason in the tooltip. |

## What was admitted

| Page | Row | Id | Lane | Default | Range | Applies |
|---|---|---|---|---|---|---|
| Void Cascade (top) + Quick settings "Void Cascade: exolizer progress speed" | All Void Cascade missions = Exolizer progress speed | `void_cascade.exolizer_speed` (master) | addon, inverse drive of `void_cascade.pillar_duration`, scale 90 | x1 | 0.006 to 90 | live (next read; exolizers that start after the change) |
| Void Cascade > Timers | Exolizer defense time (moved; wins when on) | `void_cascade.pillar_duration` | addon (unchanged owner) | 90 s | 1 to 32767 | live |
| Void Cascade > Rewards / drops | Exolizers per reward | `void_cascade.reward_interval` | live literal (P97 i80) | 4 | 1 to 32767 | next mission |

Player text (R7): master "Speeds up every exolizer, also in The Circuit (x2 = 45 s instead of 90 s): rewards come sooner, each
one holds back the cascade for less time. The minimum keeps its timer moving."; reward row "Exolizers that must finish for
each reward in normal Void Cascade missions (1 = a reward for every exolizer). Applies from the next mission."; the Alert row
text now states the confirmed unit; "Exolizer defense time" says it wins over the speed.

## Change

| File | Change |
|---|---|
| `src/mission_profiles.inl` | `master_drive_inverse()`; master verification for inverse drives (addon float master, positive minimum, positive row stock, no engine-writer row, stock = scale / row stock, limits inverted); addon emission: `inverse = true` in `drives`, inverse branch in `effectiveSettings` only when the build applies an inverse drive; baked literal path refuses inverse drives. |
| `src/mission_live_literals.inl`, `src/mission_engine_params.inl` | Refuse an inverse drive (recipe / engine writer resolve master x scale only). |
| `src/core.cpp` | Self-test: the full-package master harness computes scale / value for inverse drives (cases 31 -> 37); five rejection cases (inverse on a literal master, `inverse: false`, wrong stock, max beyond the row, minimum 0). |
| `inputs/r22_row_drafts.json` (LF SHA-256 `936F0EDD…A2D1C1`) | Draft of `void_cascade.reward_interval` (EXACT_LITERAL, one LOADN site; resolves the Phase 1 PARTIAL exclusion). |
| `tools/mission_owner_specs.py` | Loads the R22 drafts (pinned). |
| `tools/player_text.py` | `master()` accepts `(row, scale, 'inverse')` drives, a `unit` and a narrower `limits` pair; Alert reward text. |
| `tools/player_text_r17.py`, `tools/player_text_live_literals.py`, `tools/player_layout.py` | The master, the live literal, page placement (master on the type page, defense time under Timers), descriptions, default label. |
| `tools/test_void_cascade_exolizer_harness.py` (new) | See Gates. |
| `tools/test_r20_multiplier_minimums.py` | R22 pins; 52 x values; R22 floor table (exolizer speed 0.006) and the inverse-master minimum rule. |
| `tools/test_engine_param_override_harness.py`, `test_entry_native_harness.py`, `test_void_flood_tank_harness.py` | R22 pins (the R21 bootstrapper fixture keeps its R21 `package.json`; `engine_params.json` is unchanged). |
| `tools/test_live_literals.py` | The baked package gains the R22 master. |
| `REGISTRIES/mission_build_u44.json` | 670 rows, 50 masters, fixed point `be56dc8a…`. |

## Package (pinned input `MISSIONS_R13_NATIVE_ENTRY_2026-10-01/inputs/rebuild_input.r12.json`)

| File | Bytes | SHA-256 | vs R21 |
|---|---:|---|---|
| `Missions.targets.addon.lua_B` | 114,296 | `a943cd3e5ca053368fd3604cd96d6cbde768090f283ac2ee33db60d0f1ad9340` | master + inverse drive in the Void Cascade target |
| `package.json` | 255,616 | `fd89dacae8cfd9cec10af9c06af22dcd2835a6e8c88a2842206fdb8c3904eda0` | +1 declaration (374), 3 Void Cascade texts/paths |
| `literals.json` | 215,063 | `9beaa4385ee3efe39daf0f3788bcf19b41aa500af1cd7705b03e3ab4df0392e8` | +1 value (136), 44 modules |
| `engine_params.json` | 4,582 | `20323777391827278dea4494f6f123ac0ba2846cf2b65f4a886c4eaed61e1bad` | identical |

Byte identity: the R22 CLI on the R21 registry (worktree of `17b94e9`) rebuilds `d8736450…`, `acc2256e…`, `96a97899…`,
`20323777…` exactly.

## Gates (logs in `work/staging/combined-r22/evidence/`)

| Gate | Result |
|---|---|
| `register_registry.py` -> `player_text.py` x2, then again | fixed point `be56dc8a…`, player text data `D03E0DC517CAA73D` (462 rows, 50 masters) |
| CLI build (MSYS2 ucrt64, `-Wall -Wextra -Wpedantic -Werror`), `verify-missions`, `self-test`, ctest | 0 warnings; PASS 670/670, 150/150 (master harness 37 cases), 2/2 |
| Package build gates | `settings-layout` values=374 live_literals=136 pages=210 quick=25; `settings-declarations` values=374 masters=32; `live-literal-recipe` values=136 modules=44; `engine-param-overrides` rows=13 overrides=20; `hook-plan` targets=35 hooks=110 |
| `test_void_cascade_exolizer_harness.py` (new) | PASS: pins; registry; owner order (readers of both duration fields are hooked prototypes; `REWARD_INTERVAL` only at P97 i81/i237); 43 Luau checks on the real addon (x2/x0.5/x3/x7/0.006/90, row wins, inert cases, no compounding, new generation, cleanup; progress replay of TimerMgr + P46/P38/P42/P79/P45/P28: 90 / speed in normal and Circuit mode, marker, corruption pause with the floored resume, reward cadence model); float32 floor (0.006 moves to 2048 fps, 0.005 / 0.001 stall); literal synthesis N = 1, 2, 10 (one byte, render `REWARD_INTERVAL = 1`, addon initialisers unchanged) |
| `test_engine_param_override_harness.py` (179 Luau), `test_entry_native_harness.py` (164), `test_void_flood_tank_harness.py` (43), `test_r20_multiplier_minimums.py` (24), `test_live_literals.py` (33), `test_defense_reader_pin_harness.py`, `test_presets_and_sample.py`, `test_r17_type_masters_harness.py`, `test_flow_gate.py`, `test_phase2d/2e/2k` | PASS |
| R19 failure-order replay | Not applicable: no row of R22 is a level parameter (no engine writer). The root-table equivalent (reader runs before the hook) is the owner-order gate above. |
| Bootstrapper `verify_addon_settings.ps1 -Package -Settings -ScriptStates` (R22 Missions + installed Frost/Octavia, read-only copies of the installed values files and `ScriptStates.json`) | ADDON SETTINGS GATES PASS; `LIVE LITERALS RECIPE ACCEPT … modules=44 values=136`; `ENGINE PARAMS RECIPE ACCEPT … overrides=20 modules=10 values=13`; Missions `declarations=510 rejected=0 members_staged=1/1`; `PACKAGE ACCEPT … target_keys=35`; pages "All Void Cascade missions: x1 (default)", "Exolizer defense time: 90 s (default)", "Exolizers per reward: 4 (default)" |
| Same, with a test values file (speed 2, reward interval 1) | `LIVE LITERALS PLAN … key=32c344afa33be174 … patches=1 values=void_cascade.reward_interval`; `DELIVER … context.settings["void_cascade.exolizer_speed"] = { enabled = true, value = 2, stock = 1 }`; rejected=0 |
| Bootstrapper `verify_live_literals.ps1`, `verify_engine_params.ps1` (unchanged gates) | LIVE LITERALS GATES PASS; ENGINE PARAMS GATES PASS |

## Limits (exact)

- **Nothing is live.** Pending: exolizer time at x3 (about 30 s after a cleanse), reward after every exolizer at interval 1
  (EE.log `Pillars used increased to: 1` then `Host reward 1`), `LIVE LITERALS SYNTHESIZE PASS key=32c344afa33be174`.
- The progress and reward rules are transcriptions of the readable decompile run in plain Luau; the arrival model's cap, slot
  count and cleanse time are inputs, not game data.
- A change of the speed during a mission applies to exolizers that spawn after it; running ones keep their timer (the marker
  ratio uses the new duration).
- Net var storage width is unknown; a fractional duration (for example x7) may be stored whole for the paused remainder.
- "Exolizer defense time" keeps its range 1 to 32767 s; above 16384 s the same float32 stall applies above 1024 fps (not
  changed in R22).
- Multiplayer: host-side analysis only.
