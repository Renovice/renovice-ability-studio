-- RENOVICE_HASH_FIELD: ClearGameMode
-- RENOVICE_HASH_FIELD: ClearPrimaryObjText
-- RENOVICE_HASH_FIELD: ClearSecondaryObjText
-- RENOVICE_HASH_FIELD: ClearTitleObjText
-- RENOVICE_HASH_FIELD: Closest
-- RENOVICE_HASH_FIELD: CreateTimerMgr
-- RENOVICE_HASH_FIELD: FormatNumber
-- RENOVICE_HASH_FIELD: FormatTime
-- RENOVICE_HASH_FIELD: GetNetString
-- RENOVICE_HASH_FIELD: GetPriorityOffset
-- RENOVICE_HASH_FIELD: IsFirstTimeInNode
-- RENOVICE_HASH_FIELD: IsGameModeInProgress
-- RENOVICE_HASH_FIELD: IsInGamePlay
-- RENOVICE_HASH_FIELD: IsTransmissionPlaying
-- RENOVICE_HASH_FIELD: PlayGlobalTransmission
-- RENOVICE_HASH_FIELD: PlayLocalTransmission
-- RENOVICE_HASH_FIELD: RemoveObjProgressBar
-- RENOVICE_HASH_FIELD: Round
-- RENOVICE_HASH_FIELD: SetGameMode
-- RENOVICE_HASH_FIELD: SetObjProgressBar
-- RENOVICE_HASH_FIELD: SetPrimaryObjText
-- RENOVICE_HASH_FIELD: SetSecondaryObjText
-- RENOVICE_HASH_FIELD: SetSubTitleObjText
-- RENOVICE_HASH_FIELD: SetTitleObjText
-- RENOVICE_HASH_FIELD: SetupMissionTransmissionSet
-- RENOVICE_HASH_FIELD: ShowTutorialHint
-- RENOVICE_HASH_FIELD: ShuffleTable
-- RENOVICE_HASH_FIELD: SortByLayerIndex
-- RENOVICE_HASH_FIELD: Ternary
-- RENOVICE_HASH_FIELD: TooltipEx
-- RENOVICE_HASH_FIELD: UpdateObjProgressBar
local frame_49 = {}
frame_49[0] = require
frame_49[2] = frame_49[0]("EE.Interface.Utilities")
frame_49[3] = require
frame_49[5] = frame_49[3]("Lotus.Interface.LotusUtilities")
frame_49[6] = require
frame_49[8] = frame_49[6]("Lotus.Scripts.Libs.TransmissionSet")
frame_49[9] = require
frame_49[11] = frame_49[9]("Lotus.Scripts.Libs.CommonGamemodeFunctions")
frame_49[12] = require
frame_49[14] = frame_49[12]("Lotus.Scripts.Libs.ObjectiveText")
frame_49[15] = require
frame_49[17] = frame_49[15]("Lotus.Scripts.Libs.LandscapeLib")
frame_49[18] = require
frame_49[20] = frame_49[18]("Lotus.Scripts.Duviri.ArenaLib")
frame_49[21] = require
frame_49[23] = frame_49[21]("Lotus.Interface.Libs.TimerMgr")
frame_49[24] = require
frame_49[26] = frame_49[24]("Lotus.Interface.Libs.ImGuiLib")
frame_49[27] = 1
frame_49[28] = 3
frame_49[29] = 0
frame_49[30] = nil
frame_49[31] = {}
frame_49[32] = 0
frame_49[33] = 0
frame_49[34] = {}
frame_49[34][1] = 8
frame_49[34][2] = 15
frame_49[34][3] = 25
frame_49[34][4] = 30
frame_49[39] = {}
frame_49[39][1] = 12
frame_49[39][2] = 25
frame_49[39][3] = 30
frame_49[39][4] = 35
frame_49[44] = {}
frame_49[44][1] = 7
frame_49[44][2] = 15
frame_49[44][3] = 25
frame_49[44][4] = 30
frame_49[49] = {}
frame_49[49][1] = 10
frame_49[49][2] = 25
frame_49[49][3] = 30
frame_49[49][4] = 35
frame_49[54] = {}
frame_49[54][1] = 5
frame_49[54][2] = 5
frame_49[54][3] = 5
frame_49[54][4] = 5
frame_49[59] = {}
frame_49[59][1] = 5
frame_49[59][2] = 5
frame_49[59][3] = 5
frame_49[59][4] = 5
frame_49[64] = 0
frame_49[65] = 0
frame_49[66] = 900
frame_49[67] = 1020
frame_49[68] = nil
frame_49[69] = 100
frame_49[70] = 100
frame_49[71] = false
frame_49[72] = Symbol
frame_49[74] = frame_49[72]("HiddenMissionTimer")
frame_49[75] = Symbol
frame_49[77] = frame_49[75]("ExcavationScanner")
frame_49[78] = Symbol
frame_49[80] = frame_49[78]("ExcavationExtractor")
frame_49[81] = Symbol
frame_49[83] = frame_49[81]("ExcavationExtractorSand")
frame_49[84] = Symbol
frame_49[86] = frame_49[84]("ExcavatorAvatar")
frame_49[87] = Symbol
frame_49[89] = frame_49[87]("ExcavationState")
frame_49[90] = Symbol
frame_49[92] = frame_49[90]("ExcavatorMover")
frame_49[93] = Symbol
frame_49[95] = frame_49[93]("ExcavationScannerDeco")
frame_49[96] = Symbol
frame_49[98] = frame_49[96]("ExcavationObjectiveMarker")
frame_49[99] = Symbol
frame_49[101] = frame_49[99]("ScannerTrigger")
frame_49[102] = Symbol
frame_49[104] = frame_49[102]("ExcavationState")
frame_49[105] = Symbol
frame_49[107] = frame_49[105]("ScannerPowerVal")
frame_49[108] = Symbol
frame_49[110] = frame_49[108]("ScanTime")
frame_49[111] = Symbol
frame_49[113] = frame_49[111]("TimeElapsed")
frame_49[114] = Symbol
frame_49[116] = frame_49[114]("DigsScore")
frame_49[117] = Symbol
frame_49[119] = frame_49[117]("Score")
frame_49[120] = Symbol
frame_49[122] = frame_49[120]("ExcavatorsSpawned")
frame_49[123] = Symbol
frame_49[125] = frame_49[123]("ExcavatorsStarted")
frame_49[126] = Symbol
frame_49[128] = frame_49[126]("ExcavatorsEnded")
frame_49[129] = Symbol
frame_49[131] = frame_49[129]("LastSuccessfulDig")
frame_49[132] = Symbol
frame_49[134] = frame_49[132]("RewardsGiven")
frame_49[135] = Symbol
frame_49[137] = frame_49[135]("LastBossSpawnTime")
frame_49[138] = Symbol
frame_49[140] = frame_49[138]("VoidProjectionFlow")
frame_49[141] = Symbol
frame_49[143] = frame_49[141]("DigsFullyCompleted")
frame_49[144] = Symbol
frame_49[146] = frame_49[144]("CustomMissionHealth")
frame_49[147] = Symbol
frame_49[149] = frame_49[147]("PossibleAFKFarming")
frame_49[150] = Symbol
frame_49[152] = frame_49[150]("ExcavatorStatesCount")
frame_49[153] = Symbol
frame_49[155] = frame_49[153]("mArenaComplete")
frame_49[156] = Symbol
frame_49[158] = frame_49[156]("Infestation")
frame_49[159] = Symbol
frame_49[161] = frame_49[159]("RandomTeam")
frame_49[162] = Symbol
frame_49[164] = frame_49[162]("DefenseAgentSpawn")
frame_49[165] = Symbol
frame_49[167] = frame_49[165]("BipedSpecialSpawn")
frame_49[168] = Symbol
frame_49[170] = frame_49[168]("DoNotUse")
frame_49[171] = Symbol
frame_49[173] = frame_49[171]("CameraSpawn")
frame_49[174] = Symbol
frame_49[176] = frame_49[174]("TurretSpawn")
frame_49[177] = Symbol
frame_49[179] = frame_49[177]("ExitMarker")
frame_49[180] = Symbol
frame_49[182] = frame_49[180]("MissionExtractionAvailable")
frame_49[183] = Symbol
frame_49[185] = frame_49[183]("MissionExcavatorItemFound")
frame_49[186] = Symbol
frame_49[188] = frame_49[186]("NV_FOUND_PISTOLS")
frame_49[189] = nil
frame_49[190] = Symbol
frame_49[192] = frame_49[190]("BeamAttach")
frame_49[193] = Symbol
frame_49[195] = frame_49[193]("BeamX")
frame_49[196] = Symbol
frame_49[198] = frame_49[196]("BeamY")
frame_49[199] = Symbol
frame_49[201] = frame_49[199]("BeamZ")
frame_49[202] = Type
frame_49[204] = frame_49[202]("/Lotus/Fx/Gameplay/MoonShieldBeam")
frame_49[205] = nil
frame_49[206] = nil
frame_49[207] = nil
frame_49[208] = nil
frame_49[209] = Symbol
frame_49[211] = frame_49[209]("SolNode332")
frame_49[212] = false
frame_49[213] = nil
frame_49[214] = nil
frame_49[215] = Resource
frame_49[217] = frame_49[215]("/Lotus/Interface/SurvivalReward.swf")
frame_49[218] = Symbol
frame_49[220] = frame_49[218]("DuviriQuest")
frame_49[221] = WeakResource
frame_49[223] = frame_49[221]("/Lotus/Types/Friendly/PlayerControllable/ControllableDuviriDrifterTennoAvatar")
frame_49[224] = WeakResource
frame_49[226] = frame_49[224]("/Lotus/Types/PickUps/VoidTearSealerPickup")
frame_49[227] = WeakResource
frame_49[229] = frame_49[227]("/Lotus/Types/PickUps/VoidTearSealerItem")
frame_49[230] = WeakResource
frame_49[232] = frame_49[230]("/Lotus/Fx/Gameplay/Excavation/ExcavationPillar")
frame_49["cap_49_240_1"] = frame_49[20]
frame_49[233] = function()
    local v0_0
    local v0_1
    local v0_2
    local v0_3
    local v0_4
    local v0_5
    local v0_6
    local v0_7
    v0_0 = frame_49[212]
    if not (v0_0) then
        v0_7 = gPromotedToHost
        return v0_7
    else
        v0_1 = gRegion
        v0_4 = v0_1:IsMaster()
        if v0_4 then
            v0_5 = frame_49["cap_49_240_1"]
            v0_6 = (v0_5).IsGameModeInProgress
            v0_4 = v0_6()
        end
        return v0_4
    end
end
frame_49["cap_49_243_0"] = frame_49[5]
frame_49[234] = function()
    local v1_0
    local v1_1
    local v1_2
    local v1_3
    local v1_4
    local v1_5
    local v1_6
    local v1_7
    local v1_8
    local v1_9
    local v1_10
    local v1_11
    local v1_12
    local v1_13
    local v1_14
    local v1_15
    v1_0 = gRegion
    v1_1 = IsNull
    v1_2 = v1_1(v1_0)
    if not (v1_2) then
        v1_3 = gRegion
        v1_6 = v1_3:GetHumanPlayers()
        v1_7 = 1
        v1_8 = (#v1_6)
        v1_9 = 1
        for v1_7 = v1_7, v1_8, v1_9 do
            v1_10 = frame_49["cap_49_243_0"]
            v1_11 = (v1_10).IsFirstTimeInNode
            v1_12 = v1_6[v1_7]
            v1_13 = v1_11(v1_12)
            if not (not (v1_13)) then
                return true
            end
        end
    end
    return false
end
frame_49["cap_49_245_0"] = frame_49[5]
frame_49[235] = function()
    local v2_0
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
    v2_0 = true
    v2_1 = gGameRules
    v2_4 = v2_1:GetMission()
    v2_5 = (v2_4).periodicMissionTag
    v2_6 = frame_49["cap_49_245_0"]
    v2_7 = (v2_6).ELITE_ALERT_PERIODIC_MISSION_TAG
    if not (v2_5 == v2_7) then
        v2_8 = gGameRules
        v2_11 = v2_8:GetMission()
        v2_12 = (v2_11).periodicMissionTag
        v2_13 = frame_49["cap_49_245_0"]
        v2_14 = (v2_13).ELITE_ALERT_PERIODIC_MISSION_TAG_ALT
        if v2_12 == v2_14 then
            v2_0 = true
        else
            v2_0 = false
        end
    end
    return v2_0
end
frame_49[236] = function(p3_0)
    local v3_1
    local v3_2
    local v3_3
    local v3_4
    local v3_5
    local v3_6
    local v3_7
    local v3_8
    local v3_9
    local v3_10
    local v3_11
    local v3_12
    local v3_13
    local v3_14
    local v3_15
    v3_1 = gLotusVehicleAvatarType
    v3_4 = p3_0:IsA(v3_1)
    if v3_4 then
        v3_7 = p3_0:IsHoverboard()
        if not (v3_7) then
        else
            v3_10 = p3_0:GetRider()
            if not (v3_10) then
            else
                return p3_0:GetRider()
            end
        end
    end
    return p3_0
end
frame_49[237] = function(p4_0, p4_1)
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
    local v4_28
    local v4_29
    local v4_30
    local v4_31
    local v4_32
    local v4_33
    local v4_34
    local v4_35
    local v4_36
    local v4_37
    local v4_38
    local v4_39
    local v4_40
    local v4_41
    local v4_42
    local v4_43
    local v4_44
    local v4_45
    local v4_46
    local v4_47
    local v4_48
    local v4_49
    v4_2 = p4_0
    v4_3 = IsNull
    v4_4 = v4_3(v4_2)
    if not (v4_4) then
        v4_5 = gRegion
        v4_8 = v4_5:GetHumanPlayerAvatars()
        v4_10 = v4_8
        for v4_48, v4_49 in ipairs(v4_10) do
            v4_20 = IsNull
            v4_21 = v4_20(v4_49:GetPlayer())
            if not (v4_21) then
                v4_24 = v4_49:GetPlayer()
                v4_27 = v4_24:IsActive()
                if v4_27 then
                    v4_28 = gLotusVehicleAvatarType
                    v4_31 = v4_49:IsA(v4_28)
                    local sc_4_5
                    if not (v4_31) then
                        sc_4_5 = true
                    else
                        v4_34 = v4_49:IsHoverboard()
                        if not (v4_34) then
                            sc_4_5 = true
                        else
                            v4_37 = v4_49:GetRider()
                            sc_4_5 = not (v4_37)
                        end
                    end
                    if sc_4_5 then
                        v4_40 = v4_49
                    else
                        v4_40 = v4_49:GetRider()
                    end
                    v4_43 = v4_40:InventoryControl()
                    v4_44 = p4_0
                    v4_45 = p4_1
                    v4_43:AddMiscItem(v4_44, v4_45)
                end
            end
        end
        return
    else
        return
    end
end
frame_49[238] = function(p5_0, p5_1, p5_2, p5_3)
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
    if not (p5_3) then
        p5_0:SetVisibility(false, false)
        v5_37 = p5_1
        for v5_46, v5_47 in ipairs(v5_37) do
            v5_41 = v5_47
            v5_42 = IsNull
            v5_43 = v5_42(v5_41)
            if not (v5_43) then
                v5_47:Disable()
            end
        end
        v5_49 = p5_2
        for v5_58, v5_59 in ipairs(v5_49) do
            v5_53 = v5_59
            v5_54 = IsNull
            v5_55 = v5_54(v5_53)
            if not (v5_55) then
                v5_59:Disable()
            end
        end
        return
    else
        p5_0:SetVisibility(true, false)
        v5_9 = p5_1
        for v5_18, v5_19 in ipairs(v5_9) do
            v5_13 = v5_19
            v5_14 = IsNull
            v5_15 = v5_14(v5_13)
            if not (v5_15) then
                v5_19:Enable()
            end
        end
        v5_21 = p5_2
        for v5_30, v5_31 in ipairs(v5_21) do
            v5_25 = v5_31
            v5_26 = IsNull
            v5_27 = v5_26(v5_25)
            if not (v5_27) then
                v5_31:Enable()
            end
        end
        return
    end
end
frame_49["cap_49_250_0"] = frame_49[89]
frame_49["cap_49_250_1"] = frame_49[238]
frame_49[239] = function(p6_0, p6_1)
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
    v6_2 = gRegion
    v6_3 = frame_49["cap_49_250_0"]
    v6_15 = v6_2:FindNearestTagged(v6_3, p6_0:GetPosition())
    v6_16 = gParticleSysType
    v6_19 = p6_1:GetAllAttachments(v6_16)
    v6_20 = gSequencerType
    v6_23 = p6_1:GetAllAttachments(v6_20)
    v6_24 = pillarType
    v6_27 = p6_1:GetAttachment(v6_24)
    v6_30 = v6_15:IsEnabled()
    if v6_30 then
        v6_33 = v6_15:GetPower()
        if 0 < v6_33 then
            v6_30 = true
        else
            v6_30 = false
        end
    end
    v6_35 = frame_49["cap_49_250_1"]
    v6_36 = v6_27
    v6_37 = v6_19
    v6_38 = v6_23
    v6_39 = v6_30
    v6_35(v6_36, v6_37, v6_38, v6_39)
    return
end
ShowExcavationFX = frame_49[239]
frame_49[240] = function(p7_0, p7_1, p7_2)
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
    local v7_25
    local v7_26
    local v7_27
    v7_3 = p7_0
    v7_4 = IsNull
    v7_5 = v7_4(v7_3)
    if not (v7_5) then
        v7_6 = p7_1
        v7_9 = p7_0:GetAllAttachments(v7_6)
        v7_11 = v7_9
        for v7_26, v7_27 in ipairs(v7_11) do
            v7_17 = v7_27:GetTag()
            local sc_7_2
            if v7_17 == p7_2 then
                sc_7_2 = true
            else
                v7_18 = v7_17
                v7_19 = IsNull
                v7_20 = v7_19(v7_18)
                if v7_20 then
                    sc_7_2 = true
                else
                    v7_21 = p7_2
                    v7_22 = IsNull
                    v7_23 = v7_22(v7_21)
                    sc_7_2 = v7_23
                end
            end
            if not (sc_7_2) then continue end
            v7_27:Destroy()
        end
    end
    return
end
frame_49["cap_49_255_0"] = frame_49[110]
frame_49[241] = function(p8_0)
    local v8_1
    local v8_2
    local v8_3
    local v8_4
    local v8_5
    local v8_6
    local v8_7
    local v8_8
    v8_1 = gGameRules
    if p8_0 < 0 then
        p8_0 = 0
    end
    v8_3 = frame_49["cap_49_255_0"]
    v8_4 = (p8_0 * 16384)
    v8_5 = math.ceil
    v8_6 = v8_5(v8_4)
    v8_1:SetNetPersistentVar(v8_3, v8_6)
    return
end
frame_49["cap_49_257_0"] = frame_49[110]
frame_49[242] = function()
    local v9_0
    local v9_1
    local v9_2
    local v9_3
    local v9_4
    local v9_5
    v9_0 = gGameRules
    v9_1 = frame_49["cap_49_257_0"]
    v9_4 = v9_0:GetNetPersistentVar(v9_1)
    v9_5 = (v9_4 / 16384)
    return v9_5
end
frame_49["cap_49_259_0"] = frame_49[217]
frame_49[243] = function(p10_0)
    local v10_1
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
    local v10_13
    local v10_14
    local v10_15
    local v10_16
    local v10_17
    local v10_18
    v10_1 = gFlashMgr
    v10_2 = frame_49["cap_49_259_0"]
    v10_5 = v10_1:PushMovie(v10_2)
    v10_6 = v10_5
    v10_7 = IsNull
    v10_8 = v10_7(v10_6)
    if not (v10_8) then
        v10_10 = p10_0
        v10_11 = tostring
        v10_12 = v10_11(v10_10)
        v10_5:Execute("ShowReward", v10_12)
        v10_15 = print
        v10_17 = p10_0
        v10_18 = ("Survival: Gave reward tier " .. v10_17)
        v10_15(v10_18)
    end
    return
end
frame_49["cap_49_261_0"] = frame_49[134]
frame_49["cap_49_261_1"] = frame_49[217]
frame_49["cap_49_261_2"] = frame_49[192]
frame_49["cap_49_261_3"] = frame_49[204]
frame_49["cap_49_261_4"] = frame_49[195]
frame_49["cap_49_261_5"] = frame_49[198]
frame_49["cap_49_261_6"] = frame_49[201]
frame_49["cap_49_261_7"] = frame_49[240]
frame_49[244] = function()
    local v11_0
    local v11_1
    local v11_2
    local v11_3
    local v11_4
    local v11_5
    local v11_6
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
    local v11_118
    local v11_119
    local v11_120
    local v11_121
    local v11_122
    local v11_123
    local v11_124
    local v11_125
    local v11_126
    local v11_127
    local v11_128
    local v11_129
    local v11_130
    local v11_131
    local v11_132
    local v11_133
    local v11_134
    local v11_135
    local v11_136
    local v11_137
    local v11_138
    local v11_139
    local v11_140
    local v11_141
    local v11_142
    local v11_143
    local v11_144
    local v11_145
    local v11_146
    local v11_147
    local v11_148
    local v11_149
    v11_0 = print
    v11_0("excavation: starting client loop")
    v11_2 = gGameRules
    while true do
        v11_3 = v11_2
        v11_4 = IsNull
        v11_5 = v11_4(v11_3)
        if not (v11_5) then break end
        v11_6 = Sleep
        v11_6(0)
        v11_2 = gGameRules
    end
    v11_8 = frame_49["cap_49_261_0"]
    v11_12 = v11_2:GetNetPersistentVar(v11_8, 65535)
    while true do
        v11_13 = gPromotedToHost
        if v11_13 then break end
        v11_14 = v11_2
        v11_15 = IsNull
        v11_16 = v11_15(v11_14)
        if not (not (v11_16)) then
            break
        end
        v11_19 = frame_49["cap_49_261_0"]
        v11_22 = v11_2:GetNetPersistentVar(v11_19)
        if not (v11_12 == v11_22) then
            if not (v11_12 < v11_22) then
                if not (v11_12 ~= 65535) then
                    v11_58 = print
                    v11_60 = v11_22
                    v11_61 = tostring
                    v11_62 = v11_61(v11_60)
                    v11_63 = ("Reward count not yet initialized, setting to " .. v11_62)
                    v11_58(v11_63)
                    v11_12 = v11_22
                end
            else
                v11_2:Name__94db44db()
                v11_25 = (v11_22 - 1)
                v11_2:OnTieredRewardRoundOver(v11_25)
                while true do
                    if v11_12 == v11_22 then break end
                    v11_28 = print
                    v11_30 = v11_22
                    v11_31 = tostring
                    v11_32 = v11_31(v11_30)
                    v11_33 = v11_32
                    v11_35 = v11_12
                    v11_36 = tostring
                    v11_37 = v11_36(v11_35)
                    v11_38 = ("Client: trying to catch up with new reward count= " .. v11_33 .. ", current=" .. v11_37)
                    v11_28(v11_38)
                    v11_12 = (v11_12 + 1)
                    v11_39 = v11_12
                    v11_40 = gFlashMgr
                    v11_41 = frame_49["cap_49_261_1"]
                    v11_44 = v11_40:PushMovie(v11_41)
                    v11_45 = v11_44
                    v11_46 = IsNull
                    v11_47 = v11_46(v11_45)
                    if not (v11_47) then
                        v11_49 = v11_39
                        v11_50 = tostring
                        v11_51 = v11_50(v11_49)
                        v11_44:Execute("ShowReward", v11_51)
                        v11_54 = print
                        v11_56 = v11_39
                        v11_57 = ("Survival: Gave reward tier " .. v11_56)
                        v11_54(v11_57)
                    end
                end
            end
        end
        v11_64 = gRegion
        v11_65 = IsNull
        v11_66 = v11_65(v11_64)
        if not (v11_66) then
            v11_67 = gRegion
            v11_70 = v11_67:GetHumanPlayers()
            v11_71 = 1
            v11_72 = (#v11_70)
            v11_73 = 1
            for v11_71 = v11_71, v11_72, v11_73 do
                v11_74 = v11_70[v11_71]
                v11_77 = v11_74:GetMissionData()
                v11_78 = v11_70[v11_71]
                v11_81 = v11_78:GetAvatar()
                v11_82 = v11_77
                v11_83 = IsNull
                v11_84 = v11_83(v11_82)
                if not (v11_84) then
                    v11_85 = frame_49["cap_49_261_2"]
                    v11_88 = v11_77:Name__2b56de52(v11_85)
                    if v11_88 ~= 1 then
                        v11_144 = frame_49["cap_49_261_7"]
                        v11_145 = v11_81
                        v11_146 = frame_49["cap_49_261_3"]
                        v11_144(v11_145, v11_146, nil)
                    else
                        v11_89 = v11_81
                        v11_90 = IsNull
                        v11_91 = v11_90(v11_89)
                        if not (v11_91) then
                            v11_92 = frame_49["cap_49_261_3"]
                            v11_95 = v11_81:GetAttachment(v11_92)
                            v11_96 = v11_95
                            v11_97 = IsNull
                            v11_98 = v11_97(v11_96)
                            if v11_98 then
                                v11_101 = v11_81:DamageControl()
                                v11_105 = v11_101:Name__b7c91969(0)
                                v11_106 = frame_49["cap_49_261_3"]
                                v11_107 = v11_105
                                v11_108 = Vector
                                v11_118 = v11_81:Attach(v11_106, v11_107, v11_108(-0.2, 0, 0))
                                v11_95 = v11_118
                            end
                            v11_119 = v11_95
                            v11_120 = IsNull
                            v11_121 = v11_120(v11_119)
                            if not (v11_121) then
                                v11_122 = Vector
                                v11_123 = frame_49["cap_49_261_4"]
                                v11_126 = v11_77:Name__2b56de52(v11_123)
                                v11_127 = frame_49["cap_49_261_5"]
                                v11_130 = v11_77:Name__2b56de52(v11_127)
                                v11_131 = frame_49["cap_49_261_6"]
                                v11_140 = v11_122(v11_126, v11_130, v11_77:Name__2b56de52(v11_131))
                                v11_141 = v11_140
                                v11_95:SetEndPoint(v11_141)
                            end
                        end
                    end
                end
            end
        end
        v11_148 = Sleep
        v11_148(0)
    end
    v11_17 = print
    v11_17("Bailing on ExcavationLoopClient because I am now the host!")
    return
end
frame_49["cap_49_270_0"] = frame_49[134]
frame_49["cap_49_270_1"] = frame_49[217]
frame_49[245] = function()
    local v12_0
    local v12_1
    local v12_2
    local v12_3
    local v12_4
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
    v12_0 = gGameRules
    v12_1 = frame_49["cap_49_270_0"]
    v12_4 = v12_0:GetNetPersistentVar(v12_1)
    if v12_4 ~= 0 then
        v12_35 = (v12_4 + 1)
        v12_36 = gGameRules
        v12_37 = frame_49["cap_49_270_0"]
        v12_38 = v12_35
        v12_36:SetNetPersistentVar(v12_37, v12_38)
        v12_41 = gGameRules
        v12_42 = (v12_35 - 1)
        v12_41:OnTieredRewardRoundOver(v12_42)
        v12_45 = gFlashMgr
        v12_46 = frame_49["cap_49_270_1"]
        v12_49 = v12_45:PushMovie(v12_46)
        v12_50 = v12_49
        v12_51 = IsNull
        v12_52 = v12_51(v12_50)
        if not (v12_52) then
            v12_54 = v12_35
            v12_55 = tostring
            v12_56 = v12_55(v12_54)
            v12_49:Execute("ShowReward", v12_56)
            v12_59 = print
            v12_61 = v12_35
            v12_62 = ("Survival: Gave reward tier " .. v12_61)
            v12_59(v12_62)
        end
    else
        v12_5 = gGameRules
        v12_6 = frame_49["cap_49_270_0"]
        v12_5:SetNetPersistentVar(v12_6, 1)
        v12_10 = gGameRules
        v12_10:Name__94db44db()
        v12_13 = gGameRules
        v12_13:OnTieredRewardRoundOver(0)
        v12_17 = gFlashMgr
        v12_18 = frame_49["cap_49_270_1"]
        v12_21 = v12_17:PushMovie(v12_18)
        v12_22 = v12_21
        v12_23 = IsNull
        v12_24 = v12_23(v12_22)
        if v12_24 then
        else
            v12_27 = tostring
            v12_28 = v12_27(1)
            v12_21:Execute("ShowReward", v12_28)
            v12_31 = print
            v12_34 = ("Survival: Gave reward tier " .. 1)
            v12_31(v12_34)
            return
        end
    end
    return
end
frame_49["cap_49_273_1"] = frame_49[86]
frame_49[246] = function(p13_0, p13_1, p13_2, p13_3)
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
    local v13_41
    local v13_42
    local v13_43
    local v13_44
    local v13_45
    local v13_46
    local v13_47
    local v13_48
    local v13_49
    local v13_50
    local v13_51
    local v13_52
    local v13_53
    local v13_54
    local v13_55
    local v13_56
    local v13_57
    local v13_58
    local v13_59
    local v13_60
    local v13_61
    local v13_62
    local v13_63
    local v13_64
    local v13_65
    local v13_66
    local v13_67
    local v13_68
    local v13_69
    local v13_70
    local v13_71
    local v13_72
    local v13_73
    local v13_74
    local v13_75
    local v13_76
    local v13_77
    local v13_78
    local v13_79
    local v13_80
    local v13_81
    local v13_82
    local v13_83
    local v13_84
    local v13_85
    local v13_86
    local v13_87
    local v13_88
    v13_6 = p13_0:GetAvatar()
    v13_7 = v13_6
    v13_8 = IsNull
    v13_9 = v13_8(v13_7)
    if not (v13_9) then
        v13_10 = gRegion
        v13_11 = v13_6
        v13_12 = p13_1
        v13_15 = v13_10:Name__81993ba3(v13_11, v13_12)
        v13_16 = nil
        v13_17 = gRegion
        v13_20 = v13_17:GetNpcMgr()
        v13_23 = v13_20:GetAiDirector()
        v13_24 = v13_15
        v13_25 = IsNull
        v13_26 = v13_25(v13_24)
        if v13_26 then
            v13_27 = frame_49[212]
            if v13_27 then
                v13_28 = gRegion
                v13_29 = frame_49["cap_49_273_1"]
                v13_37 = v13_28:FindNearestTagged(v13_29, v13_6:GetPosition())
                v13_15 = v13_37
            end
        end
        if 0 < p13_2 then
            v13_39 = gRegion
            v13_40 = v13_6
            v13_41 = p13_3
            v13_44 = v13_39:Name__81993ba3(v13_40, v13_41)
            v13_16 = v13_44
            v13_45 = v13_16
            v13_46 = IsNull
            v13_47 = v13_46(v13_45)
            if v13_47 then
                v13_48 = frame_49[212]
                if v13_48 then
                    v13_49 = v13_6
                    v13_52 = v13_23:PlayAlternatebuff(v13_49)
                    v13_16 = v13_52
                end
            end
        end
        v13_53 = v13_15
        v13_54 = IsNull
        v13_55 = v13_54(v13_53)
        if v13_55 then
            v13_56 = v13_16
            v13_57 = IsNull
            v13_58 = v13_57(v13_56)
            if not (v13_58) then
            else
                return
            end
        end
        v13_59 = v13_15
        v13_60 = IsNull
        v13_61 = v13_60(v13_59)
        if not (v13_61) then
            v13_65 = v13_16
            v13_66 = IsNull
            v13_67 = v13_66(v13_65)
            if not (v13_67) then
                v13_73 = v13_6:GetPosition()
                v13_74 = v13_73
                v13_77 = v13_15:DistanceToPoint(v13_74)
                v13_78 = v13_73
                v13_81 = v13_16:DistanceToPoint(v13_78)
                v13_82 = (v13_81 + 25)
                if not (v13_82 < v13_77) then
                    v13_86 = v13_15
                    p13_0:StormTarget(v13_86)
                    return
                else
                    v13_83 = v13_16
                    p13_0:StormTarget(v13_83)
                    return
                end
            else
                v13_68 = v13_15
                p13_0:StormTarget(v13_68)
                return
            end
        else
            v13_62 = v13_16
            p13_0:StormTarget(v13_62)
            return
        end
    else
        return
    end
end
frame_49["cap_49_276_0"] = frame_49[125]
frame_49["cap_49_276_1"] = frame_49[246]
frame_49[247] = function(p14_0)
    local v14_1
    local v14_2
    local v14_3
    local v14_4
    local v14_5
    local v14_6
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
    local v14_57
    local v14_58
    local v14_59
    local v14_60
    local v14_61
    local v14_62
    local v14_63
    local v14_64
    local v14_65
    local v14_66
    local v14_67
    local v14_68
    local v14_69
    local v14_70
    local v14_71
    local v14_72
    local v14_73
    local v14_74
    local v14_75
    local v14_76
    local v14_77
    local v14_78
    local v14_79
    local v14_80
    local v14_81
    local v14_82
    local v14_83
    local v14_84
    local v14_85
    local v14_86
    local v14_87
    local v14_88
    local v14_89
    local v14_90
    local v14_91
    local v14_92
    local v14_93
    local v14_94
    local v14_95
    local v14_96
    local v14_97
    local v14_98
    local v14_99
    local v14_100
    local v14_101
    local v14_102
    local v14_103
    local v14_104
    local v14_105
    local v14_106
    local v14_107
    local v14_108
    local v14_109
    local v14_110
    v14_1 = gRegion
    v14_4 = v14_1:GetHumanPlayerAvatars()
    v14_6 = v14_4
    for v14_17, v14_18 in ipairs(v14_6) do
        v14_10 = v14_18
        v14_11 = IsNull
        v14_12 = v14_11(v14_10)
        if not (v14_12) then
            v14_15 = v14_18:IsKilled()
            if v14_15 then
                v14_4[v14_17] = nil
            end
        end
    end
    v14_19 = gGameRules
    v14_20 = frame_49["cap_49_276_0"]
    v14_24 = v14_19:GetNetPersistentVar(v14_20, 0)
    v14_25 = gRegion
    v14_28 = v14_25:GetNpcMgr()
    v14_31 = v14_28:GetAiDirector()
    v14_37 = v14_31:Name__e0776624(nil, 10000, false)
    v14_38 = (#v14_37)
    v14_39 = 1
    v14_40 = -1
    for v14_38 = v14_38, v14_39, v14_40 do
        v14_41 = v14_37[v14_38]
        v14_42 = v14_41
        v14_43 = IsNull
        v14_44 = v14_43(v14_42)
        if not (v14_44) then
            v14_47 = v14_41:GetStormTarget()
            v14_48 = (#p14_0)
            local sc_14_7
            if not (0 < v14_48) then
                sc_14_7 = true
            else
                v14_50 = v14_47
                v14_51 = IsNull
                v14_52 = v14_51(v14_50)
                if v14_52 then
                    sc_14_7 = true
                else
                    v14_53 = gAvatarType
                    v14_56 = v14_47:IsA(v14_53)
                    if not (v14_56) then
                        sc_14_7 = true
                    else
                        v14_63 = IsNull
                        v14_64 = v14_63(v14_47:GetPlayer())
                        sc_14_7 = v14_64
                    end
                end
            end
            if sc_14_7 then
                v14_65 = v14_47
                v14_66 = IsNull
                v14_67 = v14_66(v14_65)
                if not (v14_67) then
                    v14_68 = gAvatarType
                    v14_71 = v14_47:IsA(v14_68)
                    if v14_71 then
                        v14_74 = v14_47:IsKilled()
                        if v14_74 then
                            v14_75 = v14_47
                            v14_31:Name__ae3a6128(v14_75)
                            v14_47 = nil
                        end
                    end
                end
            else
                v14_47 = nil
            end
            v14_78 = v14_47
            v14_79 = IsNull
            v14_80 = v14_79(v14_78)
            if not (v14_80) then
                v14_86 = print
                v14_90 = v14_47:GetFullName()
                v14_91 = ("Keeping existing target of " .. v14_90)
                v14_86(v14_91)
            else
                v14_81 = frame_49["cap_49_276_1"]
                v14_82 = v14_41
                v14_83 = p14_0
                v14_84 = v14_24
                v14_85 = v14_4
                v14_81(v14_82, v14_83, v14_84, v14_85)
            end
        end
    end
    v14_92 = (#p14_0)
    if not (0 < v14_92) then
        return
    else
        v14_94 = RandomInt
        v14_96 = (#p14_0)
        v14_97 = v14_94(1, v14_96)
        v14_98 = p14_0[v14_97]
        v14_99 = v14_98
        v14_31:SetObjective(v14_99)
        v14_102 = v14_98
        v14_31:Name__7fccb7d5(v14_102)
        v14_105 = print
        v14_109 = v14_98:GetFullName()
        v14_110 = ("SetObjective " .. v14_109)
        v14_105(v14_110)
        return
    end
end
frame_49[248] = function()
    local v15_0
    local v15_1
    local v15_2
    local v15_3
    local v15_4
    local v15_5
    local v15_6
    local v15_7
    local v15_8
    local v15_9
    local v15_10
    local v15_11
    local v15_12
    local v15_13
    local v15_14
    local v15_15
    local v15_16
    local v15_17
    local v15_18
    v15_0 = _T.EndlessModeEnemyLevel
    v15_1 = IsNull
    v15_2 = v15_1(v15_0)
    if v15_2 then
        v15_3 = gRegion
        v15_6 = v15_3:GetNpcMgr()
        v15_9 = v15_6:GetAiDirector()
        v15_10 = _T
        v15_13 = v15_9:GetMinEnemyLevel()
        v15_10.EndlessModeEnemyLevel = v15_13
    end
    v15_14 = _T.EndlessModeEnemyLevel
    v15_15 = (v15_14 / 30)
    v15_17 = math.min
    v15_18 = v15_17(v15_15, 1)
    return v15_18
end
frame_49["cap_49_280_0"] = frame_49[246]
frame_49[249] = function(p16_0, p16_1, p16_2, p16_3)
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
    p16_0:SetAlert()
    v16_6 = Sleep
    v16_6(0)
    v16_8 = p16_0
    v16_9 = IsNull
    v16_10 = v16_9(v16_8)
    if not (v16_10) then
        v16_12 = p16_3
        for v16_23, v16_24 in ipairs(v16_12) do
            v16_16 = v16_24
            v16_17 = IsNull
            v16_18 = v16_17(v16_16)
            if not (v16_18) then
                v16_21 = v16_24:IsKilled()
                if v16_21 then
                    p16_3[v16_23] = nil
                end
            end
        end
        v16_25 = frame_49["cap_49_280_0"]
        v16_26 = p16_0
        v16_27 = p16_1
        v16_28 = p16_2
        v16_29 = p16_3
        v16_25(v16_26, v16_27, v16_28, v16_29)
        return
    else
        return
    end
end
frame_49["cap_49_282_0"] = frame_49[220]
frame_49[250] = function()
    local v17_0
    local v17_1
    local v17_2
    local v17_3
    local v17_4
    local v17_5
    local v17_6
    local v17_7
    local v17_8
    local v17_9
    local v17_10
    local v17_11
    local v17_12
    local v17_13
    local v17_14
    local v17_15
    local v17_16
    local v17_17
    local v17_18
    local v17_19
    local v17_20
    local v17_21
    local v17_22
    local v17_23
    local v17_24
    local v17_25
    v17_0 = gGameRules
    v17_3 = v17_0:GetMission()
    v17_4 = (v17_3).enemySpec
    v17_5 = 0
    v17_6 = v17_4
    v17_7 = IsNull
    v17_8 = v17_7(v17_6)
    if not (v17_8) then
        v17_11 = v17_4:GetEnemies()
        v17_13 = v17_11
        for v17_22, v17_23 in ipairs(v17_13) do
            v17_17 = (v17_23).tier
            if not (v17_17 ~= 9) then
                v17_18 = (v17_23).maxSimultaneous
                v17_19 = v17_5
                v17_20 = math.max
                v17_21 = v17_20(v17_19, v17_18)
                v17_5 = v17_21
            end
        end
    end
    v17_24 = (v17_3).goalTag
    v17_25 = frame_49["cap_49_282_0"]
    if not (v17_24 ~= v17_25) then
        v17_5 = 0
    end
    return v17_5
end
frame_49[251] = function(p18_0)
    local v18_1
    local v18_2
    local v18_3
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
    v18_2 = p18_0
    for v18_11, v18_12 in ipairs(v18_2) do
        v18_8 = v18_12:GetPower()
        if not (0 < v18_8) then continue end
        return true
    end
    return false
end
frame_49["cap_49_285_4"] = frame_49[137]
frame_49["cap_49_285_5"] = frame_49[250]
frame_49["cap_49_285_6"] = frame_49[161]
frame_49["cap_49_285_7"] = frame_49[249]
frame_49["cap_49_285_8"] = frame_49[220]
frame_49["cap_49_285_9"] = frame_49[17]
frame_49["cap_49_285_10"] = frame_49[119]
frame_49[252] = function(p19_0, p19_1, p19_2, p19_3)
    local frame_19 = {}
    local cfg_19 = 0
    while true do
        if cfg_19 == 0 then
            frame_19[4] = gRegion
            frame_19[7] = (frame_19[4]):GetNpcMgr()
            frame_19[10] = (frame_19[7]):GetAiDirector()
            frame_19[13] = (frame_19[10]):GetMinEnemyLevel()
            frame_19[16] = (frame_19[10]):GetMaxEnemyLevel()
            frame_19[17] = nil
            frame_19[18] = frame_49[206]
            if not (frame_19[18]) then
                cfg_19 = 2
            else
                cfg_19 = 1
            end
        elseif cfg_19 == 1 then
            frame_19[16] = (frame_19[13] + 5)
            cfg_19 = 2
        elseif cfg_19 == 2 then
            frame_19[19] = frame_49[67]
            if not (frame_19[19] < p19_0) then
                cfg_19 = 4
            else
                cfg_19 = 3
            end
        elseif cfg_19 == 3 then
            frame_19[20] = frame_49[67]
            frame_19[21] = (p19_0 - frame_19[20])
            frame_19[22] = (frame_19[21] / 40)
            frame_19[23] = (frame_19[22] * 0.13)
            frame_19[24] = (40 - frame_19[23])
            frame_19[25] = math.floor
            frame_19[26] = frame_19[25](frame_19[24])
            frame_19[28] = math.max
            frame_19[29] = frame_19[28](frame_19[26], 5)
            frame_19[30] = frame_49[67]
            frame_19[31] = (p19_0 - frame_19[30])
            frame_19[32] = (frame_19[31] / frame_19[29])
            frame_19[33] = math.floor
            frame_19[34] = frame_19[33](frame_19[32])
            frame_19[35] = (frame_19[16] + frame_19[34])
            cfg_19 = 5
        elseif cfg_19 == 4 then
            frame_19[36] = frame_49[66]
            frame_19[37] = (p19_0 / frame_19[36])
            frame_19[38] = Lerp
            frame_19[39] = frame_19[13]
            frame_19[40] = frame_19[16]
            frame_19[41] = frame_19[37]
            frame_19[42] = frame_19[38](frame_19[39], frame_19[40], frame_19[41])
            frame_19[35] = frame_19[42]
            cfg_19 = 5
        elseif cfg_19 == 5 then
            frame_19[43] = frame_49[212]
            if not (frame_19[43]) then
                cfg_19 = 7
            else
                cfg_19 = 6
            end
        elseif cfg_19 == 6 then
            frame_19[35] = (frame_19[35] + 0)
            cfg_19 = 7
        elseif cfg_19 == 7 then
            frame_19[44] = Engine.EngineNpcAgent_MAX_LEVEL
            frame_19[45] = frame_19[35]
            frame_19[46] = math.min
            frame_19[47] = frame_19[46](frame_19[45], frame_19[44])
            frame_19[48] = frame_19[47]
            frame_19[49] = _T
            frame_19[49].EndlessModeEnemyLevel = frame_19[48]
            frame_19[50] = (p19_0 % 300)
            if not (300 < p19_0) then
                cfg_19 = 15
            else
                cfg_19 = 8
            end
        elseif cfg_19 == 8 then
            if not (0 <= frame_19[50]) then
                cfg_19 = 15
            else
                cfg_19 = 9
            end
        elseif cfg_19 == 9 then
            if not (frame_19[50] < 15) then
                cfg_19 = 15
            else
                cfg_19 = 10
            end
        elseif cfg_19 == 10 then
            frame_19[54] = (p19_0 - frame_19[50])
            frame_19[55] = gGameRules
            frame_19[56] = frame_49["cap_49_285_4"]
            frame_19[59] = (frame_19[55]):GetNetPersistentVar(frame_19[56])
            if not (frame_19[59] < frame_19[54]) then
                cfg_19 = 15
            else
                cfg_19 = 11
            end
        elseif cfg_19 == 11 then
            do (frame_19[10]):SetCurrentTier(9, true) end
            frame_19[64] = frame_49["cap_49_285_5"]
            frame_19[65] = frame_19[64]()
            frame_19[66] = 1
            frame_19[67] = frame_19[65]
            frame_19[68] = 1
            local leave_for_19_12 = false
            for for_value_19_12 = frame_19[66], frame_19[67], frame_19[68] do
                frame_19[66] = for_value_19_12
                cfg_19 = 12
                while true do
                    if cfg_19 == 12 then
                        frame_19[70] = frame_49["cap_49_285_6"]
                        frame_19[71] = frame_19[48]
                        frame_19[76] = (frame_19[10]):CreateRandomAgent(nil, frame_19[70], frame_19[71], nil, 1)
                        frame_19[77] = frame_19[76]
                        frame_19[78] = IsNull
                        frame_19[79] = frame_19[78](frame_19[77])
                        if frame_19[79] then
                            cfg_19 = 14
                        else
                            cfg_19 = 13
                        end
                    elseif cfg_19 == 13 then
                        frame_19[80] = gGameRules
                        frame_19[81] = frame_49["cap_49_285_4"]
                        frame_19[82] = p19_0
                        do (frame_19[80]):SetNetPersistentVar(frame_19[81], frame_19[82]) end
                        frame_19[85] = frame_49["cap_49_285_7"]
                        frame_19[86] = frame_19[76]
                        frame_19[87] = p19_1
                        frame_19[88] = p19_2
                        frame_19[89] = p19_3
                        frame_19[85](frame_19[86], frame_19[87], frame_19[88], frame_19[89])
                        cfg_19 = 14
                    elseif cfg_19 == 14 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_19_12 then break end
            end
            if not leave_for_19_12 then
                cfg_19 = 15
            end
        elseif cfg_19 == 15 then
            frame_19[90] = (p19_0 / 120)
            frame_19[91] = math.floor
            frame_19[92] = frame_19[91](frame_19[90])
            frame_19[93] = (frame_19[92] * 1)
            frame_19[94] = frame_19[93]
            frame_19[96] = math.min
            frame_19[97] = frame_19[96](frame_19[94], 5)
            frame_19[98] = frame_19[97]
            frame_19[99] = frame_19[98]
            do (frame_19[10]):SetCurrentTier(frame_19[99]) end
            frame_19[102] = gGameRules
            frame_19[105] = (frame_19[102]):GetMission()
            frame_19[106] = 0
            frame_19[108] = Lerp
            frame_19[111] = (frame_19[105]).difficulty
            frame_19[112] = frame_19[108](120, 0, frame_19[111])
            frame_19[113] = (60 + frame_19[112])
            frame_19[115] = Lerp
            frame_19[118] = (frame_19[105]).difficulty
            frame_19[119] = frame_19[115](120, 0, frame_19[118])
            frame_19[120] = (3000 + frame_19[119])
            frame_19[121] = 0.02
            frame_19[122] = 0.15
            frame_19[123] = (frame_19[105]).goalTag
            frame_19[124] = frame_49["cap_49_285_8"]
            if frame_19[123] ~= frame_19[124] then
                cfg_19 = 17
            else
                cfg_19 = 16
            end
        elseif cfg_19 == 16 then
            frame_19[121] = 0
            frame_19[122] = 0
            cfg_19 = 17
        elseif cfg_19 == 17 then
            frame_19[125] = false
            frame_19[126] = (frame_19[105]).leadersAlwaysAllowed
            if not (frame_19[126]) then
                cfg_19 = 24
            else
                cfg_19 = 18
            end
        elseif cfg_19 == 18 then
            frame_19[127] = (frame_19[105]).sortieId
            if frame_19[127] ~= "" then
                cfg_19 = 21
            else
                cfg_19 = 19
            end
        elseif cfg_19 == 19 then
            frame_19[128] = (frame_19[105]).alertId
            if frame_19[128] ~= "" then
                cfg_19 = 21
            else
                cfg_19 = 20
            end
        elseif cfg_19 == 20 then
            frame_19[129] = (frame_19[105]).goalId
            if frame_19[129] == "" then
                cfg_19 = 24
            else
                cfg_19 = 21
            end
        elseif cfg_19 == 21 then
            frame_19[130] = Clamp
            frame_19[131] = (frame_19[113] * 0.1)
            frame_19[133] = frame_19[113]
            frame_19[134] = frame_19[130](frame_19[131], 1, frame_19[133])
            frame_19[113] = frame_19[134]
            frame_19[135] = Clamp
            frame_19[136] = (frame_19[120] * 0.1)
            frame_19[138] = frame_19[120]
            frame_19[139] = frame_19[135](frame_19[136], 1, frame_19[138])
            frame_19[120] = frame_19[139]
            frame_19[140] = _T.IsLiteSortie
            if not (frame_19[140]) then
                cfg_19 = 23
            else
                cfg_19 = 22
            end
        elseif cfg_19 == 22 then
            frame_19[142] = gRegion
            frame_19[145] = (frame_19[142]):GetNumHumanPlayers()
            frame_19[146] = (frame_19[145] * 0.025)
            frame_19[122] = (0.05 + frame_19[146])
            cfg_19 = 28
        elseif cfg_19 == 23 then
            frame_19[121] = (frame_19[121] * 5)
            frame_19[122] = (frame_19[122] * 5)
            cfg_19 = 28
        elseif cfg_19 == 24 then
            frame_19[147] = frame_49[212]
            if not (frame_19[147]) then
                cfg_19 = 28
            else
                cfg_19 = 25
            end
        elseif cfg_19 == 25 then
            frame_19[148] = gGameRules
            frame_19[149] = Symbol
            frame_19[159] = (frame_19[148]):GetNetPersistentVar(frame_19[149]("mCurrentPortalId"))
            frame_19[160] = frame_49["cap_49_285_9"]
            frame_19[161] = (frame_19[160]).GetNetString
            frame_19[162] = frame_19[159]
            frame_19[163] = tostring
            frame_19[164] = frame_19[163](frame_19[162])
            frame_19[165] = frame_19[161](frame_19[164])
            frame_19[166] = frame_19[165]
            frame_19[167] = IsNull
            frame_19[168] = frame_19[167](frame_19[166])
            frame_19[169] = (not frame_19[168])
            if not (frame_19[169]) then
                cfg_19 = 27
            else
                cfg_19 = 26
            end
        elseif cfg_19 == 26 then
            frame_19[169] = (frame_19[165]).isStaticPortal
            cfg_19 = 27
        elseif cfg_19 == 27 then
            frame_19[125] = frame_19[169]
            cfg_19 = 28
        elseif cfg_19 == 28 then
            frame_19[170] = gGameRules
            frame_19[173] = (frame_19[170]):GetEximusMultiplier()
            frame_19[174] = (frame_19[121] * frame_19[173])
            frame_19[175] = (frame_19[122] * frame_19[173])
            if not (frame_19[125]) then
                cfg_19 = 31
            else
                cfg_19 = 29
            end
        elseif cfg_19 == 29 then
            frame_19[176] = gGameRules
            frame_19[177] = frame_49["cap_49_285_10"]
            frame_19[181] = (frame_19[176]):GetNetPersistentVar(frame_19[177], 0)
            frame_19[182] = (frame_19[181] / 500)
            frame_19[184] = math.min
            frame_19[185] = frame_19[184](frame_19[182], 1)
            frame_19[186] = Lerp
            frame_19[187] = frame_19[174]
            frame_19[188] = frame_19[175]
            frame_19[189] = frame_19[185]
            frame_19[190] = frame_19[186](frame_19[187], frame_19[188], frame_19[189])
            frame_19[191] = (frame_19[190] * 5)
            frame_19[192] = math.random
            frame_19[193] = frame_19[192]()
            if not (frame_19[193] <= frame_19[191]) then
                cfg_19 = 34
            else
                cfg_19 = 30
            end
        elseif cfg_19 == 30 then
            frame_19[106] = 1
            cfg_19 = 34
        elseif cfg_19 == 31 then
            if not (frame_19[113] <= p19_0) then
                cfg_19 = 34
            else
                cfg_19 = 32
            end
        elseif cfg_19 == 32 then
            frame_19[194] = (p19_0 - frame_19[113])
            frame_19[195] = (frame_19[120] - frame_19[113])
            frame_19[196] = (frame_19[194] / frame_19[195])
            frame_19[198] = math.min
            frame_19[199] = frame_19[198](frame_19[196], 1)
            frame_19[200] = Lerp
            frame_19[201] = frame_19[174]
            frame_19[202] = frame_19[175]
            frame_19[203] = frame_19[199]
            frame_19[204] = frame_19[200](frame_19[201], frame_19[202], frame_19[203])
            frame_19[205] = math.random
            frame_19[206] = frame_19[205]()
            if not (frame_19[206] <= frame_19[204]) then
                cfg_19 = 34
            else
                cfg_19 = 33
            end
        elseif cfg_19 == 33 then
            frame_19[106] = 1
            cfg_19 = 34
        elseif cfg_19 == 34 then
            frame_19[208] = frame_49["cap_49_285_6"]
            frame_19[209] = frame_19[48]
            frame_19[211] = frame_19[106]
            frame_19[214] = (frame_19[10]):CreateRandomAgent(nil, frame_19[208], frame_19[209], nil, frame_19[211])
            frame_19[215] = frame_19[214]
            frame_19[216] = IsNull
            frame_19[217] = frame_19[216](frame_19[215])
            if not (frame_19[217]) then
                cfg_19 = 37
            else
                cfg_19 = 35
            end
        elseif cfg_19 == 35 then
            frame_19[218] = Time
            frame_19[219] = frame_19[218]()
            frame_19[220] = frame_49[32]
            if not (frame_19[220] < frame_19[219]) then
                cfg_19 = 38
            else
                cfg_19 = 36
            end
        elseif cfg_19 == 36 then
            frame_19[221] = print
            frame_19[221]("Could not spawn agent")
            frame_19[223] = (frame_19[219] + 5)
            frame_49[32] = frame_19[223]
            return frame_19[214]
        elseif cfg_19 == 37 then
            frame_19[224] = frame_49["cap_49_285_7"]
            frame_19[225] = frame_19[214]
            frame_19[226] = p19_1
            frame_19[227] = p19_2
            frame_19[228] = p19_3
            frame_19[224](frame_19[225], frame_19[226], frame_19[227], frame_19[228])
            cfg_19 = 38
        elseif cfg_19 == 38 then
            return frame_19[214]
        else
            error("invalid control state")
        end
    end
end
frame_49["cap_49_298_0"] = frame_49[220]
frame_49["cap_49_298_1"] = frame_49[54]
frame_49["cap_49_298_2"] = frame_49[59]
frame_49["cap_49_298_3"] = frame_49[158]
frame_49["cap_49_298_4"] = frame_49[34]
frame_49["cap_49_298_5"] = frame_49[39]
frame_49["cap_49_298_6"] = frame_49[44]
frame_49["cap_49_298_7"] = frame_49[49]
frame_49["cap_49_298_8"] = frame_49[2]
frame_49[253] = function(p20_0, p20_1)
    local v20_2
    local v20_3
    local v20_4
    local v20_5
    local v20_6
    local v20_7
    local v20_8
    local v20_9
    local v20_10
    local v20_11
    local v20_12
    local v20_13
    local v20_14
    local v20_15
    local v20_16
    local v20_17
    local v20_18
    local v20_19
    local v20_20
    local v20_21
    local v20_22
    local v20_23
    local v20_24
    local v20_25
    local v20_26
    local v20_27
    local v20_28
    local v20_29
    local v20_30
    local v20_31
    local v20_32
    local v20_33
    local v20_34
    local v20_35
    local v20_36
    local v20_37
    local v20_38
    local v20_39
    local v20_40
    local v20_41
    local v20_42
    local v20_43
    local v20_44
    local v20_45
    local v20_46
    local v20_47
    local v20_48
    local v20_49
    local v20_50
    local v20_51
    local v20_52
    local v20_53
    local v20_54
    local v20_55
    local v20_56
    local v20_57
    local v20_58
    local v20_59
    local v20_60
    local v20_61
    local v20_62
    local v20_63
    local v20_64
    local v20_65
    local v20_66
    local v20_67
    local v20_68
    local v20_69
    local v20_70
    local v20_71
    local v20_72
    local v20_73
    local v20_74
    local v20_75
    local v20_76
    local v20_77
    local v20_78
    local v20_79
    local v20_80
    local v20_81
    local v20_82
    local v20_83
    local v20_84
    local v20_85
    local v20_86
    local v20_87
    local v20_88
    local v20_89
    local v20_90
    local v20_91
    local v20_92
    local v20_93
    v20_2 = gRegion
    v20_5 = v20_2:Name__c988433c()
    v20_6 = gGameRules
    v20_9 = v20_6:GetMission()
    v20_12 = v20_9:GetFactionTag()
    v20_13 = nil
    v20_14 = nil
    v20_15 = (v20_9).goalTag
    v20_16 = frame_49["cap_49_298_0"]
    if v20_15 ~= v20_16 then
        v20_19 = frame_49["cap_49_298_3"]
        if v20_12 ~= v20_19 then
            v20_17 = frame_49["cap_49_298_6"]
            v20_18 = frame_49["cap_49_298_7"]
        else
            v20_17 = frame_49["cap_49_298_4"]
            v20_18 = frame_49["cap_49_298_5"]
        end
    else
        v20_17 = frame_49["cap_49_298_1"]
        v20_18 = frame_49["cap_49_298_2"]
    end
    v20_20 = v20_5
    v20_21 = p20_1
    v20_22 = math.max
    v20_23 = v20_22(v20_20, v20_21)
    v20_24 = v20_23
    v20_25 = frame_49["cap_49_298_8"]
    v20_26 = (v20_25).Ternary
    v20_27 = Engine.IsConsole
    v20_28 = v20_27()
    v20_31 = v20_26(v20_28, 3, 4)
    v20_32 = Clamp
    v20_33 = v20_24
    v20_35 = v20_31
    v20_36 = v20_32(v20_33, 1, v20_35)
    v20_37 = v20_36
    v20_38 = Lerp
    v20_39 = v20_17[v20_37]
    v20_40 = v20_18[v20_37]
    v20_41 = _T.EndlessModeEnemyLevel
    v20_42 = IsNull
    v20_43 = v20_42(v20_41)
    if v20_43 then
        v20_44 = gRegion
        v20_47 = v20_44:GetNpcMgr()
        v20_50 = v20_47:GetAiDirector()
        v20_51 = _T
        v20_54 = v20_50:GetMinEnemyLevel()
        v20_51.EndlessModeEnemyLevel = v20_54
    end
    v20_55 = _T.EndlessModeEnemyLevel
    v20_56 = (v20_55 / 30)
    v20_58 = math.min
    v20_59 = v20_58(v20_56, 1)
    v20_60 = v20_59
    v20_61 = v20_38(v20_39, v20_40, v20_60)
    frame_49[33] = v20_61
    if p20_0 < 15 then
        v20_63 = (p20_0 / 15)
        v20_64 = Lerp
        v20_66 = frame_49[33]
        v20_67 = v20_63
        v20_68 = v20_64(0, v20_66, v20_67)
        v20_69 = math.floor
        v20_70 = v20_69(v20_68)
        frame_49[33] = v20_70
    end
    v20_71 = frame_49[205]
    if v20_71 then
        v20_72 = frame_49[29]
        if 0 < v20_72 then
            v20_74 = frame_49[33]
            v20_75 = (v20_74 * 0.65)
            v20_76 = math.ceil
            v20_77 = v20_76(v20_75)
            frame_49[33] = v20_77
        end
    end
    v20_78 = frame_49[33]
    v20_79 = math.floor
    v20_80 = v20_79(v20_78)
    frame_49[33] = v20_80
    v20_81 = gRegion
    v20_84 = v20_81:GetNpcMgr()
    v20_87 = v20_84:GetAiDirector()
    v20_90 = v20_87:GetNpcHardCap()
    v20_91 = frame_49[33]
    v20_92 = math.min
    v20_93 = v20_92(v20_90, v20_91)
    frame_49[33] = v20_93
    return
end
frame_49[254] = function()
    local v21_0
    local v21_1
    local v21_2
    local v21_3
    local v21_4
    local v21_5
    local v21_6
    local v21_7
    local v21_8
    local v21_9
    local v21_10
    local v21_11
    local v21_12
    local v21_13
    local v21_14
    local v21_15
    local v21_16
    local v21_17
    local v21_18
    local v21_19
    local v21_20
    v21_0 = frame_49[65]
    v21_1 = math.cos
    v21_2 = v21_1(v21_0)
    v21_3 = (v21_2 + 0.99)
    v21_4 = (v21_3 ^ 2)
    v21_5 = (v21_4 * 0.25)
    v21_6 = Lerp
    v21_9 = v21_5
    v21_10 = v21_6(0.1, 1.8, v21_9)
    v21_11 = frame_49[33]
    v21_12 = (6.28 / v21_11)
    v21_13 = frame_49[65]
    v21_14 = (v21_13 + v21_12)
    frame_49[65] = v21_14
    v21_15 = frame_49[65]
    if 6.28 < v21_15 then
        v21_17 = math.mod
        v21_18 = frame_49[65]
        v21_20 = v21_17(v21_18, 6.28)
        frame_49[65] = v21_20
    end
    return v21_10
end
frame_49[255] = function(p22_0)
    local v22_1
    local v22_2
    local v22_3
    local v22_4
    local v22_5
    local v22_6
    local v22_7
    local v22_8
    local v22_9
    local v22_10
    local v22_11
    local v22_12
    local v22_13
    local v22_14
    local v22_15
    local v22_16
    local v22_17
    local v22_18
    local v22_19
    local v22_20
    v22_1 = frame_49[33]
    if p22_0 then
        v22_2 = (v22_1 * 0.8)
        v22_3 = math.floor
        v22_4 = v22_3(v22_2)
        v22_1 = v22_4
    end
    v22_5 = gRegion
    v22_8 = v22_5:GetNpcMgr()
    v22_11 = v22_8:GetAiDirector()
    v22_14 = v22_11:Name__dab3929a()
    if v22_14 < v22_1 then
        v22_17 = v22_11:Name__4d3a2098()
        v22_18 = (v22_1 + 20)
        if not (v22_17 < v22_18) then
        else
            return true
        end
    end
    return false
end
frame_49["cap_49_316_0"] = frame_49[229]
frame_49[256] = function()
    local v23_0
    local v23_1
    local v23_2
    local v23_3
    local v23_4
    local v23_5
    local v23_6
    local v23_7
    local v23_8
    local v23_9
    local v23_10
    local v23_11
    local v23_12
    local v23_13
    local v23_14
    local v23_15
    local v23_16
    local v23_17
    local v23_18
    local v23_19
    local v23_20
    local v23_21
    local v23_22
    local v23_23
    local v23_24
    local v23_25
    local v23_26
    local v23_27
    local v23_28
    local v23_29
    local v23_30
    local v23_31
    local v23_32
    local v23_33
    local v23_34
    local v23_35
    local v23_36
    local v23_37
    local v23_38
    local v23_39
    local v23_40
    local v23_41
    local v23_42
    local v23_43
    local v23_44
    local v23_45
    local v23_46
    local v23_47
    local v23_48
    local v23_49
    local v23_50
    local v23_51
    local v23_52
    local v23_53
    local v23_54
    local v23_55
    v23_0 = gRegion
    v23_3 = v23_0:GetHumanPlayers()
    v23_5 = v23_3
    for v23_53, v23_54 in ipairs(v23_5) do
        v23_9 = v23_54
        v23_10 = IsNull
        v23_11 = v23_10(v23_9)
        if v23_11 then
        else
            v23_14 = v23_54:GetOwnedPowerSuitAvatar()
            v23_15 = v23_14
            v23_16 = IsNull
            v23_17 = v23_16(v23_15)
            if v23_17 then continue end
            v23_20 = v23_14:InventoryControl()
            v23_21 = frame_49["cap_49_316_0"]
            v23_24 = v23_20:Name__ec179f6f(v23_21)
            v23_27 = v23_54:GetAvatar()
            v23_28 = v23_27
            v23_29 = IsNull
            v23_30 = v23_29(v23_28)
            local predicate_value_23_3 = (not (v23_30) and not (v23_27 == v23_14))
            if predicate_value_23_3 then
                v23_33 = v23_27:InventoryControl()
                v23_34 = frame_49["cap_49_316_0"]
                v23_37 = v23_33:Name__ec179f6f(v23_34)
                v23_24 = (v23_24 + v23_37)
                v23_40 = v23_54:GetOperatorAvatar()
                v23_41 = v23_40
                v23_42 = IsNull
                v23_43 = v23_42(v23_41)
                local predicate_value_23_5 = (not (v23_43) and not (v23_27 == v23_40))
                if predicate_value_23_5 then
                    v23_46 = v23_40:InventoryControl()
                    v23_47 = frame_49["cap_49_316_0"]
                    v23_50 = v23_46:Name__ec179f6f(v23_47)
                    v23_24 = (v23_24 + v23_50)
                end
            end
            if not (v23_24 < 10) then continue end
            return false
        end
    end
    return true
end
frame_49["cap_49_318_0"] = frame_49[116]
frame_49["cap_49_318_1"] = frame_49[253]
frame_49["cap_49_318_4"] = frame_49[256]
frame_49["cap_49_318_5"] = frame_49[226]
frame_49["cap_49_318_7"] = frame_49[125]
frame_49["cap_49_318_8"] = frame_49[252]
frame_49[257] = function(p24_0, p24_1, p24_2, p24_3)
    local frame_24 = {}
    local cfg_24 = 0
    while true do
        if cfg_24 == 0 then
            frame_24[4] = 0.5
            frame_24[5] = gGameRules
            frame_24[6] = frame_49["cap_49_318_0"]
            frame_24[10] = (frame_24[5]):GetNetPersistentVar(frame_24[6], 0)
            frame_24[11] = (p24_0 * 0.5)
            frame_24[12] = (frame_24[10] * 0.75)
            frame_24[13] = (frame_24[11] + frame_24[12])
            frame_24[14] = (#p24_2)
            if frame_24[14] == 0 then
                cfg_24 = 2
            else
                cfg_24 = 1
            end
        elseif cfg_24 == 1 then
            frame_24[15] = false
            cfg_24 = 3
        elseif cfg_24 == 2 then
            frame_24[15] = true
            cfg_24 = 3
        elseif cfg_24 == 3 then
            frame_24[16] = frame_49["cap_49_318_1"]
            frame_24[17] = frame_24[13]
            frame_24[18] = (#p24_2)
            frame_24[16](frame_24[17], frame_24[18])
            frame_24[19] = frame_49[33]
            if not (frame_24[15]) then
                cfg_24 = 5
            else
                cfg_24 = 4
            end
        elseif cfg_24 == 4 then
            frame_24[20] = (frame_24[19] * 0.8)
            frame_24[21] = math.floor
            frame_24[22] = frame_24[21](frame_24[20])
            frame_24[19] = frame_24[22]
            cfg_24 = 5
        elseif cfg_24 == 5 then
            frame_24[23] = gRegion
            frame_24[26] = (frame_24[23]):GetNpcMgr()
            frame_24[29] = (frame_24[26]):GetAiDirector()
            frame_24[32] = (frame_24[29]):Name__dab3929a()
            if not (frame_24[32] < frame_24[19]) then
                cfg_24 = 8
            else
                cfg_24 = 6
            end
        elseif cfg_24 == 6 then
            frame_24[35] = (frame_24[29]):Name__4d3a2098()
            frame_24[36] = (frame_24[19] + 20)
            if not (frame_24[35] < frame_24[36]) then
                cfg_24 = 8
            else
                cfg_24 = 7
            end
        elseif cfg_24 == 7 then
            frame_24[37] = true
            cfg_24 = 9
        elseif cfg_24 == 8 then
            frame_24[37] = false
            cfg_24 = 9
        elseif cfg_24 == 9 then
            if frame_24[37] then
                cfg_24 = 11
            else
                cfg_24 = 10
            end
        elseif cfg_24 == 10 then
            return frame_24[4]
        elseif cfg_24 == 11 then
            frame_24[38] = cellItemPickup
            frame_24[39] = IsNull
            frame_24[40] = frame_24[39](frame_24[38])
            if not (frame_24[40]) then
                cfg_24 = 13
            else
                cfg_24 = 12
            end
        elseif cfg_24 == 12 then
            frame_24[41] = print
            frame_24[41]("No cellItemPickup")
            cfg_24 = 26
        elseif cfg_24 == 13 then
            frame_24[43] = gRegion
            frame_24[44] = cellItemPickup
            frame_24[47] = (frame_24[43]):Name__0b406dc3(frame_24[44])
            if not (frame_24[47]) then
                cfg_24 = 26
            else
                cfg_24 = 14
            end
        elseif cfg_24 == 14 then
            frame_24[49] = p24_3
            local leave_for_24_17 = false
            for for_value_24_17_0, for_value_24_17_1 in ipairs(frame_24[49]) do
                frame_24[58], frame_24[59] = for_value_24_17_0, for_value_24_17_1
                cfg_24 = 15
                while true do
                    if cfg_24 == 15 then
                        frame_24[55] = (frame_24[59]):GetPower()
                        if not (0 < frame_24[55]) then
                            cfg_24 = 17
                        else
                            cfg_24 = 16
                        end
                    elseif cfg_24 == 16 then
                        frame_24[57] = true
                        cfg_24 = 19
                        leave_for_24_17 = true
                        break
                    elseif cfg_24 == 17 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_24_17 then break end
            end
            if not leave_for_24_17 then
                cfg_24 = 18
            end
        elseif cfg_24 == 18 then
            frame_24[57] = false
            cfg_24 = 19
        elseif cfg_24 == 19 then
            if frame_24[57] then
                cfg_24 = 26
            else
                cfg_24 = 20
            end
        elseif cfg_24 == 20 then
            frame_24[60] = frame_49[207]
            if not (frame_24[60]) then
                cfg_24 = 25
            else
                cfg_24 = 21
            end
        elseif cfg_24 == 21 then
            frame_24[61] = frame_49["cap_49_318_4"]
            frame_24[62] = frame_24[61]()
            if frame_24[62] then
                cfg_24 = 25
            else
                cfg_24 = 22
            end
        elseif cfg_24 == 22 then
            frame_24[63] = gRegion
            frame_24[64] = frame_49["cap_49_318_5"]
            frame_24[67] = (frame_24[63]):FindAll(frame_24[64])
            frame_24[68] = (#frame_24[67])
            if not (10 <= frame_24[68]) then
                cfg_24 = 26
            else
                cfg_24 = 23
            end
        elseif cfg_24 == 23 then
            return frame_24[4]
        elseif cfg_24 == 25 then
            return frame_24[4]
        elseif cfg_24 == 26 then
            frame_24[70] = frame_49[64]
            frame_24[71] = (frame_24[70] - p24_1)
            frame_24[73] = math.max
            frame_24[74] = frame_24[73](frame_24[71], -0.5)
            frame_49[64] = frame_24[74]
            frame_24[75] = frame_49[64]
            if not (0 < frame_24[75]) then
                cfg_24 = 28
            else
                cfg_24 = 27
            end
        elseif cfg_24 == 27 then
            frame_24[77] = frame_49[64]
            frame_24[78] = frame_24[4]
            frame_24[79] = math.min
            frame_24[80] = frame_24[79](frame_24[78], frame_24[77])
            return frame_24[80]
        elseif cfg_24 == 28 then
            frame_24[81] = gRegion
            frame_24[84] = (frame_24[81]):GetHumanPlayerAvatars()
            frame_24[85] = gGameRules
            frame_24[86] = frame_49["cap_49_318_7"]
            frame_24[90] = (frame_24[85]):GetNetPersistentVar(frame_24[86], 0)
            cfg_24 = 29
        elseif cfg_24 == 29 then
            frame_24[91] = frame_49["cap_49_318_8"]
            frame_24[92] = frame_24[13]
            frame_24[93] = p24_2
            frame_24[94] = frame_24[90]
            frame_24[95] = frame_24[84]
            frame_24[96] = frame_24[91](frame_24[92], frame_24[93], frame_24[94], frame_24[95])
            frame_24[97] = frame_24[96]
            frame_24[98] = IsNull
            frame_24[99] = frame_24[98](frame_24[97])
            if not (frame_24[99]) then
                cfg_24 = 31
            else
                cfg_24 = 30
            end
        elseif cfg_24 == 30 then
            return frame_24[4]
        elseif cfg_24 == 31 then
            frame_24[100] = frame_49[65]
            frame_24[101] = math.cos
            frame_24[102] = frame_24[101](frame_24[100])
            frame_24[103] = (frame_24[102] + 0.99)
            frame_24[104] = (frame_24[103] ^ 2)
            frame_24[105] = (frame_24[104] * 0.25)
            frame_24[106] = Lerp
            frame_24[109] = frame_24[105]
            frame_24[110] = frame_24[106](0.1, 1.8, frame_24[109])
            frame_24[111] = frame_49[33]
            frame_24[112] = (6.28 / frame_24[111])
            frame_24[113] = frame_49[65]
            frame_24[114] = (frame_24[113] + frame_24[112])
            frame_49[65] = frame_24[114]
            frame_24[115] = frame_49[65]
            if not (6.28 < frame_24[115]) then
                cfg_24 = 33
            else
                cfg_24 = 32
            end
        elseif cfg_24 == 32 then
            frame_24[117] = math.mod
            frame_24[118] = frame_49[65]
            frame_24[120] = frame_24[117](frame_24[118], 6.28)
            frame_49[65] = frame_24[120]
            cfg_24 = 33
        elseif cfg_24 == 33 then
            frame_24[121] = frame_24[110]
            frame_24[122] = frame_49[64]
            frame_24[123] = (frame_24[122] + frame_24[121])
            frame_49[64] = frame_24[123]
            frame_24[124] = frame_49[64]
            if not (0 < frame_24[124]) then
                cfg_24 = 35
            else
                cfg_24 = 34
            end
        elseif cfg_24 == 34 then
            frame_24[126] = frame_49[64]
            frame_24[127] = frame_24[4]
            frame_24[128] = math.min
            frame_24[129] = frame_24[128](frame_24[127], frame_24[126])
            return frame_24[129]
        elseif cfg_24 == 35 then
            frame_24[130] = frame_49[33]
            if not (frame_24[15]) then
                cfg_24 = 37
            else
                cfg_24 = 36
            end
        elseif cfg_24 == 36 then
            frame_24[131] = (frame_24[130] * 0.8)
            frame_24[132] = math.floor
            frame_24[133] = frame_24[132](frame_24[131])
            frame_24[130] = frame_24[133]
            cfg_24 = 37
        elseif cfg_24 == 37 then
            frame_24[134] = gRegion
            frame_24[137] = (frame_24[134]):GetNpcMgr()
            frame_24[140] = (frame_24[137]):GetAiDirector()
            frame_24[143] = (frame_24[140]):Name__dab3929a()
            if not (frame_24[143] < frame_24[130]) then
                cfg_24 = 40
            else
                cfg_24 = 38
            end
        elseif cfg_24 == 38 then
            frame_24[146] = (frame_24[140]):Name__4d3a2098()
            frame_24[147] = (frame_24[130] + 20)
            if not (frame_24[146] < frame_24[147]) then
                cfg_24 = 40
            else
                cfg_24 = 39
            end
        elseif cfg_24 == 39 then
            frame_24[148] = true
            cfg_24 = 41
        elseif cfg_24 == 40 then
            frame_24[148] = false
            cfg_24 = 41
        elseif cfg_24 == 41 then
            if frame_24[148] then
                cfg_24 = 43
            else
                cfg_24 = 42
            end
        elseif cfg_24 == 42 then
            return frame_24[4]
        elseif cfg_24 == 43 then
            frame_24[149] = Sleep
            frame_24[149](0)
            frame_24[151] = Name__3b4b94b0
            frame_24[152] = frame_24[151]()
            frame_24[4] = (frame_24[4] - frame_24[152])
            if not (frame_24[4] < 0) then
                cfg_24 = 45
            else
                cfg_24 = 44
            end
        elseif cfg_24 == 44 then
            return 0
        elseif cfg_24 == 45 then
            cfg_24 = 29
        else
            error("invalid control state")
        end
    end
end
frame_49["cap_49_329_0"] = frame_49[2]
frame_49[258] = function(p25_0, p25_1)
    local v25_2
    local v25_3
    local v25_4
    local v25_5
    local v25_6
    local v25_7
    local v25_8
    local v25_9
    local v25_10
    local v25_11
    local v25_12
    local v25_13
    local v25_14
    local v25_15
    local v25_16
    local v25_17
    local v25_18
    local v25_19
    local v25_20
    local v25_21
    local v25_22
    local v25_23
    local v25_24
    local v25_25
    local v25_26
    local v25_27
    local v25_28
    local v25_29
    local v25_30
    local v25_31
    local v25_32
    local v25_33
    local v25_34
    local v25_35
    local v25_36
    local v25_37
    local v25_38
    local v25_39
    local v25_40
    v25_2 = (#p25_1)
    if not (v25_2 < 2) then
        v25_4 = 0
        v25_5 = 0
        v25_6 = (#p25_1)
        v25_7 = p25_1[v25_6]
        v25_10 = v25_7:GetPosition()
        v25_11 = 1
        v25_12 = (#p25_1)
        v25_13 = 1
        for v25_11 = v25_11, v25_12, v25_13 do
            v25_14 = p25_1[v25_11]
            v25_17 = v25_14:GetPosition()
            v25_18 = Distance
            v25_19 = v25_10
            v25_20 = v25_17
            v25_21 = v25_18(v25_19, v25_20)
            v25_4 = (v25_4 + v25_21)
            v25_5 = (v25_5 + 1)
            v25_10 = v25_17
        end
        v25_22 = (v25_4 / v25_5)
        v25_23 = frame_49["cap_49_329_0"]
        v25_24 = (v25_23).Round
        v25_25 = v25_4
        v25_26 = v25_24(v25_25)
        v25_27 = v25_26
        v25_28 = frame_49["cap_49_329_0"]
        v25_29 = (v25_28).Round
        v25_30 = v25_22
        v25_31 = v25_29(v25_30)
        v25_32 = v25_31
        v25_33 = print
        v25_34 = p25_0
        v25_36 = v25_27
        v25_38 = v25_32
        v25_40 = (v25_34 .. " tour length: " .. v25_36 .. " m (" .. v25_38 .. "m avg)")
        v25_33(v25_40)
        return
    else
        return
    end
end
frame_49[259] = function(p26_0)
    local frame_26 = {}
    local cfg_26 = 0
    while true do
        if cfg_26 == 0 then
            frame_26[1] = p26_0[1]
            frame_26[4] = (frame_26[1]):GetPosition()
            frame_26[5] = (#p26_0)
            frame_26[6] = 2
            frame_26[7] = frame_26[5]
            frame_26[8] = 1
            local leave_for_26_1 = false
            for for_value_26_1 = frame_26[6], frame_26[7], frame_26[8] do
                frame_26[6] = for_value_26_1
                cfg_26 = 1
                while true do
                    if cfg_26 == 1 then
                        frame_26[9] = nil
                        frame_26[10] = nil
                        frame_26[11] = frame_26[6]
                        frame_26[12] = frame_26[5]
                        frame_26[13] = 1
                        local leave_for_26_2 = false
                        for for_value_26_2 = frame_26[11], frame_26[12], frame_26[13] do
                            frame_26[11] = for_value_26_2
                            cfg_26 = 2
                            while true do
                                if cfg_26 == 2 then
                                    frame_26[14] = p26_0[frame_26[11]]
                                    frame_26[15] = frame_26[4]
                                    frame_26[18] = (frame_26[14]):DistanceToPoint(frame_26[15])
                                    if (not (frame_26[9] == nil) and not (frame_26[18] < frame_26[10])) then
                                        cfg_26 = 5
                                    else
                                        cfg_26 = 4
                                    end
                                elseif cfg_26 == 4 then
                                    frame_26[9] = frame_26[11]
                                    frame_26[10] = frame_26[18]
                                    cfg_26 = 5
                                elseif cfg_26 == 5 then
                                    break
                                else
                                    error("invalid control state")
                                end
                            end
                            if leave_for_26_2 then break end
                        end
                        if not leave_for_26_2 then
                            cfg_26 = 6
                        end
                        if cfg_26 ~= 1 and cfg_26 ~= 6 and cfg_26 ~= 7 and cfg_26 ~= 8 then
                            leave_for_26_1 = true
                            break
                        end
                    elseif cfg_26 == 6 then
                        if frame_26[9] == frame_26[6] then
                            cfg_26 = 8
                        else
                            cfg_26 = 7
                        end
                    elseif cfg_26 == 7 then
                        frame_26[19] = p26_0[frame_26[6]]
                        frame_26[20] = p26_0[frame_26[9]]
                        p26_0[frame_26[6]] = frame_26[20]
                        p26_0[frame_26[9]] = frame_26[19]
                        cfg_26 = 8
                    elseif cfg_26 == 8 then
                        frame_26[21] = p26_0[frame_26[6]]
                        frame_26[24] = (frame_26[21]):GetPosition()
                        frame_26[4] = frame_26[24]
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_26_1 then break end
            end
            if not leave_for_26_1 then
                cfg_26 = 9
            end
        elseif cfg_26 == 9 then
            return
        else
            error("invalid control state")
        end
    end
end
frame_49["cap_49_332_2"] = frame_49[83]
frame_49["cap_49_332_3"] = frame_49[80]
frame_49["cap_49_332_5"] = frame_49[2]
frame_49["cap_49_332_6"] = frame_49[11]
frame_49["cap_49_332_7"] = frame_49[259]
frame_49["cap_49_332_8"] = frame_49[258]
frame_49[260] = function()
    local frame_27 = {}
    local cfg_27 = 0
    while true do
        if cfg_27 == 0 then
            frame_27[0] = gRegion
            frame_27[1] = Symbol
            frame_27[33] = (frame_27[0]):FindTagged(frame_27[1]("Spawn"))
            frame_27[34] = (#frame_27[33])
            if frame_27[34] ~= 0 then
                cfg_27 = 2
            else
                cfg_27 = 1
            end
        elseif cfg_27 == 1 then
            return
        elseif cfg_27 == 2 then
            frame_27[35] = frame_49[205]
            if not (frame_27[35]) then
                cfg_27 = 4
            else
                cfg_27 = 3
            end
        elseif cfg_27 == 3 then
            frame_27[36] = gRegion
            frame_27[37] = frame_49["cap_49_332_2"]
            frame_27[40] = (frame_27[36]):FindTagged(frame_27[37])
            frame_49[189] = frame_27[40]
            cfg_27 = 8
        elseif cfg_27 == 4 then
            frame_27[41] = {}
            frame_49[189] = frame_27[41]
            frame_27[42] = gRegion
            frame_27[43] = frame_49["cap_49_332_2"]
            frame_27[46] = (frame_27[42]):FindTagged(frame_27[43])
            frame_27[47] = 1
            frame_27[48] = (#frame_27[46])
            frame_27[49] = 1
            local leave_for_27_5 = false
            for for_value_27_5 = frame_27[47], frame_27[48], frame_27[49] do
                frame_27[47] = for_value_27_5
                cfg_27 = 5
                while true do
                    if cfg_27 == 5 then
                        frame_27[50] = frame_49[189]
                        frame_27[51] = frame_27[46][frame_27[47]]
                        frame_27[52] = table.insert
                        frame_27[52](frame_27[50], frame_27[51])
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_27_5 then break end
            end
            if not leave_for_27_5 then
                cfg_27 = 6
            end
        elseif cfg_27 == 6 then
            frame_27[53] = gRegion
            frame_27[54] = frame_49["cap_49_332_3"]
            frame_27[57] = (frame_27[53]):FindTagged(frame_27[54])
            frame_27[58] = frame_27[57]
            frame_27[59] = 1
            frame_27[60] = (#frame_27[58])
            frame_27[61] = 1
            local leave_for_27_7 = false
            for for_value_27_7 = frame_27[59], frame_27[60], frame_27[61] do
                frame_27[59] = for_value_27_7
                cfg_27 = 7
                while true do
                    if cfg_27 == 7 then
                        frame_27[62] = frame_49[189]
                        frame_27[63] = frame_27[58][frame_27[59]]
                        frame_27[64] = table.insert
                        frame_27[64](frame_27[62], frame_27[63])
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_27_7 then break end
            end
            if not leave_for_27_7 then
                cfg_27 = 8
            end
        elseif cfg_27 == 8 then
            frame_27[65] = frame_49[212]
            if not (frame_27[65]) then
                cfg_27 = 12
            else
                cfg_27 = 9
            end
        elseif cfg_27 == 9 then
            frame_27[66] = _T.FilterEntitiesToCurrentLayer
            if not (frame_27[66]) then
                cfg_27 = 11
            else
                cfg_27 = 10
            end
        elseif cfg_27 == 10 then
            frame_27[67] = _T.FilterEntitiesToCurrentLayer
            frame_27[68] = frame_49[189]
            frame_27[69] = frame_27[67](frame_27[68])
            frame_49[189] = frame_27[69]
            cfg_27 = 11
        elseif cfg_27 == 11 then
            frame_27[70] = frame_49["cap_49_332_5"]
            frame_27[71] = (frame_27[70]).ShuffleTable
            frame_27[72] = frame_49[189]
            frame_27[71](frame_27[72])
            return
        elseif cfg_27 == 12 then
            frame_27[73] = gGameRules
            frame_27[76] = (frame_27[73]):GetMission()
            frame_27[77] = (frame_27[76]).goalTag
            frame_27[78] = true
            frame_27[79] = Symbol
            frame_27[81] = frame_27[79]("ShieldExcav")
            if frame_27[77] == frame_27[81] then
                cfg_27 = 16
            else
                cfg_27 = 13
            end
        elseif cfg_27 == 13 then
            frame_27[82] = Symbol
            frame_27[84] = frame_27[82]("OldWorldSalvage")
            if frame_27[77] == frame_27[84] then
                cfg_27 = 15
            else
                cfg_27 = 14
            end
        elseif cfg_27 == 14 then
            frame_27[78] = false
            cfg_27 = 16
        elseif cfg_27 == 15 then
            frame_27[78] = true
            cfg_27 = 16
        elseif cfg_27 == 16 then
            if not (frame_27[78]) then
                cfg_27 = 22
            else
                cfg_27 = 17
            end
        elseif cfg_27 == 17 then
            frame_27[85] = frame_49["cap_49_332_6"]
            frame_27[86] = (frame_27[85]).SortByLayerIndex
            frame_27[87] = frame_49[189]
            frame_27[88] = frame_27[86](frame_27[87])
            frame_49[189] = frame_27[88]
            frame_27[89] = frame_49[189]
            frame_27[90] = frame_49[189]
            frame_27[91] = (#frame_27[90])
            frame_27[92] = frame_27[89][frame_27[91]]
            frame_27[95] = (frame_27[92]):GetZone()
            frame_27[98] = (frame_27[95]):GetLayerIndex()
            frame_27[99] = frame_49[189]
            frame_27[100] = (#frame_27[99])
            frame_27[101] = 1
            frame_27[102] = -1
            local leave_for_27_18 = false
            for for_value_27_18 = frame_27[100], frame_27[101], frame_27[102] do
                frame_27[100] = for_value_27_18
                cfg_27 = 18
                while true do
                    if cfg_27 == 18 then
                        frame_27[103] = frame_49[189]
                        frame_27[104] = frame_27[103][frame_27[100]]
                        frame_27[107] = (frame_27[104]):GetZone()
                        frame_27[110] = (frame_27[107]):GetLayerIndex()
                        if frame_27[110] == frame_27[98] then
                            cfg_27 = 20
                        else
                            cfg_27 = 19
                        end
                    elseif cfg_27 == 19 then
                        frame_27[111] = table.remove
                        frame_27[112] = frame_49[189]
                        frame_27[113] = frame_27[100]
                        frame_27[111](frame_27[112], frame_27[113])
                        cfg_27 = 20
                    elseif cfg_27 == 20 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_27_18 then break end
            end
            if not leave_for_27_18 then
                cfg_27 = 21
            end
        elseif cfg_27 == 21 then
            return
        elseif cfg_27 == 22 then
            frame_27[114] = frame_49[189]
            frame_27[115] = (#frame_27[114])
            if frame_27[115] ~= 0 then
                cfg_27 = 24
            else
                cfg_27 = 23
            end
        elseif cfg_27 == 23 then
            return
        elseif cfg_27 == 24 then
            frame_27[116] = print
            frame_27[117] = frame_49[189]
            frame_27[118] = (#frame_27[117])
            frame_27[120] = (frame_27[118] .. " extractors found")
            frame_27[116](frame_27[120])
            frame_27[121] = frame_49[189]
            frame_27[122] = (#frame_27[121])
            if frame_27[122] ~= 1 then
                cfg_27 = 26
            else
                cfg_27 = 25
            end
        elseif cfg_27 == 25 then
            return
        elseif cfg_27 == 26 then
            frame_27[123] = {}
            frame_27[124] = {}
            frame_27[125] = 1
            frame_27[126] = frame_49[189]
            frame_27[127] = (#frame_27[126])
            frame_27[128] = 1
            local leave_for_27_27 = false
            for for_value_27_27 = frame_27[125], frame_27[127], frame_27[128] do
                frame_27[125] = for_value_27_27
                cfg_27 = 27
                while true do
                    if cfg_27 == 27 then
                        frame_27[129] = frame_49[189]
                        frame_27[130] = frame_27[129][frame_27[125]]
                        frame_27[133] = (frame_27[130]):GetZone()
                        frame_27[134] = frame_27[133]
                        frame_27[135] = IsNull
                        frame_27[136] = frame_27[135](frame_27[134])
                        if not (frame_27[136]) then
                            cfg_27 = 29
                        else
                            cfg_27 = 28
                        end
                    elseif cfg_27 == 28 then
                        frame_27[137] = print
                        frame_27[141] = (frame_27[130]):GetFullName()
                        frame_27[142] = frame_27[141]
                        frame_27[144] = ("Skipping " .. frame_27[142] .. " (in the void)")
                        frame_27[137](frame_27[144])
                        cfg_27 = 32
                    elseif cfg_27 == 29 then
                        frame_27[145] = print
                        frame_27[149] = (frame_27[130]):GetFullName()
                        frame_27[150] = ("Found" .. frame_27[149])
                        frame_27[145](frame_27[150])
                        frame_27[153] = (frame_27[133]):GetLayerIndex()
                        frame_27[154] = frame_27[123][frame_27[153]]
                        if frame_27[154] ~= nil then
                            cfg_27 = 31
                        else
                            cfg_27 = 30
                        end
                    elseif cfg_27 == 30 then
                        frame_27[155] = {}
                        frame_27[156] = frame_27[130]
                        frame_27[155][1] = frame_27[156]
                        frame_27[123][frame_27[153]] = frame_27[155]
                        frame_27[157] = frame_27[124]
                        frame_27[158] = frame_27[130]
                        frame_27[159] = table.insert
                        frame_27[159](frame_27[157], frame_27[158])
                        cfg_27 = 32
                    elseif cfg_27 == 31 then
                        frame_27[160] = frame_27[123][frame_27[153]]
                        frame_27[161] = frame_27[130]
                        frame_27[162] = table.insert
                        frame_27[162](frame_27[160], frame_27[161])
                        cfg_27 = 32
                    elseif cfg_27 == 32 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_27_27 then break end
            end
            if not leave_for_27_27 then
                cfg_27 = 33
            end
        elseif cfg_27 == 33 then
            frame_27[163] = frame_49["cap_49_332_7"]
            frame_27[164] = frame_27[124]
            frame_27[163](frame_27[164])
            frame_27[165] = print
            frame_27[166] = (#frame_27[124])
            frame_27[168] = (frame_27[166] .. " tiles in path")
            frame_27[165](frame_27[168])
            frame_27[169] = (#frame_27[124])
            if frame_27[169] ~= 1 then
                cfg_27 = 35
            else
                cfg_27 = 34
            end
        elseif cfg_27 == 34 then
            return
        elseif cfg_27 == 35 then
            frame_27[170] = (#frame_27[124])
            frame_27[171] = frame_27[124][frame_27[170]]
            frame_27[172] = nil
            frame_27[173] = {}
            frame_27[174] = 1
            frame_27[175] = (#frame_27[124])
            frame_27[176] = 1
            local leave_for_27_36 = false
            for for_value_27_36 = frame_27[174], frame_27[175], frame_27[176] do
                frame_27[174] = for_value_27_36
                cfg_27 = 36
                while true do
                    if cfg_27 == 36 then
                        frame_27[177] = frame_27[124][frame_27[174]]
                        frame_27[178] = gRegion
                        frame_27[179] = frame_27[171]
                        frame_27[180] = frame_27[177]
                        frame_27[183] = (frame_27[178]):FindZonePath(frame_27[179], frame_27[180])
                        frame_27[184] = 1
                        frame_27[185] = (#frame_27[183])
                        frame_27[186] = 1
                        local leave_for_27_37 = false
                        for for_value_27_37 = frame_27[184], frame_27[185], frame_27[186] do
                            frame_27[184] = for_value_27_37
                            cfg_27 = 37
                            while true do
                                if cfg_27 == 37 then
                                    frame_27[187] = frame_27[183][frame_27[184]]
                                    frame_27[190] = (frame_27[187]):GetZone()
                                    frame_27[191] = frame_27[190]
                                    frame_27[192] = IsNull
                                    frame_27[193] = frame_27[192](frame_27[191])
                                    if frame_27[193] then
                                        cfg_27 = 41
                                    else
                                        cfg_27 = 38
                                    end
                                elseif cfg_27 == 38 then
                                    frame_27[196] = (frame_27[190]):GetLayerIndex()
                                    frame_27[197] = frame_27[123][frame_27[196]]
                                    if (frame_27[197] == nil or frame_27[172] == frame_27[196]) then
                                        cfg_27 = 41
                                    else
                                        cfg_27 = 40
                                    end
                                elseif cfg_27 == 40 then
                                    frame_27[198] = frame_27[173]
                                    frame_27[199] = frame_27[196]
                                    frame_27[200] = table.insert
                                    frame_27[200](frame_27[198], frame_27[199])
                                    frame_27[172] = frame_27[196]
                                    cfg_27 = 41
                                elseif cfg_27 == 41 then
                                    break
                                else
                                    error("invalid control state")
                                end
                            end
                            if leave_for_27_37 then break end
                        end
                        if not leave_for_27_37 then
                            cfg_27 = 42
                        end
                        if cfg_27 ~= 36 and cfg_27 ~= 42 then
                            leave_for_27_36 = true
                            break
                        end
                    elseif cfg_27 == 42 then
                        frame_27[171] = frame_27[177]
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_27_36 then break end
            end
            if not leave_for_27_36 then
                cfg_27 = 43
            end
        elseif cfg_27 == 43 then
            frame_27[201] = frame_27[173][1]
            frame_27[202] = (#frame_27[173])
            frame_27[203] = frame_27[173][frame_27[202]]
            if frame_27[201] ~= frame_27[203] then
                cfg_27 = 45
            else
                cfg_27 = 44
            end
        elseif cfg_27 == 44 then
            frame_27[204] = table.remove
            frame_27[205] = frame_27[173]
            frame_27[206] = (#frame_27[173])
            frame_27[204](frame_27[205], frame_27[206])
            cfg_27 = 45
        elseif cfg_27 == 45 then
            frame_27[207] = print
            frame_27[208] = (#frame_27[173])
            frame_27[210] = (frame_27[208] .. " tiles in tour")
            frame_27[207](frame_27[210])
            frame_27[211] = 1
            frame_27[212] = (#frame_27[123])
            frame_27[213] = 1
            local leave_for_27_46 = false
            for for_value_27_46 = frame_27[211], frame_27[212], frame_27[213] do
                frame_27[211] = for_value_27_46
                cfg_27 = 46
                while true do
                    if cfg_27 == 46 then
                        frame_27[214] = frame_49["cap_49_332_5"]
                        frame_27[215] = (frame_27[214]).ShuffleTable
                        frame_27[216] = frame_27[123][frame_27[211]]
                        frame_27[215](frame_27[216])
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_27_46 then break end
            end
            if not leave_for_27_46 then
                cfg_27 = 47
            end
        elseif cfg_27 == 47 then
            frame_27[217] = {}
            frame_27[218] = 1
            frame_27[219] = (#frame_27[173])
            frame_27[220] = 1
            local leave_for_27_48 = false
            for for_value_27_48 = frame_27[218], frame_27[219], frame_27[220] do
                frame_27[218] = for_value_27_48
                cfg_27 = 48
                while true do
                    if cfg_27 == 48 then
                        frame_27[221] = frame_27[173][frame_27[218]]
                        frame_27[222] = frame_27[217][frame_27[221]]
                        if frame_27[222] ~= nil then
                            cfg_27 = 50
                        else
                            cfg_27 = 49
                        end
                    elseif cfg_27 == 49 then
                        frame_27[217][frame_27[221]] = 1
                        cfg_27 = 51
                    elseif cfg_27 == 50 then
                        frame_27[224] = frame_27[217][frame_27[221]]
                        frame_27[225] = (frame_27[224] + 1)
                        frame_27[217][frame_27[221]] = frame_27[225]
                        cfg_27 = 51
                    elseif cfg_27 == 51 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_27_48 then break end
            end
            if not leave_for_27_48 then
                cfg_27 = 52
            end
        elseif cfg_27 == 52 then
            frame_27[226] = (#frame_27[173])
            frame_27[227] = 1
            frame_27[228] = frame_27[226]
            frame_27[229] = 1
            local leave_for_27_53 = false
            for for_value_27_53 = frame_27[227], frame_27[228], frame_27[229] do
                frame_27[227] = for_value_27_53
                cfg_27 = 53
                while true do
                    if cfg_27 == 53 then
                        frame_27[230] = frame_27[173][frame_27[227]]
                        frame_27[231] = frame_27[173]
                        frame_27[232] = table.insert
                        frame_27[232](frame_27[231], frame_27[230])
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_27_53 then break end
            end
            if not leave_for_27_53 then
                cfg_27 = 54
            end
        elseif cfg_27 == 54 then
            frame_27[233] = 1
            frame_27[234] = frame_27[226]
            frame_27[235] = 1
            local leave_for_27_55 = false
            for for_value_27_55 = frame_27[233], frame_27[234], frame_27[235] do
                frame_27[233] = for_value_27_55
                cfg_27 = 55
                while true do
                    if cfg_27 == 55 then
                        frame_27[236] = frame_27[173][frame_27[233]]
                        frame_27[237] = frame_27[173]
                        frame_27[238] = table.insert
                        frame_27[238](frame_27[237], frame_27[236])
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_27_55 then break end
            end
            if not leave_for_27_55 then
                cfg_27 = 56
            end
        elseif cfg_27 == 56 then
            frame_27[239] = {}
            frame_49[189] = frame_27[239]
            frame_27[240] = nil
            frame_27[241] = 0
            frame_27[242] = 1
            frame_27[243] = (#frame_27[173])
            frame_27[244] = 1
            local leave_for_27_57 = false
            for for_value_27_57 = frame_27[242], frame_27[243], frame_27[244] do
                frame_27[242] = for_value_27_57
                cfg_27 = 57
                while true do
                    if cfg_27 == 57 then
                        frame_27[245] = frame_27[173][frame_27[242]]
                        frame_27[246] = frame_27[123][frame_27[245]]
                        frame_27[247] = 100
                        frame_27[248] = frame_27[217][frame_27[245]]
                        if frame_27[248] ~= 1 then
                            cfg_27 = 59
                        else
                            cfg_27 = 58
                        end
                    elseif cfg_27 == 58 then
                        frame_27[247] = (frame_27[247] * 0.5)
                        cfg_27 = 59
                    elseif cfg_27 == 59 then
                        frame_27[249] = 1
                        frame_27[250] = (#frame_27[246])
                        frame_27[251] = 1
                        local leave_for_27_60 = false
                        for for_value_27_60 = frame_27[249], frame_27[250], frame_27[251] do
                            frame_27[249] = for_value_27_60
                            cfg_27 = 60
                            while true do
                                if cfg_27 == 60 then
                                    frame_27[252] = frame_27[246][frame_27[249]]
                                    frame_27[253] = 0
                                    if frame_27[240] == nil then
                                        cfg_27 = 69
                                    else
                                        cfg_27 = 61
                                    end
                                elseif cfg_27 == 61 then
                                    frame_27[254] = frame_27[240]
                                    frame_27[257] = (frame_27[252]):DistanceToEntity(frame_27[254])
                                    frame_27[253] = frame_27[257]
                                    frame_27[258] = (frame_27[241] + frame_27[253])
                                    frame_27[259] = frame_49[189]
                                    frame_27[260] = (#frame_27[259])
                                    frame_27[261] = (frame_27[260] + 1)
                                    frame_27[262] = (frame_27[258] / frame_27[261])
                                    if not (frame_27[262] < frame_27[247]) then
                                        cfg_27 = 63
                                    else
                                        cfg_27 = 62
                                    end
                                elseif cfg_27 == 62 then
                                    frame_27[253] = 0
                                    cfg_27 = 63
                                elseif cfg_27 == 63 then
                                    frame_27[263] = frame_49[189]
                                    frame_27[264] = (#frame_27[263])
                                    if frame_27[264] < 1 then
                                        cfg_27 = 69
                                    else
                                        cfg_27 = 64
                                    end
                                elseif cfg_27 == 64 then
                                    frame_27[266] = frame_49[189]
                                    frame_27[267] = frame_49[189]
                                    frame_27[268] = (#frame_27[267])
                                    frame_27[269] = (frame_27[268] - 1)
                                    frame_27[270] = (frame_27[269] + 1)
                                    frame_27[271] = frame_27[266][frame_27[270]]
                                    if frame_27[271] ~= frame_27[252] then
                                        cfg_27 = 66
                                    else
                                        cfg_27 = 65
                                    end
                                elseif cfg_27 == 65 then
                                    frame_27[253] = 0
                                    cfg_27 = 69
                                elseif cfg_27 == 66 then
                                    frame_27[272] = frame_49[189]
                                    frame_27[273] = (#frame_27[272])
                                    if frame_27[273] < 2 then
                                        cfg_27 = 69
                                    else
                                        cfg_27 = 67
                                    end
                                elseif cfg_27 == 67 then
                                    frame_27[275] = frame_49[189]
                                    frame_27[276] = frame_49[189]
                                    frame_27[277] = (#frame_27[276])
                                    frame_27[278] = (frame_27[277] - 2)
                                    frame_27[279] = (frame_27[278] + 1)
                                    frame_27[280] = frame_27[275][frame_27[279]]
                                    if frame_27[280] ~= frame_27[252] then
                                        cfg_27 = 69
                                    else
                                        cfg_27 = 68
                                    end
                                elseif cfg_27 == 68 then
                                    frame_27[253] = 0
                                    cfg_27 = 69
                                elseif cfg_27 == 69 then
                                    if frame_27[240] == nil then
                                        cfg_27 = 71
                                    else
                                        cfg_27 = 70
                                    end
                                elseif cfg_27 == 70 then
                                    if not (50 < frame_27[253]) then
                                        cfg_27 = 72
                                    else
                                        cfg_27 = 71
                                    end
                                elseif cfg_27 == 71 then
                                    frame_27[282] = frame_49[189]
                                    frame_27[283] = frame_27[252]
                                    frame_27[284] = table.insert
                                    frame_27[284](frame_27[282], frame_27[283])
                                    frame_27[241] = (frame_27[241] + frame_27[253])
                                    frame_27[240] = frame_27[252]
                                    frame_27[285] = table.remove
                                    frame_27[286] = frame_27[246]
                                    frame_27[285](frame_27[286], 1)
                                    frame_27[288] = frame_27[246]
                                    frame_27[289] = frame_27[252]
                                    frame_27[290] = table.insert
                                    frame_27[290](frame_27[288], frame_27[289])
                                    cfg_27 = 72
                                elseif cfg_27 == 72 then
                                    break
                                else
                                    error("invalid control state")
                                end
                            end
                            if leave_for_27_60 then break end
                        end
                        if not leave_for_27_60 then
                            cfg_27 = 73
                        end
                        if cfg_27 ~= 57 and cfg_27 ~= 58 and cfg_27 ~= 59 and cfg_27 ~= 73 then
                            leave_for_27_57 = true
                            break
                        end
                    elseif cfg_27 == 73 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_27_57 then break end
            end
            if not leave_for_27_57 then
                cfg_27 = 74
            end
        elseif cfg_27 == 74 then
            frame_27[291] = gRegion
            frame_27[292] = frame_27[33][1]
            frame_27[293] = frame_49[189]
            frame_27[296] = (frame_27[291]):Name__81993ba3(frame_27[292], frame_27[293])
            frame_27[297] = frame_27[296]
            frame_27[298] = IsNull
            frame_27[299] = frame_27[298](frame_27[297])
            if frame_27[299] then
                cfg_27 = 78
            else
                cfg_27 = 75
            end
        elseif cfg_27 == 75 then
            frame_27[300] = 1
            frame_27[301] = frame_49[189]
            frame_27[302] = (#frame_27[301])
            frame_27[303] = 1
            local leave_for_27_76 = false
            for for_value_27_76 = frame_27[300], frame_27[302], frame_27[303] do
                frame_27[300] = for_value_27_76
                cfg_27 = 76
                while true do
                    if cfg_27 == 76 then
                        frame_27[304] = frame_49[189]
                        frame_27[305] = frame_27[304][1]
                        if frame_27[305] == frame_27[296] then
                            cfg_27 = 78
                            leave_for_27_76 = true
                            break
                        else
                            cfg_27 = 77
                        end
                    elseif cfg_27 == 77 then
                        frame_27[306] = table.remove
                        frame_27[307] = frame_49[189]
                        frame_27[306](frame_27[307], 1)
                        frame_27[309] = frame_49[189]
                        frame_27[310] = frame_27[305]
                        frame_27[311] = table.insert
                        frame_27[311](frame_27[309], frame_27[310])
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_27_76 then break end
            end
            if not leave_for_27_76 then
                cfg_27 = 78
            end
        elseif cfg_27 == 78 then
            frame_27[312] = frame_49["cap_49_332_8"]
            frame_27[314] = frame_49[189]
            frame_27[312]("Optimized", frame_27[314])
            return
        else
            error("invalid control state")
        end
    end
end
frame_49["cap_49_342_4"] = frame_49[260]
frame_49["cap_49_342_5"] = frame_49[122]
frame_49["cap_49_342_6"] = frame_49[125]
frame_49["cap_49_342_7"] = frame_49[110]
frame_49["cap_49_342_8"] = frame_49[116]
frame_49["cap_49_342_11"] = frame_49[5]
frame_49["cap_49_342_12"] = frame_49[143]
frame_49["cap_49_342_14"] = frame_49[234]
frame_49["cap_49_342_15"] = frame_49[8]
frame_49["cap_49_342_16"] = frame_49[2]
frame_49[261] = function(p28_0, p28_1, p28_2)
    local frame_28 = {}
    local cfg_28 = 0
    while true do
        if cfg_28 == 0 then
            frame_28[3] = frame_49[206]
            if not (frame_28[3]) then
                cfg_28 = 3
            else
                cfg_28 = 1
            end
        elseif cfg_28 == 1 then
            frame_28[4] = _T.extractionAvailable
            if not (frame_28[4]) then
                cfg_28 = 3
            else
                cfg_28 = 2
            end
        elseif cfg_28 == 2 then
            return
        elseif cfg_28 == 3 then
            frame_28[5] = (#p28_1)
            frame_49[29] = frame_28[5]
            frame_28[7] = p28_2
            local leave_for_28_7 = false
            for for_value_28_7_0, for_value_28_7_1 in ipairs(frame_28[7]) do
                frame_28[19], frame_28[20] = for_value_28_7_0, for_value_28_7_1
                cfg_28 = 4
                while true do
                    if cfg_28 == 4 then
                        frame_28[11] = frame_28[20]
                        frame_28[12] = IsNull
                        frame_28[13] = frame_28[12](frame_28[11])
                        if frame_28[13] then
                            cfg_28 = 7
                        else
                            cfg_28 = 5
                        end
                    elseif cfg_28 == 5 then
                        frame_28[16] = (frame_28[20]):IsEnabled()
                        if not (frame_28[16]) then
                            cfg_28 = 7
                        else
                            cfg_28 = 6
                        end
                    elseif cfg_28 == 6 then
                        frame_28[17] = frame_49[29]
                        frame_28[18] = (frame_28[17] + 1)
                        frame_49[29] = frame_28[18]
                        cfg_28 = 7
                    elseif cfg_28 == 7 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_28_7 then break end
            end
            if not leave_for_28_7 then
                cfg_28 = 8
            end
        elseif cfg_28 == 8 then
            frame_28[21] = frame_49[29]
            frame_28[22] = frame_49[28]
            if not (frame_28[22] <= frame_28[21]) then
                cfg_28 = 10
            else
                cfg_28 = 9
            end
        elseif cfg_28 == 9 then
            return
        elseif cfg_28 == 10 then
            frame_28[23] = frame_49[189]
            if frame_28[23] ~= nil then
                cfg_28 = 12
            else
                cfg_28 = 11
            end
        elseif cfg_28 == 11 then
            frame_28[24] = frame_49["cap_49_342_4"]
            frame_28[24]()
            cfg_28 = 12
        elseif cfg_28 == 12 then
            frame_28[25] = frame_49[189]
            frame_28[26] = (#frame_28[25])
            if frame_28[26] ~= 0 then
                cfg_28 = 14
            else
                cfg_28 = 13
            end
        elseif cfg_28 == 13 then
            return
        elseif cfg_28 == 14 then
            frame_28[27] = gGameRules
            frame_28[28] = frame_49["cap_49_342_5"]
            frame_28[32] = (frame_28[27]):GetNetPersistentVar(frame_28[28], 0)
            frame_28[33] = frame_49["cap_49_342_6"]
            frame_28[37] = (frame_28[27]):GetNetPersistentVar(frame_28[33], 0)
            if (frame_28[32] ~= 1 or frame_28[37] ~= 0) then
                cfg_28 = 17
            else
                cfg_28 = 16
            end
        elseif cfg_28 == 16 then
            return
        elseif cfg_28 == 17 then
            frame_28[39] = frame_49[189]
            frame_28[40] = (#frame_28[39])
            frame_28[41] = (frame_28[32] % frame_28[40])
            frame_28[42] = (1 + frame_28[41])
            frame_28[43] = frame_49[189]
            frame_28[44] = frame_28[43][frame_28[42]]
            frame_28[45] = gRegion
            frame_28[46] = gLotusExcavationStateType
            frame_28[49] = (frame_28[44]):GetPosition()
            frame_28[53] = (frame_28[45]):FindNearest(frame_28[46], frame_28[49], 5)
            frame_28[54] = frame_28[53]
            frame_28[55] = IsNull
            frame_28[56] = frame_28[55](frame_28[54])
            if not (frame_28[56]) then
                cfg_28 = 19
            else
                cfg_28 = 18
            end
        elseif cfg_28 == 18 then
            frame_28[57] = print
            frame_28[61] = (frame_28[44]):GetFullName()
            frame_28[62] = ("Could not find excavator state for " .. frame_28[61])
            frame_28[57](frame_28[62])
            frame_28[63] = table.remove
            frame_28[64] = frame_49[189]
            frame_28[65] = frame_28[42]
            frame_28[63](frame_28[64], frame_28[65])
            return
        elseif cfg_28 == 19 then
            frame_28[68] = (frame_28[53]):IsEnabled()
            if not (frame_28[68]) then
                cfg_28 = 21
            else
                cfg_28 = 20
            end
        elseif cfg_28 == 20 then
            return
        elseif cfg_28 == 21 then
            frame_28[69] = frame_49["cap_49_342_7"]
            frame_28[73] = (frame_28[27]):GetNetPersistentVar(frame_28[69], 0)
            if frame_28[73] ~= 0 then
                cfg_28 = 57
            else
                cfg_28 = 22
            end
        elseif cfg_28 == 22 then
            frame_28[74] = gRegion
            frame_28[75] = gMultiAvatarTriggerType
            frame_28[78] = (frame_28[44]):GetPosition()
            frame_28[82] = (frame_28[74]):FindNearest(frame_28[75], frame_28[78], 0.2)
            frame_28[83] = frame_28[82]
            frame_28[84] = IsNull
            frame_28[85] = frame_28[84](frame_28[83])
            if frame_28[85] then
                cfg_28 = 25
            else
                cfg_28 = 23
            end
        elseif cfg_28 == 23 then
            frame_28[88] = (frame_28[82]):IsEnabled()
            if not (frame_28[88]) then
                cfg_28 = 25
            else
                cfg_28 = 24
            end
        elseif cfg_28 == 24 then
            return
        elseif cfg_28 == 25 then
            frame_28[89] = frame_49["cap_49_342_8"]
            frame_28[93] = (frame_28[27]):GetNetPersistentVar(frame_28[89], 0)
            frame_28[94] = 500
            frame_28[95] = gGameRules
            frame_28[98] = (frame_28[95]):GetMission()
            frame_28[99] = frame_49[213]
            if frame_28[99] then
                cfg_28 = 27
            else
                cfg_28 = 26
            end
        elseif cfg_28 == 26 then
            frame_28[99] = (frame_28[98]).maxWaveNum
            cfg_28 = 27
        elseif cfg_28 == 27 then
            if not (0 < frame_28[99]) then
                cfg_28 = 29
            else
                cfg_28 = 28
            end
        elseif cfg_28 == 28 then
            frame_28[101] = frame_49[70]
            frame_28[94] = (frame_28[99] * frame_28[101])
            cfg_28 = 29
        elseif cfg_28 == 29 then
            frame_28[102] = true
            frame_28[103] = gGameRules
            frame_28[106] = (frame_28[103]):GetMission()
            frame_28[107] = (frame_28[106]).periodicMissionTag
            frame_28[108] = frame_49["cap_49_342_11"]
            frame_28[109] = (frame_28[108]).ELITE_ALERT_PERIODIC_MISSION_TAG
            if frame_28[107] == frame_28[109] then
                cfg_28 = 33
            else
                cfg_28 = 30
            end
        elseif cfg_28 == 30 then
            frame_28[110] = gGameRules
            frame_28[113] = (frame_28[110]):GetMission()
            frame_28[114] = (frame_28[113]).periodicMissionTag
            frame_28[115] = frame_49["cap_49_342_11"]
            frame_28[116] = (frame_28[115]).ELITE_ALERT_PERIODIC_MISSION_TAG_ALT
            if frame_28[114] == frame_28[116] then
                cfg_28 = 32
            else
                cfg_28 = 31
            end
        elseif cfg_28 == 31 then
            frame_28[102] = false
            cfg_28 = 33
        elseif cfg_28 == 32 then
            frame_28[102] = true
            cfg_28 = 33
        elseif cfg_28 == 33 then
            if not (frame_28[102]) then
                cfg_28 = 35
            else
                cfg_28 = 34
            end
        elseif cfg_28 == 34 then
            frame_28[94] = (frame_28[94] * 2)
            cfg_28 = 35
        elseif cfg_28 == 35 then
            frame_28[117] = false
            frame_28[118] = frame_49["cap_49_342_12"]
            frame_28[121] = (frame_28[27]):GetNetPersistentVar(frame_28[118])
            frame_28[122] = frame_49[208]
            if (not (frame_28[122]) or frame_28[121] ~= 0) then
                cfg_28 = 39
            else
                cfg_28 = 37
            end
        elseif cfg_28 == 37 then
            frame_28[123] = frame_49["cap_49_342_14"]
            frame_28[124] = frame_28[123]()
            if not (frame_28[124]) then
                cfg_28 = 39
            else
                cfg_28 = 38
            end
        elseif cfg_28 == 38 then
            frame_28[117] = true
            cfg_28 = 39
        elseif cfg_28 == 39 then
            frame_28[125] = true
            frame_28[126] = (frame_28[98]).goalTag
            frame_28[127] = Symbol
            frame_28[129] = frame_28[127]("ShieldExcav")
            if frame_28[126] == frame_28[129] then
                cfg_28 = 43
            else
                cfg_28 = 40
            end
        elseif cfg_28 == 40 then
            frame_28[130] = (frame_28[98]).goalTag
            frame_28[131] = Symbol
            frame_28[133] = frame_28[131]("OldWorldSalvage")
            if frame_28[130] == frame_28[133] then
                cfg_28 = 42
            else
                cfg_28 = 41
            end
        elseif cfg_28 == 41 then
            frame_28[125] = false
            cfg_28 = 43
        elseif cfg_28 == 42 then
            frame_28[125] = true
            cfg_28 = 43
        elseif cfg_28 == 43 then
            if ((not (frame_28[125]) or not (frame_28[99] <= frame_28[32])) or frame_28[117]) then
                cfg_28 = 47
            else
                cfg_28 = 46
            end
        elseif cfg_28 == 46 then
            frame_49[28] = 0
            return
        elseif cfg_28 == 47 then
            frame_28[135] = frame_49[206]
            if ((not (frame_28[135]) or not (frame_28[94] <= frame_28[93])) or frame_28[125]) then
                cfg_28 = 51
            else
                cfg_28 = 50
            end
        elseif cfg_28 == 50 then
            frame_49[28] = 0
            return
        elseif cfg_28 == 51 then
            frame_28[137] = nil
            if frame_28[32] == 0 then
                cfg_28 = 54
            else
                cfg_28 = 52
            end
        elseif cfg_28 == 52 then
            frame_28[138] = _T.MissionDebug
            if not (frame_28[138]) then
                cfg_28 = 55
            else
                cfg_28 = 53
            end
        elseif cfg_28 == 53 then
            frame_28[139] = _T.MissionDebug.FastDig
            if not (frame_28[139]) then
                cfg_28 = 55
            else
                cfg_28 = 54
            end
        elseif cfg_28 == 54 then
            frame_28[140] = 2
            cfg_28 = 56
        elseif cfg_28 == 55 then
            frame_28[140] = 60
            cfg_28 = 56
        elseif cfg_28 == 56 then
            frame_28[141] = frame_49["cap_49_342_7"]
            frame_28[142] = (p28_0 + frame_28[140])
            do (frame_28[27]):SetNetPersistentVar(frame_28[141], frame_28[142]) end
            return
        elseif cfg_28 == 57 then
            if not (p28_0 < frame_28[73]) then
                cfg_28 = 59
            else
                cfg_28 = 58
            end
        elseif cfg_28 == 58 then
            return
        elseif cfg_28 == 59 then
            if not (frame_28[37] < frame_28[32]) then
                cfg_28 = 61
            else
                cfg_28 = 60
            end
        elseif cfg_28 == 60 then
            return
        elseif cfg_28 == 61 then
            frame_28[145] = frame_49[29]
            if frame_28[145] ~= 0 then
                cfg_28 = 63
            else
                cfg_28 = 62
            end
        elseif cfg_28 == 62 then
            frame_28[146] = gRegion
            frame_28[149] = (frame_28[146]):GetNpcMgr()
            frame_28[152] = (frame_28[149]):GetAiDirector()
            frame_28[153] = frame_28[44]
            do (frame_28[152]):SetObjective(frame_28[153]) end
            frame_28[156] = frame_28[44]
            do (frame_28[152]):Name__7fccb7d5(frame_28[156]) end
            cfg_28 = 63
        elseif cfg_28 == 63 then
            frame_28[159] = frame_49["cap_49_342_5"]
            frame_28[160] = (frame_28[32] + 1)
            do (frame_28[27]):SetNetPersistentVar(frame_28[159], frame_28[160]) end
            frame_28[163] = frame_49["cap_49_342_7"]
            do (frame_28[27]):SetNetPersistentVar(frame_28[163], 0) end
            do (frame_28[44]):FirePort("TriggerPort") end
            frame_28[170] = frame_49["cap_49_342_15"]
            frame_28[171] = (frame_28[170]).PlayGlobalTransmission
            frame_28[172] = _T.MissionTransmissionSet
            frame_28[173] = frame_49["cap_49_342_16"]
            frame_28[174] = (frame_28[173]).Ternary
            frame_28[175] = frame_49[29]
            if frame_28[175] == 0 then
                cfg_28 = 65
            else
                cfg_28 = 64
            end
        elseif cfg_28 == 64 then
            frame_28[176] = false
            cfg_28 = 66
        elseif cfg_28 == 65 then
            frame_28[176] = true
            cfg_28 = 66
        elseif cfg_28 == 66 then
            frame_28[177] = Symbol
            frame_28[179] = frame_28[177]("MissionIntro")
            frame_28[180] = Symbol
            frame_28[171](frame_28[172], frame_28[174](frame_28[176], frame_28[179], frame_28[180]("MissionScannerComplete")))
            frame_28[201] = frame_49["cap_49_342_15"]
            frame_28[202] = (frame_28[201]).PlayGlobalTransmission
            frame_28[203] = _T.MissionTransmissionSet
            frame_28[204] = frame_49["cap_49_342_16"]
            frame_28[205] = (frame_28[204]).Ternary
            frame_28[206] = frame_49[29]
            if frame_28[206] == 0 then
                cfg_28 = 68
            else
                cfg_28 = 67
            end
        elseif cfg_28 == 67 then
            frame_28[207] = false
            cfg_28 = 69
        elseif cfg_28 == 68 then
            frame_28[207] = true
            cfg_28 = 69
        elseif cfg_28 == 69 then
            frame_28[208] = Symbol
            frame_28[210] = frame_28[208]("MissionIntroExtra")
            frame_28[211] = Symbol
            frame_28[202](frame_28[203], frame_28[205](frame_28[207], frame_28[210], frame_28[211]("MissionScannerCompleteExtra")))
            return
        else
            error("invalid control state")
        end
    end
end
frame_49["cap_49_360_1"] = frame_49[140]
frame_49["cap_49_360_2"] = frame_49[2]
frame_49["cap_49_360_3"] = frame_49[5]
frame_49[262] = function(p29_0, p29_1)
    local frame_29 = {}
    local cfg_29 = 0
    while true do
        if cfg_29 == 0 then
            frame_29[2] = false
            frame_29[3] = frame_49[207]
            if not (frame_29[3]) then
                cfg_29 = 19
            else
                cfg_29 = 1
            end
        elseif cfg_29 == 1 then
            if (not (p29_1 == nil) and p29_1 ~= 1) then
                cfg_29 = 19
            else
                cfg_29 = 3
            end
        elseif cfg_29 == 3 then
            frame_29[4] = gGameRules
            frame_29[5] = frame_49["cap_49_360_1"]
            do (frame_29[4]):SetNetPersistentVar(frame_29[5], 1) end
            frame_29[9] = frame_49["cap_49_360_2"]
            frame_29[10] = (frame_29[9]).Ternary
            if p29_1 == nil then
                cfg_29 = 5
            else
                cfg_29 = 4
            end
        elseif cfg_29 == 4 then
            frame_29[11] = false
            cfg_29 = 6
        elseif cfg_29 == 5 then
            frame_29[11] = true
            cfg_29 = 6
        elseif cfg_29 == 6 then
            frame_29[14] = frame_29[10](frame_29[11], 3, 0)
            cfg_29 = 7
        elseif cfg_29 == 7 then
            frame_29[15] = frame_49["cap_49_360_3"]
            frame_29[16] = (frame_29[15]).IsTransmissionPlaying
            frame_29[17] = frame_29[16]()
            if frame_29[17] then
                cfg_29 = 10
            else
                cfg_29 = 8
            end
        elseif cfg_29 == 8 then
            frame_29[18] = DeltaTime
            frame_29[19] = frame_29[18]()
            frame_29[14] = (frame_29[14] - frame_29[19])
            if frame_29[14] <= 0 then
                cfg_29 = 10
            else
                cfg_29 = 9
            end
        elseif cfg_29 == 9 then
            frame_29[21] = Sleep
            frame_29[21](0)
            cfg_29 = 7
        elseif cfg_29 == 10 then
            frame_29[23] = 20
            cfg_29 = 11
        elseif cfg_29 == 11 then
            frame_29[24] = frame_49["cap_49_360_3"]
            frame_29[25] = (frame_29[24]).IsTransmissionPlaying
            frame_29[26] = frame_29[25]()
            if not (frame_29[26]) then
                cfg_29 = 14
            else
                cfg_29 = 12
            end
        elseif cfg_29 == 12 then
            frame_29[27] = DeltaTime
            frame_29[28] = frame_29[27]()
            frame_29[23] = (frame_29[23] - frame_29[28])
            if frame_29[23] <= 0 then
                cfg_29 = 14
            else
                cfg_29 = 13
            end
        elseif cfg_29 == 13 then
            frame_29[30] = Sleep
            frame_29[30](0)
            cfg_29 = 11
        elseif cfg_29 == 14 then
            frame_29[32] = gGameRules
            frame_29[33] = p29_0
            frame_29[37] = (frame_29[32]):OpenVoidProjectionRewardScreen(frame_29[33], false)
            frame_29[38] = frame_29[37]
            frame_29[39] = IsNull
            frame_29[40] = frame_29[39](frame_29[38])
            if frame_29[40] then
                cfg_29 = 19
            else
                cfg_29 = 15
            end
        elseif cfg_29 == 15 then
            frame_29[2] = true
            cfg_29 = 16
        elseif cfg_29 == 16 then
            frame_29[41] = frame_29[37]
            frame_29[42] = IsNull
            frame_29[43] = frame_29[42](frame_29[41])
            if frame_29[43] then
                cfg_29 = 18
            else
                cfg_29 = 17
            end
        elseif cfg_29 == 17 then
            frame_29[44] = Sleep
            frame_29[44](0)
            cfg_29 = 16
        elseif cfg_29 == 18 then
            frame_29[46] = gGameRules
            do (frame_29[46]):CloseVoidProjectionRewardScreen() end
            cfg_29 = 19
        elseif cfg_29 == 19 then
            if (not (frame_29[2]) and p29_1 ~= 2) then
                cfg_29 = 27
            else
                cfg_29 = 21
            end
        elseif cfg_29 == 21 then
            frame_29[49] = gGameRules
            frame_29[50] = frame_49["cap_49_360_1"]
            do (frame_29[49]):SetNetPersistentVar(frame_29[50], 2) end
            frame_29[54] = gGameRules
            if p29_1 ~= nil then
                cfg_29 = 23
            else
                cfg_29 = 22
            end
        elseif cfg_29 == 22 then
            frame_29[55] = false
            cfg_29 = 24
        elseif cfg_29 == 23 then
            frame_29[55] = true
            cfg_29 = 24
        elseif cfg_29 == 24 then
            frame_29[58] = (frame_29[54]):OpenVoidProjectionSelectionScreen(frame_29[55])
            frame_29[59] = frame_29[58]
            frame_29[60] = IsNull
            frame_29[61] = frame_29[60](frame_29[59])
            if frame_29[61] then
                cfg_29 = 27
            else
                cfg_29 = 25
            end
        elseif cfg_29 == 25 then
            frame_29[62] = frame_29[58]
            frame_29[63] = IsNull
            frame_29[64] = frame_29[63](frame_29[62])
            if frame_29[64] then
                cfg_29 = 27
            else
                cfg_29 = 26
            end
        elseif cfg_29 == 26 then
            frame_29[65] = Sleep
            frame_29[65](0)
            cfg_29 = 25
        elseif cfg_29 == 27 then
            frame_29[67] = gGameRules
            frame_29[68] = frame_49["cap_49_360_1"]
            do (frame_29[67]):SetNetPersistentVar(frame_29[68], 0) end
            return
        else
            error("invalid control state")
        end
    end
end
frame_49["cap_49_365_1"] = frame_49[164]
frame_49["cap_49_365_2"] = frame_49[167]
frame_49["cap_49_365_3"] = frame_49[170]
frame_49["cap_49_365_4"] = frame_49[173]
frame_49["cap_49_365_5"] = frame_49[176]
frame_49["cap_49_365_7"] = frame_49[179]
frame_49["cap_49_365_8"] = frame_49[104]
frame_49["cap_49_365_9"] = frame_49[113]
frame_49["cap_49_365_12"] = frame_49[149]
frame_49["cap_49_365_13"] = frame_49[257]
frame_49["cap_49_365_14"] = frame_49[74]
frame_49["cap_49_365_15"] = frame_49[119]
frame_49["cap_49_365_16"] = frame_49[125]
frame_49["cap_49_365_17"] = frame_49[86]
frame_49["cap_49_365_18"] = frame_49[98]
frame_49["cap_49_365_19"] = frame_49[247]
frame_49["cap_49_365_20"] = frame_49[261]
frame_49["cap_49_365_22"] = frame_49[182]
frame_49["cap_49_365_23"] = frame_49[188]
frame_49["cap_49_365_24"] = frame_49[5]
frame_49["cap_49_365_25"] = frame_49[8]
frame_49["cap_49_365_26"] = frame_49[220]
frame_49["cap_49_365_28"] = frame_49[116]
frame_49["cap_49_365_30"] = frame_49[262]
frame_49["cap_49_365_31"] = frame_49[131]
frame_49[263] = function()
    local frame_30 = {}
    local cfg_30 = 0
    while true do
        if cfg_30 == 0 then
            frame_30[0] = gRegion
            frame_30[3] = (frame_30[0]):GetNpcMgr()
            frame_30[6] = (frame_30[3]):GetAiDirector()
            do (frame_30[6]):Enable(true) end
            do (frame_30[6]):Name__87452014(false) end
            do (frame_30[6]):SetEnableAutoSpawns(false) end
            do (frame_30[6]):SetLevelAlert(true) end
            do (frame_30[6]):Name__f2101814(0) end
            do (frame_30[6]):Name__b37ce12d(150, 150, false, false) end
            do (frame_30[6]):Name__46efd736(true) end
            frame_30[31] = frame_49[212]
            if not (frame_30[31]) then
                cfg_30 = 2
            else
                cfg_30 = 1
            end
        elseif cfg_30 == 1 then
            do (frame_30[6]):Name__4d8be231(false) end
            do (frame_30[6]):Name__7cfddb2b(10, 150, 0, 3, false, false, true) end
            cfg_30 = 3
        elseif cfg_30 == 2 then
            do (frame_30[6]):Name__7cfddb2b(10, 150, 0, 3, true, true, true) end
            cfg_30 = 3
        elseif cfg_30 == 3 then
            frame_30[53] = frame_49["cap_49_365_1"]
            do (frame_30[6]):Name__58d782d8(frame_30[53]) end
            frame_30[56] = frame_49["cap_49_365_2"]
            do (frame_30[6]):Name__58d782d8(frame_30[56]) end
            frame_30[59] = frame_49["cap_49_365_3"]
            do (frame_30[6]):Name__58d782d8(frame_30[59]) end
            frame_30[62] = frame_49["cap_49_365_4"]
            do (frame_30[6]):Name__58d782d8(frame_30[62]) end
            frame_30[65] = frame_49["cap_49_365_5"]
            do (frame_30[6]):Name__58d782d8(frame_30[65]) end
            do (frame_30[6]):Name__af932d17(0) end
            frame_30[71] = frame_49[212]
            if frame_30[71] then
                cfg_30 = 5
            else
                cfg_30 = 4
            end
        elseif cfg_30 == 4 then
            frame_30[72] = gRegion
            frame_30[73] = frame_49["cap_49_365_7"]
            frame_30[76] = (frame_30[72]):FindFirstTagged(frame_30[73])
            frame_49[214] = frame_30[76]
            cfg_30 = 5
        elseif cfg_30 == 5 then
            frame_30[77] = _T.ExcavationScanner
            frame_30[78] = IsNull
            frame_30[79] = frame_30[78](frame_30[77])
            if frame_30[79] then
                cfg_30 = 7
            else
                cfg_30 = 6
            end
        elseif cfg_30 == 6 then
            frame_30[80] = _T.ExcavationScanner
            do (frame_30[6]):SetObjective(frame_30[80]) end
            cfg_30 = 10
        elseif cfg_30 == 7 then
            frame_30[83] = frame_49[212]
            if frame_30[83] then
                cfg_30 = 10
            else
                cfg_30 = 8
            end
        elseif cfg_30 == 8 then
            frame_30[84] = frame_49[214]
            frame_30[85] = IsNull
            frame_30[86] = frame_30[85](frame_30[84])
            if frame_30[86] then
                cfg_30 = 10
            else
                cfg_30 = 9
            end
        elseif cfg_30 == 9 then
            frame_30[87] = frame_49[214]
            do (frame_30[6]):SetObjective(frame_30[87]) end
            cfg_30 = 10
        elseif cfg_30 == 10 then
            frame_30[90] = gGameRules
            frame_30[91] = frame_49["cap_49_365_8"]
            frame_30[94] = (frame_30[90]):GetNetPersistentVar(frame_30[91])
            frame_30[95] = gGameRules
            frame_30[96] = frame_49["cap_49_365_9"]
            frame_30[100] = (frame_30[95]):GetNetPersistentVar(frame_30[96], 0)
            frame_30[101] = gGameRules
            frame_30[104] = (frame_30[101]):GetMission()
            frame_30[105] = {}
            frame_30[106] = {}
            frame_49[31] = frame_30[106]
            frame_30[107] = {}
            frame_30[108] = 0
            frame_30[109] = gGameRules
            frame_30[110] = frame_49["cap_49_365_12"]
            frame_30[114] = (frame_30[109]):GetNetPersistentVar(frame_30[110], 0)
            if 0 < frame_30[114] then
                cfg_30 = 12
            else
                cfg_30 = 11
            end
        elseif cfg_30 == 11 then
            frame_30[116] = false
            cfg_30 = 13
        elseif cfg_30 == 12 then
            frame_30[116] = true
            cfg_30 = 13
        elseif cfg_30 == 13 then
            frame_49[71] = frame_30[116]
            cfg_30 = 14
        elseif cfg_30 == 14 then
            if frame_30[94] ~= 0 then
                cfg_30 = 16
            else
                cfg_30 = 15
            end
        elseif cfg_30 == 15 then
            frame_30[117] = frame_49["cap_49_365_13"]
            frame_30[118] = frame_30[100]
            frame_30[119] = frame_30[108]
            frame_30[120] = frame_30[105]
            frame_30[121] = frame_49[31]
            frame_30[122] = frame_30[117](frame_30[118], frame_30[119], frame_30[120], frame_30[121])
            frame_30[108] = frame_30[122]
            frame_30[123] = Sleep
            frame_30[124] = frame_30[108]
            frame_30[123](frame_30[124])
            frame_30[125] = gGameRules
            frame_30[126] = frame_49["cap_49_365_8"]
            frame_30[129] = (frame_30[125]):GetNetPersistentVar(frame_30[126])
            frame_30[94] = frame_30[129]
            cfg_30 = 14
        elseif cfg_30 == 16 then
            if frame_30[94] ~= 1 then
                cfg_30 = 18
            else
                cfg_30 = 17
            end
        elseif cfg_30 == 17 then
            frame_30[130] = frame_49["cap_49_365_13"]
            frame_30[131] = frame_30[100]
            frame_30[132] = frame_30[108]
            frame_30[133] = frame_30[105]
            frame_30[134] = frame_49[31]
            frame_30[135] = frame_30[130](frame_30[131], frame_30[132], frame_30[133], frame_30[134])
            frame_30[108] = frame_30[135]
            frame_30[136] = Sleep
            frame_30[137] = frame_30[108]
            frame_30[136](frame_30[137])
            frame_30[138] = gGameRules
            frame_30[139] = frame_49["cap_49_365_8"]
            frame_30[142] = (frame_30[138]):GetNetPersistentVar(frame_30[139])
            frame_30[94] = frame_30[142]
            cfg_30 = 16
        elseif cfg_30 == 18 then
            frame_30[143] = gGameRules
            frame_30[144] = frame_49["cap_49_365_14"]
            frame_30[145] = EMPTY_SYMBOL
            do (frame_30[143]):SetMissionTimer(frame_30[144], frame_30[145], 0, false, false, true) end
            frame_30[152] = gGameRules
            frame_30[153] = frame_49["cap_49_365_14"]
            frame_30[154] = frame_30[100]
            do (frame_30[152]):Name__bb656394(frame_30[153], frame_30[154]) end
            frame_30[157] = _T
            frame_30[157].LastActivityTime = frame_30[100]
            do (frame_30[6]):SetLevelAlert(true) end
            do (frame_30[6]):RlJets(10) end
            frame_30[164] = false
            frame_30[165] = false
            frame_30[166] = 0
            frame_30[167] = gGameRules
            frame_30[168] = frame_49["cap_49_365_15"]
            frame_30[172] = (frame_30[167]):GetNetPersistentVar(frame_30[168], 0)
            frame_30[173] = (frame_30[172] / 200)
            frame_30[174] = math.floor
            frame_30[175] = frame_30[174](frame_30[173])
            frame_30[176] = (frame_30[175] + 1)
            frame_30[177] = (frame_30[176] * 200)
            frame_30[178] = -1
            frame_30[179] = 0
            frame_30[180] = 0
            cfg_30 = 19
        elseif cfg_30 == 19 then
            frame_30[181] = _T.DebugCompleteArena
            if (frame_30[181] or frame_30[94] ~= 2) then
                cfg_30 = 88
            else
                cfg_30 = 21
            end
        elseif cfg_30 == 21 then
            frame_30[182] = gGameRules
            frame_30[183] = frame_49["cap_49_365_16"]
            frame_30[187] = (frame_30[182]):GetNetPersistentVar(frame_30[183], 0)
            frame_30[188] = false
            if frame_30[178] == frame_30[187] then
                cfg_30 = 27
            else
                cfg_30 = 22
            end
        elseif cfg_30 == 22 then
            frame_30[178] = frame_30[187]
            frame_30[189] = gRegion
            frame_30[190] = frame_49["cap_49_365_17"]
            frame_30[193] = (frame_30[189]):FindTagged(frame_30[190])
            frame_30[105] = frame_30[193]
            frame_30[194] = {}
            frame_49[31] = frame_30[194]
            frame_30[195] = 1
            frame_30[196] = (#frame_30[105])
            frame_30[197] = 1
            local leave_for_30_23 = false
            for for_value_30_23 = frame_30[195], frame_30[196], frame_30[197] do
                frame_30[195] = for_value_30_23
                cfg_30 = 23
                while true do
                    if cfg_30 == 23 then
                        frame_30[198] = frame_30[105][frame_30[195]]
                        frame_30[199] = gRegion
                        frame_30[200] = gLotusExcavationStateType
                        frame_30[203] = (frame_30[198]):GetPosition()
                        frame_30[207] = (frame_30[199]):FindNearest(frame_30[200], frame_30[203], 5)
                        frame_30[208] = frame_30[207]
                        frame_30[209] = IsNull
                        frame_30[210] = frame_30[209](frame_30[208])
                        if not (frame_30[210]) then
                            cfg_30 = 25
                        else
                            cfg_30 = 24
                        end
                    elseif cfg_30 == 24 then
                        frame_30[211] = print
                        frame_30[215] = (frame_30[198]):GetFullName()
                        frame_30[216] = ("No state for " .. frame_30[215])
                        frame_30[211](frame_30[216])
                        cfg_30 = 25
                    elseif cfg_30 == 25 then
                        frame_30[217] = frame_49[31]
                        frame_30[217][frame_30[195]] = frame_30[207]
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_30_23 then break end
            end
            if not leave_for_30_23 then
                cfg_30 = 26
            end
        elseif cfg_30 == 26 then
            frame_30[188] = true
            cfg_30 = 31
        elseif cfg_30 == 27 then
            frame_30[218] = (#frame_30[105])
            frame_30[219] = 1
            frame_30[220] = -1
            local leave_for_30_28 = false
            for for_value_30_28 = frame_30[218], frame_30[219], frame_30[220] do
                frame_30[218] = for_value_30_28
                cfg_30 = 28
                while true do
                    if cfg_30 == 28 then
                        frame_30[221] = frame_30[105][frame_30[218]]
                        frame_30[222] = IsNull
                        frame_30[223] = frame_30[222](frame_30[221])
                        if not (frame_30[223]) then
                            cfg_30 = 30
                        else
                            cfg_30 = 29
                        end
                    elseif cfg_30 == 29 then
                        frame_30[224] = table.remove
                        frame_30[225] = frame_30[105]
                        frame_30[226] = frame_30[218]
                        frame_30[224](frame_30[225], frame_30[226])
                        frame_30[227] = table.remove
                        frame_30[228] = frame_49[31]
                        frame_30[229] = frame_30[218]
                        frame_30[227](frame_30[228], frame_30[229])
                        frame_30[188] = true
                        cfg_30 = 30
                    elseif cfg_30 == 30 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_30_28 then break end
            end
            if not leave_for_30_28 then
                cfg_30 = 31
            end
        elseif cfg_30 == 31 then
            frame_30[230] = (#frame_30[107])
            if frame_30[230] ~= 0 then
                cfg_30 = 35
            else
                cfg_30 = 32
            end
        elseif cfg_30 == 32 then
            frame_30[231] = gRegion
            frame_30[232] = frame_49["cap_49_365_18"]
            frame_30[235] = (frame_30[231]):FindTagged(frame_30[232])
            frame_30[107] = frame_30[235]
            frame_30[236] = frame_49[212]
            if not (frame_30[236]) then
                cfg_30 = 35
            else
                cfg_30 = 33
            end
        elseif cfg_30 == 33 then
            frame_30[237] = _T.FilterEntitiesToCurrentLayer
            if not (frame_30[237]) then
                cfg_30 = 35
            else
                cfg_30 = 34
            end
        elseif cfg_30 == 34 then
            frame_30[238] = _T.FilterEntitiesToCurrentLayer
            frame_30[239] = frame_30[107]
            frame_30[240] = frame_30[238](frame_30[239])
            frame_30[107] = frame_30[240]
            cfg_30 = 35
        elseif cfg_30 == 35 then
            if not (frame_30[188]) then
                cfg_30 = 41
            else
                cfg_30 = 36
            end
        elseif cfg_30 == 36 then
            frame_30[241] = frame_30[105]
            do (frame_30[6]):Name__01403939(frame_30[241]) end
            frame_30[244] = (#frame_30[105])
            if not (0 < frame_30[244]) then
                cfg_30 = 40
            else
                cfg_30 = 37
            end
        elseif cfg_30 == 37 then
            frame_30[246] = frame_49[212]
            if not (frame_30[246]) then
                cfg_30 = 39
            else
                cfg_30 = 38
            end
        elseif cfg_30 == 38 then
            do (frame_30[6]):Name__7cfddb2b(10, 150, 0, 3, false, false, true) end
            cfg_30 = 40
        elseif cfg_30 == 39 then
            do (frame_30[6]):Name__7cfddb2b(10, 150, 0, 3, true, false, true) end
            cfg_30 = 40
        elseif cfg_30 == 40 then
            frame_30[265] = frame_49["cap_49_365_19"]
            frame_30[266] = frame_30[105]
            frame_30[265](frame_30[266])
            cfg_30 = 49
        elseif cfg_30 == 41 then
            frame_30[267] = gRegion
            frame_30[270] = (frame_30[267]):GetHumanPlayerAvatars()
            frame_30[271] = 0
            frame_30[273] = frame_30[270]
            local leave_for_30_45 = false
            for for_value_30_45_0, for_value_30_45_1 in ipairs(frame_30[273]) do
                frame_30[283], frame_30[284] = for_value_30_45_0, for_value_30_45_1
                cfg_30 = 42
                while true do
                    if cfg_30 == 42 then
                        frame_30[277] = frame_30[284]
                        frame_30[278] = IsNull
                        frame_30[279] = frame_30[278](frame_30[277])
                        if frame_30[279] then
                            cfg_30 = 45
                        else
                            cfg_30 = 43
                        end
                    elseif cfg_30 == 43 then
                        frame_30[282] = (frame_30[284]):IsKilled()
                        if frame_30[282] then
                            cfg_30 = 45
                        else
                            cfg_30 = 44
                        end
                    elseif cfg_30 == 44 then
                        frame_30[271] = (frame_30[271] + 1)
                        cfg_30 = 45
                    elseif cfg_30 == 45 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_30_45 then break end
            end
            if not leave_for_30_45 then
                cfg_30 = 46
            end
        elseif cfg_30 == 46 then
            frame_30[285] = (#frame_30[270])
            if (not (frame_30[179] ~= frame_30[285]) and frame_30[180] == frame_30[271]) then
                cfg_30 = 49
            else
                cfg_30 = 48
            end
        elseif cfg_30 == 48 then
            frame_30[286] = frame_49["cap_49_365_19"]
            frame_30[287] = frame_30[105]
            frame_30[286](frame_30[287])
            frame_30[179] = (#frame_30[270])
            frame_30[180] = frame_30[271]
            cfg_30 = 49
        elseif cfg_30 == 49 then
            frame_30[288] = frame_49["cap_49_365_20"]
            frame_30[289] = frame_30[100]
            frame_30[290] = frame_30[105]
            frame_30[291] = frame_30[107]
            frame_30[288](frame_30[289], frame_30[290], frame_30[291])
            frame_30[292] = _T.extractionAvailable
            if (not (frame_30[292]) or frame_30[164]) then
                cfg_30 = 65
            else
                cfg_30 = 51
            end
        elseif cfg_30 == 51 then
            frame_30[293] = frame_49[208]
            if not (frame_30[293]) then
                cfg_30 = 59
            else
                cfg_30 = 52
            end
        elseif cfg_30 == 52 then
            frame_30[294] = frame_49["cap_49_365_22"]
            frame_30[295] = gGameRules
            frame_30[296] = frame_49["cap_49_365_23"]
            frame_30[300] = (frame_30[295]):GetNetPersistentVar(frame_30[296], 0)
            if frame_30[300] ~= 1 then
                cfg_30 = 54
            else
                cfg_30 = 53
            end
        elseif cfg_30 == 53 then
            frame_30[301] = Symbol
            frame_30[303] = frame_30[301]("MissionExtractionAvailablePistol")
            frame_30[294] = frame_30[303]
            cfg_30 = 54
        elseif cfg_30 == 54 then
            frame_30[304] = gRegion
            frame_30[307] = (frame_30[304]):GetHumanPlayers()
            frame_30[308] = 1
            frame_30[309] = (#frame_30[307])
            frame_30[310] = 1
            local leave_for_30_55 = false
            for for_value_30_55 = frame_30[308], frame_30[309], frame_30[310] do
                frame_30[308] = for_value_30_55
                cfg_30 = 55
                while true do
                    if cfg_30 == 55 then
                        frame_30[311] = frame_49["cap_49_365_24"]
                        frame_30[312] = (frame_30[311]).IsFirstTimeInNode
                        frame_30[313] = frame_30[307][frame_30[308]]
                        frame_30[314] = frame_30[312](frame_30[313])
                        if not (frame_30[314]) then
                            cfg_30 = 57
                        else
                            cfg_30 = 56
                        end
                    elseif cfg_30 == 56 then
                        frame_30[315] = Symbol
                        frame_30[317] = frame_30[315]("MissionFirstExtractionAvailable")
                        frame_30[294] = frame_30[317]
                        cfg_30 = 57
                    elseif cfg_30 == 57 then
                        frame_30[318] = frame_49["cap_49_365_25"]
                        frame_30[319] = (frame_30[318]).PlayLocalTransmission
                        frame_30[320] = _T.MissionTransmissionSet
                        frame_30[321] = frame_30[294]
                        frame_30[322] = frame_30[307][frame_30[308]]
                        frame_30[319](frame_30[320], frame_30[321], (frame_30[322]):GetAvatar())
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_30_55 then break end
            end
            if not leave_for_30_55 then
                cfg_30 = 58
            end
        elseif cfg_30 == 58 then
            cfg_30 = 61
        elseif cfg_30 == 59 then
            frame_30[327] = (frame_30[104]).goalTag
            frame_30[328] = frame_49["cap_49_365_26"]
            if frame_30[327] == frame_30[328] then
                cfg_30 = 61
            else
                cfg_30 = 60
            end
        elseif cfg_30 == 60 then
            frame_30[329] = frame_49["cap_49_365_25"]
            frame_30[330] = (frame_30[329]).PlayGlobalTransmission
            frame_30[331] = _T.MissionTransmissionSet
            frame_30[332] = frame_49["cap_49_365_22"]
            frame_30[330](frame_30[331], frame_30[332])
            cfg_30 = 61
        elseif cfg_30 == 61 then
            frame_30[333] = frame_49[212]
            if frame_30[333] then
                cfg_30 = 64
            else
                cfg_30 = 62
            end
        elseif cfg_30 == 62 then
            frame_30[334] = gGameRules
            do (frame_30[334]):SetObjectiveComplete(true, true) end
            frame_30[339] = frame_49[214]
            frame_30[340] = IsNull
            frame_30[341] = frame_30[340](frame_30[339])
            if frame_30[341] then
                cfg_30 = 64
            else
                cfg_30 = 63
            end
        elseif cfg_30 == 63 then
            frame_30[342] = frame_49[214]
            do (frame_30[342]):FirePort("Enable") end
            cfg_30 = 64
        elseif cfg_30 == 64 then
            frame_30[164] = true
            cfg_30 = 65
        elseif cfg_30 == 65 then
            if frame_30[165] then
                cfg_30 = 69
            else
                cfg_30 = 66
            end
        elseif cfg_30 == 66 then
            frame_30[346] = frame_49[206]
            if not (frame_30[346]) then
                cfg_30 = 69
            else
                cfg_30 = 67
            end
        elseif cfg_30 == 67 then
            frame_30[347] = gGameRules
            frame_30[348] = frame_49["cap_49_365_28"]
            frame_30[352] = (frame_30[347]):GetNetPersistentVar(frame_30[348], 0)
            frame_30[353] = frame_49[70]
            frame_30[354] = (frame_30[353] * 3)
            if not (frame_30[354] <= frame_30[352]) then
                cfg_30 = 69
            else
                cfg_30 = 68
            end
        elseif cfg_30 == 68 then
            frame_30[355] = gGameRules
            do (frame_30[355]):HideGameSession(true) end
            frame_30[165] = true
            cfg_30 = 69
        elseif cfg_30 == 69 then
            frame_30[359] = gGameRules
            frame_30[360] = frame_49["cap_49_365_15"]
            frame_30[364] = (frame_30[359]):GetNetPersistentVar(frame_30[360], 0)
            frame_30[365] = frame_30[364]
            if frame_30[365] == frame_30[166] then
                cfg_30 = 74
            else
                cfg_30 = 70
            end
        elseif cfg_30 == 70 then
            if (not (frame_30[166] < frame_30[177]) or not (frame_30[177] <= frame_30[365])) then
                cfg_30 = 73
            else
                cfg_30 = 72
            end
        elseif cfg_30 == 72 then
            frame_30[177] = (frame_30[177] + 200)
            frame_30[366] = frame_49["cap_49_365_30"]
            frame_30[367] = (frame_30[365] / 200)
            frame_30[368] = math.floor
            frame_30[369] = frame_30[368](frame_30[367])
            frame_30[366](frame_30[369])
            cfg_30 = 73
        elseif cfg_30 == 73 then
            frame_30[166] = frame_30[365]
            cfg_30 = 74
        elseif cfg_30 == 74 then
            frame_30[370] = frame_49["cap_49_365_13"]
            frame_30[371] = frame_30[100]
            frame_30[372] = frame_30[108]
            frame_30[373] = frame_30[105]
            frame_30[374] = frame_49[31]
            frame_30[375] = frame_30[370](frame_30[371], frame_30[372], frame_30[373], frame_30[374])
            frame_30[108] = frame_30[375]
            frame_30[376] = _T.DropshipNextEventTime
            frame_30[377] = IsNull
            frame_30[378] = frame_30[377](frame_30[376])
            if frame_30[378] then
                cfg_30 = 77
            else
                cfg_30 = 75
            end
        elseif cfg_30 == 75 then
            frame_30[379] = gGameRules
            frame_30[380] = frame_49["cap_49_365_31"]
            frame_30[384] = (frame_30[379]):GetNetPersistentVar(frame_30[380], 0)
            frame_30[385] = (frame_30[100] - frame_30[384])
            if not (150 < frame_30[385]) then
                cfg_30 = 77
            else
                cfg_30 = 76
            end
        elseif cfg_30 == 76 then
            frame_30[387] = _T
            frame_30[388] = _T.DropshipNextEventTime
            frame_30[389] = (frame_30[388] + frame_30[108])
            frame_30[387].DropshipNextEventTime = frame_30[389]
            cfg_30 = 77
        elseif cfg_30 == 77 then
            frame_30[390] = frame_49[212]
            if not (frame_30[390]) then
                cfg_30 = 80
            else
                cfg_30 = 78
            end
        elseif cfg_30 == 78 then
            frame_30[391] = _T.extractionAvailable
            if not (frame_30[391]) then
                cfg_30 = 80
            else
                cfg_30 = 79
            end
        elseif cfg_30 == 79 then
            return
        elseif cfg_30 == 80 then
            frame_30[392] = Sleep
            frame_30[393] = frame_30[108]
            frame_30[392](frame_30[393])
            frame_30[394] = gGameRules
            frame_30[395] = frame_49["cap_49_365_8"]
            frame_30[398] = (frame_30[394]):GetNetPersistentVar(frame_30[395])
            frame_30[94] = frame_30[398]
            frame_30[399] = gGameRules
            frame_30[400] = frame_49["cap_49_365_14"]
            frame_30[403] = (frame_30[399]):GetMissionTimeLeft(frame_30[400])
            frame_30[100] = frame_30[403]
            if not (0 <= frame_30[100]) then
                cfg_30 = 82
            else
                cfg_30 = 81
            end
        elseif cfg_30 == 81 then
            frame_30[405] = gGameRules
            frame_30[406] = frame_49["cap_49_365_9"]
            frame_30[407] = frame_30[100]
            frame_30[408] = math.ceil
            frame_30[409] = frame_30[408](frame_30[407])
            do (frame_30[405]):SetNetPersistentVar(frame_30[406], frame_30[409]) end
            cfg_30 = 82
        elseif cfg_30 == 82 then
            frame_30[412] = _T.LastActivityTime
            frame_30[413] = (frame_30[100] - frame_30[412])
            if not (180 < frame_30[413]) then
                cfg_30 = 85
            else
                cfg_30 = 83
            end
        elseif cfg_30 == 83 then
            frame_30[415] = frame_49[71]
            if frame_30[415] then
                cfg_30 = 87
            else
                cfg_30 = 84
            end
        elseif cfg_30 == 84 then
            frame_49[71] = true
            frame_30[417] = gGameRules
            frame_30[418] = frame_49["cap_49_365_12"]
            do (frame_30[417]):SetNetPersistentVar(frame_30[418], 1) end
            cfg_30 = 87
        elseif cfg_30 == 85 then
            frame_30[422] = frame_49[71]
            if not (frame_30[422]) then
                cfg_30 = 87
            else
                cfg_30 = 86
            end
        elseif cfg_30 == 86 then
            frame_49[71] = false
            frame_30[424] = gGameRules
            frame_30[425] = frame_49["cap_49_365_12"]
            do (frame_30[424]):SetNetPersistentVar(frame_30[425], 0) end
            cfg_30 = 87
        elseif cfg_30 == 87 then
            cfg_30 = 19
        elseif cfg_30 == 88 then
            return
        else
            error("invalid control state")
        end
    end
end
frame_49["cap_49_398_0"] = frame_49[77]
frame_49["cap_49_398_1"] = frame_49[89]
frame_49[264] = function()
    local v31_0
    local v31_1
    local v31_2
    local v31_3
    local v31_4
    local v31_5
    local v31_6
    local v31_7
    local v31_8
    local v31_9
    local v31_10
    local v31_11
    local v31_12
    local v31_13
    local v31_14
    local v31_15
    local v31_16
    local v31_17
    local v31_18
    local v31_19
    local v31_20
    local v31_21
    local v31_22
    local v31_23
    local v31_24
    local v31_25
    local v31_26
    local v31_27
    local v31_28
    local v31_29
    local v31_30
    local v31_31
    local v31_32
    local v31_33
    local v31_34
    local v31_35
    local v31_36
    local v31_37
    local v31_38
    local v31_39
    local v31_40
    local v31_41
    local v31_42
    local v31_43
    local v31_44
    local v31_45
    local v31_46
    local v31_47
    local v31_48
    local v31_49
    local v31_50
    local v31_51
    local v31_52
    local v31_53
    local v31_54
    local v31_55
    local v31_56
    local v31_57
    local v31_58
    v31_0 = nil
    while true do
        v31_1 = v31_0
        v31_2 = IsNull
        v31_3 = v31_2(v31_1)
        if not (v31_3) then break end
        v31_4 = gRegion
        v31_7 = v31_4:GetLocalPlayerAvatar()
        v31_0 = v31_7
        v31_8 = Sleep
        v31_8(0)
    end
    v31_10 = gRegion
    v31_11 = frame_49["cap_49_398_0"]
    v31_14 = v31_10:FindTagged(v31_11)
    v31_15 = nil
    v31_16 = (#v31_14)
    if v31_16 ~= 0 then
        v31_18 = (#v31_14)
        if v31_18 ~= 1 then
            v31_20 = gRegion
            v31_21 = frame_49["cap_49_398_1"]
            v31_24 = v31_20:FindTagged(v31_21)
            v31_25 = {}
            v31_26 = 1
            v31_27 = (#v31_24)
            v31_28 = 1
            for v31_26 = v31_26, v31_27, v31_28 do
                v31_29 = v31_25
                v31_30 = v31_24[v31_26]
                v31_40 = table.insert
                v31_40(v31_29, v31_30:GetPosition())
            end
            v31_41 = 0
            v31_42 = 1
            v31_43 = (#v31_14)
            v31_44 = 1
            for v31_42 = v31_42, v31_43, v31_44 do
                v31_45 = 0
                v31_46 = v31_14[v31_42]
                v31_49 = v31_46:GetPosition()
                v31_50 = 1
                v31_51 = (#v31_25)
                v31_52 = 1
                for v31_50 = v31_50, v31_51, v31_52 do
                    v31_53 = Distance
                    v31_54 = v31_49
                    v31_55 = v31_25[v31_50]
                    v31_56 = v31_53(v31_54, v31_55)
                    v31_45 = (v31_45 + v31_56)
                end
                local predicate_value_31_12 = (v31_15 == nil or v31_45 < v31_41)
                if predicate_value_31_12 then
                    v31_15 = v31_14[v31_42]
                    v31_41 = v31_45
                end
            end
        else
            v31_19 = v31_14[1]
        end
    else
        v31_17 = nil
    end
    v31_57 = _T
    v31_57.ExcavationScanner = nil
    return
end
frame_49["cap_49_401_6"] = frame_49[211]
frame_49["cap_49_401_10"] = frame_49[5]
frame_49[265] = function()
    local v32_0
    local v32_1
    local v32_2
    local v32_3
    local v32_4
    local v32_5
    local v32_6
    local v32_7
    local v32_8
    local v32_9
    local v32_10
    local v32_11
    local v32_12
    local v32_13
    local v32_14
    local v32_15
    local v32_16
    local v32_17
    local v32_18
    local v32_19
    local v32_20
    local v32_21
    local v32_22
    local v32_23
    local v32_24
    local v32_25
    local v32_26
    local v32_27
    local v32_28
    local v32_29
    local v32_30
    local v32_31
    local v32_32
    local v32_33
    local v32_34
    local v32_35
    local v32_36
    local v32_37
    local v32_38
    local v32_39
    local v32_40
    local v32_41
    local v32_42
    local v32_43
    local v32_44
    local v32_45
    local v32_46
    local v32_47
    local v32_48
    local v32_49
    local v32_50
    local v32_51
    local v32_52
    local v32_53
    local v32_54
    local v32_55
    local v32_56
    local v32_57
    local v32_58
    local v32_59
    local v32_60
    local v32_61
    local v32_62
    local v32_63
    local v32_64
    local v32_65
    local v32_66
    local v32_67
    local v32_68
    local v32_69
    local v32_70
    local v32_71
    local v32_72
    local v32_73
    while true do
        v32_0 = gGameRules
        v32_1 = IsNull
        v32_2 = v32_1(v32_0)
        if not (v32_2) then break end
        v32_3 = Sleep
        v32_3(0)
    end
    v32_5 = _T
    v32_5.extractionAvailable = false
    v32_7 = gGameRules
    v32_10 = v32_7:GetMission()
    v32_11 = (v32_10).levelOverride
    v32_12 = IsNull
    v32_13 = v32_12(v32_11)
    local bridge_32_2
    if v32_13 then
        bridge_32_2 = true
    else
        v32_14 = (v32_10).goalId
        bridge_32_2 = not (v32_14 ~= "")
    end
    if bridge_32_2 then
        frame_49[205] = false
    end
    v32_16 = string.find
    v32_17 = (v32_10).activeMissionTag
    v32_18 = tostring
    v32_19 = v32_18(v32_17)
    v32_21 = v32_16(v32_19, "Void")
    frame_49[207] = v32_21
    v32_22 = string.find
    v32_23 = (v32_10).levelOverride
    v32_28 = tostring
    v32_29 = v32_28(v32_23:GetFullName())
    v32_31 = v32_22(v32_29, "Duviri")
    if v32_31 ~= nil then
        v32_32 = true
    else
        v32_32 = false
    end
    frame_49[212] = v32_32
    v32_33 = (v32_10).alertId
    local sc_32_8
    if v32_33 ~= "" then
        sc_32_8 = true
    else
        v32_34 = (v32_10).invasionId
        if v32_34 ~= "" then
            sc_32_8 = true
        else
            v32_35 = (v32_10).syndicateTag
            v32_38 = v32_35:IsValid()
            if v32_38 then
                sc_32_8 = true
            else
                v32_39 = (v32_10).sortieId
                if v32_39 ~= "" then
                    sc_32_8 = true
                else
                    v32_40 = (v32_10).nightmare
                    if v32_40 then
                        sc_32_8 = true
                    else
                        v32_41 = (v32_10).maxWaveNum
                        if 0 < v32_41 then
                            sc_32_8 = true
                        else
                            v32_43 = frame_49[212]
                            sc_32_8 = v32_43
                        end
                    end
                end
            end
        end
    end
    if sc_32_8 then
        frame_49[206] = true
        frame_49[67] = 600
        frame_49[66] = 600
    end
    v32_47 = (v32_10).goalTag
    v32_48 = Symbol
    v32_50 = v32_48("OldWorldSalvage")
    if not (v32_47 ~= v32_50) then
        v32_51 = (v32_10).location
        v32_52 = frame_49["cap_49_401_6"]
        if v32_51 ~= v32_52 then
        else
            frame_49[208] = true
            frame_49[70] = 10
            frame_49[69] = 60
            return
        end
    end
    v32_56 = true
    v32_57 = gGameRules
    v32_60 = v32_57:GetMission()
    v32_61 = (v32_60).periodicMissionTag
    v32_62 = frame_49["cap_49_401_10"]
    v32_63 = (v32_62).ELITE_ALERT_PERIODIC_MISSION_TAG
    if not (v32_61 == v32_63) then
        v32_64 = gGameRules
        v32_67 = v32_64:GetMission()
        v32_68 = (v32_67).periodicMissionTag
        v32_69 = frame_49["cap_49_401_10"]
        v32_70 = (v32_69).ELITE_ALERT_PERIODIC_MISSION_TAG_ALT
        if v32_68 == v32_70 then
            v32_56 = true
        else
            v32_56 = false
        end
    end
    if not (v32_56) then
        v32_72 = frame_49[212]
        if v32_72 then
            frame_49[213] = 3
        end
        return
    else
        frame_49[69] = 140
        return
    end
end
frame_49["cap_49_414_0"] = frame_49[14]
frame_49["cap_49_414_1"] = frame_49[26]
frame_49["cap_49_414_2"] = frame_49[104]
frame_49["cap_49_414_3"] = frame_49[107]
frame_49["cap_49_414_4"] = frame_49[110]
frame_49["cap_49_414_5"] = frame_49[116]
frame_49["cap_49_414_6"] = frame_49[119]
frame_49["cap_49_414_7"] = frame_49[122]
frame_49["cap_49_414_8"] = frame_49[125]
frame_49["cap_49_414_9"] = frame_49[128]
frame_49["cap_49_414_10"] = frame_49[131]
frame_49["cap_49_414_11"] = frame_49[134]
frame_49["cap_49_414_12"] = frame_49[137]
frame_49["cap_49_414_13"] = frame_49[140]
frame_49["cap_49_414_14"] = frame_49[143]
frame_49["cap_49_414_15"] = frame_49[146]
frame_49["cap_49_414_16"] = frame_49[149]
frame_49["cap_49_414_17"] = frame_49[152]
frame_49["cap_49_414_18"] = frame_49[113]
frame_49[266] = function()
    local v33_0
    local v33_1
    local v33_2
    local v33_3
    local v33_4
    local v33_5
    local v33_6
    local v33_7
    local v33_8
    local v33_9
    local v33_10
    local v33_11
    local v33_12
    local v33_13
    local v33_14
    local v33_15
    local v33_16
    local v33_17
    local v33_18
    local v33_19
    local v33_20
    local v33_21
    local v33_22
    local v33_23
    local v33_24
    local v33_25
    local v33_26
    local v33_27
    local v33_28
    local v33_29
    local v33_30
    local v33_31
    local v33_32
    local v33_33
    local v33_34
    local v33_35
    local v33_36
    local v33_37
    local v33_38
    local v33_39
    local v33_40
    local v33_41
    local v33_42
    local v33_43
    local v33_44
    local v33_45
    local v33_46
    local v33_47
    local v33_48
    local v33_49
    local v33_50
    local v33_51
    local v33_52
    local v33_53
    local v33_54
    local v33_55
    local v33_56
    local v33_57
    local v33_58
    local v33_59
    local v33_60
    local v33_61
    local v33_62
    local v33_63
    local v33_64
    local v33_65
    local v33_66
    local v33_67
    local v33_68
    local v33_69
    local v33_70
    local v33_71
    local v33_72
    local v33_73
    local v33_74
    local v33_75
    local v33_76
    local v33_77
    local v33_78
    local v33_79
    local v33_80
    local v33_81
    local v33_82
    local v33_83
    local v33_84
    local v33_85
    local v33_86
    local v33_87
    local v33_88
    local v33_89
    local v33_90
    local v33_91
    local v33_92
    local v33_93
    local v33_94
    v33_0 = frame_49["cap_49_414_0"]
    v33_1 = (v33_0).ClearPrimaryObjText
    v33_1()
    v33_2 = frame_49["cap_49_414_0"]
    v33_3 = (v33_2).ClearSecondaryObjText
    v33_3()
    v33_4 = frame_49["cap_49_414_0"]
    v33_5 = (v33_4).RemoveObjProgressBar
    v33_5()
    v33_6 = frame_49["cap_49_414_1"]
    v33_7 = (v33_6).ClearGameMode
    v33_7(17)
    v33_9 = gRegion
    v33_12 = v33_9:IsMaster()
    if v33_12 then
        v33_13 = print
        v33_13("duviri excav clearing state")
        v33_15 = gGameRules
        v33_16 = frame_49["cap_49_414_2"]
        v33_15:Name__a835d47c(v33_16)
        v33_19 = gGameRules
        v33_20 = frame_49["cap_49_414_3"]
        v33_19:Name__a835d47c(v33_20)
        v33_23 = gGameRules
        v33_24 = frame_49["cap_49_414_4"]
        v33_23:Name__a835d47c(v33_24)
        v33_27 = gGameRules
        v33_28 = frame_49["cap_49_414_5"]
        v33_27:Name__a835d47c(v33_28)
        v33_31 = gGameRules
        v33_32 = frame_49["cap_49_414_6"]
        v33_31:Name__a835d47c(v33_32)
        v33_35 = gGameRules
        v33_36 = frame_49["cap_49_414_7"]
        v33_35:Name__a835d47c(v33_36)
        v33_39 = gGameRules
        v33_40 = frame_49["cap_49_414_8"]
        v33_39:Name__a835d47c(v33_40)
        v33_43 = gGameRules
        v33_44 = frame_49["cap_49_414_9"]
        v33_43:Name__a835d47c(v33_44)
        v33_47 = gGameRules
        v33_48 = frame_49["cap_49_414_10"]
        v33_47:Name__a835d47c(v33_48)
        v33_51 = gGameRules
        v33_52 = frame_49["cap_49_414_11"]
        v33_51:Name__a835d47c(v33_52)
        v33_55 = gGameRules
        v33_56 = frame_49["cap_49_414_12"]
        v33_55:Name__a835d47c(v33_56)
        v33_59 = gGameRules
        v33_60 = frame_49["cap_49_414_13"]
        v33_59:Name__a835d47c(v33_60)
        v33_63 = gGameRules
        v33_64 = frame_49["cap_49_414_14"]
        v33_63:Name__a835d47c(v33_64)
        v33_67 = gGameRules
        v33_68 = frame_49["cap_49_414_15"]
        v33_67:Name__a835d47c(v33_68)
        v33_71 = gGameRules
        v33_72 = frame_49["cap_49_414_16"]
        v33_71:Name__a835d47c(v33_72)
        v33_75 = gGameRules
        v33_76 = frame_49["cap_49_414_17"]
        v33_75:Name__a835d47c(v33_76)
        v33_79 = gGameRules
        v33_80 = frame_49["cap_49_414_18"]
        v33_79:Name__a835d47c(v33_80)
        v33_83 = _T.ArenaComplete
        if v33_83 then
            v33_84 = _T.ArenaComplete
            v33_84()
        end
        v33_85 = gRegion
        v33_88 = v33_85:GetNpcMgr()
        v33_91 = v33_88:GetAiDirector()
        v33_91:Name__4a133811(nil)
    end
    return
end
frame_49["cap_49_434_0"] = frame_49[8]
frame_49["cap_49_434_2"] = frame_49[104]
frame_49[267] = function()
    local v34_0
    local v34_1
    local v34_2
    local v34_3
    local v34_4
    local v34_5
    local v34_6
    local v34_7
    local v34_8
    local v34_9
    local v34_10
    local v34_11
    local v34_12
    local v34_13
    local v34_14
    local v34_15
    local v34_16
    local v34_17
    local v34_18
    local v34_19
    local v34_20
    local v34_21
    local v34_22
    local v34_23
    local v34_24
    local v34_25
    local v34_26
    local v34_27
    local v34_28
    local v34_29
    local v34_30
    local v34_31
    local v34_32
    local v34_33
    local v34_34
    local v34_35
    local v34_36
    local v34_37
    v34_0 = _T
    v34_0.maxTier = 5
    v34_2 = frame_49["cap_49_434_0"]
    v34_3 = (v34_2).SetupMissionTransmissionSet
    v34_4 = transmissionSet
    v34_3(v34_4)
    v34_5 = gRegion
    v34_6 = Symbol
    v34_15 = v34_5:FindTagged(v34_6("BreakableOnPath"))
    v34_16 = 1
    v34_17 = (#v34_15)
    v34_18 = 1
    for v34_16 = v34_16, v34_17, v34_18 do
        v34_19 = v34_15[v34_16]
        v34_19:FirePort("Destroy")
    end
    v34_23 = frame_49[208]
    if v34_23 then
        v34_24 = frame_49["cap_49_434_0"]
        v34_25 = (v34_24).PlayGlobalTransmission
        v34_26 = _T.MissionTransmissionSet
        v34_27 = Symbol
        v34_25(v34_26, v34_27("MissionIntro"))
    end
    v34_33 = gGameRules
    v34_34 = frame_49["cap_49_434_2"]
    v34_33:SetNetPersistentVar(v34_34, 2)
    return
end
frame_49["cap_49_438_0"] = frame_49[265]
frame_49["cap_49_438_1"] = frame_49[26]
frame_49["cap_49_438_2"] = frame_49[134]
frame_49["cap_49_438_4"] = frame_49[20]
frame_49["cap_49_438_5"] = frame_49[140]
frame_49["cap_49_438_6"] = frame_49[119]
frame_49["cap_49_438_7"] = frame_49[262]
frame_49["cap_49_438_8"] = frame_49[155]
frame_49["cap_49_438_9"] = frame_49[104]
frame_49["cap_49_438_10"] = frame_49[267]
frame_49["cap_49_438_11"] = frame_49[263]
frame_49["cap_49_438_12"] = frame_49[266]
frame_49["cap_49_438_13"] = frame_49[95]
frame_49["cap_49_438_14"] = frame_49[92]
frame_49["cap_49_438_15"] = frame_49[244]
frame_49[268] = function(p35_0)
    local frame_35 = {}
    local cfg_35 = 0
    while true do
        if cfg_35 == 0 then
            frame_35[1] = frame_49["cap_49_438_0"]
            frame_35[1]()
            frame_35[2] = frame_49["cap_49_438_1"]
            frame_35[3] = (frame_35[2]).SetGameMode
            frame_35[5] = ImGuiDebug
            frame_35[3](17, frame_35[5])
            frame_35[6] = _T
            frame_35[7] = gGameRules
            frame_35[10] = (frame_35[7]):GetRewardSeed()
            frame_35[6].gSurvivalRewardSeed = frame_35[10]
            frame_35[11] = gGameRules
            frame_35[12] = frame_49["cap_49_438_2"]
            frame_35[16] = (frame_35[11]):GetNetPersistentVar(frame_35[12], 0)
            if not (0 < frame_35[16]) then
                cfg_35 = 2
            else
                cfg_35 = 1
            end
        elseif cfg_35 == 1 then
            frame_35[18] = GetSeed
            frame_35[19] = frame_35[18]()
            frame_35[20] = Name__dadf7b26
            frame_35[21] = _T.gSurvivalRewardSeed
            frame_35[22] = frame_35[16]
            frame_35[20](frame_35[21], frame_35[22])
            frame_35[23] = _T
            frame_35[24] = GetSeed
            frame_35[25] = frame_35[24]()
            frame_35[23].gSurvivalRewardSeed = frame_35[25]
            frame_35[26] = SetSeed
            frame_35[27] = frame_35[19]
            frame_35[26](frame_35[27])
            cfg_35 = 2
        elseif cfg_35 == 2 then
            frame_35[28] = frame_49[212]
            if not (frame_35[28]) then
                cfg_35 = 5
            else
                cfg_35 = 3
            end
        elseif cfg_35 == 3 then
            frame_35[29] = gRegion
            frame_35[32] = (frame_35[29]):IsMaster()
            if not (frame_35[32]) then
                cfg_35 = 6
            else
                cfg_35 = 4
            end
        elseif cfg_35 == 4 then
            frame_35[33] = frame_49["cap_49_438_4"]
            frame_35[34] = (frame_35[33]).IsGameModeInProgress
            frame_35[32] = frame_35[34]()
            cfg_35 = 6
        elseif cfg_35 == 5 then
            frame_35[32] = gPromotedToHost
            cfg_35 = 6
        elseif cfg_35 == 6 then
            if not (frame_35[32]) then
                cfg_35 = 25
            else
                cfg_35 = 7
            end
        elseif cfg_35 == 7 then
            frame_35[35] = gGameRules
            frame_35[36] = frame_49["cap_49_438_5"]
            frame_35[40] = (frame_35[35]):GetNetPersistentVar(frame_35[36], 0)
            if frame_35[40] == 0 then
                cfg_35 = 12
            else
                cfg_35 = 8
            end
        elseif cfg_35 == 8 then
            frame_35[41] = gFlashMgr
            frame_35[42] = loadingScreen
            frame_35[45] = (frame_35[41]):FindMovie(frame_35[42])
            cfg_35 = 9
        elseif cfg_35 == 9 then
            frame_35[46] = frame_35[45]
            frame_35[47] = IsNull
            frame_35[48] = frame_35[47](frame_35[46])
            if frame_35[48] then
                cfg_35 = 11
            else
                cfg_35 = 10
            end
        elseif cfg_35 == 10 then
            frame_35[49] = Sleep
            frame_35[49](0)
            cfg_35 = 9
        elseif cfg_35 == 11 then
            frame_35[51] = gGameRules
            frame_35[52] = frame_49["cap_49_438_6"]
            frame_35[56] = (frame_35[51]):GetNetPersistentVar(frame_35[52], 0)
            frame_35[57] = frame_49["cap_49_438_7"]
            frame_35[58] = (frame_35[56] / 200)
            frame_35[59] = math.floor
            frame_35[60] = frame_35[59](frame_35[58])
            frame_35[61] = frame_35[40]
            frame_35[57](frame_35[60], frame_35[61])
            cfg_35 = 12
        elseif cfg_35 == 12 then
            frame_35[62] = gGameRules
            frame_35[63] = frame_49["cap_49_438_8"]
            frame_35[67] = (frame_35[62]):GetNetPersistentVar(frame_35[63], 0)
            if frame_35[67] == 1 then
                cfg_35 = 14
            else
                cfg_35 = 13
            end
        elseif cfg_35 == 13 then
            frame_35[68] = false
            cfg_35 = 15
        elseif cfg_35 == 14 then
            frame_35[68] = true
            cfg_35 = 15
        elseif cfg_35 == 15 then
            frame_35[69] = gGameRules
            frame_35[70] = frame_49["cap_49_438_9"]
            frame_35[74] = (frame_35[69]):GetNetPersistentVar(frame_35[70], 0)
            if frame_35[74] == 2 then
                cfg_35 = 17
            else
                cfg_35 = 16
            end
        elseif cfg_35 == 16 then
            frame_35[75] = false
            cfg_35 = 18
        elseif cfg_35 == 17 then
            frame_35[75] = true
            cfg_35 = 18
        elseif cfg_35 == 18 then
            frame_35[76] = frame_49[212]
            if ((not (frame_35[76]) or frame_35[68]) or frame_35[75]) then
                cfg_35 = 22
            else
                cfg_35 = 21
            end
        elseif cfg_35 == 21 then
            frame_35[77] = frame_49["cap_49_438_10"]
            frame_35[77]()
            cfg_35 = 22
        elseif cfg_35 == 22 then
            frame_35[78] = frame_49["cap_49_438_11"]
            frame_35[78]()
            frame_35[79] = frame_49[212]
            if not (frame_35[79]) then
                cfg_35 = 24
            else
                cfg_35 = 23
            end
        elseif cfg_35 == 23 then
            frame_35[80] = frame_49["cap_49_438_12"]
            frame_35[80]()
            cfg_35 = 24
        elseif cfg_35 == 24 then
            return
        elseif cfg_35 == 25 then
            frame_35[81] = gRegion
            frame_35[82] = frame_49["cap_49_438_13"]
            frame_35[85] = (frame_35[81]):FindTagged(frame_35[82])
            frame_35[86] = gRegion
            frame_35[87] = frame_49["cap_49_438_14"]
            frame_35[90] = (frame_35[86]):FindTagged(frame_35[87])
            frame_35[91] = 1
            frame_35[92] = (#frame_35[85])
            frame_35[93] = 1
            local leave_for_35_26 = false
            for for_value_35_26 = frame_35[91], frame_35[92], frame_35[93] do
                frame_35[91] = for_value_35_26
                cfg_35 = 26
                while true do
                    if cfg_35 == 26 then
                        frame_35[94] = frame_35[85][frame_35[91]]
                        frame_35[95] = scannerMesh
                        do (frame_35[94]):SetMesh(frame_35[95], false, false) end
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_35_26 then break end
            end
            if not leave_for_35_26 then
                cfg_35 = 27
            end
        elseif cfg_35 == 27 then
            frame_35[100] = 1
            frame_35[101] = (#frame_35[90])
            frame_35[102] = 1
            local leave_for_35_28 = false
            for for_value_35_28 = frame_35[100], frame_35[101], frame_35[102] do
                frame_35[100] = for_value_35_28
                cfg_35 = 28
                while true do
                    if cfg_35 == 28 then
                        frame_35[103] = frame_35[90][frame_35[100]]
                        frame_35[104] = excavatorMesh
                        do (frame_35[103]):SetMesh(frame_35[104], false, false) end
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_35_28 then break end
            end
            if not leave_for_35_28 then
                cfg_35 = 29
            end
        elseif cfg_35 == 29 then
            frame_35[109] = gRegion
            frame_35[112] = (frame_35[109]):IsMaster()
            if not (frame_35[112]) then
                cfg_35 = 32
            else
                cfg_35 = 30
            end
        elseif cfg_35 == 30 then
            frame_35[113] = frame_49["cap_49_438_10"]
            frame_35[113]()
            frame_35[114] = frame_49["cap_49_438_11"]
            frame_35[114]()
            frame_35[115] = frame_49[212]
            if not (frame_35[115]) then
                cfg_35 = 36
            else
                cfg_35 = 31
            end
        elseif cfg_35 == 31 then
            frame_35[116] = frame_49["cap_49_438_12"]
            frame_35[116]()
            return
        elseif cfg_35 == 32 then
            frame_35[117] = frame_49["cap_49_438_15"]
            frame_35[117]()
            frame_35[118] = gPromotedToHost
            if not (frame_35[118]) then
                cfg_35 = 34
            else
                cfg_35 = 33
            end
        elseif cfg_35 == 33 then
            frame_35[119] = print
            frame_35[119]("Bailing on Excavation because I am now the host!")
            return
        elseif cfg_35 == 34 then
            frame_35[121] = frame_49[212]
            if not (frame_35[121]) then
                cfg_35 = 36
            else
                cfg_35 = 35
            end
        elseif cfg_35 == 35 then
            frame_35[122] = frame_49["cap_49_438_12"]
            frame_35[122]()
            cfg_35 = 36
        elseif cfg_35 == 36 then
            return
        else
            error("invalid control state")
        end
    end
end
Excavation = frame_49[268]
frame_49["cap_49_456_0"] = frame_49[265]
frame_49["cap_49_456_2"] = frame_49[223]
frame_49["cap_49_456_5"] = frame_49[5]
frame_49["cap_49_456_6"] = frame_49[2]
frame_49["cap_49_456_9"] = frame_49[152]
frame_49["cap_49_456_10"] = frame_49[89]
frame_49["cap_49_456_11"] = frame_49[104]
frame_49["cap_49_456_13"] = frame_49[14]
frame_49["cap_49_456_15"] = frame_49[179]
frame_49["cap_49_456_16"] = frame_49[119]
frame_49["cap_49_456_17"] = frame_49[143]
frame_49["cap_49_456_18"] = frame_49[134]
frame_49["cap_49_456_19"] = frame_49[217]
frame_49["cap_49_456_20"] = frame_49[245]
frame_49["cap_49_456_21"] = frame_49[11]
frame_49[269] = function(p36_0)
    local frame_36 = {}
    local cfg_36 = 0
    while true do
        if cfg_36 == 0 then
            frame_36[1] = frame_49["cap_49_456_0"]
            frame_36[1]()
            frame_36[2] = gGameRules
            cfg_36 = 1
        elseif cfg_36 == 1 then
            frame_36[3] = frame_36[2]
            frame_36[4] = IsNull
            frame_36[5] = frame_36[4](frame_36[3])
            if not (frame_36[5]) then
                cfg_36 = 3
            else
                cfg_36 = 2
            end
        elseif cfg_36 == 2 then
            frame_36[2] = gGameRules
            frame_36[6] = Sleep
            frame_36[6](0.1)
            cfg_36 = 1
        elseif cfg_36 == 3 then
            frame_36[8] = frame_49[212]
            if not (frame_36[8]) then
                cfg_36 = 8
            else
                cfg_36 = 4
            end
        elseif cfg_36 == 4 then
            frame_36[9] = gRegion
            frame_36[12] = (frame_36[9]):GetLocalPlayerAvatar()
            cfg_36 = 5
        elseif cfg_36 == 5 then
            frame_36[13] = frame_36[12]
            frame_36[14] = IsNull
            frame_36[15] = frame_36[14](frame_36[13])
            if frame_36[15] then
                cfg_36 = 7
            else
                cfg_36 = 6
            end
        elseif cfg_36 == 6 then
            frame_36[16] = frame_49["cap_49_456_2"]
            frame_36[19] = (frame_36[12]):IsA(frame_36[16])
            if not (frame_36[19]) then
                cfg_36 = 8
            else
                cfg_36 = 7
            end
        elseif cfg_36 == 7 then
            frame_36[20] = Sleep
            frame_36[20](0)
            frame_36[22] = gRegion
            frame_36[25] = (frame_36[22]):GetLocalPlayerAvatar()
            frame_36[12] = frame_36[25]
            cfg_36 = 5
        elseif cfg_36 == 8 then
            frame_36[26] = frame_36[2]
            frame_36[27] = IsNull
            frame_36[28] = frame_36[27](frame_36[26])
            if not (frame_36[28]) then
                cfg_36 = 10
            else
                cfg_36 = 9
            end
        elseif cfg_36 == 9 then
            return
        elseif cfg_36 == 10 then
            frame_36[31] = (frame_36[2]):Name__fd0086f7()
            cfg_36 = 11
        elseif cfg_36 == 11 then
            frame_36[32] = frame_36[31]
            frame_36[33] = IsNull
            frame_36[34] = frame_36[33](frame_36[32])
            if not (frame_36[34]) then
                cfg_36 = 15
            else
                cfg_36 = 12
            end
        elseif cfg_36 == 12 then
            frame_36[35] = frame_36[2]
            frame_36[36] = IsNull
            frame_36[37] = frame_36[36](frame_36[35])
            if not (frame_36[37]) then
                cfg_36 = 14
            else
                cfg_36 = 13
            end
        elseif cfg_36 == 13 then
            return
        elseif cfg_36 == 14 then
            frame_36[40] = (frame_36[2]):Name__fd0086f7()
            frame_36[31] = frame_36[40]
            frame_36[41] = Sleep
            frame_36[41](0.1)
            cfg_36 = 11
        elseif cfg_36 == 15 then
            frame_36[43] = false
            frame_36[48] = (frame_36[31]):GetLocalized("/Lotus/Language/Game/ExcavatorObject", false)
            frame_36[49] = {}
            frame_36[49][1] = "<MISSION_MARKER_A>"
            frame_36[49][2] = "<MISSION_MARKER_B>"
            frame_36[49][3] = "<MISSION_MARKER_C>"
            frame_36[49][4] = "<MISSION_MARKER_D>"
            frame_36[49][5] = "<MISSION_MARKER_E>"
            frame_36[49][6] = "<MISSION_MARKER_F>"
            frame_36[57] = frame_36[49]
            local leave_for_36_17 = false
            for for_value_36_17_0, for_value_36_17_1 in ipairs(frame_36[57]) do
                frame_36[70], frame_36[71] = for_value_36_17_0, for_value_36_17_1
                cfg_36 = 16
                while true do
                    if cfg_36 == 16 then
                        frame_36[61] = frame_36[71]
                        frame_36[65] = (frame_36[31]):GetLocalized(frame_36[61], true)
                        frame_36[66] = frame_36[65]
                        frame_36[68] = frame_36[48]
                        frame_36[69] = (frame_36[66] .. " " .. frame_36[68])
                        frame_36[49][frame_36[70]] = frame_36[69]
                        cfg_36 = 17
                    elseif cfg_36 == 17 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_36_17 then break end
            end
            if not leave_for_36_17 then
                cfg_36 = 18
            end
        elseif cfg_36 == 18 then
            frame_36[72] = (#frame_36[49])
            frame_36[73] = 500
            frame_36[74] = gGameRules
            frame_36[77] = (frame_36[74]):GetMission()
            frame_36[78] = frame_49[213]
            if frame_36[78] then
                cfg_36 = 20
            else
                cfg_36 = 19
            end
        elseif cfg_36 == 19 then
            frame_36[78] = (frame_36[77]).maxWaveNum
            cfg_36 = 20
        elseif cfg_36 == 20 then
            if not (0 < frame_36[78]) then
                cfg_36 = 22
            else
                cfg_36 = 21
            end
        elseif cfg_36 == 21 then
            frame_36[80] = frame_49[70]
            frame_36[73] = (frame_36[78] * frame_36[80])
            cfg_36 = 22
        elseif cfg_36 == 22 then
            frame_36[81] = true
            frame_36[82] = gGameRules
            frame_36[85] = (frame_36[82]):GetMission()
            frame_36[86] = (frame_36[85]).periodicMissionTag
            frame_36[87] = frame_49["cap_49_456_5"]
            frame_36[88] = (frame_36[87]).ELITE_ALERT_PERIODIC_MISSION_TAG
            if frame_36[86] == frame_36[88] then
                cfg_36 = 26
            else
                cfg_36 = 23
            end
        elseif cfg_36 == 23 then
            frame_36[89] = gGameRules
            frame_36[92] = (frame_36[89]):GetMission()
            frame_36[93] = (frame_36[92]).periodicMissionTag
            frame_36[94] = frame_49["cap_49_456_5"]
            frame_36[95] = (frame_36[94]).ELITE_ALERT_PERIODIC_MISSION_TAG_ALT
            if frame_36[93] == frame_36[95] then
                cfg_36 = 25
            else
                cfg_36 = 24
            end
        elseif cfg_36 == 24 then
            frame_36[81] = false
            cfg_36 = 26
        elseif cfg_36 == 25 then
            frame_36[81] = true
            cfg_36 = 26
        elseif cfg_36 == 26 then
            if not (frame_36[81]) then
                cfg_36 = 28
            else
                cfg_36 = 27
            end
        elseif cfg_36 == 27 then
            frame_36[73] = (frame_36[73] * 2)
            cfg_36 = 28
        elseif cfg_36 == 28 then
            frame_36[96] = frame_49["cap_49_456_6"]
            frame_36[97] = (frame_36[96]).Ternary
            frame_36[98] = frame_49[208]
            frame_36[101] = frame_36[97](frame_36[98], "/Lotus/Language/Game/OldWorldCompletedExcavations", "/Lotus/Language/Game/ExcavationsRemaining")
            frame_36[102] = frame_49["cap_49_456_6"]
            frame_36[103] = (frame_36[102]).Ternary
            frame_36[104] = frame_49[206]
            frame_36[105] = frame_36[101]
            frame_36[107] = frame_36[103](frame_36[104], frame_36[105], "/Lotus/Language/Game/CompletedExcavations")
            frame_36[111] = (frame_36[31]):GetLocalized(frame_36[107], true)
            frame_36[116] = (frame_36[31]):GetLocalized("/Lotus/Language/Objectives/ExcavPowerFull", true)
            frame_36[122] = (frame_36[31]):GetLocalized("/Lotus/Language/Game/ExcavationHalted", true)
            frame_36[123] = ("0% " .. frame_36[122])
            frame_36[124] = nil
            frame_36[125] = gGameRules
            frame_36[126] = frame_49["cap_49_456_9"]
            frame_36[130] = (frame_36[125]):GetNetPersistentVar(frame_36[126], 1)
            cfg_36 = 29
        elseif cfg_36 == 29 then
            frame_36[131] = gRegion
            frame_36[134] = (frame_36[131]):IsMaster()
            if (frame_36[134] or frame_36[130] ~= 1) then
                cfg_36 = 32
            else
                cfg_36 = 31
            end
        elseif cfg_36 == 31 then
            frame_36[135] = Sleep
            frame_36[135](0.1)
            frame_36[137] = gGameRules
            frame_36[138] = frame_49["cap_49_456_9"]
            frame_36[142] = (frame_36[137]):GetNetPersistentVar(frame_36[138], 1)
            frame_36[130] = frame_36[142]
            cfg_36 = 29
        elseif cfg_36 == 32 then
            frame_36[143] = (#frame_36[124])
            if not (frame_36[143] < frame_36[130]) then
                cfg_36 = 37
            else
                cfg_36 = 33
            end
        elseif cfg_36 == 33 then
            frame_36[144] = gRegion
            frame_36[145] = frame_49["cap_49_456_10"]
            frame_36[148] = (frame_36[144]):FindTagged(frame_36[145])
            frame_36[124] = frame_36[148]
            frame_36[149] = frame_49[212]
            if not (frame_36[149]) then
                cfg_36 = 36
            else
                cfg_36 = 34
            end
        elseif cfg_36 == 34 then
            frame_36[150] = _T.FilterEntitiesToCurrentLayer
            if not (frame_36[150]) then
                cfg_36 = 36
            else
                cfg_36 = 35
            end
        elseif cfg_36 == 35 then
            frame_36[151] = _T.FilterEntitiesToCurrentLayer
            frame_36[152] = frame_36[124]
            frame_36[153] = frame_36[151](frame_36[152])
            frame_36[124] = frame_36[153]
            cfg_36 = 36
        elseif cfg_36 == 36 then
            frame_36[154] = Sleep
            frame_36[154](0.1)
            cfg_36 = 32
        elseif cfg_36 == 37 then
            frame_36[156] = gRegion
            frame_36[159] = (frame_36[156]):IsMaster()
            if not (frame_36[159]) then
                cfg_36 = 39
            else
                cfg_36 = 38
            end
        elseif cfg_36 == 38 then
            frame_36[160] = gGameRules
            frame_36[161] = frame_49["cap_49_456_9"]
            frame_36[162] = (#frame_36[124])
            do (frame_36[160]):SetNetPersistentVar(frame_36[161], frame_36[162]) end
            cfg_36 = 39
        elseif cfg_36 == 39 then
            frame_36[165] = print
            frame_36[167] = (#frame_36[124])
            frame_36[168] = ("Num excav states found: " .. frame_36[167])
            frame_36[165](frame_36[168])
            frame_36[169] = nil
            frame_36[170] = gGameRules
            frame_36[171] = frame_49["cap_49_456_11"]
            frame_36[174] = (frame_36[170]):GetNetPersistentVar(frame_36[171])
            frame_36[175] = print
            frame_36[177] = frame_36[174]
            frame_36[178] = tostring
            frame_36[179] = frame_36[178](frame_36[177])
            frame_36[180] = ("HUD: state=" .. frame_36[179])
            frame_36[175](frame_36[180])
            cfg_36 = 40
        elseif cfg_36 == 40 then
            frame_36[181] = frame_36[31]
            frame_36[182] = IsNull
            frame_36[183] = frame_36[182](frame_36[181])
            if not (frame_36[183]) then
                cfg_36 = 44
            else
                cfg_36 = 41
            end
        elseif cfg_36 == 41 then
            frame_36[184] = frame_36[2]
            frame_36[185] = IsNull
            frame_36[186] = frame_36[185](frame_36[184])
            if not (frame_36[186]) then
                cfg_36 = 43
            else
                cfg_36 = 42
            end
        elseif cfg_36 == 42 then
            return
        elseif cfg_36 == 43 then
            frame_36[189] = (frame_36[2]):Name__fd0086f7()
            frame_36[31] = frame_36[189]
            frame_36[190] = Sleep
            frame_36[190](0.1)
            cfg_36 = 40
        elseif cfg_36 == 44 then
            frame_36[193] = frame_36[111]
            frame_36[195] = ("<p><font face=\"Noto Sans\">" .. frame_36[193] .. "</font></p><p><font face=\"Noto Sans\" size=\"24\"><b> %s</b></font></p> ")
            frame_36[197] = string.format
            frame_36[200] = frame_36[197]("<Color%u>", 42)
            frame_36[201] = "<p><font face=\"Noto Sans\"><b>%s</b> </font>"
            frame_36[203] = string.format
            frame_36[206] = frame_36[203]("<Color%u>", 56)
            frame_36[207] = frame_36[206]
            frame_36[209] = string.format
            frame_36[212] = frame_36[209]("<Color%u>", 24)
            frame_36[213] = frame_36[212]
            frame_36[215] = (frame_36[201] .. "<font color=\"" .. frame_36[207] .. "\"><b> %s</b></font><font color=\"" .. frame_36[213] .. "\"><b> %s</b></font>")
            frame_36[216] = frame_36[215]
            frame_36[218] = frame_36[200]
            frame_36[224] = (frame_36[31]):GetLocalized("/Lotus/Language/Game/ExcavationTime", true)
            frame_36[225] = frame_36[224]
            frame_36[227] = frame_36[200]
            frame_36[229] = (frame_36[216] .. "<font color=\"" .. frame_36[218] .. "\"><br>      " .. frame_36[225] .. "</font><font color=\"" .. frame_36[227] .. "\"><b> %s</b></font>")
            frame_36[230] = frame_36[229]
            frame_36[232] = frame_36[200]
            frame_36[238] = (frame_36[31]):GetLocalized("/Lotus/Language/Game/ExcavationPower", true)
            frame_36[239] = frame_36[238]
            frame_36[241] = (frame_36[230] .. "<font color=\"" .. frame_36[232] .. "\">  " .. frame_36[239] .. "</font>%s")
            frame_36[242] = frame_36[241]
            frame_36[244] = (frame_36[242] .. "</p>")
            frame_36[245] = frame_49[207]
            if not (frame_36[245]) then
                cfg_36 = 45
            else
                cfg_36 = 45
            end
        elseif cfg_36 == 45 then
            frame_36[246] = frame_49[207]
            if not (frame_36[246]) then
                cfg_36 = 47
            else
                cfg_36 = 46
            end
        elseif cfg_36 == 46 then
            frame_36[247] = frame_49["cap_49_456_13"]
            frame_36[248] = (frame_36[247]).SetObjProgressBar
            frame_36[248]("/Lotus/Language/Objectives/ExcavNextRelicTitle", 0, 200, nil, false, "/Lotus/Language/Objectives/ExcavNextRelicCryotic")
            cfg_36 = 49
        elseif cfg_36 == 47 then
            frame_36[255] = frame_49[206]
            if not (frame_36[255]) then
                cfg_36 = 49
            else
                cfg_36 = 48
            end
        elseif cfg_36 == 48 then
            frame_36[256] = frame_49["cap_49_456_13"]
            frame_36[257] = (frame_36[256]).SetObjProgressBar
            frame_36[260] = frame_36[73]
            frame_36[257]("/Lotus/Language/Game/CompletedExcavations", 0, frame_36[260])
            cfg_36 = 49
        elseif cfg_36 == 49 then
            frame_36[261] = frame_49[208]
            if not (frame_36[261]) then
                cfg_36 = 51
            else
                cfg_36 = 50
            end
        elseif cfg_36 == 50 then
            cfg_36 = 51
        elseif cfg_36 == 51 then
            frame_36[262] = {}
            frame_36[263] = frame_49[208]
            if frame_36[263] then
                cfg_36 = 52
            else
                cfg_36 = 52
            end
        elseif cfg_36 == 52 then
            if frame_36[174] ~= 0 then
                cfg_36 = 56
            else
                cfg_36 = 53
            end
        elseif cfg_36 == 53 then
            frame_36[264] = frame_36[2]
            frame_36[265] = IsNull
            frame_36[266] = frame_36[265](frame_36[264])
            if not (frame_36[266]) then
                cfg_36 = 55
            else
                cfg_36 = 54
            end
        elseif cfg_36 == 54 then
            return
        elseif cfg_36 == 55 then
            frame_36[267] = frame_49["cap_49_456_11"]
            frame_36[270] = (frame_36[2]):GetNetPersistentVar(frame_36[267])
            frame_36[174] = frame_36[270]
            frame_36[271] = Sleep
            frame_36[271](0)
            cfg_36 = 52
        elseif cfg_36 == 56 then
            frame_36[273] = frame_49[208]
            if frame_36[273] then
                cfg_36 = 57
            else
                cfg_36 = 57
            end
        elseif cfg_36 == 57 then
            if frame_36[174] ~= 1 then
                cfg_36 = 61
            else
                cfg_36 = 58
            end
        elseif cfg_36 == 58 then
            frame_36[274] = frame_36[2]
            frame_36[275] = IsNull
            frame_36[276] = frame_36[275](frame_36[274])
            if not (frame_36[276]) then
                cfg_36 = 60
            else
                cfg_36 = 59
            end
        elseif cfg_36 == 59 then
            return
        elseif cfg_36 == 60 then
            frame_36[277] = frame_49["cap_49_456_11"]
            frame_36[280] = (frame_36[2]):GetNetPersistentVar(frame_36[277])
            frame_36[174] = frame_36[280]
            frame_36[281] = Sleep
            frame_36[281](0)
            cfg_36 = 57
        elseif cfg_36 == 61 then
            frame_36[283] = frame_49["cap_49_456_13"]
            frame_36[284] = (frame_36[283]).SetTitleObjText
            frame_36[284]("/Lotus/Language/Missions/MissionName_Excavation")
            frame_36[286] = frame_49[208]
            if frame_36[286] then
                cfg_36 = 66
            else
                cfg_36 = 62
            end
        elseif cfg_36 == 62 then
            frame_36[287] = Engine.IsMobile
            frame_36[288] = frame_36[287]()
            if not (frame_36[288]) then
                cfg_36 = 65
            else
                cfg_36 = 63
            end
        elseif cfg_36 == 63 then
            frame_36[289] = frame_49[207]
            frame_36[290] = IsNull
            frame_36[291] = frame_36[290](frame_36[289])
            if not (frame_36[291]) then
                cfg_36 = 65
            else
                cfg_36 = 64
            end
        elseif cfg_36 == 64 then
            frame_36[292] = frame_49["cap_49_456_13"]
            frame_36[293] = (frame_36[292]).SetPrimaryObjText
            frame_36[296] = frame_36[293]("/Lotus/Language/Game/ExcavationLocateAndProtect", 1)
            frame_36[297] = (frame_36[296]).SetOffset
            frame_36[297](0, 10, true)
            cfg_36 = 66
        elseif cfg_36 == 65 then
            frame_36[301] = frame_49["cap_49_456_13"]
            frame_36[302] = (frame_36[301]).SetPrimaryObjText
            frame_36[302]("/Lotus/Language/Game/ExcavationLocateAndProtect", 1)
            cfg_36 = 66
        elseif cfg_36 == 66 then
            frame_36[305] = frame_36[31]
            frame_36[306] = IsNull
            frame_36[307] = frame_36[306](frame_36[305])
            if (not (frame_36[307]) or frame_36[174] ~= 2) then
                cfg_36 = 71
            else
                cfg_36 = 68
            end
        elseif cfg_36 == 68 then
            frame_36[308] = frame_36[2]
            frame_36[309] = IsNull
            frame_36[310] = frame_36[309](frame_36[308])
            if not (frame_36[310]) then
                cfg_36 = 70
            else
                cfg_36 = 69
            end
        elseif cfg_36 == 69 then
            return
        elseif cfg_36 == 70 then
            frame_36[313] = (frame_36[2]):Name__fd0086f7()
            frame_36[31] = frame_36[313]
            frame_36[314] = frame_49["cap_49_456_11"]
            frame_36[317] = (frame_36[2]):GetNetPersistentVar(frame_36[314])
            frame_36[174] = frame_36[317]
            frame_36[318] = Sleep
            frame_36[318](0)
            cfg_36 = 66
        elseif cfg_36 == 71 then
            frame_36[320] = frame_49[212]
            if frame_36[320] then
                cfg_36 = 73
            else
                cfg_36 = 72
            end
        elseif cfg_36 == 72 then
            frame_36[321] = gRegion
            frame_36[322] = frame_49["cap_49_456_15"]
            frame_36[325] = (frame_36[321]):FindFirstTagged(frame_36[322])
            frame_49[214] = frame_36[325]
            cfg_36 = 73
        elseif cfg_36 == 73 then
            frame_36[326] = true
            frame_36[327] = gPlayerProfileMgr
            frame_36[331] = (frame_36[327]):GetPlayerProfile(0)
            frame_36[332] = frame_36[331]
            frame_36[333] = IsNull
            frame_36[334] = frame_36[333](frame_36[332])
            if frame_36[334] then
                cfg_36 = 76
            else
                cfg_36 = 74
            end
        elseif cfg_36 == 74 then
            frame_36[337] = (frame_36[331]):Settings()
            frame_36[340] = (frame_36[337]):EnableTutorialTransmissions()
            if frame_36[340] then
                cfg_36 = 76
            else
                cfg_36 = 75
            end
        elseif cfg_36 == 75 then
            frame_36[326] = false
            cfg_36 = 76
        elseif cfg_36 == 76 then
            if not (frame_36[326]) then
                cfg_36 = 78
            else
                cfg_36 = 77
            end
        elseif cfg_36 == 77 then
            frame_36[341] = -7.5
            cfg_36 = 79
        elseif cfg_36 == 78 then
            frame_36[341] = 0
            cfg_36 = 79
        elseif cfg_36 == 79 then
            frame_36[342] = nil
            if not (frame_36[326]) then
                cfg_36 = 81
            else
                cfg_36 = 80
            end
        elseif cfg_36 == 80 then
            frame_36[343] = _T.AddHudTracker
            frame_36[345] = frame_49["cap_49_456_5"]
            frame_36[346] = (frame_36[345]).HT_LABEL
            frame_36[348] = frame_49["cap_49_456_13"]
            frame_36[349] = (frame_36[348]).GetPriorityOffset
            frame_36[350] = frame_36[349]()
            frame_36[351] = (frame_36[350] + 5)
            frame_36[353] = frame_36[343]("PowerHint", frame_36[346], 0.15, frame_36[351], true)
            frame_36[342] = frame_36[353]
            frame_36[354] = (frame_36[342]).SetOffset
            frame_36[354](0, -7.5)
            frame_36[357] = (frame_36[342]).SetLabel
            frame_36[357]("")
            cfg_36 = 81
        elseif cfg_36 == 81 then
            frame_36[359] = 0
            cfg_36 = 82
        elseif cfg_36 == 82 then
            if frame_36[174] ~= 2 then
                cfg_36 = 164
            else
                cfg_36 = 83
            end
        elseif cfg_36 == 83 then
            frame_36[360] = frame_36[2]
            frame_36[361] = IsNull
            frame_36[362] = frame_36[361](frame_36[360])
            if not (frame_36[362]) then
                cfg_36 = 85
            else
                cfg_36 = 84
            end
        elseif cfg_36 == 84 then
            return
        elseif cfg_36 == 85 then
            frame_36[363] = frame_49["cap_49_456_11"]
            frame_36[366] = (frame_36[2]):GetNetPersistentVar(frame_36[363])
            frame_36[174] = frame_36[366]
            frame_36[367] = frame_49["cap_49_456_16"]
            frame_36[371] = (frame_36[2]):GetNetPersistentVar(frame_36[367], 0)
            if frame_36[169] == frame_36[371] then
                cfg_36 = 103
            else
                cfg_36 = 86
            end
        elseif cfg_36 == 86 then
            frame_36[169] = frame_36[371]
            frame_36[372] = frame_49[206]
            if not (frame_36[372]) then
                cfg_36 = 89
            else
                cfg_36 = 87
            end
        elseif cfg_36 == 87 then
            frame_36[373] = frame_49[208]
            if frame_36[373] then
                cfg_36 = 89
            else
                cfg_36 = 88
            end
        elseif cfg_36 == 88 then
            frame_36[374] = frame_49["cap_49_456_13"]
            frame_36[375] = (frame_36[374]).UpdateObjProgressBar
            frame_36[376] = frame_36[371]
            frame_36[377] = frame_36[73]
            frame_36[375](frame_36[376], frame_36[377])
            cfg_36 = 103
        elseif cfg_36 == 89 then
            frame_36[378] = frame_49[207]
            if not (frame_36[378]) then
                cfg_36 = 91
            else
                cfg_36 = 90
            end
        elseif cfg_36 == 90 then
            frame_36[379] = math.mod
            frame_36[380] = frame_36[371]
            frame_36[382] = frame_36[379](frame_36[380], 200)
            frame_36[383] = frame_49["cap_49_456_13"]
            frame_36[384] = (frame_36[383]).UpdateObjProgressBar
            frame_36[385] = frame_36[382]
            frame_36[384](frame_36[385], 200, "/Lotus/Language/Objectives/ExcavNextRelicCryotic")
            cfg_36 = 103
        elseif cfg_36 == 91 then
            frame_36[388] = frame_49[208]
            if not (frame_36[388]) then
                cfg_36 = 94
            else
                cfg_36 = 92
            end
        elseif cfg_36 == 92 then
            frame_36[389] = frame_49[208]
            if not (frame_36[389]) then
                cfg_36 = 103
            else
                cfg_36 = 93
            end
        elseif cfg_36 == 93 then
            if not (0 < frame_36[371]) then
                cfg_36 = 103
            else
                cfg_36 = 94
            end
        elseif cfg_36 == 94 then
            frame_36[391] = frame_49["cap_49_456_6"]
            frame_36[392] = (frame_36[391]).Ternary
            frame_36[393] = true
            frame_36[394] = gGameRules
            frame_36[397] = (frame_36[394]):GetMission()
            frame_36[398] = (frame_36[397]).periodicMissionTag
            frame_36[399] = frame_49["cap_49_456_5"]
            frame_36[400] = (frame_36[399]).ELITE_ALERT_PERIODIC_MISSION_TAG
            if frame_36[398] == frame_36[400] then
                cfg_36 = 98
            else
                cfg_36 = 95
            end
        elseif cfg_36 == 95 then
            frame_36[401] = gGameRules
            frame_36[404] = (frame_36[401]):GetMission()
            frame_36[405] = (frame_36[404]).periodicMissionTag
            frame_36[406] = frame_49["cap_49_456_5"]
            frame_36[407] = (frame_36[406]).ELITE_ALERT_PERIODIC_MISSION_TAG_ALT
            if frame_36[405] == frame_36[407] then
                cfg_36 = 97
            else
                cfg_36 = 96
            end
        elseif cfg_36 == 96 then
            frame_36[393] = false
            cfg_36 = 98
        elseif cfg_36 == 97 then
            frame_36[393] = true
            cfg_36 = 98
        elseif cfg_36 == 98 then
            frame_36[408] = frame_49["cap_49_456_17"]
            frame_36[409] = frame_49["cap_49_456_18"]
            frame_36[432] = (frame_36[2]):GetNetPersistentVar(frame_36[392](frame_36[393], frame_36[408], frame_36[409]))
            if not (0 < frame_36[432]) then
                cfg_36 = 100
            else
                cfg_36 = 99
            end
        elseif cfg_36 == 99 then
            frame_36[434] = frame_49["cap_49_456_13"]
            frame_36[435] = (frame_36[434]).SetPrimaryObjText
            frame_36[435]("/Lotus/Language/Objectives/GetToExtraction", 3)
            frame_36[438] = frame_49["cap_49_456_13"]
            frame_36[439] = (frame_36[438]).SetSecondaryObjText
            frame_36[439]("/Lotus/Language/GameModes/ExcavationExtraObjective", 1)
            cfg_36 = 100
        elseif cfg_36 == 100 then
            frame_36[442] = Engine.IsMobile
            frame_36[443] = frame_36[442]()
            if not (frame_36[443]) then
                cfg_36 = 102
            else
                cfg_36 = 101
            end
        elseif cfg_36 == 101 then
            frame_36[444] = frame_49["cap_49_456_13"]
            frame_36[445] = (frame_36[444]).SetSubTitleObjText
            frame_36[448] = frame_36[432]
            frame_36[449] = (": " .. frame_36[448])
            frame_36[450] = frame_36[445]("/Lotus/Language/Objectives/ExcavDigsComplete", frame_36[449])
            frame_36[451] = (frame_36[450]).SetOffset
            frame_36[451](0, -5, true)
            cfg_36 = 103
        elseif cfg_36 == 102 then
            frame_36[455] = frame_49["cap_49_456_13"]
            frame_36[456] = (frame_36[455]).SetSubTitleObjText
            frame_36[459] = frame_36[432]
            frame_36[460] = (": " .. frame_36[459])
            frame_36[456]("/Lotus/Language/Objectives/ExcavDigsComplete", frame_36[460])
            cfg_36 = 103
        elseif cfg_36 == 103 then
            frame_36[461] = frame_49[212]
            if frame_36[461] then
                cfg_36 = 106
            else
                cfg_36 = 104
            end
        elseif cfg_36 == 104 then
            frame_36[462] = frame_49[214]
            frame_36[463] = IsNull
            frame_36[464] = frame_36[463](frame_36[462])
            if not (frame_36[464]) then
                cfg_36 = 106
            else
                cfg_36 = 105
            end
        elseif cfg_36 == 105 then
            frame_36[465] = gRegion
            frame_36[466] = frame_49["cap_49_456_15"]
            frame_36[469] = (frame_36[465]):FindFirstTagged(frame_36[466])
            frame_49[214] = frame_36[469]
            cfg_36 = 106
        elseif cfg_36 == 106 then
            frame_36[470] = frame_49[206]
            if (not (frame_36[470]) or frame_36[43]) then
                cfg_36 = 121
            else
                cfg_36 = 108
            end
        elseif cfg_36 == 108 then
            frame_36[471] = frame_49["cap_49_456_19"]
            frame_36[472] = IsNull
            frame_36[473] = frame_36[472](frame_36[471])
            if frame_36[473] then
                cfg_36 = 121
            else
                cfg_36 = 109
            end
        elseif cfg_36 == 109 then
            frame_36[474] = frame_49[214]
            frame_36[475] = IsNull
            frame_36[476] = frame_36[475](frame_36[474])
            if frame_36[476] then
                cfg_36 = 121
            else
                cfg_36 = 110
            end
        elseif cfg_36 == 110 then
            frame_36[477] = frame_49[214]
            frame_36[480] = (frame_36[477]):IsEnabled()
            if not (frame_36[480]) then
                cfg_36 = 121
            else
                cfg_36 = 111
            end
        elseif cfg_36 == 111 then
            frame_36[483] = (frame_36[2]):Name__b89efb85()
            if not (frame_36[483] < 4294967295) then
                cfg_36 = 117
            else
                cfg_36 = 112
            end
        elseif cfg_36 == 112 then
            frame_36[43] = true
            frame_36[485] = Resource
            frame_36[488] = (frame_36[2]):GetMission()
            frame_36[489] = (frame_36[488]).levelKeyName
            frame_36[490] = frame_36[485](frame_36[489])
            frame_36[491] = frame_36[490]
            frame_36[492] = IsNull
            frame_36[493] = frame_36[492](frame_36[491])
            if frame_36[493] then
                cfg_36 = 117
            else
                cfg_36 = 113
            end
        elseif cfg_36 == 113 then
            frame_36[494] = frame_36[483]
            frame_36[497] = (frame_36[490]):GetReward(frame_36[494])
            frame_36[498] = (frame_36[497]).items
            if frame_36[498] == nil then
                cfg_36 = 117
            else
                cfg_36 = 114
            end
        elseif cfg_36 == 114 then
            frame_36[499] = frame_36[498][1]
            frame_36[500] = IsNull
            frame_36[501] = frame_36[500](frame_36[499])
            if frame_36[501] then
                cfg_36 = 117
            else
                cfg_36 = 115
            end
        elseif cfg_36 == 115 then
            frame_36[502] = gFlashMgr
            frame_36[503] = frame_49["cap_49_456_19"]
            frame_36[506] = (frame_36[502]):PushMovie(frame_36[503])
            frame_36[507] = frame_36[506]
            frame_36[508] = IsNull
            frame_36[509] = frame_36[508](frame_36[507])
            if frame_36[509] then
                cfg_36 = 117
            else
                cfg_36 = 116
            end
        elseif cfg_36 == 116 then
            frame_36[510] = _T.DisplayReward
            frame_36[511] = frame_36[498][1]
            frame_36[510](frame_36[511], 1)
            cfg_36 = 117
        elseif cfg_36 == 117 then
            frame_36[513] = gRegion
            frame_36[516] = (frame_36[513]):IsMaster()
            if not (frame_36[516]) then
                cfg_36 = 121
            else
                cfg_36 = 118
            end
        elseif cfg_36 == 118 then
            frame_36[517] = (frame_36[77]).goalId
            if frame_36[517] == "" then
                cfg_36 = 121
            else
                cfg_36 = 119
            end
        elseif cfg_36 == 119 then
            frame_36[518] = gGameRules
            frame_36[519] = frame_49["cap_49_456_18"]
            frame_36[523] = (frame_36[518]):GetNetPersistentVar(frame_36[519], 0)
            if frame_36[523] ~= 0 then
                cfg_36 = 121
            else
                cfg_36 = 120
            end
        elseif cfg_36 == 120 then
            frame_36[43] = true
            frame_36[524] = frame_49["cap_49_456_20"]
            frame_36[524]()
            cfg_36 = 121
        elseif cfg_36 == 121 then
            frame_36[525] = false
            frame_36[526] = 0
            frame_36[527] = 1
            frame_36[528] = (#frame_36[124])
            frame_36[529] = 1
            local leave_for_36_122 = false
            for for_value_36_122 = frame_36[527], frame_36[528], frame_36[529] do
                frame_36[527] = for_value_36_122
                cfg_36 = 122
                while true do
                    if cfg_36 == 122 then
                        frame_36[530] = frame_36[124][frame_36[527]]
                        frame_36[531] = frame_36[530]
                        frame_36[532] = IsNull
                        frame_36[533] = frame_36[532](frame_36[531])
                        if frame_36[533] then
                            cfg_36 = 153
                        else
                            cfg_36 = 123
                        end
                    elseif cfg_36 == 123 then
                        frame_36[536] = (frame_36[530]):IsEnabled()
                        if not (frame_36[536]) then
                            cfg_36 = 153
                        else
                            cfg_36 = 124
                        end
                    elseif cfg_36 == 124 then
                        frame_36[539] = (frame_36[530]):GetInstanceNumber()
                        frame_36[540] = (frame_36[539] % frame_36[72])
                        if frame_36[540] ~= 0 then
                            cfg_36 = 126
                        else
                            cfg_36 = 125
                        end
                    elseif cfg_36 == 125 then
                        frame_36[540] = frame_36[72]
                        cfg_36 = 126
                    elseif cfg_36 == 126 then
                        frame_36[526] = (frame_36[526] + 1)
                        frame_36[541] = frame_36[262][frame_36[527]]
                        frame_36[542] = IsNull
                        frame_36[543] = frame_36[542](frame_36[541])
                        if not (frame_36[543]) then
                            cfg_36 = 128
                        else
                            cfg_36 = 127
                        end
                    elseif cfg_36 == 127 then
                        frame_36[544] = frame_49["cap_49_456_13"]
                        frame_36[545] = (frame_36[544]).GetPriorityOffset
                        frame_36[546] = frame_36[545]()
                        frame_36[547] = (frame_36[546] + 10)
                        frame_36[548] = _T.AddHudTracker
                        frame_36[550] = frame_36[527]
                        frame_36[551] = ("ExcavationInfo" .. frame_36[550])
                        frame_36[552] = frame_49["cap_49_456_5"]
                        frame_36[553] = (frame_36[552]).HT_LABEL
                        frame_36[555] = frame_36[547]
                        frame_36[557] = frame_36[548](frame_36[551], frame_36[553], 0.15, frame_36[555], false)
                        frame_36[262][frame_36[527]] = frame_36[557]
                        frame_36[558] = frame_36[262][frame_36[527]]
                        frame_36[559] = (frame_36[558]).Colorize
                        frame_36[559](42)
                        frame_36[561] = frame_36[262][frame_36[527]]
                        frame_36[562] = (frame_36[561]).Colorize
                        frame_36[562](56)
                        frame_36[564] = frame_36[262][frame_36[527]]
                        frame_36[565] = (frame_36[564]).Colorize
                        frame_36[565](24)
                        frame_36[567] = frame_36[262][frame_36[527]]
                        frame_36[568] = (frame_36[567]).SetOffset
                        frame_36[570] = frame_36[341]
                        frame_36[568](0, frame_36[570])
                        cfg_36 = 128
                    elseif cfg_36 == 128 then
                        frame_36[571] = _T.HudInitState
                        if not (frame_36[571]) then
                            cfg_36 = 155
                        else
                            cfg_36 = 129
                        end
                    elseif cfg_36 == 129 then
                        frame_36[572] = nil
                        frame_36[573] = nil
                        frame_36[576] = (frame_36[530]):GetAvatar()
                        frame_36[577] = frame_36[576]
                        frame_36[578] = IsNull
                        frame_36[579] = frame_36[578](frame_36[577])
                        if not (frame_36[579]) then
                            cfg_36 = 131
                        else
                            cfg_36 = 130
                        end
                    elseif cfg_36 == 130 then
                        frame_36[580] = 0
                        frame_36[581] = 0
                        cfg_36 = 132
                    elseif cfg_36 == 131 then
                        frame_36[584] = (frame_36[576]):GetHealth()
                        frame_36[580] = frame_36[584]
                        frame_36[587] = (frame_36[576]):DamageControl()
                        frame_36[590] = (frame_36[587]):GetUIShield()
                        frame_36[581] = frame_36[590]
                        cfg_36 = 132
                    elseif cfg_36 == 132 then
                        frame_36[593] = (frame_36[530]):GetPower()
                        frame_36[594] = ""
                        if not (frame_36[593] < 0.001) then
                            cfg_36 = 134
                        else
                            cfg_36 = 133
                        end
                    elseif cfg_36 == 133 then
                        frame_36[596] = -1
                        cfg_36 = 135
                    elseif cfg_36 == 134 then
                        frame_36[597] = frame_49["cap_49_456_6"]
                        frame_36[598] = (frame_36[597]).Round
                        frame_36[599] = frame_36[593]
                        frame_36[600] = frame_36[598](frame_36[599])
                        frame_36[596] = frame_36[600]
                        cfg_36 = 135
                    elseif cfg_36 == 135 then
                        frame_36[603] = (frame_36[530]):GetTimer()
                        if not (frame_36[596] < 0) then
                            cfg_36 = 137
                        else
                            cfg_36 = 136
                        end
                    elseif cfg_36 == 136 then
                        frame_36[605] = string.format
                        frame_36[607] = frame_36[262][frame_36[527]]
                        frame_36[608] = (frame_36[607]).ColorizeBlink
                        frame_36[611] = frame_36[608](42, 38)
                        frame_36[612] = frame_36[123]
                        frame_36[613] = frame_36[605]("<font color=\"%s\"><b>%s</b></font>", frame_36[611], frame_36[612])
                        frame_36[614] = frame_36[613]
                        frame_36[525] = true
                        cfg_36 = 143
                    elseif cfg_36 == 137 then
                        if not (frame_36[596] <= 25) then
                            cfg_36 = 140
                        else
                            cfg_36 = 138
                        end
                    elseif cfg_36 == 138 then
                        frame_36[616] = frame_36[603]
                        frame_36[617] = math.floor
                        frame_36[618] = frame_36[617](frame_36[616])
                        if not (frame_36[596] < frame_36[618]) then
                            cfg_36 = 140
                        else
                            cfg_36 = 139
                        end
                    elseif cfg_36 == 139 then
                        frame_36[619] = string.format
                        frame_36[621] = frame_36[262][frame_36[527]]
                        frame_36[622] = (frame_36[621]).ColorizeBlink
                        frame_36[625] = frame_36[622](42, 38)
                        frame_36[626] = frame_36[596]
                        frame_36[628] = (frame_36[626] .. "%")
                        frame_36[629] = frame_36[619]("<font color=\"%s\"><b>%s</b></font>", frame_36[625], frame_36[628])
                        frame_36[614] = frame_36[629]
                        cfg_36 = 143
                    elseif cfg_36 == 140 then
                        frame_36[630] = frame_36[603]
                        frame_36[631] = math.floor
                        frame_36[632] = frame_36[631](frame_36[630])
                        if not (frame_36[632] <= frame_36[596]) then
                            cfg_36 = 142
                        else
                            cfg_36 = 141
                        end
                    elseif cfg_36 == 141 then
                        frame_36[633] = string.format
                        frame_36[635] = frame_36[262][frame_36[527]]
                        frame_36[636] = (frame_36[635]).Colorize
                        frame_36[638] = frame_36[636](13)
                        frame_36[639] = frame_36[116]
                        frame_36[640] = frame_36[633]("<font color=\"%s\"><b>%s</b></font>", frame_36[638], frame_36[639])
                        frame_36[614] = frame_36[640]
                        cfg_36 = 143
                    elseif cfg_36 == 142 then
                        frame_36[641] = string.format
                        frame_36[643] = frame_36[262][frame_36[527]]
                        frame_36[644] = (frame_36[643]).Colorize
                        frame_36[646] = frame_36[644](42)
                        frame_36[647] = frame_36[596]
                        frame_36[649] = (frame_36[647] .. "%")
                        frame_36[650] = frame_36[641]("<font color=\"%s\"><b>%s</b></font>", frame_36[646], frame_36[649])
                        frame_36[614] = frame_36[650]
                        cfg_36 = 143
                    elseif cfg_36 == 143 then
                        frame_36[651] = frame_49["cap_49_456_6"]
                        frame_36[652] = (frame_36[651]).FormatNumber
                        frame_36[653] = frame_36[603]
                        frame_36[658] = frame_36[652](frame_36[653], 1, nil, nil, true)
                        frame_36[659] = frame_36[576]
                        frame_36[660] = IsNull
                        frame_36[661] = frame_36[660](frame_36[659])
                        if frame_36[661] then
                            cfg_36 = 147
                        else
                            cfg_36 = 144
                        end
                    elseif cfg_36 == 144 then
                        frame_36[664] = (frame_36[576]):DamageControl()
                        frame_36[667] = (frame_36[664]):IsInvulnerable()
                        if frame_36[667] then
                            cfg_36 = 146
                        else
                            cfg_36 = 145
                        end
                    elseif cfg_36 == 145 then
                        frame_36[670] = (frame_36[576]):DamageControl()
                        frame_36[673] = (frame_36[670]):Name__15f53748()
                        if not (frame_36[673]) then
                            cfg_36 = 147
                        else
                            cfg_36 = 146
                        end
                    elseif cfg_36 == 146 then
                        frame_36[674] = string.format
                        frame_36[676] = frame_36[262][frame_36[527]]
                        frame_36[677] = (frame_36[676]).Colorize
                        frame_36[679] = frame_36[677](13)
                        frame_36[682] = (frame_36[576]):DamageControl()
                        frame_36[690] = frame_36[674]("<font color=\"%s\"><b>%s</b></font>", frame_36[679], (frame_36[682]):GetUIShield())
                        frame_36[581] = frame_36[690]
                        frame_36[691] = string.format
                        frame_36[693] = frame_36[262][frame_36[527]]
                        frame_36[694] = (frame_36[693]).Colorize
                        frame_36[696] = frame_36[694](13)
                        frame_36[704] = frame_36[691]("<font color=\"%s\"><b>%s</b></font>", frame_36[696], (frame_36[576]):GetHealth())
                        frame_36[580] = frame_36[704]
                        cfg_36 = 147
                    elseif cfg_36 == 147 then
                        frame_36[705] = frame_36[262][frame_36[527]]
                        frame_36[706] = (frame_36[705]).SetLabel
                        frame_36[707] = string.format
                        frame_36[708] = frame_36[244]
                        frame_36[709] = frame_36[49][frame_36[540]]
                        frame_36[710] = frame_36[581]
                        frame_36[711] = frame_36[580]
                        frame_36[712] = frame_49["cap_49_456_21"]
                        frame_36[713] = (frame_36[712]).FormatTime
                        frame_36[714] = frame_36[658]
                        frame_36[715] = frame_36[713](frame_36[714])
                        frame_36[716] = frame_36[614]
                        frame_36[706](frame_36[707](frame_36[708], frame_36[709], frame_36[710], frame_36[711], frame_36[715], frame_36[716]))
                        frame_36[724] = frame_36[262][frame_36[527]]
                        frame_36[725] = (frame_36[724]).NeedsInit
                        if frame_36[725] then
                            cfg_36 = 155
                        else
                            cfg_36 = 148
                        end
                    elseif cfg_36 == 148 then
                        frame_36[726] = frame_36[31]
                        frame_36[727] = IsNull
                        frame_36[728] = frame_36[727](frame_36[726])
                        if not (frame_36[728]) then
                            cfg_36 = 150
                        else
                            cfg_36 = 149
                        end
                    elseif cfg_36 == 149 then
                        frame_36[731] = (frame_36[2]):Name__fd0086f7()
                        frame_36[31] = frame_36[731]
                        cfg_36 = 150
                    elseif cfg_36 == 150 then
                        frame_36[732] = frame_36[31]
                        frame_36[733] = IsNull
                        frame_36[734] = frame_36[733](frame_36[732])
                        if frame_36[734] then
                            cfg_36 = 155
                        else
                            cfg_36 = 151
                        end
                    elseif cfg_36 == 151 then
                        frame_36[735] = frame_36[262][frame_36[527]]
                        frame_36[736] = (frame_36[735]).ClipName
                        frame_36[738] = (frame_36[736] .. ".Label")
                        frame_36[742] = (frame_36[31]):GetNumberVariable(frame_36[738], 41)
                        if frame_36[742] == nil then
                            cfg_36 = 155
                        else
                            cfg_36 = 152
                        end
                    elseif cfg_36 == 152 then
                        frame_36[743] = frame_36[262][frame_36[527]]
                        frame_36[744] = (frame_36[743]).SetHeight
                        frame_36[745] = (frame_36[742] + 25)
                        frame_36[744](frame_36[745])
                        cfg_36 = 155
                    elseif cfg_36 == 153 then
                        frame_36[746] = frame_36[262][frame_36[527]]
                        if not (frame_36[746]) then
                            cfg_36 = 155
                        else
                            cfg_36 = 154
                        end
                    elseif cfg_36 == 154 then
                        frame_36[747] = _T.RemoveHudTracker
                        frame_36[748] = frame_36[262][frame_36[527]]
                        frame_36[747](frame_36[748])
                        frame_36[262][frame_36[527]] = nil
                        cfg_36 = 155
                    elseif cfg_36 == 155 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_36_122 then break end
            end
            if not leave_for_36_122 then
                cfg_36 = 156
            end
        elseif cfg_36 == 156 then
            if not (frame_36[342]) then
                cfg_36 = 163
            else
                cfg_36 = 157
            end
        elseif cfg_36 == 157 then
            if not (frame_36[525]) then
                cfg_36 = 162
            else
                cfg_36 = 158
            end
        elseif cfg_36 == 158 then
            frame_36[750] = Name__3b4b94b0
            frame_36[751] = frame_36[750]()
            frame_36[359] = (frame_36[359] + frame_36[751])
            if not (5 <= frame_36[359]) then
                cfg_36 = 161
            else
                cfg_36 = 159
            end
        elseif cfg_36 == 159 then
            frame_36[753] = frame_36[31]
            frame_36[754] = IsNull
            frame_36[755] = frame_36[754](frame_36[753])
            if frame_36[755] then
                cfg_36 = 163
            else
                cfg_36 = 160
            end
        elseif cfg_36 == 160 then
            frame_36[760] = (frame_36[31]):GetLocalized("/Lotus/Language/GameModes/ExcavationHaltedHint", true)
            frame_36[762] = frame_36[760]
            frame_36[764] = ("<p><font color=\"#FFD700\"><b>" .. frame_36[762] .. "</b></font></p>")
            frame_36[765] = (frame_36[342]).SetLabel
            frame_36[766] = frame_36[764]
            frame_36[765](frame_36[766])
            cfg_36 = 163
        elseif cfg_36 == 161 then
            frame_36[767] = (frame_36[342]).SetLabel
            frame_36[767]("")
            cfg_36 = 163
        elseif cfg_36 == 162 then
            frame_36[359] = 0
            frame_36[769] = (frame_36[342]).SetLabel
            frame_36[769]("")
            cfg_36 = 163
        elseif cfg_36 == 163 then
            frame_36[771] = Sleep
            frame_36[771](0)
            cfg_36 = 82
        elseif cfg_36 == 164 then
            frame_36[773] = frame_49[212]
            if not (frame_36[773]) then
                cfg_36 = 170
            else
                cfg_36 = 165
            end
        elseif cfg_36 == 165 then
            frame_36[774] = _T.RemoveHudTracker
            if not (frame_36[774]) then
                cfg_36 = 170
            else
                cfg_36 = 166
            end
        elseif cfg_36 == 166 then
            frame_36[775] = 1
            frame_36[776] = (#frame_36[124])
            frame_36[777] = 1
            local leave_for_36_167 = false
            for for_value_36_167 = frame_36[775], frame_36[776], frame_36[777] do
                frame_36[775] = for_value_36_167
                cfg_36 = 167
                while true do
                    if cfg_36 == 167 then
                        frame_36[778] = frame_36[262][frame_36[775]]
                        if not (frame_36[778]) then
                            cfg_36 = 169
                        else
                            cfg_36 = 168
                        end
                    elseif cfg_36 == 168 then
                        frame_36[779] = _T.RemoveHudTracker
                        frame_36[780] = frame_36[262][frame_36[775]]
                        frame_36[779](frame_36[780])
                        cfg_36 = 169
                    elseif cfg_36 == 169 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_36_167 then break end
            end
            if not leave_for_36_167 then
                cfg_36 = 170
            end
        elseif cfg_36 == 170 then
            frame_36[781] = frame_49["cap_49_456_13"]
            frame_36[782] = (frame_36[781]).ClearTitleObjText
            frame_36[782]()
            frame_36[783] = _T.RemoveHudTracker
            if not (frame_36[783]) then
                cfg_36 = 172
            else
                cfg_36 = 171
            end
        elseif cfg_36 == 171 then
            frame_36[784] = _T.RemoveHudTracker
            frame_36[784]("PowerHint")
            cfg_36 = 172
        elseif cfg_36 == 172 then
            return
        else
            error("invalid control state")
        end
    end
end
ExcavationHUD = frame_49[269]
frame_49["cap_49_480_0"] = frame_49[80]
frame_49["cap_49_480_2"] = frame_49[83]
frame_49["cap_49_480_4"] = frame_49[20]
frame_49[270] = function()
    local v37_0
    local v37_1
    local v37_2
    local v37_3
    local v37_4
    local v37_5
    local v37_6
    local v37_7
    local v37_8
    local v37_9
    local v37_10
    local v37_11
    local v37_12
    local v37_13
    local v37_14
    local v37_15
    local v37_16
    local v37_17
    local v37_18
    local v37_19
    local v37_20
    local v37_21
    local v37_22
    local v37_23
    local v37_24
    local v37_25
    local v37_26
    local v37_27
    local v37_28
    local v37_29
    local v37_30
    local v37_31
    local v37_32
    local v37_33
    local v37_34
    local v37_35
    local v37_36
    local v37_37
    local v37_38
    local v37_39
    local v37_40
    local v37_41
    local v37_42
    local v37_43
    local v37_44
    local v37_45
    local v37_46
    local v37_47
    local v37_48
    local v37_49
    local v37_50
    local v37_51
    local v37_52
    v37_0 = frame_49["cap_49_480_0"]
    v37_1 = frame_49[205]
    if v37_1 then
        v37_0 = frame_49["cap_49_480_2"]
    end
    v37_2 = gRegion
    v37_3 = v37_0
    v37_6 = v37_2:FindTagged(v37_3)
    v37_7 = frame_49[212]
    if not (v37_7) then
        v37_11 = gPromotedToHost
    else
        v37_8 = gRegion
        v37_11 = v37_8:IsMaster()
        if v37_11 then
            v37_12 = frame_49["cap_49_480_4"]
            v37_13 = (v37_12).IsGameModeInProgress
            v37_11 = v37_13()
        end
    end
    if v37_11 then
        v37_14 = {}
        v37_15 = 1
        v37_16 = (#v37_6)
        v37_17 = 1
        for v37_15 = v37_15, v37_16, v37_17 do
            v37_18 = gRegion
            v37_19 = gMultiAvatarTriggerType
            v37_20 = v37_6[v37_15]
            v37_23 = v37_20:GetPosition()
            v37_27 = v37_18:FindNearest(v37_19, v37_23, 0.2)
            v37_28 = v37_27
            v37_29 = IsNull
            v37_30 = v37_29(v37_28)
            local sc_37_9
            if v37_30 then
                sc_37_9 = true
            else
                v37_33 = v37_27:IsEnabled()
                sc_37_9 = not (v37_33)
            end
            if sc_37_9 then
                v37_46 = v37_6[v37_15]
                v37_47 = frame_49[68]
                local sc_37_12
                if v37_46 ~= v37_47 then
                    sc_37_12 = true
                else
                    v37_48 = (#v37_6)
                    v37_49 = frame_49[28]
                    sc_37_12 = v37_48 <= v37_49
                end
                if not (sc_37_12) then continue end
                v37_50 = v37_6[v37_15]
                v37_51 = v37_14
                v37_52 = table.insert
                v37_52(v37_51, v37_50)
            else
                v37_34 = print
                v37_36 = v37_6[v37_15]
                v37_41 = tostring
                v37_42 = v37_41(v37_36:GetFullName())
                v37_43 = v37_42
                v37_45 = ("Extractor " .. v37_43 .. " already used, removing")
                v37_34(v37_45)
            end
        end
        return v37_14
    else
        return v37_6
    end
end
frame_49[271] = function(p38_0, p38_1, p38_2)
    local v38_3
    local v38_4
    local v38_5
    local v38_6
    local v38_7
    local v38_8
    local v38_9
    local v38_10
    local v38_11
    local v38_12
    local v38_13
    local v38_14
    local v38_15
    local v38_16
    local v38_17
    local v38_18
    local v38_19
    v38_3 = nil
    v38_4 = 1
    v38_5 = (#p38_0)
    v38_6 = 1
    for v38_4 = v38_4, v38_5, v38_6 do
        v38_7 = p38_0[v38_4]
        v38_8 = p38_1
        v38_11 = v38_7:DistanceToPoint(v38_8)
        if v38_11 < p38_2 then
            v38_12 = true
        else
            v38_12 = false
        end
        if v38_12 then
            v38_3 = v38_4
        end
    end
    v38_13 = v38_3
    v38_14 = IsNull
    v38_15 = v38_14(v38_13)
    if v38_15 then
        v38_16 = RandomInt
        v38_18 = (#p38_0)
        v38_19 = v38_16(1, v38_18)
        v38_3 = v38_19
    end
    return v38_3
end
frame_49["cap_49_489_2"] = frame_49[270]
frame_49["cap_49_489_3"] = frame_49[104]
frame_49["cap_49_489_4"] = frame_49[107]
frame_49["cap_49_489_5"] = frame_49[95]
frame_49["cap_49_489_7"] = frame_49[20]
frame_49["cap_49_489_8"] = frame_49[110]
frame_49["cap_49_489_9"] = frame_49[86]
frame_49["cap_49_489_10"] = frame_49[98]
frame_49["cap_49_489_11"] = frame_49[122]
frame_49["cap_49_489_12"] = frame_49[271]
frame_49["cap_49_489_14"] = frame_49[8]
frame_49["cap_49_489_16"] = frame_49[2]
frame_49[272] = function(p39_0)
    local frame_39 = {}
    local cfg_39 = 0
    while true do
        if cfg_39 == 0 then
            frame_39[1] = gRegion
            frame_39[4] = (frame_39[1]):IsMaster()
            if frame_39[4] then
                cfg_39 = 2
            else
                cfg_39 = 1
            end
        elseif cfg_39 == 1 then
            return
        elseif cfg_39 == 2 then
            frame_39[5] = frame_49[205]
            if not (frame_39[5]) then
                cfg_39 = 4
            else
                cfg_39 = 3
            end
        elseif cfg_39 == 3 then
            frame_49[28] = 1
            cfg_39 = 4
        elseif cfg_39 == 4 then
            frame_39[7] = frame_49["cap_49_489_2"]
            frame_39[8] = frame_39[7]()
            frame_39[10] = print
            frame_39[12] = (#frame_39[8])
            frame_39[13] = tostring
            frame_39[14] = frame_39[13](frame_39[12])
            frame_39[15] = ("Nr of extractors = " .. frame_39[14])
            frame_39[10](frame_39[15])
            frame_39[16] = gGameRules
            frame_39[17] = frame_49["cap_49_489_3"]
            frame_39[20] = (frame_39[16]):GetNetPersistentVar(frame_39[17])
            if frame_39[20] ~= 0 then
                cfg_39 = 6
            else
                cfg_39 = 5
            end
        elseif cfg_39 == 5 then
            frame_39[21] = gGameRules
            frame_39[22] = frame_49["cap_49_489_4"]
            frame_39[23] = 50
            do (frame_39[21]):SetNetPersistentVar(frame_39[22], frame_39[23]) end
            cfg_39 = 6
        elseif cfg_39 == 6 then
            frame_39[26] = 0
            frame_39[27] = 0
            frame_39[28] = 0
            if frame_39[20] ~= 0 then
                cfg_39 = 8
            else
                cfg_39 = 7
            end
        elseif cfg_39 == 7 then
            frame_39[29] = gGameRules
            frame_39[30] = frame_49["cap_49_489_3"]
            do (frame_39[29]):SetNetPersistentVar(frame_39[30], 1) end
            cfg_39 = 8
        elseif cfg_39 == 8 then
            frame_39[34] = nil
            cfg_39 = 9
        elseif cfg_39 == 9 then
            frame_39[35] = frame_39[34]
            frame_39[36] = IsNull
            frame_39[37] = frame_39[36](frame_39[35])
            if not (frame_39[37]) then
                cfg_39 = 15
            else
                cfg_39 = 10
            end
        elseif cfg_39 == 10 then
            frame_39[38] = gRegion
            frame_39[39] = frame_49["cap_49_489_5"]
            frame_39[42] = (frame_39[38]):FindTagged(frame_39[39])
            frame_39[43] = 1
            frame_39[44] = (#frame_39[42])
            frame_39[45] = 1
            local leave_for_39_11 = false
            for for_value_39_11 = frame_39[43], frame_39[44], frame_39[45] do
                frame_39[43] = for_value_39_11
                cfg_39 = 11
                while true do
                    if cfg_39 == 11 then
                        frame_39[46] = frame_39[42][frame_39[43]]
                        frame_39[49] = (frame_39[46]):IsVisible()
                        if not (frame_39[49]) then
                            cfg_39 = 13
                        else
                            cfg_39 = 12
                        end
                    elseif cfg_39 == 12 then
                        frame_39[34] = frame_39[42][frame_39[43]]
                        cfg_39 = 14
                        leave_for_39_11 = true
                        break
                    elseif cfg_39 == 13 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_39_11 then break end
            end
            if not leave_for_39_11 then
                cfg_39 = 14
            end
        elseif cfg_39 == 14 then
            frame_39[50] = Sleep
            frame_39[50](0)
            cfg_39 = 9
        elseif cfg_39 == 15 then
            frame_39[54] = (frame_39[34]):GetPosition()
            frame_39[55] = frame_49[212]
            if not (frame_39[55]) then
                cfg_39 = 18
            else
                cfg_39 = 16
            end
        elseif cfg_39 == 16 then
            frame_39[56] = gRegion
            frame_39[59] = (frame_39[56]):IsMaster()
            if not (frame_39[59]) then
                cfg_39 = 19
            else
                cfg_39 = 17
            end
        elseif cfg_39 == 17 then
            frame_39[60] = frame_49["cap_49_489_7"]
            frame_39[61] = (frame_39[60]).IsGameModeInProgress
            frame_39[59] = frame_39[61]()
            cfg_39 = 19
        elseif cfg_39 == 18 then
            frame_39[59] = gPromotedToHost
            cfg_39 = 19
        elseif cfg_39 == 19 then
            if (not (frame_39[59]) or frame_39[20] == 0) then
                cfg_39 = 22
            else
                cfg_39 = 21
            end
        elseif cfg_39 == 21 then
            frame_39[62] = gGameRules
            frame_39[63] = frame_49["cap_49_489_8"]
            frame_39[66] = (frame_39[62]):GetNetPersistentVar(frame_39[63])
            frame_39[67] = (frame_39[66] / 16384)
            frame_39[28] = (25 - frame_39[67])
            cfg_39 = 22
        elseif cfg_39 == 22 then
            frame_39[68] = true
            cfg_39 = 23
        elseif cfg_39 == 23 then
            frame_39[69] = gGameRules
            frame_39[70] = frame_49["cap_49_489_4"]
            frame_39[74] = (frame_39[69]):GetNetPersistentVar(frame_39[70], 0)
            frame_39[75] = frame_39[74]
            frame_39[76] = gRegion
            frame_39[77] = frame_49["cap_49_489_9"]
            frame_39[80] = (frame_39[76]):FindTagged(frame_39[77])
            frame_39[81] = (#frame_39[80])
            frame_39[82] = gRegion
            frame_39[83] = frame_49["cap_49_489_10"]
            frame_39[86] = (frame_39[82]):FindTagged(frame_39[83])
            frame_39[87] = frame_39[86]
            frame_39[88] = 1
            frame_39[89] = (#frame_39[87])
            frame_39[90] = 1
            local leave_for_39_24 = false
            for for_value_39_24 = frame_39[88], frame_39[89], frame_39[90] do
                frame_39[88] = for_value_39_24
                cfg_39 = 24
                while true do
                    if cfg_39 == 24 then
                        frame_39[91] = frame_39[87][frame_39[88]]
                        frame_39[94] = (frame_39[91]):IsEnabled()
                        if not (frame_39[94]) then
                            cfg_39 = 26
                        else
                            cfg_39 = 25
                        end
                    elseif cfg_39 == 25 then
                        frame_39[81] = (frame_39[81] + 1)
                        cfg_39 = 26
                    elseif cfg_39 == 26 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_39_24 then break end
            end
            if not leave_for_39_24 then
                cfg_39 = 27
            end
        elseif cfg_39 == 27 then
            frame_39[95] = gGameRules
            frame_39[96] = frame_49["cap_49_489_11"]
            frame_39[100] = (frame_39[95]):GetNetPersistentVar(frame_39[96], 0)
            if not (25 < frame_39[28]) then
                cfg_39 = 40
            else
                cfg_39 = 28
            end
        elseif cfg_39 == 28 then
            if not (0 < frame_39[75]) then
                cfg_39 = 40
            else
                cfg_39 = 29
            end
        elseif cfg_39 == 29 then
            frame_39[103] = frame_49[28]
            if not (frame_39[81] < frame_39[103]) then
                cfg_39 = 40
            else
                cfg_39 = 30
            end
        elseif cfg_39 == 30 then
            frame_39[104] = (#frame_39[8])
            if not (frame_39[104] <= 0) then
                cfg_39 = 32
            else
                cfg_39 = 31
            end
        elseif cfg_39 == 31 then
            frame_39[106] = frame_49["cap_49_489_2"]
            frame_39[107] = frame_39[106]()
            frame_39[8] = frame_39[107]
            frame_39[108] = print
            frame_39[110] = (#frame_39[8])
            frame_39[111] = tostring
            frame_39[112] = frame_39[111](frame_39[110])
            frame_39[113] = ("Nr of extractors = " .. frame_39[112])
            frame_39[108](frame_39[113])
            cfg_39 = 32
        elseif cfg_39 == 32 then
            frame_39[114] = nil
            if not (3 < frame_39[100]) then
                cfg_39 = 34
            else
                cfg_39 = 33
            end
        elseif cfg_39 == 33 then
            frame_39[116] = RandomInt
            frame_39[118] = (#frame_39[8])
            frame_39[119] = frame_39[116](1, frame_39[118])
            frame_39[120] = frame_39[119]
            cfg_39 = 39
        elseif cfg_39 == 34 then
            if not (2 < frame_39[100]) then
                cfg_39 = 36
            else
                cfg_39 = 35
            end
        elseif cfg_39 == 35 then
            frame_39[122] = frame_49["cap_49_489_12"]
            frame_39[123] = frame_39[8]
            frame_39[124] = frame_39[54]
            frame_39[126] = frame_39[122](frame_39[123], frame_39[124], 400)
            frame_39[120] = frame_39[126]
            cfg_39 = 39
        elseif cfg_39 == 36 then
            if not (1 < frame_39[100]) then
                cfg_39 = 38
            else
                cfg_39 = 37
            end
        elseif cfg_39 == 37 then
            frame_39[128] = frame_49["cap_49_489_12"]
            frame_39[129] = frame_39[8]
            frame_39[130] = frame_39[54]
            frame_39[132] = frame_39[128](frame_39[129], frame_39[130], 300)
            frame_39[120] = frame_39[132]
            cfg_39 = 39
        elseif cfg_39 == 38 then
            frame_39[133] = frame_49["cap_49_489_12"]
            frame_39[134] = frame_39[8]
            frame_39[135] = frame_39[54]
            frame_39[137] = frame_39[133](frame_39[134], frame_39[135], 200)
            frame_39[120] = frame_39[137]
            cfg_39 = 39
        elseif cfg_39 == 39 then
            frame_39[138] = frame_39[8][frame_39[120]]
            frame_49[68] = frame_39[138]
            frame_39[139] = frame_39[8][frame_39[120]]
            do (frame_39[139]):FirePort("TriggerPort") end
            frame_39[143] = table.remove
            frame_39[144] = frame_39[8]
            frame_39[145] = frame_39[120]
            frame_39[143](frame_39[144], frame_39[145])
            frame_39[146] = frame_49["cap_49_489_14"]
            frame_39[147] = (frame_39[146]).PlayGlobalTransmission
            frame_39[148] = _T.MissionTransmissionSet
            frame_39[149] = Symbol
            frame_39[147](frame_39[148], frame_39[149]("MissionScannerComplete"))
            frame_39[28] = 0
            cfg_39 = 40
        elseif cfg_39 == 40 then
            frame_39[169] = gRegion
            frame_39[172] = (frame_39[169]):GetHumanPlayerAvatars()
            frame_39[173] = 1
            frame_39[174] = (#frame_39[172])
            frame_39[175] = 1
            local leave_for_39_41 = false
            for for_value_39_41 = frame_39[173], frame_39[174], frame_39[175] do
                frame_39[173] = for_value_39_41
                cfg_39 = 41
                while true do
                    if cfg_39 == 41 then
                        frame_39[176] = frame_39[172][frame_39[173]]
                        frame_39[177] = gLotusVehicleAvatarType
                        frame_39[180] = (frame_39[176]):IsA(frame_39[177])
                        if not (frame_39[180]) then
                            cfg_39 = 45
                        else
                            cfg_39 = 42
                        end
                    elseif cfg_39 == 42 then
                        frame_39[183] = (frame_39[176]):IsHoverboard()
                        if not (frame_39[183]) then
                            cfg_39 = 45
                        else
                            cfg_39 = 43
                        end
                    elseif cfg_39 == 43 then
                        frame_39[186] = (frame_39[176]):GetRider()
                        if not (frame_39[186]) then
                            cfg_39 = 45
                        else
                            cfg_39 = 44
                        end
                    elseif cfg_39 == 44 then
                        frame_39[189] = (frame_39[176]):GetRider()
                        frame_39[190] = frame_39[189]
                        cfg_39 = 46
                    elseif cfg_39 == 45 then
                        frame_39[190] = frame_39[176]
                        cfg_39 = 46
                    elseif cfg_39 == 46 then
                        frame_39[191] = cellItemType
                        frame_39[194] = (frame_39[190]):HasItem(frame_39[191])
                        if not (frame_39[194]) then
                            cfg_39 = 52
                        else
                            cfg_39 = 47
                        end
                    elseif cfg_39 == 47 then
                        frame_39[195] = frame_49[69]
                        frame_39[196] = (frame_39[195] * 10)
                        frame_39[197] = (frame_39[196] / 9)
                        if not (frame_39[75] < frame_39[197]) then
                            cfg_39 = 52
                        else
                            cfg_39 = 48
                        end
                    elseif cfg_39 == 48 then
                        frame_39[198] = frame_39[172][frame_39[173]]
                        frame_39[201] = (frame_39[198]):GetPosition()
                        frame_39[202] = (frame_39[201]).x
                        frame_39[203] = (frame_39[54]).x
                        frame_39[204] = (frame_39[202] - frame_39[203])
                        frame_39[205] = (frame_39[201]).x
                        frame_39[206] = (frame_39[54]).x
                        frame_39[207] = (frame_39[205] - frame_39[206])
                        frame_39[208] = (frame_39[204] * frame_39[207])
                        frame_39[209] = (frame_39[201]).z
                        frame_39[210] = (frame_39[54]).z
                        frame_39[211] = (frame_39[209] - frame_39[210])
                        frame_39[212] = (frame_39[201]).z
                        frame_39[213] = (frame_39[54]).z
                        frame_39[214] = (frame_39[212] - frame_39[213])
                        frame_39[215] = (frame_39[211] * frame_39[214])
                        frame_39[216] = (frame_39[208] + frame_39[215])
                        if not (frame_39[216] < 25) then
                            cfg_39 = 52
                        else
                            cfg_39 = 49
                        end
                    elseif cfg_39 == 49 then
                        frame_39[218] = frame_39[172][frame_39[173]]
                        frame_39[221] = (frame_39[218]):GetPlayer()
                        frame_39[224] = (frame_39[190]):InventoryControl()
                        frame_39[227] = (frame_39[224]):Name__4ee25a12()
                        frame_39[228] = frame_49["cap_49_489_16"]
                        frame_39[229] = (frame_39[228]).Round
                        frame_39[231] = (20 * frame_39[227])
                        frame_39[232] = frame_49[69]
                        frame_39[233] = (frame_39[232] - frame_39[75])
                        frame_39[234] = math.min
                        frame_39[235] = frame_39[234](frame_39[231], frame_39[233])
                        frame_39[236] = frame_39[229](frame_39[235])
                        frame_39[237] = gGameRules
                        frame_39[238] = frame_39[221]
                        frame_39[245] = frame_39[236]
                        frame_39[246] = tostring
                        frame_39[247] = frame_39[246](frame_39[245])
                        do (frame_39[237]):DisplayMessage(frame_39[238], "/Lotus/Language/Game/GainedPower", "", 0, 2, true, "AMOUNT", frame_39[247]) end
                        frame_39[75] = (frame_39[75] + frame_39[236])
                        frame_39[250] = frame_39[172][frame_39[173]]
                        frame_39[251] = cellDeliverySound
                        do (frame_39[250]):PlaySound(frame_39[251], false) end
                        frame_39[255] = cellItemType
                        do (frame_39[190]):RemoveItem(frame_39[255]) end
                        frame_39[258] = _T
                        frame_39[258].PlayerHasDeliveredCell = true
                        frame_39[260] = frame_39[221]
                        frame_39[261] = IsNull
                        frame_39[262] = frame_39[261](frame_39[260])
                        if frame_39[262] then
                            cfg_39 = 52
                        else
                            cfg_39 = 50
                        end
                    elseif cfg_39 == 50 then
                        frame_39[265] = (frame_39[221]):GetStats()
                        frame_39[266] = frame_39[265]
                        frame_39[267] = IsNull
                        frame_39[268] = frame_39[267](frame_39[266])
                        if frame_39[268] then
                            cfg_39 = 52
                        else
                            cfg_39 = 51
                        end
                    elseif cfg_39 == 51 then
                        do (frame_39[265]):Name__e6196dda() end
                        cfg_39 = 52
                    elseif cfg_39 == 52 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_39_41 then break end
            end
            if not leave_for_39_41 then
                cfg_39 = 53
            end
        elseif cfg_39 == 53 then
            if not (1 <= frame_39[27]) then
                cfg_39 = 56
            else
                cfg_39 = 54
            end
        elseif cfg_39 == 54 then
            frame_39[272] = frame_49[28]
            if not (frame_39[81] < frame_39[272]) then
                cfg_39 = 56
            else
                cfg_39 = 55
            end
        elseif cfg_39 == 55 then
            frame_39[273] = (frame_39[75] - 1)
            frame_39[275] = math.max
            frame_39[276] = frame_39[275](frame_39[273], 0)
            frame_39[75] = frame_39[276]
            frame_39[27] = 0
            cfg_39 = 56
        elseif cfg_39 == 56 then
            if (not (frame_39[75] <= 0) or frame_39[81] ~= 0) then
                cfg_39 = 59
            else
                cfg_39 = 58
            end
        elseif cfg_39 == 58 then
            frame_39[278] = frame_49["cap_49_489_14"]
            frame_39[279] = (frame_39[278]).PlayGlobalTransmission
            frame_39[280] = _T.MissionTransmissionSet
            frame_39[281] = Symbol
            frame_39[279](frame_39[280], frame_39[281]("MissionScannerUnpowered"))
            frame_39[26] = 0
            cfg_39 = 59
        elseif cfg_39 == 59 then
            if (not (frame_39[75] <= 0) or not (frame_39[68])) then
                cfg_39 = 62
            else
                cfg_39 = 61
            end
        elseif cfg_39 == 61 then
            frame_39[68] = false
            cfg_39 = 65
        elseif cfg_39 == 62 then
            if (not (0 < frame_39[75]) or frame_39[68]) then
                cfg_39 = 65
            else
                cfg_39 = 64
            end
        elseif cfg_39 == 64 then
            frame_39[68] = true
            cfg_39 = 65
        elseif cfg_39 == 65 then
            frame_39[303] = gGameRules
            frame_39[304] = frame_49["cap_49_489_4"]
            frame_39[305] = frame_39[75]
            do (frame_39[303]):SetNetPersistentVar(frame_39[304], frame_39[305]) end
            frame_39[308] = gGameRules
            frame_39[309] = frame_49["cap_49_489_11"]
            frame_39[310] = frame_39[100]
            do (frame_39[308]):SetNetPersistentVar(frame_39[309], frame_39[310]) end
            frame_39[313] = Name__3b4b94b0
            frame_39[314] = frame_39[313]()
            frame_39[26] = (frame_39[26] + frame_39[314])
            frame_39[315] = Name__3b4b94b0
            frame_39[316] = frame_39[315]()
            frame_39[27] = (frame_39[27] + frame_39[316])
            if not (0 < frame_39[75]) then
                cfg_39 = 68
            else
                cfg_39 = 66
            end
        elseif cfg_39 == 66 then
            frame_39[318] = frame_49[28]
            if not (frame_39[81] < frame_39[318]) then
                cfg_39 = 68
            else
                cfg_39 = 67
            end
        elseif cfg_39 == 67 then
            frame_39[319] = Name__3b4b94b0
            frame_39[320] = frame_39[319]()
            frame_39[28] = (frame_39[28] + frame_39[320])
            cfg_39 = 68
        elseif cfg_39 == 68 then
            frame_39[321] = (25 - frame_39[28])
            frame_39[322] = gGameRules
            if not (frame_39[321] < 0) then
                cfg_39 = 70
            else
                cfg_39 = 69
            end
        elseif cfg_39 == 69 then
            frame_39[321] = 0
            cfg_39 = 70
        elseif cfg_39 == 70 then
            frame_39[324] = frame_49["cap_49_489_8"]
            frame_39[325] = (frame_39[321] * 16384)
            frame_39[326] = math.ceil
            frame_39[327] = frame_39[326](frame_39[325])
            do (frame_39[322]):SetNetPersistentVar(frame_39[324], frame_39[327]) end
            frame_39[330] = Sleep
            frame_39[330](0)
            cfg_39 = 23
        else
            error("invalid control state")
        end
    end
end
frame_49["cap_49_507_0"] = frame_49[272]
frame_49[273] = function(p40_0, p40_1)
    local v40_2
    local v40_3
    v40_2 = frame_49["cap_49_507_0"]
    v40_3 = p40_0
    v40_2(v40_3)
    return
end
Scanner = frame_49[273]
frame_49["cap_49_510_1"] = frame_49[192]
frame_49["cap_49_510_2"] = frame_49[195]
frame_49["cap_49_510_3"] = frame_49[198]
frame_49["cap_49_510_4"] = frame_49[201]
frame_49["cap_49_510_5"] = frame_49[240]
frame_49[274] = function(p41_0, p41_1, p41_2, p41_3, p41_4)
    local v41_5
    local v41_6
    local v41_7
    local v41_8
    local v41_9
    local v41_10
    local v41_11
    local v41_12
    local v41_13
    local v41_14
    local v41_15
    local v41_16
    local v41_17
    local v41_18
    local v41_19
    local v41_20
    local v41_21
    local v41_22
    local v41_23
    local v41_24
    local v41_25
    local v41_26
    local v41_27
    local v41_28
    local v41_29
    local v41_30
    local v41_31
    local v41_32
    local v41_33
    local v41_34
    local v41_35
    local v41_36
    local v41_37
    local v41_38
    local v41_39
    local v41_40
    local v41_41
    local v41_42
    local v41_43
    local v41_44
    local v41_45
    local v41_46
    local v41_47
    local v41_48
    local v41_49
    local v41_50
    local v41_51
    local v41_52
    local v41_53
    local v41_54
    local v41_55
    local v41_56
    local v41_57
    local v41_58
    local v41_59
    local v41_60
    local v41_61
    local v41_62
    local v41_63
    local v41_64
    local v41_65
    local v41_66
    local v41_67
    local v41_68
    local v41_69
    local v41_70
    local v41_71
    local v41_72
    local v41_73
    local v41_74
    local v41_75
    local v41_76
    local v41_77
    local v41_78
    local v41_79
    local v41_80
    local v41_81
    local v41_82
    local v41_83
    local v41_84
    local v41_85
    local v41_86
    local v41_87
    local v41_88
    local v41_89
    local v41_90
    local v41_91
    local v41_92
    local v41_93
    local v41_94
    local v41_95
    local v41_96
    local v41_97
    local v41_98
    local v41_99
    local v41_100
    local v41_101
    local v41_102
    local v41_103
    local v41_104
    local v41_105
    local v41_106
    local v41_107
    local v41_108
    local v41_109
    local v41_110
    local v41_111
    local v41_112
    local v41_113
    local v41_114
    local v41_115
    local v41_116
    local v41_117
    local v41_118
    local v41_119
    local v41_120
    local v41_121
    local v41_122
    local v41_123
    local v41_124
    local v41_125
    local v41_126
    local v41_127
    local v41_128
    local v41_129
    local v41_130
    local v41_131
    local v41_132
    local v41_133
    local v41_134
    local v41_135
    local v41_136
    local v41_137
    local v41_138
    local v41_139
    local v41_140
    local v41_141
    local v41_142
    local v41_143
    local v41_144
    local v41_145
    local v41_146
    local v41_147
    v41_5 = 0
    v41_6 = false
    v41_7 = 1
    v41_8 = (#p41_0)
    v41_9 = 1
    for v41_7 = v41_7, v41_8, v41_9 do
        v41_10 = p41_0[v41_7]
        v41_13 = v41_10:GetPlayer()
        v41_16 = v41_13:GetMissionData()
        v41_17 = p41_0[v41_7]
        v41_18 = p41_1
        v41_21 = v41_17:DistanceToPoint(v41_18)
        if v41_21 < 6 then
            v41_23 = true
        else
            v41_23 = false
        end
        v41_24 = false
        if v41_23 then
            v41_25 = frame_49[69]
            if p41_3 < v41_25 then
                v41_26 = frame_49[69]
                v41_27 = (v41_26 - p41_4)
                if p41_3 <= v41_27 then
                    v41_28 = p41_0[v41_7]
                    v41_31 = v41_28:DamageControl()
                    v41_34 = v41_31:GetShield()
                    v41_37 = v41_31:GetMaxShield()
                    v41_38 = p41_0[v41_7]
                    v41_41 = v41_38:GetHealth()
                    if not (0 < v41_34) then
                        if not (v41_37 ~= 0) then
                            if 100 < v41_41 then
                                v41_55 = gRegion
                                v41_58 = v41_55:IsMaster()
                                if v41_58 then
                                    v41_59 = (v41_41 - 30)
                                    v41_61 = math.max
                                    v41_62 = v41_61(v41_59, 0)
                                    v41_63 = p41_0[v41_7]
                                    v41_64 = v41_62
                                    v41_63:SetHealth(v41_64)
                                end
                                v41_24 = true
                            end
                        end
                    else
                        v41_43 = gRegion
                        v41_46 = v41_43:IsMaster()
                        if v41_46 then
                            v41_47 = (v41_34 - 30)
                            v41_49 = math.max
                            v41_50 = v41_49(v41_47, 0)
                            v41_51 = v41_50
                            v41_31:SetShield(v41_51)
                        end
                        v41_24 = true
                    end
                    if v41_24 then
                        v41_67 = p41_0[v41_7]
                        v41_68 = beamType
                        v41_79 = IsNull
                        v41_80 = v41_79(v41_67:GetAttachment(v41_68))
                        if v41_80 then
                            v41_84 = v41_31:Name__b7c91969(0)
                            v41_85 = p41_0[v41_7]
                            v41_86 = beamType
                            v41_87 = v41_84
                            v41_88 = Vector
                            v41_98 = v41_85:Attach(v41_86, v41_87, v41_88(-0.2, 0, 0))
                            v41_99 = Vector
                            v41_103 = v41_99(0, 2, 0)
                            v41_104 = (p41_1 + v41_103)
                            v41_98:SetEndPoint(v41_104)
                            v41_107 = p41_2
                            v41_98:SetTag(v41_107)
                            v41_110 = p41_0[v41_7]
                            v41_111 = avProjType
                            v41_112 = EMPTY_SYMBOL
                            v41_110:Attach(v41_111, v41_112)
                            v41_115 = v41_16
                            v41_116 = IsNull
                            v41_117 = v41_116(v41_115)
                            if not (v41_117) then
                                v41_118 = frame_49["cap_49_510_1"]
                                v41_16:SetMissionVar(v41_118, 1)
                                v41_122 = frame_49["cap_49_510_2"]
                                v41_123 = (p41_1).x
                                v41_16:SetMissionVar(v41_122, v41_123)
                                v41_126 = frame_49["cap_49_510_3"]
                                v41_127 = (p41_1).y
                                v41_128 = (v41_127 + 2)
                                v41_16:SetMissionVar(v41_126, v41_128)
                                v41_131 = frame_49["cap_49_510_4"]
                                v41_132 = (p41_1).z
                                v41_16:SetMissionVar(v41_131, v41_132)
                            end
                        end
                        v41_5 = (v41_5 + 0.4)
                    end
                end
            end
        end
        if not (v41_24) then
            v41_135 = frame_49["cap_49_510_5"]
            v41_136 = p41_0[v41_7]
            v41_137 = beamType
            v41_138 = p41_2
            v41_135(v41_136, v41_137, v41_138)
            v41_139 = v41_16
            v41_140 = IsNull
            v41_141 = v41_140(v41_139)
            if not (v41_141) then
                v41_142 = frame_49["cap_49_510_1"]
                v41_16:SetMissionVar(v41_142, 0)
            end
        end
    end
    v41_146 = frame_49[69]
    v41_147 = (v41_146 - p41_4)
    if v41_147 < p41_3 then
        v41_6 = true
    end
    return v41_5, v41_6
end
frame_49["cap_49_517_0"] = frame_49[14]
frame_49[275] = function()
    local v42_0
    local v42_1
    local v42_2
    local v42_3
    local v42_4
    local v42_5
    local v42_6
    v42_0 = _T.PlayerHasDeliveredCell
    if not (v42_0) then
        v42_1 = frame_49["cap_49_517_0"]
        v42_2 = (v42_1).ShowTutorialHint
        v42_2("/Lotus/Language/GameModes/ExcavationHint", 10)
        v42_5 = _T
        v42_5.PlayerHasDeliveredCell = true
    end
    return
end
frame_49["cap_49_519_0"] = frame_49[232]
frame_49["cap_49_519_1"] = frame_49[5]
frame_49["cap_49_519_2"] = frame_49[265]
frame_49["cap_49_519_5"] = frame_49[104]
frame_49["cap_49_519_6"] = frame_49[125]
frame_49["cap_49_519_7"] = frame_49[8]
frame_49["cap_49_519_8"] = frame_49[146]
frame_49["cap_49_519_9"] = frame_49[238]
frame_49["cap_49_519_10"] = frame_49[98]
frame_49["cap_49_519_11"] = frame_49[74]
frame_49["cap_49_519_13"] = frame_49[20]
frame_49["cap_49_519_15"] = frame_49[23]
frame_49["cap_49_519_16"] = frame_49[275]
frame_49["cap_49_519_17"] = frame_49[274]
frame_49["cap_49_519_18"] = frame_49[2]
frame_49["cap_49_519_19"] = frame_49[155]
frame_49["cap_49_519_20"] = frame_49[128]
frame_49["cap_49_519_21"] = frame_49[143]
frame_49["cap_49_519_23"] = frame_49[113]
frame_49["cap_49_519_24"] = frame_49[131]
frame_49["cap_49_519_25"] = frame_49[240]
frame_49["cap_49_519_26"] = frame_49[116]
frame_49["cap_49_519_27"] = frame_49[119]
frame_49["cap_49_519_31"] = frame_49[234]
frame_49["cap_49_519_34"] = frame_49[237]
frame_49["cap_49_519_35"] = frame_49[245]
frame_49["cap_49_519_36"] = frame_49[185]
frame_49["cap_49_519_37"] = frame_49[188]
frame_49[276] = function(p43_0)
    local frame_43 = {}
    local cfg_43 = 0
    while true do
        if cfg_43 == 0 then
            frame_43[1] = gGameRules
            frame_43[2] = IsNull
            frame_43[3] = frame_43[2](frame_43[1])
            if not (frame_43[3]) then
                cfg_43 = 2
            else
                cfg_43 = 1
            end
        elseif cfg_43 == 1 then
            frame_43[4] = Sleep
            frame_43[4](0)
            cfg_43 = 0
        elseif cfg_43 == 2 then
            frame_43[6] = gGameRules
            frame_43[7] = gLotusBaseGameRulesType
            frame_43[10] = (frame_43[6]):IsA(frame_43[7])
            if frame_43[10] then
                cfg_43 = 4
            else
                cfg_43 = 3
            end
        elseif cfg_43 == 3 then
            return
        elseif cfg_43 == 4 then
            frame_43[11] = gGameRules
            frame_43[14] = (frame_43[11]):GetMission()
            frame_43[15] = gRegion
            frame_43[18] = (frame_43[15]):GetNpcMgr()
            frame_43[21] = (frame_43[18]):GetAiDirector()
            frame_43[22] = (frame_43[14]).goalTag
            frame_43[23] = true
            frame_43[24] = Symbol
            frame_43[26] = frame_43[24]("ShieldExcav")
            if frame_43[22] == frame_43[26] then
                cfg_43 = 8
            else
                cfg_43 = 5
            end
        elseif cfg_43 == 5 then
            frame_43[27] = Symbol
            frame_43[29] = frame_43[27]("OldWorldSalvage")
            if frame_43[22] == frame_43[29] then
                cfg_43 = 7
            else
                cfg_43 = 6
            end
        elseif cfg_43 == 6 then
            frame_43[23] = false
            cfg_43 = 8
        elseif cfg_43 == 7 then
            frame_43[23] = true
            cfg_43 = 8
        elseif cfg_43 == 8 then
            frame_43[30] = gPlayerProfileMgr
            frame_43[34] = (frame_43[30]):GetPlayerProfile(0)
            if not (frame_43[23]) then
                cfg_43 = 13
            else
                cfg_43 = 9
            end
        elseif cfg_43 == 9 then
            frame_43[36] = shieldDrainExcavatorMat
            p43_0:SetOverrideMaterial(0, frame_43[36])
            frame_43[39] = frame_49["cap_49_519_0"]
            frame_43[42] = p43_0:GetAllAttachments(frame_43[39])
            frame_43[44] = frame_43[42]
            local leave_for_43_11 = false
            for for_value_43_11_0, for_value_43_11_1 in ipairs(frame_43[44]) do
                frame_43[52], frame_43[53] = for_value_43_11_0, for_value_43_11_1
                cfg_43 = 10
                while true do
                    if cfg_43 == 10 then
                        frame_43[49] = shieldDrainPillarMat
                        do (frame_43[53]):SetOverrideMaterial(0, frame_43[49]) end
                        cfg_43 = 11
                    elseif cfg_43 == 11 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_43_11 then break end
            end
            if not leave_for_43_11 then
                cfg_43 = 12
            end
        elseif cfg_43 == 12 then
            frame_43[54] = shieldRingType
            frame_43[55] = EMPTY_SYMBOL
            frame_43[58] = p43_0:Attach(frame_43[54], frame_43[55])
            do (frame_43[58]):SetMeshScale(0.6, true) end
            cfg_43 = 13
        elseif cfg_43 == 13 then
            frame_43[63] = frame_49["cap_49_519_1"]
            frame_43[64] = (frame_43[63]).IsInGamePlay
            frame_43[65] = frame_43[64]()
            if frame_43[65] then
                cfg_43 = 15
            else
                cfg_43 = 14
            end
        elseif cfg_43 == 14 then
            return
        elseif cfg_43 == 15 then
            frame_43[66] = frame_49["cap_49_519_2"]
            frame_43[66]()
            frame_43[67] = 20
            frame_43[68] = 0
            frame_43[69] = false
            frame_43[70] = 0
            frame_43[71] = frame_49[69]
            frame_43[72] = 0
            frame_43[73] = false
            frame_43[74] = (frame_43[14]).goalId
            if frame_43[74] ~= "" then
                cfg_43 = 17
            else
                cfg_43 = 16
            end
        elseif cfg_43 == 16 then
            frame_43[75] = false
            cfg_43 = 18
        elseif cfg_43 == 17 then
            frame_43[75] = true
            cfg_43 = 18
        elseif cfg_43 == 18 then
            frame_43[76] = (frame_43[14]).levelOverride
            frame_43[77] = nil
            frame_43[78] = frame_43[76]
            frame_43[79] = IsNull
            frame_43[80] = frame_43[79](frame_43[78])
            if (frame_43[80] or not (frame_43[75])) then
                cfg_43 = 26
            else
                cfg_43 = 20
            end
        elseif cfg_43 == 20 then
            frame_43[83] = (frame_43[76]):GetFullName()
            frame_43[84] = frame_43[83]
            frame_43[85] = string.find
            frame_43[86] = frame_43[84]
            frame_43[88] = frame_43[85](frame_43[86], "Ice")
            if not (frame_43[88]) then
                cfg_43 = 22
            else
                cfg_43 = 21
            end
        elseif cfg_43 == 21 then
            frame_49[27] = 3
            cfg_43 = 26
        elseif cfg_43 == 22 then
            frame_43[90] = string.find
            frame_43[91] = frame_43[84]
            frame_43[93] = frame_43[90](frame_43[91], "Settlement")
            if not (frame_43[93]) then
                cfg_43 = 25
            else
                cfg_43 = 23
            end
        elseif cfg_43 == 23 then
            frame_43[94] = string.find
            frame_43[95] = (frame_43[14]).goalTag
            frame_43[96] = tostring
            frame_43[97] = frame_43[96](frame_43[95])
            frame_43[99] = frame_43[94](frame_43[97], "Anniversary")
            if frame_43[99] then
                cfg_43 = 25
            else
                cfg_43 = 24
            end
        elseif cfg_43 == 24 then
            frame_49[27] = 2
            cfg_43 = 26
        elseif cfg_43 == 25 then
            frame_49[27] = 1
            cfg_43 = 26
        elseif cfg_43 == 26 then
            frame_43[102] = gRegion
            frame_43[103] = cellItemPickup
            frame_43[106] = (frame_43[102]):Name__88f3b23b(frame_43[103])
            frame_43[107] = print
            frame_43[109] = frame_43[106]
            frame_43[111] = ("Flushed " .. frame_43[109] .. " inactive power cells.")
            frame_43[107](frame_43[111])
            frame_43[112] = gGameRules
            frame_43[113] = frame_49["cap_49_519_5"]
            do (frame_43[112]):SetNetPersistentVar(frame_43[113], 2) end
            frame_43[117] = gGameRules
            frame_43[118] = frame_49["cap_49_519_6"]
            frame_43[122] = (frame_43[117]):GetNetPersistentVar(frame_43[118], 0)
            if frame_43[122] ~= 0 then
                cfg_43 = 28
            else
                cfg_43 = 27
            end
        elseif cfg_43 == 27 then
            frame_43[123] = frame_49["cap_49_519_7"]
            frame_43[124] = (frame_43[123]).PlayGlobalTransmission
            frame_43[125] = _T.MissionTransmissionSet
            frame_43[126] = Symbol
            frame_43[124](frame_43[125], frame_43[126]("MissionExcavatorDeployedFirstTime"))
            cfg_43 = 29
        elseif cfg_43 == 28 then
            frame_43[173] = frame_49["cap_49_519_7"]
            frame_43[174] = (frame_43[173]).PlayGlobalTransmission
            frame_43[175] = _T.MissionTransmissionSet
            frame_43[176] = Symbol
            frame_43[174](frame_43[175], frame_43[176]("MissionExcavatorDeployed"))
            cfg_43 = 29
        elseif cfg_43 == 29 then
            frame_43[223] = (frame_43[122] + 1)
            frame_43[224] = gGameRules
            frame_43[225] = frame_49["cap_49_519_6"]
            frame_43[226] = frame_43[223]
            do (frame_43[224]):SetNetPersistentVar(frame_43[225], frame_43[226]) end
            frame_43[231] = (frame_43[21]):GetMaxEnemyLevel()
            frame_43[232] = gRegion
            frame_43[235] = (frame_43[232]):Name__c988433c()
            frame_43[236] = Name__e7eb854d
            frame_43[238] = frame_43[236]("Server.NumVirtualTestClients")
            frame_43[239] = (frame_43[235] + frame_43[238])
            frame_43[240] = sharedHealthPoolLevelPower
            if frame_43[239] ~= 1 then
                cfg_43 = 31
            else
                cfg_43 = 30
            end
        elseif cfg_43 == 30 then
            frame_43[240] = sharedHealthPoolLevelPowerSolo
            cfg_43 = 31
        elseif cfg_43 == 31 then
            frame_43[241] = gGameRules
            frame_43[242] = frame_49["cap_49_519_8"]
            frame_43[246] = (frame_43[241]):GetNetPersistentVar(frame_43[242], 0)
            frame_43[247] = baseexcavatorHealth
            if not (0 < frame_43[246]) then
                cfg_43 = 33
            else
                cfg_43 = 32
            end
        elseif cfg_43 == 32 then
            frame_43[247] = frame_43[246]
            cfg_43 = 33
        elseif cfg_43 == 33 then
            frame_43[251] = (frame_43[231] ^ frame_43[240])
            frame_43[252] = (0.025 * frame_43[251])
            frame_43[253] = (1 + frame_43[252])
            frame_43[254] = (frame_43[247] * frame_43[253])
            frame_43[255] = baseexcavatorShields
            frame_43[258] = (frame_43[231] ^ frame_43[240])
            frame_43[259] = (0.025 * frame_43[258])
            frame_43[260] = (1 + frame_43[259])
            frame_43[261] = (frame_43[255] * frame_43[260])
            frame_43[262] = frame_43[254]
            p43_0:SetMaxHealth(frame_43[262], true)
            frame_43[268] = p43_0:IsKilled()
            if frame_43[268] then
                cfg_43 = 35
            else
                cfg_43 = 34
            end
        elseif cfg_43 == 34 then
            frame_43[271] = p43_0:GetMaxHealth()
            p43_0:SetHealth(frame_43[271], false)
            cfg_43 = 35
        elseif cfg_43 == 35 then
            frame_43[277] = p43_0:DamageControl()
            frame_43[278] = frame_43[261]
            do (frame_43[277]):SetMaxShield(frame_43[278]) end
            frame_43[283] = p43_0:DamageControl()
            frame_43[286] = p43_0:DamageControl()
            do (frame_43[283]):SetShield((frame_43[286]):GetMaxShield()) end
            frame_43[329] = excavatorSpawnInvulnerabilityDuration
            if not (0 < frame_43[329]) then
                cfg_43 = 37
            else
                cfg_43 = 36
            end
        elseif cfg_43 == 36 then
            frame_43[333] = p43_0:DamageControl()
            frame_43[334] = excavatorSpawnInvulnerabilityDuration
            frame_43[335] = excavatorSpawnInvulnerabilityDuration
            do (frame_43[333]):GiveTemporaryImmunity(frame_43[334], frame_43[335]) end
            cfg_43 = 37
        elseif cfg_43 == 37 then
            frame_43[338] = Sleep
            frame_43[338](0.1)
            frame_43[340] = frame_43[231]
            p43_0:SetLevel(frame_43[340])
            frame_43[343] = gRegion
            frame_43[344] = gLotusExcavationStateType
            frame_43[347] = p43_0:GetPosition()
            frame_43[351] = (frame_43[343]):FindNearest(frame_43[344], frame_43[347], 5)
            frame_43[352] = frame_43[351]
            frame_43[353] = IsNull
            frame_43[354] = frame_43[353](frame_43[352])
            if not (frame_43[354]) then
                cfg_43 = 39
            else
                cfg_43 = 38
            end
        elseif cfg_43 == 38 then
            frame_43[355] = excavatorAnim
            p43_0:PlayAnimation(frame_43[355], false, 2, 2)
            return
        elseif cfg_43 == 39 then
            frame_43[361] = p43_0
            do (frame_43[21]):SetObjective(frame_43[361]) end
            frame_43[364] = p43_0
            do (frame_43[21]):Name__7fccb7d5(frame_43[364]) end
            frame_43[367] = print
            frame_43[371] = p43_0:GetFullName()
            frame_43[372] = ("SetObjective " .. frame_43[371])
            frame_43[367](frame_43[372])
            frame_43[373] = excavatorAnim
            p43_0:PlayAnimation(frame_43[373], false, 2, 2)
            do (frame_43[351]):Enable(true) end
            frame_43[382] = p43_0
            do (frame_43[351]):SetAvatar(frame_43[382]) end
            frame_43[385] = frame_43[223]
            do (frame_43[351]):SetInstanceNumber(frame_43[385]) end
            frame_43[388] = gParticleSysType
            frame_43[391] = p43_0:GetAllAttachments(frame_43[388])
            frame_43[392] = gSequencerType
            frame_43[395] = p43_0:GetAllAttachments(frame_43[392])
            frame_43[396] = pillarType
            frame_43[399] = p43_0:GetAttachment(frame_43[396])
            frame_43[400] = frame_49["cap_49_519_9"]
            frame_43[401] = frame_43[399]
            frame_43[402] = frame_43[391]
            frame_43[403] = frame_43[395]
            frame_43[400](frame_43[401], frame_43[402], frame_43[403], true)
            frame_43[405] = true
            frame_43[406] = false
            frame_43[409] = p43_0:DamageControl()
            frame_43[410] = excavatorMarkerTypes
            frame_43[411] = (#frame_43[410])
            frame_43[412] = (frame_43[223] % frame_43[411])
            if frame_43[412] ~= 0 then
                cfg_43 = 41
            else
                cfg_43 = 40
            end
        elseif cfg_43 == 40 then
            frame_43[413] = excavatorMarkerTypes
            frame_43[412] = (#frame_43[413])
            cfg_43 = 41
        elseif cfg_43 == 41 then
            frame_43[414] = gRegion
            frame_43[415] = frame_49["cap_49_519_10"]
            frame_43[418] = p43_0:GetPosition()
            frame_43[423] = (frame_43[414]):FindFirstTaggedInRadius(frame_43[415], frame_43[418], 0, 5)
            frame_43[424] = frame_43[423]
            frame_43[425] = IsNull
            frame_43[426] = frame_43[425](frame_43[424])
            if frame_43[426] then
                cfg_43 = 43
            else
                cfg_43 = 42
            end
        elseif cfg_43 == 42 then
            do (frame_43[423]):Disable() end
            cfg_43 = 43
        elseif cfg_43 == 43 then
            frame_43[429] = excavatorMarkerTypes
            frame_43[430] = frame_43[429][frame_43[412]]
            frame_43[431] = EMPTY_SYMBOL
            frame_43[432] = Vector
            p43_0:Attach(frame_43[430], frame_43[431], frame_43[432](0, 1.5, 0))
            frame_43[465] = _T
            frame_43[466] = gGameRules
            frame_43[467] = frame_49["cap_49_519_11"]
            frame_43[470] = (frame_43[466]):GetMissionTimeLeft(frame_43[467])
            frame_43[465].LastActivityTime = frame_43[470]
            frame_43[471] = frame_49[212]
            if not (frame_43[471]) then
                cfg_43 = 46
            else
                cfg_43 = 44
            end
        elseif cfg_43 == 44 then
            frame_43[472] = gRegion
            frame_43[475] = (frame_43[472]):IsMaster()
            if not (frame_43[475]) then
                cfg_43 = 47
            else
                cfg_43 = 45
            end
        elseif cfg_43 == 45 then
            frame_43[476] = frame_49["cap_49_519_13"]
            frame_43[477] = (frame_43[476]).IsGameModeInProgress
            frame_43[475] = frame_43[477]()
            cfg_43 = 47
        elseif cfg_43 == 46 then
            frame_43[475] = gPromotedToHost
            cfg_43 = 47
        elseif cfg_43 == 47 then
            if not (frame_43[475]) then
                cfg_43 = 50
            else
                cfg_43 = 48
            end
        elseif cfg_43 == 48 then
            frame_43[480] = (frame_43[351]):GetPower()
            if frame_43[480] == 0 then
                cfg_43 = 50
            else
                cfg_43 = 49
            end
        elseif cfg_43 == 49 then
            frame_43[67] = frame_43[480]
            frame_43[483] = (frame_43[351]):GetTimer()
            frame_43[70] = (frame_43[71] - frame_43[483])
            cfg_43 = 50
        elseif cfg_43 == 50 then
            frame_43[484] = Symbol
            frame_43[486] = math.random
            frame_43[487] = frame_43[486]()
            frame_43[488] = ("Excavator" .. frame_43[487])
            frame_43[489] = frame_43[484](frame_43[488])
            frame_43[490] = 0
            frame_43[491] = false
            frame_43[492] = false
            frame_43[493] = _T.ExcavatorHealthTransmissionState
            frame_43[494] = IsNull
            frame_43[495] = frame_43[494](frame_43[493])
            if not (frame_43[495]) then
                cfg_43 = 52
            else
                cfg_43 = 51
            end
        elseif cfg_43 == 51 then
            frame_43[496] = _T
            frame_43[497] = {}
            frame_43[496].ExcavatorHealthTransmissionState = frame_43[497]
            cfg_43 = 52
        elseif cfg_43 == 52 then
            frame_43[498] = _T.ExcavatorHealthTransmissionState
            frame_43[501] = (frame_43[351]):GetInstanceNumber()
            frame_43[502] = { heavyDamage = false, damaged = false }
            frame_43[503] = table.insert
            frame_43[503](frame_43[498], frame_43[501], frame_43[502])
            frame_43[504] = frame_49["cap_49_519_15"]
            frame_43[505] = (frame_43[504]).CreateTimerMgr
            frame_43[506] = frame_43[505]()
            frame_49[30] = frame_43[506]
            frame_43[507] = frame_49[30]
            frame_43[509] = frame_49["cap_49_519_16"]
            do (frame_43[507]):AddTimer(60, frame_43[509]) end
            cfg_43 = 53
        elseif cfg_43 == 53 then
            frame_43[512] = p43_0
            frame_43[513] = IsNull
            frame_43[514] = frame_43[513](frame_43[512])
            if frame_43[514] then
                cfg_43 = 128
            else
                cfg_43 = 54
            end
        elseif cfg_43 == 54 then
            frame_43[517] = p43_0:IsKilled()
            if frame_43[517] then
                cfg_43 = 128
            else
                cfg_43 = 55
            end
        elseif cfg_43 == 55 then
            frame_43[518] = frame_43[351]
            frame_43[519] = IsNull
            frame_43[520] = frame_43[519](frame_43[518])
            if frame_43[520] then
                cfg_43 = 128
            else
                cfg_43 = 56
            end
        elseif cfg_43 == 56 then
            frame_43[521] = gRegion
            frame_43[524] = (frame_43[521]):GetHumanPlayerAvatars()
            frame_43[527] = p43_0:GetPosition()
            if not (frame_43[23]) then
                cfg_43 = 64
            else
                cfg_43 = 57
            end
        elseif cfg_43 == 57 then
            if frame_43[491] then
                cfg_43 = 95
            else
                cfg_43 = 58
            end
        elseif cfg_43 == 58 then
            if not (0.2 < frame_43[490]) then
                cfg_43 = 60
            else
                cfg_43 = 59
            end
        elseif cfg_43 == 59 then
            frame_43[529] = 0
            frame_43[530] = frame_49["cap_49_519_17"]
            frame_43[531] = frame_43[524]
            frame_43[532] = frame_43[527]
            frame_43[533] = frame_43[489]
            frame_43[534] = frame_43[67]
            frame_43[535] = frame_43[70]
            frame_43[536], frame_43[537] = frame_43[530](frame_43[531], frame_43[532], frame_43[533], frame_43[534], frame_43[535])
            frame_43[538] = frame_43[536]
            frame_43[491] = frame_43[537]
            frame_43[539] = (frame_43[67] + frame_43[538])
            frame_43[540] = frame_49[69]
            frame_43[541] = math.min
            frame_43[542] = frame_43[541](frame_43[539], frame_43[540])
            frame_43[67] = frame_43[542]
            frame_43[490] = 0
            cfg_43 = 61
        elseif cfg_43 == 60 then
            frame_43[543] = Name__3b4b94b0
            frame_43[544] = frame_43[543]()
            frame_43[490] = (frame_43[490] + frame_43[544])
            cfg_43 = 61
        elseif cfg_43 == 61 then
            if not (frame_43[491]) then
                cfg_43 = 95
            else
                cfg_43 = 62
            end
        elseif cfg_43 == 62 then
            frame_43[545] = shieldRingType
            frame_43[548] = p43_0:GetAttachment(frame_43[545])
            frame_43[549] = frame_43[548]
            frame_43[550] = IsNull
            frame_43[551] = frame_43[550](frame_43[549])
            if frame_43[551] then
                cfg_43 = 95
            else
                cfg_43 = 63
            end
        elseif cfg_43 == 63 then
            do (frame_43[548]):Destroy() end
            cfg_43 = 95
        elseif cfg_43 == 64 then
            frame_43[554] = frame_49["cap_49_519_18"]
            frame_43[555] = (frame_43[554]).Round
            frame_43[582] = frame_43[555]((frame_43[351]):GetPower())
            frame_43[585] = (frame_43[351]):GetTimer()
            frame_43[586] = math.floor
            frame_43[587] = frame_43[586](frame_43[585])
            frame_43[590] = (frame_43[409]):GetShield()
            frame_43[593] = (frame_43[409]):GetMaxShield()
            if (not (frame_43[582] < frame_43[587]) and not (frame_43[590] < frame_43[593])) then
                cfg_43 = 89
            else
                cfg_43 = 66
            end
        elseif cfg_43 == 66 then
            frame_43[595] = frame_43[524]
            local leave_for_43_88 = false
            for for_value_43_88_0, for_value_43_88_1 in ipairs(frame_43[595]) do
                frame_43[719], frame_43[720] = for_value_43_88_0, for_value_43_88_1
                cfg_43 = 67
                while true do
                    if cfg_43 == 67 then
                        frame_43[599] = gLotusVehicleAvatarType
                        frame_43[602] = (frame_43[720]):IsA(frame_43[599])
                        if not (frame_43[602]) then
                            cfg_43 = 71
                        else
                            cfg_43 = 68
                        end
                    elseif cfg_43 == 68 then
                        frame_43[605] = (frame_43[720]):IsHoverboard()
                        if not (frame_43[605]) then
                            cfg_43 = 71
                        else
                            cfg_43 = 69
                        end
                    elseif cfg_43 == 69 then
                        frame_43[608] = (frame_43[720]):GetRider()
                        if not (frame_43[608]) then
                            cfg_43 = 71
                        else
                            cfg_43 = 70
                        end
                    elseif cfg_43 == 70 then
                        frame_43[611] = (frame_43[720]):GetRider()
                        cfg_43 = 72
                    elseif cfg_43 == 71 then
                        frame_43[611] = frame_43[720]
                        cfg_43 = 72
                    elseif cfg_43 == 72 then
                        frame_43[612] = cellItemType
                        frame_43[615] = (frame_43[611]):HasItem(frame_43[612])
                        if not (frame_43[615]) then
                            cfg_43 = 88
                        else
                            cfg_43 = 73
                        end
                    elseif cfg_43 == 73 then
                        frame_43[616] = frame_43[527]
                        frame_43[619] = (frame_43[720]):DistanceToPoint(frame_43[616])
                        if frame_43[619] < 5 then
                            cfg_43 = 75
                        else
                            cfg_43 = 74
                        end
                    elseif cfg_43 == 74 then
                        frame_43[621] = false
                        cfg_43 = 76
                    elseif cfg_43 == 75 then
                        frame_43[621] = true
                        cfg_43 = 76
                    elseif cfg_43 == 76 then
                        if not (frame_43[621]) then
                            cfg_43 = 88
                        else
                            cfg_43 = 77
                        end
                    elseif cfg_43 == 77 then
                        frame_43[624] = (frame_43[720]):GetPlayer()
                        frame_43[627] = (frame_43[611]):InventoryControl()
                        frame_43[630] = (frame_43[627]):Name__4ee25a12()
                        frame_43[631] = frame_49["cap_49_519_18"]
                        frame_43[632] = (frame_43[631]).Round
                        frame_43[634] = (20 * frame_43[630])
                        frame_43[635] = frame_49[69]
                        frame_43[636] = (frame_43[635] - frame_43[67])
                        frame_43[637] = math.min
                        frame_43[638] = frame_43[637](frame_43[634], frame_43[636])
                        frame_43[639] = frame_43[632](frame_43[638])
                        frame_43[640] = gGameRules
                        frame_43[641] = frame_43[624]
                        frame_43[648] = frame_43[639]
                        frame_43[649] = tostring
                        frame_43[650] = frame_43[649](frame_43[648])
                        do (frame_43[640]):DisplayMessage(frame_43[641], "/Lotus/Language/Game/GainedPower", "", 0, 2, true, "AMOUNT", frame_43[650]) end
                        frame_43[67] = (frame_43[67] + frame_43[639])
                        if (not (frame_43[587] < frame_43[67]) or frame_43[406]) then
                            cfg_43 = 80
                        else
                            cfg_43 = 79
                        end
                    elseif cfg_43 == 79 then
                        frame_43[406] = true
                        frame_43[653] = frame_49["cap_49_519_7"]
                        frame_43[654] = (frame_43[653]).PlayGlobalTransmission
                        frame_43[655] = _T.MissionTransmissionSet
                        frame_43[656] = Symbol
                        frame_43[654](frame_43[655], frame_43[656]("MissionExcavatorFull"))
                        cfg_43 = 80
                    elseif cfg_43 == 80 then
                        frame_43[667] = cellItemType
                        do (frame_43[611]):RemoveItem(frame_43[667]) end
                        frame_43[670] = cellDeliverySound
                        do (frame_43[720]):PlaySound(frame_43[670], false) end
                        frame_43[674] = _T
                        frame_43[674].PlayerHasDeliveredCell = true
                        frame_43[676] = _T
                        frame_43[677] = gGameRules
                        frame_43[678] = frame_49["cap_49_519_11"]
                        frame_43[681] = (frame_43[677]):GetMissionTimeLeft(frame_43[678])
                        frame_43[676].LastActivityTime = frame_43[681]
                        frame_43[682] = frame_43[624]
                        frame_43[683] = IsNull
                        frame_43[684] = frame_43[683](frame_43[682])
                        if frame_43[684] then
                            cfg_43 = 83
                        else
                            cfg_43 = 81
                        end
                    elseif cfg_43 == 81 then
                        frame_43[687] = (frame_43[624]):GetStats()
                        frame_43[688] = frame_43[687]
                        frame_43[689] = IsNull
                        frame_43[690] = frame_43[689](frame_43[688])
                        if frame_43[690] then
                            cfg_43 = 83
                        else
                            cfg_43 = 82
                        end
                    elseif cfg_43 == 82 then
                        do (frame_43[687]):Name__e6196dda() end
                        cfg_43 = 83
                    elseif cfg_43 == 83 then
                        if not (frame_43[590] < frame_43[593]) then
                            cfg_43 = 86
                        else
                            cfg_43 = 84
                        end
                    elseif cfg_43 == 84 then
                        frame_43[693] = shieldOverlayType
                        frame_43[696] = p43_0:HasAttachment(frame_43[693])
                        if frame_43[696] then
                            cfg_43 = 86
                        else
                            cfg_43 = 85
                        end
                    elseif cfg_43 == 85 then
                        frame_43[697] = shieldOverlayType
                        frame_43[698] = EMPTY_SYMBOL
                        p43_0:Attach(frame_43[697], frame_43[698])
                        cfg_43 = 86
                    elseif cfg_43 == 86 then
                        frame_43[701] = frame_43[593]
                        do (frame_43[409]):SetShield(frame_43[701]) end
                        frame_43[704] = batteryBeamType
                        frame_43[707] = (frame_43[720]):HasAttachment(frame_43[704])
                        if frame_43[707] then
                            cfg_43 = 88
                        else
                            cfg_43 = 87
                        end
                    elseif cfg_43 == 87 then
                        frame_43[710] = (frame_43[720]):DamageControl()
                        frame_43[714] = (frame_43[710]):Name__b7c91969(0)
                        frame_43[715] = batteryBeamType
                        frame_43[716] = frame_43[714]
                        do (frame_43[720]):Attach(frame_43[715], frame_43[716]) end
                        cfg_43 = 88
                    elseif cfg_43 == 88 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_43_88 then break end
            end
            if not leave_for_43_88 then
                cfg_43 = 89
            end
        elseif cfg_43 == 89 then
            frame_43[723] = p43_0:GetHealthPercentage()
            frame_43[724] = _T.ExcavatorHealthTransmissionState
            frame_43[727] = (frame_43[351]):GetInstanceNumber()
            frame_43[728] = frame_43[724][frame_43[727]]
            if not (frame_43[723] <= 0.25) then
                cfg_43 = 92
            else
                cfg_43 = 90
            end
        elseif cfg_43 == 90 then
            frame_43[730] = (frame_43[728]).heavyDamage
            if frame_43[730] then
                cfg_43 = 92
            else
                cfg_43 = 91
            end
        elseif cfg_43 == 91 then
            frame_43[731] = frame_49["cap_49_519_7"]
            frame_43[732] = (frame_43[731]).PlayGlobalTransmission
            frame_43[733] = _T.MissionTransmissionSet
            frame_43[734] = Symbol
            frame_43[732](frame_43[733], frame_43[734]("MissionExcavatorHeavyDamaged"))
            frame_43[728].heavyDamage = true
            cfg_43 = 95
        elseif cfg_43 == 92 then
            if not (frame_43[723] <= 0.75) then
                cfg_43 = 95
            else
                cfg_43 = 93
            end
        elseif cfg_43 == 93 then
            frame_43[755] = (frame_43[728]).damaged
            if frame_43[755] then
                cfg_43 = 95
            else
                cfg_43 = 94
            end
        elseif cfg_43 == 94 then
            frame_43[756] = frame_49["cap_49_519_7"]
            frame_43[757] = (frame_43[756]).PlayGlobalTransmission
            frame_43[758] = _T.MissionTransmissionSet
            frame_43[759] = Symbol
            frame_43[757](frame_43[758], frame_43[759]("MissionExcavatorDamaged"))
            frame_43[728].damaged = true
            cfg_43 = 95
        elseif cfg_43 == 95 then
            if (not (frame_43[67] <= 0) or not (frame_43[405])) then
                cfg_43 = 101
            else
                cfg_43 = 97
            end
        elseif cfg_43 == 97 then
            frame_43[780] = frame_49["cap_49_519_9"]
            frame_43[781] = frame_43[399]
            frame_43[782] = frame_43[391]
            frame_43[783] = frame_43[395]
            frame_43[780](frame_43[781], frame_43[782], frame_43[783], false)
            frame_43[405] = false
            frame_43[492] = true
            p43_0:PlayAnimation(nil, false, 2, 2)
            if not (frame_43[23]) then
                cfg_43 = 99
            else
                cfg_43 = 98
            end
        elseif cfg_43 == 98 then
            frame_43[791] = frame_49["cap_49_519_7"]
            frame_43[792] = (frame_43[791]).PlayGlobalTransmission
            frame_43[793] = _T.MissionTransmissionSet
            frame_43[794] = Symbol
            frame_43[792](frame_43[793], frame_43[794]("MissionExcavatorUnpoweredShield"))
            cfg_43 = 100
        elseif cfg_43 == 99 then
            frame_43[819] = frame_49["cap_49_519_7"]
            frame_43[820] = (frame_43[819]).PlayGlobalTransmission
            frame_43[821] = _T.MissionTransmissionSet
            frame_43[822] = Symbol
            frame_43[820](frame_43[821], frame_43[822]("MissionExcavatorUnpowered"))
            cfg_43 = 100
        elseif cfg_43 == 100 then
            frame_43[847] = p43_0
            do (frame_43[21]):SetObjective(frame_43[847]) end
            frame_43[850] = p43_0
            do (frame_43[21]):Name__7fccb7d5(frame_43[850]) end
            cfg_43 = 104
        elseif cfg_43 == 101 then
            if (not (0 < frame_43[67]) or frame_43[405]) then
                cfg_43 = 104
            else
                cfg_43 = 103
            end
        elseif cfg_43 == 103 then
            frame_43[854] = frame_49["cap_49_519_9"]
            frame_43[855] = frame_43[399]
            frame_43[856] = frame_43[391]
            frame_43[857] = frame_43[395]
            frame_43[854](frame_43[855], frame_43[856], frame_43[857], true)
            frame_43[405] = true
            frame_43[859] = excavatorAnim
            p43_0:PlayAnimation(frame_43[859], false, 2, 2)
            cfg_43 = 104
        elseif cfg_43 == 104 then
            frame_43[865] = Name__3b4b94b0
            frame_43[866] = frame_43[865]()
            if not (0 < frame_43[67]) then
                cfg_43 = 106
            else
                cfg_43 = 105
            end
        elseif cfg_43 == 105 then
            frame_43[70] = (frame_43[70] + frame_43[866])
            cfg_43 = 106
        elseif cfg_43 == 106 then
            frame_43[868] = (frame_43[866] * 1)
            frame_43[869] = (frame_43[67] - frame_43[868])
            frame_43[871] = math.max
            frame_43[872] = frame_43[871](frame_43[869], 0)
            frame_43[67] = frame_43[872]
            frame_43[873] = frame_43[34]
            frame_43[874] = IsNull
            frame_43[875] = frame_43[874](frame_43[873])
            if frame_43[875] then
                cfg_43 = 117
            else
                cfg_43 = 107
            end
        elseif cfg_43 == 107 then
            frame_43[878] = (frame_43[34]):Settings()
            frame_43[881] = (frame_43[878]):EnableTutorialTransmissions()
            if not (frame_43[881]) then
                cfg_43 = 117
            else
                cfg_43 = 108
            end
        elseif cfg_43 == 108 then
            if not (frame_43[67] <= 0) then
                cfg_43 = 115
            else
                cfg_43 = 109
            end
        elseif cfg_43 == 109 then
            if frame_43[69] then
                cfg_43 = 117
            else
                cfg_43 = 110
            end
        elseif cfg_43 == 110 then
            frame_43[68] = (frame_43[68] + frame_43[866])
            if not (30 <= frame_43[68]) then
                cfg_43 = 117
            else
                cfg_43 = 111
            end
        elseif cfg_43 == 111 then
            frame_43[884] = _T.ShowImpactMessage
            if not (frame_43[884]) then
                cfg_43 = 114
            else
                cfg_43 = 112
            end
        elseif cfg_43 == 112 then
            frame_43[885] = _T.PlayerHasDeliveredCell
            if frame_43[885] then
                cfg_43 = 114
            else
                cfg_43 = 113
            end
        elseif cfg_43 == 113 then
            frame_43[886] = _T.ShowImpactMessage
            frame_43[886]("/Lotus/Language/GameModes/ExcavatorOutOfPower", 10)
            cfg_43 = 114
        elseif cfg_43 == 114 then
            frame_43[69] = true
            cfg_43 = 117
        elseif cfg_43 == 115 then
            frame_43[68] = 0
            frame_43[889] = _T.HintActive
            if not (frame_43[889]) then
                cfg_43 = 117
            else
                cfg_43 = 116
            end
        elseif cfg_43 == 116 then
            frame_43[890] = _T.HideImpactMessage
            frame_43[890]()
            cfg_43 = 117
        elseif cfg_43 == 117 then
            frame_43[891] = (frame_43[70] + 0.05)
            if not (frame_43[71] <= frame_43[891]) then
                cfg_43 = 119
            else
                cfg_43 = 118
            end
        elseif cfg_43 == 118 then
            frame_43[73] = true
            cfg_43 = 128
        elseif cfg_43 == 119 then
            frame_43[892] = _T.MissionDebug
            if not (frame_43[892]) then
                cfg_43 = 122
            else
                cfg_43 = 120
            end
        elseif cfg_43 == 120 then
            frame_43[893] = _T.MissionDebug.FastDig
            if not (frame_43[893]) then
                cfg_43 = 122
            else
                cfg_43 = 121
            end
        elseif cfg_43 == 121 then
            frame_43[71] = 20
            cfg_43 = 122
        elseif cfg_43 == 122 then
            frame_43[894] = frame_43[351]
            frame_43[895] = IsNull
            frame_43[896] = frame_43[895](frame_43[894])
            if frame_43[896] then
                cfg_43 = 124
            else
                cfg_43 = 123
            end
        elseif cfg_43 == 123 then
            frame_43[897] = frame_43[67]
            do (frame_43[351]):SetPower(frame_43[897]) end
            frame_43[900] = (frame_43[71] - frame_43[70])
            do (frame_43[351]):SetTimer(frame_43[900]) end
            cfg_43 = 124
        elseif cfg_43 == 124 then
            frame_43[903] = frame_49[212]
            if not (frame_43[903]) then
                cfg_43 = 127
            else
                cfg_43 = 125
            end
        elseif cfg_43 == 125 then
            frame_43[904] = gGameRules
            frame_43[905] = frame_49["cap_49_519_19"]
            frame_43[908] = (frame_43[904]):GetNetPersistentVar(frame_43[905])
            if frame_43[908] ~= 1 then
                cfg_43 = 127
            else
                cfg_43 = 126
            end
        elseif cfg_43 == 126 then
            return
        elseif cfg_43 == 127 then
            frame_43[909] = frame_49[30]
            frame_43[910] = frame_43[866]
            do (frame_43[909]):Update(frame_43[910]) end
            frame_43[913] = Sleep
            frame_43[913](0)
            cfg_43 = 53
        elseif cfg_43 == 128 then
            frame_43[915] = gGameRules
            frame_43[916] = frame_49["cap_49_519_20"]
            frame_43[920] = (frame_43[915]):GetNetPersistentVar(frame_43[916], 0)
            frame_43[921] = (frame_43[920] + 1)
            frame_43[922] = gGameRules
            frame_43[923] = frame_49["cap_49_519_20"]
            frame_43[924] = frame_43[921]
            do (frame_43[922]):SetNetPersistentVar(frame_43[923], frame_43[924]) end
            frame_43[927] = gGameRules
            frame_43[928] = frame_49["cap_49_519_21"]
            frame_43[932] = (frame_43[927]):GetNetPersistentVar(frame_43[928], 0)
            if not (frame_43[73]) then
                cfg_43 = 131
            else
                cfg_43 = 129
            end
        elseif cfg_43 == 129 then
            frame_43[933] = frame_49[70]
            frame_43[934] = gGameRules
            frame_43[935] = frame_49["cap_49_519_23"]
            frame_43[939] = (frame_43[934]):GetNetPersistentVar(frame_43[935], 0)
            frame_43[940] = gGameRules
            frame_43[941] = frame_49["cap_49_519_24"]
            frame_43[942] = frame_43[939]
            do (frame_43[940]):SetNetPersistentVar(frame_43[941], frame_43[942]) end
            frame_43[932] = (frame_43[932] + 1)
            frame_43[945] = gGameRules
            frame_43[946] = frame_49["cap_49_519_21"]
            frame_43[947] = frame_43[932]
            do (frame_43[945]):SetNetPersistentVar(frame_43[946], frame_43[947]) end
            if frame_43[492] then
                cfg_43 = 132
            else
                cfg_43 = 130
            end
        elseif cfg_43 == 130 then
            frame_43[950] = gChallengeMgr
            frame_43[951] = Symbol
            do (frame_43[950]):Name__ed305ebd(frame_43[951]("EXCAVATION_COMPLETED_WITHOUT_LOSING_POWER")) end
            cfg_43 = 132
        elseif cfg_43 == 131 then
            frame_43[977] = frame_49["cap_49_519_18"]
            frame_43[978] = (frame_43[977]).Round
            frame_43[979] = frame_49[70]
            frame_43[980] = (frame_43[70] / frame_43[71])
            frame_43[981] = (frame_43[979] * frame_43[980])
            frame_43[982] = frame_43[978](frame_43[981])
            frame_43[933] = frame_43[982]
            frame_43[983] = frame_49["cap_49_519_7"]
            frame_43[984] = (frame_43[983]).PlayGlobalTransmission
            frame_43[985] = _T.MissionTransmissionSet
            frame_43[986] = Symbol
            frame_43[984](frame_43[985], frame_43[986]("MissionExcavatorDestroyed"))
            cfg_43 = 132
        elseif cfg_43 == 132 then
            if not (frame_43[23]) then
                cfg_43 = 136
            else
                cfg_43 = 133
            end
        elseif cfg_43 == 133 then
            frame_43[1011] = gRegion
            frame_43[1014] = (frame_43[1011]):GetHumanPlayerAvatars()
            frame_43[1016] = frame_43[1014]
            local leave_for_43_135 = false
            for for_value_43_135_0, for_value_43_135_1 in ipairs(frame_43[1016]) do
                frame_43[1024], frame_43[1025] = for_value_43_135_0, for_value_43_135_1
                cfg_43 = 134
                while true do
                    if cfg_43 == 134 then
                        frame_43[1020] = frame_49["cap_49_519_25"]
                        frame_43[1021] = frame_43[1025]
                        frame_43[1022] = beamType
                        frame_43[1023] = frame_43[489]
                        frame_43[1020](frame_43[1021], frame_43[1022], frame_43[1023])
                        cfg_43 = 135
                    elseif cfg_43 == 135 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_43_135 then break end
            end
            if not leave_for_43_135 then
                cfg_43 = 136
            end
        elseif cfg_43 == 136 then
            frame_43[1026] = frame_43[933]
            frame_43[1028] = math.max
            frame_43[1029] = frame_43[1028](frame_43[1026], 1)
            frame_43[1030] = frame_43[1029]
            frame_43[1031] = gGameRules
            frame_43[1032] = frame_49["cap_49_519_26"]
            frame_43[1036] = (frame_43[1031]):GetNetPersistentVar(frame_43[1032], 0)
            frame_43[1037] = (frame_43[1036] + frame_43[1030])
            frame_43[1038] = gGameRules
            frame_43[1039] = frame_49["cap_49_519_26"]
            frame_43[1040] = frame_43[1037]
            do (frame_43[1038]):SetNetPersistentVar(frame_43[1039], frame_43[1040]) end
            frame_43[1043] = gGameRules
            frame_43[1044] = frame_49["cap_49_519_27"]
            frame_43[1048] = (frame_43[1043]):GetNetPersistentVar(frame_43[1044], 0)
            frame_43[1049] = frame_49[27]
            frame_43[1050] = (frame_43[1030] * frame_43[1049])
            frame_43[1051] = (frame_43[1048] + frame_43[1050])
            frame_43[1052] = gGameRules
            frame_43[1053] = frame_49["cap_49_519_27"]
            frame_43[1054] = frame_43[1051]
            do (frame_43[1052]):SetNetPersistentVar(frame_43[1053], frame_43[1054]) end
            frame_43[1057] = 500
            frame_43[1058] = frame_49[213]
            if frame_43[1058] then
                cfg_43 = 138
            else
                cfg_43 = 137
            end
        elseif cfg_43 == 137 then
            frame_43[1058] = (frame_43[14]).maxWaveNum
            cfg_43 = 138
        elseif cfg_43 == 138 then
            if not (0 < frame_43[1058]) then
                cfg_43 = 140
            else
                cfg_43 = 139
            end
        elseif cfg_43 == 139 then
            frame_43[1060] = frame_49[70]
            frame_43[1057] = (frame_43[1058] * frame_43[1060])
            cfg_43 = 140
        elseif cfg_43 == 140 then
            frame_43[1061] = _T.HasPlayedHalfwayTransmission
            frame_43[1062] = IsNull
            frame_43[1063] = frame_43[1062](frame_43[1061])
            if not (frame_43[1063]) then
                cfg_43 = 142
            else
                cfg_43 = 141
            end
        elseif cfg_43 == 141 then
            frame_43[1064] = _T
            frame_43[1064].HasPlayedHalfwayTransmission = false
            cfg_43 = 142
        elseif cfg_43 == 142 then
            frame_43[1066] = (frame_43[1057] / 2)
            if not (frame_43[1066] < frame_43[1051]) then
                cfg_43 = 145
            else
                cfg_43 = 143
            end
        elseif cfg_43 == 143 then
            frame_43[1067] = _T.HasPlayedHalfwayTransmission
            if frame_43[1067] then
                cfg_43 = 145
            else
                cfg_43 = 144
            end
        elseif cfg_43 == 144 then
            frame_43[1068] = _T
            frame_43[1068].HasPlayedHalfwayTransmission = true
            frame_43[1070] = frame_49["cap_49_519_7"]
            frame_43[1071] = (frame_43[1070]).PlayGlobalTransmission
            frame_43[1072] = _T.MissionTransmissionSet
            frame_43[1073] = Symbol
            frame_43[1071](frame_43[1072], frame_43[1073]("MissionHalfway"))
            cfg_43 = 145
        elseif cfg_43 == 145 then
            frame_43[1094] = frame_49[205]
            if not (frame_43[1094]) then
                cfg_43 = 147
            else
                cfg_43 = 146
            end
        elseif cfg_43 == 146 then
            frame_43[1095] = _T
            frame_43[1095].extractionAvailable = true
            cfg_43 = 179
        elseif cfg_43 == 147 then
            frame_43[1097] = frame_49[208]
            if not (frame_43[1097]) then
                cfg_43 = 158
            else
                cfg_43 = 148
            end
        elseif cfg_43 == 148 then
            frame_43[1098] = false
            frame_43[1099] = frame_49["cap_49_519_31"]
            frame_43[1100] = frame_43[1099]()
            if not (frame_43[1100]) then
                cfg_43 = 154
            else
                cfg_43 = 149
            end
        elseif cfg_43 == 149 then
            frame_43[1101] = false
            if not (frame_43[1058] <= frame_43[921]) then
                cfg_43 = 153
            else
                cfg_43 = 150
            end
        elseif cfg_43 == 150 then
            if 0 < frame_43[932] then
                cfg_43 = 152
            else
                cfg_43 = 151
            end
        elseif cfg_43 == 151 then
            frame_43[1101] = false
            cfg_43 = 153
        elseif cfg_43 == 152 then
            frame_43[1101] = true
            cfg_43 = 153
        elseif cfg_43 == 153 then
            frame_43[1103] = frame_43[1101]
            cfg_43 = 157
        elseif cfg_43 == 154 then
            if frame_43[1058] <= frame_43[921] then
                cfg_43 = 156
            else
                cfg_43 = 155
            end
        elseif cfg_43 == 155 then
            frame_43[1103] = false
            cfg_43 = 157
        elseif cfg_43 == 156 then
            frame_43[1103] = true
            cfg_43 = 157
        elseif cfg_43 == 157 then
            frame_43[1104] = _T
            frame_43[1104].extractionAvailable = frame_43[1103]
            cfg_43 = 179
        elseif cfg_43 == 158 then
            frame_43[1105] = frame_49[206]
            if not (frame_43[1105]) then
                cfg_43 = 163
            else
                cfg_43 = 159
            end
        elseif cfg_43 == 159 then
            frame_43[1106] = _T
            if frame_43[1057] <= frame_43[1037] then
                cfg_43 = 161
            else
                cfg_43 = 160
            end
        elseif cfg_43 == 160 then
            frame_43[1107] = false
            cfg_43 = 162
        elseif cfg_43 == 161 then
            frame_43[1107] = true
            cfg_43 = 162
        elseif cfg_43 == 162 then
            frame_43[1106].extractionAvailable = frame_43[1107]
            cfg_43 = 179
        elseif cfg_43 == 163 then
            frame_43[1108] = frame_49[207]
            if not (frame_43[1108]) then
                cfg_43 = 169
            else
                cfg_43 = 164
            end
        elseif cfg_43 == 164 then
            frame_43[1109] = _T
            frame_43[1110] = false
            if not (200 <= frame_43[1051]) then
                cfg_43 = 168
            else
                cfg_43 = 165
            end
        elseif cfg_43 == 165 then
            if 0 < frame_43[932] then
                cfg_43 = 167
            else
                cfg_43 = 166
            end
        elseif cfg_43 == 166 then
            frame_43[1110] = false
            cfg_43 = 168
        elseif cfg_43 == 167 then
            frame_43[1110] = true
            cfg_43 = 168
        elseif cfg_43 == 168 then
            frame_43[1109].extractionAvailable = frame_43[1110]
            cfg_43 = 179
        elseif cfg_43 == 169 then
            if not (frame_43[73]) then
                cfg_43 = 179
            else
                cfg_43 = 170
            end
        elseif cfg_43 == 170 then
            frame_43[1113] = _T
            frame_43[1114] = true
            frame_43[1115] = gGameRules
            frame_43[1118] = (frame_43[1115]):GetMission()
            frame_43[1119] = (frame_43[1118]).periodicMissionTag
            frame_43[1120] = frame_49["cap_49_519_1"]
            frame_43[1121] = (frame_43[1120]).ELITE_ALERT_PERIODIC_MISSION_TAG
            if frame_43[1119] == frame_43[1121] then
                cfg_43 = 174
            else
                cfg_43 = 171
            end
        elseif cfg_43 == 171 then
            frame_43[1122] = gGameRules
            frame_43[1125] = (frame_43[1122]):GetMission()
            frame_43[1126] = (frame_43[1125]).periodicMissionTag
            frame_43[1127] = frame_49["cap_49_519_1"]
            frame_43[1128] = (frame_43[1127]).ELITE_ALERT_PERIODIC_MISSION_TAG_ALT
            if frame_43[1126] == frame_43[1128] then
                cfg_43 = 173
            else
                cfg_43 = 172
            end
        elseif cfg_43 == 172 then
            frame_43[1114] = false
            cfg_43 = 174
        elseif cfg_43 == 173 then
            frame_43[1114] = true
            cfg_43 = 174
        elseif cfg_43 == 174 then
            frame_43[1129] = (not frame_43[1114])
            if frame_43[1129] then
                cfg_43 = 178
            else
                cfg_43 = 175
            end
        elseif cfg_43 == 175 then
            if 1 < frame_43[932] then
                cfg_43 = 177
            else
                cfg_43 = 176
            end
        elseif cfg_43 == 176 then
            frame_43[1129] = false
            cfg_43 = 178
        elseif cfg_43 == 177 then
            frame_43[1129] = true
            cfg_43 = 178
        elseif cfg_43 == 178 then
            frame_43[1113].extractionAvailable = frame_43[1129]
            cfg_43 = 179
        elseif cfg_43 == 179 then
            if not (0 < frame_43[1030]) then
                cfg_43 = 182
            else
                cfg_43 = 180
            end
        elseif cfg_43 == 180 then
            frame_43[1132] = frame_49[27]
            frame_43[1133] = (frame_43[1030] * frame_43[1132])
            frame_43[1134] = (frame_43[1133] * 1)
            frame_43[1136] = math.max
            frame_43[1137] = frame_43[1136](frame_43[1134], 1)
            frame_43[1138] = frame_49["cap_49_519_34"]
            frame_43[1139] = frame_49["cap_49_519_18"]
            frame_43[1140] = (frame_43[1139]).Ternary
            frame_43[1141] = frame_49[208]
            frame_43[1142] = oldWorldSalvageResource
            frame_43[1143] = cryoticResource
            frame_43[1144] = frame_43[1140](frame_43[1141], frame_43[1142], frame_43[1143])
            frame_43[1145] = frame_43[1137]
            frame_43[1138](frame_43[1144], frame_43[1145])
            frame_43[1146] = frame_49["cap_49_519_18"]
            frame_43[1147] = (frame_43[1146]).Ternary
            frame_43[1148] = frame_49[208]
            frame_43[1151] = frame_43[1147](frame_43[1148], "/Lotus/Language/Game/GainedOldWorldSalvage", "/Lotus/Language/Game/GainedCryotic")
            frame_43[1152] = gRegion
            frame_43[1155] = (frame_43[1152]):GetHumanPlayerAvatars()
            frame_43[1156] = 1
            frame_43[1157] = (#frame_43[1155])
            frame_43[1158] = 1
            local leave_for_43_181 = false
            for for_value_43_181 = frame_43[1156], frame_43[1157], frame_43[1158] do
                frame_43[1156] = for_value_43_181
                cfg_43 = 181
                while true do
                    if cfg_43 == 181 then
                        frame_43[1159] = gGameRules
                        frame_43[1160] = frame_43[1155][frame_43[1156]]
                        frame_43[1163] = (frame_43[1160]):GetPlayer()
                        frame_43[1164] = frame_43[1151]
                        frame_43[1170] = frame_43[1137]
                        frame_43[1171] = tostring
                        frame_43[1172] = frame_43[1171](frame_43[1170])
                        do (frame_43[1159]):DisplayMessage(frame_43[1163], frame_43[1164], "", 0, 2, true, "AMOUNT", frame_43[1172]) end
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_43_181 then break end
            end
            if not leave_for_43_181 then
                cfg_43 = 182
            end
        elseif cfg_43 == 182 then
            if not (frame_43[73]) then
                cfg_43 = 202
            else
                cfg_43 = 183
            end
        elseif cfg_43 == 183 then
            frame_43[1175] = frame_49[206]
            if not (frame_43[1175]) then
                cfg_43 = 185
            else
                cfg_43 = 184
            end
        elseif cfg_43 == 184 then
            frame_43[1176] = frame_49[208]
            if not (frame_43[1176]) then
                cfg_43 = 202
            else
                cfg_43 = 185
            end
        elseif cfg_43 == 185 then
            frame_43[1177] = true
            frame_43[1178] = gGameRules
            frame_43[1181] = (frame_43[1178]):GetMission()
            frame_43[1182] = (frame_43[1181]).periodicMissionTag
            frame_43[1183] = frame_49["cap_49_519_1"]
            frame_43[1184] = (frame_43[1183]).ELITE_ALERT_PERIODIC_MISSION_TAG
            if frame_43[1182] == frame_43[1184] then
                cfg_43 = 189
            else
                cfg_43 = 186
            end
        elseif cfg_43 == 186 then
            frame_43[1185] = gGameRules
            frame_43[1188] = (frame_43[1185]):GetMission()
            frame_43[1189] = (frame_43[1188]).periodicMissionTag
            frame_43[1190] = frame_49["cap_49_519_1"]
            frame_43[1191] = (frame_43[1190]).ELITE_ALERT_PERIODIC_MISSION_TAG_ALT
            if frame_43[1189] == frame_43[1191] then
                cfg_43 = 188
            else
                cfg_43 = 187
            end
        elseif cfg_43 == 187 then
            frame_43[1177] = false
            cfg_43 = 189
        elseif cfg_43 == 188 then
            frame_43[1177] = true
            cfg_43 = 189
        elseif cfg_43 == 189 then
            if not (frame_43[1177]) then
                cfg_43 = 191
            else
                cfg_43 = 190
            end
        elseif cfg_43 == 190 then
            frame_43[1192] = (frame_43[932] % 2)
            if frame_43[1192] ~= 0 then
                cfg_43 = 202
            else
                cfg_43 = 191
            end
        elseif cfg_43 == 191 then
            frame_43[1193] = frame_49["cap_49_519_35"]
            frame_43[1193]()
            frame_43[1194] = frame_49["cap_49_519_36"]
            frame_43[1195] = _T.lastSurvivalRewardStoreItem
            frame_43[1196] = IsNull
            frame_43[1197] = frame_43[1196](frame_43[1195])
            if frame_43[1197] then
                cfg_43 = 194
            else
                cfg_43 = 192
            end
        elseif cfg_43 == 192 then
            frame_43[1198] = string.find
            frame_43[1199] = _T.lastSurvivalRewardStoreItem
            frame_43[1202] = (frame_43[1199]):GetLocalizeTag()
            frame_43[1205] = (frame_43[1202]):c_str()
            frame_43[1207] = frame_43[1198](frame_43[1205], "Rusty")
            if frame_43[1207] == nil then
                cfg_43 = 194
            else
                cfg_43 = 193
            end
        elseif cfg_43 == 193 then
            frame_43[1208] = Symbol
            frame_43[1210] = frame_43[1208]("MissionExcavatorPistolFound")
            frame_43[1194] = frame_43[1210]
            frame_43[1211] = gGameRules
            frame_43[1212] = frame_49["cap_49_519_37"]
            do (frame_43[1211]):SetNetPersistentVar(frame_43[1212], 1) end
            cfg_43 = 194
        elseif cfg_43 == 194 then
            frame_43[1216] = frame_49[208]
            if not (frame_43[1216]) then
                cfg_43 = 201
            else
                cfg_43 = 195
            end
        elseif cfg_43 == 195 then
            frame_43[1217] = gRegion
            frame_43[1220] = (frame_43[1217]):GetHumanPlayers()
            frame_43[1221] = 1
            frame_43[1222] = (#frame_43[1220])
            frame_43[1223] = 1
            local leave_for_43_196 = false
            for for_value_43_196 = frame_43[1221], frame_43[1222], frame_43[1223] do
                frame_43[1221] = for_value_43_196
                cfg_43 = 196
                while true do
                    if cfg_43 == 196 then
                        frame_43[1224] = frame_49["cap_49_519_1"]
                        frame_43[1225] = (frame_43[1224]).IsFirstTimeInNode
                        frame_43[1226] = frame_43[1220][frame_43[1221]]
                        frame_43[1227] = frame_43[1225](frame_43[1226])
                        if not (frame_43[1227]) then
                            cfg_43 = 199
                        else
                            cfg_43 = 197
                        end
                    elseif cfg_43 == 197 then
                        frame_43[1194] = frame_49["cap_49_519_36"]
                        if frame_43[932] ~= 1 then
                            cfg_43 = 199
                        else
                            cfg_43 = 198
                        end
                    elseif cfg_43 == 198 then
                        frame_43[1228] = Symbol
                        frame_43[1230] = frame_43[1228]("MissionExcavatorFirstPistolFound")
                        frame_43[1194] = frame_43[1230]
                        cfg_43 = 199
                    elseif cfg_43 == 199 then
                        frame_43[1231] = frame_49["cap_49_519_7"]
                        frame_43[1232] = (frame_43[1231]).PlayLocalTransmission
                        frame_43[1233] = _T.MissionTransmissionSet
                        frame_43[1234] = frame_43[1194]
                        frame_43[1235] = frame_43[1220][frame_43[1221]]
                        frame_43[1232](frame_43[1233], frame_43[1234], (frame_43[1235]):GetAvatar())
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_43_196 then break end
            end
            if not leave_for_43_196 then
                cfg_43 = 200
            end
        elseif cfg_43 == 200 then
            cfg_43 = 202
        elseif cfg_43 == 201 then
            frame_43[1251] = frame_49["cap_49_519_7"]
            frame_43[1252] = (frame_43[1251]).PlayGlobalTransmission
            frame_43[1253] = _T.MissionTransmissionSet
            frame_43[1254] = frame_43[1194]
            frame_43[1252](frame_43[1253], frame_43[1254])
            cfg_43 = 202
        elseif cfg_43 == 202 then
            frame_43[1255] = frame_43[351]
            frame_43[1256] = IsNull
            frame_43[1257] = frame_43[1256](frame_43[1255])
            if frame_43[1257] then
                cfg_43 = 204
            else
                cfg_43 = 203
            end
        elseif cfg_43 == 203 then
            do (frame_43[351]):SetPower(0) end
            do (frame_43[351]):SetTimer(0) end
            do (frame_43[351]):Enable(false) end
            cfg_43 = 204
        elseif cfg_43 == 204 then
            frame_43[1267] = p43_0
            frame_43[1268] = IsNull
            frame_43[1269] = frame_43[1268](frame_43[1267])
            if frame_43[1269] then
                cfg_43 = 206
            else
                cfg_43 = 205
            end
        elseif cfg_43 == 205 then
            frame_43[1270] = gRegion
            frame_43[1271] = destructionEffect
            frame_43[1274] = p43_0:GetSimPosition()
            frame_43[1275] = ZERO_ROTATION
            do (frame_43[1270]):CreateEntity(frame_43[1271], frame_43[1274], frame_43[1275]) end
            frame_43[1278] = Engine.DamageData
            frame_43[1279] = frame_43[1278]()
            do (frame_43[1279]):SetDamagePct(0, 1) end
            frame_43[1279].baseAmount = 999999
            frame_43[1285] = frame_43[351]
            do (frame_43[1279]):SetSource(frame_43[1285]) end
            frame_43[1288] = frame_43[1279]
            p43_0:DamageDD(frame_43[1288])
            p43_0:Destroy()
            cfg_43 = 206
        elseif cfg_43 == 206 then
            return
        else
            error("invalid control state")
        end
    end
end
ExcavatorAvatar = frame_49[276]
frame_49["cap_49_559_0"] = frame_49[116]
frame_49["cap_49_559_1"] = frame_49[119]
frame_49[277] = function()
    local v44_0
    local v44_1
    local v44_2
    local v44_3
    local v44_4
    local v44_5
    local v44_6
    local v44_7
    local v44_8
    local v44_9
    local v44_10
    v44_0 = gGameRules
    v44_1 = frame_49["cap_49_559_0"]
    v44_5 = v44_0:GetNetPersistentVar(v44_1, 0)
    v44_6 = gGameRules
    v44_7 = frame_49["cap_49_559_1"]
    v44_8 = v44_5
    v44_6:SetNetPersistentVar(v44_7, v44_8)
    return
end
EndMission = frame_49[277]
frame_49["cap_49_563_0"] = frame_49[104]
frame_49[278] = function()
    local v45_0
    local v45_1
    local v45_2
    local v45_3
    local v45_4
    local v45_5
    local v45_6
    local v45_7
    local v45_8
    local v45_9
    local v45_10
    local v45_11
    local v45_12
    local v45_13
    local v45_14
    local v45_15
    local v45_16
    local v45_17
    local v45_18
    local v45_19
    v45_0 = gGameRules
    while true do
        v45_1 = v45_0
        v45_2 = IsNull
        v45_3 = v45_2(v45_1)
        if not (v45_3) then break end
        v45_0 = gGameRules
        v45_4 = Sleep
        v45_4(0.1)
    end
    v45_8 = v45_0:GetMissionType()
    if v45_8 == 17 then
        v45_10 = frame_49["cap_49_563_0"]
        v45_13 = v45_0:GetNetPersistentVar(v45_10)
        v45_14 = print
        v45_16 = v45_13
        v45_17 = tostring
        v45_18 = v45_17(v45_16)
        v45_19 = ("HostMigrationInit - excavation state=" .. v45_18)
        v45_14(v45_19)
        return
    else
        return
    end
end
HostMigrationInit = frame_49[278]
frame_49["cap_49_566_0"] = frame_49[86]
frame_49[279] = function(p46_0)
    local frame_46 = {}
    local cfg_46 = 0
    while true do
        if cfg_46 == 0 then
            frame_46[1] = gRegion
            frame_46[2] = frame_49["cap_49_566_0"]
            frame_46[10] = (frame_46[1]):FindNearestTagged(frame_46[2], p46_0:GetPosition())
            frame_46[13] = (frame_46[10]):GetPosition()
            frame_46[14] = 0
            cfg_46 = 1
        elseif cfg_46 == 1 then
            frame_46[15] = beamDelay
            if not (frame_46[14] < frame_46[15]) then
                cfg_46 = 4
            else
                cfg_46 = 2
            end
        elseif cfg_46 == 2 then
            frame_46[16] = frame_46[10]
            frame_46[17] = IsNull
            frame_46[18] = frame_46[17](frame_46[16])
            if frame_46[18] then
                cfg_46 = 4
            else
                cfg_46 = 3
            end
        elseif cfg_46 == 3 then
            frame_46[21] = (frame_46[10]):GetPosition()
            frame_46[22] = frame_46[21]
            frame_46[23] = frame_46[22]
            p46_0:SetEndPoint(frame_46[23])
            frame_46[26] = DeltaTime
            frame_46[27] = frame_46[26]()
            frame_46[14] = (frame_46[14] + frame_46[27])
            frame_46[28] = Sleep
            frame_46[28](0)
            cfg_46 = 1
        elseif cfg_46 == 4 then
            frame_46[30] = p46_0
            frame_46[31] = IsNull
            frame_46[32] = frame_46[31](frame_46[30])
            if frame_46[32] then
                cfg_46 = 6
            else
                cfg_46 = 5
            end
        elseif cfg_46 == 5 then
            p46_0:Destroy()
            cfg_46 = 6
        elseif cfg_46 == 6 then
            return
        else
            error("invalid control state")
        end
    end
end
BatteryBeam = frame_49[279]
frame_49[280] = function(p47_0)
    local v47_1
    local v47_2
    local v47_3
    local v47_4
    local v47_5
    local v47_6
    local v47_7
    local v47_8
    local v47_9
    local v47_10
    local v47_11
    local v47_12
    local v47_13
    local v47_14
    local v47_15
    local v47_16
    local v47_17
    local v47_18
    local v47_19
    local v47_20
    local v47_21
    local v47_22
    local v47_23
    local v47_24
    local v47_25
    local v47_26
    local v47_27
    local v47_28
    local v47_29
    local v47_30
    local v47_31
    local v47_32
    local v47_33
    local v47_34
    local v47_35
    local v47_36
    local v47_37
    local v47_38
    v47_1 = p47_0
    v47_2 = IsNull
    v47_3 = v47_2(v47_1)
    if not (v47_3) then
        v47_4 = gRegion
        v47_7 = v47_4:IsMaster()
        if v47_7 then
            v47_8 = gRegion
            v47_11 = v47_8:GetNpcMgr()
            v47_14 = v47_11:GetAiDirector()
            v47_15 = p47_0
            v47_14:Name__d991ada3(v47_15)
        end
    end
    v47_18 = gRegion
    v47_19 = gLotusExcavationStateType
    v47_22 = p47_0:GetPosition()
    v47_26 = v47_18:FindNearest(v47_19, v47_22, 5)
    v47_27 = v47_26
    v47_28 = IsNull
    v47_29 = v47_28(v47_27)
    if not (v47_29) then
        v47_26:SetPower(0)
        v47_26:SetTimer(0)
        v47_26:Enable(false)
    end
    return
end
OnExcavatorDeath = frame_49[280]
frame_49["cap_49_571_1"] = frame_49[26]
frame_49["cap_49_571_3"] = frame_49[110]
frame_49["cap_49_571_4"] = frame_49[11]
frame_49["cap_49_571_5"] = frame_49[98]
frame_49[281] = function()
    local frame_48 = {}
    frame_48[0] = _T.MissionDebug
    if not (frame_48[0]) then
        frame_48[1] = _T
        frame_48[2] = { FastDig = false, OldExcavatorPower = 0 }
        frame_48[1].MissionDebug = frame_48[2]
    end
    frame_48[3] = Name__dcd1aad1
    frame_48[5] = frame_48[3]("Excavation Mission")
    if frame_48[5] then
        frame_48[6] = ResetAttachedReposition
        frame_48[6]("Excavators")
        frame_48[8] = Name__f1cc455a
        frame_48[8]("Excavator Tracker", 4)
        frame_48[11] = Name__01adc66a
        frame_48[11]("Entity")
        frame_48[13] = Name__01adc66a
        frame_48[13]("Shields/Health")
        frame_48[15] = Name__01adc66a
        frame_48[15]("Timer")
        frame_48[17] = Name__01adc66a
        frame_48[17]("Power")
        frame_48[19] = Name__fb6f65c1
        frame_48[19]()
        frame_48[21] = frame_49[31]
        for for_value_48_9_0, for_value_48_9_1 in ipairs(frame_48[21]) do
            frame_48[122], frame_48[123] = for_value_48_9_0, for_value_48_9_1
            frame_48[25] = Name__e0dd80d6
            frame_48[25]()
            frame_48[28] = (frame_48[123]):GetAvatar()
            frame_48[29] = Name__71bf49fc
            frame_48[29](0)
            frame_48[31] = frame_48[28]
            frame_48[32] = IsNull
            frame_48[33] = frame_48[32](frame_48[31])
            if not (frame_48[33]) then
                frame_48[34] = Name__34ac3a00
                frame_48[43] = tostring
                frame_48[44] = frame_48[43]((frame_48[28]):GetName())
                frame_48[34](frame_48[44])
            end
            frame_48[45] = Name__71bf49fc
            frame_48[45](1)
            frame_48[47] = frame_48[28]
            frame_48[48] = IsNull
            frame_48[49] = frame_48[48](frame_48[47])
            if not (frame_48[49]) then
                frame_48[50] = ImGuiTextColored
                frame_48[57] = (frame_48[28]):DamageControl()
                frame_48[62] = tostring
                frame_48[63] = frame_48[62]((frame_48[57]):GetShield())
                frame_48[50](0, 0.753, 1, 1, frame_48[63])
                frame_48[64] = ImGuiSameLine
                frame_48[64]()
                frame_48[65] = ImGuiTextColored
                frame_48[74] = tostring
                frame_48[75] = frame_48[74]((frame_48[28]):GetHealth())
                frame_48[65](0.961, 0.255, 0.255, 1, frame_48[75])
            end
            frame_48[76] = Name__71bf49fc
            frame_48[76](2)
            frame_48[87] = tonumber
            frame_48[88] = frame_48[87]((frame_48[123]):GetTimer())
            frame_48[89] = Name__34ac3a00
            frame_48[90] = string.format
            frame_48[92] = frame_48[88]
            frame_48[98] = tostring
            frame_48[99] = frame_48[98](frame_48[90]("%0.3f", frame_48[92]))
            frame_48[89](frame_48[99])
            frame_48[100] = Name__71bf49fc
            frame_48[100](3)
            frame_48[110] = tonumber
            frame_48[111] = frame_48[110]((frame_48[123]):GetPower())
            frame_48[112] = Name__34ac3a00
            frame_48[113] = string.format
            frame_48[115] = frame_48[111]
            frame_48[120] = tostring
            frame_48[121] = frame_48[120](frame_48[113]("%0.0f", frame_48[115]))
            frame_48[112](frame_48[121])
        end
        frame_48[124] = Name__a43cdd06
        frame_48[124]()
        frame_48[125] = ResetAttachedReposition
        frame_48[125]("Commands")
        frame_48[127] = Name__bc6b5382
        frame_48[129] = frame_48[127]("Give Powercell")
        if frame_48[129] then
            frame_48[130] = gRegion
            frame_48[133] = (frame_48[130]):GetLocalPlayerAvatar()
            frame_48[134] = frame_48[133]
            frame_48[135] = IsNull
            frame_48[136] = frame_48[135](frame_48[134])
            if not (frame_48[136]) then
                frame_48[137] = gRegion
                frame_48[138] = Type
                frame_48[139] = cellItemPickup
                frame_48[140] = frame_48[138](frame_48[139])
                frame_48[143] = (frame_48[133]):GetSimPosition()
                do (frame_48[137]):CreateEntity(frame_48[140], frame_48[143], (frame_48[133]):GetSimRotation()) end
            end
        end
        frame_48[157] = frame_49["cap_49_571_1"]
        frame_48[158] = (frame_48[157]).TooltipEx
        frame_48[158]("Spawn a Powercell directly at your avatar's feet.")
        frame_48[160] = nil
        frame_48[161] = _T.MissionDebug
        frame_48[162] = Name__49802c36
        frame_48[164] = _T.MissionDebug.FastDig
        frame_48[165], frame_48[166] = frame_48[162]("Fast Dig", frame_48[164])
        frame_48[161].FastDig = frame_48[166]
        frame_48[167] = frame_48[165]
        if frame_48[167] then
            frame_48[168] = _T.MissionDebug.FastDig
            if not (frame_48[168]) then
                frame_48[189] = _T.MissionDebug.OldExcavatorPower
                frame_49[69] = frame_48[189]
            else
                frame_48[169] = _T.MissionDebug
                frame_48[170] = frame_49[69]
                frame_48[169].OldExcavatorPower = frame_48[170]
                frame_49[69] = 20
                frame_48[172] = frame_49[31]
                frame_48[173] = nil
                frame_48[174] = nil
                for for_value_48_18_0, for_value_48_18_1 in frame_48[172], frame_48[173], frame_48[174] do
                    frame_48[182], frame_48[183] = for_value_48_18_0, for_value_48_18_1
                    frame_48[177] = (frame_48[183]):GetTimer()
                    frame_48[178] = frame_49[69]
                    if frame_48[178] < frame_48[177] then
                        frame_48[179] = frame_49[69]
                        do (frame_48[183]):SetTimer(frame_48[179]) end
                    end
                end
                frame_48[184] = gGameRules
                frame_48[185] = frame_49["cap_49_571_3"]
                do (frame_48[184]):SetNetPersistentVar(frame_48[185], 1) end
            end
        end
        frame_48[190] = Name__bc6b5382
        frame_48[192] = frame_48[190]("Go To Nearest Dig")
        if frame_48[192] then
            frame_48[193] = gRegion
            frame_48[196] = (frame_48[193]):GetLocalPlayerAvatar()
            frame_48[197] = frame_48[196]
            frame_48[198] = IsNull
            frame_48[199] = frame_48[198](frame_48[197])
            if not (frame_48[199]) then
                frame_48[200] = frame_49["cap_49_571_4"]
                frame_48[201] = (frame_48[200]).Closest
                frame_48[202] = frame_49[31]
                frame_48[215] = frame_48[201](frame_48[202], (frame_48[196]):GetPosition())
                frame_48[216] = frame_48[215]
                frame_48[217] = IsNull
                frame_48[218] = frame_48[217](frame_48[216])
                if frame_48[218] then
                    frame_48[219] = gRegion
                    frame_48[220] = frame_49["cap_49_571_5"]
                    frame_48[223] = (frame_48[219]):FindTagged(frame_48[220])
                    frame_48[224] = (#frame_48[223])
                    frame_48[225] = 1
                    frame_48[226] = -1
                    for for_value_48_25 = frame_48[224], frame_48[225], frame_48[226] do
                        frame_48[224] = for_value_48_25
                        frame_48[227] = frame_48[223][frame_48[224]]
                        frame_48[230] = (frame_48[227]):IsEnabled()
                        if not (frame_48[230]) then
                            frame_48[231] = table.remove
                            frame_48[232] = frame_48[223]
                            frame_48[233] = frame_48[224]
                            frame_48[231](frame_48[232], frame_48[233])
                        end
                    end
                    frame_48[234] = frame_49["cap_49_571_4"]
                    frame_48[235] = (frame_48[234]).Closest
                    frame_48[236] = frame_48[223]
                    frame_48[247] = frame_48[235](frame_48[236], (frame_48[196]):GetPosition())
                    frame_48[215] = frame_48[247]
                end
                frame_48[248] = frame_48[215]
                frame_48[249] = IsNull
                frame_48[250] = frame_48[249](frame_48[248])
                if not (frame_48[250]) then
                    frame_48[251] = gRegion
                    frame_48[254] = (frame_48[251]):GetNpcMgr()
                    frame_48[257] = (frame_48[254]):GetAiDirector()
                    frame_48[260] = (frame_48[215]):GetPosition()
                    frame_48[267] = (frame_48[257]):GetRandomPointInRangeOnNav(frame_48[260], 2, 5, true, 0.1)
                    frame_48[268] = frame_48[267]
                    frame_48[269] = ZERO_ROTATION
                    do (frame_48[196]):Teleport(frame_48[268], frame_48[269]) end
                end
            end
        end
    end
    frame_48[272] = Name__1cc08613
    frame_48[272]()
    return
end
ImGuiDebug = frame_49[281]
return
