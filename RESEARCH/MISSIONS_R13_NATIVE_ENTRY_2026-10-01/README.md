# Missions R13: native-entry harness for the entry-template rows (2026-10-01)

- **Build:** client 44.0.2 (`2026.09.28.13.06`).
- **Branch:** ability editor `feat/missions-r13-native-entry-harness-2026-10-01`, from R12 `d0d963f`.
- **Runtime:** bootstrapper contract R13, `fix/r13-native-entry-member-policy-2026-10-01`
  (`RESEARCH/NATIVE_ENTRY_AND_MEMBER_POLICY_R13_2026-10-01/README.md` there).
- **Package:** unchanged. The installed R12 package (`Missions.targets.addon.lua_B` `8e0e1871…`, `package.json`
  `465c72be…`, `literals.json` `d9b3a764…`) is correct; the defect was in the runtime. No generator source changed.
- **Status:** offline gate PASS. Live pending.

## Why

Live 2026-10-01: Defense "Waves per reward" = 1 had no effect. Two runtime causes (full evidence in the bootstrapper record):

1. The Missions addon member was never staged: a stored `member:missions/missions.targets.addon.lua_b: false` from the
   R5/R6 member switches, which no UI has owned since Settings R7 (`members_staged=0/1`, `DELIVERY ... staged=0`).
2. Every entry prototype of the R10-R12 entry templates is a level-trigger or encounter function entered by the engine,
   and the R11 `luaCalls.before` observer saw only Lua CALL instructions. The `WaveDefense` hook (P50) could never run.

The R12 offline gates checked hook plans, hashed keys and declarations, but nothing ran the generated hook the way the
runtime enters it, and nothing replayed the installed ScriptStates.json.

## Hypotheses and results

| # | Hypothesis | Result | Evidence |
|---|---|---|---|
| H1 | The generated entry hooks write correctly once they are dispatched at a native entry. | **TRUE (offline)** | `test_entry_native_harness.py`: 22 entry rows, 113 checks: write per mode (absolute, scale, scale_inverse, scale_count with a list), MissionInfo write through `SetMission`, R3 retire signal, no compounding, a new instance written again, cleanup restore. |
| H2 | With the R13 boundary, Waves per reward changes the stock checkpoint rule. | **TRUE (offline, transcribed reader)** | WaveDefend P48 L9060 (wave counter + 1 after a wave) and L9228-9240 (`(counter - 1) % minWavesToComplete == 0` unless `isDuviriDefense` `b5fdc7ca` / `isCircle` `9dc69664`): stock 3,6,9,12; R11 boundary (no native-entry dispatch) 3,6,9,12 = the live symptom; R13 value 1: every wave; value 2: 2,4,6,... The addon prints `RENOVICE Missions: defense.waves_per_reward minWavesToComplete 3 -> 1`. |
| H3 | The generator needs a change. | **FALSE** | The rebuild of the pinned R12 input is byte-identical to the installed addon `8e0e1871…`. |

## Files

- `RESEARCH/UNIVERSAL_MISSION_REGISTRY_2026-09-29/tools/test_entry_native_harness.py` (new gate).
- `RESEARCH/MISSIONS_R13_NATIVE_ENTRY_2026-10-01/inputs/rebuild_input.r12.json` (pinned R12 build input, SHA-256
  `479e0a6b…a60203`, copied from `work/staging/combined-r12/evidence/generator/`).

## Limits

- The checkpoint rule is the decompiled reader run in plain Luau, not the DE bytecode in the game VM.
- Which entries the runtime dispatches is proven by the bootstrapper gate (`verify_lua_call_retirement.ps1` section 15),
  not by this harness.
