# Ability Studio compiler checkpoints — 2026-09-05

These immutable copies pin the compiler inputs selected for the next semantic-view audit. They were
copied from `repos/toolchains/de-luau-toolchain/work/diagnostics` after their report hashes and
declared compiler hash were checked against the current binary.

## Shared compiler identity

```text
D734114550B1815C898C47C70A0692693C959234D79EC852F89F29450FD8A078  derecomp.exe
```

## Raw first-pass fixed point

`fixedpoint-full360-raw350-d734-20260905.json`

```text
BDE478539788352E70A4374CBC2208C91D2C73DB4B3B622EEDE5C41E4CE2C7C0  report SHA-256
360 rows, 350 PASS, 10 FAIL, 0 errors, 5/5 long-cycle witnesses PASS
decompile mode: decompile-mod
```

## Compiler-closed stable fixed point

`fixedpoint-full360-stable360-d734-20260905.json`

```text
22884DCE105CC26EDBD026FD83DCA1FC6D7C006DD726766F875E0E9888328617  report SHA-256
360 rows, 360 PASS, 0 FAIL, 0 errors, 5/5 long-cycle witnesses PASS
decompile mode: decompile-mod-stable
```

The raw 350 checkpoint is the strict input partition for the first audit. The stable 360 checkpoint
is retained as a separate production/editing lane and must never be relabeled as raw first-pass
parity. Neither certificate alone proves semantic-view beautification or in-game behavior.

## Downstream semantic-view result

The raw-350 schema-3 audit accepted 318 scripts and fail-closed rejected 32, so
the corpus-wide result is 318 verified and 42 unverified. All 315 scripts from
the previous accepted set remained accepted. Of the five newly raw-eligible
scripts, three passed every semantic-view gate; `Lotus_Interface_Codex.lua_B`
and `Lotus_Interface_Hub.lua_B` both stopped at the exact
`FIDELITY_RENDER_ORPHAN_PROTOTYPE_PENDING` boundary.

```text
CF5B89309BD4C19FB777A6A485E5639788C8CDA9A9689CAA54781EB3F001D531  schema-3 coverage JSON
0E2F68A3C865B9DB9AFFEC63F93FCD34EE4AA7F46DD247F9E574A29BC1D7BC1F  old-to-new transition JSON
2CA3806F392DB66FC656EADB17BDA5150D7316138358E6A2EF352D694C774E91  exact rejection diagnostics JSON
```
