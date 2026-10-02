# Update resilience steps 2 and 3, script side: auto-remap and rebuild (2026-10-02)

- **Client:** 44.0.2 `2026.09.28.13.06` (`Warframe.x64.exe` `0124f0b9…`), read only. No real new build exists yet; every
  proof uses a synthetic build B made from COPIES of the 44.0.2 stock modules (workspace rule: no old real builds).
- **Branch:** ability editor `feat/update-resilience-step2-3-2026-10-02` from `main` `d2f0769` (step 1 merged). Offline
  only: nothing written to the game or server folder, nothing deployed, nothing pushed. The bootstrapper repository was
  not edited (the native side is another agent's work; read only through `NATIVE_INTERFACE.md`).
- **One command:** `python repos\apps\ability-editor\tools\update_check\renovice_update.py`.

## Hypotheses and results

| # | Hypothesis | Result | Evidence |
|---|---|---|---|
| S1 | Every script-level dependency (registry owners, luaCalls, nativeCalls, literal sites and preimages, root-table owners and hook plans, entry hooks and readers, engine-parameter readers, metadata consumers, replacements, authored addons) can be carried from build A to build B by function identity instead of by byte offset. | **TRUE (offline, synthetic B)** | Remap of 10 mutated modules: 137 auto, 8 review, 13 dropped, 857 unchanged dependencies; every auto item re-proven on the new bytes (below). |
| S2 | The registrar's own gates, run on build B with the mapped evidence, are a sufficient proof for an auto item; anything they cannot re-prove must not be carried. | **TRUE** | `verify-missions` 656/656 on the rebased registry; rows the gates reject go to review and are left out (fail closed). |
| S3 | An identity rebase (B = A) reproduces the registry byte for byte. | **TRUE** | Control run: rebased registry SHA-256 = repository registry `1e78d8b2…`; package rebuild = installed R22 files byte for byte; nothing to install. |
| S4 | The authored addons rebuild from their recorded sources with only the target numbers changed. | **TRUE for Mallet, Ice Wave, Elite Sanctuary** | All three sources rebuild the installed bytes exactly (`95d26a91…`, `f3ddb433…`, `4e6d5b71…`); rebuilt candidates differ only in LOADN immediates, decompiled hook tables = plan. |
| S5 | The installed replacements can be rebased automatically. | **PARTIALLY TRUE** | The three Octavia replacements are instruction-level edits (rebased, proven). The Riven lock replacement is a full rewrite (77 -> 81 prototypes): review, rebuild from `work/research/riven-multilock-2026-09-29`. |

## Matching strategy

Implemented in `tools/update_check/uc_remap.py` (standard library, reads the U44 opcode profile only).

1. **Module identity:** by file name (= module path). Same content key: unchanged, every index stays. Same file, new
   key: changed. No file: removed; a single new file with the same base name is reported as moved (review).
2. **Prototypes of a changed module:**
   - **exact:** step-1 fingerprint (header, size, canonical code, constants with strings resolved, closures as a
     marker) equal and unique; identical copies are told apart by their creation site (mapped parent, rank among that
     parent's same-fingerprint children), so a dead inserted copy never takes the place of the real function;
   - **similar (auto with a note):** score >= 0.86, lead over the runner-up >= 0.08, mutual best. Features: parameter
     and upvalue count, vararg, constant multiset (strings as text, numbers, name hashes, import paths, closures by
     fingerprint), NAMECALL methods, opcode histogram, CFG shape (branches, back edges, calls, returns), size, child
     count, debug name when present, parent consistency with the map;
   - **ambiguous (review):** best >= 0.55 but the rule above fails; **unmatched (dropped):** nothing resembles it.
3. **Instructions:** identical prototypes map index to index; a similar prototype is aligned with difflib on tokens
   (opcode, registers, resolved constants; branch offsets and child indices are left out because an insertion changes
   them). Equal runs map one to one; a same-length replaced run maps position by position ("modified").
4. **Constants:** identity for identical prototypes, else through the aligned instruction that uses them, else a unique
   equal value.

## Sites (registrar rebase, `RESEARCH/UNIVERSAL_MISSION_REGISTRY_2026-09-29/tools/rebase_registry.py`)

The registrar's specs name 44.0.2 positions; re-running `register_registry.py` on a new build would stop at the first
moved owner. The rebase carries the CURRENT registry's evidence through the map and re-proves every owner with the
registrar's own functions on the new bytes:

| Owner | Re-proof on build B |
|---|---|
| LOADN literal site | aligned instruction is a U44 LOADN of the same register; immediate = stock x num / den; a pattern anchor is resolved again by `phase2d.resolve_pattern` in the mapped prototypes and must give exactly the mapped sites |
| number constant | `anchors.exclusive_constant` (K_CONSTANT_EXCLUSIVE_V1) with the mapped use set, or `template_field` for a template value |
| IMPORT_READ_PIN_V1 pair | `mission_owner_specs.import_pin_sites` + `import_pin_complete` (census of the hash = the pinned reads) |
| root-table field | `addon_owner.RootTables.owner` / `element_owner` (ROOT_TABLE_UPVALUE_V1); capturing prototypes, upvalues, paths, containers and field reads must be the mapped ones; the minimal hook plan is recomputed by `hook_plan.plan_module` exactly as the registrar does |
| entry hook (R10) | `mission_owner_specs.root_child` per entry, `census` per reader = mapped instructions; hashed globals still referenced |
| Survival/Interception template | capture contract re-read from the toolchain closure map; `source_rewrites` and `current_prototype` follow the map |
| metadata consumer | re-keyed; hashed global still referenced; a changed `Packages.bin` sends the row to review (metadata update path) |

**Stock values:** when every site of a row reads one new number and the code around each changed site is unchanged
(aligned neighbours equal, anchor still exact), the stock is updated (`STOCK_CHANGED`, auto with a note) and the player
text is re-applied (`player_text.apply`, `player_layout.apply`). Sites that disagree, or a changed context, go to review.

**Value ids stay stable:** tunable and master ids are never renamed. Review and dropped rows are left out of the rebased
registry (listed in `excluded` with `UPDATE <build> review|dropped: <reason>`); `player_text.apply` / `player_layout.apply`
take an `absent` set (default empty: the registrar's normal run is byte-identical, fixed point re-checked). A saved value
of a row that is out stays in `Settings/*.json` and is ignored (`unknown_entries`) until the row returns.

**Not carried by the rebase:** prose fields (`evidence`, `label`) keep their 44.0.2 wording; only `P<a> i<b>` references
in site owner texts and the entry `backend_note` are rewritten. The registrar specs (`phase2d_lua_specs.py`, the R10+
drafts) still name 44.0.2 positions; re-deriving a review row means updating the spec as before.

## Step 3: rebuild (`tools/update_check/uc_rebuild.py`)

1. Staged editor root `work/temp/upd-<time>/editor` (REGISTRIES, SCHEMA, EXAMPLES, include copies; the rebased registry;
   corpus = the build-B bytes of the registry modules + METADATA_SNAPSHOT when `Packages.bin` is unchanged).
2. `verify-missions` (production rules). A failing row is sent to review and the registry rebased again (at most twice).
3. `build-missions` with the pinned input `MISSIONS_R13_NATIVE_ENTRY_2026-10-01/inputs/rebuild_input.r12.json` (build
   label = build B; ids that are out are left out). Every BUILD_GATES entry must PASS.
4. All presets through `build` (reference artifacts, not installed).
5. Authored addons (`authored_addons.json`): identity gate, callsite map, source rewrite at every callback filter
   (count must equal the installed addon's filters), `recompile-u44` x2 (deterministic), `de-roundtrip`, only-numbers
   delta vs the installed addon, decompiled hook table = plan; renamed to the new key, package member renamed,
   `settings.build` updated. Replacements: the step-2 rebase result (edit script re-applied, branch targets re-aimed,
   proofs: parses, differs from new stock exactly at the edited words, edited prototypes identical to the replacement's).
6. `ScriptStates.json` with renamed entries keeping their state.
7. Settings compatibility (read-only copies): every saved id declared, values inside the new limits; entries the
   installed package did not declare either are reported apart.
8. Step 1 again on a simulated install (copy of CustomScripts + the set) with the rebased registry: every BROKEN item
   must belong to a review item or to the native side.
9. Stage `work/staging/update-<build>-<time>/`: `README.md` (install, rollback, short live test, adopt), `UPDATE_REPORT.md`
   / `.json`, `install\` (mirrors the game folder), `rollback\`, `remove.txt`, `SHA256SUMS`, `evidence\`.

`--adopt <stage>` (after the live test) copies the rebased registry into `REGISTRIES/` and its corpus to
`shared/corpus/de-luau-<build>-authoring`; then `renovice_update_check.py --write-baseline` and commit.

## Baseline V2 (step 1 extension)

`tools/update_check/baselines/2026.09.28.13.06.json` regenerated (`RENOVICE_UPDATE_CHECK_BASELINE_V2`): plus
`stock_pack` (the build-A bytes of the 74 referenced modules, `shared/corpus/update-baseline-2026.09.28.13.06/`,
SHA-pinned; the remap reads them after the update), `literal_sites` (136 values, 338 sites: prototype + instruction or
constant, aux flag; 0 unresolved) and `root_table_initialisers` (327 rows, 336 fields; 0 unresolved). Step-1 run on the
install: OK=1182, BROKEN=0, UNKNOWN=0.

## Server pin (step-1 BROKEN item fixed)

`server.credit_boost_multiplier` pinned the CRLF bytes of `missionInventoryUpdateService.ts`; the git checkout now has
LF. The registrar pins the LF-normalized content (`sha256_text: "LF"`), `verify-missions` hashes the same way
(`sha256_text_lf`, `core.cpp`; a pin without the flag fails closed with "re-pin with the registrar"). Re-pinned through
the registrar (`register_registry.py`, `player_text.py` x2): only the server row changed (`schema_sha256` `1DF7CE8F…`,
`consumer_sha256` `32F3B475…`); registry `1e78d8b2…` (fixed point); `verify-missions` 670/670; `self-test` 166/0; the
R22 package rebuilds byte for byte (`a943cd3e…`, `fd89daca…`, `9beaa438…`, `20323777…`).

## Proof: synthetic build B (`tools/update_check/test_update_resilience.py`, 28/28 PASS)

One synthetic build with every case, plus a control run. Mutations (`uc_synthetic.py`, copies served by `--stock-overlay`):

| Case | Mutation | Result |
|---|---|---|
| control | none | every dependency unchanged, every gate PASS, nothing to install, registry byte-identical (exit 0) |
| inserted prototypes | SurvivalMission: 3 new functions first (P67 -> P70) | all Survival rows auto (exact); hook plan P70; preset rewrites `prototype == 64` -> `prototype == 70` |
| | IceSpike: 2 new functions first | Ice Wave rebuilt: P7 i42/i53/i65 -> P9 (6 gates PASS), renamed `cbea8b00….IceWaveColdStackDamage` |
| | BardAmplify: 1 new function first | Amp replacement rebased P11 i339 -> P12 i339 (exact) |
| moved literal | Arbitration: one new pool string (offsets +30) | resurrection score cap: 10/10 sites at offset + 30, same prototypes/instructions (exact) |
| changed default | Rescue P8 i20 LOADN 90 -> 100 | `rescue.hostage_timer.easy` stock 90 -> 100 (auto, STOCK_CHANGED); description re-rendered "stock 100" |
| changed context | WaveDefend: one of 15 Duviri wave-count copies 3 -> 4 | review: "the sites now encode different stock values [3, 4]" |
| moved callsite | BardMusic P16: 3 instructions inserted before i560 | Mallet rebuilt: PushFloatArg P16 i596 -> i599 (similar match, aligned NAMECALL); No Cover rebased i568/i570 -> i571/i573 |
| removed function | TerritoryMission without P35 | 9 Interception rows dropped (score rate, round timer, ...), Interception preset dropped, 3 engine-param overrides dropped |
| ambiguous | CaptureNew P17: one number changed + a near copy as a second root child | 4 capture target-health rows review ("ambiguous: best candidate 44 scores 1.00 (runner-up 1.00)") |
| full rewrite | OmegaRerollSelection changed | Riven lock replacement review (source project named) |
| unchanged | every other module | e.g. Elite Sanctuary addon and the Metrone replacement unchanged |

Synthetic run: 137 auto (93 registry rows, 4 nativeCalls, 13 luaCalls, 13 literal values, 2 addons, 2 replacements,
10 modules), 8 review, 13 dropped; gates 14/14 PASS: `verify-missions` 656/656, `build-missions` 9 named gates PASS,
presets 11/11, authored-compiler identity, both addon rebuilds, Settings compatibility (Missions 278/289 accepted; 5 unknown = the saved values of
rows now out; 6 not declared by the installed package either), step 1 on the simulated install OK=1156 BROKEN=2 (both
the Riven review item). About 55 s per run with caches.

## Integration with the native side

`work/research/update-resilience/NATIVE_INTERFACE.md`, block `renovice-native-interface` (read by `uc_native_iface.py`).
The script side wrote the expectation; the native side agreed to it unchanged and documented its tool
(`RENOVICE_TOOLCHAIN/native_update/renovice_native_update.py --game --out [--apply --build]`, result
`native_update_report.json`, exit 0 OK / 1 REVIEW / 2 BUILD FAILED / 3 TOOL ERROR, `staged_files` -> `install\`).
`renovice_update.py` calls it analysis-only by default, `--native-build` adds `--apply --build`;
`--bootstrapper-root` selects the tree (the entry is on the native branch's worktree until merged). Missing entry =
native set pending, the script set stays complete.

## Gates run for this change

- `renovice_update_check.py` on the install: OK=1182 BROKEN=0 UNKNOWN=0 (the server row is fixed).
- `test_update_resilience.py`: 28/28; `renovice_update.py` control on the install: ALL AUTO, 11/11 gates.
- CLI build (MSYS2 ucrt64, `-Werror`): 0 warnings; `verify-missions` 670/670; `self-test` 166 passed, 0 failed; ctest 2/2.
- Step-1 mutation proof `test_update_check_mutations.py`: 16/16.
- Registry harnesses on the repository state: 11 PASS (`test_void_cascade_exolizer_harness`,
  `test_engine_param_override_harness`, `test_entry_native_harness`, `test_void_flood_tank_harness`,
  `test_presets_and_sample` 12 presets / 36 rejections, `test_r17_type_masters_harness`, `test_r20_multiplier_minimums`,
  `test_flow_gate` regressed=0, `test_phase2d_gates`, `test_phase2e_gates`, `test_phase2k_hook_plan`). 2 cannot run in
  this workspace: `test_defense_reader_pin_harness` and `test_live_literals` read staged sets that no longer exist
  (`work/staging/combined-r14`, `work/staging/missions-full-package`); FileNotFoundError before any check, independent of
  this change. Their result files were restored (environment-dependent output not committed).
- Native integration: `renovice_update.py --bootstrapper-root repos\runtime\bootstrapper-runtime-wt-native-update` on
  the install: native OK (121 unchanged, 0 auto, 0 review, allowlist "already"), script side ALL AUTO 11/11.

## Limits (exact)

- Offline and static; no real new build has been processed. The thresholds (0.86 / 0.08 / 0.55) are tuned on synthetic
  mutations only and need a check on the first real update.
- The rebase re-proves what the registry records. A new owner a new build introduces (a value DE added) is not found;
  only existing owners are carried.
- Authored luaCalls hooks are not rewritten automatically (no installed authored addon uses them; review).
- Replacements with constant or string edits, new functions, or edited branches whose target has no counterpart: review.
- Metadata rows need the metadata update path when `Packages.bin` changes (review with that reason).
- The registry harness tests are pinned to the certified 44.0.2 registry; on a new build they run after `--adopt`, and a
  pin naming a 44.0.2 position is an intended difference to update deliberately.
- Synthetic container edits drop the line info of a function with inserted instructions (debug data only).
