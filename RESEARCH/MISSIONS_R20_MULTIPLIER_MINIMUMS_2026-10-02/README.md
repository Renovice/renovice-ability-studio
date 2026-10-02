# Missions R20: every "x" multiplier accepts values down to 0.001 (2026-10-02)

- **Build:** client 44.0.2 (`2026.09.28.13.06`), U44 name-hash seed `768e5ed0`.
- **Branch:** ability editor `fix/missions-r20-multiplier-minimums-2026-10-02`, from R19 `fd6c80b`.
- **Runtime:** no DLL change. The installed R17 DLL `304b57de…` already handles 0.001 end to end (checked below). Bootstrapper
  gate branch `fix/r20-multiplier-minimums-2026-10-02` (worktree `repos/runtime/bootstrapper-runtime-wt-r19`, from R19
  `7dcd7a9`): render gate section 1e and fixture `fixtures/r20` only. Record there:
  `RESEARCH/MULTIPLIER_MINIMUMS_R20_2026-10-02/README.md`.
- **Status:** every offline gate PASS. **Nothing is live.** Staged `work/staging/combined-r20/` (2 files). Nothing deployed or
  pushed.

## Hypothesis

Every multiplier setting ("x" unit) of the Missions package can accept 0.001: counts already clamp to at least 1, and no
reader divides by a scaled value that can reach zero or loops on a near-zero interval. Exceptions must come from the
decompiled code.

**Result: Partially true.** 46 of the 51 "x" values accept 0.001: 23 lowered to 0.001 by R20 (5 of them were whole-number
only), 4 raised from 0 to 0.001 because 0 breaks their reader (Capture health duo/trio/squad, Mirror Defense pickup
threshold), 19 keep minimum 0. Five have a floor with a code reason: Interception scoring speed 0.1, Void Flood orb value
0.06, Alert Purge tiers 1-3 0.134 (also made fractional).

## Scope (denominator)

The package declares 51 values with unit `x` (46 in `package.json`, 5 in `literals.json`): every "x" scale row (`scale`,
`scale_inverse`, `scale_count`, engine-writer rows), the Railjack master, and every absolute multiplier. Metadata
(Packages.bin) multipliers are not in SCRIPT SETTINGS and are out of scope.

## Per-value decision (input `inputs/r20_minimums.json`, LF SHA-256 `CAB91F54…52773A`, 31 rows; evidence text per row)

| Value(s) | Mode / owner | Was | Now | Why (decompile, 44.0.2) |
|---|---|---|---|---|
| Railjack fighters, crewships, Corpus fighters, Pontis (2) | scale_count, engine writer | 0.1 | **0.001** | Every count becomes max(1, round(n x v)) = 1. Readers take 1: `RandomInt(1,1)`, kills / goal (goal >= 1), `goal <= count`, `min(director, list)`. One kill completes the goal. |
| "All Railjack missions" (master) | master of the 5 rows | 0.1 | **0.001** | Follows its rows (largest row minimum / scale). |
| Exterminate "Kills needed" (master) | scale_inverse, engine writer | 0.1 | **0.001** | metersPerEnemy / v = x1000; path / it floors to 0 and TriggerAlarm P21 L3219-3264 adds `max(15, ...)`: about 15 kills. Later divisors use the director total. |
| Exterminate "Archwing kill factor" | absolute, engine writer | 0.01 | **0.001** | A product on Archwing maps (L3136-3137); the same 15-kill floor. |
| Interception "Score to win" (master) | scale, engine writer | 0.05 | **0.001** | Only compared and a ratio denominator (never 0: 1450 x 0.001 = 1.45). Rounds are decided within seconds. |
| Interception "Scoring speed" | scale, engine writer | 0.05 | **0.1 (floor)** | Score += towers x rate x dt every frame in float32 (P35 L7515-7621, Sleep(0) loop). A gain below half a float32 step never changes the score: at the 1450 goal one tower stalls above 819 fps at 0.05 and above 1638 fps at 0.1 (goals up to 2048). A stalled round never ends. |
| Spy "Vault alarm time" (master) | scale | 0.05 | **0.001** | The countdown loop subtracts dt with Sleep(0), then the vault fails; no division by it (Intel P43). |
| Gas City "meltdown time" | scale, engine writer | 0.05 | **0.001** | hackTime and modeTimer only feed SetObjTimer and `GetObjTime() <= 0`; fixed Sleeps; no division. |
| Gas City easy/hard factors | live literal (number constant) | 0.01 | **0.001** | The Lerp ends of the same timer; any positive value. |
| Void Flood "All Void Flood missions" (fill speed) | scale (root table) | 0.05 | **0.001** | Only multiplied (P48 L9618-9662). Float32 progress holds up to about 1600 fps (squad rate 0.07). With the default capacity a tank then takes hours and the corruption meter fails the mission (game rule). |
| Void Flood "Tank capacity" | scale_count (root table) | 0.05 | **0.001** | Each capacity becomes 1; every division by capacity has capacity >= 1; the snap at `capacity - 1` fills a tank on one touch. |
| Void Flood "Void orb value" | scale (root table) | 0.05 | **0.06 (floor)** | A downed player drops `floor(E/2 / medium) + ceil((E/2 % medium) / small)` orbs in one loop (P28 L4404-4425, the scaled table); E <= capacity (350 squad). That is 179 orbs at 0.05, 149 at 0.06 and 8750 at 0.001; the game itself keeps at most 150 pickups active (P33 L5655, L5744). |
| Void Flood "Tank drain speed" | scale (root table) | 0 | 0 (unchanged) | 0 = no drain; never a divisor. |
| Kela De Thaym health duo/trio/squad | live literal (number constant) | 0.01 | **0.001** | Multiplied with GetMaxHealth (BossKelaArena P15); the stage logic divides by the captured max health, not by the factor. |
| Capture target health solo | named setting | int, 1 | **float, 0.001** | Whole-number only because its stock is 1. `ceil(base x level x T[players])` (CaptureNew P17): never an index or count; ceil keeps health >= 1. |
| Capture target health duo/trio/squad | named setting | 0 | **0.001** | 0 gave `ceil(0) = 0` and SetMaxHealth(0). |
| Faceoff Assassination health solo..squad | named setting | int, 1 | **float, 0.001** | Only `AddUpgrade(79, 2, mult)` (WF99PvPvEMission P123); the same call takes fractional stocks elsewhere. |
| Alert Purge tier 1-3 multiplier | named setting | int, 1 | **float, 0.134 (floor)** | SetMaxSourceAi(15 x m): a spawn point away from players gets `floor(15 m / 2)`, 0 below 2/15 = 0.1333 (SpawnLib Update), so nothing spawns there. 0.134 is the lowest 3-decimal value with both caps >= 1. SetSpawnDelay(4 / m) is read only at SpawnLib Initialize, before this loop. |
| Mirror Defense "Pickup threshold" | named setting | 0 | **0.001** | 0 was unsafe: mod x K is a divisor and a modulus (LoopDefend L5366-5419, L6123-6180, L7463-7471): NaN, crystals never trigger. At 0.001 the client loop activates about 1000 / K crystals in one frame (bounded; K = the unresolved global `eeb574b8`). |
| 18 other "x" values with minimum 0 (Survival drop multipliers, Lantern decay, Purgatory damage, Disruption boss health, Mirror Defense pickup rate, meter time shrink, ...) | | 0 | 0 (unchanged) | Already accept 0.001; no division by them in their readers (pickup rate divides a threshold by it: 0 = never, no error). |

Tooltips (descriptions, `player_layout.py` OVERRIDE, R20 block): the 5 Railjack rows, the Railjack master and Void Flood tank
capacity say "at least 1"; Exterminate kills needed names the game's ~15-kill floor; the 5 floor rows say why their minimum
is above 0.001 (descriptions may not carry decimal numbers; the editor tooltip adds "Range <min> to <max>." itself).

## Display, editing and storage of 0.001 (installed R17 DLL code, bootstrapper `45ed7b0`/`7dcd7a9`, checked offline)

| Step | Code | 0.001 |
|---|---|---|
| Declaration parse | `settings_core.hpp` `parse_value` -> `std::from_chars` (double) | exact |
| Validation | `validate_value`: `value < minimum` (double) | 0.001 accepted, 0.0009 refused |
| Row text | `settings_ui_core.hpp` `display_number`: whole numbers without a point, otherwise `%.6g` | "0.001x" |
| INPUTBOX content | `json::number_text`: shortest round trip (`std::to_chars`) | "0.001" |
| Bridge validator | `ScriptSettingsBridgeV1` `textValidator`: `tonumber(text) < spec.minimum`; the minimum crosses as float32 (`SettingsRowView.minimum`) and the DE VM numbers are float32, so both sides are float32(0.001) | valid |
| Values file | `write_values_file` -> `number_text` (shortest round trip); re-read with `from_chars` | stored exactly as 0.001 |
| Delivery / engine writer | delivered value pushed as a VM number (float32); writer arithmetic float32 (`override_number`) | 0.001f |

**No rounding to 2 decimals exists, so the DLL is unchanged.** The render gate types 0.001 through the real stock screen
and the real C++ host model (below).

## Package (pinned input `MISSIONS_R13_NATIVE_ENTRY_2026-10-01/inputs/rebuild_input.r12.json`)

| File | Bytes | SHA-256 | vs R19 |
|---|---:|---|---|
| `Missions.targets.addon.lua_B` | 114,106 | `d8736450cc81c2c03daaf219fbd5a046dad82b57e1d54fd8263fe2832a4d3c88` | identical |
| `package.json` | 254,884 | `acc2256eb4a76f6782af1aa51534a5387c065ae1323da36daa45dfbbd06f6d71` | 27 declarations: `min`, `type` (8 int -> float), 13 descriptions |
| `literals.json` | 213,736 | `96a97899889b6a5f5357a4c0ae0024d0afe9a214c398784fdcc834f401f0fd03` | 5 declarations: `min` |
| `engine_params.json` | 4,038 | `eafd2ddf3b3916aad7a0dd4d1b09090a2a6ca74192dde69dd0e3afbf72aa259b` | identical |

32 of 508 declarations change (the 31 input rows and the Railjack master); nothing else.

## Change

| File | Change |
|---|---|
| `inputs/r20_minimums.json` | The per-row decision: `was` (checked exactly), `minimum`, optional `integer: false`, `basis` (evidence). |
| `tools/register_registry.py` | `apply_minimums()`: pinned input applied after every row is built, before the editor fields; registry report `r20_minimums`. Registry fixed point `f81b1798…` (R19 `366ab8c5…`). |
| `tools/player_layout.py` | R20 description block (count rows "at least 1", floor reasons, Exterminate floor). |
| `tools/test_r20_multiplier_minimums.py` (new) | Gate: build pins; every "x" declaration fractional and >= 0.001 only as a recorded floor; input rows = declarations; master rule; tooltips; the real addon writes every named-setting multiplier at its minimum exactly and cleanup restores it (24 Luau checks). |
| `tools/test_entry_native_harness.py` | + the 10 scaled entry rows at their minimum (scale, scale_inverse, scale_count). |
| `tools/test_engine_param_override_harness.py` | + every writer-owned row at its minimum (with the hook: reads see the result, the addon writes nothing; entry fallback); pins R20. |
| `tools/test_void_flood_tank_harness.py` | + capacity 0.001 (1 per tank, one frame fills), fill speed 0.001 (progress, no stall), orb value 0.06 (largest drop 149 <= 150) and the 0.05 control (175 > 150); pin R20. |
| `tools/test_live_literals.py`, `tools/test_presets_and_sample.py` | Compare with the older staged sets: an R20 difference is admitted only in `min`, `type` and the description, with the exact R20 minimum. |

## Gates (logs in `work/staging/combined-r20/evidence/`)

| Gate | Result |
|---|---|
| `register_registry.py` -> `player_text.py` x2, then again | fixed point `f81b1798…` |
| CLI build (MSYS2 ucrt64, `-Wall -Wextra -Wpedantic -Werror`), `verify-missions`, `self-test`, ctest | 0 warnings; PASS 669/669, 150/150, 2/2 |
| Package build gates | `settings-layout` values=373 live_literals=135 pages=209 quick=25; `settings-declarations` values=373 masters=31; `engine-param-overrides` rows=11 overrides=17; `live-literal-recipe` values=135 extreme_syntheses=280 |
| `test_r20_multiplier_minimums.py` | PASS (24 Luau checks) |
| `test_entry_native_harness.py` | PASS 164 (21 rows + 10 at the minimum) |
| `test_engine_param_override_harness.py` | PASS 87 Luau checks (11 rows at the minimum) |
| `test_void_flood_tank_harness.py` | PASS 43 |
| `test_live_literals.py`, `test_presets_and_sample.py`, `test_r17_type_masters_harness.py`, `test_defense_reader_pin_harness.py`, `test_flow_gate.py`, `test_phase2d/2e/2k` | PASS |
| Bootstrapper render gate `verify_script_settings_render.ps1` section 1e (bridge + stock screen + C++ host tape) | PASS: 0.001 typed on 6 value pages (Railjack fighters, Railjack master kept number, Exterminate master kept number, Void Flood capacity, Kela health duo (live literal), Capture solo (formerly whole-number)); rows read "<row>: 0.001x"; reopened fields show "0.001"; values file holds exactly 0.001; Kela plan synthesizes from the real stock bytes; 0.001 under the orb-value floor is refused (`REJECT outside-min-max`, stock message, default kept) |
| Bootstrapper `verify_addon_settings.ps1 -Package -Settings -ScriptStates` (R20 Missions + installed Frost/Octavia, read-only copies of the installed values files and ScriptStates.json) | ADDON SETTINGS GATES PASS; Missions `declarations=508 rejected=0 effective=6 unknown_entries=6`, delivery `values=4`; every delivered value reaches a staged member |

## Limits (exact)

- **Nothing is live.** Each decision is static (decompile + generator/host models). Plain Luau and Python use doubles; the
  float32 statements are arithmetic on the DE VM number type, not a run in the game VM.
- Interception scoring-speed floor assumes the map score rate 1 per tower at goals up to 2048; a much higher "Score to win"
  combined with a low scoring speed can still stall at very high frame rates (for example x20 goal and 0.1 above ~409 fps).
- Void Flood orb-value floor uses the default squad capacity 350; a larger "Tank capacity" also enlarges the downed drop (as it
  does at x1).
- Mirror Defense pickup threshold: the burst size depends on the unresolved global `eeb574b8` (K).
- Gameplay at the extremes is the game's own rule, not a fault: Interception rounds end in seconds at 0.001 score, a Spy alarm
  loses the vault at once, a Void Flood tank at fill speed 0.001 with the default capacity cannot beat the corruption meter,
  very low Capture health can spawn the target already downed.
