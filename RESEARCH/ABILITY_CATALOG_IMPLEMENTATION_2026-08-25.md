# Ability catalog implementation — 2026-08-25

## Scope

Implement the first project-wide Warframe/ability browser for RENOVICE Ability
Studio. This is catalog infrastructure, not per-ability scripting.

## Hypotheses and results

| Hypothesis | Evidence | Result |
|---|---|---|
| The metadata snapshot contains an authoritative Warframe-to-ability ownership chain. | Playable base suits inherit directly from `/Lotus/Types/Game/PowerSuits/PlayerPowerSuit` and expose ordered `data.AbilityTypes`; each referenced ability object exposes `Script`, `Function`, localization tags, and `UniquePowerIdentifier`. | TRUE |
| Every object with `AbilityTypes` is a playable Warframe. | The unfiltered scan returned 495 objects, including NPC, Eximus, operator, vehicle, deluxe, and baby-suit definitions. | FALSE |
| Direct `PlayerPowerSuit` inheritance alone isolates playable Warframes. | It returned 76 objects and still included `BardNpc`, deluxe, operator, and NPC assets. | FALSE |
| Direct `PlayerPowerSuit` inheritance plus a `*BaseSuit` asset boundary identifies the intended playable base definitions in this snapshot. | The deterministic scan returns 62 definitions, each with four ordered ability slots. Manual inspection includes Octavia, Gyre, Rhino, Excalibur, etc., while the observed NPC/deluxe/operator noise is absent. | TRUE for the pinned snapshot |
| A module's loader body key can be reconstructed without a hand-written mapping. | Metadata supplies the module path; the corpus filename is its slash-to-underscore cache name; the loader's deployed basis `1469598103934665603` and prime `1099511628211` hash the exact bytes. Mallet resolves to the live-known `08faf07b504d058f`. | TRUE |
| Friendly names should be guessed from internal asset names. | Internal names include `BardMusic`, `BardCharm`, and many codenames that do not equal player-facing names. | FALSE |
| Existing Metadata Editor localization infrastructure can supply the names without another cache parser. | Its cache/Oodle/Languages decoder extracted installed `H.Misc_en` and maps Octavia's four tags to `Mallet`, `Resonator`, `Metronome`, `Amp`. | TRUE |
| All pinned playable abilities have exact stock bodies in the shared corpus. | Final catalog: 62 Warframes, 248 ability slots, 248 resolved body keys, zero unresolved modules. | TRUE for this snapshot/corpus pair |
| The production decompiler can supply source lazily from a selected catalog row. | CLI `render-source` invoked `semantic-ir-render-module` for Mallet, returned exit 0, and atomically produced non-empty verified source at `work/rendered-source/ability-editor/08faf07b504d058f.luau`. | TRUE |

## Implemented artifacts

- C++ catalog builder and CLI `build-catalog`.
- C++ production-source bridge and CLI `render-source`.
- WPF `ABILITIES` browser with search, Warframe hierarchy, counts, exact target
  preview, source rendering, and explicit addon/replacement draft actions.
- Installed English-name extraction by reusing `MetadataPatchEditor.Core`.
- Deterministic fixture tests for playable filtering, localization, module path,
  and the loader's nonstandard FNV body key.
- Pinned .NET 9.0.314 SDK to remove the preview-SDK warning.

## Current limits

- The metadata graph is the named 2026-07-01 workspace snapshot; installed
  `Packages.bin` build detection and update diff/rebase remain next-stage work.
- Icon and video paths are present in metadata but not yet projected into the
  catalog/UI.
- Catalog rows do not yet display active deployed addon/replacement state.
- Generic addons still require a proven hook/action template. Selecting an
  arbitrary ability does not invent a hook; the draft remains unbuildable until
  a registry-backed binding is selected.
- Source rendering is semantic-IR verified, but syntax services, completion,
  prototype navigation, and diff/rebase UX are separate checklist items.
