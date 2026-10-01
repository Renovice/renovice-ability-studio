# Missions R14: Void Flood tank multipliers (2026-10-01)

- **Build:** client 44.0.2 (`2026.09.28.13.06`), U44 name-hash seed `768e5ed0`.
- **Branch:** ability editor `feat/missions-r14-void-flood-tanks-2026-10-01`, from R13 `3e10cd9` (on R12 `d0d963f`).
- **Runtime:** unchanged. Bootstrapper `fix/r13-native-entry-member-policy-2026-10-01` `827027c`, installed DLL
  `e5d9b61b…`. No DLL build was needed.
- **Contract:** `work/research/universal-mission-editor-2026-09-29/CONTRACT_PHASE1.md`, Revision R14 (generic multiplier
  mode for ROOT_TABLE_FIELD rows).
- **Research:** `work/research/void-flood-tanks-2026-10-01/README.md` (what each field does in play; H1-H9). The drafts
  (`inputs/r14_row_drafts.json`) are pinned by their LF content (`CF23C919…C4E6E3`) in `tools/mission_owner_specs.py`.
- **Status:** every offline gate PASS. **Nothing here is live-tested.** Nothing was deployed or pushed.

## Hypotheses and results

| # | Hypothesis | Result | Evidence |
|---|---|---|---|
| H1 | The user's "how fast tanks fill" is `depositPctPerSecond`. | **TRUE (static)** | Deposit loop prototype 48: per frame capacity x rate[squad size] x dt (research H2). Index = squad size, not tank. |
| H2 | The existing lane can own the four values without a runtime change. | **TRUE** | ROOT_TABLE_UPVALUE_V1 PASS for the array elements (element owner, container path) and the scalar fields; hook plans retire-safe; the generated hooks run under R3/R4/R13 unchanged. |
| H3 | One row per value needs a new generator form. | **TRUE → mode `scale` / `scale_count`** | A multiplier over fields with different stocks (0.12/0.09/0.08/0.07; 125-350; 5/20/60) cannot be a single absolute row or an R5 master (masters write master x constant, no rounding, one declaration per driven row). Generic form: owner `mode`, per-field `stock`; R11's count rule (rounded, at least 1) for `scale_count`. No Void Flood name in shared code. |
| H4 | The scaled write cannot compound. | **TRUE (harness)** | The write is computed from the registered stock; a bound instance is never rewritten; a drifted field fails closed; cleanup restores only where the written number is still there. Checked across hook re-entry, re-activation without cleanup, two instances and a new generation. |
| H5 | Builds without a scaled row are byte-identical. | **TRUE** | The per-field `ownedTable` is emitted only when a scaled row is declared (same rule as R11's count helper); plain field entries are unchanged. `test_presets_and_sample.py` rebuilds the phase2g sample and the 12 presets and compares them with the committed outputs (PASS). |
| H6 | The "Tank fill time" rows time the tanks. | **FALSE** | They time the corruption meter (research H7). Renamed "Corruption meter time", "Shortest meter time", "Meter time shrink"; ids unchanged. "Void energy capacity" text corrected (Shadowgrapher only). |

## What was admitted

| Page | Row | Id | Mode | Default | Range |
|---|---|---|---|---|---|
| Void Flood > Objectives | Tank fill speed (Quick: "Void Flood: tank fill speed") | `void_flood.deposit_speed_scale` | scale over `depositPctPerSecond[1..4]` | x1 (8-14 s) | 0.05 to 100 |
| Void Flood > Objectives | Tank capacity | `void_flood.tank_capacity_scale` | scale_count over `capacity[1..4]` | x1 (125-350) | 0.05 to 100 |
| Void Flood > Objectives | Void orb value | `void_flood.orb_value_scale` | scale over `smallAmt`, `mediumAmt`, `largeAmt` | x1 (5-60) | 0.05 to 100 |
| Void Flood > Objectives | Tank drain speed | `void_flood.drain_speed_scale` | scale over `drainPercent` | x1 | 0 to 100 |

Minimum 0.05 for fill speed, capacity and orb value (0 would stop tanks from filling or make orbs worthless); 0 allowed for
drain (no drain). Maximum 100 is a numeric guard, not a tested gameplay range. Phase 1 rows `void_flood.deposit_and_drain`,
`.tank_capacity` and `.pickup_amounts` are now covered (the first and last partly; the rest is in `excluded_parts`).

## Files changed

- `src/mission_profiles.inl`: `root_field_mode`, per-field stock and mode checks in `verify_root_table_fields`,
  `kScaledOwnedTableHelper` (emitted only with a scaled row), scaled field entries in `multi_target_addon_source`.
- `src/core.cpp`: self-test: the two-instance harness understands scaled fields (field stock, expected written number,
  setting numbers); the wide package build enables the four Void Flood multipliers; a new check rejects wrong/missing field
  stocks, a field stock on an unscaled row, a row stock other than 1, a fractional `scale_count` field and an unknown mode.
- Registrar: `mission_owner_specs.py` (R14 drafts, `mode`, per-field proof, `value_instruction`, `phase1_tunable_id`,
  `EXCLUDED_PARTS`), `register_registry.py` (merges those parts), `player_text_r10.py` (R14 rows), `player_text.py` and
  `player_layout.py` (corrected Void Flood meter rows, R14 layout, defaults, descriptions, Quick entry).
- New gate `tools/test_void_flood_tank_harness.py`; `tools/test_entry_native_harness.py` pins the R14 build of the same
  input (R12 was `8e0e1871`).
- `REGISTRIES/mission_build_u44.json` (667 rows, SHA-256 `CA9E926A…D18BA50B`), `registry_build_report.json`, test results.

## Package (staged `work/staging/combined-r14/`, 2 files)

| File | Bytes | SHA-256 |
|---|---:|---|
| `Missions.targets.addon.lua_B` (34 targets, 109 hooks, 22 entry rows) | 113,552 | `4c70b5ec200f9409ca034546aea37555c8f6081cd6661978c3a41e347b7ccbba` |
| `package.json` (373 declarations incl. 30 masters) | 254,270 | `65714ffb0af4a435848563e7bf42d25ad72cf16f5bceb6099bb6a88a3d543b21` |
| `literals.json` (unchanged, not staged) | | `d9b3a76481e3999d46b7571ff23073c525fd8e71cdef5e8748c4197de39aabdd` |

495 values in SCRIPT SETTINGS (491 before), 40 mission types, 17 Quick settings entries. Build input: the R12 input unchanged
(`RESEARCH/MISSIONS_R13_NATIVE_ENTRY_2026-10-01/inputs/rebuild_input.r12.json`).

## Gates

| Gate | Result |
|---|---|
| Build (g++ `-Wall -Wextra -Wpedantic -Werror`, `work/builds/ability-editor/current`) | 0 warnings, 0 errors |
| `register_registry.py` → `player_text.py` (x2), then again | PASS; 667 rows; fixed point (registrar `3C3D4E8A…`, registry `CA9E926A…` twice, data `2B749E070291CBEF`) |
| `verify-missions` | 667/667 PASS, structure PASS |
| self-test / ctest | 150/150 (new: R14 verify cases; wide-package harness with the four multipliers) / 2/2 |
| `test_live_literals.py` | 29/29 |
| `test_presets_and_sample.py`, `test_flow_gate.py`, `test_phase2d/2e/2k` | PASS (flow gate 288 / 20 / 37 / 0 regressions; hook plan tables 95, minimal hooks 160) |
| `test_void_flood_tank_harness.py` | PASS: 37 Luau checks on the real generated addon (scaled once, retire signals, no compounding on re-entry / re-activation / second instance / new generation, cleanup restore, drift, R4 retire-all, rounding to at least 1, transcribed deposit / carry / drain / orb rules) + R5-C coexistence (no overlap with the 3 literal sites; synthesized fractures-4 module keeps every field stock) |
| `test_entry_native_harness.py` | PASS, 113 checks (22 entry rows, Defense checkpoint rule) |
| Package build gates | `entry-parameter-keys` names=18; `multi-target-declared-keys` 34/34; `hook-plan` targets=34 hooks=109 entry_rows=22, idle/retire-all on every hook; `live-literal-core` `2fdda7b8…`; `live-literal-recipe` values=122 extreme_syntheses=244; `settings-layout` values=373 live_literals=122 pages=212 quick=17; `settings-declarations` values=373 masters=30 |
| Bootstrapper `verify_addon_settings.ps1 -Package/-Settings/-ScriptStates` (wt-r11 `827027c`; R14 Missions + installed Frost/Octavia, read-only copies of the installed values files and ScriptStates.json) | ADDON SETTINGS GATES PASS; `LIVE LITERALS RECIPE ACCEPT … values=122`; Missions `declarations=495 rejected=0 unknown_entries=6 members_staged=1/1`; `PACKAGE ACCEPT … target_keys=34`; rows "Tank fill speed: x1 (8-14 s) (default)" etc. and Quick "Void Flood: tank fill speed" rendered |
| Bootstrapper `verify_live_literals.ps1` | LIVE LITERALS GATES PASS (146 checks, `/W4 /WX`) |

## Limits (exact)

- **Nothing is live.** Pending: the four values in a real Void Flood mission (host, solo), the HUD tank percentage on
  clients, and the corruption meter with faster tanks.
- The gameplay effect is read from the readable decompile and transcribed in the harness; the pickup module
  (`ZarimanCorruptionPickups`) is read from bytecode only (decompile unavailable).
- "Void orb value" is copied by the game at mission start: a change applies from the next mission, although the editor's
  generic line says "Applies live, at the next read" (lane-level text). The row description states the exact rule.
- The Shadowgrapher variant (flag `3420abb0`, name unresolved) is not affected by any of the four rows.
