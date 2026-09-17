# Structural source rebase status — 2026-09-06

## Scope

This work preserves user-authored replacement-source edits when the verified
readable presentation is regenerated. It does not claim original game-byte
identity, replacement compiler closure, successful deployment, or in-game
behavior. Those remain later and separate gates.

## Hypothesis 1

**A textual whole-file replacement is unsafe once a user edits generated
readable source.**

Evidence:

- the readable files contain no inline prototype markers;
- exact prototype/value-web occurrences and instruction-addressed callsites do
  exist in the hash-bound semantic proof;
- an older and current independently valid Mallet presentation differ in 26
  line hunks even though they represent the same selected stock module;
- a user change can be separate from those 26 regions or can touch the same
  region.

Result: **TRUE.** Rebase ownership must come from semantic proof identities,
and overlapping changes must stop rather than guess.

## Hypothesis 2

**Non-overlapping user hunks can be transferred deterministically when their
prototype ownership and surrounding structural identities survive.**

Implementation evidence:

- a patience-style unique-line map computes deterministic baseline-to-user and
  baseline-to-generated hunks without quadratic memory use;
- every user hunk must resolve to exactly one smallest proven prototype range;
- each hunk requires at least one surviving boundary identity outside the
  edited region;
- value anchors use `(prototype, value-web, occurrence)` and call anchors use
  `(prototype, instruction, source_occurrence)`;
- the fresh proof must preserve every baseline canonical value identity, the
  exact closure graph, the exact export set, and every available baseline
  instruction-addressed callsite; added evidence rows are allowed, removed or
  changed structural evidence is not;
- the mapped generated segment must still equal the baseline segment exactly;
- hunks are applied from the bottom of the source upward only after every hunk
  passes, so one conflict prevents all output.

Result: **TRUE for the implemented fail-closed contract.** A real old-to-current
Mallet run had 26 generator hunks and preserved a separate user edit exactly.

## Hypothesis 3

**An edit in the same baseline region as a generator change must never be
resolved automatically.**

Evidence:

- the real Mallet line `v15_14 = v15_13[1]` became
  `v15_14 = (v15_13)[1]` in the fresh verified presentation;
- changing the old line's index to `[2]` created a user hunk over the same
  baseline line;
- the headless command returned exit code 1 with
  `OVERLAPPING_GENERATOR_CHANGE`;
- the JSON report status was `CONFLICT` and the requested merged output did not
  exist.

Result: **TRUE.** This is a manual semantic decision, so the engine emits
negative evidence and no code.

## Implemented artifacts

- `editor/Core/StructuralSourceRebaser.cs`
  - strict semantic bundle loading;
  - immutable hash-addressed baseline binding;
  - structural three-way rebase;
  - atomic preview/report writes;
  - `RENOVICE_STRUCTURAL_SOURCE_REBASE_V1` reports.
- `editor/Dev/Program.cs`
  - headless `--rebase-source` command;
  - success and conflict exit codes;
  - focused regression coverage.
- `editor/App/MainWindow.xaml` and `.xaml.cs`
  - fresh stock rerender;
  - three-input comparison and merged preview;
  - per-hunk conflict table;
  - apply button enabled only for a current zero-conflict result;
  - apply-time hash and merge recomputation.

## Focused verification

- managed suite: **82 passed / 0 failed**;
- WPF compile: **0 warnings / 0 errors**;
- published WPF process smoke: exact `RenoviceAbilityStudio.exe` stayed alive
  through startup and only the spawned test PID was stopped;
- headless unchanged-source run: `SAFE_TO_APPLY`, zero conflicts, output exists;
- real verified Mallet non-overlap run: one user hunk, 26 generator hunks, zero
  conflicts, edit retained;
- real verified Mallet overlap run: exit 1,
  `OVERLAPPING_GENERATOR_CHANGE`, no output;
- project workspace test: baseline bundle copied beneath a SHA-256 directory,
  binding reloaded, body key and hash revalidated.
- unrelated verified-module test: rejected as `STRUCTURAL_PROOF_MISMATCH`
  before any line mapping.

The current automation session exposed browser control only, so the new WPF
layout was not visually screenshot-checked or click-driven. The XAML compiled,
the published process started, and no real project rebase was applied during
verification. These are explicit remaining UI/runtime evidence boundaries, not
silent passes.

## Deliberate rejection boundaries

The engine emits no merged source for:

- no unique proven prototype owner;
- no structural evidence outside the edited lines;
- a missing prototype or boundary identity in the fresh proof;
- reordered anchors or a mapped region outside the fresh prototype range;
- any overlapping generator/user hunk;
- any unexplained target-context difference;
- an invalid, stale, path-escaping, body-key-mismatched, or hash-mismatched
  project baseline binding.

Old edited projects that predate baseline capture are not silently assigned the
current renderer output as their historical base. They remain rebase-unbound
until a trustworthy base is supplied. This avoids turning generator drift into
supposed user intent.
