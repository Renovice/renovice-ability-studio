# Mallet threat-level audit (2026-09-11)

## Question

Does observing some enemies attack Octavia prove that the Mallet threat-level-5
addon failed?

## Hypothesis results

### H1: the exact threat callsite was removed or shifted by the no-cover replacement

**Evidence:** the live replacement
`08faf07b504d058f (Octavia Mallet No Cover exact flags).lua_B` is 17,805 bytes
with SHA-256
`554F847CAD45ADB4AA46B2615EF0E1E68FBCC5BA3864F57A5DF087F363325CE5`.
Its disassembly still contains the stock threat update in prototype 16:

- instructions 591-593 construct the stock `SecondaryScriptArgs` value;
- instruction 594 moves the currently calculated stock threat scalar into the
  explicit argument register;
- instruction 595 resolves method hash `0x0BD8905A`, exactly `PushFloatArg`;
- instruction 596 performs the call;
- the exact callsite map identifies `p16:i596:o0:method:PushFloatArg` and its
  one explicit argument.

**Result: FALSE.** The no-cover replacement preserves the exact prototype and
instruction boundary used by the threat addon.

### H2: the addon is wired to the exact authoritative stock call

**Evidence:** the deployed addon
`08faf07b504d058f.MalletOverguardAndCard.target.addon.lua_B` is 2,732 bytes
with SHA-256
`36D2E3EC21E5879FBC0129A82139CF35E53D5FC95C8A82443D106EFF6FBDF049`.
Its `nativeCalls.PushFloatArg.before` callback changes `arguments[2]` to `5`
only when `prototype==16` and `instruction==596`. Exact DE roundtrip and
semantic-plan verification pass. Previous runtime startup evidence reports one
installed `PushFloatArg` adapter and one declared native call for the addon.

**Result: TRUE for structure, registration, and offline callback behavior.**
The addon targets the exact stock value handoff; it does not run a parallel
threat system, poll AI, or repeatedly scan enemies.

### H3: any enemy attacking Octavia proves threat 5 is absent

**Evidence:** this hook changes the scalar passed into the stock
`SetThreatLevel` secondary-script path. It does not set invulnerability, clear
every existing AI target, or replace all AI behavior. An enemy can still attack
the player because of its current target, proximity, behavior-specific logic,
or target selection outside the path controlled by this scalar.

**Result: FALSE.** Occasional player targeting is compatible with Mallet threat
5. A useful gameplay comparison is whether newly acquiring enemies prefer
Mallet more strongly; it is not an absolute zero-attacks guarantee.

### H4: the outgoing live argument has been directly captured as 5

**Evidence:** the previous broad trace exhausted its 4,096-event budget before a
selected `PushFloatArg` record. The existing log proves adapter installation but
does not contain a bounded `native.call.before` record for prototype 16,
instruction 596 showing the post-provider outgoing argument.

**Result: PENDING LIVE.** After the Control Area timer acceptance run, use the
existing reusable logger with:

```ini
DiagnosticsMode=trace
DiagnosticsMaxEvents=256
DiagnosticsTarget=08faf07b504d058f
DiagnosticsMethod=PushFloatArg
DiagnosticsAddon=08faf07b504d058f.MalletOverguardAndCard.target.addon.lua_B
```

Press F9, cast one Mallet, allow it to enter its threat update path, and inspect
the bounded trace. Acceptance requires the exact prototype 16/instruction 596
provider callback to return successfully with explicit argument 1 changed to 5
(native log `arg1`, Lua table `arguments[2]`). Return diagnostics to `off` after
the capture.

## Evidence files

- Exact callsite map:
  `work/ability-behavior/current/modules/08faf07b504d058f/calls.tsv`
- Readable stock view:
  `work/ability-behavior/current/modules/08faf07b504d058f/readable.luau`
- Live no-cover disassembly snapshot:
  `repos/apps/ability-editor/RESEARCH/CONTROL_AREA_LIVE_RECOVERY_2026-09-11/mallet-live-no-cover.disasm.txt`
- Reusable logger contract:
  `repos/runtime/bootstrapper-runtime/RENOVICE_SCRIPTING/DIAGNOSTICS_CONFIG.md`
