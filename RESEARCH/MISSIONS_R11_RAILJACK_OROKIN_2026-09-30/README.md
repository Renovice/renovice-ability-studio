# Missions R11: Railjack kill goals and the Orokin escape timer (2026-09-30)

- **Build:** client 44.0.2 (`2026.09.28.13.06`), U44 name-hash seed `768e5ed0`.
- **Branch:** ability editor `feat/missions-r11-railjack-2026-09-30`, from `feat/missions-r10-owners-2026-09-30` `2d07b6a`.
- **Runtime:** bootstrapper `feat/settings-r11-coupled-literals-2026-09-30` from `d250e11` (worktree
  `repos/runtime/bootstrapper-runtime-wt-r11`; record `RESEARCH/COUPLED_LITERALS_R11_2026-09-30/README.md` there).
- **Contract:** `work/research/universal-mission-editor-2026-09-29/CONTRACT_PHASE1.md`, Revision R11.
- **Research input:** `work/research/railjack-kills-2026-09-30/README.md`. The drafts
  (`inputs/r11_row_drafts.json`) are pinned by their LF content (`B60EDD6E…A18544`) in `tools/mission_owner_specs.py`.
  `inputs/hmisc_railjack_types.txt` and `inputs/CorpusFighterPatrol.inspect-type.txt` are the read-only captures of the
  installed 44.0.2 item data the drafts cite.
- **Scope decision (user):** metadata values are not added to SCRIPT SETTINGS (R5-M not implemented); they are edited
  with the metadata editor.
- **Status:** every offline gate PASS. **Nothing here is live-tested.** Nothing was deployed or pushed.

## Hypotheses and results

| # | Hypothesis | Result | Evidence |
|---|---|---|---|
| H1 | The Grineer Railjack kill goals have a client owner that an existing lane reaches. | **TRUE (static)** | Research RJ-1..RJ-3: encounter parameters (`_minorKillGoals`, `_minorKillGoalsMax`, `_kuvaLichKillGoalMin/Max`, `_majorKillGoals`, `_kuvaLichKillGoal`) stored only in `H.Misc`, read as environment globals in proto 6 of `KillFightersExterminateEncounter` / `KillCrewShipsExterminateObjective`, reached only from the published objective function (proto 9, a root child). Lane: `SCRIPT_PARAM_GLOBAL_AT_ENTRY` (R10). |
| H2 | The R10 parameter modes can write them. | **FALSE → `scale_count`** | Lists and whole-number counts. New generic mode (generator helper `scriptCountParameter`, registrar `PARAM_MODES`): a number or every number of a plain list x value, rounded, at least 1; lists written as new lists; malformed values left alone with one line; cleanup restores the original table. No bootstrapper change. |
| H3 | The Corpus Railjack goal uses the same route. | **TRUE (static), different meaning** | `BasicRailJackPatrol` proto 15 `EnemyPatrol` reads `minorKillGoals/minorKillGoalsMax` from `CorpusFighterPatrol` / `CorpusCrewShipPatrol` (Packages.bin) and publishes the fighter **limit** (netvar `MinorKillGoal`; at the limit `NO_MORE_FIGHTERS` stops new squadrons). No HUD counter. |
| H4 | The Orokin escape timer fits the shared live-literal core with a small change. | **TRUE** | `Site::value_offset` (default 0): `operand = (value + value_offset) x num / den`. 4 lines in the core, byte-identical in both repositories (SHA-256 `2fdda7b8…ba9be8`, pinned by `live-literal-core` here and `verify_live_literals.ps1` there). The bootstrapper recipe parser reads the optional `value_offset` (finite number) and compares it in the row-agreement check. |
| H5 | The coupled row writes both literals from one value with both preimages checked. | **TRUE (offline)** | Registry row `sabotage.orokin_escape_timer` (draft `sabotage_orokin.escape_timer`, now admitted): LOADN 30 at 14959 (value) and LOADN 27 at 14947 (`value_offset: -3`). The registrar checks `27 == (30 - 3)`; the generator checks each preimage and the operand domain (min 4 → 1). The bootstrapper render tape synthesizes the module for 45 s: SHA-256 `7d0f2a08041c5ed2…`, equal to an independent byte patch (45 at 14959, 42 at 14947). |
| H6 | Plain sites keep their R8 recipe form. | **TRUE** | `value_offset` is emitted only when non-zero; every R10 recipe value is byte-for-byte the same JSON (diff: +1 value `sabotage.orokin_escape_timer`; groups differ only by the `order` numbers after the new Railjack group). |

## What was admitted

| Page | Row | Id | Lane | Default |
|---|---|---|---|---|
| Railjack | Fighters to kill (Quick: "Railjack: fighters to kill") | `railjack.fighter_kills_scale` | parameter `scale_count` | x1 (20-130) |
| Railjack | Crewships to kill | `railjack.crewship_kills_scale` | parameter `scale_count` | x1 (2-10) |
| Railjack | Corpus fighters | `railjack.corpus_fighter_limit_scale` | parameter `scale_count` | x1 (20-130) |
| Sabotage > Timers | Orokin: escape timer | `sabotage.orokin_escape_timer` | live literal (coupled site) | 30 s (4 to 32767) |

Railjack has one category, so its rows sit directly on the Railjack page (R7 collapse). New family `railjack`
(`editor_fields.py` group, `player_layout.py` type). The 37 rows ranked after the Orokin row changed only `ui.rank`.

## Files changed

- `include/renovice/live_literal_patch_core.hpp`: `Site::value_offset`, `operand()` (shared core, R11 header note).
- `src/mission_live_literals.inl`: core pin; `mission_patch_site` reads `value_offset`; the recipe emits it when non-zero.
- `src/mission_profiles.inl`: `mission_operand_site` reads `value_offset`; `scale_count` mode; `kScriptCountParameterHelper`
  emitted only when a `scale_count` row is built.
- `src/core.cpp`: the R10 entry harness also runs `scale_count` (Railjack lists x0.5 and x0.1, malformed and keyed tables,
  absent parameter, re-entry, observed-back rewrite, cleanup identity, print text).
- Registrar: `mission_owner_specs.py` (R11 drafts, `scale_count`, `value_offset` literal sites, Orokin admitted),
  `editor_fields.py`, `player_layout.py`, `player_text_r10.py`, `test_live_literals.py` (R11 addon rows in the expected set).
- `REGISTRIES/mission_build_u44.json` (662 rows), `registry_build_report.json`, test results.

## Package (staged `work/staging/combined-r11/`)

| File | SHA-256 |
|---|---|
| `Missions.targets.addon.lua_B` (34 targets, 101 hooks, 21 entry rows, 17 hashed parameter names) | `266996a5ac300a60812328a4515217cd5ca15868af28094f754f81f02b5e8a6a` |
| `package.json` (368 declarations incl. 30 masters) | `29e03fe732d0eb345dd99db52a37c3db369dddcc8de097ee871b110e916224fe` |
| `literals.json` (122 typeable literals, 42 modules) | `d9b3a76481e3999d46b7571ff23073c525fd8e71cdef5e8748c4197de39aabdd` |

490 values in SCRIPT SETTINGS (486 before), 40 mission types, 15 Quick settings entries. Build input: the R10 input
unchanged (`rebuild_input.r11.json`).

## Gates

| Gate | Result |
|---|---|
| Build (g++, `work/builds/ability-editor/current`) | 0 warnings, 0 errors |
| `register_registry.py` → `player_text.py` (x2) | PASS; 662 rows; fixed point (data `CE900EDAB45139DF` twice) |
| `verify-missions` | 662/662 PASS, structure PASS |
| self-test / ctest | 149/149 (R10/R11 entry harness PASS) / 2/2 |
| `test_live_literals.py` | 29/29 |
| `test_presets_and_sample.py`, `test_flow_gate.py`, `test_phase2d/2e/2k` | PASS (flow gate 288 / 20 / 37 / 0 regressions) |
| Package build gates | `entry-parameter-keys` PASS names=17; `multi-target-declared-keys` 34/34; `hook-plan` targets=34 hooks=101 entry_rows=21; `live-literal-core` PASS `2fdda7b8…`; `live-literal-recipe` PASS values=122 extreme_syntheses=244; `settings-layout` PASS values=368 live_literals=122 quick=15; `settings-declarations` PASS |

## Limits (exact)

- **Nothing is live.** Railjack: that the called environment of the sub-objective instance holds the H.Misc parameters
  (same class of proof as the R10 Deepmines row); HUD text and client view of the scaled goal. Orokin: the timer on a real
  Orokin Sabotage; the restored timer after a host migration.
- **Compatibility:** the R11 `literals.json` needs the R11 DLL. The R10 DLL refuses the whole recipe (`site-unknown-field=
  value_offset`, `live_literals_core.hpp` field allow-list), so every typeable fixed number would stay stock there. The
  addon and `package.json` work on the R10 DLL.
- A Railjack change mid-mission applies to the next objective instance (next mission); the running objective keeps its
  goal (cleanup restores the encounter's own lists).
