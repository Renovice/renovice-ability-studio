# Missions R18: coverage audit fixes ("All" masters, cross-script drives, Pontis tower rows) (2026-10-02)

- **Build:** client 44.0.2 (`2026.09.28.13.06`), U44 name-hash seed `768e5ed0`.
- **Branch:** ability editor `feat/missions-r18-coverage-2026-10-02`, from R17 `dc8eef5`.
- **Runtime:** none (the installed R17 bootstrapper `304b57de…` already has every primitive used here).
- **Research:** `work/research/mission-coverage-audit-2026-10-02/README.md` (audit of the installed R17 package, lost-value
  history R5-R17, mission types, master coverage, Railjack Corpus/Pontis owners in `railjack/FINDINGS.txt`).
- **Status:** every offline gate PASS. **Nothing is live.** Staged `work/staging/combined-r18/`. Nothing deployed or pushed.

## Hypotheses

| # | Hypothesis | Result | Evidence |
|---|---|---|---|
| H1 | The audit gaps need no new runtime primitive. | **TRUE** | Masters: R5/R17 literal masters (single and cross-module drives). Pontis: SCRIPT_PARAM_GLOBAL_AT_ENTRY `scale_count` (R11) + ENGINE_PARAM_OVERRIDE (R16) with a master on a writer-owned row (R17). Bootstrapper replay accepts the package (`declarations=508 rejected=0`). |
| H2 | The Pontis goals can be admitted through the registrar unchanged. | **TRUE** | Drafts re-derived and re-checked on the pinned stock bytes: entries are root children (AS1Space P16 closure at root i198, GS1Space P13 at i178), census of `833d05b3` = one hashed GETIMPORT each (P14 i130, P11 i83), hash and module identity match. |
| H3 | Adding a cross-module drive to a literal master keeps the legacy baked build correct. | **FALSE → fixed** | The R5 regression input (masters MD 20 s, Excavation 50 s, shipped off) built two extra exact-replacement members (SentientMobileDefense, CoHExcavationLite) whose rows were switched on independently of the master and displaced that module's four addon values. Generator fix: a baked build expands a cross-module literal master in its own module only and records the other rows in `excluded_values`; the baked set is byte-identical to the staged one again (`test_live_literals`). |

## Changes

| Area | Change |
|---|---|
| `inputs/r18_row_drafts.json` (LF SHA-256 `7CF89970…60BC7E8`) | `railjack.pontis_ash_enemies_scale` (AS1Space `434d0132e720ed37`), `railjack.pontis_garuda_enemies_scale` (GS1Space `52145531e84e69ca`): `spaceEnemyCountPerVariant`, `scale_count`, x1 (0.1-10). |
| `inputs/r18_engine_overrides.json` (`6BE472F4…8BE773`) | Both rows EXPOSED (conditional Sleep(0) wait before the read) → ENGINE_PARAM_OVERRIDE_V1. |
| `tools/mission_owner_specs.py` | R18 drafts and overrides (pinned). |
| `tools/player_text.py` | `mobiledefense.time_per_terminal` + `sentientmd.defend_time`; `excavation.dig_time` + `coh_excavation.dig_duration` (group named: cross-module). |
| `tools/player_text_r17.py` | New masters `entrati_swarm.tears_per_stage_all` (10 rows), `sabotage.escape_timer` (ship + Orokin, 2 modules); Railjack master + both Pontis rows. |
| `tools/player_text_r10.py`, `tools/player_layout.py` | Pontis rows (Railjack > Pontis tower: space enemies), two page masters, defaults ("8-20", "30-300 s", "45-140 s", "60-120 s", "x1 (4-6)", "x1 (4-7)"), tooltips naming the missions each Railjack and Exterminate value reaches (Corpus Exterminate counter = Exterminate "Kills needed"; Corpus has no crewship goal). |
| `src/mission_profiles.inl` | Baked build: cross-module literal master drives outside the master's module are left stock and recorded (H3). |
| `src/core.cpp` | Self-test pin: MD master default label "60-120 s". |
| Gates | Pins moved to the R18 build: `test_engine_param_override_harness.py` (+2 Pontis cases, 11 overrides / 6 modules, masters on three writer-owned rows; the bootstrapper fixture stays R17), `test_entry_native_harness.py` (21 entry rows), `test_void_flood_tank_harness.py`, `test_presets_and_sample.py` (engine_params), `test_live_literals.py` (MD label, R18 master drives, baked cross-module check). |

## Package (staged `work/staging/combined-r18/OpenWF/CustomScripts/Packages/Missions/`)

| File | Bytes | SHA-256 |
|---|---:|---|
| `Missions.targets.addon.lua_B` (35 targets, 110 hooks, 21 entry rows) | see `SHA256SUMS` | `43cb89c3a3f230c75d9fdb665a57418023d54d2c4d5d555c9faf539a192ebba7` |
| `package.json` (373 declarations, 31 masters) | | `150c0d1642d9208f97fc46df7a14ce411b60120cb4280d30f991aaf179978ff7` |
| `literals.json` (135 live literals, 18 masters, 43 modules) | | `786c7b94a7c296758b8c94d40c3fcd69cb1a5dcbcda661a2cc7f15093cc1cbe6` |
| `engine_params.json` (11 overrides, 9 values, 6 modules, 1 master) | | `13cb029064ef4c29141a0bbec37e3daf5888a5271fae141bc9282db9c07c0341` |

508 values (373 + 135), 25 Quick settings entries, 23 "All <type> missions" masters. Build input unchanged
(`MISSIONS_R13_NATIVE_ENTRY_2026-10-01/inputs/rebuild_input.r12.json`). Registry fixed point `a45603ce…` (669 rows), player
text data `C8F00E7467866B2F`.

## Gates

| Gate | Result |
|---|---|
| `register_registry.py` → `player_text.py` ×2, then again | fixed point `a45603ce…` |
| CLI build (MSYS2 ucrt64, `-Werror`), `verify-missions`, `self-test`, ctest | 0 warnings; PASS 669/669, 150/150, 2/2 |
| Package build gates | `entry-parameter-keys` names=17; `multi-target-declared-keys` 35/35; `hook-plan` targets=35 hooks=110; `live-literal-recipe` values=135 masters=18 modules=43; `engine-param-overrides` rows=9 overrides=11 modules=6 masters=1; `settings-layout` values=373 live_literals=135 pages=209 quick=25; `settings-declarations` masters=31 |
| `test_flow_gate`, `test_phase2d/2e/2k`, `test_live_literals` (33), `test_presets_and_sample`, `test_r17_type_masters_harness`, `test_engine_param_override_harness`, `test_entry_native_harness`, `test_defense_reader_pin_harness`, `test_void_flood_tank_harness` | PASS |
| Bootstrapper `verify_addon_settings.ps1` (worktree `bootstrapper-runtime-wt-r16` `45ed7b0`): R18 Missions + installed Frost/Octavia + read-only copies of the user's values files and `ScriptStates.json` | ADDON SETTINGS GATES PASS; Missions `declarations=508 rejected=0 unknown_entries=6 members_staged=1/1`; recipe and engine-params ACCEPT |

## Limits (exact)

- Nothing is live. Pontis: the goal is `min(AI director value, list[variant])`, so a higher multiplier may not show; whether
  the H.AnimRetarget encounter parameters pass through the engine writer is the R16 open inference.
- A cross-module master reaches its other modules only through `literals.json` (recipe build, R17 DLL); a legacy baked build
  leaves those rows stock (recorded in `excluded_values`).
- One "All" master per type page: second families (Defense waves to finish, Mobile Defense terminals/areas, Orphix round
  limits, Void Flood fractures, Survival lengths) are flagged in the research, not changed.
