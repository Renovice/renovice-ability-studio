# NAMECALL callsite audit of every addon and generator (2026-09-29)

- Client: 44.0.2 (`2026.09.28.13.06`), native-name seed `0x768e5ed0`.
- Toolchain: `derecomp.head.exe` `c1672d8d…7c58` (committed U44 raw-hash build `0299da9`), `ir` / `ir-u44` listings.
- Stock: 44.0.2 `repos/toolchains/de-luau-toolchain/work/u44-rawhash-2026-09-29/stock/` (5,474 modules); U43 `shared/corpus/de-luau-stock/` (5,386 modules). Hashes are pinned in `tests/run_gates.py`.
- Installed files, logs, the OpenWF server and the bootstrapper repository were read only. Nothing was deployed.

## The rule being audited

`native_callsite_instruction_from_saved_pc` (`bootstrapper-runtime/renovice/injection_core.hpp`) maps a `CALL` whose previous instruction is `NAMECALL` back to the `NAMECALL`'s logical index. Since V66 (2026-09-13), every `nativeCalls[method].before/after`, `transformFloatArgument` and ENGINE_DAMAGE source callsite is reported at the `NAMECALL` that names the method. A filter written against the `CALL` (NAMECALL + 1) never matches, and the callback returns without doing anything.

Classification of one `(prototype, instruction, method)` filter against the target's stock IR:

- **OK**: the instruction is `NAMECALL :method` and the next one is `CALL`.
- **OFF-BY-ONE**: the instruction is the `CALL` directly after `NAMECALL :method`.
- **OTHER-MISMATCH**: anything else (wrong method, missing prototype, out of range). None was found.

## Audit table

Scope: every compiled addon in `repos/`, `work/`, `RESEARCH/` and the installed `CustomScripts` (337 files, 117 unique by SHA-256), plus every Luau source declaring `nativeCalls` or `transformFloatArgument` (37 files). The full per-file results are in `evidence/scan-bytecode.tsv` and `evidence/scan-sources.tsv`.

### Installed (44.0.2)

| Addon | Filters | Stock 44.0.2 | Verdict | Live log (`prototype=`/`instruction=`) |
|---|---|---|---|---|
| Ice Wave `8fba3a28f8fef624` (`dcedc4a2…`) | SetBaseAmount p7/42, SetSource p7/53, DamageDD p7/65 (before and after) | NAMECALL 42/53/65, CALL 43/54/66 | **OK** | p7/42, p7/53, p7/65 in all four rotations (for example 144/144/331 before-events in `.log.1`). This matches the known-working live behaviour. |
| Mallet `ec368d4901690a15` (`22e0cb49…`, the fix is installed) | transformFloatArgument p16/596 | NAMECALL :PushFloatArg 596, CALL 597 | **OK** | Live anchor through the same mapper: 240× ENGINE_DAMAGE `SourcePrototype 16 / SourceInstruction 576`, which is RadialDamage NAMECALL 576. No threat transform has been logged since the install; that live check is pending. |
| Elite Sanctuary `64d11e6973afa4b1` (`86eacb89…`) | BuildMissionForLocation.after p25/**10** | NAMECALL 9, CALL 10 | **OFF-BY-ONE** | The runtime reported `prototype=25 instruction=9` and `prototype=21 instruction=324` (pid 11584). The filter tests 10, so it never matched. The fix is already staged (see below). |
| Elite staged fix (`4e6d5b71…`) | p25/9, p21/324 | NAMECALL 9, NAMECALL 324 | **OK** | Same log lines as above. |
| `Missions.targets.addon` (`00da193d…`) | none: `luaCalls` keyed by callee prototype only | n/a | **OK (N/A)** | `luaCalls` dispatch carries only `(prototype, arguments, upvalues)`, so no instruction identity is involved. |
| Circuit `95ef5b82a8400944` | skipped (dropped by the user) | | | |

### Generators, templates and examples

| Item | Before | Stock | Verdict | Fix (this branch) |
|---|---|---|---|---|
| `EXAMPLES/mallet_linked_overguard_addon.json`, `LinkedAddonForm` defaults (`core.hpp`), GUI default (`gui_win32.cpp`) | `PushFloatArg` p16/**596** on U43 body `08faf07b504d058f`, emitted as `nativeCalls.PushFloatArg.before` | U43 NAMECALL 595, CALL 596 | **OFF-BY-ONE**, plus the emitted `nativeCalls.PushFloatArg` form, which the runtime has rejected since 2026-09-27 | Index 595. The target now carries `stock_module`. `PushFloatArg` rewrites are generated as `hooks.transformFloatArgument`. |
| `core.cpp` linked-overguard generator (`native_argument_rewrites`) | emits whatever index the project holds; nothing checks it | | Root enabler | The generic `native-callsite-namecall` build gate (below). |
| `core.cpp` Plains Control Area template lock | GetNetPersistentVar p8/**30** | NAMECALL 29 (U43 and 44.0.2) | **OFF-BY-ONE** (latent: validator lock only, never emitted; the template is live-falsified and emits `luaCalls`) | 29 |
| `core.cpp` Deimos Control Area template lock | GetNetPersistentVar p7/**62** | NAMECALL 61 | **OFF-BY-ONE** (latent, as above) | 61 |
| `core.cpp` Mobile Defense template comment | "instruction 139" | NAMECALL 138 | **OFF-BY-ONE** (comment only; the template is retired). Earlier generator output in `work/staging/ability-editor/mission_mobile_defense_timers_addon/*` has a real filter `nativeCalls.GetNetPersistentVar.after` p22/139. | Comment corrected. Staged history left as evidence. |
| Missions multi-target generator (`feat/universal-mission-registry`), `REGISTRIES/mission_build_u44.json` | `luaCalls` plus LOADK/LOADN/NEWTABLE byte-patch sites checked by expected bytes | | **N/A** (not a runtime-reported callsite) | none |
| `RENOVICE_SCRIPTING/TEMPLATES/TargetActivateAbilityHook.target.addon.luau`, MultiTarget fixtures, `HOW_TO_ADD_SCRIPTS.md` | no instruction literal | | **OK (N/A)** | none |
| Bootstrapper `Scripts/` | the folder does not exist on any bootstrapper branch | | n/a | none |
| U44 port rebase (`work/research/U44-2026-09-27/lua-port/artifacts/addon-callsite-rebase.json`) | carried Elite `oldInstruction 10 → newInstruction 10` with anchor `oldCode 54020302` (opcode 0x54 = **CALL**); Ice Wave anchors are `2d…` (0x2d = NAMECALL) | | **OFF-BY-ONE carried forward**: the rebase preserved the role but not the NAMECALL rule | Superseded by the Elite fix. The rebase never checked the opcode of the address. |

### Historical and evidence artifacts (not installed; their target bodies are not in 44.0.2)

| Artifacts (unique SHA-256 count) | Filter | Stock | Verdict |
|---|---|---|---|
| U44 Mallet pre-fix: `U44_AUTHORING_2026-09-27` (`d3bbd127…`, nativeCalls form), bootstrapper `LOADOUT_NATIVE_HOOK_CONFLICT_2026-09-27` (`0acbfea2…`) and its `test_mallet_contract.luau` (asserts 597 transforms and 596 does not) | PushFloatArg p16/597 | 44.0.2 NAMECALL 596 | OFF-BY-ONE (superseded by `MALLET_THREAT_CALLSITE_FIX_2026-09-29`) |
| U43 Mallet V47–V59 packages and the V49 editor contract build (7) | PushFloatArg p16/596 | U43 NAMECALL 595 | OFF-BY-ONE |
| U43 Mallet cover-bypass addon 2026-09-09 (`c2558368…`) | RadialDamage p16/576 | U43 NAMECALL 575 | OFF-BY-ONE. Live U43 anchor: `.log.3` ENGINE_DAMAGE `SourceBody 0x08faf07b504d058f`, `SourcePrototype 16 / SourceInstruction 575`, 1,528×. |
| U43 Elite 2026-09-12 and 2026-09-13 packages and the V72 F9 live-test fixture (3); the U44 port staged copy is byte-identical to the installed file | BuildMissionForLocation p25/10 | NAMECALL 9 | OFF-BY-ONE |
| U43 Mobile Defense nativeCalls addon (2) | GetNetPersistentVar p22/139 | NAMECALL 138 | OFF-BY-ONE |
| U43 Ice Wave V66–V99 packages (17) and the 44.0.2 Ice Wave port and bonus 10/50 builds (3) | p7/41, 52, 64 (U43) and p7/42, 53, 65 (U44) | NAMECALLs in each build | OK |
| 5 pre-key POCs (`Mallet.v50/53/54`, `V91_R1.IceWave`, Elite `addon.stable-pass1`) | no body key in the file name | | UNRESOLVED by name; they are byte-level variants of the families above |

Classification changes nothing in these trees. The records stay as dated evidence.

## Where the CALL numbers came from

- **Derecomp API call map (`calls.tsv`) and the Ability Studio callsite view.** Both number a method call by its `CALL`. For U43 BardMusic, 210 of 210 method rows sit at NAMECALL + 1 (gate `provenance.call-map-numbers-method-calls-by-CALL`), for example `PushFloatArg 596` and `RadialDamage 576`. The V49 Mallet note cites "instruction 596 in the pinned Ability Studio call map", and the Studio footer prints `instruction {callsite.Instruction}` for a selected method call.
- **`wf_api_catalog`** (`FROST_ICE_WAVE_COLD_STACK_DAMAGE_2026-09-13/exact_callsites.tsv`) numbers the NAMECALL. Every addon authored from it (Ice Wave) is OK.
- **The U44 port rebase** kept the role of an address without checking its opcode.

## Fixes (ability-editor, branch `fix/callsite-namecall-audit-2026-09-29`, based on `main` 01c9651)

1. **Generator.**
   - `PushFloatArg` rewrites are emitted as `transformFloatArgument(prototype, instruction, stockValue)`, returning the replacement only at the exact site and value and `stockValue` everywhere else. The reserved `nativeCalls.PushFloatArg` form is never emitted.
   - Other methods keep `nativeCalls[method].before`.
   - A `PushFloatArg` rewrite must address argument 2 (`NATIVE_TRANSFORM_ARGUMENT`).
2. **Project binding.**
   - `target.stock_module {path, sha256, bytecode_profile}` (schema and validation) is required whenever `native_argument_rewrites` is non-empty (`NATIVE_STOCK_BINDING`, NEEDS_BINDING).
   - `path` is workspace-relative `.lua_B`; `bytecode_profile` is `U43` or `U44`.
3. **Generic gate: `native-callsite-namecall`** (external build gate, before compile).
   - It verifies the stock module's SHA-256 and runs `derecomp ir` or `ir-u44` on it.
   - For every rewrite it calls the public `check_native_callsites_against_ir()`. The site must be `NAMECALL :<hook's native name>` followed by `CALL`.
   - Otherwise it reports `NATIVE_CALLSITE_NOT_NAMECALL` with the expected NAMECALL index, and the build is `STAGED_FAILED`.
4. **Profile-correct compile.** A `U44` stock module compiles with `recompile-u44`; `U43` keeps `recompile`.
5. **Corrected indices.**
   - Example and form default: 595.
   - Control Area locks: 29 and 61.
   - Mobile Defense comment: NAMECALL 138.
   - `EDITOR_CONTRACT.md`, `ARCHITECTURE.md` and `CHECKLIST.md` now state the rule.

Evidence (`evidence/editor-build-gates.txt`):

- **Example build:** `STAGED_PASS` with `native-callsite-namecall`, recompile, de-roundtrip, plan-verify and focused-api-check. The artifact is `bdcfab8e…`, and a second build is byte-identical.
- **Negative build** (the same project at 596): `STAGED_FAILED` with `NATIVE_CALLSITE_NOT_NAMECALL … 596 is the CALL; the runtime reports NAMECALL :PushFloatArg at 595`.
- **Self-test:** 110/110 PASS, zero warnings or errors (`-Wall -Wextra -Wpedantic -Werror`). It covers:
  - fixture-IR positive and negative cases (CALL index, another method's NAMECALL, wrong hook name, missing prototype);
  - the real U43 BardMusic stock;
  - three unrelated 44.0.2 targets, where Mallet p16/596, Ice Wave p7/42, 53, 65 and Elite p25/9, p21/324 are OK and 597 and p25/10 are OFF-BY-ONE.
- **ctest:** 2/2 PASS.
- **Regression:** the Interception and Survival mission target-addon projects (no native rewrites) still build `STAGED_PASS` through the same path with their four unchanged gates (`work/staging/callsite-audit-2026-09-29/mreg`).

## Tool: `tools/callsite_audit.py`

The tool reads its inputs and does not change them.

- `check`: checks one site.
- `addon`: checks one `.lua_B` or `.luau` (sources are compiled with the target profile and read back through the same decompiler).
- `scan`: checks many files, deduplicated by SHA-256.

How it works:

- The stock module is resolved from the file's 16-hex body key (runtime FNV-1a-64, `replacements_core.hpp`) across the 44.0.2 and U43 corpora.
- Hook bindings (`nativeCalls[method].before/after`, `transformFloatArgument`) are resolved in the decompiled module, and the `(prototype, instruction)` constant tests are extracted from the callback.
- It follows one delegation such as `isOnslaughtBuild(prototype, instruction, …)`.
- A `.u44.` source that still carries its U43 key in the file name is reported UNRESOLVED instead of being checked against the wrong stock.

This gives hand-written addons the same gate as generated ones: `python tools/callsite_audit.py addon <addon>`, where exit code 0 means every site is a NAMECALL.

## Gates

`tests/run_gates.py <out> --editor-build <dir>` gives **41/41 PASS** (`evidence/gates.json`):

- the tool and all 11 stock identities;
- 18 audited sites with their expected class;
- the 4 installed and 2 staged addons through the generic extractor;
- the call-map provenance;
- the editor self-test.

## Limits (exact)

- The linked-overguard template cannot yet build a **U44** project. Its hook and modifier registries (`renovice.mallet.damage_dispatch`, `mallet.strength.channel_10`) are scoped to U43 body `08faf07b504d058f` (`HOOK_TARGET_SCOPE`). The `recompile-u44` and `ir-u44` build branch is therefore exercised only through the self-test's `ir-u44` gate, not through a full U44 build.
- The C# Dev tests (`editor/Dev`) were not run. `WorkspaceLocator` resolves `repos.ability_editor` to the main checkout, which another agent is using, not to this worktree. The C# code reads no field that changed, and `stock_module` is preserved by `JsonObject` round trips.
- **Not changed; follow-ups for the owners:**
  - The Ability Studio callsite footer and `SemanticCallsitePresentation` show the call-map `instruction` (the CALL) for method calls. A `runtime_instruction` (method: instruction − 1, other calls: instruction) should be presented next to it, with the C# Dev fixtures updated.
  - The derecomp call-map schema could carry the same field.
  - Bootstrapper `LOADOUT_NATIVE_HOOK_CONFLICT_2026-09-27/scripts/test_mallet_contract.luau` and the `RENOVICE_LIVE_TESTS/F9_CHANGED_GENERATION_V72_2026-09-14` Elite fixture encode CALL indices. They should be marked superseded; no bootstrapper file was edited.
  - The runtime documentation (`NATIVE_TARGET_ADDON_HOOKS.md`, bootstrapper `dc15d9c`) already states the NAMECALL rule.
- Static and offline proof only. No gameplay claim is made. The Elite and Mallet live checks remain as described in their own notes.

## Install steps (the user runs them; only one file changes)

1. Close Warframe.
2. Copy `work/staging/elite-sanctuary-fix/64d11e6973afa4b1.EliteSanctuaryNoRank.target.addon.lua_B` (785 B, `4e6d5b71…90e3`) over `OpenWF\CustomScripts\Inject\64d11e6973afa4b1.EliteSanctuaryNoRank.target.addon.lua_B`. The rollback is `work/staging/elite-sanctuary-fix/rollback/` (`86eacb89…2ed1`).
3. Leave Ice Wave, Mallet (already fixed), Missions and Circuit untouched.
4. Live check: `ELITE_SANCTUARY_NO_RANK_U44_2026-09-29/README.md` §Live check (Elite Onslaught with a sub-30 Warframe and no Forma). Mallet: `MALLET_THREAT_CALLSITE_FIX_2026-09-29` §Live check (look for one `PushFloatArg.instruction-transform` and `native.float.transform … instruction=596`).
5. The editor example is a generator proof for a U43 target and is **not** installed.

## Hypothesis report

- **Hypothesis:** besides Mallet and Elite, other addons or generators filter on the CALL index.
- **Evidence:** 117 unique compiled addons and 37 sources were scanned against pinned stock IR, together with the live logs (four rotations) and the generator code.
- **Finding:** Partially true.
  - Among installed addons, only Elite is broken, and its fix is already staged. Ice Wave and Mallet are OK, and Missions has no instruction filter.
  - In the generators, the Ability Editor example, form and GUI defaults were OFF-BY-ONE (and used the rejected `nativeCalls.PushFloatArg` form). The Control Area validator locks were OFF-BY-ONE (latent) and the Mobile Defense comment was wrong. The derecomp call map and the Studio view number method calls by CALL, which is the provenance of the bug.
  - The historical U43 packages are OFF-BY-ONE and are left as dated evidence.
  - No OTHER-MISMATCH was found.
- **Rejected:**
  - "The Missions multi-target addon is affected": `luaCalls` carry no instruction.
  - "`mission_build_u44.json` instruction fields are callsite filters": they are byte-patch sites checked by expected bytes.
