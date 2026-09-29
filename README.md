# RENOVICE Ability Editor

Clone with submodules so the WPF editor can compile against the pinned Metadata
Editor decoder/core without depending on an undocumented machine-local path:

```powershell
git clone --recursive https://github.com/Renovice/renovice-ability-studio.git
```

Inside the complete RENOVICE workspace, the existing sibling
`repos/apps/metadata-editor` checkout remains authoritative. Outside that
layout, the project automatically uses
`external/WarframeMetaDataEditor`. Full catalog rendering and deployment still
require a `WORKSPACE.json`, the private stock corpus, metadata snapshots, and
the DE Luau toolchain; [`WORKSPACE.example.json`](WORKSPACE.example.json)
documents the expected relative layout without publishing those generated game
assets.

## Goal

This is the project-wide authoring layer for Warframe ability changes. Mallet
was the proof case, not the architecture. The editor must let an author:

- browse Warframes and abilities from installed metadata;
- make simple numeric changes without manually finding registers/constants;
- define new gameplay effects through a managed addon when a proven hook exists;
- edit a reconstructed native ability module directly when stock control flow
  must change;
- add native ability-card rows from the same stat definitions used by gameplay;
- edit the colloquial ability description separately;
- compile, validate, diff, deploy, reload with F9, inspect the live result, and
  roll back;
- choose an addon or native replacement explicitly, or accept the editor's
  deterministic recommendation based on the required hook and control-flow
  changes.

The editor is not a second decompiler, compiler, injector, or UI renderer. It
orchestrates the proven project components:

```text
Installed metadata + script corpus
        -> ability catalog
        -> authoring project (one source of truth)
        -> deterministic generators
             -> managed addon, when appropriate
             -> native module patch/replacement, when required
             -> native GetAbilityUpgradeLevelInfo rows
             -> description/localization override
        -> DeNativeDecompiler recompile and gates
        -> rollback snapshot
        -> CustomScripts / Inject deployment
        -> native-descriptor F9 refresh
        -> log and in-game acceptance
```

## Authoring modes

| Mode | Use when | Produced artifacts |
|---|---|---|
| Quick numeric patch | An existing native value/formula changes but control flow does not. | Minimal native module replacement; updated native rows if needed. |
| Managed addon | A proven lifecycle/event hook can add behavior without replacing stock control flow. | `.addon.lua_B`; no stock module replacement unless a hook must first be exposed. |
| Exact Lua-call addon | One exact target-module prototype owns the required captured value or table. | `.target.addon.lua_B` with body/prototype/capture locks and no stock module replacement. |
| Managed addon + card attachment | Additive gameplay must also appear on a native ability card. | Managed addon plus an ability-card extension descriptor, attached to the target module in its owning UI VM without changing the stock bytecode. |
| Compatibility hybrid | The card-attachment bridge cannot bind the current build/ability yet. | Managed addon plus the already-working minimal target-module row projection. |
| Native source replacement | Existing functions, callbacks, loops, authority logic, or unsupported hook points must change. | Full keyed `.lua_B` replacement with native rows in the same source. |

The author may choose addon or replacement format directly. Automatic mode may
recommend the smallest viable form, but it must show the reason and allow an
explicit override. An addon is valid only when the target event and cleanup
contract are known. If an additive event is missing, either add a reusable hook
or choose a native replacement; never emulate the stock ability through polling.

The Mission Timers screen uses the exact Lua-call mode for Survival. It keeps
the stock mission/keypad module and binds prototype 64 captures 19, 22, and 70
for reward elapsed time, pickup configuration, and reward configuration. The
old Survival full replacement is rejected after failing the live keypad/start
gate. V60's first addon reached the stock start path but exposed a generic host
bug by dispatching `after` on a yielded coroutine; V61 fixes that host boundary.
Studio now emits a before-only prototype 64 addon byte-identical to the deployed
V61 artifact.

Control Area is represented by three separate exact presets because the stock
game uses three different modules. Live testing proved that changing only the
Plains/Narmer or Deimos 90-second fallback leaves an already-populated network
value at 90 seconds. Studio therefore emits hash-pinned replacements that change
the verified stock pacing owner and the later authoritative timer consumer.
Venus/Nokko reads `defendTime` from mission-resource data that is unavailable as
an ordinary addon global, so its replacement changes the stock `SetObjTimer`
argument and the linked one-half and two-thirds threshold results directly.

## One edit definition, multiple projections

The author enters an effect/stat once. The project model records:

- target Warframe, ability, script path, body key, and expected source version;
- gameplay owner and authoring mode;
- event/hook, authority, lifetime, cleanup, and stacking behavior;
- canonical base value and optional cap;
- mod affinity and evidence-backed DE modifier binding;
- gameplay expression;
- native card label, numeric unit, icon, order, base expression, and modded
  expression;
- description text;
- required API contracts and confidence;
- build, deployment, rollback, and live-test state.

The editor then generates the required projections. It must never maintain an
unrelated “UI value” beside a separate gameplay value.

Example: “Gyre gains 25% movement speed while a selected ability is active”
may be authored as a managed addon if a reliable activation/cleanup hook exists.
If the user also enables “Show on ability card,” the preferred design attaches
a card-extension descriptor to that ability in its actual UI VM. The stock
module continues producing its ordinary rows; the extension appends more rows
through the same native row contract. The already-working minimal native
`GetAbilityUpgradeLevelInfo` projection remains a compatibility fallback until
that loader bridge is implemented and live-proven.

See:

- [Architecture](ARCHITECTURE.md)
- [Authoring and code-generation contract](EDITOR_CONTRACT.md)
- [Implementation checklist](CHECKLIST.md)
- [Machine-readable project schema](SCHEMA/ability_edit.schema.json)
- [Gyre conceptual example](EXAMPLES/gyre_movement_speed_addon.json)
- [Reusable hook and modifier evidence registries](REGISTRIES/README.md)
- [Instructions for future agents and contributors](AGENTS.md)
- [Canonical native card-row and DE scaling guide](https://github.com/Renovice/renovice-bootstrapper-runtime/blob/main/RENOVICE_SCRIPTING/CARD_UI/NATIVE_ABILITY_CARD_ROWS.md)
- [Addon gameplay and same-VM card-extension bridge plan](CARD_EXTENSION_BRIDGE_PLAN.md)

## Current status

The underlying mechanisms exist and are separately proven:

- readable/recompilable DE Luau pipeline;
- focused native API catalog and checker;
- keyed full replacements;
- managed addon lifecycle transactions;
- native ability-card rows;
- description overrides;
- native-descriptor F9 refresh for already-loaded gameplay/UI objects;
- rollback artifacts and live logs.

The first executable vertical slice now exists. `Launch Ability Editor.bat`
opens the polished WPF **RENOVICE Ability Studio** while keeping the C++ core
and CLI authoritative. The application now provides:

- explicit **ADDON** and **REPLACEMENT** authoring modes;
- a searchable ability browser generated from the metadata ownership graph,
  installed English localization, and exact stock corpus bytes;
- a separate searchable browser for examples and saved projects;
- target identity, effect, linked-stat, native card-row, and colloquial
  description editing;
- a monospaced generated-source view for addons and an editable native-source
  workspace for replacements;
- atomic project/source saves under `work/ability-projects/`;
- validation and staged builds through the same C++ CLI used by automation;
- visible diagnostics, generated source, build manifest, and output folder;
- staged builds by default, followed by an explicit transactional **Deploy…**
  action that verifies the artifact, snapshots the exact previous target, and
  replaces atomically;
- one-click rollback that refuses to overwrite a target changed externally.

The current catalog is not a hand-written list. Its C++ builder walks only
playable `PlayerPowerSuit` base-suit definitions, follows each ordered
`AbilityTypes` reference into the ability metadata object, resolves the primary
script/function/identifier/localization tags, maps the module into the stock
corpus, and computes the loader's deployed nonstandard FNV-1a body key from the
exact byte sequence. English display names are decoded from the installed
game's `Languages.bin` through the Metadata Editor's existing cache decoder.
The pinned 2026-07-01 metadata snapshot currently produces 62 Warframes and
248 abilities with 248/248 exact body keys. Selecting an ability lazily runs
the production Semantic IR module renderer; unresolved targets are visible but
cannot be converted into a buildable draft. Native Lua now opens the
human-readable identifier view and writes five adjacent provenance artifacts:
`<name>.fidelity.luau` preserves canonical value-web names and
`<name>.names.tsv` records every readable alias plus evidence-backed semantic
type, confidence, and provenance. `<name>.calls.tsv` records every rendered
call by exact `(prototype, instruction)` bytecode identity plus a contiguous
`source_occurrence`, effect order, callee, receiver, argument/result value
webs, readable/fidelity source spans, the receiver type with
confidence/evidence, the descriptor-join basis, and the matched Semantic SDK
contract without promoting unknown or ambiguous facts. `RECEIVER_TYPE` means
independent receiver evidence selected the descriptor; `UNIQUE_METHOD_NAME`
preserves a single name candidate without claiming that the receiver proved
ownership; `RECEIVER_TYPE_CONFLICT` keeps incompatible receiver evidence
visible.
One bytecode call can have several mutually exclusive expressions after
structured control-flow rendering; every expression is retained while corpus
totals count the underlying bytecode instruction once.
`<name>.closures.tsv` records the exact
parent instruction, child/constant operand namespace, target prototype, and
ordered upvalue captures for every closure site. `<name>.semantic-view.json`
hash-binds all five inputs, verifies token alignment, records exact UTF-8 source
spans, exact root exports and API callsites, and rejects every source difference except the two
fixed readable-view preamble comments and identifier aliases authorized by a
unique `(prototype, value-web)` identity. Source rendering consumes the
validated shared Semantic SDK and fail-closed closure mapper. The readable
source, fidelity twin, name evidence, callsite evidence, closure ownership map,
and semantic proof are activated as one recoverable six-file transaction. Its renderer and
planner share the toolchain executable with the raw lane, so every presentation
change requires a fresh raw fixed-point and release-gate certificate.

The **SOURCE WORKSPACE** keeps those roles separate: readable source remains
the replacement editor, fidelity source is read-only, API/value-web evidence is
searchable by prototype/type/confidence/evidence, and closure ownership is a
separate navigable table. The API Calls table selects exact readable or fidelity
expressions by proven byte spans and shows contract status separately from
callsite identity. The readable editor projects every proof-bound call span as
a subtle inline marker and exposes its exact identity, descriptor join,
receiver provenance, arity, parameters, returns, and evidence boundary in a
dark tooltip. `UNRESOLVED`, `AMBIGUOUS`, `OBSERVED_MISMATCH`, and
`RECEIVER_TYPE_CONFLICT` rows receive explicit warning markers; an unregistered
call remains informational because missing SDK evidence is not itself a runtime
failure. The marker layer is removed immediately when the editable source no
longer matches the hash-validated base. Loading an addon project with a resolved stock body key now
loads its verified stock module as read-only target context, rendering fresh
companions when the cached set is incomplete; the API Calls page therefore
does not depend on manually selecting an ability after startup. A changed editable source disables exact readable-call
navigation until regeneration or structural rebase. The API evidence index groups only strict
`semantic-sdk:lua:` descriptors and preserves live-confirmed, stock-bytecode,
catalog-only, and unresolved counts without relabeling identity rows as
callsites. The verified structural outline joins exact module exports and
closure ownership; it explicitly does not invent native-call edges or complete
function-body ownership. Identity/export/outline navigation uses proof spans
rather than text search while the readable hash is fresh. Each selected
identity shows its presentation status and behavior-evidence boundary. If the
editable source differs from the generated readable base, the provenance badge
changes to `BASE PROVENANCE — SOURCE EDITED`; exact navigation and future
automatic rewriting stay disabled until regeneration or structural rebase.
Missing or stale proof never produces a green badge.

Replacement projects now capture their first trustworthy generated source as
an immutable, hash-addressed six-file semantic bundle under
`source/generated-bases/<sha256-prefix>/`. `source/rebase-binding.json` binds
that baseline to the project's exact module body key and source hash. The
editor creates this binding automatically only when the verified base was
fresh when the document was opened; an older edited project with no provable
base remains unbound instead of silently adopting today's renderer output.

**Preview Structural Rebase** renders a fresh verified bundle from the same
stock bytecode and performs a fail-closed three-way comparison of the captured
base, the user-edited source, and the fresh generated source. Each user hunk
must have one proven prototype owner plus surviving boundary evidence from an
exact `(prototype, value-web, occurrence)` or
`(prototype, instruction, source_occurrence)` identity. Generator edits to the
same baseline region, missing/ambiguous ownership, missing/reordered anchors,
or target-context drift produce an explicit conflict and no merged source.
Non-overlapping edits are copied exactly into the fresh source. The **REBASE
REVIEW** page shows the original base, fresh generated source, user source,
merged preview, and every hunk/conflict. Applying is enabled only after a
zero-conflict preview; it recalculates the merge and all three hashes before an
atomic source save and baseline promotion. Reports use
`RENOVICE_STRUCTURAL_SOURCE_REBASE_V1` and are retained at
`source/rebase-report.json`.

The same engine is available without the GUI:

```powershell
dotnet run --project .\editor\Dev\AbilityEditor.Dev.csproj -c Release -- `
  --rebase-source --base <verified-base.luau> --user <edited.luau> `
  --generated <fresh-verified.luau> --output <rebased.luau> --report <report.json>
```

The baseline and generated paths must each have their hash-valid semantic
companions. A conflict returns exit code 1, writes the negative-evidence report,
removes any stale requested output, and emits no merged source. Rebase success
only proves safe source preservation across that presentation regeneration;
the result still has to pass replacement compile, reparse, exact DE round-trip,
API, manifest, and any intended in-game behavior gates.

The selected certification corpus contains **360 scripts**. Its final raw
`decompile-mod` inventory is 360/360 compiler-closed at both source and rebuilt
bytecode, and the hash-bound Ability Studio audit now accepts **360/360
semantic views** with zero rejects. All 2,160 coordinated artifacts were
published, no transaction temporary remained, and both executables and the raw
inventory stayed byte-identical throughout the audit. The semantic documents
record 290,002 authorized identifier-alias occurrences, 17,010 exact closure
sites, 6,765 exact exports, 143,691 distinct instruction-addressed API calls,
and 143,745 exact rendered call expressions. Of those bytecode calls, 26,068
join one SDK descriptor, 20,066 carry a confirmed descriptor, 117,623 remain
unregistered, none are ambiguous, and 132 are explicitly outside a known
observed call form. The join basis is explicit: 1,236 receiver-type joins,
7,801 unique-method-name candidates, and 434 receiver-type conflicts. The SDK
compact feed preserves non-contiguous catalog arities as exact sets rather than
widening them into minimum/maximum ranges. There are zero confirmed contract
violations. Twenty-seven unreachable prototypes in 15
files are omitted only from executable source because no live closure site can
instantiate them; both views must carry the same canonical prototype-ID
markers, and Ability Studio records those IDs explicitly or rejects the whole
transaction. The toolchain was rebuilt after the presentation changes and
independently re-passed raw 360/360, five default ten-cycle witnesses, all canonical
300/150 release gates, the 360-file zero-access-loss audit, and both 3,213-case
runtime-fixture configurations.

The fixed-point statement compares rebuilt cycle 2 with later rebuilt cycles.
It proves that repeated decompile/recompile no longer drifts for this pinned
corpus; it does not claim that rebuilt bytecode equals the original stock byte
stream. Compilation, parse, DE-container round-trip, semantic-plan, and
presentation-proof gates are offline evidence. They are not a new live-game or
full gameplay-behavior claim.

This is corpus-complete for the pinned 360-file sample, not for every local
stock module. A separate exploratory scan of all 5,386 local scripts found 20
ownership-manifest failures and 8 Semantic IR verifier failures among 82,059
prototypes; those unresolved rows remain negative evidence and were not hidden
inside the 360 result. Exact categories, hashes, and every selected corpus row
are documented in
`RESEARCH/SEMANTIC_BEAUTIFICATION_360_2026-09-05/STATUS.md` and
`RESEARCH/API_CALLSITE_INTEGRATION_2026-09-06/STATUS.md` and
`RESEARCH/SEMANTIC_SOURCE_WORKSPACE_2026-09-04/VERIFIED_SEMANTIC_VIEW_2026-09-04.md`.

The full-width **QUICK STATS** workspace edits the canonical project values
rather than keeping separate gameplay and card numbers. It exposes kind,
base/min/max, modifier family, exact evidence binding, native-row enablement,
unit, and order, with base/modded card preview. Modifier preview is fail-closed:
currently only `NONE` and the exact registry-scoped Mallet Strength contract
are executable; other modifier families stay blocked until evidence is added.

The **STOCK VALUES** workspace now discovers repeated numeric rank ladders from
the exact rendered module. Exact body-key/value-web bindings receive proven
names; unknown ladders remain visibly `UNRESOLVED`. Selected values can be
turned into a native replacement without hand-editing Lua. Arbitrary addon
generation remains blocked unless a real lifecycle hook is registered.

The **MISSION TIMERS** workspace provides body-key-locked exact target addons
for Survival and Interception. It provides hash-pinned exact stock-body
replacements for Mobile Defense, Excavation, and all three Control Area variants.
Survival
separates reward interval, enemy-pickup life-support refill, and optional
reward-clock progress. Mobile Defense exposes its difficulty-interpolated
minimum and maximum total time by changing only the two stock `DefenseStage`
`LOADN` operands; its terminal lifecycle stays byte-identical. Interception honestly exposes tower scoring
speed because ownership-driven rounds have no fixed timer. Excavation exposes
the separate standard, Old World Salvage, and Elite Alert dig durations.
Control Area exposes separate Plains/Narmer, Deimos, and Venus/Nokko targets;
the first two have exact 90-second root pacing values, while Venus/Nokko is
honestly shown as mission-resource configured. The clean cards show stock
values, faster examples, units, and plain-language effects. Excavation changes
only its three authoritative `LOADN` duration operands. Plains changes its root
pacing owner and exact `SetObjTimer` argument. Deimos changes its root pacing
owner and the persisted duration result before stock derives halfway timing.
Venus/Nokko changes the `SetObjTimer` argument and the exact one-half and
two-thirds threshold results. Every replacement preserves
the stock prototype count, instruction widths, constants, closures, and
callsites. No preset installs a timer loop or per-frame setter. Generated addons
pass compile/reparse, DE round-trip, semantic-plan, and focused strict API gates.
Exact replacements pass stock-hash, exact-byte-diff, DE round-trip,
semantic-plan, semantic-IR, and prototype-layout gates. **Build + Save Timer
.lua_B** opens a Windows save dialog, keeps the
editable manifest under
`work/ability-projects/<project-id>`, runs every build gate, validates the
staged manifest/size/SHA-256, and atomically exports one `.lua_B` to the chosen
folder. If the selected file already exists, its prior bytes are preserved
under `work/export-rollbacks/ability-editor`. See
[`RESEARCH/MISSION_TIMER_TARGET_ADDONS_2026-09-09.md`](RESEARCH/MISSION_TIMER_TARGET_ADDONS_2026-09-09.md).
The Control Area owner proof and generated-artifact hashes are in
[`RESEARCH/CONTROL_AREA_LIVE_RECOVERY_2026-09-11/README.md`](RESEARCH/CONTROL_AREA_LIVE_RECOVERY_2026-09-11/README.md).

Helminth identity is joined by exact ability asset path from the committed
`REGISTRIES/helminth_abilities.tsv` snapshot. The registry refresh tool reads
the official Wiki `Module:Ability/data` API and never guesses identity from a
display name.

The addon generator currently supports the proven
numeric-damage-to-caster-Overguard action template and:

- writes one canonical linked-stat project;
- generates the gameplay and native card projections from the same Lua stat
  definitions;
- resolves only registered hook/modifier bindings;
- compiles and reparses through `derecomp`;
- requires exact DE round-trip, zero plan failures, and the focused native API
  gate;
- writes a hashed package under the workspace `work/staging/ability-editor/`
  route and never writes to the live game. The repo-local `STAGING` name is a
  compatibility junction, not a second copy.

Mallet is the golden project in
`EXAMPLES/mallet_linked_overguard_addon.json`. The rate label/base/cap, native
unit, modifier binding, target identity, and output name are project data rather
than hardcoded card/gameplay literals. In the generated Lua, `0.01`, `0.05`,
and `15000` each occur once in canonical definitions; gameplay and card code
call the same accessors.

Native replacement projects now have a real gated pipeline rather than a UI
placeholder: source is recompiled to DE bytecode, reparsed, exact-round-tripped,
plan-verified, and checked against the focused native API catalog before a
hashed package is staged. This is still not the complete editor described
above. Live `Packages.bin` update/rebase detection, arbitrary action templates,
syntax-aware completion and automatic F9/log acceptance remain later checklist
items. Building still stages only. Live files change only after a separate
confirmation in **Deploy…**, and every deployment has a verified rollback
manifest before the atomic replacement occurs.

## Build and run

Double-click:

```text
Launch Ability Editor.bat
```

To rebuild explicitly:

```text
build_editor.bat
```

The build script resolves the workspace root and writes generated files under
`work/builds/ability-editor/current`. The polished executable is
`work/builds/ability-editor/current/studio/RenoviceAbilityStudio.exe`; the C++
CLI remains under `current/bin/`. The repo-local `build` name is a compatibility
junction. CMake downloads nlohmann/json 3.11.3 with a pinned SHA-256. Release
executables statically link the MinGW C++ and threading runtimes to avoid the
Git-for-Windows `libstdc++-6.dll` PATH-shadowing failure previously diagnosed
in the research tools.

CLI examples:

```powershell
& "..\..\..\work\builds\ability-editor\current\bin\renovice_ability_editor_cli.exe" self-test --editor-root "."
& "..\..\..\work\builds\ability-editor\current\bin\renovice_ability_editor_cli.exe" validate ".\EXAMPLES\mallet_linked_overguard_addon.json" --editor-root "."
& "..\..\..\work\builds\ability-editor\current\bin\renovice_ability_editor_cli.exe" build ".\EXAMPLES\mallet_linked_overguard_addon.json" --staging "..\..\..\work\staging\ability-editor" --editor-root "."
& "..\..\..\work\builds\ability-editor\current\bin\renovice_ability_editor_cli.exe" build-replacement ".\project.json" --source ".\replacement.luau" --baseline ".\verified-stock.luau" --staging "..\..\..\work\staging\ability-editor" --editor-root "."
& "..\..\..\work\builds\ability-editor\current\bin\renovice_ability_editor_cli.exe" build-catalog --metadata "..\..\..\shared\metadata\snapshots\packages-bin-data-2026-07-01" --corpus "..\..\..\shared\corpus\de-luau-stock" --output "..\..\..\work\catalogs\ability-catalog.json" --names "..\..\..\work\catalogs\Names.en.json" --editor-root "."
& "..\..\..\work\builds\ability-editor\current\bin\renovice_ability_editor_cli.exe" render-source --toolchain "..\..\toolchains\de-luau-toolchain" --bytecode "..\..\..\shared\corpus\de-luau-stock\Lotus_Powersuits_Bard_Abilities_BardMusic.lua_B" --output "..\..\..\work\rendered-source\ability-editor\08faf07b504d058f.luau" --editor-root "."
```

See
[`RESEARCH/LINKED_STAT_EDITOR_IMPLEMENTATION_2026-08-25.md`](RESEARCH/LINKED_STAT_EDITOR_IMPLEMENTATION_2026-08-25.md)
for the exact gate results, hashes, hypotheses, and current limitations.

## Mission timers and progression (2026-09-27)

The published Studio **Mission Timers** picker has twelve presets for build `2026.09.24.13.29`. Regular missions retain their previous presets, including:

| Preset | Control | Stock / faster example | Output |
|---|---|---|---|
| Netracells | Power per qualifying kill | 1 / 2 | Native metadata `.txt` |
| Descendia · Shrine offerings | Offering generation time | 30 / 15 seconds | Native metadata `.txt` |
| Descendia · Excavation | Powered excavator completion time | 45 / 15 seconds | Exact Lua replacement `.lua_B` |

Use **Build + Save Mission Edit** to choose a Windows destination. Metadata patches default to `OpenWF/Metadata Patches`; Lua replacements use `OpenWF/CustomScripts`. Existing destination files get rollback copies. These presets change gameplay progression, not server reward quantities. Netracell's parameter also affects the quest variant, which keeps its additional ×8 factor. Descendia's overall failure deadlines are unchanged.

Builds require exact current stock hashes. Excavation changes its completion threshold and the shared constant feeding migration, battery limits, remaining-time display and partial progress together. Whole-second durations are required. Offline validation passed; these new presets are not yet live-game confirmed.

### EDA / ETA section

Choose **Mission Timers → Section: EDA / ETA**. Six event subsections control EDA Survival time, Mirror Defense target defenses, Alchemy mixtures and Disruption conduits, plus ETA Survival time and Defense waves. Both normal and Elite versions share these settings. Stock defaults are unchanged; Faster Examples halves them. Survival values are whole minutes (10 stock); the other values are completion counts, not per-phase duration or reward quantities.

All six choices export as one ConquestLib replacement through **Build + Save Mission Edit**. Re-export that file to change either mode; separate files would compete for the same module. Restart after installation and generate a fresh mission chain. Regular Survival pickup settings remain shared, while its reward-rotation interval does not control Archimedea completion. Extermination, Assassination and Legacyte Harvest are unchanged by this preset. [Exact ownership, offline checks and live-test boundary](RESEARCH/ARCHIMEDEA_TIMERS_2026-09-27/findings.md).

## Linked ability stats (2026-09-27)

Select an ability, open **Stock Values**, and use **Discover**. Large cards show a label, stock value, editable value and unit. An editable control updates all verified gameplay and native-card assignments together; native mod scaling remains in place. **Create Replacement**, then Validate and Build through the existing source/compiler gates.

The generic C++ analyser now traces native card values through shared roots, helper returns, modifier wrappers and ability-stat storage to supported gameplay operations. A card label or stat-storage read alone does **not** authorize an editable control. Automatically linked values appear as **Base scale**, initially **1×**. Setting 2× scales every literal assignment of that base together, including defaults, ranks and PvP/variant branches; it is not a max-rank-only edit. Stock base values and the operation evidence are shown on the control. Unsupported/ambiguous traces remain read-only. Equal numbers or labels are never enough to merge variables.

`REGISTRIES/linked_card_stats.json` retains reviewed per-rank groups with exact source SHA-256 and body identity. These take precedence over automatic scales for the same root; changed registered sources require review. Dagath Rakhali's Cavalry Damage and Duration retain their eight reviewed rank controls.

The 23 cached-source audit additionally found four automatic controls: Lavos Vial Rush Damage/Second and Explosion Radius, Dagath Grave Spirit Time Invulnerable, and Garuda Dread Mirror Explosion Radius. All three automatically edited modules passed compilation, all-prototype plan verification and exact compiled-container roundtrip. This is bounded source-analysis coverage, not full-catalog or live-game certification. The older ability catalog remains separate from the current mission profile; automatic discovery does not migrate its build identities.

[Evidence, reproduction and remaining coverage](RESEARCH/CARD_VALUE_LABELS_2026-09-27/findings.md).
