# Elite Sanctuary Onslaught "No Rank": why it never worked, and the fix (2026-09-29)

- Client: 44.0.2 (`2026.09.28.13.06`), native-name seed `0x768e5ed0`.
- Target module: `/Lotus/Interface/MissionRequirementUtilities.lua`.
  - Stock bytes: 34,198 B, SHA-256 `6801f711…1d25`, 28 prototypes. They are unchanged since 44.0 (same hash in `work/research/U44-2026-09-27/lua-port/artifacts`).
  - Live body key: `64d11e6973afa4b1`.
- Installed addon (read only, and it is the rollback): `OpenWF\CustomScripts\Inject\64d11e6973afa4b1.EliteSanctuaryNoRank.target.addon.lua_B`, 471 B, `86eacb89…2ed1`.
- Evidence session: pid 11584, `CustomScripts\Logs\renovice_source.log` plus rotations `.1` to `.3`. Excerpt: `evidence/live-log-anchor.txt`.
- Nothing was written to the game folder, the OpenWF server or the bootstrapper repository.

## Where the gate lives

The dialog text is `/Lotus/Language/Menu/MissionMaxSuitRequired`: "Requires Rank 30 Warframe or Mastery Rank 30 plus Forma to play this mission."
- It was decoded read-only from the 44.0.2 `H.Misc_en` `/Languages.bin` with `metadata-editor/decoder/lang_parse.py`.
- The squad variant is `…MissionMaxSuitRequiredSquad`.
- In the 5,474-module 44.0.2 Lua corpus, only `MissionRequirementUtilities` references this key.

The owner is prototype 21 of that module. It is the stock requirement checker, published through the wrapper p22 as the global that the namebase renders `CheckConclaveRequirements`. Its signature is `(node, flag, mission, …)`. For this gate it does the following:

1. If `mission` is nil, it looks the node up in alerts, goals, sorties, syndicate missions, invasions and so on. If none of those match, it builds the mission itself: `StarChart:BuildMissionForLocation(Symbol(nodeName))` at **p21 NAMECALL 324**.
2. It checks `masteryReq`. Then, only when `mission.maxSuitReq` is truthy:
   - **Solo, or a squad of one:** the equipped Warframe is `gPlayerProfileMgr:GetPlayerProfile(0):GetGameSpecificData():GetLoadOut():GetWeaponInfo(0,0)`. The check passes if `gGameConfig:GetItemLevel(mXP, mItemType) >= gGameConfig:GetLevelCap(mItemType)`. Otherwise it passes if `gGameData:<unresolved U44 hash c5213244>() >= 30` (the Mastery Rank, per the dialog text; the method name is not guessed) **and** `suit.mPolarized > 0` (at least one Forma on the equipped frame). If neither holds, it returns `MissionMaxSuitRequired`.
   - **Squad:** for each `gMatchingService:GetSquadMembers()` entry, it reads `cjson.decode(member.loadout).NORMAL[1]`. The member passes if `Level >= GetLevelCap`, or if `PlayerLevel >= 30` and `Polarized > 0`. Otherwise the checker returns `MissionMaxSuitRequired` (for the local player or a squad of one) or `…Squad` with the member's name.

The gate runs on the client when a mission is chosen, not when the mission is built on the host. `maxSuitReq` is a boolean field of the engine mission descriptor. Stock sets it the same way when it generates Elite missions: `Background` writes `mission:Copy().maxSuitReq = true` for elite alerts, and `SortieGenerator` writes it for sorties.

Three stock paths reach the checker for Sanctuary Onslaught:

| Path | Caller | Mission source |
|---|---|---|
| Launch | `TryLaunchOnslaught(isElite)` p25, from MapRedux, TennoHubScreenLauncher and ThemedSquadOverlay | `BuildMissionForLocation(Ternary(isElite, SolNode802, SolNode801))` at **p25 NAMECALL 9**, passed in |
| Star-chart confirm | MapRedux `Confirm sector` → checker `(Symbol(name), true, nil, true, true)` | p21 fallback, NAMECALL 324 |
| Squad pending-mission re-check after `SendSquadMission` | ThemedSquadOverlay → checker `(gPendingMission.name, not IsSquadHost())` | p21 fallback, NAMECALL 324 |

The caller details come from the readable U43 corpus (`guard-boundary-corpus-source-20260905`). The 44.0.2 bytecode of MapRedux, TennoHubScreenLauncher and ThemedSquadOverlay still references the U44 hashes of `TryLaunchOnslaught` (`b560c144`) and of the checker global (`6aa80081`).

## Server and data owner check

- The OpenWF server (`SpaceNinjaServer/src`, read only) has no `maxSuitReq`, `MissionMaxSuitRequired` or Warframe-rank entry test. `SolNode802` appears only as a `NodeOverrides` weekly seed. The gate is client-only.
- `spoofMasteryRank` alone does **not** satisfy the stock rule. It sets `PlayerLevel` (and fakes `XPInfo` unless the client disables the XP-based cap), so it covers the "MR 30" half. The stock rule also needs `mPolarized > 0` on the equipped frame. It is also account-wide and changes every MR-gated feature.
- A server-side route that stays inside the stock rule does exist: rank the equipped frame to 30 with the WebUI XP tool (`addXpController`), or spoof MR 30 and put one Forma on the frame. Both change account data per frame. Neither expresses "no rank requirement for Onslaught".
- So the owner of "remove the requirement" is the mission descriptor field that the checker reads: the target addon. Neither the server nor the metadata is the owner.

## Why the addon never worked

| # | Hypothesis | Evidence | Result |
|---|---|---|---|
| H1 | The addon binds and its native hook is called at the TryLaunchOnslaught callsite. | `target module identity PASS`, `TARGET ADDON PASS`, the adapter lists `BuildMissionForLocation`, and there is `native.call.provider.enter/return … invoked=1` with no provider error. | **TRUE** |
| H2 | The addon's callsite filter never matches. | The installed bytes (rebuilt byte for byte from the 2026-09-13 source) return unless `prototype == 25 and instruction == 10`. The runtime reports a native call at the **NAMECALL** that names the method. `native_callsite_instruction_from_saved_pc` maps a CALL preceded by NAMECALL back one instruction, and this has been so since V66 (2026-09-13). Live: `prototype=25 instruction=9`. Stock IR: p25 `[9] NAMECALL :BuildMissionForLocation`, `[10] CALL`. | **TRUE.** The callback always returned before writing. This is the root cause for every runtime since V66, which covers the 2026-09-13 corrected package and the current U44 install. |
| H3 | The 2026-09-12 `tostring(arguments[2]) == "SolNode802"` test caused the first live rejection. | That version had the same `instruction ~= 10` test placed before the node test. It ran on runtime V62, whose callsite numbering was not re-examined here. Stock itself turns the node Symbol into the squad mission name with `tostring(node)` (p25), and the checker turns that name back with `Symbol(name)`. | **UNCONFIRMED, and not supported.** No evidence ever showed the tostring line failing. The 2026-09-13 correction removed it but kept the actual defect. |
| H4 | Fixing p25 alone is enough. | After a successful p25 check, `SendSquadMission` leads to the ThemedSquadOverlay re-check. That call passes no mission, so the checker rebuilds one at p21/324, where `maxSuitReq` is set again. The star-chart confirm uses the same p21 fallback. Live `prototype=21 instruction=324` calls occurred 4 times across the rotations. | **FALSE.** Both callsites must be covered. |
| H5 | Writing `maxSuitReq = false` on the returned userdata is accepted. | Stock writes this same boolean field on mission descriptors (Background, SortieGenerator). The installed write was never executed live (H2). | **UNRESOLVED (live).** A write error would be a logged provider error: stock continues and the dialog shows. |
| H6 | `tostring(arguments[2])` at p21/324 yields `SolNode80x`. | The stock round trip `tostring(Symbol)` → squad name → `Symbol(name)` depends on it. The checker also calls `tostring(node)` on entry for its `Dojo` and `_HUB` tests. | **Supported by stock code; UNRESOLVED (live).** If it fails, only the p21 paths keep the dialog, and the p25 launch check still passes. |

## Fix (addon source only)

`64d11e6973afa4b1.EliteSanctuaryNoRank.target.addon.luau` keeps the single `hooks.nativeCalls.BuildMissionForLocation.after` and clears `mission.maxSuitReq` only in these two cases:

- **`prototype == 25 and instruction == 9`**: TryLaunchOnslaught. p25 only ever builds SolNode801 or SolNode802.
- **`prototype == 21 and instruction == 324`**, when `tostring(arguments[2])` is exactly `SolNode801` or `SolNode802`. `arguments[1]` is the StarChart `self`, and `arguments[2]` is the node Symbol.

Every other callsite and node is untouched, including TryLaunchFrameFighter p26/3 and every non-Onslaught mission through p21/324. The stock checker and launch flow stay authoritative: the checker is called the same number of times, and there is no polling, replacement, server change or runtime change. As before, the normal node SolNode801 is included. Clearing a flag that normal Onslaught does not set is a no-op.

Build: `derecomp.head.exe` `c1672d8d…7c58` (the committed U44 raw-hash toolchain, `0299da9`), `recompile-u44`. The source declares no seed and uses no `X__hex` names. Plain globals hash with the U44 seed: `tostring` → `cb160055`, `type` → `404f8a8c`, `IsNull` → `6514b208`. These are the same hashes and FASTCALL ids (63 and 40) that the stock 44.0.2 corpus uses.

Staged: `work/staging/elite-sanctuary-fix/`

| File | Size | SHA-256 |
|---|---|---|
| `64d11e6973afa4b1.EliteSanctuaryNoRank.target.addon.lua_B` | 785 B | `4e6d5b7133017e6001c61d0f1e1f1b7d6878f6a9085ca570008fede6815b90e3` |
| `64d11e6973afa4b1.EliteSanctuaryNoRank.target.addon.luau` (source) | | `75b7fe5d1ace10d6e17be9d83c8bb098287cfd9754a7da0639453940db52fce6` |
| `rollback/…lua_B` (the installed file) | 471 B | `86eacb891078aeb40b054ae2041ea29a23c3f55bc636612af35bd133d9672ed1` |

### Gates (`tests/run_gates.py`: 21/21 PASS, `evidence/gates.json`)

- **Input and tool identity:** the stock module, the installed addon, `derecomp` `c1672d8d…` and `luau.exe` `a0f4edd1…`.
- **Stock ownership:**
  - 28 prototypes, matching the live `module.graph nodes=28`.
  - `BuildMissionForLocation` NAMECALLs are exactly {p21/324, p25/9, p26/3}.
  - p25 is `Ternary(SANCTUARY_ONSLAUGHT_CHALLENGE_NODE, SANCTUARY_ONSLAUGHT_NODE)`, then NAMECALL 9, then CALL 10.
  - The p21/324 argument is `Symbol(...)`.
  - p21 reads `.maxSuitReq` and holds `MissionMaxSuitRequired`.
- **Baseline:**
  - The 2026-09-13 source reproduces the installed bytes exactly.
  - The installed IR filters on 25 and 10 only.
- **Contract test** on the real source under upstream Luau (`IsNull` stub, Symbol modelled with `__tostring`):
  - p25/9 and p21/324 for 801 and 802 clear the flag.
  - p25/10, p21/325, p21 with other or near-miss nodes, p26/3, the wrong prototype, missing arguments, nil or empty results, the inactive state and the post-cleanup state all leave it unchanged.
  - **Negative control:** the same assertions reject the installed source at `p25 i9`.
- **Build:**
  - `recompile-u44` re-parses the output.
  - Two builds are byte-identical.
  - `de-roundtrip` re-encodes 6/6 constants with a byte-identical full body.
- **CONST-ID:**
  - `decompile-mod-u44 → recompile-u44` gives 6/6 PASS (hash, string and key-use).
  - The compiler-closed fixed point holds: pass 2 and pass 3 are byte-identical, `49d86e05…`.
- **Constant classes against the installed addon:**
  - 0 hash/string class swaps.
  - The module-level delta is exactly: added strings `"SolNode801"` and `"SolNode802"`, added hash `tostring`, nothing removed, and no name used in both classes.
- **Opcode coverage:** all 21 candidate opcodes already occur in the stock module or in the installed addon that the game loaded live.

These gates prove the source, the build, the bytes and the exact callsite contract. They do not prove gameplay (H5, and the live check below).

## Runtime specification (NOT implemented; bootstrapper owner)

No runtime change is required: the runtime identity (the NAMECALL index) is consistent and already documented in code. Two small items would have prevented this class of failure, which also hit Mallet (`MALLET_THREAT_CALLSITE_FIX_2026-09-29`):

1. **Documentation.**
   - `RENOVICE_SCRIPTING/NATIVE_TARGET_ADDON_HOOKS.md` should state that `instruction` for `nativeCalls` is the NAMECALL's logical index when a NAMECALL precedes the CALL.
   - `RENOVICE_SCRIPTING/RESEARCH/ELITE_SANCTUARY_ONSLAUGHT_NO_RANK_2026-09-12.md` should link to this record. Its "instruction 10" and "tostring was the defect" statements are superseded.
2. **Optional generic admission diagnostic.** When Diagnostics is on, log once per (key, method) the set of `(prototype, instruction)` pairs that the adapter actually observed. A callback filter that never matches then shows up in the log without a gameplay test. It stays generic and bounded, and it formats nothing when Diagnostics is off. A stronger alternative is an optional declarative `callsites = {{prototype=…, instruction=…}}` per native method, validated at admission against the stock prototype graph. That is a new API surface, so it is left to the owner.

## Live check (the user runs it; nothing was deployed)

1. Close the game. Copy `work/staging/elite-sanctuary-fix/64d11e6973afa4b1.EliteSanctuaryNoRank.target.addon.lua_B` over the same-named file in `OpenWF\CustomScripts\Inject\`. `rollback/` holds the current file.
2. Start the game. Equip a Warframe below rank 30 that has no Forma (the stock rule would block it).
3. Open the Star Chart, go to Sanctuary Onslaught, and select **Elite** Sanctuary Onslaught (solo).
   - **Expected:** no "Requires Rank 30 Warframe…" dialog, and the mission loads.
   - As a control, normal Sanctuary Onslaught should still start as before.
4. With Diagnostics on, the latest session of `Logs\renovice_source.log` should show, for key `64d11e6973afa4b1`:
   - `native.call.provider.return … phase=after` after `prototype=25 instruction=9`, and after `prototype=21 instruction=324`;
   - no `native.call.provider.error`.

If the dialog still appears, send the log lines for this key. A provider error would identify H5 (the field write). A missing p21/324 or p25/9 event would identify the calling path.

## Superseded or rejected

- The p25/**i10** filter (2026-09-12 and 2026-09-13 packages, and the U44 port `addon-callsite-rebase.json`, which kept "instruction 10") never matched the runtime identity. Superseded.
- "tostring(Symbol) is unproven, so the node test caused the failure" (2026-09-13): not supported by any evidence (H3). The new node test uses it only at p21/324, and the contract test covers both plain-string and Symbol-like node values.
- p25-only coverage: rejected (H4). The squad re-check and the star-chart confirm rebuild the mission at p21/324.
- A server cheat or metadata as the owner: rejected. The gate is client-only and data-driven by the equipped frame and MR; the server can only satisfy the stock rule, not remove it.
