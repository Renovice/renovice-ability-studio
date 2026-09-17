# Mission timer crash recovery (2026-09-11)

> **2026-09-12 correction:** live Mobile Defense execution falsified the
> prototype-22 `before` addon described below. After datamass insertion, the game
> reported `MobileDefense.lua::DefenseStage(910): attempt to index nil with
> number`, and the mission remained at `DATA TERMINALS 0/3`. The addon is retired.
> Mobile Defense now uses a hash-pinned exact stock-body replacement that changes
> only proto22/i120 `180 -> configured minimum` and proto22/i121 `240 -> configured
> maximum`. See
> [`MOBILE_DEFENSE_TIMER_LIVE_RECOVERY_2026-09-12.md`](MOBILE_DEFENSE_TIMER_LIVE_RECOVERY_2026-09-12.md).

## Scope

This investigation covers the deployed Ability Studio Mobile Defense and
Excavation timer addons and the related Mallet cover-bypass report. It does not
change the bootstrapper DLL or the generic replacement pipeline.

The live files were copied byte-for-byte into
`RENOVICE_DEPLOYMENTS/MISSION_TIMER_AND_MALLET_LOS_RECOVERY_2026-09-11/rollback`
before deployment work began.

## Hypotheses and results

| Hypothesis | Evidence | Result |
|---|---|---|
| The Mobile Defense addon is safely scoped to Mobile Defense. | The deployed source requested `hooks.nativeCalls.GetNetPersistentVar.after`. Runtime repeatedly reported `native hook adapter rejected GetNetPersistentVar bindings=2 originals=2`, while the user's controlled A/B report tied unrelated ability crashes to the presence of this addon. A native-method request has process lifetime and is wider than the exact mission closure that owns the value. | **FALSE** |
| Mobile Defense can use the stock value owner without replacing the mission. | `DefenseStage` is exact prototype 22. Stock calculates its total, then reads `CustomMissionTime` from `gGameRules` at instruction 139. A `luaCalls[22].before` callback can write the configured value through `SetNetPersistentVar` before stock performs that read. Existing positive values and `maxWaveNum` overrides remain authoritative. The user confirmed the unrelated-ability crash is gone. | **TRUE live for the reported crash** |
| The Excavation post-selector hook is safe across the mission coroutine. | The deployed `luaCalls[32].after` generated 557 `lua.call.after.skip` records for target `303f809a05c1fbaa`, all with `thread-status status=1` and `stock-resume-preserved=1`. The callback was waiting across yielded stock execution instead of editing a completed selector. | **FALSE** |
| Excavation has a usable non-yielding runtime capture for the selected duration. | The static closure map suggested prototype 43 capture 4. Live execution repeatedly emitted `luaCalls.43.before ... Excavation duration capture is not numeric`. The callback ran and failed closed, so stock timing remained active. | **FALSE live** |
| Excavation duration can be changed at its authoritative stock assignments without touching coroutine behavior. | The hash-pinned stock body assigns standard `100` at proto49/i76, Old World Salvage `60` at proto32/i81, and Elite Alert `140` at proto32/i102. Ability Studio now changes only those three `LOADN` operand bytes. All 50 prototypes, instruction counts, widths, constants, calls, closure layouts, and the separate Fast Dig value of 20 remain intact. After deployment and a full game restart, the user confirmed the configured accelerated Excavation timer works in game. | **TRUE live** |
| The deployed Mallet native callback disabled cover. | The addon contained `nativeCalls.RadialDamage.before`, but the accumulated live target trace contains zero Mallet `RadialDamage` callback events. Stock still sets both cover flags to true. | **FALSE** |
| Mallet cover can be disabled at the authoritative stock assignments. | BardMusic prototype 16 instructions 567 and 569 are the two `LOADB` instructions that supply `true` to `checkForCover` and `staticCoverOnly`; their following field writes are instructions 568 and 570. Changing only the two `LOADB.B` bytes from 1 to 0 preserves all prototypes, instruction widths, constants, callsites, damage logic, and exports. The user confirmed Mallet now damages through walls. | **TRUE live** |

## Implemented correction

Ability Studio now generates Mobile Defense as an exact prototype-22 `before`
hook. It writes the normal `CustomMissionTime` mission value once and installs
no native-call detour. Cleanup restores the earlier value only if the same game
rules generation still contains the value owned by the addon.

Ability Studio now generates Excavation as
`MANAGED_MISSION_EXACT_REPLACEMENT`. It verifies the stock body SHA-256 before
patching, edits the three authoritative `LOADN` sites, checks the exact binary
diff, then runs decode, DE roundtrip, semantic-plan, and prototype-structure
gates. The prototype-32 and prototype-43 runtime hooks are removed from the
active generator, managed model, schema, and project snapshot. Their sources
remain only as superseded negative evidence.

The Excavation replacement changes exactly these bytes for the current
50/50/50-second project:

| Absolute byte offset | Stock | Patched | Meaning |
|---:|---:|---:|---|
| `0x71B3` | `60` | `50` | Old World Salvage duration |
| `0x722F` | `140` | `50` | Elite Alert duration |
| `0x1113A` | `100` | `50` | Standard Excavation duration |

The Mallet package restores the live-accepted V57 Overguard/card/threat addon
and adds a direct BardMusic replacement whose only binary changes are:

| Absolute byte offset | Stock | Patched | Meaning |
|---:|---:|---:|---|
| `0x316A` | `1` | `0` | `checkForCover` value |
| `0x3176` | `1` | `0` | `staticCoverOnly` value |

This is an edit to the stock producer, not a helper shim or a parallel damage
system. The V57 target addon remains responsible for Overguard, card rows, and
the existing threat-level rewrite.

## API contract update

The stock corpus already supplied direct evidence for
`GameRules:GetNetPersistentVar` and `GameRules:SetNetPersistentVar`. They are
now explicit Semantic SDK contracts:

- `GetNetPersistentVar(key, [default]) -> any`, because different stock keys
  are consumed as different dynamic types;
- `SetNetPersistentVar(key, value) -> nil`, with mission-generation lifetime.

The evidence does not claim the native storage layout or universal multiplayer
replication behavior.

## Offline validation

An isolated semantic render of nested prototype 43 reported
`RENDER_UPVALUE_CONTEXT_MISSING`. This is expected for a nested prototype
rendered without its parent closure context and is not accepted as proof of a
runtime capture. The full-module closure map remained useful for locating the
consumer, while the live nonnumeric callback result overruled the inferred
capture binding.

- Ability Studio C++ test: 1/1 passed.
- Managed Ability Studio test: 102 passed, 0 failed.
- Mobile Defense: compile/reparse, exact DE roundtrip, semantic plan, and
  strict focused API gates passed; artifact 1,351 bytes, SHA-256
  `65542A75BA2F25BA3BB45810127536E606A1943E0D009A61AE068D336F9910AA`.
- Excavation exact replacement: 8/8 gates passed; 50/50 prototypes preserve
  their bytecode structure, all 6,994 decoded instructions are clean, all 50
  prototype semantic plans report zero failures, DE roundtrip is exact, and
  the only stock differences are the
  three operand bytes listed above. Artifact 75,895 bytes, SHA-256
  `0DB55FD7F51F9A97FB170391F59B96C571E4DA21AC8DDE2B3D69C56BD02DEFEC`.
- Mallet direct replacement: 22/22 prototypes re-encode exactly, all 1,924
  instructions validate, and the file differs from stock at exactly the two
  boolean bytes above; artifact 17,805 bytes, SHA-256
  `554F847CAD45ADB4AA46B2615EF0E1E68FBCC5BA3864F57A5DF087F363325CE5`.
- Mallet addon restored from V57: 2,732 bytes, SHA-256
  `36D2E3EC21E5879FBC0129A82139CF35E53D5FC95C8A82443D106EFF6FBDF049`.

## Live acceptance after the first recovery deployment

- The game no longer crashes from unrelated ability use with the Mobile
  Defense timer addon present.
- Mallet damages through walls.
- Excavation missions load and operate without the previous crash.
- Excavation remained at stock timing because the prototype-43 callback failed
  closed on a nonnumeric capture. This is the exact failure the new stock-body
  replacement removes.

After the exact replacement deployment and a full game restart, the user
confirmed that the accelerated Excavation duration works correctly in game.
This closes the final live acceptance gate for this recovery package.
