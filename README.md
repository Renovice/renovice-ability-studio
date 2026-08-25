# RENOVICE Ability Editor

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
| Managed addon + card attachment | Additive gameplay must also appear on a native ability card. | Managed addon plus an ability-card extension descriptor, attached to the target module in its owning UI VM without changing the stock bytecode. |
| Compatibility hybrid | The card-attachment bridge cannot bind the current build/ability yet. | Managed addon plus the already-working minimal target-module row projection. |
| Native source replacement | Existing functions, callbacks, loops, authority logic, or unsupported hook points must change. | Full keyed `.lua_B` replacement with native rows in the same source. |

The author may choose addon or replacement format directly. Automatic mode may
recommend the smallest viable form, but it must show the reason and allow an
explicit override. An addon is valid only when the target event and cleanup
contract are known. If an additive event is missing, either add a reusable hook
or choose a native replacement; never emulate the stock ability through polling.

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
- [Canonical native card-row and DE scaling guide](../../runtime/bootstrapper-runtime/RENOVICE_SCRIPTING/CARD_UI/NATIVE_ABILITY_CARD_ROWS.md)
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
opens the native Windows **Addon Creation / Linked Stats** screen. It currently
supports the proven numeric-damage-to-caster-Overguard action template and:

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

This is not yet the complete editor described above. The ability catalog,
arbitrary action templates, native-Lua workspace, atomic live deployment, and
rollback UI remain later checklist items. The current GUI intentionally stages
only; it does not silently copy an artifact into `CustomScripts/Inject`.

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
`work/builds/ability-editor/current`. The repo-local `build` name is a
compatibility junction. CMake downloads nlohmann/json 3.11.3 with a pinned SHA-256. Release
executables statically link the MinGW C++ and threading runtimes to avoid the
Git-for-Windows `libstdc++-6.dll` PATH-shadowing failure previously diagnosed
in the research tools.

CLI examples:

```powershell
& "..\..\..\work\builds\ability-editor\current\bin\renovice_ability_editor_cli.exe" self-test --editor-root "."
& "..\..\..\work\builds\ability-editor\current\bin\renovice_ability_editor_cli.exe" validate ".\EXAMPLES\mallet_linked_overguard_addon.json" --editor-root "."
& "..\..\..\work\builds\ability-editor\current\bin\renovice_ability_editor_cli.exe" build ".\EXAMPLES\mallet_linked_overguard_addon.json" --staging "..\..\..\work\staging\ability-editor" --editor-root "."
```

See
[`RESEARCH/LINKED_STAT_EDITOR_IMPLEMENTATION_2026-08-25.md`](RESEARCH/LINKED_STAT_EDITOR_IMPLEMENTATION_2026-08-25.md)
for the exact gate results, hashes, hypotheses, and current limitations.
