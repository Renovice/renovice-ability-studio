# V49 low-level native calls in Ability Studio

Date: 2026-09-07

Runtime evidence:
`repos/runtime/bootstrapper-runtime/RENOVICE_SCRIPTING/RESEARCH/V49_LOW_LEVEL_NATIVE_CALLS_AND_IMMEDIATE_MALLET_2026-09-07.md`

## Hypotheses and results

### H1: the editor's old handler-slot template matches the universal runtime

**FALSE.** It generated `_T.RENOVICE_AFTER_MALLET_DAMAGE`, required a
compatibility native module, and used a shared-table lifecycle. V49 accepts the
standalone target addon's `hooks.afterDamage`, `hooks.afterAbilityCard`, and
`hooks.nativeCalls` declarations directly. The old fields have been removed
from the schema, generator, example, tests, and legacy Win32 form.

### H2: exact low-level numeric changes can be represented without prose-only hooks

**TRUE.** `addon_generation.native_argument_rewrites` now stores:

- native method;
- exact zero-based prototype and instruction;
- one-based argument index;
- expected and replacement numeric values;
- evidence ID.

Validation rejects malformed method names, negative sites, invalid argument
indices, missing numeric values, missing evidence, duplicate sites, and more
than 32 declared rewrites. Generation groups declarations by method and emits a
single `before` callback per `hooks.nativeCalls[method]` entry.

### H3: Mallet's cap can remain an unmodified raw stat

**FALSE.** Stock Pagemaster evidence applies
`InventoryControl:GetUpgradeModifiedValue(baseCap, 10, suitType, suit)` to its
15,000 Overguard cap. The Mallet template now applies the same evidence-backed
operation to both its 1% conversion and 15,000 cap. The conversion alone keeps
the configured 5% ceiling. Gameplay and modded card rows call the same generated
accessors.

### H4: the editor needs a target-module shim for the card or threat change

**FALSE for V49.** The generated project uses
`MANAGED_ADDON_CARD_EXTENSION`, requires one addon and the card extension, and
sets `requires_native_module=false`. Threat level 5 is an exact
`PushFloatArg` rewrite at prototype 16, instruction 596. Activation and cleanup
are empty because the host owns callback registration and transactional root
release.

## Verification

- C++ compilation: PASS with warnings as errors.
- C++ self-test: PASS.
- Managed Studio tests: PASS, 82/82.
- WPF publish: PASS.
- Checked-in Mallet project validation: PASS with the explicit
  `MODIFIER_LIVE_REMAINING` evidence warning.
- Real staged build: PASS.
- DE recompile/reparse: PASS.
- DE roundtrip: PASS, 9/9 prototypes.
- Semantic plan: PASS, 9/9 prototypes.
- Focused API gate: PASS, zero unknown calls.
- Live gameplay: pending. Base and non-base Strength, immediate damage timing,
  card values, threat 5, normal performance, and UI transitions remain the live
  acceptance set.

Generated proof artifact:
`work/staging/ability-editor-v49-contract-final/octavia_mallet_overguard/304705ECE0B3`
