# Missions R16: EXPOSED level parameters owned at the engine's writer (2026-10-01)

- **Build:** client 44.0.2 (`2026.09.28.13.06`, `Warframe.x64.exe` `0124f0b9…`), U44 name-hash seed `768e5ed0`.
- **Branch:** ability editor `feat/missions-r16-engine-param-override-2026-10-01`, from R15 `5b83709`.
- **Runtime:** bootstrapper `feat/r16-engine-param-override-2026-10-01` (from R13 `827027c`), primitive ENGINE_PARAM_OVERRIDE
  (record `repos/runtime/bootstrapper-runtime-wt-r16/RESEARCH/ENGINE_PARAM_OVERRIDE_R16_2026-10-01/README.md`).
- **Research:** `work/research/engine-param-override-2026-10-01/README.md` (writer contract, 32 asserted native checks);
  R15 classification `work/research/defense-reward-interval-2026-10-01/README.md` ("Other parameter rows").
- **Status:** every offline gate PASS. **Nothing is live.** Staged `work/staging/combined-r16/`. Nothing deployed or pushed.

## Hypotheses and results

| # | Hypothesis | Result | Evidence |
|---|---|---|---|
| G1 | The six R15 EXPOSED rows can be declared to the native lane without changing the addon or package.json. | **TRUE** | The pinned build input rebuilds the addon `70fff0b6…`, `package.json` `44fc0b53…` and `literals.json` `a16b2520…` byte for byte; the only new file is `engine_params.json` `ae090c33…` (7 overrides, 3 modules). |
| G2 | Every override is exact: admitted row, every parameter global, U44 hash, the row's own mode and stock module key. | **TRUE** | Generator gate `engine-param-overrides` (verify_mission_row re-proves each owner on the pinned stock bytes, no master drives a row, int/float value of the addon member) and `test_engine_param_override_harness.py` re-check against the registry. |
| G3 | With the R16 DLL every read after the entry and after engine re-writes sees the configured value; the addon writes nothing for those rows. | **TRUE (modelled)** | Harness, real generated addon in Luau, order: engine write → native entry → engine write x3, for all six rows (30 Luau checks). |
| G4 | The R10 lane stays the fallback. | **TRUE** | R13/R15 DLL (file ignored) and R16 DLL with the hook refused: values delivered, the addon writes at the entry (and loses it at the next engine write, the R15 control). Old bootstrapper `6227cc0` `verify_script_packages -AdmitPackage` accepts the package with the file present (`test_live_literals.py`). |
| G5 | Native and addon must not both apply a value. | **TRUE** | Harness negative control: scale rows compound (1450 x0.5 x0.5), so the bootstrapper withholds the owned values from `context.settings`; absolute rows would be idempotent. |

## Rows (registry owner field `engine_override`, gate ENGINE_PARAM_OVERRIDE_V1)

| Row | Module (stock key) | Parameters (hash) | Mode | R15 class |
|---|---|---|---|---|
| `exterminate.kills_scale` | TriggerAlarm `c05987eccd08c1ca` | metersPerEnemy (`baa888a8`) | scale_inverse | EXPOSED |
| `exterminate.archwing_kill_mult` | TriggerAlarm `c05987eccd08c1ca` | spaceBattleKillCountMultiplier (`e34f013b`) | absolute | EXPOSED (conditional) |
| `interception.score_goal_scale` | TerritoryMission `c9605470a8c47d8d` | scoreGoal (`3a44eae1`) | scale | EXPOSED |
| `interception.scoring_speed` | TerritoryMission `c9605470a8c47d8d` | scoreRatePerSecond (`5241ca6c`) | scale | EXPOSED |
| `interception.round_end_timer` | TerritoryMission `c9605470a8c47d8d` | roundEndTimer (`b68a06b6`) | absolute | EXPOSED |
| `railjack.corpus_fighter_limit_scale` | BasicRailJackPatrol `0a6394a10884c38a` | minorKillGoals (`288044d3`), minorKillGoalsMax (`e290a5e6`) | scale_count | EXPOSED (conditional) |

Not moved (R15 class REACHES: the reads finish before control returns to the engine): `spy.vault_alarm_scale`,
`railjack.fighter_kills_scale`, `railjack.crewship_kills_scale`. Not classified by R15 and left on the R10 lane:
`sabotage.gascity_hack_time`, `sabotage.random_extraction_timer`, `control_area_nokko.hold_time`,
`control_area_nokko.bonus_threshold` (follow-up: classify them; admitting one is one line of
`inputs/r16_engine_overrides.json`).

## Change

- `inputs/r16_engine_overrides.json` (LF SHA-256 `EF03BA27…BDFEB14`): the six admissions with their R15 evidence.
- `tools/mission_owner_specs.py`: `engine_overrides()` marks the rows (`owner.engine_override` = gate, exposure, evidence,
  parameters, mode); report key `engine_overrides`. Registry fixed point `b169e8dd…` (player text data `A9379C88E56065D1`
  unchanged).
- `src/mission_engine_params.inl` (new) + `src/mission_profiles.inl`: `emit_engine_param_recipe` writes
  `Packages/Missions/engine_params.json` (format `RENOVICE_ENGINE_PARAMS_V1`) and runs gate `engine-param-overrides`; the
  package-folder gate ignores the file like `literals.json`; the manifest records it (`package.engine_params`).
- New gate `tools/test_engine_param_override_harness.py`. `test_live_literals.py` and `test_presets_and_sample.py` accept
  the new non-member file (its content gated by the new harness).

## Gates

| Gate | Result |
|---|---|
| `register_registry.py` → `player_text.py` x2, then again | fixed point: registry `b169e8dd…` |
| CLI build (MSYS2 ucrt64, zero warnings), `verify-missions`, `self-test`, ctest | PASS 667/667, 150/150, 2/2 |
| Package build gates | `engine-param-overrides` PASS rows=6 overrides=7 modules=3; the R15 gates unchanged |
| `test_engine_param_override_harness.py` (new) | PASS (registry, recipe, bootstrapper fixture identity, 30 Luau checks) |
| `test_entry_native_harness.py`, `test_defense_reader_pin_harness.py`, `test_live_literals.py` (30), `test_flow_gate.py`, `test_presets_and_sample.py`, `test_phase2d/2e/2k`, `test_void_flood_tank_harness.py` | PASS |
| Bootstrapper `verify_engine_params.ps1` (89 checks + source pins) on the same `engine_params.json` | PASS |

## Limits (exact)

- **Nothing is live.** The writer and the readers are modelled in the harness; the native contract is the bootstrapper's
  byte-checked registration.
- Applies: the declarations keep `applies: next_mission`. With the R16 DLL a change committed mid-mission takes effect at the
  engine's next write of that parameter (possibly in the running mission).
