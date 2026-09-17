# Semantic beautification 324 to 360 investigation — 2026-09-05

## Acceptance boundary

The raw `decompile-mod` foundation is pinned at 360/360 source-and-rebuilt-bytecode
fixed points. This investigation changes only the semantic/readable presentation
path used by Ability Studio. It must not weaken or relabel the raw certificate.

A script is accepted only when the coordinated readable, fidelity, naming,
closure, and semantic-proof artifacts all activate; the readable source
compiles; its DE output reparses and round-trips; and its semantic plan verifies.
Unknown names and API meanings stay canonical/unknown. There are no filename or
prototype exceptions.

## Pinned starting state

```text
40BC733B43E366A7E65CFB40BDFD13D3F71B268C65F3841155B593D3F3DBA5D3  derecomp.exe
AB3E0FBA411CC3FC78752B1C2407DB55013194C77087AEC3F66ED5BD7F3E0254  raw-360 inventory
FBA8427159D03CD1B5EB7E6C4253ABD6AFA12EC8E5646A69DFFC5F52FB3BC094  Ability CLI
```

Fresh schema-3 audit:

```text
corpus=360 baseline-pass=360 baseline-fail=0
semantic-accepted=324 semantic-rejected=36
retained-artifacts=1620 expected=1620 temporary-files=0
```

Evidence outside the repository source tree:

- `work/research/semantic-view-corpus-360/corpus360-raw360-v35-20260905/corpus360-coverage-audit.json`
  SHA-256 `EA4684E8174B853074BB038815EDBEDA47F88E1A0D5B53A4F782006E4E85166F`.
- The adjacent TSV SHA-256 is
  `48237FB237842715F80EBE1854D6F679F3C61859A46E7159E123CADCBA14C164`.

## Hypotheses and evidence

1. **The new raw 360 compiler makes all ten formerly excluded scripts eligible:
   TRUE.** The inventory contains 360 unique PASS rows, zero failures/errors,
   and its embedded compiler hash matches the selected binary.
2. **Compiler eligibility alone closes the semantic layer: FALSE.** Six of the
   ten newly evaluated scripts pass every semantic-view gate, moving verified
   coverage 318 to 324. Thirty-six presentation transactions still reject.
3. **The historical rejection partition can be reused without measurement:
   FALSE.** The exact current 36 rows are being re-probed against the new
   compiler before any renderer change.

## Work sequence

1. Reproduce and classify all 36 rejection signals with pinned inputs.
2. Address shared representation limits with proof-backed, lossless rules.
3. Rerun every member of an affected class plus accepted controls after each
   change.
4. Rebuild the Ability CLI, rerun all 360 transactions, and independently
   validate the resulting artifacts and hashes.
5. Update Ability Studio documentation only to the result actually measured.

No game, OpenWF server, corpus, backup, or ability-editor deployment has been
modified or attempted.

## Final result — 2026-09-06

The target hypothesis is **TRUE for the pinned 360-file sample**: all 360 raw
compiler-closed inputs now produce a complete, verified readable transaction.
The final result is not inferred from renderer success. Every accepted row
passed the same production sequence used by Ability Studio:

```text
readable + fidelity render
-> exact identifier/token provenance
-> exact closure ownership sidecar
-> compile both views
-> DE transcode and container reparse
-> exact DE parse/re-emit round-trip
-> semantic-plan verification of both rebuilt containers
-> atomic publication of five artifacts
```

Final schema-3 corpus result:

```text
corpus-files=360 unique=360 baseline-pass=360 baseline-fail=0
semantic-evaluated=360 accepted=360 rejected=0
total-verified=360 total-unverified=0 coverage=100%
retained-artifacts=1800 expected=1800 temporary-files=0
compiler-stable=true ability-cli-stable=true inventory-stable=true
```

The exact five-file output per script is readable `.luau`, fidelity `.luau`,
name/type TSV, closure TSV, and semantic-view JSON. The aggregate proof records:

```text
aligned tokens                         8,460,780
authorized identifier alias uses        290,002
evidence-backed alias rows               271,230
typed value rows                          37,067
closure sites / ordered captures   17,010 / 41,496
exact exports                              6,765
dead orphan omissions              27 prototypes in 15 files
```

### Hypotheses settled

1. **Mixed plaintext/hash metadata needs a guessed replacement name: FALSE.**
   When one recovered name occurs as both plaintext and DE hash metadata, only
   the hashed occurrence receives the lossless `OriginalName__hhhhhhhh`
   spelling. The existing hash-suffix decoder restores the exact original
   32-bit value during recompilation. No API meaning or original local name is
   inferred.
2. **An unreachable prototype must be reintroduced as executable source:
   FALSE.** A prototype with no live closure path cannot be instantiated by the
   module. Emitting a closure site would invent behavior. The renderer omits it
   from executable source, preserves its model/name/closure evidence in the
   sidecars, and emits its canonical prototype ID in both views. Ability Studio
   parses the markers strictly, rejects malformed/duplicate IDs, rejects any
   readable/fidelity set mismatch, and records the exact IDs in JSON. This
   closes 15 files and 27 dead prototypes without pretending the dead bodies
   execute.
3. **Every numeric `FORNPREP` must have a natural backedge: FALSE.** Luau omits
   `FORNLOOP` when every path through the body exits. The new terminal-numeric-
   for contract requires the exact prep/body identity, exact
   `NumericForExhausted` operands and edges, a single external range exit, a
   closed body region, and no recurrence to the prep/body. The normal and
   dispatcher renderers consume that verified contract. AvatarDiorama and
   LotusUtilities pass their complete transactions.
4. **Membership inside any natural loop proves ownership of the terminal for:
   FALSE.** AvatarDiorama's terminal loop is lexically inside a dispatcher
   `while`; that enclosing loop contains the prep/body blocks but does not own
   their source-for identity. Ownership now requires an exact matching loop
   prep or header, while the closed-region checks still reject hidden
   recurrence and non-range escapes.
5. **`nil[index]` is valid Luau syntax: FALSE.** Index and numeric-index reads
   now parenthesize their computed base consistently. LayoutEditor then
   compiles and passes the complete transaction; compiler and plan gates prove
   that this is syntax grouping rather than an unchecked source rewrite.
6. **A natural-loop parent chain is the only proof of lexical loop nesting:
   FALSE.** In DiegeticUpgradeCards, the source generic `for` fully contains a
   dispatcher `while`, but the while backedge closes over only its own header.
   Full natural-body containment plus dominance of the while header by the
   generic-for header proves the relationship. Partially overlapping cycles
   still fail closed.

Focused evidence progressed from 32/36 to 4/4 for the final residuals. The
last focused report contains AvatarDiorama, DiegeticUpgradeCards, LayoutEditor,
and LotusUtilities; all four passed, both executable hashes remained stable,
and all twenty output artifacts were present.

### Final pinned identities and evidence

```text
C4A1355F8893C02A8B6C431DA7A9DC328491512545B8592ACE6149B98E5B196E  derecomp.exe
16B0D5C48C1598321BF4FCB36BF55607F0132373A4BC618948EAC00A765CFDFB  Ability CLI
8A6DEA78551AD97785423F52102DFADEC7A441CD05B52E5D3D1C9F9ABE573D0E  raw-360 inventory JSON
842CA61A0168BE4D6141A6A883CEE31D73C8C3CD2AA6C6B4B667C87CC59BB862  semantic coverage JSON
355C5728224F0F16EAECED27E495E3E6C79ECA7A650B061319B74A684B5F8E46  semantic coverage TSV
1EBB3E8A0B192CF14E30C09FB860D86842BC931038765BC64EE12DC661404364  semantic aggregate JSON
144E54C42B2412A940F6090429FEB02BDE4464805DDDAEBFC374C83CF1908057  zero-rejection probe JSON
AF759BD39BCD7E5A624B445520878A88F60BF39E75F98B6294358B1DB65740CA  focused four JSON
```

Primary report locations:

- `../../../../../work/research/semantic-view-corpus-360/corpus360-final-20260906/corpus360-coverage-audit.json`
- `../../../../../work/research/semantic-view-corpus-360/corpus360-final-20260906/corpus360-coverage-audit.tsv`
- `../../../../../work/research/semantic-view-corpus-360/corpus360-final-20260906/corpus360-semantic-aggregate.json`
- `../../../../../work/research/semantic-view-corpus-360/corpus360-final-zero-rejections-20260906/semantic-view-rejection-diagnostics.json`
- `../../../../../work/research/semantic-view-corpus-360/focused4-final-v40/focused4-result.json`
- `../../toolchains/de-luau-toolchain/cert/baselines/fixedpoint-full360-semantic-beautification-final-2026-09-06.json`
- `../../toolchains/de-luau-toolchain/cert/baselines/release-gates-semantic-beautification-final-2026-09-06.json`
- `../../toolchains/de-luau-toolchain/cert/baselines/semantic-plan-cert-selected360-beautification-final-2026-09-06.json`
- `../../toolchains/de-luau-toolchain/cert/baselines/semantic-ir-cert-selected360-files-beautification-final-2026-09-06.json`

### Independent regression results

The presentation fixes share the same executable as raw `decompile-mod`, so
the raw certificate was regenerated after the last source change:

```text
raw compiler fixed point        360/360, errors=0
ten-cycle witnesses             5/5 default + 6/6 difficult
release structure/access        300 selected, ALL GATES PASS
behavioral round-trip           150/150, differences=0, timeouts=0
Semantic IR behavior            150/150, vacuous=0
Warframe API trace               11/11, vacuous=0
independent stock access loss         0 across 360
known-source fixture suite       19/19, 3,213 assertions
native-opcode fixture suite      19/19, 3,213 assertions
ownership manifests       17,374/17,374 across the selected 360 files
Semantic IR verification  17,374/17,374 across the selected 360 files
Ability Studio self-tests        52/52
```

The release-gate JSON SHA-256 is
`E956C7C306EC6D0A9EF06C897711D54D917C94D6415015802275015201EB3CF6`.
The difficult-cycle JSON SHA-256 is
`6040172CC50AB899F2E077F32C4FBB613764064DB54490612517C8F4C298E712`.
The selected-360 ownership and IR JSON hashes are respectively
`37421C66355A856B8C5D07CC5BB95342A13A48487B84F1E8C44C61CFA68E296B`
and
`B6D2F2B675BE51BF99114E5E193B9E867C0BE388503CAC74B91222389B78816A`.

### Broader corpus boundary retained as negative evidence

The local stock directory contains 5,386 scripts. An exploratory unfiltered
run covered 82,059 prototypes and did **not** pass completely:

```text
ownership manifest: 82,039 pass, 20 fail
  FOR_OWNER_ORPHANED       16
  FOR_OWNER_NO_LOOP_ID       2
  LOOP_REGION_ROLE_ALIAS     2
Semantic IR:       82,051 pass, 8 fail
  SIR_EDGE_COVERAGE           7
  SIR_TERMINAL_NUMERIC_FOR    1
```

Those reports are retained as
`../../toolchains/de-luau-toolchain/cert/baselines/semantic-plan-cert-full360-beautification-final-2026-09-06.json`
and
`../../toolchains/de-luau-toolchain/cert/baselines/semantic-ir-cert-full360-beautification-final-2026-09-06.json`;
their historical filenames say `full360`, but their embedded scope and counts
correctly record the accidental unfiltered 5,386-file run. They must not be
cited as passing 360 evidence.

No game directory, OpenWF server, stock corpus file, backup, or deployment was
modified. These results prove compiler closure, structural/provenance gates,
selected execution fixtures, and transactional Ability Studio output. They do
not replace an in-game runtime test or prove the gameplay meaning of every
unresolved native API.
