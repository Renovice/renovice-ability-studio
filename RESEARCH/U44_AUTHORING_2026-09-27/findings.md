# U44 authoring and Mallet threat — 2026-09-27

## Scope and evidence
Current game build: 2026.09.24.13.29, installed in Warframe 23.09.2026.
User reports current Scripts/cards/addon effects working except Mallet threat. Obsolete Riven lock crash is outside this change. No runtime DLL or diagnostics configuration changed.

## Mallet
Hypothesis: luaCalls.before on exported SetThreatLevel (flat prototype 18) misses engine secondary-script entry.
SUPPORTED static path: BoxLoop p16 computes a threat value, calls SecondaryScriptArgs:PushFloatArg at current CALL instruction 597 (NAMECALL 596), then requests the secondary script. The old current addon observed p18 through Lua CALL observation; engine entry is a different path. Runtime non-entry remains unmeasured because diagnostics are off.
Change: existing universal nativeCalls.PushFloatArg.before edits argument 2 to 5 ONLY at p16/i597. Receiver is argument 1. All six stock input threat levels are covered; unrelated sites remain unchanged. No repeating setter or additional runtime system.
The native setter hash is unresolved; do not invent a symbolic setter name.
Candidate retains all Overguard and ability-card source. Its 14-prototype bytecode passes full-body serialization roundtrip. Extracted callback fixture passes six input levels and three unrelated sites. This does not prove enemy targeting behavior.
Installed artifact and rollback hashes: artifacts/deployment.json. Exactly one CustomScripts file changed. Diagnostics=false retained. Gameplay acceptance requires restart and fresh Mallet cast; test stationary Mallet separately from Resonator.

## Mission maker
SUPPORTED: REGISTRIES/mission_build_u44.json binds seven existing presets plus Void Cascade to current raw stock body keys, SHA256 and exact operand preimages. Old corpus remains untouched. New local corpus: shared/corpus/de-luau-u44-authoring.
Existing staging, CLI validation, manifests and hash-checked export are reused. Survival current main prototype is 67 (previously 64); capture ownership retained. Interception retains its existing current verified owner. Addon values are taken from the profile's displayed parameters, not stale legacy generation fields.
Replacement edits retain all original stock bytes except declared LOADN instructions. Full-source recompilation of these mission bodies remains disallowed by the existing approach.
Void Cascade uses Lotus.Scripts.Modes.ZarimanSurvivalMission: PILLAR_DURATION and PILLAR_DURATION_CIRCLE are both 90. Stock timer creation and UI consume these values. The multiplier writes 90/speed to both; 2x=45 seconds, 3x=30. Spawn timing, rewards and other mission settings are not changed. Current LOADN editing requires positive whole-second results; unsupported fractional results reject.
Builds passed for all eight presets; wrong target, wrong build and invalid parameter rejection passed for each (24 cases). Existing C++ self-test passed; managed tests 107/107 passed. WPF published to work/builds/ability-editor/current/studio.
Mission artifacts were tested in staging, not automatically copied over the user's existing mission choices. Use Mission Timers, select a preset, edit values and Create to choose the destination .lua_B.
Gameplay acceptance on current client remains pending.

## Numeric labels and remaining authoring coverage
The existing stock-value binding registry supports friendly names tied to exact body and readable variable. It is not a universal semantic inference system. A native numeric register is not enough to name a stat reliably.
Current Snow Globe extracted IceShield evidence: artifacts/globe.readable.luau variable v19_16 is the base-health rank ladder, with 1500/2500/3000/3500 PvE values and separate 425/450/475/500 PvP values. It feeds HEALTH card and maxHealth payloads after modifiers. Do not label every reused c2v1 temporary as health.
Ice Wave's custom Cold Damage Multiplier belongs to the addon, separate from native Ice Wave base damage. Labels for custom addon constants and stock ability values must retain that distinction.
The full ability catalog and all readable stock-value bindings have NOT been refreshed/certified here. The current-build migration implemented here covers mission presets. The extracted Snow Globe evidence is available for a subsequent verified label/catalog update; no guessed labels were shipped.

## Reproduce
Run build_editor.bat for core self-test, managed tests and WPF publish.
Run python RESEARCH/U44_AUTHORING_2026-09-27/scripts/test_profiles.py for eight current mission builds and 24 rejections (requires local stock corpus/toolchain and existing test projects).
Artifacts/profile-tests/results.json and per-mission logs record outputs. Deep research staging paths exceeded Windows path limits; tests use work/staging/ability-editor-u44-tests.

## Superseded Mallet declaration
2026-09-27 follow-up found installed runtime rejects nativeCalls.PushFloatArg as reserved; the earlier declaration deployed here was incorrect despite passing compilation. It could poison later native-hook installation after starting as Octavia. Corrected using existing transformFloatArgument at p16/i597; see runtime RESEARCH/LOADOUT_NATIVE_HOOK_CONFLICT_2026-09-27/findings.md. Current gameplay switch acceptance pending.
