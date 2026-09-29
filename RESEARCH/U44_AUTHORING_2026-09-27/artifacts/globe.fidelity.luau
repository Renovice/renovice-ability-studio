-- RENOVICE_HASH_FIELD: Name__1c00e12c
-- RENOVICE_HASH_FIELD: Name__43080fee
-- RENOVICE_HASH_FIELD: Name__4369ab26
-- RENOVICE_HASH_FIELD: Name__6e44af97
-- RENOVICE_HASH_FIELD: Name__8e8dc7ef
-- RENOVICE_HASH_FIELD: Name__a34fa566
-- RENOVICE_HASH_FIELD: Name__cbbd4ec1
-- RENOVICE_HASH_FIELD: Name__dcbe841c
-- RENOVICE_HASH_FIELD: Name__e81dbfc2
-- RENOVICE_HASH_FIELD: Name__fe1fea46
local v19_0
local v19_1
local v19_2
local v19_3
local v19_4
local v19_5
local v19_6
local v19_7
local v19_8
local v19_9
local v19_10
local v19_11
local v19_12
local v19_13
local v19_14
local v19_15
local v19_16
local v19_17
local v19_18
local v19_19
local v19_20
local v19_21
local v19_22
local v19_23
local v19_24
local v19_25
local v19_26
local v19_27
local v19_28
local v19_29
local v19_30
local v19_31
local v19_32
local v19_33
local v19_34
local v19_35
local v19_36
local v19_37
local v19_38
local v19_39
local v19_40
local v19_41
local v19_42
local v19_43
local v19_44
local v19_45
local v19_46
local v19_47
local v19_48
v19_0 = Name__9ff10ded
v19_2 = v19_0("Lotus.Powersuits.PowersuitAbilities.PVPLib")
v19_3 = Name__9ff10ded
v19_5 = v19_3("Lotus.Scripts.Libs.AbilitiesLib")
v19_6 = Name__3df6d685
v19_8 = v19_6("Scalar2")
v19_9 = Name__3df6d685
v19_11 = v19_9("Scalar3")
v19_12 = Name__3df6d685
v19_14 = v19_12("FresnelGradientScale_FresnelGradientPan_FresnelGradientBaseStrength")
v19_15 = 5
v19_16 = 300
v19_17 = 0.5
v19_18 = 0.6
v19_19 = 10
v19_20 = 5
v19_21 = 100
v19_22 = 0.15
v19_23 = 1
v19_24 = Name__3df6d685
v19_26 = v19_24("ICE_SHIELD_AUG_TWO_PARKOUR_UPGRADE")
v19_27 = Name__9466a60b
v19_29 = v19_27("/Lotus/Powersuits/Frost/VelimirNpcSuit")
local cap_19_31_0 = v19_29
v19_30 = function(p0_0)
    local v0_1
    local v0_2
    local v0_3
    local v0_4
    local v0_5
    local v0_6
    local v0_7
    local v0_8
    local v0_9
    local v0_10
    v0_1 = Name__9828c6d9.slamGlobe
    if v0_1 == nil then
        return false
    else
        v0_2 = Name__41bc84cf
        v0_3 = Name__9828c6d9.slamGlobe
        v0_4 = v0_2(v0_3)
        if v0_4 ~= nil then
            v0_5 = true
        else
            v0_5 = false
        end
        v0_6 = v0_5
        if v0_6 then
            v0_7 = cap_19_31_0
            v0_6 = p0_0:Name__2888fc5c(v0_7)
        end
        return v0_6
    end
end
local cap_19_33_5 = v19_2
v19_31 = function(p1_0)
    local frame_1 = {}
    local cfg_1 = 0
    while true do
        if cfg_1 == 0 then
            v19_15 = 5
            if p1_0 ~= 1 then
                cfg_1 = 2
            else
                cfg_1 = 1
            end
        elseif cfg_1 == 1 then
            v19_16 = 1500
            v19_17 = 1
            v19_18 = 0.6
            v19_21 = 50
            cfg_1 = 7
        elseif cfg_1 == 2 then
            if p1_0 ~= 2 then
                cfg_1 = 4
            else
                cfg_1 = 3
            end
        elseif cfg_1 == 3 then
            v19_16 = 2500
            v19_17 = 2
            v19_18 = 0.5
            v19_21 = 100
            cfg_1 = 7
        elseif cfg_1 == 4 then
            if p1_0 ~= 3 then
                cfg_1 = 6
            else
                cfg_1 = 5
            end
        elseif cfg_1 == 5 then
            v19_16 = 3000
            v19_17 = 3
            v19_18 = 0.4
            v19_21 = 125
            cfg_1 = 7
        elseif cfg_1 == 6 then
            v19_16 = 3500
            v19_17 = 4
            v19_18 = 0.33
            v19_21 = 150
            cfg_1 = 7
        elseif cfg_1 == 7 then
            frame_1[18] = cap_19_33_5
            frame_1[19] = (frame_1[18]).Name__4369ab26
            frame_1[20] = frame_1[19]()
            if not (frame_1[20]) then
                cfg_1 = 15
            else
                cfg_1 = 8
            end
        elseif cfg_1 == 8 then
            v19_15 = 1
            if p1_0 ~= 1 then
                cfg_1 = 10
            else
                cfg_1 = 9
            end
        elseif cfg_1 == 9 then
            v19_16 = 425
            v19_17 = 0.1
            v19_18 = 0.33
            return
        elseif cfg_1 == 10 then
            if p1_0 ~= 2 then
                cfg_1 = 12
            else
                cfg_1 = 11
            end
        elseif cfg_1 == 11 then
            v19_16 = 450
            v19_17 = 0.1
            v19_18 = 0.33
            return
        elseif cfg_1 == 12 then
            if p1_0 ~= 3 then
                cfg_1 = 14
            else
                cfg_1 = 13
            end
        elseif cfg_1 == 13 then
            v19_16 = 475
            v19_17 = 0.1
            v19_18 = 0.33
            return
        elseif cfg_1 == 14 then
            v19_16 = 500
            v19_17 = 0.1
            v19_18 = 0.33
            cfg_1 = 15
        elseif cfg_1 == 15 then
            return
        else
            error("invalid control state")
        end
    end
end
v19_32 = function(p2_0)
    local v2_1
    local v2_2
    local v2_3
    local v2_4
    local v2_5
    local v2_6
    local v2_7
    local v2_8
    local v2_9
    local v2_10
    local v2_11
    local v2_12
    local v2_13
    local v2_14
    local v2_15
    local v2_16
    local v2_17
    local v2_18
    local v2_19
    local v2_20
    local v2_21
    local v2_22
    local v2_23
    local v2_24
    local v2_25
    local v2_26
    local v2_27
    local v2_28
    local v2_29
    local v2_30
    local v2_31
    local v2_32
    local v2_33
    local v2_34
    local v2_35
    local v2_36
    local v2_37
    local v2_38
    local v2_39
    local v2_40
    local v2_41
    local v2_42
    local v2_43
    local v2_44
    local v2_45
    local v2_46
    local v2_47
    local v2_48
    local v2_49
    local v2_50
    local v2_51
    local v2_52
    local v2_53
    local v2_54
    local v2_55
    local v2_56
    local v2_57
    local v2_58
    local v2_59
    local v2_60
    local v2_61
    local v2_62
    local v2_63
    local v2_64
    local v2_65
    local v2_66
    local v2_67
    v2_1 = v19_16
    v2_2 = v19_20
    v2_3 = v19_19
    v2_4 = Name__5ebaa8da.Name__b78c546f
    v2_5 = v19_21
    v2_6 = v2_4(v2_5)
    v2_7 = p2_0
    v2_8 = Name__6514b208
    v2_9 = v2_8(v2_7)
    if not (v2_9) then
        v2_10 = v19_16
        v2_13 = p2_0:Name__402a3166()
        v2_16 = v2_13:Name__52652686()
        v2_17 = v19_15
        v2_18 = (v2_16 * v2_17)
        v2_1 = (v2_10 + v2_18)
        v2_21 = p2_0:Name__682cbf57()
        v2_24 = v2_21:Name__b2e22fcd()
        v2_25 = v2_24
        v2_26 = Name__6514b208
        v2_27 = v2_26(v2_25)
        if not (v2_27) then
            v2_30 = v2_24:Name__bab6c411()
            v2_31 = v2_1
            v2_33 = v2_30
            v2_34 = v2_24
            v2_37 = v2_21:Name__d7d71bec(v2_31, 10, v2_33, v2_34)
            v2_1 = v2_37
            v2_38 = v19_20
            v2_40 = v2_30
            v2_41 = v2_24
            v2_44 = v2_21:Name__d7d71bec(v2_38, 9, v2_40, v2_41)
            v2_2 = v2_44
            v2_45 = v19_19
            v2_47 = v2_30
            v2_48 = v2_24
            v2_51 = v2_21:Name__d7d71bec(v2_45, 3, v2_47, v2_48)
            v2_3 = v2_51
            v2_52 = v2_6
            v2_54 = v2_30
            v2_55 = v2_24
            v2_21:Name__7101e8b5(v2_52, 10, v2_54, v2_55)
            v2_61 = v2_24:Name__c7fc329f(2)
            v2_65 = v2_24:Name__9dfce5ad(2)
            if 0 < v2_61 then
                if not (v2_65 ~= 2) then
                    v2_2 = (v2_2 * 0.45)
                end
            end
        end
    end
    return v2_1, v2_2, v2_3, v2_6
end
v19_33 = function(p3_0, p3_1)
    local frame_3 = {}
    local cfg_3 = 0
    while true do
        if cfg_3 == 0 then
            if p3_1 ~= 1 then
                cfg_3 = 8
            else
                cfg_3 = 1
            end
        elseif cfg_3 == 1 then
            if p3_0 ~= 1 then
                cfg_3 = 3
            else
                cfg_3 = 2
            end
        elseif cfg_3 == 2 then
            v19_22 = 0.3
            return
        elseif cfg_3 == 3 then
            if p3_0 ~= 2 then
                cfg_3 = 5
            else
                cfg_3 = 4
            end
        elseif cfg_3 == 4 then
            v19_22 = 0.35
            return
        elseif cfg_3 == 5 then
            if p3_0 ~= 3 then
                cfg_3 = 7
            else
                cfg_3 = 6
            end
        elseif cfg_3 == 6 then
            v19_22 = 0.4
            return
        elseif cfg_3 == 7 then
            v19_22 = 0.5
            return
        elseif cfg_3 == 8 then
            if p3_1 ~= 2 then
                cfg_3 = 16
            else
                cfg_3 = 9
            end
        elseif cfg_3 == 9 then
            if p3_0 ~= 1 then
                cfg_3 = 11
            else
                cfg_3 = 10
            end
        elseif cfg_3 == 10 then
            v19_23 = 0.01
            return
        elseif cfg_3 == 11 then
            if p3_0 ~= 2 then
                cfg_3 = 13
            else
                cfg_3 = 12
            end
        elseif cfg_3 == 12 then
            v19_23 = 0.02
            return
        elseif cfg_3 == 13 then
            if p3_0 ~= 3 then
                cfg_3 = 15
            else
                cfg_3 = 14
            end
        elseif cfg_3 == 14 then
            v19_23 = 0.03
            return
        elseif cfg_3 == 15 then
            v19_23 = 0.04
            cfg_3 = 16
        elseif cfg_3 == 16 then
            return
        else
            error("invalid control state")
        end
    end
end
v19_34 = function(p4_0, p4_1)
    local v4_2
    local v4_3
    local v4_4
    local v4_5
    local v4_6
    local v4_7
    local v4_8
    local v4_9
    local v4_10
    local v4_11
    local v4_12
    local v4_13
    local v4_14
    local v4_15
    local v4_16
    local v4_17
    local v4_18
    local v4_19
    local v4_20
    local v4_21
    local v4_22
    local v4_23
    local v4_24
    local v4_25
    local v4_26
    local v4_27
    v4_4 = p4_0:Name__682cbf57()
    v4_7 = v4_4:Name__b2e22fcd()
    v4_8 = v4_7
    v4_9 = Name__6514b208
    v4_10 = v4_9(v4_8)
    local bridge_4_0
    if v4_10 then
        bridge_4_0 = true
    else
        v4_13 = v4_7:Name__bab6c411()
        bridge_4_0 = not (v4_13)
    end
    if bridge_4_0 then
        v4_13 = nil
    end
    if p4_1 ~= 2 then
        return nil
    else
        v4_15 = v19_23
        v4_17 = v4_13
        v4_18 = v4_7
        return v4_4:Name__d7d71bec(v4_15, 10, v4_17, v4_18)
    end
end
local cap_19_51_0 = v19_33
local cap_19_51_3 = v19_34
v19_35 = function(p5_0)
    local v5_1
    local v5_2
    local v5_3
    local v5_4
    local v5_5
    local v5_6
    local v5_7
    local v5_8
    local v5_9
    local v5_10
    local v5_11
    local v5_12
    local v5_13
    local v5_14
    local v5_15
    local v5_16
    local v5_17
    local v5_18
    local v5_19
    local v5_20
    local v5_21
    local v5_22
    local v5_23
    local v5_24
    local v5_25
    local v5_26
    local v5_27
    local v5_28
    local v5_29
    local v5_30
    local v5_31
    local v5_32
    local v5_33
    local v5_34
    local v5_35
    local v5_36
    local v5_37
    local v5_38
    local v5_39
    local v5_40
    local v5_41
    local v5_42
    local v5_43
    local v5_44
    local v5_45
    local v5_46
    local v5_47
    local v5_48
    local v5_49
    local v5_50
    local v5_51
    local v5_52
    local v5_53
    local v5_54
    local v5_55
    local v5_56
    local v5_57
    local v5_58
    local v5_59
    local v5_60
    local v5_61
    local v5_62
    v5_1 = Name__9828c6d9.AbilityLevelQueryParms.Avatar
    v5_2 = v5_1
    v5_3 = Name__6514b208
    v5_4 = v5_3(v5_2)
    if not (v5_4) then
        v5_7 = v5_1:Name__682cbf57()
        v5_10 = v5_7:Name__b2e22fcd()
        v5_11 = v5_10
        v5_12 = Name__6514b208
        v5_13 = v5_12(v5_11)
        if not (v5_13) then
            v5_14 = Name__9828c6d9.AbilityLevelQueryParms.Ability
            v5_17 = v5_10:Name__58012efc(v5_14)
            v5_20 = v5_10:Name__83aa2c02()
            if not (v5_20 <= v5_17) then
                v5_21 = v5_17
                v5_24 = v5_10:Name__c7fc329f(v5_21)
                if not (v5_24 <= 0) then
                    v5_26 = v5_17
                    v5_29 = v5_10:Name__9dfce5ad(v5_26)
                    v5_30 = cap_19_51_0
                    v5_31 = v5_24
                    v5_32 = v5_29
                    v5_30(v5_31, v5_32)
                    if v5_29 ~= 1 then
                        if not (v5_29 ~= 2) then
                            v5_45 = Name__9828c6d9.AbilityLevelQueryParms.Modded
                            if v5_45 then
                                v5_46 = cap_19_51_3
                                v5_47 = v5_1
                                v5_48 = v5_29
                                v5_49 = v5_46(v5_47, v5_48)
                                v19_23 = v5_49
                            end
                            v5_50 = { Label = "/Lotus/Language/Suits/SnowGlobeAbilityAugment2Name", Title = true }
                            v5_51 = p5_0
                            v5_52 = Name__6e962203.Name__c614a8c6
                            v5_52(v5_51, v5_50)
                            v5_53 = { Label = "/Lotus/Language/Labels/AVATAR_PARKOUR_BOOST", Value = 25, ValueUnit = "/Lotus/Language/Game/UNIT_PERCENT" }
                            v5_54 = p5_0
                            v5_55 = Name__6e962203.Name__c614a8c6
                            v5_55(v5_54, v5_53)
                            v5_56 = { Label = "/Lotus/Language/Game/HEALTH_PER_KILL", Value = nil, ValueUnit = "/Lotus/Language/Game/UNIT_PERCENT" }
                            v5_57 = v19_23
                            v5_58 = (v5_57 * 100)
                            v5_59 = Name__b6e30ca3.Name__d4f2b58e
                            v5_60 = v5_59(v5_58)
                            v5_56.Value = v5_60
                            v5_61 = p5_0
                            v5_62 = Name__6e962203.Name__c614a8c6
                            v5_62(v5_61, v5_56)
                        end
                        return
                    else
                        v5_34 = { Label = "/Lotus/Language/Suits/SnowGlobeAbilityAugment1Name", Title = true }
                        v5_35 = p5_0
                        v5_36 = Name__6e962203.Name__c614a8c6
                        v5_36(v5_35, v5_34)
                        v5_37 = { Label = "/Lotus/Language/Labels/WEAPON_PROC_CHANCE", Value = nil, ValueUnit = "/Lotus/Language/Game/UNIT_PERCENT" }
                        v5_38 = v19_22
                        v5_39 = (v5_38 * 100)
                        v5_40 = Name__b6e30ca3.Name__d4f2b58e
                        v5_41 = v5_40(v5_39)
                        v5_37.Value = v5_41
                        v5_42 = p5_0
                        v5_43 = Name__6e962203.Name__c614a8c6
                        v5_43(v5_42, v5_37)
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
    else
        return
    end
end
local cap_19_56_0 = v19_31
local cap_19_56_5 = v19_32
local cap_19_56_8 = v19_35
v19_36 = function()
    local v6_0
    local v6_1
    local v6_2
    local v6_3
    local v6_4
    local v6_5
    local v6_6
    local v6_7
    local v6_8
    local v6_9
    local v6_10
    local v6_11
    local v6_12
    local v6_13
    local v6_14
    local v6_15
    local v6_16
    local v6_17
    local v6_18
    local v6_19
    local v6_20
    local v6_21
    local v6_22
    local v6_23
    local v6_24
    local v6_25
    local v6_26
    local v6_27
    local v6_28
    local v6_29
    local v6_30
    local v6_31
    local v6_32
    local v6_33
    local v6_34
    local v6_35
    local v6_36
    local v6_37
    local v6_38
    local v6_39
    local v6_40
    local v6_41
    local v6_42
    local v6_43
    local v6_44
    local v6_45
    local v6_46
    local v6_47
    local v6_48
    local v6_49
    local v6_50
    local v6_51
    local v6_52
    local v6_53
    local v6_54
    local v6_55
    local v6_56
    local v6_57
    local v6_58
    local v6_59
    local v6_60
    v6_0 = cap_19_56_0
    v6_1 = Name__9828c6d9.AbilityLevelQueryParms.Level
    v6_0(v6_1)
    v6_2 = Name__9828c6d9.AbilityLevelQueryParms.Modded
    if v6_2 ~= true then
        v6_13 = Name__9828c6d9.AbilityLevelQueryParms.Avatar
        v6_14 = Name__6514b208
        v6_15 = v6_14(v6_13)
        if not (v6_15) then
            v6_16 = Name__9828c6d9.AbilityLevelQueryParms.Avatar
            v6_19 = v6_16:Name__682cbf57()
            v6_22 = v6_19:Name__b2e22fcd()
            v6_23 = v6_22
            v6_24 = Name__6514b208
            v6_25 = v6_24(v6_23)
            if not (v6_25) then
                v6_26 = v19_16
                v6_29 = v6_22:Name__cc743631()
                v6_30 = v19_15
                v6_31 = (v6_29 * v6_30)
                v6_32 = (v6_26 + v6_31)
                v19_16 = v6_32
            end
        end
    else
        v6_3 = cap_19_56_5
        v6_4 = Name__9828c6d9.AbilityLevelQueryParms.Avatar
        v6_5, v6_6, v6_7, v6_8 = v6_3(v6_4)
        v19_16 = v6_5
        v19_20 = v6_6
        v19_19 = v6_7
        v19_21 = v6_8
        v6_9 = v19_21
        v6_12 = v6_9:Name__8a0e346e()
        v19_21 = v6_12
    end
    v6_33 = {}
    v6_34 = { Label = "/Lotus/Language/Game/ABILITY_RADIUS", Value = nil, ValueUnit = "/Lotus/Language/Game/UNIT_METER" }
    v6_35 = v19_20
    v6_34.Value = v6_35
    v6_36 = v6_33
    v6_37 = Name__6e962203.Name__c614a8c6
    v6_37(v6_36, v6_34)
    v6_38 = { Label = "/Lotus/Language/Suits/FreezePerSecond", Value = 0.3333333333333333, ValueIcon = "<DT_FREEZE>" }
    v6_39 = v6_33
    v6_40 = Name__6e962203.Name__c614a8c6
    v6_40(v6_39, v6_38)
    v6_41 = { Label = "/Lotus/Language/Suits/FreezeDuration", Value = nil, ValueIcon = "<DT_FREEZE>", ValueUnit = "/Lotus/Language/Game/UNIT_SECOND" }
    v6_42 = v19_19
    v6_41.Value = v6_42
    v6_43 = v6_33
    v6_44 = Name__6e962203.Name__c614a8c6
    v6_44(v6_43, v6_41)
    v6_45 = { Label = "/Lotus/Language/Game/HEALTH", Value = nil }
    v6_46 = v19_16
    v6_45.Value = v6_46
    v6_47 = v6_33
    v6_48 = Name__6e962203.Name__c614a8c6
    v6_48(v6_47, v6_45)
    v6_49 = { Label = "/Lotus/Language/Game/INVULNERABILITY_DUARTION", Value = nil, ValueUnit = "/Lotus/Language/Game/UNIT_SECOND" }
    v6_50 = v19_17
    v6_49.Value = v6_50
    v6_51 = v6_33
    v6_52 = Name__6e962203.Name__c614a8c6
    v6_52(v6_51, v6_49)
    v6_53 = { Label = "/Lotus/Language/Game/AOE_DAMAGE", Value = nil, ValueIcon = "<DT_FREEZE>" }
    v6_54 = v19_21
    v6_53.Value = v6_54
    v6_55 = v6_33
    v6_56 = Name__6e962203.Name__c614a8c6
    v6_56(v6_55, v6_53)
    v6_57 = cap_19_56_8
    v6_58 = v6_33
    v6_57(v6_58)
    v6_59 = Name__9828c6d9.AbilityLevelQueryParms.Modded
    v6_33.Modded = v6_59
    v6_60 = Name__9828c6d9
    v6_60.AbilityUpgradeLevelInfo = v6_33
    return
end
GetAbilityUpgradeLevelInfo = v19_36
local cap_19_67_0 = v19_33
v19_37 = function(p7_0, p7_1)
    local v7_2
    local v7_3
    local v7_4
    local v7_5
    local v7_6
    local v7_7
    local v7_8
    local v7_9
    local v7_10
    local v7_11
    local v7_12
    local v7_13
    local v7_14
    local v7_15
    local v7_16
    local v7_17
    local v7_18
    local v7_19
    local v7_20
    local v7_21
    local v7_22
    local v7_23
    local v7_24
    v7_2 = {}
    v7_3 = cap_19_67_0
    v7_4 = p7_0
    v7_5 = p7_1
    v7_3(v7_4, v7_5)
    if p7_1 ~= 1 then
        if not (p7_1 ~= 2) then
            v7_14 = { HEALTH_PER_KILL = nil }
            v7_15 = v19_23
            v7_16 = (v7_15 * 100)
            v7_17 = Name__b6e30ca3.Name__d4f2b58e
            v7_18 = v7_17(v7_16)
            v7_14.HEALTH_PER_KILL = v7_18
            v7_2 = v7_14
        end
    else
        v7_7 = { FROZEN_PCT = nil, DURATION = nil }
        v7_8 = v19_22
        v7_9 = (v7_8 * 100)
        v7_10 = Name__b6e30ca3.Name__d4f2b58e
        v7_11 = v7_10(v7_9)
        v7_7.FROZEN_PCT = v7_11
        v7_12 = v19_19
        v7_7.DURATION = v7_12
        v7_2 = v7_7
    end
    v7_19 = Name__3990010e.Name__84eaa3ce
    v7_20 = v7_2
    return v7_19(v7_20)
end
GetAugmentDescriptionInfo = v19_37
v19_38 = function(p8_0, p8_1, p8_2)
    local v8_3
    local v8_4
    local v8_5
    local v8_6
    local v8_7
    local v8_8
    local v8_9
    local v8_10
    local v8_11
    local v8_12
    local v8_13
    local v8_14
    local v8_15
    local v8_16
    local v8_17
    local v8_18
    local v8_19
    local v8_20
    local v8_21
    local v8_22
    local v8_23
    local v8_24
    local v8_25
    local v8_26
    local v8_27
    local v8_28
    local v8_29
    local v8_30
    v8_5 = p8_1:Name__402a3166()
    v8_8 = v8_5:Name__3e99536f()
    v8_11 = p8_1:Name__636bf764()
    if 0.25 < v8_8 then
        if not (0.5 < v8_11) then
        else
            return 0
        end
    end
    v8_15 = p8_2
    v8_16 = Name__6514b208
    v8_17 = v8_16(v8_15)
    if v8_17 then
        p8_2 = 1
    end
    v8_18 = Name__b364fd20
    v8_19 = Name__96d3309e
    v8_20 = (v8_19)[p8_2]
    v8_23 = v8_18:Name__45a25bce(v8_20)
    v8_24 = v8_23
    v8_25 = Name__6514b208
    v8_26 = v8_25(v8_24)
    if not (v8_26) then
        v8_27 = (#v8_23)
        if not (0 < v8_27) then
        else
            return 0
        end
    end
    return 1.5
end
NpcEvaluateAbility = v19_38
v19_39 = function(p9_0, p9_1)
    local v9_2
    local v9_3
    local v9_4
    local v9_5
    local v9_6
    local v9_7
    local v9_8
    local v9_9
    local v9_10
    local v9_11
    local v9_12
    local v9_13
    local v9_14
    local v9_15
    local v9_16
    local v9_17
    v9_4 = p9_1:Name__d8e31809()
    v9_5 = Name__5d59c07d
    v9_6 = v9_4
    v9_7 = v9_5(v9_6)
    v9_10 = p9_1:Name__65be499d()
    v9_11 = (v9_7 + v9_10)
    v9_12 = (v9_11).y
    v9_13 = (v9_12 + 1.1)
    v9_11.y = v9_13
    v9_14 = v9_11
    p9_0:Name__2d1b0aca(v9_14)
    return true
end
EvaluateAbility = v19_39
local cap_19_77_0 = v19_2
v19_40 = function(p10_0, p10_1)
    local v10_2
    local v10_3
    local v10_4
    local v10_5
    local v10_6
    local v10_7
    local v10_8
    local v10_9
    local v10_10
    local v10_11
    local v10_12
    v10_2 = cap_19_77_0
    v10_3 = (v10_2).Name__a34fa566
    v10_4 = v10_3()
    if v10_4 then
        v10_5 = Name__20bbc0cd
        v10_6 = Name__d7e3ec85
        v10_9 = v10_6:Name__95ce4bc4()
        v10_10 = (v10_9 + 100)
        v10_5:Name__722de996(v10_10)
    end
    return
end
InitializeAbility = v19_40
local cap_19_80_0 = v19_5
v19_41 = function(p11_0, p11_1, p11_2, p11_3, p11_4, p11_5, p11_6)
    local v11_7
    local v11_8
    local v11_9
    local v11_10
    local v11_11
    local v11_12
    local v11_13
    local v11_14
    local v11_15
    local v11_16
    local v11_17
    local v11_18
    local v11_19
    local v11_20
    local v11_21
    local v11_22
    local v11_23
    local v11_24
    local v11_25
    local v11_26
    local v11_27
    local v11_28
    local v11_29
    local v11_30
    local v11_31
    local v11_32
    local v11_33
    local v11_34
    local v11_35
    local v11_36
    local v11_37
    local v11_38
    local v11_39
    local v11_40
    local v11_41
    local v11_42
    local v11_43
    local v11_44
    local v11_45
    local v11_46
    local v11_47
    local v11_48
    local v11_49
    local v11_50
    local v11_51
    local v11_52
    local v11_53
    local v11_54
    local v11_55
    local v11_56
    local v11_57
    local v11_58
    local v11_59
    local v11_60
    local v11_61
    local v11_62
    local v11_63
    local v11_64
    local v11_65
    local v11_66
    local v11_67
    local v11_68
    local v11_69
    local v11_70
    local v11_71
    local v11_72
    local v11_73
    local v11_74
    local v11_75
    local v11_76
    local v11_77
    local v11_78
    local v11_79
    local v11_80
    local v11_81
    local v11_82
    local v11_83
    local v11_84
    local v11_85
    local v11_86
    local v11_87
    local v11_88
    local v11_89
    local v11_90
    local v11_91
    local v11_92
    local v11_93
    local v11_94
    local v11_95
    local v11_96
    local v11_97
    local v11_98
    local v11_99
    local v11_100
    local v11_101
    local v11_102
    local v11_103
    local v11_104
    local v11_105
    local v11_106
    local v11_107
    local v11_108
    local v11_109
    local v11_110
    local v11_111
    local v11_112
    local v11_113
    local v11_114
    local v11_115
    local v11_116
    local v11_117
    if p11_1 ~= p11_3 then
        v11_25 = Name__b364fd20
        v11_26 = Name__3df6d685
        v11_36 = p11_0:Name__f88aefc6(v11_26("IceShieldCast"))
        v11_37 = p11_4
        v11_38 = p11_5
        v11_39 = p11_3
        v11_25:Name__86603178(v11_36, v11_37, v11_38, v11_39)
        v11_42 = Name__b364fd20
        v11_43 = Name__1cba3673
        v11_44 = p11_4
        v11_42:Name__c48cfabb(v11_43, v11_44, false, 0)
    else
        v11_7 = Name__3df6d685
        v11_17 = p11_0:Name__f88aefc6(v11_7("IceShieldCast"))
        v11_18 = Name__f6aba2d9
        p11_1:Name__f275c3f8(v11_17, v11_18)
        v11_21 = Name__1cba3673
        p11_1:Name__c48cfabb(v11_21, false)
    end
    v11_49 = Name__b364fd20
    v11_52 = v11_49:Name__ce228771()
    if v11_52 then
        v11_53 = Name__96d3309e
        v11_54 = Name__20bbc0cd
        v11_71 = p11_2:Name__d90ea404(p11_2:Name__58012efc(v11_54:Name__bab6c411()))
        v11_72 = (v11_53)[v11_71]
        v11_73 = nil
        if not (p11_6) then
            v11_90 = Name__b364fd20
            v11_91 = v11_72
            v11_92 = p11_4
            v11_93 = p11_5
            v11_94 = p11_1
            v11_97 = v11_90:Name__86603178(v11_91, v11_92, v11_93, v11_94)
            v11_89 = v11_97
        else
            v11_76 = p11_1:Name__402a3166()
            v11_80 = v11_76:Name__ccefdb4a(0)
            v11_81 = v11_72
            v11_82 = v11_80
            v11_83 = Name__3f3779af
            v11_84 = Name__3b0d8a4c
            v11_85 = p11_1
            v11_88 = p11_1:Name__f275c3f8(v11_81, v11_82, v11_83, v11_84, v11_85)
            v11_89 = v11_88
        end
        v11_98 = v11_89
        v11_99 = Name__6514b208
        v11_100 = v11_99(v11_98)
        if not (v11_100) then
            v11_101 = Name__20bbc0cd
            v11_102 = v11_89
            v11_101:Name__e1a37b54(v11_102)
            if not (p11_6) then
                v11_105 = cap_19_80_0
                v11_106 = (v11_105).Name__8e8dc7ef
                v11_107 = v11_89
                v11_110 = v11_89:Name__3ca198c7()
                v11_111 = Name__76c01753
                v11_115 = v11_111(0, 0.5, 0)
                v11_116 = (v11_110 + v11_115)
                v11_106(v11_107, v11_116, true)
            end
        end
    end
    return
end
local cap_19_82_0 = v19_31
local cap_19_82_5 = v19_32
local cap_19_82_7 = v19_33
local cap_19_82_9 = v19_34
local cap_19_82_10 = v19_5
local cap_19_82_11 = v19_41
v19_42 = function(p12_0, p12_1, p12_2, p12_3, p12_4)
    local v12_5
    local v12_6
    local v12_7
    local v12_8
    local v12_9
    local v12_10
    local v12_11
    local v12_12
    local v12_13
    local v12_14
    local v12_15
    local v12_16
    local v12_17
    local v12_18
    local v12_19
    local v12_20
    local v12_21
    local v12_22
    local v12_23
    local v12_24
    local v12_25
    local v12_26
    local v12_27
    local v12_28
    local v12_29
    local v12_30
    local v12_31
    local v12_32
    local v12_33
    local v12_34
    local v12_35
    local v12_36
    local v12_37
    local v12_38
    local v12_39
    local v12_40
    local v12_41
    local v12_42
    local v12_43
    local v12_44
    local v12_45
    local v12_46
    local v12_47
    local v12_48
    local v12_49
    local v12_50
    local v12_51
    local v12_52
    local v12_53
    local v12_54
    local v12_55
    local v12_56
    local v12_57
    local v12_58
    local v12_59
    local v12_60
    local v12_61
    local v12_62
    local v12_63
    local v12_64
    local v12_65
    local v12_66
    local v12_67
    local v12_68
    local v12_69
    local v12_70
    local v12_71
    local v12_72
    local v12_73
    local v12_74
    local v12_75
    local v12_76
    local v12_77
    local v12_78
    local v12_79
    local v12_80
    local v12_81
    local v12_82
    local v12_83
    local v12_84
    local v12_85
    local v12_86
    local v12_87
    local v12_88
    local v12_89
    local v12_90
    local v12_91
    local v12_92
    local v12_93
    local v12_94
    local v12_95
    local v12_96
    local v12_97
    local v12_98
    local v12_99
    local v12_100
    local v12_101
    local v12_102
    local v12_103
    local v12_104
    local v12_105
    local v12_106
    local v12_107
    local v12_108
    local v12_109
    local v12_110
    local v12_111
    local v12_112
    local v12_113
    local v12_114
    local v12_115
    local v12_116
    local v12_117
    local v12_118
    local v12_119
    local v12_120
    local v12_121
    local v12_122
    local v12_123
    v12_5 = cap_19_82_0
    v12_6 = p12_3
    v12_5(v12_6)
    v12_7 = cap_19_82_5
    v12_8 = p12_1
    v12_9, v12_10, v12_11, v12_12 = v12_7(v12_8)
    v19_16 = v12_9
    v19_20 = v12_10
    v19_19 = v12_11
    v19_21 = v12_12
    v12_13 = { maxHealth = nil, shieldRange = nil, invulnDuration = nil, shatterDamage = nil }
    v12_14 = v19_16
    v12_13.maxHealth = v12_14
    v12_15 = v19_20
    v12_13.shieldRange = v12_15
    v12_16 = v19_17
    v12_13.invulnDuration = v12_16
    v12_17 = v19_21
    v12_13.shatterDamage = v12_17
    v12_18 = false
    v12_21 = p12_0:Name__c7fc329f()
    v12_24 = p12_0:Name__9dfce5ad()
    if 0 < v12_21 then
        local sc_12_1
        if v12_24 == 1 then
            sc_12_1 = true
        else
            sc_12_1 = not (v12_24 ~= 2)
        end
        if sc_12_1 then
            v12_28 = cap_19_82_7
            v12_29 = v12_21
            v12_30 = v12_24
            v12_28(v12_29, v12_30)
            v12_31 = cap_19_82_9
            v12_32 = p12_1
            v12_33 = v12_24
            v12_34 = v12_31(v12_32, v12_33)
            v19_23 = v12_34
            if v12_24 == 2 then
                v12_18 = true
            else
                v12_18 = false
            end
        end
    end
    v12_36 = Name__20bbc0cd
    v12_39 = v12_36:Name__4690e5a2()
    v12_42 = p12_1:Name__682cbf57()
    v12_43 = Name__b364fd20
    v12_46 = v12_43:Name__ce228771()
    if v12_46 then
        v12_47 = v12_39
        v12_50 = v12_42:Name__2f0c9e81(v12_47)
        if not (v12_50) then
            v12_51 = v12_39
            v12_54 = v19_19
            v12_55 = (v12_54 - 3)
            v12_56 = Name__20bbc0cd
            v12_59 = v12_56:Name__bab6c411()
            v12_62 = Name__3df6d685
            v12_64 = v12_62("FrozenSolid")
            v12_42:Name__56a2305f(v12_51, 370, 0, v12_55, v12_59, nil, 25, v12_64, 4)
        end
    end
    v12_68 = cap_19_82_10
    v12_69 = (v12_68).Name__6e44af97
    v12_70 = p12_0
    v12_72 = v12_13
    v12_69(v12_70, "IceShield", v12_72)
    v12_75 = p12_1:Name__d8e31809()
    v12_78 = p12_1:Name__bef01360()
    v12_79 = v12_75
    v12_78:Name__409a3949(v12_79)
    v12_82 = cap_19_82_10
    v12_83 = (v12_82).Name__dcbe841c
    v12_84 = p12_0
    v12_85 = Name__f8261964
    v12_83(v12_84, v12_85, "Shield", false, 2, 1, true)
    v12_102 = Name__6514b208
    v12_103 = v12_102(p12_1:Name__b7f5db56())
    if not (v12_103) then
        v12_104 = Name__5d59c07d
        v12_105 = v12_75
        v12_106 = v12_104(v12_105)
        v12_109 = p12_1:Name__65be499d()
        p12_4 = (v12_106 + v12_109)
        v12_110 = (p12_4).y
        v12_111 = (v12_110 + 1.1)
        p12_4.y = v12_111
    end
    v12_114 = p12_1:Name__d8e31809()
    v12_114.pitch = 0
    v12_116 = cap_19_82_11
    v12_117 = p12_0
    v12_118 = p12_1
    v12_119 = p12_0
    v12_120 = p12_1
    v12_121 = p12_4
    v12_122 = v12_114
    v12_123 = v12_18
    v12_116(v12_117, v12_118, v12_119, v12_120, v12_121, v12_122, v12_123)
    return
end
ActivateAbility = v19_42
local cap_19_96_0 = v19_31
local cap_19_96_3 = v19_32
v19_43 = function()
    local v13_0
    local v13_1
    local v13_2
    local v13_3
    local v13_4
    local v13_5
    local v13_6
    local v13_7
    local v13_8
    local v13_9
    local v13_10
    local v13_11
    local v13_12
    local v13_13
    local v13_14
    local v13_15
    local v13_16
    local v13_17
    local v13_18
    local v13_19
    local v13_20
    local v13_21
    local v13_22
    local v13_23
    local v13_24
    local v13_25
    local v13_26
    local v13_27
    local v13_28
    local v13_29
    local v13_30
    local v13_31
    local v13_32
    local v13_33
    local v13_34
    local v13_35
    local v13_36
    local v13_37
    local v13_38
    local v13_39
    local v13_40
    v13_0 = Name__9828c6d9.CrewShipAbilityInfo.mAbility
    v13_3 = v13_0:Name__7234d87e()
    v13_4 = cap_19_96_0
    v13_4(v13_3:Name__d90ea404(v13_3:Name__58012efc(v13_0:Name__bab6c411())))
    v13_23 = cap_19_96_3
    v13_32, v13_33 = v13_23(v13_3:Name__8c362f50())
    v19_16 = v13_32
    v19_20 = v13_33
    v13_34 = Name__9828c6d9.CrewShipAbilityInfo
    v13_35 = { Radius = nil, EnergyCost = nil }
    v13_36 = v19_20
    v13_35.Radius = v13_36
    v13_40 = v13_0:Name__0a844e4e(true)
    v13_35.EnergyCost = v13_40
    v13_34.mAbilityInfo = v13_35
    return
end
CrewShipInfo = v19_43
local cap_19_102_0 = v19_5
local cap_19_102_1 = v19_31
local cap_19_102_6 = v19_32
local cap_19_102_8 = v19_41
v19_44 = function(p14_0, p14_1, p14_2, p14_3, p14_4, p14_5, p14_6)
    local v14_7
    local v14_8
    local v14_9
    local v14_10
    local v14_11
    local v14_12
    local v14_13
    local v14_14
    local v14_15
    local v14_16
    local v14_17
    local v14_18
    local v14_19
    local v14_20
    local v14_21
    local v14_22
    local v14_23
    local v14_24
    local v14_25
    local v14_26
    local v14_27
    local v14_28
    local v14_29
    local v14_30
    local v14_31
    local v14_32
    local v14_33
    local v14_34
    local v14_35
    local v14_36
    local v14_37
    local v14_38
    local v14_39
    local v14_40
    local v14_41
    local v14_42
    local v14_43
    local v14_44
    local v14_45
    local v14_46
    local v14_47
    local v14_48
    local v14_49
    local v14_50
    local v14_51
    local v14_52
    local v14_53
    local v14_54
    local v14_55
    local v14_56
    v14_7 = Name__20bbc0cd
    v14_10 = v14_7:Name__bab6c411()
    v14_13 = v14_10:Name__50b0e03d()
    v14_14 = cap_19_102_0
    v14_15 = (v14_14).Name__fe1fea46
    v14_16 = v14_13
    v14_17 = v14_15(v14_16)
    if not (v14_17) then
        v14_19 = cap_19_102_1
        v14_20 = p14_4
        v14_19(v14_20)
        v14_21 = cap_19_102_6
        v14_22 = p14_3
        v14_23, v14_24, v14_25, v14_26 = v14_21(v14_22)
        v19_16 = v14_23
        v19_20 = v14_24
        v19_19 = v14_25
        v19_21 = v14_26
        v14_27 = { maxHealth = nil, shieldRange = nil, invulnDuration = nil, shatterDamage = nil }
        v14_28 = v19_16
        v14_27.maxHealth = v14_28
        v14_29 = v19_20
        v14_27.shieldRange = v14_29
        v14_30 = v19_17
        v14_27.invulnDuration = v14_30
        v14_31 = v19_21
        v14_27.shatterDamage = v14_31
        v14_32 = cap_19_102_0
        v14_33 = (v14_32).Name__6e44af97
        v14_34 = p14_1
        v14_36 = v14_27
        v14_33(v14_34, "IceShield", v14_36)
        v14_37 = cap_19_102_8
        v14_38 = p14_1
        v14_39 = p14_0
        v14_40 = p14_2
        v14_41 = p14_3
        v14_42 = p14_6
        v14_43 = Name__0b53c522
        v14_44 = Name__2510ee3d
        v14_47 = v14_44(0, 360)
        v14_37(v14_38, v14_39, v14_40, v14_41, v14_42, v14_43(v14_47, 0, 0))
        v14_54 = cap_19_102_0
        v14_55 = (v14_54).Name__1c00e12c
        v14_56 = v14_13
        v14_55(v14_56)
        return
    else
        return true
    end
end
CrewShipActivate = v19_44
v19_45 = function(p15_0, p15_1)
    local v15_2
    local v15_3
    local v15_4
    local v15_5
    local v15_6
    local v15_7
    v15_2 = 1
    v15_3 = (#p15_1)
    v15_4 = 1
    for v15_2 = v15_2, v15_3, v15_4 do
        v15_5 = (p15_1)[v15_2]
        if not (v15_5 ~= p15_0) then
            return true
        end
    end
    return false
end
v19_46 = function(p16_0, p16_1, p16_2)
    local v16_3
    local v16_4
    local v16_5
    local v16_6
    local v16_7
    local v16_8
    local v16_9
    local v16_10
    local v16_11
    local v16_12
    local v16_13
    local v16_14
    local v16_15
    local v16_16
    local v16_17
    local v16_18
    local v16_19
    local v16_20
    local v16_21
    local v16_22
    local v16_23
    local v16_24
    local v16_25
    local v16_26
    local v16_27
    local v16_28
    local v16_29
    local v16_30
    local v16_31
    local v16_32
    local v16_33
    local v16_34
    local v16_35
    local v16_36
    local v16_37
    local v16_38
    local v16_39
    local v16_40
    local v16_41
    local v16_42
    local v16_43
    local v16_44
    local v16_45
    local v16_46
    local v16_47
    local v16_48
    local v16_49
    local v16_50
    local v16_51
    local v16_52
    local v16_53
    local v16_54
    local v16_55
    local v16_56
    local v16_57
    local v16_58
    local v16_59
    local v16_60
    local v16_61
    local v16_62
    local v16_63
    local v16_64
    local v16_65
    local v16_66
    local v16_67
    local v16_68
    local v16_69
    local v16_70
    local v16_71
    local v16_72
    local v16_73
    local v16_74
    local v16_75
    local v16_76
    local v16_77
    local v16_78
    v16_5 = p16_0:Name__7107e6c8()
    v16_6 = v16_5
    v16_7 = Name__6514b208
    v16_8 = v16_7(v16_6)
    if not (v16_8) then
        v16_11 = v16_5:Name__682cbf57()
        v16_14 = v16_11:Name__b2e22fcd()
        v16_15 = v16_14
        v16_16 = Name__6514b208
        v16_17 = v16_16(v16_15)
        if not (v16_17) then
            v16_18 = Name__b364fd20
            v16_19 = Name__280f302c
            v16_22 = p16_0:Name__3ca198c7()
            v16_25 = p16_0:Name__c92bc52f()
            v16_26 = v16_5
            v16_29 = v16_18:Name__86603178(v16_19, v16_22, v16_25, v16_26)
            v16_29:Name__9f3d68a0(p16_0:Name__af35e5c4())
            v16_39 = v16_5:Name__35302b3f()
            if v16_39 then
                if 0 < p16_1 then
                    v16_41 = Name__5ebaa8da.Name__337afdb0
                    v16_42 = v16_41()
                    v16_43 = v16_5
                    v16_42:Name__a3f45f18(v16_43)
                    v16_42:Name__9efafcef(p16_0:Name__3ca198c7())
                    v16_52 = p16_2
                    v16_42:Name__f8ac5a33(v16_52)
                    v16_55 = (p16_1 * 1.3)
                    v16_42.radius = v16_55
                    v16_42:Name__4f67a88c(4, 1)
                    v16_42.ignoreEntity = p16_0
                    v16_60 = v16_14
                    v16_42:Name__47cb1af5(v16_60)
                    v16_42:Name__3d8e91b5(20, true)
                    v16_42:Name__cb11565a(4, 3)
                    v16_42.checkForCover = false
                    v16_42.staticCoverOnly = false
                    v16_42.fallOff = 0
                    v16_42.hostAuthoritative = false
                    v16_75 = Name__b364fd20
                    v16_76 = v16_42
                    v16_75:Name__ba9b0b7b(v16_76)
                end
            end
            return
        else
            return
        end
    else
        return
    end
end
local cap_19_115_0 = v19_5
local cap_19_115_3 = v19_2
local cap_19_115_4 = v19_29
local cap_19_115_5 = v19_33
local cap_19_115_7 = v19_26
local cap_19_115_8 = v19_11
local cap_19_115_9 = v19_14
local cap_19_115_10 = v19_8
local cap_19_115_12 = v19_46
v19_47 = function(p17_0)
    local frame_17 = {}
    local cfg_17 = 0
    while true do
        if cfg_17 == 0 then
            p17_0:Name__0f2113b8(1)
            frame_17[6] = p17_0:Name__7107e6c8()
            frame_17[7] = frame_17[6]
            frame_17[8] = Name__6514b208
            frame_17[9] = frame_17[8](frame_17[7])
            if not (frame_17[9]) then
                cfg_17 = 4
            else
                cfg_17 = 1
            end
        elseif cfg_17 == 1 then
            frame_17[10] = Name__b364fd20
            frame_17[13] = (frame_17[10]):Name__ce228771()
            if not (frame_17[13]) then
                cfg_17 = 3
            else
                cfg_17 = 2
            end
        elseif cfg_17 == 2 then
            p17_0:Name__9c6a9ac9()
            cfg_17 = 3
        elseif cfg_17 == 3 then
            return
        elseif cfg_17 == 4 then
            frame_17[18] = (frame_17[6]):Name__682cbf57()
            frame_17[21] = (frame_17[18]):Name__b2e22fcd()
            frame_17[22] = frame_17[21]
            frame_17[23] = Name__6514b208
            frame_17[24] = frame_17[23](frame_17[22])
            if not (frame_17[24]) then
                cfg_17 = 8
            else
                cfg_17 = 5
            end
        elseif cfg_17 == 5 then
            frame_17[25] = Name__b364fd20
            frame_17[28] = (frame_17[25]):Name__ce228771()
            if not (frame_17[28]) then
                cfg_17 = 7
            else
                cfg_17 = 6
            end
        elseif cfg_17 == 6 then
            p17_0:Name__9c6a9ac9()
            cfg_17 = 7
        elseif cfg_17 == 7 then
            return
        elseif cfg_17 == 8 then
            frame_17[31] = p17_0
            do (frame_17[21]):Name__c9c04883(frame_17[31]) end
            frame_17[34] = Name__b364fd20
            frame_17[37] = (frame_17[34]):Name__ce228771()
            frame_17[40] = p17_0:Name__3ca198c7()
            frame_17[43] = (frame_17[6]):Name__33d67970()
            frame_17[44] = Name__e9daf057
            frame_17[47] = (frame_17[21]):Name__2888fc5c(frame_17[44])
            if frame_17[47] then
                cfg_17 = 10
            else
                cfg_17 = 9
            end
        elseif cfg_17 == 9 then
            frame_17[51] = (frame_17[21]):Name__88cc409d(2)
            if frame_17[51] then
                cfg_17 = 11
            else
                cfg_17 = 10
            end
        elseif cfg_17 == 10 then
            frame_17[51] = nil
            cfg_17 = 11
        elseif cfg_17 == 11 then
            frame_17[55] = (frame_17[21]):Name__c7fc329f(2)
            frame_17[59] = (frame_17[21]):Name__9dfce5ad(2)
            frame_17[60] = false
            if not (0 < frame_17[55]) then
                cfg_17 = 15
            else
                cfg_17 = 12
            end
        elseif cfg_17 == 12 then
            if frame_17[59] == 2 then
                cfg_17 = 14
            else
                cfg_17 = 13
            end
        elseif cfg_17 == 13 then
            frame_17[60] = false
            cfg_17 = 15
        elseif cfg_17 == 14 then
            frame_17[60] = true
            cfg_17 = 15
        elseif cfg_17 == 15 then
            frame_17[63] = Name__45655ea6
            frame_17[64] = Name__f6aba2d9
            frame_17[65] = Name__3f3779af
            frame_17[66] = Name__3b0d8a4c
            frame_17[67] = frame_17[21]
            p17_0:Name__f275c3f8(frame_17[63], frame_17[64], frame_17[65], frame_17[66], frame_17[67])
            frame_17[70] = cap_19_115_0
            frame_17[71] = (frame_17[70]).Name__cbbd4ec1
            frame_17[72] = frame_17[21]
            frame_17[76] = frame_17[71](frame_17[72], "IceShield", 2, true)
            frame_17[77] = frame_17[21]
            frame_17[78] = Name__6514b208
            frame_17[79] = frame_17[78](frame_17[77])
            if frame_17[79] then
                cfg_17 = 18
            else
                cfg_17 = 16
            end
        elseif cfg_17 == 16 then
            frame_17[80] = frame_17[6]
            frame_17[81] = Name__6514b208
            frame_17[82] = frame_17[81](frame_17[80])
            if frame_17[82] then
                cfg_17 = 18
            else
                cfg_17 = 17
            end
        elseif cfg_17 == 17 then
            frame_17[83] = frame_17[76]
            frame_17[84] = Name__6514b208
            frame_17[85] = frame_17[84](frame_17[83])
            if not (frame_17[85]) then
                cfg_17 = 21
            else
                cfg_17 = 18
            end
        elseif cfg_17 == 18 then
            if not (frame_17[37]) then
                cfg_17 = 20
            else
                cfg_17 = 19
            end
        elseif cfg_17 == 19 then
            p17_0:Name__9c6a9ac9()
            cfg_17 = 20
        elseif cfg_17 == 20 then
            return
        elseif cfg_17 == 21 then
            frame_17[88] = v19_20
            frame_17[89] = (frame_17[76]).maxHealth
            frame_17[90] = (frame_17[76]).shieldRange
            frame_17[91] = (frame_17[76]).shatterDamage
            frame_17[92] = (frame_17[76]).invulnDuration
            v19_17 = frame_17[92]
            if not (frame_17[37]) then
                cfg_17 = 23
            else
                cfg_17 = 22
            end
        elseif cfg_17 == 22 then
            p17_0:Name__0f12b923()
            p17_0:Name__cf06651f(false)
            p17_0:Name__a37322ec(1000000, true)
            cfg_17 = 23
        elseif cfg_17 == 23 then
            frame_17[102] = cap_19_115_3
            frame_17[103] = (frame_17[102]).Name__4369ab26
            frame_17[104] = frame_17[103]()
            if not (frame_17[104]) then
                cfg_17 = 29
            else
                cfg_17 = 24
            end
        elseif cfg_17 == 24 then
            frame_17[105] = Name__b364fd20
            frame_17[106] = Name__6e6b3a27
            frame_17[107] = frame_17[40]
            frame_17[109] = frame_17[90]
            frame_17[112] = (frame_17[105]):Name__45a25bce(frame_17[106], frame_17[107], 0, frame_17[109])
            frame_17[113] = 1
            frame_17[114] = (#frame_17[112])
            frame_17[115] = 1
            local leave_for_17_25 = false
            for for_value_17_25 = frame_17[113], frame_17[114], frame_17[115] do
                frame_17[113] = for_value_17_25
                cfg_17 = 25
                while true do
                    if cfg_17 == 25 then
                        frame_17[116] = (frame_17[112])[frame_17[113]]
                        frame_17[119] = (frame_17[116]):Name__7f7b27a9()
                        if not (frame_17[119]) then
                            cfg_17 = 28
                        else
                            cfg_17 = 26
                        end
                    elseif cfg_17 == 26 then
                        frame_17[120] = cap_19_115_3
                        frame_17[121] = (frame_17[120]).Name__e81dbfc2
                        frame_17[122] = frame_17[6]
                        frame_17[123] = frame_17[116]
                        frame_17[124] = frame_17[121](frame_17[122], frame_17[123])
                        if not (frame_17[124]) then
                            cfg_17 = 28
                        else
                            cfg_17 = 27
                        end
                    elseif cfg_17 == 27 then
                        frame_17[127] = (frame_17[116]):Name__bef01360()
                        do (frame_17[127]):Name__424cec65(100) end
                        frame_17[133] = (frame_17[116]):Name__3ca198c7()
                        frame_17[136] = (frame_17[6]):Name__3ca198c7()
                        frame_17[137] = (frame_17[133] - frame_17[136])
                        frame_17[138] = Name__39273653
                        frame_17[139] = frame_17[137]
                        frame_17[140] = frame_17[138](frame_17[139])
                        frame_17[143] = (frame_17[116]):Name__bef01360()
                        frame_17[144] = (frame_17[137] / frame_17[140])
                        frame_17[145] = (frame_17[144] * 15)
                        frame_17[147] = (frame_17[140] / frame_17[90])
                        frame_17[148] = (1 - frame_17[147])
                        frame_17[149] = Name__b6e30ca3.Name__4042c2a4
                        frame_17[150] = frame_17[149](0.4, frame_17[148])
                        frame_17[151] = (frame_17[145] * frame_17[150])
                        do (frame_17[143]):Name__de405722(frame_17[151]) end
                        cfg_17 = 28
                    elseif cfg_17 == 28 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_17_25 then break end
            end
            if not leave_for_17_25 then
                cfg_17 = 29
            end
        elseif cfg_17 == 29 then
            if not (frame_17[37]) then
                cfg_17 = 40
            else
                cfg_17 = 30
            end
        elseif cfg_17 == 30 then
            if not (frame_17[60]) then
                cfg_17 = 32
            else
                cfg_17 = 31
            end
        elseif cfg_17 == 31 then
            frame_17[156] = (frame_17[6]):Name__3ca198c7()
            cfg_17 = 33
        elseif cfg_17 == 32 then
            frame_17[156] = p17_0:Name__3ca198c7()
            cfg_17 = 33
        elseif cfg_17 == 33 then
            frame_17[159] = Name__b364fd20
            frame_17[160] = Name__d48bf954
            frame_17[161] = frame_17[40]
            frame_17[163] = frame_17[90]
            frame_17[166] = (frame_17[159]):Name__45a25bce(frame_17[160], frame_17[161], 0, frame_17[163])
            frame_17[167] = Name__d06efad8
            frame_17[168] = frame_17[166]
            frame_17[169], frame_17[170], frame_17[171] = frame_17[167](frame_17[168])
            local leave_for_17_39 = false
            for for_value_17_39_0, for_value_17_39_1 in frame_17[169], frame_17[170], frame_17[171] do
                frame_17[249], frame_17[250] = for_value_17_39_0, for_value_17_39_1
                cfg_17 = 34
                while true do
                    if cfg_17 == 34 then
                        frame_17[172] = frame_17[43]
                        frame_17[175] = (frame_17[250]):Name__67118af5(frame_17[172])
                        if frame_17[175] then
                            cfg_17 = 39
                        else
                            cfg_17 = 35
                        end
                    elseif cfg_17 == 35 then
                        frame_17[178] = (frame_17[250]):Name__decc89f9()
                        if frame_17[178] then
                            cfg_17 = 39
                        else
                            cfg_17 = 36
                        end
                    elseif cfg_17 == 36 then
                        frame_17[182] = (frame_17[250]):Name__6920e862(11)
                        if frame_17[182] then
                            cfg_17 = 38
                        else
                            cfg_17 = 37
                        end
                    elseif cfg_17 == 37 then
                        frame_17[185] = (frame_17[250]):Name__bef01360()
                        do (frame_17[185]):Name__424cec65(100) end
                        frame_17[191] = (frame_17[250]):Name__3ca198c7()
                        frame_17[192] = (frame_17[191] - frame_17[156])
                        frame_17[193] = Name__39273653
                        frame_17[194] = frame_17[192]
                        frame_17[195] = frame_17[193](frame_17[194])
                        frame_17[198] = (frame_17[250]):Name__bef01360()
                        frame_17[199] = Name__76c01753
                        frame_17[203] = frame_17[199](0, 0.25, 0)
                        frame_17[204] = (frame_17[192] / frame_17[195])
                        frame_17[205] = (frame_17[203] + frame_17[204])
                        frame_17[206] = (frame_17[205] * 45)
                        frame_17[208] = (frame_17[195] / frame_17[90])
                        frame_17[209] = (1 - frame_17[208])
                        frame_17[210] = Name__b6e30ca3.Name__4042c2a4
                        frame_17[211] = frame_17[210](0.4, frame_17[209])
                        frame_17[212] = (frame_17[206] * frame_17[211])
                        do (frame_17[198]):Name__de405722(frame_17[212]) end
                        cfg_17 = 38
                    elseif cfg_17 == 38 then
                        frame_17[215] = Name__5ebaa8da.Name__929d54c4
                        frame_17[216] = frame_17[215]()
                        frame_17[217] = frame_17[6]
                        do (frame_17[216]):Name__a3f45f18(frame_17[217]) end
                        frame_17[220] = frame_17[21]
                        do (frame_17[216]):Name__47cb1af5(frame_17[220]) end
                        frame_17[223] = frame_17[51]
                        do (frame_17[216]):Name__0e3bf94e(frame_17[223]) end
                        frame_17[228] = (frame_17[250]):Name__402a3166()
                        frame_17[230] = frame_17[216]
                        frame_17[233] = (frame_17[228]):Name__287da42d(4, frame_17[230])
                        frame_17[237] = (frame_17[228]):Name__e6841eeb(4)
                        frame_17[238] = (frame_17[233] - frame_17[237])
                        frame_17[240] = Name__b6e30ca3.Name__4042c2a4
                        frame_17[241] = frame_17[240](frame_17[238], 0)
                        frame_17[243] = frame_17[241]
                        do (frame_17[216]):Name__cb11565a(4, frame_17[243]) end
                        frame_17[246] = frame_17[216]
                        do (frame_17[250]):Name__053d681d(frame_17[246]) end
                        cfg_17 = 39
                    elseif cfg_17 == 39 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_17_39 then break end
            end
            if not leave_for_17_39 then
                cfg_17 = 40
            end
        elseif cfg_17 == 40 then
            frame_17[251] = Name__daf81ef9
            frame_17[251](0)
            frame_17[253] = frame_17[89]
            frame_17[254] = frame_17[21]
            frame_17[255] = Name__6514b208
            frame_17[256] = frame_17[255](frame_17[254])
            if frame_17[256] then
                cfg_17 = 43
            else
                cfg_17 = 41
            end
        elseif cfg_17 == 41 then
            frame_17[259] = p17_0:Name__af35e5c4()
            frame_17[260] = (frame_17[90] / frame_17[88])
            frame_17[261] = (frame_17[259] * frame_17[260])
            frame_17[262] = frame_17[261]
            p17_0:Name__9f3d68a0(frame_17[262])
            frame_17[265] = Name__ce537bf6.Name__38715e5b
            frame_17[266] = p17_0
            frame_17[267] = Name__76c01753
            frame_17[269] = (5 * frame_17[261])
            frame_17[271] = (5 * frame_17[261])
            frame_17[273] = (5 * frame_17[261])
            frame_17[265](frame_17[266], frame_17[267](frame_17[269], frame_17[271], frame_17[273]))
            frame_17[304] = Name__00a9cfac
            frame_17[307] = p17_0:Name__b8f8a1e7(frame_17[304])
            frame_17[308] = 1
            frame_17[309] = (#frame_17[307])
            frame_17[310] = 1
            local leave_for_17_42 = false
            for for_value_17_42 = frame_17[308], frame_17[309], frame_17[310] do
                frame_17[308] = for_value_17_42
                cfg_17 = 42
                while true do
                    if cfg_17 == 42 then
                        frame_17[311] = (frame_17[307])[frame_17[308]]
                        frame_17[312] = frame_17[261]
                        do (frame_17[311]):Name__9f3d68a0(frame_17[312]) end
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_17_42 then break end
            end
            if not leave_for_17_42 then
                cfg_17 = 43
            end
        elseif cfg_17 == 43 then
            frame_17[317] = (frame_17[6]):Name__cfd1d8a9()
            frame_17[318] = Name__9828c6d9.frostShield
            frame_17[319] = Name__6514b208
            frame_17[320] = frame_17[319](frame_17[318])
            if not (frame_17[320]) then
                cfg_17 = 45
            else
                cfg_17 = 44
            end
        elseif cfg_17 == 44 then
            frame_17[321] = Name__9828c6d9
            frame_17[322] = {}
            frame_17[321].frostShield = frame_17[322]
            cfg_17 = 45
        elseif cfg_17 == 45 then
            frame_17[323] = Name__9828c6d9.frostShield
            frame_17[324] = (frame_17[323])[frame_17[317]]
            frame_17[325] = Name__6514b208
            frame_17[326] = frame_17[325](frame_17[324])
            if not (frame_17[326]) then
                cfg_17 = 47
            else
                cfg_17 = 46
            end
        elseif cfg_17 == 46 then
            frame_17[327] = Name__9828c6d9.frostShield
            frame_17[328] = {}
            frame_17[327][frame_17[317]] = frame_17[328]
            cfg_17 = 47
        elseif cfg_17 == 47 then
            frame_17[329] = Name__9828c6d9.frostShield
            frame_17[330] = (frame_17[329])[frame_17[317]]
            frame_17[331] = (#frame_17[330])
            frame_17[332] = 1
            frame_17[333] = -1
            local leave_for_17_48 = false
            for for_value_17_48 = frame_17[331], frame_17[332], frame_17[333] do
                frame_17[331] = for_value_17_48
                cfg_17 = 48
                while true do
                    if cfg_17 == 48 then
                        frame_17[334] = Name__9828c6d9.frostShield
                        frame_17[335] = (frame_17[334])[frame_17[317]]
                        frame_17[336] = (frame_17[335])[frame_17[331]]
                        frame_17[337] = (frame_17[336]).shield
                        frame_17[338] = frame_17[337]
                        frame_17[339] = Name__6514b208
                        frame_17[340] = frame_17[339](frame_17[338])
                        if frame_17[340] then
                            cfg_17 = 50
                        else
                            cfg_17 = 49
                        end
                    elseif cfg_17 == 49 then
                        frame_17[343] = (frame_17[337]):Name__d9ea32b7()
                        if not (frame_17[343] <= 0) then
                            cfg_17 = 51
                        else
                            cfg_17 = 50
                        end
                    elseif cfg_17 == 50 then
                        frame_17[345] = Name__6e962203.Name__0d4f9c32
                        frame_17[346] = Name__9828c6d9.frostShield
                        frame_17[347] = (frame_17[346])[frame_17[317]]
                        frame_17[348] = frame_17[331]
                        frame_17[345](frame_17[347], frame_17[348])
                        cfg_17 = 54
                    elseif cfg_17 == 51 then
                        if not (frame_17[37]) then
                            cfg_17 = 54
                        else
                            cfg_17 = 52
                        end
                    elseif cfg_17 == 52 then
                        frame_17[349] = frame_17[40]
                        frame_17[352] = (frame_17[337]):Name__a74ebac5(frame_17[349])
                        if not (frame_17[352] <= frame_17[90]) then
                            cfg_17 = 54
                        else
                            cfg_17 = 53
                        end
                    elseif cfg_17 == 53 then
                        frame_17[355] = (frame_17[337]):Name__1073524c()
                        frame_17[355].isReplaced = true
                        frame_17[357] = Name__9828c6d9.frostShield
                        frame_17[358] = (frame_17[357])[frame_17[317]]
                        frame_17[359] = (frame_17[358])[frame_17[331]]
                        frame_17[360] = (frame_17[359]).reinforceHealth
                        frame_17[389] = Name__b6e30ca3.Name__5ce6de7d
                        frame_17[390] = frame_17[389](frame_17[360], (frame_17[337]):Name__d9ea32b7())
                        frame_17[89] = (frame_17[89] + frame_17[390])
                        do (frame_17[337]):Name__a37322ec(0) end
                        frame_17[394] = Name__6e962203.Name__0d4f9c32
                        frame_17[395] = Name__9828c6d9.frostShield
                        frame_17[396] = (frame_17[395])[frame_17[317]]
                        frame_17[397] = frame_17[331]
                        frame_17[394](frame_17[396], frame_17[397])
                        cfg_17 = 54
                    elseif cfg_17 == 54 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_17_48 then break end
            end
            if not leave_for_17_48 then
                cfg_17 = 55
            end
        elseif cfg_17 == 55 then
            if not (frame_17[37]) then
                cfg_17 = 60
            else
                cfg_17 = 56
            end
        elseif cfg_17 == 56 then
            frame_17[398] = 4
            frame_17[399] = cap_19_115_3
            frame_17[400] = (frame_17[399]).Name__4369ab26
            frame_17[401] = frame_17[400]()
            if not (frame_17[401]) then
                cfg_17 = 58
            else
                cfg_17 = 57
            end
        elseif cfg_17 == 57 then
            frame_17[398] = 1
            cfg_17 = 58
        elseif cfg_17 == 58 then
            frame_17[402] = Name__9828c6d9.frostShield
            frame_17[403] = (frame_17[402])[frame_17[317]]
            frame_17[404] = (#frame_17[403])
            if not (frame_17[398] <= frame_17[404]) then
                cfg_17 = 60
            else
                cfg_17 = 59
            end
        elseif cfg_17 == 59 then
            frame_17[405] = Name__9828c6d9.frostShield
            frame_17[406] = (frame_17[405])[frame_17[317]]
            frame_17[407] = (frame_17[406])[1]
            frame_17[408] = (frame_17[407]).shield
            do (frame_17[408]):Name__a37322ec(0) end
            frame_17[412] = Name__6e962203.Name__0d4f9c32
            frame_17[413] = Name__9828c6d9.frostShield
            frame_17[414] = (frame_17[413])[frame_17[317]]
            frame_17[412](frame_17[414], 1)
            cfg_17 = 58
        elseif cfg_17 == 60 then
            frame_17[416] = Name__9828c6d9.frostShield
            frame_17[417] = (frame_17[416])[frame_17[317]]
            frame_17[418] = { shield = nil, reinforceHealth = nil, radius = nil }
            frame_17[418].shield = p17_0
            frame_17[418].reinforceHealth = frame_17[89]
            frame_17[418].radius = frame_17[90]
            frame_17[419] = Name__6e962203.Name__c614a8c6
            frame_17[419](frame_17[417], frame_17[418])
            frame_17[420] = 0
            frame_17[421] = false
            frame_17[422] = frame_17[21]
            frame_17[423] = Name__6514b208
            frame_17[424] = frame_17[423](frame_17[422])
            if (frame_17[424] or frame_17[47]) then
                cfg_17 = 77
            else
                cfg_17 = 62
            end
        elseif cfg_17 == 62 then
            frame_17[425] = Name__9828c6d9.slamGlobe
            if frame_17[425] == nil then
                cfg_17 = 68
            else
                cfg_17 = 63
            end
        elseif cfg_17 == 63 then
            frame_17[426] = Name__41bc84cf
            frame_17[427] = Name__9828c6d9.slamGlobe
            frame_17[428] = frame_17[426](frame_17[427])
            if frame_17[428] ~= nil then
                cfg_17 = 65
            else
                cfg_17 = 64
            end
        elseif cfg_17 == 64 then
            frame_17[429] = false
            cfg_17 = 66
        elseif cfg_17 == 65 then
            frame_17[429] = true
            cfg_17 = 66
        elseif cfg_17 == 66 then
            frame_17[430] = frame_17[429]
            if not (frame_17[430]) then
                cfg_17 = 69
            else
                cfg_17 = 67
            end
        elseif cfg_17 == 67 then
            frame_17[431] = cap_19_115_4
            frame_17[434] = (frame_17[21]):Name__2888fc5c(frame_17[431])
            frame_17[430] = frame_17[434]
            cfg_17 = 69
        elseif cfg_17 == 68 then
            frame_17[430] = false
            cfg_17 = 69
        elseif cfg_17 == 69 then
            if not (frame_17[430]) then
                cfg_17 = 71
            else
                cfg_17 = 70
            end
        elseif cfg_17 == 70 then
            frame_17[420] = 0.5
            frame_17[421] = true
            cfg_17 = 74
        elseif cfg_17 == 71 then
            if not (0 < frame_17[55]) then
                cfg_17 = 74
            else
                cfg_17 = 72
            end
        elseif cfg_17 == 72 then
            if frame_17[59] ~= 1 then
                cfg_17 = 74
            else
                cfg_17 = 73
            end
        elseif cfg_17 == 73 then
            frame_17[437] = cap_19_115_5
            frame_17[438] = frame_17[55]
            frame_17[439] = frame_17[59]
            frame_17[437](frame_17[438], frame_17[439])
            frame_17[420] = v19_22
            frame_17[421] = true
            cfg_17 = 74
        elseif cfg_17 == 74 then
            if not (frame_17[421]) then
                cfg_17 = 77
            else
                cfg_17 = 75
            end
        elseif cfg_17 == 75 then
            frame_17[440] = Name__8aef5d18
            frame_17[441] = Name__f6aba2d9
            frame_17[442] = Name__76c01753
            frame_17[446] = frame_17[442](0, -0.5, 0)
            frame_17[447] = Name__3b0d8a4c
            frame_17[448] = frame_17[21]
            frame_17[451] = p17_0:Name__f275c3f8(frame_17[440], frame_17[441], frame_17[446], frame_17[447], frame_17[448])
            frame_17[452] = frame_17[451]
            frame_17[453] = Name__6514b208
            frame_17[454] = frame_17[453](frame_17[452])
            if frame_17[454] then
                cfg_17 = 77
            else
                cfg_17 = 76
            end
        elseif cfg_17 == 76 then
            frame_17[456] = (4.4 * frame_17[90])
            frame_17[457] = (frame_17[456] / 5)
            do (frame_17[451]):Name__9f3d68a0(frame_17[457]) end
            cfg_17 = 77
        elseif cfg_17 == 77 then
            frame_17[460] = 1
            cfg_17 = 78
        elseif cfg_17 == 78 then
            if not (0 < frame_17[460]) then
                cfg_17 = 80
            else
                cfg_17 = 79
            end
        elseif cfg_17 == 79 then
            frame_17[462] = frame_17[460]
            p17_0:Name__0f2113b8(frame_17[462])
            frame_17[466] = Name__b420c85a
            frame_17[467] = frame_17[466]()
            frame_17[468] = (frame_17[467] * 3.33)
            frame_17[469] = (frame_17[460] - frame_17[468])
            frame_17[470] = Name__b6e30ca3.Name__4042c2a4
            frame_17[471] = frame_17[470](0, frame_17[469])
            frame_17[460] = frame_17[471]
            frame_17[472] = Name__daf81ef9
            frame_17[472](0)
            cfg_17 = 78
        elseif cfg_17 == 80 then
            p17_0:Name__0f2113b8(0)
            frame_17[477] = false
            frame_17[478] = false
            frame_17[479] = 0
            frame_17[480] = false
            frame_17[481] = {}
            frame_17[482] = {}
            frame_17[483] = 0
            if not (frame_17[60]) then
                cfg_17 = 84
            else
                cfg_17 = 81
            end
        elseif cfg_17 == 81 then
            frame_17[484] = Name__9466a60b
            frame_17[486] = frame_17[484]("/Lotus/Powersuits/Frost/Abilities/IceShieldAbility")
            frame_17[487] = Name__3df6d685
            frame_17[489] = frame_17[487]("OnKillOrAssist")
            do (frame_17[21]):Name__6380c3aa(frame_17[486], frame_17[489], true) end
            if not (frame_17[37]) then
                cfg_17 = 84
            else
                cfg_17 = 82
            end
        elseif cfg_17 == 82 then
            frame_17[495] = (frame_17[6]):Name__682cbf57()
            frame_17[496] = cap_19_115_7
            frame_17[499] = (frame_17[495]):Name__2f0c9e81(frame_17[496])
            if frame_17[499] then
                cfg_17 = 84
            else
                cfg_17 = 83
            end
        elseif cfg_17 == 83 then
            frame_17[500] = cap_19_115_7
            do (frame_17[495]):Name__56a2305f(frame_17[500], 167, 3, 0.25) end
            cfg_17 = 84
        elseif cfg_17 == 84 then
            frame_17[508] = p17_0:Name__1073524c()
            frame_17[508].maxHealth = frame_17[89]
            cfg_17 = 85
        elseif cfg_17 == 85 then
            frame_17[509] = p17_0
            frame_17[510] = Name__6514b208
            frame_17[511] = frame_17[510](frame_17[509])
            if frame_17[511] then
                cfg_17 = 177
            else
                cfg_17 = 86
            end
        elseif cfg_17 == 86 then
            frame_17[512] = frame_17[6]
            frame_17[513] = Name__6514b208
            frame_17[514] = frame_17[513](frame_17[512])
            if frame_17[514] then
                cfg_17 = 177
            else
                cfg_17 = 87
            end
        elseif cfg_17 == 87 then
            frame_17[517] = (frame_17[6]):Name__decc89f9()
            if frame_17[517] then
                cfg_17 = 177
            else
                cfg_17 = 88
            end
        elseif cfg_17 == 88 then
            frame_17[518] = frame_17[21]
            frame_17[519] = Name__6514b208
            frame_17[520] = frame_17[519](frame_17[518])
            if frame_17[520] then
                cfg_17 = 177
            else
                cfg_17 = 89
            end
        elseif cfg_17 == 89 then
            if not (frame_17[479] <= 0) then
                cfg_17 = 92
            else
                cfg_17 = 90
            end
        elseif cfg_17 == 90 then
            frame_17[522] = Name__d7e3ec85
            frame_17[523] = Name__6514b208
            frame_17[524] = frame_17[523](frame_17[522])
            if frame_17[524] then
                cfg_17 = 92
            else
                cfg_17 = 91
            end
        elseif cfg_17 == 91 then
            frame_17[525] = Name__d7e3ec85
            frame_17[526] = frame_17[6]
            frame_17[529] = p17_0:Name__3ca198c7()
            frame_17[530] = frame_17[90]
            frame_17[533] = (frame_17[525]):Name__7806daf2(frame_17[526], frame_17[529], frame_17[530])
            frame_17[480] = frame_17[533]
            frame_17[479] = 0.2
            cfg_17 = 92
        elseif cfg_17 == 92 then
            if ((not (frame_17[37]) or not (frame_17[480])) or not (frame_17[477])) then
                cfg_17 = 96
            else
                cfg_17 = 95
            end
        elseif cfg_17 == 95 then
            frame_17[534] = (frame_17[253] * 0.2)
            frame_17[535] = Name__b420c85a
            frame_17[536] = frame_17[535]()
            frame_17[537] = (frame_17[534] * frame_17[536])
            frame_17[540] = p17_0:Name__d9ea32b7()
            frame_17[541] = (frame_17[540] - frame_17[537])
            frame_17[543] = Name__b6e30ca3.Name__4042c2a4
            frame_17[544] = frame_17[543](frame_17[541], 0)
            p17_0:Name__a37322ec(frame_17[544])
            cfg_17 = 96
        elseif cfg_17 == 96 then
            frame_17[547] = v19_17
            if not (frame_17[547] <= 0) then
                cfg_17 = 105
            else
                cfg_17 = 97
            end
        elseif cfg_17 == 97 then
            if frame_17[477] then
                cfg_17 = 103
            else
                cfg_17 = 98
            end
        elseif cfg_17 == 98 then
            frame_17[551] = p17_0:Name__d9ea32b7()
            if not (0 < frame_17[551]) then
                cfg_17 = 102
            else
                cfg_17 = 99
            end
        elseif cfg_17 == 99 then
            frame_17[553] = (frame_17[89] + frame_17[483])
            frame_17[554] = (frame_17[508]).augmentAddedHealth
            if not (frame_17[554]) then
                cfg_17 = 101
            else
                cfg_17 = 100
            end
        elseif cfg_17 == 100 then
            frame_17[555] = (frame_17[508]).augmentAddedHealth
            frame_17[553] = (frame_17[553] + frame_17[555])
            cfg_17 = 101
        elseif cfg_17 == 101 then
            frame_17[556] = frame_17[553]
            p17_0:Name__a37322ec(frame_17[556], true)
            cfg_17 = 102
        elseif cfg_17 == 102 then
            frame_17[477] = true
            p17_0:Name__cf06651f(true)
            frame_17[508].absorbedDamage = nil
            cfg_17 = 103
        elseif cfg_17 == 103 then
            frame_17[566] = p17_0:Name__d9ea32b7()
            if not (frame_17[566] <= 1000000) then
                cfg_17 = 110
            else
                cfg_17 = 104
            end
        elseif cfg_17 == 104 then
            frame_17[568] = frame_17[253]
            frame_17[590] = Name__b6e30ca3.Name__4042c2a4
            frame_17[591] = frame_17[590](frame_17[568], p17_0:Name__d9ea32b7())
            frame_17[253] = frame_17[591]
            frame_17[508].maxHealth = frame_17[253]
            cfg_17 = 110
        elseif cfg_17 == 105 then
            if not (frame_17[37]) then
                cfg_17 = 110
            else
                cfg_17 = 106
            end
        elseif cfg_17 == 106 then
            frame_17[594] = p17_0:Name__d9ea32b7()
            if not (0 < frame_17[594]) then
                cfg_17 = 110
            else
                cfg_17 = 107
            end
        elseif cfg_17 == 107 then
            if frame_17[480] then
                cfg_17 = 109
            else
                cfg_17 = 108
            end
        elseif cfg_17 == 108 then
            frame_17[598] = p17_0:Name__d9ea32b7()
            frame_17[599] = (1000000 - frame_17[598])
            frame_17[483] = (frame_17[483] + frame_17[599])
            frame_17[508].absorbedDamage = frame_17[483]
            cfg_17 = 109
        elseif cfg_17 == 109 then
            p17_0:Name__a37322ec(1000000)
            cfg_17 = 110
        elseif cfg_17 == 110 then
            frame_17[605] = p17_0:Name__d9ea32b7()
            if frame_17[605] <= 0 then
                cfg_17 = 177
            else
                cfg_17 = 111
            end
        elseif cfg_17 == 111 then
            frame_17[608] = (frame_17[605] / frame_17[253])
            frame_17[609] = Name__b6e30ca3.Name__5ce6de7d
            frame_17[610] = frame_17[609](1, frame_17[608])
            frame_17[613] = (frame_17[6]):Name__7f7b27a9()
            if (not (frame_17[613]) or frame_17[47]) then
                cfg_17 = 114
            else
                cfg_17 = 113
            end
        elseif cfg_17 == 113 then
            frame_17[614] = Name__9828c6d9.SetAbilityTimer
            frame_17[615] = frame_17[51]
            frame_17[616] = frame_17[6]
            frame_17[617] = (frame_17[610] * 100)
            frame_17[614](frame_17[615], frame_17[616], frame_17[617], true)
            cfg_17 = 114
        elseif cfg_17 == 114 then
            frame_17[619] = cap_19_115_8
            frame_17[620] = (1 - frame_17[610])
            frame_17[621] = (1 - frame_17[610])
            frame_17[622] = (frame_17[620] * frame_17[621])
            frame_17[623] = (frame_17[622] * 2)
            p17_0:Name__c9537147(frame_17[619], frame_17[623])
            frame_17[627] = (frame_17[610] / 0.3)
            frame_17[628] = Name__b6e30ca3.Name__5ce6de7d
            frame_17[629] = frame_17[628](1, frame_17[627])
            frame_17[630] = cap_19_115_9
            frame_17[633] = frame_17[629]
            p17_0:Name__c9537147(frame_17[630], 1, 0, frame_17[633])
            frame_17[636] = 0.25
            frame_17[637] = v19_17
            if not (0 < frame_17[637]) then
                cfg_17 = 116
            else
                cfg_17 = 115
            end
        elseif cfg_17 == 115 then
            frame_17[639] = Name__753fcbe8
            frame_17[640] = v19_17
            frame_17[641] = frame_17[639](frame_17[640])
            frame_17[642] = (frame_17[641] * 3.141592653589793)
            frame_17[643] = (frame_17[642] * 2)
            frame_17[644] = Name__b6e30ca3.Name__9fcabda9
            frame_17[645] = frame_17[644](frame_17[643])
            frame_17[646] = Name__b6e30ca3.Name__ee3f0b88
            frame_17[647] = frame_17[646](frame_17[645])
            frame_17[648] = (frame_17[647] * 1.5)
            frame_17[636] = (frame_17[636] + frame_17[648])
            cfg_17 = 116
        elseif cfg_17 == 116 then
            frame_17[649] = cap_19_115_10
            frame_17[650] = frame_17[636]
            p17_0:Name__c9537147(frame_17[649], frame_17[650])
            if not (frame_17[37]) then
                cfg_17 = 176
            else
                cfg_17 = 117
            end
        elseif cfg_17 == 117 then
            frame_17[653] = Name__b364fd20
            frame_17[654] = Name__d48bf954
            frame_17[657] = p17_0:Name__3ca198c7()
            frame_17[659] = frame_17[90]
            frame_17[662] = (frame_17[653]):Name__45a25bce(frame_17[654], frame_17[657], 0, frame_17[659])
            frame_17[663] = nil
            frame_17[664] = cap_19_115_3
            frame_17[665] = (frame_17[664]).Name__4369ab26
            frame_17[666] = frame_17[665]()
            if not (frame_17[666]) then
                cfg_17 = 119
            else
                cfg_17 = 118
            end
        elseif cfg_17 == 118 then
            frame_17[667] = Name__b364fd20
            frame_17[668] = Name__6e6b3a27
            frame_17[671] = p17_0:Name__3ca198c7()
            frame_17[673] = frame_17[90]
            frame_17[676] = (frame_17[667]):Name__45a25bce(frame_17[668], frame_17[671], 0, frame_17[673])
            frame_17[663] = frame_17[676]
            cfg_17 = 119
        elseif cfg_17 == 119 then
            frame_17[677] = {}
            frame_17[678] = Name__327588f0
            frame_17[679] = frame_17[481]
            frame_17[680], frame_17[681], frame_17[682] = frame_17[678](frame_17[679])
            local leave_for_17_134 = false
            for for_value_17_134_0, for_value_17_134_1 in frame_17[680], frame_17[681], frame_17[682] do
                frame_17[730], frame_17[731] = for_value_17_134_0, for_value_17_134_1
                cfg_17 = 120
                while true do
                    if cfg_17 == 120 then
                        frame_17[683] = (frame_17[731]).enemy
                        frame_17[684] = frame_17[683]
                        frame_17[685] = Name__6514b208
                        frame_17[686] = frame_17[685](frame_17[684])
                        if frame_17[686] then
                            cfg_17 = 128
                        else
                            cfg_17 = 121
                        end
                    elseif cfg_17 == 121 then
                        frame_17[687] = 1
                        frame_17[688] = (#frame_17[662])
                        frame_17[689] = 1
                        local leave_for_17_122 = false
                        for for_value_17_122 = frame_17[687], frame_17[688], frame_17[689] do
                            frame_17[687] = for_value_17_122
                            cfg_17 = 122
                            while true do
                                if cfg_17 == 122 then
                                    frame_17[690] = (frame_17[662])[frame_17[687]]
                                    if frame_17[690] ~= frame_17[683] then
                                        cfg_17 = 124
                                    else
                                        cfg_17 = 123
                                    end
                                elseif cfg_17 == 123 then
                                    frame_17[691] = true
                                    cfg_17 = 126
                                    leave_for_17_122 = true
                                    break
                                elseif cfg_17 == 124 then
                                    break
                                else
                                    error("invalid control state")
                                end
                            end
                            if leave_for_17_122 then break end
                        end
                        if not leave_for_17_122 then
                            cfg_17 = 125
                        end
                        if cfg_17 ~= 120 and cfg_17 ~= 121 and cfg_17 ~= 125 and cfg_17 ~= 126 and cfg_17 ~= 127 and cfg_17 ~= 128 and cfg_17 ~= 129 and cfg_17 ~= 130 and cfg_17 ~= 131 and cfg_17 ~= 132 and cfg_17 ~= 133 and cfg_17 ~= 134 then
                            leave_for_17_134 = true
                            break
                        end
                    elseif cfg_17 == 125 then
                        frame_17[691] = false
                        cfg_17 = 126
                    elseif cfg_17 == 126 then
                        if not (frame_17[691]) then
                            cfg_17 = 128
                        else
                            cfg_17 = 127
                        end
                    elseif cfg_17 == 127 then
                        frame_17[695] = (frame_17[683]):Name__6920e862(0)
                        if not (frame_17[695]) then
                            cfg_17 = 129
                        else
                            cfg_17 = 128
                        end
                    elseif cfg_17 == 128 then
                        frame_17[696] = frame_17[677]
                        frame_17[697] = frame_17[730]
                        frame_17[698] = Name__6e962203.Name__c614a8c6
                        frame_17[698](frame_17[696], frame_17[697])
                        cfg_17 = 134
                    elseif cfg_17 == 129 then
                        frame_17[699] = (frame_17[731]).timer
                        if not (0 < frame_17[699]) then
                            cfg_17 = 131
                        else
                            cfg_17 = 130
                        end
                    elseif cfg_17 == 130 then
                        frame_17[701] = (frame_17[731]).timer
                        frame_17[702] = Name__b420c85a
                        frame_17[703] = frame_17[702]()
                        frame_17[704] = (frame_17[701] - frame_17[703])
                        frame_17[731].timer = frame_17[704]
                        cfg_17 = 131
                    elseif cfg_17 == 131 then
                        frame_17[705] = (frame_17[731]).timer
                        if not (frame_17[705] <= 0) then
                            cfg_17 = 134
                        else
                            cfg_17 = 132
                        end
                    elseif cfg_17 == 132 then
                        frame_17[709] = (frame_17[683]):Name__df558356()
                        if frame_17[709] then
                            cfg_17 = 134
                        else
                            cfg_17 = 133
                        end
                    elseif cfg_17 == 133 then
                        frame_17[731].timer = 3
                        frame_17[711] = Name__5ebaa8da.Name__929d54c4
                        frame_17[712] = frame_17[711]()
                        do (frame_17[712]):Name__3d8e91b5(4, true) end
                        frame_17[717] = frame_17[6]
                        do (frame_17[712]):Name__a3f45f18(frame_17[717]) end
                        frame_17[720] = frame_17[21]
                        do (frame_17[712]):Name__47cb1af5(frame_17[720]) end
                        frame_17[723] = frame_17[51]
                        do (frame_17[712]):Name__0e3bf94e(frame_17[723]) end
                        frame_17[712].hitType = 7
                        frame_17[727] = frame_17[712]
                        do (frame_17[683]):Name__053d681d(frame_17[727]) end
                        cfg_17 = 134
                    elseif cfg_17 == 134 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_17_134 then break end
            end
            if not leave_for_17_134 then
                cfg_17 = 135
            end
        elseif cfg_17 == 135 then
            frame_17[732] = Name__d06efad8
            frame_17[733] = frame_17[677]
            frame_17[734], frame_17[735], frame_17[736] = frame_17[732](frame_17[733])
            local leave_for_17_137 = false
            for for_value_17_137_0, for_value_17_137_1 in frame_17[734], frame_17[735], frame_17[736] do
                frame_17[738], frame_17[739] = for_value_17_137_0, for_value_17_137_1
                cfg_17 = 136
                while true do
                    if cfg_17 == 136 then
                        frame_17[481][frame_17[739]] = nil
                        cfg_17 = 137
                    elseif cfg_17 == 137 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_17_137 then break end
            end
            if not leave_for_17_137 then
                cfg_17 = 138
            end
        elseif cfg_17 == 138 then
            frame_17[740] = (#frame_17[482])
            frame_17[741] = 1
            frame_17[742] = -1
            local leave_for_17_139 = false
            for for_value_17_139 = frame_17[740], frame_17[741], frame_17[742] do
                frame_17[740] = for_value_17_139
                cfg_17 = 139
                while true do
                    if cfg_17 == 139 then
                        frame_17[743] = (frame_17[482])[frame_17[740]]
                        frame_17[744] = Name__6514b208
                        frame_17[745] = frame_17[744](frame_17[743])
                        if frame_17[745] then
                            cfg_17 = 148
                        else
                            cfg_17 = 140
                        end
                    elseif cfg_17 == 140 then
                        frame_17[746] = (frame_17[482])[frame_17[740]]
                        frame_17[747] = frame_17[663]
                        frame_17[748] = 1
                        frame_17[749] = (#frame_17[747])
                        frame_17[750] = 1
                        local leave_for_17_141 = false
                        for for_value_17_141 = frame_17[748], frame_17[749], frame_17[750] do
                            frame_17[748] = for_value_17_141
                            cfg_17 = 141
                            while true do
                                if cfg_17 == 141 then
                                    frame_17[751] = (frame_17[747])[frame_17[748]]
                                    if frame_17[751] ~= frame_17[746] then
                                        cfg_17 = 143
                                    else
                                        cfg_17 = 142
                                    end
                                elseif cfg_17 == 142 then
                                    frame_17[752] = true
                                    cfg_17 = 145
                                    leave_for_17_141 = true
                                    break
                                elseif cfg_17 == 143 then
                                    break
                                else
                                    error("invalid control state")
                                end
                            end
                            if leave_for_17_141 then break end
                        end
                        if not leave_for_17_141 then
                            cfg_17 = 144
                        end
                        if cfg_17 ~= 139 and cfg_17 ~= 140 and cfg_17 ~= 144 and cfg_17 ~= 145 and cfg_17 ~= 146 and cfg_17 ~= 147 and cfg_17 ~= 148 and cfg_17 ~= 149 and cfg_17 ~= 150 and cfg_17 ~= 151 and cfg_17 ~= 152 then
                            leave_for_17_139 = true
                            break
                        end
                    elseif cfg_17 == 144 then
                        frame_17[752] = false
                        cfg_17 = 145
                    elseif cfg_17 == 145 then
                        if not (frame_17[752]) then
                            cfg_17 = 148
                        else
                            cfg_17 = 146
                        end
                    elseif cfg_17 == 146 then
                        frame_17[753] = (frame_17[482])[frame_17[740]]
                        frame_17[757] = (frame_17[753]):Name__6920e862(0)
                        if frame_17[757] then
                            cfg_17 = 148
                        else
                            cfg_17 = 147
                        end
                    elseif cfg_17 == 147 then
                        frame_17[758] = (frame_17[482])[frame_17[740]]
                        frame_17[761] = (frame_17[758]):Name__402a3166()
                        frame_17[765] = (frame_17[761]):Name__a9eac0a6(4)
                        if not (frame_17[765]) then
                            cfg_17 = 152
                        else
                            cfg_17 = 148
                        end
                    elseif cfg_17 == 148 then
                        frame_17[766] = (frame_17[482])[frame_17[740]]
                        frame_17[767] = Name__6514b208
                        frame_17[768] = frame_17[767](frame_17[766])
                        if frame_17[768] then
                            cfg_17 = 151
                        else
                            cfg_17 = 149
                        end
                    elseif cfg_17 == 149 then
                        frame_17[769] = cap_19_115_3
                        frame_17[770] = (frame_17[769]).Name__43080fee
                        frame_17[771] = (frame_17[482])[frame_17[740]]
                        frame_17[772] = v19_18
                        frame_17[770](frame_17[771], frame_17[772], false)
                        frame_17[774] = (frame_17[482])[frame_17[740]]
                        frame_17[775] = Name__cfc31c2b
                        frame_17[778] = (frame_17[774]):Name__efec1c81(frame_17[775])
                        frame_17[779] = frame_17[778]
                        frame_17[780] = Name__6514b208
                        frame_17[781] = frame_17[780](frame_17[779])
                        if frame_17[781] then
                            cfg_17 = 151
                        else
                            cfg_17 = 150
                        end
                    elseif cfg_17 == 150 then
                        do (frame_17[778]):Name__9c6a9ac9() end
                        cfg_17 = 151
                    elseif cfg_17 == 151 then
                        frame_17[784] = Name__6e962203.Name__0d4f9c32
                        frame_17[785] = frame_17[482]
                        frame_17[786] = frame_17[740]
                        frame_17[784](frame_17[785], frame_17[786])
                        cfg_17 = 152
                    elseif cfg_17 == 152 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_17_139 then break end
            end
            if not leave_for_17_139 then
                cfg_17 = 153
            end
        elseif cfg_17 == 153 then
            frame_17[787] = Name__d06efad8
            frame_17[788] = frame_17[662]
            frame_17[789], frame_17[790], frame_17[791] = frame_17[787](frame_17[788])
            local leave_for_17_163 = false
            for for_value_17_163_0, for_value_17_163_1 in frame_17[789], frame_17[790], frame_17[791] do
                frame_17[855], frame_17[856] = for_value_17_163_0, for_value_17_163_1
                cfg_17 = 154
                while true do
                    if cfg_17 == 154 then
                        frame_17[792] = frame_17[43]
                        frame_17[795] = (frame_17[856]):Name__67118af5(frame_17[792])
                        if frame_17[795] then
                            cfg_17 = 163
                        else
                            cfg_17 = 155
                        end
                    elseif cfg_17 == 155 then
                        frame_17[798] = (frame_17[856]):Name__decc89f9()
                        if frame_17[798] then
                            cfg_17 = 163
                        else
                            cfg_17 = 156
                        end
                    elseif cfg_17 == 156 then
                        frame_17[801] = (frame_17[856]):Name__cfd1d8a9()
                        frame_17[802] = (frame_17[481])[frame_17[801]]
                        if frame_17[802] ~= nil then
                            cfg_17 = 163
                        else
                            cfg_17 = 157
                        end
                    elseif cfg_17 == 157 then
                        frame_17[806] = (frame_17[856]):Name__6920e862(0)
                        if not (frame_17[806]) then
                            cfg_17 = 160
                        else
                            cfg_17 = 158
                        end
                    elseif cfg_17 == 158 then
                        if frame_17[478] then
                            cfg_17 = 163
                        else
                            cfg_17 = 159
                        end
                    elseif cfg_17 == 159 then
                        frame_17[807] = frame_17[6]
                        do (frame_17[856]):Name__c8f04e21(frame_17[807]) end
                        frame_17[478] = true
                        cfg_17 = 163
                    elseif cfg_17 == 160 then
                        frame_17[812] = (frame_17[856]):Name__cfd1d8a9()
                        frame_17[813] = { enemy = nil, timer = 3 }
                        frame_17[813].enemy = frame_17[856]
                        frame_17[481][frame_17[812]] = frame_17[813]
                        frame_17[816] = (frame_17[856]):Name__402a3166()
                        frame_17[817] = Name__5ebaa8da.Name__929d54c4
                        frame_17[818] = frame_17[817]()
                        frame_17[819] = frame_17[6]
                        do (frame_17[818]):Name__a3f45f18(frame_17[819]) end
                        frame_17[822] = frame_17[21]
                        do (frame_17[818]):Name__47cb1af5(frame_17[822]) end
                        frame_17[825] = frame_17[51]
                        do (frame_17[818]):Name__0e3bf94e(frame_17[825]) end
                        frame_17[828] = 1
                        frame_17[829] = Name__b6e30ca3.Name__19517a64
                        frame_17[830] = frame_17[829]()
                        if not (frame_17[830] < frame_17[420]) then
                            cfg_17 = 162
                        else
                            cfg_17 = 161
                        end
                    elseif cfg_17 == 161 then
                        frame_17[832] = frame_17[818]
                        frame_17[835] = (frame_17[816]):Name__287da42d(4, frame_17[832])
                        frame_17[839] = (frame_17[816]):Name__e6841eeb(4)
                        frame_17[840] = (frame_17[835] - frame_17[839])
                        frame_17[828] = frame_17[840]
                        cfg_17 = 162
                    elseif cfg_17 == 162 then
                        frame_17[842] = Name__87803f1b
                        frame_17[843] = frame_17[828]
                        do (frame_17[818]):Name__cb11565a(4, frame_17[842](frame_17[843], 0, 10)) end
                        frame_17[852] = frame_17[818]
                        do (frame_17[856]):Name__053d681d(frame_17[852]) end
                        cfg_17 = 163
                    elseif cfg_17 == 163 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_17_163 then break end
            end
            if not leave_for_17_163 then
                cfg_17 = 164
            end
        elseif cfg_17 == 164 then
            frame_17[857] = cap_19_115_3
            frame_17[858] = (frame_17[857]).Name__4369ab26
            frame_17[859] = frame_17[858]()
            if not (frame_17[859]) then
                cfg_17 = 176
            else
                cfg_17 = 165
            end
        elseif cfg_17 == 165 then
            frame_17[860] = 1
            frame_17[861] = (#frame_17[663])
            frame_17[862] = 1
            local leave_for_17_166 = false
            for for_value_17_166 = frame_17[860], frame_17[861], frame_17[862] do
                frame_17[860] = for_value_17_166
                cfg_17 = 166
                while true do
                    if cfg_17 == 166 then
                        frame_17[863] = cap_19_115_3
                        frame_17[864] = (frame_17[863]).Name__e81dbfc2
                        frame_17[865] = frame_17[6]
                        frame_17[866] = (frame_17[663])[frame_17[860]]
                        frame_17[867] = frame_17[864](frame_17[865], frame_17[866])
                        if not (frame_17[867]) then
                            cfg_17 = 175
                        else
                            cfg_17 = 167
                        end
                    elseif cfg_17 == 167 then
                        frame_17[868] = (frame_17[663])[frame_17[860]]
                        frame_17[871] = (frame_17[868]):Name__402a3166()
                        frame_17[875] = (frame_17[871]):Name__a9eac0a6(4)
                        if frame_17[875] then
                            cfg_17 = 175
                        else
                            cfg_17 = 168
                        end
                    elseif cfg_17 == 168 then
                        frame_17[876] = (frame_17[663])[frame_17[860]]
                        frame_17[877] = 1
                        frame_17[878] = (#frame_17[482])
                        frame_17[879] = 1
                        local leave_for_17_169 = false
                        for for_value_17_169 = frame_17[877], frame_17[878], frame_17[879] do
                            frame_17[877] = for_value_17_169
                            cfg_17 = 169
                            while true do
                                if cfg_17 == 169 then
                                    frame_17[880] = (frame_17[482])[frame_17[877]]
                                    if frame_17[880] ~= frame_17[876] then
                                        cfg_17 = 171
                                    else
                                        cfg_17 = 170
                                    end
                                elseif cfg_17 == 170 then
                                    frame_17[881] = true
                                    cfg_17 = 173
                                    leave_for_17_169 = true
                                    break
                                elseif cfg_17 == 171 then
                                    break
                                else
                                    error("invalid control state")
                                end
                            end
                            if leave_for_17_169 then break end
                        end
                        if not leave_for_17_169 then
                            cfg_17 = 172
                        end
                        if cfg_17 ~= 166 and cfg_17 ~= 167 and cfg_17 ~= 168 and cfg_17 ~= 172 and cfg_17 ~= 173 and cfg_17 ~= 174 and cfg_17 ~= 175 then
                            leave_for_17_166 = true
                            break
                        end
                    elseif cfg_17 == 172 then
                        frame_17[881] = false
                        cfg_17 = 173
                    elseif cfg_17 == 173 then
                        if frame_17[881] then
                            cfg_17 = 175
                        else
                            cfg_17 = 174
                        end
                    elseif cfg_17 == 174 then
                        frame_17[882] = cap_19_115_3
                        frame_17[883] = (frame_17[882]).Name__43080fee
                        frame_17[884] = (frame_17[663])[frame_17[860]]
                        frame_17[885] = v19_18
                        frame_17[883](frame_17[884], frame_17[885], true)
                        frame_17[887] = (frame_17[663])[frame_17[860]]
                        frame_17[888] = Name__cfc31c2b
                        frame_17[889] = Name__f6aba2d9
                        do (frame_17[887]):Name__f275c3f8(frame_17[888], frame_17[889]) end
                        frame_17[892] = (frame_17[663])[frame_17[860]]
                        frame_17[893] = frame_17[482]
                        frame_17[894] = Name__6e962203.Name__c614a8c6
                        frame_17[894](frame_17[893], frame_17[892])
                        cfg_17 = 175
                    elseif cfg_17 == 175 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_17_166 then break end
            end
            if not leave_for_17_166 then
                cfg_17 = 176
            end
        elseif cfg_17 == 176 then
            frame_17[895] = Name__daf81ef9
            frame_17[895](0)
            frame_17[897] = v19_17
            frame_17[898] = Name__b420c85a
            frame_17[899] = frame_17[898]()
            frame_17[900] = (frame_17[897] - frame_17[899])
            v19_17 = frame_17[900]
            frame_17[901] = Name__b420c85a
            frame_17[902] = frame_17[901]()
            frame_17[479] = (frame_17[479] - frame_17[902])
            cfg_17 = 85
        elseif cfg_17 == 177 then
            if not (frame_17[60]) then
                cfg_17 = 184
            else
                cfg_17 = 178
            end
        elseif cfg_17 == 178 then
            frame_17[903] = frame_17[21]
            frame_17[904] = Name__6514b208
            frame_17[905] = frame_17[904](frame_17[903])
            if frame_17[905] then
                cfg_17 = 184
            else
                cfg_17 = 179
            end
        elseif cfg_17 == 179 then
            frame_17[906] = Name__9466a60b
            frame_17[908] = frame_17[906]("/Lotus/Powersuits/Frost/Abilities/IceShieldAbility")
            frame_17[909] = Name__3df6d685
            frame_17[911] = frame_17[909]("OnKillOrAssist")
            do (frame_17[21]):Name__6380c3aa(frame_17[908], frame_17[911], false) end
            if not (frame_17[37]) then
                cfg_17 = 184
            else
                cfg_17 = 180
            end
        elseif cfg_17 == 180 then
            frame_17[915] = p17_0
            frame_17[916] = Name__6514b208
            frame_17[917] = frame_17[916](frame_17[915])
            if frame_17[917] then
                cfg_17 = 182
            else
                cfg_17 = 181
            end
        elseif cfg_17 == 181 then
            frame_17[920] = p17_0:Name__1073524c()
            frame_17[921] = (frame_17[920]).isReplaced
            if frame_17[921] then
                cfg_17 = 184
            else
                cfg_17 = 182
            end
        elseif cfg_17 == 182 then
            frame_17[924] = (frame_17[6]):Name__682cbf57()
            frame_17[925] = cap_19_115_7
            frame_17[928] = (frame_17[924]):Name__2f0c9e81(frame_17[925])
            if not (frame_17[928]) then
                cfg_17 = 184
            else
                cfg_17 = 183
            end
        elseif cfg_17 == 183 then
            frame_17[929] = cap_19_115_7
            do (frame_17[924]):Name__872cea58(frame_17[929], 167, 3, 0.25) end
            cfg_17 = 184
        elseif cfg_17 == 184 then
            frame_17[935] = frame_17[6]
            frame_17[936] = Name__6514b208
            frame_17[937] = frame_17[936](frame_17[935])
            if frame_17[937] then
                cfg_17 = 188
            else
                cfg_17 = 185
            end
        elseif cfg_17 == 185 then
            frame_17[940] = (frame_17[6]):Name__7f7b27a9()
            if (not (frame_17[940]) or frame_17[47]) then
                cfg_17 = 188
            else
                cfg_17 = 187
            end
        elseif cfg_17 == 187 then
            frame_17[941] = Name__9828c6d9.SetAbilityTimer
            frame_17[942] = frame_17[51]
            frame_17[943] = frame_17[6]
            frame_17[941](frame_17[942], frame_17[943], 0, true)
            cfg_17 = 188
        elseif cfg_17 == 188 then
            if not (frame_17[37]) then
                cfg_17 = 194
            else
                cfg_17 = 189
            end
        elseif cfg_17 == 189 then
            frame_17[946] = 1
            frame_17[947] = (#frame_17[482])
            frame_17[948] = 1
            local leave_for_17_190 = false
            for for_value_17_190 = frame_17[946], frame_17[947], frame_17[948] do
                frame_17[946] = for_value_17_190
                cfg_17 = 190
                while true do
                    if cfg_17 == 190 then
                        frame_17[949] = (frame_17[482])[frame_17[946]]
                        frame_17[950] = Name__6514b208
                        frame_17[951] = frame_17[950](frame_17[949])
                        if frame_17[951] then
                            cfg_17 = 193
                        else
                            cfg_17 = 191
                        end
                    elseif cfg_17 == 191 then
                        frame_17[952] = cap_19_115_3
                        frame_17[953] = (frame_17[952]).Name__43080fee
                        frame_17[954] = (frame_17[482])[frame_17[946]]
                        frame_17[955] = v19_18
                        frame_17[953](frame_17[954], frame_17[955], false)
                        frame_17[957] = (frame_17[482])[frame_17[946]]
                        frame_17[958] = Name__cfc31c2b
                        frame_17[961] = (frame_17[957]):Name__efec1c81(frame_17[958])
                        frame_17[962] = frame_17[961]
                        frame_17[963] = Name__6514b208
                        frame_17[964] = frame_17[963](frame_17[962])
                        if frame_17[964] then
                            cfg_17 = 193
                        else
                            cfg_17 = 192
                        end
                    elseif cfg_17 == 192 then
                        do (frame_17[961]):Name__9c6a9ac9() end
                        cfg_17 = 193
                    elseif cfg_17 == 193 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_17_190 then break end
            end
            if not leave_for_17_190 then
                cfg_17 = 194
            end
        elseif cfg_17 == 194 then
            frame_17[967] = p17_0
            frame_17[968] = Name__6514b208
            frame_17[969] = frame_17[968](frame_17[967])
            if frame_17[969] then
                cfg_17 = 198
            else
                cfg_17 = 195
            end
        elseif cfg_17 == 195 then
            if not (frame_17[60]) then
                cfg_17 = 197
            else
                cfg_17 = 196
            end
        elseif cfg_17 == 196 then
            frame_17[972] = p17_0:Name__1073524c()
            frame_17[973] = (frame_17[972]).isReplaced
            if frame_17[973] then
                cfg_17 = 198
            else
                cfg_17 = 197
            end
        elseif cfg_17 == 197 then
            frame_17[974] = cap_19_115_12
            frame_17[975] = p17_0
            frame_17[976] = frame_17[90]
            frame_17[977] = frame_17[91]
            frame_17[974](frame_17[975], frame_17[976], frame_17[977])
            cfg_17 = 198
        elseif cfg_17 == 198 then
            if not (frame_17[460] < 1) then
                cfg_17 = 201
            else
                cfg_17 = 199
            end
        elseif cfg_17 == 199 then
            frame_17[979] = p17_0
            frame_17[980] = Name__6514b208
            frame_17[981] = frame_17[980](frame_17[979])
            if frame_17[981] then
                cfg_17 = 201
            else
                cfg_17 = 200
            end
        elseif cfg_17 == 200 then
            frame_17[982] = frame_17[460]
            p17_0:Name__0f2113b8(frame_17[982])
            frame_17[985] = Name__b420c85a
            frame_17[986] = frame_17[985]()
            frame_17[987] = (frame_17[986] * 2)
            frame_17[460] = (frame_17[460] + frame_17[987])
            frame_17[988] = Name__daf81ef9
            frame_17[988](0)
            cfg_17 = 198
        elseif cfg_17 == 201 then
            if not (frame_17[37]) then
                cfg_17 = 204
            else
                cfg_17 = 202
            end
        elseif cfg_17 == 202 then
            frame_17[990] = p17_0
            frame_17[991] = Name__6514b208
            frame_17[992] = frame_17[991](frame_17[990])
            if frame_17[992] then
                cfg_17 = 204
            else
                cfg_17 = 203
            end
        elseif cfg_17 == 203 then
            p17_0:Name__9c6a9ac9()
            cfg_17 = 204
        elseif cfg_17 == 204 then
            return
        else
            error("invalid control state")
        end
    end
end
Deploy = v19_47
local cap_19_130_0 = v19_33
local cap_19_130_2 = v19_34
v19_48 = function(p18_0, p18_1, p18_2, p18_3)
    local v18_4
    local v18_5
    local v18_6
    local v18_7
    local v18_8
    local v18_9
    local v18_10
    local v18_11
    local v18_12
    local v18_13
    local v18_14
    local v18_15
    local v18_16
    local v18_17
    local v18_18
    local v18_19
    local v18_20
    local v18_21
    local v18_22
    local v18_23
    local v18_24
    local v18_25
    local v18_26
    local v18_27
    local v18_28
    local v18_29
    local v18_30
    local v18_31
    local v18_32
    local v18_33
    local v18_34
    local v18_35
    local v18_36
    local v18_37
    local v18_38
    local v18_39
    local v18_40
    local v18_41
    local v18_42
    local v18_43
    local v18_44
    local v18_45
    local v18_46
    local v18_47
    local v18_48
    local v18_49
    local v18_50
    local v18_51
    local v18_52
    local v18_53
    local v18_54
    local v18_55
    local v18_56
    local v18_57
    local v18_58
    local v18_59
    local v18_60
    local v18_61
    local v18_62
    local v18_63
    local v18_64
    local v18_65
    local v18_66
    local v18_67
    local v18_68
    local v18_69
    local v18_70
    local v18_71
    local v18_72
    local v18_73
    local v18_74
    local v18_75
    local v18_76
    local v18_77
    local v18_78
    local v18_79
    local v18_80
    local v18_81
    local v18_82
    local v18_83
    local v18_84
    local v18_85
    local v18_86
    local v18_87
    local v18_88
    local v18_89
    local v18_90
    local v18_91
    local v18_92
    local v18_93
    local v18_94
    v18_4 = Name__b364fd20
    v18_7 = v18_4:Name__ce228771()
    if v18_7 then
        v18_8 = p18_3
        v18_9 = Name__6514b208
        v18_10 = v18_9(v18_8)
        if v18_10 then
        else
            v18_11 = Name__64ec4e19
            v18_14 = p18_3:Name__2888fc5c(v18_11)
            if v18_14 then
                v18_17 = p18_0:Name__8c362f50()
                v18_20 = v18_17:Name__cfd1d8a9()
                v18_23 = p18_3:Name__402a3166()
                v18_27 = v18_23:Name__e6841eeb(4)
                v18_29 = Name__5ebaa8da.Name__929d54c4
                v18_38 = v18_23:Name__287da42d(4, v18_29())
                if v18_38 <= v18_27 then
                    v18_39 = true
                else
                    v18_39 = false
                end
                v18_40 = p18_3
                v18_41 = Name__6514b208
                v18_42 = v18_41(v18_40)
                local predicate_value_18_7 = (not (v18_42) and v18_39)
                if predicate_value_18_7 then
                    v18_43 = Name__9828c6d9.frostShield
                    if v18_43 == nil then
                    else
                        v18_44 = Name__9828c6d9.frostShield
                        v18_45 = (v18_44)[v18_20]
                        if v18_45 == nil then
                        else
                            v18_46 = Name__9828c6d9.frostShield
                            v18_47 = (v18_46)[v18_20]
                            v18_48 = (v18_47)[1]
                            if v18_48 == nil then
                            else
                                v18_49 = Name__9828c6d9.frostShield
                                v18_50 = (v18_49)[v18_20]
                                v18_51 = (v18_50)[1]
                                v18_52 = (v18_51).shield
                                v18_53 = Name__6514b208
                                v18_54 = v18_53(v18_52)
                                if not (v18_54) then
                                    v18_55 = Name__9828c6d9.frostShield
                                    v18_56 = (v18_55)[v18_20]
                                    v18_57 = (v18_56)[1]
                                    v18_58 = (v18_57).shield
                                    v18_61 = v18_58:Name__1073524c()
                                    v18_62 = (v18_61).maxHealth
                                    if v18_62 then
                                        v18_66 = p18_0:Name__c7fc329f(2)
                                        v18_70 = p18_0:Name__9dfce5ad(2)
                                        v18_71 = cap_19_130_0
                                        v18_72 = v18_66
                                        v18_73 = v18_70
                                        v18_71(v18_72, v18_73)
                                        v18_74 = cap_19_130_2
                                        v18_75 = v18_17
                                        v18_76 = v18_70
                                        v18_77 = v18_74(v18_75, v18_76)
                                        v19_23 = v18_77
                                        v18_78 = (v18_61).maxHealth
                                        v18_79 = (v18_61).absorbedDamage
                                        if v18_79 then
                                            v18_80 = (v18_61).absorbedDamage
                                            v18_78 = (v18_78 + v18_80)
                                        end
                                        v18_81 = v19_23
                                        v18_82 = (v18_78 * v18_81)
                                        v18_85 = v18_58:Name__a35f18ac()
                                        if v18_85 then
                                            v18_91 = v18_58:Name__d9ea32b7()
                                            v18_92 = (v18_91 + v18_82)
                                            v18_58:Name__a37322ec(v18_92)
                                            return
                                        else
                                            v18_86 = (v18_61).augmentAddedHealth
                                            v18_87 = (v18_86 or 0)
                                            v18_88 = (v18_87 + v18_82)
                                            v18_61.augmentAddedHealth = v18_88
                                            return
                                        end
                                    else
                                        return
                                    end
                                end
                            end
                        end
                    end
                end
                return
            end
        end
    end
    return
end
OnKillOrAssist = v19_48
return
