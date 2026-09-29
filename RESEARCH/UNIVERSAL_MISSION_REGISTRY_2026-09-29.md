# Universal mission registry and group-by-body-key generator (Phase 2a + 2b) — 2026-09-29

**Build.** Steam client `2026.09.28.13.06` (Hotfix 44.0.2). Packages.bin SHA-256 `d0c66fc4…955b6`.
**Scope.** Offline only. Nothing was written to a game folder, deployed, or applied to the server.
In-game verification is pending (Phase 2c).
**Inputs.** Phase 1 study `work/research/universal-mission-editor-2026-09-29/` (`ARCHITECTURE_OPTIONS.md` Option A,
`mission_tunables.json`, `stock/`, `meta/`). Previous registry: git `01c9651:REGISTRIES/mission_build_u44.json`
(build `2026.09.24.13.29`).

## Hypotheses and results

| # | Hypothesis | Result |
|---|---|---|
| H1 | The Phase 1 stock extraction is the real 44.0.2 client code. | **TRUE.** All 311 extracted modules were re-extracted from the live `Cache.Windows/B.Font.toc` and compared: 311/311 byte-identical. `Packages-44.0.2.bin` hashes to the recorded `d0c66fc4…`. |
| H2 | 11 of the 12 presets are still valid on 44.0.2 by bytes; only ConquestLib moved. | **TRUE.** 11 bodies have the same SHA-256 and every carried-over preimage matches at its offset. |
| H3 | ConquestLib keeps the six EDA/ETA `LOADN` preimages in prototype 43, moved by +61 bytes. | **TRUE.** Body `076a7b443af7fdb8`, SHA-256 `73107506…29453`. Re-derived structurally (two `waveOverrides` stores at root instructions 1015/1049; `LOADN r8,<mission type>; LOADN r9,<stock>; SETTABLE r9,r7,r8` exactly once per setting). Instructions 1010/1013/1038/1041/1044/1047 are unchanged, offsets are 46631…46823 (each old offset +61), preimages unchanged. |
| H4 | The live-proven Survival addon owners are the root tables that hold `interval` and `pickupTimeAdded`. | **TRUE (static).** `derecomp closure-map`: prototype 67 is created once by root instruction 717. Capture 70 = `VAL:R9`, last written by `DUPTABLE` template 39 whose `interval` entry is constant 34 = 300.0. Capture 22 = `VAL:R8`, template 33, `pickupTimeAdded` constant 23 = 7.0. Capture 19 = `REF:R43` (elapsed reward clock). |
| H5 | Presets keep working through the new generator. | **TRUE (offline).** The 11 presets on unchanged bodies, built through the registry path with the values used by the 2026-09-27 tests, produce byte-identical artifacts to the previous path's staged outputs. For Survival and Interception the addon source is identical apart from the build-label header comment, and the bytecode is identical. |
| H6 | Many Phase 1 Lua rows can be anchored automatically. | **FALSE for most rows.** Only one new Lua row has a unique `LOADN→SETTABLEKS "field"` anchor. Most root-table values live in `DUPTABLE` template constants, and most literal rows are described only in prose. See the exclusions below. |

## What was built

1. **Registry (schema 2).** `REGISTRIES/mission_build_u44.json` (SHA-256 `0DAC8B9C…6F42F`). It has:
   - `build` (the only accepted label);
   - the corpus path and the Packages.bin hash;
   - the name-hash seed;
   - `modules` (17 body keys, with the addon template record for Survival and Interception);
   - 31 `tunables`, 12 `missions` presets (views over tunables), and 337 `excluded` rows, each with a reason.

   Each row has: `tunable_id` (from Phase 1; `mobiledefense.total_time` is split into `.minimum` / `.maximum`),
   `owner_kind`, `backend`, the exact `owner`, `unit`, `stock`, `limits`, `variant`, `shared_with`, `applies`,
   `confidence` and `provenance`. The exact owner is one of:
   - body key + stock SHA-256 + prototype/instruction/offset/preimage;
   - prototype + upvalue + field with capture evidence;
   - trigger type + field + preimage line + consumer body + name hash;
   - server config key + source SHA-256 + preimage.
2. **Corpus.** `shared/corpus/de-luau-u44.0.2-authoring/` holds:
   - the 17 stock bodies the registry names;
   - `METADATA_SNAPSHOT.json`, the composed trigger text for the admitted owner types;
   - `CORPUS_MANIFEST.json`.

   The previous `de-luau-u44-authoring` corpus is untouched as evidence.
3. **Registrar.** `RESEARCH/UNIVERSAL_MISSION_REGISTRY_2026-09-29/tools/register_registry.py` (with `deluau.py`) regenerates
   the registry, the corpus and `registry_build_report.json` from the current build. It does not search blindly for
   numbers. The previous `RESEARCH/U44_AUTHORING_2026-09-27/scripts/build_profile.py` and
   `ARCHIMEDEA_TIMERS_2026-09-27/scripts/bindings.py --register` are superseded: they write the schema-1 format. Do
   not rerun them.
4. **C++ core** (`src/mission_profiles.inl`, `include/renovice/core.hpp`, `src/cli.cpp`):
   - **Build label.** It is read from the registry. Presets and settings for any other build fail closed
     (`Unsupported mission build profile`).
   - **`verify_mission_registry` / `verify-missions`.** Structural checks cover duplicate IDs, overlapping exact
     sites, limits, `applies`, and whether each preset's lane matches its backend. Each row is then checked against
     its evidence:
     - literal rows: body SHA-256 and exact preimage, plus the numeric-constant tag;
     - addon rows: module template and value binding;
     - metadata rows: snapshot SHA-256 and value, the preimage line, the consumer body SHA-256, and the hashed global
       present in the consumer (a guard against unread parameters);
     - server rows: source SHA-256 and preimage.
   - **`build_mission_settings` / `build-missions`.** The input is `{"format":"RENOVICE_MISSION_SETTINGS_V1","build",
     "values":{tunable_id:number}}`. Values are validated against the row limits, whole-number rules and exact
     operand rules. Every used row is re-verified. Rows are then grouped:
     - one merged exact replacement per body key;
     - one target addon per body key, built by the existing verified templates from a registry scaffold;
     - one `RENOVICE_Missions.txt` for all metadata rows;
     - one `server-config-diff.json`, which is written but never applied.

     A body key that would get both a replacement and an addon is rejected. Overlapping sites are rejected. Gates
     reused: stock hash, preimage and allowed diff, metadata readback, `recompile` / `plan-verify` / `recompile-u44`,
     and `de-roundtrip`. Each artifact gets an existing-format `BUILD_MANIFEST.*.json`, and the set gets
     `MISSION_SET_MANIFEST.json`.
   - **`build_profile_mission` (presets).** It maps the preset parameters to tunables. The Void Cascade speed
     multiplier becomes `90/x` seconds on `void_cascade.pillar_duration`. The preset then builds through the same
     generator, keeping the old artifact names and a single `BUILD_MANIFEST.json`.
5. **C# desktop** (UI contract unchanged):
   - `MissionBuildProfile.Build(editorRoot)` and `Lane(...)` are read from the registry.
   - `MissionTimerPreset.Lane` is added.
   - `AbilityProject.ConfigureMissionBuildProfile` and the `MainWindow` export choose the lane from the registry
     instead of hard-coded ID lists.

## Registry row counts (client 44.0.2)

Phase 1 denominator: 367 rows. Registry: **31 rows included** (they cover 30 Phase 1 IDs, plus one carried-over preset
extension row). **337 excluded.**

**Included rows by owner kind**

| Owner kind | Rows | Backend | Carried over / re-registered / new |
|---|---:|---|---|
| `LUA_PROTO_LITERAL` | 9 | EXACT_LITERAL | 9 / 0 / 0 |
| `LUA_ROOT_TABLE` | 10 | 8 EXACT_LITERAL (root-constructor literal: ConquestLib ×6, Void Cascade ×2), 2 TARGET_ADDON (Survival) | 3 / 6 (ConquestLib) / 1 (`void_cascade.alert_reward_interval`) |
| `METADATA_PARAM` | 10 | 9 METADATA_PATCH, 1 TARGET_ADDON (Interception, Phase 1 PARTIAL, carried-over preset) | 3 / 0 / 7 |
| `SERVER` | 1 | SERVER_CONFIG (`worldState.creditBoostMultiplier`) | 0 / 0 / 1 |
| `ADDON_EXTENSION` | 1 | TARGET_ADDON (`survival.pickup_reward_progress`, preset behaviour, not a stock owner) | 1 / 0 / 0 |

By `applies`: `next_mission` 17, `restart` 9, `F9` 4, `immediate` 1.

The new rows are:
- `void_cascade.alert_reward_interval`;
- `coh_destroy_targets.num_targets`;
- `cohinterception.beacon_chase_time`;
- `cohinterception.is_descent`;
- `defense.marker_threshold`;
- `faceoff.cd_burn`;
- `netracell.quest_power_multiplier`;
- `void_flood.is_duviri_flag`;
- `server.credit_boost_multiplier`.

The boolean mode switches (`is_descent`, `is_duviri_flag`, `cd_burn`) are admitted because they have a proven consumer
and a metadata back end. Changing them selects a different stock branch; treat them as expert controls.

**Excluded, by owner kind and reason** (the exact reason is stored per row in `excluded`)

| Owner kind | Excluded | Reasons (count) |
|---|---:|---|
| `LUA_PROTO_LITERAL` | 117 | Phase 1 PARTIAL/UNCONFIRMED (30); no field-anchored owner in the owner text (72); module not uniquely resolvable (12); stock value is not a whole number that `LOADN` can hold (2); 2 identical anchor sites (1, `survival.duviri_fixed_length`) |
| `LUA_ROOT_TABLE` | 110 | PARTIAL/UNCONFIRMED (40); no field anchor (52); module not resolvable (7); the value sits in a `DUPTABLE` template constant and no constant-exclusivity gate exists yet (6); float/table/formula value (5) |
| `METADATA_PARAM` | 55 | PARTIAL/UNCONFIRMED (23); owner type not named (15; refers to sibling or "both" triggers); compound row (5); no field named (5); field in several `Scripts` entries (4); spans two trigger types (2); negative index value (1) |
| `MISSIONINFO` | 21 | no MissionInfo producer back end (only the ConquestLib literals are registered) |
| `NATIVE_OR_UNKNOWN` | 23 | owner not established |
| `SERVER` | 11 | server code rather than a `config.json` key (8); compound key (1); list-valued (1); per-account database tuning (1) |

`coh_excavation.shared_constant_90` is not counted as excluded. It is merged as the second site of
`coh_excavation.dig_duration`, the same control.

## Gate results (offline)

| Gate | Denominator | Result |
|---|---|---|
| Stock extraction vs live cache | 311 modules | 311 identical |
| `verify-missions` (structure + every row vs 44.0.2 evidence) | 31 rows | 31 PASS / 0 FAIL: EXACT_LITERAL 17, METADATA_PATCH 9, TARGET_ADDON 4, SERVER_CONFIG 1 |
| C++ build (`-Wall -Wextra -Wpedantic -Werror`) | 3 targets + tests | 0 warnings, 0 errors |
| CTest | 2 tests | 2/2 PASS |
| C++ self-test (existing + 16 new mission checks) | 110 checks | 110 PASS |
| Managed Dev tests (existing + new registry checks) | 162 checks | 162 PASS |
| WPF App / Dev build (`--no-incremental` for the App) | 2 projects | 0 warnings, 0 errors |
| Preset builds through the registry path (all gates) | 12 presets | 12 PASS; rejections 36/36 (wrong body, superseded build, out of range) |
| Preset output equivalence vs previous path (same values, unchanged bodies) | 11 presets | 11 byte-identical |
| Sample `mission_settings.json` group build | 9 tunables, 4 bodies + metadata + server | 5 artifacts + 1 unapplied server diff, one artifact per body key |

The new self-test checks cover:
- registry verification;
- the 44.0.2 build label;
- the two-literals-in-one-module merge (Excavation: exactly 2 bytes changed; Void Cascade carried-over plus new row:
  3 operands);
- ConquestLib re-registration (offsets +61) and its build;
- a mixed set (replacement + addon + metadata + server diff);
- fail-closed cases: unknown build, unknown ID, out-of-range values, non-whole operands, stock SHA-256 mismatch,
  preimage mismatch, a competing replacement and addon on one body, and overlapping registry sites;
- the preset path, including its established artifact name and the rejection of the superseded build label.

Reproduce:
- `python RESEARCH/UNIVERSAL_MISSION_REGISTRY_2026-09-29/tools/register_registry.py`
- `renovice_ability_editor_cli verify-missions`
- `ctest`
- `dotnet run --project editor/Dev`
- `python RESEARCH/UNIVERSAL_MISSION_REGISTRY_2026-09-29/tools/test_presets_and_sample.py`, which writes
  `test-results/results.json`, stages to `work/staging/aer44`, and writes the sample to the research folder.

## Sample output set

Location: `work/research/universal-mission-editor-2026-09-29/phase2b-sample/` (the research folder, not the game).
Settings: netracell 2, shrine offering 15 s, Mobile Defense 90/120 s, Survival reward interval 150 s, credit boost
2×, Excavation standard 50 s + Elite Alert 70 s (two literal rows in one module), ETA Survival 5 min.

| Artifact | Tunables | SHA-256 |
|---|---|---|
| `076a7b443af7fdb8 (missions_exact-replacement).lua_B` | archimedea.eta_survival_minutes | `2832158E3B243C4F508AD882ED69A9339FE7F062DF76A709CBE90C58E5522D9D` |
| `a807aae359ffc1eb (missions_exact-replacement).lua_B` | mobiledefense.total_time.minimum/.maximum | `9DC9D6FB76B9FEDC7BD7F057FCD75D77E98AE5A63CCEFF71803F1DD502DAD368` |
| `f7444e3c621ff018 (missions_exact-replacement).lua_B` | excavation.dig_duration, excavation.dig_duration_elite_alert | `D2A8537B7EA0259D4ECE33F7A5C456F7E7E643CAB4CC0FCF6B0027926128B0BA` |
| `f10a043e7f825db2.missions.target.addon.lua_B` | survival.reward_interval | `5B2AAE27A4EFADAB03C40D5EC16293B97D0F42CD7A3361F0F3A20D284ECB0202` |
| `RENOVICE_Missions.txt` | netracell.enemy_power_fill, shrine.offering_generation_time | `F6FDB56BA18466485CF7669A90C048DC676CA8A59A8574D010DF128F1AC571B8` |
| `server-config-diff.json` (`applied: false`) | server.credit_boost_multiplier | `2C3063AA4BCD1D1ADD8F5D3E9105F8DB9F32A121B7F13EE425F600151D75B88C` |

`SHA256SUMS.json` in the sample folder lists every file. The build is deterministic: rerunning it reproduced the same
hashes.

## Limitations

- **Offline evidence only.** This does not prove live behaviour, multiplayer authority, host migration or server
  reward coupling. Offline gates do not prove in-game behaviour.
- **Coverage is narrow on purpose.** The 31 rows are mostly the 12 presets. Broader coverage needs:
  - per-row anchors for prose-only literal rows;
  - a constant-exclusivity gate, so that `DUPTABLE` template constants can be edited with the existing
    `number_constant` kind;
  - per-field or per-owner-type splits of compound Phase 1 rows;
  - a MissionInfo producer back end.
- **Target addons use only the two existing templates** (Survival, Interception). No generic root-table addon
  generator was added, because no new root-table row has a proven hook prototype and pre-consumer dispatch order.
  When Survival (`f10a…`) gets both literal rows and addon rows, the build fails closed rather than composing a
  replacement and an addon.
- **Metadata limits are numeric guards only** (`limits.basis`). Gameplay-safe ranges were not established. Mode-switch
  booleans change stock branches.
- **The server row** is verified against `OpenWF Server 23.09.2026` source hashes. A changed server source disables
  that row with an exact reason. The diff must be reviewed and applied by the user.
- **Paths.** Windows MAX_PATH applies to staging paths: deep staging roots fail with `Unable to write`. Use a short
  staging root.

## Phase 2c (live verification) — needed from the user

1. Authorization to deploy one concrete generated set (for example the sample files) to the Warframe install, using
   the existing rollback/export path. Nothing has been deployed.
2. In-game checks for two unrelated targets per back end:
   - Survival reward interval (addon, F9) and Excavation standard/Elite durations (replacement, new mission);
   - Netracell power and HellDefense `_markerThreshold` or Descendia shrine (metadata, after restart);
   - ETA Survival on a freshly generated Archimedea chain;
   - one adjacent stock behaviour per target, and the current EE.log checked for new script errors.
3. For the server row: explicit approval to apply `worldState.creditBoostMultiplier` to `config.json` (or not).

Superseded: the build-`2026.09.24.13.29` schema-1 registry (kept in git history as `01c9651`) and its hard-coded
build checks in `mission_profiles.inl` / `MissionBuildProfile.cs`.
