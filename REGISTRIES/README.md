# Evidence registries

These registries convert reverse-engineering discoveries into reusable editor
inputs. They are deliberately small and conservative at first.

- `hook_registry.tsv` records events that generated addons or minimal native
  dispatch hooks may bind to.
- `modifier_bindings.tsv` records DE value-modification paths that gameplay and
  native card projections may share.

The editor should eventually compile these tables into a versioned catalog.
Until then, preserve the TSVs as reviewable source data.

## Registry policy

1. A row describes the exact proven scope, not a universal guess.
2. `LIVE_CONFIRMED` means the stated behavior was observed in the private live
   environment; it does not imply untested multiplayer behavior.
3. `IMPLEMENTATION_VERIFIED` means source/bytecode and offline gates agree, but
   the complete runtime progression still needs its stated live acceptance.
4. `UNRESOLVED` entries may guide research but cannot authorize generation or
   deployment.
5. Negative evidence stays in the native API catalog's
   `negative_contracts.tsv` and must be checked before promoting a binding.
6. A game update must rebind the target module/source hash even when the
   semantic hook or modifier contract is believed unchanged.
7. `target_module_body_key` and `target_ability_identifier` are executable
   scope guards. `*` is allowed only for a genuinely generic engine contract;
   a Mallet-scoped hook or selector must fail validation for every other
   ability/body key.

## Why this prevents repeated research

The first time an event, callback, or modifier path is established, record its
exact receiver, arguments, authority, lifecycle, evidence, source binding, and
acceptance level. Later ability projects select that binding by ID. The GUI
shows its confidence and limitations; the generator never has to rediscover or
reinterpret a naked method name or selector number.
