-- Sanctuary Onslaught: remove only the Warframe-rank requirement.
--
-- Target: /Lotus/Interface/MissionRequirementUtilities.lua, 44.0.2 body key 64d11e6973afa4b1.
-- The stock requirement checker (prototype 21) returns
-- /Lotus/Language/Menu/MissionMaxSuitRequired when mission.maxSuitReq is set and the
-- equipped Warframe is below its level cap (without MR 30 plus Forma). This addon clears
-- that game-owned field on the mission descriptor right after the engine builds it, so the
-- stock checker and launch flow stay authoritative.
--
-- The runtime reports a native call at its NAMECALL instruction (U44 logical index),
-- not at the CALL that follows it. There are two exact callsites:
--   p25 i9   TryLaunchOnslaught: StarChart:BuildMissionForLocation(SolNode801 or SolNode802).
--            Prototype 25 only ever builds the two Onslaught nodes, so no node test is needed.
--   p21 i324 The checker's own fallback build when its caller passed no mission
--            (star-chart confirm, squad pending-mission re-check). Every node goes through
--            this callsite, so it is filtered to the two Onslaught nodes.
-- Every other callsite, including TryLaunchFrameFighter (p26 i3), is left untouched.

local active = false

local function isOnslaughtNode(node)
    local name = tostring(node)
    return name == "SolNode801" or name == "SolNode802"
end

local function isOnslaughtBuild(prototype, instruction, arguments)
    if prototype == 25 and instruction == 9 then
        return true
    end
    if prototype == 21 and instruction == 324 then
        if type(arguments) ~= "table" then return false end
        return isOnslaughtNode(arguments[2])
    end
    return false
end

local function afterBuildMissionForLocation(prototype, instruction, arguments, results)
    if not active then return end
    if not isOnslaughtBuild(prototype, instruction, arguments) then return end
    if type(results) ~= "table" then return end

    local mission = results[1]
    if IsNull(mission) then return end
    mission.maxSuitReq = false
end

return {
    activate = function()
        active = true
    end,
    cleanup = function()
        active = false
    end,
    hooks = {
        nativeCalls = {
            BuildMissionForLocation = {
                after = afterBuildMissionForLocation,
            },
        },
    },
}
