# Authoring and code-generation contract

## Rule 1: choose the owner before generating code

| Question | Result |
|---|---|
| Is this only an existing numeric/formula change? | Quick native patch. |
| Is there a proven additive event with reliable cleanup? | Managed addon. |
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

For the current POC, BardMusic contains two reusable minimal dispatch points:
`RENOVICE_AFTER_MALLET_DAMAGE` and `RENOVICE_AUGMENT_ABILITY_CARD`. The single
addon owns the conversion formula, Overguard mutation, cap, labels, values, and
native rows. This proves addon ownership and repeatable generation, but it is a
compatibility hybrid because the target module still contains generic hooks.

The target architecture is a loader-mediated ability-card attachment:

1. the addon manifest identifies the target ability module/body key;
2. it declares card rows linked to the addon's canonical stat definitions;
3. when the target module naturally loads, the bootstrapper stages the addon in
   that module's exact owning VM;
4. the binder decorates the target `GetAbilityUpgradeLevelInfo` call, lets the
   stock producer finish, then appends ordinary native row tables to the
   published `_T.AbilityUpgradeLevelInfo` array;
5. addon-generation cleanup removes only its own decorator/rows and restores
   the previous callable when it still owns the attachment;
6. the attachment runs only when the card query runs—never through per-frame
   polling.

Therefore:

- addon behavior alone may remain addon-only;
- “addon behavior + show on native card” should generate an addon plus card
  extension descriptor while leaving the stock `.lua_B` unchanged;
- until that same-VM bridge is implemented and live-proven, the current minimal
  target-module dispatch-hook projection is a compatibility fallback, not a
  hard architectural requirement;
- the editor treats every produced artifact as one project, deployment,
  rollback, and acceptance unit;
- if the native module also needs an event dispatcher, the generated patch is
  explicit and reusable rather than hidden polling.

Immediate F9 propagation of a changed target addon into every already-loaded
foreign VM is not yet claimed. The current target-addon generation is replaced
transactionally at the next matching natural module load; a restart is the
deterministic POC test boundary.

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

The 150 selected APIs and 100 high-confidence tier are authoring assistance,
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
