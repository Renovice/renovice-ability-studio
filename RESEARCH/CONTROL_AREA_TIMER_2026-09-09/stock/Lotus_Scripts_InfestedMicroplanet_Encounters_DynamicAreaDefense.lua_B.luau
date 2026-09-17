  local v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37, v38, v39, v40, v41, v42, v43, v44, v45, v46, v47, v48, v49, v50, v51, v52, v53, v54, v55
  v0 = require
  v1 = "Lotus.Interface.LotusUtilities"
  v0 = v0(v1)
  v1 = require
  v2 = "Lotus.Scripts.Libs.LandscapeLib"
  v1 = v1(v2)
  v2 = require
  v3 = "Lotus.Scripts.Libs.TransmissionSet"
  v2 = v2(v3)
  v3 = require
  v4 = "Lotus.Interface.Libs.TimerMgr"
  v3 = v3(v4)
  v4 = require
  v5 = "EE.Interface.Utilities"
  v4 = v4(v5)
  v5 = require
  v6 = "Lotus.Scripts.Libs.CommonGamemodeFunctions"
  v5 = v5(v6)
  v6 = Type
  v7 = "/Lotus/Types/Game/MarkerInfos/AreaMarkerDefend"
  v6 = v6(v7)
  v7 = Type
  v8 = "/Lotus/Types/Game/MarkerInfos/AreaKillMarker"
  v7 = v7(v8)
  v8 = Type
  v9 = "/Lotus/Types/Game/MarkerInfos/EnemyObjectiveMarkerInfo"
  v8 = v8(v9)
  v9 = WeakResource
  v10 = "/Lotus/Types/Enemies/Orokin/Entrati/EntratiTech/NechroTech/NechroTechAvatar"
  v9 = v9(v10)
  v10 = WeakResource
  v11 = "/Lotus/Types/Enemies/Orokin/Entrati/EntratiTech/EntratiTechDormantLandscapeAvatar"
  v10 = v10(v11)
  v11 = Symbol
  v12 = "TENNO"
  v11 = v11(v12)
  v12 = Symbol
  v13 = "CAPTURE_PROGRESS"
  v12 = v12(v13)
  v13 = Symbol
  v14 = "MISSION_TIME"
  v13 = v13(v14)
  v14 = Symbol
  v15 = "DynamicAreaDefenseCenter"
  v14 = v14(v15)
  v15 = require
  v16 = "Lotus.Scripts.Libs.ObjectiveText"
  v15 = v15(v16)
  v16 = nil
  v17 = nil
  v18 = nil
  v19 = nil
  v20 = 0
  v21 = nil
  v22 = nil
  v23 = 90
  v25 = 5
  v26 = 6
  v27 = 6
  v28 = 7
  v24 = {v25, v26, v27, v28}
  v25 = nil
  v26 = nil
  v27 = false
  v28 = nil
  v29 = nil
  v30 = nil
  v31 = nil
  v32 = 0
  v33 = false
  v34 = true
  v35 = 100
  v36 = 0
  v37 = {}
  v38 = 0
  v39 = 0
  v40 = nil
  v41 = nil
  v42 = nil
  v43 = nil
  v45 = v23 / 3
  v44 = v23 - v45
  v45 = false
  v46 = 0
  v47 = function()
    local c1v0, c1v1, c1v2, c1v3, c1v4
    c1v1 = 0
    c1v3 = v35
    c1v4 = v36
    c1v2 = c1v3 - c1v4
    c1v0 = math.max
    c1v0 = c1v0(c1v1, c1v2)
    v35 = c1v0
    c1v0 = v16
    c1v2 = v12
    c1v3 = v35
    c1v0:SetNetPersistentVar(c1v2, c1v3)
    c1v0 = v35
    c1v1 = 25
    if c1v1 < c1v0 then
      c1v0 = v34
      if c1v0 then
        c1v0 = _T
        c1v1 = true
        c1v0.QualifiedForBountyBonus = c1v1
        c1v0 = v15
        c1v0 = c1v0.SetBountyBonusAchieved
        c1v1 = "/Lotus/Language/EidolonPlains/DynamicDefendBonusObjective"
        c1v2 = { VALUE = 25 }
        c1v0(c1v1, c1v2)
        do return end
      end
    end
    c1v0 = false
    v34 = c1v0
    c1v0 = v15
    c1v0 = c1v0.SetBountyBonusFailed
    c1v1 = "/Lotus/Language/EidolonPlains/DynamicDefendBonusObjective"
    c1v2 = { VALUE = 25 }
    c1v0(c1v1, c1v2)
    do return end
  end
  v48 = function()
    local c2v0, c2v1, c2v2, c2v3, c2v4
    c2v1 = v31
    c2v1 = c2v1:GetNumAvatarsInside()
    c2v2 = v31
    c2v4 = v11
    c2v2 = c2v2:Name__7a86968a(c2v4)
    c2v0 = c2v1 - c2v2
    c2v1 = 3
    v36 = c2v1
    c2v1 = Name__995796a0
    if c2v0 <= c2v1 then
      c2v1 = 0
      v36 = c2v1
      do return end
    end
    c2v2 = v24
    c2v4 = v37
    c2v3 = #c2v4
    c2v1 = c2v2[c2v3]
    if c2v0 <= c2v1 then
      c2v1 = 1
      v36 = c2v1
    end
    do return end
  end
  v49 = function()
    local c3v0, c3v1, c3v2, c3v3
    c3v0 = v16
    c3v1 = v13
    c3v3 = v15
    c3v3 = c3v3.GetObjTime
    c3v3 = c3v3()
    c3v2 = math.ceil
    c3v2 = c3v2(c3v3)
    c3v0:SetNetPersistentVar(c3v1, c3v2)
    do return end
  end
  v50 = function()
    local c4v0, c4v1, c4v2, c4v3, c4v4, c4v5, c4v6, c4v7
    c4v0 = gRegion
    c4v0 = c4v0:GetHumanPlayerAvatars()
    c4v1 = v32
    c4v2 = ipairs
    c4v2, c4v3, c4v4 = c4v2(c4v0)
    for __renovice_for_0_0, __renovice_for_0_1 in c4v2, c4v3, c4v4 do
      c4v5 = __renovice_for_0_1:GetZone()
      c4v6 = IsNull
      c4v6 = c4v6(c4v5)
      if c4v6 then
        continue
      end
      c4v7 = gTerrainZoneType
      c4v6 = c4v5:IsA(c4v7)
      if not c4v6 then
        continue
      end
      c4v1 = c4v1 - 1
    end
    do return c4v1 end
  end
  v51 = function()
    local c5v0, c5v1, c5v2, c5v3, c5v4, c5v5, c5v6, c5v7, c5v8, c5v9, c5v10, c5v11, c5v12, c5v13, c5v14, c5v15, c5v16, c5v17
    c5v0 = print
    c5v2 = "DynamicDefend - Num Registered Agents = "
    c5v3 = v21
    c5v3 = c5v3:GetNumRegisteredAgents()
    c5v1 = c5v2 .. c5v3
    c5v0(c5v1)
    c5v0 = v21
    c5v0 = c5v0:GetRegisteredAgents()
    c5v1 = ipairs
    c5v1, c5v2, c5v3 = c5v1(c5v0)
    for __renovice_for_0_0, __renovice_for_0_1 in c5v1, c5v2, c5v3 do
      c5v4 = __renovice_for_0_1:GetAvatar()
      c5v5 = IsNull
      c5v5 = c5v5(c5v4)
      if c5v5 then
        continue
      end
      c5v5 = c5v4:GetPosition()
      c5v6 = print
      c5v8 = c5v4:GetName()
      c5v9 = " - "
      c5v10 = c5v5.x
      c5v11 = " "
      c5v12 = c5v5.y
      c5v13 = " "
      c5v14 = c5v5.z
      c5v15 = " - Distance to hint: "
      c5v17 = v21
      c5v16 = c5v4:DistanceToEntity(c5v17)
      c5v7 = c5v8 .. c5v9 .. c5v10 .. c5v11 .. c5v12 .. c5v13 .. c5v14 .. c5v15 .. c5v16
      c5v6(c5v7)
      c5v6 = c5v4:IsOnNav()
      if c5v6 then
        continue
      end
      c5v6 = print
      c5v8 = c5v4:GetName()
      c5v9 = " is not on nav, teleporting to nav"
      c5v7 = c5v8 .. c5v9
      c5v6(c5v7)
      c5v6 = v16
      c5v6:TrackshipGS(c5v4)
    end
    do return end
  end
  v52 = function()
    local c6v0, c6v1, c6v2
    c6v0 = v18
    c6v0 = c6v0:GetEncounterStatus()
    c6v1 = 4
    if c6v0 < c6v1 then
      c6v0 = v18
      c6v2 = 4
      c6v0:SetEncounterStatus(c6v2)
    end
    do return end
  end
  v53 = function()
    local c8v0, c8v1, c8v2, c8v3, c8v4, c8v5, c8v6, c8v7, c8v8, c8v9, c8v10, c8v11, c8v12, c8v13, c8v14, c8v15
    c8v14 = v30
    c8v14 = c8v14:GetModeState()
    c8v0 = 0
    v46 = c8v0
    c8v15 = 1
    local __renovice_local_0 = c8v14
    if __renovice_local_0 == c8v15 then
      c8v0 = v2
      c8v0 = c8v0.PlayGlobalTransmission
      c8v1 = v22
      c8v2 = Symbol
      c8v3 = "Arrival"
      c8v2 = c8v2(c8v3)
      c8v3 = true
      c8v0(c8v1, c8v2, c8v3)
      do return end
    end
    c8v15 = 2
    __renovice_local_0 = c8v14
    if __renovice_local_0 == c8v15 then
      c8v0 = v15
      c8v0 = c8v0.SetPrimaryObjText
      c8v1 = "/Lotus/Language/EidolonPlains/DefendClearHostiles"
      c8v2 = 2
      c8v0(c8v1, c8v2)
      do return end
    end
    c8v15 = 3
    __renovice_local_0 = c8v14
    if __renovice_local_0 == c8v15 then
      c8v0 = v2
      c8v0 = c8v0.PlayGlobalTransmission
      c8v1 = v22
      c8v2 = Symbol
      c8v3 = "Cleared"
      c8v0(c8v1, c8v2(c8v3))
      c8v1 = v26
      c8v0 = IsNull
      c8v0 = c8v0(c8v1)
      if not c8v0 then
        c8v0 = v26
        c8v0:Destroy()
      end
      c8v1 = nil
      c8v0 = IsNull
      c8v0 = c8v0(c8v1)
      if not c8v0 then
        c8v0 = nil
        c8v0:Destroy()
      end
      c8v0 = v5
      c8v0 = c8v0.CreateAreaMarker
      c8v1 = v6
      c8v2 = v43
      c8v3 = defendRadius
      c8v0 = c8v0(c8v1, c8v2, c8v3)
      v26 = c8v0
      c8v0 = v15
      c8v0 = c8v0.AddBountyBonus
      c8v1 = "/Lotus/Language/EidolonPlains/DynamicDefendBonusObjective"
      c8v2 = { VALUE = 25 }
      c8v0(c8v1, c8v2)
      c8v0 = v16
      c8v2 = v13
      c8v3 = v23
      c8v0 = c8v0:GetNetPersistentVar(c8v2, c8v3)
      c8v3 = v23
      c8v2 = c8v3 / 2
      c8v1 = c8v0 - c8v2
      c8v2 = 0
      if c8v2 < c8v1 then
        c8v2 = v29
        c8v5 = function()
          local c7v0, c7v1, c7v2, c7v3
          c7v0 = v2
          c7v0 = c7v0.PlayGlobalTransmission
          c7v1 = v22
          c7v2 = Symbol
          c7v3 = "Halfway"
          c7v0(c7v1, c7v2(c7v3))
          do return end
        end
        c8v2:AddTimer(c8v1, c8v5)
      end
      c8v2 = v29
      c8v4 = 1
      c8v5 = v47
      c8v6 = true
      c8v2 = c8v2:AddTimer(c8v4, c8v5, c8v6)
      v41 = c8v2
      c8v2 = v29
      c8v4 = 1
      c8v5 = v49
      c8v6 = true
      c8v2 = c8v2:AddTimer(c8v4, c8v5, c8v6)
      v40 = c8v2
      c8v2 = _T.AddHudTracker
      c8v3 = "DefendControl"
      c8v4 = v0
      c8v4 = c8v4.HT_LABEL
      c8v5 = 0
      c8v6 = 5
      c8v2 = c8v2(c8v3, c8v4, c8v5, c8v6)
      v25 = c8v2
      c8v2 = v15
      c8v2 = c8v2.GetPriorityOffset
      c8v2 = c8v2()
      c8v3 = v15
      c8v3 = c8v3.GetSubObjIndents
      c8v3, c8v4 = c8v3()
      c8v5 = v25
      c8v5 = c8v5.SetSortPriority
      c8v6 = c8v2 + 6
      c8v7 = false
      c8v5(c8v6, c8v7)
      c8v5 = v25
      c8v5 = c8v5.SetOffset
      c8v6 = c8v3 + 120
      c8v7 = c8v4 - 50
      c8v8 = true
      c8v5(c8v6, c8v7, c8v8)
      c8v5 = v15
      c8v5 = c8v5.SetObjTimer
      c8v7 = false
      c8v8 = true
      c8v9 = false
      c8v10 = nil
      c8v11 = nil
      c8v12 = nil
      c8v13 = "/Lotus/Language/EidolonPlains/DefendCaptureTimer"
      c8v5(c8v0, c8v7, c8v8, c8v9, c8v10, c8v11, c8v12, c8v13)
      c8v5 = v15
      c8v5 = c8v5.SetObjProgressBar
      c8v6 = "/Lotus/Language/EidolonPlains/DefendEnemyPresence"
      c8v7 = 100
      c8v8 = 100
      c8v9 = nil
      c8v10 = true
      c8v5(c8v6, c8v7, c8v8, c8v9, c8v10)
      c8v5 = v15
      c8v5 = c8v5.SetPrimaryObjText
      c8v6 = "/Lotus/Language/EidolonPlains/DefendArea"
      c8v7 = 5
      c8v5(c8v6, c8v7)
      do return end
    end
    c8v15 = 4
    __renovice_local_0 = c8v14
    if __renovice_local_0 == c8v15 then
      c8v1 = nil
      c8v0 = IsNull
      c8v0 = c8v0(c8v1)
      if not c8v0 then
        c8v0 = nil
        c8v0:Destroy()
      end
      c8v1 = v40
      c8v0 = IsNull
      c8v0 = c8v0(c8v1)
      if not c8v0 then
        c8v0 = v29
        c8v2 = v40
        c8v0:RemoveTimer(c8v2)
      end
      c8v1 = v41
      c8v0 = IsNull
      c8v0 = c8v0(c8v1)
      if not c8v0 then
        c8v0 = v29
        c8v2 = v41
        c8v0:RemoveTimer(c8v2)
      end
      c8v0 = v29
      c8v2 = 10
      c8v3 = v51
      c8v4 = true
      c8v0:AddTimer(c8v2, c8v3, c8v4)
      c8v0 = v29
      c8v2 = 30
      c8v3 = v52
      c8v0:AddTimer(c8v2, c8v3)
      c8v0 = v2
      c8v0 = c8v0.PlayGlobalTransmission
      c8v1 = v22
      c8v2 = Symbol
      c8v3 = "ClearRemainingEnemies"
      c8v0(c8v1, c8v2(c8v3))
      c8v0 = v15
      c8v0 = c8v0.SetPrimaryObjText
      c8v1 = "/Lotus/Language/EidolonPlains/ClearRemaining"
      c8v2 = 2
      c8v0(c8v1, c8v2)
      c8v0 = v15
      c8v0 = c8v0.RemoveObjProgressBar
      c8v0()
      c8v0 = false
      v27 = c8v0
      c8v0 = _T.RemoveHudTracker
      c8v1 = v25
      c8v0(c8v1)
      c8v0 = v1
      c8v0 = c8v0.UnregisterEnemiesOutsideRadius
      c8v1 = v21
      c8v2 = v20
      c8v0(c8v1, c8v2)
    end
    do return end
  end
  v54 = function(c9v0)
    local c9v1, c9v2, c9v3, c9v4, c9v5, c9v6, c9v7, c9v8, c9v9, c9v10, c9v11, c9v12, c9v13, c9v14
    c9v1 = Name__28a98c92
    Name__28a98c92 = c9v1
    c9v1 = gGameRules
    v16 = c9v1
    c9v1 = c9v0:Name__82555728()
    v21 = c9v1
    c9v1 = gRegion
    c9v1 = c9v1:GetNpcMgr()
    c9v1 = c9v1:GetAiDirector()
    v17 = c9v1
    while true do
      c9v1 = v17
      c9v1 = c9v1:Name__a76d4ecc()
      if c9v1 then break end
      c9v1 = Sleep
      c9v2 = 0
      c9v1(c9v2)
    end
    v18 = c9v0
    c9v1 = c9v0:GetPosition()
    v19 = c9v1
    c9v1 = c9v0:GetActivationRadius()
    v20 = c9v1
    c9v1 = c9v0:Name__0b41bc7d()
    c9v2 = c9v1:GetTransmissionSet()
    v22 = c9v2
    c9v2 = Name__43d4eab5
    if c9v2 then
      c9v2 = v17
      c9v4 = v14
      c9v2:TrackTaggedEntities(c9v4)
    end
    c9v2 = gRegion
    c9v4 = "OnPlayersChanged"
    c9v2:Name__f3e0f198(c9v4)
    c9v2 = gRegion
    c9v2 = c9v2:GetHumanPlayers()
    v37 = c9v2
    c9v2 = v1
    c9v2 = c9v2.CreateReinforcementMgr
    c9v3 = v17
    c9v2 = c9v2(c9v3, c9v0)
    v28 = c9v2
    c9v2 = v28
    c9v3 = true
    c9v2.mIncludeChildHints = c9v3
    c9v2 = v28
    c9v4 = 5
    c9v5 = 6
    c9v6 = 7
    c9v7 = 8
    c9v3 = {c9v4, c9v5, c9v6, c9v7}
    c9v2.mMinNumAgents = c9v3
    c9v2 = v28
    c9v4 = 9
    c9v5 = 12
    c9v6 = 15
    c9v7 = 20
    c9v3 = {c9v4, c9v5, c9v6, c9v7}
    c9v2.mMaxNumAgents = c9v3
    c9v2 = v1
    c9v2 = c9v2.CreateModeMgr
    c9v3 = v53
    c9v4 = v18
    c9v6 = v13
    c9v7 = v12
    c9v5 = {c9v6, c9v7}
    c9v2 = c9v2(c9v3, c9v4, c9v5)
    v30 = c9v2
    c9v2 = v3
    c9v2 = c9v2.CreateTimerMgr
    c9v2 = c9v2()
    v29 = c9v2
    c9v2 = v19
    v43 = c9v2
    c9v2 = gRegion
    c9v4 = v14
    c9v5 = v19
    c9v6 = 0
    c9v7 = v20
    c9v2 = c9v2:FindTaggedInRadius(c9v4, c9v5, c9v6, c9v7)
    c9v3 = v21
    c9v3 = c9v3:GetZone()
    c9v3 = c9v3:GetLayerIndex()
    c9v4 = ipairs
    c9v4, c9v5, c9v6 = c9v4(c9v2)
    for __renovice_for_0_0, __renovice_for_0_1 in c9v4, c9v5, c9v6 do
      c9v9 = __renovice_for_0_1:GetZone()
      c9v10 = IsNull
      c9v10 = c9v10(c9v9)
      if c9v10 then
        continue
      end
      c9v10 = c9v9:GetLayerIndex()
      if c9v10 ~= c9v3 then
        continue
      end
      c9v10 = __renovice_for_0_1:GetPosition()
      v43 = c9v10
      break
    end
    c9v4 = v5
    c9v4 = c9v4.CreateAreaMarker
    c9v5 = v7
    c9v6 = v43
    c9v7 = defendRadius
    c9v4 = c9v4(c9v5, c9v6, c9v7)
    v26 = c9v4
    c9v4 = gRegion
    c9v6 = defendTriggerType
    c9v7 = v43
    c9v8 = ZERO_ROTATION
    c9v4 = c9v4:CreateEntity(c9v6, c9v7, c9v8)
    v31 = c9v4
    c9v4 = v31
    c9v6 = defendRadius
    c9v4:SetRadius(c9v6)
    c9v4 = gRegion
    c9v6 = Symbol
    c9v7 = "DefenseStartedSeq"
    c9v4 = c9v4:FindFirstTagged(c9v6(c9v7))
    v42 = c9v4
    c9v6 = "PlayersLeaving"
    c9v7 = Symbol
    c9v8 = "LeavingCB"
    c9v0:Name__b2f41e3d(c9v6, c9v7(c9v8))
    c9v6 = "PlayersReturning"
    c9v7 = Symbol
    c9v8 = "ReturningCB"
    c9v0:AgnosticTest(c9v6, c9v7(c9v8))
    c9v4 = v16
    c9v6 = v12
    c9v7 = 100
    c9v4 = c9v4:GetNetPersistentVar(c9v6, c9v7)
    v35 = c9v4
    c9v4 = v21
    c9v6 = "OnAgentRegistered"
    c9v7 = Symbol
    c9v8 = "DefendRegistration"
    c9v7 = c9v7(c9v8)
    c9v8 = true
    c9v4:Name__800c0049(c9v6, c9v7, c9v8)
    c9v4 = Name__43d4eab5
    if c9v4 then
      c9v4 = gRegion
      c9v6 = gLotusNpcAvatarType
      c9v7 = v21
      c9v7 = c9v7:GetPosition()
      c9v8 = 0
      c9v9 = v21
      c9v4 = c9v4:FindAll(c9v6, c9v7, c9v8, c9v9:GetActivationRadius())
      c9v5 = ipairs
      c9v5, c9v6, c9v7 = c9v5(c9v4)
      for __renovice_for_1_0, __renovice_for_1_1 in c9v5, c9v6, c9v7 do
        c9v10 = __renovice_for_1_1:GetFaction()
        c9v11 = Symbol
        c9v12 = "Infestation"
        c9v11 = c9v11(c9v12)
        if c9v10 ~= c9v11 then
          continue
        end
        c9v10 = IsNull
        c9v10 = c9v10(__renovice_for_1_1:GetAgent())
        if c9v10 then
          continue
        end
        c9v0:RegisterAgent(__renovice_for_1_1:GetAgent())
      end
    end
    c9v4 = v18
    c9v4 = c9v4:Name__68bb2263()
    c9v5 = v30
    c9v7 = v4
    c9v7 = c9v7.Ternary
    c9v13 = 0
    c9v14 = c9v4
    if c9v14 ~= c9v13 then
      c9v8 = false
    else
      c9v8 = true
    end
    c9v9 = 1
    c9v5:SetModeState(c9v7(c9v8, c9v9, c9v4))
    c9v5 = Name__43d4eab5
    if c9v5 then
      c9v5 = v21
      c9v7 = 1
      c9v5:Name__27934b63(c9v7)
    end
    c9v5 = c9v0:GetEncounterStatus()
    c9v6 = 1
    if c9v5 == c9v6 then
      c9v7 = 2
      c9v0:SetEncounterStatus(c9v7)
    end
    do return end
  end
  v55 = function(c10v0)
    local c10v1, c10v2, c10v3, c10v4, c10v5, c10v6, c10v7, c10v8, c10v9, c10v10, c10v11
    c10v1 = v54
    c10v1(c10v0)
    while true do
      c10v1 = c10v0:GetEncounterStatus()
      c10v2 = 4
      if not (c10v1 < c10v2) then break end
      c10v1 = Name__3b4b94b0
      c10v1 = c10v1()
      c10v2 = v30
      c10v2 = c10v2:GetModeState()
      c10v4 = v46
      c10v3 = c10v4 + c10v1
      v46 = c10v3
      c10v3 = Name__43d4eab5
      if c10v3 then
        c10v3 = 4
        if c10v2 <= c10v3 then
          c10v4 = 1
          c10v5 = gRegion
          c10v3 = math.max
          c10v3 = c10v3(c10v4, c10v5:Name__c988433c())
          v32 = c10v3
          c10v3 = v50
          c10v3 = c10v3()
          c10v10 = 0
          c10v11 = c10v3
          if c10v11 == c10v10 then
            c10v4 = gRegion
            c10v4 = c10v4:GetNpcMgr()
            c10v4 = c10v4:GetAiDirector()
            c10v4 = c10v4:GetSysTime()
            c10v5 = v33
            if not c10v5 then
              c10v5 = v1
              c10v5 = c10v5.PlayersAbandoningObjective
              c10v6 = v18
              c10v7 = true
              c10v5(c10v6, c10v7)
              c10v5 = v18
              c10v7 = c10v4 + 15
              c10v5:SetAbandonTime(c10v7)
              c10v5 = true
              v33 = c10v5
            else
              c10v5 = v18
              c10v5 = c10v5:WebsAttr()
              if c10v5 <= c10v4 then
                c10v5 = v1
                c10v5 = c10v5.PlayersAbandonedObjective
                c10v5()
                c10v5 = v18
                c10v7 = 5
                c10v5:SetEncounterStatus(c10v7)
              end
            end
          else
            c10v4 = v33
            if c10v4 then
              c10v4 = false
              v33 = c10v4
              c10v4 = v1
              c10v4 = c10v4.PlayersAbandoningObjective
              c10v5 = v18
              c10v6 = false
              c10v4(c10v5, c10v6)
              c10v4 = v18
              c10v6 = 0
              c10v4:SetAbandonTime(c10v6)
            end
          end
        end
      end
      c10v10 = 1
      c10v11 = c10v2
      if c10v11 == c10v10 then
        repeat
          c10v3 = v21
          c10v3 = c10v3:GetEncounterStatus()
          c10v4 = 2
          if not (c10v4 <= c10v3) then
            c10v3 = v21
            c10v3 = c10v3:IsActive()
            if c10v3 then break end
          end
          c10v3 = v30
          c10v5 = 2
          c10v3:SetModeState(c10v5)
        until true
      else
        c10v10 = 2
        c10v11 = c10v2
        if c10v11 == c10v10 then
          c10v9 = -1
          c10v3 = v21
          c10v3 = c10v3:Name__48b3218f()
          c10v10 = 0
          c10v11 = c10v3
          if c10v11 == c10v10 then
            c10v9 = -1
          else
            c10v9 = 1
          end
          c10v10 = 1
          c10v11 = c10v9
          if c10v11 == c10v10 then
            c10v3 = v46
            c10v4 = Name__36d88e97
            if not (c10v4 < c10v3) then
              c10v9 = 2
            else
              c10v9 = -1
            end
          end
          c10v10 = 2
          c10v11 = c10v9
          if c10v11 == c10v10 then
            c10v3 = v21
            c10v3 = c10v3:Name__48b3218f()
            c10v4 = 5
            if not (c10v3 <= c10v4) then
              c10v9 = 5
            else
              c10v9 = 3
            end
          end
          c10v10 = 3
          c10v11 = c10v9
          if c10v11 == c10v10 then
            c10v3 = v27
            if c10v3 then
              c10v9 = 5
            else
              c10v9 = 4
            end
          end
          c10v10 = 4
          c10v11 = c10v9
          if c10v11 == c10v10 then
            c10v3 = v1
            c10v3 = c10v3.MarkRemainingEnemies
            c10v4 = v21
            c10v5 = v8
            c10v6 = v21
            c10v3(c10v4, c10v5, c10v6)
            c10v3 = true
            v27 = c10v3
            c10v9 = 5
          end
          c10v10 = 5
          c10v11 = c10v9
          if c10v11 ~= c10v10 then
            c10v3 = gRegion
            c10v5 = geoReveal
            c10v6 = v43
            c10v7 = ZERO_ROTATION
            c10v3 = c10v3:CreateEntity(c10v5, c10v6, c10v7)
            v42 = c10v3
            c10v3 = v42
            c10v3:Enable()
            c10v3 = v30
            c10v5 = 3
            c10v3:SetModeState(c10v5)
          end
        else
          c10v10 = 3
          c10v11 = c10v2
          if c10v11 == c10v10 then
            c10v4 = v44
            c10v3 = c10v4 - c10v1
            v44 = c10v3
            c10v3 = v44
            c10v4 = 0
            if c10v3 < c10v4 then
              c10v3 = v45
              c10v10 = false
              c10v11 = c10v3
              if c10v11 == c10v10 then
                c10v3 = v28
                c10v5 = 7
                c10v6 = 8
                c10v7 = 9
                c10v8 = 10
                c10v4 = {c10v5, c10v6, c10v7, c10v8}
                c10v3.mMinNumAgents = c10v4
                c10v3 = v28
                c10v5 = 9
                c10v6 = 12
                c10v7 = 15
                c10v8 = 20
                c10v4 = {c10v5, c10v6, c10v7, c10v8}
                c10v3.mMaxNumAgents = c10v4
                c10v3 = true
                v45 = c10v3
              end
            end
            c10v4 = v31
            c10v4 = c10v4:GetNumAvatarsInside()
            c10v5 = v31
            c10v7 = v11
            c10v5 = c10v5:Name__7a86968a(c10v7)
            c10v3 = c10v4 - c10v5
            c10v4 = 3
            v36 = c10v4
            c10v4 = Name__995796a0
            if c10v3 <= c10v4 then
              c10v4 = 0
              v36 = c10v4
            else
              c10v5 = v24
              c10v7 = v37
              c10v6 = #c10v7
              c10v4 = c10v5[c10v6]
              if c10v3 <= c10v4 then
                c10v4 = 1
                v36 = c10v4
              end
            end
            c10v3 = v28
            c10v3:Update(c10v1)
            c10v3 = v15
            c10v3 = c10v3.SetObjProgressBar
            c10v4 = "/Lotus/Language/EidolonPlains/DefendEnemyPresence"
            c10v5 = v35
            c10v6 = 100
            c10v7 = nil
            c10v8 = true
            c10v3(c10v4, c10v5, c10v6, c10v7, c10v8)
            c10v3 = v39
            c10v4 = 0
            if c10v4 < c10v3 then
              c10v4 = v39
              c10v3 = c10v4 - c10v1
              v39 = c10v3
            else
              c10v3 = v25
              c10v3 = c10v3.SetLabel
              c10v4 = ""
              c10v3(c10v4)
              c10v3 = 0
              v38 = c10v3
            end
            c10v3 = v15
            c10v3 = c10v3.GetObjTime
            c10v3 = c10v3()
            c10v4 = 0
            if c10v3 <= c10v4 then
              c10v3 = v30
              c10v5 = 4
              c10v3:SetModeState(c10v5)
            else
              c10v3 = v35
              c10v4 = 0
              if c10v3 <= c10v4 then
                c10v5 = 5
                c10v0:SetEncounterStatus(c10v5)
              end
            end
          else
            c10v10 = 4
            c10v11 = c10v2
            if c10v11 == c10v10 then
              c10v3 = v21
              c10v3 = c10v3:Name__48b3218f()
              c10v10 = 0
              c10v11 = c10v3
              if c10v11 == c10v10 then
                c10v5 = 4
                c10v0:SetEncounterStatus(c10v5)
              else
                c10v3 = v21
                c10v3 = c10v3:Name__48b3218f()
                c10v4 = 5
                if c10v3 <= c10v4 then
                  c10v3 = v27
                  if not c10v3 then
                    c10v3 = v1
                    c10v3 = c10v3.MarkRemainingEnemies
                    c10v4 = v21
                    c10v5 = v8
                    c10v6 = v21
                    c10v3(c10v4, c10v5, c10v6)
                    c10v3 = true
                    v27 = c10v3
                  end
                end
              end
            end
          end
        end
      end
      c10v3 = v29
      c10v3:Update(c10v1)
      c10v3 = c10v0:ShouldShutDown()
      if c10v3 then
        c10v3 = v1
        c10v3 = c10v3.PlayersAbandonedObjective
        c10v3()
        c10v5 = 5
        c10v0:SetEncounterStatus(c10v5)
      end
      c10v3 = Sleep
      c10v4 = 0
      c10v3(c10v4)
    end
    c10v2 = v26
    c10v1 = IsNull
    c10v1 = c10v1(c10v2)
    if not c10v1 then
      c10v1 = v26
      c10v1:Destroy()
    end
    c10v2 = nil
    c10v1 = IsNull
    c10v1 = c10v1(c10v2)
    if not c10v1 then
      c10v1 = nil
      c10v1:Destroy()
    end
    c10v2 = v42
    c10v1 = IsNull
    c10v1 = c10v1(c10v2)
    if not c10v1 then
      c10v1 = v42
      c10v1:Destroy()
    end
    c10v2 = v31
    c10v1 = IsNull
    c10v1 = c10v1(c10v2)
    if not c10v1 then
      c10v1 = v31
      c10v1:Destroy()
    end
    c10v1 = v18
    c10v1 = c10v1:GetEncounterStatus()
    c10v2 = 4
    if c10v1 == c10v2 then
      c10v1 = _T.QualifiedForBountyBonus
      if c10v1 then
        c10v1 = v2
        c10v1 = c10v1.PlayGlobalTransmission
        c10v2 = v22
        c10v3 = Symbol
        c10v4 = "CompleteBonus"
        c10v1(c10v2, c10v3(c10v4))
      else
        c10v1 = v2
        c10v1 = c10v1.PlayGlobalTransmission
        c10v2 = v22
        c10v3 = Symbol
        c10v4 = "Complete"
        c10v1(c10v2, c10v3(c10v4))
      end
    end
    c10v1 = v1
    c10v1 = c10v1.CleanUpDynamicMission
    c10v2 = v21
    c10v1(c10v2)
    c10v1 = v17
    c10v3 = true
    c10v1:InterludeENTRANCE(c10v3)
    c10v1 = v15
    c10v1 = c10v1.RemoveBountyBonus
    c10v1()
    c10v1 = v15
    c10v1 = c10v1.ClearPrimaryObjText
    c10v1()
    c10v1 = v15
    c10v1 = c10v1.RemoveObjProgressBar
    c10v1()
    c10v1 = v15
    c10v1 = c10v1.RemoveObjTimer
    c10v1()
    c10v1 = _T.RemoveHudTracker
    c10v2 = v25
    c10v1(c10v2)
    c10v1 = v21
    c10v3 = Symbol
    c10v4 = "DefendRegistration"
    c10v1:Name__9a661e27(c10v3(c10v4))
    c10v3 = Symbol
    c10v4 = "LeavingCB"
    c10v0:Name__8707bcec(c10v3(c10v4))
    c10v3 = Symbol
    c10v4 = "ReturningCB"
    c10v0:Name__9e4ee8e6(c10v3(c10v4))
    c10v1 = v30
    c10v1:ShutDown()
    do return end
  end
  DefendStart = v55
  v55 = function()
    local c11v0
    c11v0 = gRegion
    c11v0 = c11v0:GetHumanPlayers()
    v37 = c11v0
    do return end
  end
  OnPlayersChanged = v55
  v55 = function(c12v0)
    local c12v1, c12v2, c12v3, c12v4, c12v5, c12v6, c12v7, c12v8, c12v9, c12v10, c12v11
    c12v1 = v30
    c12v1 = c12v1:GetModeState()
    c12v10 = 3
    c12v11 = c12v1
    if c12v11 == c12v10 then
      c12v3 = v35
      c12v4 = Name__28a98c92
      c12v2 = c12v3 + c12v4
      c12v3 = 100
      c12v1 = math.min
      c12v1 = c12v1(c12v2, c12v3)
      v35 = c12v1
      c12v2 = v38
      c12v1 = c12v2 + 1
      v38 = c12v1
      c12v1 = 3
      v39 = c12v1
      c12v2 = v38
      c12v3 = Name__28a98c92
      c12v1 = c12v2 * c12v3
      c12v2 = v25
      c12v2 = c12v2.SetLabel
      c12v4 = "<p><font face=\"Noto Sans\" size=\"14\">"
      c12v7 = v25
      c12v7 = c12v7.Localize
      c12v8 = "/Lotus/Language/EidolonPlains/DefendControlTracker"
      c12v9 = { AMOUNT = nil }
      c12v9.AMOUNT = c12v1
      c12v5 = c12v7(c12v8, c12v9)
      c12v6 = "</font></p>"
      c12v3 = c12v4 .. c12v5 .. c12v6
      c12v2(c12v3)
    end
    do return end
  end
  OnKilled = v55
  v55 = function(c13v0)
    local c13v1, c13v2, c13v3, c13v4, c13v5, c13v6
    c13v5 = 0
    c13v1 = c13v0:GetAvatar()
    c13v3 = v9
    c13v1 = c13v1:IsA(c13v3)
    if c13v1 then
      c13v5 = 2
    else
      c13v5 = 1
    end
    c13v6 = 1
    local __renovice_local_0 = c13v5
    if __renovice_local_0 == c13v6 then
      c13v1 = c13v0:GetAvatar()
      c13v3 = v10
      c13v1 = c13v1:IsA(c13v3)
      if not c13v1 then
        c13v5 = 3
      else
        c13v5 = 2
      end
    end
    c13v6 = 2
    __renovice_local_0 = c13v5
    if __renovice_local_0 == c13v6 then
      do return end
    end
    c13v6 = 3
    __renovice_local_0 = c13v5
    if __renovice_local_0 == c13v6 then
      c13v1 = ObjectPortHandler
      c13v2 = c13v0:GetAvatar()
      c13v3 = "OnKilled"
      c13v1(c13v2, c13v3)
      c13v3 = v18
      c13v0:StormTarget(c13v3)
      c13v1 = v30
      c13v1 = c13v1:GetModeState()
      c13v6 = 4
      __renovice_local_0 = c13v1
      if __renovice_local_0 == c13v6 then
        c13v5 = 5
      else
        c13v5 = 4
      end
    end
    c13v6 = 4
    __renovice_local_0 = c13v5
    if __renovice_local_0 == c13v6 then
      c13v1 = v30
      c13v1 = c13v1:GetModeState()
      c13v6 = 2
      __renovice_local_0 = c13v1
      if __renovice_local_0 ~= c13v6 then
        c13v5 = 7
      else
        c13v5 = 5
      end
    end
    c13v6 = 5
    __renovice_local_0 = c13v5
    if __renovice_local_0 == c13v6 then
      c13v1 = v21
      c13v1 = c13v1:GetNumRegisteredAgents()
      c13v2 = 5
      if not (c13v1 <= c13v2) then
        c13v5 = 7
      else
        c13v5 = 6
      end
    end
    c13v6 = 6
    __renovice_local_0 = c13v5
    if __renovice_local_0 == c13v6 then
      c13v1 = v1
      c13v1 = c13v1.MarkRemainingEnemies
      c13v2 = v21
      c13v3 = v8
      c13v4 = v21
      c13v1(c13v2, c13v3, c13v4)
      c13v5 = 7
    end
    c13v6 = 7
    __renovice_local_0 = c13v5
    if __renovice_local_0 == c13v6 then
      do return end
    end
    do return end
  end
  OnAgentRegistered = v55
  v55 = function()
    local c14v0, c14v1, c14v2
    c14v0 = v1
    c14v0 = c14v0.PlayersAbandoningObjective
    c14v1 = v18
    c14v2 = true
    c14v0(c14v1, c14v2)
    do return end
  end
  PlayersLeaving = v55
  v55 = function()
    local c15v0, c15v1, c15v2
    c15v0 = v1
    c15v0 = c15v0.PlayersAbandoningObjective
    c15v1 = v18
    c15v2 = false
    c15v0(c15v1, c15v2)
    do return end
  end
  PlayersReturning = v55
  do return end
