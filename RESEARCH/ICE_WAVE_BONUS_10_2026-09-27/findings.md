# Ice Wave per-Cold-stack bonus update
2026-09-27. User requested bonus +10x at base Strength; automatic numeric-label mapping cancelled.
Verified prior source after the four recorded U44 callsite rebases recompiles byte-identically to installed SHA256 945881D62F376D735E38CD5D537E8F823CD7C39C83D6AD89853020E768123073. Prior bonus was 3, not 5.
Changed only four source expressions: card coefficient, gameplay coefficient, damage diagnostic bonusPerStack, Strength diagnostic coefficient. All 3 -> 10. Source recompilation, not binary byte edits.
Formula retained: stockRaw * (1 + coldStacks * 10 * abilityStrength). Per-target handling unchanged. Card remains Cold Damage Multiplier and shows 10 * Strength.
Canonical compilation and semantic plans passed all 37 prototypes; U44 compilation/reparse and full-body serialization roundtrip passed 37/37.
Installed only the Ice Wave addon in Warframe 23.09.2026; DLL, other scripts and diagnostics settings unchanged. Previous bytes retained as artifacts/rollback-bonus3.lua_B.
Installed SHA256: 78FE0410BA34B056AF74FF215ED28A50E2B7925821D94CBA8B90C80987D3D30F
Gameplay/card acceptance requires a fresh load; not claimed live-tested.

## Reported regression
User sees new card coefficient but no gameplay bonus. Audit finds exactly three changed bytes: two LOADN immediates 3->10 and one shared f64 constant 3->10. Same 37 prototypes, same instruction sizes, native hashes and hook bindings. Installed DLL/build and enabled state match. No evidence of accidental unrelated recompile changes; cause INCONCLUSIVE. Prepared temporary target/addon filtered trace, max1024, engine/caster/buff/memory observers off. Original config artifacts/renovice-before-targeted-test.cfg MUST be restored after capture. No further addon or DLL change in this investigation.

## User loadout-switch reproduction
User reports Octavia at startup -> switch to Frost: card shows updated value but damage bonus absent. Restart with Frost selected: bonus works. SUPPORTED by user gameplay observation; consistent with attachment/initialization or stale-state issue, not proof of a specific internal cause. Numeric +10 change remains installed. Latest appended capture confirms Ice Wave target module identity, dispatcher installation, Inject PASS and TARGET ADDON PASS, but contains no current damage-callback evidence proving the switching failure. Older V82/PID29384 records in the same append-only log must not be attributed to this test. Current CircuitProgressPreview activate protected-call-rejected also appears; separate issue, not established as causal for Ice Wave.
Restored original renovice.cfg byte-for-byte from artifacts/renovice-before-targeted-test.cfg: Diagnostics=false and Logging=false. Running process needs restart (or successful config reload) to consume restored state. No runtime architecture or addon changes made for this observation. Retain startup-as-Frost as workaround until switch attachment is diagnosed.
