# Missions R10: mission-owner research rows, entry templates and the flow-sensitive addon gate (2026-09-30)

- **Build:** client 44.0.2 (`2026.09.28.13.06`), U44 name-hash seed `768e5ed0`.
- **Branch:** ability editor `feat/missions-r10-owners-2026-09-30`, from `feat/missions-r7-r8-merged-2026-09-30` `777618e`.
- **Runtime:** bootstrapper `feat/settings-r10-param-env-2026-09-30` from `c2909f2`
  (`RESEARCH/LUA_CALL_ENVIRONMENT_R10_2026-09-30/README.md` there).
- **Contract:** `work/research/universal-mission-editor-2026-09-29/CONTRACT_PHASE1.md`, Revision R10.
- **Research input:** `work/research/mission-owners-2026-09-30/README.md` (rounds 1 and 2). The drafts are copied byte for
  byte to `inputs/row_drafts.json` (SHA-256 `8b94d678…12e8a4dd`, pinned in `tools/mission_owner_specs.py`).
- **Scope:** repository and `work/` only. The installed game was read only (two `inspect-type` captures, the installed
  `Settings\*.json` hashes). Nothing was deployed or pushed.
- **Status:** every offline gate PASS. **Nothing here is live-tested.**

## Hypotheses and results

| # | Hypothesis | Result | Evidence |
|---|---|---|---|
| H1 | The 65 research drafts can be admitted through the normal registrar path, re-derived from the pinned stock bytes. | **TRUE (64 of 65)** | `register_registry.py` calls `mission_owner_specs.rows()`. Every literal site, number constant (K_CONSTANT_EXCLUSIVE_V1 recomputed), root-table field (ROOT_TABLE_UPVALUE_V1 recomputed), entry prototype (closure map: created once by the root), reader census and metadata preimage is re-checked. `verify-missions` 658/658 PASS. |
| H2 | The Orokin escape timer needs the coupled `value_offset` site form. | **TRUE → excluded** | SabotageOrokin proto 17: `timer = saved > 27 ? 30 : saved + 3`. The 27 is the host-migration restore threshold (30 − 3). A single-site edit leaves the restore rule inconsistent; a coupled site needs a `value_offset` form in the shared live-literal patch core, which is pinned byte-identical in both repositories. Not added in R10; the draft is in `excluded` with that reason. |
| H3 | The flow-sensitive consumer (`tools/flow_gate.py`) replaces the straight-order consumer with no regression. | **TRUE** | `test_flow_gate.py` over the pre-R10 registry (`777618e`): 288 pass both, **20 newly pass** (exactly the Defense caps), 37 fail both, **0 regressions**. |
| H4 | The 20 Defense caps become addon values without changing anything else. | **TRUE** | The regenerated registry changes the backend of exactly those 20 rows (EXACT_LITERAL → TARGET_ADDON). Their 4 masters move from live-literal to addon masters; every other row keeps its backend. |
| H5 | The research's MissionInfo write can be generated without a bootstrapper change. | **TRUE (offline)** | Template `MISSION_INFO_FIELD_AT_ENTRY` uses only `gRegion`, `gGameRules`, `GetMission`, `SetMission`, `IsMaster`, `IsValid` and `print` (hashes checked against a compiled probe: `b364fd20 d7e3ec85 aeab7b8b e9228c58 ce228771 b26a1114 0811edde`). MissionInfo fields are string keys (every stock reader uses string `GETTABLEKS`). |
| H6 | A script-parameter global of the called instance can be addressed from the addon as a hashed field of the environment table. | **TRUE (offline)** | With `-- RENOVICE_HASH_FIELD: <name>` the generator's compile path (`recompile-u44` + alias map) keys `environment.<name>` by the U44 hash (`scoreGoal` → `3a44eae1`, the key of the stock `GETGLOBAL`). Proven by the bootstrapper gate `verify_lua_call_environment.ps1` (CONST-ID: only `FIELD S:scoreGoal` → `FIELD H:3a44eae1`) and by the generator gate `entry-parameter-keys` (compiler reports 11 hashed field names = the 11 parameter globals, each used only in its accessor pair). |
| H7 | Registrar + player text is a fixed point. | **TRUE (after one fix)** | `player_layout.py` added its 100000 rank offset again on every run (the committed registry had 500000). Fixed (`% 100000`). `register_registry.py` then `player_text.py` is byte-stable on a second `player_text.py` run. |

## What was admitted (64 rows)

| Mission type (page) | Rows | Template / lane | Values |
|---|---:|---|---|
| Defense | 1 | MissionInfo count | Waves to finish (normal nodes; default Endless) |
| Interception | 4 | 1 MissionInfo + 3 parameters | Rounds to finish; Score to win (x map value); Time between rounds (15 s); Scoring speed (Advanced) |
| Excavation | 1 | MissionInfo count | Excavators to finish |
| Spy | 2 | 1 MissionInfo + 1 parameter pair | Vault alarm time (x, both alarm globals); Vaults required (Advanced, success rule not traced) |
| Mirror Defense | 1 | MissionInfo count | Phases to finish |
| Void Flood | 1 | MissionInfo count | Tanks to finish |
| Void Cascade | 1 | MissionInfo count | Exolizers to finish |
| Survival | 1 | MissionInfo count | Fixed length (minutes, max 60) |
| Exterminate | 2 | parameters | Kills needed (x, `metersPerEnemy` inverse scale); Archwing kill factor (Advanced) |
| Sabotage | 9 | 7 literal + 2 parameters | Ship escape timer, Archwing time limit and enemies, Orokin charge time, Forest injector time, Gas City meltdown time (parameter) and its two difficulty factors, Surprise extraction (parameter) |
| Control Area (Deepmines) | 2 | parameters | Hold-zone time (90 s), Bonus control threshold (50) |
| Void Armageddon | 16 | root-table addon | Wave, prepare, pre-wave, post-wave, between-round and angel-channel times; waves per round; rounds per reward; kills per wave and max enemies (solo..squad) |
| Rescue | 2 | literal | Hostage timer (easiest, hardest nodes) |
| Legacyte Harvest | 4 | literal | Captures to finish (high scaling, mutated, double trouble, Descendia) |
| Rush | 1 | literal | Pace speed |
| Sanctuary Onslaught | 6 | literal | Zone time, zones per reward, efficiency maximum and gains |
| Assassination | 7 | literal | Kela De Thaym health (duo..squad), boss level bonus, hard-mode level and per player, Ambulas per player |
| All missions | 2 | 1 literal + 1 metadata | Extraction timer (endless, literal); extraction countdown (metadata) |
| The Circuit | 1 | metadata | Decree fragments |

Plus the 20 Defense caps (regular, Infested and Duviri-min tables) that the flow-sensitive gate unlocked, shown under
Defense → Enemies → Max enemies at once (and its "Lowest levels", "Infested", "Duviri" pages).

**Id changes against the drafts** (drafts proposed new families where the registry already has one):
`legacyte_harvest.*` → `infested_capture.required_captures.*`, `mirror_defense.phases_to_finish` →
`loopdefend.phases_to_finish`, `sabotage_orokin.portal_charge_time` → `sabotage.orokin_charge_time`,
`sabotage_forest.defend_time` → `sabotage.forest_defend_time`, `gascity.*` → `sabotage.gascity_*`, `extraction.*` →
`gamerules.extraction_countdown*`. The full map is `ID_MAP` in `tools/mission_owner_specs.py`; each row keeps
`research_draft_id`.

**Units and ranges:** a LOADN literal row's range is clamped to 1..32767 (the shared patch core's LOADN domain; the drafts
had 0 for three Onslaught gains). A MissionInfo count has minimum 0 (0 = the game's own rule, which is also "no write").

**Stock sources:** six modules are not in the Phase 1 extraction (TriggerAlarm, DarkSectors, BossKelaArena,
BossAmbulasArena, HardModeBossUtil, SimpleBossScaling). The registrar takes them from the full U44 extraction
(`repos/toolchains/de-luau-toolchain/work/u44-rawhash-2026-09-29/stock`); all 311 files present in both folders are
byte-identical. They are copied into `shared/corpus/de-luau-u44.0.2-authoring` like every other registered module.

**Metadata inputs:** `inputs/ExtractionTrigger.inspect-type.txt` and `inputs/DuviriArenaBoonPickup.inspect-type.txt`
(read-only `openwf-metadata-updater inspect-type` on the installed 44.0.2). The preimages `_duration=60` (inside
`OnFirstTouchedScript`) and `_boonCollectablesThreshold=3` (inside `PickUpScript`) are verified inside their struct. The
generator now accepts a named script struct (`<Name>Script._param`) as a metadata owner field.

## Generator (src/mission_profiles.inl, src/core.cpp)

- `verify_entry_owner`: gate `CAPTURE_GRAPH_ENTRY_V1`; every entry is a recorded root child; a MissionInfo field is a
  string the module names; a parameter hash equals `FNV(name, seed)` and is referenced by the module.
- `multi_target_addon_source`:
  - `missionInfo_<field>(tag, value)`: host only; normal nodes only (field 0; no alert, invasion, syndicate, goal,
    sortie or nightmare mission); written through `GetMission`/`SetMission`; skipped when already equal; one `print` line.
  - `scriptParameter(tag, mode, read, write)`: per called environment (weak keys): first entry records the observed
    number and writes `x value`, `/ value` or `value`; later entries skip, rewrite when the observed number is back, or
    leave another writer's number alone; `restore()` in cleanup. No environment (older runtime): nothing written.
  - Hooks of entry prototypes use the five-parameter signature; every hook keeps the R3 idle path, the R4 retire-all path
    and the settled retire (entries are root children and are done for the instance once they ran).
- Gates: `hook-plan`/`hook-retire` include entry prototypes (`entry_rows=18`); new `entry-parameter-keys`; the live-flag
  read-back regex uses a lookahead (two flag declarations on consecutive lines were counted as one).
- UI: an entry row applies `next_mission`; parameter rows declare `stock_check: "none"` (the addon writes whatever the
  level passed).
- Self-test: new luau.exe harness "R10 entry templates" (MissionInfo host/client/special missions/once; parameters scale,
  inverse, two globals, rewrite, drift, no environment, cleanup). 149/149.

## Player text and layout (tools/player_text_r10.py, player_layout.py, player_text_live_literals.py, editor_fields.py)

- Every R10 row has a label, a one-sentence description and an R7 path/row. Literal rows are live literals
  (`literal_scope: headline`: 121 recipe values now, 105 before).
- Quick settings (14): new Defense waves to finish, Exterminate kills needed, Interception score to win, Spy vault alarm
  time, Void Armageddon wave time, Control Area (Deepmines) hold time.
- Defaults shown as the player sees them: "Endless", "x1 (map value)", "x1 (30-120 s)", "x1 (formula)", "0.5-0.8x",
  "Game rule"; Defense caps 7-10 / 13-20 / 22-26 / 25-29.
- Categories on every mission page are in the R7 order (Timers, Objectives, Enemies, Rewards / drops, Advanced).
- Control Area locations: Plains of Eidolon, Cambion Drift, Deepmines (below Fortuna). The group label
  "Control Area (Orb Vallis)" and its Orb Vallis node selector are gone (research CA-2: Orb Vallis has no Control Area).
  `control_area_nokko.duration` stays the owner of the `control_area_nokko` preset; SCRIPT SETTINGS shows
  `control_area_nokko.hold_time` instead.

## Metadata lane decision

**Kept out of SCRIPT SETTINGS (R5-M not implemented).** A metadata value applies only when OpenWF's startup metadata
patcher reads a patch file; showing it as an editable row would need a new runtime path that writes (or injects) a patch at
SCRIPT SETTINGS close and a restart. That is a separate bootstrapper feature with its own drift and rollback rules. The 64
metadata rows stay in the registry and build as `OpenWF/Metadata Patches/*.txt` through a mission settings build (not a
package). List (64): the 6 `alchemy.*`, 6 `ascension.*`, `circuit.decree_fragments`, `coh_destroy_targets.num_targets`,
5 `coh_excavation.*`, 2 `cohinterception.*`, 4 `defense.*` (marker threshold, target level falloff x3), `faceoff.cd_burn`,
`gamerules.extraction_countdown`, 14 `infested_capture.*` (Descendia and 1999 variants), 14 `meltdown.*`, 2 `netracell.*`,
6 `shrine.*`, `void_flood.is_duviri_flag`. Exact ids: registry rows with `backend` `METADATA_PATCH`.

## Package (staged `work/staging/combined-r10/`)

| File | SHA-256 |
|---|---|
| `Missions.targets.addon.lua_B` (31 targets, 98 hooks, 18 entry rows) | `71e12ee717f8dbeb8f60d81858b3dcc9cccf42ff0c03fbb11826d81d9cd73b53` |
| `package.json` (365 declarations incl. 30 masters) | `cf40478788a5a0209a1b1ea0b544069d23d9b03ecb2707e3485ab9a80106da82` |
| `literals.json` (121 typeable literals, 42 modules) | `05393c3aaa8f6b6665267b21f8a9308574256c56946b808dc6504c846ba0b8b9` |

486 values in SCRIPT SETTINGS (412 before). Build input: the R9 input unchanged (`rebuild_input.r10.json`).

## Gates

| Gate | Result |
|---|---|
| Build (g++, `-Werror`, `work/builds/ability-editor/current`) | 0 warnings, 0 errors |
| `register_registry.py` → `player_text.py` | PASS; 658 rows, 450 player-text rows, 38 masters; fixed point |
| `verify-missions` | 658/658 PASS, structure PASS |
| self-test / ctest | 149/149 / 2/2 |
| `test_flow_gate.py` | 288 / 20 fixed / 37 / 0 regressions |
| `test_live_literals.py` | 29/29 (baked replacements byte-identical; R10 adds 56 addon values off; recipe syntheses identical) |
| `test_presets_and_sample.py` | 12 presets, 36 rejections, samples as recorded, full package: staged replacements identical, R10 additions only |
| `test_phase2d/2e/2k` | 7 / 7 / 6 PASS |
| Package build gates | `entry-parameter-keys` PASS names=11; `hook-plan` PASS targets=31 hooks=98 entry_rows=18; `live-literal-recipe` PASS values=121; `settings-layout` PASS values=365 live_literals=121 quick=14; `settings-declarations` PASS |

## Limits (exact)

- **Nothing is live.** Open points: the MissionInfo write reaches every reader (research MI-3: live probe), `SetMission`
  replication to clients (squad HUD counts), host migration (the entry hook retires after its write; a new host does not
  write again), the parameter write lands before the trigger's reads (static proof only), the Exterminate population cap
  follows `metersPerEnemy` (the HUD reads `_T.MaxEnemyCount`), the Void Armageddon addon fields in live Zariman missions.
- **Changing a parameter value mid-mission** (F9 or SCRIPT SETTINGS close) restores the level's own value in the running
  mission (cleanup), and the new value applies from the next mission. MissionInfo counts are not undone mid-mission.
- **Spy vaults required** changes a count the success rule may not read (research: PARTIAL); it is in Advanced.
- **Rewards** stay server-side: OpenWF rewards what the client reports as completed.
