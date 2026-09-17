function proto_49(...)
  local v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37, v38, v39, v40, v41, v42, v43, v44, v45, v46, v47, v48, v49, v50, v51, v52, v53, v54, v55, v56, v57, v58, v59, v60, v61, v62, v63, v64, v65, v66, v67, v68, v69, v70, v71, v72, v73, v74, v75, v76, v77, v78, v79, v80, v81, v82, v83, v84, v85, v86, v87, v88, v89, v90, v91, v92, v93, v94, v95, v96, v97, v98, v99, v100, v101, v102, v103, v104, v105, v106, v107, v108, v109, v110, v111, v112, v113, v114, v115, v116, v117, v118, v119, v120, v121, v122, v123, v124, v125, v126, v127, v128
  v0 = require
  v1 = "EE.Interface.Utilities"
  v0 = v0(v1)
  v1 = require
  v2 = "Lotus.Interface.LotusUtilities"
  v1 = v1(v2)
  v2 = require
  v3 = "Lotus.Scripts.Libs.TransmissionSet"
  v2 = v2(v3)
  v3 = require
  v4 = "Lotus.Scripts.Libs.CommonGamemodeFunctions"
  v3 = v3(v4)
  v4 = require
  v5 = "Lotus.Scripts.Libs.ObjectiveText"
  v4 = v4(v5)
  v5 = require
  v6 = "Lotus.Scripts.Libs.LandscapeLib"
  v5 = v5(v6)
  v6 = require
  v7 = "Lotus.Scripts.Duviri.ArenaLib"
  v6 = v6(v7)
  v7 = require
  v8 = "Lotus.Interface.Libs.TimerMgr"
  v7 = v7(v8)
  v8 = require
  v9 = "Lotus.Interface.Libs.ImGuiLib"
  v8 = v8(v9)
  v9 = 1
  v10 = 3
  v11 = 0
  v12 = nil
  v13 = {}
  v14 = 0
  v15 = 0
  v17 = 8
  v18 = 15
  v19 = 25
  v20 = 30
  v16 = {v17, v18, v19, v20}
  v18 = 12
  v19 = 25
  v20 = 30
  v21 = 35
  v17 = {v18, v19, v20, v21}
  v19 = 7
  v20 = 15
  v21 = 25
  v22 = 30
  v18 = {v19, v20, v21, v22}
  v20 = 10
  v21 = 25
  v22 = 30
  v23 = 35
  v19 = {v20, v21, v22, v23}
  v21 = 5
  v22 = 5
  v23 = 5
  v24 = 5
  v20 = {v21, v22, v23, v24}
  v22 = 5
  v23 = 5
  v24 = 5
  v25 = 5
  v21 = {v22, v23, v24, v25}
  v22 = 0
  v23 = 0
  v24 = 900
  v25 = 1020
  v26 = nil
  v27 = 100
  v28 = 100
  v29 = false
  v30 = Symbol
  v31 = "HiddenMissionTimer"
  v30 = v30(v31)
  v31 = Symbol
  v32 = "ExcavationScanner"
  v31 = v31(v32)
  v32 = Symbol
  v33 = "ExcavationExtractor"
  v32 = v32(v33)
  v33 = Symbol
  v34 = "ExcavationExtractorSand"
  v33 = v33(v34)
  v34 = Symbol
  v35 = "ExcavatorAvatar"
  v34 = v34(v35)
  v35 = Symbol
  v36 = "ExcavationState"
  v35 = v35(v36)
  v36 = Symbol
  v37 = "ExcavatorMover"
  v36 = v36(v37)
  v37 = Symbol
  v38 = "ExcavationScannerDeco"
  v37 = v37(v38)
  v38 = Symbol
  v39 = "ExcavationObjectiveMarker"
  v38 = v38(v39)
  v39 = Symbol
  v40 = "ScannerTrigger"
  v39 = v39(v40)
  v40 = Symbol
  v41 = "ExcavationState"
  v40 = v40(v41)
  v41 = Symbol
  v42 = "ScannerPowerVal"
  v41 = v41(v42)
  v42 = Symbol
  v43 = "ScanTime"
  v42 = v42(v43)
  v43 = Symbol
  v44 = "TimeElapsed"
  v43 = v43(v44)
  v44 = Symbol
  v45 = "DigsScore"
  v44 = v44(v45)
  v45 = Symbol
  v46 = "Score"
  v45 = v45(v46)
  v46 = Symbol
  v47 = "ExcavatorsSpawned"
  v46 = v46(v47)
  v47 = Symbol
  v48 = "ExcavatorsStarted"
  v47 = v47(v48)
  v48 = Symbol
  v49 = "ExcavatorsEnded"
  v48 = v48(v49)
  v49 = Symbol
  v50 = "LastSuccessfulDig"
  v49 = v49(v50)
  v50 = Symbol
  v51 = "RewardsGiven"
  v50 = v50(v51)
  v51 = Symbol
  v52 = "LastBossSpawnTime"
  v51 = v51(v52)
  v52 = Symbol
  v53 = "VoidProjectionFlow"
  v52 = v52(v53)
  v53 = Symbol
  v54 = "DigsFullyCompleted"
  v53 = v53(v54)
  v54 = Symbol
  v55 = "CustomMissionHealth"
  v54 = v54(v55)
  v55 = Symbol
  v56 = "PossibleAFKFarming"
  v55 = v55(v56)
  v56 = Symbol
  v57 = "ExcavatorStatesCount"
  v56 = v56(v57)
  v57 = Symbol
  v58 = "mArenaComplete"
  v57 = v57(v58)
  v58 = Symbol
  v59 = "Infestation"
  v58 = v58(v59)
  v59 = Symbol
  v60 = "RandomTeam"
  v59 = v59(v60)
  v60 = Symbol
  v61 = "DefenseAgentSpawn"
  v60 = v60(v61)
  v61 = Symbol
  v62 = "BipedSpecialSpawn"
  v61 = v61(v62)
  v62 = Symbol
  v63 = "DoNotUse"
  v62 = v62(v63)
  v63 = Symbol
  v64 = "CameraSpawn"
  v63 = v63(v64)
  v64 = Symbol
  v65 = "TurretSpawn"
  v64 = v64(v65)
  v65 = Symbol
  v66 = "ExitMarker"
  v65 = v65(v66)
  v66 = Symbol
  v67 = "MissionExtractionAvailable"
  v66 = v66(v67)
  v67 = Symbol
  v68 = "MissionExcavatorItemFound"
  v67 = v67(v68)
  v68 = Symbol
  v69 = "NV_FOUND_PISTOLS"
  v68 = v68(v69)
  v69 = nil
  v70 = Symbol
  v71 = "BeamAttach"
  v70 = v70(v71)
  v71 = Symbol
  v72 = "BeamX"
  v71 = v71(v72)
  v72 = Symbol
  v73 = "BeamY"
  v72 = v72(v73)
  v73 = Symbol
  v74 = "BeamZ"
  v73 = v73(v74)
  v74 = Type
  v75 = "/Lotus/Fx/Gameplay/MoonShieldBeam"
  v74 = v74(v75)
  v75 = nil
  v76 = nil
  v77 = nil
  v78 = nil
  v79 = Symbol
  v80 = "SolNode332"
  v79 = v79(v80)
  v80 = false
  v81 = nil
  v82 = nil
  v83 = Resource
  v84 = "/Lotus/Interface/SurvivalReward.swf"
  v83 = v83(v84)
  v84 = Symbol
  v85 = "DuviriQuest"
  v84 = v84(v85)
  v85 = WeakResource
  v86 = "/Lotus/Types/Friendly/PlayerControllable/ControllableDuviriDrifterTennoAvatar"
  v85 = v85(v86)
  v86 = WeakResource
  v87 = "/Lotus/Types/PickUps/VoidTearSealerPickup"
  v86 = v86(v87)
  v87 = WeakResource
  v88 = "/Lotus/Types/PickUps/VoidTearSealerItem"
  v87 = v87(v88)
  v88 = WeakResource
  v89 = "/Lotus/Fx/Gameplay/Excavation/ExcavationPillar"
  v88 = v88(v89)
  v89 = function()
    local c1v0
    c1v0 = v80
    if not c1v0 then
      c1v0 = gPromotedToHost
      do return c1v0 end
    end
    c1v0 = gRegion
    c1v0 = c1v0:IsMaster()
    if c1v0 then
      c1v0 = v6
      c1v0 = c1v0.IsGameModeInProgress
      c1v0 = c1v0()
    end
    do return c1v0 end
  end
  v90 = function()
    local c2v0, c2v1, c2v2, c2v3, c2v4, c2v5
    c2v1 = gRegion
    c2v0 = IsNull
    c2v0 = c2v0(c2v1)
    if not c2v0 then
      c2v0 = gRegion
      c2v0 = c2v0:GetHumanPlayers()
      c2v3 = 1
      c2v1 = #c2v0
      c2v2 = 1
      for __renovice_for_0_0 = c2v3, c2v1, c2v2 do
        c2v4 = v1
        c2v4 = c2v4.IsFirstTimeInNode
        c2v5 = c2v0[__renovice_for_0_0]
        c2v4 = c2v4(c2v5)
        if not c2v4 then
          continue
        end
        c2v4 = true
        do return c2v4 end
      end
    end
    c2v0 = false
    do return c2v0 end
  end
  v91 = function()
    local c3v0, c3v1, c3v2
    c3v0 = true
    c3v1 = gGameRules
    c3v1 = c3v1:GetMission()
    c3v1 = c3v1.periodicMissionTag
    c3v2 = v1
    c3v2 = c3v2.ELITE_ALERT_PERIODIC_MISSION_TAG
    if c3v1 ~= c3v2 then
      c3v1 = gGameRules
      c3v1 = c3v1:GetMission()
      c3v1 = c3v1.periodicMissionTag
      c3v2 = v1
      c3v2 = c3v2.ELITE_ALERT_PERIODIC_MISSION_TAG_ALT
      if c3v1 ~= c3v2 then
        c3v0 = false
        do return c3v0 end
      end
      c3v0 = true
    end
    do return c3v0 end
  end
  v92 = function(c4v0)
    local c4v1, c4v2
    c4v2 = gLotusVehicleAvatarType
    c4v1 = c4v0:IsA(c4v2)
    if c4v1 then
      c4v1 = c4v0:IsHoverboard()
      if c4v1 then
        c4v1 = c4v0:GetRider()
        if c4v1 then
          do return c4v0:GetRider() end
        end
      end
    end
    do return c4v0 end
  end
  v93 = function(c5v0, c5v1)
    local c5v2, c5v3, c5v4, c5v5, c5v6, c5v7, c5v8
    c5v2 = IsNull
    c5v2 = c5v2(c5v0)
    if c5v2 then
      do return end
    end
    c5v2 = gRegion
    c5v2 = c5v2:GetHumanPlayerAvatars()
    c5v3 = ipairs
    c5v3, c5v4, c5v5 = c5v3(c5v2)
    for __renovice_for_0_0, __renovice_for_0_1 in c5v3, c5v4, c5v5 do
      c5v6 = IsNull
      c5v6 = c5v6(__renovice_for_0_1:GetPlayer())
      if c5v6 then
        continue
      end
      c5v6 = __renovice_for_0_1:GetPlayer()
      c5v6 = c5v6:IsActive()
      if not c5v6 then
        continue
      end
      local __renovice_state_0 = -1
      c5v8 = gLotusVehicleAvatarType
      c5v7 = __renovice_for_0_1:IsA(c5v8)
      if not c5v7 then
        __renovice_state_0 = -1
      else
        __renovice_state_0 = 1
      end
      if __renovice_state_0 == 1 then
        c5v7 = __renovice_for_0_1:IsHoverboard()
        if not c5v7 then
          __renovice_state_0 = -1
        else
          __renovice_state_0 = 2
        end
      end
      if __renovice_state_0 == 2 then
        c5v7 = __renovice_for_0_1:GetRider()
        if not c5v7 then
          __renovice_state_0 = -1
        else
          __renovice_state_0 = 3
        end
      end
      if __renovice_state_0 == 3 then
        c5v6 = __renovice_for_0_1:GetRider()
        __renovice_state_0 = 4
      end
      if __renovice_state_0 ~= 4 then
        c5v6 = __renovice_for_0_1
      end
      c5v7 = c5v6:InventoryControl()
      c5v7:AddMiscItem(c5v0, c5v1)
    end
    do return end
  end
  v94 = function(c6v0, c6v1, c6v2, c6v3)
    local c6v4, c6v5, c6v6, c6v7, c6v8
    if c6v3 then
      c6v6 = true
      c6v7 = false
      c6v0:SetVisibility(c6v6, c6v7)
      c6v4 = ipairs
      c6v4, c6v5, c6v6 = c6v4(c6v1)
      for __renovice_for_0_0, __renovice_for_0_1 in c6v4, c6v5, c6v6 do
        c6v8 = IsNull
        c6v8 = c6v8(__renovice_for_0_1)
        if c6v8 then
          continue
        end
        __renovice_for_0_1:Enable()
      end
      c6v4 = ipairs
      c6v4, c6v5, c6v6 = c6v4(c6v2)
      for __renovice_for_1_0, __renovice_for_1_1 in c6v4, c6v5, c6v6 do
        c6v8 = IsNull
        c6v8 = c6v8(__renovice_for_1_1)
        if c6v8 then
          continue
        end
        __renovice_for_1_1:Enable()
      end
      do return end
    end
    c6v6 = false
    c6v7 = false
    c6v0:SetVisibility(c6v6, c6v7)
    c6v4 = ipairs
    c6v4, c6v5, c6v6 = c6v4(c6v1)
    for __renovice_for_2_0, __renovice_for_2_1 in c6v4, c6v5, c6v6 do
      c6v8 = IsNull
      c6v8 = c6v8(__renovice_for_2_1)
      if c6v8 then
        continue
      end
      __renovice_for_2_1:Disable()
    end
    c6v4 = ipairs
    c6v4, c6v5, c6v6 = c6v4(c6v2)
    for __renovice_for_3_0, __renovice_for_3_1 in c6v4, c6v5, c6v6 do
      c6v8 = IsNull
      c6v8 = c6v8(__renovice_for_3_1)
      if c6v8 then
        continue
      end
      __renovice_for_3_1:Disable()
    end
    do return end
  end
  v95 = function(c7v0, c7v1)
    local c7v2, c7v3, c7v4, c7v5, c7v6, c7v7, c7v8
    c7v2 = gRegion
    c7v4 = v35
    c7v2 = c7v2:FindNearestTagged(c7v4, c7v0:GetPosition())
    c7v5 = gParticleSysType
    c7v3 = c7v1:GetAllAttachments(c7v5)
    c7v6 = gSequencerType
    c7v4 = c7v1:GetAllAttachments(c7v6)
    c7v7 = pillarType
    c7v5 = c7v1:GetAttachment(c7v7)
    c7v6 = c7v2:IsEnabled()
    if c7v6 then
      c7v7 = c7v2:GetPower()
      c7v8 = 0
      if not (c7v8 < c7v7) then
        c7v6 = false
      else
        c7v6 = true
      end
    end
    c7v7 = v94
    c7v7(c7v5, c7v3, c7v4, c7v6)
    do return end
  end
  ShowExcavationFX = v95
  v95 = function(c8v0, c8v1, c8v2)
    local c8v3, c8v4, c8v5, c8v6, c8v7, c8v8
    c8v3 = IsNull
    c8v3 = c8v3(c8v0)
    if not c8v3 then
      c8v3 = c8v0:GetAllAttachments(c8v1)
      c8v4 = ipairs
      c8v4, c8v5, c8v6 = c8v4(c8v3)
      for __renovice_for_0_0, __renovice_for_0_1 in c8v4, c8v5, c8v6 do
        repeat
          c8v7 = __renovice_for_0_1:GetTag()
          if c8v7 ~= c8v2 then
            c8v8 = IsNull
            c8v8 = c8v8(c8v7)
            if not c8v8 then
              c8v8 = IsNull
              c8v8 = c8v8(c8v2)
              if not c8v8 then break end
            end
          end
          __renovice_for_0_1:Destroy()
        until true
      end
    end
    do return end
  end
  v96 = function(c9v0)
    local c9v1, c9v2, c9v3, c9v4, c9v5
    c9v1 = gGameRules
    c9v2 = 0
    if c9v0 < c9v2 then
      c9v0 = 0
    end
    c9v3 = v42
    c9v5 = c9v0 * 16384
    c9v4 = math.ceil
    c9v4 = c9v4(c9v5)
    c9v1:SetNetPersistentVar(c9v3, c9v4)
    do return end
  end
  v97 = function()
    local c10v0, c10v1, c10v2, c10v3
    c10v0 = gGameRules
    c10v3 = v42
    c10v2 = c10v0:GetNetPersistentVar(c10v3)
    c10v1 = c10v2 / 16384
    do return c10v1 end
  end
  v98 = function(c11v0)
    local c11v1, c11v2, c11v3, c11v4, c11v5
    c11v1 = gFlashMgr
    c11v3 = v83
    c11v1 = c11v1:PushMovie(c11v3)
    c11v2 = IsNull
    c11v2 = c11v2(c11v1)
    if not c11v2 then
      c11v4 = "ShowReward"
      c11v5 = tostring
      c11v5 = c11v5(c11v0)
      c11v1:Execute(c11v4, c11v5)
      c11v2 = print
      c11v4 = "Survival: Gave reward tier "
      c11v3 = c11v4 .. c11v0
      c11v2(c11v3)
    end
    do return end
  end
  v99 = function()
    local c12v0, c12v1, c12v2, c12v3, c12v4, c12v5, c12v6, c12v7, c12v8, c12v9, c12v10, c12v11, c12v12, c12v13, c12v14, c12v15, c12v16, c12v17
    c12v0 = print
    local __renovice_local_0 = "excavation: starting client loop"
    c12v0(__renovice_local_0)
    c12v0 = gGameRules
    while true do
      __renovice_local_0 = IsNull
      __renovice_local_0 = __renovice_local_0(c12v0)
      if not __renovice_local_0 then break end
      __renovice_local_0 = Sleep
      c12v1 = 0
      __renovice_local_0(c12v1)
      c12v0 = gGameRules
    end
    c12v2 = v50
    c12v3 = 65535
    __renovice_local_0 = c12v0:GetNetPersistentVar(c12v2, c12v3)
    while true do
      c12v1 = gPromotedToHost
      if c12v1 then break end
      c12v1 = IsNull
      c12v1 = c12v1(c12v0)
      if c12v1 then break end
      c12v3 = v50
      c12v1 = c12v0:GetNetPersistentVar(c12v3)
      if __renovice_local_0 ~= c12v1 then
        if __renovice_local_0 < c12v1 then
          c12v0:Name__94db44db()
          c12v4 = c12v1 - 1
          c12v0:OnTieredRewardRoundOver(c12v4)
          while true do
            if __renovice_local_0 == c12v1 then break end
            c12v2 = print
            c12v4 = "Client: trying to catch up with new reward count= "
            c12v8 = tostring
            c12v5 = c12v8(c12v1)
            c12v6 = ", current="
            c12v7 = tostring
            c12v7 = c12v7(__renovice_local_0)
            c12v3 = c12v4 .. c12v5 .. c12v6 .. c12v7
            c12v2(c12v3)
            __renovice_local_0 = __renovice_local_0 + 1
            c12v2 = __renovice_local_0
            c12v3 = gFlashMgr
            c12v5 = v83
            c12v3 = c12v3:PushMovie(c12v5)
            c12v4 = IsNull
            c12v4 = c12v4(c12v3)
            if c12v4 then
              continue
            end
            c12v6 = "ShowReward"
            c12v7 = tostring
            c12v7 = c12v7(c12v2)
            c12v3:Execute(c12v6, c12v7)
            c12v4 = print
            c12v6 = "Survival: Gave reward tier "
            c12v5 = c12v6 .. c12v2
            c12v4(c12v5)
          end
        else
          if __renovice_local_0 == 65535 then
            c12v2 = print
            c12v4 = "Reward count not yet initialized, setting to "
            c12v5 = tostring
            c12v5 = c12v5(c12v1)
            c12v3 = c12v4 .. c12v5
            c12v2(c12v3)
            __renovice_local_0 = c12v1
          end
        end
      end
      c12v3 = gRegion
      c12v2 = IsNull
      c12v2 = c12v2(c12v3)
      if not c12v2 then
        c12v2 = gRegion
        c12v2 = c12v2:GetHumanPlayers()
        c12v5 = 1
        c12v3 = #c12v2
        c12v4 = 1
        for __renovice_for_0_0 = c12v5, c12v3, c12v4 do
          c12v6 = c12v2[__renovice_for_0_0]
          c12v6 = c12v6:GetMissionData()
          c12v7 = c12v2[__renovice_for_0_0]
          c12v7 = c12v7:GetAvatar()
          c12v8 = IsNull
          c12v8 = c12v8(c12v6)
          if c12v8 then
            continue
          end
          c12v10 = v70
          c12v8 = c12v6:Name__2b56de52(c12v10)
          if c12v8 == 1 then
            c12v8 = IsNull
            c12v8 = c12v8(c12v7)
            if not c12v8 then
              c12v10 = v74
              c12v8 = c12v7:GetAttachment(c12v10)
              c12v9 = IsNull
              c12v9 = c12v9(c12v8)
              if c12v9 then
                c12v9 = c12v7:DamageControl()
                c12v11 = 0
                c12v9 = c12v9:Name__b7c91969(c12v11)
                c12v12 = v74
                c12v14 = Vector
                c12v15 = -0.2
                c12v16 = 0
                c12v17 = 0
                c12v8 = c12v7:Attach(c12v12, c12v9, c12v14(c12v15, c12v16, c12v17))
              end
              c12v9 = IsNull
              c12v9 = c12v9(c12v8)
              if not c12v9 then
                c12v9 = Vector
                c12v12 = v71
                c12v10 = c12v6:Name__2b56de52(c12v12)
                c12v13 = v72
                c12v11 = c12v6:Name__2b56de52(c12v13)
                c12v14 = v73
                c12v12 = c12v9(c12v10, c12v11, c12v6:Name__2b56de52(c12v14))
                c12v8:SetEndPoint(c12v12)
              end
            end
            continue
          end
          c12v8 = v95
          c12v10 = v74
          c12v11 = nil
          c12v8(c12v7, c12v10, c12v11)
        end
      end
      c12v2 = Sleep
      c12v3 = 0
      c12v2(c12v3)
    end
    c12v1 = print
    c12v2 = "Bailing on ExcavationLoopClient because I am now the host!"
    c12v1(c12v2)
    do return end
  end
  v100 = function()
    local c13v0, c13v1, c13v2, c13v3, c13v4, c13v5, c13v6
    c13v0 = gGameRules
    c13v2 = v50
    c13v0 = c13v0:GetNetPersistentVar(c13v2)
    if c13v0 == 0 then
      c13v1 = gGameRules
      c13v3 = v50
      c13v4 = 1
      c13v1:SetNetPersistentVar(c13v3, c13v4)
      c13v1 = gGameRules
      c13v1:Name__94db44db()
      c13v1 = gGameRules
      c13v3 = 0
      c13v1:OnTieredRewardRoundOver(c13v3)
      c13v1 = gFlashMgr
      c13v3 = v83
      c13v1 = c13v1:PushMovie(c13v3)
      c13v2 = IsNull
      c13v2 = c13v2(c13v1)
      if not c13v2 then
        c13v4 = "ShowReward"
        c13v6 = 1
        c13v5 = tostring
        c13v5 = c13v5(c13v6)
        c13v1:Execute(c13v4, c13v5)
        c13v2 = print
        c13v4 = "Survival: Gave reward tier "
        c13v5 = 1
        c13v3 = c13v4 .. c13v5
        c13v2(c13v3)
      end
    else
      c13v1 = c13v0 + 1
      c13v2 = gGameRules
      c13v4 = v50
      c13v2:SetNetPersistentVar(c13v4, c13v1)
      c13v2 = gGameRules
      c13v4 = c13v1 - 1
      c13v2:OnTieredRewardRoundOver(c13v4)
      c13v2 = gFlashMgr
      c13v4 = v83
      c13v2 = c13v2:PushMovie(c13v4)
      c13v3 = IsNull
      c13v3 = c13v3(c13v2)
      if not c13v3 then
        c13v5 = "ShowReward"
        c13v6 = tostring
        c13v6 = c13v6(c13v1)
        c13v2:Execute(c13v5, c13v6)
        c13v3 = print
        c13v5 = "Survival: Gave reward tier "
        c13v4 = c13v5 .. c13v1
        c13v3(c13v4)
      end
    end
    do return end
  end
  v101 = function(c14v0, c14v1, c14v2, c14v3)
    local c14v4, c14v5, c14v6, c14v7, c14v8, c14v9, c14v10, c14v11
    c14v4 = c14v0:GetAvatar()
    c14v5 = IsNull
    c14v5 = c14v5(c14v4)
    if c14v5 then
      do return end
    end
    c14v5 = gRegion
    c14v5 = c14v5:Name__81993ba3(c14v4, c14v1)
    c14v6 = nil
    c14v7 = gRegion
    c14v7 = c14v7:GetNpcMgr()
    c14v7 = c14v7:GetAiDirector()
    c14v8 = IsNull
    c14v8 = c14v8(c14v5)
    if c14v8 then
      c14v8 = v80
      if c14v8 then
        c14v8 = gRegion
        c14v10 = v34
        c14v5 = c14v8:FindNearestTagged(c14v10, c14v4:GetPosition())
      end
    end
    c14v8 = 0
    if c14v8 < c14v2 then
      c14v8 = gRegion
      c14v6 = c14v8:Name__81993ba3(c14v4, c14v3)
      c14v8 = IsNull
      c14v8 = c14v8(c14v6)
      if c14v8 then
        c14v8 = v80
        if c14v8 then
          c14v6 = c14v7:PlayAlternatebuff(c14v4)
        end
      end
    end
    c14v8 = IsNull
    c14v8 = c14v8(c14v5)
    if c14v8 then
      c14v8 = IsNull
      c14v8 = c14v8(c14v6)
      if c14v8 then
        do return end
      end
    end
    c14v8 = IsNull
    c14v8 = c14v8(c14v5)
    if c14v8 then
      c14v0:StormTarget(c14v6)
      do return end
    end
    c14v8 = IsNull
    c14v8 = c14v8(c14v6)
    if c14v8 then
      c14v0:StormTarget(c14v5)
      do return end
    end
    c14v8 = c14v4:GetPosition()
    c14v11 = c14v8
    c14v9 = c14v5:DistanceToPoint(c14v11)
    c14v10 = c14v6:DistanceToPoint(c14v8)
    c14v11 = c14v10 + 25
    if c14v11 < c14v9 then
      c14v0:StormTarget(c14v6)
      do return end
    end
    c14v0:StormTarget(c14v5)
    do return end
  end
  v102 = function(c15v0)
    local c15v1, c15v2, c15v3, c15v4, c15v5, c15v6, c15v7, c15v8, c15v9, c15v10, c15v11, c15v12, c15v13
    c15v1 = gRegion
    c15v1 = c15v1:GetHumanPlayerAvatars()
    c15v2 = ipairs
    c15v2, c15v3, c15v4 = c15v2(c15v1)
    for __renovice_for_0_0, __renovice_for_0_1 in c15v2, c15v3, c15v4 do
      c15v7 = IsNull
      c15v7 = c15v7(__renovice_for_0_1)
      if c15v7 then
        continue
      end
      c15v7 = __renovice_for_0_1:IsKilled()
      if not c15v7 then
        continue
      end
      c15v7 = nil
      c15v1[__renovice_for_0_0] = c15v7
    end
    c15v2 = gGameRules
    c15v4 = v47
    c15v5 = 0
    c15v2 = c15v2:GetNetPersistentVar(c15v4, c15v5)
    c15v3 = gRegion
    c15v3 = c15v3:GetNpcMgr()
    c15v3 = c15v3:GetAiDirector()
    c15v6 = nil
    c15v7 = 10000
    c15v8 = false
    c15v4 = c15v3:Name__e0776624(c15v6, c15v7, c15v8)
    c15v7 = #c15v4
    c15v5 = 1
    c15v6 = -1
    for __renovice_for_1_0 = c15v7, c15v5, c15v6 do
      c15v8 = c15v4[__renovice_for_1_0]
      c15v9 = IsNull
      c15v9 = c15v9(c15v8)
      if c15v9 then
        continue
      end
      local __renovice_state_0 = -1
      c15v9 = c15v8:GetStormTarget()
      c15v10 = #c15v0
      c15v11 = 0
      if not (c15v11 < c15v10) then
        __renovice_state_0 = -1
      else
        __renovice_state_0 = 1
      end
      if __renovice_state_0 == 1 then
        c15v10 = IsNull
        c15v10 = c15v10(c15v9)
        if c15v10 then
          __renovice_state_0 = -1
        else
          __renovice_state_0 = 2
        end
      end
      if __renovice_state_0 == 2 then
        c15v12 = gAvatarType
        c15v10 = c15v9:IsA(c15v12)
        if not c15v10 then
          __renovice_state_0 = -1
        else
          __renovice_state_0 = 3
        end
      end
      if __renovice_state_0 == 3 then
        c15v10 = IsNull
        c15v10 = c15v10(c15v9:GetPlayer())
        if c15v10 then
          __renovice_state_0 = -1
        else
          __renovice_state_0 = 4
        end
      end
      if __renovice_state_0 == 4 then
        c15v9 = nil
        __renovice_state_0 = 5
      end
      if __renovice_state_0 ~= 5 then
        c15v10 = IsNull
        c15v10 = c15v10(c15v9)
        if not c15v10 then
          c15v12 = gAvatarType
          c15v10 = c15v9:IsA(c15v12)
          if c15v10 then
            c15v10 = c15v9:IsKilled()
            if c15v10 then
              c15v3:Name__ae3a6128(c15v9)
              c15v9 = nil
            end
          end
        end
      end
      c15v10 = IsNull
      c15v10 = c15v10(c15v9)
      if c15v10 then
        c15v10 = v101
        c15v10(c15v8, c15v0, c15v2, c15v1)
        continue
      end
      c15v10 = print
      c15v12 = "Keeping existing target of "
      c15v13 = c15v9:GetFullName()
      c15v11 = c15v12 .. c15v13
      c15v10(c15v11)
    end
    c15v5 = #c15v0
    c15v6 = 0
    if c15v6 < c15v5 then
      c15v6 = RandomInt
      c15v7 = 1
      c15v8 = #c15v0
      c15v6 = c15v6(c15v7, c15v8)
      c15v5 = c15v0[c15v6]
      c15v3:SetObjective(c15v5)
      c15v3:Name__7fccb7d5(c15v5)
      c15v6 = print
      c15v8 = "SetObjective "
      c15v9 = c15v5:GetFullName()
      c15v7 = c15v8 .. c15v9
      c15v6(c15v7)
      do return end
    end
    do return end
  end
  v103 = function()
    local c16v0, c16v1, c16v2
    c16v1 = _T.EndlessModeEnemyLevel
    c16v0 = IsNull
    c16v0 = c16v0(c16v1)
    if c16v0 then
      c16v0 = gRegion
      c16v0 = c16v0:GetNpcMgr()
      c16v0 = c16v0:GetAiDirector()
      c16v1 = _T
      c16v2 = c16v0:GetMinEnemyLevel()
      c16v1.EndlessModeEnemyLevel = c16v2
    end
    c16v2 = _T.EndlessModeEnemyLevel
    c16v1 = c16v2 / 30
    c16v2 = 1
    c16v0 = math.min
    c16v0 = c16v0(c16v1, c16v2)
    do return c16v0 end
  end
  v104 = function(c17v0, c17v1, c17v2, c17v3)
    local c17v4, c17v5, c17v6, c17v7
    c17v0:SetAlert()
    c17v4 = Sleep
    c17v5 = 0
    c17v4(c17v5)
    c17v4 = IsNull
    c17v4 = c17v4(c17v0)
    if c17v4 then
      do return end
    end
    c17v4 = ipairs
    c17v4, c17v5, c17v6 = c17v4(c17v3)
    for __renovice_for_0_0, __renovice_for_0_1 in c17v4, c17v5, c17v6 do
      c17v7 = IsNull
      c17v7 = c17v7(__renovice_for_0_1)
      if c17v7 then
        continue
      end
      c17v7 = __renovice_for_0_1:IsKilled()
      if not c17v7 then
        continue
      end
      c17v7 = nil
      c17v3[__renovice_for_0_0] = c17v7
    end
    c17v4 = v101
    c17v4(c17v0, c17v1, c17v2, c17v3)
    do return end
  end
  v105 = function()
    local c18v0, c18v1, c18v2, c18v3, c18v4, c18v5, c18v6, c18v7, c18v8, c18v9
    c18v0 = gGameRules
    c18v1 = c18v0:GetMission()
    c18v2 = c18v1.enemySpec
    c18v3 = 0
    c18v4 = IsNull
    c18v4 = c18v4(c18v2)
    if not c18v4 then
      c18v4 = c18v2:GetEnemies()
      c18v5 = ipairs
      c18v5, c18v6, c18v7 = c18v5(c18v4)
      for __renovice_for_0_0, __renovice_for_0_1 in c18v5, c18v6, c18v7 do
        c18v8 = __renovice_for_0_1.tier
        if c18v8 ~= 9 then
          continue
        end
        c18v9 = __renovice_for_0_1.maxSimultaneous
        c18v8 = math.max
        c18v3 = c18v8(c18v3, c18v9)
      end
    end
    c18v4 = c18v1.goalTag
    c18v5 = v84
    if c18v4 == c18v5 then
      c18v3 = 0
    end
    do return c18v3 end
  end
  v106 = function(c19v0)
    local c19v1, c19v2, c19v3, c19v4, c19v5
    c19v1 = ipairs
    c19v1, c19v2, c19v3 = c19v1(c19v0)
    for __renovice_for_0_0, __renovice_for_0_1 in c19v1, c19v2, c19v3 do
      c19v4 = __renovice_for_0_1:GetPower()
      c19v5 = 0
      if not (c19v5 < c19v4) then
        continue
      end
      c19v4 = true
      do return c19v4 end
    end
    c19v1 = false
    do return c19v1 end
  end
  v107 = function(c20v0, c20v1, c20v2, c20v3)
    local c20v4, c20v5, c20v6, c20v7, c20v8, c20v9, c20v10, c20v11, c20v12, c20v13, c20v14, c20v15, c20v16, c20v17, c20v18, c20v19, c20v20, c20v21, c20v22
    c20v4 = gRegion
    c20v4 = c20v4:GetNpcMgr()
    c20v4 = c20v4:GetAiDirector()
    c20v5 = c20v4:GetMinEnemyLevel()
    c20v6 = c20v4:GetMaxEnemyLevel()
    c20v7 = nil
    c20v8 = v76
    if c20v8 then
      c20v6 = c20v5 + 5
    end
    c20v8 = v25
    if c20v8 < c20v0 then
      c20v14 = v25
      c20v13 = c20v0 - c20v14
      c20v12 = c20v13 / 40
      c20v11 = c20v12 * 0.13
      c20v10 = 40 - c20v11
      c20v9 = math.floor
      c20v9 = c20v9(c20v10)
      c20v10 = 5
      c20v8 = math.max
      c20v8 = c20v8(c20v9, c20v10)
      c20v12 = v25
      c20v11 = c20v0 - c20v12
      c20v10 = c20v11 / c20v8
      c20v9 = math.floor
      c20v9 = c20v9(c20v10)
      c20v7 = c20v6 + c20v9
    else
      c20v9 = v24
      c20v8 = c20v0 / c20v9
      c20v9 = Lerp
      c20v7 = c20v9(c20v5, c20v6, c20v8)
    end
    c20v8 = v80
    if c20v8 then
      c20v7 = c20v7 + 0
    end
    c20v10 = Engine.EngineNpcAgent_MAX_LEVEL
    c20v8 = math.min
    c20v7 = c20v8(c20v7, c20v10)
    _T.EndlessModeEnemyLevel = c20v7
    c20v8 = c20v0 % 300
    c20v9 = 300
    if c20v9 < c20v0 then
      c20v9 = 0
      if c20v9 <= c20v8 then
        c20v9 = 15
        if c20v8 < c20v9 then
          c20v9 = c20v0 - c20v8
          c20v10 = gGameRules
          c20v12 = v51
          c20v10 = c20v10:GetNetPersistentVar(c20v12)
          if c20v10 < c20v9 then
            c20v13 = 9
            c20v14 = true
            c20v4:SetCurrentTier(c20v13, c20v14)
            c20v11 = v105
            c20v11 = c20v11()
            c20v14 = 1
            c20v12 = c20v11
            c20v13 = 1
            for __renovice_for_0_0 = c20v14, c20v12, c20v13 do
              c20v17 = nil
              c20v18 = v59
              c20v20 = nil
              c20v21 = 1
              c20v15 = c20v4:CreateRandomAgent(c20v17, c20v18, c20v7, c20v20, c20v21)
              c20v16 = IsNull
              c20v16 = c20v16(c20v15)
              if c20v16 then
                continue
              end
              c20v16 = gGameRules
              c20v18 = v51
              c20v16:SetNetPersistentVar(c20v18, c20v0)
              c20v16 = v104
              c20v16(c20v15, c20v1, c20v2, c20v3)
            end
          end
        end
      end
    end
    c20v11 = c20v0 / 120
    c20v10 = math.floor
    c20v10 = c20v10(c20v11)
    c20v9 = c20v10 * 1
    c20v12 = 5
    c20v10 = math.min
    c20v9 = c20v10(c20v9, c20v12)
    c20v4:SetCurrentTier(c20v9)
    c20v10 = gGameRules
    c20v10 = c20v10:GetMission()
    c20v11 = 0
    c20v13 = 60
    c20v14 = Lerp
    c20v15 = 120
    c20v16 = 0
    c20v17 = c20v10.difficulty
    c20v14 = c20v14(c20v15, c20v16, c20v17)
    c20v12 = c20v13 + c20v14
    c20v14 = 3000
    c20v15 = Lerp
    c20v16 = 120
    c20v17 = 0
    c20v18 = c20v10.difficulty
    c20v15 = c20v15(c20v16, c20v17, c20v18)
    c20v13 = c20v14 + c20v15
    c20v14 = 0.02
    c20v15 = 0.15
    c20v16 = c20v10.goalTag
    c20v17 = v84
    if c20v16 == c20v17 then
      c20v14 = 0
      c20v15 = 0
    end
    local __renovice_state_0 = -1
    c20v16 = false
    c20v17 = c20v10.leadersAlwaysAllowed
    if not c20v17 then
      __renovice_state_0 = -1
    else
      __renovice_state_0 = 1
    end
    if __renovice_state_0 == 1 then
      c20v17 = c20v10.sortieId
      if c20v17 ~= "" then
        __renovice_state_0 = 4
      else
        __renovice_state_0 = 2
      end
    end
    if __renovice_state_0 == 2 then
      c20v17 = c20v10.alertId
      if c20v17 ~= "" then
        __renovice_state_0 = 4
      else
        __renovice_state_0 = 3
      end
    end
    if __renovice_state_0 == 3 then
      c20v17 = c20v10.goalId
      if c20v17 == "" then
        __renovice_state_0 = -1
      else
        __renovice_state_0 = 4
      end
    end
    if __renovice_state_0 == 4 then
      c20v17 = Clamp
      c20v18 = c20v12 * 0.1
      c20v19 = 1
      c20v12 = c20v17(c20v18, c20v19, c20v12)
      c20v17 = Clamp
      c20v18 = c20v13 * 0.1
      c20v19 = 1
      c20v13 = c20v17(c20v18, c20v19, c20v13)
      c20v17 = _T.IsLiteSortie
      if not c20v17 then
        __renovice_state_0 = 6
      else
        __renovice_state_0 = 5
      end
    end
    if __renovice_state_0 == 5 then
      c20v17 = 0.05
      c20v19 = gRegion
      c20v19 = c20v19:GetNumHumanPlayers()
      c20v18 = c20v19 * 0.025
      c20v15 = c20v17 + c20v18
      __renovice_state_0 = 7
    end
    if __renovice_state_0 == 6 then
      c20v14 = c20v14 * 5
      c20v15 = c20v15 * 5
      __renovice_state_0 = 7
    end
    if __renovice_state_0 ~= 7 then
      c20v17 = v80
      if c20v17 then
        c20v17 = gGameRules
        c20v19 = Symbol
        c20v20 = "mCurrentPortalId"
        c20v17 = c20v17:GetNetPersistentVar(c20v19(c20v20))
        c20v18 = v5
        c20v18 = c20v18.GetNetString
        c20v19 = tostring
        c20v19 = c20v19(c20v17)
        c20v18 = c20v18(c20v19)
        c20v20 = IsNull
        c20v20 = c20v20(c20v18)
        c20v19 = not c20v20
        if c20v19 then
          c20v19 = c20v18.isStaticPortal
        end
        c20v16 = c20v19
      end
    end
    c20v17 = gGameRules
    c20v17 = c20v17:GetEximusMultiplier()
    c20v14 = c20v14 * c20v17
    c20v15 = c20v15 * c20v17
    if c20v16 then
      c20v18 = gGameRules
      c20v20 = v45
      c20v21 = 0
      c20v18 = c20v18:GetNetPersistentVar(c20v20, c20v21)
      c20v20 = c20v18 / 500
      c20v21 = 1
      c20v19 = math.min
      c20v19 = c20v19(c20v20, c20v21)
      c20v20 = Lerp
      c20v20 = c20v20(c20v14, c20v15, c20v19)
      c20v20 = c20v20 * 5
      c20v21 = math.random
      c20v21 = c20v21()
      if c20v21 <= c20v20 then
        c20v11 = 1
      end
    else
      if c20v12 <= c20v0 then
        c20v20 = c20v0 - c20v12
        c20v21 = c20v13 - c20v12
        c20v19 = c20v20 / c20v21
        c20v20 = 1
        c20v18 = math.min
        c20v18 = c20v18(c20v19, c20v20)
        c20v19 = Lerp
        c20v19 = c20v19(c20v14, c20v15, c20v18)
        c20v20 = math.random
        c20v20 = c20v20()
        if c20v20 <= c20v19 then
          c20v11 = 1
        end
      end
    end
    c20v20 = nil
    c20v21 = v59
    c20v22 = nil
    c20v18 = c20v4:CreateRandomAgent(c20v20, c20v21, c20v7, c20v22, c20v11)
    c20v19 = IsNull
    c20v19 = c20v19(c20v18)
    if c20v19 then
      c20v19 = Time
      c20v19 = c20v19()
      c20v20 = v14
      if c20v20 < c20v19 then
        c20v20 = print
        c20v21 = "Could not spawn agent"
        c20v20(c20v21)
        c20v20 = c20v19 + 5
        v14 = c20v20
        do return c20v18 end
      end
    else
      c20v19 = v104
      c20v19(c20v18, c20v1, c20v2, c20v3)
    end
    do return c20v18 end
  end
  v108 = function(c21v0, c21v1)
    local c21v2, c21v3, c21v4, c21v5, c21v6, c21v7, c21v8, c21v9, c21v10, c21v11, c21v12, c21v13, c21v14
    c21v2 = gRegion
    c21v2 = c21v2:Name__c988433c()
    c21v3 = gGameRules
    c21v3 = c21v3:GetMission()
    c21v4 = c21v3:GetFactionTag()
    c21v5 = nil
    c21v6 = nil
    c21v7 = c21v3.goalTag
    c21v8 = v84
    if c21v7 == c21v8 then
      c21v5 = v20
      c21v6 = v21
    else
      c21v7 = v58
      if c21v4 == c21v7 then
        c21v5 = v16
        c21v6 = v17
      else
        c21v5 = v18
        c21v6 = v19
      end
    end
    c21v7 = math.max
    c21v2 = c21v7(c21v2, c21v1)
    c21v7 = v0
    c21v7 = c21v7.Ternary
    c21v8 = Engine.IsConsole
    c21v8 = c21v8()
    c21v9 = 3
    c21v10 = 4
    c21v7 = c21v7(c21v8, c21v9, c21v10)
    c21v8 = Clamp
    c21v10 = 1
    c21v2 = c21v8(c21v2, c21v10, c21v7)
    c21v8 = Lerp
    c21v9 = c21v5[c21v2]
    c21v10 = c21v6[c21v2]
    c21v13 = _T.EndlessModeEnemyLevel
    c21v12 = IsNull
    c21v12 = c21v12(c21v13)
    if c21v12 then
      c21v12 = gRegion
      c21v12 = c21v12:GetNpcMgr()
      c21v12 = c21v12:GetAiDirector()
      c21v13 = _T
      c21v14 = c21v12:GetMinEnemyLevel()
      c21v13.EndlessModeEnemyLevel = c21v14
    end
    c21v14 = _T.EndlessModeEnemyLevel
    c21v13 = c21v14 / 30
    c21v14 = 1
    c21v12 = math.min
    c21v11 = c21v12(c21v13, c21v14)
    c21v8 = c21v8(c21v9, c21v10, c21v11)
    v15 = c21v8
    c21v8 = 15
    if c21v0 < c21v8 then
      c21v8 = c21v0 / 15
      c21v10 = Lerp
      c21v11 = 0
      c21v12 = v15
      c21v10 = c21v10(c21v11, c21v12, c21v8)
      c21v9 = math.floor
      c21v9 = c21v9(c21v10)
      v15 = c21v9
    end
    c21v8 = v75
    if c21v8 then
      c21v8 = v11
      c21v9 = 0
      if c21v9 < c21v8 then
        c21v10 = v15
        c21v9 = c21v10 * 0.65
        c21v8 = math.ceil
        c21v8 = c21v8(c21v9)
        v15 = c21v8
      end
    end
    c21v9 = v15
    c21v8 = math.floor
    c21v8 = c21v8(c21v9)
    v15 = c21v8
    c21v8 = gRegion
    c21v8 = c21v8:GetNpcMgr()
    c21v8 = c21v8:GetAiDirector()
    c21v10 = c21v8:GetNpcHardCap()
    c21v11 = v15
    c21v9 = math.min
    c21v9 = c21v9(c21v10, c21v11)
    v15 = c21v9
    do return end
  end
  v109 = function()
    local c22v0, c22v1, c22v2, c22v3, c22v4, c22v5
    c22v4 = v23
    c22v3 = math.cos
    c22v3 = c22v3(c22v4)
    c22v2 = c22v3 + 0.99
    c22v1 = c22v2 ^ 2
    c22v0 = c22v1 * 0.25
    c22v1 = Lerp
    c22v2 = 0.1
    c22v3 = 1.8
    c22v1 = c22v1(c22v2, c22v3, c22v0)
    c22v3 = v15
    c22v2 = 6.28 / c22v3
    c22v4 = v23
    c22v3 = c22v4 + c22v2
    v23 = c22v3
    c22v3 = v23
    c22v4 = 6.28
    if c22v4 < c22v3 then
      c22v3 = math.mod
      c22v4 = v23
      c22v5 = 6.28
      c22v3 = c22v3(c22v4, c22v5)
      v23 = c22v3
    end
    do return c22v1 end
  end
  v110 = function(c23v0)
    local c23v1, c23v2, c23v3, c23v4
    c23v1 = v15
    if c23v0 then
      c23v3 = c23v1 * 0.8
      c23v2 = math.floor
      c23v1 = c23v2(c23v3)
    end
    c23v2 = gRegion
    c23v2 = c23v2:GetNpcMgr()
    c23v2 = c23v2:GetAiDirector()
    c23v3 = c23v2:Name__dab3929a()
    if c23v3 < c23v1 then
      c23v3 = c23v2:Name__4d3a2098()
      c23v4 = c23v1 + 20
      if c23v3 < c23v4 then
        c23v3 = true
        do return c23v3 end
      end
    end
    c23v3 = false
    do return c23v3 end
  end
  v111 = function()
    local c24v0, c24v1, c24v2, c24v3, c24v4, c24v5, c24v6, c24v7, c24v8, c24v9, c24v10
    c24v0 = gRegion
    c24v0 = c24v0:GetHumanPlayers()
    c24v1 = ipairs
    c24v1, c24v2, c24v3 = c24v1(c24v0)
    for __renovice_for_0_0, __renovice_for_0_1 in c24v1, c24v2, c24v3 do
      c24v4 = IsNull
      c24v4 = c24v4(__renovice_for_0_1)
      if c24v4 then
        continue
      end
      c24v4 = __renovice_for_0_1:GetOwnedPowerSuitAvatar()
      c24v5 = IsNull
      c24v5 = c24v5(c24v4)
      if c24v5 then
        continue
      end
      c24v5 = c24v4:InventoryControl()
      c24v7 = v87
      c24v5 = c24v5:Name__ec179f6f(c24v7)
      c24v6 = __renovice_for_0_1:GetAvatar()
      c24v7 = IsNull
      c24v7 = c24v7(c24v6)
      if (not c24v7 and c24v6 ~= c24v4) then
        c24v7 = c24v6:InventoryControl()
        c24v9 = v87
        c24v7 = c24v7:Name__ec179f6f(c24v9)
        c24v5 = c24v5 + c24v7
        c24v7 = __renovice_for_0_1:GetOperatorAvatar()
        c24v8 = IsNull
        c24v8 = c24v8(c24v7)
        if (not c24v8 and c24v6 ~= c24v7) then
          c24v8 = c24v7:InventoryControl()
          c24v10 = v87
          c24v8 = c24v8:Name__ec179f6f(c24v10)
          c24v5 = c24v5 + c24v8
        end
      end
      c24v7 = 10
      if not (c24v5 < c24v7) then
        continue
      end
      c24v7 = false
      do return c24v7 end
    end
    c24v1 = true
    do return c24v1 end
  end
  v112 = function(c25v0, c25v1, c25v2, c25v3)
    local c25v4, c25v5, c25v6, c25v7, c25v8, c25v9, c25v10, c25v11, c25v12, c25v13, c25v14, c25v15, c25v16, c25v17
    c25v14 = nil
    c25v15 = c25v14:Name__4d3a2098()
    c25v13 = nil
    c25v16 = c25v13 + 20
    c25v12 = true
    c25v12 = false
    if not c25v12 then
      c25v4 = nil
      do return c25v4 end
    end
    c25v12 = Sleep
    c25v13 = 0
    c25v12(c25v13)
    c25v12 = Name__3b4b94b0
    c25v12 = c25v12()
    c25v4 = c25v4 - c25v12
    c25v12 = 0
    if c25v4 < c25v12 then
      c25v12 = 0
      do return c25v12 end
    end
    c25v10 = v107
    c25v6 = nil
    c25v8 = nil
    c25v9 = nil
    c25v10 = c25v10(c25v6, c25v2, c25v9, c25v8)
    c25v11 = IsNull
    c25v11 = c25v11(c25v10)
    if c25v11 then
      do return c25v4 end
    end
    c25v16 = v23
    c25v15 = math.cos
    c25v15 = c25v15(c25v16)
    c25v14 = c25v15 + 0.99
    c25v13 = c25v14 ^ 2
    c25v12 = c25v13 * 0.25
    c25v13 = Lerp
    c25v14 = 0.1
    c25v15 = 1.8
    c25v13 = c25v13(c25v14, c25v15, c25v12)
    c25v15 = v15
    c25v14 = 6.28 / c25v15
    c25v16 = v23
    c25v15 = c25v16 + c25v14
    v23 = c25v15
    c25v15 = v23
    c25v16 = 6.28
    if c25v16 < c25v15 then
      c25v15 = math.mod
      c25v16 = v23
      c25v17 = 6.28
      c25v15 = c25v15(c25v16, c25v17)
      v23 = c25v15
    end
    c25v11 = c25v13
    c25v13 = v22
    c25v12 = c25v13 + c25v11
    v22 = c25v12
    c25v12 = v22
    c25v13 = 0
    if c25v13 < c25v12 then
      c25v14 = v22
      c25v12 = math.min
      c25v12 = c25v12(c25v4, c25v14)
      do return c25v12 end
    end
    c25v13 = v15
    c25v7 = nil
    if c25v7 then
      c25v15 = c25v13 * 0.8
      c25v14 = math.floor
      c25v13 = c25v14(c25v15)
    end
    c25v14 = gRegion
    c25v14 = c25v14:GetNpcMgr()
    c25v14 = c25v14:GetAiDirector()
    c25v15 = c25v14:Name__dab3929a()
    local __renovice_state_0 = 6
    if __renovice_state_0 == 0 then
      c25v4 = 0.5
      c25v5 = gGameRules
      c25v7 = v44
      c25v8 = 0
      c25v5 = c25v5:GetNetPersistentVar(c25v7, c25v8)
      c25v7 = c25v0 * 0.5
      c25v8 = c25v5 * 0.75
      c25v6 = c25v7 + c25v8
      c25v8 = #c25v2
      if c25v8 == 0 then
        __renovice_state_0 = 2
      else
        __renovice_state_0 = 1
      end
    end
    if __renovice_state_0 == 1 then
      c25v7 = false
      __renovice_state_0 = 3
    end
    if __renovice_state_0 == 2 then
      c25v7 = true
      __renovice_state_0 = 3
    end
    if __renovice_state_0 == 3 then
      c25v8 = v108
      c25v10 = #c25v2
      c25v8(c25v6, c25v10)
      c25v9 = v15
      if not c25v7 then
        __renovice_state_0 = 5
      else
        __renovice_state_0 = 4
      end
    end
    if __renovice_state_0 == 4 then
      c25v11 = c25v9 * 0.8
      c25v10 = math.floor
      c25v9 = c25v10(c25v11)
      __renovice_state_0 = 5
    end
    if __renovice_state_0 == 5 then
      c25v10 = gRegion
      c25v10 = c25v10:GetNpcMgr()
      c25v10 = c25v10:GetAiDirector()
      c25v11 = c25v10:Name__dab3929a()
      if not (c25v11 < c25v9) then
        __renovice_state_0 = 8
      else
        __renovice_state_0 = 6
      end
    end
    if __renovice_state_0 == 6 then
      c25v11 = c25v10:Name__4d3a2098()
      c25v12 = c25v9 + 20
      if not (c25v11 < c25v12) then
        __renovice_state_0 = 8
      else
        __renovice_state_0 = 7
      end
    end
    if __renovice_state_0 == 7 then
      c25v8 = true
      __renovice_state_0 = 9
    end
    if __renovice_state_0 == 8 then
      c25v8 = false
      __renovice_state_0 = 9
    end
    if __renovice_state_0 == 9 then
      if c25v8 then
        __renovice_state_0 = 11
      else
        __renovice_state_0 = 10
      end
    end
    if __renovice_state_0 == 10 then
      do return c25v4 end
    end
    if __renovice_state_0 == 11 then
      c25v9 = cellItemPickup
      c25v8 = IsNull
      c25v8 = c25v8(c25v9)
      if not c25v8 then
        __renovice_state_0 = 13
      else
        __renovice_state_0 = 12
      end
    end
    if __renovice_state_0 == 12 then
      c25v8 = print
      c25v9 = "No cellItemPickup"
      c25v8(c25v9)
      __renovice_state_0 = 26
    end
    if __renovice_state_0 == 13 then
      c25v8 = gRegion
      c25v10 = cellItemPickup
      c25v8 = c25v8:Name__0b406dc3(c25v10)
      if not c25v8 then
        __renovice_state_0 = 26
      else
        __renovice_state_0 = 14
      end
    end
    if __renovice_state_0 == 14 then
      c25v9 = ipairs
      c25v9, c25v10, c25v11 = c25v9(c25v3)
      __renovice_state_0 = 17
    end
    if __renovice_state_0 == 15 then
      c25v14 = c25v13:GetPower()
      c25v15 = 0
      if not (c25v15 < c25v14) then
        __renovice_state_0 = 17
      else
        __renovice_state_0 = 16
      end
    end
    if __renovice_state_0 == 16 then
      c25v8 = true
      __renovice_state_0 = 19
    end
    if __renovice_state_0 == 17 then
      __renovice_state_0 = 18
    end
    if __renovice_state_0 == 18 then
      c25v8 = false
      __renovice_state_0 = 19
    end
    if __renovice_state_0 == 19 then
      if c25v8 then
        __renovice_state_0 = 26
      else
        __renovice_state_0 = 20
      end
    end
    if __renovice_state_0 == 20 then
      c25v8 = v77
      if not c25v8 then
        __renovice_state_0 = 25
      else
        __renovice_state_0 = 21
      end
    end
    if __renovice_state_0 == 21 then
      c25v8 = v111
      c25v8 = c25v8()
      if c25v8 then
        __renovice_state_0 = 25
      else
        __renovice_state_0 = 22
      end
    end
    if __renovice_state_0 == 22 then
      c25v8 = gRegion
      c25v10 = v86
      c25v8 = c25v8:FindAll(c25v10)
      c25v9 = #c25v8
      c25v10 = 10
      if not (c25v10 <= c25v9) then
        __renovice_state_0 = 26
      else
        __renovice_state_0 = 23
      end
    end
    if __renovice_state_0 == 23 then
      do return c25v4 end
    end
    if __renovice_state_0 == 25 then
      do return c25v4 end
    end
    if __renovice_state_0 == 26 then
      c25v10 = v22
      c25v9 = c25v10 - c25v1
      c25v10 = -0.5
      c25v8 = math.max
      c25v8 = c25v8(c25v9, c25v10)
      v22 = c25v8
      c25v8 = v22
      c25v9 = 0
      if not (c25v9 < c25v8) then
        __renovice_state_0 = 28
      else
        __renovice_state_0 = 27
      end
    end
    if __renovice_state_0 == 27 then
      c25v10 = v22
      c25v8 = math.min
      c25v8 = c25v8(c25v4, c25v10)
      do return c25v8 end
    end
    if __renovice_state_0 == 28 then
      c25v8 = gRegion
      c25v8 = c25v8:GetHumanPlayerAvatars()
      c25v9 = gGameRules
      c25v11 = v47
      c25v12 = 0
      c25v9 = c25v9:GetNetPersistentVar(c25v11, c25v12)
    end
    for __renovice_for_0_0, __renovice_for_0_1 in c25v9, c25v10, c25v11 do
    end
    do return end
  end
  v113 = function(c26v0, c26v1)
    local c26v2, c26v3, c26v4, c26v5, c26v6, c26v7, c26v8, c26v9, c26v10, c26v11
    c26v2 = #c26v1
    c26v3 = 2
    if c26v2 < c26v3 then
      do return end
    end
    c26v2 = 0
    c26v3 = 0
    c26v5 = #c26v1
    c26v4 = c26v1[c26v5]
    c26v4 = c26v4:GetPosition()
    c26v7 = 1
    c26v5 = #c26v1
    c26v6 = 1
    for __renovice_for_0_0 = c26v7, c26v5, c26v6 do
      c26v8 = c26v1[__renovice_for_0_0]
      c26v8 = c26v8:GetPosition()
      c26v9 = Distance
      c26v9 = c26v9(c26v4, c26v8)
      c26v2 = c26v2 + c26v9
      c26v3 = c26v3 + 1
      c26v4 = c26v8
    end
    c26v5 = c26v2 / c26v3
    c26v6 = v0
    c26v6 = c26v6.Round
    c26v2 = c26v6(c26v2)
    c26v6 = v0
    c26v6 = c26v6.Round
    c26v5 = c26v6(c26v5)
    c26v6 = print
    c26v9 = " tour length: "
    c26v10 = " m ("
    c26v11 = "m avg)"
    c26v7 = c26v0 .. c26v9 .. c26v2 .. c26v10 .. c26v5 .. c26v11
    c26v6(c26v7)
    do return end
  end
  v114 = function(c27v0)
    local c27v1, c27v2, c27v3, c27v4, c27v5, c27v6, c27v7, c27v8, c27v9, c27v10, c27v11
    c27v1 = c27v0[1]
    c27v1 = c27v1:GetPosition()
    c27v2 = #c27v0
    c27v5 = 2
    c27v3 = c27v2
    c27v4 = 1
    for __renovice_for_0_0 = c27v5, c27v3, c27v4 do
      c27v6 = nil
      c27v7 = nil
      c27v10 = __renovice_for_0_0
      c27v8 = c27v2
      c27v9 = 1
      for __renovice_for_1_0 = c27v10, c27v8, c27v9 do
        c27v11 = c27v0[__renovice_for_1_0]
        c27v11 = c27v11:DistanceToPoint(c27v1)
        if (c27v6 == nil or c27v11 < c27v7) then
          c27v6 = __renovice_for_1_0
          c27v7 = c27v11
        end
      end
      if c27v6 ~= __renovice_for_0_0 then
        c27v8 = c27v0[__renovice_for_0_0]
        c27v9 = c27v0[c27v6]
        c27v0[__renovice_for_0_0] = c27v9
        c27v0[c27v6] = c27v8
      end
      c27v8 = c27v0[__renovice_for_0_0]
      c27v1 = c27v8:GetPosition()
    end
    do return end
  end
  v115 = function()
    local c28v0, c28v1, c28v2, c28v3, c28v4, c28v5, c28v6, c28v7, c28v8, c28v9, c28v10, c28v11, c28v12, c28v13, c28v14, c28v15, c28v16, c28v17, c28v18, c28v19, c28v20, c28v21, c28v22, c28v23, c28v24, c28v25, c28v26, c28v27, c28v28
    c28v0 = gRegion
    c28v2 = Symbol
    local __renovice_local_0 = "Spawn"
    c28v0 = c28v0:FindTagged(c28v2(__renovice_local_0))
    c28v1 = #c28v0
    if c28v1 == 0 then
      do return end
    end
    c28v1 = v75
    if c28v1 then
      c28v1 = gRegion
      __renovice_local_0 = v33
      c28v1 = c28v1:FindTagged(__renovice_local_0)
      v69 = c28v1
    else
      c28v1 = {}
      v69 = c28v1
      c28v1 = gRegion
      __renovice_local_0 = v33
      c28v1 = c28v1:FindTagged(__renovice_local_0)
      c28v3 = 1
      c28v2 = #c28v1
      __renovice_local_0 = 1
      for __renovice_for_0_0 = c28v3, c28v2, __renovice_local_0 do
        c28v5 = v69
        c28v6 = c28v1[__renovice_for_0_0]
        c28v4 = table.insert
        c28v4(c28v5, c28v6)
      end
      c28v2 = gRegion
      c28v3 = v32
      c28v1 = c28v2:FindTagged(c28v3)
      c28v3 = 1
      c28v2 = #c28v1
      __renovice_local_0 = 1
      for __renovice_for_1_0 = c28v3, c28v2, __renovice_local_0 do
        c28v5 = v69
        c28v6 = c28v1[__renovice_for_1_0]
        c28v4 = table.insert
        c28v4(c28v5, c28v6)
      end
    end
    c28v1 = v80
    if c28v1 then
      c28v1 = _T.FilterEntitiesToCurrentLayer
      if c28v1 then
        c28v1 = _T.FilterEntitiesToCurrentLayer
        c28v2 = v69
        c28v1 = c28v1(c28v2)
        v69 = c28v1
      end
      c28v1 = v0
      c28v1 = c28v1.ShuffleTable
      c28v2 = v69
      c28v1(c28v2)
      do return end
    end
    c28v1 = gGameRules
    c28v1 = c28v1:GetMission()
    c28v1 = c28v1.goalTag
    c28v2 = true
    __renovice_local_0 = Symbol
    c28v3 = "ShieldExcav"
    __renovice_local_0 = __renovice_local_0(c28v3)
    if c28v1 ~= __renovice_local_0 then
      __renovice_local_0 = Symbol
      c28v3 = "OldWorldSalvage"
      __renovice_local_0 = __renovice_local_0(c28v3)
      if c28v1 ~= __renovice_local_0 then
        c28v2 = false
      else
        c28v2 = true
      end
    end
    if c28v2 then
      __renovice_local_0 = v3
      __renovice_local_0 = __renovice_local_0.SortByLayerIndex
      c28v3 = v69
      __renovice_local_0 = __renovice_local_0(c28v3)
      v69 = __renovice_local_0
      c28v3 = v69
      c28v5 = v69
      c28v4 = #c28v5
      __renovice_local_0 = c28v3[c28v4]
      __renovice_local_0 = __renovice_local_0:GetZone()
      __renovice_local_0 = __renovice_local_0:GetLayerIndex()
      c28v6 = v69
      c28v5 = #c28v6
      c28v3 = 1
      c28v4 = -1
      for __renovice_for_2_0 = c28v5, c28v3, c28v4 do
        c28v6 = v69[__renovice_for_2_0]
        c28v6 = c28v6:GetZone()
        c28v6 = c28v6:GetLayerIndex()
        if c28v6 == __renovice_local_0 then
          continue
        end
        c28v7 = table.remove
        c28v8 = v69
        c28v7(c28v8, __renovice_for_2_0)
      end
      do return end
    end
    c28v3 = v69
    __renovice_local_0 = #c28v3
    if __renovice_local_0 == 0 then
      do return end
    end
    __renovice_local_0 = print
    c28v6 = v69
    c28v4 = #c28v6
    c28v5 = " extractors found"
    c28v3 = c28v4 .. c28v5
    __renovice_local_0(c28v3)
    c28v3 = v69
    __renovice_local_0 = #c28v3
    if __renovice_local_0 == 1 then
      do return end
    end
    __renovice_local_0 = {}
    c28v3 = {}
    c28v6 = 1
    c28v7 = v69
    c28v4 = #c28v7
    c28v5 = 1
    for __renovice_for_3_0 = c28v6, c28v4, c28v5 do
      c28v7 = v69[__renovice_for_3_0]
      c28v8 = c28v7:GetZone()
      c28v9 = IsNull
      c28v9 = c28v9(c28v8)
      if c28v9 then
        c28v9 = print
        c28v11 = "Skipping "
        c28v12 = c28v7:GetFullName()
        c28v13 = " (in the void)"
        c28v10 = c28v11 .. c28v12 .. c28v13
        c28v9(c28v10)
        continue
      end
      c28v9 = print
      c28v11 = "Found"
      c28v12 = c28v7:GetFullName()
      c28v10 = c28v11 .. c28v12
      c28v9(c28v10)
      c28v9 = c28v8:GetLayerIndex()
      c28v10 = __renovice_local_0[c28v9]
      if c28v10 == nil then
        c28v10 = {c28v7}
        __renovice_local_0[c28v9] = c28v10
        c28v10 = table.insert
        c28v10(c28v3, c28v7)
        continue
      end
      c28v11 = __renovice_local_0[c28v9]
      c28v10 = table.insert
      c28v10(c28v11, c28v7)
    end
    c28v4 = v114
    c28v4(c28v3)
    c28v4 = print
    c28v6 = #c28v3
    c28v7 = " tiles in path"
    c28v5 = c28v6 .. c28v7
    c28v4(c28v5)
    c28v4 = #c28v3
    if c28v4 == 1 then
      do return end
    end
    c28v5 = #c28v3
    c28v4 = c28v3[c28v5]
    c28v5 = nil
    c28v6 = {}
    c28v9 = 1
    c28v7 = #c28v3
    c28v8 = 1
    for __renovice_for_4_0 = c28v9, c28v7, c28v8 do
      c28v10 = c28v3[__renovice_for_4_0]
      c28v11 = gRegion
      c28v11 = c28v11:FindZonePath(c28v4, c28v10)
      c28v14 = 1
      c28v12 = #c28v11
      c28v13 = 1
      for __renovice_for_5_0 = c28v14, c28v12, c28v13 do
        c28v15 = c28v11[__renovice_for_5_0]
        c28v15 = c28v15:GetZone()
        c28v16 = IsNull
        c28v16 = c28v16(c28v15)
        if c28v16 then
          continue
        end
        c28v16 = c28v15:GetLayerIndex()
        c28v17 = __renovice_local_0[c28v16]
        if (c28v17 ~= nil and c28v5 ~= c28v16) then
          c28v17 = table.insert
          c28v17(c28v6, c28v16)
          c28v5 = c28v16
        end
      end
      c28v4 = c28v10
    end
    c28v7 = c28v6[1]
    c28v9 = #c28v6
    c28v8 = c28v6[c28v9]
    if c28v7 == c28v8 then
      c28v7 = table.remove
      c28v9 = #c28v6
      c28v7(c28v6, c28v9)
    end
    c28v7 = print
    c28v9 = #c28v6
    c28v10 = " tiles in tour"
    c28v8 = c28v9 .. c28v10
    c28v7(c28v8)
    c28v9 = 1
    c28v7 = #__renovice_local_0
    c28v8 = 1
    for __renovice_for_6_0 = c28v9, c28v7, c28v8 do
      c28v10 = v0
      c28v10 = c28v10.ShuffleTable
      c28v11 = __renovice_local_0[__renovice_for_6_0]
      c28v10(c28v11)
    end
    c28v7 = {}
    c28v10 = 1
    c28v8 = #c28v6
    c28v9 = 1
    for __renovice_for_7_0 = c28v10, c28v8, c28v9 do
      c28v11 = c28v6[__renovice_for_7_0]
      c28v12 = c28v7[c28v11]
      if c28v12 == nil then
        c28v12 = 1
        c28v7[c28v11] = c28v12
        continue
      end
      c28v13 = c28v7[c28v11]
      c28v12 = c28v13 + 1
      c28v7[c28v11] = c28v12
    end
    c28v8 = #c28v6
    c28v11 = 1
    c28v9 = c28v8
    c28v10 = 1
    for __renovice_for_8_0 = c28v11, c28v9, c28v10 do
      c28v14 = c28v6[__renovice_for_8_0]
      c28v12 = table.insert
      c28v12(c28v6, c28v14)
    end
    c28v11 = 1
    c28v9 = c28v8
    c28v10 = 1
    for __renovice_for_9_0 = c28v11, c28v9, c28v10 do
      c28v14 = c28v6[__renovice_for_9_0]
      c28v12 = table.insert
      c28v12(c28v6, c28v14)
    end
    c28v9 = {}
    v69 = c28v9
    c28v9 = nil
    c28v10 = 0
    c28v13 = 1
    c28v11 = #c28v6
    c28v12 = 1
    for __renovice_for_10_0 = c28v13, c28v11, c28v12 do
      c28v14 = c28v6[__renovice_for_10_0]
      c28v15 = __renovice_local_0[c28v14]
      c28v16 = 100
      c28v17 = c28v7[c28v14]
      if c28v17 == 1 then
        c28v16 = c28v16 * 0.5
      end
      c28v19 = 1
      c28v17 = #c28v15
      c28v18 = 1
      for __renovice_for_11_0 = c28v19, c28v17, c28v18 do
        c28v20 = c28v15[__renovice_for_11_0]
        c28v21 = 0
        if c28v9 ~= nil then
          c28v21 = c28v20:DistanceToEntity(c28v9)
          c28v23 = c28v10 + c28v21
          c28v26 = v69
          c28v25 = #c28v26
          c28v24 = c28v25 + 1
          c28v22 = c28v23 / c28v24
          if c28v22 < c28v16 then
            c28v21 = 0
          end
          c28v24 = v69
          c28v23 = #c28v24
          c28v24 = 1
          if not (c28v23 < c28v24) then
            c28v24 = v69
            c28v28 = v69
            c28v27 = #c28v28
            c28v26 = c28v27 - 1
            c28v25 = c28v26 + 1
            c28v23 = c28v24[c28v25]
            if c28v23 == c28v20 then
              c28v21 = 0
            else
              c28v24 = v69
              c28v23 = #c28v24
              c28v24 = 2
              if not (c28v23 < c28v24) then
                c28v24 = v69
                c28v28 = v69
                c28v27 = #c28v28
                c28v26 = c28v27 - 2
                c28v25 = c28v26 + 1
                c28v23 = c28v24[c28v25]
                if c28v23 == c28v20 then
                  c28v21 = 0
                end
              end
            end
          end
        end
        repeat
          if c28v9 ~= nil then
            c28v22 = 50
            if not (c28v22 < c28v21) then break end
          end
          c28v23 = v69
          c28v22 = table.insert
          c28v22(c28v23, c28v20)
          c28v10 = c28v10 + c28v21
          c28v9 = c28v20
          c28v22 = table.remove
          c28v24 = 1
          c28v22(c28v15, c28v24)
          c28v22 = table.insert
          c28v22(c28v15, c28v20)
        until true
      end
    end
    c28v11 = gRegion
    c28v13 = c28v0[1]
    c28v14 = v69
    c28v11 = c28v11:Name__81993ba3(c28v13, c28v14)
    c28v12 = IsNull
    c28v12 = c28v12(c28v11)
    if not c28v12 then
      c28v14 = 1
      c28v15 = v69
      c28v12 = #c28v15
      c28v13 = 1
      for __renovice_for_12_0 = c28v14, c28v12, c28v13 do
        c28v15 = v69[1]
        if c28v15 == c28v11 then break end
        c28v16 = table.remove
        c28v17 = v69
        c28v18 = 1
        c28v16(c28v17, c28v18)
        c28v17 = v69
        c28v16 = table.insert
        c28v16(c28v17, c28v15)
      end
    end
    c28v12 = v113
    c28v13 = "Optimized"
    c28v14 = v69
    c28v12(c28v13, c28v14)
    do return end
  end
  v116 = function(c29v0, c29v1, c29v2)
    local c29v3, c29v4, c29v5, c29v6, c29v7, c29v8, c29v9, c29v10, c29v11, c29v12, c29v13, c29v14, c29v15, c29v16, c29v17, c29v18, c29v19, c29v20, c29v21
    local __renovice_local_0 = v76
    if __renovice_local_0 then
      __renovice_local_0 = _T.extractionAvailable
      if __renovice_local_0 then
        do return end
      end
    end
    __renovice_local_0 = #c29v1
    v11 = __renovice_local_0
    __renovice_local_0 = ipairs
    c29v3 = nil
    c29v4 = nil
    __renovice_local_0, c29v3, c29v4 = __renovice_local_0(c29v2)
    for __renovice_for_0_0, __renovice_for_0_1 in __renovice_local_0, c29v3, c29v4 do
      c29v7 = IsNull
      c29v7 = c29v7(__renovice_for_0_1)
      if c29v7 then
        continue
      end
      c29v7 = __renovice_for_0_1:IsEnabled()
      if not c29v7 then
        continue
      end
      c29v8 = v11
      c29v7 = c29v8 + 1
      v11 = c29v7
    end
    __renovice_local_0 = v11
    c29v3 = v10
    if c29v3 <= __renovice_local_0 then
      do return end
    end
    __renovice_local_0 = v69
    if __renovice_local_0 == nil then
      __renovice_local_0 = v115
      __renovice_local_0()
    end
    c29v3 = v69
    __renovice_local_0 = #c29v3
    if __renovice_local_0 == 0 then
      do return end
    end
    __renovice_local_0 = gGameRules
    c29v5 = v46
    c29v6 = 0
    c29v3 = __renovice_local_0:GetNetPersistentVar(c29v5, c29v6)
    c29v6 = v47
    c29v7 = 0
    c29v4 = __renovice_local_0:GetNetPersistentVar(c29v6, c29v7)
    if (c29v3 == 1 and c29v4 == 0) then
      do return end
    end
    c29v6 = 1
    c29v9 = v69
    c29v8 = #c29v9
    c29v7 = c29v3 % c29v8
    c29v5 = c29v6 + c29v7
    c29v6 = v69[c29v5]
    c29v7 = gRegion
    c29v9 = gLotusExcavationStateType
    c29v10 = c29v6:GetPosition()
    c29v11 = 5
    c29v7 = c29v7:FindNearest(c29v9, c29v10, c29v11)
    c29v8 = IsNull
    c29v8 = c29v8(c29v7)
    if c29v8 then
      c29v8 = print
      c29v10 = "Could not find excavator state for "
      c29v11 = c29v6:GetFullName()
      c29v9 = c29v10 .. c29v11
      c29v8(c29v9)
      c29v8 = table.remove
      c29v9 = v69
      c29v8(c29v9, c29v5)
      do return end
    end
    c29v8 = c29v7:IsEnabled()
    if c29v8 then
      do return end
    end
    c29v10 = v42
    c29v11 = 0
    c29v8 = __renovice_local_0:GetNetPersistentVar(c29v10, c29v11)
    if c29v8 == 0 then
      c29v9 = gRegion
      c29v11 = gMultiAvatarTriggerType
      c29v12 = c29v6:GetPosition()
      c29v13 = 0.2
      c29v9 = c29v9:FindNearest(c29v11, c29v12, c29v13)
      c29v10 = IsNull
      c29v10 = c29v10(c29v9)
      if not c29v10 then
        c29v10 = c29v9:IsEnabled()
        if c29v10 then
          do return end
        end
      end
      c29v12 = v44
      c29v13 = 0
      c29v10 = __renovice_local_0:GetNetPersistentVar(c29v12, c29v13)
      c29v11 = 500
      c29v12 = gGameRules
      c29v12 = c29v12:GetMission()
      c29v13 = v81
      if not c29v13 then
        c29v13 = c29v12.maxWaveNum
      end
      c29v14 = 0
      if c29v14 < c29v13 then
        c29v14 = v28
        c29v11 = c29v13 * c29v14
      end
      c29v14 = true
      c29v15 = gGameRules
      c29v15 = c29v15:GetMission()
      c29v15 = c29v15.periodicMissionTag
      c29v16 = v1
      c29v16 = c29v16.ELITE_ALERT_PERIODIC_MISSION_TAG
      if c29v15 ~= c29v16 then
        c29v15 = gGameRules
        c29v15 = c29v15:GetMission()
        c29v15 = c29v15.periodicMissionTag
        c29v16 = v1
        c29v16 = c29v16.ELITE_ALERT_PERIODIC_MISSION_TAG_ALT
        if c29v15 ~= c29v16 then
          c29v14 = false
        else
          c29v14 = true
        end
      end
      if c29v14 then
        c29v11 = c29v11 * 2
      end
      c29v14 = false
      c29v17 = v53
      c29v15 = __renovice_local_0:GetNetPersistentVar(c29v17)
      c29v16 = v78
      if (c29v16 and c29v15 == 0) then
        c29v16 = v90
        c29v16 = c29v16()
        if c29v16 then
          c29v14 = true
        end
      end
      c29v16 = true
      c29v17 = c29v12.goalTag
      c29v18 = Symbol
      c29v19 = "ShieldExcav"
      c29v18 = c29v18(c29v19)
      if c29v17 ~= c29v18 then
        c29v17 = c29v12.goalTag
        c29v18 = Symbol
        c29v19 = "OldWorldSalvage"
        c29v18 = c29v18(c29v19)
        if c29v17 ~= c29v18 then
          c29v16 = false
        else
          c29v16 = true
        end
      end
      if ((c29v16 and c29v13 <= c29v3) and not c29v14) then
        c29v17 = 0
        v10 = c29v17
        do return end
      end
      c29v17 = v76
      if ((c29v17 and c29v11 <= c29v10) and not c29v16) then
        c29v17 = 0
        v10 = c29v17
        do return end
      end
      local __renovice_state_0 = -1
      c29v17 = nil
      if c29v3 == 0 then
        __renovice_state_0 = -1
      else
        __renovice_state_0 = 1
      end
      if __renovice_state_0 == 1 then
        c29v18 = _T.MissionDebug
        if not c29v18 then
          __renovice_state_0 = 3
        else
          __renovice_state_0 = 2
        end
      end
      if __renovice_state_0 == 2 then
        c29v18 = _T.MissionDebug.FastDig
        if not c29v18 then
          __renovice_state_0 = 3
        else
          __renovice_state_0 = -1
        end
      end
      if __renovice_state_0 == 3 then
        c29v17 = 60
        __renovice_state_0 = 4
      end
      if __renovice_state_0 ~= 4 then
        c29v17 = 2
      end
      c29v20 = v42
      c29v21 = c29v0 + c29v17
      __renovice_local_0:SetNetPersistentVar(c29v20, c29v21)
      do return end
    end
    if c29v0 < c29v8 then
      do return end
    end
    if c29v4 < c29v3 then
      do return end
    end
    c29v9 = v11
    if c29v9 == 0 then
      c29v9 = gRegion
      c29v9 = c29v9:GetNpcMgr()
      c29v9 = c29v9:GetAiDirector()
      c29v9:SetObjective(c29v6)
      c29v9:Name__7fccb7d5(c29v6)
    end
    c29v11 = v46
    c29v12 = c29v3 + 1
    __renovice_local_0:SetNetPersistentVar(c29v11, c29v12)
    c29v11 = v42
    c29v12 = 0
    __renovice_local_0:SetNetPersistentVar(c29v11, c29v12)
    c29v11 = "TriggerPort"
    c29v6:FirePort(c29v11)
    c29v9 = v2
    c29v9 = c29v9.PlayGlobalTransmission
    c29v10 = _T.MissionTransmissionSet
    c29v11 = v0
    c29v11 = c29v11.Ternary
    c29v13 = v11
    if c29v13 ~= 0 then
      c29v12 = false
    else
      c29v12 = true
    end
    c29v13 = Symbol
    c29v14 = "MissionIntro"
    c29v13 = c29v13(c29v14)
    c29v14 = Symbol
    c29v15 = "MissionScannerComplete"
    c29v9(c29v10, c29v11(c29v12, c29v13, c29v14(c29v15)))
    c29v9 = v2
    c29v9 = c29v9.PlayGlobalTransmission
    c29v10 = _T.MissionTransmissionSet
    c29v11 = v0
    c29v11 = c29v11.Ternary
    c29v13 = v11
    if c29v13 ~= 0 then
      c29v12 = false
    else
      c29v12 = true
    end
    c29v13 = Symbol
    c29v14 = "MissionIntroExtra"
    c29v13 = c29v13(c29v14)
    c29v14 = Symbol
    c29v15 = "MissionScannerCompleteExtra"
    c29v9(c29v10, c29v11(c29v12, c29v13, c29v14(c29v15)))
    do return end
  end
  v117 = function(c30v0, c30v1)
    local c30v2, c30v3, c30v4, c30v5, c30v6, c30v7
    c30v2 = false
    c30v3 = v77
    if (c30v3 and (c30v1 == nil or c30v1 == 1)) then
      c30v3 = gGameRules
      c30v5 = v52
      c30v6 = 1
      c30v3:SetNetPersistentVar(c30v5, c30v6)
      c30v3 = v0
      c30v3 = c30v3.Ternary
      if c30v1 ~= nil then
        c30v4 = false
      else
        c30v4 = true
      end
      c30v5 = 3
      c30v6 = 0
      c30v3 = c30v3(c30v4, c30v5, c30v6)
      while true do
        c30v4 = v1
        c30v4 = c30v4.IsTransmissionPlaying
        c30v4 = c30v4()
        if c30v4 then break end
        c30v4 = DeltaTime
        c30v4 = c30v4()
        c30v3 = c30v3 - c30v4
        c30v4 = 0
        if c30v3 <= c30v4 then break end
        c30v4 = Sleep
        c30v5 = 0
        c30v4(c30v5)
      end
      c30v3 = 20
      while true do
        c30v4 = v1
        c30v4 = c30v4.IsTransmissionPlaying
        c30v4 = c30v4()
        if not c30v4 then break end
        c30v4 = DeltaTime
        c30v4 = c30v4()
        c30v3 = c30v3 - c30v4
        c30v4 = 0
        if c30v3 <= c30v4 then break end
        c30v4 = Sleep
        c30v5 = 0
        c30v4(c30v5)
      end
      c30v4 = gGameRules
      c30v7 = false
      c30v4 = c30v4:OpenVoidProjectionRewardScreen(c30v0, c30v7)
      c30v5 = IsNull
      c30v5 = c30v5(c30v4)
      if not c30v5 then
        c30v2 = true
        while true do
          c30v5 = IsNull
          c30v5 = c30v5(c30v4)
          if c30v5 then break end
          c30v5 = Sleep
          c30v6 = 0
          c30v5(c30v6)
        end
        c30v5 = gGameRules
        c30v5:CloseVoidProjectionRewardScreen()
      end
    end
    if (c30v2 or c30v1 == 2) then
      c30v3 = gGameRules
      c30v5 = v52
      c30v6 = 2
      c30v3:SetNetPersistentVar(c30v5, c30v6)
      c30v3 = gGameRules
      if c30v1 == nil then
        c30v5 = false
      else
        c30v5 = true
      end
      c30v3 = c30v3:OpenVoidProjectionSelectionScreen(c30v5)
      c30v4 = IsNull
      c30v4 = c30v4(c30v3)
      if not c30v4 then
        while true do
          c30v4 = IsNull
          c30v4 = c30v4(c30v3)
          if c30v4 then break end
          c30v4 = Sleep
          c30v5 = 0
          c30v4(c30v5)
        end
      end
    end
    c30v3 = gGameRules
    c30v5 = v52
    c30v6 = 0
    c30v3:SetNetPersistentVar(c30v5, c30v6)
    do return end
  end
  v118 = function()
    local c31v0, c31v1, c31v2, c31v3, c31v4, c31v5, c31v6, c31v7, c31v8, c31v9, c31v10, c31v11, c31v12, c31v13, c31v14, c31v15, c31v16, c31v17, c31v18, c31v19, c31v20, c31v21, c31v22, c31v23, c31v24, c31v25
    c31v15 = nil
    c31v12 = c31v15
    c31v17 = gRegion
    c31v19 = v34
    c31v4 = c31v17:FindTagged(c31v19)
    c31v17 = {}
    v13 = c31v17
    c31v19 = 1
    c31v17 = #c31v4
    c31v18 = 1
    for __renovice_for_0_0 = c31v19, c31v17, c31v18 do
      c31v20 = c31v4[__renovice_for_0_0]
      c31v21 = gRegion
      c31v23 = gLotusExcavationStateType
      c31v24 = c31v20:GetPosition()
      c31v25 = 5
      c31v21 = c31v21:FindNearest(c31v23, c31v24, c31v25)
      c31v22 = IsNull
      c31v22 = c31v22(c31v21)
      if c31v22 then
        c31v22 = print
        c31v24 = "No state for "
        c31v25 = c31v20:GetFullName()
        c31v23 = c31v24 .. c31v25
        c31v22(c31v23)
      end
      v13[__renovice_for_0_0] = c31v21
    end
    c31v16 = true
    c31v19 = #c31v4
    c31v17 = 1
    c31v18 = -1
    c31v17 = v78
    c31v22 = v2
    c31v22 = c31v22.PlayLocalTransmission
    c31v23 = _T.MissionTransmissionSet
    c31v25 = c31v18[c31v21]
    c31v22(c31v23, c31v17, c31v25:GetAvatar())
    c31v21 = c31v4[c31v19]
    c31v20 = IsNull
    c31v20 = c31v20(c31v21)
    if c31v20 then
      c31v20 = table.remove
      c31v20(c31v4, c31v19)
      c31v20 = table.remove
      c31v21 = v13
      c31v20(c31v21, c31v19)
      c31v16 = true
    end
    c31v22 = v1
    c31v22 = c31v22.IsFirstTimeInNode
    c31v23 = c31v18[c31v21]
    c31v22 = c31v22(c31v23)
    if c31v22 then
      c31v22 = Symbol
      c31v23 = "MissionFirstExtractionAvailable"
      c31v17 = c31v22(c31v23)
    end
    c31v3 = nil
    c31v17 = c31v3.goalTag
    c31v18 = v84
    if c31v17 ~= c31v18 then
      c31v17 = v2
      c31v17 = c31v17.PlayGlobalTransmission
      c31v18 = _T.MissionTransmissionSet
      c31v19 = v66
      c31v17(c31v18, c31v19)
    end
    c31v15 = _T.DebugCompleteArena
    c31v1 = nil
    if (c31v15 or c31v1 ~= 2) then
      do return end
    end
    c31v15 = gGameRules
    c31v17 = v47
    c31v18 = 0
    c31v15 = c31v15:GetNetPersistentVar(c31v17, c31v18)
    c31v16 = false
    c31v17 = v66
    c31v18 = gGameRules
    c31v20 = v68
    c31v21 = 0
    c31v18 = c31v18:GetNetPersistentVar(c31v20, c31v21)
    if c31v18 == 1 then
      c31v18 = Symbol
      c31v19 = "MissionExtractionAvailablePistol"
      c31v17 = c31v18(c31v19)
    end
    c31v18 = gRegion
    c31v18 = c31v18:GetHumanPlayers()
    c31v21 = 1
    c31v19 = #c31v18
    c31v20 = 1
    c31v17 = v80
    if not c31v17 then
      c31v17 = gGameRules
      c31v19 = true
      c31v20 = true
      c31v17:SetObjectiveComplete(c31v19, c31v20)
      c31v18 = v82
      c31v17 = IsNull
      c31v17 = c31v17(c31v18)
      if not c31v17 then
        c31v17 = v82
        c31v19 = "Enable"
        c31v17:FirePort(c31v19)
      end
    end
    c31v7 = true
    c31v0 = gRegion
    c31v0 = c31v0:GetNpcMgr()
    c31v0 = c31v0:GetAiDirector()
    c31v3 = true
    c31v0:Enable(c31v3)
    c31v3 = false
    c31v0:Name__87452014(c31v3)
    c31v3 = false
    c31v0:SetEnableAutoSpawns(c31v3)
    c31v3 = true
    c31v0:SetLevelAlert(c31v3)
    c31v3 = 0
    c31v0:Name__f2101814(c31v3)
    c31v3 = 150
    c31v4 = 150
    c31v5 = false
    c31v6 = false
    c31v0:Name__b37ce12d(c31v3, c31v4, c31v5, c31v6)
    c31v3 = true
    c31v0:Name__46efd736(c31v3)
    c31v1 = v80
    if c31v1 then
      c31v3 = false
      c31v0:Name__4d8be231(c31v3)
      c31v3 = 10
      c31v4 = 150
      c31v5 = 0
      c31v6 = 3
      c31v7 = false
      c31v8 = false
      c31v9 = true
      c31v0:Name__7cfddb2b(c31v3, c31v4, c31v5, c31v6, c31v7, c31v8, c31v9)
    else
      c31v3 = 10
      c31v4 = 150
      c31v5 = 0
      c31v6 = 3
      c31v7 = true
      c31v8 = true
      c31v9 = true
      c31v0:Name__7cfddb2b(c31v3, c31v4, c31v5, c31v6, c31v7, c31v8, c31v9)
    end
    c31v3 = v60
    c31v0:Name__58d782d8(c31v3)
    c31v3 = v61
    c31v0:Name__58d782d8(c31v3)
    c31v3 = v62
    c31v0:Name__58d782d8(c31v3)
    c31v3 = v63
    c31v0:Name__58d782d8(c31v3)
    c31v3 = v64
    c31v0:Name__58d782d8(c31v3)
    c31v3 = 0
    c31v0:Name__af932d17(c31v3)
    c31v1 = v80
    if not c31v1 then
      c31v1 = gRegion
      c31v3 = v65
      c31v1 = c31v1:FindFirstTagged(c31v3)
      v82 = c31v1
    end
    c31v2 = _T.ExcavationScanner
    c31v1 = IsNull
    c31v1 = c31v1(c31v2)
    if not c31v1 then
      c31v3 = _T.ExcavationScanner
      c31v0:SetObjective(c31v3)
    else
      c31v1 = v80
      if not c31v1 then
        c31v2 = v82
        c31v1 = IsNull
        c31v1 = c31v1(c31v2)
        if not c31v1 then
          c31v3 = v82
          c31v0:SetObjective(c31v3)
        end
      end
    end
    c31v1 = gGameRules
    c31v3 = v40
    c31v1 = c31v1:GetNetPersistentVar(c31v3)
    c31v2 = gGameRules
    c31v4 = v43
    c31v5 = 0
    c31v2 = c31v2:GetNetPersistentVar(c31v4, c31v5)
    c31v3 = gGameRules
    c31v3 = c31v3:GetMission()
    c31v4 = {}
    c31v5 = {}
    v13 = c31v5
    c31v5 = {}
    c31v6 = 0
    c31v8 = gGameRules
    c31v10 = v55
    c31v11 = 0
    c31v8 = c31v8:GetNetPersistentVar(c31v10, c31v11)
    c31v9 = 0
    if not (c31v9 < c31v8) then
      c31v7 = false
    else
      c31v7 = true
    end
    v29 = c31v7
    while c31v1 == 0 do
      c31v7 = v112
      c31v11 = v13
      c31v6 = c31v7(c31v2, c31v6, c31v4, c31v11)
      c31v7 = Sleep
      c31v7(c31v6)
      c31v7 = gGameRules
      c31v9 = v40
      c31v1 = c31v7:GetNetPersistentVar(c31v9)
    end
    while c31v1 == 1 do
      c31v7 = v112
      c31v11 = v13
      c31v6 = c31v7(c31v2, c31v6, c31v4, c31v11)
      c31v7 = Sleep
      c31v7(c31v6)
      c31v7 = gGameRules
      c31v9 = v40
      c31v1 = c31v7:GetNetPersistentVar(c31v9)
    end
    c31v7 = gGameRules
    c31v9 = v30
    c31v10 = EMPTY_SYMBOL
    c31v11 = 0
    c31v12 = false
    c31v13 = false
    c31v14 = true
    c31v7:SetMissionTimer(c31v9, c31v10, c31v11, c31v12, c31v13, c31v14)
    c31v7 = gGameRules
    c31v9 = v30
    c31v7:Name__bb656394(c31v9, c31v2)
    _T.LastActivityTime = c31v2
    c31v9 = true
    c31v0:SetLevelAlert(c31v9)
    c31v9 = 10
    c31v0:RlJets(c31v9)
    c31v7 = false
    c31v8 = false
    c31v9 = 0
    c31v10 = gGameRules
    c31v12 = v45
    c31v13 = 0
    c31v10 = c31v10:GetNetPersistentVar(c31v12, c31v13)
    c31v14 = c31v10 / 200
    c31v13 = math.floor
    c31v13 = c31v13(c31v14)
    c31v12 = c31v13 + 1
    c31v11 = c31v12 * 200
    c31v12 = -1
    c31v13 = 0
    c31v14 = 0
    c31v17 = #c31v5
    if c31v17 == 0 then
      c31v17 = gRegion
      c31v19 = v38
      c31v5 = c31v17:FindTagged(c31v19)
      c31v17 = v80
      if c31v17 then
        c31v17 = _T.FilterEntitiesToCurrentLayer
        if c31v17 then
          c31v17 = _T.FilterEntitiesToCurrentLayer
          c31v5 = c31v17(c31v5)
        end
      end
    end
    c31v0:Name__01403939(c31v4)
    c31v17 = #c31v4
    c31v18 = 0
    if c31v18 < c31v17 then
      c31v17 = v80
      if c31v17 then
        c31v19 = 10
        c31v20 = 150
        c31v21 = 0
        c31v22 = 3
        c31v23 = false
        c31v24 = false
        c31v25 = true
        c31v0:Name__7cfddb2b(c31v19, c31v20, c31v21, c31v22, c31v23, c31v24, c31v25)
      else
        c31v19 = 10
        c31v20 = 150
        c31v21 = 0
        c31v22 = 3
        c31v23 = true
        c31v24 = false
        c31v25 = true
        c31v0:Name__7cfddb2b(c31v19, c31v20, c31v21, c31v22, c31v23, c31v24, c31v25)
      end
    end
    c31v17 = v102
    c31v17(c31v4)
    c31v17 = gRegion
    c31v17 = c31v17:GetHumanPlayerAvatars()
    c31v18 = 0
    c31v19 = ipairs
    c31v19, c31v20, c31v21 = c31v19(c31v17)
    for __renovice_for_1_0, __renovice_for_1_1 in c31v19, c31v20, c31v21 do
      c31v24 = IsNull
      c31v24 = c31v24(__renovice_for_1_1)
      if c31v24 then
        continue
      end
      c31v24 = __renovice_for_1_1:IsKilled()
      if c31v24 then
        continue
      end
      c31v18 = c31v18 + 1
    end
    c31v19 = #c31v17
    if (c31v13 ~= c31v19 or c31v14 ~= c31v18) then
      c31v19 = v102
      c31v19(c31v4)
      c31v13 = #c31v17
      c31v14 = c31v18
    end
    for __renovice_for_2_0, __renovice_for_2_1 in c31v19, c31v20, c31v21 do
    end
    c31v17 = v116
    c31v17(c31v2, c31v4, c31v5)
    c31v17 = _T.extractionAvailable
    if not c31v8 then
      c31v17 = v76
      if c31v17 then
        c31v17 = gGameRules
        c31v19 = v44
        c31v20 = 0
        c31v17 = c31v17:GetNetPersistentVar(c31v19, c31v20)
        c31v19 = v28
        c31v18 = c31v19 * 3
        if c31v18 <= c31v17 then
          c31v17 = gGameRules
          c31v19 = true
          c31v17:HideGameSession(c31v19)
          c31v8 = true
        end
      end
    end
    c31v17 = gGameRules
    c31v19 = v45
    c31v20 = 0
    c31v10 = c31v17:GetNetPersistentVar(c31v19, c31v20)
    if c31v10 ~= c31v9 then
      if (c31v9 < c31v11 and c31v11 <= c31v10) then
        c31v11 = c31v11 + 200
        c31v17 = v117
        c31v19 = c31v10 / 200
        c31v18 = math.floor
        c31v18 = c31v18(c31v19)
        c31v17(c31v18)
      end
      c31v9 = c31v10
    end
    c31v17 = v112
    c31v21 = v13
    c31v6 = c31v17(c31v2, c31v6, c31v4, c31v21)
    c31v18 = _T.DropshipNextEventTime
    c31v17 = IsNull
    c31v17 = c31v17(c31v18)
    if not c31v17 then
      c31v18 = gGameRules
      c31v20 = v49
      c31v21 = 0
      c31v18 = c31v18:GetNetPersistentVar(c31v20, c31v21)
      c31v17 = c31v2 - c31v18
      c31v18 = 150
      if c31v18 < c31v17 then
        c31v18 = _T
        c31v20 = _T.DropshipNextEventTime
        c31v19 = c31v20 + c31v6
        c31v18.DropshipNextEventTime = c31v19
      end
    end
    c31v17 = v80
    if c31v17 then
      c31v17 = _T.extractionAvailable
      if c31v17 then
        do return end
      end
    end
    c31v17 = Sleep
    c31v17(c31v6)
    c31v17 = gGameRules
    c31v19 = v40
    c31v1 = c31v17:GetNetPersistentVar(c31v19)
    c31v17 = gGameRules
    c31v19 = v30
    c31v2 = c31v17:GetMissionTimeLeft(c31v19)
    c31v17 = 0
    if c31v17 <= c31v2 then
      c31v17 = gGameRules
      c31v19 = v43
      c31v20 = math.ceil
      c31v20 = c31v20(c31v2)
      c31v17:SetNetPersistentVar(c31v19, c31v20)
    end
    c31v18 = _T.LastActivityTime
    c31v17 = c31v2 - c31v18
    c31v18 = 180
    if c31v18 < c31v17 then
      c31v17 = v29
      if not c31v17 then
        c31v17 = true
        v29 = c31v17
        c31v17 = gGameRules
        c31v19 = v55
        c31v20 = 1
        c31v17:SetNetPersistentVar(c31v19, c31v20)
      end
    else
      c31v17 = v29
      if c31v17 then
        c31v17 = false
        v29 = c31v17
        c31v17 = gGameRules
        c31v19 = v55
        c31v20 = 0
        c31v17:SetNetPersistentVar(c31v19, c31v20)
      end
    end
    do return end
  end
  v119 = function()
    local c32v0, c32v1, c32v2, c32v3, c32v4, c32v5, c32v6, c32v7, c32v8, c32v9, c32v10, c32v11, c32v12, c32v13, c32v14
    while true do
      c32v1 = IsNull
      c32v0 = nil
      c32v1 = c32v1(c32v0)
      if not c32v1 then break end
      c32v1 = gRegion
      c32v0 = c32v1:GetLocalPlayerAvatar()
      c32v1 = Sleep
      c32v2 = 0
      c32v1(c32v2)
    end
    c32v1 = gRegion
    local __renovice_local_0 = v31
    c32v1 = c32v1:FindTagged(__renovice_local_0)
    c32v2 = nil
    __renovice_local_0 = #c32v1
    if __renovice_local_0 == 0 then
      c32v2 = nil
    else
      __renovice_local_0 = #c32v1
      if __renovice_local_0 == 1 then
        c32v2 = c32v1[1]
      else
        __renovice_local_0 = gRegion
        c32v4 = v35
        __renovice_local_0 = __renovice_local_0:FindTagged(c32v4)
        c32v3 = {}
        c32v6 = 1
        c32v4 = #__renovice_local_0
        c32v5 = 1
        for __renovice_for_0_0 = c32v6, c32v4, c32v5 do
          c32v9 = __renovice_local_0[__renovice_for_0_0]
          c32v7 = table.insert
          c32v7(c32v3, c32v9:GetPosition())
        end
        c32v4 = 0
        c32v7 = 1
        c32v5 = #c32v1
        c32v6 = 1
        for __renovice_for_1_0 = c32v7, c32v5, c32v6 do
          c32v8 = 0
          c32v9 = c32v1[__renovice_for_1_0]
          c32v9 = c32v9:GetPosition()
          c32v12 = 1
          c32v10 = #c32v3
          c32v11 = 1
          for __renovice_for_2_0 = c32v12, c32v10, c32v11 do
            c32v13 = Distance
            c32v14 = c32v3[__renovice_for_2_0]
            c32v13 = c32v13(c32v9, c32v14)
            c32v8 = c32v8 + c32v13
          end
          if (c32v2 == nil or c32v8 < c32v4) then
            c32v2 = c32v1[__renovice_for_1_0]
            c32v4 = c32v8
          end
        end
      end
    end
    __renovice_local_0 = _T
    c32v3 = nil
    __renovice_local_0.ExcavationScanner = c32v3
    do return end
  end
  v120 = function()
    local c33v0, c33v1, c33v2, c33v3, c33v4
    while true do
      c33v1 = gGameRules
      c33v0 = IsNull
      c33v0 = c33v0(c33v1)
      if not c33v0 then break end
      c33v0 = Sleep
      c33v1 = 0
      c33v0(c33v1)
    end
    repeat
      c33v0 = _T
      c33v1 = false
      c33v0.extractionAvailable = c33v1
      c33v0 = gGameRules
      c33v0 = c33v0:GetMission()
      c33v2 = c33v0.levelOverride
      c33v1 = IsNull
      c33v1 = c33v1(c33v2)
      if not c33v1 then
        c33v1 = c33v0.goalId
        if c33v1 ~= "" then break end
      end
      c33v1 = false
      v75 = c33v1
    until true
    c33v1 = string.find
    c33v3 = c33v0.activeMissionTag
    c33v2 = tostring
    c33v2 = c33v2(c33v3)
    c33v3 = "Void"
    c33v1 = c33v1(c33v2, c33v3)
    v77 = c33v1
    c33v2 = string.find
    c33v4 = c33v0.levelOverride
    c33v3 = tostring
    c33v3 = c33v3(c33v4:GetFullName())
    c33v4 = "Duviri"
    c33v2 = c33v2(c33v3, c33v4)
    if c33v2 == nil then
      c33v1 = false
    else
      c33v1 = true
    end
    local __renovice_state_0 = -1
    v80 = c33v1
    c33v1 = c33v0.alertId
    if c33v1 ~= "" then
      __renovice_state_0 = -1
    else
      __renovice_state_0 = 1
    end
    if __renovice_state_0 == 1 then
      c33v1 = c33v0.invasionId
      if c33v1 ~= "" then
        __renovice_state_0 = -1
      else
        __renovice_state_0 = 2
      end
    end
    if __renovice_state_0 == 2 then
      c33v1 = c33v0.syndicateTag
      c33v1 = c33v1:IsValid()
      if c33v1 then
        __renovice_state_0 = -1
      else
        __renovice_state_0 = 3
      end
    end
    if __renovice_state_0 == 3 then
      c33v1 = c33v0.sortieId
      if c33v1 ~= "" then
        __renovice_state_0 = -1
      else
        __renovice_state_0 = 4
      end
    end
    if __renovice_state_0 == 4 then
      c33v1 = c33v0.nightmare
      if c33v1 then
        __renovice_state_0 = -1
      else
        __renovice_state_0 = 5
      end
    end
    if __renovice_state_0 == 5 then
      c33v1 = c33v0.maxWaveNum
      c33v2 = 0
      if c33v2 < c33v1 then
        __renovice_state_0 = -1
      else
        __renovice_state_0 = 6
      end
    end
    if __renovice_state_0 == 6 then
      c33v1 = v80
      if not c33v1 then
        __renovice_state_0 = 7
      else
        __renovice_state_0 = -1
      end
    end
    if __renovice_state_0 ~= 7 then
      c33v1 = true
      v76 = c33v1
      c33v1 = 600
      v25 = c33v1
      c33v1 = 600
      v24 = c33v1
    end
    c33v1 = c33v0.goalTag
    c33v2 = Symbol
    c33v3 = "OldWorldSalvage"
    c33v2 = c33v2(c33v3)
    if c33v1 == c33v2 then
      c33v1 = c33v0.location
      c33v2 = v79
      if c33v1 == c33v2 then
        c33v1 = true
        v78 = c33v1
        c33v1 = 10
        v28 = c33v1
        c33v1 = 60
        v27 = c33v1
        do return end
      end
    end
    c33v1 = true
    c33v2 = gGameRules
    c33v2 = c33v2:GetMission()
    c33v2 = c33v2.periodicMissionTag
    c33v3 = v1
    c33v3 = c33v3.ELITE_ALERT_PERIODIC_MISSION_TAG
    if c33v2 ~= c33v3 then
      c33v2 = gGameRules
      c33v2 = c33v2:GetMission()
      c33v2 = c33v2.periodicMissionTag
      c33v3 = v1
      c33v3 = c33v3.ELITE_ALERT_PERIODIC_MISSION_TAG_ALT
      if c33v2 ~= c33v3 then
        c33v1 = false
      else
        c33v1 = true
      end
    end
    if c33v1 then
      c33v1 = 140
      v27 = c33v1
      do return end
    end
    c33v1 = v80
    if c33v1 then
      c33v1 = 3
      v81 = c33v1
    end
    do return end
  end
  v121 = function()
    local c34v0, c34v1, c34v2, c34v3
    c34v0 = v4
    c34v0 = c34v0.ClearPrimaryObjText
    c34v0()
    c34v0 = v4
    c34v0 = c34v0.ClearSecondaryObjText
    c34v0()
    c34v0 = v4
    c34v0 = c34v0.RemoveObjProgressBar
    c34v0()
    c34v0 = v8
    c34v0 = c34v0.ClearGameMode
    c34v1 = 17
    c34v0(c34v1)
    c34v0 = gRegion
    c34v0 = c34v0:IsMaster()
    if c34v0 then
      c34v0 = print
      c34v1 = "duviri excav clearing state"
      c34v0(c34v1)
      c34v0 = gGameRules
      c34v2 = v40
      c34v0:Name__a835d47c(c34v2)
      c34v0 = gGameRules
      c34v2 = v41
      c34v0:Name__a835d47c(c34v2)
      c34v0 = gGameRules
      c34v2 = v42
      c34v0:Name__a835d47c(c34v2)
      c34v0 = gGameRules
      c34v2 = v44
      c34v0:Name__a835d47c(c34v2)
      c34v0 = gGameRules
      c34v2 = v45
      c34v0:Name__a835d47c(c34v2)
      c34v0 = gGameRules
      c34v2 = v46
      c34v0:Name__a835d47c(c34v2)
      c34v0 = gGameRules
      c34v2 = v47
      c34v0:Name__a835d47c(c34v2)
      c34v0 = gGameRules
      c34v2 = v48
      c34v0:Name__a835d47c(c34v2)
      c34v0 = gGameRules
      c34v2 = v49
      c34v0:Name__a835d47c(c34v2)
      c34v0 = gGameRules
      c34v2 = v50
      c34v0:Name__a835d47c(c34v2)
      c34v0 = gGameRules
      c34v2 = v51
      c34v0:Name__a835d47c(c34v2)
      c34v0 = gGameRules
      c34v2 = v52
      c34v0:Name__a835d47c(c34v2)
      c34v0 = gGameRules
      c34v2 = v53
      c34v0:Name__a835d47c(c34v2)
      c34v0 = gGameRules
      c34v2 = v54
      c34v0:Name__a835d47c(c34v2)
      c34v0 = gGameRules
      c34v2 = v55
      c34v0:Name__a835d47c(c34v2)
      c34v0 = gGameRules
      c34v2 = v56
      c34v0:Name__a835d47c(c34v2)
      c34v0 = gGameRules
      c34v2 = v43
      c34v0:Name__a835d47c(c34v2)
      c34v0 = _T.ArenaComplete
      if c34v0 then
        c34v0 = _T.ArenaComplete
        c34v0()
      end
      c34v0 = gRegion
      c34v0 = c34v0:GetNpcMgr()
      c34v0 = c34v0:GetAiDirector()
      c34v3 = nil
      c34v0:Name__4a133811(c34v3)
    end
    do return end
  end
  v122 = function()
    local c35v0, c35v1, c35v2, c35v3, c35v4, c35v5
    c35v0 = _T
    c35v1 = 5
    c35v0.maxTier = c35v1
    c35v0 = v2
    c35v0 = c35v0.SetupMissionTransmissionSet
    c35v1 = transmissionSet
    c35v0(c35v1)
    c35v0 = gRegion
    c35v2 = Symbol
    c35v3 = "BreakableOnPath"
    c35v0 = c35v0:FindTagged(c35v2(c35v3))
    c35v3 = 1
    c35v1 = #c35v0
    c35v2 = 1
    for __renovice_for_0_0 = c35v3, c35v1, c35v2 do
      c35v4 = c35v0[__renovice_for_0_0]
      c35v5 = "Destroy"
      c35v4:FirePort(c35v5)
    end
    c35v1 = v78
    if c35v1 then
      c35v1 = v2
      c35v1 = c35v1.PlayGlobalTransmission
      c35v2 = _T.MissionTransmissionSet
      c35v3 = Symbol
      c35v4 = "MissionIntro"
      c35v1(c35v2, c35v3(c35v4))
    end
    c35v1 = gGameRules
    c35v3 = v40
    c35v4 = 2
    c35v1:SetNetPersistentVar(c35v3, c35v4)
    do return end
  end
  v123 = function(c36v0)
    local c36v1, c36v2, c36v3, c36v4, c36v5, c36v6, c36v7, c36v8, c36v9, c36v10, c36v11
    c36v1 = v120
    c36v1()
    c36v1 = v8
    c36v1 = c36v1.SetGameMode
    c36v2 = 17
    c36v3 = ImGuiDebug
    c36v1(c36v2, c36v3)
    c36v1 = _T
    c36v2 = gGameRules
    c36v2 = c36v2:GetRewardSeed()
    c36v1.gSurvivalRewardSeed = c36v2
    c36v1 = gGameRules
    c36v3 = v50
    c36v4 = 0
    c36v1 = c36v1:GetNetPersistentVar(c36v3, c36v4)
    c36v2 = 0
    if c36v2 < c36v1 then
      c36v2 = GetSeed
      c36v2 = c36v2()
      c36v3 = Name__dadf7b26
      c36v4 = _T.gSurvivalRewardSeed
      c36v3(c36v4, c36v1)
      c36v3 = _T
      c36v4 = GetSeed
      c36v4 = c36v4()
      c36v3.gSurvivalRewardSeed = c36v4
      c36v3 = SetSeed
      c36v3(c36v2)
    end
    c36v3 = v80
    if c36v3 then
      c36v2 = gRegion
      c36v2 = c36v2:IsMaster()
      if c36v2 then
        c36v2 = v6
        c36v2 = c36v2.IsGameModeInProgress
        c36v2 = c36v2()
      end
    else
      c36v2 = gPromotedToHost
    end
    if c36v2 then
      c36v2 = gGameRules
      c36v4 = v52
      c36v5 = 0
      c36v2 = c36v2:GetNetPersistentVar(c36v4, c36v5)
      if c36v2 ~= 0 then
        c36v3 = gFlashMgr
        c36v5 = loadingScreen
        c36v3 = c36v3:FindMovie(c36v5)
        while true do
          c36v4 = IsNull
          c36v4 = c36v4(c36v3)
          if c36v4 then break end
          c36v4 = Sleep
          c36v5 = 0
          c36v4(c36v5)
        end
        c36v4 = gGameRules
        c36v6 = v45
        c36v7 = 0
        c36v4 = c36v4:GetNetPersistentVar(c36v6, c36v7)
        c36v5 = v117
        c36v7 = c36v4 / 200
        c36v6 = math.floor
        c36v6 = c36v6(c36v7)
        c36v5(c36v6, c36v2)
      end
      c36v4 = gGameRules
      c36v6 = v57
      c36v7 = 0
      c36v4 = c36v4:GetNetPersistentVar(c36v6, c36v7)
      if c36v4 ~= 1 then
        c36v3 = false
      else
        c36v3 = true
      end
      c36v5 = gGameRules
      c36v7 = v40
      c36v8 = 0
      c36v5 = c36v5:GetNetPersistentVar(c36v7, c36v8)
      if c36v5 ~= 2 then
        c36v4 = false
      else
        c36v4 = true
      end
      c36v5 = v80
      if ((c36v5 and not c36v3) and not c36v4) then
        c36v5 = v122
        c36v5()
      end
      c36v5 = v118
      c36v5()
      c36v5 = v80
      if c36v5 then
        c36v5 = v121
        c36v5()
      end
      do return end
    end
    c36v2 = gRegion
    c36v4 = v37
    c36v2 = c36v2:FindTagged(c36v4)
    c36v3 = gRegion
    c36v5 = v36
    c36v3 = c36v3:FindTagged(c36v5)
    c36v6 = 1
    c36v4 = #c36v2
    c36v5 = 1
    for __renovice_for_0_0 = c36v6, c36v4, c36v5 do
      c36v7 = c36v2[__renovice_for_0_0]
      c36v9 = scannerMesh
      c36v10 = false
      c36v11 = false
      c36v7:SetMesh(c36v9, c36v10, c36v11)
    end
    c36v6 = 1
    c36v4 = #c36v3
    c36v5 = 1
    for __renovice_for_1_0 = c36v6, c36v4, c36v5 do
      c36v7 = c36v3[__renovice_for_1_0]
      c36v9 = excavatorMesh
      c36v10 = false
      c36v11 = false
      c36v7:SetMesh(c36v9, c36v10, c36v11)
    end
    c36v4 = gRegion
    c36v4 = c36v4:IsMaster()
    if c36v4 then
      c36v4 = v122
      c36v4()
      c36v4 = v118
      c36v4()
      c36v4 = v80
      if c36v4 then
        c36v4 = v121
        c36v4()
        do return end
      end
    else
      c36v4 = v99
      c36v4()
      c36v4 = gPromotedToHost
      if c36v4 then
        c36v4 = print
        c36v5 = "Bailing on Excavation because I am now the host!"
        c36v4(c36v5)
        do return end
      end
      c36v4 = v80
      if c36v4 then
        c36v4 = v121
        c36v4()
      end
    end
    do return end
  end
  Excavation = v123
  v123 = function(c37v0)
    local c37v1, c37v2, c37v3, c37v4, c37v5, c37v6, c37v7, c37v8, c37v9, c37v10, c37v11, c37v12, c37v13, c37v14, c37v15, c37v16, c37v17, c37v18, c37v19, c37v20, c37v21, c37v22, c37v23, c37v24, c37v25, c37v26, c37v27, c37v28, c37v29, c37v30, c37v31, c37v32, c37v33, c37v34, c37v35, c37v36, c37v37, c37v38, c37v39, c37v40, c37v41, c37v42, c37v43, c37v44, c37v45, c37v46
    c37v1 = v120
    c37v1()
    c37v1 = gGameRules
    while true do
      c37v2 = IsNull
      c37v2 = c37v2(c37v1)
      if not c37v2 then break end
      c37v1 = gGameRules
      c37v2 = Sleep
      c37v3 = 0.1
      c37v2(c37v3)
    end
    c37v2 = v80
    if c37v2 then
      c37v2 = gRegion
      c37v2 = c37v2:GetLocalPlayerAvatar()
      while true do
        c37v3 = IsNull
        c37v3 = c37v3(c37v2)
        if not c37v3 then
          c37v5 = v85
          c37v3 = c37v2:IsA(c37v5)
          if not c37v3 then break end
        end
        c37v3 = Sleep
        c37v4 = 0
        c37v3(c37v4)
        c37v3 = gRegion
        c37v2 = c37v3:GetLocalPlayerAvatar()
      end
    end
    c37v2 = IsNull
    c37v2 = c37v2(c37v1)
    if c37v2 then
      do return end
    end
    c37v2 = c37v1:Name__fd0086f7()
    while true do
      c37v3 = IsNull
      c37v3 = c37v3(c37v2)
      if not c37v3 then break end
      c37v3 = IsNull
      c37v3 = c37v3(c37v1)
      if c37v3 then
        do return end
      end
      c37v2 = c37v1:Name__fd0086f7()
      c37v3 = Sleep
      c37v4 = 0.1
      c37v3(c37v4)
    end
    c37v3 = false
    c37v6 = "/Lotus/Language/Game/ExcavatorObject"
    c37v7 = false
    c37v4 = c37v2:GetLocalized(c37v6, c37v7)
    c37v6 = "<MISSION_MARKER_A>"
    c37v7 = "<MISSION_MARKER_B>"
    c37v8 = "<MISSION_MARKER_C>"
    c37v9 = "<MISSION_MARKER_D>"
    c37v10 = "<MISSION_MARKER_E>"
    c37v11 = "<MISSION_MARKER_F>"
    c37v5 = {c37v6, c37v7, c37v8, c37v9, c37v10, c37v11}
    c37v6 = ipairs
    c37v6, c37v7, c37v8 = c37v6(c37v5)
    for __renovice_for_0_0, __renovice_for_0_1 in c37v6, c37v7, c37v8 do
      c37v18 = true
      c37v12 = c37v2:GetLocalized(__renovice_for_0_1, c37v18)
      c37v13 = " "
      c37v11 = c37v12 .. c37v13 .. c37v4
      c37v5[__renovice_for_0_0] = c37v11
    end
    c37v6 = #c37v5
    c37v7 = 500
    c37v8 = gGameRules
    c37v8 = c37v8:GetMission()
    c37v9 = v81
    if not c37v9 then
      c37v9 = c37v8.maxWaveNum
    end
    c37v10 = 0
    if c37v10 < c37v9 then
      c37v10 = v28
      c37v7 = c37v9 * c37v10
    end
    c37v10 = true
    c37v11 = gGameRules
    c37v11 = c37v11:GetMission()
    c37v11 = c37v11.periodicMissionTag
    c37v12 = v1
    c37v12 = c37v12.ELITE_ALERT_PERIODIC_MISSION_TAG
    if c37v11 ~= c37v12 then
      c37v11 = gGameRules
      c37v11 = c37v11:GetMission()
      c37v11 = c37v11.periodicMissionTag
      c37v12 = v1
      c37v12 = c37v12.ELITE_ALERT_PERIODIC_MISSION_TAG_ALT
      if c37v11 ~= c37v12 then
        c37v10 = false
      else
        c37v10 = true
      end
    end
    if c37v10 then
      c37v7 = c37v7 * 2
    end
    c37v10 = v0
    c37v10 = c37v10.Ternary
    c37v11 = v78
    c37v12 = "/Lotus/Language/Game/OldWorldCompletedExcavations"
    c37v13 = "/Lotus/Language/Game/ExcavationsRemaining"
    c37v10 = c37v10(c37v11, c37v12, c37v13)
    c37v13 = v0
    c37v13 = c37v13.Ternary
    c37v14 = v76
    c37v16 = "/Lotus/Language/Game/CompletedExcavations"
    c37v13 = c37v13(c37v14, c37v10, c37v16)
    c37v14 = true
    c37v11 = c37v2:GetLocalized(c37v13, c37v14)
    c37v14 = "/Lotus/Language/Objectives/ExcavPowerFull"
    c37v15 = true
    c37v12 = c37v2:GetLocalized(c37v14, c37v15)
    c37v14 = "0% "
    c37v17 = "/Lotus/Language/Game/ExcavationHalted"
    c37v18 = true
    c37v15 = c37v2:GetLocalized(c37v17, c37v18)
    c37v13 = c37v14 .. c37v15
    c37v14 = nil
    c37v15 = gGameRules
    c37v17 = v56
    c37v18 = 1
    c37v15 = c37v15:GetNetPersistentVar(c37v17, c37v18)
    while true do
      c37v16 = gRegion
      c37v16 = c37v16:IsMaster()
      if (c37v16 or c37v15 ~= 1) then break end
      c37v16 = Sleep
      c37v17 = 0.1
      c37v16(c37v17)
      c37v16 = gGameRules
      c37v18 = v56
      c37v19 = 1
      c37v15 = c37v16:GetNetPersistentVar(c37v18, c37v19)
    end
    while true do
      c37v16 = #c37v14
      if not (c37v16 < c37v15) then break end
      c37v16 = gRegion
      c37v18 = v35
      c37v14 = c37v16:FindTagged(c37v18)
      c37v16 = v80
      if c37v16 then
        c37v16 = _T.FilterEntitiesToCurrentLayer
        if c37v16 then
          c37v16 = _T.FilterEntitiesToCurrentLayer
          c37v14 = c37v16(c37v14)
        end
      end
      c37v16 = Sleep
      c37v17 = 0.1
      c37v16(c37v17)
    end
    c37v16 = gRegion
    c37v16 = c37v16:IsMaster()
    if c37v16 then
      c37v16 = gGameRules
      c37v18 = v56
      c37v19 = #c37v14
      c37v16:SetNetPersistentVar(c37v18, c37v19)
    end
    c37v16 = print
    c37v18 = "Num excav states found: "
    c37v19 = #c37v14
    c37v17 = c37v18 .. c37v19
    c37v16(c37v17)
    c37v16 = nil
    c37v17 = gGameRules
    c37v19 = v40
    c37v17 = c37v17:GetNetPersistentVar(c37v19)
    c37v18 = print
    c37v20 = "HUD: state="
    c37v21 = tostring
    c37v21 = c37v21(c37v17)
    c37v19 = c37v20 .. c37v21
    c37v18(c37v19)
    while true do
      c37v18 = IsNull
      c37v18 = c37v18(c37v2)
      if not c37v18 then break end
      c37v18 = IsNull
      c37v18 = c37v18(c37v1)
      if c37v18 then
        do return end
      end
      c37v2 = c37v1:Name__fd0086f7()
      c37v18 = Sleep
      c37v19 = 0.1
      c37v18(c37v19)
    end
    c37v18 = "<p><font face=\"Noto Sans\">"
    c37v20 = "</font></p><p><font face=\"Noto Sans\" size=\"24\"><b> %s</b></font></p> "
    c37v11 = c37v18 .. c37v11 .. c37v20
    c37v18 = "<p><font face=\"Noto Sans\"><b>%s</b> </font>"
    c37v19 = string.format
    c37v20 = "<Color%u>"
    c37v21 = 42
    c37v19 = c37v19(c37v20, c37v21)
    c37v21 = "<font color=\""
    c37v26 = string.format
    c37v27 = "<Color%u>"
    c37v28 = 56
    c37v22 = c37v26(c37v27, c37v28)
    c37v23 = "\"><b> %s</b></font><font color=\""
    c37v26 = string.format
    c37v27 = "<Color%u>"
    c37v28 = 24
    c37v24 = c37v26(c37v27, c37v28)
    c37v25 = "\"><b> %s</b></font>"
    c37v18 = c37v18 .. c37v21 .. c37v22 .. c37v23 .. c37v24 .. c37v25
    c37v21 = "<font color=\""
    c37v23 = "\"><br>      "
    c37v30 = "/Lotus/Language/Game/ExcavationTime"
    c37v31 = true
    c37v24 = c37v2:GetLocalized(c37v30, c37v31)
    c37v25 = "</font><font color=\""
    c37v27 = "\"><b> %s</b></font>"
    c37v18 = c37v18 .. c37v21 .. c37v19 .. c37v23 .. c37v24 .. c37v25 .. c37v19 .. c37v27
    c37v21 = "<font color=\""
    c37v23 = "\">  "
    c37v28 = "/Lotus/Language/Game/ExcavationPower"
    c37v29 = true
    c37v24 = c37v2:GetLocalized(c37v28, c37v29)
    c37v25 = "</font>%s"
    c37v18 = c37v18 .. c37v21 .. c37v19 .. c37v23 .. c37v24 .. c37v25
    c37v21 = "</p>"
    c37v18 = c37v18 .. c37v21
    c37v20 = v77
    c37v20 = v77
    if c37v20 then
      c37v20 = v4
      c37v20 = c37v20.SetObjProgressBar
      c37v21 = "/Lotus/Language/Objectives/ExcavNextRelicTitle"
      c37v22 = 0
      c37v23 = 200
      c37v24 = nil
      c37v25 = false
      c37v26 = "/Lotus/Language/Objectives/ExcavNextRelicCryotic"
      c37v20(c37v21, c37v22, c37v23, c37v24, c37v25, c37v26)
    else
      c37v20 = v76
      if c37v20 then
        c37v20 = v4
        c37v20 = c37v20.SetObjProgressBar
        c37v21 = "/Lotus/Language/Game/CompletedExcavations"
        c37v22 = 0
        c37v20(c37v21, c37v22, c37v7)
      end
    end
    c37v20 = v78
    c37v20 = {}
    c37v21 = v78
    while true do
      if c37v17 ~= 0 then break end
      c37v21 = IsNull
      c37v21 = c37v21(c37v1)
      if c37v21 then
        do return end
      end
      c37v23 = v40
      c37v17 = c37v1:GetNetPersistentVar(c37v23)
      c37v21 = Sleep
      c37v22 = 0
      c37v21(c37v22)
    end
    c37v21 = v78
    while true do
      if c37v17 ~= 1 then break end
      c37v21 = IsNull
      c37v21 = c37v21(c37v1)
      if c37v21 then
        do return end
      end
      c37v23 = v40
      c37v17 = c37v1:GetNetPersistentVar(c37v23)
      c37v21 = Sleep
      c37v22 = 0
      c37v21(c37v22)
    end
    c37v21 = v4
    c37v21 = c37v21.SetTitleObjText
    c37v22 = "/Lotus/Language/Missions/MissionName_Excavation"
    c37v21(c37v22)
    c37v21 = v78
    if not c37v21 then
      repeat
        c37v21 = Engine.IsMobile
        c37v21 = c37v21()
        if c37v21 then
          c37v22 = v77
          c37v21 = IsNull
          c37v21 = c37v21(c37v22)
          if c37v21 then
            c37v21 = v4
            c37v21 = c37v21.SetPrimaryObjText
            c37v22 = "/Lotus/Language/Game/ExcavationLocateAndProtect"
            c37v23 = 1
            c37v21 = c37v21(c37v22, c37v23)
            c37v22 = c37v21.SetOffset
            c37v23 = 0
            c37v24 = 10
            c37v25 = true
            c37v22(c37v23, c37v24, c37v25)
            break
          end
        end
        c37v21 = v4
        c37v21 = c37v21.SetPrimaryObjText
        c37v22 = "/Lotus/Language/Game/ExcavationLocateAndProtect"
        c37v23 = 1
        c37v21(c37v22, c37v23)
      until true
    end
    while true do
      c37v21 = IsNull
      c37v21 = c37v21(c37v2)
      if (not c37v21 or c37v17 ~= 2) then break end
      c37v21 = IsNull
      c37v21 = c37v21(c37v1)
      if c37v21 then
        do return end
      end
      c37v2 = c37v1:Name__fd0086f7()
      c37v23 = v40
      c37v17 = c37v1:GetNetPersistentVar(c37v23)
      c37v21 = Sleep
      c37v22 = 0
      c37v21(c37v22)
    end
    c37v21 = v80
    if not c37v21 then
      c37v21 = gRegion
      c37v23 = v65
      c37v21 = c37v21:FindFirstTagged(c37v23)
      v82 = c37v21
    end
    c37v21 = true
    c37v22 = gPlayerProfileMgr
    c37v24 = 0
    c37v22 = c37v22:GetPlayerProfile(c37v24)
    c37v23 = IsNull
    c37v23 = c37v23(c37v22)
    if not c37v23 then
      c37v23 = c37v22:Settings()
      c37v23 = c37v23:EnableTutorialTransmissions()
      if not c37v23 then
        c37v21 = false
      end
    end
    if c37v21 then
      c37v23 = -7.5
    else
      c37v23 = 0
    end
    c37v24 = nil
    if c37v21 then
      c37v25 = _T.AddHudTracker
      c37v26 = "PowerHint"
      c37v27 = v1
      c37v27 = c37v27.HT_LABEL
      c37v28 = 0.15
      c37v30 = v4
      c37v30 = c37v30.GetPriorityOffset
      c37v30 = c37v30()
      c37v29 = c37v30 + 5
      c37v30 = true
      c37v24 = c37v25(c37v26, c37v27, c37v28, c37v29, c37v30)
      c37v25 = c37v24.SetOffset
      c37v26 = 0
      c37v27 = -7.5
      c37v25(c37v26, c37v27)
      c37v25 = c37v24.SetLabel
      c37v26 = ""
      c37v25(c37v26)
    end
    c37v25 = 0
    while true do
      if c37v17 ~= 2 then break end
      c37v26 = IsNull
      c37v26 = c37v26(c37v1)
      if c37v26 then
        do return end
      end
      c37v28 = v40
      c37v17 = c37v1:GetNetPersistentVar(c37v28)
      c37v28 = v45
      c37v29 = 0
      c37v26 = c37v1:GetNetPersistentVar(c37v28, c37v29)
      if c37v16 ~= c37v26 then
        repeat
          c37v16 = c37v26
          c37v27 = v76
          if c37v27 then
            c37v27 = v78
            if not c37v27 then
              c37v27 = v4
              c37v27 = c37v27.UpdateObjProgressBar
              c37v27(c37v26, c37v7)
              break
            end
          end
          c37v27 = v77
          if c37v27 then
            c37v27 = math.mod
            c37v29 = 200
            c37v27 = c37v27(c37v26, c37v29)
            c37v28 = v4
            c37v28 = c37v28.UpdateObjProgressBar
            c37v30 = 200
            c37v31 = "/Lotus/Language/Objectives/ExcavNextRelicCryotic"
            c37v28(c37v27, c37v30, c37v31)
          else
            repeat
              c37v27 = v78
              if c37v27 then
                c37v27 = v78
                if not c37v27 then break end
                c37v27 = 0
                if not (c37v27 < c37v26) then break end
              end
              c37v29 = v0
              c37v29 = c37v29.Ternary
              c37v30 = true
              c37v31 = gGameRules
              c37v31 = c37v31:GetMission()
              c37v31 = c37v31.periodicMissionTag
              c37v32 = v1
              c37v32 = c37v32.ELITE_ALERT_PERIODIC_MISSION_TAG
              if c37v31 ~= c37v32 then
                c37v31 = gGameRules
                c37v31 = c37v31:GetMission()
                c37v31 = c37v31.periodicMissionTag
                c37v32 = v1
                c37v32 = c37v32.ELITE_ALERT_PERIODIC_MISSION_TAG_ALT
                if c37v31 ~= c37v32 then
                  c37v30 = false
                else
                  c37v30 = true
                end
              end
              c37v31 = v53
              c37v32 = v50
              c37v27 = c37v1:GetNetPersistentVar(c37v29(c37v30, c37v31, c37v32))
              c37v28 = 0
              if c37v28 < c37v27 then
                c37v28 = v4
                c37v28 = c37v28.SetPrimaryObjText
                c37v29 = "/Lotus/Language/Objectives/GetToExtraction"
                c37v30 = 3
                c37v28(c37v29, c37v30)
                c37v28 = v4
                c37v28 = c37v28.SetSecondaryObjText
                c37v29 = "/Lotus/Language/GameModes/ExcavationExtraObjective"
                c37v30 = 1
                c37v28(c37v29, c37v30)
              end
              c37v28 = Engine.IsMobile
              c37v28 = c37v28()
              if c37v28 then
                c37v28 = v4
                c37v28 = c37v28.SetSubTitleObjText
                c37v29 = "/Lotus/Language/Objectives/ExcavDigsComplete"
                c37v31 = ": "
                c37v30 = c37v31 .. c37v27
                c37v28 = c37v28(c37v29, c37v30)
                c37v29 = c37v28.SetOffset
                c37v30 = 0
                c37v31 = -5
                c37v32 = true
                c37v29(c37v30, c37v31, c37v32)
              else
                c37v28 = v4
                c37v28 = c37v28.SetSubTitleObjText
                c37v29 = "/Lotus/Language/Objectives/ExcavDigsComplete"
                c37v31 = ": "
                c37v30 = c37v31 .. c37v27
                c37v28(c37v29, c37v30)
              end
            until true
          end
        until true
      end
      c37v27 = v80
      if not c37v27 then
        c37v28 = v82
        c37v27 = IsNull
        c37v27 = c37v27(c37v28)
        if c37v27 then
          c37v27 = gRegion
          c37v29 = v65
          c37v27 = c37v27:FindFirstTagged(c37v29)
          v82 = c37v27
        end
      end
      c37v27 = v76
      if (c37v27 and not c37v3) then
        c37v28 = v83
        c37v27 = IsNull
        c37v27 = c37v27(c37v28)
        if not c37v27 then
          c37v28 = v82
          c37v27 = IsNull
          c37v27 = c37v27(c37v28)
          if not c37v27 then
            c37v27 = v82
            c37v27 = c37v27:IsEnabled()
            if c37v27 then
              c37v27 = c37v1:Name__b89efb85()
              c37v28 = 4294967295
              if c37v27 < c37v28 then
                c37v3 = true
                c37v28 = Resource
                c37v29 = c37v1:GetMission()
                c37v29 = c37v29.levelKeyName
                c37v28 = c37v28(c37v29)
                c37v29 = IsNull
                c37v29 = c37v29(c37v28)
                if not c37v29 then
                  c37v29 = c37v28:GetReward(c37v27)
                  c37v30 = c37v29.items
                  if c37v30 ~= nil then
                    c37v32 = c37v30[1]
                    c37v31 = IsNull
                    c37v31 = c37v31(c37v32)
                    if not c37v31 then
                      c37v31 = gFlashMgr
                      c37v33 = v83
                      c37v31 = c37v31:PushMovie(c37v33)
                      c37v32 = IsNull
                      c37v32 = c37v32(c37v31)
                      if not c37v32 then
                        c37v32 = _T.DisplayReward
                        c37v33 = c37v30[1]
                        c37v34 = 1
                        c37v32(c37v33, c37v34)
                      end
                    end
                  end
                end
              end
              c37v28 = gRegion
              c37v28 = c37v28:IsMaster()
              if c37v28 then
                c37v28 = c37v8.goalId
                if c37v28 ~= "" then
                  c37v28 = gGameRules
                  c37v30 = v50
                  c37v31 = 0
                  c37v28 = c37v28:GetNetPersistentVar(c37v30, c37v31)
                  if c37v28 == 0 then
                    c37v3 = true
                    c37v28 = v100
                    c37v28()
                  end
                end
              end
            end
          end
        end
      end
      c37v27 = false
      c37v28 = 0
      c37v31 = 1
      c37v29 = #c37v14
      c37v30 = 1
      for __renovice_for_1_0 = c37v31, c37v29, c37v30 do
        local __renovice_state_0 = -1
        c37v32 = c37v14[__renovice_for_1_0]
        c37v33 = IsNull
        c37v33 = c37v33(c37v32)
        if c37v33 then
          __renovice_state_0 = -1
        else
          __renovice_state_0 = 1
        end
        if __renovice_state_0 == 1 then
          c37v33 = c37v32:IsEnabled()
          if not c37v33 then
            __renovice_state_0 = -1
          else
            __renovice_state_0 = 2
          end
        end
        if __renovice_state_0 == 2 then
          c37v34 = c37v32:GetInstanceNumber()
          c37v33 = c37v34 % c37v6
          if c37v33 ~= 0 then
            __renovice_state_0 = 4
          else
            __renovice_state_0 = 3
          end
        end
        if __renovice_state_0 == 3 then
          c37v33 = c37v6
          __renovice_state_0 = 4
        end
        if __renovice_state_0 == 4 then
          c37v28 = c37v28 + 1
          c37v35 = c37v20[__renovice_for_1_0]
          c37v34 = IsNull
          c37v34 = c37v34(c37v35)
          if not c37v34 then
            __renovice_state_0 = 6
          else
            __renovice_state_0 = 5
          end
        end
        if __renovice_state_0 == 5 then
          c37v35 = v4
          c37v35 = c37v35.GetPriorityOffset
          c37v35 = c37v35()
          c37v34 = c37v35 + 10
          c37v35 = _T.AddHudTracker
          c37v37 = "ExcavationInfo"
          c37v36 = c37v37 .. __renovice_for_1_0
          c37v37 = v1
          c37v37 = c37v37.HT_LABEL
          c37v38 = 0.15
          c37v40 = false
          c37v35 = c37v35(c37v36, c37v37, c37v38, c37v34, c37v40)
          c37v20[__renovice_for_1_0] = c37v35
          c37v35 = c37v20[__renovice_for_1_0]
          c37v35 = c37v35.Colorize
          c37v36 = 42
          c37v35(c37v36)
          c37v35 = c37v20[__renovice_for_1_0]
          c37v35 = c37v35.Colorize
          c37v36 = 56
          c37v35(c37v36)
          c37v35 = c37v20[__renovice_for_1_0]
          c37v35 = c37v35.Colorize
          c37v36 = 24
          c37v35(c37v36)
          c37v35 = c37v20[__renovice_for_1_0]
          c37v35 = c37v35.SetOffset
          c37v36 = 0
          c37v35(c37v36, c37v23)
          __renovice_state_0 = 6
        end
        if __renovice_state_0 == 6 then
          c37v34 = _T.HudInitState
          if not c37v34 then
            __renovice_state_0 = 31
          else
            __renovice_state_0 = 7
          end
        end
        if __renovice_state_0 == 7 then
          c37v34 = nil
          c37v35 = nil
          c37v36 = c37v32:GetAvatar()
          c37v37 = IsNull
          c37v37 = c37v37(c37v36)
          if not c37v37 then
            __renovice_state_0 = 9
          else
            __renovice_state_0 = 8
          end
        end
        if __renovice_state_0 == 8 then
          c37v34 = 0
          c37v35 = 0
          __renovice_state_0 = 10
        end
        if __renovice_state_0 == 9 then
          c37v34 = c37v36:GetHealth()
          c37v37 = c37v36:DamageControl()
          c37v35 = c37v37:GetUIShield()
          __renovice_state_0 = 10
        end
        if __renovice_state_0 == 10 then
          c37v37 = c37v32:GetPower()
          c37v38 = ""
          c37v39 = 0.001
          if not (c37v37 < c37v39) then
            __renovice_state_0 = 12
          else
            __renovice_state_0 = 11
          end
        end
        if __renovice_state_0 == 11 then
          c37v37 = -1
          __renovice_state_0 = 13
        end
        if __renovice_state_0 == 12 then
          c37v39 = v0
          c37v39 = c37v39.Round
          c37v37 = c37v39(c37v37)
          __renovice_state_0 = 13
        end
        if __renovice_state_0 == 13 then
          c37v39 = c37v32:GetTimer()
          c37v40 = 0
          if not (c37v37 < c37v40) then
            __renovice_state_0 = 15
          else
            __renovice_state_0 = 14
          end
        end
        if __renovice_state_0 == 14 then
          c37v40 = string.format
          c37v41 = "<font color=\"%s\"><b>%s</b></font>"
          c37v42 = c37v20[__renovice_for_1_0]
          c37v42 = c37v42.ColorizeBlink
          c37v43 = 42
          c37v44 = 38
          c37v42 = c37v42(c37v43, c37v44)
          c37v38 = c37v40(c37v41, c37v42, c37v13)
          c37v27 = true
          __renovice_state_0 = 21
        end
        if __renovice_state_0 == 15 then
          c37v40 = 25
          if not (c37v37 <= c37v40) then
            __renovice_state_0 = 18
          else
            __renovice_state_0 = 16
          end
        end
        if __renovice_state_0 == 16 then
          c37v40 = math.floor
          c37v40 = c37v40(c37v39)
          if not (c37v37 < c37v40) then
            __renovice_state_0 = 18
          else
            __renovice_state_0 = 17
          end
        end
        if __renovice_state_0 == 17 then
          c37v40 = string.format
          c37v41 = "<font color=\"%s\"><b>%s</b></font>"
          c37v42 = c37v20[__renovice_for_1_0]
          c37v42 = c37v42.ColorizeBlink
          c37v43 = 42
          c37v44 = 38
          c37v42 = c37v42(c37v43, c37v44)
          c37v45 = "%"
          c37v43 = c37v37 .. c37v45
          c37v38 = c37v40(c37v41, c37v42, c37v43)
          __renovice_state_0 = 21
        end
        if __renovice_state_0 == 18 then
          c37v40 = math.floor
          c37v40 = c37v40(c37v39)
          if not (c37v40 <= c37v37) then
            __renovice_state_0 = 20
          else
            __renovice_state_0 = 19
          end
        end
        if __renovice_state_0 == 19 then
          c37v40 = string.format
          c37v41 = "<font color=\"%s\"><b>%s</b></font>"
          c37v42 = c37v20[__renovice_for_1_0]
          c37v42 = c37v42.Colorize
          c37v43 = 13
          c37v42 = c37v42(c37v43)
          c37v38 = c37v40(c37v41, c37v42, c37v12)
          __renovice_state_0 = 21
        end
        if __renovice_state_0 == 20 then
          c37v40 = string.format
          c37v41 = "<font color=\"%s\"><b>%s</b></font>"
          c37v42 = c37v20[__renovice_for_1_0]
          c37v42 = c37v42.Colorize
          c37v43 = 42
          c37v42 = c37v42(c37v43)
          c37v45 = "%"
          c37v43 = c37v37 .. c37v45
          c37v38 = c37v40(c37v41, c37v42, c37v43)
          __renovice_state_0 = 21
        end
        if __renovice_state_0 == 21 then
          c37v40 = v0
          c37v40 = c37v40.FormatNumber
          c37v42 = 1
          c37v43 = nil
          c37v44 = nil
          c37v45 = true
          c37v40 = c37v40(c37v39, c37v42, c37v43, c37v44, c37v45)
          c37v41 = IsNull
          c37v41 = c37v41(c37v36)
          if c37v41 then
            __renovice_state_0 = 25
          else
            __renovice_state_0 = 22
          end
        end
        if __renovice_state_0 == 22 then
          c37v41 = c37v36:DamageControl()
          c37v41 = c37v41:IsInvulnerable()
          if c37v41 then
            __renovice_state_0 = 24
          else
            __renovice_state_0 = 23
          end
        end
        if __renovice_state_0 == 23 then
          c37v41 = c37v36:DamageControl()
          c37v41 = c37v41:Name__15f53748()
          if not c37v41 then
            __renovice_state_0 = 25
          else
            __renovice_state_0 = 24
          end
        end
        if __renovice_state_0 == 24 then
          c37v41 = string.format
          c37v42 = "<font color=\"%s\"><b>%s</b></font>"
          c37v43 = c37v20[__renovice_for_1_0]
          c37v43 = c37v43.Colorize
          c37v44 = 13
          c37v43 = c37v43(c37v44)
          c37v44 = c37v36:DamageControl()
          c37v35 = c37v41(c37v42, c37v43, c37v44:GetUIShield())
          c37v41 = string.format
          c37v42 = "<font color=\"%s\"><b>%s</b></font>"
          c37v43 = c37v20[__renovice_for_1_0]
          c37v43 = c37v43.Colorize
          c37v44 = 13
          c37v43 = c37v43(c37v44)
          c37v34 = c37v41(c37v42, c37v43, c37v36:GetHealth())
          __renovice_state_0 = 25
        end
        if __renovice_state_0 == 25 then
          c37v41 = c37v20[__renovice_for_1_0]
          c37v41 = c37v41.SetLabel
          c37v42 = string.format
          c37v44 = c37v5[c37v33]
          c37v46 = v3
          c37v46 = c37v46.FormatTime
          c37v46 = c37v46(c37v40)
          c37v41(c37v42(c37v18, c37v44, c37v35, c37v34, c37v46, c37v38))
          c37v41 = c37v20[__renovice_for_1_0]
          c37v41 = c37v41.NeedsInit
          if c37v41 then
            __renovice_state_0 = 31
          else
            __renovice_state_0 = 26
          end
        end
        if __renovice_state_0 == 26 then
          c37v41 = IsNull
          c37v41 = c37v41(c37v2)
          if not c37v41 then
            __renovice_state_0 = 28
          else
            __renovice_state_0 = 27
          end
        end
        if __renovice_state_0 == 27 then
          c37v2 = c37v1:Name__fd0086f7()
          __renovice_state_0 = 28
        end
        if __renovice_state_0 == 28 then
          c37v41 = IsNull
          c37v41 = c37v41(c37v2)
          if c37v41 then
            __renovice_state_0 = 31
          else
            __renovice_state_0 = 29
          end
        end
        if __renovice_state_0 == 29 then
          c37v44 = c37v20[__renovice_for_1_0]
          c37v44 = c37v44.ClipName
          c37v45 = ".Label"
          c37v43 = c37v44 .. c37v45
          c37v44 = 41
          c37v41 = c37v2:GetNumberVariable(c37v43, c37v44)
          if c37v41 == nil then
            __renovice_state_0 = 31
          else
            __renovice_state_0 = 30
          end
        end
        if __renovice_state_0 == 30 then
          c37v42 = c37v20[__renovice_for_1_0]
          c37v42 = c37v42.SetHeight
          c37v43 = c37v41 + 25
          c37v42(c37v43)
          __renovice_state_0 = 31
        end
        if __renovice_state_0 == 31 then
          continue
        end
        c37v33 = c37v20[__renovice_for_1_0]
        if not c37v33 then
          continue
        end
        c37v33 = _T.RemoveHudTracker
        c37v34 = c37v20[__renovice_for_1_0]
        c37v33(c37v34)
        c37v33 = nil
        c37v20[__renovice_for_1_0] = c37v33
      end
      if c37v24 then
        if c37v27 then
          c37v29 = Name__3b4b94b0
          c37v29 = c37v29()
          c37v25 = c37v25 + c37v29
          c37v29 = 5
          if c37v29 <= c37v25 then
            c37v29 = IsNull
            c37v29 = c37v29(c37v2)
            if not c37v29 then
              c37v31 = "/Lotus/Language/GameModes/ExcavationHaltedHint"
              c37v32 = true
              c37v29 = c37v2:GetLocalized(c37v31, c37v32)
              c37v31 = "<p><font color=\"#FFD700\"><b>"
              c37v33 = "</b></font></p>"
              c37v30 = c37v31 .. c37v29 .. c37v33
              c37v31 = c37v24.SetLabel
              c37v31(c37v30)
            end
          else
            c37v29 = c37v24.SetLabel
            c37v30 = ""
            c37v29(c37v30)
          end
        else
          c37v25 = 0
          c37v29 = c37v24.SetLabel
          c37v30 = ""
          c37v29(c37v30)
        end
      end
      c37v29 = Sleep
      c37v30 = 0
      c37v29(c37v30)
    end
    c37v26 = v80
    if c37v26 then
      c37v26 = _T.RemoveHudTracker
      if c37v26 then
        c37v28 = 1
        c37v26 = #c37v14
        c37v27 = 1
        for __renovice_for_2_0 = c37v28, c37v26, c37v27 do
          c37v29 = c37v20[__renovice_for_2_0]
          if not c37v29 then
            continue
          end
          c37v29 = _T.RemoveHudTracker
          c37v30 = c37v20[__renovice_for_2_0]
          c37v29(c37v30)
        end
      end
    end
    c37v26 = v4
    c37v26 = c37v26.ClearTitleObjText
    c37v26()
    c37v26 = _T.RemoveHudTracker
    if c37v26 then
      c37v26 = _T.RemoveHudTracker
      c37v27 = "PowerHint"
      c37v26(c37v27)
    end
    do return end
  end
  ExcavationHUD = v123
  v123 = function()
    local c38v0, c38v1, c38v2, c38v3, c38v4, c38v5, c38v6, c38v7, c38v8, c38v9, c38v10, c38v11, c38v12, c38v13
    c38v0 = v32
    c38v1 = v75
    if c38v1 then
      c38v0 = v33
    end
    c38v1 = gRegion
    c38v1 = c38v1:FindTagged(c38v0)
    c38v3 = v80
    if c38v3 then
      c38v2 = gRegion
      c38v2 = c38v2:IsMaster()
      if c38v2 then
        c38v2 = v6
        c38v2 = c38v2.IsGameModeInProgress
        c38v2 = c38v2()
      end
    else
      c38v2 = gPromotedToHost
    end
    if not c38v2 then
      do return c38v1 end
    end
    c38v2 = {}
    c38v5 = 1
    c38v3 = #c38v1
    c38v4 = 1
    for __renovice_for_0_0 = c38v5, c38v3, c38v4 do
      repeat
        c38v6 = gRegion
        c38v8 = gMultiAvatarTriggerType
        c38v9 = c38v1[__renovice_for_0_0]
        c38v9 = c38v9:GetPosition()
        c38v10 = 0.2
        c38v6 = c38v6:FindNearest(c38v8, c38v9, c38v10)
        c38v7 = IsNull
        c38v7 = c38v7(c38v6)
        if not c38v7 then
          c38v7 = c38v6:IsEnabled()
          if c38v7 then
            c38v7 = print
            c38v9 = "Extractor "
            c38v13 = c38v1[__renovice_for_0_0]
            c38v12 = tostring
            c38v10 = c38v12(c38v13:GetFullName())
            c38v11 = " already used, removing"
            c38v8 = c38v9 .. c38v10 .. c38v11
            c38v7(c38v8)
            break
          end
        end
        repeat
          c38v7 = c38v1[__renovice_for_0_0]
          c38v8 = v26
          if c38v7 == c38v8 then
            c38v7 = #c38v1
            c38v8 = v10
            if not (c38v7 <= c38v8) then break end
          end
          c38v9 = c38v1[__renovice_for_0_0]
          c38v7 = table.insert
          c38v7(c38v2, c38v9)
        until true
      until true
    end
    do return c38v2 end
  end
  v124 = function(c39v0, c39v1, c39v2)
    local c39v3, c39v4, c39v5, c39v6, c39v7, c39v8
    c39v6 = 1
    c39v4 = #c39v0
    c39v5 = 1
    for __renovice_for_0_0 = c39v6, c39v4, c39v5 do
      c39v8 = c39v0[__renovice_for_0_0]
      c39v8 = c39v8:DistanceToPoint(c39v1)
      if not (c39v8 < c39v2) then
        c39v7 = false
      else
        c39v7 = true
      end
      if not c39v7 then
        continue
      end
      c39v3 = __renovice_for_0_0
    end
    c39v4 = IsNull
    c39v4 = c39v4(c39v3)
    if c39v4 then
      c39v4 = RandomInt
      c39v5 = 1
      c39v6 = #c39v0
      c39v3 = c39v4(c39v5, c39v6)
    end
    do return c39v3 end
  end
  v125 = function(c40v0)
    local c40v1, c40v2, c40v3, c40v4, c40v5, c40v6, c40v7, c40v8, c40v9, c40v10, c40v11, c40v12, c40v13, c40v14, c40v15, c40v16, c40v17, c40v18, c40v19, c40v20, c40v21, c40v22, c40v23, c40v24, c40v25, c40v26, c40v27, c40v28, c40v29, c40v30, c40v31
    c40v1 = gRegion
    c40v1 = c40v1:IsMaster()
    if not c40v1 then
      do return end
    end
    c40v1 = v75
    if c40v1 then
      c40v1 = 1
      v10 = c40v1
    end
    c40v1 = v123
    c40v1 = c40v1()
    c40v2 = 50
    local __renovice_local_0 = print
    c40v4 = "Nr of extractors = "
    c40v6 = #c40v1
    c40v5 = tostring
    c40v5 = c40v5(c40v6)
    c40v3 = c40v4 .. c40v5
    __renovice_local_0(c40v3)
    __renovice_local_0 = gGameRules
    c40v4 = v40
    __renovice_local_0 = __renovice_local_0:GetNetPersistentVar(c40v4)
    if __renovice_local_0 == 0 then
      c40v3 = gGameRules
      c40v5 = v41
      c40v3:SetNetPersistentVar(c40v5, c40v2)
    end
    c40v3 = 0
    c40v4 = 0
    c40v5 = 0
    if __renovice_local_0 == 0 then
      c40v6 = gGameRules
      c40v8 = v40
      c40v9 = 1
      c40v6:SetNetPersistentVar(c40v8, c40v9)
    end
    c40v6 = nil
    c40v7 = IsNull
    c40v7 = c40v7(c40v6)
    c40v7 = gRegion
    c40v9 = v37
    c40v7 = c40v7:FindTagged(c40v9)
    c40v10 = 1
    c40v8 = #c40v7
    c40v9 = 1
    for __renovice_for_0_0 = c40v10, c40v8, c40v9 do
      c40v11 = c40v7[__renovice_for_0_0]
      c40v11 = c40v11:IsVisible()
      if c40v11 then break end
    end
    c40v6 = c40v7[c40v10]
    c40v8 = Sleep
    c40v9 = 0
    c40v8(c40v9)
    c40v7 = c40v6:GetPosition()
    c40v9 = v80
    if c40v9 then
      c40v8 = gRegion
      c40v8 = c40v8:IsMaster()
      if c40v8 then
        c40v8 = v6
        c40v8 = c40v8.IsGameModeInProgress
        c40v8 = c40v8()
      end
    else
      c40v8 = gPromotedToHost
    end
    if (c40v8 and __renovice_local_0 ~= 0) then
      c40v9 = gGameRules
      c40v12 = v42
      c40v10 = c40v9:GetNetPersistentVar(c40v12)
      c40v8 = c40v10 / 16384
      c40v5 = 25 - c40v8
    end
    c40v8 = true
    c40v9 = gGameRules
    c40v11 = v41
    c40v12 = 0
    c40v2 = c40v9:GetNetPersistentVar(c40v11, c40v12)
    c40v9 = gRegion
    c40v11 = v34
    c40v9 = c40v9:FindTagged(c40v11)
    c40v10 = #c40v9
    c40v11 = gRegion
    c40v13 = v38
    c40v9 = c40v11:FindTagged(c40v13)
    c40v13 = 1
    c40v11 = #c40v9
    c40v12 = 1
    for __renovice_for_1_0 = c40v13, c40v11, c40v12 do
      c40v14 = c40v9[__renovice_for_1_0]
      c40v14 = c40v14:IsEnabled()
      if not c40v14 then
        continue
      end
      c40v10 = c40v10 + 1
    end
    c40v15 = nil
    c40v17 = c40v12[c40v15]
    c40v20 = gLotusVehicleAvatarType
    c40v18 = c40v17:IsA(c40v20)
    c40v18 = c40v17:IsHoverboard()
    c40v18 = c40v17:GetRider()
    c40v16 = c40v17:GetRider()
    c40v16 = c40v17
    c40v19 = cellItemType
    c40v17 = c40v16:HasItem(c40v19)
    if c40v17 then
      c40v19 = v27
      c40v18 = c40v19 * 10
      c40v17 = c40v18 / 9
      if c40v2 < c40v17 then
        c40v17 = c40v12[c40v15]
        c40v17 = c40v17:GetPosition()
        c40v21 = c40v17.x
        c40v22 = c40v7.x
        c40v20 = c40v21 - c40v22
        c40v22 = c40v17.x
        c40v23 = c40v7.x
        c40v21 = c40v22 - c40v23
        c40v19 = c40v20 * c40v21
        c40v22 = c40v17.z
        c40v23 = c40v7.z
        c40v21 = c40v22 - c40v23
        c40v23 = c40v17.z
        c40v24 = c40v7.z
        c40v22 = c40v23 - c40v24
        c40v20 = c40v21 * c40v22
        c40v18 = c40v19 + c40v20
        c40v19 = 25
        if c40v18 < c40v19 then
          c40v19 = c40v12[c40v15]
          c40v19 = c40v19:GetPlayer()
          c40v20 = c40v16:InventoryControl()
          c40v20 = c40v20:Name__4ee25a12()
          c40v21 = v0
          c40v21 = c40v21.Round
          c40v23 = 20 * c40v20
          c40v25 = v27
          c40v24 = c40v25 - c40v2
          c40v22 = math.min
          c40v22 = c40v22(c40v23, c40v24)
          c40v21 = c40v21(c40v22)
          c40v22 = gGameRules
          c40v25 = "/Lotus/Language/Game/GainedPower"
          c40v26 = ""
          c40v27 = 0
          c40v28 = 2
          c40v29 = true
          c40v30 = "AMOUNT"
          c40v31 = tostring
          c40v31 = c40v31(c40v21)
          c40v22:DisplayMessage(c40v19, c40v25, c40v26, c40v27, c40v28, c40v29, c40v30, c40v31)
          c40v2 = c40v2 + c40v21
          c40v22 = c40v12[c40v15]
          c40v24 = cellDeliverySound
          c40v25 = false
          c40v22:PlaySound(c40v24, c40v25)
          c40v24 = cellItemType
          c40v16:RemoveItem(c40v24)
          c40v22 = _T
          c40v23 = true
          c40v22.PlayerHasDeliveredCell = c40v23
          c40v22 = IsNull
          c40v22 = c40v22(c40v19)
          if not c40v22 then
            c40v22 = c40v19:GetStats()
            c40v23 = IsNull
            c40v23 = c40v23(c40v22)
            if not c40v23 then
              c40v22:Name__e6196dda()
            end
          end
        end
      end
    end
    c40v11 = gGameRules
    c40v13 = v46
    c40v14 = 0
    c40v11 = c40v11:GetNetPersistentVar(c40v13, c40v14)
    c40v12 = 25
    if c40v12 < c40v5 then
      c40v12 = 0
      if c40v12 < c40v2 then
        c40v12 = v10
        if c40v10 < c40v12 then
          c40v12 = #c40v1
          c40v13 = 0
          if c40v12 <= c40v13 then
            c40v12 = v123
            c40v1 = c40v12()
            c40v12 = print
            c40v14 = "Nr of extractors = "
            c40v16 = #c40v1
            c40v15 = tostring
            c40v15 = c40v15(c40v16)
            c40v13 = c40v14 .. c40v15
            c40v12(c40v13)
          end
          c40v12 = nil
          c40v13 = 3
          if c40v13 < c40v11 then
            c40v13 = RandomInt
            c40v14 = 1
            c40v15 = #c40v1
            c40v12 = c40v13(c40v14, c40v15)
          else
            c40v13 = 2
            if c40v13 < c40v11 then
              c40v13 = v124
              c40v16 = 400
              c40v12 = c40v13(c40v1, c40v7, c40v16)
            else
              c40v13 = 1
              if c40v13 < c40v11 then
                c40v13 = v124
                c40v16 = 300
                c40v12 = c40v13(c40v1, c40v7, c40v16)
              else
                c40v13 = v124
                c40v16 = 200
                c40v12 = c40v13(c40v1, c40v7, c40v16)
              end
            end
          end
          c40v13 = c40v1[c40v12]
          v26 = c40v13
          c40v13 = c40v1[c40v12]
          c40v15 = "TriggerPort"
          c40v13:FirePort(c40v15)
          c40v13 = table.remove
          c40v13(c40v1, c40v12)
          c40v13 = v2
          c40v13 = c40v13.PlayGlobalTransmission
          c40v14 = _T.MissionTransmissionSet
          c40v15 = Symbol
          c40v16 = "MissionScannerComplete"
          c40v13(c40v14, c40v15(c40v16))
          c40v5 = 0
        end
      end
    end
    c40v12 = gRegion
    c40v12 = c40v12:GetHumanPlayerAvatars()
    c40v15 = 1
    c40v13 = #c40v12
    c40v14 = 1
    c40v13 = 1
    if c40v13 <= c40v4 then
      c40v13 = v10
      if c40v10 < c40v13 then
        c40v14 = c40v2 - 1
        c40v15 = 0
        c40v13 = math.max
        c40v2 = c40v13(c40v14, c40v15)
        c40v4 = 0
      end
    end
    c40v13 = 0
    if (c40v2 <= c40v13 and c40v10 == 0) then
      c40v13 = v2
      c40v13 = c40v13.PlayGlobalTransmission
      c40v14 = _T.MissionTransmissionSet
      c40v15 = Symbol
      c40v16 = "MissionScannerUnpowered"
      c40v13(c40v14, c40v15(c40v16))
      c40v3 = 0
    end
    c40v13 = 0
    if (c40v2 <= c40v13 and c40v8) then
      c40v8 = false
    else
      c40v13 = 0
      if (c40v13 < c40v2 and not c40v8) then
        c40v8 = true
      end
    end
    c40v13 = gGameRules
    c40v15 = v41
    c40v13:SetNetPersistentVar(c40v15, c40v2)
    c40v13 = gGameRules
    c40v15 = v46
    c40v13:SetNetPersistentVar(c40v15, c40v11)
    c40v13 = Name__3b4b94b0
    c40v13 = c40v13()
    c40v3 = c40v3 + c40v13
    c40v13 = Name__3b4b94b0
    c40v13 = c40v13()
    c40v4 = c40v4 + c40v13
    c40v13 = 0
    if c40v13 < c40v2 then
      c40v13 = v10
      if c40v10 < c40v13 then
        c40v13 = Name__3b4b94b0
        c40v13 = c40v13()
        c40v5 = c40v5 + c40v13
      end
    end
    c40v13 = 25 - c40v5
    c40v14 = gGameRules
    c40v15 = 0
    if c40v13 < c40v15 then
      c40v13 = 0
    end
    c40v17 = v42
    c40v19 = c40v13 * 16384
    c40v18 = math.ceil
    c40v18 = c40v18(c40v19)
    c40v14:SetNetPersistentVar(c40v17, c40v18)
    c40v13 = Sleep
    c40v14 = 0
    c40v13(c40v14)
    do return end
  end
  v126 = function(c41v0, c41v1)
    local c41v2
    c41v2 = v125
    c41v2(c41v0)
    do return end
  end
  Scanner = v126
  v126 = function(c42v0, c42v1, c42v2, c42v3, c42v4)
    local c42v5, c42v6, c42v7, c42v8, c42v9, c42v10, c42v11, c42v12, c42v13, c42v14, c42v15, c42v16, c42v17, c42v18, c42v19, c42v20, c42v21, c42v22, c42v23, c42v24, c42v25, c42v26
    c42v5 = 0
    c42v6 = false
    c42v9 = 1
    c42v7 = #c42v0
    c42v8 = 1
    for __renovice_for_0_0 = c42v9, c42v7, c42v8 do
      c42v10 = c42v0[__renovice_for_0_0]
      c42v10 = c42v10:GetPlayer()
      c42v11 = c42v10:GetMissionData()
      c42v13 = c42v0[__renovice_for_0_0]
      c42v13 = c42v13:DistanceToPoint(c42v1)
      c42v14 = 6
      if not (c42v13 < c42v14) then
        c42v12 = false
      else
        c42v12 = true
      end
      c42v13 = false
      if c42v12 then
        c42v14 = v27
        if c42v3 < c42v14 then
          c42v15 = v27
          c42v14 = c42v15 - c42v4
          if c42v3 <= c42v14 then
            c42v14 = c42v0[__renovice_for_0_0]
            c42v14 = c42v14:DamageControl()
            c42v15 = c42v14:GetShield()
            c42v16 = c42v14:GetMaxShield()
            c42v17 = c42v0[__renovice_for_0_0]
            c42v17 = c42v17:GetHealth()
            c42v18 = 0
            if c42v18 < c42v15 then
              c42v18 = gRegion
              c42v18 = c42v18:IsMaster()
              if c42v18 then
                c42v19 = c42v15 - 30
                c42v20 = 0
                c42v18 = math.max
                c42v21 = c42v18(c42v19, c42v20)
                c42v14:SetShield(c42v21)
              end
              c42v13 = true
            else
              if c42v16 == 0 then
                c42v18 = 100
                if c42v18 < c42v17 then
                  c42v18 = gRegion
                  c42v18 = c42v18:IsMaster()
                  if c42v18 then
                    c42v19 = c42v17 - 30
                    c42v20 = 0
                    c42v18 = math.max
                    c42v18 = c42v18(c42v19, c42v20)
                    c42v19 = c42v0[__renovice_for_0_0]
                    c42v19:SetHealth(c42v18)
                  end
                  c42v13 = true
                end
              end
            end
            if c42v13 then
              c42v19 = c42v0[__renovice_for_0_0]
              c42v21 = beamType
              c42v18 = IsNull
              c42v18 = c42v18(c42v19:GetAttachment(c42v21))
              if c42v18 then
                c42v20 = 0
                c42v18 = c42v14:Name__b7c91969(c42v20)
                c42v19 = c42v0[__renovice_for_0_0]
                c42v21 = beamType
                c42v23 = Vector
                c42v24 = -0.2
                c42v25 = 0
                c42v26 = 0
                c42v19 = c42v19:Attach(c42v21, c42v18, c42v23(c42v24, c42v25, c42v26))
                c42v23 = Vector
                c42v24 = 0
                c42v25 = 2
                c42v26 = 0
                c42v23 = c42v23(c42v24, c42v25, c42v26)
                c42v22 = c42v1 + c42v23
                c42v19:SetEndPoint(c42v22)
                c42v19:SetTag(c42v2)
                c42v20 = c42v0[__renovice_for_0_0]
                c42v22 = avProjType
                c42v23 = EMPTY_SYMBOL
                c42v20:Attach(c42v22, c42v23)
                c42v20 = IsNull
                c42v20 = c42v20(c42v11)
                if not c42v20 then
                  c42v22 = v70
                  c42v23 = 1
                  c42v11:SetMissionVar(c42v22, c42v23)
                  c42v22 = v71
                  c42v23 = c42v1.x
                  c42v11:SetMissionVar(c42v22, c42v23)
                  c42v22 = v72
                  c42v24 = c42v1.y
                  c42v23 = c42v24 + 2
                  c42v11:SetMissionVar(c42v22, c42v23)
                  c42v22 = v73
                  c42v23 = c42v1.z
                  c42v11:SetMissionVar(c42v22, c42v23)
                end
              end
              c42v5 = c42v5 + 0.4
            end
          end
        end
      end
      if c42v13 then
        continue
      end
      c42v14 = v95
      c42v15 = c42v0[__renovice_for_0_0]
      c42v16 = beamType
      c42v14(c42v15, c42v16, c42v2)
      c42v14 = IsNull
      c42v14 = c42v14(c42v11)
      if c42v14 then
        continue
      end
      c42v16 = v70
      c42v17 = 0
      c42v11:SetMissionVar(c42v16, c42v17)
    end
    c42v8 = v27
    c42v7 = c42v8 - c42v4
    if c42v7 < c42v3 then
      c42v6 = true
    end
    do return c42v5, c42v6 end
  end
  v127 = function()
    local c43v0, c43v1, c43v2
    c43v0 = _T.PlayerHasDeliveredCell
    if not c43v0 then
      c43v0 = v4
      c43v0 = c43v0.ShowTutorialHint
      c43v1 = "/Lotus/Language/GameModes/ExcavationHint"
      c43v2 = 10
      c43v0(c43v1, c43v2)
      c43v0 = _T
      c43v1 = true
      c43v0.PlayerHasDeliveredCell = c43v1
    end
    do return end
  end
  v128 = function(c44v0)
    local c44v1, c44v2, c44v3, c44v4, c44v5, c44v6, c44v7, c44v8, c44v9, c44v10, c44v11, c44v12, c44v13, c44v14, c44v15, c44v16, c44v17, c44v18, c44v19, c44v20, c44v21, c44v22, c44v23, c44v24, c44v25, c44v26, c44v27, c44v28, c44v29, c44v30, c44v31, c44v32, c44v33, c44v34, c44v35, c44v36, c44v37, c44v38, c44v39, c44v40, c44v41, c44v42, c44v43, c44v44, c44v45, c44v46, c44v47, c44v48, c44v49, c44v50, c44v51, c44v52, c44v53, c44v54, c44v55, c44v56, c44v57, c44v58, c44v59, c44v60, c44v61, c44v62, c44v63
    c44v44 = v76
    c44v44 = v78
    c44v39 = nil
    c44v44 = c44v39 % 2
    c44v45 = gRegion
    c44v45 = c44v45:GetHumanPlayers()
    c44v48 = 1
    c44v46 = #c44v45
    c44v47 = 1
    for __renovice_for_0_0 = c44v48, c44v46, c44v47 do
      c44v49 = v1
      c44v49 = c44v49.IsFirstTimeInNode
      c44v50 = c44v45[__renovice_for_0_0]
      c44v49 = c44v49(c44v50)
      if c44v49 then
        c44v44 = v67
        if c44v39 == 1 then
          c44v49 = Symbol
          c44v50 = "MissionExcavatorFirstPistolFound"
          c44v44 = c44v49(c44v50)
        end
      end
      c44v49 = v2
      c44v49 = c44v49.PlayLocalTransmission
      c44v50 = _T.MissionTransmissionSet
      c44v52 = c44v45[__renovice_for_0_0]
      c44v49(c44v50, c44v44, c44v52:GetAvatar())
    end
    c44v44 = true
    c44v45 = gGameRules
    c44v45 = c44v45:GetMission()
    c44v45 = c44v45.periodicMissionTag
    c44v46 = v1
    c44v46 = c44v46.ELITE_ALERT_PERIODIC_MISSION_TAG
    if c44v45 ~= c44v46 then
      c44v45 = gGameRules
      c44v45 = c44v45:GetMission()
      c44v45 = c44v45.periodicMissionTag
      c44v46 = v1
      c44v46 = c44v46.ELITE_ALERT_PERIODIC_MISSION_TAG_ALT
      do
        local __renovice_unused_condition_0 = c44v45 == c44v46
      end
    end
    c44v44 = v100
    c44v44()
    c44v44 = v67
    c44v46 = _T.lastSurvivalRewardStoreItem
    c44v45 = IsNull
    c44v45 = c44v45(c44v46)
    if not c44v45 then
      c44v45 = string.find
      c44v46 = _T.lastSurvivalRewardStoreItem
      c44v46 = c44v46:GetLocalizeTag()
      c44v46 = c44v46:c_str()
      c44v47 = "Rusty"
      c44v45 = c44v45(c44v46, c44v47)
      if c44v45 ~= nil then
        c44v45 = Symbol
        c44v46 = "MissionExcavatorPistolFound"
        c44v44 = c44v45(c44v46)
        c44v45 = gGameRules
        c44v47 = v68
        c44v48 = 1
        c44v45:SetNetPersistentVar(c44v47, c44v48)
      end
    end
    c44v45 = v78
    while true do
      c44v2 = gGameRules
      c44v1 = IsNull
      c44v1 = c44v1(c44v2)
      if not c44v1 then break end
      c44v1 = Sleep
      c44v2 = 0
      c44v1(c44v2)
    end
    c44v1 = gGameRules
    c44v3 = gLotusBaseGameRulesType
    c44v1 = c44v1:IsA(c44v3)
    if not c44v1 then
      do return end
    end
    c44v1 = gGameRules
    c44v1 = c44v1:GetMission()
    c44v2 = gRegion
    c44v2 = c44v2:GetNpcMgr()
    c44v2 = c44v2:GetAiDirector()
    c44v3 = c44v1.goalTag
    c44v4 = true
    c44v5 = Symbol
    c44v6 = "ShieldExcav"
    c44v5 = c44v5(c44v6)
    if c44v3 ~= c44v5 then
      c44v5 = Symbol
      c44v6 = "OldWorldSalvage"
      c44v5 = c44v5(c44v6)
      if c44v3 ~= c44v5 then
        c44v4 = false
      else
        c44v4 = true
      end
    end
    c44v5 = gPlayerProfileMgr
    c44v7 = 0
    c44v5 = c44v5:GetPlayerProfile(c44v7)
    c44v8 = 0
    c44v9 = shieldDrainExcavatorMat
    c44v0:SetOverrideMaterial(c44v8, c44v9)
    c44v8 = v88
    c44v6 = c44v0:GetAllAttachments(c44v8)
    c44v7 = ipairs
    c44v7, c44v8, c44v9 = c44v7(c44v6)
    for __renovice_for_1_0, __renovice_for_1_1 in c44v7, c44v8, c44v9 do
      c44v14 = 0
      c44v15 = shieldDrainPillarMat
      __renovice_for_1_1:SetOverrideMaterial(c44v14, c44v15)
    end
    c44v9 = shieldRingType
    c44v10 = EMPTY_SYMBOL
    c44v7 = c44v0:Attach(c44v9, c44v10)
    c44v10 = 0.6
    c44v11 = true
    c44v7:SetMeshScale(c44v10, c44v11)
    for __renovice_for_2_0, __renovice_for_2_1 in c44v7, c44v8, c44v9 do
    end
    c44v6 = v1
    c44v6 = c44v6.IsInGamePlay
    c44v6 = c44v6()
    if not c44v6 then
      do return end
    end
    c44v6 = v120
    c44v6()
    c44v6 = 20
    c44v7 = 0
    c44v8 = false
    c44v9 = 0
    c44v10 = v27
    c44v11 = 0
    c44v12 = false
    c44v14 = c44v1.goalId
    if c44v14 == "" then
      c44v13 = false
    else
      c44v13 = true
    end
    c44v14 = c44v1.levelOverride
    c44v15 = nil
    c44v16 = IsNull
    c44v16 = c44v16(c44v14)
    if (not c44v16 and c44v13) then
      local __renovice_state_0 = 20
      c44v15 = c44v14:GetFullName()
      c44v16 = string.find
      c44v18 = "Ice"
      c44v16 = c44v16(c44v15, c44v18)
      if not c44v16 then
        __renovice_state_0 = 22
      else
        __renovice_state_0 = 21
      end
      if __renovice_state_0 == 21 then
        c44v16 = 3
        v9 = c44v16
      end
      if __renovice_state_0 == 22 then
        c44v16 = string.find
        c44v18 = "Settlement"
        c44v16 = c44v16(c44v15, c44v18)
        if not c44v16 then
          __renovice_state_0 = 25
        else
          __renovice_state_0 = 23
        end
      end
      if __renovice_state_0 == 23 then
        c44v16 = string.find
        c44v18 = c44v1.goalTag
        c44v17 = tostring
        c44v17 = c44v17(c44v18)
        c44v18 = "Anniversary"
        c44v16 = c44v16(c44v17, c44v18)
        if c44v16 then
          __renovice_state_0 = 25
        else
          __renovice_state_0 = 24
        end
      end
      if __renovice_state_0 == 24 then
        c44v16 = 2
        v9 = c44v16
      end
      if __renovice_state_0 == 25 then
        c44v16 = 1
        v9 = c44v16
      end
    end
    c44v16 = gRegion
    c44v18 = cellItemPickup
    c44v16 = c44v16:Name__88f3b23b(c44v18)
    c44v17 = print
    c44v19 = "Flushed "
    c44v21 = " inactive power cells."
    c44v18 = c44v19 .. c44v16 .. c44v21
    c44v17(c44v18)
    c44v17 = gGameRules
    c44v19 = v40
    c44v20 = 2
    c44v17:SetNetPersistentVar(c44v19, c44v20)
    c44v17 = gGameRules
    c44v19 = v47
    c44v20 = 0
    c44v17 = c44v17:GetNetPersistentVar(c44v19, c44v20)
    if c44v17 == 0 then
      c44v18 = v2
      c44v18 = c44v18.PlayGlobalTransmission
      c44v19 = _T.MissionTransmissionSet
      c44v20 = Symbol
      c44v21 = "MissionExcavatorDeployedFirstTime"
      c44v18(c44v19, c44v20(c44v21))
    else
      c44v18 = v2
      c44v18 = c44v18.PlayGlobalTransmission
      c44v19 = _T.MissionTransmissionSet
      c44v20 = Symbol
      c44v21 = "MissionExcavatorDeployed"
      c44v18(c44v19, c44v20(c44v21))
    end
    c44v17 = c44v17 + 1
    c44v18 = gGameRules
    c44v20 = v47
    c44v18:SetNetPersistentVar(c44v20, c44v17)
    c44v18 = c44v2:GetMaxEnemyLevel()
    c44v20 = gRegion
    c44v20 = c44v20:Name__c988433c()
    c44v21 = Name__e7eb854d
    c44v22 = "Server.NumVirtualTestClients"
    c44v21 = c44v21(c44v22)
    c44v19 = c44v20 + c44v21
    c44v20 = sharedHealthPoolLevelPower
    if c44v19 == 1 then
      c44v20 = sharedHealthPoolLevelPowerSolo
    end
    c44v21 = gGameRules
    c44v23 = v54
    c44v24 = 0
    c44v21 = c44v21:GetNetPersistentVar(c44v23, c44v24)
    c44v22 = baseexcavatorHealth
    c44v23 = 0
    if c44v23 < c44v21 then
      c44v22 = c44v21
    end
    c44v25 = 1
    c44v27 = 0.025
    c44v28 = c44v18 ^ c44v20
    c44v26 = c44v27 * c44v28
    c44v24 = c44v25 + c44v26
    c44v23 = c44v22 * c44v24
    c44v25 = baseexcavatorShields
    c44v27 = 1
    c44v29 = 0.025
    c44v30 = c44v18 ^ c44v20
    c44v28 = c44v29 * c44v30
    c44v26 = c44v27 + c44v28
    c44v24 = c44v25 * c44v26
    c44v28 = true
    c44v0:SetMaxHealth(c44v23, c44v28)
    c44v25 = c44v0:IsKilled()
    if not c44v25 then
      c44v27 = c44v0:GetMaxHealth()
      c44v28 = false
      c44v0:SetHealth(c44v27, c44v28)
    end
    c44v25 = c44v0:DamageControl()
    c44v25:SetMaxShield(c44v24)
    c44v25 = c44v0:DamageControl()
    c44v27 = c44v0:DamageControl()
    c44v25:SetShield(c44v27:GetMaxShield())
    c44v25 = excavatorSpawnInvulnerabilityDuration
    c44v26 = 0
    if c44v26 < c44v25 then
      c44v25 = c44v0:DamageControl()
      c44v27 = excavatorSpawnInvulnerabilityDuration
      c44v28 = excavatorSpawnInvulnerabilityDuration
      c44v25:GiveTemporaryImmunity(c44v27, c44v28)
    end
    c44v25 = Sleep
    c44v26 = 0.1
    c44v25(c44v26)
    c44v0:SetLevel(c44v18)
    c44v25 = gRegion
    c44v27 = gLotusExcavationStateType
    c44v28 = c44v0:GetPosition()
    c44v29 = 5
    c44v25 = c44v25:FindNearest(c44v27, c44v28, c44v29)
    c44v26 = IsNull
    c44v26 = c44v26(c44v25)
    if c44v26 then
      c44v28 = excavatorAnim
      c44v29 = false
      c44v30 = 2
      c44v31 = 2
      c44v0:PlayAnimation(c44v28, c44v29, c44v30, c44v31)
      do return end
    end
    c44v2:SetObjective(c44v0)
    c44v2:Name__7fccb7d5(c44v0)
    c44v26 = print
    c44v28 = "SetObjective "
    c44v29 = c44v0:GetFullName()
    c44v27 = c44v28 .. c44v29
    c44v26(c44v27)
    c44v28 = excavatorAnim
    c44v29 = false
    c44v30 = 2
    c44v31 = 2
    c44v0:PlayAnimation(c44v28, c44v29, c44v30, c44v31)
    c44v28 = true
    c44v25:Enable(c44v28)
    c44v25:SetAvatar(c44v0)
    c44v25:SetInstanceNumber(c44v17)
    c44v28 = gParticleSysType
    c44v26 = c44v0:GetAllAttachments(c44v28)
    c44v29 = gSequencerType
    c44v27 = c44v0:GetAllAttachments(c44v29)
    c44v30 = pillarType
    c44v28 = c44v0:GetAttachment(c44v30)
    c44v29 = v94
    c44v33 = true
    c44v29(c44v28, c44v26, c44v27, c44v33)
    c44v29 = true
    c44v30 = false
    c44v31 = c44v0:DamageControl()
    c44v34 = excavatorMarkerTypes
    c44v33 = #c44v34
    c44v32 = c44v17 % c44v33
    if c44v32 == 0 then
      c44v33 = excavatorMarkerTypes
      c44v32 = #c44v33
    end
    c44v33 = gRegion
    c44v35 = v38
    c44v36 = c44v0:GetPosition()
    c44v37 = 0
    c44v38 = 5
    c44v33 = c44v33:FindFirstTaggedInRadius(c44v35, c44v36, c44v37, c44v38)
    c44v34 = IsNull
    c44v34 = c44v34(c44v33)
    if not c44v34 then
      c44v33:Disable()
    end
    c44v36 = excavatorMarkerTypes[c44v32]
    c44v37 = EMPTY_SYMBOL
    c44v38 = Vector
    c44v39 = 0
    c44v40 = 1.5
    c44v41 = 0
    c44v0:Attach(c44v36, c44v37, c44v38(c44v39, c44v40, c44v41))
    c44v34 = _T
    c44v35 = gGameRules
    c44v37 = v30
    c44v35 = c44v35:GetMissionTimeLeft(c44v37)
    c44v34.LastActivityTime = c44v35
    c44v35 = v80
    if c44v35 then
      c44v34 = gRegion
      c44v34 = c44v34:IsMaster()
      if c44v34 then
        c44v34 = v6
        c44v34 = c44v34.IsGameModeInProgress
        c44v34 = c44v34()
      end
    else
      c44v34 = gPromotedToHost
    end
    if c44v34 then
      c44v34 = c44v25:GetPower()
      if c44v34 ~= 0 then
        c44v6 = c44v34
        c44v35 = c44v25:GetTimer()
        c44v9 = c44v10 - c44v35
      end
    end
    c44v34 = Symbol
    c44v36 = "Excavator"
    c44v37 = math.random
    c44v37 = c44v37()
    c44v35 = c44v36 .. c44v37
    c44v34 = c44v34(c44v35)
    c44v35 = 0
    c44v36 = false
    c44v37 = false
    c44v39 = _T.ExcavatorHealthTransmissionState
    c44v38 = IsNull
    c44v38 = c44v38(c44v39)
    if c44v38 then
      c44v38 = _T
      c44v39 = {}
      c44v38.ExcavatorHealthTransmissionState = c44v39
    end
    c44v39 = _T.ExcavatorHealthTransmissionState
    c44v40 = c44v25:GetInstanceNumber()
    c44v41 = { heavyDamage = false, damaged = false }
    c44v38 = table.insert
    c44v38(c44v39, c44v40, c44v41)
    c44v38 = v7
    c44v38 = c44v38.CreateTimerMgr
    c44v38 = c44v38()
    v12 = c44v38
    c44v38 = v12
    c44v40 = 60
    c44v41 = v127
    c44v38:AddTimer(c44v40, c44v41)
    c44v38 = IsNull
    c44v38 = c44v38(c44v0)
    c44v38 = c44v0:IsKilled()
    c44v38 = IsNull
    c44v38 = c44v38(c44v25)
    c44v38 = gRegion
    c44v38 = c44v38:GetHumanPlayerAvatars()
    c44v39 = c44v0:GetPosition()
    c44v40 = v0
    c44v40 = c44v40.Round
    c44v40 = c44v40(c44v25:GetPower())
    c44v42 = c44v25:GetTimer()
    c44v41 = math.floor
    c44v41 = c44v41(c44v42)
    c44v42 = c44v31:GetShield()
    c44v43 = c44v31:GetMaxShield()
    c44v44 = ipairs
    c44v44, c44v45, c44v46 = c44v44(c44v38)
    for __renovice_for_3_0, __renovice_for_3_1 in c44v44, c44v45, c44v46 do
      c44v52 = gLotusVehicleAvatarType
      c44v50 = __renovice_for_3_1:IsA(c44v52)
      c44v50 = __renovice_for_3_1:IsHoverboard()
      c44v50 = __renovice_for_3_1:GetRider()
      c44v49 = __renovice_for_3_1:GetRider()
      c44v49 = __renovice_for_3_1
      c44v44 = c44v0:GetHealthPercentage()
      c44v46 = _T.ExcavatorHealthTransmissionState
      __renovice_for_3_0 = c44v25:GetInstanceNumber()
      c44v45 = c44v46[__renovice_for_3_0]
      c44v46 = 0.25
      c44v46 = c44v45.heavyDamage
      c44v46 = v2
      c44v46 = c44v46.PlayGlobalTransmission
      __renovice_for_3_0 = _T.MissionTransmissionSet
      __renovice_for_3_1 = Symbol
      c44v49 = "MissionExcavatorHeavyDamaged"
      c44v46(__renovice_for_3_0, __renovice_for_3_1(c44v49))
      c44v46 = true
      c44v45.heavyDamage = c44v46
      c44v46 = 0.75
      if c44v44 <= c44v46 then
        c44v46 = c44v45.damaged
        if not c44v46 then
          c44v46 = v2
          c44v46 = c44v46.PlayGlobalTransmission
          __renovice_for_3_0 = _T.MissionTransmissionSet
          __renovice_for_3_1 = Symbol
          c44v49 = "MissionExcavatorDamaged"
          c44v46(__renovice_for_3_0, __renovice_for_3_1(c44v49))
          c44v46 = true
          c44v45.damaged = c44v46
        end
      end
      if not c44v36 then
        c44v40 = 0.2
        if c44v40 < c44v35 then
          c44v40 = 0
          c44v41 = v126
          c44v40, c44v36 = c44v41(c44v38, c44v39, c44v34, c44v6, c44v9)
          c44v42 = c44v6 + c44v40
          c44v43 = v27
          c44v41 = math.min
          c44v6 = c44v41(c44v42, c44v43)
          c44v35 = 0
        else
          c44v40 = Name__3b4b94b0
          c44v40 = c44v40()
          c44v35 = c44v35 + c44v40
        end
        if c44v36 then
          c44v42 = shieldRingType
          c44v40 = c44v0:GetAttachment(c44v42)
          c44v41 = IsNull
          c44v41 = c44v41(c44v40)
          if not c44v41 then
            c44v40:Destroy()
          end
        end
      end
      c44v52 = cellItemType
      c44v50 = c44v49:HasItem(c44v52)
      if c44v50 then
        c44v51 = __renovice_for_3_1:DistanceToPoint(c44v39)
        c44v52 = 5
        if not (c44v51 < c44v52) then
          c44v50 = false
        else
          c44v50 = true
        end
        if c44v50 then
          c44v51 = __renovice_for_3_1:GetPlayer()
          c44v52 = c44v49:InventoryControl()
          c44v52 = c44v52:Name__4ee25a12()
          c44v53 = v0
          c44v53 = c44v53.Round
          c44v55 = 20 * c44v52
          c44v57 = v27
          c44v56 = c44v57 - c44v6
          c44v54 = math.min
          c44v54 = c44v54(c44v55, c44v56)
          c44v53 = c44v53(c44v54)
          c44v54 = gGameRules
          c44v57 = "/Lotus/Language/Game/GainedPower"
          c44v58 = ""
          c44v59 = 0
          c44v60 = 2
          c44v61 = true
          c44v62 = "AMOUNT"
          c44v63 = tostring
          c44v63 = c44v63(c44v53)
          c44v54:DisplayMessage(c44v51, c44v57, c44v58, c44v59, c44v60, c44v61, c44v62, c44v63)
          c44v6 = c44v6 + c44v53
          if (c44v41 < c44v6 and not c44v30) then
            c44v30 = true
            c44v54 = v2
            c44v54 = c44v54.PlayGlobalTransmission
            c44v55 = _T.MissionTransmissionSet
            c44v56 = Symbol
            c44v57 = "MissionExcavatorFull"
            c44v54(c44v55, c44v56(c44v57))
          end
          c44v56 = cellItemType
          c44v49:RemoveItem(c44v56)
          c44v56 = cellDeliverySound
          c44v57 = false
          __renovice_for_3_1:PlaySound(c44v56, c44v57)
          c44v54 = _T
          c44v55 = true
          c44v54.PlayerHasDeliveredCell = c44v55
          c44v54 = _T
          c44v55 = gGameRules
          c44v57 = v30
          c44v55 = c44v55:GetMissionTimeLeft(c44v57)
          c44v54.LastActivityTime = c44v55
          c44v54 = IsNull
          c44v54 = c44v54(c44v51)
          if not c44v54 then
            c44v54 = c44v51:GetStats()
            c44v55 = IsNull
            c44v55 = c44v55(c44v54)
            if not c44v55 then
              c44v54:Name__e6196dda()
            end
          end
          if c44v42 < c44v43 then
            c44v56 = shieldOverlayType
            c44v54 = c44v0:HasAttachment(c44v56)
            if not c44v54 then
              c44v56 = shieldOverlayType
              c44v57 = EMPTY_SYMBOL
              c44v0:Attach(c44v56, c44v57)
            end
          end
          c44v31:SetShield(c44v43)
          c44v56 = batteryBeamType
          c44v54 = __renovice_for_3_1:HasAttachment(c44v56)
          if not c44v54 then
            c44v54 = __renovice_for_3_1:DamageControl()
            c44v57 = 0
            c44v55 = c44v54:Name__b7c91969(c44v57)
            c44v58 = batteryBeamType
            __renovice_for_3_1:Attach(c44v58, c44v55)
          end
        end
      end
      c44v41 = _T.MissionDebug
      if c44v41 then
        c44v41 = _T.MissionDebug.FastDig
        if c44v41 then
          c44v10 = 20
        end
      end
      c44v41 = IsNull
      c44v41 = c44v41(c44v25)
      if not c44v41 then
        c44v25:SetPower(c44v6)
        c44v43 = c44v10 - c44v9
        c44v25:SetTimer(c44v43)
      end
      c44v41 = v80
      if c44v41 then
        c44v41 = gGameRules
        c44v43 = v57
        c44v41 = c44v41:GetNetPersistentVar(c44v43)
        if c44v41 == 1 then
          do return end
        end
      end
      c44v41 = v12
      c44v41:Update(c44v40)
      c44v41 = Sleep
      c44v42 = 0
      c44v41(c44v42)
      c44v40 = 0
      if (c44v6 <= c44v40 and c44v29) then
        c44v40 = v94
        c44v44 = false
        c44v40(c44v28, c44v26, c44v27, c44v44)
        c44v29 = false
        c44v37 = true
        c44v42 = nil
        c44v43 = false
        c44v44 = 2
        c44v45 = 2
        c44v0:PlayAnimation(c44v42, c44v43, c44v44, c44v45)
        if c44v4 then
          c44v40 = v2
          c44v40 = c44v40.PlayGlobalTransmission
          c44v41 = _T.MissionTransmissionSet
          c44v42 = Symbol
          c44v43 = "MissionExcavatorUnpoweredShield"
          c44v40(c44v41, c44v42(c44v43))
        else
          c44v40 = v2
          c44v40 = c44v40.PlayGlobalTransmission
          c44v41 = _T.MissionTransmissionSet
          c44v42 = Symbol
          c44v43 = "MissionExcavatorUnpowered"
          c44v40(c44v41, c44v42(c44v43))
        end
        c44v2:SetObjective(c44v0)
        c44v2:Name__7fccb7d5(c44v0)
      else
        c44v40 = 0
        if (c44v40 < c44v6 and not c44v29) then
          c44v40 = v94
          c44v44 = true
          c44v40(c44v28, c44v26, c44v27, c44v44)
          c44v29 = true
          c44v42 = excavatorAnim
          c44v43 = false
          c44v44 = 2
          c44v45 = 2
          c44v0:PlayAnimation(c44v42, c44v43, c44v44, c44v45)
        end
      end
      c44v40 = Name__3b4b94b0
      c44v40 = c44v40()
      c44v41 = 0
      if c44v41 < c44v6 then
        c44v9 = c44v9 + c44v40
      end
      c44v43 = c44v40 * 1
      c44v42 = c44v6 - c44v43
      c44v43 = 0
      c44v41 = math.max
      c44v6 = c44v41(c44v42, c44v43)
      c44v41 = IsNull
      c44v41 = c44v41(c44v5)
      if not c44v41 then
        c44v41 = c44v5:Settings()
        c44v41 = c44v41:EnableTutorialTransmissions()
        if c44v41 then
          c44v41 = 0
          if c44v6 <= c44v41 then
            if not c44v8 then
              c44v7 = c44v7 + c44v40
              c44v41 = 30
              if c44v41 <= c44v7 then
                c44v41 = _T.ShowImpactMessage
                if c44v41 then
                  c44v41 = _T.PlayerHasDeliveredCell
                  if not c44v41 then
                    c44v41 = _T.ShowImpactMessage
                    c44v42 = "/Lotus/Language/GameModes/ExcavatorOutOfPower"
                    c44v43 = 10
                    c44v41(c44v42, c44v43)
                  end
                end
                c44v8 = true
              end
            end
          else
            c44v7 = 0
            c44v41 = _T.HintActive
            if c44v41 then
              c44v41 = _T.HideImpactMessage
              c44v41()
            end
          end
        end
      end
      c44v41 = c44v9 + 0.05
    end
    if not c44v1 then
      c44v12 = true
    end
    c44v38 = gGameRules
    c44v40 = v48
    c44v41 = 0
    c44v38 = c44v38:GetNetPersistentVar(c44v40, c44v41)
    c44v38 = c44v38 + 1
    c44v39 = gGameRules
    c44v41 = v48
    c44v39:SetNetPersistentVar(c44v41, c44v38)
    c44v39 = gGameRules
    c44v41 = v53
    c44v42 = 0
    c44v39 = c44v39:GetNetPersistentVar(c44v41, c44v42)
    if c44v12 then
      c44v11 = v28
      c44v40 = gGameRules
      c44v42 = v43
      c44v43 = 0
      c44v40 = c44v40:GetNetPersistentVar(c44v42, c44v43)
      c44v41 = gGameRules
      c44v43 = v49
      c44v41:SetNetPersistentVar(c44v43, c44v40)
      c44v39 = c44v39 + 1
      c44v41 = gGameRules
      c44v43 = v53
      c44v41:SetNetPersistentVar(c44v43, c44v39)
      if not c44v37 then
        c44v41 = gChallengeMgr
        c44v43 = Symbol
        c44v44 = "EXCAVATION_COMPLETED_WITHOUT_LOSING_POWER"
        c44v41:Name__ed305ebd(c44v43(c44v44))
      end
    else
      c44v40 = v0
      c44v40 = c44v40.Round
      c44v42 = v28
      c44v43 = c44v9 / c44v10
      c44v41 = c44v42 * c44v43
      c44v11 = c44v40(c44v41)
      c44v40 = v2
      c44v40 = c44v40.PlayGlobalTransmission
      c44v41 = _T.MissionTransmissionSet
      c44v42 = Symbol
      c44v43 = "MissionExcavatorDestroyed"
      c44v40(c44v41, c44v42(c44v43))
    end
    c44v40 = gRegion
    c44v40 = c44v40:GetHumanPlayerAvatars()
    c44v41 = ipairs
    c44v41, c44v42, c44v43 = c44v41(c44v40)
    for __renovice_for_4_0, __renovice_for_4_1 in c44v41, c44v42, c44v43 do
      c44v46 = v95
      c44v48 = beamType
      c44v46(__renovice_for_4_1, c44v48, c44v34)
    end
    for __renovice_for_5_0, __renovice_for_5_1 in c44v41, c44v42, c44v43 do
    end
    c44v42 = 1
    c44v40 = math.max
    c44v11 = c44v40(c44v11, c44v42)
    c44v40 = gGameRules
    c44v42 = v44
    c44v43 = 0
    c44v40 = c44v40:GetNetPersistentVar(c44v42, c44v43)
    c44v40 = c44v40 + c44v11
    c44v41 = gGameRules
    c44v43 = v44
    c44v41:SetNetPersistentVar(c44v43, c44v40)
    c44v41 = gGameRules
    c44v43 = v45
    c44v44 = 0
    c44v41 = c44v41:GetNetPersistentVar(c44v43, c44v44)
    c44v43 = v9
    c44v42 = c44v11 * c44v43
    c44v41 = c44v41 + c44v42
    c44v42 = gGameRules
    c44v44 = v45
    c44v42:SetNetPersistentVar(c44v44, c44v41)
    c44v42 = 500
    c44v43 = v81
    if not c44v43 then
      c44v43 = c44v1.maxWaveNum
    end
    c44v44 = 0
    if c44v44 < c44v43 then
      c44v44 = v28
      c44v42 = c44v43 * c44v44
    end
    c44v45 = _T.HasPlayedHalfwayTransmission
    c44v44 = IsNull
    c44v44 = c44v44(c44v45)
    if c44v44 then
      c44v44 = _T
      c44v45 = false
      c44v44.HasPlayedHalfwayTransmission = c44v45
    end
    c44v44 = c44v42 / 2
    if c44v44 < c44v41 then
      c44v44 = _T.HasPlayedHalfwayTransmission
      if not c44v44 then
        c44v44 = _T
        c44v45 = true
        c44v44.HasPlayedHalfwayTransmission = c44v45
        c44v44 = v2
        c44v44 = c44v44.PlayGlobalTransmission
        c44v45 = _T.MissionTransmissionSet
        c44v46 = Symbol
        c44v47 = "MissionHalfway"
        c44v44(c44v45, c44v46(c44v47))
      end
    end
    c44v44 = v75
    if c44v44 then
      c44v44 = _T
      c44v45 = true
      c44v44.extractionAvailable = c44v45
    else
      c44v44 = v78
      if c44v44 then
        c44v44 = false
        c44v45 = v90
        c44v45 = c44v45()
        if c44v45 then
          c44v46 = false
          if c44v43 <= c44v38 then
            c44v47 = 0
            if not (c44v47 < c44v39) then
              c44v46 = false
            else
              c44v46 = true
            end
          end
          c44v44 = c44v46
        else
          if not (c44v43 <= c44v38) then
            c44v44 = false
          else
            c44v44 = true
          end
        end
        _T.extractionAvailable = c44v44
      else
        c44v44 = v76
        if c44v44 then
          c44v44 = _T
          if not (c44v42 <= c44v40) then
            c44v45 = false
          else
            c44v45 = true
          end
          c44v44.extractionAvailable = c44v45
        else
          c44v44 = v77
          if c44v44 then
            c44v44 = _T
            c44v45 = false
            c44v46 = 200
            if c44v46 <= c44v41 then
              c44v46 = 0
              if not (c44v46 < c44v39) then
                c44v45 = false
              else
                c44v45 = true
              end
            end
            c44v44.extractionAvailable = c44v45
          else
            if c44v12 then
              c44v44 = _T
              c44v46 = true
              c44v47 = gGameRules
              c44v47 = c44v47:GetMission()
              c44v47 = c44v47.periodicMissionTag
              c44v48 = v1
              c44v48 = c44v48.ELITE_ALERT_PERIODIC_MISSION_TAG
              if c44v47 ~= c44v48 then
                c44v47 = gGameRules
                c44v47 = c44v47:GetMission()
                c44v47 = c44v47.periodicMissionTag
                c44v48 = v1
                c44v48 = c44v48.ELITE_ALERT_PERIODIC_MISSION_TAG_ALT
                if c44v47 ~= c44v48 then
                  c44v46 = false
                else
                  c44v46 = true
                end
              end
              c44v45 = not c44v46
              if not c44v45 then
                c44v46 = 1
                if not (c44v46 < c44v39) then
                  c44v45 = false
                else
                  c44v45 = true
                end
              end
              c44v44.extractionAvailable = c44v45
            end
          end
        end
      end
    end
    c44v44 = 0
    if c44v44 < c44v11 then
      c44v47 = v9
      c44v46 = c44v11 * c44v47
      c44v45 = c44v46 * 1
      c44v46 = 1
      c44v44 = math.max
      c44v44 = c44v44(c44v45, c44v46)
      c44v45 = v93
      c44v46 = v0
      c44v46 = c44v46.Ternary
      c44v47 = v78
      c44v48 = oldWorldSalvageResource
      c44v49 = cryoticResource
      c44v46 = c44v46(c44v47, c44v48, c44v49)
      c44v45(c44v46, c44v44)
      c44v45 = v0
      c44v45 = c44v45.Ternary
      c44v46 = v78
      c44v47 = "/Lotus/Language/Game/GainedOldWorldSalvage"
      c44v48 = "/Lotus/Language/Game/GainedCryotic"
      c44v45 = c44v45(c44v46, c44v47, c44v48)
      c44v46 = gRegion
      c44v46 = c44v46:GetHumanPlayerAvatars()
      c44v49 = 1
      c44v47 = #c44v46
      c44v48 = 1
      for __renovice_for_6_0 = c44v49, c44v47, c44v48 do
        c44v50 = gGameRules
        c44v52 = c44v46[__renovice_for_6_0]
        c44v52 = c44v52:GetPlayer()
        c44v54 = ""
        c44v55 = 0
        c44v56 = 2
        c44v57 = true
        c44v58 = "AMOUNT"
        c44v59 = tostring
        c44v59 = c44v59(c44v44)
        c44v50:DisplayMessage(c44v52, c44v45, c44v54, c44v55, c44v56, c44v57, c44v58, c44v59)
      end
    end
    if not c44v44 then
      c44v45 = v2
      c44v45 = c44v45.PlayGlobalTransmission
      c44v46 = _T.MissionTransmissionSet
      c44v45(c44v46, c44v44)
    end
    c44v44 = IsNull
    c44v44 = c44v44(c44v25)
    if not c44v44 then
      c44v46 = 0
      c44v25:SetPower(c44v46)
      c44v46 = 0
      c44v25:SetTimer(c44v46)
      c44v46 = false
      c44v25:Enable(c44v46)
    end
    c44v44 = IsNull
    c44v44 = c44v44(c44v0)
    if not c44v44 then
      c44v44 = gRegion
      c44v46 = destructionEffect
      c44v47 = c44v0:GetSimPosition()
      c44v48 = ZERO_ROTATION
      c44v44:CreateEntity(c44v46, c44v47, c44v48)
      c44v44 = Engine.DamageData
      c44v44 = c44v44()
      c44v47 = 0
      c44v48 = 1
      c44v44:SetDamagePct(c44v47, c44v48)
      c44v45 = 999999
      c44v44.baseAmount = c44v45
      c44v44:SetSource(c44v25)
      c44v0:DamageDD(c44v44)
      c44v0:Destroy()
    end
    do return end
  end
  ExcavatorAvatar = v128
  v128 = function()
    local c45v0, c45v1, c45v2, c45v3
    c45v0 = gGameRules
    c45v2 = v44
    c45v3 = 0
    c45v0 = c45v0:GetNetPersistentVar(c45v2, c45v3)
    c45v1 = gGameRules
    c45v3 = v45
    c45v1:SetNetPersistentVar(c45v3, c45v0)
    do return end
  end
  EndMission = v128
  v128 = function()
    local c46v0, c46v1, c46v2, c46v3, c46v4, c46v5
    c46v0 = gGameRules
    while true do
      c46v1 = IsNull
      c46v1 = c46v1(c46v0)
      if not c46v1 then break end
      c46v0 = gGameRules
      c46v1 = Sleep
      c46v2 = 0.1
      c46v1(c46v2)
    end
    c46v1 = c46v0:GetMissionType()
    c46v2 = 17
    if c46v1 ~= c46v2 then
      do return end
    end
    c46v3 = v40
    c46v1 = c46v0:GetNetPersistentVar(c46v3)
    c46v2 = print
    c46v4 = "HostMigrationInit - excavation state="
    c46v5 = tostring
    c46v5 = c46v5(c46v1)
    c46v3 = c46v4 .. c46v5
    c46v2(c46v3)
    do return end
  end
  HostMigrationInit = v128
  v128 = function(c47v0)
    local c47v1, c47v2, c47v3, c47v4, c47v5
    c47v1 = gRegion
    c47v3 = v34
    c47v1 = c47v1:FindNearestTagged(c47v3, c47v0:GetPosition())
    c47v2 = c47v1:GetPosition()
    c47v3 = 0
    while true do
      c47v4 = beamDelay
      if not (c47v3 < c47v4) then break end
      c47v4 = IsNull
      c47v4 = c47v4(c47v1)
      if c47v4 then break end
      c47v2 = c47v1:GetPosition()
      c47v0:SetEndPoint(c47v2)
      c47v4 = DeltaTime
      c47v4 = c47v4()
      c47v3 = c47v3 + c47v4
      c47v4 = Sleep
      c47v5 = 0
      c47v4(c47v5)
    end
    c47v4 = IsNull
    c47v4 = c47v4(c47v0)
    if not c47v4 then
      c47v0:Destroy()
    end
    do return end
  end
  BatteryBeam = v128
  v128 = function(c48v0)
    local c48v1, c48v2, c48v3, c48v4, c48v5
    c48v1 = IsNull
    c48v1 = c48v1(c48v0)
    if not c48v1 then
      c48v1 = gRegion
      c48v1 = c48v1:IsMaster()
      if c48v1 then
        c48v1 = gRegion
        c48v1 = c48v1:GetNpcMgr()
        c48v1 = c48v1:GetAiDirector()
        c48v1:Name__d991ada3(c48v0)
      end
    end
    c48v1 = gRegion
    c48v3 = gLotusExcavationStateType
    c48v4 = c48v0:GetPosition()
    c48v5 = 5
    c48v1 = c48v1:FindNearest(c48v3, c48v4, c48v5)
    c48v2 = IsNull
    c48v2 = c48v2(c48v1)
    if not c48v2 then
      c48v4 = 0
      c48v1:SetPower(c48v4)
      c48v4 = 0
      c48v1:SetTimer(c48v4)
      c48v4 = false
      c48v1:Enable(c48v4)
    end
    do return end
  end
  OnExcavatorDeath = v128
  v128 = function()
    local c49v0, c49v1, c49v2, c49v3, c49v4, c49v5, c49v6, c49v7, c49v8, c49v9, c49v10, c49v11, c49v12
    c49v0 = _T.MissionDebug
    if not c49v0 then
      c49v0 = _T
      c49v1 = { FastDig = false, OldExcavatorPower = 0 }
      c49v0.MissionDebug = c49v1
    end
    c49v0 = Name__dcd1aad1
    c49v1 = "Excavation Mission"
    c49v0 = c49v0(c49v1)
    if c49v0 then
      c49v0 = ResetAttachedReposition
      c49v1 = "Excavators"
      c49v0(c49v1)
      c49v0 = Name__f1cc455a
      c49v1 = "Excavator Tracker"
      c49v2 = 4
      c49v0(c49v1, c49v2)
      c49v0 = Name__01adc66a
      c49v1 = "Entity"
      c49v0(c49v1)
      c49v0 = Name__01adc66a
      c49v1 = "Shields/Health"
      c49v0(c49v1)
      c49v0 = Name__01adc66a
      c49v1 = "Timer"
      c49v0(c49v1)
      c49v0 = Name__01adc66a
      c49v1 = "Power"
      c49v0(c49v1)
      c49v0 = Name__fb6f65c1
      c49v0()
      c49v0 = ipairs
      c49v1 = v13
      c49v0, c49v1, c49v2 = c49v0(c49v1)
      for __renovice_for_0_0, __renovice_for_0_1 in c49v0, c49v1, c49v2 do
        c49v5 = Name__e0dd80d6
        c49v5()
        c49v5 = __renovice_for_0_1:GetAvatar()
        c49v6 = Name__71bf49fc
        c49v7 = 0
        c49v6(c49v7)
        c49v6 = IsNull
        c49v6 = c49v6(c49v5)
        if not c49v6 then
          c49v6 = Name__34ac3a00
          c49v7 = tostring
          c49v7 = c49v7(c49v5:GetName())
          c49v6(c49v7)
        end
        c49v6 = Name__71bf49fc
        c49v7 = 1
        c49v6(c49v7)
        c49v6 = IsNull
        c49v6 = c49v6(c49v5)
        if not c49v6 then
          c49v6 = ImGuiTextColored
          c49v7 = 0
          c49v8 = 0.753
          c49v9 = 1
          c49v10 = 1
          c49v12 = c49v5:DamageControl()
          c49v11 = tostring
          c49v11 = c49v11(c49v12:GetShield())
          c49v6(c49v7, c49v8, c49v9, c49v10, c49v11)
          c49v6 = ImGuiSameLine
          c49v6()
          c49v6 = ImGuiTextColored
          c49v7 = 0.961
          c49v8 = 0.255
          c49v9 = 0.255
          c49v10 = 1
          c49v11 = tostring
          c49v11 = c49v11(c49v5:GetHealth())
          c49v6(c49v7, c49v8, c49v9, c49v10, c49v11)
        end
        c49v6 = Name__71bf49fc
        c49v7 = 2
        c49v6(c49v7)
        c49v6 = tonumber
        c49v6 = c49v6(__renovice_for_0_1:GetTimer())
        c49v7 = Name__34ac3a00
        c49v9 = string.format
        c49v10 = "%0.3f"
        c49v8 = tostring
        c49v8 = c49v8(c49v9(c49v10, c49v6))
        c49v7(c49v8)
        c49v7 = Name__71bf49fc
        c49v8 = 3
        c49v7(c49v8)
        c49v7 = tonumber
        c49v7 = c49v7(__renovice_for_0_1:GetPower())
        c49v8 = Name__34ac3a00
        c49v10 = string.format
        c49v11 = "%0.0f"
        c49v9 = tostring
        c49v9 = c49v9(c49v10(c49v11, c49v7))
        c49v8(c49v9)
      end
      c49v0 = Name__a43cdd06
      c49v0()
      c49v0 = ResetAttachedReposition
      c49v1 = "Commands"
      c49v0(c49v1)
      c49v0 = Name__bc6b5382
      c49v1 = "Give Powercell"
      c49v0 = c49v0(c49v1)
      if c49v0 then
        c49v0 = gRegion
        c49v0 = c49v0:GetLocalPlayerAvatar()
        c49v1 = IsNull
        c49v1 = c49v1(c49v0)
        if not c49v1 then
          c49v1 = gRegion
          c49v3 = Type
          c49v4 = cellItemPickup
          c49v3 = c49v3(c49v4)
          c49v4 = c49v0:GetSimPosition()
          c49v1:CreateEntity(c49v3, c49v4, c49v0:GetSimRotation())
        end
      end
      c49v0 = v8
      c49v0 = c49v0.TooltipEx
      c49v1 = "Spawn a Powercell directly at your avatar's feet."
      c49v0(c49v1)
      c49v0 = nil
      c49v1 = _T.MissionDebug
      c49v2 = Name__49802c36
      c49v3 = "Fast Dig"
      c49v4 = _T.MissionDebug.FastDig
      c49v2, c49v3 = c49v2(c49v3, c49v4)
      c49v1.FastDig = c49v3
      c49v0 = c49v2
      if c49v0 then
        c49v1 = _T.MissionDebug.FastDig
        if c49v1 then
          c49v1 = _T.MissionDebug
          c49v2 = v27
          c49v1.OldExcavatorPower = c49v2
          c49v1 = 20
          v27 = c49v1
          c49v1 = v13
          c49v2 = nil
          c49v3 = nil
          for __renovice_for_1_0, __renovice_for_1_1 in c49v1, c49v2, c49v3 do
            c49v6 = __renovice_for_1_1:GetTimer()
            c49v7 = v27
            if not (c49v7 < c49v6) then
              continue
            end
            c49v9 = v27
            __renovice_for_1_1:SetTimer(c49v9)
          end
          c49v1 = gGameRules
          c49v3 = v42
          c49v4 = 1
          c49v1:SetNetPersistentVar(c49v3, c49v4)
        else
          c49v1 = _T.MissionDebug.OldExcavatorPower
          v27 = c49v1
        end
      end
      c49v1 = Name__bc6b5382
      c49v2 = "Go To Nearest Dig"
      c49v1 = c49v1(c49v2)
      if c49v1 then
        c49v1 = gRegion
        c49v1 = c49v1:GetLocalPlayerAvatar()
        c49v2 = IsNull
        c49v2 = c49v2(c49v1)
        if not c49v2 then
          c49v2 = v3
          c49v2 = c49v2.Closest
          c49v3 = v13
          c49v2 = c49v2(c49v3, c49v1:GetPosition())
          c49v3 = IsNull
          c49v3 = c49v3(c49v2)
          if c49v3 then
            c49v3 = gRegion
            c49v5 = v38
            c49v3 = c49v3:FindTagged(c49v5)
            c49v6 = #c49v3
            c49v4 = 1
            c49v5 = -1
            for __renovice_for_2_0 = c49v6, c49v4, c49v5 do
              c49v7 = c49v3[__renovice_for_2_0]
              c49v7 = c49v7:IsEnabled()
              if c49v7 then
                continue
              end
              c49v7 = table.remove
              c49v7(c49v3, __renovice_for_2_0)
            end
            c49v4 = v3
            c49v4 = c49v4.Closest
            c49v2 = c49v4(c49v3, c49v1:GetPosition())
          end
          c49v3 = IsNull
          c49v3 = c49v3(c49v2)
          if not c49v3 then
            c49v3 = gRegion
            c49v3 = c49v3:GetNpcMgr()
            c49v3 = c49v3:GetAiDirector()
            c49v6 = c49v2:GetPosition()
            c49v7 = 2
            c49v8 = 5
            c49v9 = true
            c49v10 = 0.1
            c49v7 = c49v3:GetRandomPointInRangeOnNav(c49v6, c49v7, c49v8, c49v9, c49v10)
            c49v8 = ZERO_ROTATION
            c49v1:Teleport(c49v7, c49v8)
          end
        end
      end
    end
    c49v0 = Name__1cc08613
    c49v0()
    do return end
  end
  ImGuiDebug = v128
  do return end
end

