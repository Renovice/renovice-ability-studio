-- Contract test for the real addon source under upstream Luau.
-- `addon` is the table returned by the source. A table with __tostring stands in for
-- the engine Symbol: stock TryLaunchOnslaught sends tostring(node) as the squad mission
-- name, and the checker turns that name back into Symbol(name), so tostring(Symbol) is
-- the node name.
local function symbol(name)
    return setmetatable({}, { __tostring = function() return name end })
end
local starChart = {}
local after = addon.hooks.nativeCalls.BuildMissionForLocation.after
assert(type(after) == "function", "after hook missing")
assert(addon.hooks.luaCalls == nil, "no luaCalls expected")
local count = 0
for _ in pairs(addon.hooks.nativeCalls) do count = count + 1 end
assert(count == 1, "exactly one native method expected")

local function run(p, i, node)
    local mission = { maxSuitReq = true }
    after(p, i, { starChart, node }, { mission })
    return mission.maxSuitReq
end

-- Inactive: nothing changes.
assert(run(25, 9, symbol("SolNode802")) == true, "inactive addon must not mutate")

addon.activate()

-- TryLaunchOnslaught (p25 NAMECALL 9): both Onslaught nodes.
assert(run(25, 9, symbol("SolNode802")) == false, "elite onslaught p25 i9 must clear")
assert(run(25, 9, symbol("SolNode801")) == false, "normal onslaught p25 i9 must clear")
-- The old addon's CALL index never matches the runtime identity.
assert(run(25, 10, symbol("SolNode802")) == true, "p25 i10 (CALL) must be ignored")

-- Checker fallback (p21 NAMECALL 324): only the two Onslaught nodes.
assert(run(21, 324, symbol("SolNode802")) == false, "elite onslaught p21 i324 must clear")
assert(run(21, 324, symbol("SolNode801")) == false, "normal onslaught p21 i324 must clear")
assert(run(21, 324, symbol("SolNode803")) == true, "other node p21 i324 must be unchanged")
assert(run(21, 324, symbol("SolNode80")) == true, "prefix node must be unchanged")
assert(run(21, 324, symbol("SolNode802_Hard")) == true, "suffixed node must be unchanged")
assert(run(21, 324, "SolNode802") == false, "plain string node name is accepted")
assert(run(21, 325, symbol("SolNode802")) == true, "p21 i325 (CALL) must be ignored")
do
    local mission = { maxSuitReq = true }
    after(21, 324, nil, { mission })
    assert(mission.maxSuitReq == true, "missing arguments must be unchanged")
end

-- Unrelated callsites in the same module.
assert(run(26, 3, symbol("SolNode973")) == true, "TryLaunchFrameFighter p26 i3 must be unchanged")
assert(run(26, 3, symbol("SolNode802")) == true, "p26 must be unchanged even for an onslaught node")
assert(run(24, 9, symbol("SolNode802")) == true, "wrong prototype must be unchanged")

-- Malformed results never raise.
after(25, 9, { starChart }, nil)
after(25, 9, { starChart }, {})
after(21, 324, { starChart, symbol("SolNode802") }, { nil })

addon.cleanup()
assert(run(25, 9, symbol("SolNode802")) == true, "cleanup must disable the mutation")
assert(run(21, 324, symbol("SolNode802")) == true, "cleanup must disable the fallback mutation")

print("PASS contract p25/i9 + p21/i324(SolNode801|SolNode802) -> maxSuitReq=false; all else unchanged")
