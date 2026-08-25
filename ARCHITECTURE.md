# Ability Editor architecture

## Professional shape

Build the deterministic editor core first and keep the GUI thin. The same core
must support a command-line build so generation and tests are reproducible
without clicking through windows.

```text
RENOVICE Ability Editor GUI
  Ability Browser
  Quick Stats
  Effects / Addons
  Native Lua
  Ability Card
  Description
  Build / Deploy / Live Log
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
             +--> CustomScripts and Inject
             +--> RENOVICE F9 native-descriptor loader
```

The GUI never writes live files directly. It asks the core to create a staged
candidate, show the diff, run gates, preserve rollback, deploy atomically, and
report the exact hashes.

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

- readable reconstructed source;
- syntax highlighting, search, function/prototype navigation;
- typed completion from `api/warframe`;
- inline confidence/evidence for native calls;
- original/generated diff;
- compile, reparse, plan, round-trip, and API diagnostics.

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
  -> CustomScripts/Inject/*.addon.lua_B
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

The first implemented proof uses the same package model with a compatibility
hybrid: a minimal target replacement exposes evidence-backed gameplay/card
dispatch points, while one target-scoped addon owns all feature behavior and UI
data. The bootstrapper recognizes
`<16-hex-body-key>.<name>.target.addon.lua_B` and activates a separate lifecycle
instance after each natural load of that exact module in that exact DE VM. This
removes the failed cross-VM `_T` assumption and is the deterministic template
the editor can generate today.

Target-scoped same-VM delivery is implemented and offline-proven, but the
strict stock-bytecode post-card-query interception remains an implementation
target, not a live claim. Do not assume descriptor `+0x58` is a module
environment. If the strict bridge cannot safely bind a particular installed
module, the editor may
offer the proven compatibility fallback: a minimal native module projection
that adds the row. That fallback must be labeled clearly rather than presented
as an unavoidable property of addons.

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
