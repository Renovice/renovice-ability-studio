# Archimedea objective controls — 2026-09-27

## Question and result

Hypothesis: EDA/ETA simply inherit every ordinary mission timer preset. **REFUTED.** Current ConquestLib explicitly defines independent mission-length overrides. Ordinary Survival pickup refill and the addon that advances elapsed time can still affect the shared Survival script; editing its reward-rotation interval alone does not alter Archimedea's required completion time. Thus "none of our scripts affect EDA/ETA" is also incorrect.

**SUPPORTED by current extracted source:** `Lotus.Scripts.Libs.ConquestLib`, body `a4c803e5a624d43d`, SHA256 `f66902986b5e5b8f46ed460c8dab1ff576a336c7464e7637813c62bf24620fa5`, is the authoritative configuration owner. `DeepArchimedeaMissionGenerator` selects LAB_CONFIGURATION or HEX_CONFIGURATION and copies `waveOverrides[missionType]` into the newly created mission's `maxWaveNum` (current readable lines 2310–2370). Both normal and Elite difficulties share these length settings; difficulty-specific enemy levels are separate and untouched.

| Mode / objective | Native setting | Stock | Faster example |
|---|---|---:|---:|
| ETA Survival | HEX waveOverrides[2], minutes | 10 | 5 |
| ETA Defense | HEX waveOverrides[8], waves | 6 | 3 |
| EDA Survival | LAB waveOverrides[2], minutes | 10 | 5 |
| EDA Mirror Defense | LAB waveOverrides[8], individual target defenses | 4 | 2 |
| EDA Alchemy | LAB waveOverrides[38], completed mixtures | 2 | 1 |
| EDA Disruption | LAB waveOverrides[33], completed conduits | 8 | 4 |

These are direct completion requirements, not reward multipliers, spawn-rate multipliers or repeated runtime enforcement. Survival is limited to whole minutes 1–60 (the consumer clamps at 3600 seconds); counts are limited to 1 through stock to avoid claiming uninvestigated extended-objective sequencing support.

## Consumer evidence

All sources were read from the current Steam cache and normalized using the existing U44 opcode map solely for offline analysis. Originals and rendered views are under ignored `artifacts/`.

- Survival: existing U44 `SurvivalMission.lua_B.canonical.luau`, lines 7190–7250: positive `info.maxWaveNum` selects fixed length, `min(maxWaveNum * 60, 3600)`. The independent reward table has `interval=300`, which the regular addon changes to 150. Shared elapsed time is also used in fixed-length checks; existing pickup-time advancement is not exclusive to reward rotations. Original evidence remains in `work/research/U44-2026-09-27/lua-port/artifacts` and `staged`.
- Mirror Defense: current `LoopDefend` recognizes Entrati ear/eye objectives, reads `info.maxWaveNum` (p9/p10), increments the target-phase index after defense, and calls completion when the index exceeds the configured requirement (readable 7870–7920). Phase duration is separate and unchanged by this control.
- Defense: current `WaveDefend` uses positive `info.maxWaveNum` as the fixed wave count (e.g. readable 7878–7920). ETA's mission permutation is VaniaEchoesDefense, with its separate 1999Defense special-enemy logic retained.
- Alchemy: `EntratiLabAlchemy` imports the mission's `maxWaveNum`; completed crucibles are counted and compared with the configured requirement before extraction (readable 4518–4530, 5536 onward).
- Disruption: `SentientArtifactMission` initializes `fixedLength` from positive `info.maxWaveNum` (p10 and inlined equivalents). It compares current `numDone` plus persisted completion count against that fixed length to enter MISSION_COMPLETE (13742–13818). This is a conduit target, not eight A/B/C reward rotations.
- ConquestManifest confirms LAB and HEX mission permutations. Existing Excavation, Mobile Defense, Interception, Control Area, Void Cascade, Netracell and Descendia timer controls are not the owners of the six settings above. Extermination, Assassination and Legacyte Harvest receive no new controls in this change; do not claim all objectives or all internal delays are covered.

## Implementation and validation

The existing mission-profile builder/exporter handles one additional profile. One exact stock replacement holds all six settings, avoiding two EDA/ETA exports competing for the same library body. The UI adds Mission Timers → EDA / ETA and groups the six large controls by mode/event. Stock defaults are retained until the user edits values or chooses Faster Examples. The export uses the existing folder picker, gates, readback and rollback mechanism. No runtime DLL, server settings or live game files changed.

`scripts/bindings.py --register` verifies the full stock hash and the six root LOADN→SETTABLE sequences, including mission-type keys, before writing the registry entry. It does not search globally for numbers. All other code and constants remain stock. `scripts/inspect.py` reproduces selected current-cache extraction; it requires the existing legacy extraction/parser helpers and toolchain in this workspace. The base profile regeneration script now restores these bindings as well.

Validation passed:
- C++ build and both CTest targets; 148 managed checks; WPF publish.
- All 12 mission-profile builds and 36 rejection cases.
- `scripts/test_archimedea.py`: eight exports (stock, all faster examples, each of six isolated changes); stock export is byte-identical; each isolated change leaves every other byte unchanged; all faster examples produce exactly six corresponding readable-source changes.
- All-prototype plan verification of the normalized candidate, exact native-container roundtrip, correct replacement export lane, and 18 zero/fractional/out-of-range rejection cases.

**INCONCLUSIVE until in-game testing:** full mission acceptance, special weekly conditions and multiplayer completion. After exporting, restart and generate a fresh Archimedea chain; an already generated mission retains its old MissionInfo. Verify the relevant completion/countdown display, finish a shortened objective and confirm the next chain stage/reward remains correct. Normal mission and other-mode settings should remain stock when left at defaults. No live test or deployment is claimed.
