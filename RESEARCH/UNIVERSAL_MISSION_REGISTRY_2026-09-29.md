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

## Phase 2d — exact owners for Phase 1 rows (2026-09-29)

**Build.** Client `2026.09.28.13.06` (Hotfix 44.0.2) only. **Scope.** Offline only; nothing was written to a game folder,
deployed, or applied to the server. Registry SHA-256 `BAAFA6FC…0A792AA` (`REGISTRIES/mission_build_u44.json`).

### Hypotheses and results

| # | Hypothesis | Result |
|---|---|---|
| H7 | A root config table value held in a `DUPTABLE` template constant can be edited exactly when a gate proves the constant and the template have a single owner. | **TRUE, with a new gate.** `K_CONSTANT_EXCLUSIVE_V1` (`tools/anchors.py`) requires: the value constant is used by exactly one entry of one tag-8 template and by no instruction or other constant; the template is consumed by exactly one `DUPTABLE`; that `DUPTABLE` is outside any loop; and the constructing prototype does not overwrite the field before the register is reassigned. Corpus census over all 311 extracted modules: **1953** numeric template fields, **766 PASS**, 1187 FAIL (1118 value constant shared, 39 built inside a loop, 30 template used by several `DUPTABLE` sites, 0 dead initialisers). |
| H8 | Most Phase 1 prose owners can be pinned to exact bytecode sites. | **PARTIALLY TRUE.** 406 new Lua rows and 53 new metadata rows resolve and verify. Shared constants are the main blocker (35 Phase 1 rows or parts). |
| H9 | Phase 1 `Scripts.N` metadata paths match the runtime patcher. | **FALSE for N>0.** `trigger_params.py` counts list separators as elements, so its `Scripts.2` is runtime `Scripts.1`: in the bootstrapper `EeNotationParser`, `,` only ends a value. Only `Scripts.0` rows were registered before, so no earlier row was wrong. The registrar now parses entries with the runtime rule and refuses Phase 1 paths with N>0. The managed test independently resolves every path, `Scripts.1` included, with the metadata editor's query extractor. |
| H10 | Survival `interval` (300) is safe to edit as a constant. | **FALSE.** Its constant is shared with `killPlayerTime`. It stays on the live-proven target-addon lane. |

### What was built

**Gate and resolver (tools)**
- `anchors.py` provides:
  - constant offsets;
  - a complete per-prototype constant-use census, covering every K operand, template key/value and import descriptor
    (unclassified operands count as possible uses and fail closed);
  - loop detection;
  - the gate itself.
- `phase2d.py` defines three declarative owner kinds:
  - `pattern` matches every `LOADN v` whose neighbouring instruction signatures match, and requires an exact `count`, so a
    row owns the complete set of sites of one control;
  - `template` applies the single-use template gate;
  - `constant` requires the declared instruction-use set to equal the complete use set.
- `phase2d_lua_specs.py` holds 406 rows and 70 exclusions; `phase2d_metadata_specs.py` holds 53 rows and 8 exclusions. The Lua
  specs came from four per-family anchor passes and were merged. `register_registry.py` re-resolves and re-gates every spec
  on each run.
- `register_registry.py` also:
  - attaches the gate evidence to every `number_constant` site, including the carried-over Descendia 45 constant (3 `SUBRK`
    and 1 `DIVK` uses);
  - flags carried-over linked-result sites with `rewrites_instruction`;
  - writes `excluded_parts` for split Phase 1 rows.

**C++ core (`src/mission_profiles.inl`)**
- A `number_constant` site must carry `K_CONSTANT_EXCLUSIVE_V1` evidence consistent with the site. A template use needs exactly
  one template entry, one `DUPTABLE`, `loop_free` and `initialiser_live`.
- Every LOADN and constant site must decode to the registered stock value.
- Constant sites accept any finite f64 value within the row limits. LOADN sites keep the whole-number 1..32767 rule.
- Metadata rows may list `also` entries: the same parameter in another runtime `Scripts` entry. All entries are verified and
  always written together.
- Two rows may not own the same metadata path.

The desktop contract is unchanged.

### Rows (client 44.0.2)

Registry: **490 rows** (31 before Phase 2d + 459 new). By backend: `EXACT_LITERAL` 423, `METADATA_PATCH` 62,
`TARGET_ADDON` 4, `SERVER_CONFIG` 1.

Of the 459 new rows, 456 are `CONFIRMED_STATIC`. The other 3 are `CONFIRMED_STATIC_PHASE2D`: they were re-derived from
bytecode where Phase 1 was PARTIAL or MISSIONINFO. They are Disruption default rounds, Disruption sortie rounds and the
Excavation default resource goal.

**New rows by owner kind**

| Owner kind | New rows | Exact sites |
|---|---:|---|
| `LUA_ROOT_TABLE` | 286 | Root/config table initialisers: LOADN before SETTABLEKS/SETLIST, and single-use template f64 constants. Player-count arrays get one row per element. |
| `LUA_PROTO_LITERAL` | 120 | LOADN literals and exclusive instruction-used constants |
| `METADATA_PARAM` | 53 | Per-owner-type and per-field splits; 5 rows patch two runtime `Scripts` entries |

Sites: 411 LOADN and 123 number constants. Gates passed: 311 complete patterns, 54 single-use templates, 69 exclusive
constants.

37 rows own more than one site, and each is always patched as a unit. Examples:
- the four Defense wave-count literals, with 15 inlined copies each;
- the Arbitration cap 25 (10 sites);
- the Steel Path acolyte cooldown (8 sites);
- Disruption default rounds (7 sites: 4 `fixedLength` fallbacks and 3 `Ternary(maxWaveNum>0, maxWaveNum, 4)`);
- the Excavation default goal 500 (3 sites);
- Descendia excavation 45: 1 constant with 4 uses plus 1 LOADN (carried over, now gated).

**New rows by mode (priority modes first)**

| Mode | Rows | Mode | Rows |
|---|---:|---|---:|
| Survival | 11 | Descendia: Shrine Defense | 54 (49 Lua + 5 metadata) |
| Orphix Venom | 3 | Descendia: Excavation | 6 (1 Lua + 5 metadata) |
| Void Cascade | 4 | Descendia: Legacyte Harvest / Meltdown / Alchemy / Defense / Destroy Targets / Nemesis | 7 / 7 / 3 / 3 / 4 / 2 |
| Void Flood | 3 | Legacyte Harvest (1999) | 7 |
| Defense | 45 | Alchemy (Entrati lab) / Meltdown (lab) | 3 / 7 |
| Mirror Defense | 50 | Ascension | 6 |
| Mobile Defense / Sentient MD / MultiDefend / 1999 Defense tile | 14 / 6 / 9 / 4 | Entrati Swarm | 19 |
| Interception | 4 | Infested Salvage | 12 |
| Disruption | 51 | Hijack | 2 |
| Excavation | 2 | Netracell | 3 |

Other families add 109 rows:
- Faceoff 18
- Defection 16
- Purge 11
- Raid 11
- Exterminate/Escalation 10
- Capture 8
- Five Fates 7
- Archimedea levels 6
- All-missions acolyte/drone 5
- Rescue 4
- The Circuit 4
- Colonist door 3
- Arbitration, Spy, Archwing, Pursuit and Sentient capture, 1 each

Lantern and Purgatory have **no Phase 1 row** in `mission_tunables.json`, so nothing was registered for them. They need a
Phase 1 study first.

### Phase 1 accounting (denominator 367)

| Status | Rows |
|---|---:|
| Registered fully | 152 |
| Registered partially (other parts listed in `excluded_parts`, 34 parts) | 32 |
| Excluded | 183 |

**Excluded rows by reason**

| Reason | Rows |
|---|---:|
| Phase 1 PARTIAL | 85 |
| Phase 1 UNCONFIRMED | 7 |
| Native or unknown owner | 24 |
| MissionInfo (no producer back end) | 20 |
| Shared constant or template (gate FAIL) | 12 |
| Flag, selector or index | 9 |
| Server code or compound | 9 |
| Transmission or HUD only | 5 |
| Other semantic reasons (coupled to level data or equipment, or meaning differs from Phase 1) | 5 |
| Debug only | 2 |
| Derived | 2 |
| List value | 2 |
| Other | 1 |

**Excluded parts by reason**

| Reason | Parts |
|---|---:|
| Shared constant or template | 23 |
| Coupled, dual-unit, marker or reset values | 6 |
| Formula | 2 |
| Derived | 1 |
| Transmission | 1 |
| Index | 1 |

Every entry carries its exact reason. These notable exclusions are all shared constants, so editing them would change
unrelated fields:
- Survival `alertInterval`, `maxTimeAvailable`, Kuva 600/600, and the alert/sortie level boosts;
- Orphix `interval` 3 and 50, and `scoreAddPerRound`;
- Void Flood `curseCountNormal`/`SteelPath`, `maxFractureActive`, `playerCapacity` and `timeToFillMin`.

### Gate results (offline)

| Gate | Denominator | Result |
|---|---|---|
| `verify-missions` (structure + every row vs 44.0.2 stock evidence) | 490 rows | 490 PASS / 0 FAIL: EXACT_LITERAL 423, METADATA_PATCH 62, TARGET_ADDON 4, SERVER_CONFIG 1 |
| Template gate corpus census | 1953 numeric template fields in 311 modules | 766 PASS / 1187 FAIL (reasons above) |
| Phase 2d gate cases (`tools/test_phase2d_gates.py`) | 7 cases | 7 PASS |
| C++ build (`-Werror`) | core + GUI + CLI + tests | 0 warnings, 0 errors |
| CTest | 2 tests | 2/2 PASS |
| C++ self-test | 115 checks (110 + 5 new) | 115 PASS |
| Managed Dev tests | 162 checks | 162 PASS |
| WPF App / Dev build (`--no-incremental`) | 2 projects | 0 warnings, 0 errors |
| Preset builds through the registry path | 12 presets, 36 rejections | 12 PASS; all 12 artifacts byte-identical to the Phase 2b results |
| Phase 2b sample | 5 artifacts | Byte-identical to the Phase 2b hashes |

The 7 gate cases are:
- template PASS (Survival `lowDropMultiplier`);
- rejection of a shared value;
- rejection of a template built in a loop;
- rejection of a template used by two `DUPTABLE` sites;
- rejection of an incomplete pattern;
- rejection of a constant declared with only a subset of its uses;
- constant PASS with the full use set.

The 5 new self-test checks are:
- a multi-site row (Disruption default rounds) patches all 7 sites and nothing else;
- one drifted site fails the whole row, and no artifact is written (no partial coverage);
- a template field builds with only its 8-byte f64 changed (2.25);
- the template gate rejects a second `DUPTABLE`, a shared value, a loop, and missing evidence;
- a multi-entry metadata control writes `Scripts.0` and `Scripts.1`.

The managed metadata check now resolves every `also` path as well.

### Phase 2d sample output

Location: `work/research/universal-mission-editor-2026-09-29/phase2d-sample/` (research folder). `SHA256SUMS.json` there
lists every file.

Settings: 13 tunables, producing 8 exact replacements and 1 metadata file.

| Artifact body | Tunables | SHA-256 |
|---|---|---|
| `b6d8c45f9424d376` (Disruption) | default_round_count 6, boss_health_multiplier 0.5, round_timeout 120 | `BE99A12B…04AB56` |
| `f7444e3c621ff018` (Excavation) | resource_goal_default 300 | `B9F98E43…AEE8D6A` |
| `fc711ff621a75552` (Void Flood) | fill_timer.timeToFillMax 150 | `D8F3C4E7…DAF4330` |
| `721710696afea305` (Orphix) | sortie_rounds 8 | `8F536A41…F8ED0D18` |
| `fb346b59e2b7687a` (Hijack) | payload_health 20000 | `6D7C70D4…F2F2273` |
| `0c498e078835f9fe` (Netracell) | power_required.base 100 | `8D0EDA35…45DCC564` |
| `f10a043e7f825db2` (Survival) | elite_alert_pickup_mult 1 | `DE20BA0C…2299FB9D2` |
| `1a1354d153712f9d` (Defense) | inter_wave_sleep 3 | `BFE46442…3B488782` |
| `RENOVICE_Missions.txt` | coh_excavation.base_health 3000 (2 entries), infested_capture.search_time.wf1999 50, meltdown.heat_increase.descendia 0.0125 | `7EE0AD90…AFD6566F` |

### Limitations

- **Offline evidence only.** In-game behaviour, multiplayer authority and host migration are not claimed.
- **Survival body `f10a…` is also the target-addon body.** A settings file that mixes Survival literal rows with the
  Survival addon rows fails closed, because a body may own only one artifact.
- **Limits are operand-domain guards, not gameplay-safe ranges.** Constant rows accept any finite value in
  `[0, max(1000, 100 × stock)]`.
- **Per-element array rows follow the stock index semantics.** Two Phase 1 corrections came out of the anchor passes:
  - the Entrati Swarm index is the stage/area counter;
  - the Shrine Steel Path `OverallStateTime` is never read.
- **Gaps the current tools cannot handle yet:**
  - a group owner for shared templates (Five Fates 3600/180);
  - a per-site scale (the acolyte chance increment is stored as 5/100 in one site and 0.05 in another);
  - a table-path anchor for nested tables (Interception spawn profiles);
  - a constant-split primitive for shared constants. It would append a new constant and redirect one template entry, which
    changes the body size, so it needs Replacement-lane evidence first.

### Suggested live checks (need explicit user authorization to deploy)

Two targets per mechanism:

| Mechanism | Tunable | Change | Where to observe |
|---|---|---|---|
| LOADN literal | `loopdefend.phase_duration` (2 sites) | 150 → 75 | Mirror Defense phase timer |
| LOADN literal | `defense.inter_wave_sleep` | 6 → 3 | Pause between Defense waves |
| Template f64 | `void_flood.fill_timer.timeToFillMax` | 200 → 100 | Void Flood tank fill time |
| Template f64 | `disruption.boss_health_multiplier` | 0.7 → 0.35 | Demolyst health |
| Instruction constant | `circuit.enemy_level_formula.base_normal` | 30 → 60 | Normal Circuit enemy level |
| Instruction constant | `survival.elite_alert_pickup_mult` | 0.75 → 1 | Arbitration Survival life support per pickup |
| Metadata split | `coh_excavation.base_health` | 1500 → 3000 | Descendia excavator health; gameplay and HUD entries |
| Metadata split | `infested_capture.search_time.wf1999` | 100 → 50 | 1999 Legacyte Harvest search duration |

Check the current EE.log for new script errors after each test.

## Phase 2e — root-table fields on the target-addon lane (2026-09-29)

**Build.** Client `2026.09.28.13.06` (Hotfix 44.0.2) only. **Scope.** Offline only; nothing was written to a game folder,
deployed, or applied to the server. Registry SHA-256 `EEFF2087…25B0AFA` (`REGISTRIES/mission_build_u44.json`).

### Problem

Phase 2d excluded root-table fields whose value constant is shared (1,118 of 1,953 template fields in the census; for
example Survival `interval` = 300 shares its constant with `killPlayerTime` = 300). Byte patching cannot separate them.
The Survival preset never needed a byte patch: its target addon writes the live table field once
(`luaCalls[67].before`, prototype + upvalue + field name), checks the stock value first and restores it in cleanup.

### Hypotheses and results

| # | Hypothesis | Result |
|---|---|---|
| H11 | A root config table field can be owned by the target-addon lane per field name, independent of constant sharing. | **TRUE (offline).** Gate `ROOT_TABLE_UPVALUE_V1` (`tools/addon_owner.py`) proves the owner on the 44.0.2 bytes. Survival `interval` (table `root:i19:R9`, hooks include the live-proven `67:70`) and `killPlayerTime` (table `root:i70:R14`) are different tables; each build writes only its own field. |
| H12 | Most Phase 2d `LUA_ROOT_TABLE` rows pass the addon gate. | **PARTIALLY TRUE.** 217 of 321 literal root-table rows pass and are routed to the addon lane; they keep their exact literal form as `literal_owner`. 104 stay literal-only, each with the exact `addon_gate` reason (see below). |
| H13 | A module needing both root-table and literal edits can be built as one artifact without a new runtime mechanism. | **TRUE for rows that have both forms.** Option (b) chosen: one merged exact replacement using the literal form of each root-table row. Option (a) (`nativeCalls[method].before` argument transforms) was rejected: mission literals are mostly `LOADN` operands of stores and arithmetic, not native call arguments, and `PushFloatArg` is reserved by the adapter. |
| H14 | Lantern and Purgatory values can be registered on 44.0.2. | **TRUE.** Both decompiled sources were already in `decomp/`; every value was re-derived from the stock bytes (19 Lantern rows, 24 Purgatory rows). |

### Gate `ROOT_TABLE_UPVALUE_V1` (all conditions on the pinned stock bytes)

1. The module root builds the table exactly once, outside any loop: `DUPTABLE` of a template whose field entry is the
   stock number, `NEWTABLE` + one `SETTABLEKS field` from `LOADN`/`LOADK`, or `NEWTABLE` + `SETLIST` for an array element.
   The root never writes the field again and never reads it (a root read happens at module load, before any hook).
2. The table leaves the root only by closure capture (`CAPTURE VAL/REF`), or by one store into a root container table
   (nested path, for example Purgatory `difficulty[2].ghostLevel`, Lantern `numEnemies[3]`). A `REF` capture also
   requires that the root never reassigns the register.
3. Every capturing prototype is created exactly once, by the root, and **all** of them are hooked (`before`), so no code
   that can reach the table runs before the write. No capturer or nested re-capture replaces the upvalue (`SETUPVAL`).
4. At least one capturer (or nested re-capture) reads the field (or, for a container path, the container key).

The registry stores each table once per module (`modules[body].root_tables[table_id]`: construction, containers,
hooks with upvalue index and path). Each row lists its `fields` with the stock initialiser offset and bytes;
`verify-missions` re-checks that those bytes encode the registered stock value and that the table record is complete.

### Generator

- **Generic root-table addon** (`root_table_addon_source`, template `ROOT_TABLE_FIELD`): one addon per body key. Each
  table is bound when a hooked capturer is first called: stock values asserted once, requested fields written once,
  cleanup restores each field that still holds the written value. A table whose stock drifted is left unchanged (the
  callback error is logged, stock execution continues). No polling, no per-frame writes, no C++ mission branch.
- **Lane per body key:** all requested rows addon-capable → one addon; otherwise all rows have an exact literal form →
  **one merged exact replacement** (root-table rows use `literal_owner`); otherwise fail closed with
  `Body key … would need both an exact replacement (literal-only: …) and a target addon (addon-only: …)`.
- **Presets keep their lane and bytes:** `void_cascade.pillar_duration` serves the EXACT_LITERAL preset through
  `literal_owner`; the Survival/Interception presets still use their established templates. The Survival template is
  also used for settings that contain only template-only rows (`survival.pickup_reward_progress`); combining that
  row with generic root-table rows fails closed with its exact reason.

### Rows (client 44.0.2)

Registry: **594 rows** (490 + 104 new). Excluded Phase 1 rows 169 (was 183); Phase 1 denominator 387 (367 + 20 rows
added to `mission_tunables.json` by `tools/add_phase1_rows.py`: Lantern 11, Purgatory 8, `void_flood.fractures_per_round`).
Phase 1 accounting: 195 registered fully, 23 partially (24 excluded parts), 169 excluded.

| Owner kind | Rows | Backend |
|---|---:|---|
| `LUA_ROOT_TABLE` | 391 | 287 TARGET_ADDON (217 with `literal_owner`, 68 addon-only, 2 Survival template rows) + 104 EXACT_LITERAL |
| `LUA_PROTO_LITERAL` | 138 | EXACT_LITERAL |
| `METADATA_PARAM` | 63 | 62 METADATA_PATCH + 1 TARGET_ADDON (Interception template) |
| `SERVER` | 1 | SERVER_CONFIG |
| `ADDON_EXTENSION` | 1 | TARGET_ADDON (Survival template only) |

By backend: TARGET_ADDON 289, EXACT_LITERAL 242, METADATA_PATCH 62, SERVER_CONFIG 1. Root tables: 83 in 23 modules,
269 hooked prototypes in total (1 to 24 per table).

New rows (104): 68 addon-only root-table fields (shared constants or non-unique literal owners), 20 new literal rows
that also passed the addon gate, 16 new literal-only rows.

**Priority modes (total rows; before Phase 2e in brackets)**

| Mode | Rows | Addon | Literal | Notes |
|---|---:|---:|---:|---|
| Survival | 30 (13) | 28 | 2 | reward/alert interval, capsule initial/max/added/interval/incoming, pickup LS, drop multipliers (low/high threshold+mult, alert, Duviri ×2, 1999 ×2), level/enrage (incl. Kuva, alert/sortie boosts), `killPlayerTime`, `playerDamagePercent` |
| Orphix Venom | 7 (3) | 6 | 1 | reward interval 3, Orphix interval 50, `condrixCap`, `eventInterval`, `scoreAddPerRound`, railjack max rounds |
| Void Flood | 11 (4) | 7 | 3 (+1 metadata) | fractures per round: normal 3 (root local, literal), Duviri 5 (2 assignment sites, literal), Shadowgrapher `maxFractureActive` 3 (addon); curses normal/Steel Path, `playerCapacity`, `timeToFillMin/Max`, `curveScaleV` |
| Void Cascade | 6 (6) | 6 | 0 | all dual (addon + `literal_owner`); preset unchanged |
| Lantern | 19 (0) | 14 | 5 | min score 300 (2 sites), extraction 180 (2 sites), boss 900, min/max lamp radius 7/32 (all sites) literal; tier-up 90, max tier 5, `numEnemies` ×4, radius per kill ×4, lamp decay b/v/m/p addon (all dual) |
| Purgatory | 24 (0) | 15 | 9 | initial time 60, +5 s per pickup, drop chance 0.1, initial pickups 5, enemy cap 10, spawn batch Range(2,4), spawn interval Range(3,5) literal; difficulty warrior/ghost/damage ×3 (nested, addon-only), kill thresholds 25..150 (dual) |

Other families gaining rows: Mirror Defense 57 (50), Faceoff 38 (19), Five Fates 14 (7). All other modes keep
their row counts; their root-table rows that pass the gate are now routed to the addon lane.

**Root-table rows that stay literal-only (104, reason stored per row in `addon_gate`)**

| Reason | Rows |
|---|---:|
| no capturer reads the element/field directly (array passed to a helper; consumer not proven) | 57 |
| root local or call argument, not a table field (incl. ConquestLib `waveOverrides`, `Range(...)` arguments, Void Flood fractures per round) | 30 |
| captured table replaced by `SETUPVAL` (Disruption variant tables) | 11 |
| library table leaves the module other than by capture (ConquestLib enemy levels) | 6 |

Still excluded: Disruption shared-constant variant tables (same `SETUPVAL` reason, appended to the exclusion),
ConquestLib enemy levels (library), Sentient capture swarm (table built in prototype 15, not the root), Survival
`alertPlayerDamagePercent`, `playerDamageCurve`, `playerDamageMult` (no proven consumer read).

Lantern lamp radius note: every 7 and every 32 in the module is owned (clamps, expiry checks, HUD normalisation). The
light-intensity lerps divide by 25 (= 32 − 7) and 9; those divisors are not owned and stay stock (visual only).

### Gate results (offline)

| Gate | Denominator | Result |
|---|---|---|
| `verify-missions` (structure + every row vs 44.0.2 stock evidence) | 594 rows | 594 PASS / 0 FAIL: TARGET_ADDON 289, EXACT_LITERAL 242, METADATA_PATCH 62, SERVER_CONFIG 1 |
| Phase 2e gate cases (`tools/test_phase2e_gates.py`) | 7 cases | 7 PASS |
| Phase 2d gate cases + template census | 7 cases, 1953 fields | 7 PASS; census unchanged (766 / 1187) |
| C++ build (`-Werror`) | core + GUI + CLI + tests | 0 warnings, 0 errors |
| CTest | 2 tests | 2/2 PASS |
| C++ self-test | 121 checks | 121 PASS |
| Managed Dev tests | 162 checks | 162 PASS |
| WPF App / Dev build (`--no-incremental`) | 2 projects | 0 warnings, 0 errors |
| Preset builds | 12 presets, 36 rejections | 12 PASS, all byte-identical to the previous run |
| Phase 2b sample rebuilt (folder untouched) | 5 artifacts | 4 identical; Survival addon changed by design (generic generator: writes `interval` only) |
| Phase 2d sample rebuilt (folder untouched) | 9 artifacts | 8 identical; Void Flood `timeToFillMax` now builds as an addon instead of a replacement |

New self-test checks (items 1–3):
- shared-constant fields are independent addon controls (`interval` 150 leaves `killPlayerTime` unchanged, and the reverse);
- the addon gate evidence rejects a drifted initialiser, a table without hooks, missing gate evidence and an unread field;
- **one root-table row + one literal row in one module → one merged replacement** (`lowDropMultiplier` 2.25 and
  `elite_alert_pickup_mult` 1: only the two f64 constants change);
- an addon-only row plus a literal-only row of one module fail closed and name both rows;
- root-table rows of one body build one generic addon (Void Cascade `PILLAR_DURATION`, `PILLAR_DURATION_CIRCLE`, `ALERT_REWARD_INTERVAL`);
- the Duviri fracture count builds as one replacement with exactly its two sites changed;
- Shadowgrapher `maxFractureActive` plus a curse count build as one addon;
- a nested table (Purgatory difficulty 2) is reached through its container path.

Reproduce: `tools/add_phase1_rows.py` (idempotent), `tools/register_registry.py`, `renovice_ability_editor_cli verify-missions`,
`tools/test_phase2e_gates.py`, `ctest`, `dotnet run --project editor/Dev`, `tools/test_presets_and_sample.py`.

### Phase 2e sample output

Location: `work/research/universal-mission-editor-2026-09-29/phase2e-sample/` (research folder). `SHA256SUMS.json`
(SHA-256 `2AFE7737…26228103`) lists every file. The build is deterministic (a trial build produced the same artifact hashes).

| Artifact body | Tunable | Lane | SHA-256 |
|---|---|---|---|
| `f10a043e7f825db2` (Survival) | `survival.reward_interval` 300 → 150 (`killPlayerTime` untouched) | addon | `CEF8808F993059F44C3E55CDE72038C5271260A7BFB803FB8B47C6132CE9DA6A` |
| `fc711ff621a75552` (Void Flood) | `void_flood.fractures_per_round.normal` 3 → 4 | replacement | `E979F5E7906F0D88E49C42B4191ECA6AFDC1237FDDD91D52CBF427DB3FA9F6D2` |
| `caec63d8e739b693` (Lantern) | `lantern.tier_up_interval` 90 → 60 | addon | `228754AF891C5A9A75DA250EF171A0689323E6E439CDFD28EC054D6B7334358C` |
| `6fa60841c9e0f207` (Purgatory) | `purgatory.difficulty1.warrior_level` 10 → 15 | addon (nested path `[1]`) | `043176ECDEECF9A876108D87BEB72EB4A7BD7CAA3A799ECD849FAD4E0EEA8472` |

### Limitations

- **Offline evidence only.** No live claim. The generic addon relies on the proven `luaCalls[P].before` contract and
  on at least one hooked capturer being entered by a Lua `CALL` before the field is first read. A capturer invoked only
  natively (engine callback) is not hooked by the runtime; the gate cannot prove call order statically.
- A mixed body still fails closed when a requested root-table row has no literal form (shared constant) and another
  requested row is literal-only (for example `survival.alert_interval` + `survival.elite_alert_pickup_mult`). Removing
  that needs either an addon mechanism for function literals or a constant-split replacement primitive.
- Variant code that overwrites a field before the first hook (for example Survival fast mode `pickupTimeAdded = 4`)
  makes the stock check fail for that table; the addon then leaves it unchanged by design.
- Limits of new addon rows are numeric guards only (`[0 or min(1, stock), max(1000, 100 × stock)]`).
- Hot prototypes are hooked (up to 24 per table for Void Cascade); the callback returns immediately after binding.

### Suggested live checks (need explicit user authorization to deploy)

| Mechanism | Tunable | Change | Observe |
|---|---|---|---|
| Generic addon, shared constant | `survival.reward_interval` | 300 → 150 | reward every 2.5 min; zero-LS kill timer still 300 s |
| Generic addon, nested path | `purgatory.difficulty1.warrior_level` | 10 → 15 | Purgatory difficulty 1 warrior level |
| Merged replacement (root-table + literal) | `survival.pickup_drop_low_high_mult.lowDropMultiplier` + `survival.elite_alert_pickup_mult` | 1.5 → 2.25, 0.75 → 1 | LS drops at low life support; Arbitration pickup value |
| Literal | `void_flood.fractures_per_round.normal` | 3 → 4 | fractures per round (normal Void Flood) |

Check the current EE.log for new script errors after each test.

## Phase 2f — live failure of the Phase 2e Survival addon: root cause and generator fix (2026-09-29)

**Build.** Client `2026.09.28.13.06` (Hotfix 44.0.2). Installed runtime `wtsapi32.dll` SHA-256 `15DAF981…3CEA`
(bootstrapper `bcad39e`, V110 luaCalls boundary). Registry unchanged: SHA-256 `EEFF2087…25B0AFA`.
**Scope.** Offline analysis of the stock bytes, decompiled source, runtime source and the user's logs (read only).
Nothing was written to a game folder, and the bootstrapper was not changed.

### Live symptom

The user installed the Phase 2e sample (`f10a043e7f825db2.missions.target.addon.lua_B`, SHA-256 `CEF8808F…`,
`survival.reward_interval` 300 → 150) and ran a Kuva Survival (`SolNode744_Hard`). No reward came at 2:30.

- `renovice_source.log` (session from line 63055; `Logging=true`, diagnostics off): `target module identity PASS
  key=f10a043e7f825db2 env=000001E4BD62DA60`, `native hook PASS … event=target-environment-dispatcher.install`,
  `Inject PASS …missions.target.addon.lua_B`, `TARGET ADDON PASS key=f10a043e7f825db2 addons=1`. After that there is
  no `luaCalls` line of any kind for this key.
- `EE.log`: `Survival: State Change: ENDLESS` at 127.17 s. The log ends at 328.0 s, about 201 s of survival.
  There is no `Survival: Session locked` and no `Survival: Host - first reward` line. With `interval = 150` both
  would print at about 277 s (prototype 31, reward 1).

### Hypotheses and results

| # | Hypothesis | Result |
|---|---|---|
| H15 | `interval` on `root:i19:R9` is what times the Survival reward rotation on 44.0.2. | **TRUE (static).** Host tick prototype 67 advances the elapsed reward clock (root R119, `REF` capture) by `dt`. It then calls prototype 33 (`cap_79_717_47`). Prototype 33 computes `floor(elapsed / rewardTable.interval)` and calls prototype 31 once for each new reward. Prototype 31 locks the session, calls `OnTieredRewardRoundOver` and prints `Survival: Host reward N`. The field is read live on every tick (prototypes 31, 33, 55, 58, 67, 69). It is not cached in another local, upvalue or native timer. Reward *contents* come from the mission deck, but *timing* is Lua on the host. |
| H16 | A hooked capturer is entered by a Lua `CALL` before the first read of `interval`. | **TRUE (static).** The global `Mission` is prototype 70. It is called by the engine and captures no config table, so it is unhooked. It calls prototype 61 (host setup), then 62, then 67 and 68 every tick, all by Lua `CALL`. Prototype 67 calls 33, and 33 calls 31. |
| H17 | A `before` callback ran, and an assert (upvalue index, stock drift) failed silently. | **FALSE.** A callback error logs `RENOVICE luaCalls.before protected leaf FAIL key=0x… prototype=… stage=… callback_status=…` through `config::log`. That happens whenever `Logging=true`, independent of diagnostics, and the first 8 occurrences are always logged. The line does not appear. (The Lua error *text* is not logged; see the parallel Circuit finding below. The failure line itself is.) All 10 registry upvalue indices equal the decompiled capture index + 1 (`cap_79_376_8` → 9 … `cap_79_805_25` → 26). |
| H18 | The runtime dispatched `luaCalls[P].before` for the addon. | **FALSE.** The first successful dispatch per key/prototype/VM logs `RENOVICE native hook PASS key=… event=luaCalls.<P>.before` (`log_native_hook_once`). The same function logged `nativeCalls.SetSource/DamageDD/SetBaseAmount` and `BuildMissionForLocation` in the same session. It logged no `luaCalls` event. EE.log confirms that no reward was processed. |
| H19 | The `luaCalls.before` boundary has worked live since it was replaced in V107 (2026-09-19). | **FALSE (log census).** The pre-V107 archive (`Logs/Archive/ARSENAL_LOADOUT_UI_REGRESSION_2026-09-19_PRE_FULL_DIAGNOSTICS`, VM-entry lane) has `luaCalls.18.before` (Mallet), `luaCalls.64/67.after.skipped` (Survival `1e3647332a578b78`), and `target-execution.enter` for every target. The retained logs since then (V109 trace session with Mallet `luaCalls[18]` and 55 Mallet casts, V110, both 44.0.2 sessions, and the `Warframe Ice blade of narin 28.09.2026` copy) contain **zero** `luaCalls` events and **zero** `target-execution.enter` lines. `REGISTRIES/hook_registry.tsv` has always listed `renovice.target.lua_call` as `OFFLINE_VERIFIED`. The Phase 2e phrase "live-proven 67:70" (and H4 above) was wrong: 64:70 was live only on the pre-V107 lane. |
| H20 | The runtime rejects every call at closure identity, because live module closures do not carry the environment recorded at module load. | **TRUE on static and log evidence; live confirmation is pending.** `target_lua_call_for_published_closure` → `published_target_closure_is_live` requires `closure->env == identity.environment`. `identity.environment` is the registry closure's env at the loader return (`remember_target_module_identity`, logged `env=000001E4BD62DA60`). In the same session TopMenu logs load `env=000001E471CCD8C0` but `runtime_env=000001E4B2212660` for the same proto `000001E475EB2360`, so the root runs later in another environment and its closures inherit that environment. The V110 record (Mallet H4) proved the same mismatch live. V110 added an exact prototype + `savedpc` fallback only for damage-target association, which is why `nativeCalls` work and `luaCalls` do not. `target-execution.enter` uses the same check and has also not been logged since V109. The parallel Circuit finding (`CIRCUIT_PROGRESS_PREVIEW_ACTIVATION_2026-09-29.md`) is the same mechanism for `activate`. Which later check would fail after the env check (proto-prefix liveness, CALL decode) cannot be tested until the env check passes. |
| H21 | The old Survival preset stopped working because of U44. | **FALSE.** It worked on the V60/V61 VM-entry/resume lane. That lane identified closures by prototype address only (V108 source still does), with no env check. V107–V109 (2026-09-19) replaced the lane and added the strict env identity. U44 only renumbered prototype 64 → 67. The U44 port of the preset fails the same way. |
| H22 | The reward interval can be reached today through another live-proven lane without a runtime change. | **FALSE.** The value is template constant K34, shared with `killPlayerTime`. Changing it needs a constant-split replacement primitive, which changes the body size and has no Replacement-lane evidence yet. `nativeCalls` callbacks get no upvalue view. No module global reaches the table. |
| H23 | Lantern (`caec63d8e739b693`) and Purgatory (`6fa60841c9e0f207`) have the same problem. | **TRUE.** Both act only through `luaCalls.before`. For Lantern, hooks 11–14 are the capturers; only 14 is called by Lua, from prototype 32. Purgatory hook 37 is `MasterInit`, called from `StartMode` (prototype 39). Statically their binding order is correct, but the runtime never dispatches them. Lantern `tier_up_interval` has a literal form (single-use template f64) and now builds as an exact replacement. Purgatory `difficulty1.warrior_level` has none. |
| H24 | The Circuit `activate` `protected-call-rejected` has the same cause. | **Different boundary, same mechanism.** Circuit declares no `luaCalls`. It fails in `activate` because module-root globals are published in the runtime env, not the load env (parallel finding). It is not caused by the mission generator. |

Also corrected: the Phase 2e limitation "variant code that overwrites a field before the first hook makes the stock check
fail" is inaccurate for Survival. Prototype 61 is hooked. Its `before` would write first, and then the fixed-length
branch sets `interval = fixedLength` (and fast mode sets `pickupTimeAdded = 4`), so the variant value wins. Prototype
60's `interval` writes are dead code: they run only under `debugCmd`, which the same function sets to `false` first.

### Generator fix (smallest generic change)

The mission generator did not apply the rule the editor already enforces for ability projects: `HOOK_UNPROVEN`, meaning
generate only from `LIVE_CONFIRMED` hooks. It staged `TARGET_ADDON` artifacts as `STAGED_PASS` for a hook binding that
has no live dispatch. Changes (`src/mission_profiles.inl`):

- Every mission target addon is tied to hook binding `renovice.target.lua_call`. Its status is read from
  `REGISTRIES/hook_registry.tsv`, the same authority `validate_project` uses.
- Automatic lane, while the binding is not `LIVE_CONFIRMED`:
  - a body whose rows all have an exact literal form builds as one exact replacement, including dual root-table rows through `literal_owner`;
  - a body with addon-only rows fails closed with `NEEDS_BINDING: body key … <rows> can be written only by a target addon … renovice.target.lua_call, which is OFFLINE_VERIFIED …`;
  - mixed bodies keep the existing competing-artifact error.
- Live acceptance probe: the settings may name the binding in `"allow_unproven_hook_bindings":
  ["renovice.target.lua_call"]`. Only registered binding names are accepted; others fail closed. The addon is then
  staged with a `HOOK_UNPROVEN` warning. The opt-in is part of the settings hash.
- Every `TARGET_ADDON` manifest and set-manifest entry records `runtime_hook` (`binding`, `registry_status`,
  `live_confirmed`, `built_by_explicit_opt_in`). Presets keep their lane and bytes and get the same warning and record.
- When the binding becomes `LIVE_CONFIRMED` in the hook registry, the Phase 2e routing returns automatically. No code
  change is needed.
- `REGISTRIES/hook_registry.tsv`: the `renovice.target.lua_call` authority note and evidence were updated. The status
  stays `OFFLINE_VERIFIED`.

No addon source, gate, registry row or runtime file changed. The generated addon bytes are identical under the opt-in.

### Gate results (offline)

| Gate | Result |
|---|---|
| `verify-missions` | 594/594 PASS (TARGET_ADDON 289, EXACT_LITERAL 242, METADATA_PATCH 62, SERVER_CONFIG 1); registry SHA-256 unchanged |
| `test_phase2e_gates.py` / `test_phase2d_gates.py` | 7 PASS / 7 PASS, template census unchanged (766 / 1187) |
| C++ build (`-Wall -Wextra -Wpedantic -Werror`) | 0 warnings, 0 errors |
| CTest | 2/2 PASS |
| C++ self-test | 125/125 PASS (121 + 4 new: literal lane for dual rows, NEEDS_BINDING for an addon-only row, opt-in probe records the binding status and warns, unregistered opt-in rejected) |
| Managed Dev tests | 162/162 PASS |
| WPF App / Dev (`--no-incremental`) | 0 warnings, 0 errors |
| Presets (`test_presets_and_sample.py`) | 12 PASS, byte-identical to the previous run; 36 rejections |
| Phase 2b settings | default: NEEDS_BINDING (`survival.reward_interval`); opt-in probe: 4/5 identical (Survival = Phase 2e generic addon) |
| Phase 2d settings | default: 9/9 **identical to the recorded Phase 2d manifest** (Void Flood `timeToFillMax` back on its exact literal); opt-in: 8/9 |
| Phase 2e settings | default: NEEDS_BINDING (Purgatory, Survival); opt-in probe: 4/4 identical to the installed Phase 2e artifacts |

### Phase 2f sample output

Location: `work/research/universal-mission-editor-2026-09-29/phase2f-sample/`. The Phase 2e values were rebuilt with
default settings. `rejected_rows.json` holds the two exact NEEDS_BINDING rejections (`survival.reward_interval`,
`purgatory.difficulty1.warrior_level`). `SHA256SUMS.json` lists every file.

| Artifact | Tunable | Lane | SHA-256 |
|---|---|---|---|
| `caec63d8e739b693 (missions_exact-replacement).lua_B` (Lantern) | `lantern.tier_up_interval` 90 → 60 (one f64 constant; 2 bytes differ; DE round-trip identical) | replacement | `AF066CE608243DF782DFFAABC1EF33135E82C2DB28E5F19AF70729D458C919D8` |
| `fc711ff621a75552 (missions_exact-replacement).lua_B` (Void Flood) | `void_flood.fractures_per_round.normal` 3 → 4 | replacement | `E979F5E7906F0D88E49C42B4191ECA6AFDC1237FDDD91D52CBF427DB3FA9F6D2` (same as Phase 2e) |

### What the runtime must provide (bootstrapper owner; not done here)

1. Publish the target module's **runtime** environment (the env the root actually runs in; per VM, root proto, env
   instance and generation) into the identity used by `published_target_closure_is_live`. Alternatively, give
   `target_lua_call_for_published_closure` the V110 exact-prototype fallback. Moving only `activate` to the root
   return does **not** fix `luaCalls`, because resolution would still compare against the load env.
2. Per-instance activation. The generic addon binds one owner table per activation and asserts `owner changed` if a
   second root instance's table arrives. Per-instance activation keeps that invariant; a shared activation would need
   per-owner bookkeeping in the generator.
3. Bounded error text for lifecycle and `luaCalls.before` failures, so asserts are readable (operational logging, not diagnostics).
4. Live acceptance on two unrelated targets, for example Survival `reward_interval` and Purgatory warrior level or a
   Void Cascade field, built with the opt-in probe. Then set `renovice.target.lua_call` to `LIVE_CONFIRMED`.

Acceptance log lines after a runtime fix: `RENOVICE native hook PASS key=f10a043e7f825db2 event=luaCalls.61.before`
(host) and/or `…event=luaCalls.67.before`; no `luaCalls.before protected leaf FAIL key=0xf10a043e7f825db2`;
`EE.log` `Survival: Session locked` and `Survival: Host - first reward` about 150 s after
`Survival: State Change: ENDLESS`.

### Limitations

- H20 names the first failing check. Later checks in the same path cannot be tested until it passes.
- Survival reward interval, Purgatory difficulty and every other addon-only row cannot be delivered until the runtime
  change above is live-accepted, or until a constant-split replacement primitive exists.
- The Phase 2e sample folder is left untouched as dated evidence of the installed (inert) artifacts.

## Phase 2g — one multi-target Missions addon with per-instance binding (2026-09-29)

**Build.** Client `2026.09.28.13.06` (Hotfix 44.0.2). Registry unchanged: SHA-256 `EEFF2087…25B0AFA`. Runtime contract:
bootstrapper-runtime `feat/multi-target-addon` `67cd256`
(`RESEARCH/MULTI_TARGET_ADDON_AND_ROOT_BINDING_2026-09-29/README.md`, repo copy of `OpenWF/CustomScripts/HOW_TO_ADD_SCRIPTS.md`).
**Scope.** Generator and gates only. Offline; nothing was written to a game or server folder. The installed files were
only hashed (read-only) to name what the sample replaces.

### Goal

One **Missions** row in the in-game Scripts menu instead of one file and one row per mission module. Later, the same
script is meant to expose every mission value for in-game editing (F12 overlay; not built here). Its reserved `label` and
`settings` fields are emitted now so that the overlay has one place to read the values from.

### Hypotheses and results

| # | Hypothesis | Result |
|---|---|---|
| H25 | Every addon-lane body key of a settings build fits in ONE `Inject\Missions.targets.addon.lua_B` without a runtime change. | **TRUE (offline).** The runtime (67cd256) expands `targets["<key>"]` into one ordinary target binding per key. The generator emits one entry per body key; replacements, metadata and server rows are unchanged. |
| H26 | The compiled file declares exactly the addon body keys: no generated string (tunable ids, table ids, module paths, labels, messages) is lowercase 16-hex. | **TRUE.** The editor's own pool reader (the loader's `09 03 | varint count | {varint length, bytes}` rules) and the bootstrapper's `verify_multi_target_addon.exe` (built from 67cd256, running the real `discover_multi_target_keys`) both read exactly `6fa60841c9e0f207`, `caec63d8e739b693`, `f10a043e7f825db2` from the sample artifact (`MULTI-TARGET ADDON PASS declared_targets=3`). Keys occur only as `targets` keys; comments name modules by path. |
| H27 | The Phase 2e generic root-table generator is safe when hooks fire for every live instance. | **FALSE.** It cached the first table (`tableN`) and asserted `owner changed` for any other table. With 67cd256 attributing `luaCalls` by exact prototype for every instance, a second module instance would raise on every hooked call and never be written; cleanup restored only the first table. The generator is replaced (below). |
| H28 | Weak-keyed per-table binding meets the instance contract: each live table written once after its stock check, a drifted table skipped with one error, every written table restored in cleanup, lifecycle idempotent and repeatable. | **TRUE (offline, executed).** The generated source runs under the reference Luau VM (`de-luau-toolchain/bin/luau.exe`) in the new self-test harness for all 3 modules (see Gate results). |
| H29 | The established Survival/Interception template addons can be embedded as entries unchanged. | **FALSE.** Both bind one owner per activation (`configured`, module-global state); the Survival template asserts `owner changed`. Template-only rows (`survival.pickup_reward_progress`, `interception.score_rate`) now fail closed in a settings build with the exact reason and the preset that still builds them (`survival`, `interception`, single-key files, byte-identical). |

### Design

- **One file per settings build.** `build-missions` puts every body key whose rows are on the addon lane into
  `artifacts/Missions.targets.addon.lua_B` (source `source/Missions.targets.addon.luau`). Exact replacements stay separate
  files, one per body key; one body key still never gets both. Presets (`single_artifact`) keep their established
  `<key>.mission_<id>.target.addon.lua_B` file and bytes.
- **Returned value.** `return { label = "Missions", targets = { ["<key>"] = targetN(), ... } }`. There is no top-level
  `hooks` and no top-level lifecycle. Each entry has its own `activate`, `cleanup` and `hooks = { luaCalls = { [P] = { before = … } } }`,
  plus the reserved `label` (module path) and `settings` (`{ ["<tunable_id>"] = { value = …, stock = … } }`). The runtime
  ignores both reserved fields. The entry's code reads its values from that one `settings` table.
- **Per-instance binding** (`ownedTable(tag, settings, fields)`, shared helper emitted once):
  - `bound = setmetatable({}, { __mode = "k" })` maps each live table to the values written, or to `false` if it drifted.
    Weak keys let the collector drop tables of finished instances. `setmetatable`/`__mode` are used by stock DE code
    (`Lotus.Scripts.HubNpc`), and the compiled file resolves `setmetatable`/`pairs`/`assert`/`type` by name like the earlier addons (`hashed-globals=0`).
  - A hook resolves the table from **that call's** `upvalues` (and container path), never from a cached owner. A table
    already in `bound` returns at once (idempotent; one table lookup per call on hot prototypes).
  - Stock check before the write: every owned field must hold its registered stock value. On drift the table is marked
    `false` and the call fails with `<module path> <table id> stock values drifted; this instance is left unchanged`; later calls skip it silently (reported once).
  - `cleanup` restores every table it wrote whose field still holds the written value, and clears the record, so the
    next activation (rollback, F9, root-return rebind) binds again from stock. Fields another owner changed are left alone.
- **Declaration gate** (`multi-target-declared-keys`, in every multi-target build): the compiled pool must declare exactly
  the addon body keys; the source must hold no other run of 16 or more lowercase hex digits and each key exactly once;
  the file must be smaller than 1 MiB and declare at most 1,024 keys. The gate runs after the existing
  `source-compile`, `source-plan`, `u44-compile` and `de-roundtrip` gates.
- **Manifests.** The addon record has `body_key = "multi-target"`, `target_keys`, and one `targets[]` record per module
  (module path, tunables, stock body path and SHA-256, and `supersedes`: the per-module file it replaces). It also has
  `scripts_menu` (`[ADDON] Missions`, `target-addon:missions.targets.addon.lua_b`) and the unchanged `runtime_hook`
  record. The CLI prints one `Target:` line per key.
- **Hook status gate kept.** `renovice.target.lua_call` stays `OFFLINE_VERIFIED`; the addon lane is used only with the
  settings opt-in `"allow_unproven_hook_bindings": ["renovice.target.lua_call"]`, and the build warns `HOOK_UNPROVEN`. The
  warning is now added only after the addon is actually staged, so a failed build reports its error first.

### Gate results (offline)

| Gate | Result |
|---|---|
| `verify-missions` | 594/594 PASS (TARGET_ADDON 289, EXACT_LITERAL 242, METADATA_PATCH 62, SERVER_CONFIG 1); structure PASS; registry SHA-256 unchanged |
| C++ build (`-Wall -Wextra -Wpedantic -Werror`) | 0 warnings, 0 errors |
| CTest | 2/2 PASS |
| C++ self-test | 130/130 PASS (125 + 5 new, below) |
| Managed Dev tests | 162/162 PASS |
| WPF App / Dev (`--no-incremental`) | 0 warnings, 0 errors each |
| `test_phase2e_gates.py` / `test_phase2d_gates.py` | 7 PASS / 7 PASS; template census unchanged (766 / 1187) |
| Presets (`test_presets_and_sample.py`) | 12 PASS, all byte-identical to the previous run; 36 rejections |
| Phase 2b / 2d / 2e settings, opt-in rebuild | 4/5, 8/9, 1/4 byte-identical. Every difference is an addon now carried by the Missions file (by design). Default builds unchanged (2b/2e NEEDS_BINDING, 2d PASS). |
| Phase 2f sample rebuild | both replacements byte-identical |
| Phase 2g sample | built twice; artifacts identical (deterministic) |
| Bootstrapper loader discovery (`verify_multi_target_addon.exe`, 67cd256) on the Phase 2g artifact | `MULTI-TARGET ADDON PASS`, 6,043 bytes, declared_targets=3 |

New self-test checks:
1. Survival + Purgatory + Lantern (opt-in) + Void Flood build exactly one addon, `Missions.targets.addon.lua_B`, and one
   replacement. The compiled pool declares exactly the 3 keys; the source has no stray hex; the returned table has
   `targets` and no top-level hooks; there is no `owner changed`; the manifest records the policy ID, the opt-in and the 3 superseded per-module files.
2. **Per-instance harness** (luau.exe, generated source unchanged, one case per module). Hooks are inert before
   `activate`. Two live instances are both written. A repeated call does not rewrite a table. A drifted instance errors
   once and is never written. Double `activate`/`cleanup` are safe. Cleanup restores every written instance and keeps a
   value changed by another owner. Hooks are inert after cleanup. Re-activation binds a restored instance again. Two chunk runs (two bindings) have separate state.
3. **No-stray-hex rule.** A stray lowercase 16-hex run, a repeated key, or a 17-digit run is rejected; uppercase is ignored.
   The pool reader matches the loader (uppercase is not declared; the zero key is rejected).
4. A registry string that would compile to an extra declaration (module path `…Purgatory0123456789abcdef`) fails the
   build closed with `multi-target-declared-keys failed: stray lowercase hex text '0123456789abcdef'`.
5. A template-only row (`survival.pickup_reward_progress`) fails closed with `not multi-instance safe` and names the `survival` preset.

Existing checks were updated for the new source form (value in the entry's `settings`, field named by
`{ key = …, setting = … }`): Void Cascade 3 fields, Survival `interval` vs `killPlayerTime`, Void Flood Shadowgrapher and
curse, and Purgatory nested difficulty 2.

`test_presets_and_sample.py` compares multi-target artifacts per covered body key. It now **never rewrites a recorded
sample folder**: an existing folder is compared by artifact hash and left untouched, and only a missing folder is created.
Before that fix, the first run of this phase rebuilt `phase2f-sample` in place, as the Phase 2f script always did. Its
two artifacts and the recorded `phase2f_sample` entry in `test-results/results.json` are identical. The folder's
`SHA256SUMS.json` changed from `852042D9…82E8D845` to `D86E2A25…E2CF7B51`, and the prior ancillary files (logs, manifests,
settings copies) were not preserved.

### Phase 2g sample output (live-test set)

Location: `work/research/universal-mission-editor-2026-09-29/phase2g-sample/`. Settings: `survival.reward_interval` 150,
`purgatory.difficulty1.warrior_level` 15, `lantern.tier_up_interval` 60 (addon lane via the opt-in), and
`void_flood.fractures_per_round.normal` 4 (replacement), with `allow_unproven_hook_bindings: ["renovice.target.lua_call"]`.
`SHA256SUMS.json` (SHA-256 `C7142325…EF334151`) lists every file.

| Artifact | Install to | Covers | SHA-256 | Bytes |
|---|---|---|---|---:|
| `Missions.targets.addon.lua_B` | `OpenWF\CustomScripts\Inject\` | Purgatory `6fa60841c9e0f207`, Lantern `caec63d8e739b693`, Survival `f10a043e7f825db2` | `00DA193D03D43472D4DF98806E7A532A82F449E17FA82E07624CC2F9816A773E` | 6,043 |
| `fc711ff621a75552 (missions_exact-replacement).lua_B` | `OpenWF\CustomScripts\` | Void Flood fractures per round 3 → 4 | `E979F5E7906F0D88E49C42B4191ECA6AFDC1237FDDD91D52CBF427DB3FA9F6D2` | 112,244 |

Source `Missions.targets.addon.luau` SHA-256 `FAA6149F…0E14C2`.

**Migration against the installed files** (read-only hash check on 2026-09-29; installed `wtsapi32.dll` is `83e74faf…51a9`,
the 67cd256 multi-target build):

- `Missions.targets.addon.lua_B` replaces all three installed Phase 2e per-module addons. Remove them, or the hooks bind twice:
  - `Inject\f10a043e7f825db2.missions.target.addon.lua_B` (`CEF8808F…`)
  - `Inject\caec63d8e739b693.missions.target.addon.lua_B` (`228754AF…`)
  - `Inject\6fa60841c9e0f207.missions.target.addon.lua_B` (`043176EC…`)
- The installed root `fc711ff621a75552 (missions_exact-replacement).lua_B` is already byte-identical (`E979F5E7…`), so
  no change is needed.
- The old `ScriptStates.json` IDs of the three per-module files become harmless orphans.

### Limitations

- **Offline evidence only.** No live claim. `renovice.target.lua_call` stays `OFFLINE_VERIFIED` until two unrelated
  live passes (for example Survival and Purgatory) confirm dispatch; then the registry row is flipped and the opt-in is no longer needed.
- **Double binding.** A per-module mission addon, or a Survival/Interception preset file for a key the Missions file also
  covers, binds a second time if it stays installed. The per-target `supersedes` record names the files to remove.
- **Template-only rows** (`survival.pickup_reward_progress`, `interception.score_rate`) are not in the Missions file. They
  build only through their presets until a per-instance form exists.
- **Harness coverage.** The luau harness drives one root table per module, through its first hook. A prototype binding
  several tables and container paths deeper than one step are covered by the same generated code, but not executed by the harness.
- **Rebind window.** On a root-return rebind, cleanup restores every instance's table and the new binding writes each
  again at that table's next hooked capturer call. Gate `ROOT_TABLE_UPVALUE_V1` condition 3 (all capturers hooked) means
  no stock code reads the table in between without a hook running first.
- **Drift reporting.** A drifted table is reported once per binding. It is logged through the runtime's sampled
  `luaCalls.before protected leaf FAIL` line with the bounded error text.

### Suggested live checks (need explicit user authorization to deploy)

With the game closed, remove the three per-module addons, then copy the Missions file (the replacement is already
installed). Then check:

- **Scripts menu.** Exactly one row, `[ADDON] Missions`, tooltip `target 3 modules`.
- **`renovice_source.log`.** No `MULTI-TARGET ADDON REJECT`, `multi_target_reason=`, or `stock values drifted`. `TARGET ADDON PASS` per module as it loads.
- **Survival.** `native hook PASS key=f10a043e7f825db2 event=luaCalls.61.before` (or `.67.before`). In `EE.log`,
  `Survival: Host - first reward` appears about 150 s after `State Change: ENDLESS`. The zero-LS kill timer stays at 300 s.
- **Purgatory.** Difficulty 1 warriors spawn at level 15 (`luaCalls.37.before`).
- **Lantern.** The lantern tier rises every 60 s (`luaCalls.14.before`).
- **Void Flood.** 4 fractures per round.
- **Regression.** F9 reload is PASS with the Missions row unchanged. Disabling the row and pressing F9 runs cleanup, which
  restores the stock values. Mallet, Ice Wave, ESO and Circuit are unchanged.
