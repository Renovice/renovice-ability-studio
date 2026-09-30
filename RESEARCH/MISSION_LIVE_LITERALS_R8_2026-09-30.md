# Missions: typeable script-literal values as recipes (LIVE_LITERALS_V1, contract R8, 2026-09-30)

Client 44.0.2 (`2026.09.28.13.06`). Branch `feat/live-literals-recipes-2026-09-30` (from `feat/universal-mission-registry`
`4511059`). Runtime: bootstrapper `feat/live-literals-2026-09-30` (record
`repos/runtime/bootstrapper-runtime/RESEARCH/LIVE_LITERALS_2026-09-30/README.md` on that branch). Contract:
`work/research/universal-mission-editor-2026-09-29/CONTRACT_PHASE1.md` Revision R8. Offline only: no game or server folder was
written; nothing was pushed.

## Hypotheses

| # | Hypothesis | Result | Evidence |
|---|---|---|---|
| G1 | The exact-literal builder's site logic can move into one shared core without changing any built byte. | **TRUE** | `include/renovice/live_literal_patch_core.hpp` (SHA-256 `b933c7c7…`, byte-identical to the bootstrapper's `renovice/live_literal_patch_core.hpp`) now does operand, domain, encoding, preimage verification and the permitted-diff application for the baked builder, `check_literal_operand` and the registry stock check. The staged full package's rebuild input builds a byte-identical package (7 files) and values file; self-test 148/148; `verify-missions` 594/594. |
| G2 | A declarative recipe (sites, preimages, encoding, scale, stock SHA-256) reproduces the baked bytes. | **TRUE** | Recipe mode synthesizes Mobile Defense 20 s, Void Flood 4, Excavation 50 s and Control Area 30 s (Plains, Cambion) equal to the staged baked replacements byte for byte (generator and bootstrapper gates, independently). |
| G3 | Every literal-lane headline row of the R5 matrix can be declared with player text and a stock the player experiences. | **TRUE for every literal-lane matrix row that has a registry row with a stock (exceptions below)** | `tools/player_text_live_literals.py`: 105 values (93 rows, 12 master knobs) in 28 modules; `player_text.py` gates (label <= 33, value row <= 40, banned abbreviations, stock + unit, tooltip <= 300, unique per section) PASS. |
| G4 | With recipes, a module may carry live literal values and addon values at once (R5-C). | **TRUE offline** | The recipe does not replace the module statically; the host synthesizes at the undump and addons keep binding by the stock content key (bootstrapper R8 gate pins). Recipe mode no longer excludes addon rows: the 8 Mobile Defense enemy counts and 4 masters, the Void Flood tank rows and the other rows of literal modules are declared again (package.json 294 -> 308 values). Live pending. |
| G5 | The recipe package stays valid on a DLL without LIVE_LITERALS_V1. | **TRUE (gate on `b5a120b`)** | `literals.json` is not a member file; old DLLs ignore it. `verify_script_packages -AdmitPackage`: `PACKAGE ACCEPT … members=1 replacements=0 target_addons=1 target_keys=23`; `verify_addon_settings -Package -Settings`: ADDON SETTINGS GATES PASS (recipe ids in the values file are unknown entries, ignored). The package description says why those values stay stock. |

## What changed

- **Shared core** `include/renovice/live_literal_patch_core.hpp` (new; `src/core.cpp` includes it). `src/mission_profiles.inl`:
  `mission_site_operand`, `check_literal_operand`, the registry stock-operand check and the exact-replacement builder use it
  (same error texts, same bytes).
- **Recipe emitter** `src/mission_live_literals.inl` (new, included before `build_mission_set`): `mission_patch_site`,
  `live_literal_value` (row or literal master), `resolve_live_literal_module` (the host's precedence rule), 
  `synthesize_live_literal_module`, `live_literal_recipe` (ordered JSON) and `emit_live_literal_recipe` (file + gates).
- **Build input** (`build_mission_settings`): `"literal_mode": "baked"` (default, unchanged) or `"recipe"` (needs
  `output_layout: package` and `package_scope: all_addon_values`); `"literal_scope": "built_values"` (default) or `"headline"`
  (declare every `ui_player_text.live_literal_headline` value at stock, off). Recorded in the normalized input only when set, so
  every earlier build keeps its hash.
- **Recipe mode** (`build_mission_set`): literal masters are not expanded; named EXACT_LITERAL rows go to the recipe; no
  baked replacement member is built; addon rows of literal modules are declared (R5-C); `Packages/Missions/literals.json` is
  written after `package.json` (recipe values carry `insert_before` so SCRIPT SETTINGS keeps the section/rank order);
  groups used only by recipe values are declared in the recipe, not in package.json; the values file lists every recipe value
  (`enabled` = named and not in `disabled_values`, `value` = the built value or stock); `package-folder` ignores `literals.json`;
  the package description names the requirement; `MISSION_SET_MANIFEST.json` `package.live_literals` records the recipe.
- **Gates** (BUILD_GATES.log): `live-literal-core` (pinned core SHA-256), `live-literal-recipe` (schema via
  `validate_settings_declarations`, player text, per-section label uniqueness with package.json values, every site re-verified
  against the pinned stock, constant sites only with `K_CONSTANT_EXCLUSIVE_V1`, every value alone at its min and at its max
  synthesizes, the shipped values synthesize), `live-literal-roundtrip` (`derecomp de-roundtrip` FULL BODY identical for each
  shipped synthesized module).
- **Player text**: `tools/player_text_live_literals.py` (new; called from `player_text.py`, which also writes
  `ui_player_text.live_literal_headline`); registry `REGISTRIES/mission_build_u44.json` regenerated (376 player-text rows, 38
  masters; data digest `002EC603D5154936…`).
- **Test** `tools/test_live_literals.py` (22 checks) with `test-results/live_literals.json`.

## Typeable headline values (105)

Masters are listed with the rows they drive; "adv" = the mission's Advanced section.

| Mission | Values |
|---|---|
| Survival | Duviri: Survival length (300 s) |
| Defense | Max enemies at once (solo/duo/trio/squad; masters over regular and Infested, both level ends; 10/20/26/29); adv: Level 30+: max enemies x4, Infested: max enemies x4; Delay before the first wave (6 s); Time between waves (6 s); Alert missions / Nightmare / Duviri / Descendia: waves to finish (6/3/3/1) |
| Mobile Defense | Time per terminal (master, 80 s); adv: Hard/Easy nodes: total terminal time (240/180 s); Terminals per mission (3) |
| 1999 Exterminate | Supply crate timer (120 s) |
| Excavation | Dig time per excavator (master, 100 s); adv: Standard / Elite Alert / Old World Salvage dig time; Duviri: excavations (3) |
| Disruption | Rounds to finish (4); Sortie: rounds to finish (8); Round time-out timer (180 s); Time between rounds (20 s); Relics: time between rounds (10 s); Max enemies at once x4 (masters over standard, Sentient, Entrati lab, both ends); adv: Standard / Sentient / Lab: max enemies x4 each |
| Void Flood | Fractures per round (3); Duviri: fractures per round (5) |
| Capture | Downed target: grace time (20 s); Downed target: escape timer (60 s) |
| Defection | Squads to rescue (4); Sortie: squads to rescue (5) |
| Mirror Defense | Time per phase (150 s); Jade: time per phase (60 s) |
| Lantern | Score to win (300 s); Time to reach extraction (180 s); Boss arrives after (900 s) |
| Purgatory | Starting time (60 s); Time per pickup (5 s, float); Max enemies at once (10); Time between spawns (master, 5 s, random 3-5); adv: Shortest / Longest time between spawns |
| Descendia | Excavation: dig time (45 s); Nemesis: time between spawns (15 s) |
| 1999 Defense | Time between drone spawns (5 s) |
| Orphix Venom | Sortie: rounds to finish (12) |
| Sentient Mobile Defense | Defend time per area (120 s); Areas to complete (3) |
| Hack-Station Defense | Defend time per station (master, 240 s, random 30-240 by node level); adv: Easy/Hard nodes: shortest/longest defend time; Stations to defend (4) |
| Netracell | Power required (200); Power per extra player (100) |
| Archimedea (new chains) | Deep: Survival minutes (10); Temporal: Survival minutes (10); Temporal: Defense waves (6); Deep: Alchemy mixtures (2); Deep: Disruption conduits (8); Deep: Mirror Defense phases (4) |
| Pursuit / Archwing | Defend-ship phase time (60 s); EMP countdown (30 s) |
| Entrati Swarm | Tears for stage 1-5 (8/10/12/15/15); adv: Challenge: tears for stage 1-5 |
| Purge | Enemies to kill (50) |
| Arbitration | Max resurrection score (25) |
| Hijack | Payload health (10000); Goal missions: payload health (3000) |
| Control Area | Hold-zone time (Plains 90 s); Hold-zone time (Cambion) (90 s) |

Matrix literal rows **not** made typeable, and why:
- Rescue hostage timer and Legacyte captures: no registry row yet (drafted in `work/research/mission-owners-2026-09-30`; they
  need the registrar's verification before a recipe can carry them).
- Orb Vallis Control Area: the row has no stock value (mission resource `defendTime`).
- Defense's regular enemy caps stay literal (now typeable through the Defense masters) until the flow-sensitive addon gate moves
  them to the addon lane (live mid-mission).

Every value applies at the next mission (next load of the module). A value at its default (stock) adds no patch: the stock
module loads.

## Gates

| Gate | Result |
|---|---|
| Build (`-Werror`, g++) | 0 warnings, 0 errors |
| `player_text.py` | PASS: 376 rows, 38 masters, 5 hidden, 105 live literal headline values |
| `verify-missions` | 594/594 PASS, structure PASS |
| C++ self-test / ctest | 148/148 / 2/2 |
| Baked rebuild of the staged full package | package (7 files) and values file byte-identical |
| Recipe build (`literal_mode` recipe, `literal_scope` headline, staged build values) | live-literal-core PASS; live-literal-recipe PASS values=105 masters=12 modules=28 extreme_syntheses=210 shipped_modules=5 recipe_groups=18; 5 x live-literal-roundtrip FULL BODY identical; hook-plan PASS targets=23 hooks=69; package-folder PASS members=1; settings-declarations PASS values=308 groups=36 masters=26 |
| `test_live_literals.py` | 22/22 (baked identity, recipe shape, 105 headline values, 5 byte-exact syntheses, R5-C declarations, values file, 3 rejections, old bootstrapper `b5a120b` admit + settings) |
| Bootstrapper `verify_live_literals.ps1` on the same recipe | 124 checks PASS, zero-warning private build `e19adfb5…` (bootstrapper record) |

Not rerun here: `test_presets_and_sample.py`, `test_phase2d/2e/2k` (they hard-code the main checkout
`repos/apps/ability-editor` and its `current` build). Baked mode is proven unchanged by the byte-identical full package and the
148 self-tests on this checkout.

## Merge notes (against `4511059`)

- `src/core.cpp`: one include after `renovice/core.hpp`.
- `src/mission_profiles.inl` (**the SCRIPT SETTINGS redesign agent also edits the generator for labels and paths**):
  1. `mission_site_operand` / new `mission_operand_site` / `check_literal_operand` (top of file);
  2. `verify_mission_row`'s stock-operand block (6 lines);
  3. `MissionNaming`: two fields `literal_recipes`, `literal_headline` (appended);
  4. `#include "mission_live_literals.inl"` before `build_mission_set`;
  5. `build_mission_set`: literal-master expansion skip (1 line), named EXACT_LITERAL rows skip (1 line), normalized input (2
     lines), exact-replacement builder loop (the per-site body and `patches`/`synthesize_live_literal_module`), package block:
     `LiveLiteralOutput` declaration, description text (recipe branch), recipe emission after `package.json`, `literals.json`
     excluded from `on_disk`, migration values merge (2 lines), `package_record.live_literals`;
  6. `build_mission_settings`: `literal_mode` / `literal_scope` parsing after `disabled_values`.
  Label/path changes of the redesign merge independently, except: the recipe declarations are built with the same
  `mission_value_declaration` / `mission_master_declaration` / `mission_group_declaration`, so any new declaration field the
  redesign adds flows into `literals.json` automatically, but the recipe `declaration` object copies an explicit key list
  (`group label unit type stock min max scope lane applies` in `live_literal_recipe`): add new keys there too.
- `RESEARCH/UNIVERSAL_MISSION_REGISTRY_2026-09-29/tools/player_text.py`: 4 lines before the group labels (import + register),
  `data_digest` includes the headline list, `apply()` validates it and writes `live_literal_headline` into the meta.
- `REGISTRIES/mission_build_u44.json`: regenerated by `player_text.py`; on conflict, rerun `python player_text.py` after merging
  the text sources.
- New: `include/renovice/live_literal_patch_core.hpp`, `src/mission_live_literals.inl`,
  `tools/player_text_live_literals.py`, `tools/test_live_literals.py`, `test-results/live_literals.json`, this note.
