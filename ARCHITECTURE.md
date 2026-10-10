# Ability Editor architecture

## Professional shape

Build the deterministic editor core first and keep the GUI thin. The same core
must support a command-line build so generation and tests are reproducible
without clicking through windows.

```text
RENOVICE Ability Studio WPF GUI (thin frontend)
  Ability Browser
  Quick Stats
  Effects / Addons
  Native Lua
  Ability Card
  Description
  Build / Deploy / Live Log
             |
             v
AbilityEditor.Core (managed, headless presentation/provenance layer)
  Six-file semantic proof loader
  Prototype/value-web/callsite source anchors
  Three-way source rebase + conflict report
  Immutable project baseline binding
             |
             v
ability_editor_core (C++)
  Project model + JSON schema
  Installed-build detector
  Metadata and script catalog
  Native API/type catalog
  Evidence-backed hook and modifier registries
  Stat normalization engine
  Code generators / structural patch planner
  Diff, validation, rollback, deployment
             |
             +--> DeNativeDecompiler derecomp.exe
             +--> focused API checker
             +--> OpenWF label reload
             +--> LuaScripts/Replacements and Addons
             +--> RENOVICE F9 native-descriptor loader
```

The GUI never writes live files directly. It asks the core to create a staged
candidate, show the diff, run gates, preserve rollback, deploy atomically, and
report the exact hashes.

The managed core owns source-presentation evidence already consumed by WPF and
also exposes it through the `editor/Dev` command line. Its structural rebase is
therefore headless and deterministic even though it is implemented beside the
semantic proof verifier. The C++ CLI remains authoritative for stock rendering,
project/build validation, compilation, staging, deployment, and rollback.

The implemented catalog boundary is similarly strict:

```text
Pinned Packages metadata JSON
  PlayerPowerSuit *BaseSuit only
    -> ordered AbilityTypes
      -> ability metadata asset
        -> Script.Script + Script.Function + UniquePowerIdentifier
          -> exact shared/corpus bytecode
            -> deployed nonstandard FNV body key

Installed Cache.Windows/H.Misc_en
  -> reused Metadata Editor TOC/Oodle/Languages decoder
    -> LocalizeTag to current English display name
```

The metadata graph, stock body, and localization provenance remain separate in
the catalog. A friendly name never substitutes for an asset identity or body
key. Source is rendered lazily through `derecomp semantic-ir-render-module` and
activated atomically only after that command succeeds with a non-empty output.

The WPF frontend intentionally mirrors the Metadata Editor's dark, searchable,
form-plus-preview workflow. It owns presentation and atomic authoring-file
saves only. Project validation, addon generation, replacement compilation,
semantic gates, package manifests, and future deployment transactions remain
owned by the C++ CLI/core so GUI and automation cannot disagree. The current
single-artifact transaction verifies `STAGED_PASS` and hashes, snapshots the
previous target, atomically replaces it, and provides guarded rollback. Future
multi-artifact packages must extend that same transaction boundary.

## Editor screens

### Ability Browser

- Warframe and ability search;
- name, description, icon/video, identifier, metadata object, script path;
- current stock body key and installed-build binding;
- reconstructed source status and confidence;
- existing native rows and their source expressions;
- active RENOVICE projects and live deployment status.

### Quick Stats

- edit existing base numbers;
- choose `NONE`, an evidence-backed DE mod binding, or a custom formula;
- choose optional min/max cap;
- preview base and modded values;
- select native unit/icon and row order;
- show generated gameplay and card expressions before building.

Quick Stats must be structural. It edits a resolved constant/expression owned by
a known function; it must not perform blind text or byte replacement.

### Effects / Addons

- plain-language effect description;
- target ability/event;
- duration and stacking model;
- host/client authority;
- lifecycle (`activate`, `cleanup`, recast, death, unload);
- native API calls with confidence and callback signatures;
- addon, card-attached addon, compatibility-hybrid, or native-replacement
  recommendation, with a manual mode override;
- generated hook/addon source and deterministic manifest.

### Native Lua

- readable reconstructed source from the verified Semantic IR renderer;
- an adjacent canonical fidelity twin plus per-value-web name/evidence TSV;
- syntax highlighting, search, function/prototype navigation;
- typed completion from `api/warframe`;
- inline confidence/evidence for native calls;
- original/generated diff;
- captured-base/fresh-generated/user-edited comparison, per-hunk structural
  conflicts, and a separately reviewable merged preview;
- compile, reparse, plan, round-trip, and API diagnostics.

`render-source` activates those three coordinated artifacts through one
recoverable transaction. The readable file is shown/edited; the fidelity twin
remains the exact diagnostic reference. Existing targets are restored if any
of the three activation renames fails.

### Ability Card

- colloquial description editor;
- list of stock and custom native rows;
- label, unit, icon, ordering, base preview, modded preview;
- link each row to its gameplay stat definition;
- show whether addon-owned rows bind through the same-VM card extension bridge
  or require the compatibility native projection on the current build.

### Build / Deploy / Live Log

- staged artifact list and hashes;
- validation results with no hidden warnings;
- rollback snapshot;
- target live paths;
- F9 instruction and live RENOVICE transaction status;
- `native module refresh PASS`, executed/failure/pending counts;
- in-game checklist and final accepted/rejected state.

## Runtime packages

### Addon-only package

```text
project
  -> generated managed addon
  -> compile
  -> LuaScripts/Addons/*.addon.lua_B
  -> F9 lifecycle transaction
```

Use only when no native card row or stock-module hook change is required.

### Managed addon with card attachment

```text
one project / one stat definition
  -> gameplay addon
  -> card extension descriptor
       - target ability module/body key
       - native row projections
       - generation ownership and cleanup
  -> loader targets the extension to the module's owning UI VM
       - a proven post-card-query interception point lets stock
         GetAbilityUpgradeLevelInfo run first
       - the VM-local extension appends ordinary native rows
  -> optional description override
  -> build and deploy as one transaction set
```

This is how a user-friendly editor can say “add 25% movement speed and show it
on Gyre's card” while keeping Gyre's stock script bytecode unchanged.

The current V49 proof uses one target-scoped addon for feature behavior, card
rows, and low-level native changes. The bootstrapper recognizes
`<16-hex-body-key>.<name>.target.addon.lua_B`, loads it in the exact target DE VM
and prototype graph, and exposes high-level `afterDamage`/`afterAbilityCard`
callbacks plus instruction-addressed `nativeCalls[method].before/after`
callbacks. A native callback receives the exact zero-based prototype and
instruction plus one-based mutable argument or result tables. The receiver is
argument 1. This removes the old cross-VM `_T` handler and target-module shim.

The editor stores simple low-level numeric changes as
`native_argument_rewrites`, including method, prototype, instruction, argument,
expected value, replacement value, and evidence ID. It generates the V49 hook
shape only after validating those identities. Since bootstrapper V66 the
reported `instruction` is the NAMECALL that names the method (the CALL is
`instruction + 1`); the `native-callsite-namecall` build gate verifies every
site against `target.stock_module` with `derecomp ir`/`ir-u44`, and
`PushFloatArg` rewrites are emitted as `transformFloatArgument` because the
runtime rejects `nativeCalls.PushFloatArg`
(`RESEARCH/CALLSITE_NAMECALL_AUDIT_2026-09-29`). Broader logic remains editable
as native Lua. The runtime rejects missing or ambiguous native implementations,
reserved hook conflicts, malformed callbacks, and partial detour sets. If a
particular installed build lacks a proven reusable native callsite, the editor
keeps the project at `NEEDS_BINDING` or uses an explicitly selected replacement.

V61 supports body-keyed `hooks.luaCalls[prototype].before/after` when a
closure map proves that one stock Lua prototype owns the required capture. The
`MANAGED_LUA_CALL_ADDON` and `MANAGED_MISSION_ADDON` project modes lock the
prototype and one-based capture indices; the runtime rejects missing or
ambiguous prototype matches before commit. Referenced table fields retain their
native ownership, while scalar copyback is limited to same-type finite numbers
and booleans. `before` runs on each exact entry/resume. `after` requires status
zero, valid active CallInfo bounds, and proof that the exact target closure has
left the active frame chain. Yielded, broken, errored, invalid-frame, and
status-zero still-active returns skip it so the stock coroutine can resume
unchanged.

The Mission Timers workspace uses this same generic runtime contract for
Survival prototype 64 and Interception prototype 35. Mobile Defense uses no
runtime callback: its exact replacement changes only the stock `DefenseStage`
minimum and maximum `LOADN` operands at proto22/i120 and i121. Excavation also
uses no runtime callback: its exact replacement changes the three hash-pinned `LOADN` assignments at proto49/i76
and proto32/i81+i102. Control Area has three body-keyed implementations:
Plains uses an exact replacement whose only edit is root proto17/i44
`LOADN 90`; Deimos uses an exact replacement whose only edit is root proto15/i56
`LOADN 90`. Their stock initializers still copy or derive every linked pacing
value. Venus/Nokko changes resource-backed global `defendTime` once at exported
`DefendStart` prototype 9, before its first stock action invokes prototype 6 to
read it. Each edit changes the verified owner once. Exact replacements preserve
the complete stock bodies except their enumerated duration operands, while the
addons retain the original mission/keypad modules. Source-recompiled timer
replacements are rejected; the general Replacement workspace remains available
for edits that actually require stock control-flow replacement.

The exact hypotheses, candidate interception points, and add/change/remove
acceptance sequence are in [the card-extension bridge plan](CARD_EXTENSION_BRIDGE_PLAN.md).

### Native replacement package

```text
reconstructed source
  -> structural change to existing function/control flow
  -> stat/card projections in the same module
  -> keyed full replacement
  -> native-descriptor F9 refresh
```

## Deterministic editor input

The ability editor is a normal GUI/CLI tool, comparable in spirit to the
Warframe metadata editor. It does not require an embedded AI assistant. For
“Gyre gains 25% movement speed,” its forms require the author to select:

- which ability owns the effect/card;
- whether the bonus is active-only, duration-based, or permanent;
- additive versus multiplicative movement semantics;
- whether Power Strength affects it;
- caster-only, allies, or squad;
- host/client authority;
- stacking and recast behavior;
- cleanup on expiry, death, mission transition, and F9 generation replacement.

The editor accepts only native APIs, callback signatures, modifier selectors,
and hooks backed by its local catalogs. Unknown bindings keep the project in
`NEEDS_BINDING` state and cannot be deployed as if verified.

Once research establishes a reusable binding, it is recorded under
`REGISTRIES/` with its precise scope, evidence, confidence, lifetime, authority,
and remaining acceptance work. Later projects reference the binding ID instead
of repeating the reverse-engineering or copying an unexplained selector.

## Build transaction

```text
Validate project schema
  -> resolve installed build and exact target source/body key
  -> resolve API and hook evidence
  -> generate in a staging directory
  -> compile and reparse
  -> plan-verify every replacement prototype
  -> exact DE round-trip
  -> focused API check
  -> show semantic/source diff
  -> create rollback snapshot
  -> atomically deploy all package artifacts
  -> user presses F9
  -> parse live transaction log
  -> accept or roll back the package as one unit
```

No file reaches the live folders when a required gate fails.
