# Mission timer target addons (2026-09-09)

> **2026-09-12 correction:** Mobile Defense prototype-22 `before` was falsified
> by an exact live `DefenseStage(910)` nil-index failure after datamass insertion.
> Its current implementation is the two-operand exact replacement documented in
> [`MOBILE_DEFENSE_TIMER_LIVE_RECOVERY_2026-09-12.md`](MOBILE_DEFENSE_TIMER_LIVE_RECOVERY_2026-09-12.md).

> **2026-09-11 correction:** the Mobile Defense native-call hook and the
> Excavation prototype-32 post-return hook were falsified by live evidence and
> are superseded by
> [`MISSION_TIMER_CRASH_RECOVERY_2026-09-11.md`](MISSION_TIMER_CRASH_RECOVERY_2026-09-11.md).
> Mobile Defense now uses prototype 22 `before`. Live execution then falsified
> the inferred Excavation prototype-43 capture because `upvalues[4]` was not
> numeric. Excavation now uses a hash-pinned exact replacement that patches only
> proto49/i76 and proto32/i81+i102. Interception was subsequently falsified live
> because its borrowed-environment `type(scoreRatePerSecond)` guard rejected
> before assignment; the guard-only correction and exact runtime evidence are
> documented in
> [`INTERCEPTION_SCORING_RECOVERY_2026-09-11.md`](INTERCEPTION_SCORING_RECOVERY_2026-09-11.md).
> The Excavation and original Interception implementation sections below are
> retained as superseded evidence, not as current implementation guidance.
>
> **Control Area correction:** live testing falsified the later nested-callback,
> fallback-only, and Venus `defendTime` addon approaches. All three worlds now
> use exact stock-body replacements at their timer consumers and linked pacing
> points. See
> [`CONTROL_AREA_LIVE_RECOVERY_2026-09-11/README.md`](CONTROL_AREA_LIVE_RECOVERY_2026-09-11/README.md).

## Scope and evidence boundary

This audit migrates the Ability Studio mission-timer presets away from whole
mission-module replacement. It covers Survival, Mobile Defense, Interception,
and Excavation. The generic ability Replacement workspace remains available
and was not changed by this migration.

The later Control Area extension is documented separately in
[`CONTROL_AREA_TIMER_2026-09-09/README.md`](CONTROL_AREA_TIMER_2026-09-09/README.md).

V61 correction: V60 live testing proved that an outer `vm_execute` return can
represent a coroutine yield. Its unconditional `luaCalls.after` dispatch
corrupted the suspended Survival update state and the next resume crashed.
V61 runs `after` only when status is zero, the active CallInfo bounds validate,
and the exact target closure is absent from the active frame chain. This also
rejects a status-zero native/JIT handoff that still owns the target call.
Survival requires only its existing `before` edit, so Studio no longer generates
`afterSurvivalUpdate`. The deployed V61 addon is 2,616 bytes with SHA-256
`25CD05FC50C5350630F0360829B7DC8E4A4DF84EE359187FBCF248F8302763DD`.

The exact stock inputs were:

| Module | Body key | Bytes | SHA-256 |
|---|---:|---:|---|
| `Lotus.Scripts.MobileDefense` | `89329f85c8575b84` | 31,935 | `E9CBBEF4B6BECA2AC61EC741F3F9A22BA45DF06878708C429176843222B47541` |
| `Lotus.Scripts.Modes.TerritoryMission` | `a51e98a1833bd8c1` | 80,604 | `83FD75DA524B45FB4B7460F698F66271CA7E380D6871C8A53F2066166042F292` |
| `Lotus.Scripts.Modes.ExcavationMission` | `303f809a05c1fbaa` | 75,895 | `A2326FD92DDC2075E03CAB08300744BFA15ED8BDEC7C13FA98DD5071EEEC20C2` |

The current `derecomp.exe` was 7,067,929 bytes with SHA-256
`60157E2FD66E884E089AA7762AA7C5CD79C67748A502B7885FF6FEAE5AB46D6C`.
Generated closure maps and call maps are retained under
`work/diagnostics/mission-timer-addon-migration-v60/`.

## Hypothesis results

### Mobile Defense

**Hypothesis:** The configured minimum and maximum can be applied through a
stock-owned override point without replacing the mission module.

**Evidence:** Stock prototype 22 performs these operations in order:

1. `Lerp(180, 240, mission.difficulty)`;
2. the stock Archwing Grineer `1.3` multiplier;
3. a positive `mission.maxWaveNum` override;
4. `GetNetPersistentVar(CustomMissionTime, 0)` at instruction 139;
5. a positive CustomMissionTime result replaces the total before it is divided
   across active consoles.

The exact call map records `GetMission` at prototype 22 instruction 118 and
`GetNetPersistentVar` at prototype 22 instruction 139. Both calls use the same
game-rules receiver value. The addon changes only the result of instruction
139, and only when the native result and `maxWaveNum` are nonpositive. A
positive existing CustomMissionTime remains authoritative. The addon repeats
the stock linear interpolation and Archwing Grineer multiplier.

**Result: TRUE.** Use `hooks.nativeCalls.GetNetPersistentVar.after` at prototype
22 instruction 139. No polling and no persistent value owner are introduced.

### Interception

**Hypothesis:** The scoring multiplier can be applied once at the stock scalar
owner and still preserve all native variant multipliers.

**Evidence:** Exact Territory prototype 35 reads the global
`scoreRatePerSecond`. Its stock value is `1`. The same closure subsequently
applies the existing `x4` mission branch and derives the existing `x2.25`
alert value. The closure map identifies prototype 35 exactly at root prototype
48 instruction 234. The addon asserts the stock value, replaces it once on
prototype entry, and lets both stock branches execute afterward.

**Result: TRUE.** Use `hooks.luaCalls[35].before`. Cleanup restores either the
owned base value or its exact native `x4` derivative. No score loop or repeated
setter is generated.

### Excavation

**Hypothesis:** All three exposed durations can be changed at one shared stock
owner after the mission chooses its variant.

**Evidence:** Root duration register `R27` starts at `100`. Prototype 32 owns
variant selection and writes `60` for Old World Salvage or `140` for either
Elite Alert tag. Its closure-map capture 9 is `REF:R27`, exposed to the V60
one-based callback as `upvalues[10]`. Later prototypes consume the same shared
value: prototype 41 compares dig progress against it, prototype 43 clamps and
calculates progress with it, and prototype 48 separately replaces it with the
developer `Fast Dig` value `20` when that native debug option is selected.

The addon runs after prototype 32, maps only `100`, `60`, and `140` to the three
configured values, remembers the value it owns so a repeated callback cannot
reinterpret it as another stock variant, and explicitly preserves `20`.
Unknown stock values fail closed.

**Result: TRUE for a natural mission load.** Use
`hooks.luaCalls[32].after`, capture 10. The numeric referenced owner is recreated
from stock when the mission module is loaded again. F9 can replace the addon
generation, but it does not replay a stock initializer that already ran; a new
Excavation mission is therefore the acceptance boundary for changed values.

### Whole-module timer replacements

**Hypothesis:** Keeping the previous full replacement path as the Studio default
is necessary after the exact owners above are known.

**Evidence:** Survival already demonstrated that a compiling, roundtripping
whole-module artifact can disturb the keypad/start lifecycle. The other three
timer edits now have narrower exact target seams. Retaining a second automatic
path would create two competing ownership models for the same editor controls.

**Result: FALSE.** The Mission Timers screen creates target addons for all four
presets. `MissionTimerPatcher.Apply` rejects all four legacy timer replacement
requests. The general replacement editor remains unchanged.

## API contract added

`GameRules:GetMission()` is now a detailed stock-bytecode contract. The three
exact call maps contain 61 sites: Mobile Defense 3, Territory 34, and Excavation
24. Every site has zero explicit arguments, one closed result, and no open
argument or result width. The contract proves the source-visible shape and the
mission descriptor fields consumed by this timer path. It does not claim a
native descriptor class, behavior outside an active mission, or ownership after
the mission lifecycle.

Evidence ID: `WF-MISSION-TIMER-OWNER-CALLS-2026-09-09`.

The rebuilt catalog contains 46 detailed contracts and 17 evidence IDs. The
published Semantic SDK contains 242 symbols, 47 deep contracts, 225 catalog
rows, and 37,615 exact sites. Its `semantic-sdk.json` SHA-256 is
`92F8A65315AAA8AC04627C33402F0BC3445FED05CCB9763594C2DB36D8F7D842`.

## Negative evidence and tool limitations

- The older generic `derecomp dump` path did not parse these three stock files:
  it reported unhandled constant tags `84`, `14`, and `10`. This is a dump-mode
  limitation. Current `decompile`, `closure-map`, `plan-verify`, and
  `semantic-ir-render-module-readable` all succeeded on the exact same bodies.
- Readable rendering retained ambiguity warnings in unrelated Territory
  prototypes 9, 16, 35, 40, 41, 42, and 47, and unrelated Excavation
  prototypes 23, 36, 43, and 46. None of the accepted timer bindings relies on
  an ambiguous alias or receiver type.
- The first Excavation ownership-hardening build referenced `ownedDuration` as
  a legal Lua global because its intended local declaration was inserted into
  the Mobile Defense template. Compiler and semantic gates passed because the
  source was syntactically valid. Direct generated-source inspection caught the
  mistake before deployment. The declaration was moved into the Excavation
  template, a focused source assertion was added, and the superseded artifact
  was never written to the game folder.
- Offline compilation, exact DE container roundtrip, semantic plan checks, and
  focused API checks do not prove in-game timer behavior. Each mission still
  needs a fresh mission load and direct gameplay acceptance.

## Built addon artifacts

All four gates (`recompile`, `de-roundtrip`, `plan-verify`, and
`focused-api-check`) passed with exit code 0 for each new artifact. No live game
file was written by these builds.

| Preset | Bytes | SHA-256 |
|---|---:|---|
| Mobile Defense | 1,531 | `8628D971355048DF742DCD9BF3CACEF8C70017A5D629D60040B414FEF4AC4F70` |
| Interception | 1,075 | `5C1F441FCE9BCDB3A61691E24864FBC4588CAE8340EC5F7CA27EB1A42F751429` |
| Excavation | 951 | `543D13A1B34EB3A63BB175F834CC094F22CD19859FF6A60D89B9771CEB4635B2` |

The published Ability Studio executable is 156,672 bytes with SHA-256
`F13C3885380A0788856A1907175D0A7B160844254C160448B33C6578D171EC54`.
The final focused suites pass 78/78 native checks and 93/93 managed checks.

## Deterministic evidence files

| File | SHA-256 |
|---|---|
| `mobile.closures.tsv` | `D239FD51F4E1802C61D89233418AB8F129C6B3633757A22BC80A95A204464558` |
| `territory.closures.tsv` | `986B82E8AAC526A48E8E0A6683D728B807737332A33D7FB3428FAE4B94188A85` |
| `excavation.closures.tsv` | `A8C977831B4ABE7FD7B65C02F81DD9CC027B955429230E53641E8519915ECA8D` |
| `mobile.calls.tsv` | `EA8B10423628B96A26F3EFCCD959A849A0595623EE1B1F3CE9FD9D1F31EE1150` |
| `territory.calls.tsv` | `53DF11C93176F98C57D69ABC2BB15FD05DD4EA667531F4C54C5F5A82FE3E6F58` |
| `excavation.calls.tsv` | `CFE59C39AC19544975F73E1AE23D3BC9BEBF47C6F03E1DC59E351CA361B3DF4F` |
