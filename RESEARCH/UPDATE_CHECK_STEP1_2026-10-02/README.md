# Update resilience step 1: the post-update check (2026-10-02)

- **Client:** 44.0.2 `2026.09.28.13.06`, installed `Warframe.x64.exe` `0124f0b93516e60a…` (sideloadified), `B.Font.toc`
  `10cced56a9467274…` (5,473 `.lua` modules), `Packages.bin` `d0c66fc45872561a…`. Read only.
- **Installed RENOVICE set (read only):** DLL `WTSAPI32.dll` `304b57de…` (R17, bootstrapper `45ed7b0`), Missions R22 set
  (addon `a943cd3e…`, `package.json` `fd89daca…`, `literals.json` `9beaa438…`, `engine_params.json` `20323777…`), Frost,
  Octavia, 4 loose replacements, 2 loose target addons, 2 internal bridges.
- **Bootstrapper source checked:** `main` `f97215c` (`git diff 45ed7b0 main -- main.cpp main.hpp renovice OpenWF/tunables.json
  OpenWF/vv` is empty: the installed DLL's runtime sources are the ones checked).
- **Branch:** `feat/update-check-step1-2026-10-02` from R22 `4a9deeb`. Offline only: nothing written to the game or server
  folder, nothing deployed, nothing pushed.

## Hypotheses and results

| # | Hypothesis | Result | Evidence |
|---|---|---|---|
| U1 | Every per-build dependency of RENOVICE can be re-verified offline in one command from the installed client (exe, script cache, `Packages.bin`, `Hotfix.owf`, `CustomScripts`) plus the repositories, with an exact reason per item. | **TRUE (offline)** | The command below covers the six areas of the request (1,182 items on 44.0.2, about 15 s with caches); the mutation proof turns 7 synthetic breakages into BROKEN items with the expected reasons (16/16 expectations). |
| U2 | The installed 44.0.2 set is intact today. | **TRUE for every client-build item; FALSE for one registry row** | 1,181 OK, 0 UNKNOWN. One BROKEN: `server.credit_boost_multiplier`, a SERVER_CONFIG row pinned to the OpenWF server source (separate product); only the file's line endings changed, see Findings. |
| U3 | The hooks of an installed addon can be read from its own bytes, without its source. | **TRUE for the 5 installed addons** | `derecomp decompile-mod-u44` + the hook-table parser: Missions 35 targets / 110 `luaCalls` prototypes (= the generator manifest's 110 hooks); Mallet `PushFloatArg` P16 i596; Ice Wave `SetBaseAmount` P7 i42, `SetSource` P7 i53, `DamageDD` P7 i65; Elite Sanctuary `BuildMissionForLocation` P25 i9 and P21 i324; Circuit has no hook table (lifecycle only). Each callsite is a NAMECALL of that method in the stock module. |

## Where it lives and why

`repos/apps/ability-editor/tools/update_check/`, entry `renovice_update_check.py` (Python 3, standard library only).

- The ability editor owns everything the check validates on the content side: the mission registry and its CLI
  (`verify-missions`), the Missions package generator (`literals.json`, `engine_params.json`, the addon), the hook and
  modifier registries, and the authored addons (Frost, Octavia, Elite Sanctuary, Circuit). Step 2 (auto-remap) will
  rewrite registry owners and hook plans, which also live here.
- The bootstrapper's facts (signatures, per-build tables, allowlists, opcode profile copy) are read from its repository
  at a git ref with `git show`, never from its worktree. The bootstrapper's main worktree is checked out on an old branch
  (`fix/settings-r5-…`); reading `main` by ref keeps the check independent of that. Its C++ gates are not rebuilt or run:
  they need MSVC and refuse an uncertified client (`verify_client_44.ps1`) or require old images
  (`verify_engine_damage_codec.ps1` needs one image per registration). The check reimplements their exact rules in Python
  and points at them.
- Versioned in git with its baseline (`tools/update_check/baselines/2026.09.28.13.06.json`) and its mutation proof.

## The command

```powershell
python repos\apps\ability-editor\tools\update_check\renovice_update_check.py [--game <folder>] [--bootstrapper-ref main]
       [--write-baseline] [--exe <copy>] [--custom-scripts <copy>] [--stock-dir <folder>] [--stock-overlay <folder>]
```

Report: `work/diagnostics/update-check/<build>_<time>/update_check_report.md` and `.json`. Exit: 0 OK, 1 BROKEN, 2 only
UNKNOWN, 3 tool failure. Cache: `work/temp/update-check/` (stock extraction keyed by the `B.Font.toc` SHA-256 with recorded
content keys, the corpus walk, decompiled addons, the throw-away `verify-missions` editor root).

## What it checks (44.0.2 run, 1,182 items)

| Area | OK | BROKEN | UNKNOWN | Rules mirrored |
|---|---:|---:|---:|---|
| Build and allowlists | 11 | 0 | 0 | main.cpp build gate (`supported_builds_44`, `supported_client_sha256_44` as joaat in the installed `Hotfix.owf` msgpack `tunables.json`, title hash = `BOOTSTRAPPER_TITLE`; and in the source `tunables.json`), `game_versions.json` + `toonew`, `verify_client_44.ps1` certified table, `engine_damage_builds.hpp` (registration, `admit_codec`, the codec gate's vtable-slot checks: 29 DamageControl vtables, 126 health slots), `engine_params_builds.hpp` registration |
| Bootstrapper native signatures | 117 | 0 | 0 | DE_VM_AUTHORITY lock identity (thunks by import name, dispatcher +40 / epilogue cross-checks), luaCalls boundary (interrupt leaf 0x4C98E0 unique, owner callback 0x1919F90 unique and calling the leaf), 8 engine-param writer byte ranges, runtime native names (RunScript, PushFloatArg, SetDamageCallback, SetSourceObject, Initialize), OpenWF frame profile, undump raw offset 0x191A480, WTS proxy exports, census of 150 hex-pattern literals (96 match on 44.0.2; 54 version-gated/legacy rows had 0 on the baseline and are reported only if they start matching) |
| Game scripts | 77 | 0 | 0 | extraction, `Packages.bin` = registry, registry authoring corpus = this client (67/67), 74 referenced content keys |
| Installed RENOVICE content | 25 | 0 | 0 | runtime inventory rules (`injection_core.hpp` classify / multi-target string-pool keys, replacement filename keys, packages), U44 opcode walk of every installed file, package build labels |
| Addon hooks | 116 | 0 | 0 | 110 `luaCalls` prototypes (present; fingerprint = baseline), 6 `nativeCalls` callsites (NAMECALL of the method's U44 name hash at the logical index) |
| Mission registry and package | 826 | 1 | 0 | `verify-missions` with `corpus` redirected to the current modules (669/670 rows), 136 `literals.json` values (bootstrapper `live_literal_patch_core` verify + stock_error, stock size/SHA), 20 `engine_params.json` overrides (U44 hash, the module's recorded key uses at P/i), registry structure |
| Toolchain sanity | 9 | 0 | 0 | profile identity (toolchain = runtime copy), opcode walk 5,468/5,473 (the 5 known stale U43-format modules), seed 0x768E5ED0 in exe = OpenWF = registry = toolchain, `u44-rawhash-selftest` 15/15, `de-roundtrip-batch` 74/74 byte-exact, decompile/recompile/const-identity PASS on BardMusic, OmegaRerollSelection, TerritoryMission, DuviriUtil |

Prototype fingerprint (`uc_bytecode.Module.fingerprint`): SHA-256 (16 hex) over the 5 header bytes, size, child count,
canonical code and the constants with strings resolved to text and closure constants as a marker. It does not depend on
the prototype's flat index, other prototypes, the string pool order or line numbers, so an unchanged function keeps its
fingerprint when the module around it changes.

## Mutation proof (`test_update_check_mutations.py`, copies only, 16/16)

| Case | Mutation (current build bytes, on copies) | BROKEN item and reason |
|---|---|---|
| control | none | no client-build BROKEN |
| shifted prototype | SurvivalMission: copy of P0 inserted first | `scripts.content_key` "content key changed: the module is now 8b35849ccb1d64e3" (affects "Missions: Survival > …"); `hooks.lua_call` "prototype 67 fingerprint mismatch (…); the identical prototype is now 68"; 32 `verify-missions` rows "stock SHA-256 mismatch" |
| shifted callsite | BardMusic: copy of P0 inserted first | `hooks.native_call` "prototype 16 is now 17; callsite P17 i596 is still NAMECALL :PushFloatArg: re-key the target and move the callsite to P17"; `content.keys` for the Mallet No Cover replacement |
| changed literal preimage | extraction countdown LOADN 60 -> 61 | `missions.literal_recipe` "preimage changed at offset 6448: expected 08103c00 found 08103d00" (affects "Missions: All missions > Extraction (endless)") |
| removed function | TerritoryMission without P35 | `hooks.lua_call` P35 "no prototype with the baseline fingerprint remains (function changed or removed)"; P37 "the identical prototype is now 36"; engine-param override "P35 i1269 no longer uses roundEndTimer" |
| altered exe signature range | exe copy: one byte of the lock-enter thunk, one of push_value | `native.de_vm_authority` "lock-enter matches=0 thunks=2"; `native.engine_params.range` 0x191A010 "push-value-prologue-or-type-dispatch-mismatch"; allowlists and per-build tables "not registered" |
| changed content key | OmegaRerollSelection: one string byte | `content.keys` Riven Lock replacement "477479ee5209dc94 (…OmegaRerollSelection…: changed -> 3b1207462d596c71)"; `scripts.content_key` |

No old game build was used (workspace rule): every mutation is made from the current build's own bytes.

## Findings on the current install

1. **Server pin broken by line endings (BROKEN, server product):** `server.credit_boost_multiplier` (SERVER_CONFIG) fails
   `verify-missions`: `src/services/missionInventoryUpdateService.ts` in `OpenWF Server 23.09.2026/SpaceNinjaServer` no
   longer has the registry's SHA-256 (`5FE80633…`). The file was rewritten on 2026-10-02 18:24 with LF line endings
   (`32f3b475…` = git HEAD `e82caad7`); with CRLF it hashes to the pinned `5FE80633…` again. The content and both preimages
   are unchanged; the credit-boost value still works. The R22 record's 670/670 predates the rewrite. Fix: restore the
   CRLF working copy, or re-pin the row on LF content (better: pin LF-normalized content). Not caused by the client.
2. **Cosmetic log label:** the `luaCalls before observer` log line prints the fixed text leaf `0x1AB150` / owner-callback
   `0x197EC80`; on 44.0.2 the signatures resolve to `0x4C98E0` / `0x1919F90`. Resolution is by signature; no effect.
3. Pre-existing, unchanged: the OpenWF versioned signatures `check_string_substitutions` and `irc_send_raw` match 0 on
   U44 (already recorded in `DE_VM_AUTHORITY_LOCK_IDENTITY_44_0_2`; optional OpenWF paths).

## Limits (exact)

- Offline and static. OK means the recorded dependency still holds on these bytes; it does not prove in-game behaviour.
- Level and encounter parameter stock values (engine-param rows, level decode) are not re-derived; the check proves the
  module still uses the hashed parameter at the recorded instructions. Metadata rows are covered only through the
  `Packages.bin` SHA-256 and `verify-missions`.
- Callsite filters are read from the decompiled callback shape `if param0 == P … if param1 == I`. A callback without that
  shape is reported UNKNOWN, not guessed. The parser is tied to `decompile-mod-u44` output.
- The opcode permutation is checked by walking every module, not re-derived from the executable's dispatch table.
- SWF replacements are inventoried (none installed) but their keys are not checked.
- The signature census compares counts with the baseline; a multi-hit row whose count changes is UNKNOWN (review).
- `verify-missions` uses the built CLI in `work/builds/ability-editor/current` (not rebuilt by the check).

## What step 2 (auto-remap) needs from this tool

The baseline (`baselines/<build>.json`) and the JSON report already hold the remap inputs:

- **Modules:** per referenced content key: file, size, SHA-256 and the fingerprint and shape of **every** prototype
  (74 modules). With the new build's fingerprints this gives the old-to-new prototype map directly (the report already
  prints "the identical prototype is now N").
- **Hooks:** per installed addon and target key: `luaCalls` prototypes and `nativeCalls` (method, prototype, instruction).
  Step 2 maps them through the prototype map and, for callsites, finds the method's NAMECALL in the mapped prototype.
- **Natives:** signature counts per census row, native-name rows, the resolved RVAs (lock thunks, dispatcher, interrupt
  leaf and callback, push_value), the engine-damage accessor counts and evaluator hits; the probe rows show whether the
  previous registration's bytes still exist and where (`moved` RVAs).
- **Still missing for step 2:** literal-site context (the instruction index and prototype of each recipe offset, so a
  site can be found again by fingerprint + logical index instead of by byte offset), the root-table initialiser sites in
  the same form, and a per-prototype instruction-level diff for prototypes whose fingerprint changed. The registrar
  (`register_registry.py`) stays the owner of re-derivation; step 2 should drive it with the map, not edit the registry.

## Gates

- `renovice_update_check.py` on the installed 44.0.2: OK=1181, BROKEN=1 (server row), UNKNOWN=0, about 15 s with caches
  (about 60 s on a new build: extraction and the full opcode walk).
- `test_update_check_mutations.py`: MUTATION PROOF PASS 16/16.
- Baseline written by `--write-baseline` (refused while any client-build item is BROKEN; the server row is not a client
  fact).

## Follow-up

Steps 2 and 3 (auto-remap and rebuild, one command `renovice_update.py`): [UPDATE_RESILIENCE_STEP2_3_2026-10-02](../UPDATE_RESILIENCE_STEP2_3_2026-10-02/README.md). The literal-site and initialiser context listed above as missing is in baseline V2; the server pin is LF-normalized.
