# Mallet Overguard proportionality, live check (2026-09-30)

- Client: 44.0.2 (`2026.09.28.13.06`), `Warframe.x64.exe` SHA-256 `0124f0b9…7d33` (sideloadified digest registered in `engine_damage.cpp`).
- Runtime: installed bootstrapper DLL `ed2a996d…` (bootstrapper branch `feat/ingame-settings-editor-2026-09-30`, source read at `dd5414c`, read only).
- Addon under test (installed, read only): `OpenWF/CustomScripts/Packages/Octavia/ec368d4901690a15.MalletOverguardAndCard.target.addon.lua_B`, 3,798 B, SHA-256 `1e3682a4…bb86`. It equals `SETTINGS_SECOND_CONSUMER_2026-09-30/package/Octavia/…` and rebuilds byte for byte from `SETTINGS_SECOND_CONSUMER_2026-09-30/src/mallet-threat-settings.u44.luau`. `Settings/Octavia.json`: `mallet.threat_level` enabled, 5.
- Evidence (pid 15124, `Diagnostics=true`, trace mode, `DiagnosticsCasterStats=true`, engine damage capture on):
  - Session A: `renovice_source.log.1` from the pid-15124 module graph (line 75,950) through `renovice_source.log` byte 33,910,702. 43,711,582 B snapshot, SHA-256 `26433af9…3e27`. 231 Mallet beats.
  - Session B: `renovice_source.log` bytes 33,910,702 to 54,379,236 (ticks 88,638,359 to 88,940,234). SHA-256 `a4bc73f7…6bdb`. Same generation (every ENGINE_DAMAGE record `Generation 0`); the `DiagnosticsMode=battle` switch made in `renovice.cfg` around 09:00 was not yet committed by F9 in it. 149 beats.
- Nothing was written to the game folder, the OpenWF server or the bootstrapper repository.

## 1. What the addon computes (source)

`afterDamage` (`v9`, prototype 8) runs synchronously for every **positive engine-reported per-target damage result of the Mallet's own radial burst**. Transport (`renovice.mallet.damage_dispatch`, `injection.cpp` `set_source_object_adapter`, `install_addon_damage_callback`, `addon_damage_callback_wrapper`): at the stock `SetSourceObject` in `BoxLoop` (p16, fallback frame i566) the host installs a native `SetDamageCallback` wrapper on that beat's `RadialDamageData`. During `gRegion:RadialDamage` (p16 NAMECALL i576) the engine calls it once per resolved target with `(target, damage)`. Each positive damage becomes `afterDamage(sourceAbility, reportedDamage, canonicalTarget, packet, correlation)`.

The input is the damage the Mallet **deals**, not the damage it absorbs. The stock burst size comes from the stored pool: enemy damage absorbed by the Mallet fills the pool, and each musical beat releases part of it. So absorbed damage matters only through the stock pool.

```
caster   = sourceAbility:GetAvatarOwner()                    -- Octavia (damage.identity: OctaviaPrime)
cap      = max(0, GetUpgradeModifiedValue(15000, 10, ...))   -- 15000 x strength
fraction = min(0.05, max(0, GetUpgradeModifiedValue(0.01, 10, ...)))   -- 1% x strength, max 5% (strength 5.0)
og       = caster:DamageControl():GetOverguardAmount()
skip if damage <= 0, target killed (IsKilled after the hit), health <= 0, no caster/DamageControl, og >= cap
new      = min(cap, og + damage * fraction)
if og < new: DamageControl:SetOverguardAmount(new); caster:NotifyOverguardGain(player, new - og);
             AbilitiesLib.NotifyGaveOverguard(caster, caster)
```

Operation 10 is the strength channel. CASTER_STATS reads `strength` as `ModifyValue(unit=1, operation=10)`, and every observed Overguard saturation value equals `floor(15000 x strength)` (35,700 to 38,184 across 22 strength values). Overguard is written on Octavia's `DamageControl`, per hit, at hit time.

## 2. Live pairing (`tools/mallet_overguard_beats.py`)

Where the values are:

- **Damage per hit:** `ADDON_TRACE … event=dispatch.results`. The fields are `result0` label, `result1` correlation, `result2` target, `result3` reportedDamage, `result4`/`result5` killed (known, value), and `result6`/`result7` health (known, value after the hit). These lines exist only in `DiagnosticsMode=trace`.
- **Octavia's Overguard and strength:** `CASTER_STATS … Method SetSource`, once per beat before the burst (`Live.overguard`, `Live.strength`).
- **Missing:** no record carries per-hit Overguard before/after or the granted amount. The addon returns 8 values and none of them is Overguard. The host also traces at most 8 results (`call_value` `traced_result_count = 8`). A per-hit gain is therefore only measurable per beat. The bounded fields needed are `overguardBefore`/`overguardAfter` (or `granted`) per afterDamage dispatch: either the addon returns them as results 8 and 9 with the host limit raised to at least 10, or the host records them. See the runtime spec.

Model per beat k (SetSource snapshot k to k+1, 500 ms): apply `og = floor(min(cap, og + dmg x r))` for each grant hit in order.

| Result | Session A | Session B |
|---|---|---|
| clean beats (500 ms gap, Octavia not hit, strength constant, below cap, no rate-limited trace) | 96 | 32 |
| exact match, per-hit truncation model | **96/96** | **32/32** |
| exact match, no truncation / rounding model | 45 / 62 of 102 | 16 / 24 of 32 |

Sample beats (session A unless marked B):

| beat | strength | OG before → next | grant hits | Σ damage | r·Σ (nominal) | per-hit floor model | observed ΔOG | effective |
|---|---|---|---|---|---|---|---|---|
| 0 | 2.3800 | 0 → 996 | 20 | 42,180 | 1,003.9 | 996 | 996 | 2.361% |
| 2 | 2.3800 | 1,927 → 2,804 | 20 | 37,084 | 882.6 | 2,804 | 877 | 2.365% |
| 8 | 2.3800 | 6,420 → 10,657 | 20 | 178,584 | 4,250.3 | 10,657 | 4,237 | 2.373% |
| 10 | 2.3800 | 14,636 → 18,009 | 19 (+1 lethal) | 141,956 | 3,378.6 | 18,009 | 3,373 | 2.376% |
| 12 | 2.4016 | 18,493 → 19,043 | 11 (+3 lethal) | 22,957 | 551.3 | 19,043 | 550 | 2.396% |
| 27 | 2.4016 | 30,373 → 31,374 | 11 | 42,042 | 1,009.7 | 31,374 | 1,001 | 2.381% |
| 41 | 2.4112 | 36,084 → 36,168 | 5 | 35,250 | 849.9 | 36,168 (cap) | 84 | cap-limited |
| B 8 | 2.3800 | 2,258 → 2,722 | 2 | 19,550 | 465.3 | 2,722 | 464 | 2.373% |
| B 9 | 2.3800 | 2,722 → 3,192 | 2 | 19,758 | 470.2 | 3,192 | 470 | 2.379% |

Across the 96 clean beats of session A: 445 hits, 1,421,124 damage, 34,005 Overguard. That is 2.393% effective against 34,232.7 nominal (2.409% at the per-beat strength). The 227.7 difference is exactly the engine's per-hit truncation (under 1 point per hit, 0.67% here).

User measurement ("about 19,000 damage, about 450 Overguard, 2.37 to 2.39%"): at strength 2.38 the nominal rate is 2.38% (452 Overguard for 19,000 damage), and truncation brings it to 2.36 to 2.38%. Session B beats 8 and 9 are that measurement: 19,550 damage gave 464, and 19,758 damage gave 470. **Match.**

Double counting and missed hits:

- **One install per beat:** 231 SetSource entries, 231 callback installs, 231 `native-return status=ok`. There is one positive dispatch per positive callback, and correlations 1 to 1,344 are contiguous.
- **No hit counted twice:** within every beat, each dispatch has a distinct target userdata (0 repeats in 1,244). Health continuity across beats equals the reported damage (for example 71,106 → 67,324 = 3,782, and 74,606 → 74,105 = 501). So `reportedDamage` is the damage actually applied to that target, and each target is hit once per burst. A burst that hits N enemies grants N times; this is the design, and total Overguard scales with the number of enemies.
- **Missing trace lines are diagnostics only:** 100 of 1,344 dispatches (10 windows of 8, plus one of 20) are missing from the trace because `dispatch.*` is rate-limited to 32 lines per event per 1,000 ms (`trace.rate-limited suppressed_event=dispatch.results`, 100 in total). Those beats show the positive residual that the untraced hits imply. For example beat 9 has +400 Overguard, which is 8 hits of about 2,121 damage. So the grants happened and only the trace lines are missing.
- **Killing blows grant nothing (by design):** `skip-killed-target` fired 113 times for 2,249,748 damage. The check runs after damage, so the killing hit's damage (mostly overkill) grants 0. This is the addon's rule, not a transport loss. A possible refinement would grant `damage + healthAfter` (the health actually removed) for the killing hit.
- **Zero-damage callbacks:** there are 3,211 zero-damage callbacks (allies, the sentinel, or targets in cover). They are no-ops.

## 3. Defect found and staged fix

**Integer cap (TRUE, low severity).** The engine stores Overguard as an integer, but the cap `15000 x strength` is fractional (strength 2.4544… gives 36,816.018). `GetOverguardAmount()` returns 36,816, so `cap <= og` is never true. `skip-cap` fired 0 times in 1,244 dispatches. In 75 at-cap beats, 363 to 365 hits still ran `SetOverguardAmount(36816.018)`, `NotifyOverguardGain(player, ≈0.02)` and `AbilitiesLib.NotifyGaveOverguard`, each with zero real gain. Hits worth less than 1 point (damage below 1/r ≈ 42) do the same. The Overguard amount itself is correct (it stays at the cap). What is wrong is repeated writes and notifications, and a notified gain that overstates the real gain by the truncated fraction. Downstream effects of `NotifyGaveOverguard` are unverified.

Fix (addon source only), in `src/mallet-overguard-integer-cap.u44.luau`: `cap = math.floor(15000 x strength)` and `new = min(cap, math.floor(og + damage x r))`. Resulting Overguard is identical to the engine's truncation. At the cap it returns `skip-cap`, and sub-point hits return `skip-zero-grant`, both with no write. The notified gain equals the real gain. Nothing else changes: threat, card, settings and return tuple are the same.

Staged: `work/staging/mallet-overguard-integer-cap-2026-09-30/ec368d4901690a15.MalletOverguardAndCard.target.addon.lua_B`, 3,844 B, SHA-256 `95d26a914eae2749d8be579df1d09d9f69d34dbc7c1f68eab22e0b61218cb52d`. It is a drop-in package member; `package.json` is unchanged. Rollback is the installed `1e3682a4…`.

Gates (`tests/run_gates.py <installed Packages/Octavia> <out>`, `evidence/gates.json`, all PASS):

- **Identity:** derecomp `c1672d8d…`; the installed package is `1e3682a4…` and equals the committed package; the baseline source rebuilds the installed bytes exactly.
- **Build:** `recompile-u44` re-parses; two builds are byte-identical; `de-roundtrip` passes 14/14.
- **const-identity vs installed:** the only delta is proto 8 (afterDamage), which adds hash `d4f2b58e` (`floor`, already used by the installed addon). Nothing is removed and there are 0 class swaps.
- **Real-source contract under upstream Luau, with an integer-truncating engine model:** formula, 5% clamp, fractional cap gives `skip-cap` with 0 writes, integer clamp with an exact notified gain, sub-point hit, and lethal skip. The **live replay** of 128 clean beats (sessions A and B) reproduces the observed Overguard 128/128 for both candidate and baseline. In the 75 at-cap beats the candidate writes 0 times and the baseline 363 times, which reproduces the defect.

These gates prove source, build, bytes and formula parity against recorded beats. They do not prove gameplay.

## 4. ENGINE_DAMAGE nonsense values: diagnostics decoding defect (spec, not fixed)

Hypothesis: `ObservedRaw` garbage and null pools are specific to `SentinelAvatar`. **FALSE.** The actual cause is a stale U43 field codec on 44.0.2 that affects every target class.

- **Scope:** 8,069/8,069 `end` records (9 target types) and 1,306/1,306 Mallet transactions in `AnalyzeCombatBattleLog.ps1` have null Health, Shield and Overguard before and after. `ObservedRaw` is garbage for every type (for example −6.28e−12 or 2.65e30 on Orokin enemies). Plausible values appear only where the packet's cached-value flag is set (for example 55,346.95 on `MusicAvatar`).
- **Target types:** `SentinelAvatar` is the player's sentinel (TenaciousPartner source; CASTER_STATS health 450, shield 2,100). It stands inside the Mallet radius and has 116 Mallet-sourced native records but no positive Lua dispatch. The Mallet entity is `MusicAvatar`. Octavia is `TennoAvatar` in native type names and `LotusHumanPlayer` in Lua trace names. The Overguard lands on Octavia's DamageControl.
- **Cause (source and image):** `engine_damage.cpp` re-registered 44.0.x RVAs but kept U43 (`cca46d60`) layout and codec:
  - `integer_getter` accepts only `rol eax,19 … xor eax,0xC55198A3`;
  - `decode_float` uses `rotl 30 ^ (addr>>3) ^ 0x635BF253`.
  - `tools/scan_field_codec.py` on the 44.0.2 image finds **0 occurrences** of either constant. The 44.0.2 accessors use `rol 19 / xor 0xAC7E8740` (integer returns) and `rol 17 / xor 0x8637D1B6` followed by `movd xmm0,eax` (float returns) (`evidence/exe-44.0.2-field-codec-scan.txt`).
  - The integer shape check therefore always fails, so all pools are null. The float decode is applied blindly with the stale key, so `ObservedRaw` is garbage.

Spec for the bootstrapper owner:

1. Move the codec (rotate and key for integer and float) and every layout constant into the per-build registration next to the RVAs, keyed by the image digest, with no fallback. The layout constants are: target slot 0x340; DamageControl slots 0x2b8 and 0x328; `control+0x28`; the `packet+0x60` UpgradedValue offsets 0x0c, 0x14, 0x24 and 0x30; and flag 0x20.
2. For 44.0.2, the image scan supports the candidates above. Confirm them by disassembling the actual accessor at each vtable slot of a live Orokin target and its DamageControl, and the packet UpgradedValue reader. Re-derive the slots too, because they are also carried over from U43.
3. Validate `base_amount` the same way `integer_getter` is validated. When the codec is not verified for the running digest, emit `ObservedRaw: null` with a reason (for example `"RawReason":"codec-unverified-for-build"`), never a decoded value.
4. At `install()`, check that each registered constant occurs in the image. If one is missing, log once `ENGINE_DAMAGE event=degraded reason=codec-not-registered-for-build`, keep correlation, target and source records, and null the decoded fields.
5. Gates:
   - extend `verify_native_damage` with the per-build table;
   - extend `inspect_damage_boundary.py --verify-contract` to assert constant presence per registered digest;
   - live acceptance: for one Mallet burst, native slot-0 `HealthLoss + ShieldLoss + OverguardLoss` for a target equals that target's Lua `dispatch.results` `reportedDamage` (the health continuity above shows it should).
6. Related diagnostic gaps:
   - `dispatch.*` is rate-limited to 32/s, which dropped 100 per-hit records. Exempt `afterDamage` results or give them their own bounded budget; keep the suppression counter.
   - `dispatch.results` is emitted only in trace mode, so `DiagnosticsMode=battle` loses the per-hit addon values.
   - Add the per-hit Overguard fields from section 2.

## 5. Threat 5 cannot drift back to 4 through Lua (TRUE for stock Lua; native unverified)

- 44.0.2 BardMusic (U44_AUTHORING artifacts `mallet.luau`, p16 BoxLoop) computes `level = floor(Lerp(5, 0, min(1, pool/1500)))`. It pushes only when `level ~= last`, where `last` is the stock integer (`c17v21`, initially 0), not the transformed value. Each push runs `ActivateSecondaryScript(…, "SetThreatLevel", args)`. p18 `SetThreatLevel` calls the file's only `SetThreatModifier` (`dded29df`) on `_T.bardMusic[instance].box`. There is no other writer in the module.
- In the U43 stock corpus (5,386 modules), BardMusic is the only Bard script that calls `SetThreatModifier` (`ecb31eeb`), and no module names `MusicAvatar`. 54 non-ability scripts call `SetThreatModifier` on their own entities (mission objects and similar). None of them is proven to iterate every avatar, but none addresses the Mallet.
- **Live:** 12 `native.float.transform p16 i596` records, with stock values 1,0 at one cast; 0 on four later casts; and 3,1,0 twice. Every one was transformed to 5. The first push of each box is stock 5 (0 → 5), passes through unchanged and is not traced. Stock 4 and 2 were skipped because the pool jumps past them. Every push that reaches the Mallet therefore carries 5, and between pushes no Lua path writes the modifier.
- **Unverified:** whether native AI code decays or overrides a threat modifier. That is outside Lua evidence.

## Recipe: verify an ability's numbers with the battle logger (44.0.2 as of this note)

1. Set up `renovice.cfg`:
   - `DiagnosticsMode=trace` for addon-level values. `battle` does not emit `dispatch.results`.
   - `DiagnosticsCasterStats=true` and `DiagnosticsDamageCapture=engine`.
   - Press F9 right before the run. Budgets are per generation (32,768 trace events); in session B, caster snapshots stopped at tick 88,793,125 when `event-budget-exhausted` hit.
   - Note the log byte offset at F9 for `-SinceByte`.
2. Snapshot the log (shared read) and run:
   ```powershell
   AnalyzeCombatBattleLog.ps1 -LogPath <snapshot> -SinceByte <offset> -SourceBody <module key> -TargetType <enemy type> -CsvPath <out.csv>
   ```
   - Enemy side: read `HealthLoss`, `ShieldLoss` and `OverguardLoss` per target (slot 0 only). Native and Lua layers are not additive. These columns are null on 44.0.2 until section 4 is fixed.
   - Caster side: read `CasterSnapshots[*].Live.overguard` and `.strength` at `SetSource` and `RadialDamage`.
3. Read the per-hit input the addon used from `ADDON_TRACE key=<module key> event=dispatch.results`. `result3` is the damage, `result0` the decision, `result7` the target health after the hit.
4. Pair per beat: `ΔOG(k→k+1) = Σ grant hits of beat k` under the addon formula with per-hit truncation. Exclude beats where:
   - Octavia took damage (a `TennoAvatar` record in the beat);
   - strength changed;
   - Overguard is at the cap;
   - or a `trace.rate-limited suppressed_event=dispatch.results` window overlaps (visible as a gap in `result1` correlations).
   `tools/mallet_overguard_beats.py` does this for Mallet; for another ability, change the key and the formula.
