# Linked-stat Ability Editor implementation — 2026-08-25

## Result

The first usable Ability Editor vertical slice is implemented in C++ with a
native Windows GUI and CLI. It automates the previously manual linkage between
an addon gameplay value and its ordinary native ability-card row.

The project is intentionally staged-only. No live Warframe file was changed by
the editor build or its acceptance run.

## Implemented path

```text
Addon Creation / Linked Stats GUI
  -> one ability_edit JSON project
  -> registry validation
  -> canonical Lua stat definitions
       -> gameplay accessors
       -> base/modded native card rows
  -> target-addon lifecycle source
  -> derecomp recompile/reparse
  -> exact DE round-trip
  -> plan verification
  -> strict focused API check
  -> hashed STAGING package
```

The first action template is
`LINKED_DAMAGE_TO_CASTER_OVERGUARD`. It consumes a registered numeric damage
event, multiplies it by a linked fraction stat, adds the result to caster
Overguard, and clamps against a linked cap stat. The generator is parameterized
by target identity, body key, handler slot, labels, stat IDs, values, units,
modifier binding, and trace prefix. The event/API implementation is deliberately
limited to the live-proven contract rather than pretending arbitrary hooks are
known.

## Single-source invariant

Hypothesis: one authored stat can drive gameplay and the native card without
maintaining unrelated literals.

Evidence:

- the JSON project stores `damage_to_overguard.base=0.01`, maximum `0.05`, and
  `overguard_cap.base=15000` once;
- generated Lua emits each of those three numeric literals exactly once in a
  `linkedDefinition_*` table;
- gameplay calls `linkedStat_damage_to_overguard(caster)` and
  `linkedStat_overguard_cap(caster)`;
- the modded card calls the same functions with `query.Avatar`;
- base-card mode reads the same definitions' `.base` members;
- percentages multiply by 100 only at the native card boundary.

Conclusion: **TRUE by generated-source structure and focused self-test.**

## Evidence gates

The release core, GUI, and CLI compile with `-Wall -Wextra -Wpedantic -Werror`.
The MinGW C++/threading runtimes are linked statically; neither executable
imports `libstdc++-6.dll`, `libgcc_s_seh-1.dll`, nor `libwinpthread-1.dll`.

Focused self-test:

```text
passed=24
failed=0
```

The negative cases reject:

- duplicate stat IDs;
- unknown modifier bindings;
- unknown hooks;
- use of the Mallet-scoped hook/modifier binding with another ability/body key;
- unsafe/injectable handler-slot names;
- base values above their cap;
- FRACTION card rows without the native percent unit;
- nondeterministic generation.

Generated Mallet fixture:

```text
recompile:       PASS, re-parses=yes
de-roundtrip:    PASS, 9/9 prototypes' constants exact, FULL BODY identical: True
plan-verify:     PASS, every prototype failures=0
focused API:     PASS, violations=0, unverified_calls=0
staging status:  STAGED_PASS
live write:      false
```

## Artifact identity

Editor GUI:

```text
SHA-256 781D2CC4798C81210E2D2EFD15AEC91A0C06381C13279A68BE45FA5FA3FF3C09
```

Editor CLI:

```text
SHA-256 D61DE0B478117C83AEF2872A0230C8822D4CE98DA4C67CF7984DE06960CC9C04
```

Generated source:

```text
SHA-256 B46F5B27168D9BD8899F8CDE8F33692D4FCE397568148F9A97915075B0278FE4
```

Generated DE bytecode:

```text
SHA-256 F8E9049FA2CC0CBD370F4191AF73954C896190CEC4817FB3E92523B7F2EC82DA
```

The canonical build record is:

```text
STAGING/octavia_mallet_overguard/90E8BFA48E45/BUILD_MANIFEST.json
```

## API-catalog correction

Strict API checking initially rejected three previously uncatalogued calls:
`Ability:GetLocalizeTag`, `LocalizeTag:c_str`, and
`InventoryControl:ModifyValue`. The gate was not weakened. Exact scoped
contracts and the live pipeline evidence were added to
`DeNativeDecompiler (use this instead of native)/api/warframe/`.

After the correction, the strict checker reports 14 contract-verified calls,
four catalog-matched calls, zero violations, and zero unknown calls.

## Remaining limitation

The Mallet modifier binding remains `IMPLEMENTATION_VERIFIED`, not fully
`LIVE_CONFIRMED` for progression. Its call shape and shared gameplay/card
implementation are established, but the remaining acceptance is an explicit
base-versus-several-modded-Power-Strength comparison in gameplay and the card.
The editor surfaces this as a warning and records it in the build manifest.

The current action template also assumes the already live-proven BardMusic
damage dispatch shim. The editor does not yet generate that structural shim,
deploy to the live game, or claim arbitrary abilities expose the same event.
Those remain separate checklist work rather than hidden assumptions.
