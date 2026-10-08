# Mallet threat 5 at the game's own setter (2026-10-08)

- Client 44.1.0 (`2026.10.06.16.12`). BardMusic is byte-identical to 44.0.2 (content key `ec368d4901690a15`,
  stock sha256 `c713c4d6…299f`, 17,835 B, 22 prototypes).
- User report: "the threat level Mallet script keeps resetting it and enemies randomly stop attacking Mallet".

## Hypotheses and evidence

| # | Hypothesis | Evidence | Result |
|---|---|---|---|
| H1 | The Mallet addon is not bound or its threat setting is not delivered. | Session pid 34340: `TARGET ADDON PASS key=ec368d4901690a15` once; `SETTINGS PACKAGE … package=Octavia … effective=1 rejected=0`; `SETTINGS DELIVERY … values=1`; the one Scripts-settings open closed with `close-no-changes`. The settings file's older build stamp is accepted because the recorded stock (5) matches the declaration. | FALSE |
| H2 | The `PushFloatArg` transform works when it fires. | `native.float.transform prototype=16 instruction=596 stock=0/2/3 transformed=5` (26 records over logs .2/.1). | TRUE |
| H3 | The hook can miss threat pushes. | `push_float_arg_adapter` (`renovice/injection.cpp`) silently skips when the generation gate is closed, the global state is not in callsite-snapshot mode, the active callsite is not exact, or no provider is bound for that global state; none of these are logged. Live: transforms at ticks 182451531…182701703, then none until the session's last Mallet damage at 183774265 (≈18 min) while the Mallet absorbed 10^6-10^7 per hit. Each new Mallet starts its loop with last level 0, pushes stock 5 (untraced, equal), then stock 0 on its first stored damage, which must produce a traced transform if caught. The callback counter still advanced (`VM_MEMORY … transformFloatArgument calls=16384` at 183268781). | PLAUSIBLE (strong): consistent with missed or untransformed pushes; the skip reason is not observable with current diagnostics |
| H4 | Mallet threat mechanics differ from Loki Decoy. | Decoy (`DecoyAbility` P10, 44.1 decompile): on the master, `avatar:SetThreatModifier(5)` once at spawn. Mallet (`BardMusic` P16): `level = floor(Lerp(5, 0, min(1, pool / 1500)))`, pushed through `SecondaryScriptArgs:PushFloatArg(level)` + `ActivateSecondaryScript(…, "SetThreatLevel", …)` whenever the integer changes; P18 `SetThreatLevel` (EM_HOST) calls `_T.bardMusic[owner].box:SetThreatModifier(level)`. At 999+ enemy level the pool exceeds 1500 on the first hit, so stock applies 0: one missed push leaves the Mallet ignored. | TRUE: same setter, the Mallet value depends on catching every push |

## Fix

Root replacement `ec368d4901690a15 (Octavia Mallet No Cover + threat 5).lua_B` (supersedes
`… (Octavia Mallet No Cover exact flags).lua_B`, moved to `work/backups/mallet-before-setthreat-2026-10-08`):

| Prototype | Instruction | Stock | Edit | Effect |
|---|---|---|---|---|
| P16 | i568 | `LOADB R31 true` | `LOADB R31 false` | radial damage `checkForCover = false` (existing) |
| P16 | i570 | `LOADB R31 true` | `LOADB R31 false` | radial damage `staticCoverOnly = false` (existing) |
| P18 | i25 | `MOVE R6, R2` (the pushed level) | `LOADN R6, 5` | `SetThreatLevel` always calls `box:SetThreatModifier(5)` |

The game's own update cadence and its single setter are kept; only the value changes. No polling, no extra calls.
The addon's `transformFloatArgument` still runs but no longer decides the applied value; its `mallet.threat_level`
setting does not change the applied threat while this replacement is enabled (turn the replacement off in SCRIPTS
for the stock falling threat, which also restores cover checks).

Gates (`build.py`, reusing `Scripts/IcebindSolo/src/build_members.py`, extended with MOVE/LOADN words): stock-key,
expected-old-words, parse-u44, byte-diff (4 bytes vs stock; 2 vs the previous replacement), same-shape+edit-script,
self-rebase, shifted-rebase, de-roundtrip 22/22, const-identity 22/22 PASS; cfg-identity reports the intended
labels. Candidate sha256 `5478983cb3b381ed…`.

## Limits / pending live

- Threat 5 is the Decoy value; the AI may still pick another target for reasons outside threat (current target,
  range, behaviour). Live: cast Mallet against level 999 enemies and watch whether they keep attacking it.
- The window between Mallet spawn and its first threat update (first beat) keeps the stock default.
- H3's skip reason stays unobserved; a bounded skip-reason diagnostic in `push_float_arg_adapter` is the next step if
  enemies still leave the Mallet.
