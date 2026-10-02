-- Appended after the real addon source by run_gates.py (the source is wrapped in a
-- function and its returned table is bound to `addon`). Only the game-only require
-- is stubbed; AbilitiesLib gameplay methods are not executed by these checks.
assert(type(addon) == "table")
assert(type(addon.activate) == "function" and type(addon.cleanup) == "function")
local hooks = addon.hooks
assert(type(hooks) == "table")
assert(type(hooks.matchesAbility) == "function")
assert(type(hooks.afterAbilityCard) == "function")
assert(type(hooks.afterDamage) == "function")
assert(type(hooks.transformFloatArgument) == "function")
-- PushFloatArg is reserved by the runtime's dedicated adapter; a generic
-- nativeCalls declaration is rejected (LOADOUT_NATIVE_HOOK_CONFLICT_2026-09-27).
assert(hooks.nativeCalls == nil)
assert(hooks.luaCalls == nil)

local transform = hooks.transformFloatArgument
-- The exact callsite as the runtime reports it: 44.0.2 BardMusic p16, NAMECALL
-- PushFloatArg at logical instruction 596. Every stock threat level becomes 5.
for value = 0, 5 do
    assert(transform(16, 596, value) == 5, "threat callsite not transformed for " .. value)
end
-- The CALL instruction index (597), the previous wrong target, is not a
-- runtime-reported callsite and must stay unchanged, as must every other
-- PushFloatArg site in the module (p10 i64/i67, p15 i100/i103) and neighbours.
for _, site in {{16, 597}, {16, 595}, {16, 576}, {10, 64}, {10, 67}, {15, 100}, {15, 103}, {18, 26}} do
    assert(transform(site[1], site[2], 2.5) == 2.5,
        "unrelated site changed: p" .. site[1] .. " i" .. site[2])
end
print("PASS contract: p16/i596 threat 0..5 -> 5; p16/i597 and 7 other PushFloatArg/neighbour sites unchanged; damage/card hooks retained; no nativeCalls/luaCalls")
