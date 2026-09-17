# Ability-stat AI data audit — 2026-08-28

## Scope

Audit of
`../../toolchains/de-luau-toolchain/data/ability_stats_labeled.json` against the authoritative Semantic
IR render of stock body key `08faf07b504d058f` (`BardMusic`, Octavia Mallet).
The JSON is treated as a discovery hint only; the exact corpus, body key, and
value-flow are the authority used by Ability Studio.

## H1 — the AI-labelled Mallet range and duration values are correct

**Result: FALSE.**

The labelled JSON assigns `5/6/8/10` to duration and `8/12/16/20` to radius.
The exact stock function proves the opposite:

| Value web | Rank ladder | Exact consumer | Proven meaning |
|---|---:|---|---|
| `v21_12` | `1/1.5/2/2.5` | `ModifyValue(..., 10)` | damage multiplier / Strength |
| `v21_13` | `5/6/8/10` | `GetUpgradeModifiedValue(..., 9)` | radius / Range |
| `v21_14` | `8/12/16/20` | `GetUpgradeModifiedValue(..., 3)` | duration / Duration |

The prior data swapped radius and duration. It is not accepted as a production
binding.

A read-only consistency scan over the complete JSON found 28 additional
candidate selector/label conflicts (for example, evidence that mentions exact
selector `3` on a non-Duration label or selector `9` on a non-Range label).
Those are candidates, not automatic corrections: some evidence prose discusses
more than one value, so each row still requires exact-body review. The known
Mallet rows were corrected in place; the remaining dataset stays quarantined
from production binding.

## H2 — AI labels are sufficient authority for zero-code numeric editing

**Result: FALSE.**

The file has no reproducible body-key lock, generator, source span, or call-flow
proof. A plausible label can therefore silently bind the wrong ladder. Ability
Studio now discovers exact repeated numeric assignments structurally, but only
shows a gameplay name when `REGISTRIES/stock_value_bindings.tsv` binds the exact
body key and value web with evidence. Unknown assignments remain editable in a
replacement and visibly say `UNRESOLVED`; they are never guessed into a named
stat.

## H3 — a value-only edit can always be emitted as an addon

**Result: FALSE.**

An addon needs a proven lifecycle hook, arguments, authority, cleanup, and
stacking contract. A numeric constant inside stock control flow does not provide
one. Ability Studio therefore emits a native replacement for arbitrary stock
ladder edits. Addon generation remains available only for registered hooks.
This prevents a per-frame polling shim from being presented as an equivalent
patch.

## Accepted outcome

- Exact stock ladders are surfaced in the new **STOCK VALUES** tab.
- Verified bindings receive human-readable names and modifier families.
- Unverified ladders remain explicitly unresolved.
- Edits replace only the selected numeric tokens in exact rendered source.
- Source-shift, body-key mismatch, non-finite values, or missing anchors fail
  closed before a replacement project is created.
