# Missions R12: Defense "Waves per reward" (2026-10-01)

- **Build:** client 44.0.2 (`2026.09.28.13.06`), U44 name-hash seed `768e5ed0`.
- **Branch:** ability editor `feat/missions-r12-defense-reward-2026-10-01`, from `feat/missions-r11-railjack-2026-09-30`
  `3316ef1`.
- **Runtime:** unchanged. Bootstrapper `feat/settings-r11-coupled-literals-2026-09-30` `0cb0182`, installed DLL
  `b729b2e1…`. No generator C++ change either (the CLI build in `work/builds/ability-editor/current` is up to date).
- **Contract:** `work/research/universal-mission-editor-2026-09-29/CONTRACT_PHASE1.md`, Revision R12 (one row on the R10
  lane; no new primitive).
- **Research input:** `work/research/defense-reward-interval-2026-10-01/README.md`. The draft (`inputs/r12_row_drafts.json`)
  is pinned by its LF content (`B6410C68…5EF4C4`) in `tools/mission_owner_specs.py`.
- **Status:** every offline gate PASS. **Nothing here is live-tested.** Nothing was deployed or pushed.

## Hypotheses and results

| # | Hypothesis | Result | Evidence |
|---|---|---|---|
| H1 | The reward interval is the `MODK 3` at WaveDefend P48 i455 (readable L8055). | **FALSE** | K104, exclusive to that instruction, but it only skips the `StartedDefenseWave<N>` voice line on every third wave when the VIP agent is a `TempleDefenseAgent`. Left stock. |
| H2 | The reward interval is the trigger parameter `minWavesToComplete` and the R10 lane `SCRIPT_PARAM_GLOBAL_AT_ENTRY` reaches it. | **TRUE (static)** | Hash `69d6d911` (only WaveDefend of 5,473 bodies); readers P36 i238/i307 and P48 i960/i1122, all reached only from P50 `WaveDefense` (a root child); registrar census and `CAPTURE_GRAPH_ENTRY_V1` re-derived from the pinned stock bytes. Level value 3 on all 28 regular Defense maps; Duviri (9 triggers, 3) and Descendia arenas (13 triggers, 2) skip the checkpoint code. |
| H3 | The row needs no generator or runtime change. | **TRUE** | Mode `absolute` (as `interception.round_end_timer` and the Deepmines rows). The P50 hook already exists (Waves to finish); the hook plan stays at 34 targets / 101 hooks, entry rows 21 → 22, hashed parameter names 17 → 18. `literals.json` is byte-identical to R11. |
| H4 | The user's tooltip texts fit the R7 text gates without duplicating the default. | **TRUE** | "Waves per reward" description: "Waves between each reward and extraction choice." The editor tooltip renders "Default 3. Range 1 to 1000. Applies at the next mission." itself (bootstrapper `editor_tooltip`), so "Default 3" is not repeated in the description. "Waves to finish": "0 / Endless = keep going as long as you like; a number ends the mission after that wave." plus the existing special-mission sentence. |

## What was admitted

| Page | Row | Id | Lane | Default |
|---|---|---|---|---|
| Defense > Rewards / drops | Waves per reward (Quick: "Defense: waves per reward") | `defense.waves_per_reward` | parameter `absolute`, global `minWavesToComplete` at the `WaveDefense` entry | 3 (1 to 1000) |

Range: minimum 1 (0 would make the checkpoint test `x % 0`, which never matches); maximum 1000 (numeric guard, not a tested
gameplay range). Applies at mission start (next mission); a mid-mission change restores the map's value for the rest of that
mission (R10 cleanup rule).

## Files changed

- `tools/mission_owner_specs.py`: R12 draft input (pinned), generic per-draft provenance.
- `tools/player_text_r10.py`: R12 text row. `tools/player_layout.py`: R12 page, row and Quick entry; R7 descriptions for
  `defense.waves_per_reward` and `defense.waves_to_finish`.
- `tools/test_live_literals.py`: the R12 provenance joins the expected added addon values.
- `REGISTRIES/mission_build_u44.json` (663 rows; registry SHA-256 `7FB6B4E5…5B141A8ED`), `registry_build_report.json`,
  test results. Registry diff against R11: one new row, one `scope_text`, `ui.rank` of 426 rows and 34 masters, counters.

## Package (staged `work/staging/combined-r12/`, 2 files)

| File | SHA-256 |
|---|---|
| `Missions.targets.addon.lua_B` (34 targets, 101 hooks, 22 entry rows, 18 hashed parameter names) | `8e0e187124379d78ab039bc283eb9963d9696d6f1d7c4a420af5a3d96c1ebb07` |
| `package.json` (369 declarations incl. 30 masters) | `465c72be3b3c7b740c149b812369f257f2e9553ebf1380c8105ef77d01864807` |
| `literals.json` (unchanged, not staged) | `d9b3a76481e3999d46b7571ff23073c525fd8e71cdef5e8748c4197de39aabdd` |

491 values in SCRIPT SETTINGS (490 before), 40 mission types, 16 Quick settings entries. Build input: the R11 input unchanged
(`rebuild_input.r12.json`).

## Gates

| Gate | Result |
|---|---|
| Build (g++, `work/builds/ability-editor/current`) | no source change; `ninja: no work to do` |
| `register_registry.py` → `player_text.py` (x2), then again | PASS; 663 rows; fixed point (data `4A55ED105B322148`, registry `7FB6B4E5…` twice) |
| `verify-missions` | 663/663 PASS, structure PASS |
| self-test / ctest | 149/149 / 2/2 |
| `test_live_literals.py` | 29/29 |
| `test_presets_and_sample.py`, `test_flow_gate.py`, `test_phase2d/2e/2k` | PASS (flow gate 288 / 20 / 37 / 0 regressions) |
| Package build gates | `entry-parameter-keys` PASS names=18; `multi-target-declared-keys` 34/34; `hook-plan` targets=34 hooks=101 entry_rows=22; `live-literal-core` PASS `2fdda7b8…`; `live-literal-recipe` PASS values=122 extreme_syntheses=244; `settings-layout` PASS values=369 live_literals=122 quick=16; `settings-declarations` PASS |
| Bootstrapper `verify_live_literals.ps1` (wt-r11, `0cb0182`) | LIVE LITERALS GATES PASS (146 checks, `/W4 /WX`) |
| Bootstrapper `verify_addon_settings.ps1 -Package` (R12 Missions + installed Frost/Octavia, installed values files) | ADDON SETTINGS GATES PASS; `LIVE LITERALS RECIPE ACCEPT … values=122`; Missions `declarations=491 rejected=0 unknown_entries=6`; `target_keys=34`; rows `Waves per reward: 3 (default)` and Quick `Defense: waves per reward` rendered |

## Limits (exact)

- **Nothing is live.** Pending: the addon write line, the checkpoint after every N waves, the relic reward count, the OpenWF
  reward count (client-reported `rewardQualifications`; not traced), clients in a squad (the hook writes on every machine
  that enters WaveDefense; on a client WaveDefense returns at once when `gRegion:IsMaster()` is false, readable L9643-9654,
  so only the host's checkpoint loop reads the value).
- Duviri: a value below 3 also delays the session hide from late joiners by 1-2 waves. Descendia arenas: no effect.
- The Temple-agent voice-cue literal (H1) stays 3.
