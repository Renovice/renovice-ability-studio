-- Appended by run_gates.py after the real Ice Wave addon source (wrapped in a
-- function; its returned table is `addon`). `DECL` is injected from
-- package/Frost/package.json. Engine objects are minimal Lua stubs; the
-- native pipeline order is the stock p7 order: SetBaseAmount i42,
-- SetSource i53, DamageDD i65 before/after.
assert(type(addon) == "table" and type(addon.activate) == "function" and type(addon.cleanup) == "function")
local hooks = addon.hooks
local native = hooks.nativeCalls
assert(type(hooks.matchesAbility) == "function" and type(hooks.afterAbilityCard) == "function")
assert(type(native.SetBaseAmount.before) == "function" and type(native.SetSource.before) == "function"
    and type(native.DamageDD.before) == "function" and type(native.DamageDD.after) == "function")
assert(DECL.id == "ice_wave.bonus_per_cold_stack" and DECL.type == "float" and DECL.stock == 0)

local function world(stacks)
    local damage = { base = 100, writes = 0 }
    function damage:GetBaseAmount() return self.base end
    function damage:SetBaseAmount(value) self.base = value; self.writes += 1 end
    local control = {}
    function control:Name__ff67e37d(index) if index == 4 then return stacks end return 0 end
    local target = {}
    function target:DamageControl() return control end
    local suit = {}
    function suit:GetType() return "suit" end
    local inventory = {}
    function inventory:GetActivePowerSuit() return suit end
    function inventory:ModifyValue() end
    local source = {}
    function source:InventoryControl() return inventory end
    return damage, target, source
end

local function cast(stacks)
    local damage, target, source = world(stacks)
    native.SetBaseAmount.before(7, 42, { damage, 100 }, nil)
    native.SetSource.before(7, 53, { damage, source }, nil)
    native.DamageDD.before(7, 65, { target, damage }, nil)
    local installed = damage.base
    native.DamageDD.after(7, 65, { target, damage }, {}, nil)
    return installed, damage.base, damage.writes
end

local cases = 0
local function expect(bonus, why)
    local rows = {}
    local returned = hooks.afterAbilityCard(rows, { Modded = false })
    assert(returned == rows, why .. ": the stock row array is returned")
    if bonus == 0 then
        assert(#rows == 0, why .. ": stock card unchanged")
        INERT = true -- the IsNull stub raises: an inert addon never reaches it
        local installed, restored, writes = cast(3)
        INERT = false
        assert(installed == 100 and restored == 100 and writes == 0, why .. ": stock damage, no write")
    else
        assert(#rows == 1 and rows[1].Label == "Cold Damage Multiplier" and rows[1].Value == bonus,
            why .. ": card row " .. tostring(rows[1] and rows[1].Value))
        for _, stacks in ipairs({ 0, 1, 3, 10, 12 }) do
            local installed, restored = cast(stacks)
            local expected = 100 * (1 + math.min(stacks, 10) * bonus * 1)
            assert(math.abs(installed - expected) < 1e-6, why .. ": stacks " .. stacks .. " installed "
                .. installed .. " expected " .. expected)
            assert(restored == 100, why .. ": stock amount restored after DamageDD")
        end
    end
    cases += 1
end
local function with(entry) return { settings = { [DECL.id] = entry } } end

addon.activate() expect(50, "activate() loose layout / older DLL: compiled 50")
addon.activate({}) expect(50, "context without settings")
addon.activate({ settings = {} }) expect(0, "empty context.settings = stock (inert)")
addon.activate(with({ enabled = true, value = 10, stock = DECL.stock })) expect(10, "enabled 10")
addon.activate(with({ enabled = true, value = 0.5, stock = DECL.stock })) expect(0.5, "enabled 0.5")
addon.activate(with({ enabled = true, value = DECL.max, stock = DECL.stock })) expect(DECL.max, "enabled max")
addon.activate(with({ enabled = true, value = DECL.min, stock = DECL.stock })) expect(0, "enabled min (0) = inert")
addon.activate(with({ enabled = false, value = 10, stock = DECL.stock })) expect(0, "enabled=false")
addon.activate(with({ enabled = true, value = 10, stock = 50 })) expect(0, "stock differs from compiled")
addon.activate(with({ enabled = true, value = DECL.max + 0.001, stock = DECL.stock })) expect(0, "above max")
addon.activate(with({ enabled = true, value = -1, stock = DECL.stock })) expect(0, "below min")
addon.activate(with({ enabled = true, value = 0 / 0, stock = DECL.stock })) expect(0, "NaN")
addon.activate(with({ enabled = true, value = math.huge, stock = DECL.stock })) expect(0, "infinity")
addon.activate(with({ enabled = true, value = "10", stock = DECL.stock })) expect(0, "string value")
addon.activate(with({ enabled = true, value = 10, stock = DECL.stock })) expect(10, "re-activate custom")
addon.activate() expect(50, "re-activate compiled")
addon.cleanup()
local installed = cast(3)
assert(installed == 100, "after cleanup the addon is inert")
print("PASS icewave-settings-contract cases=" .. cases
    .. " (compiled 50 without context.settings; stock 0 = inert card and damage; enabled "
    .. DECL.min .. ".." .. DECL.max .. " applied as stockRaw*(1+min(stacks,10)*bonus*strength))")
