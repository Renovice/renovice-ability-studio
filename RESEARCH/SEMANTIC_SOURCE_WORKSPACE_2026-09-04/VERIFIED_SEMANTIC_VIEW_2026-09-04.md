# Verified semantic-view layer — 2026-09-04

## Outcome

Ability Studio now has a fail-closed presentation layer above the existing DE
Luau compiler. The baseline compiler was not modified by this work.

The renderer produces and activates five coordinated files:

1. readable/editable Luau;
2. fidelity/read-only Luau;
3. prototype/value-web naming and API/type evidence;
4. exact closure ownership and ordered captures;
5. a hash-bound semantic verification document with exact source spans and
   exact root exports.

The fifth file is `<name>.semantic-view.json`, format
`RENOVICE_SEMANTIC_VIEW_V1`, status `VERIFIED_PRESENTATION_ONLY`.

This is not a claim that friendly source recompiles to the original stock byte
sequence. It proves that the accepted friendly source is a presentation-only
view of the fidelity source under the explicit rules below, and it proves that
both source views survive the existing compiler/container/planner gates before
they become active in Ability Studio.

## Hypotheses and results

### H1 — comparing readable and fidelity text loosely is sufficient

**Result: FALSE.**

The verifier lexes both generated Luau files and aligns every non-whitespace
token. A changed token is accepted only when:

- both tokens are identifiers;
- the fidelity identifier is a unique canonical identity in the naming map;
- its canonical prefix belongs to the row's prototype;
- the readable token exactly equals that row's evidence-backed alias; and
- the alias is a valid, non-reserved Luau identifier.

Operators, keywords, numbers, strings, long strings, comments, and punctuation
must remain identical. The only non-alias exception is the exact two-comment
`RENOVICE_READABLE_VIEW_V1` preamble at its fixed boundary. The proof records
that exception separately instead of hiding it from the counts.

### H2 — every naming row must have a friendly alias

**Result: FALSE.**

Stock Mallet exposed 12 rows with complete API/type evidence but no justified
friendly name. They remain canonical and are marked
`UNKNOWN_CANONICAL_PRESERVED`. Partial name evidence is rejected; complete
typed-only evidence is accepted without inventing a name.

### H3 — a presentation proof alone protects the compiler pipeline

**Result: FALSE.**

The 345-row baseline-PASS subset audit found one file whose readable and fidelity source were
presentation-equivalent, both recompiled/reparsed, and both DE containers
round-tripped exactly, but both later failed semantic plan verification.
`render-source` now runs all of these gates on both temporary source views
before activating any of the five targets:

1. recompile and reparse;
2. exact DE container round-trip;
3. semantic plan verification with no failed prototype.

`Lotus_Interface_DiegeticUpgradeCards.lua_B` is the negative fixture for this
boundary. Both views fail prototype 165 with:

```text
FAIL LOOP_REGION_ROLE_ALIAS outer=4 inner=86 region=125 contains_inner=0
outer_form=while inner_form=for_generic
```

A deliberate retry proved that this failure leaves all five prior target
hashes unchanged and leaves zero temporary files.

### H4 — 345 byte-exact fixed points imply all 360 scripts have readable semantic views

**Result: FALSE.**

The complete inventory contains 360 scripts. The exact 345 baseline PASS rows from
`fixedpoint-full360-terminal-pair.json` were audited with the production Ability
Studio transaction; the 15 baseline FAIL rows were not eligible for semantic
rendering. The eligible-subset result is **315 accepted and 30 rejected**.

The rejected set is:

- 29 failures in the existing readable/fidelity renderer;
- 1 post-recompile semantic-plan failure described above.

Direct sequential reruns of all 29 renderer failures reproduced them and
classified them as:

- 15 `RENDER_NAME_METADATA_MIXED_NAME`;
- 12 `FIDELITY_RENDER_ORPHAN_PROTOTYPE_PENDING`;
- 1 combined `FIDELITY_RENDER_LOOP_PREDICATE_AS_BRANCH` /
  `FIDELITY_RENDER_BLOCK_COVERAGE`;
- 1 `READABLE_SOURCE_COMPILE` syntax failure involving bracketed expressions.

Therefore coverage among the baseline-PASS subset is **315/345 (91.3%)**. The
real project-wide denominator is 360: total verified beautification coverage is
**315/360 (87.5%)**, with 45 scripts not yet verified. Fifteen require baseline
compiler parity before this layer can evaluate them, while 30 are rejected by
the semantic-view renderer/transaction. The important safety result is that no
unsupported script is activated with a misleading green proof. The 345-row
subset result was first pinned to `B0DE77AC...` and then reproduced on
`F6439FFE...` as documented below.

### H5 — friendly API names are equivalent to live behavioral proof

**Result: FALSE.**

The semantic document preserves each row's existing confidence and evidence;
it does not upgrade evidence grades. `LIVE_CONFIRMED`, `API_CONTRACT`,
`CORPUS_CATALOG`, and `STRUCTURAL` remain distinct. A structurally verified
alias means “this label is the exact authorized presentation for this IR
identity under its recorded evidence,” not “every behavior of this native API
was newly tested in game.” Unknowns remain null/canonical.

## Enforced document contract

The C++ verifier independently validates:

- exact nine-column naming-map schema;
- unique `(prototype, value-web)` identities and canonical names;
- canonical name/prototype prefix agreement;
- complete alias evidence or complete typed-only evidence;
- safe non-reserved identifiers;
- exact thirteen-column closure-map schema;
- unique `(parent prototype, instruction)` closure sites;
- supported closure opcodes and operand namespaces;
- `PASS` status for every closure row;
- contiguous capture indexes, capture kinds, register/upvalue storage, and
  declared capture counts;
- exact readable/fidelity token alignment after the fixed preamble is removed;
- zero unauthorized identifier changes;
- zero non-identifier changes;
- exact UTF-8 byte spans with one-based line/column metadata;
- exact root exports derived only from `EXACT_EXPORT` + `global store ...`
  evidence; and
- SHA-256 plus byte length for all four input artifacts.

The WPF consumer validates the document again. It recomputes all four input
hashes, cross-checks every value row against the naming TSV, every closure row
against the closure TSV, every export against its identity occurrences, all
aggregate counts, span validity, and the zero-difference invariants. It also
decodes every mapped readable/fidelity span from the exact UTF-8 bytes, requires
the expected canonical/alias token, and recomputes the one-based line/column
position. A stale source hash, falsified difference count, or shifted span is
rejected.

## Ability Studio behavior

- Green state is now `SEMANTIC PROOF MATCHES` and requires the proof, both
  sidecars, and an unchanged readable base.
- Missing proof is amber and cannot authorize automatic rewriting.
- Editing readable source immediately changes the state to
  `BASE PROVENANCE — SOURCE EDITED`.
- Identity and export navigation use verified source spans while the hash is
  fresh.
- Spans declare UTF-8 byte encoding and are converted to WPF UTF-16 text
  positions with strict decoding.
- Sidecar-only identities remain visibly non-navigable.
- The verification tab exposes the exact root-export outline and the full
  machine-readable proof.
- The verified structural outline joins exact exports and closure ownership by
  prototype and navigates only through hash-bound identity spans.
- The outline explicitly contains no native call edges and does not claim
  complete nested function-body ownership.
- The API evidence index strictly parses `semantic-sdk:lua:` descriptors and
  displays live-confirmed, stock-bytecode, catalog-only, and unresolved rows
  separately. Counts are bound identities, not invocation counts.
- Selecting an identity shows its exact mapping state and a behavior boundary
  derived from the original evidence grade; presentation proof never upgrades
  catalog/structural evidence into live proof.

## Mallet reference result

Stock input:

```text
shared/corpus/de-luau-stock/Lotus_Powersuits_Bard_Abilities_BardMusic.lua_B
```

Proof summary:

```text
status:                         VERIFIED_PRESENTATION_ONLY
aligned tokens:                 15,448
fixed preamble comments:        2
authorized alias occurrences:   598
unauthorized identifiers:       0
non-identifier changes:         0
mapped source occurrences:      630
canonical-retained occurrences: 32
sidecar-only rows:               372
naming rows:                    572
closure sites/captures:          21 / 46
exact root exports:              16
```

All 630 navigation spans were independently decoded from the generated UTF-8
files and matched the exact expected canonical/readable token bytes.

Deterministic five-file hashes:

```text
0B12BE6CB0B10DD0ECB3FC82507A7F9C1D6DC45FBB61158A691911115F386ED1  mallet.readable.luau
DC6FB2AF678E2641FE8CDCF478508F3253A3373A5A8E0DFF25783F55C3B3A54D  mallet.readable.fidelity.luau
79B812BEBFE94A3A5C4BEFBF7CF5B3593C84D392AB7ECE5DD4ECEFA696663E68  mallet.readable.names.tsv
D7AF7747ABE9D7BFBC8B20444CB84E36879C278B1FC57FE167E80F8D78FDFF48  mallet.readable.closures.tsv
190F0D397BD03EFBAC09A6DC608168289B14840C59F1011F1E70DF530B427E39  mallet.readable.semantic-view.json
```

Both views recompile/reparse to 22 prototypes, preserve 2 hashed globals and 11
hashed fields, exact-round-trip 22/22 constant pools with full-body identity,
and pass all 22 semantic plans. The readable/fidelity recompiled container
hashes remain intentionally different because friendly identifier encodings
are different:

```text
E5E82665D173B72A0D9394E367AC4587B7CBF761BC4B572C6DB00163D4B74123  readable
EDFB5C0661AE1DB9190F6013AD2CA185DF83956B4C1E0A38A7A458E3DA5A9562  fidelity
```

## Negative tests

The focused C++ suite rejects:

- an identifier absent from the naming map;
- an alias that disagrees with its prototype/value-web row;
- a non-identifier structural token insertion;
- a string-literal change;
- an altered or misplaced readable preamble;
- a reserved-word alias;
- partial naming evidence; and
- a closure row not marked `PASS`.

The C# consumer rejects:

- malformed naming and closure rows;
- incomplete capture contracts;
- a stale readable-source hash;
- a falsified unauthorized-difference count;
- a falsified UTF-8 navigation span or line/column;
- inconsistent aggregate/value/export/closure rows; and
- invalid source spans.

Focused results:

```text
C++ self-tests: 50/50 PASS
C# model and integration tests: 62/62 PASS
C++ warnings-as-errors build and CTest: PASS
C# warnings-as-errors build: PASS, 0 warnings, 0 errors
published WPF startup smoke: PASS
```

Validation harness notes:

- the first final smoke wrapper observed the GUI alive for seven seconds but
  inherited exit code `1` after deliberately terminating that spawned process;
  an explicit pass/fail wrapper was rerun, again observed the GUI alive for
  seven seconds, stopped only its own process, and exited `0`;
- the .NET SDK reported optional workload updates for Android, iOS, Mac
  Catalyst, and MAUI Windows. Ability Studio is WPF and does not consume those
  workloads; the notice was inspected and no machine-wide workload mutation
  was performed.

## Baseline-PASS subset production audit — 345 of 360 scripts

The production transaction audit used stable executable hashes for the entire
run:

```text
Ability CLI: FBA8427159D03CD1B5EB7E6C4253ABD6AFA12EC8E5646A69DFFC5F52FB3BC094
derecomp:    B0DE77ACAC4C12BCAD5A56CF43331B9F643DAC91591917813DC90935D249F58E
```

For the 315 accepted files:

```text
aligned tokens:               4,201,535
authorized aliases:             170,713
canonical-retained:                 647
mapped occurrences:             171,360
sidecar-only rows:                73,294
naming rows:                     131,216
closure sites/captures:       10,011 / 24,096
exact exports:                     4,197
fixed comments:                      630
```

All 1,575 retained files (five per accepted script) were rehashed after the
workers exited and matched the report exactly. There were 345 unique evaluated
baseline-PASS rows, zero final `*.tmp` files, and zero `.readability.bak` files. A deterministic
sample spanning 10 accepted rows reran 10/10 through the integrated production
transaction with all five hashes unchanged.

Evidence:

- `../../../../../work/research/semantic-view-corpus-345/full345-20260904/production-transaction-audit.json`
- `../../../../../work/research/semantic-view-corpus-345/full345-20260904/production-transaction-audit.tsv`
- `../../../../../work/research/semantic-view-corpus-345/full345-20260904/renderer-failure-diagnostics.tsv`
- `../../../../../work/research/semantic-view-corpus-345/full345-20260904/deterministic-rerender-sample.tsv`

Final production-audit report SHA-256:

```text
25E255A7C2CC8B2E5A5F5219F3F168BF6507CEDAFC62CBAD1811362591607595
```

### Compiler-drift recheck

The 345-row eligible-subset result above is pinned to `derecomp` `B0DE77AC...`. Another
process rebuilt the baseline compiler after that audit. The working compiler
then stabilized at:

```text
F6439FFE69677C91185ED8320B563312F41A7FE5B58669F5E9BF1ACF98A376A3
```

Rather than mislabel the older eligible-subset run as current, two bounded production
transaction rechecks were executed while both the Ability CLI and compiler
hashes remained unchanged:

- all 30 previously rejected scripts were checked: **0 accepted / 30 rejected**;
  the same 29 fail at `BASELINE_READABLE_RENDER`, and the same one fails at
  `POST_RECOMPILE_PLAN`;
- the fixed 10-file accepted sample was checked: **10 accepted / 0 rejected**;
  all 50 generated artifacts match the pinned audit byte-for-byte; and
- both rechecks ended with zero global temporary or backup files.

The first revision of the accepted-sample audit report contained a PowerShell
harness error: its five expected filenames were concatenated into one string,
so it falsely labeled ten successful exit-code-zero renders as failures. The
artifact rows exposed the mistake. Revision 2 corrects the filename list,
retains the superseded revision-1 SHA-256 in the report, and records the
correction explicitly. This was an audit-report defect, not a product or
transaction failure.

Evidence:

- `../../../../../work/research/semantic-view-corpus-345/targeted30-current-20260904/targeted30-recheck.json`
- `../../../../../work/research/semantic-view-corpus-345/targeted30-current-20260904/targeted30-recheck.tsv`
- `../../../../../work/research/semantic-view-corpus-345/accepted10-current-20260904/accepted10-current-recheck.json`
- `../../../../../work/research/semantic-view-corpus-345/accepted10-current-20260904/accepted10-current-recheck.tsv`

Evidence hashes:

```text
E2F08493719028EDBA831D30026FF5B1D78BC72F3BDD5BD40E3884BA9AC02C97  targeted30-recheck.json
D993AE24D7C4230228649B2C721608DD6C1DE336CE842D1549E594D02A63D7E4  targeted30-recheck.tsv
0195E2B3FF50D6F8CC7CE92DAFD0347557D666DCF03A42E9E0417669C19AEF47  accepted10-current-recheck.json revision 2
C5F74F49D9FB3FC1970DB07B75DC98CDEDEAC5C0AEF46D466149D03D4B223627  accepted10-current-recheck.tsv revision 2
```

These bounded checks are evidence against drift in the known reject set and
sampled accepted set. They were followed by the fresh 360-row coverage audit below.

### Previous schema-2 360-script corpus coverage audit — 2026-09-04

After the bounded drift checks, all 360 inventory rows were represented in a
coverage audit. The production semantic transaction was rerun for the 345
baseline-PASS rows; the 15 baseline-FAIL rows were recorded explicitly as
`BASELINE_COMPILER_PARITY_REQUIRED` against stable binaries:

```text
Ability CLI: FBA8427159D03CD1B5EB7E6C4253ABD6AFA12EC8E5646A69DFFC5F52FB3BC094
derecomp:    F6439FFE69677C91185ED8320B563312F41A7FE5B58669F5E9BF1ACF98A376A3
inventory:   99D6C914FD4CC847473B21E3C2BBB323A76936431824B3114D58B02E3CECC619
```

Result: **315/360 verified and 45/360 not verified**. Within the 345 eligible
rows, 315 were accepted and 30 fail-closed rejected, exactly reproducing the
earlier subset audit. Both binary hashes remained unchanged from start to
finish, all 360 corpus names were unique, all 1,575 expected accepted artifacts
were present and hash-bound, and zero global temporary/backup files remained.

The reusable harness is
`RESEARCH/tools/audit-semantic-view-corpus.ps1`. Its first report revision used
a generic result code for the exact `failed semantic plan verification`
diagnostic. Revision 2 mapped only that phrase to `POST_RECOMPILE_PLAN`.
Schema revision 2 corrects the more important denominator error: the earlier
report was mislabeled “full corpus” even though it evaluated the 345 baseline
PASS rows. That superseded report is preserved under the legacy run's
`superseded-report-revisions`; no execution result or artifact was altered.
The schema-2 harness was then rerun end-to-end into the correctly named
`semantic-view-corpus-360/corpus360-v2-fresh-20260904` evidence directory.

An independent managed verifier then:

- rehashed all 1,575 accepted artifacts;
- reparsed all 315 naming maps, closure maps, and semantic proofs;
- decoded and checked every mapped UTF-8 identity span and its line/column;
- confirmed the aggregate proof totals; and
- rejected any unreported or rejected-transaction artifact in the evidence
  directory.

Independent result:

```text
corpus=360 baseline-pass=345 baseline-fail=15
semantic-accepted=315 semantic-rejected=30
total-verified=315 total-unverified=45 artifacts=1575
tokens=4,201,535 aliases=170,713 mapped=171,360 naming=131,216
closures=10,011/24,096 captures exports=4,197
api-descriptors=94 api-identity-rows=24,598
api-live=4,168 api-stock=16,272 api-catalog=4,118 api-unresolved=40
```

Evidence:

- `../../../../../work/research/semantic-view-corpus-360/corpus360-v2-fresh-20260904/corpus360-coverage-audit.json`
- `../../../../../work/research/semantic-view-corpus-360/corpus360-v2-fresh-20260904/corpus360-coverage-audit.tsv`

Final revision-2 evidence hashes:

```text
3AFE2C67FFF501F8FCBFA303FDF285852014A47EC4A1DFCB94A96BAD40C337CA  corpus360-coverage-audit.json
1C67B9238B2A0FBDC16BCEBD3E5DD2DBE200915B8FB42E73BB0FC7753F67D9E9  corpus360-coverage-audit.tsv
```

### Current raw-350 transition and schema-3 audit — 2026-09-05

The compiler advanced from 345 to 350 raw first-pass fixed-point PASS rows.
The Ability Studio audit did not infer semantic coverage from that number. It
instead pinned and checked both immutable inventory lanes:

```text
D734114550B1815C898C47C70A0692693C959234D79EC852F89F29450FD8A078  derecomp.exe
BDE478539788352E70A4374CBC2208C91D2C73DB4B3B622EEDE5C41E4CE2C7C0  raw 350/360 inventory
22884DCE105CC26EDBD026FD83DCA1FC6D7C006DD726766F875E0E9888328617  stable 360/360 inventory
```

The raw inventory uses `decompile-mod`; the stable inventory uses
`decompile-mod-stable`. They are separate claims. The raw 350 report is the
eligibility partition used below. The stable 360 report is evidence that the
compiler-closed production lane covers the corpus, not permission to call raw
first-pass parity or semantic beautification 360/360.

The schema-3 audit now requires the inventory path and expected inventory hash,
checks all 360 unique rows, checks its cycle-2 totals, verifies the inventory's
embedded compiler hash against the selected binary, records the decompile mode,
and rehashes the inventory and both executables after the run. The managed
verifier accepts schema 2 for historical evidence and independently enforces
the new schema-3 inventory/compiler binding.

Result:

```text
corpus=360 baseline-pass=350 baseline-fail=10
semantic-accepted=318 semantic-rejected=32
total-verified=318 total-unverified=42 artifacts=1590
tokens=4,242,552 aliases=172,170 mapped=172,838 naming=132,756
closures=10,079/24,259 captures exports=4,212
api-descriptors=94 api-identity-rows=24,931
api-live=4,186 api-stock=16,510 api-catalog=4,193 api-unresolved=42
```

The old 315 accepted rows had **zero regressions**. Exactly five scripts moved
from baseline FAIL to raw-eligible:

| Script | Semantic result | Exact boundary |
|---|---:|---|
| `Lotus_Interface_Components_EvolutionList.lua_B` | accepted | all five artifacts and all gates PASS |
| `Lotus_Interface_Dojo_InWorldTransmissionController.lua_B` | accepted | all five artifacts and all gates PASS |
| `Lotus_Interface_InWorldLeaderboard.lua_B` | accepted | all five artifacts and all gates PASS |
| `Lotus_Interface_Codex.lua_B` | rejected | `FIDELITY_RENDER_ORPHAN_PROTOTYPE_PENDING` |
| `Lotus_Interface_Hub.lua_B` | rejected | `FIDELITY_RENDER_ORPHAN_PROTOTYPE_PENDING` |

Therefore the hypothesis “five new compiler PASS rows imply five new verified
beautified scripts” is **FALSE**. Three became verified and two correctly
remained fail-closed at the semantic renderer.

The exact 32 rejection signals were independently reproduced by invoking the
selected renderer directly. For the post-recompile failure, the probe also
required readable recompilation and exact DE round-trip before replaying the
semantic plan gate. All 32 reproduced with a recognized signal:

```text
15  MIXED_NAME_METADATA
14  ORPHAN_PROTOTYPE
 1  LOOP_BLOCK_COVERAGE
 1  READABLE_SOURCE_SYNTAX
 1  POST_RECOMPILE_LOOP_ROLE_ALIAS
```

The last row is `Lotus_Interface_DiegeticUpgradeCards.lua_B`, prototype 165:
`LOOP_REGION_ROLE_ALIAS outer=4 inner=86 region=125`. Its readable source
recompiled, reparsed, and exact-DE-round-tripped before the semantic planner
rejected it. This is negative evidence that the transaction is failing closed
at the intended boundary, not a compiler-parity regression.

Evidence:

- `BASELINES_2026-09-05/fixedpoint-full360-raw350-d734-20260905.json`
- `BASELINES_2026-09-05/fixedpoint-full360-stable360-d734-20260905.json`
- `../../../../../work/research/semantic-view-corpus-360/corpus360-raw350-d734-20260905/corpus360-coverage-audit.json`
- `../../../../../work/research/semantic-view-corpus-360/corpus360-raw350-d734-20260905/corpus360-coverage-audit.tsv`
- `../../../../../work/research/semantic-view-corpus-360/transition-old315-to-raw350-d734-20260905/semantic-view-transition.json`
- `../../../../../work/research/semantic-view-corpus-360/transition-old315-to-raw350-d734-20260905/semantic-view-transition.tsv`
- `../../../../../work/research/semantic-view-corpus-360/raw350-rejection-diagnostics-20260905/semantic-view-rejection-diagnostics.json`
- `../../../../../work/research/semantic-view-corpus-360/raw350-rejection-diagnostics-20260905/semantic-view-rejection-diagnostics.tsv`

Evidence hashes:

```text
CF5B89309BD4C19FB777A6A485E5639788C8CDA9A9689CAA54781EB3F001D531  schema-3 coverage JSON
DD0663963D59D773D3914D10F58D795D1CD6D1A9B01BD8C73F12460A7AE127B7  schema-3 coverage TSV
0E2F68A3C865B9DB9AFFEC63F93FCD34EE4AA7F46DD247F9E574A29BC1D7BC1F  transition JSON
B2260770E186E8BC6417D401466CC25B1D602EA04DC76EA999FD26091B7AFCA1  transition TSV
2CA3806F392DB66FC656EADB17BDA5150D7316138358E6A2EF352D694C774E91  rejection diagnostics JSON
72EF36381CF2DE261F9CF45D9561C7B6E3C77EA402CD6CFF21C98B92E20F69AF  rejection diagnostics TSV
```

## Confidence boundary and next work

For the 318 accepted scripts, the presentation relation, provenance, input
hashes, exact navigation spans, closure rows, exports, recompilation, container
integrity, and planner acceptance are deterministic machine-checked facts.
That is a strong structural foundation for a readable editor.

It is not yet valid to say that all 360 scripts are beautified or that every
API's gameplay meaning is live-proven. The next safe sequence is:

1. retain the raw-350 and stable-360 compiler lanes as separate immutable
   inputs; do not rewrite their claims or modify the pinned baseline binary;
2. fix the 15 mixed-name, 14 orphan-prototype, 1 loop/coverage, and 1 readable
   syntax renderer failures in an isolated presentation-layer candidate,
   without filename-specific exceptions;
3. fix the shared loop-region role-alias problem that blocks both views of
   `DiegeticUpgradeCards`;
4. after each generic renderer fix, rerun every member of its failure class and
   the previously accepted regression set; then rerun this exact coverage audit
   against a newly pinned compiler identity;
5. require semantic-accepted=360 and total-verified=360 before calling the layer
   corpus-complete; the separate stable compiler lane can supply all 360 inputs
   only when the audit records that mode explicitly;
6. extend the now-implemented exact export/closure outline with
   instruction-addressed native callsite records; do not derive call counts
   from the API identity index;
7. join callsites, receiver/type evidence, closure targets, and exported
   entrypoints into a display-only call/function graph only after that new
   sidecar has its own proof contract; and
8. permit structural edits only after each transform has its own inverse or
   compile/container/plan equivalence oracle.

The 10 raw first-pass compiler-parity blockers are:

- `Lotus_Interface_ChatRedux.lua_B`
- `Lotus_Interface_DialogWithCards.lua_B`
- `Lotus_Interface_DiegeticFoundry.lua_B`
- `Lotus_Interface_HudRedux.lua_B`
- `Lotus_Interface_InventoryTest.lua_B`
- `Lotus_Interface_LoadOutRedux.lua_B`
- `Lotus_Interface_LoadOutSelect.lua_B`
- `Lotus_Interface_LotusNetworkUtilities.lua_B`
- `Lotus_Interface_LotusUtilities.lua_B`
- `Lotus_Interface_MapRedux.lua_B`

## Superseding 360/360 closeout — 2026-09-06

The raw blocker list and 318/360 figures above are historical checkpoints.
They are superseded for the same selected sample by the final raw
`decompile-mod` certificate and schema-3 semantic audit:

```text
raw fixed points=360/360
semantic views=360/360
rejected=0 unverified=0
artifacts=1800/1800 temporaries=0
compiler/inventory/Ability CLI stable=true
```

The semantic transaction remains presentation-only and fail-closed. Mixed
plaintext/hash metadata is represented with a reversible hash suffix rather
than a guessed name. Unreachable prototypes are not invented as executable
closures: 27 prototype IDs in 15 files are explicitly and identically marked
in fidelity/readable source, retained in the sidecars, and recorded in each
semantic JSON. Terminal numeric loops require exact FORNPREP operands and
edges, a closed body region, one range exit, and no recurrence. Computed index
bases are parenthesized so literal bases remain valid Luau. The
DiegeticUpgradeCards compiler-generated loop relation is accepted only when
full natural-body containment and header dominance prove nesting.

The complete hypothesis/evidence table and hashes are in
`../SEMANTIC_BEAUTIFICATION_360_2026-09-05/STATUS.md`. The authoritative final
coverage files are:

- `../../../../../work/research/semantic-view-corpus-360/corpus360-final-20260906/corpus360-coverage-audit.json`
- `../../../../../work/research/semantic-view-corpus-360/corpus360-final-20260906/corpus360-coverage-audit.tsv`
- `../../../../../work/research/semantic-view-corpus-360/corpus360-final-20260906/corpus360-semantic-aggregate.json`

This closes the pinned 360-file Ability Studio beautification target. It does
not certify all 5,386 local stock scripts or an in-game run. The separate
unfiltered experiment found 20 ownership-manifest failures and 8 Semantic IR
verifier failures among 82,059 prototypes, and those negative results remain
documented in the closeout rather than being folded into the passing sample.
