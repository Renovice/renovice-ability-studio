# Mission replacement creation and API baseline — 2026-09-09

> **Superseded for all four timer presets later on 2026-09-09:** The Survival full replacement passed
> every offline compiler, roundtrip, semantic-plan, and stock-baseline API gate,
> then failed the live keypad/start gate. The old project is retained with
> status `REJECTED`. A second closure audit proved its pickup reward-progress
> insertion targeted remaining life support rather than elapsed reward time.
> Timer creation now emits V60 exact target addons for Survival, Mobile Defense,
> Interception, and Excavation and preserves each stock mission module. See
> `MISSION_TIMER_TARGET_ADDONS_2026-09-09.md` for the accepted bindings and the
> current offline/live evidence boundary.
>
> **2026-09-11 status:** that four-addon statement is historical. Excavation,
> Plains Control Area, and Deimos Control Area now use hash-pinned exact
> replacements; Survival, Mobile Defense, Interception, and Venus/Nokko Control
> Area retain verified target addons. Current Control Area evidence is in
> `CONTROL_AREA_LIVE_RECOVERY_2026-09-11/README.md`.
>
> **2026-09-12 status:** Mobile Defense also uses a hash-pinned exact replacement.
> The prototype-22 addon failed the live datamass-to-defense transition. The exact
> replacement changes only the stock 180/240 second operands and preserves the
> rest of the module byte-for-byte.

## Result table

| Hypothesis | Evidence | Result |
|---|---|---|
| **Create Replacement Project** did not create anything. | The action wrote `work/ability-projects/mission.survival.timers.replacement/ability_edit.json` and `source/replacement.luau` at 2026-09-09 08:54. | **FALSE** |
| The editable Survival source implements the requested timer behavior correctly. | It contains the requested literals, but the inserted pickup expression writes `frame_76[116]`/root R32, which the later closure audit proved is remaining life support. Elapsed reward time is root R42/prototype 64 capture 19. | **FALSE** |
| The first saved manifest was a clean native replacement. | It was `NATIVE_REPLACEMENT`, but inherited Mallet's localization tag, `renovice.mallet.damage_dispatch`, evidence, stacking policy, and complete `LINKED_DAMAGE_TO_CASTER_OVERGUARD` generator from the addon template. | **FALSE** |
| Changing modes previously removed addon-only semantics. | `AbilityProject.SetMode(Replacement)` changed only owner and deployment flags. | **FALSE** |
| Replacement creation now removes inherited addon-only semantics. | The shared model clears hook/evidence/stacking, removes `addon_generation`, resets inherited ownership text to explicit replacement/rollback text, and exposes replacement-specific mode metadata. Managed regression checks pass. | **TRUE** |
| A mission replacement can use the ability-only API catalog as a strict whole-file contract. | Untouched stock Survival calls include `Enable(true)` and `ApplyForce(vector)`, while the 55,709-site selected ability census records only `Enable()` and two-argument `ApplyForce`. The original build `D9884B3199A6` therefore failed with two false whole-file catalog violations and 378 stock calls outside the registry. | **FALSE** |
| Baseline-aware checking can stay strict for intentional additions. | `wf_api_check` now subtracts the hash-validated stock multiset keyed by call kind, name, visible arity, and callback arity, then applies `--strict-unknown` to remaining calls. A fixture with unchanged stock overloads passes; an introduced unknown call fails. Receiver identity remains a separately reported limitation. | **TRUE** |
| The repaired Survival project passes all offline staging gates. | Generation `6B3266206458` reports compile/reparse PASS, 79/79 constant re-encode and full-body round-trip PASS, all 79 prototype plans with zero failures, and API baseline 648/648 stock calls suppressed with zero candidate calls, zero violations, and zero unknown calls. | **TRUE** |
| The replacement was installed or tested in game. | Build manifest says `live_write_performed=false`; no deployment command or gameplay run occurred. | **FALSE** |
| Mission creation should produce only an internal draft. | The button now opens a Windows `.lua_B` save dialog, retains the editable project internally, runs the same complete gated build, independently validates `STAGED_PASS`, every gate, artifact size, and SHA-256, then atomically exports the verified bytecode. | **FALSE** |
| Choosing an existing output can discard its previous bytes. | An overwrite is retained under `work/export-rollbacks/ability-editor` before the verified artifact replaces the selected file. | **FALSE** |
| Windows shell presentation should define the default output name. | The shared core validates the exact 16-hex body key and deterministically emits `1e3647332a578b78 (mission_survival_timers_replacement).lua_B`; invalid keys fail before the dialog opens. | **FALSE** |

## Current artifacts

- Project manifest: `work/ability-projects/mission.survival.timers.replacement/ability_edit.json`
- Editable source: `work/ability-projects/mission.survival.timers.replacement/source/replacement.luau`
- Rebase/API baseline binding: `work/ability-projects/mission.survival.timers.replacement/source/rebase-binding.json`
- Passing generation: `work/staging/ability-editor/mission_survival_timers_replacement/6B3266206458`
- Staged bytecode SHA-256: `33351682596BC29F34D6DD544A9A1460427B036F7DF52F900B83393C7718D5A2`
- Editable source SHA-256: `B562F825CC7D7CD3532DA348DF5FF25C51F92DBAA20863AC779EED8F5F4EBA72`
- Verified stock baseline SHA-256: `F19BFAC8F475769FF6978917993C4EFB745114B87E3C27D4D91E3B3FB75B9150`

## Operational meaning

Creating the project writes the editable Lua and its JSON manifest. **Validate**
checks project/source structure. **Build** compiles and stages a `.lua_B` only
after all gates pass. **Deploy** is a later explicit transaction. These are
three separate states and the Studio must display them separately.
