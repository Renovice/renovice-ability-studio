# Native card labels and mission progression investigation — 2026-09-27

## Ability Studio: SUPPORTED, with bounded coverage

Hypothesis: native card Label/Value pairs can supply trustworthy visible names without assigning meanings to unrelated constants.
Evidence: `src/card_stats.cpp`, CLI `card-stats`, `editor/Core/CardStatDiscovery.cs`, and the Stock Values panel. The analyser follows direct identifier copies to renderer-unique root variables and their numeric assignments. Localization comes from the existing Names.en.json catalog. One input feeding several card rows is edited once with combined labels. Separate assignments retain their source lines; rank/PvP branch meanings are not guessed. Initial defaults are omitted when explicit later numeric assignments exist.

Computed expressions, branch joins, shadowed locals/parameters, inline display-only constants, and frame-backed values without a root binding remain read-only. Comments and long strings are excluded while preserving byte offsets. The GUI converts UTF8 offsets to UTF16 positions, checks source tokens, and rejects stale source/target selections. Existing structural replacement, compiler and semantic-proof gates remain in force.

Final sample: **98 card rows across 19 existing ability modules; 63 rows resolve to editable base inputs**. The additional mission source has zero card rows. The separately extracted current-build Snow Globe source has **9 rows, 5 direct bindings**, including Radius, Freeze Duration, Health, Time Invulnerable, and Area Damage. These are row counts, not counts of unique editable numeric assignments. An earlier progress message mistakenly included the five Snow Globe bindings in the 19-module binding total; 63/98 is the correct sample total.

This is a generic analyser used on demand, not a manually curated set of ability-specific mappings. It is also not a complete Lua semantic analyser. More complex Value producers retain their native labels without an invented editable binding. Custom addon card rows and constants are separate from stock ability values.

The existing full ability catalog remains the July snapshot; **this change does not migrate or certify every ability against U44**. The current Snow Globe source was used as an offline research fixture, not silently installed into the old catalog. The earlier U44 mission profile work remains separate. Do not install an old catalog body's replacement into a new game build without rebasing and verifying its identity.

## Validation

- `build_editor.bat`: C++ build; 2/2 CTest targets; 112/112 managed checks; WPF publish passed.
- Negative tests cover calculated/branch ambiguity, shadowing, reassignment, comment/string false matches, wrong body identities, and stale numeric spans.
- UTF8 offset conversion, multiple labels sharing one input, and exact-token numeric edits passed.
- `scripts/coverage.py` runs the production CLI against the existing rendered sample and current Snow Globe fixture; `artifacts/coverage.json` records exact input paths and totals.
- `artifacts/build.log` retains the final build output. No game runtime, live Lua addon, server configuration, or mission behavior was changed by this investigation. Interactive GUI and new gameplay edits have not been live-tested here.

## Initial Netracell investigation (superseded by metadata follow-up below): progression owner SUPPORTED; editable binding INCONCLUSIVE

Exact current body: `/Lotus/Scripts/Modes/EntratiVoidVaults.lua`, key `0c498e078835f9fe`, SHA256 `036522b0202ab810737f23c765e45050cb02f87b10f9c293932b3be8da24f85f`.

- Export `OnEnemyKilled`, prototype 49, invokes prototype 32 after its target/range checks. Prototype 32 adds `Name__9a8fa363` to the shared acquired-power value, with a separate quest multiplier `Name__f8ce5d4e`.
- Root string identities: `VoidVaultsVaultDoorPowerRequired` and stock-spelled `VoidVaultsVaultDoorPowerAdquired`.
- The same acquired/required ratio drives the visible percentage; thresholds drive disruption stages and vault opening. See readable lines 3039–3190 and 7292–7298.
- The per-kill amount is a **script external/global**, not a proven literal 1 next to the event. The `VAULT_ENEMIES_KILLED` increment of 1 later in prototype 49 is a separate counter, not proof of power gain.
- Next binding work: resolve that exact resource-supplied global and its module lifecycle, then scale it at its authoritative input. Preserve quest and disruption behavior; test percentage and vault completion together. No guessed slider exported.

## Descendia: separate objective scripts SUPPORTED

`Purgatory.lua` was inspected and REFUTED as Descendia: it contains Deadlock Protocol, PurgatoryWarrior, Solaran and Granum-style timer/kill logic. Do not modify it for Descendia.

Actual objective scripts extracted from current cache:

- `/Lotus/Types/Gameplay/DevilTower/LiteGameModes/CoHExcavationLite.lua`, key `415a57536412719f`, SHA256 `c641b897157618608088a5cfbd1d5688ace5c12822f8adaadf95089c6491d0e8`. Contains `Descendia_Excavation`, excavation state/time/dig counters and `ChallengeComplete`. `ScanTime` in prototype 8 schedules extractor triggering; it is **not by itself proof of the dig duration**. Need the extractor's actual duration/completion owner before exposing a speed multiplier.
- `/Lotus/Types/Gameplay/DevilTower/LiteGameModes/CoHShrineDefenseLite.lua`, key `1ef96aede7fe612e`, SHA256 `4bea96c94d8a22a6578139c47919e05d4a191d97a6a88cf371ed150bb11ed946`. Contains `Descendia_ShrineDefense`, state-specific OverallStateTime tables (420/180 and 300/180) and native timer callbacks. Need to distinguish objective deadlines/failure behavior from completion waits before reducing these values.

Conclusion: there is no verified single Descendia gameplay-speed knob from these findings. Server `descendiaMultiplier` concerns reward quantities; it is not an objective timer. Existing server reward multipliers remain unchanged. Netracell/Descendia gameplay controls were **investigated, not added or claimed working**.

## Reproduction and artifacts

`scripts/missions.py` and `scripts/descendia.py` extract only the named current cache scripts, apply the existing verified opcode-only normalizer, and render research-readable source. Native hashes remain intact/unresolved where no name evidence exists. Renderer success is not original-byte or gameplay certification. Raw game files and generated research views stay under ignored local `artifacts/`; no proprietary corpus is added to the distributed tool. `artifacts/mission-identities.json` records identities. `scripts/probe.py` records initial source/cache discovery.

## Follow-up: metadata owners verified, 2026-09-27

**SUPPORTED.** Reused the existing offline metadata query tool against `work/research/U44-2026-09-27/Packages-new.dec`. `scripts/verify_metadata_owners.py` reproduces the query and asserts the native-name bindings with the U44 FNV seed `0x768e5ed0`. Metadata script parameters carry a serialization underscore; Lua global names omit it. All three hashes match exactly:

| Metadata field | Lua global/hash | Current value | Consumer |
|---|---|---:|---|
| `_enemyPowerFill` | `enemyPowerFill` / `9a8fa363` | 1 | Netracell p32 adds it to acquired power after qualifying kill; same total drives HUD percentage and vault stages |
| `_questPowerMultiplier` | `questPowerMultiplier` / `f8ce5d4e` | 8 | Additional multiplication in quest-specific branch; not a general speed setting |
| `_offeringGenerationTime` | `offeringGenerationTime` / `0bf412f0` | 30 | Descendia shrine p12/p59 start the native offering timer; p11 enables pickup and changes offering state to 3 when time expires |

Authoritative metadata owners and candidate nested patch paths:
- `/Lotus/Types/Gameplay/EntratiLab/VoidVaults/EntratiVoidVaultsScriptTrigger`: `Scripts.0.Script._enemyPowerFill`. Setting 2 would double qualifying-kill power relative to the decoded default; it would not halve drone/search/transition durations. The same parameter also participates in the quest branch, so quest scope must be accounted for before deployment.
- `/Lotus/Types/Gameplay/DevilTower/LiteGameModes/CoHShrineDefenseTrigger`: `Scripts.0.Script._offeringGenerationTime`. Setting 15 would halve the 30-second generation timer. This is the actual generation/pickup-readiness timer, not merely a cosmetic HUD label. The separate OverallStateTime values also feed phase timer/spawn logic and must not be used as a blanket completion-speed control.

These paths follow decoded nested structure and the existing q-path convention. No metadata patch was installed, no reload was requested, and no live effective-value/gameplay test was claimed. Level/instance overrides and inheritance scope remain deployment checks.

### Descendia excavation: Lua-owned duration SUPPORTED

`CoHExcavationLite` prototype 23 accumulates elapsed time only while power is positive. At readable lines 3668–3685 it compares elapsed + 0.05 against **45 seconds** and sets the completed flag. The same 45 appears in host-migration elapsed reconstruction (3299), battery-cap calculation (3449), remaining-time presentation (3699), and partial-score proportion (3763). A full dig yields 25 progress; accumulated dig score reaches completion at 50 (3787 onward). These are objective progress values, not server reward quantities. Therefore a correct duration change must keep those linked consumers consistent and preserve per-dig score. This is a Lua constant in the inspected current module, not a `_digDuration` metadata property. No timer patch was built or installed in this follow-up.

### Ability labels versus actual stats: important scope correction

`/Lotus/Language/...` identifies localized display text, not storage of the numeric stat. Metadata fields and Lua constants are both used by abilities. Current Ice Wave metadata contains `EnergyRequiredToActivate=50` and script parameters such as `_pathDamage=100`; the latter must not be confused with total rank-based Ice Wave damage. Snow Globe's base-health ladder is in Lua (`v19_16`), reaches its HEALTH card and gameplay `maxHealth` payload; no equivalent base-health ladder was found in the inspected IceShieldAbility metadata.

The user's screenshot is catalog Dagath Rakhali's Cavalry, body `dc33836ea5685c89`. Its `v18_7` DAMAGE is passed to `SecondaryScriptArgs:PushFloatArg` and `DoHorseSpawn` (readable lines 1806–1813), so the variable has a real gameplay consumer. However the source duplicates numeric rank assignments in p0 (common setup), p2 (`GetAbilityUpgradeLevelInfo`, lines 313/317/322/327), and p13 (`ActivateAbility`, lines 1644/1655/1666/1671). Editing only a p2 card assignment does not automatically change p13's assignment.

The current panel edits numeric Lua tokens, not localization strings, but **it does not yet synchronize duplicated gameplay/card/rank assignments or prove every assignment's gameplay effect**. Its direct-card association is not sufficient evidence for an automatically linked one-knob gameplay edit. Preserve this distinction in the UI and future exporter work. Per-row ownership/grouping needs to distinguish card-only, activation, shared setup, rank, and PvP branches before those can be merged; do not merge identical labels/numbers blindly.


## Shipped editor controls, 2026-09-27 follow-up

**SUPPORTED offline:** eleven mission presets build, including Netracell power-per-kill and Descendia shrine generation as metadata patches, and Descendia excavation as an exact Lua replacement. The q paths are now checked against `Extract.QueryableText` from the existing metadata editor. `.txt` exports use the same manifest/gate/hash/readback/rollback transaction as `.lua_B` exports; their output lanes cannot be interchanged.

Excavation inspection refined the earlier hypothesis: the five duration consumers do NOT all refer to one constant. Four use p23 K90 (float64 at offset 22618), while completion uses p23 instruction word 736 (LOADN at offset 21000). Both must change. `scripts/test_control_artifacts.py` renders the staged replacement and proves precisely five `45 -> 15` source changes, with unchanged per-dig score and all other bytes outside the allowlist identical. This is a stock hash/preimage gated change, not an unqualified byte search.

**SUPPORTED offline:** the large stat controls use a generic declarative binding registry. Initial reviewed coverage is Dagath Damage and Duration, four explicit rank-input branches each. Shared p0, card p2 and activation p13 assignments move together. Duration reaches p16's lifetime countdown (`frame_16[42]`, decremented by elapsed time); damage reaches DoHorseSpawn. The final branch is the stock fallback after rank inputs 1/2/3; no inference from identical numbers is used. The previous independent assignment-grid behavior is replaced by read-only labels where gameplay linkage is unproven.

`scripts/register_controls.py` reproduces the new registry entries from the local evidence. `scripts/test_control_artifacts.py` checks generated metadata, all five excavation consumers, and compiles the linked Dagath damage edit with all-prototype plan verification and exact container roundtrip. Managed tests also check linked edits preserve other ranks, changed sources lose editability, unknown bodies stay read-only, metadata query paths resolve, and project save retains the new output lanes.

Validation: C++ build/2 CTest targets, 126 managed checks, WPF publish, all eleven mission builds and 33 invalid-profile rejections passed. No bootstrapper/server/game file was changed. **INCONCLUSIVE until live testing:** mission effective metadata inheritance/instance overrides, native gameplay acceptance of the new mission exports and edited ability output. Ability bindings cover the exact existing catalog source, not a newly migrated U44 ability catalog.

## Automatic card-to-gameplay links (latest follow-up)

Hypothesis: a reusable bounded dataflow analyser can expose some linked controls without a per-ability registry. **SUPPORTED for the accepted source shapes**, not all abilities. `src/card_links.cpp` runs after native card discovery, follows shared module roots and consistent local aliases/helper returns, and requires a non-card exported gameplay path reaching a supported operation. Known modifier wrappers preserve base provenance. Literal card-unit conversions are accepted. AbilitiesLib publication/getter tracing requires the exact imported module, an unambiguous field owner and a straight-line publication; unknown competing writes reject. A read from ability-stat storage alone was investigated and **REFUTED as sufficient proof**: the value must reach an effect. Applied radial packets require a subsequent application in the same function and no competing amount setter.

Automatically generated controls use `operation=scale`, not inferred rank labels. Every literal base assignment (including initialization and duplicate card/activation/rank/PvP branches) changes by the same factor. This preserves relative branches without guessing which rank a number represents. Reviewed rank controls override automatic controls for their root. The existing exact-source gate remains for reviewed modules. CLI output records `link_rejections` and operation/line evidence; the UI retains unresolved labels read-only.

Evidence from the 23 locally cached catalog sources (`scripts/test_automatic_links.py`, ignored `artifacts/automatic-tests/summary.json`):

| Ability / body | Automatic control | Gameplay evidence |
|---|---|---|
| Lavos Vial Rush / `2e32a50ec477c59e` | Damage / Second; Explosion Radius | `SetBaseAmount` and radius on subsequently applied radial packet |
| Dagath Grave Spirit / `72e258069c32ff89` | Time Invulnerable | `GiveTemporaryImmunity` duration |
| Garuda Dread Mirror / `b5da5e61b7843e20` | Explosion Radius | `SetDamageRadius` |

Mallet external initialization remains unresolved; no guessed per-ability exception was added. Function-parameter propagation, arbitrary native calls, full CFG/dominance and arbitrary table mutation are not a complete general Lua semantic model here. Unknown expressions, inconsistent writes, shadowed locals, long-string/nested-function structures, unused packets, cancelled expressions and unsupported operations reject. Receiver native behavior is based on existing source/API evidence, not newly tested engine behavior. `SetMaxHealth` and `DealDamage` were excluded because their contracts were not established for this analyser.

Validation: 2 CTest targets (including 16 negative automatic-link cases), 144 managed checks and WPF publish. Exact-span ×2 edits for the three accepted real modules compile/reparse, pass all-prototype plan verification and preserve their compiled DE container on roundtrip. **This is not original-stock-byte identity or gameplay proof.** The user can use Stock Values → Discover → Base scale → Create Replacement → Validate/Build. No runtime hooks, game files or server files changed. Full U44 ability-catalog migration and live behavior remain unverified.
