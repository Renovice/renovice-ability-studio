# Missions R21: Spy vault alarm and Sabotage surprise extraction owned at the engine writer; R19 failure-order gate (2026-10-02)

- **Build:** client 44.0.2 (`2026.09.28.13.06`), U44 name-hash seed `768e5ed0`.
- **Branch:** ability editor `fix/missions-r21-param-lane-audit-2026-10-02`, from R20 `b17fa68`.
- **Runtime:** no DLL change; the installed R17 DLL `304b57de…` has the writer hook. Bootstrapper gate branch
  `fix/r21-param-lane-audit-2026-10-02` (worktree `repos/runtime/bootstrapper-runtime-wt-r19`, from R20 `b4a0bfc`), record
  `RESEARCH/PARAM_LANE_AUDIT_R21_2026-10-02/README.md` there.
- **Research:** `work/research/param-lane-audit-r21-2026-10-02/README.md` (rows on the R10 lane, writer evidence, MissionInfo
  audit). Contract `CONTRACT_PHASE1.md` R21.
- **Status:** every offline gate PASS. **Nothing is live.** Staged `work/staging/combined-r21/`. Nothing deployed or pushed.

## Why

R19 refuted the R15/R17 class REACHES live: a parameter read inside the entry call (before any yield) still missed the R10 Lua
entry write. The class is closed by owning every level/encounter parameter at the engine's parameter writer.

## Hypotheses

| # | Hypothesis | Result | Evidence |
|---|---|---|---|
| H1 | Exactly two rows were still on the plain R10 entry write. | **TRUE** | Registry: 13 `SCRIPT_PARAM_GLOBAL_AT_ENTRY` rows, 11 writer-owned (R16-R19); `spy.vault_alarm_scale` and `sabotage.random_extraction_timer` were not. No other template writes a level parameter (`interception.score_rate` is template-only, not in the package). |
| H2 | Both values pass through the engine writer and nothing in Lua recomputes them. | **TRUE (static)** | Level ScriptTrigger parameters; whole-module census: one GETIMPORT each (Intel P43 i64/i65, Sabotage P11 i223), no SETGLOBAL or string-keyed use. |
| H3 | Admitting them changes only `engine_params.json`. | **TRUE** | The pinned build input rebuilds the addon `d8736450…`, `package.json` `acc2256e…`, `literals.json` `96a97899…` byte for byte; `engine_params.json` `eafd2ddf…` -> `20323777…`. |
| H4 | With the writer hook the value reaches the read under every R19 mechanism; the R10 lane alone reproduces the live failure. | **TRUE (modelled)** | Harness "R19 order" (writer -> Lua entry write -> read; re-write, other reader env, early resolution): 6 checks per row, all 13 writer-owned rows. |
| H5 | The MissionInfo rows need the same move. | **FALSE** | `maxWaveNum` is a MissionInfo field written through `SetMission`, not an environment global; no in-mission stock Lua writes it after the entry (census). Residual native/multiplayer risks are recorded in the research note; no cleaner owner exists. |

## Change

| Area | Change |
|---|---|
| `inputs/r21_engine_overrides.json` (LF SHA-256 `91518C83…0517F90`) | Admits `spy.vault_alarm_scale` (intelTimerDurationMax, intelTimerDurationMin; scale) and `sabotage.random_extraction_timer` (duration; absolute) to ENGINE_PARAM_OVERRIDE_V1, class "EXPOSED (R19 class)". |
| `tools/mission_owner_specs.py` | Loads the R21 input after R16-R19. Registry fixed point `ee7df8d0…` (+2 `engine_override` owners; player text data `C8F00E7467866B2F` unchanged). |
| `tools/test_engine_param_override_harness.py` | + Spy and Sabotage cases; "R19 order" section for every writer-owned row; class-audit checks (no plain R10 parameter row left; the 8 MissionInfo rows stay); pins R21; fixture `MissionsR21`. |
| `tools/test_r17_type_masters_harness.py` | The surprise extraction is writer-owned (its REACHES check stays as the R10 fallback model). |
| `tools/test_presets_and_sample.py`, `tools/test_r20_multiplier_minimums.py` | `engine_params.json` pin moved to R21. |
| `tools/trigger_entry_protos.py` | Writes the bootstrapper fixture `fixtures/MissionsR21/trigger_entry_protos.txt` (Intel P43, Sabotage P11 stock code). |

## Package (pinned input `MISSIONS_R13_NATIVE_ENTRY_2026-10-01/inputs/rebuild_input.r12.json`)

| File | Bytes | SHA-256 | vs R20 |
|---|---:|---|---|
| `Missions.targets.addon.lua_B` | 114,106 | `d8736450cc81c2c03daaf219fbd5a046dad82b57e1d54fd8263fe2832a4d3c88` | identical |
| `package.json` | 254,884 | `acc2256eb4a76f6782af1aa51534a5387c065ae1323da36daa45dfbbd06f6d71` | identical |
| `literals.json` | 213,736 | `96a97899889b6a5f5357a4c0ae0024d0afe9a214c398784fdcc834f401f0fd03` | identical |
| `engine_params.json` | 4,582 | `20323777391827278dea4494f6f123ac0ba2846cf2b65f4a886c4eaed61e1bad` | +3 overrides (20 overrides, 13 values, 10 modules, master on 10) |

## Gates (logs in `work/staging/combined-r21/evidence/`)

| Gate | Result |
|---|---|
| `register_registry.py` -> `player_text.py` x2, then again | fixed point `ee7df8d0…` |
| CLI build (MSYS2 ucrt64, `-Wall -Wextra -Wpedantic -Werror`, no source change), `verify-missions`, `self-test`, ctest | 0 warnings; PASS 669/669, 150/150, 2/2 |
| Package build gates | `engine-param-overrides` rows=13 overrides=20 modules=10 masters=1; `settings-layout` values=373 live_literals=135 pages=209 quick=25; `settings-declarations` values=373 masters=31; `hook-plan` targets=35 hooks=110; `entry-parameter-keys` names=17 |
| `test_engine_param_override_harness.py` | PASS, 179 Luau checks (78 of them the R19 order: 13 rows x 3 mechanisms x hook/no hook) |
| `test_entry_native_harness.py` (164), `test_void_flood_tank_harness.py` (43), `test_defense_reader_pin_harness.py`, `test_live_literals.py` (33), `test_presets_and_sample.py`, `test_r17_type_masters_harness.py`, `test_r20_multiplier_minimums.py`, `test_flow_gate.py`, `test_phase2d/2e/2k` | PASS |
| Bootstrapper `verify_engine_params.ps1` (R21 F1-F4 on the fixture of this build) | ENGINE PARAMS GATES PASS checks=125 (R19: 115) |
| Bootstrapper `verify_addon_settings.ps1 -Package -Settings -ScriptStates` (R21 Missions + installed Frost/Octavia, read-only copies of the installed values files and `ScriptStates.json`) | ADDON SETTINGS GATES PASS; `ENGINE PARAMS RECIPE ACCEPT … overrides=20 modules=10 values=13`; Missions `declarations=508 rejected=0`, delivery `values=4`; every delivered value reaches a staged member |

## Limits (exact)

- **Nothing is live.** Pending: `ENGINE_PARAM APPLY` lines for Intel and Sabotage and the in-game timers (staging README).
- With a DLL older than R16, or the hook refused, both rows keep the R10 entry write (the class R19 refuted).
- `applies: next_mission`: with the hook a value changed mid-mission applies at the engine's next write of the parameter (for
  Spy, the next vault whose trigger runs).
