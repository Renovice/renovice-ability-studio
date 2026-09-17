# Instruction-addressed API callsite integration — 2026-09-06

## Conclusion

The selected 360-script corpus now has a complete six-artifact readable-source
transaction. Every module produces readable source, its canonical fidelity
twin, a value-web naming map, an API callsite map, a closure ownership map, and
a hash-bound semantic proof. The final corpus audit accepted 360/360 modules,
rejected zero, retained exactly 2,160 artifacts, and left zero temporary files.

This now includes the next Ability Studio layer: exact call navigation,
receiver-type provenance, explicit descriptor-join basis, and conservative API
contract display. Discovering every parameter's gameplay
meaning, side effect, or dynamic return type is not required for faithful
decompile/recompile. Those facts should be added only when evidence supports
them; current unknowns remain explicit.

## Hypotheses and results

| Hypothesis | Result | Evidence and consequence |
|---|---:|---|
| One bytecode call instruction always renders to one source expression. | **False** | Structured control flow can duplicate an instruction into mutually exclusive regions. The final maps contain 49 multi-projection calls across eight modules: 44 have two expressions and five have three. They account for 54 expressions beyond the distinct-call count. |
| A callsite row can be recovered without guessing from source text. | **True** | The renderer inserts private nested markers while emitting each authoritative call, removes them before publication, and records the resulting UTF-8 byte spans. Readable and fidelity spans are paired by exact prototype/instruction and ordered occurrence. No method-name search establishes identity. |
| Repeated projections can be counted as separate bytecode calls. | **False** | The bytecode identity remains `(prototype, instruction)`. `source_occurrence` starts at zero and is contiguous; repeated rows must carry identical block, effect order, webs, arity, descriptor, and contract evidence. Only their source spans may differ. Corpus totals count occurrence zero once. |
| A `CONFIRMED` SDK row proves that no overload has another arity. | **False** | `UIMovie:Execute` was confirmed for one two-argument form, while stock bytecode also proves zero- and one-argument calls. The SDK has no exhaustive-overload field. Outside-form stock calls are therefore `OBSERVED_MISMATCH`; they retain the descriptor evidence but are not promoted to confirmed violations. |
| A catalog minimum/maximum envelope preserves non-contiguous observed arities. | **False** | `PowerSuit:GetUpgradeModifiedValue` was observed at exactly `2|4|5`; the old compact feed exposed `2..5` and incorrectly made arity 3 look observed. `symbols.tsv` now carries `observed_args` and `observed_open_args`; catalog matching uses that exact set. |
| An explicit `Avatar` receiver can select the `Avatar:DamageControl` descriptor over `AvatarOrEntity:DamageControl`. | **True** | The type join compares only explicitly spelled type alternatives and nullable wrappers. It treats `Avatar` as a syntactic refinement of `AvatarOrEntity`; the three pinned instructions now select the existing confirmed descriptor with `RECEIVER_TYPE`, zero ambiguity, and no invented class hierarchy. |
| A receiver type learned only from the same unique method name independently proves descriptor ownership. | **False** | Such rows retain their type candidate but are marked `UNIQUE_METHOD_NAME`, not `RECEIVER_TYPE`. A separate `RECEIVER_TYPE_CONFLICT` state preserves explicit incompatible evidence instead of silently joining it. |
| Every observed mismatch or selected open-width call proves a new deep overload. | **False** | The strict target audit records 186 review rows: all 132 corpus mismatches plus 54 open-width calls in the original six target descriptors. Of these, 176 are unique-name joins, six have explicit receiver conflicts, and four have receiver-compatible joins. These rows prove instruction identity and call shape, but not parameter meaning, return type, side effects, or exhaustive ownership. No new deep overload was published. |
| The Nokko source itself failed to compile. | **False** | The first parallel audit built a 264-character private fidelity-verification path for `NokkoArchGunRandomRotation`, crossing this executable's Windows path boundary. Short private `.rv.lua_B.tmp` and `.fv.lua_B.tmp` suffixes reduce the stressed path to 248 characters; the same long-named module then passed every source and container gate. Final artifact names did not change. |
| The corrected source-occurrence and overload model covers the selected corpus. | **True** | The final native audit and the independent managed verifier both accept 360/360 scripts with zero unverified files. |
| Recompilation is compiler-closed and does not drift on the selected corpus. | **True, within the stated boundary** | The final `decompile-mod` certificate passes 360/360 at cycle 2 and 5/5 default difficult witnesses through cycle 10, with zero byte, source, structure, prototype, max-stack, or opcode drift between rebuilt cycles. |
| Rebuilt bytecode is byte-identical to DE's original stock bytecode. | **False as a current claim** | The fixed-point certificate reports `original_byte_identity=0`. It proves cycle-2-to-later-cycle stability, not original-to-rebuilt byte identity. |
| These offline gates prove complete live gameplay behavior. | **False** | The gates prove compilation, parsing, exact DE-container round-trip, semantic-plan validity, source-view alignment, sidecar integrity, and selected fixture behavior. No new in-game deployment or live gameplay test was performed here. |

## Final corpus measurements

| Measurement | Result |
|---|---:|
| Selected scripts | 360 |
| Accepted / rejected / unverified | 360 / 0 / 0 |
| Coordinated artifacts | 2,160 / 2,160 |
| Global temporary files after audit | 0 |
| Aligned source tokens | 8,460,780 |
| Authorized readable aliases | 290,002 |
| Naming rows | 271,249 |
| Closure sites / ordered captures | 17,010 / 41,496 |
| Exact exports | 6,765 |
| Distinct bytecode API calls | 143,691 |
| Rendered API call expressions | 143,745 |
| Calls joined to one SDK descriptor | 26,068 |
| Calls carrying a confirmed descriptor | 20,066 |
| Calls carrying an unresolved descriptor | 108 |
| Explicitly unregistered calls | 117,623 |
| Receiver-type / unique-method-name / receiver-conflict joins | 1,236 / 7,801 / 434 |
| Ambiguous descriptor joins | 0 |
| Calls outside a known observed form | 132 |
| Confirmed contract violations | 0 |
| Static call names / unique joined descriptors | 6,741 / 112 |

Call kinds are 69,128 methods, 63,586 global functions, and 10,977 dynamic
functions. One module has no calls; 359 have at least one.

The eight modules with repeated structured projections are:

- `Lotus_Interface_1999_RetroMessenger`
- `Lotus_Interface_DuviriMissionComplete`
- `Lotus_Interface_DuviriTitleCard`
- `Lotus_Interface_EidolonMissionComplete`
- `Lotus_Interface_HudFighter`
- `Lotus_Interface_HudRedux`
- `Lotus_Interface_InputDialog`
- `Lotus_Interface_Minigames_OlliesCrashCourseTimer`

## Targeted API evidence result

The bounded review covered the six existing target descriptors and the three
formerly ambiguous `DamageControl` instructions. The exact-set fix also
exposed four `RemoveUpgrade` mismatches hidden by the old range envelope, so
the evidence includes them rather than leaving the corpus aggregate
unexplained. The 54 open-width rows from the original six targets are kept as
a separate class because they cannot be assigned a fixed arity.

| Existing descriptor | Strict review evidence | Result |
|---|---:|---|
| `AvatarOrEntity:SetPosition` | 84: 76 fixed outside-set calls and eight open calls | Four rows have compatible receiver evidence; 80 are only unique-name joins. The mixed UI callsites do not support a new blanket Avatar contract. |
| `UIMovie:Execute` | 68: 29 zero-argument, two one-argument, and 37 open calls | All 68 are unique-name joins. The existing confirmed two-argument Generic Settings form remains scoped to its evidence. |
| `AvatarOrEntity:ApplyCustomization` | 9 two-argument calls | Seven are unique-name joins; two explicitly carry `Customization` receiver evidence and are conflicts. No blanket overload was added. |
| `AvatarOrEntity:PlaySound` | 6 one-argument method calls | All six are unique-name joins. Separate global `PlaySound(...)` calls remain unregistered and are not conflated with this descriptor. |
| `AvatarOrItem:GetCustomization` | 10: three two-argument and seven open calls | All ten are unique-name joins. No argument or return contract was invented. |
| `PowerSuit:GetUpgradeModifiedValue` | 5: one three-argument, two six-argument, and two open calls | Four rows have explicit `InventoryControl` receiver conflicts; the remaining open row has no independent receiver type. The exact `2|4|5` catalog set is preserved and no `PowerSuit` overload was added. |
| `PowerSuitOrAvatar:RemoveUpgrade` | 4 two-argument calls | Its exact catalog set is `1|3|4|5|6|7|8|9|open`, so all four are now visible mismatches. They are unique-name joins and do not establish a new deep overload. |

The three pinned zero-argument `DamageControl` calls now resolve to the existing
confirmed `Avatar:DamageControl` descriptor. They are
`Lotus_Interface_LoadOutRedux` prototype 99 instruction 440 and
`Lotus_Interface_LotusUtilities` prototype 493 instructions 29 and 31. Each
has an independently refined `Avatar` receiver, a `RECEIVER_TYPE` join, and a
`MATCH` result. This conclusion is instruction-scoped; it does not generalize
unknown behavior beyond the existing zero-argument contract.

The checked-in target TSV contains all 189 rows with module, prototype,
instruction, exact arity/open state, receiver web/type/evidence, join basis,
descriptor status, contract result, and the exact readable byte span. Its JSON
summary records the two explicit True/False hypotheses used above.

## Negative evidence retained

The first attempted corpus pass stopped after 331 accepted modules. Its
one-span representation could not encode duplicated structured projections,
and 29 modules had no committed six-file result. That checkpoint is invalid as
a completion claim and remains under:

`C:\Users\Bartek\OneDrive\Dokumenter\Warframe RE PROJECT RENOVICE\work\research\semantic-view-corpus-360\corpus360-api-calls-20260906`

After source occurrences were added, the next full audit reached 338/360. It
correctly exposed 21 overclaimed `CONFIRMED_MISMATCH` results and one Windows
verification-path failure. Its report is retained as negative evidence:

`C:\Users\Bartek\OneDrive\Dokumenter\Warframe RE PROJECT RENOVICE\work\research\semantic-view-corpus-360\corpus360-api-calls-occurrences-20260906\corpus360-coverage-audit.json`

SHA-256:
`79D56D9EEC331DC58F7D75AC7E5BF8598E1AD737A3D18CFF5341645B7DC2155F`

## Final evidence

- Final compiler: `derecomp.exe` SHA-256
  `60157E2FD66E884E089AA7762AA7C5CD79C67748A502B7885FF6FEAE5AB46D6C`.
- Final Ability Studio CLI SHA-256:
  `0C903B90C2C9ABED5AD724406371288A9D2688EAF8E5B0EF03D9B49445182FF0`.
- Compiler-closed fixed-point certificate:
  `..\..\..\..\toolchains\de-luau-toolchain\cert\baselines\fixedpoint-full360-api-receiver-exact-shapes-2026-09-06.json`,
  SHA-256 `79D3B79F8EE7D9571406D62E0115A0DE80021422242146C1743A81D049FCA195`.
- Final six-artifact audit:
  `C:\Users\Bartek\OneDrive\Dokumenter\Warframe RE PROJECT RENOVICE\work\research\semantic-view-corpus-360\api-receiver-exact-shapes-certified-v1-20260906\corpus360-coverage-audit.json`,
  SHA-256 `E7F02F1B091FBCB7784D64609343B340D22546EA8B79D6F0986ED1D0AE2BA9DE`.
- Checked-in callsite aggregate:
  `corpus360-api-callsite-aggregate.json`, SHA-256
  `48A5A6B197C827F6115F9B5FE3D32710E1E0D421DC6CBCB785A10117962050CE`.
- Checked-in target evidence:
  `corpus360-target-api-form-evidence.tsv`, SHA-256
  `1197459D93EE1A30EBBAD6DDA20BC3F3C64715DD5D39D0153B51F2404B43AD36`,
  and `corpus360-target-api-form-summary.json`, SHA-256
  `A40232987FE66F51C35B4E0ED9D7204ADFEDA074D5F9742A4D4B1E042D1AA0AB`.
- Final 300/150 release gates:
  `..\..\..\..\toolchains\de-luau-toolchain\cert\baselines\release-gates-api-receiver-exact-shapes-2026-09-06.json`,
  SHA-256 `636D86169F664E2861F2CA97C1925621CAF5F3FA55236CDAC679895E0608D430`.
- Release result: all gates pass; semantic behavior 150/150, behavioral
  round-trip 150/150, API trace 11/11, no dropped paths, no lost named accesses,
  and zero failures in the machine-readable report.
- Native/managed Ability Studio build: CMake/CTest pass, C++ self-test pass,
  managed suite 66/66, WPF publish pass.
- Independent managed corpus verifier: 360/360, 2,160 artifacts, the exact
  counts above, and zero confirmed contract violations.

## Validation boundary

The readable view is accepted only when its token stream differs from the
fidelity view by the two fixed preamble comments and aliases authorized by an
exact `(prototype, value-web)` identity. Both views compile and reparse, their
DE containers round-trip exactly, and their semantic plans verify before the
six-file transaction is activated.

API call records prove instruction identity, effect order, call kind, static
name when recoverable, callee/receiver/argument/result value webs, exact
explicit/open arity, source spans, and the unambiguous SDK descriptor/evidence
available today. They do not infer unknown semantic names, hidden side effects,
native ownership behavior, or dynamic return types.

No game directory, backup, injector deployment, or live process was modified by
this work.

## Ability Studio inline evidence layer

Hypothesis: the hash-validated callsite spans can drive useful inline API
diagnostics without treating an absent SDK descriptor as proof of a broken
call, and without allowing stale spans to survive a user edit.

Result: **TRUE** for the current Ability Studio implementation.

- The readable `TextBox` keeps its existing source bytes and editing behavior.
  A separate WPF adorner with pointer hit testing explicitly disabled projects the already verified UTF-8
  call spans into text positions; it does not rewrite the document.
- One ordered UTF-8 boundary pass maps all callsite offsets, avoiding a full
  source rescan for each call expression.
- Every exact call expression receives a subtle dotted evidence marker and a
  tooltip containing its prototype/block/instruction/source-occurrence
  identity, descriptor status, join basis, receiver provenance, argument and
  result widths, parameter/return text, and the explicit evidence boundary.
- `OBSERVED_MISMATCH` is red. `UNRESOLVED`, `AMBIGUOUS`, and
  `RECEIVER_TYPE_CONFLICT` are amber. Descriptor-less `UNREGISTERED` calls stay
  informational because the current evidence proves only that no SDK contract
  was selected.
- Source-hash freshness is rechecked after every edit. A mismatch clears all
  inline spans and tooltips and displays the disabled reason; restoring or
  regenerating the exact verified base reconstructs them.
- Live WPF inspection loaded Mallet with 368 exact expressions and 24 warning
  expressions (one ambiguous and 23 receiver conflicts). A second resolved
  stock target loaded 334 expressions and 30 warnings (two unresolved and 28
  receiver conflicts), showing that the categories come from each module's
  proof rather than a UI constant.
- Native CTest passes, the managed suite passes 71/71 including five new
  evidence-boundary checks, WPF publish passes, and the launched editor remains
  responsive.
- The final post-change independent corpus verification passes 360/360 with
  zero rejects and revalidates all 2,160 retained artifacts, 143,691 distinct
  bytecode calls, 143,745 source expressions, 132 observed mismatches, zero
  ambiguous calls, and zero confirmed-contract violations.

Negative evidence retained: API completion remains unfinished; the tooltip
does not claim unknown parameter meanings or runtime side effects. Syntax
highlighting, structural rebase/edit anchors, user-edit preservation, and live
gameplay validation are separate later gates. No game file, backup, injector,
or live game process was modified by this UI work.
