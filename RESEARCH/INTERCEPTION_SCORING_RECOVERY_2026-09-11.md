# Interception scoring recovery (2026-09-11)

## Scope

This investigation covers the Ability Studio two-times Interception scoring
addon for `Lotus.Scripts.Modes.TerritoryMission`, exact body key
`a51e98a1833bd8c1`. It does not change the bootstrapper DLL, the stock Territory
module, or any other mission addon.

## Hypotheses and results

| Hypothesis | Evidence | Result |
|---|---|---|
| The previously deployed multiplier changed Interception scoring. | The live runtime reached `luaCalls.35.before` hundreds of times, but every callback failed before mutation with `Interception scoreRatePerSecond is not numeric`. Stock execution continued because the hook fails closed. | **FALSE live** |
| The target addon failed to load or prototype 35 was not reached. | The decoded callback error is emitted only after the exact body-keyed provider and prototype-35 callback have been selected and entered. | **FALSE** |
| The reconstructed global name is wrong. | The stock prototype-35 constant table contains hash `0xD422845B`; `derecomp namehash scoreRatePerSecond` resolves to the same value. Exact stock uses that global at bytecode instructions 85, 87, 90, 839, and 909. | **FALSE** |
| The callback's `type(scoreRatePerSecond)` guard is required for safe mutation. | The subsequent equality check against exact stock value `1` already rejects nil, nonnumeric, and drifted values. The type guard prevented the owner assignment and supplied no additional accepted state. | **FALSE live for the old guard** |
| Removing only the rejected type guard preserves the native scoring model. | The successor still requires prototype 35, valid callback tables, and `scoreRatePerSecond == 1`; assigns `1 * 2` once; and retains stock's times-four mission branch and times-2.25 alert derivation. | **TRUE offline; live F9 test pending** |

## Exact behavior retained

The stock module calculates progress from tower ownership, its
`scoreRatePerSecond` global, and the existing time/scale function. The addon
changes only the stock scalar from `1` to `2` before the mission closure uses
it. It does not poll score, rewrite progress each frame, replace Territory
bytecode, or add a parallel scoring system.

The earlier callback failure is bounded evidence that the old artifact did not
apply the multiplier. It does not show that Interception itself malfunctioned;
stock continued normally.

## Offline and deployment evidence

- Ability Studio native test: 1/1 passed.
- Ability Studio managed tests: 102/102 passed.
- Generated artifact gates: 4/4 passed.
- Corrected addon: 945 bytes, SHA-256
  `E802EDB863CCFC9A7F7D67C70B52CE2C2D108E627116CE93EAA743C3C8FB76FD`.
- Decode: 4 prototypes, 109 instructions, zero violations.
- DE container roundtrip: 4/4 prototypes exact.
- Semantic plans: 4/4 prototypes, zero failures.
- Previous addon rollback: 1,075 bytes, SHA-256
  `5C1F441FCE9BCDB3A61691E24864FBC4588CAE8340EC5F7CA27EB1A42F751429`.
- Live bootstrapper remains V61, SHA-256
  `5CB029981628A41B8C2D92BA2E2A4B986F8546188897BC53A983AE5C09204E45`.

The corrected script is deployed. Because the game was already running, live
acceptance requires F9 to commit the new script generation, followed by a newly
started Interception mission. Required observations are an accepted F9
transaction, visibly faster scoring under equivalent tower ownership, adjacent
stock mission behavior, and no new relevant callback error.
