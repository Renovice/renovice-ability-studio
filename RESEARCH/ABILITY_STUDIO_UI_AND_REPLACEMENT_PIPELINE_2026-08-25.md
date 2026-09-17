# Ability Studio UI and native replacement pipeline — 2026-08-25

## Hypotheses and results

| Hypothesis | Evidence | Result |
|---|---|---|
| The old GUI can serve as the project-wide editor | It exposes only the Mallet linked-Overguard form and has no project browser or replacement command. | FALSE |
| A polished frontend requires duplicating the generator in C# | The WPF application invokes the existing C++ CLI for validation/builds and edits only the canonical JSON/source inputs. | FALSE |
| Native replacement can be a real first-release workflow | `build-replacement` runs recompile, DE reparse, exact round-trip, plan verification, and strict focused API checking before emitting a staged manifest. | TRUE |
| Addon and replacement should silently write to the game | Builds remain staged. Deployment is a separate confirmation that first creates a verified rollback transaction. | FALSE |
| Safe live deployment and rollback can share one deterministic implementation | The C++ deployer validates `STAGED_PASS`, artifact hash, and confined relative target; snapshots the prior file; atomically replaces; and refuses rollback over external changes. | TRUE |
| One linked stat can remain authoritative for gameplay and card values | The existing C++ generator and its tests still generate both consumers from one stat definition. | TRUE |

## Implemented boundaries

- WPF owns project browsing, forms, source editing, status, and presentation.
- C# core preserves unknown JSON fields, updates canonical stats, validates
  basic authoring input, and saves project/source files atomically.
- C++ owns registered-hook/modifier validation, addon generation, compilation,
  DE semantic gates, artifact hashes, and build manifests.
- Addon Lua is generated and read-only in the UI.
- Native replacement Lua is user-owned and editable.
- Both outputs are staged under the workspace authority route.
- No live file changes during Build. The separate Deploy action requires a
  selected game root and confirmation, then uses the C++ transaction.

## Verified gates

- C++ compilation uses warnings-as-errors.
- C++ self-test covers valid/invalid replacement project contracts in addition
  to the linked-stat generator.
- WPF and C# core compile with warnings-as-errors.
- C# model suite covers workspace routing, mode conversion, stat preservation,
  atomic save, and reload.
- The offline replacement fixture passes all external compiler/semantic gates.
- Sandbox deployment tests prove restoration of an existing file and removal
  of a newly introduced file without touching the actual game installation.
- The packaged WPF executable must pass a process-launch smoke test before
  release handoff.

## Known non-claims

- The project browser is not yet an installed-game ability catalog.
- Arbitrary addons are not generated without a registered hook/template.
- The source editor does not yet provide syntax-tree navigation or API
  completion.
- Staged PASS is not live gameplay acceptance.
- F9 success and in-game behavior remain separate acceptance steps after a
  deployment transaction succeeds.
