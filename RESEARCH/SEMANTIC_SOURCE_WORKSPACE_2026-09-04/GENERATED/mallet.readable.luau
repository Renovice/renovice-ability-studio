-- RENOVICE_HASH_GLOBAL: musicBoxType
-- RENOVICE_HASH_GLOBAL: projectileType
-- RENOVICE_HASH_FIELD: AttachToMover
-- RENOVICE_HASH_FIELD: FormatNumber
-- RENOVICE_HASH_FIELD: GetAbilityStats
-- RENOVICE_HASH_FIELD: GetUniqueAbilityId
-- RENOVICE_HASH_FIELD: IsFightingGame
-- RENOVICE_HASH_FIELD: IsPvpEnabled
-- RENOVICE_HASH_FIELD: IsValidMover
-- RENOVICE_HASH_FIELD: PlayAnimAndSuspendUntilEvent
-- RENOVICE_HASH_FIELD: PlayUpperBodyAnimAndSuspendUntilEvent
-- RENOVICE_HASH_FIELD: SetAbilityStats
-- RENOVICE_HASH_FIELD: SyncSequencer
-- RENOVICE_READABLE_VIEW_V1
-- Identifier aliases are evidence-backed presentation only. Use the fidelity twin and TSV sidecar for exact provenance.
local v21_0
local v21_1
local require2
local v21_3
local v21_4
local require3
local v21_6
local v21_7
local require4
local v21_9
local v21_10
local require5
local v21_12
local v21_13
local v21_14
local v21_15
local v21_16
local v21_17
local symbol
local v21_19
local v21_20
local symbol2
local tableValue
local v21_23
local v21_24
local symbol3
local v21_26
local v21_27
local symbol4
local v21_29
local v21_30
local symbol5
local v21_32
local v21_33
local symbol6
local symbol7
local symbol8
local symbol9
local symbol10
local symbol11
local v21_40
local v21_41
local symbol12
local v21_43
local v21_44
local symbol13
local v21_46
local v21_47
local v21_48
local v21_49
local getAbilityUpgradeLevelInfoFunction
local getAugmentDescriptionInfoFunction
local evalBusyLoopFunction
local evaluateAbilityFunction
local npcEvaluateAbilityFunction
local initializeAbilityFunction
local v21_56
local activateAbilityFunction
local deactivateAbilityFunction
local projectileStoppedFunction
local projectileContactFunction
local spawnBoxFunction
local v21_62
local boxLoopFunction
local spawnSequencerFunction
local setThreatLevelFunction
local giveFightingUpgradesFunction
local removeFightingUpgradesFunction
v21_0 = require
require2 = v21_0("Lotus.Powersuits.PowersuitAbilities.PVPLib")
v21_3 = require
require3 = v21_3("Lotus.Scripts.Libs.AbilitiesLib")
v21_6 = require
require4 = v21_6("Lotus.Interface.SequencerUtilities")
v21_9 = require
require5 = v21_9("EE.Interface.Utilities")
v21_12 = 5
v21_13 = 5
v21_14 = 15
v21_15 = 0.3
v21_16 = Symbol
symbol = v21_16("extrudeLength")
v21_19 = Symbol
symbol2 = v21_19("UnlitAtten")
tableValue = {}
v21_23 = Symbol
symbol3 = v21_23("waveOne")
v21_26 = Symbol
symbol4 = v21_26("waveTwo")
v21_29 = Symbol
symbol5 = v21_29("waveThree")
v21_32 = Symbol
do
    local setlist_values_21_36 = table.pack(v21_32("waveFour"))
    tableValue[1] = symbol3
    tableValue[2] = symbol4
    tableValue[3] = symbol5
    for setlist_index_21_36 = 1, setlist_values_21_36.n do
        tableValue[4 + setlist_index_21_36 - 1] = setlist_values_21_36[setlist_index_21_36]
    end
end
v21_40 = Symbol
symbol12 = v21_40("uvOffset")
v21_43 = Symbol
symbol13 = v21_43("extrudeScales")
local cap_21_43_0 = require2
v21_46 = function(p0_0)
    local v0_1
    local isPvpEnabledValue
    local isPvpEnabled
    local v0_4
    local v0_5
    local v0_6
    local v0_7
    local v0_8
    local v0_9
    local v0_10
    local v0_11
    local v0_12
    local v0_13
    local v0_14
    local v0_15
    local v0_16
    local isFightingGameValue
    local isFightingGame
    local v0_19
    local v0_20
    local v0_21
    local v0_22
    local v0_23
    local v0_24
    local v0_25
    local v0_26
    local v0_27
    local v0_28
    local v0_29
    local v0_30
    local v0_31
    local v0_32
    v0_1 = cap_21_43_0
    isPvpEnabledValue = (v0_1).IsPvpEnabled
    isPvpEnabled = isPvpEnabledValue()
    if isPvpEnabled then
        v0_16 = cap_21_43_0
        isFightingGameValue = (v0_16).IsFightingGame
        isFightingGame = isFightingGameValue()
        if not (isFightingGame) then
            if p0_0 ~= 1 then
                if p0_0 ~= 2 then
                    if p0_0 ~= 3 then
                        v21_12 = 0.1
                        v21_13 = 4
                        v21_14 = 20
                        return
                    else
                        v21_12 = 0.08
                        v21_13 = 3
                        v21_14 = 18
                        return
                    end
                else
                    v21_12 = 0.06
                    v21_13 = 2
                    v21_14 = 16
                    return
                end
            else
                v21_12 = 0.04
                v21_13 = 1
                v21_14 = 14
                return
            end
        else
            v21_13 = 4
            v21_14 = 6
            return
        end
    else
        if p0_0 ~= 1 then
            if p0_0 ~= 2 then
                if p0_0 ~= 3 then
                    v21_12 = 2.5
                    v21_13 = 10
                    v21_14 = 20
                    return
                else
                    v21_12 = 2
                    v21_13 = 8
                    v21_14 = 16
                    return
                end
            else
                v21_12 = 1.5
                v21_13 = 6
                v21_14 = 12
                return
            end
        else
            v21_12 = 1
            v21_13 = 5
            v21_14 = 8
            return
        end
    end
end
v21_47 = function(p1_0)
    local v1_1
    local v1_2
    local engineUpgradedValue
    local v1_4
    local v1_5
    local value
    local v1_7
    local isNull
    local v1_9
    local v1_10
    local inventoryControl
    local v1_12
    local v1_13
    local powerSuit
    local value2
    local v1_16
    local isNull2
    local value3
    local selector
    local v1_20
    local v1_21
    local suit_type
    local suit
    local v1_24
    local v1_25
    local v1_26
    local v1_27
    local v1_28
    local v1_29
    local resourceType
    local v1_31
    local v1_32
    local v1_33
    local numberOrUpgradedValue
    local v1_35
    local v1_36
    local v1_37
    local v1_38
    local resourceType2
    local v1_40
    local v1_41
    local v1_42
    local numberOrUpgradedValue2
    v1_1 = Engine.UpgradedValue
    v1_2 = v21_12
    engineUpgradedValue = v1_1(v1_2)
    v1_4 = v21_13
    v1_5 = v21_14
    value = avatar
    v1_7 = IsNull
    isNull = v1_7(value)
    if not (isNull) then
        inventoryControl = avatar:InventoryControl()
        powerSuit = inventoryControl:GetActivePowerSuit()
        value2 = powerSuit
        v1_16 = IsNull
        isNull2 = v1_16(value2)
        if not (isNull2) then
            value3 = engineUpgradedValue
            suit_type = powerSuit:GetType()
            suit = powerSuit
            inventoryControl:ModifyValue(value3, 10, suit_type, suit)
            v1_26 = v21_13
            resourceType = powerSuit:GetType()
            v1_31 = powerSuit
            numberOrUpgradedValue = inventoryControl:GetUpgradeModifiedValue(v1_26, 9, resourceType, v1_31)
            v1_4 = numberOrUpgradedValue
            v1_35 = v21_14
            resourceType2 = powerSuit:GetType()
            v1_40 = powerSuit
            numberOrUpgradedValue2 = inventoryControl:GetUpgradeModifiedValue(v1_35, 3, resourceType2, v1_40)
            v1_5 = numberOrUpgradedValue2
        end
    end
    return engineUpgradedValue, v1_4, v1_5
end
v21_48 = function(p2_0, p2_1)
    local frame_2 = {}
    local cfg_2 = 0
    while true do
        if cfg_2 == 0 then
            if p2_1 ~= 1 then
                cfg_2 = 8
            else
                cfg_2 = 1
            end
        elseif cfg_2 == 1 then
            if p2_0 ~= 1 then
                cfg_2 = 3
            else
                cfg_2 = 2
            end
        elseif cfg_2 == 2 then
            v21_15 = 0.35
            return
        elseif cfg_2 == 3 then
            if p2_0 ~= 2 then
                cfg_2 = 5
            else
                cfg_2 = 4
            end
        elseif cfg_2 == 4 then
            v21_15 = 0.5
            return
        elseif cfg_2 == 5 then
            if p2_0 ~= 3 then
                cfg_2 = 7
            else
                cfg_2 = 6
            end
        elseif cfg_2 == 6 then
            v21_15 = 0.65
            return
        elseif cfg_2 == 7 then
            v21_15 = 0.8
            cfg_2 = 8
        elseif cfg_2 == 8 then
            return
        else
            error("invalid control state")
        end
    end
end
v21_49 = function(p3_0)
    local avatar
    local value
    local v3_3
    local isNull
    local v3_5
    local v3_6
    local inventoryControl
    local v3_8
    local v3_9
    local powerSuit
    local value2
    local v3_12
    local isNull2
    local v3_14
    local v3_15
    local v3_16
    local v3_17
    local v3_18
    local v3_19
    local numAbilities
    local v3_21
    local v3_22
    local v3_23
    local abilityAugmentLevel
    local v3_25
    local v3_26
    local v3_27
    local v3_28
    local resourceTypeOrNumber
    local v3_30
    local v3_31
    local v3_32
    local v3_33
    local v3_34
    local v3_35
    local v3_36
    local v3_37
    local v3_38
    local v3_39
    local v3_40
    local v3_41
    local v3_42
    local mathFloor
    local v3_44
    local v3_45
    avatar = _T.AbilityLevelQueryParms.Avatar
    value = avatar
    v3_3 = IsNull
    isNull = v3_3(value)
    if not (isNull) then
        inventoryControl = avatar:InventoryControl()
        powerSuit = inventoryControl:GetActivePowerSuit()
        value2 = powerSuit
        v3_12 = IsNull
        isNull2 = v3_12(value2)
        if not (isNull2) then
            v3_14 = _T.AbilityLevelQueryParms.Ability
            v3_17 = powerSuit:Name__b1572999(v3_14)
            numAbilities = powerSuit:GetNumAbilities()
            if not (numAbilities <= v3_17) then
                v3_21 = v3_17
                abilityAugmentLevel = powerSuit:GetAbilityAugmentLevel(v3_21)
                if not (abilityAugmentLevel <= 0) then
                    v3_26 = v3_17
                    resourceTypeOrNumber = powerSuit:GetAbilityAugmentType(v3_26)
                    if not (resourceTypeOrNumber ~= 1) then
                        if abilityAugmentLevel ~= 1 then
                            if abilityAugmentLevel ~= 2 then
                                if abilityAugmentLevel ~= 3 then
                                    v21_15 = 0.8
                                else
                                    v21_15 = 0.65
                                end
                            else
                                v21_15 = 0.5
                            end
                        else
                            v21_15 = 0.35
                        end
                    end
                    if not (resourceTypeOrNumber ~= 1) then
                        v3_36 = { Label = "/Lotus/Language/Suits/BardMusicAbilityAugment1Name", Title = true }
                        v3_37 = p3_0
                        v3_38 = table.insert
                        v3_38(v3_37, v3_36)
                        v3_39 = { Label = "/Lotus/Language/Game/ABILITY_RADIUS", Value = nil, ValueUnit = "/Lotus/Language/Game/UNIT_PERCENT" }
                        v3_40 = v21_15
                        v3_41 = (v3_40 * 100)
                        v3_42 = math.floor
                        mathFloor = v3_42(v3_41)
                        v3_39.Value = mathFloor
                        v3_44 = p3_0
                        v3_45 = table.insert
                        v3_45(v3_44, v3_39)
                    end
                    return
                else
                    return
                end
            else
                return
            end
        else
            return
        end
    else
        return
    end
end
local cap_21_56_0 = v21_46
local cap_21_56_4 = v21_47
local cap_21_56_6 = v21_49
getAbilityUpgradeLevelInfoFunction = function()
    local v4_0
    local v4_1
    local v4_2
    local v4_3
    local v4_4
    local v4_5
    local v4_6
    local v4_7
    local v4_8
    local upgradedValue
    local v4_10
    local v4_11
    local modifiedValue
    local value
    local v4_14
    local isNull
    local value2
    local v4_17
    local isNull2
    local avatar
    local v4_20
    local v4_21
    local inventoryControl
    local v4_23
    local v4_24
    local powerSuit
    local value3
    local v4_27
    local isNull3
    local v4_29
    local v4_30
    local v4_31
    local v4_32
    local v4_33
    local v4_34
    local v4_35
    local abilityAugmentLevel
    local v4_37
    local v4_38
    local v4_39
    local resourceTypeOrNumber
    local v4_41
    local v4_42
    local v4_43
    local v4_44
    local v4_45
    local v4_46
    local v4_47
    local v4_48
    local v4_49
    local v4_50
    local tableValue
    local v4_52
    local v4_53
    local v4_54
    local v4_55
    local v4_56
    local v4_57
    local v4_58
    local v4_59
    local v4_60
    local v4_61
    local v4_62
    local v4_63
    local v4_64
    local v4_65
    local v4_66
    local sharedState
    v4_0 = _T.AbilityLevelQueryParms.Level
    v4_1 = cap_21_56_0
    v4_2 = v4_0
    v4_1(v4_2)
    v4_3 = _T.AbilityLevelQueryParms.Modded
    if not (v4_3 ~= true) then
        v4_4 = cap_21_56_4
        v4_5 = _T.AbilityLevelQueryParms.Avatar
        v4_6, v4_7, v4_8 = v4_4(v4_5)
        v21_12 = v4_6
        v21_13 = v4_7
        v21_14 = v4_8
        upgradedValue = v21_12
        modifiedValue = upgradedValue:GetModifiedValue()
        v21_12 = modifiedValue
        value = _T.AbilityLevelQueryParms.Avatar
        v4_14 = IsNull
        isNull = v4_14(value)
        if not (isNull) then
            value2 = _T.AbilityLevelQueryParms.Ability
            v4_17 = IsNull
            isNull2 = v4_17(value2)
            if not (isNull2) then
                avatar = _T.AbilityLevelQueryParms.Avatar
                inventoryControl = avatar:InventoryControl()
                powerSuit = inventoryControl:GetActivePowerSuit()
                value3 = powerSuit
                v4_27 = IsNull
                isNull3 = v4_27(value3)
                if not (isNull3) then
                    v4_29 = _T.AbilityLevelQueryParms.Ability
                    v4_32 = powerSuit:Name__b1572999(v4_29)
                    v4_33 = v4_32
                    abilityAugmentLevel = powerSuit:GetAbilityAugmentLevel(v4_33)
                    v4_37 = v4_32
                    resourceTypeOrNumber = powerSuit:GetAbilityAugmentType(v4_37)
                    if 0 < abilityAugmentLevel then
                        if not (resourceTypeOrNumber ~= 1) then
                            if not (resourceTypeOrNumber ~= 1) then
                                if abilityAugmentLevel ~= 1 then
                                    if abilityAugmentLevel ~= 2 then
                                        if abilityAugmentLevel ~= 3 then
                                            v21_15 = 0.8
                                        else
                                            v21_15 = 0.65
                                        end
                                    else
                                        v21_15 = 0.5
                                    end
                                else
                                    v21_15 = 0.35
                                end
                            end
                            v4_48 = v21_13
                            v4_49 = v21_15
                            v4_50 = (v4_48 * v4_49)
                            v21_13 = v4_50
                        end
                    end
                end
            end
        end
    end
    tableValue = {}
    v4_52 = { Label = "/Lotus/Language/Game/DAMAGE_MULTIPLIER", Value = nil, ValueIcon = "<DT_EXPLOSION>", ValueUnit = "/Lotus/Language/Game/UNIT_MULTIPLIER" }
    v4_53 = v21_12
    v4_52.Value = v4_53
    v4_54 = tableValue
    v4_55 = table.insert
    v4_55(v4_54, v4_52)
    v4_56 = { Label = "/Lotus/Language/Game/ABILITY_RADIUS", Value = nil, ValueUnit = "/Lotus/Language/Game/UNIT_METER" }
    v4_57 = v21_13
    v4_56.Value = v4_57
    v4_58 = tableValue
    v4_59 = table.insert
    v4_59(v4_58, v4_56)
    v4_60 = { Label = "/Lotus/Language/Game/ABILITY_DURATION", Value = nil, ValueUnit = "/Lotus/Language/Game/UNIT_SECOND" }
    v4_61 = v21_14
    v4_60.Value = v4_61
    v4_62 = tableValue
    v4_63 = table.insert
    v4_63(v4_62, v4_60)
    v4_64 = cap_21_56_6
    v4_65 = tableValue
    v4_64(v4_65)
    v4_66 = _T.AbilityLevelQueryParms.Modded
    tableValue.Modded = v4_66
    sharedState = _T
    sharedState.AbilityUpgradeLevelInfo = tableValue
    return
end
GetAbilityUpgradeLevelInfo = getAbilityUpgradeLevelInfoFunction
local cap_21_65_1 = require5
getAugmentDescriptionInfoFunction = function(p5_0, p5_1)
    local tableValue
    local v5_3
    local v5_4
    local v5_5
    local v5_6
    local v5_7
    local v5_8
    local v5_9
    local v5_10
    local formatNumberValue
    local v5_12
    local v5_13
    local v5_14
    local v5_15
    local formatNumber
    local v5_17
    local v5_18
    local cjsonEncode
    local cjsonEncode2
    local cjsonEncode3
    local cjsonEncode4
    local cjsonEncode5
    tableValue = {}
    if not (p5_1 ~= 1) then
        if p5_0 ~= 1 then
            if p5_0 ~= 2 then
                if p5_0 ~= 3 then
                    v21_15 = 0.8
                else
                    v21_15 = 0.65
                end
            else
                v21_15 = 0.5
            end
        else
            v21_15 = 0.35
        end
    end
    if not (p5_1 ~= 1) then
        v5_9 = { RANGE = nil }
        v5_10 = cap_21_65_1
        formatNumberValue = (v5_10).FormatNumber
        v5_12 = v21_15
        v5_13 = (1 - v5_12)
        v5_14 = (v5_13 * 100)
        formatNumber = formatNumberValue(v5_14, 0)
        v5_9.RANGE = formatNumber
        tableValue = v5_9
    end
    v5_17 = cjson.encode
    v5_18 = tableValue
    return v5_17(v5_18)
end
GetAugmentDescriptionInfo = getAugmentDescriptionInfoFunction
evalBusyLoopFunction = function(p6_0)
    local frame_6 = {}
    local cfg_6 = 0
    while true do
        if cfg_6 == 0 then
            frame_6[3] = p6_0:DamageControl()
            cfg_6 = 1
        elseif cfg_6 == 1 then
            frame_6[4] = mOwner
            frame_6[7] = (frame_6[4]):IsEvaluating()
            if not (frame_6[7]) then
                cfg_6 = 10
            else
                cfg_6 = 2
            end
        elseif cfg_6 == 2 then
            frame_6[10] = p6_0:IsKilled()
            if frame_6[10] then
                cfg_6 = 10
            else
                cfg_6 = 3
            end
        elseif cfg_6 == 3 then
            frame_6[13] = (frame_6[3]):IsPreDeath()
            if frame_6[13] then
                cfg_6 = 10
            else
                cfg_6 = 4
            end
        elseif cfg_6 == 4 then
            frame_6[14] = false
            frame_6[16] = animsToWaitFor
            local leave_for_6_7 = false
            for for_value_6_7_0, for_value_6_7_1 in ipairs(frame_6[16]) do
                frame_6[24], frame_6[25] = for_value_6_7_0, for_value_6_7_1
                cfg_6 = 5
                while true do
                    if cfg_6 == 5 then
                        frame_6[20] = frame_6[25]
                        frame_6[23] = p6_0:IsPlayingAnimation(frame_6[20])
                        if not (frame_6[23]) then
                            cfg_6 = 7
                        else
                            cfg_6 = 6
                        end
                    elseif cfg_6 == 6 then
                        frame_6[14] = true
                        cfg_6 = 8
                        leave_for_6_7 = true
                        break
                    elseif cfg_6 == 7 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_6_7 then break end
            end
            if not leave_for_6_7 then
                cfg_6 = 8
            end
        elseif cfg_6 == 8 then
            if not (frame_6[14]) then
                cfg_6 = 10
            else
                cfg_6 = 9
            end
        elseif cfg_6 == 9 then
            frame_6[26] = Sleep
            frame_6[26](0)
            cfg_6 = 1
        elseif cfg_6 == 10 then
            return
        else
            error("invalid control state")
        end
    end
end
EvalBusyLoop = evalBusyLoopFunction
evaluateAbilityFunction = function(p7_0, p7_1)
    local v7_2
    local v7_3
    local symbol
    local v7_5
    local v7_6
    local v7_7
    local v7_8
    local v7_9
    local isKilled
    local v7_11
    local v7_12
    local v7_13
    local isPreDeath
    v7_2 = Symbol
    symbol = v7_2("EvalBusyLoop")
    avatarOrEntity:Name__a50e34c3(symbol, true)
    isKilled = avatarOrEntity:IsKilled()
    v7_11 = (not isKilled)
    if v7_11 then
        isPreDeath = avatarOrEntity:IsPreDeath()
        v7_11 = (not isPreDeath)
    end
    return v7_11
end
EvaluateAbility = evaluateAbilityFunction
npcEvaluateAbilityFunction = function(p8_0, p8_1)
    local v8_2
    local v8_3
    local agent
    local v8_5
    local v8_6
    local entity
    local visibleValue
    local value
    local v8_10
    local isNull
    local avatarOrEntity
    local v8_13
    local v8_14
    local isPreDeath
    local distanceToTargetValue
    local v8_17
    local distanceToTargetValue2
    local v8_19
    local avatarValue
    local v8_21
    local v8_22
    local v8_23
    local v8_24
    agent = agentOrEntity:GetAgent()
    entity = agent:GetTarget()
    visibleValue = (entity).visible
    if visibleValue then
        value = (entity).avatar
        v8_10 = IsNull
        isNull = v8_10(value)
        if isNull then
        else
            avatarOrEntity = (entity).avatar
            isPreDeath = avatarOrEntity:IsPreDeath()
            if isPreDeath then
            else
                distanceToTargetValue = (entity).distanceToTarget
                if not (1 <= distanceToTargetValue) then
                else
                    distanceToTargetValue2 = (entity).distanceToTarget
                    if not (distanceToTargetValue2 < 10) then
                    else
                        avatarValue = (entity).avatar
                        p8_0:Name__5b724fe7(avatarValue)
                        return 1
                    end
                end
            end
        end
    end
    return 0
end
NpcEvaluateAbility = npcEvaluateAbilityFunction
local cap_21_75_0 = require2
initializeAbilityFunction = function(p9_0, p9_1)
    local v9_2
    local isFightingGameValue
    local isFightingGame
    local ownerReference
    local v9_6
    local v9_7
    local v9_8
    local v9_9
    local v9_10
    local v9_11
    local v9_12
    v9_2 = cap_21_75_0
    isFightingGameValue = (v9_2).IsFightingGame
    isFightingGame = isFightingGameValue()
    if isFightingGame then
        ownerReference = mOwner
        v9_6 = gGameRules
        ownerReference:Name__fd3aedec(v9_6:Name__7194a234())
    end
    return
end
InitializeAbility = initializeAbilityFunction
local cap_21_78_0 = require3
v21_56 = function(p10_0)
    local frame_10 = {}
    local cfg_10 = 0
    while true do
        if cfg_10 == 0 then
            frame_10[3] = p10_0:GetInstigator()
            frame_10[4] = frame_10[3]
            frame_10[5] = IsNull
            frame_10[6] = frame_10[5](frame_10[4])
            if frame_10[6] then
                cfg_10 = 10
            else
                cfg_10 = 1
            end
        elseif cfg_10 == 1 then
            frame_10[9] = (frame_10[3]):IsKilled()
            if frame_10[9] then
                cfg_10 = 10
            else
                cfg_10 = 2
            end
        elseif cfg_10 == 2 then
            frame_10[12] = (frame_10[3]):ReplicaLocallyAuthoritative()
            if frame_10[12] then
                cfg_10 = 5
            else
                cfg_10 = 3
            end
        elseif cfg_10 == 3 then
            frame_10[13] = gRegion
            frame_10[16] = (frame_10[13]):IsMaster()
            if not (frame_10[16]) then
                cfg_10 = 10
            else
                cfg_10 = 4
            end
        elseif cfg_10 == 4 then
            frame_10[19] = (frame_10[3]):IsHumanPlayer()
            if frame_10[19] then
                cfg_10 = 10
            else
                cfg_10 = 5
            end
        elseif cfg_10 == 5 then
            frame_10[22] = (frame_10[3]):InventoryControl()
            frame_10[25] = (frame_10[22]):GetActivePowerSuit()
            frame_10[26] = frame_10[25]
            frame_10[27] = IsNull
            frame_10[28] = frame_10[27](frame_10[26])
            if frame_10[28] then
                cfg_10 = 10
            else
                cfg_10 = 6
            end
        elseif cfg_10 == 6 then
            frame_10[32] = (frame_10[25]):GetAbilityByIndex(0)
            frame_10[33] = cap_21_78_0
            frame_10[34] = (frame_10[33]).GetAbilityStats
            frame_10[35] = frame_10[25]
            frame_10[36] = frame_10[32]
            frame_10[37] = frame_10[34](frame_10[35], frame_10[36])
            frame_10[38] = frame_10[37]
            frame_10[39] = IsNull
            frame_10[40] = frame_10[39](frame_10[38])
            if frame_10[40] then
                cfg_10 = 10
            else
                cfg_10 = 7
            end
        elseif cfg_10 == 7 then
            frame_10[41] = (frame_10[37]).projectile
            if frame_10[41] == p10_0 then
                cfg_10 = 9
            else
                cfg_10 = 8
            end
        elseif cfg_10 == 8 then
            frame_10[42] = (frame_10[37]).secondProjectile
            if frame_10[42] ~= p10_0 then
                cfg_10 = 10
            else
                cfg_10 = 9
            end
        elseif cfg_10 == 9 then
            frame_10[43] = Lotus_Game.SecondaryScriptArgs
            frame_10[45] = frame_10[43](true)
            do (frame_10[45]):PushVector3Arg(p10_0:GetPosition()) end
            frame_10[53] = AngleToDirection
            do (frame_10[45]):PushVector3Arg(frame_10[53](p10_0:GetRotation())) end
            frame_10[63] = (frame_10[37]).damageMult
            do (frame_10[45]):Name__35ebc6c5(frame_10[63]) end
            frame_10[66] = (frame_10[37]).radius
            do (frame_10[45]):PushFloatArg(frame_10[66]) end
            frame_10[69] = (frame_10[37]).duration
            do (frame_10[45]):PushFloatArg(frame_10[69]) end
            frame_10[72] = frame_10[32]
            frame_10[73] = Symbol
            frame_10[75] = frame_10[73]("SpawnBox")
            frame_10[76] = frame_10[45]
            do (frame_10[25]):ActivateSecondaryScriptEx(frame_10[72], frame_10[75], frame_10[76]) end
            cfg_10 = 10
        elseif cfg_10 == 10 then
            p10_0:Destroy()
            return
        else
            error("invalid control state")
        end
    end
end
local cap_21_80_0 = v21_46
local cap_21_80_1 = v21_47
local cap_21_80_3 = require3
local cap_21_80_4 = require2
local cap_21_80_5 = v21_56
activateAbilityFunction = function(p11_0, p11_1, p11_2, p11_3)
    local frame_11 = {}
    local cfg_11 = 0
    while true do
        if cfg_11 == 0 then
            frame_11[4] = cap_21_80_0
            frame_11[5] = p11_3
            frame_11[4](frame_11[5])
            frame_11[6] = cap_21_80_1
            frame_11[7] = p11_1
            frame_11[8], frame_11[9], frame_11[10] = frame_11[6](frame_11[7])
            frame_11[13] = p11_0:GetAbilityAugmentLevel()
            frame_11[16] = p11_0:GetAbilityAugmentType()
            frame_11[17] = false
            if not (0 < frame_11[13]) then
                cfg_11 = 4
            else
                cfg_11 = 1
            end
        elseif cfg_11 == 1 then
            if frame_11[16] == 1 then
                cfg_11 = 3
            else
                cfg_11 = 2
            end
        elseif cfg_11 == 2 then
            frame_11[17] = false
            cfg_11 = 4
        elseif cfg_11 == 3 then
            frame_11[17] = true
            cfg_11 = 4
        elseif cfg_11 == 4 then
            if not (frame_11[17]) then
                cfg_11 = 14
            else
                cfg_11 = 5
            end
        elseif cfg_11 == 5 then
            if frame_11[16] ~= 1 then
                cfg_11 = 13
            else
                cfg_11 = 6
            end
        elseif cfg_11 == 6 then
            if frame_11[13] ~= 1 then
                cfg_11 = 8
            else
                cfg_11 = 7
            end
        elseif cfg_11 == 7 then
            v21_15 = 0.35
            cfg_11 = 13
        elseif cfg_11 == 8 then
            if frame_11[13] ~= 2 then
                cfg_11 = 10
            else
                cfg_11 = 9
            end
        elseif cfg_11 == 9 then
            v21_15 = 0.5
            cfg_11 = 13
        elseif cfg_11 == 10 then
            if frame_11[13] ~= 3 then
                cfg_11 = 12
            else
                cfg_11 = 11
            end
        elseif cfg_11 == 11 then
            v21_15 = 0.65
            cfg_11 = 13
        elseif cfg_11 == 12 then
            v21_15 = 0.8
            cfg_11 = 13
        elseif cfg_11 == 13 then
            frame_11[25] = v21_15
            frame_11[9] = (frame_11[9] * frame_11[25])
            cfg_11 = 14
        elseif cfg_11 == 14 then
            frame_11[28] = p11_1:InventoryControl()
            do (frame_11[28]):EnableWeaponFiring(false) end
            do (frame_11[28]):StopWeapons() end
            do (frame_11[28]):SetItemVisibility(0, 2) end
            frame_11[40] = p11_1:ReplicaLocallyAuthoritative()
            if not (frame_11[40]) then
                cfg_11 = 16
            else
                cfg_11 = 15
            end
        elseif cfg_11 == 15 then
            frame_11[41] = inputFilter
            p11_1:PushInputFilter(frame_11[41])
            cfg_11 = 16
        elseif cfg_11 == 16 then
            p11_0:ToggleCastTrails(true)
            frame_11[47] = castEffect
            frame_11[48] = Symbol
            frame_11[50] = frame_11[48]("GAME_R1_WEAPON1")
            frame_11[51] = ZERO_VECTOR
            frame_11[52] = ZERO_ROTATION
            frame_11[53] = p11_0
            p11_1:Attach(frame_11[47], frame_11[50], frame_11[51], frame_11[52], frame_11[53])
            frame_11[58] = p11_1:IsFalling()
            if not (frame_11[58]) then
                cfg_11 = 18
            else
                cfg_11 = 17
            end
        elseif cfg_11 == 17 then
            frame_11[59] = cap_21_80_3
            frame_11[60] = (frame_11[59]).PlayAnimAndSuspendUntilEvent
            frame_11[61] = p11_0
            frame_11[62] = activateAnim
            frame_11[60](frame_11[61], frame_11[62], "MusicCast", false, 2, 1, false)
            cfg_11 = 19
        elseif cfg_11 == 18 then
            frame_11[68] = cap_21_80_3
            frame_11[69] = (frame_11[68]).PlayUpperBodyAnimAndSuspendUntilEvent
            frame_11[70] = p11_0
            frame_11[71] = activateAnim
            frame_11[69](frame_11[70], frame_11[71], "MusicCast", false, 2, 1, false)
            cfg_11 = 19
        elseif cfg_11 == 19 then
            p11_0:ToggleCastTrails(false)
            frame_11[82] = p11_1:ReplicaLocallyAuthoritative()
            if not (frame_11[82]) then
                cfg_11 = 21
            else
                cfg_11 = 20
            end
        elseif cfg_11 == 20 then
            frame_11[83] = inputFilter
            p11_1:PopInputFilter(frame_11[83])
            cfg_11 = 21
        elseif cfg_11 == 21 then
            frame_11[88] = p11_1:InventoryControl()
            frame_11[91] = (frame_11[88]):GetAimEndPoint()
            frame_11[92] = Symbol
            frame_11[103] = p11_1:GetBonePosition(frame_11[92]("GAME_R1_WEAPON1"))
            frame_11[104] = LookTo
            frame_11[105] = frame_11[103]
            frame_11[106] = frame_11[91]
            frame_11[107] = frame_11[104](frame_11[105], frame_11[106])
            frame_11[108] = Dot
            frame_11[109] = (frame_11[91] - frame_11[103])
            frame_11[110] = AngleToDirection
            frame_11[122] = frame_11[108](frame_11[109], frame_11[110](p11_1:GetCameraView()))
            if not (frame_11[122]) then
                cfg_11 = 23
            else
                cfg_11 = 22
            end
        elseif cfg_11 == 22 then
            frame_11[125] = p11_1:GetCameraView()
            frame_11[107] = frame_11[125]
            cfg_11 = 23
        elseif cfg_11 == 23 then
            frame_11[126] = cap_21_80_4
            frame_11[127] = (frame_11[126]).IsFightingGame
            frame_11[128] = frame_11[127]()
            if not (frame_11[128]) then
                cfg_11 = 25
            else
                cfg_11 = 24
            end
        elseif cfg_11 == 24 then
            frame_11[129] = fightingProjectileType
            projectileType = frame_11[129]
            cfg_11 = 25
        elseif cfg_11 == 25 then
            frame_11[130] = gRegion
            frame_11[131] = projectileType
            frame_11[132] = frame_11[103]
            frame_11[133] = frame_11[107]
            frame_11[134] = p11_1
            frame_11[137] = (frame_11[130]):CreateEntity(frame_11[131], frame_11[132], frame_11[133], frame_11[134])
            frame_11[138] = frame_11[137]
            frame_11[139] = IsNull
            frame_11[140] = frame_11[139](frame_11[138])
            if frame_11[140] then
                cfg_11 = 30
            else
                cfg_11 = 26
            end
        elseif cfg_11 == 26 then
            frame_11[141] = p11_1
            do (frame_11[137]):SetInstigator(frame_11[141]) end
            frame_11[144] = p11_0
            do (frame_11[137]):SetInstigatorItem(frame_11[144]) end
            do (frame_11[137]):SetDamageMultiplier(0) end
            frame_11[150] = Symbol
            frame_11[158] = p11_0:GetResType(frame_11[150]("GrenadeOverride"))
            frame_11[159] = frame_11[158]
            frame_11[160] = IsNull
            frame_11[161] = frame_11[160](frame_11[159])
            if frame_11[161] then
                cfg_11 = 29
            else
                cfg_11 = 27
            end
        elseif cfg_11 == 27 then
            frame_11[162] = frame_11[158]
            do (frame_11[137]):SetMesh(frame_11[162], false, false) end
            frame_11[169] = (frame_11[158]):GetBoundsMax()
            frame_11[172] = (frame_11[158]):GetBoundsMin()
            frame_11[173] = (frame_11[169] - frame_11[172])
            frame_11[174] = Length
            frame_11[175] = frame_11[173]
            frame_11[176] = frame_11[174](frame_11[175])
            if not (1 < frame_11[176]) then
                cfg_11 = 29
            else
                cfg_11 = 28
            end
        elseif cfg_11 == 28 then
            do (frame_11[137]):SetMeshScale(0.25, true) end
            cfg_11 = 29
        elseif cfg_11 == 29 then
            frame_11[184] = p11_0:GetCustomization()
            do (frame_11[184]):ClearSkins() end
            frame_11[187] = frame_11[137]
            do (frame_11[184]):ApplyCustomization(frame_11[187]) end
            cfg_11 = 30
        elseif cfg_11 == 30 then
            frame_11[190] = cap_21_80_3
            frame_11[191] = (frame_11[190]).GetAbilityStats
            frame_11[192] = p11_0
            frame_11[193] = mOwner
            frame_11[194] = frame_11[191](frame_11[192], frame_11[193])
            frame_11[195] = frame_11[194]
            frame_11[196] = IsNull
            frame_11[197] = frame_11[196](frame_11[195])
            if not (frame_11[197]) then
                cfg_11 = 32
            else
                cfg_11 = 31
            end
        elseif cfg_11 == 31 then
            frame_11[194] = {}
            cfg_11 = 38
        elseif cfg_11 == 32 then
            frame_11[198] = (frame_11[194]).projectile
            frame_11[199] = IsNull
            frame_11[200] = frame_11[199](frame_11[198])
            if frame_11[200] then
                cfg_11 = 38
            else
                cfg_11 = 33
            end
        elseif cfg_11 == 33 then
            if not (frame_11[17]) then
                cfg_11 = 37
            else
                cfg_11 = 34
            end
        elseif cfg_11 == 34 then
            frame_11[201] = (frame_11[194]).secondProjectile
            frame_11[202] = IsNull
            frame_11[203] = frame_11[202](frame_11[201])
            if frame_11[203] then
                cfg_11 = 36
            else
                cfg_11 = 35
            end
        elseif cfg_11 == 35 then
            frame_11[204] = (frame_11[194]).secondProjectile
            do (frame_11[204]):Destroy() end
            cfg_11 = 36
        elseif cfg_11 == 36 then
            frame_11[207] = (frame_11[194]).projectile
            frame_11[194].secondProjectile = frame_11[207]
            cfg_11 = 38
        elseif cfg_11 == 37 then
            frame_11[208] = (frame_11[194]).projectile
            do (frame_11[208]):Destroy() end
            cfg_11 = 38
        elseif cfg_11 == 38 then
            frame_11[194].projectile = frame_11[137]
            frame_11[194].damageMult = frame_11[8]
            frame_11[194].radius = frame_11[9]
            frame_11[194].duration = frame_11[10]
            frame_11[194].augmentOne = frame_11[17]
            frame_11[211] = cap_21_80_3
            frame_11[212] = (frame_11[211]).SetAbilityStats
            frame_11[213] = p11_0
            frame_11[214] = mOwner
            frame_11[215] = frame_11[194]
            frame_11[212](frame_11[213], frame_11[214], frame_11[215])
            p11_0:Name__f3e85b73()
            do (frame_11[28]):SetItemVisibility(0, 2) end
            frame_11[222] = cap_21_80_4
            frame_11[223] = (frame_11[222]).IsFightingGame
            frame_11[224] = frame_11[223]()
            if not (frame_11[224]) then
                cfg_11 = 40
            else
                cfg_11 = 39
            end
        elseif cfg_11 == 39 then
            frame_11[225] = cap_21_80_5
            frame_11[226] = frame_11[137]
            frame_11[225](frame_11[226])
            cfg_11 = 40
        elseif cfg_11 == 40 then
            frame_11[227] = p11_1
            frame_11[228] = IsNull
            frame_11[229] = frame_11[228](frame_11[227])
            if frame_11[229] then
                cfg_11 = 43
            else
                cfg_11 = 41
            end
        elseif cfg_11 == 41 then
            frame_11[230] = activateAnim
            frame_11[233] = p11_1:IsPlayingAnimation(frame_11[230])
            if not (frame_11[233]) then
                cfg_11 = 43
            else
                cfg_11 = 42
            end
        elseif cfg_11 == 42 then
            frame_11[234] = Sleep
            frame_11[234](0)
            cfg_11 = 40
        elseif cfg_11 == 43 then
            frame_11[236] = Sleep
            frame_11[236](0.3)
            return
        else
            error("invalid control state")
        end
    end
end
ActivateAbility = activateAbilityFunction
deactivateAbilityFunction = function(p12_0, p12_1, p12_2, p12_3)
    local frame_12 = {}
    local cfg_12 = 0
    while true do
        if cfg_12 == 0 then
            frame_12[6] = p12_1:ReplicaLocallyAuthoritative()
            if not (frame_12[6]) then
                cfg_12 = 2
            else
                cfg_12 = 1
            end
        elseif cfg_12 == 1 then
            frame_12[7] = inputFilter
            p12_1:PopInputFilter(frame_12[7])
            cfg_12 = 2
        elseif cfg_12 == 2 then
            frame_12[10] = false
            frame_12[11] = 0
            frame_12[12] = 3
            frame_12[13] = 1
            local leave_for_12_3 = false
            for for_value_12_3 = frame_12[11], frame_12[12], frame_12[13] do
                frame_12[11] = for_value_12_3
                cfg_12 = 3
                while true do
                    if cfg_12 == 3 then
                        frame_12[14] = frame_12[11]
                        frame_12[17] = p12_0:GetAbilityByIndex(frame_12[14])
                        frame_12[18] = frame_12[17]
                        frame_12[19] = IsNull
                        frame_12[20] = frame_12[19](frame_12[18])
                        if frame_12[20] then
                            cfg_12 = 8
                        else
                            cfg_12 = 4
                        end
                    elseif cfg_12 == 4 then
                        frame_12[21] = mOwner
                        if frame_12[17] == frame_12[21] then
                            cfg_12 = 8
                        else
                            cfg_12 = 5
                        end
                    elseif cfg_12 == 5 then
                        frame_12[24] = (frame_12[17]):IsActive()
                        if not (frame_12[24]) then
                            cfg_12 = 8
                        else
                            cfg_12 = 6
                        end
                    elseif cfg_12 == 6 then
                        frame_12[27] = (frame_12[17]):IsAbilityOverride()
                        if frame_12[27] then
                            cfg_12 = 8
                        else
                            cfg_12 = 7
                        end
                    elseif cfg_12 == 7 then
                        frame_12[10] = true
                        cfg_12 = 9
                        leave_for_12_3 = true
                        break
                    elseif cfg_12 == 8 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_12_3 then break end
            end
            if not leave_for_12_3 then
                cfg_12 = 9
            end
        elseif cfg_12 == 9 then
            if frame_12[10] then
                cfg_12 = 11
            else
                cfg_12 = 10
            end
        elseif cfg_12 == 10 then
            frame_12[30] = p12_1:InventoryControl()
            do (frame_12[30]):EnableWeaponFiring(true) end
            do (frame_12[30]):SetItemVisibility(0, 0) end
            cfg_12 = 11
        elseif cfg_12 == 11 then
            return
        else
            error("invalid control state")
        end
    end
end
DeactivateAbility = deactivateAbilityFunction
local cap_21_90_0 = v21_56
projectileStoppedFunction = function(p13_0)
    local v13_1
    local v13_2
    v13_1 = cap_21_90_0
    v13_2 = p13_0
    v13_1(v13_2)
    return
end
ProjectileStopped = projectileStoppedFunction
local cap_21_93_0 = require3
projectileContactFunction = function(p14_0, p14_1)
    local v14_2
    local v14_3
    local v14_4
    local isA
    local v14_6
    local isValidMoverValue
    local v14_8
    local isValidMover
    local v14_10
    local v14_11
    v14_2 = gMoverType
    isA = engineObject:IsA(v14_2)
    if isA then
        v14_6 = cap_21_93_0
        isValidMoverValue = (v14_6).IsValidMover
        v14_8 = engineObject
        isValidMover = isValidMoverValue(v14_8)
        if isValidMover then
            p14_0:Stop()
        end
    end
    return
end
ProjectileContact = projectileContactFunction
local cap_21_96_0 = require2
local cap_21_96_1 = require3
spawnBoxFunction = function(p15_0, p15_1, p15_2, p15_3, p15_4, p15_5)
    local ownerReference
    local v15_7
    local v15_8
    local resourceType
    local v15_10
    local v15_11
    local v15_12
    local v15_13
    local v15_14
    local v15_15
    local zeroVector
    local v15_17
    local lookTo
    local v15_19
    local v15_20
    local avatarOwner
    local v15_22
    local v15_23
    local isFightingGameValue
    local isFightingGame
    local v15_26
    local v15_27
    local v15_28
    local v15_29
    local v15_30
    local vector
    local v15_32
    local v15_33
    local v15_34
    local v15_35
    local v15_36
    local vector2
    local region
    local v15_39
    local v15_40
    local v15_41
    local v15_42
    local v15_43
    local v15_44
    local entity
    local value
    local v15_47
    local isNull
    local ownerReference2
    local v15_50
    local v15_51
    local v15_52
    local region2
    local v15_54
    local v15_55
    local v15_56
    local v15_57
    local v15_58
    local v15_59
    local v15_60
    local attachToMoverValue
    local v15_62
    local v15_63
    local v15_64
    local v15_65
    local v15_66
    local vector3
    local v15_68
    local v15_69
    local v15_70
    local originalFaction
    local originalFaction2
    local originalFaction3
    local originalFaction4
    local originalFaction5
    local v15_76
    local v15_77
    local v15_78
    local v15_79
    local motionControl
    local v15_81
    local v15_82
    local v15_83
    local v15_84
    local v15_85
    local v15_86
    local v15_87
    local v15_88
    local v15_89
    local v15_90
    local v15_91
    local v15_92
    local v15_93
    local v15_94
    local v15_95
    local v15_96
    local v15_97
    local v15_98
    local v15_99
    local lotus_GameSecondaryScriptArgs
    local v15_101
    local v15_102
    local v15_103
    local v15_104
    local v15_105
    local v15_106
    local v15_107
    local v15_108
    local v15_109
    local v15_110
    local v15_111
    local v15_112
    local ownerReference3
    local v15_114
    local v15_115
    local symbol
    local v15_117
    local v15_118
    local v15_119
    ownerReference = mOwner
    resourceType = ownerReference:GetType()
    v15_10 = resourceType
    v15_13 = avatar:Name__9e0e48b9(v15_10)
    v15_14 = v15_13[1]
    v15_15 = LookTo
    zeroVector = ZERO_VECTOR
    v15_17 = p15_3
    lookTo = v15_15(zeroVector, v15_17)
    avatarOwner = avatar:GetAvatarOwner()
    v15_22 = p15_2
    v15_23 = cap_21_96_0
    isFightingGameValue = (v15_23).IsFightingGame
    isFightingGame = isFightingGameValue()
    if not (isFightingGame) then
        v15_33 = Vector
        vector2 = v15_33(0, 1, 0)
        v15_32 = (v15_22 + vector2)
    else
        v15_26 = fightingBoxType
        musicBoxType = v15_26
        v15_27 = Vector
        vector = v15_27(0, 0.7, 1)
        v15_32 = (v15_22 - vector)
    end
    region = gRegion
    v15_39 = musicBoxType
    v15_40 = v15_32
    v15_41 = lookTo
    v15_42 = avatarOwner
    entity = region:CreateEntity(v15_39, v15_40, v15_41, v15_42)
    value = entity
    v15_47 = IsNull
    isNull = v15_47(value)
    if not (isNull) then
        ownerReference2 = mOwner
        v15_50 = entity
        ownerReference2:AttachAbilityObject(v15_50)
        region2 = gRegion
        v15_54 = spawnEffect
        v15_55 = p15_2
        v15_56 = lookTo
        v15_57 = avatar
        region2:CreateEntity(v15_54, v15_55, v15_56, v15_57)
        v15_60 = cap_21_96_1
        attachToMoverValue = (v15_60).AttachToMover
        v15_62 = entity
        v15_63 = Vector
        vector3 = v15_63(0, 0.5, 0)
        v15_68 = (v15_32 + vector3)
        attachToMoverValue(v15_62, v15_68)
        entity:SetFaction(avatarOwner:GetOriginalFaction())
        motionControl = entity:MotionControl()
        v15_81 = lookTo
        motionControl:SetTorsoFromView(v15_81)
        v15_84 = lookTo
        entity:SetView(v15_84)
        entity:SetPostureModifier(27, true)
        v15_91 = avatarOwner
        entity:SetSpawnedByAvatar(v15_91)
        v15_94 = avatarOwner
        entity:Name__38c006f7(v15_94)
        v15_97 = Lotus_Game.SecondaryScriptArgs
        lotus_GameSecondaryScriptArgs = v15_97(true, true)
        v15_101 = entity
        lotus_GameSecondaryScriptArgs:PushObjectArg(v15_101)
        v15_104 = v15_14
        lotus_GameSecondaryScriptArgs:Name__35ebc6c5(v15_104)
        v15_107 = p15_4
        lotus_GameSecondaryScriptArgs:PushFloatArg(v15_107)
        v15_110 = p15_5
        lotus_GameSecondaryScriptArgs:PushFloatArg(v15_110)
        ownerReference3 = mOwner
        v15_114 = Symbol
        symbol = v15_114("SpawnSequencer")
        v15_117 = lotus_GameSecondaryScriptArgs
        avatar:ActivateSecondaryScriptEx(ownerReference3, symbol, v15_117)
        return
    else
        return
    end
end
SpawnBox = spawnBoxFunction
v21_62 = nil
local cap_21_101_1 = require3
local cap_21_101_3 = require2
local cap_21_101_5 = symbol
local cap_21_101_6 = symbol2
local cap_21_101_7 = tableValue
local cap_21_101_8 = symbol12
local cap_21_101_10 = symbol13
boxLoopFunction = function(p16_0)
    local frame_16 = {}
    local cfg_16 = 0
    while true do
        if cfg_16 == 0 then
            frame_16[3] = p16_0:GetCreator()
            frame_16[6] = (frame_16[3]):GetAvatarOwner()
            frame_16[9] = p16_0:GetPosition()
            frame_16[10] = v21_62
            frame_16[11] = cap_21_101_1
            frame_16[12] = (frame_16[11]).GetAbilityStats
            frame_16[13] = frame_16[3]
            frame_16[14] = mOwner
            frame_16[15] = frame_16[12](frame_16[13], frame_16[14])
            frame_16[16] = frame_16[15]
            frame_16[17] = IsNull
            frame_16[18] = frame_16[17](frame_16[16])
            if not (frame_16[18]) then
                cfg_16 = 2
            else
                cfg_16 = 1
            end
        elseif cfg_16 == 1 then
            frame_16[15] = {}
            cfg_16 = 2
        elseif cfg_16 == 2 then
            frame_16[19] = (frame_16[15]).augmentOne
            if not (frame_16[19]) then
                cfg_16 = 9
            else
                cfg_16 = 3
            end
        elseif cfg_16 == 3 then
            frame_16[20] = (frame_16[15]).secondSequencer
            frame_16[21] = IsNull
            frame_16[22] = frame_16[21](frame_16[20])
            if frame_16[22] then
                cfg_16 = 6
            else
                cfg_16 = 4
            end
        elseif cfg_16 == 4 then
            frame_16[23] = (frame_16[15]).secondSequencer
            frame_16[26] = p16_0:DistanceToEntity(frame_16[23])
            frame_16[27] = v21_13
            if not (frame_16[26] <= frame_16[27]) then
                cfg_16 = 6
            else
                cfg_16 = 5
            end
        elseif cfg_16 == 5 then
            frame_16[15].secondSequencer = nil
            cfg_16 = 6
        elseif cfg_16 == 6 then
            frame_16[29] = (frame_16[15]).sequencer
            frame_16[30] = IsNull
            frame_16[31] = frame_16[30](frame_16[29])
            if frame_16[31] then
                cfg_16 = 9
            else
                cfg_16 = 7
            end
        elseif cfg_16 == 7 then
            frame_16[32] = (frame_16[15]).sequencer
            frame_16[35] = p16_0:DistanceToEntity(frame_16[32])
            frame_16[36] = v21_13
            if not (frame_16[36] < frame_16[35]) then
                cfg_16 = 9
            else
                cfg_16 = 8
            end
        elseif cfg_16 == 8 then
            frame_16[37] = (frame_16[15]).sequencer
            frame_16[15].secondSequencer = frame_16[37]
            cfg_16 = 9
        elseif cfg_16 == 9 then
            frame_16[15].sequencer = p16_0
            frame_16[38] = cap_21_101_1
            frame_16[39] = (frame_16[38]).SetAbilityStats
            frame_16[40] = frame_16[3]
            frame_16[41] = mOwner
            frame_16[42] = frame_16[15]
            frame_16[39](frame_16[40], frame_16[41], frame_16[42])
            frame_16[43] = frame_16[10]
            do (frame_16[3]):ApplyEnergyColor(frame_16[43]) end
            frame_16[46] = attachEffect
            frame_16[47] = EMPTY_SYMBOL
            frame_16[48] = ZERO_VECTOR
            frame_16[49] = ZERO_ROTATION
            frame_16[50] = frame_16[3]
            do (frame_16[10]):Attach(frame_16[46], frame_16[47], frame_16[48], frame_16[49], frame_16[50]) end
            frame_16[53] = windEffect
            frame_16[54] = EMPTY_SYMBOL
            frame_16[55] = ZERO_VECTOR
            frame_16[56] = ZERO_ROTATION
            frame_16[57] = frame_16[3]
            frame_16[60] = (frame_16[10]):Attach(frame_16[53], frame_16[54], frame_16[55], frame_16[56], frame_16[57])
            frame_16[61] = nil
            frame_16[64] = (frame_16[6]):Layertrackers()
            if frame_16[64] then
                cfg_16 = 13
            else
                cfg_16 = 10
            end
        elseif cfg_16 == 10 then
            frame_16[65] = gRegion
            frame_16[68] = (frame_16[65]):IsMaster()
            if not (frame_16[68]) then
                cfg_16 = 12
            else
                cfg_16 = 11
            end
        elseif cfg_16 == 11 then
            frame_16[71] = (frame_16[6]):IsHumanPlayer()
            if not (frame_16[71]) then
                cfg_16 = 13
            else
                cfg_16 = 12
            end
        elseif cfg_16 == 12 then
            frame_16[72] = cap_21_101_3
            frame_16[73] = (frame_16[72]).IsPvpEnabled
            frame_16[74] = frame_16[73]()
            if not (frame_16[74]) then
                cfg_16 = 14
            else
                cfg_16 = 13
            end
        elseif cfg_16 == 13 then
            frame_16[75] = rangeDeco
            frame_16[76] = EMPTY_SYMBOL
            frame_16[77] = ZERO_VECTOR
            frame_16[78] = ZERO_ROTATION
            frame_16[79] = frame_16[3]
            frame_16[82] = (frame_16[10]):Attach(frame_16[75], frame_16[76], frame_16[77], frame_16[78], frame_16[79])
            frame_16[83] = frame_16[82]
            cfg_16 = 15
        elseif cfg_16 == 14 then
            frame_16[84] = rangeDecoQuick
            frame_16[85] = EMPTY_SYMBOL
            frame_16[86] = ZERO_VECTOR
            frame_16[87] = ZERO_ROTATION
            frame_16[88] = frame_16[3]
            frame_16[91] = (frame_16[10]):Attach(frame_16[84], frame_16[85], frame_16[86], frame_16[87], frame_16[88])
            frame_16[83] = frame_16[91]
            cfg_16 = 15
        elseif cfg_16 == 15 then
            frame_16[92] = frame_16[83]
            frame_16[93] = IsNull
            frame_16[94] = frame_16[93](frame_16[92])
            if frame_16[94] then
                cfg_16 = 17
            else
                cfg_16 = 16
            end
        elseif cfg_16 == 16 then
            frame_16[95] = v21_13
            frame_16[96] = (frame_16[95] / 1.25)
            do (frame_16[83]):SetMeshScale(frame_16[96]) end
            cfg_16 = 17
        elseif cfg_16 == 17 then
            frame_16[99] = cap_21_101_3
            frame_16[100] = (frame_16[99]).IsPvpEnabled
            frame_16[101] = frame_16[100]()
            if not (frame_16[101]) then
                cfg_16 = 23
            else
                cfg_16 = 18
            end
        elseif cfg_16 == 18 then
            frame_16[102] = cap_21_101_3
            frame_16[103] = (frame_16[102]).IsFightingGame
            frame_16[104] = frame_16[103]()
            if not (frame_16[104]) then
                cfg_16 = 22
            else
                cfg_16 = 19
            end
        elseif cfg_16 == 19 then
            frame_16[105] = fightingTriggerType
            frame_16[106] = EMPTY_SYMBOL
            frame_16[107] = ZERO_VECTOR
            frame_16[108] = ZERO_ROTATION
            frame_16[109] = frame_16[6]
            frame_16[112] = (frame_16[10]):Attach(frame_16[105], frame_16[106], frame_16[107], frame_16[108], frame_16[109])
            frame_16[113] = (frame_16[15]).radius
            frame_16[114] = IsNull
            frame_16[115] = frame_16[114](frame_16[113])
            if not (frame_16[115]) then
                cfg_16 = 21
            else
                cfg_16 = 20
            end
        elseif cfg_16 == 20 then
            frame_16[116] = v21_13
            do (frame_16[112]):SetRadius(frame_16[116]) end
            cfg_16 = 26
        elseif cfg_16 == 21 then
            frame_16[119] = (frame_16[15]).radius
            do (frame_16[112]):SetRadius(frame_16[119]) end
            cfg_16 = 26
        elseif cfg_16 == 22 then
            frame_16[122] = pvpBulletAttractor
            frame_16[123] = EMPTY_SYMBOL
            frame_16[124] = ZERO_VECTOR
            frame_16[125] = ZERO_ROTATION
            frame_16[126] = frame_16[6]
            do (frame_16[10]):Attach(frame_16[122], frame_16[123], frame_16[124], frame_16[125], frame_16[126]) end
            cfg_16 = 26
        elseif cfg_16 == 23 then
            frame_16[131] = (frame_16[6]):IsHumanPlayer()
            if frame_16[131] then
                cfg_16 = 26
            else
                cfg_16 = 24
            end
        elseif cfg_16 == 24 then
            frame_16[132] = gRegion
            frame_16[170] = (frame_16[6]):IsAvatarFriendly((frame_16[132]):GetPlayerAvatar())
            if frame_16[170] then
                cfg_16 = 26
            else
                cfg_16 = 25
            end
        elseif cfg_16 == 25 then
            frame_16[171] = npcBulletAttractor
            frame_16[172] = EMPTY_SYMBOL
            frame_16[173] = ZERO_VECTOR
            frame_16[174] = ZERO_ROTATION
            frame_16[175] = frame_16[6]
            do (frame_16[10]):Attach(frame_16[171], frame_16[172], frame_16[173], frame_16[174], frame_16[175]) end
            cfg_16 = 26
        elseif cfg_16 == 26 then
            frame_16[178] = 0
            frame_16[181] = p16_0:GetSteps()
            frame_16[182] = {}
            frame_16[183] = 0
            frame_16[184] = (frame_16[181] - 1)
            frame_16[185] = 1
            local leave_for_16_27 = false
            for for_value_16_27 = frame_16[183], frame_16[184], frame_16[185] do
                frame_16[183] = for_value_16_27
                cfg_16 = 27
                while true do
                    if cfg_16 == 27 then
                        frame_16[186] = frame_16[182]
                        frame_16[187] = frame_16[183]
                        frame_16[218] = table.insert
                        frame_16[218](frame_16[186], p16_0:Name__02012d9c(frame_16[187], 2))
                        frame_16[219] = (frame_16[183] + 1)
                        frame_16[220] = frame_16[182][frame_16[219]]
                        frame_16[178] = (frame_16[178] + frame_16[220])
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_16_27 then break end
            end
            if not leave_for_16_27 then
                cfg_16 = 28
            end
        elseif cfg_16 == 28 then
            frame_16[223] = (frame_16[6]):GetInstance()
            frame_16[226] = (frame_16[6]):Name__ad7b05b3()
            if not (frame_16[226]) then
                cfg_16 = 32
            else
                cfg_16 = 29
            end
        elseif cfg_16 == 29 then
            if 0 < frame_16[178] then
                cfg_16 = 31
            else
                cfg_16 = 30
            end
        elseif cfg_16 == 30 then
            frame_16[226] = false
            cfg_16 = 32
        elseif cfg_16 == 31 then
            frame_16[226] = true
            cfg_16 = 32
        elseif cfg_16 == 32 then
            frame_16[228] = Sleep
            frame_16[228](0)
            frame_16[230] = nil
            frame_16[231] = frame_16[10]
            frame_16[232] = IsNull
            frame_16[233] = frame_16[232](frame_16[231])
            if frame_16[233] then
                cfg_16 = 35
            else
                cfg_16 = 33
            end
        elseif cfg_16 == 33 then
            frame_16[236] = (frame_16[10]):DamageControl()
            frame_16[230] = frame_16[236]
            frame_16[237] = cap_21_101_3
            frame_16[238] = (frame_16[237]).IsFightingGame
            frame_16[239] = frame_16[238]()
            if frame_16[239] then
                cfg_16 = 35
            else
                cfg_16 = 34
            end
        elseif cfg_16 == 34 then
            do (frame_16[230]):Name__8cb1bda4(true) end
            cfg_16 = 35
        elseif cfg_16 == 35 then
            frame_16[243] = _T.bardMusic
            frame_16[244] = IsNull
            frame_16[245] = frame_16[244](frame_16[243])
            if not (frame_16[245]) then
                cfg_16 = 37
            else
                cfg_16 = 36
            end
        elseif cfg_16 == 36 then
            frame_16[246] = _T
            frame_16[247] = {}
            frame_16[246].bardMusic = frame_16[247]
            cfg_16 = 37
        elseif cfg_16 == 37 then
            frame_16[248] = _T.bardMusic
            frame_16[249] = { radius = nil, box = nil }
            frame_16[250] = v21_13
            frame_16[249].radius = frame_16[250]
            frame_16[249].box = frame_16[10]
            frame_16[248][frame_16[223]] = frame_16[249]
            frame_16[251] = mOwner
            frame_16[254] = (frame_16[251]):GetType()
            frame_16[257] = p16_0:GetCurrentStep()
            frame_16[258] = 0
            frame_16[259] = 0
            frame_16[260] = {}
            frame_16[261] = 1
            frame_16[262] = 0
            frame_16[263] = 0
            frame_16[264] = Symbol
            frame_16[266] = frame_16[264]("SetThreatLevel")
            frame_16[267] = v21_14
            frame_16[268] = cap_21_101_1
            frame_16[269] = (frame_16[268]).GetUniqueAbilityId
            frame_16[270] = frame_16[269]()
            if not (0 < frame_16[267]) then
                cfg_16 = 45
            else
                cfg_16 = 38
            end
        elseif cfg_16 == 38 then
            frame_16[272] = frame_16[6]
            frame_16[273] = IsNull
            frame_16[274] = frame_16[273](frame_16[272])
            if frame_16[274] then
                cfg_16 = 45
            else
                cfg_16 = 39
            end
        elseif cfg_16 == 39 then
            frame_16[277] = (frame_16[6]):IsKilled()
            if frame_16[277] then
                cfg_16 = 45
            else
                cfg_16 = 40
            end
        elseif cfg_16 == 40 then
            frame_16[278] = frame_16[3]
            frame_16[279] = IsNull
            frame_16[280] = frame_16[279](frame_16[278])
            if frame_16[280] then
                cfg_16 = 45
            else
                cfg_16 = 41
            end
        elseif cfg_16 == 41 then
            frame_16[281] = frame_16[10]
            frame_16[282] = IsNull
            frame_16[283] = frame_16[282](frame_16[281])
            if frame_16[283] then
                cfg_16 = 45
            else
                cfg_16 = 42
            end
        elseif cfg_16 == 42 then
            frame_16[284] = (frame_16[15]).sequencer
            if frame_16[284] == p16_0 then
                cfg_16 = 44
            else
                cfg_16 = 43
            end
        elseif cfg_16 == 43 then
            frame_16[285] = (frame_16[15]).secondSequencer
            if frame_16[285] ~= p16_0 then
                cfg_16 = 45
            else
                cfg_16 = 44
            end
        elseif cfg_16 == 44 then
            frame_16[286] = _T.AddAbilityTimer
            frame_16[287] = frame_16[254]
            frame_16[288] = frame_16[6]
            frame_16[289] = frame_16[267]
            frame_16[290] = frame_16[270]
            frame_16[286](frame_16[287], frame_16[288], frame_16[289], frame_16[290])
            cfg_16 = 45
        elseif cfg_16 == 45 then
            if not (0 < frame_16[267]) then
                cfg_16 = 97
            else
                cfg_16 = 46
            end
        elseif cfg_16 == 46 then
            frame_16[292] = frame_16[6]
            frame_16[293] = IsNull
            frame_16[294] = frame_16[293](frame_16[292])
            if frame_16[294] then
                cfg_16 = 97
            else
                cfg_16 = 47
            end
        elseif cfg_16 == 47 then
            frame_16[297] = (frame_16[6]):IsKilled()
            if frame_16[297] then
                cfg_16 = 97
            else
                cfg_16 = 48
            end
        elseif cfg_16 == 48 then
            frame_16[298] = frame_16[3]
            frame_16[299] = IsNull
            frame_16[300] = frame_16[299](frame_16[298])
            if frame_16[300] then
                cfg_16 = 97
            else
                cfg_16 = 49
            end
        elseif cfg_16 == 49 then
            frame_16[301] = frame_16[10]
            frame_16[302] = IsNull
            frame_16[303] = frame_16[302](frame_16[301])
            if frame_16[303] then
                cfg_16 = 97
            else
                cfg_16 = 50
            end
        elseif cfg_16 == 50 then
            frame_16[304] = (frame_16[15]).sequencer
            if frame_16[304] == p16_0 then
                cfg_16 = 52
            else
                cfg_16 = 51
            end
        elseif cfg_16 == 51 then
            frame_16[305] = (frame_16[15]).secondSequencer
            if frame_16[305] ~= p16_0 then
                cfg_16 = 97
            else
                cfg_16 = 52
            end
        elseif cfg_16 == 52 then
            frame_16[308] = p16_0:GetPosition()
            frame_16[9] = frame_16[308]
            if not (frame_16[259] <= 0) then
                cfg_16 = 56
            else
                cfg_16 = 53
            end
        elseif cfg_16 == 53 then
            frame_16[310] = gGameRules
            frame_16[311] = IsNull
            frame_16[312] = frame_16[311](frame_16[310])
            if frame_16[312] then
                cfg_16 = 55
            else
                cfg_16 = 54
            end
        elseif cfg_16 == 54 then
            frame_16[313] = gGameRules
            frame_16[314] = frame_16[6]
            frame_16[315] = frame_16[9]
            frame_16[318] = (frame_16[313]):Name__4a167f71(frame_16[314], frame_16[315])
            if frame_16[318] then
                cfg_16 = 97
            else
                cfg_16 = 55
            end
        elseif cfg_16 == 55 then
            frame_16[259] = 0.25
            cfg_16 = 56
        elseif cfg_16 == 56 then
            frame_16[321] = p16_0:Name__d58d4a57()
            frame_16[322] = cap_21_101_5
            do (frame_16[10]):SetMaterialParam(frame_16[322], 1) end
            frame_16[326] = cap_21_101_6
            frame_16[328] = (frame_16[321] * 0.8)
            frame_16[329] = (1 + frame_16[328])
            do (frame_16[10]):SetMaterialParam(frame_16[326], frame_16[329]) end
            frame_16[334] = p16_0:GetCurrentStep()
            if frame_16[334] == frame_16[257] then
                cfg_16 = 93
            else
                cfg_16 = 57
            end
        elseif cfg_16 == 57 then
            frame_16[335] = v21_13
            frame_16[337] = _T.bardAmplify
            local leave_for_16_62 = false
            for for_value_16_62_0, for_value_16_62_1 in pairs(frame_16[337]) do
                frame_16[349], frame_16[350] = for_value_16_62_0, for_value_16_62_1
                cfg_16 = 58
                while true do
                    if cfg_16 == 58 then
                        frame_16[341] = (frame_16[350]).pos
                        if frame_16[341] == nil then
                            cfg_16 = 61
                        else
                            cfg_16 = 59
                        end
                    elseif cfg_16 == 59 then
                        frame_16[342] = Distance
                        frame_16[343] = frame_16[9]
                        frame_16[344] = (frame_16[350]).pos
                        frame_16[345] = frame_16[342](frame_16[343], frame_16[344])
                        frame_16[346] = (frame_16[350]).radius
                        if not (frame_16[345] <= frame_16[346]) then
                            cfg_16 = 61
                        else
                            cfg_16 = 60
                        end
                    elseif cfg_16 == 60 then
                        frame_16[335] = (frame_16[335] * 2)
                        frame_16[347] = 1.5
                        cfg_16 = 63
                        leave_for_16_62 = true
                        break
                    elseif cfg_16 == 61 then
                        frame_16[348] = 1
                        cfg_16 = 62
                    elseif cfg_16 == 62 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_16_62 then break end
            end
            if not leave_for_16_62 then
                cfg_16 = 63
            end
        elseif cfg_16 == 63 then
            frame_16[351] = _T.bardMusic
            if frame_16[351] ~= nil then
                cfg_16 = 65
            else
                cfg_16 = 64
            end
        elseif cfg_16 == 64 then
            frame_16[352] = _T
            frame_16[353] = {}
            frame_16[352].bardMusic = frame_16[353]
            cfg_16 = 65
        elseif cfg_16 == 65 then
            frame_16[354] = _T.bardMusic
            frame_16[355] = frame_16[354][frame_16[223]]
            if frame_16[355] ~= nil then
                cfg_16 = 67
            else
                cfg_16 = 66
            end
        elseif cfg_16 == 66 then
            frame_16[356] = _T.bardMusic
            frame_16[357] = { radius = nil, box = nil }
            frame_16[357].radius = frame_16[335]
            frame_16[357].box = frame_16[10]
            frame_16[356][frame_16[223]] = frame_16[357]
            cfg_16 = 69
        elseif cfg_16 == 67 then
            frame_16[358] = _T.bardMusic
            frame_16[359] = frame_16[358][frame_16[223]]
            frame_16[360] = (frame_16[359]).box
            if frame_16[360] ~= frame_16[10] then
                cfg_16 = 69
            else
                cfg_16 = 68
            end
        elseif cfg_16 == 68 then
            frame_16[361] = _T.bardMusic
            frame_16[362] = frame_16[361][frame_16[223]]
            frame_16[362].radius = frame_16[335]
            cfg_16 = 69
        elseif cfg_16 == 69 then
            frame_16[363] = frame_16[83]
            frame_16[364] = IsNull
            frame_16[365] = frame_16[364](frame_16[363])
            if frame_16[365] then
                cfg_16 = 71
            else
                cfg_16 = 70
            end
        elseif cfg_16 == 70 then
            frame_16[366] = (frame_16[335] / 1.25)
            do (frame_16[83]):SetMeshScale(frame_16[366]) end
            cfg_16 = 71
        elseif cfg_16 == 71 then
            frame_16[369] = frame_16[60]
            frame_16[370] = IsNull
            frame_16[371] = frame_16[370](frame_16[369])
            if frame_16[371] then
                cfg_16 = 73
            else
                cfg_16 = 72
            end
        elseif cfg_16 == 72 then
            frame_16[372] = (frame_16[321] - frame_16[262])
            frame_16[373] = (frame_16[372] * 40)
            frame_16[374] = Range
            frame_16[375] = frame_16[373]
            frame_16[376] = frame_16[373]
            do (frame_16[60]):SetForce(frame_16[374](frame_16[375], frame_16[376])) end
            cfg_16 = 73
        elseif cfg_16 == 73 then
            frame_16[262] = frame_16[321]
            frame_16[391] = _T.bardVisualizer
            frame_16[392] = IsNull
            frame_16[393] = frame_16[392](frame_16[391])
            if frame_16[393] then
                cfg_16 = 76
            else
                cfg_16 = 74
            end
        elseif cfg_16 == 74 then
            frame_16[394] = _T.bardVisualizer
            frame_16[395] = frame_16[394][frame_16[223]]
            frame_16[396] = IsNull
            frame_16[397] = frame_16[396](frame_16[395])
            if frame_16[397] then
                cfg_16 = 76
            else
                cfg_16 = 75
            end
        elseif cfg_16 == 75 then
            frame_16[398] = _T.bardVisualizer
            frame_16[399] = frame_16[398][frame_16[223]]
            frame_16[400] = (frame_16[399]).music
            frame_16[401] = frame_16[321]
            do (frame_16[400]):Name__3f96e89a(frame_16[401]) end
            cfg_16 = 76
        elseif cfg_16 == 76 then
            frame_16[404] = 1
            frame_16[405] = cap_21_101_7
            frame_16[406] = (#frame_16[405])
            frame_16[407] = 1
            local leave_for_16_77 = false
            for for_value_16_77 = frame_16[404], frame_16[406], frame_16[407] do
                frame_16[404] = for_value_16_77
                cfg_16 = 77
                while true do
                    if cfg_16 == 77 then
                        frame_16[408] = (1 / frame_16[404])
                        frame_16[409] = (frame_16[404] - 1)
                        frame_16[410] = (frame_16[409] * 4)
                        frame_16[411] = (frame_16[410] + 1)
                        frame_16[412] = (frame_16[404] * frame_16[404])
                        frame_16[413] = (frame_16[412] + 5)
                        frame_16[414] = math.random
                        frame_16[417] = frame_16[414](1, 3)
                        frame_16[418] = (frame_16[413] + frame_16[417])
                        frame_16[260][frame_16[411]] = frame_16[418]
                        frame_16[419] = (frame_16[410] + 2)
                        frame_16[420] = Random
                        frame_16[423] = frame_16[420](0.15, 0.25)
                        frame_16[424] = (frame_16[408] * frame_16[423])
                        frame_16[260][frame_16[419]] = frame_16[424]
                        frame_16[425] = (frame_16[410] + 3)
                        frame_16[426] = Random
                        frame_16[429] = frame_16[426](-3, 3)
                        frame_16[260][frame_16[425]] = frame_16[429]
                        frame_16[430] = (frame_16[410] + 4)
                        frame_16[431] = Random
                        frame_16[434] = frame_16[431](-1, 1)
                        frame_16[260][frame_16[430]] = frame_16[434]
                        frame_16[435] = Clamp
                        frame_16[437] = Name__d299a472
                        frame_16[438] = Frac
                        frame_16[439] = Time
                        frame_16[444] = frame_16[438](frame_16[439]())
                        frame_16[445] = (frame_16[404] * frame_16[444])
                        frame_16[446] = frame_16[437](frame_16[445])
                        frame_16[447] = (4 * frame_16[446])
                        frame_16[450] = frame_16[435](frame_16[447], 0.75, 1)
                        frame_16[451] = frame_16[83]
                        frame_16[452] = IsNull
                        frame_16[453] = frame_16[452](frame_16[451])
                        if frame_16[453] then
                            cfg_16 = 79
                        else
                            cfg_16 = 78
                        end
                    elseif cfg_16 == 78 then
                        frame_16[454] = cap_21_101_7
                        frame_16[455] = frame_16[454][frame_16[404]]
                        frame_16[456] = (frame_16[410] + 1)
                        frame_16[457] = frame_16[260][frame_16[456]]
                        frame_16[459] = frame_16[321]
                        frame_16[460] = math.min
                        frame_16[461] = frame_16[460](1, frame_16[459])
                        frame_16[462] = (frame_16[450] * frame_16[461])
                        frame_16[463] = (frame_16[410] + 2)
                        frame_16[464] = frame_16[260][frame_16[463]]
                        frame_16[465] = (frame_16[462] * frame_16[464])
                        frame_16[466] = (frame_16[450] * 12)
                        frame_16[467] = (frame_16[410] + 3)
                        frame_16[468] = frame_16[260][frame_16[467]]
                        frame_16[469] = (frame_16[466] + frame_16[468])
                        frame_16[470] = (frame_16[410] + 4)
                        frame_16[471] = frame_16[260][frame_16[470]]
                        do (frame_16[83]):SetMaterialParam(frame_16[455], frame_16[457], frame_16[465], frame_16[469], frame_16[471]) end
                        cfg_16 = 79
                    elseif cfg_16 == 79 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_16_77 then break end
            end
            if not leave_for_16_77 then
                cfg_16 = 80
            end
        elseif cfg_16 == 80 then
            frame_16[474] = cap_21_101_8
            frame_16[475] = FRand
            frame_16[476] = frame_16[475]()
            frame_16[477] = FRand
            do (frame_16[10]):SetMaterialParam(frame_16[474], frame_16[476], frame_16[477]()) end
            if not (frame_16[226]) then
                cfg_16 = 92
            else
                cfg_16 = 81
            end
        elseif cfg_16 == 81 then
            frame_16[493] = (frame_16[230]):GetDamageBuffer()
            frame_16[496] = (frame_16[493]):GetBaseAmount()
            frame_16[499] = (frame_16[496]):GetModifiedValue()
            frame_16[500] = v21_12
            frame_16[503] = (frame_16[500]):GetBaseValue()
            frame_16[504] = (frame_16[499] * frame_16[503])
            frame_16[258] = (frame_16[258] + frame_16[504])
            if not (0 < frame_16[258]) then
                cfg_16 = 90
            else
                cfg_16 = 82
            end
        elseif cfg_16 == 82 then
            frame_16[506] = (frame_16[334] + 1)
            frame_16[507] = frame_16[182][frame_16[506]]
            if not (0 < frame_16[507]) then
                cfg_16 = 90
            else
                cfg_16 = 83
            end
        elseif cfg_16 == 83 then
            frame_16[509] = cap_21_101_3
            frame_16[510] = (frame_16[509]).IsFightingGame
            frame_16[511] = frame_16[510]()
            if frame_16[511] then
                cfg_16 = 85
            else
                cfg_16 = 84
            end
        elseif cfg_16 == 84 then
            do (frame_16[230]):Name__8cb1bda4(true) end
            cfg_16 = 85
        elseif cfg_16 == 85 then
            frame_16[516] = (frame_16[334] + 1)
            frame_16[517] = frame_16[182][frame_16[516]]
            frame_16[518] = (frame_16[258] * frame_16[517])
            frame_16[519] = (frame_16[518] / frame_16[178])
            frame_16[520] = math.floor
            frame_16[521] = frame_16[520](frame_16[519])
            frame_16[522] = math.max
            frame_16[523] = frame_16[522](1, frame_16[521])
            if not (0 < frame_16[523]) then
                cfg_16 = 90
            else
                cfg_16 = 86
            end
        elseif cfg_16 == 86 then
            frame_16[258] = (frame_16[258] - frame_16[523])
            frame_16[525] = Engine.RadialDamageData
            frame_16[526] = frame_16[525]()
            frame_16[527] = frame_16[6]
            do (frame_16[526]):SetSource(frame_16[527]) end
            frame_16[530] = frame_16[9]
            do (frame_16[526]):SetOrigin(frame_16[530]) end
            frame_16[533] = nil
            frame_16[534] = Engine.Name__47432c06
            frame_16[535] = frame_16[534]()
            if not (frame_16[535]) then
                cfg_16 = 88
            else
                cfg_16 = 87
            end
        elseif cfg_16 == 87 then
            frame_16[536] = Engine.UpgradedValue
            frame_16[537] = (frame_16[523] * 32)
            frame_16[538] = frame_16[536](frame_16[537])
            frame_16[539] = frame_16[538]
            cfg_16 = 89
        elseif cfg_16 == 88 then
            frame_16[540] = Engine.UpgradedValue
            frame_16[541] = frame_16[258]
            frame_16[542] = frame_16[540](frame_16[541])
            frame_16[539] = frame_16[542]
            cfg_16 = 89
        elseif cfg_16 == 89 then
            frame_16[543] = v21_12
            do (frame_16[539]):AddModifiers(frame_16[543]) end
            frame_16[546] = frame_16[539]
            do (frame_16[526]):SetBaseAmount(frame_16[546]) end
            frame_16[526].radius = frame_16[335]
            frame_16[526].horizontalImpulse = 100
            frame_16[526].verticalImpulse = 33.333333333333336
            do (frame_16[526]):SetDamagePct(7, 1) end
            frame_16[526].ignoreEntity = frame_16[10]
            frame_16[555] = frame_16[3]
            do (frame_16[526]):SetSourceObject(frame_16[555]) end
            frame_16[526].checkForCover = true
            frame_16[526].staticCoverOnly = true
            frame_16[526].fallOff = 0
            frame_16[561] = gRegion
            frame_16[562] = frame_16[526]
            do (frame_16[561]):RadialDamage(frame_16[562]) end
            cfg_16 = 90
        elseif cfg_16 == 90 then
            frame_16[565] = Lerp
            frame_16[569] = (frame_16[258] / 1500)
            frame_16[570] = math.min
            frame_16[571] = frame_16[570](1, frame_16[569])
            frame_16[572] = frame_16[565](5, 0, frame_16[571])
            frame_16[573] = math.floor
            frame_16[574] = frame_16[573](frame_16[572])
            if frame_16[574] == frame_16[263] then
                cfg_16 = 92
            else
                cfg_16 = 91
            end
        elseif cfg_16 == 91 then
            frame_16[263] = frame_16[574]
            frame_16[575] = Lotus_Game.SecondaryScriptArgs
            frame_16[577] = frame_16[575](true)
            frame_16[578] = frame_16[263]
            do (frame_16[577]):PushFloatArg(frame_16[578]) end
            frame_16[581] = frame_16[254]
            frame_16[582] = frame_16[266]
            frame_16[583] = frame_16[577]
            do (frame_16[3]):ActivateSecondaryScript(frame_16[581], frame_16[582], frame_16[583]) end
            cfg_16 = 92
        elseif cfg_16 == 92 then
            frame_16[257] = frame_16[334]
            cfg_16 = 93
        elseif cfg_16 == 93 then
            frame_16[586] = _T.bardVisualizer
            frame_16[587] = IsNull
            frame_16[588] = frame_16[587](frame_16[586])
            if frame_16[588] then
                cfg_16 = 96
            else
                cfg_16 = 94
            end
        elseif cfg_16 == 94 then
            frame_16[589] = _T.bardVisualizer
            frame_16[590] = frame_16[589][frame_16[223]]
            frame_16[591] = IsNull
            frame_16[592] = frame_16[591](frame_16[590])
            if frame_16[592] then
                cfg_16 = 96
            else
                cfg_16 = 95
            end
        elseif cfg_16 == 95 then
            frame_16[593] = _T.bardVisualizer
            frame_16[594] = frame_16[593][frame_16[223]]
            frame_16[595] = (frame_16[594]).music
            do (frame_16[595]):SetTargetVal(0) end
            frame_16[599] = cap_21_101_10
            frame_16[600] = _T.bardVisualizer
            frame_16[601] = frame_16[600][frame_16[223]]
            frame_16[602] = (frame_16[601]).music
            frame_16[605] = (frame_16[602]):GetVal()
            frame_16[606] = _T.bardVisualizer
            frame_16[607] = frame_16[606][frame_16[223]]
            frame_16[608] = (frame_16[607]).piper
            frame_16[611] = (frame_16[608]):GetVal()
            frame_16[612] = (frame_16[611] * 2.5)
            frame_16[613] = _T.bardVisualizer
            frame_16[614] = frame_16[613][frame_16[223]]
            frame_16[615] = (frame_16[614]).piper
            frame_16[618] = (frame_16[615]):GetVal()
            frame_16[619] = (frame_16[618] * 2)
            frame_16[620] = _T.bardVisualizer
            frame_16[621] = frame_16[620][frame_16[223]]
            frame_16[622] = (frame_16[621]).jam
            frame_16[625] = (frame_16[622]):GetVal()
            frame_16[626] = (frame_16[625] * 3.5)
            do (frame_16[10]):SetMaterialParam(frame_16[599], frame_16[605], frame_16[612], frame_16[619], frame_16[626]) end
            cfg_16 = 96
        elseif cfg_16 == 96 then
            frame_16[629] = Sleep
            frame_16[629](0)
            frame_16[631] = DeltaTime
            frame_16[632] = frame_16[631]()
            frame_16[267] = (frame_16[267] - frame_16[632])
            frame_16[633] = DeltaTime
            frame_16[634] = frame_16[633]()
            frame_16[259] = (frame_16[259] - frame_16[634])
            cfg_16 = 45
        elseif cfg_16 == 97 then
            frame_16[635] = _T.AddAbilityTimer
            frame_16[636] = frame_16[254]
            frame_16[637] = frame_16[6]
            frame_16[639] = frame_16[270]
            frame_16[635](frame_16[636], frame_16[637], 0, frame_16[639])
            frame_16[640] = _T.bardMusic
            frame_16[641] = IsNull
            frame_16[642] = frame_16[641](frame_16[640])
            if frame_16[642] then
                cfg_16 = 102
            else
                cfg_16 = 98
            end
        elseif cfg_16 == 98 then
            frame_16[643] = _T.bardMusic
            frame_16[644] = frame_16[643][frame_16[223]]
            frame_16[645] = IsNull
            frame_16[646] = frame_16[645](frame_16[644])
            if frame_16[646] then
                cfg_16 = 102
            else
                cfg_16 = 99
            end
        elseif cfg_16 == 99 then
            frame_16[647] = _T.bardMusic
            frame_16[648] = frame_16[647][frame_16[223]]
            frame_16[649] = (frame_16[648]).box
            if frame_16[649] ~= frame_16[10] then
                cfg_16 = 102
            else
                cfg_16 = 100
            end
        elseif cfg_16 == 100 then
            frame_16[650] = _T.bardMusic
            frame_16[650][frame_16[223]] = nil
            frame_16[652] = next
            frame_16[653] = _T.bardMusic
            frame_16[654] = frame_16[652](frame_16[653])
            if frame_16[654] ~= nil then
                cfg_16 = 102
            else
                cfg_16 = 101
            end
        elseif cfg_16 == 101 then
            frame_16[655] = _T
            frame_16[655].bardMusic = nil
            cfg_16 = 102
        elseif cfg_16 == 102 then
            frame_16[657] = gRegion
            frame_16[658] = destroyEffect
            frame_16[659] = frame_16[9]
            frame_16[660] = ZERO_ROTATION
            frame_16[661] = frame_16[3]
            do (frame_16[657]):CreateEntity(frame_16[658], frame_16[659], frame_16[660], frame_16[661]) end
            frame_16[664] = frame_16[83]
            frame_16[665] = IsNull
            frame_16[666] = frame_16[665](frame_16[664])
            if frame_16[666] then
                cfg_16 = 104
            else
                cfg_16 = 103
            end
        elseif cfg_16 == 103 then
            do (frame_16[83]):PlayTriggeredFade() end
            cfg_16 = 104
        elseif cfg_16 == 104 then
            frame_16[669] = frame_16[10]
            frame_16[670] = IsNull
            frame_16[671] = frame_16[670](frame_16[669])
            if frame_16[671] then
                cfg_16 = 106
            else
                cfg_16 = 105
            end
        elseif cfg_16 == 105 then
            do (frame_16[10]):Destroy() end
            cfg_16 = 106
        elseif cfg_16 == 106 then
            p16_0:Destroy()
            return
        else
            error("invalid control state")
        end
    end
end
BoxLoop = boxLoopFunction
local cap_21_114_4 = require4
spawnSequencerFunction = function(p17_0, p17_1, p17_2, p17_3, p17_4)
    local value
    local v17_6
    local isNull
    local ownerReference
    local v17_9
    local v17_10
    local resourceType
    local v17_12
    local v17_13
    local v17_14
    local v17_15
    local v17_16
    local v17_17
    local v17_18
    local v17_19
    local region
    local v17_21
    local avatarOrEntity
    local v17_23
    local v17_24
    local vector3
    local zeroRotation
    local v17_27
    local v17_28
    local v17_29
    local entity
    local value2
    local v17_32
    local isNull2
    local v17_34
    local v17_35
    local symbol
    local symbol2
    local symbol3
    local symbol4
    local symbol5
    local symbol6
    local symbol7
    local symbol8
    local v17_44
    local v17_45
    local v17_46
    local v17_47
    local customization
    local v17_49
    local v17_50
    local v17_51
    local song
    local v17_53
    local v17_54
    local v17_55
    local v17_56
    local v17_57
    local v17_58
    local hasNotePack
    local v17_60
    local v17_61
    local v17_62
    local v17_63
    local v17_64
    local notePack
    local notePack2
    local notePack3
    local resource
    local resource2
    local resource3
    local resource4
    local v17_72
    local v17_73
    local mHasFingerPrintValue
    local mFingerPrintValue
    local v17_76
    local v17_77
    local v17_78
    local v17_79
    local v17_80
    local v17_81
    local v17_82
    local v17_83
    local v17_84
    local v17_85
    local v17_86
    local syncSequencerValue
    local v17_88
    local v17_89
    local v17_90
    local symbol9
    local v17_92
    local v17_93
    local v17_94
    value = p17_2
    v17_6 = IsNull
    isNull = v17_6(value)
    if not (isNull) then
        ownerReference = mOwner
        resourceType = ownerReference:GetType()
        v17_12 = resourceType
        v17_15 = avatarOrItem:Name__9e0e48b9(v17_12)
        v17_16 = v17_15[1]
        v21_12 = v17_16
        v21_13 = p17_3
        v21_14 = p17_4
        v21_62 = p17_2
        v17_17 = pvpBulletAttractor
        v17_18 = npcBulletAttractor
        v17_19 = fightingTriggerType
        region = gRegion
        v17_21 = stepSequencerType
        avatarOrEntity = v21_62
        vector3 = avatarOrEntity:GetPosition()
        zeroRotation = ZERO_ROTATION
        v17_27 = avatarOrItem
        entity = region:CreateEntity(v17_21, vector3, zeroRotation, v17_27)
        value2 = entity
        v17_32 = IsNull
        isNull2 = v17_32(value2)
        if not (isNull2) then
            v17_34 = v21_62
            v17_35 = Symbol
            entity:Name__4cc50a85(v17_34, v17_35())
            customization = avatarOrItem:GetCustomization()
            song = customization:GetSong(0)
            v17_53 = 0
            v17_54 = 3
            v17_55 = 1
            for v17_53 = v17_53, v17_54, v17_55 do
                v17_56 = v17_53
                hasNotePack = song:HasNotePack(v17_56)
                if hasNotePack then
                    v17_60 = v17_53
                    v17_61 = Resource
                    v17_62 = v17_53
                    entity:SetNotePack(v17_60, v17_61(song:GetNotePack(v17_62)))
                end
            end
            mHasFingerPrintValue = (song).mHasFingerPrint
            if mHasFingerPrintValue then
                mFingerPrintValue = (song).mFingerPrint
                entity:Name__09441edf(mFingerPrintValue)
            end
            entity:SetMute(0, true)
            entity:SetMute(1, true)
            v17_86 = cap_21_114_4
            syncSequencerValue = (v17_86).SyncSequencer
            v17_88 = entity
            syncSequencerValue(v17_88)
            v17_89 = Symbol
            symbol9 = v17_89("BoxLoop")
            entity:Name__a50e34c3(symbol9, false)
        end
        return
    else
        return
    end
end
SpawnSequencer = spawnSequencerFunction
setThreatLevelFunction = function(p18_0, p18_1, p18_2)
    local v18_3
    local v18_4
    local avatarOwner
    local v18_6
    local v18_7
    local instanceId
    local value
    local v18_10
    local isNull
    local v18_12
    local value2
    local v18_14
    local isNull2
    local v18_16
    local v18_17
    local value3
    local v18_19
    local isNull3
    local v18_21
    local v18_22
    local boxValue
    local v18_24
    local v18_25
    local v18_26
    avatarOwner = sourceAbility:GetAvatarOwner()
    instanceId = avatarOwner:GetInstance()
    value = _T.bardMusic
    v18_10 = IsNull
    isNull = v18_10(value)
    if not (isNull) then
        v18_12 = _T.bardMusic
        value2 = v18_12[instanceId]
        v18_14 = IsNull
        isNull2 = v18_14(value2)
        if not (isNull2) then
            v18_16 = _T.bardMusic
            v18_17 = v18_16[instanceId]
            value3 = (v18_17).box
            v18_19 = IsNull
            isNull3 = v18_19(value3)
            if not (isNull3) then
                v18_21 = _T.bardMusic
                v18_22 = v18_21[instanceId]
                boxValue = (v18_22).box
                v18_24 = p18_2
                boxValue:Name__ecb31eeb(v18_24)
            end
        end
    end
    return
end
SetThreatLevel = setThreatLevelFunction
giveFightingUpgradesFunction = function(p19_0, p19_1)
    local region
    local v19_3
    local v19_4
    local isMaster
    local value
    local v19_7
    local isNull
    local v19_9
    local v19_10
    local isKilled
    local v19_12
    local v19_13
    local unknown_object_ref
    local v19_15
    local v19_16
    local inventoryControl
    local v19_18
    local v19_19
    local v19_20
    local v19_21
    local v19_22
    region = gRegion
    isMaster = region:IsMaster()
    if isMaster then
        value = p19_1
        v19_7 = IsNull
        isNull = v19_7(value)
        if not (isNull) then
            isKilled = p19_1:IsKilled()
            if not (isKilled) then
                unknown_object_ref = engineObject:GetCreator()
                if not (p19_1 ~= unknown_object_ref) then
                    inventoryControl = p19_1:InventoryControl()
                    inventoryControl:AddUpgrade(325, 3, 0.5)
                end
            end
        end
    end
    return
end
GiveFightingUpgrades = giveFightingUpgradesFunction
removeFightingUpgradesFunction = function(p20_0, p20_1)
    local region
    local v20_3
    local v20_4
    local isMaster
    local value
    local v20_7
    local isNull
    local v20_9
    local v20_10
    local isKilled
    local v20_12
    local v20_13
    local unknown_object_ref
    local v20_15
    local v20_16
    local inventoryControl
    local v20_18
    local v20_19
    local v20_20
    local v20_21
    local v20_22
    region = gRegion
    isMaster = region:IsMaster()
    if isMaster then
        value = p20_1
        v20_7 = IsNull
        isNull = v20_7(value)
        if not (isNull) then
            isKilled = p20_1:IsKilled()
            if not (isKilled) then
                unknown_object_ref = engineObject:GetCreator()
                if not (p20_1 ~= unknown_object_ref) then
                    inventoryControl = p20_1:InventoryControl()
                    inventoryControl:RemoveUpgrade(325, 3, 0.5)
                end
            end
        end
    end
    return
end
RemoveFightingUpgrades = removeFightingUpgradesFunction
return
