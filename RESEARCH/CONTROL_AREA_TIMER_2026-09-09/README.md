# Control Area mission timer owners (2026-09-09)

> **Final live correction, 2026-09-11:** every addon approach below and the
> later fallback-only replacements were falsified in game. The exported
> `DefendStart` callback could not access the mission-resource `defendTime`
> import, and changing only the Plains/Deimos fallback did not replace a
> persisted 90-second network value. All three worlds now use hash-pinned exact
> stock-body replacements at the timer consumer and linked pacing points. See
> [`../CONTROL_AREA_LIVE_RECOVERY_2026-09-11/README.md`](../CONTROL_AREA_LIVE_RECOVERY_2026-09-11/README.md).
>
> The historical H2/H3 addon claims and artifact table below are retained as
> negative evidence and are superseded by the live-recovery document.

## Scope

This audit adds the bounty-style **Control Area** objective to Ability Studio's
Mission Timers workspace. It preserves each stock mission module and uses V61
body-keyed `hooks.luaCalls[prototype].before` callbacks. No full mission-module
replacement, timer loop, polling watcher, or repeated setter is generated.

## Exact stock inputs

| Studio preset | Stock module | Body key | Bytes | SHA-256 |
|---|---|---:|---:|---|
| Control Area (Plains) | `Lotus.Scripts.Eidolon.Encounters.DynamicDefend` | `bf3c901cb4058c47` | 9,693 | `ECC204753DB9BDED69F6A764C919DF5DD2240B5EE907E35C046E99C624D23386` |
| Control Area (Deimos) | `Lotus.Scripts.InfestedMicroplanet.Encounters.DynamicAreaDefense` | `d9541341dfd466a3` | 11,456 | `ECBED12E85416CE5FBB25995D9252F4AD29042F1AE7DAA3C2E4C8A2F25AEDF49` |
| Control Area (Venus/Nokko) | `Lotus.Scripts.Venus.NokkoColony.Encounters.AreaDefense` | `e192d5cc2f37056e` | 15,692 | `E5048C7A1F9AE04DA38BA5AAE18D749A946172A61E67F6D56853BC719246C3F5` |

The body keys use the runtime/catalog FNV-1a body-key function. A control check
against stock Survival produced its known key `1e3647332a578b78`.

The stock corpus search for `DefendCaptureTimer`, `AreaDefenseCaptureTimer`,
`DefendControlTracker`, and `DefendControl` found these three Lua bodies and no
fourth Control Area implementation.

## Hypothesis results

### H1: Control Area is one generic 90-second script

**Evidence:** Plains owns local duration `90` and copies it into a separate
reinforcement-pacing baseline. Deimos owns local duration `90` and calculates a
separate two-thirds threshold (`60`). Venus/Nokko never declares a fixed numeric
duration in Lua; it reads global `defendTime`, supplied by the mission resource,
then derives its halfway and two-thirds thresholds from that value.

**Result: FALSE.** Studio exposes three body-keyed presets. Plains and Deimos
show exact stock `90 seconds`. Venus/Nokko says `mission-resource value (not
fixed in Lua)` and uses 90 only as the initial editable example; it is not
presented as a decoded stock value.

### H2: Changing only the visible countdown is sufficient

**Evidence:** The stock modules reuse or copy their duration for related pacing:

- Plains root prototype 17 instruction 104 creates prototype 8 with root `R21`
  as zero-based capture 6, exposed as `upvalues[7]`. Root instruction 69 creates
  prototype 1 with `R21` as `upvalues[5]` and copied baseline `R33` as
  `upvalues[6]`.
- Deimos root prototype 15 instruction 110 creates prototype 7 with duration
  `R23` as `upvalues[12]`. Root instruction 162 creates prototype 9 with the
  derived threshold `R44` as `upvalues[14]`.
- Venus/Nokko prototype 6 reads `defendTime` before calculating the two derived
  thresholds, so one change at that entry lets stock Lua calculate both.

All six referenced stock prototypes passed `plan-verify` and
`semantic-ir-verify` with zero failures.

**Result: FALSE.** Plains changes the duration and copied pacing baseline
together. Deimos changes the duration and two-thirds threshold together.
Venus/Nokko changes only the upstream resource-backed value because the stock
initializer still owns every derived calculation.

### H3: These edits can remain ordinary target addons

**Evidence:** The V61 runtime supplies one-based, same-type writable capture
tables to exact prototype callbacks and runs the addon inside the matched target
module environment. The generated addons assert the exact prototype, callback
tables, scalar types, and decoded fixed values before copyback. Venus/Nokko
captures and conditionally restores its original `defendTime` value during
cleanup. Plains and Deimos also record separate one-time configuration flags;
later prototype entries and coroutine resumes return before touching the owned
values, so Deimos' mutable pacing countdown is not reset. Referenced
Plains/Deimos encounter captures are recreated by the next
natural module load.

**Result: TRUE offline.** All three addons keep the stock objective state
machine, HUD timer, host migration variables, pause rules, and completion flow.
Live behavior still requires a fresh load of each corresponding bounty type.

## Generated verification artifacts

The fixture projects are under [`projects`](projects), and their deterministic
generator is under [`tools`](tools). Generated source, bytecode, manifests, and
gate logs remain under `work/staging/control-area` so proprietary generated
artifacts do not enter the source tree.

Each artifact passed `recompile`, exact DE container `de-roundtrip`,
`plan-verify`, and focused strict API checking:

| Preset | Bytes | SHA-256 | Gate status |
|---|---:|---|---|
| Plains | 1,722 | `4B430155C7DF872C85C4A0A95651B82C1D6662B1ABA739D5F9F202645B988E87` | `STAGED_PASS` |
| Deimos | 1,541 | `8511A9BEBFD634615DC523EB0847C02F7338137AF99FB3EA696B19495696E124` | `STAGED_PASS` |
| Venus/Nokko | 1,104 | `2755595AC871D5D009B115CEA77251C4CAF2FCB9E0D8ACB9E395903D60098648` | `STAGED_PASS` |

The C++ self-test passed 87/87, the managed harness passed 101/101, and Release builds
completed with zero warnings and zero errors. The published Studio was restarted
from `work/builds/ability-editor/current/studio/RenoviceAbilityStudio.exe`.
The code-bearing published binaries are pinned as follows:

| File | Bytes | SHA-256 |
|---|---:|---|
| `RenoviceAbilityStudio.dll` | 160,768 | `9DB09118DFFDE0A8FD6B3B38A92480D93DAE65195CFA02CA7D284DC238702BD1` |
| `AbilityEditor.Core.dll` | 304,640 | `9C4955DDBCA97628DE2C84A71D855E300E7D057085FFC0E29EADEFDCDFC39337` |
| `renovice_ability_editor_cli.exe` | 5,105,977 | `08EC0427A2CB6A28EB6ACEBF0E438E82D381C0DD5DA78B1CDC4B8F406F89F15D` |
| `derecomp.exe` | 7,067,929 | `60157E2FD66E884E089AA7762AA7C5CD79C67748A502B7885FF6FEAE5AB46D6C` |

## Negative evidence and limits

- Generic `derecomp dump` rejected the Plains, Deimos, and Venus/Nokko bodies
  with unhandled constant tags `83`, `34`, and `84`, respectively;
  this is a dump-mode limitation. `decompile-mod-stable`, `closure-map`,
  `plan-verify`, and `semantic-ir-verify` succeeded on the same bytes.
- The current Packages JSON snapshot does not expose a fixed Venus/Nokko
  `defendTime`, and the Lua body contains no fixed value. Studio therefore does
  not claim one.
- The first verification build used an unnecessarily long staging path and hit
  Windows path-length file creation failure. Re-running through the shorter
  canonical `work/staging/control-area` path passed every gate; no failed
  artifact was deployed.
- Offline gates establish valid projects, compilable DE Lua, exact generated
  bytecode roundtrip, and supported API shapes. They do not establish live timer
  behavior.
