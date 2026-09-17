# Quick Stats implementation — 2026-08-25

## Scope

Turn the original Mallet linked-stat grid into a reusable, explicit editor for
canonical project statistics. This does not claim that arbitrary stock ability
values can already be discovered or structurally rewritten.

## Hypotheses and results

| Hypothesis | Evidence | Result |
|---|---|---|
| Card and gameplay values should be edited in separate boxes. | The proven Mallet project defines one fraction and one cap consumed by both generated gameplay and ordinary native rows. Separate values would reintroduce the mismatch the editor is meant to prevent. | FALSE |
| One canonical stat can drive a game-facing value and its formatted card row. | Model tests project the exact canonical fraction as gameplay `0.01` and display `1%`; the cap remains gameplay/display `15000`. | TRUE |
| A raw selector described as Strength can be reused on every ability. | The only registry row scopes selector 10 to body key `08faf07b504d058f` and ability `BARD_MUSIC`; independent generic evidence does not exist. | FALSE |
| The UI can safely preview registered Mallet Strength behavior. | The registry parser verifies binding ID, status, family, module body key, and ability identifier before projection. Another body key is rejected. | TRUE |
| Base and modded preview can share the proven clamp order. | Tests produce 1% at 100% Strength, 2% at 200%, cap at 5% for 600%, and 1% in Show Base Stats mode. | TRUE for the registered binding |
| A wide table beside all target fields remains usable at the default window size. | Visual QA showed the evidence/unit columns and preview pushed outside the window. | FALSE |
| Full-width Quick Stats and Target/Behavior tabs preserve the data without clipping. | The revised WPF layout gives the stat table internal horizontal scrolling and keeps the description and native-card preview visible. | TRUE |

## Implemented boundary

- Kind, base, minimum, maximum, modifier family, exact evidence binding, card
  enablement, unit, and order are now first-class editable fields.
- Add and remove operations mutate the same project `stats` array used by the
  deterministic C++ generator.
- Preview reads `REGISTRIES/modifier_bindings.tsv`; it is informative only and
  does not replace authoritative C++ validation/build gates.
- `NONE` and the exact registered Mallet Strength behavior are executable
  preview contracts. Duration, Range, Efficiency, Custom, and Unknown remain
  blocked until their semantics and scope are registered.
- Description text remains separate because normal ability prose should not
  hardcode values that belong in native rows.

## Verification

- C++ suite: 39/39 PASS.
- C# editor/model suite: 26/26 PASS, including exact strength progression,
  clamp, base-mode, scope rejection, raw-cap, and friendly-unit round-trip
  cases.
- WPF publish: PASS under pinned .NET SDK 9.0.314.
- Visual artifact:
  `work/diagnostics/ability-studio-final-2026-08-25.png`.
