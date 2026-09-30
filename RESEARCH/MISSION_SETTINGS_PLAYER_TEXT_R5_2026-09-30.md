# Missions SCRIPT SETTINGS: player text, headline knobs and the headline matrix (R5, 2026-09-30)

Client 44.0.2 (`2026.09.28.13.06`). Branch `feat/universal-mission-registry` (base `b278caf`). Contract:
`work/research/universal-mission-editor-2026-09-29/CONTRACT_PHASE1.md` Revision R5. Offline only: no game or server folder was
written (the installed package and values file were only read, to record the rollback set). No push. The bootstrapper was
not touched (its committed revisions `1a67d99` and `e935739` were exported with `git archive` into `work/temp/bsv/` to run its
gates).

## User feedback addressed

- Labels were built from ids and technical prose ("MD max sim. enemies, 1 player", "Alert LS drop mult"), the list was sorted by
  id, and headline values were mixed with internals.
- Mobile Defense had enemy counts but no terminal timer.
- Coordinator scope: headline knobs per mission type (timers, reward intervals, objective counts, enemies at once per player
  count), variants named plainly, one master knob per headline value that drives all variants (a ticked variant row wins),
  everything else in an Advanced area, and a matrix that shows which headline values are editable and what the missing ones
  need.

## Hypotheses

| # | Hypothesis | Result | Evidence |
|---|---|---|---|
| R5-1 | The labels are unreadable because the registrar derives them from ids and prose, and the list order is the JSON key order. | **TRUE** | `editor_fields.py` builds `short_label` from `humanize_id`/prose with abbreviation steps (`sim.`, `mult`); the generator used `nlohmann::json` (sorted keys) for `settings.values`, and the bootstrapper renders in declaration order (`settings_ui_core.hpp` `append_group_rows`). |
| R5-2 | Mobile Defense terminal timers are missing because they are function literals, not table fields. | **TRUE** | `Lotus_Scripts_MobileDefense.readable.luau` L2708-2744 (proto 22 `DefenseStage`): total = `Lerp(180, 240, mission.difficulty)` (LOADN i120/i121 into locals), x1.3 for Archwing vs Grineer, replaced by a positive `maxWaveNum`, the `CustomMissionTime` net var (`cap_24_184_6`, L80) or the game-rules `WaveTimer` (`cap_24_184_7`, L72), then per terminal `ceil(total / terminals)` into local `frame_22[140]` -> `SetObjTimer`. No root table holds it, so the addon lane cannot write it. |
| R5-3 | They were not in the menu for three separate reasons. | **TRUE** | (a) the registry rows `mobiledefense.total_time.minimum/maximum` are EXACT_LITERAL, and the live list declared only addon rows plus replacement members the build names; (b) a replacement member may declare exactly one literal value (design section 5), and the timer is two literals; (c) one module may own one artifact, and Mobile Defense already had 8 addon rows (enemy counts). |
| R5-4 | `survival.alert_interval` is a reward interval (registry label "Seconds per reward rotation (alert Survival)"). | **FALSE** | SurvivalMission proto 61 L9555-9576: `fixedLength = Ternary(maxWaveNum > 0, min(maxWaveNum*60, 3600), alertInterval)`; it is the **total length** of fixed-length Survival (Alerts, invasions, syndicate) when the mission gives none; it also replaces the reward interval there (L10501-10511), so the single reward and extraction come at that time. In the 2026-09-30 live test the user edited it (and the capsule interval) while trying to set the normal reward interval. Relabelled "Alert missions: reward time", placed right after "Time between rewards". |
| R5-5 | The five Five Fates Steel Path stage timers (`fivefates.state_times_sp.*`) change the Steel Path stage timers. | **FALSE** | Every `OverallStateTime` read (L5050, L5111, L7802, L8095, L8230, L8358, L8443) goes through `frame_84[114]` (normal table); the Steel Path table `frame_84[195]` is read only for Min/Max enemies and RespawnDelay (L2061-2072), which are nil in this module. The rows have no effect; they are hidden (`ui.hidden`) and the normal timers apply on Steel Path too. |
| R5-6 | A master knob can be resolved inside the generated addon with no bootstrapper change. | **TRUE (offline)** | `effectiveSettings(settings, context, masters, drives)`; luau harness over the full package: 27 cases (every addon master x hooked prototype): master x scale written into every driven row, an enabled driven row wins, a master with another stock or disabled writes nothing, cleanup restores, a stock-compiled master is inert without `context.settings`. |
| R5-7 | The R5 package is accepted unchanged by the current bootstrapper. | **TRUE (offline)** | No new declaration field. `verify_addon_settings.ps1 -Package -Settings`: `1a67d99` 167 PASS, `e935739` 163 PASS, ADDON SETTINGS GATES PASS (every tooltip within budget, uniform rows, R4 flat page); `verify_script_packages.ps1 -AdmitPackage`: `PACKAGE ACCEPT ... members=6 replacements=5 target_addons=1 target_keys=21`, SCRIPT PACKAGES GATES PASS on both. |
| R5-8 | Defense's regular enemy caps are literal because no consumer reads them. | **FALSE (research agent, inferred from the tool code)** | The consumer (WaveDefend proto 26 L3014-3112) reads them; the registrar addon gate (`addon_owner.py` `_consumer`) scans in straight bytecode order, and the Infested/Duviri/Circle branches overwrite the same registers, so the gate reports "no capturer reads N". Only the last table loaded (Duviri max) passes. A flow-sensitive gate would move them to the addon lane. |
| R5-9 | Rescue's hostage timer is MissionInfo-owned (registry exclusion). | **FALSE (research agent)** | Rescue proto 8 L706-709: `Lerp(90, 60, difficulty)` with literal operands; only the difficulty input is MissionInfo; `maxWaveNum > 0` overrides (L751-754). It is a literal-lane candidate (new registry row). |

## What changed

- **Player text** (`RESEARCH/UNIVERSAL_MISSION_REGISTRY_2026-09-29/tools/player_text.py`, data digest `83514CDC6C84E7EE...C1A703BA`): labels,
  one-sentence descriptions (effect, where/when, precedence, `stock <n><unit>`), section (main or `<family>_advanced`), rank and 28
  master knobs for 291 registry rows; 5 rows hidden (no reader). `python player_text.py` applies it to the registry in place;
  `register_registry.py` calls it after `editor_fields.apply`, so a full registrar run reproduces it. Registry
  `REGISTRIES/mission_build_u44.json`: `ui` of those rows, 17 `<family>_advanced` groups (`advanced_of`), `ui_masters`,
  `ui_player_text` (registry SHA-256 `270F9CAD7AD1EA08...4C814006`, working copy). `verify-missions` 594/594 PASS, structure PASS.
- **Generator** (`src/mission_profiles.inl`):
  - `verify_mission_ui`: family or `<family>_advanced` groups; labels unique per mission section; player-text gates
    (`player_text_problems`: label <= 33, value row <= 40, banned abbreviations, camelCase, stock + unit in the description,
    rendered tooltip <= 300); master checks (one module and lane, whole scales for int, stock = first row / scale, limits inside
    every scaled row, each row driven once, id distinct from rows); banned list must equal the registry's.
  - Masters: `values` may name them (all_addon_values only); literal masters are expanded into their driven rows and their
    member declares only the master; addon masters are compiled per target (`local masters`, `local drives`) and resolved in
    `effectiveSettings(settings, context, masters, drives)`. A build without masters emits the Phase 2i function unchanged
    (byte-identical sources: the presets and the 2g/2h/2i samples are unchanged).
  - `disabled_values` (build input): built, shipped off (compiled `enabled = false`, Settings `enabled: false`).
  - Hidden rows are excluded with their reason; `package.json` values are written in (section order, rank, id) order
    (`nlohmann::ordered_json`), read back by the settings-declarations gate.
- **Converter** `missions_settings_to_build.py`: masters are package values; literal entries are always rebuilt with their value,
  non-effective ones go to `disabled_values`.
- **Self-test** 148/148 (+3: R5 registry gates and rejections, master harness, literal master build and rejections).

## Mobile Defense timers: answer and fix

- **Why they were missing:** see R5-2/R5-3. The value is a pair of LOADN literals in `DefenseStage`; the addon lane only writes
  root-table fields; the live list declared literal values only as a one-value replacement member named by the build; and the
  module already belonged to the addon.
- **Fix:** master knob `mobiledefense.time_per_terminal` "Time per terminal" (stock 80 s, 60 s on easy nodes) drives both
  literals with scale 3 (`total = 3 x value`, per terminal `ceil(total / 3)` with the usual 3 terminals). It is built as one
  replacement member (`a807aae359ffc1eb`, exactly 2 bytes changed: operands 180 -> 60 and 240 -> 60 for the user's 20 s example)
  that declares only the master. Shipped **off** (`disabled_values`): Mobile Defense stays stock until the player ticks
  "Custom Time per terminal"; it applies from the next mission. Archwing vs Grineer still multiplies by 1.3; a positive
  `maxWaveNum`, `CustomMissionTime` or `WaveTimer` still overrides (stock behaviour).
- **Trade-off (reported, not silent):** while this member is in the package, the 8 Mobile Defense enemy-count rows and their 4
  masters are not declared (`excluded_values`: "body key a807aae359ffc1eb is built as an exact replacement"), because one module
  may own one artifact. To get them back, remove `mobiledefense.time_per_terminal` from the build input and rebuild. Both at
  once needs R5-C (composition) or R5-L (live literal values).
- **The value is not typed in game.** A literal is fixed at build time; the value page shows it read-only. Change it in
  `evidence/rebuild_input.mission_settings.json` and rebuild. R5-L would make it editable in game.
- Earlier work used: `RESEARCH/MOBILE_DEFENSE_TIMER_LIVE_RECOVERY_2026-09-12.md` (proto 22 luaCalls addon crashed live at
  `DefenseStage(910)`; the exact replacement of i120/i121 is the working owner). Same two sites, now on the 44.0.2 body key.
- **Same analysis for other literal-only headline timers:** Excavation dig time (master `excavation.dig_time` over standard,
  Elite Alert and Old World Salvage, built 50 s = the user's earlier preset, shipped off) and Control Area hold time (Plains and
  Cambion Drift, built 30 s = earlier preset, shipped off) had a safe lane (no addon rows in their modules) and were added. Orb
  Vallis has no stock value (the time comes from the mission resource `defendTime`), so it is not declared. Survival's
  life-support timers are addon rows (already live). All other literal-only headline values are listed in the matrix.

## Headline matrix (every mission type)

Legend. **LIVE**: in SCRIPT SETTINGS, typed in game, applies live. **SWITCH**: in SCRIPT SETTINGS as an on/off switch; the value is
fixed when the package is built. **REBUILD**: registry row on the literal lane, not in the package (**C** = its module already
belongs to the addon, so adding it would displace that module's live values). **RESTART**: registry metadata row; the generator
writes an `OpenWF/Metadata Patches` file (restart), not shown in SCRIPT SETTINGS. **MISSING**: no registry row. Effort: S = a
registrar/generator change (about a session), M = a bootstrapper primitive plus a live proof, L = new owner research (native,
level data or node metadata) before any lane exists.

Lanes that unlock many rows at once: **R5-L** live literal values (M, bootstrapper: patch declared sites at apply) turns every
REBUILD row into an in-game value; **R5-C** replacement + addon on one module (M) removes every **C**; **R5-M** metadata values
from SCRIPT SETTINGS (M, design phase 6) turns RESTART into in-game (restart); **GATE** flow-sensitive addon gate (S-M,
registrar) moves Defense's regular enemy caps (and possibly other root tables that fail today) to LIVE; **MI** normal-node
`MissionInfo.maxWaveNum` producer (L: decode region node metadata in Packages.bin; the server sends MissionInfo only for alerts,
Archimedea is Lua); **LEVEL** level-placed script parameters (L: decode `.level` ScriptTriggers); **NAT** native owner (L).

| Mission | Headline value (stock) | Now | To make it editable in game |
|---|---|---|---|
| **Survival** (all variants: normal, Steel Path, Kuva, Void Eclipse, 1999, Duviri) | Time between rewards (300 s) | LIVE | - |
| | Alert missions: reward time (600 s, the whole fixed-length mission) | LIVE | - |
| | Life support at start / per capsule / per pickup / at 100% (150/45/7/150 s); time between capsules (90 s); time at 0% before death (300 s) | LIVE | - |
| | Fixed length from the mission (`maxWaveNum` x 60, max 3600 s) | MISSING (MissionInfo) | MI (L) |
| | Duviri Survival length (300 s) | REBUILD C | R5-C or R5-L (M) |
| | Enemies at once | MISSING (no Lua owner found; spawner is native or level data) | NAT/LEVEL research (L) |
| **Defense** | Duviri: max enemies (solo..squad) | LIVE | - |
| | Max enemies, regular and Infested ({10,20,26,29}) | REBUILD C (addon gate false negative) | GATE (S-M) -> LIVE |
| | Waves to finish (`maxWaveNum`; special 6, Nightmare 3, Duviri 3, Circuit 1) | normal nodes MISSING (MissionInfo); fallbacks REBUILD C | MI (L); fallbacks R5-L/R5-C (M) |
| | Intermission / first wave delay (6 s / 6 s) | REBUILD C | R5-L + R5-C (M) |
| **Mobile Defense** | Time per terminal (80 s; 60 s easy nodes) | SWITCH (built 20 s, off) | R5-L (M) for typing it in game |
| | Max enemies at once (solo..squad) | displaced by the timer member (LIVE in builds without it) | R5-C (M) |
| | Terminals per mission (3) | REBUILD | R5-L (M) |
| **Exterminate** | Kills needed | MISSING: AI director population is native; no Lua writes it (Purge does, via `SetMaxPopulationSpawnCount`) | NAT (L) |
| | 1999 Escalation: keys needed (solo..squad) | LIVE | - |
| | 1999 Escalation: supply crate timer (120 s) | REBUILD C | R5-L + R5-C (M) |
| **Excavation** | Dig time per excavator (100 s; Elite Alert 140, Old World 60) | SWITCH (master, built 50 s, off) | R5-L (M) |
| | Excavators to finish (`maxWaveNum`) | MISSING (MissionInfo) | MI (L) |
| | Duviri excavations (3) | REBUILD | R5-L (M) |
| **Interception** | Rounds to finish (`maxWaveNum`; special 2) | MISSING (MissionInfo) | MI (L) |
| | Score to win a round (`scoreGoal`), round end timer | MISSING (level-placed globals) | LEVEL (L) |
| | Scoring speed | preset only (template addon, not multi-instance safe) | new root-table owner (S-M) |
| **Disruption** | Delay before enemies spawn (10 s) | LIVE | - |
| | Rounds (default 4, Sortie 8; `maxWaveNum` on nodes) | REBUILD C / MISSING | R5-L + R5-C (M); MI (L) |
| | Round timer 180 s, time between rounds 20 s (relic 10 s) | REBUILD C | R5-L + R5-C (M) |
| | Max/min enemies per player count (standard, Sentient, lab) | REBUILD C (root tables that failed the addon gate) | GATE check (S-M) |
| **Void Flood** | Fractures per round (3) | SWITCH (built 4, **on**, as before) | R5-L (M) |
| | Tank fill time (200 s -> 60 s) | addon rows displaced by the fracture member | R5-C (M) |
| | Tanks to finish (`maxWaveNum`) | MISSING (MissionInfo) | MI (L) |
| **Void Cascade** | Exolizer defense time (90 s) | LIVE | - |
| | Alert missions: reward interval (10 exolizers); Circuit: exolizers to finish | LIVE | - |
| | Exolizers to finish (`maxWaveNum`), normal reward interval (4) | MISSING / excluded (PARTIAL) | MI (L); confirm row (S) |
| **Void Armageddon** | Wave, reward, prepare timers | MISSING: owner script `/Lotus/Scripts/Zariman/Encounters/DynamicAssassinateEndless.lua` (strings `REWARD_INTERVAL`, `WAVE_TIME`, `PREPARE_TIME`) not decompiled | render + registry (S-M) |
| **Capture** | Target health (solo..squad) | LIVE | - |
| | Downed target: grace 20 s + fail 60 s | REBUILD C | R5-L + R5-C (M) |
| **Sabotage** | Reactor prongs (5, Corpus) | excluded (coupled to the 5-entry heading table) | structural edit (M) |
| | Other variants' timers | MISSING (Sabotage, SabotageModular, SabotageOrokin, GrineerShipyard, GasCity, Forest not decompiled) | render + registry (S-M) |
| **Spy** | Vault alarm timer | MISSING (`intelTimerDurationMax/Min` are level-placed) | LEVEL (L) |
| | Vaults required (`maxWaveNum`) | MISSING (MissionInfo) | MI (L) |
| **Rescue** | Hostage timer (Lerp 90 -> 60 s by difficulty) | MISSING (wrongly excluded as MissionInfo; it is a literal) | new literal row (S) -> SWITCH; R5-L (M) |
| **Assassination** | Boss timers/counts | MISSING (native; Lua only reads the `BombTimer` net var) | NAT (L) |
| **Hijack** | Payload health (10000; goal missions 3000) | REBUILD | R5-L (M) |
| **Defection** | Max enemies at once (solo..squad) | LIVE (masters) | - |
| | Squads to rescue (4; Sortie 5) | REBUILD C | R5-L + R5-C (M) |
| **Infested Salvage** | Max enemies at once, time between spawns (solo..squad) | LIVE | - |
| **Alchemy** (lab and Descendia) | Rounds to finish (`_TRANSMUTER_GOAL` 1), reward interval (1) | RESTART | R5-M (M) |
| | Mixtures per round | MISSING (not found) | research (M) |
| **Mirror Defense** | Max enemies at once (solo..squad, regular and Infested) | LIVE (masters) | - |
| | Phase timer (150 s; Jade 60 s) | REBUILD C | R5-L + R5-C (M) |
| | Phases to finish (`maxWaveNum`) | MISSING (MissionInfo) | MI (L) |
| **Lantern** | Max enemies at once (solo..squad), time between tier-ups (90 s) | LIVE | - |
| | Score to win (300 s), time to reach extraction (180 s), boss after (900 s) | REBUILD C | R5-L + R5-C (M) |
| **Purgatory** | Kills for reward tiers 1-6 | LIVE | - |
| | Starting time (60 s), time per pickup (5 s), enemy cap (10), spawn interval (3-5 s) | REBUILD C | R5-L + R5-C (M) |
| **Descendia** | Destroy Targets: targets to destroy (solo..squad) | LIVE | - |
| | Shrine Defense: offering stage time (420 s), enemies at once, time between waves | LIVE (masters + Advanced rows) | - |
| | Shrine Defense: time to make an offering (30 s) | RESTART | R5-M (M) |
| | Excavation: dig time (45 s) | REBUILD | R5-L (M) |
| | Mobile Interception: beacon chase time (25 s) | RESTART | R5-M (M) |
| | Nemesis: spawn interval (15 s) | REBUILD | R5-L (M) |
| | Hive: tumors (solo..squad) | excluded (PARTIAL) | confirm row (S) |
| | Meltdown: start delay (80 s), vents (3) | RESTART | R5-M (M) |
| | Floors per descent | MISSING (native/server-seeded) | NAT (L) |
| **1999** | Faceoff: Exterminate kills, Defense/Escort/Excavation objective times, Delivery keys, Assassination targets, enemies at once | LIVE | - |
| | Defense (1999): drone spawn interval (5 s) | REBUILD | R5-L (M) |
| | Legacyte Harvest: search time (100 s; Descendia 60) | RESTART | R5-M (M) |
| | Legacyte Harvest: captures to finish (`_T.RequiredCaptures`) | MISSING (literal found by the research agent) | new literal row (S) |
| **Orphix Venom** | Rounds per reward (3), time between Orphix spawns (50 s; event 90), Orphix at once (3), Railjack round limit (36) | LIVE | - |
| | Sortie rounds (12) | REBUILD C | R5-L + R5-C (M) |
| **Sentient Mobile Defense** | Max enemies at once (solo..squad) | LIVE | - |
| | Defend time (120 s), areas (3) | REBUILD C | R5-L + R5-C (M) |
| **Five Fates (Cetus)** | Stage timers 1-5 (420/3600/180/240/180 s, also on Steel Path) | LIVE | - |
| **Control Area bounties** | Hold-zone time: Plains, Cambion Drift (90 s) | SWITCH (built 30 s, off) | R5-L (M) |
| | Orb Vallis | REBUILD row without a stock value (mission resource `defendTime`) | owner research (M) |
| **Hack-Station Defense** | Defend time per station (30-240 s by difficulty), stations (4) | REBUILD | R5-L (M) |
| **Netracell** | Power required (200 + 100 per extra player) | REBUILD | R5-L (M) |
| | Power per kill (1) | RESTART | R5-M (M) |
| **Deep/Temporal Archimedea** | Survival minutes, Defense waves, Alchemy mixtures, Disruption conduits | REBUILD (Archimedea preset) | R5-L (M) |
| **Pursuit / Archwing Fomorian** | Phase timer (60 s) / EMP timer (30 s) | REBUILD | R5-L (M) |
| **Ascension** | Elevator time (150 s x3; StageSeven 80) | RESTART | R5-M (M) |
| **Entrati Swarm** | Tears per stage | REBUILD C | R5-L + R5-C (M) |
| | Max Eximus / Eximus chance per area | LIVE (Advanced) | - |
| **Purge** (no star-chart nodes) | Population to kill (50) | REBUILD C | R5-L + R5-C (M) |
| **Rush, Circuit rewards, Railjack, Junction, Sanctuary Onslaught, Arbitration** | Rush timer (native formula); Circuit stages per reward (unresolved global); Railjack/Junction/Onslaught (owner not established); Arbitration resurrection cap (REBUILD) | MISSING / REBUILD | NAT/LEVEL (L); R5-L (M) |

Totals: every star-chart mission type is listed. LIVE or SWITCH headline values now exist for Survival, Defense (Duviri),
Mobile Defense, 1999 Escalation, Excavation, Disruption (spawn delay only), Void Flood, Void Cascade, Capture, Defection,
Infested Salvage, Mirror Defense, Lantern, Purgatory, Descendia (Destroy Targets, Shrine), 1999 Faceoff, Orphix Venom, Sentient
Mobile Defense and Swarm Capture, Five Fates and two Control Area bounties. The largest single step is R5-L (live literal
values), then R5-C; the objective counts that come from `maxWaveNum` (Defense, Interception, Excavation, Spy, Mirror Defense,
Void Flood/Cascade) and the Exterminate kill count need owner research first (MI, NAT).

## Label examples (before -> after)

| Value | Before | After (section) |
|---|---|---|
| `mobiledefense.enemy_counts.max.p1` | MD max sim. enemies, 1 player | Hard nodes: max enemies (solo) (Mobile Defense: advanced; master "Max enemies at once (solo)") |
| `survival.alert_ls_drop_mult` | Alert LS drop mult | Alert missions: pickup drop rate (Survival: advanced) |
| `survival.reward_interval` | Reward interval | Time between rewards |
| `survival.alert_interval` | Seconds per reward rotation (misleading: live test edited it instead of the reward interval) | Alert missions: reward time (listed right after Time between rewards) |
| `survival.capsule_interval` | Capsule interval | Time between capsules |
| `survival.pickup_time_added` | Pickup time added | Life support per pickup |
| `survival.player_damage_at_zero_ls.killPlayerTime` | Zero-LS kill time | Time at 0% before death |
| `survival.duviri_drop_mults.duviriSurvivalMultiplier` | LS drop mult. (Duviri) | Duviri: pickup drop rate (advanced) |
| `defense.simultaneous_enemies_duviri.max.p1` | Sim. enemies Duviri max 1P | Duviri: max enemies (solo) |
| `defection.max_sim_ai.max_p1` | Max sim AI max, 1 player | Hard nodes: max enemies (solo) (advanced; master "Max enemies at once (solo)") |
| `loopdefend.enemy_counts.maxNumInfested.p2` | Infested max sim. enemies 2P | Infested: most enemies (duo) (advanced) |
| `faceoff.exterminate_kill_goal.max` | Exterminate kill goal max | Exterminate: most kills (advanced; master "Exterminate: kills needed") |
| `shrine.respawn_delay.sp.boss_part_2.p4` | Respawn delay SP boss part 2 4P | Steel Path boss: waves (squad) (advanced; master "Time between waves (squad)") |
| `infested_salvage.spawn_caps_by_players.spawn_delay.p1` | Spawn delay, 1 player | Time between spawns (solo) |
| `loopdefend.eximus.exPeakTime` | Eximus ex peak time | Eximus ramp peak (advanced) |
| `fivefates.state_times.state2` | State 2 duration | Defend huts stage time |
| `void_cascade.pillar_duration` | Exolizer/pillar duration | Exolizer defense time |
| new `mobiledefense.time_per_terminal` | (not in the menu) | Time per terminal |

Example tooltip (CHECKBOX, rendered by the bootstrapper page model): "Off: the stock value is used. Stock 18. Range 1 to 32767.
Mirror Defense enemies alive at once with 1 player, regular and Infested; a ticked Advanced row wins; stock 18 enemies.
Applies: live, at the next read. Custom value applies only where the live value equals stock."

## Gates

| Gate | Result |
|---|---|
| Build (`-Werror`) | 0 warnings, 0 errors |
| `player_text.py` (labels <= 33, value row <= 40, banned abbreviations, camelCase, stock + unit, tooltip <= 300, per-section uniqueness incl. uncurated rows) | PASS: 291 rows, 28 masters, 5 hidden |
| `verify-missions` (registry structure incl. the same player-text and master gates in C++) | 594/594 PASS, structure PASS |
| C++ self-test / ctest | 148/148 / 2/2 |
| luau harness | 3-module `cases=6 idle=6 retire_all=6`; full package (self-test build, Mobile Defense on the addon lane) `cases=4 idle=64 retire_all=64 other=45`; wide `cases=11 idle=69 retire_all=69 other=50`; masters `cases=27` |
| Build gates of the staged set | de-roundtrip 6/6 FULL BODY identical; multi-target-declared-keys 21/21; hook-plan PASS (63 hooks, all idle/settled/retire-all); package-folder PASS members=6; settings-declarations PASS values=294 groups=37 masters=24 (incl. the declaration-order read-back) |
| `test_presets_and_sample.py` | 12 presets byte-identical, 36 rejections; 2b/2d/2e/2f unchanged; 2g/2h/2i identical except the known intentional files; full package identical to the staged set |
| `test_phase2k_hook_plan.py` / `test_phase2e_gates.py` / `test_phase2d_gates.py` | 6 / 7 / 7 PASS |
| Bootstrapper `verify_addon_settings.ps1 -Package -Settings` (`git archive` of `1a67d99` / `e935739`) | 167 / 163 PASS, ADDON SETTINGS GATES PASS |
| Bootstrapper `verify_script_packages.ps1 -AdmitPackage` (same copies) | PACKAGE ACCEPT members=6 replacements=5 target_addons=1 target_keys=21; SCRIPT PACKAGES GATES PASS |

## Package inventory (previous `e05f4980` set -> this set)

- Declared values 281 -> 294: +22 addon masters, +2 literal masters (Mobile Defense time per terminal, Excavation dig time),
  +2 literal rows (Control Area Plains and Cambion Drift hold time); -5 hidden Five Fates Steel Path timers (no reader), -8
  Mobile Defense enemy-count rows (displaced by the timer member, see the trade-off).
- Members 3 -> 7 files (addon, package.json, 5 replacements: Void Flood as before, Mobile Defense, Excavation, Plains, Cambion).
- Shipped choices unchanged: Survival time between rewards 150 s (on), Void Flood fractures 4 (on); the four new literal values
  are built with the user's earlier choices and shipped off.

## Future (not in scope)

- **Warframe base ability stats in game.** Needs research on the metadata owners (`/Lotus/Powersuits/...` ability types and
  upgrade tables in Packages.bin) and on the native owners of computed ability values; the existing card-row and ability addon
  work (Mallet, Ice Wave) covers single abilities, not a universal base-stat table. Suggested first step: a Phase 1-style owner
  census for ability stats (metadata field vs native computation), then the same lanes as missions (metadata at restart, addon
  where a Lua table owns the value).

## Live test (not done here)

See `work/staging/missions-full-package/README.md`.
