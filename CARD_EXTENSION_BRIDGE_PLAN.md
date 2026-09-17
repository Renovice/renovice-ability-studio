# Addon gameplay and ability-card bridge plan

> Historical design record. V49 supersedes the `_T`/target-module dispatch
> portions with universal target-addon `afterDamage`, `afterAbilityCard`, and
> instruction-addressed `nativeCalls` hooks. See
> `RESEARCH/V49_LOW_LEVEL_NATIVE_CALLS_ABILITY_STUDIO_2026-09-07.md` for the
> current implementation and remaining live gates.

## Goal

Allow one editor project to add gameplay behavior and native ability-card rows
without requiring the author to rewrite the stock ability module. The author
defines one canonical stat; the system attaches its gameplay and UI projections
to the selected ability.

Reference behavior:

```text
Target: Octavia / Mallet
Event: each actual outgoing Mallet radial-damage result
Effect: grant the caster 10% of that result as Overguard
Card row: Damage To Overguard    10%
```

## What the working Mallet build actually did

The current live-proven implementation is a native BardMusic replacement:

1. it creates the canonical conversion and cap helper;
2. inside Mallet's packet-construction path it installs
   `RadialDamageData:SetDamageCallback` and consumes the numeric actual-damage
   callback result;
3. inside `GetAbilityUpgradeLevelInfo` it appends ordinary native row tables;
4. it publishes the finished array through `_T.AbilityUpgradeLevelInfo`;
5. the native-descriptor F9 system refreshes every captured gameplay/UI module
   context.

This proves the gameplay formula, callback contract, native row shape, modded
query, compiler, and F9 delivery. It does not prove a standalone addon bridge.

## Why the first card addon failed

`AbilityCards.addon.luau` successfully activated and installed
`_T.RENOVICE_AUGMENT_ABILITY_CARD` in the Inject generation's current VM. The
Arsenal card was produced by a different module instance/DE `global_state`.
That instance ran its own `GetAbilityUpgradeLevelInfo` and published its own
`_T.AbilityUpgradeLevelInfo`; it did not see or invoke the function installed in
the Inject VM.

The evidence therefore rejects a process-wide Lua `_T` assumption. It does not
reject a native, target-keyed bridge that deliberately delivers an extension to
the correct owning VM.

## Why gameplay also needs a bridge

The actual per-target Mallet damage value is delivered to a callback attached
to a `RadialDamageData` packet created inside BardMusic's pulse loop. A generic
addon does not automatically receive that temporary packet or its local
callback result. It needs one of these explicit extension points:

1. a reusable native/RENOVICE event such as
   `AfterAbilityDamage(targetAbility, caster, target, actualDamage)`; or
2. a small dispatcher placed at the specific BardMusic callback site; or
3. a generated structural overlay that inserts the dispatcher while preserving
   the stock source as the immutable input.

Option 1 is the strict no-module-replacement target. Option 2 is a one-time
module hook. Option 3 gives addon authoring semantics but technically produces a
composite runtime replacement.

## Required native card-extension bridge

The source bootstrapper already records exact module body keys, managers,
original descriptors, DE global-state identities, and owner threads for
multi-VM full-replacement refresh. Reuse that identity infrastructure, but do
not copy Lua closures or tables across VMs.

Each card-attached addon supplies a validated descriptor:

```text
addon ID
target ability identifier
target original body key
stat IDs
label/unit/icon/order
base-value function
modded-value function
expected installed build/source hash
```

At F9/startup, the bootstrapper stores the descriptor in a native C++ registry.
For every matching UI VM it creates a VM-local extension closure and roots it in
that VM only. When the game completes the selected ability's stock
`GetAbilityUpgradeLevelInfo` query, RENOVICE invokes the VM-local extension. The
extension reads `_T.AbilityUpgradeLevelInfo`, appends ordinary native rows, and
leaves the stock rows and renderer intact.

No filesystem polling or per-frame callback is required. Work occurs on module
load/F9 generation changes and on the existing ability-card query.

### Missing primitive that must be proven first

The current native-descriptor loader proves target identity and VM-local
delivery, but it does not expose a proven persistent module environment through
descriptor `+0x58`; that earlier interpretation was disproven. Therefore do not
implement a wrapper by assuming `+0x58` is an environment.

Investigate these interception points in order:

1. **Central post-card-query callsite (preferred):** locate the native client
   path that invokes an ability module's `GetAbilityUpgradeLevelInfo`. Hook its
   successful return, identify the target ability/module, and invoke the
   matching VM-local extension before the UI consumes
   `_T.AbilityUpgradeLevelInfo`.
2. **Proven module-export decorator:** only if exact disassembly/instrumentation
   establishes a stable way to access and restore the module's exported
   `GetAbilityUpgradeLevelInfo` callable in its owning VM. Never infer this from
   the obsolete descriptor field.
3. **Structural overlay fallback:** generate a minimal row/dispatcher insertion
   into the reconstructed stock source and deploy it through the already-proven
   replacement system.

## One editor stat, two generated consumers

The editor stores:

```text
id = mallet_damage_to_overguard
canonical base = 0.10
kind = FRACTION
gameplay event binding = mallet.actual_radial_damage
gameplay expression = actualDamage * stat
card label = Damage To Overguard
card value = stat * 100
card unit = UNIT_PERCENT
target ability = BARD_MUSIC
```

Changing `0.10` to `0.05` regenerates both consumers. If Strength affects the
stat, both use the same evidence-backed modified-value helper. A separate UI
literal is forbidden.

## Repeatable editor operation

```text
Select ability
  -> choose Add Effect
  -> choose a proven event binding
  -> enter canonical value/formula/cap/scaling
  -> enable Show On Ability Card
  -> enter label/unit/order
  -> editor selects or author overrides ADDON / CARD-ATTACHED ADDON /
     NATIVE REPLACEMENT
  -> schema and hook/API bindings validate
  -> gameplay and card projections generate from the same stat
  -> focused compile/reparse/round-trip/API gates
  -> rollback snapshot
  -> deploy one transaction
  -> F9
  -> live acceptance
```

The editor can automate any effect whose event and API bindings are in the
registries. A genuinely new event still requires one-time reverse engineering
and registration; after that, later projects reuse it.

## Acceptance test for the true addon bridge

Use stock Mallet bytecode as the immutable control and record its hash.

1. With no addon, stock Mallet and its stock card work.
2. Add the 10% damage-to-Overguard addon and press F9.
3. Actual Mallet damage grants exactly 10% Overguard.
4. The native card gains `Damage To Overguard 10%`.
5. Change only the canonical stat to 5% and press F9.
6. Both gameplay and the card change to 5% without restarting.
7. Remove the addon and press F9.
8. Gameplay addition and row both disappear; every stock row and behavior
   remains.
9. The stock BardMusic bytecode hash is identical before and after.
10. Logs show the exact target body key/ability, owning VM, one committed addon
    generation, zero failures, zero unresolved work, and successful cleanup.

Only this full add/change/remove sequence proves the no-replacement addon/card
architecture.

## Hypotheses and current results

| Hypothesis | Result |
|---|---|
| Native row tables and percent units are understood. | TRUE LIVE. |
| Actual Mallet radial damage is available through the numeric packet callback. | TRUE LIVE. |
| A Lua `_T` installed in one Inject VM is automatically visible to every Arsenal/UI VM. | FALSE LIVE. |
| Original module descriptor identity can refresh already-loaded gameplay/UI objects in their owning VM. | TRUE LIVE for the controlled Mallet full replacement. |
| Descriptor `+0x58` is a reliable module environment. | FALSE by exact U43 disassembly/live evidence. |
| A target-keyed native post-card-query extension can avoid replacing stock bytecode. | UNPROVEN; this is the next infrastructure job. |
