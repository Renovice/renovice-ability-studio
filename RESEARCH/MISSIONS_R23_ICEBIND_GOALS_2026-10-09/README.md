# Missions R23: Icebind goals (Disruption conduits, Excavation excavators, Survival minutes) (2026-10-09)

- **Build:** client 44.1.1 (`2026.10.08.13.05`), U44 name-hash seed `768e5ed0`; registry adopted for this build
  (`6fa90d7`).
- **Runtime:** no change (addon lane, R13 native entry dispatch).
- **Status:** every offline gate PASS. Staged `work/staging/r23-icebind-goals-2026-10-09/`. Not live.

## Request

User (2026-10-09): Icebind Disruption asks for 8 conduits although every Disruption value is set lower; add Icebind's own
goals under each mission type, and let the type's settings cover them.

## Hypotheses

| # | Hypothesis | Result | Evidence |
|---|---|---|---|
| H1 | Icebind sets its own goal per mission type. | **TRUE** | KuvaKeysLib `MISSIONS` (44.1.0 and 44.1.1): Survival 10, Excavation 6, MobileDefense 540, Disruption 8 (`MaxWaveNum`), copied by `GenerateKey` into the key and by `BuildMissionInfo` into `MissionInfo.maxWaveNum`. |
| H2 | The existing goal rows never apply in Icebind. | **TRUE** | R10 rule writes only when `maxWaveNum == 0` and no alert/sortie/...; Icebind always has a goal. The Disruption round literal patches only the default 4 (`Ternary(maxWaveNum > 0, maxWaveNum, 4)`). |
| H3 | The goal can be patched in KuvaKeysLib's table on the literal lane. | **FALSE** for 8 and 10 | Their number constants are shared with other templates of the same root (8: `WIDHT`, `OFFSET_SILVER_CLAIMED` of the per-player chest bit table; 10: `STATE.COMPLETED`). 6 and 540 pin exactly. |
| H4 | One write of `MissionInfo.maxWaveNum` at each script's entry reaches every reader. | **TRUE (static)** | `goal_owners.py` (bytecode capture graph, reproduces the R10 Excavation/Survival owners exactly): SentientArtifactMission `Mission` (P85) reaches all live readers (P9, P55, P81, P82, P84; P8 and P10 dead); KuvaPath `KuvaPath` (P73) captures MasterInit (P65), which takes the `GetMission()` snapshot all its readers use (P42 and the type phase checks P0-P5, P7). Excavation and Survival reuse the R10 owners. |
| H5 | `LotusGameRules` (where `_T.IsKuvaPathMission` is set) is a single earlier write point. | **UNRESOLVED (rejected design)** | That function runs once from `OnUpdate`; no evidence orders it before the level scripts. Two writes (mode script + Icebind script), idempotent, make the order irrelevant. |
| H6 | Mobile Defense's Icebind goal is `maxWaveNum`. | **FALSE** | KuvaPath completes Mobile Defense at `MobDefConsolesDone >= 3` (literal 3); 540 is used only for phase pacing. The script is replaced by the Icebind Solo package (squad scaling member), so a literal row would compete with that replacement. Not admitted. |

## What was admitted

| Master (page) | Rows (Advanced) | Modules | Stock | Range |
|---|---|---|---|---|
| `disruption.icebind_goal` (Disruption > Objectives) | `disruption.icebind_conduits`, `_kuvapath` | `b6d8c45f9424d376`, `248d54e0074e52c2` | 8 | 1-1000 |
| `excavation.icebind_goal` (Excavation > Objectives) | `excavation.icebind_excavators`, `_kuvapath` | `f7444e3c621ff018`, `248d54e0074e52c2` | 6 | 1-1000 |
| `survival.icebind_goal` (Survival > Timers) | `survival.icebind_minutes`, `_kuvapath` | `a62aa7eea1c4f27b`, `248d54e0074e52c2` | 10 | 1-60 |

Write rule (variant `KUVA_PATH_MISSION`): host; `mission.location == Symbol("KuvaPathMission")`, `missionType` equal,
`maxWaveNum ==` Icebind stock; skip when already equal; another number is left alone with one line.

## Change

| File | Change |
|---|---|
| `src/mission_profiles.inl` | `KUVA_PATH_MISSION` MissionInfo variant: verify rule (location, positive mission type, stock = variant_stock > 0, minimum >= 1), helper `missionInfoKuvaPath_<field>`, per-row apply. Normal-node rows unchanged. |
| `RESEARCH/UNIVERSAL_MISSION_REGISTRY_2026-09-29/tools/mission_owner_specs.py` | `entry_row`: the variant (stock = Icebind value, minimum >= 1). |
| `tools/player_text_r23.py` (new), `player_text.py`, `player_layout.py` | Masters and rows, placement. |
| `tools/test_icebind_goals_harness.py` (new) | 27 checks. |
| `RESEARCH/MISSIONS_R23_ICEBIND_GOALS_2026-10-09/inputs/r23_row_drafts.json`, `tools/add_r23_rows.py` | Drafts and the append step on the current build (the registrar is pinned to 44.0.2). |
| `REGISTRIES/mission_build_u44.json` | +6 rows, +3 masters, KuvaPath module; corpus + KuvaPath stock body. |

## Gates

See `work/staging/r23-icebind-goals-2026-10-09/README.md`. The CLI self-test fails 2 of 91 checks that pin the 44.0.2
registry (pre-existing since the 44.1.0 adoption; separate task).

## Limits

- Not live. The entry dispatch is the R13 native entry path, live-proven for other entry rows.
- Host only, as every MissionInfo row. Squad clients get the host's MissionInfo as the game replicates it (not checked).
- Disruption: the mode script also uses the goal as its round count (fixedLength); with N conduits it allows N rounds,
  always enough for N conduits.
