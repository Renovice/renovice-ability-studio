# Missions R19: Grineer Railjack fighter and crewship goals owned at the engine writer (2026-10-02)

- **Build:** client 44.0.2 (`2026.09.28.13.06`), U44 name-hash seed `768e5ed0`.
- **Branch:** ability editor `fix/missions-r19-railjack-engine-owner-2026-10-02`, from R18 `3475602` (the package supersedes R18).
- **Runtime:** no DLL change; the installed R17 DLL `304b57de…` has the writer hook and masters on writer-owned rows. Bootstrapper
  gate branch `fix/r19-railjack-engine-owner-2026-10-02` (worktree `repos/runtime/bootstrapper-runtime-wt-r19`, from R17
  `45ed7b0`), record `RESEARCH/RAILJACK_ENCOUNTER_OWNER_R19_2026-10-02/README.md` there.
- **Research:** `work/research/railjack-kill-goals-r19-2026-10-02/README.md` (live session pid 7128, hypotheses H1-H4).
- **Status:** every offline gate PASS. **Nothing is live.** Staged `work/staging/combined-r19/`. Nothing deployed or pushed.

## Live report and findings (short)

| Report | Finding |
|---|---|
| Fighters x0.1: the entry write logged `{20/35/55/70/85/95} -> {2/4/6/7/9/10}`, the goal stayed stock. | The write happened (R10 lane, native entry of P9) and was not reached by the goal reader (P6, read inside the entry call). Why is UNRESOLVED offline. The R17 writer hook saw the engine's writes of the same lists into KillFighters P9 and left them stock with `module-identity-unknown key=0` only because no recipe named that module (not a mapping defect). |
| Crewships x0.1 written as x1. | Not a defect: in that run the crewship row was not set yet and the "All Railjack missions" master was on at its stock x1, which drives unset rows (x1). The later runs wrote x0.1 (`{1/1/1/1/1/1}`). |

## Change

| Area | Change |
|---|---|
| `inputs/r19_engine_overrides.json` (LF SHA-256 `AD86E8EC…12580A38`) | Admits `railjack.fighter_kills_scale` (minorKillGoals, minorKillGoalsMax, kuvaLichKillGoalMin, kuvaLichKillGoalMax) and `railjack.crewship_kills_scale` (majorKillGoals, kuvaLichKillGoal) to ENGINE_PARAM_OVERRIDE_V1 with the live evidence (class "EXPOSED (live)"). |
| `tools/mission_owner_specs.py` | Loads the R19 input after R16/R17/R18. Registry fixed point `366ab8c5…` (+2 `engine_override` owners; player text data `C8F00E7467866B2F` unchanged). |
| `src/mission_profiles.inl` | A master every drive of which is writer-owned stays compiled, with no drives, in the target of its own module (the Railjack master in KillFighters), so the member still declares and compiles it and the addon never applies it. |
| Gates | `test_engine_param_override_harness.py`: R19 cases (fighters with the live Steel Path lists, crewships, the master alone writes nothing from the addon into any of its five rows, writer output for master+row / master alone / master at stock / row wins), pins R19; `test_entry_native_harness.py`, `test_void_flood_tank_harness.py`, `test_presets_and_sample.py` (honours `RENOVICE_EDITOR_CLI`) pinned to R19. |
| Encounter fixture | `tools/encounter_entry_protos.py` writes the bootstrapper gate fixture `fixtures/MissionsR19/encounter_entry_protos.txt` (the real stock code of KillFighters P9, KillCrewShips P9, BasicRailJackPatrol P15). |

## Package (pinned input `MISSIONS_R13_NATIVE_ENTRY_2026-10-01/inputs/rebuild_input.r12.json`)

| File | Bytes | SHA-256 | vs R18 |
|---|---:|---|---|
| `Missions.targets.addon.lua_B` | 114,106 | `d8736450cc81c2c03daaf219fbd5a046dad82b57e1d54fd8263fe2832a4d3c88` | changed (Railjack master without drives) |
| `package.json` | 254,358 | `150c0d1642d9208f97fc46df7a14ce411b60120cb4280d30f991aaf179978ff7` | identical |
| `literals.json` | 213,731 | `786c7b94a7c296758b8c94d40c3fcd69cb1a5dcbcda661a2cc7f15093cc1cbe6` | identical |
| `engine_params.json` | 4,038 | `eafd2ddf3b3916aad7a0dd4d1b09090a2a6ca74192dde69dd0e3afbf72aa259b` | +6 overrides (17 overrides, 11 values, 8 modules, master on 10) |

## Gates

| Gate | Result |
|---|---|
| `register_registry.py` -> `player_text.py` x2, then again | fixed point `366ab8c5…` |
| CLI build (MSYS2 ucrt64, `-Wall -Wextra -Wpedantic -Werror`), `verify-missions`, `self-test`, ctest | PASS 669/669, 150/150, 2/2 |
| Package build gates | `engine-param-overrides` rows=11 overrides=17 modules=8 masters=1; `settings-declarations` values=373 masters=31; `settings-layout` values=373 live_literals=135; `hook-plan` targets=35 hooks=110 entry_rows=21 |
| `test_engine_param_override_harness.py` | PASS (65 Luau checks incl. R19) |
| `test_entry_native_harness.py`, `test_void_flood_tank_harness.py`, `test_presets_and_sample.py`, `test_live_literals.py`, `test_r17_type_masters_harness.py`, `test_defense_reader_pin_harness.py`, `test_flow_gate.py`, `test_phase2d/2e/2k` | PASS |
| Bootstrapper `verify_engine_params` (R19 E1-E5 on this build's fixture) and the full build-listed gate run | PASS (bootstrapper record) |

## Limits (exact)

- **Nothing is live.** The writer and the readers are modelled; why the R10 entry write did not reach the fighter goal is not
  known. If the live test shows `ENGINE_PARAM APPLY` lines for KillFighters with a stock HUD, the readers take the value from
  somewhere the writer does not store for this instance, and a reader-side owner is needed.
- With a DLL older than R16, or the hook refused, the rows keep the R10 entry write (the route that did not reach the goal) and
  the Railjack master reaches none of its rows.
- `applies: next_mission`: with the hook, a value changed mid-mission applies at the engine's next write of the parameter.
