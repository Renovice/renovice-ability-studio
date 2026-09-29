-- Appended by run_gates.py after the real Mallet addon source (wrapped in a
-- function; its returned table is `addon`). `DECL` is injected from
-- package/Octavia/package.json. Only the game-only `require` is stubbed.
assert(type(addon) == "table" and type(addon.activate) == "function" and type(addon.cleanup) == "function")
local hooks = addon.hooks
assert(type(hooks) == "table" and type(hooks.transformFloatArgument) == "function")
assert(type(hooks.matchesAbility) == "function" and type(hooks.afterAbilityCard) == "function"
    and type(hooks.afterDamage) == "function", "damage and card hooks retained")
assert(hooks.nativeCalls == nil and hooks.luaCalls == nil, "no generic nativeCalls/luaCalls")
assert(DECL.id == "mallet.threat_level" and DECL.type == "int")

local transform = hooks.transformFloatArgument
local unrelated = {{16, 597}, {16, 595}, {16, 576}, {10, 64}, {10, 67}, {15, 100}, {15, 103}, {18, 26}}
local cases = 0
local function expect(level, why)
    for stock = 0, 5 do
        local got = transform(16, 596, stock)
        if level == nil then
            assert(got == stock, why .. ": stock expected for " .. stock .. ", got " .. tostring(got))
        else
            assert(got == level, why .. ": expected " .. level .. ", got " .. tostring(got))
        end
    end
    for _, site in ipairs(unrelated) do
        assert(transform(site[1], site[2], 2.5) == 2.5, why .. ": unrelated site p" .. site[1] .. " i" .. site[2])
    end
    cases += 1
end
local function with(entry) return { settings = { [DECL.id] = entry } } end

expect(5, "before activate (compiled default)")
addon.activate() expect(5, "activate() loose layout / older DLL")
addon.activate(nil) expect(5, "activate(nil)")
addon.activate({}) expect(5, "context without settings")
addon.activate({ settings = {} }) expect(nil, "empty context.settings = stock (dynamic)")
for value = DECL.min, DECL.max do
    addon.activate(with({ enabled = true, value = value, stock = DECL.stock }))
    expect(value, "enabled value " .. value)
end
addon.activate(with({ enabled = false, value = 2, stock = DECL.stock })) expect(nil, "enabled=false")
addon.activate(with({ value = 2, stock = DECL.stock })) expect(nil, "enabled missing")
addon.activate(with({ enabled = true, value = 2, stock = DECL.stock - 1 })) expect(nil, "stock differs from compiled")
addon.activate(with({ enabled = true, value = 2 })) expect(nil, "stock missing")
addon.activate(with({ enabled = true, value = DECL.max + 1, stock = DECL.stock })) expect(nil, "above max")
addon.activate(with({ enabled = true, value = DECL.min - 1, stock = DECL.stock })) expect(nil, "below min")
addon.activate(with({ enabled = true, value = 2.5, stock = DECL.stock })) expect(nil, "fraction for int")
addon.activate(with({ enabled = true, value = 0 / 0, stock = DECL.stock })) expect(nil, "NaN")
addon.activate(with({ enabled = true, value = "3", stock = DECL.stock })) expect(nil, "string value")
addon.activate(with(true)) expect(nil, "entry not a table")
addon.activate({ settings = { ["other.id"] = { enabled = true, value = 1, stock = 5 } } }) expect(nil, "unknown id only")
-- Re-activation recomputes (F9 / settings commit / rollback).
addon.activate(with({ enabled = true, value = 2, stock = DECL.stock })) expect(2, "re-activate custom")
addon.activate({ settings = {} }) expect(nil, "re-activate stock")
addon.activate() expect(5, "re-activate compiled")
addon.cleanup() addon.cleanup()
print("PASS mallet-settings-contract cases=" .. cases
    .. " (compiled 5 without context.settings; stock without an applicable entry; enabled "
    .. DECL.min .. ".." .. DECL.max .. " forced; unrelated PushFloatArg sites unchanged)")
