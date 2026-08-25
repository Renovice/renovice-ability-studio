# RENOVICE Ability Editor project instructions

This folder defines the project-wide ability-authoring tool. Mallet is a
reference fixture, not a special-case architecture.

## Non-negotiable rules

1. Model one logical edit as one project, even when runtime constraints require
   multiple artifacts.
2. Store every gameplay/display value once in a canonical stat definition.
   Generate gameplay expressions and native card rows from that definition.
3. An addon may own ability-card rows without replacing stock bytecode once the
   loader-mediated same-VM card attachment is implemented and live-proven. The
   old global/cross-VM experiment is disproven; it is not evidence that a
   correctly targeted native loader bridge is impossible. Until that bridge is
   accepted, use the minimal native `GetAbilityUpgradeLevelInfo` projection as
   an explicitly labeled compatibility fallback.
4. Prefer an existing computed stock value. Otherwise use only a modifier
   binding recorded in `REGISTRIES/modifier_bindings.tsv` with sufficient
   evidence. Never treat raw selector numbers as universal enums.
5. Generate addons only from hooks recorded in
   `REGISTRIES/hook_registry.tsv`. A prose-only event name is not a hook.
6. Do not invent native APIs, callback signatures, ownership, authority,
   lifetime, stacking, or cleanup behavior. Unknowns keep a project in
   `NEEDS_BINDING`.
7. Use structural function/IR anchors and expected hashes. Never use blind
   whole-file textual replacement as the editor's production mechanism.
8. Keep the GUI thin. The deterministic C++ core and CLI own validation,
   generation, compilation, staging, deployment manifests, and rollback.
9. The GUI must never write directly to the live game folders. It stages a
   package, shows the diff, runs every gate, snapshots rollback, then deploys
   the package atomically.
10. Treat warnings and negative evidence as first-class results. Record both
    successful and disproven contracts so future work cannot repeat a known
    failure.
11. This is a deterministic GUI/CLI editor, not an embedded AI assistant.

## Per-edit acceptance model

Use a hypothesis -> evidence -> TRUE/FALSE conclusion for each nontrivial
behavior claim. A normal authored edit uses focused validation; it does not run
the entire ability corpus unless the evidence points to a shared compiler or
decompiler defect.

Required focused gates:

- project schema and binding validation;
- source compiles and bytecode reparses;
- every replacement prototype passes plan verification;
- exact DE container round-trip;
- focused native API check for intentionally authored code;
- rollback package exists before deployment;
- F9 subsystem transaction reports PASS with zero failures/pending work;
- intended behavior and one adjacent stock behavior pass in game;
- current EE log has no new relevant script exception or crash signature.

Live acceptance proves only the tested build, artifact hashes, environment,
and behavior. It does not automatically certify multiplayer authority or the
whole corpus.
