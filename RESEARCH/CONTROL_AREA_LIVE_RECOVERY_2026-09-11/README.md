# Control Area live recovery (2026-09-11)

## Scope and observed failure

The Ability Studio Venus/Nokko Control Area project requested **30 seconds**.
The in-game objective still displayed **1:30**, which is the stock 90-second
duration. This was a live failure, not the configured reduced value.

The failed live addon was body-keyed to `e192d5cc2f37056e`, loaded successfully,
and registered one target addon. The log then recorded execution of prototype 9
but no prototype-6 callback:

- log lines 496352-496356: exact target identity, injection, and target-addon
  registration passed;
- log lines 500462-500464: the target executed and the runtime observed
  `luaCalls.9.after.skipped`;
- the visible timer remained 90 seconds.

## Hypothesis results

### H1: 1:30 was the requested reduced duration

**Evidence:** the project JSON contains `duration_seconds=30`. Plains and Deimos
decode a literal stock duration of 90. Venus/Nokko obtains its stock default
from mission-resource global `defendTime`; the tested objective displayed 1:30.

**Result: FALSE.** The requested reduction is 30 seconds. The 1:30 result was
stock behavior and therefore falsified the deployed addon.

### H2: prototype 6 is a live-dispatched target-addon boundary

**Evidence:** stock prototype 9 is exported as `DefendStart`. Its first action
calls captured prototype 6, which reads `defendTime`, passes it to
`GetNetPersistentVar`, and derives `defendTime / 2` and
`defendTime - defendTime / 3`. The V61 live log observed prototype 9 but never
entered the configured prototype-6 callback.

**Result: FALSE live.** Prototype 6 is a nested stock call and was not dispatched
through the runtime's exported Lua-call hook boundary on the tested path.

### H3: setting `defendTime` once before exported `DefendStart` preserves stock ownership

**Evidence:** closure map target 9 is created by root prototype 15 at instruction
253 and exported as `DefendStart`. The first two stock statements load and call
its captured initializer. The initializer reads the same resource-backed
`defendTime` owner for the objective timer and both derived thresholds.

**Result: FALSE live.** The target addon loaded, but every prototype-9 callback
failed with `Venus/Nokko resource defendTime is not a positive number`.
`defendTime` is a mission-resource import in the stock module and is not exposed
as an ordinary global in the addon environment. The addon therefore never owned
the value it claimed to change and has been retired.

## Corrected artifact and deployment

- Project: `work/ability-projects/mission.control_area_nokko.timers.addon/ability_edit.json`
- Build: `work/staging/ability-editor/mission_control_area_nokko_timers_addon/4F40F087D594`
- Generated source SHA-256: `A9D368CA2896AAD19833DB36D2F9097ACB77777DD6F3F1B2E8078FCC493A4B2A`
- Bytecode: 997 bytes, SHA-256
  `6B4E432527CCF7809B22374576D8D6658E8D1D31A4F9DEDDFFBA039724546796`
- Live target: `OpenWF/CustomScripts/Inject/e192d5cc2f37056e.Control_area_nokkoTimers.target.addon.lua_B`
- Rollback manifest:
  `work/staging/ability-editor/mission_control_area_nokko_timers_addon/4F40F087D594/rollback/deployment-1789089740034/DEPLOYMENT_MANIFEST.json`

The artifact passed recompile/reparse, exact DE container roundtrip, semantic
plan verification for all four generated prototypes, and the focused strict API
gate. Deployment was atomic and preserved the previous 1,104-byte artifact with
SHA-256 `ABE86E692CC1272617B0B1D0F9053289B3039B386BC0B597915C61AFA33AD035`.

## Diagnostic acceptance plan

`renovice.cfg` is temporarily narrowed to target `e192d5cc2f37056e` and the
exact deployed addon filename, with a 256-event bound. On the next game start,
start a **fresh** Venus/Nokko Control Area objective. Acceptance requires:

1. target-addon load and activation pass;
2. `luaCalls.9.before` provider success in the exact target environment;
3. a visible starting duration of approximately 30 seconds;
4. normal pause, capture, halfway, completion, and exit behavior.

An objective created before the addon generation loads is not a valid test,
because its stock initializer has already captured its duration.

The exact pre-test log offset, expected hashes, target, addon, and prototype are
recorded in [`NEXT_LIVE_TEST_BOUNDARY.json`](NEXT_LIVE_TEST_BOUNDARY.json).

## Plains and Deimos correction

The user confirmed that the separate Plains and Deimos 30-second projects
produced the same unchanged 90-second behavior. The stock closure maps establish
the same cause:

- Plains exports `DefendStart` as prototype 11. It immediately calls captured
  initializer prototype 10, but the exported closure does not expose root
  duration register `R21` to the addon. The old prototype-8/prototype-1 addon
  callbacks therefore targeted nested owners the runtime did not dispatch.
- Deimos exports `DefendStart` as prototype 9. It immediately calls captured
  initializer prototype 8, but the exported closure does not expose root
  duration register `R23`. The old prototype-7 duration callback therefore had
  the same invalid live-boundary assumption.

**Result: the nested-callback addon hypothesis is FALSE for Plains and Deimos.**
The two old projects are marked `REJECTED`, their schemas are retired, and their
live addon artifacts were hash-verified and moved into the corresponding
deployment rollback directories.

Both bodies have a narrower authoritative edit than a runtime callback:

| Body | Stock owner | Patch | Linked stock behavior |
|---|---|---|---|
| Plains/Narmer `bf3c901cb4058c47` | root prototype 17, instruction 44, `LOADN A=21 B=90 C=0` | `B=30` | stock root later copies `R21` to its reinforcement-pacing baseline |
| Deimos `d9541341dfd466a3` | root prototype 15, instruction 56, `LOADN A=23 B=90 C=0` | `B=30` | stock root derives the one-third and two-thirds pacing thresholds from `R23` |

There is no pacing shim, timer callback, polling loop, repeated setter, or
parallel state machine. Each generated body differs from the pinned stock body
at one byte and retains the full stock code and data layout.

## Plains and Deimos artifacts and deployment

| Preset | Pinned stock SHA-256 | Build | Output bytes | Output SHA-256 | Only changed offset |
|---|---|---|---:|---|---|
| Plains/Narmer | `ECC204753DB9BDED69F6A764C919DF5DD2240B5EE907E35C046E99C624D23386` | `DB7D0A6162C9` | 9,693 | `1510F45328A50499DD681DB6AAD62E033B59B24B113BDE90D6E2B9867CE72A8B` | `0x21FF: 90 -> 30` |
| Deimos | `ECBED12E85416CE5FBB25995D9252F4AD29042F1AE7DAA3C2E4C8A2F25AEDF49` | `644F55A7523F` | 11,456 | `C6EB345AE5B19A43100AA4DEABA58030F162ED947A9B1F9C67236CBD9EBCA8B8` | `0x2882: 90 -> 30` |

Every artifact passed seven gates: stock hash, exact patch location, exact byte
diff, DE compiler roundtrip, semantic plan, semantic IR for every prototype,
and unchanged prototype layout with operand-only differences.

The live replacement paths are:

- `OpenWF/CustomScripts/bf3c901cb4058c47 (mission_control_area_plains_timers_exact-replacement).lua_B`
- `OpenWF/CustomScripts/d9541341dfd466a3 (mission_control_area_deimos_timers_exact-replacement).lua_B`

Deployment and retired-addon rollback records are under:

- `work/staging/ability-editor/mission_control_area_plains_timers_exact-replacement/DB7D0A6162C9/rollback/deployment-1789090989338`
- `work/staging/ability-editor/mission_control_area_deimos_timers_exact-replacement/644F55A7523F/rollback/deployment-1789090989605`

These fallback-only artifacts were live-falsified: all three tested worlds still
showed the stock 1:30 timer. They remain preserved in their deployment rollback
directories and are superseded by the final correction below.

## Final authoritative-consumer correction

The three scripts pass `GetNetPersistentVar(key, fallback)` into their stock
timer setup. Changing only a fallback cannot replace a 90-second value already
stored by the mission. The final replacements keep each stock state machine and
change the following exact consumers:

| World | Exact edits for 30 seconds | Reason |
|---|---|---|
| Plains/Narmer | root proto17/i44 `LOADN 90 -> 30`; proto8/i100 `MOVE R5,R0 -> LOADN R5,30` | preserves root reinforcement pacing and supplies 30 directly to stock `SetObjTimer` |
| Deimos | root proto15/i56 `LOADN 90 -> 30`; proto7/i63 `GETUPVAL R4 -> LOADN R1,30` | preserves root pacing and replaces the persisted duration result before stock computes the halfway timer |
| Venus/Nokko | proto5/i118 `MOVE R6,R1 -> LOADN R6,30`; proto6/i107 `SUB -> LOADN 15`; proto6/i112 `SUB -> LOADN 20` | supplies 30 to stock `SetObjTimer` and preserves its linked one-half and two-thirds thresholds without accessing the unavailable resource import |

No replacement changes pause, capture progress, completion, host migration,
enemy registration, cleanup, or any timer loop. The Venus/Nokko editor accepts
multiples of six so both linked fractions remain exactly representable.

| World | Build | Live SHA-256 | Bytes |
|---|---|---|---:|
| Plains/Narmer | `B6EF3D7B39F5` | `4A15BB3A63F8A5F5DEB50B49DE4A26062F3D11886A329558F1C9510D132FA6F4` | 9,693 |
| Deimos | `05D58858CAA0` | `42F302FB1AA661FE28C8E71C79C888AB7213801EBD3BFC2D30886A46C4EF20DB` | 11,456 |
| Venus/Nokko | `A29282486F15` | `B7A5EBCF95E1994F2414D6572E96120EBD8EEEA8BD7D66C962C51AD2FD3F550A` | 15,692 |

All three passed pinned stock hash, exact patch-site, exact byte-diff, DE
round-trip, semantic plan, semantic IR, and unchanged prototype-layout gates.
Deployment preserved the prior live artifacts in transaction rollback folders.
The failed Venus addon SHA-256
`6B4E432527CCF7809B22374576D8D6658E8D1D31A4F9DEDDFFBA039724546796`
was moved into the Nokko build rollback folder with a retirement manifest.

Gameplay acceptance remains separate. Restart the game, start a fresh Control
Area objective in each world, and require a timer near 30 seconds plus normal
pause, progress, completion, pacing, and exit behavior.
