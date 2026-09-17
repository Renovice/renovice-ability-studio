# Semantic Source Workspace vertical slice — 2026-09-04

> Follow-up: `VERIFIED_SEMANTIC_VIEW_2026-09-04.md` adds the fifth hash-bound
> semantic proof, exact spans/exports, compiler gates inside the activation
> transaction, independently verified baseline-PASS subset audits, exact UTF-8
> span revalidation, the strict API evidence index, and the export/closure
> prototype outline. The authoritative selected inventory has 360 scripts. The
> 318 verified / 42 unverified result on `D7341145...` was an intermediate
> checkpoint. The final gate on `C4A1355F...` is 360/360 for both semantic
> five-artifact transactions and raw fixed-point recompilation, with 1,800 of
> 1,800 artifacts independently rehashed. The original four-artifact results
> below describe the earlier foundation and are retained as history. See the
> final closeout in `VERIFIED_SEMANTIC_VIEW_2026-09-04.md` and
> `../SEMANTIC_BEAUTIFICATION_360_2026-09-05/STATUS.md`.

## Result

Ability Studio now exposes the provenance artifacts that its production
Semantic IR renderer already generated, and extends that transaction with the
existing fail-closed closure ownership map.

The source workspace has four distinct artifacts:

1. readable/editable Luau;
2. read-only fidelity Luau;
3. validated API/type/name evidence keyed by prototype and value web;
4. validated closure ownership keyed by parent prototype and instruction.

No live Warframe, backup, Steam, or OpenWF server file was read for mutation or
written by this work. Generated validation artifacts are confined to this
research folder. No deployment was attempted.

## Existing evidence reused

This was not a new Mallet special case. The implementation consumes existing
generic evidence and commands:

- the readable renderer's `.names.tsv` identity/evidence contract;
- the Semantic SDK's API contracts and types;
- the generic `derecomp.exe closure-map` ownership command;
- the existing BardMusic/Mallet stock body and live-confirmed API evidence;
- the existing linked-stat Mallet project remains unchanged.

Examples surfaced by the real Mallet map include:

- `Avatar:DamageControl` with `LIVE_CONFIRMED` evidence
  `WF-LIVE-MALLET-2026-08-23`;
- `InventoryControl:ModifyValue` with stock and exact-pipeline evidence;
- `IsNull` with stock Bard/BoxLoop evidence;
- exact root export roles such as `ActivateAbility`, `DeactivateAbility`,
  `BoxLoop`, and `SetThreatLevel`.

## Hypotheses and results

### H1 — Ability Studio needs a second guessed API-name database

**Result: FALSE.**

The generated Mallet naming map already contains API receivers, results,
arguments, types, confidence grades, and evidence. The missing part was editor
visibility and navigation, not another speculative catalog.

### H2 — readable text alone is a safe closure/function ownership map

**Result: FALSE.**

The earlier closure-map research proved that `NEWCLOSURE` child slots,
`DUPCLOSURE` constant slots, register reuse, and ordered captures cannot be
reconstructed safely from visually similar source. Ability Studio now runs the
authoritative generic closure mapper and activates its output with the other
three source artifacts.

### H3 — the naming map alone covers every module prototype

**Result: FALSE for stock BardMusic.**

The Mallet naming map contains rows spanning 20 prototypes. The closure map
references all 22 prototypes. A prototype without an alias or inferred type is
not an error in the naming map, so the UI uses the union of name and closure
identities for its prototype selector.

### H4 — an edited readable source can silently retain a fresh-provenance badge

**Result: FALSE after this change.**

Ability Studio compares normalized editable text with the exact generated
readable base. The badge is green only while they match. Any difference changes
the badge to `BASE PROVENANCE — SOURCE EDITED` and explains that the identities
are reference evidence until regeneration or a future structural rebase.

### H5 — a source workspace can expose the higher-level evidence without
changing compiler behavior

**Result: TRUE for this vertical slice.**

The WPF layer reads validated sidecars and never sends fidelity, name-map, or
closure-map text to the compiler. Replacement builds continue to use the
existing readable/editable source path and authoritative C++ CLI gates.

## Implemented contracts

### Naming map parser

`editor/Core/SemanticNamingMap.cs` requires the nine current schema columns,
parses non-negative prototype/value-web identities, rejects missing canonical
identities, and rejects duplicate `(prototype, web)` rows. Unknown aliases are
displayed using the exact canonical identity rather than a guessed label.

### Closure map parser

`editor/Core/ClosureOwnershipMap.cs` requires the current 13-column schema and
rejects:

- duplicate `(parent prototype, instruction)` sites;
- unknown closure operations;
- unknown operand namespaces;
- non-`PASS` rows;
- negative numeric identities;
- missing, malformed, or out-of-order captures;
- a declared capture count that differs from the capture list.

### Coordinated source transaction

The C++ `render-source` operation now produces these targets together:

```text
<name>.luau
<name>.fidelity.luau
<name>.names.tsv
<name>.closures.tsv
```

All four temporary files must exist and be non-empty before activation. Existing
targets are backed up and restored if activation fails. The CLI prints every
path explicitly.

### WPF presentation

The source workspace now provides:

- readable/editable and fidelity/read-only tabs;
- searchable API/value-web/type/confidence/evidence rows;
- prototype filtering across naming and closure identities;
- jumps from an identity to readable or fidelity source;
- exact parent/target/capture closure rows;
- navigation from a closure target to its identities or first canonical source
  token;
- visible missing-companion and edited-source states.

Token search is presentation navigation only. It is not used as a structural
edit anchor and does not weaken the production rule against blind textual
replacement.

## Stock Mallet validation

Input:

```text
shared/corpus/de-luau-stock/Lotus_Powersuits_Bard_Abilities_BardMusic.lua_B
```

Two consecutive coordinated renders produced identical hashes:

```text
0B12BE6CB0B10DD0ECB3FC82507A7F9C1D6DC45FBB61158A691911115F386ED1  mallet.readable.luau
DC6FB2AF678E2641FE8CDCF478508F3253A3373A5A8E0DFF25783F55C3B3A54D  mallet.readable.fidelity.luau
79B812BEBFE94A3A5C4BEFBF7CF5B3593C84D392AB7ECE5DD4ECEFA696663E68  mallet.readable.names.tsv
D7AF7747ABE9D7BFBC8B20444CB84E36879C278B1FC57FE167E80F8D78FDFF48  mallet.readable.closures.tsv
```

Map results:

```text
naming:  rows=572, prototypes-with-rows=20, aliases=560, typed=215
closure: sites=21, referenced-prototypes=22, ordered-captures=46
```

Readable-source compile:

```text
bytes=32923, prototypes=22, re-parses=yes, hashed-globals=2, hashed-fields=11
DE round-trip: 22/22 constants exact, FULL BODY identical
plan verification: 22/22 prototypes, failures=0
SHA-256 E5E82665D173B72A0D9394E367AC4587B7CBF761BC4B572C6DB00163D4B74123
```

Fidelity-source compile:

```text
bytes=32705, prototypes=22, re-parses=yes, hashed-globals=2, hashed-fields=11
DE round-trip: 22/22 constants exact, FULL BODY identical
plan verification: 22/22 prototypes, failures=0
SHA-256 EDFB5C0661AE1DB9190F6013AD2CA185DF83956B4C1E0A38A7A458E3DA5A9562
```

Application gates:

```text
C++ warnings-as-errors build: PASS
C++ linked-stat self-test:    PASS, 1/1 CTest
C# warnings-as-errors build:  PASS, 0 warnings, 0 errors
C# focused model suite:       PASS, 51/51
WPF publish:                  PASS
published process smoke:      PASS
```

## Negative findings and remaining boundary

- Readable and fidelity source intentionally compile to different byte hashes;
  friendly identifiers are valid compiler inputs but are not byte-identical
  source encodings.
- DE container round-trip proves the generated container can parse/re-emit
  exactly. It does not by itself prove stock behavioral equivalence.
- This change does not perform higher source transforms, function-declaration
  folding, syntax highlighting, API completion, or inline tooltips.
- The naming map has no exact source spans. Current jump behavior is a visual
  convenience, never an edit authority.
- Edited-source detection is an exact normalized-text comparison. Structural
  rebase and conflict resolution remain future work.
- The four-file rollback path is implemented by extending the existing
  recoverable transaction, but failure injection at each individual activation
  boundary was not added in this slice.
- No new Mallet gameplay behavior was authored, deployed, or live-tested. The
  existing accepted Mallet evidence remains historical evidence for the named
  API contracts only.

## Next bounded step

Build a generated semantic document with exact source spans and exported
lifecycle/function ownership. That document should join naming rows, closure
targets, exports, native calls, and source ranges without changing the fidelity
IR. Only after each displayed node has a stable identity and expected source
fingerprint should Ability Studio add structural edit anchors or display-only
temporary-chain/function folding.
