# Missions R15: Defense "Waves per reward" owned by its readers (2026-10-01)

- **Build:** client 44.0.2 (`2026.09.28.13.06`, `Warframe.x64.exe` `0124f0b9…`), U44 name-hash seed `768e5ed0`.
- **Branch:** ability editor `fix/missions-r15-defense-reader-pin-2026-10-01`, from R14 `c7f01f2`.
- **Runtime:** unchanged. Bootstrapper R13 `827027c`, installed DLL `e5d9b61b…`; the LIVE_LITERALS_V1 instruction-rewrite
  site form (`rewrites_instruction`) already exists in the shared patch core (`2fdda7b8…`, unchanged).
- **Research:** `work/research/defense-reward-interval-2026-10-01/README.md`, section "Live follow-up 2026-10-01 (R15)",
  native evidence `outputs/r15-live-followup/native_param_owner.txt` (tool `tools/native_param_owner.py`, read-only).
- **Status:** every offline gate PASS. **Nothing is live.** Staged `work/staging/combined-r15/`. Nothing deployed, nothing
  pushed.

## Live evidence that triggered R15 (session pid 20920, DLL `e5d9b61b`, addon `4c70b5ec`, package.json `65714ffb`)

`renovice_source.log`: `luaCalls.50.before.native-entry` for `1a1354d153712f9d`, `LUACALL_RETIRE … prototype=50 …
instance_env=0000023FC05A72B0 outcome=served-still-armed`, later `luaCalls.26.before` with the **same**
`instance_env=0000023FC05A72B0`; `SETTINGS DELIVERY … Missions values=2 staged=1`. EE.log (SolNode22, MT_DEFENSE,
DefenseMissionRewardsEasy, endless: no maxWaveNum): 581.400 `minWavesToComplete 3 -> 1`, 588.587 `_SleepBetweenWaves(6)`,
594.599 wave 1, 611.922 `_SleepBetweenWaves(6)` directly at the end of wave 1 (no `hostContinuing:`), 617.935 wave 2,
672.953 `_SleepBetweenWaves(6)` again. No addon re-activation or cleanup after the write (one `Inject PASS` only).

## Hypotheses and results

| # | Hypothesis | Result | Evidence |
|---|---|---|---|
| R1 | The end-of-wave decision is P48 state 299: `(wave - 1) % minWavesToComplete ~= 0` skips; else (endless, maxWaveNum 0) P46 resource reward and P36 continue/extract dialog. | **TRUE** | Readable L9204-9343 (state 270 increments the wave, 299 tests, 313/315 endless, 317 calls P46 then P36); P36 L5262-6107 opens `OpenMissionContinueDialog` and prints `hostContinuing:`. Bytecode P48 i1122-1125 GETIMPORT/SUBK/MOD/JUMPXEQKN. |
| R2 | The value is copied into a local/upvalue before the write (module or trigger load). | **FALSE** | All four reads are GETIMPORT at decision time (P48 i960/i1122, P36 i238/i307); no other instruction of 5,473 bodies names `69d6d911`. |
| R3 | GETIMPORT returns a load-time cached constant. | **FALSE (native)** | luau_load resolves an import only when the loader thread's globals are safeenv (RVA 0x191B80E); `lua_setsafeenv` has two callers, both fresh instance environments (0xF2948B, 0x191928C); `lua_setreadonly` is called only by `table.freeze` (no sandbox). So import constants stay nil and GETIMPORT always calls `luaV_getimport(cl->env)`. |
| R4 | The reader uses a different environment table than the one written. | **FALSE** | The env passed to the P50 hook and the env of P26 (called by P48 at wave start) are the same table `0000023FC05A72B0`; P48 is a root child of the same root run. |
| R5 | The checkpoint is driven by server data / the mission deck rotation. | **FALSE** | The dialog is client Lua (P36). OpenWF grants one reward per client-reported `rewardQualifications` entry (`missionInventoryUpdateService.ts` `getRotations`, A,A,B,C); it does not open or time the checkpoint. |
| R6 | The engine, not the entry write, owns the parameter in the instance environment. | **TRUE (native code; the specific re-applying call is not identified)** | `0x14181CAE0` writes `env[FNV(name)] = typed level value` into `getfenv(fn)`; drivers `0x14175C710` (ApplyScriptParams), `0x141280F60` (instance defaults, once before the first run), `0x140C6DD40` (generic script call, ~500 call sites, always re-applies) and the script-run loop `0x140A77E90` (re-applies to an existing instance before running it, without the busy check the entity path `0x1402EB8F0` has). By R2-R4 the decision reads the live table, and the read was not 1 at 611.9 s. |
| R7 | Pinning the four readers through the live-literal lane is a generic, runtime-neutral fix. | **TRUE (offline)** | New registrar site form `import_pin` (gate `IMPORT_READ_PIN_V1`): a single-name U44 GETIMPORT (0x35) of a hashed global becomes two LIVE_LITERALS_V1 `rewrites_instruction` sites (instruction word, aux word) → `LOADN A, N` twice; admissible only when the whole-module census of the hash equals the pinned reads. No runtime, shared-core or generator C++ change. |

## Change

- `tools/mission_owner_specs.py`: R15 drafts (`inputs/r15_row_drafts.json`, LF SHA-256 `56C3990C…7A3F8D99`) supersede the
  R12 draft of `defense.waves_per_reward` (reason recorded in the report); `import_pin_sites()` and
  `import_pin_complete()` (IMPORT_READ_PIN_V1).
- `tools/player_text_r10.py`, `tools/player_layout.py`: the row is a live literal (headline), text "Applies from the next
  mission".
- Registry `REGISTRIES/mission_build_u44.json` (667 rows; EXACT_LITERAL 252, TARGET_ADDON 350): `defense.waves_per_reward`
  backend EXACT_LITERAL, 8 sites, `applies: next_mission`, same limits 1-1000.
- New gate `tools/test_defense_reader_pin_harness.py`; `tools/test_entry_native_harness.py` (21 entry rows now; its R13
  Defense check modelled an environment only the addon writes and is replaced) and `tools/test_void_flood_tank_harness.py`
  (pins the R15 build of the same input).

## Package (staged `work/staging/combined-r15/`)

| File | Bytes | SHA-256 |
|---|---:|---|
| `Missions.targets.addon.lua_B` (34 targets, 109 hooks, 21 entry rows) | 113,164 | `70fff0b6606e452edc0825b7c58e594505f71576b887ee5cef97064079dcc2ed` |
| `package.json` (372 declarations incl. 30 masters) | 253,664 | `44fc0b53d0b71887f8a4fc5e9de41da2e88264c4591779ef57ba2de5feba21be` |
| `literals.json` (123 live literals; adds `defense.waves_per_reward`) | 177,507 | `a16b2520ea2e5762057e96bcef3fe94ae30ff72b272cf8a14d69b2cddc8e3c01` |

Build input: the R12 input unchanged (`MISSIONS_R13_NATIVE_ENTRY_2026-10-01/inputs/rebuild_input.r12.json`).

## Gates

| Gate | Result |
|---|---|
| `register_registry.py` → `player_text.py` (x2), then again | fixed point: registry `02442db2…`, data `A9379C88E56065D1`; report `import_pins` = P36 [238, 307], P48 [1122, 960] |
| `verify-missions` / self-test / ctest (generator binary unchanged, R14 build) | PASS 667 rows / 150/150 / 2/2 |
| Package build gates | `entry-parameter-keys` names=17; `multi-target-declared-keys` 34/34; `hook-plan` targets=34 hooks=109 entry_rows=21; `live-literal-core` `2fdda7b8…`; `live-literal-recipe` values=123 extreme_syntheses=246; `settings-layout` values=372 live_literals=123 quick=17; `settings-declarations` values=372 masters=30 |
| `test_defense_reader_pin_harness.py` (new) | PASS: synthesized WaveDefend for N=1,2,5 (4 reads → `LOADN A,N` x2, 24 changed bytes all inside the pinned 32, code size and slots unchanged, no instruction names `69d6d911`); derecomp render: stock 4 reads, pinned 0, state 299 `(wave - 1) % 1`; Luau decision path in the observed order: installed R14 addon + engine re-application → checkpoints 3,6,9,12 with the `3 -> 1` print (= live); R15 → every N whatever the environment holds |
| `test_entry_native_harness.py` | PASS, 103 checks (21 entry rows; the P50 hook leaves `minWavesToComplete` alone) |
| `test_live_literals.py`, `test_flow_gate.py`, `test_presets_and_sample.py`, `test_phase2d/2e/2k`, `test_void_flood_tank_harness.py` | PASS |
| Bootstrapper `verify_addon_settings.ps1 -Package/-Settings/-ScriptStates` (wt-r11 `827027c`; R15 Missions + installed Frost/Octavia, read-only copies of the installed values files and ScriptStates.json) | ADDON SETTINGS GATES PASS; `LIVE LITERALS RECIPE ACCEPT … values=123 plans=2`; `LIVE LITERALS PLAN … key=1a1354d153712f9d … patches=8 values=defense.waves_per_reward`; Missions `declarations=495 rejected=0 unknown_entries=6 members_staged=1/1` |
| Bootstrapper `verify_live_literals.ps1` | LIVE LITERALS GATES PASS (146 checks) |

## Limits (exact)

- **Nothing is live.** The live-literal synthesis (`LIVE LITERALS SYNTHESIZE`) has not appeared in any retained live log;
  R15 is its first live use.
- The decision rule is evaluated from the decompile with the pinned value read from the synthesized bytes; the DE VM
  does not run in the gate.
- Which engine call re-applied the level value in the failing session is not identified (R6). The fix does not depend
  on it.
- Same wrong-owner exposure for the other SCRIPT_PARAM_GLOBAL_AT_ENTRY rows whose readers run after a yield (research
  record, "Other parameter rows"); not changed in R15. Scaled rows cannot use a reader pin (per-level values); their
  generic owner is the native applier (RVA 0x181CAE0), a bootstrapper primitive not built here.
