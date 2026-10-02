# Authoring and code-generation contract

## Rule 1: choose the owner before generating code

| Question | Result |
|---|---|
| Is this only an existing numeric/formula change? | Quick native patch. |
| Is there a proven additive event with reliable cleanup? | Managed addon. |
| Does one exact stock Lua prototype expose the owned capture directly? | Exact Lua-call target addon. |
| Does one exact native callsite expose the stock-owned value or override result? | Exact native-call target addon. |
| Does addon gameplay also need a native ability-card row? | Managed addon plus same-VM ability-card attachment; use the minimal native projection only as the current compatibility fallback. |
| Must existing callbacks/control flow/authority change? | Native source replacement. |
| Is there no proven hook or API contract? | `NEEDS_BINDING`; do not deploy. |

The editor may recommend a mode automatically, but addon versus replacement is
also an explicit author choice. Automation cannot override a missing hook,
cleanup contract, or source binding.

## Rule 2: one canonical stat definition

Every displayed gameplay value has one definition:

```text
id
label
kind and canonical unit
base
optional min/max
mod affinity and evidence
gameplay consumer
native card projection
description policy
```

Percentages use fractions internally (`0.25` means 25%). Card projection
multiplies by 100 and supplies `UNIT_PERCENT`. Gameplay consumes `0.25`.

## Rule 3: DE owns mod evaluation

Use an existing value already computed by the target ability whenever possible.
Otherwise use `Engine.UpgradedValue` and an evidence-backed stock
`InventoryControl:ModifyValue` binding. Modifier selector numbers are not a
global enum until independently mapped and proven; a selector copied from one
ability must not be labeled Strength/Range/etc. elsewhere without evidence.

Base card mode uses the authored base. Modded card mode uses
`_T.AbilityLevelQueryParms.Avatar` and the same helper as gameplay. Clamp in the
same place and order for both consumers.

## Rule 4: native rows are projections, not a separate UI system

The editor generates ordinary row tables inside the target ability's
`GetAbilityUpgradeLevelInfo` and publishes the completed array through
`_T.AbilityUpgradeLevelInfo`.

```lua
table.insert(rows, {
    Label = stat.label,
    Value = statDisplayValue,
    ValueUnit = stat.nativeUnit,
})
```

The upper description is a separate metadata/localization projection and should
usually contain no exact numbers.

## Rule 5: addons may attach to a target ability card

The rejected `_T.RENOVICE_AUGMENT_ABILITY_CARD` experiment proved only that the
old global/cross-VM mechanism did not reach the target ability's UI producer.
It did **not** prove that addon-owned rows are impossible.

The 2026-08-24 target-scoped Mallet POC established the delivery shape. A
filename beginning with the target module's 16-hex original-body key and ending
in `.target.addon.lua_B` is staged after a successful natural target load. The
first live attempt proved that `(body key, global_state, owner thread)` was not
sufficient: the addon executed successfully but both gameplay and card hooks
were invisible. One DE VM may contain multiple closure environments. The
corrected binder therefore borrows the exact loaded target closure's `env` and
loads the addon closure into that environment; it never substitutes VM-wide
`_G` merely because `global_state` matches.

V49 retires the BardMusic `_T` dispatch fields. The single target addon owns the
conversion formula, Overguard mutation, Strength-scaled cap, labels, values,
native rows, and threat argument. The universal host exposes
`afterDamage(sourceAbility, reportedDamage)`, `afterAbilityCard(rows, query)`,
and `nativeCalls[method].before/after`; the target stock bytecode remains
unchanged.

The target architecture is a loader-mediated ability-card attachment:

1. the addon manifest identifies the target ability module/body key;
2. it declares card rows linked to the addon's canonical stat definitions;
3. when the target module naturally loads, the bootstrapper stages the addon in
   that module's exact owning VM;
4. the host observes the exact synchronous ability-card query, lets the stock
   producer finish, then passes its row array to `afterAbilityCard`;
5. declared native methods are resolved once from the SWIG catalog and invoked
   only for the addon's exact target body, VM, prototype, and instruction;
6. addon-generation cleanup removes only that generation's rooted callbacks
   and native declarations;
7. callbacks run only at their stock event/callsite boundaries, with no
   per-frame polling.

Therefore:

- addon behavior alone may remain addon-only;
- “addon behavior + show on native card” generates one target addon while
  leaving the stock `.lua_B` unchanged;
- an exact low-level numeric change may be represented by an evidence-bound
  `native_argument_rewrites` entry and emitted as `hooks.nativeCalls`
  (`PushFloatArg`, which the runtime adapter reserves, is emitted as
  `hooks.transformFloatArgument`). Its `instruction` is the logical index of the
  NAMECALL that names the method, because the runtime (V66+) reports a native
  call there and never at the following CALL. The project names the exact
  stock module in `target.stock_module`, and the `native-callsite-namecall`
  build gate rejects any site that is not `NAMECALL :method` followed by CALL
  (see `RESEARCH/CALLSITE_NAMECALL_AUDIT_2026-09-29`);
- the editor treats every produced artifact as one project, deployment,
  rollback, and acceptance unit;
- if neither a host callback nor an exact native callsite exists, the project
  remains `NEEDS_BINDING` or explicitly becomes a replacement.

Immediate F9 propagation of a changed target addon into every already-loaded
foreign VM is not yet claimed. The current target-addon generation is replaced
transactionally at the next matching natural module load; a restart is the
deterministic POC test boundary.

Mission-timer presets follow the same owner rule. Survival and Interception
generate exact target addons. Mobile Defense, Excavation, and all three Control
Area variants generate hash-pinned exact replacements because live evidence
falsified their earlier runtime or fallback-only edits. Mobile Defense changes
only the two stock `DefenseStage` duration `LOADN` operands. Excavation changes three `LOADN`
operands. Plains changes its root pacing owner and `SetObjTimer` argument. Deimos
changes its root pacing owner and the persisted result before the stock halfway
calculation. Venus/Nokko changes its timer argument and both linked threshold
results. These edits preserve the stock lifecycle and introduce no callback. A changed addon or replacement
is accepted only after a fresh load of the relevant mission; F9 does not replay
a stock initializer that has already completed.

Control Area is not treated as one universal 90-second script. Plains/Narmer and
Deimos have separate root pacing owners and separate persisted-duration
consumers. Venus/Nokko reads `defendTime` from mission-resource data; the editor
labels that stock value as dynamic and does not pretend it is a normal addon
global. Each preset may edit only its hash-pinned timer/pacing instructions, and
the stock code remains responsible for pause, progress, completion, migration,
enemy pacing, and cleanup.

## Rule 6: deterministic generation boundaries

Generated edits are anchored to resolved functions/IR nodes, expected source
hashes, and target body keys. Do not use unbounded textual search-and-replace.
If the source or installed build no longer matches the project binding, stop and
require rebase/regeneration.

Generated and user-authored sections remain distinguishable in the staged
project. Regeneration may replace generated sections but must never silently
overwrite a user-edited Lua section.

## Rule 7: API and hook evidence is part of the project

Every nontrivial API call/hook records:

- receiver/type;
- argument and return/callback shape;
- authority and lifetime assumptions;
- evidence ID/confidence;
- accepted live fixture, if one exists.

The 225 selected APIs and 175 high-confidence tier are authoring assistance,
not a claim that all methods are interchangeable on every object.

## Rule 8: transactional live deployment

A package build contains a manifest of every live path, previous hash, new
hash, and rollback artifact. F9 success requires the subsystem-specific proof:

- managed addon: generation committed and lifecycle accepted;
- full replacement/UI projection: native module refresh PASS, zero failures,
  zero pending work, committed module refresh;
- localization: server reload accepted and UI rebuilt;
- gameplay: explicit in-game behavior acceptance.

Compiler success alone is not live success.

## Example: Gyre movement-speed addition

User intent:

```text
Add 25% movement speed to Gyre and show it on an ability card.
```

Editor resolution:

```text
Canonical stat: 0.25 fraction
UI: 25 + UNIT_PERCENT
Gameplay: managed addon only if activation/cleanup hook is proven
Card: preferred same-VM addon card attachment; minimal native projection is the
      current compatibility fallback
Description: optional colloquial update
Package: managed addon with card attachment
Status: NEEDS_BINDING until ability, hook, authority, stacking, and mod affinity
        are explicitly selected and evidence-backed
```

The example intentionally does not invent a Gyre hook or movement API. Once
those bindings exist, the deterministic generator supplies both projections
from the same `0.25` stat.
