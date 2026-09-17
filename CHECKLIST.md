# Ability Editor implementation checklist

## Current linked-stat vertical slice — 2026-08-25

- [x] Native Windows Addon Creation / Linked Stats screen exists.
- [x] Deterministic C++ core and CLI share the GUI generation path.
- [x] Canonical fraction/cap definitions generate both gameplay and native
      card consumers; the generated Lua emits each numeric literal once.
- [x] Proven hook and modifier TSV registries parse and fail closed on unknown
      bindings.
- [x] `LINKED_DAMAGE_TO_CASTER_OVERGUARD` emits the V49 universal
      `afterDamage`, `afterAbilityCard`, and instruction-addressed
      `nativeCalls` contract with host-owned transactional cleanup.
- [x] Exact numeric native argument rewrites record method, prototype,
      instruction, argument, expected/replacement values, and evidence ID.
- [x] Focused C++ suite passes 78/78; the managed Studio suite passes 93/93.
- [x] Generated Mallet fixture recompiles/reparses, round-trips 9/9 prototypes'
      constants
      exactly, has zero plan failures across all prototypes, and passes strict
      API checking with zero unknown calls.
- [x] Hashed staging manifest records source/bytecode hashes and explicitly
      records `live_write_performed=false`.
- [ ] Explicitly live-test base and several non-base Power Strength values so
      `mallet.strength.channel_10` can move from
      `IMPLEMENTATION_VERIFIED` to `LIVE_CONFIRMED` for value progression.
- [ ] Add more evidence-backed action templates and modifier families; the
      current GUI must not imply that arbitrary unknown hooks are supported.

## Ability Studio shell — 2026-08-25

- [x] Metadata-Editor-style WPF application with searchable project browser.
- [x] Explicit Addon and Native Replacement modes.
- [x] Thin GUI delegates validation and builds to the authoritative C++ CLI.
- [x] Linked-stat table edits the canonical gameplay/card definitions.
- [x] Addon source is generated and read-only; replacement source is directly
      editable and atomically saved with its project.
- [x] Native replacement builds run recompile, reparse, DE round-trip,
      plan verification, and focused API gates before staging.
- [x] Diagnostics, source, manifest, and staged-output folder are visible.
- [x] GUI and C++ core model tests are part of `build_editor.bat`.
- [x] Explicit live deployment verifies staged hashes, snapshots the exact
      previous target, and uses an atomic Windows replacement.
- [x] One-click rollback restores the verified previous file or removes a
      newly introduced artifact; it stops if the live target changed outside
      the transaction.
- [x] Add a first-class Warframe/ability browser alongside the project browser.
      The current snapshot resolves 62 playable base suits, 248 localized
      abilities, and 248 exact stock-byte body keys.
- [x] Selecting a resolved ability exposes metadata identity, script path,
      entry function, body key, and lazily rendered Semantic IR source; an
      explicit action converts that target into an addon or replacement draft.
- [x] Mission timer creation opens a Windows save dialog, verifies the staged
      manifest/size/SHA-256, and atomically exports one selected `.lua_B`.
      Survival and Interception use exact target addons at verified exported
      owners or callsites. Mobile Defense, Excavation, and all three Control
      Area variants use hash-pinned exact replacements. Mobile Defense changes
      only proto22/i120 and i121, preserving its datamass and terminal path.
      Excavation changes three
      verified `LOADN` duration operands. Plains changes its root pacing owner
      and timer argument; Deimos changes its root owner and persisted timer
      result; Venus/Nokko changes its timer argument and two linked thresholds.
      Source-recompiled timer replacements
      remain rejected; the general Replacement workspace is unchanged.
- [x] Replacement API checks subtract hash-pinned stock call shapes and apply
      strict unknown/arity checks to call shapes introduced by the edit.
- [ ] Parse RENOVICE F9 transaction output and live EE logs directly in the UI;
      current deployment correctly leaves F9/restart and gameplay acceptance
      as explicit user actions.

## 0. Contracts and proof inventory

- [x] Full replacement compilation pipeline exists.
- [x] Managed addon lifecycle and F9 transaction exist.
- [x] Native ability-card rows are live-proven.
- [x] Native-descriptor F9 refresh for existing UI/gameplay objects is live-proven.
- [x] Description/localization override path exists.
- [x] Focused native API catalog/checker exists.
- [x] Project-wide editor architecture and schema are documented.
- [x] Initial reusable hook/modifier evidence registries and local contributor
      rules are documented.
- [x] Target-keyed managed-addon delivery is implemented and offline-gated by
      exact module key, DE VM, and owner thread. Live Mallet/Arsenal acceptance
      remains pending.
- [ ] Strength progression of the Mallet example is explicitly live-tested in
      base and modded views; this is evidence for the example, not a blocker for
      editor scaffolding.

## 1. Deterministic C++ core

- [ ] Load/save and validate `ability_edit.json` against the schema.
- [ ] Stable project IDs and version migrations.
- [ ] Canonical units and stat normalization library.
- [ ] Mod-binding registry with evidence IDs; unknown selectors fail closed.
- [ ] Parse and validate the checked-in hook/modifier TSV registries.
- [ ] Package planner recommends quick patch/addon/card-attached addon/
      compatibility-hybrid/native replacement and supports an explicit author
      override.
- [ ] Golden tests for valid and invalid projects.

Gate: every schema fixture is deterministic; invalid/unknown bindings cannot
reach generation.

## 2. Ability catalog

- [x] Deterministically select the latest workspace metadata snapshot; live
      `Packages.bin` build detection remains the next update/rebase step.
- [x] Import localized Warframe/ability names from the installed English
      `Languages.bin`, plus description key, identifier, metadata object path,
      script path, entry function, and exact loader body key.
- [ ] Import icon/video references into the catalog and surface previews.
- [x] Bind exact stock bytecode and lazily render verified reconstructed source.
- [ ] Bind active live replacement/addon deployment state to each ability row.
- [x] Preserve the Metadata Editor's cache/TOC decoder rather than introducing
      another TOC parser; installed localization extraction reuses its core.
- [ ] Diff/rebase projects after a game update.

Gate: every displayed editable ability has an explicit metadata object, script
path, body key, installed-build identity, and source status; unresolved entries
are read-only.

Current gate result: **PASS for the pinned 2026-07-01 snapshot** — 62 playable
base suits, 248 ability slots, 248 exact corpus bodies, zero unresolved modules.
The installed game supplies current English names, while the metadata object
graph remains pinned to the named snapshot until live `Packages.bin` catalog
rebuild/update diffing is added.

## 3. Quick Stats and native rows

- [ ] Discover existing native card rows and their value expressions.
- [x] Add/edit/remove canonical project stat definitions with explicit ID,
      label, kind, base/min/max, modifier family, evidence binding, card state,
      unit, and order.
- [x] Preview base and modded native row projections for `NONE` and the
      evidence-backed Mallet Strength binding; unsupported modifier semantics
      fail closed.
- [ ] Support percent, seconds, meters, multiplier, count, and raw amount.
- [ ] Support literal labels and known stock unit/icon keys.
- [x] Preview linked percent/raw values and cap behavior from the same
      canonical gameplay definitions.
- [x] Author the colloquial description separately from numeric rows.

Gate: generated rows use one gameplay stat definition, numeric native values,
correct units, query Avatar for modded mode, and publish the native row array.

## 4. Hook registry and addon generation

- [ ] Registry of proven events, callback signatures, authority, lifetime, and
      cleanup contracts.
- [ ] Managed-addon templates with idempotent activate/cleanup.
- [x] Reusable exact-callsite native argument-rewrite generator through V49
      `hooks.nativeCalls[method].before`.
- [x] Target-scoped `.target.addon.lua_B` manifest convention and natural-load
      same-VM delivery bridge.
- [x] Observe the exact synchronous ability-card query, preserve the stock row
      result, and dispatch `afterAbilityCard` in the exact target VM.
- [x] Bind target addons by exact body key, VM, owner thread, and prototype graph.
- [ ] Keep the minimal native card projection as a labeled compatibility
      fallback for unsupported bindings/builds.
- [ ] Extend F9 so changed/deleted target addons are delivered immediately to
      every already-loaded captured VM, not only at the next natural load.
- [ ] Stacking, recast, expiry, death, unload, and F9-generation cleanup model.

Gate: no addon is generated from a prose-only hook name; every hook/API is
bound to evidence and every persistent effect has deterministic cleanup. The
compatibility-hybrid path must show and remove its rows without duplicating
gameplay handlers. The later strict addon-only path must show its row after F9
without changing stock ability bytecode, then remove the row on cleanup without
disturbing stock rows.

## 5. Native Lua workspace

- [x] Prototype/value-web navigation backed by the readable naming map, plus
      fail-closed parent/target/capture navigation backed by `closure-map`.
- [x] Exact-span navigation and an export-aware root entrypoint outline backed
      by a hash-bound semantic proof; full nested function-body ownership and
      syntax highlighting remain pending.
- [x] Searchable native API, semantic type, confidence, and evidence table.
- [x] Strict Semantic SDK API evidence index with separate live-confirmed,
      stock-bytecode, catalog-only, and unresolved counts. These remain bound
      identity rows rather than invented callsite counts.
- [x] Verified prototype outline containing only exact module-export and
      closure-ownership relations, with proof-span navigation.
- [x] Selected-identity warning panel distinguishes presentation identity from
      the recorded behavior/type evidence grade.
- [ ] Native API completion.
- [x] Exact callsite contract/evidence tooltips expose the verified descriptor,
      join basis, receiver provenance, arity, parameter/return text, and
      evidence boundary without upgrading catalog-only or unregistered facts.
- [x] Instruction-addressed native callsite records with exact
      `(prototype, instruction, source_occurrence)` rows, distinct bytecode-call
      counting, receiver/argument/result value webs, evidence-graded contract
      joins, and verified readable/fidelity source-span navigation.
- [x] Receiver type/confidence/evidence and explicit descriptor-join basis;
      same-call name inference remains `UNIQUE_METHOD_NAME`, incompatible
      evidence remains `RECEIVER_TYPE_CONFLICT`, and exact catalog arity sets
      are not widened through minimum/maximum gaps.
- [x] Resolved addon projects automatically load or regenerate their stock
      target's verified six-file semantic context, so API Calls is populated
      at startup without a separate catalog selection.
- [x] Inline source markers and warnings for unresolved, ambiguous,
      observed-mismatch, and receiver-type-conflict calls. Unregistered calls
      remain informational, and every exact marker/tooltip is disabled when
      the readable source no longer matches its hash-validated base.
- [x] Structural generated-edit anchors and conflict detection: every edit hunk
      requires one hash-bound prototype owner plus surviving value-web or
      instruction-addressed callsite boundary evidence; overlapping generator
      changes and all missing/reordered/ambiguous anchors fail closed.
- [x] Original, fresh-generated, user-edited, and merged-preview comparison
      views with per-hunk prototype, line mapping, status, and conflict code.
- [x] Preserve user-owned code during regeneration: non-overlapping hunks are
      transferred exactly, conflict produces no merged source, and Apply
      rechecks all three hashes and the merge result before atomic save.

Current source-workspace gate: **PASS on stock BardMusic/Mallet** — coordinated
rendering is deterministic for readable, fidelity, naming, closure, and
semantic-proof artifacts. The proof aligns 15,448 tokens and permits exactly
598 evidence-authorized identifier alias occurrences plus two fixed provenance
comments, with zero unauthorized identifier or non-identifier changes. It
records 630 exact source occurrences, preserves 32 canonical occurrences,
leaves 372 non-materialized rows sidecar-only, validates 16 exact root exports,
and hash-binds the 572-row naming map to 21 closure sites and 46 ordered
captures. Both source views recompile/reparse and their 22-prototype DE
containers round-trip exactly. This is structural/tooling proof, not original
bytecode identity and not a new live-game behavior claim.

Current selected 360-script corpus gate (`derecomp`
`60157E2FD66E884E089AA7762AA7C5CD79C67748A502B7885FF6FEAE5AB46D6C`):
**360 verified / 0 rejected**. Every selected script passes the six-file
transaction, both source recompiles/reparses, both exact DE-container
round-trips, and both semantic-plan gates. The managed coverage audit rehashed
all 2,160 retained artifacts, reloaded every proof/map, checked every mapped
UTF-8 token and API-expression span, and found no temporary files. The API map
contains 143,691 distinct bytecode calls and 143,745 rendered expressions;
26,068 calls join a unique SDK descriptor, 117,623 are explicitly unregistered,
none are ambiguous, 132 are outside an observed form, and zero are recorded as
confirmed contract violations. The target evidence audit keeps 189 exact rows:
all 132 observed mismatches, 54 selected open-width rows, and three formerly
ambiguous `DamageControl` calls now selected as `Avatar:DamageControl` by
independent receiver evidence. It added no speculative overloads. Mixed plaintext/hash name
collisions now receive deterministic lossless aliases; 27 unreachable orphan
prototypes in 15 files are omitted only when readable and fidelity views carry
the same strict prototype-ID markers; terminal numeric-for fragments, literal
base indexing, and the remaining valid nested loop-role alias render
structurally. The raw fixed-point inventory remains **360/360**, with an
additional 5/5 default difficult scripts passing ten cycles. This closes the selected
360 gate; it does not assert that all 5,386 local corpus files pass the same
semantic gates or that the generated sources reproduce the original stock
byte stream.

Gate: a source-hash mismatch blocks automatic rewrite until rebase; no blind
whole-file textual replacement. Structural rebase focused gate: **82/82
managed checks PASS**, including a real 26-hunk verified Mallet presentation
change, safe preservation of a separate user edit, rejection of a user edit in
the same generated region, rejection of an unrelated verified module,
immutable baseline capture, report emission, and zero-output conflict behavior.
This is source-preservation proof; replacement
compile/round-trip and runtime behavior remain separate gates after Apply.

## 6. Build, validation, deployment, and rollback

- [ ] Recompile and reparse.
- [ ] Plan-verify every replacement prototype.
- [ ] Exact DE container round-trip.
- [ ] Focused API check.
- [ ] Package-level warning/error summary.
- [x] Atomic rollback snapshot and live deployment manifest.
- [ ] F9 trigger guidance and live log parser.
- [x] One-click rollback for the current single-artifact addon/replacement
      package; multi-artifact transaction sets remain the next extension.

Gate: no failed/warning-required artifact deploys; live acceptance records
exact hashes and subsystem-specific F9 evidence.

## 7. GUI

- [x] Ability Browser.
- [x] Quick Stats for canonical project stats and evidence-scoped preview;
      automatic discovery/editing of arbitrary stock rows remains pending.
- [ ] Effects / Addons.
- [x] Native Lua source loading/editing and gated replacement build; syntax
      highlighting and typed completion remain pending.
- [ ] Ability Card and Description.
- [x] Build / Deploy / Rollback for single-artifact packages.
- [ ] Live Log and acceptance checklist.
- [ ] Project history and update rebase.

Gate: every GUI operation calls the same deterministic C++ core available to
the CLI; the GUI contains no private code-generation path.
