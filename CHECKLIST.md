# Ability Editor implementation checklist

## Current linked-stat vertical slice — 2026-08-25

- [x] Native Windows Addon Creation / Linked Stats screen exists.
- [x] Deterministic C++ core and CLI share the GUI generation path.
- [x] Canonical fraction/cap definitions generate both gameplay and native
      card consumers; the generated Lua emits each numeric literal once.
- [x] Proven hook and modifier TSV registries parse and fail closed on unknown
      bindings.
- [x] `LINKED_DAMAGE_TO_CASTER_OVERGUARD` target-addon template has idempotent
      activation and ownership-safe cleanup.
- [x] Focused generator suite passes 24/24, including eight negative cases.
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

- [ ] Detect installed Warframe build and metadata snapshot.
- [ ] Import Warframe/ability name, description key, identifier, metadata
      object, script path, body key, icon/video references.
- [ ] Bind available reconstructed source and active live replacement.
- [ ] Preserve the directory-only TOC-parent rule from WarframeMetaDataEditor.
- [ ] Diff/rebase projects after a game update.

Gate: every displayed editable ability has an explicit metadata object, script
path, body key, installed-build identity, and source status; unresolved entries
are read-only.

## 3. Quick Stats and native rows

- [ ] Discover existing native card rows and their value expressions.
- [ ] Add/edit/remove custom stat definitions.
- [ ] Generate base and modded native row projections.
- [ ] Support percent, seconds, meters, multiplier, count, and raw amount.
- [ ] Support literal labels and known stock unit/icon keys.
- [ ] Preview base/modded values and cap behavior.
- [ ] Generate description override separately.

Gate: generated rows use one gameplay stat definition, numeric native values,
correct units, query Avatar for modded mode, and publish the native row array.

## 4. Hook registry and addon generation

- [ ] Registry of proven events, callback signatures, authority, lifetime, and
      cleanup contracts.
- [ ] Managed-addon templates with idempotent activate/cleanup.
- [ ] Minimal reusable native dispatch-hook generator when required.
- [x] Target-scoped `.target.addon.lua_B` manifest convention and natural-load
      same-VM delivery bridge.
- [ ] Reverse engineer and prove the stable post-`GetAbilityUpgradeLevelInfo`
      native callsite, or prove a safe module-export decorator; descriptor
      `+0x58` is explicitly forbidden as an environment assumption.
- [ ] Bind card extensions by exact target module/body key in every owning UI VM.
- [ ] Preserve the stock `GetAbilityUpgradeLevelInfo`, append ordinary native
      rows after its result, and restore the previous callable on cleanup.
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

- [ ] Function/prototype navigation and syntax highlighting.
- [ ] Native API completion and contract tooltips.
- [ ] Confidence/evidence warnings inline.
- [ ] Structural generated-edit anchors and conflict detection.
- [ ] Original, generated, and user-edited diff views.
- [ ] Preserve user-owned code during regeneration.

Gate: a source-hash mismatch blocks automatic rewrite until rebase; no blind
whole-file textual replacement.

## 6. Build, validation, deployment, and rollback

- [ ] Recompile and reparse.
- [ ] Plan-verify every replacement prototype.
- [ ] Exact DE container round-trip.
- [ ] Focused API check.
- [ ] Package-level warning/error summary.
- [ ] Atomic rollback snapshot and live deployment manifest.
- [ ] F9 trigger guidance and live log parser.
- [ ] One-click rollback of every artifact in the package.

Gate: no failed/warning-required artifact deploys; live acceptance records
exact hashes and subsystem-specific F9 evidence.

## 7. GUI

- [ ] Ability Browser.
- [ ] Quick Stats.
- [ ] Effects / Addons.
- [ ] Native Lua.
- [ ] Ability Card and Description.
- [ ] Build / Deploy / Rollback.
- [ ] Live Log and acceptance checklist.
- [ ] Project history and update rebase.

Gate: every GUI operation calls the same deterministic C++ core available to
the CLI; the GUI contains no private code-generation path.
