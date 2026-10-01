# Missions R17: the last four R10 entry rows and "All <mission type> missions" masters (2026-10-01)

- **Build:** client 44.0.2 (`2026.09.28.13.06`), U44 name-hash seed `768e5ed0`.
- **Branch:** ability editor `feat/missions-r17-type-masters-2026-10-01`, from R16 `c48c819`.
- **Runtime:** bootstrapper `feat/r17-type-masters-2026-10-01` (worktree `repos/runtime/bootstrapper-runtime-wt-r16`, from
  R16 `75e47a4`): `quick_on_page` page pair, a drive's own module in `literals.json`, a master on an `engine_params.json`
  override. Record `RESEARCH/TYPE_MASTERS_R17_2026-10-01/README.md` there.
- **Research:** `work/research/mission-settings-r17-2026-10-01/README.md` (classification C1-C8, masters M1-M4).
- **Status:** every offline gate PASS. **Nothing is live.** Staged `work/staging/combined-r17/`. Nothing deployed or pushed.

## Changes

| Area | Change |
|---|---|
| Registrar inputs | `inputs/r17_row_drafts.json` (LF SHA-256 `653D94A8…B7BFD3`): Deepmines hold time and bonus threshold as reader pins (supersede the R10 drafts), new row `sabotage.gascity_meltdown_time_scale` (SCRIPT_PARAM_GLOBAL_AT_ENTRY, mode scale, `hackTime` + `modeTimer`). `inputs/r17_engine_overrides.json` (`4110FEA4…276CB4`): the Gas City row admitted to ENGINE_PARAM_OVERRIDE_V1. |
| `tools/mission_owner_specs.py` | R17 drafts (supersede R10 drafts with a reason; new ids allowed), `EXCLUDED['gascity.hack_time']` (wrong owner), R16 + R17 override inputs. |
| `tools/player_text.py`, `player_text_r17.py` (new), `player_text_r10.py` | `master(..., group=, word=)`; masters may drive rows of several modules (`body_keys`, same lane); nine new masters (Control Area across three modules, Railjack kill goals across three modules, seven single-module literal masters); Gas City and Deepmines text. |
| `tools/player_layout.py` | `master_row()`: the type's master at the top of its page (`quick_on_page`, row "All <type> missions", main section); Advanced sections after every family of a type; 1999 Escalation merged after Exterminate; R17 gates (the master is the first entry of its page, page and Quick pair rows within 40). |
| Generator C++ | `quick_on_page` in declarations, recipe declarations, schema and the label budget; cross-module masters (addon: per-target drives; literal: per-drive `module`, synthesis per module); a natively owned row driven by an addon master: `engine_params.json` names the master, the addon leaves the row out of its master drives; self-test updated (paths of `survival.reward_interval`, cross-module master rejects). |
| Gates | New `tools/test_r17_type_masters_harness.py`; pins and expectations of `test_engine_param_override_harness.py`, `test_entry_native_harness.py`, `test_void_flood_tank_harness.py`, `test_live_literals.py`, `test_presets_and_sample.py` moved to the R17 build (layout deltas computed against the R16 registry `c48c819`). |

## Package (staged `work/staging/combined-r17/OpenWF/CustomScripts/Packages/Missions/`)

| File | Bytes | SHA-256 |
|---|---:|---|
| `Missions.targets.addon.lua_B` (33 targets, 108 hooks, 19 entry rows) | 112,084 | `daab653a2cdf17f5875c4e0f65f709b43f5998d2892058a2bd9692a60500d2ea` |
| `package.json` (371 declarations, 31 masters) | 252,679 | `fb43906b7c6d1532fe550a4639bbcda85a0cd1c315996c3b3815be01a3cff9f3` |
| `literals.json` (133 live literals, 16 masters, 43 modules) | 205,395 | `028fdcd230e16410f4336a6c700e96cd594d59ff6518011e9ff41057da3ac572` |
| `engine_params.json` (9 overrides, 7 values, 4 modules, 1 master) | 1,986 | `26e56e26775dfec42b0ca3aa725a5b23163b4671b2fa1128abf43b1538e3bf7c` |

504 values (371 + 133), 23 Quick settings entries, 21 "All <type> missions" masters. Build input unchanged
(`MISSIONS_R13_NATIVE_ENTRY_2026-10-01/inputs/rebuild_input.r12.json`). Registry fixed point `f8e02c21…` (667 rows:
EXACT_LITERAL 254, TARGET_ADDON 348, METADATA_PATCH 64, SERVER_CONFIG 1), player text data `EDC3E54B0BAFB323`.

## Gates

| Gate | Result |
|---|---|
| `register_registry.py` -> `player_text.py` x2, then again | fixed point `f8e02c21…` |
| CLI build (MSYS2 ucrt64, `-Werror`), `verify-missions`, `self-test`, ctest | PASS 667/667, 150/150, 2/2 |
| Package build gates | `live-literal-recipe` values=133 masters=16 modules=43; `engine-param-overrides` rows=7 overrides=9 modules=4 masters=1; `settings-layout` values=371 live_literals=133 pages=208 quick=23; `settings-declarations` masters=31; `hook-plan` targets=33 hooks=108 entry_rows=19 |
| `test_r17_type_masters_harness.py` (new) | PASS (census, readable order facts, three-module Control Area synthesis, Deepmines pins, Gas City in both engine orders and three runtimes, surprise extraction REACHES) |
| `test_engine_param_override_harness.py`, `test_entry_native_harness.py`, `test_defense_reader_pin_harness.py`, `test_void_flood_tank_harness.py`, `test_live_literals.py`, `test_presets_and_sample.py`, `test_flow_gate.py`, `test_phase2d/2e/2k` | PASS |
| Bootstrapper `verify_addon_settings`, `verify_live_literals`, `verify_engine_params`, `verify_script_settings_render` (R17 tape), every build-listed gate, private build warnings=0 errors=0 | PASS (bootstrapper record) |
| Installed-state replay (R17 Missions + read-only copies of the installed Frost/Octavia, values files, ScriptStates.json) | ADDON SETTINGS GATES PASS, Missions `declarations=504 rejected=0 unknown_entries=6 members_staged=1/1` |

## Limits (exact)

- **Nothing is live.** Live checks pending: see the staging README.
- Gas City: which engine order applies is not known offline; the scaled row covers both (R16 DLL or later); the R10
  fallback covers only the order without a re-write.
- Deepmines bonus threshold: minimum 1 (was 0; LOADN domain).
- A natively owned row driven by a master (Railjack Corpus fighters) gets the master only through the R17 writer hook; on
  an older DLL or with the hook refused the master does not reach that row (its own value still does through the R10 lane).
- Older DLLs reject the R17 package's settings (`unknown-field=quick_on_page`) and recipe (`drive-unknown-field=module`):
  install the R17 DLL with the package.
