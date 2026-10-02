# Mallet threat 5: callsite off-by-one, re-attach and lag audit (2026-09-29)

- Client: 44.0.2 (`2026.09.28.13.06`), native-name seed `0x768e5ed0`.
- Runtime under test: installed `WTSAPI32.dll` SHA-256 `420e10a4…98f4da` (4,927,488 B, bootstrapper `fix/multi-target-live-run-2026-09-29` @ `8946bfd`).
- Evidence session: pid 23260, `renovice_source.log.1` line 19654 to the end of `renovice_source.log` (97,029 lines, 64.1 MB), with `Diagnostics=true` (trace mode) and `DiagnosticsMaxEvents=32768`.
- Installed files (read-only):
  - addon `Inject\ec368d4901690a15.MalletOverguardAndCard.target.addon.lua_B`, 3,383 B, `0acbfea2…aae5`;
  - root replacement `ec368d4901690a15 (Octavia Mallet No Cover exact flags).lua_B`, 17,835 B, `e8b3c6e7…7be5`.
- Stock `/Lotus/Powersuits/Bard/Abilities/BardMusic.lua`: extracted read-only from the 44.0.2 cache with `extract_u44_stock.py`, 17,835 B, `c713c4d6…299f`, 22 prototypes.
- Nothing was written to the game folder, the OpenWF server, or the bootstrapper repository.

## Results

| # | Hypothesis | Evidence | Result |
|---|---|---|---|
| R1 | The Mallet addon re-attaches repeatedly, like Ice Wave did before fix 2. | For key `ec368d4901690a15` in this session: 0 `TARGET ROOT RETURN`, 1 `TARGET ADDON PASS`, 0 FAIL, 0 ROLLBACK, 0 lifecycle FAIL. `attempt=3..42` counts the 40 per-beat damage-callback installs on stock `SetSourceObject` (40 `source.attach-return`, 40 `damage.install.native-return`). It is a process-wide trace correlation counter (`AddonTraceScope`), not an addon bind counter. | **FALSE.** The addon binds once. |
| R2 | Ice Wave still re-attaches under fix 2. | `8fba3a28f8fef624`: 0 ROOT RETURN, 1 ADDON PASS, and 2,703 `FROST_ICE_WAVE` lines, so Ice Wave was cast. | **FALSE.** Bind-once holds live. |
| R3 | Circuit activates under fix 2. | `95ef5b82a8400944`: 4 `addon lifecycle FAIL … RENOVICE_CIRCUIT_STAGE_XP_GETTER_NOT_FUNCTION`, 4 ROLLBACK, 3 PENDING ABORT, and 1 ROOT RETURN with `entry_env == runtime_env` (`…D2D7B910`). The retry in that environment failed again. | **FALSE.** Circuit is still not active. Fix 2's expected `A ≠ B` did not occur. This is a runtime issue for the bootstrapper owner. |
| R4 | Survival luaCalls failures remain. | 0 `leaf FAIL` and 0 `mutation rejected`. No Survival target addon bound this session, and the Missions multi-target file was inventoried only. | **UNRESOLVED.** There is no Survival evidence in this session. |
| T1 | The threat hook never runs (activation or environment failure). | `native hook adapter PASS … PushFloatArg=1`. `VM_MEMORY … label=transformFloatArgument calls=64` (sampled power-of-two counter, so 64 to 127 calls). | **FALSE.** The callback runs. |
| T2 | The callback runs but never changes a value. | The adapter logs `native hook PASS … event=PushFloatArg.instruction-transform` once, and traces `native.float.transform`, whenever the returned value differs from stock. Both occur 0 times in all four log rotations. | **TRUE.** |
| T3 | Cause: the addon addresses the CALL (i597), but the runtime reports the NAMECALL (i596). | `native_callsite_instruction_from_saved_pc` (`injection_core.hpp`) maps a CALL whose previous instruction is NAMECALL back to the NAMECALL's logical index ("the catalog addresses the NAMECALL"). In 44.0.2 p16, NAMECALL `:PushFloatArg` is logical 596 and CALL is 597; the addon tests `instruction == 597`. Live anchor from the same mapper in this session: 240 `ENGINE_DAMAGE … "SourcePrototype":16,"SourceInstruction":576` for `RadialDamage`, whose NAMECALL is logical 576 (CALL 577). | **TRUE (source + bytecode + log).** This is the root cause of "threat 5 never works" on U44. |
| T4 | The addon targets the wrong object. | p16 computes `floor(Lerp(5, 0, min(1, pool/1500)))`. When the integer changes, it runs `PushFloatArg(level)` and `creator:ActivateSecondaryScript(type, Symbol("SetThreatLevel"), args)`. Metadata `BardMusicAbility.SecondaryScripts` has `tag=SetThreatLevel`, `executionMode=EM_HOST`, `Function=SetThreatLevel`. p18 `SetThreatLevel` runs `_T.bardMusic[owner:GetInstance()].box:Name__dded29df(value)`. `dded29df` = FNV(`SetThreatModifier`, `768e5ed0`), and `ecb31eeb` = FNV(`SetThreatModifier`, `7e5af8e9`), which is the same method on U43. `box` is the `/Lotus/Powersuits/Bard/MusicAvatar` entity (a `LotusNpcAvatar`, `Faction=TENNO`, with no static threat field in composed metadata). | **FALSE.** The value handoff sets the Mallet entity's threat modifier, not Octavia's. |
| T5 | The value or semantics make 5 pointless. | Stock starts at 5 while the pool is empty. `floor(5 - 5·pool/1500)` falls to 4 as soon as the Mallet stores any damage, and to 0 at 1,500. So stock Mallet stops outranking Octavia as soon as it is shot. Keeping the modifier at 5 is exactly the missing behaviour. Corpus census (`MALLET_THREAT_SEMANTICS…2026-09-11`): 5 is the high "attract" value used by Loki Decoy, Nyx Absorb, Wukong Defy and others. It is a preference, not a hard target lock. | **FALSE as a blocker.** Whether 5 is strong enough in play is **UNRESOLVED (live)**. |
| T6 | The "No Cover exact flags" replacement interacts with threat. | IR diff against stock: only p16 i568/i570 `LOADB 1→0` (`checkForCover`, `staticCoverOnly`) change. There is no instruction shift, and the threat block (i578–602) is identical. | **FALSE.** |
| L1 | The lag is caused by re-attaching. | See R1. | **FALSE.** |
| L2 | The lag is caused by per-hit diagnostic records written synchronously. | Mallet window (tick 48346781–48367328, about 20.5 s): 2,050 `damage.callback.enter/return`, 697×5 `dispatch.*` (Diagnostics=true selects trace mode, so every positive hit is fully traced), 240 Mallet `ENGINE_DAMAGE` JSON lines (~770 B each), plus ENGINE_DAMAGE, TRACE and BUFF_LIST lines from other sources. Every line is written through `config::write_log_unlocked`: under the global config mutex, on the game thread, it runs `CreateFileW` + 2×`WriteFile` + `CloseHandle`. A Mallet beat therefore performs hundreds of open/append/close cycles in one frame. | **TRUE (source + log volume).** No timing profile was captured, so the frame cost per line is not measured. |
| L3 | Diagnostic tracing is bounded. | ADDON_TRACE is capped at `DiagnosticsMaxEvents` (32,768) per generation; ENGINE_DAMAGE at max/2 (16,384) per generation. Both reset on F9 or config reload. This session used ADDON_TRACE seq 8,020. The cap is on count, not rate, and per-hit records are not deduplicated or sampled in trace mode (only non-trace mode samples, through `sample_damage_trace`). | **PARTIALLY TRUE.** It is bounded by count, not by rate. |
| L4 | Nothing expensive runs with Diagnostics=false. | `trace_addon` returns on the first check. ENGINE_DAMAGE, CASTER_STATS, BUFF and memory lanes are masked by the master switch. What remains is operational (per-beat callback install, per-hit `afterDamage` dispatch, one `pushobject`) plus small formatting leaks: (a) `dispatch_target_hook` builds label strings on sampled calls (`addon_trace_detail_enabled` is thread-local and defaults to true outside a damage scope); (b) the `damage.performance` `ostringstream` is formatted every 2 s regardless of mode; (c) after this fix, `push_float_arg_adapter` formats `log_native_hook_once`'s identity string and a `details` stream on every transformed threat push. That happens only when the stock level changes, a few times per second at most. | **PARTIALLY TRUE.** Nothing heavy runs, but (a)–(c) break the AGENTS.md rule "no string formatting when off". Runtime spec below. |

## Fix (addon source only)

`mallet-threat.u44.luau`: `transformFloatArgument` now returns 5 at `prototype == 16 and instruction == 596`. Every other callsite keeps the stock value. No other source change was made.

- This is the authoritative value handoff. The stock formula output goes into `SecondaryScriptArgs` and then to the `SetThreatLevel` secondary script (EM_HOST), which calls `MusicAvatar:SetThreatModifier`.
- The stock push count and ordering are preserved: stock pushes only when its own integer changes, and each push now carries 5.
- There is no polling, no per-frame setter, no extra secondary-script call, and no runtime change.

Built with `derecomp.exe` `c1672d8d…7c58` `recompile-u44`. The source declares no seed and contains no `X__hex` names, so plain names hash with the U44 seed.

Staged artifact: `work/staging/mallet-threat-fix/ec368d4901690a15.MalletOverguardAndCard.target.addon.lua_B`, 3,383 B, SHA-256 `22e0cb4972f81050175b982cbef7c4d09a5a1fb2a1268c38172d45e151bf422a`. Rollback (the installed file): `0acbfea2…aae5`.

### Gates (`tests/run_gates.py`, all PASS; `evidence/gates.json`)

- Input identity: stock `c713c4d6…`, installed addon `0acbfea2…`, toolchain `c1672d8d…`.
- Stock p16 has exactly one `NAMECALL :PushFloatArg` (at 596, followed by CALL at 597), and `RadialDamage` NAMECALL is at 576, which matches the live anchor.
- Real-source contract test (upstream Luau; only `require` stubbed):
  - 596 turns inputs 0..5 into 5.
  - 597, 595, 576, p10 i64/i67, p15 i100/i103 and p18 i26 stay unchanged.
  - The damage and card hooks are present; there are no `nativeCalls` or `luaCalls`.
- Build: `recompile-u44` re-parses; two builds are byte-identical; the unmodified baseline source reproduces the installed addon byte for byte (`0acbfea2…`).
- `de-roundtrip`: 14/14 constants re-encoded, full body identical.
- `const-identity` against the installed addon (`--u44`): 14/14 prototypes equal for hashes, strings and key uses; verdict PASS.
- Delta: exactly one byte (offset 2952) and exactly one IR constant (`k[1] 597 → 596`, p10 `LOADK R4 <- 596`).

These gates prove the source, build and bytes. They do not prove gameplay.

## Runtime specification (NOT implemented; bootstrapper owner)

1. **Documentation defect.** `NATIVE_TARGET_ADDON_HOOKS.md` says the `instruction` is "the zero based calling instruction resolved from `savedpc - 1`". The implementation reports the NAMECALL's logical index when a NAMECALL precedes the CALL. The documentation should state the NAMECALL rule. `LOADOUT_NATIVE_HOOK_CONFLICT_2026-09-27/mallet-threat.u44.luau` and its test (which asserted `{16,596}` unchanged) encode the wrong index and are superseded by this record.
2. **Diagnostics-off formatting.**
   - In `push_float_arg_adapter`, build `details` only when `config::diagnostics_mode() != off`.
   - In `log_native_hook_once`, check a cheap per-(event,key,vm) flag before building the `ostringstream` identity.
   - Gate the `damage.performance` formatting on the diagnostics mode.
   - In `dispatch_target_hook`, compute `detailed_trace` as `mode != off && (…)`.
3. **Optional, for diagnostics-on cost.** Rate-limit or sample per-hit `damage.callback.*` and `dispatch.*` in trace mode, as non-trace mode already does, and/or keep the source-log handle open (or batch writes) instead of `CreateFileW`/`CloseHandle` per line. The line volume is acceptable to the user, but the per-line open/close is the frame-time multiplier.
4. **Circuit.** The fix 2 root-return retry saw `entry_env == runtime_env` and failed identically. Investigate where `module(...)` publishes `EndlessGetXpForStage` in 44.0.2 before another retry design.

## Live check (the user runs it; nothing was deployed)

1. Close the game. Copy the staged addon over `OpenWF\CustomScripts\Inject\ec368d4901690a15.MalletOverguardAndCard.target.addon.lua_B`. Keep `rollback/` for restore. Leave `renovice.cfg` unchanged (Diagnostics may stay true).
2. Start as Octavia, enter a mission with several ranged enemies, cast Mallet, and step away so that enemies shoot it for 10–20 s.
3. In `Logs\renovice_source.log`, read the latest session:
   - exactly one `TARGET ADDON PASS key=ec368d4901690a15` and zero `TARGET ROOT RETURN key=ec368d4901690a15`;
   - one `native hook PASS key=ec368d4901690a15 event=PushFloatArg.instruction-transform`;
   - with Diagnostics=true, `ADDON_TRACE … key=0xec368d4901690a15 … event=native.float.transform … prototype=16 instruction=596 stock=<0..4> transformed=5` (cast Mallet early; the budget resets on F9);
   - Overguard still works: `dispatch.results … mallet.c9v57.grant`.
4. Gameplay: after the Mallet has been shot, enemies should keep preferring it rather than returning to Octavia. Threat 5 is a preference, not a lock, so an occasional enemy on Octavia is not by itself a failure.

## Superseded or rejected

- The Mallet callsite `p16/i597` (U44_AUTHORING 2026-09-27; LOADOUT_NATIVE_HOOK_CONFLICT 2026-09-27) never matched the runtime's reported index. Superseded.
- `nativeCalls.PushFloatArg` is reserved and rejected (2026-09-27) and remains rejected. `luaCalls[18]` on `SetThreatLevel` is also rejected: the engine enters it through the secondary-script path, not through an observed Lua CALL.
- The editor example `EXAMPLES/mallet_linked_overguard_addon.json` still emits `nativeCalls.PushFloatArg` with U43 `i596` (the U43 CALL; the U43 NAMECALL is 595). The generator must emit `transformFloatArgument` with the NAMECALL index. It is not changed here.
