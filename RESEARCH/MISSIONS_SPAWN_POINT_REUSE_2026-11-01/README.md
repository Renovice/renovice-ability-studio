# Missions: spawn point reuse (2026-11-01)

Build: client 44.1.3 (2026.10.22.13.12); registry build 2026.10.08.13.05 (the
EndlessSpawnLib body is byte-identical in both). Row `enemies.spawn_point_reuse`,
template `NATIVE_CALL_RETRY_AT_SPAWN_POINT`, Enemies > All missions >
"Spawn point reuse" (on/off, stock off).

## Hypothesis

Endless-spawn modes stop adding enemies when every nearby spawn point already
holds a living agent: the stock spawn helper passes no location, the native
spawn-point search skips occupied points and returns nil, and nothing spawns.
Retrying that one call with an explicit free-tag spawn point near the lead
player lets the enemy count keep rising.

## Evidence (static, read-only)

| Fact | Source | Result |
| --- | --- | --- |
| `Lotus.Scripts.Libs.EndlessSpawnLib` (body key `6f5169d34d076588`, SHA-256 `986B39C7...CCBB`) has exactly ONE `CreateRandomAgent` call: prototype 9, instruction 80, `director:CreateRandomAgent(nil, team, level, nil, eximusFlag)`. | stock bytecode; re-checked by `tools/add_spawn_point_reuse_row.py` (constant hash `d8af6c68` at P9 i80 and nowhere else) | TRUE |
| A nil location runs the native spawn-point search, which skips points holding a living agent (0x140d52569) and returns nil when all are taken. | 44.1.3 exe | TRUE (static) |
| An explicit point as argument 1 skips that search (0x141836a9f); CreateAgent has no occupancy check. | 44.1.3 exe | TRUE (static) |
| Director method `1ab54531` (no recovered name; binding 0x14207c110 -> wrapper 0x1419612c0 -> vtable +0x2a0) takes (type, minRadius, maxRadius, bool, entity) and returns a table of matching objects. | exe + AristocratManagerSpawnScript stock use | TRUE (static) |
| Stock precedent: AristocratManagerSpawnScript keeps points with `GetTag() == EMPTY_SYMBOL` and passes one as argument 1 of CreateRandomAgent/CreateAgent. | stock decompile | TRUE |
| The runtime target-addon contract admits `hooks.nativeCalls[<method>].after` on `.targets.addon` members, dispatches only for the exact target body, and copies after-phase results back as they are (no type filter), so a nil result may be replaced by an object. | bootstrapper `injection.cpp` `read_native_call_requests`, multi-target hook validation, `dispatch_native_call_phase` copy-back | TRUE (source) |
| A nested `CreateRandomAgent` from the callback reaches the original (addon frame is not a target callsite; recursive mutex). | bootstrapper contract notes | TRUE (source), live UNRESOLVED |

## Implementation

- Registry: module `6f5169d34d076588` added to `modules`; its stock body copied
  into the registry corpus `shared/corpus/de-luau-2026.10.08.13.05-authoring`
  (the update check rebuilds its corpus from `modules`, so no tool change).
- Name map: identity line `1ab54531	1ab54531` in
  `repos/toolchains/de-luau-toolchain/profiles/u44/name-map.tsv` (U44 hash, no
  U43 alias; precedent `5904fb7a`, `0a7324fb`).
- Generator (`src/mission_profiles.inl`): template constant, owner validator
  (`verify_native_retry_owner`), per-row Lua emission, `hooks.nativeCalls`
  emission (text without a native row is unchanged byte for byte), lane routing
  (a body with only native-call rows is not gated by the luaCalls binding),
  package declaration (not "template-only"), gates `native-call-alias` and the
  `hook-plan` native read-back (`native_hooks=N`; a native-only target counts as
  hooked). `src/core.cpp` self-test counts updated the same way.
- Generated Lua (per row): activate sets the live flag only when enabled AND the
  value is 1; the after callback returns unless live, prototype 9, result
  nil/null, stock location nil and host. Then lead player -> query
  `Name__1ab54531(gNpcSpawnPointType, 10, 75, true, player)` -> free-tag points
  -> random pick -> ONE `CreateRandomAgent(point, args 3..6)` inside pcall; a
  non-null agent replaces `results[1]`; one log line per generation; cleanup
  clears the flag. No state kept between calls, no polling.
- Search radii 10 m / 75 m: INFERRED choices (75 m = stock ActiveArea default;
  10 m keeps spawns off the player).

## Gates

- `verify-missions`: PASS 748/748.
- `tools/test_spawn_point_reuse_harness.py`: real generated addon in luau.exe
  with a fake runtime; off, Off-value, on, null result, stock agent, explicit
  location, wrong prototype, client, no lead player, no free point, failing
  retry, cleanup, new generation.

## Limitations

- Visibility of the chosen spawn point is not checked: enemies may appear in
  view of a player.
- Several enemies can stack on one point (no occupancy check by design).
- Whether CreateRandomAgent with an explicit point keeps faction, tier and the
  eximus choice exactly as stock: INFERRED.
- The stock "nothing spawned" print of the Lua spawn loop may still appear if
  the loop logs before the after-phase result reaches it: UNRESOLVED.
- Only EndlessSpawnLib callers are affected; other spawn paths are unchanged.

## Pending live check

Host a Survival run with the row on and Logging on: expect one
`RENOVICE Missions: enemies.spawn_point_reuse active` line once spawn points
saturate, a rising enemy count past the earlier plateau, and no new script
error or crash signature in EE.log. Then one adjacent stock check with the row
off (count plateaus as before).

Result: TRUE offline (static evidence + harness); in-game effect UNRESOLVED.
