  local v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37, v38, v39, v40, v41, v42, v43, v44, v45, v46, v47, v48, v49
  v0 = require
  v1 = "Lotus.Interface.LotusUtilities"
  v0 = v0(v1)
  v1 = require
  v2 = "Lotus.Scripts.Libs.LandscapeLib"
  v1 = v1(v2)
  v2 = require
  v3 = "Lotus.Scripts.Libs.CrewShipLib"
  v2 = v2(v3)
  v3 = require
  v4 = "Lotus.Scripts.Libs.TransmissionSet"
  v3 = v3(v4)
  v4 = require
  v5 = "Lotus.Interface.Libs.TimerMgr"
  v4 = v4(v5)
  v5 = Type
  v6 = "/Lotus/Types/Game/MarkerInfos/EidolonObjectiveMarker"
  v5 = v5(v6)
  v6 = Type
  v7 = "/Lotus/Types/Game/MarkerInfos/EnemyObjectiveMarkerInfo"
  v6 = v6(v7)
  v7 = Symbol
  v8 = "MODE_STATE"
  v7 = v7(v8)
  v8 = Symbol
  v9 = "CAPTURE_PROGRESS"
  v8 = v8(v9)
  v9 = Symbol
  v10 = "MISSION_TIME"
  v9 = v9(v10)
  v10 = require
  v11 = "Lotus.Scripts.Libs.ObjectiveText"
  v10 = v10(v11)
  v11 = nil
  v12 = nil
  v13 = nil
  v14 = nil
  v15 = 0
  v16 = 0
  v17 = nil
  v18 = nil
  v19 = 0
  v20 = nil
  v21 = 90
  v23 = 6
  v24 = 7
  v25 = 8
  v26 = 9
  v22 = {v23, v24, v25, v26}
  v23 = nil
  v24 = nil
  v25 = false
  v26 = nil
  v27 = nil
  v28 = true
  v29 = 20
  v30 = 100
  v31 = 0
  v32 = {}
  v33 = v21
  v34 = {}
  v35 = 0
  v36 = 0
  v37 = nil
  v38 = nil
  v39 = function(c1v0)
    local c1v1, c1v2, c1v3, c1v4
    c1v3 = 15 * c1v0
    c1v4 = v21
    c1v2 = c1v3 / c1v4
    c1v1 = 20 - c1v2
    do return c1v1 end
  end
  v40 = function()
    local c2v0, c2v1, c2v2, c2v3, c2v4, c2v5, c2v6, c2v7, c2v8
    c2v0 = v29
    c2v1 = 0
    if c2v0 <= c2v1 then
      c2v0 = isCrewShipEncounter
      if c2v0 then
        c2v0 = v2
        c2v0 = c2v0.SpawnReinforcementsForHint
        c2v1 = v13
        c2v2 = 0
        c2v3 = v15
        c2v4 = true
        c2v5 = false
        c2v6 = false
        c2v7 = v13
        c2v8 = true
        c2v0(c2v1, c2v2, c2v3, c2v4, c2v5, c2v6, c2v7, c2v8)
        c2v2 = v21
        c2v3 = v33
        c2v1 = c2v2 - c2v3
        c2v3 = 15 * c2v1
        c2v4 = v21
        c2v2 = c2v3 / c2v4
        c2v0 = 20 - c2v2
        v29 = c2v0
        do return end
      end
      c2v0 = nil
      c2v1 = isCaveEncounter
      if c2v1 then
        c2v1 = v12
        c2v3 = v14
        c2v4 = 0
        c2v5 = v15
        c2v6 = 2
        c2v7 = 2
        c2v8 = v13
        c2v0 = c2v1:ActivateRandomEncounterNearPos(c2v3, c2v4, c2v5, c2v6, c2v7, c2v8)
      else
        c2v1 = v12
        c2v3 = v14
        c2v4 = 0
        c2v5 = v15
        c2v6 = 2
        c2v7 = 2
        c2v8 = v13
        c2v0 = c2v1:ActivateRandomEncounterNearPos(c2v3, c2v4, c2v5, c2v6, c2v7, c2v8)
      end
      c2v1 = IsNull
      c2v1 = c2v1(c2v0)
      if c2v1 then
        c2v1 = print
        c2v2 = "MT_DEFENSE: Failed to start strike"
        c2v1(c2v2)
        do return end
      end
      c2v3 = v21
      c2v4 = v33
      c2v2 = c2v3 - c2v4
      c2v4 = 15 * c2v2
      c2v5 = v21
      c2v3 = c2v4 / c2v5
      c2v1 = 20 - c2v3
      v29 = c2v1
      c2v2 = v32
      c2v1 = table.insert
      c2v1(c2v2, c2v0)
      do return end
    end
    c2v0 = isCrewShipEncounter
    if not c2v0 then
      c2v1 = v32
      c2v0 = #c2v1
      c2v1 = 1
      if not (c2v0 < c2v1) then
        c2v3 = v32
        c2v2 = #c2v3
        c2v0 = 1
        c2v1 = -1
        for __renovice_for_0_0 = c2v2, c2v0, c2v1 do
          repeat
            c2v4 = v32[__renovice_for_0_0]
            c2v3 = IsNull
            c2v3 = c2v3(c2v4)
            if not c2v3 then
              c2v3 = v32[__renovice_for_0_0]
              c2v3 = c2v3:GetEncounterStatus()
              c2v4 = 3
              if c2v3 ~= c2v4 then break end
            end
            c2v3 = table.remove
            c2v4 = v32
            c2v3(c2v4, __renovice_for_0_0)
          until true
        end
        do return end
      end
    end
    c2v1 = v29
    c2v2 = Name__3b4b94b0
    c2v2 = c2v2()
    c2v0 = c2v1 - c2v2
    v29 = c2v0
    do return end
  end
  v41 = function()
    local c3v0, c3v1, c3v2, c3v3, c3v4, c3v5, c3v6, c3v7
    c3v0 = ""
    c3v6 = v31
    c3v7 = 1
    local __renovice_local_0 = c3v6
    if __renovice_local_0 == c3v7 then
      c3v0 = "/Lotus/Language/EidolonPlains/DefendCapRateLow"
    else
      c3v6 = v31
      c3v7 = 3
      __renovice_local_0 = c3v6
      if __renovice_local_0 == c3v7 then
        c3v0 = "/Lotus/Language/EidolonPlains/DefendCapRateHigh"
      else
        c3v0 = "/Lotus/Language/EidolonPlains/DefendCapRateNone"
      end
    end
    c3v6 = v10
    c3v6 = c3v6.SetObjProgressBar
    c3v1 = "/Lotus/Language/EidolonPlains/DefendEnemyPresence"
    c3v2 = v30
    c3v3 = 100
    c3v4 = nil
    c3v5 = true
    c3v6(c3v1, c3v2, c3v3, c3v4, c3v5)
    do return end
  end
  v42 = function()
    local c4v0, c4v1, c4v2, c4v3, c4v4
    c4v1 = 0
    c4v3 = v30
    c4v4 = v31
    c4v2 = c4v3 - c4v4
    c4v0 = math.max
    c4v0 = c4v0(c4v1, c4v2)
    v30 = c4v0
    c4v0 = v11
    c4v2 = v8
    c4v3 = v30
    c4v0:SetNetPersistentVar(c4v2, c4v3)
    c4v0 = v30
    c4v1 = 50
    if c4v1 < c4v0 then
      c4v0 = v28
      if c4v0 then
        c4v0 = _T
        c4v1 = true
        c4v0.QualifiedForBountyBonus = c4v1
        c4v0 = v10
        c4v0 = c4v0.SetBountyBonusAchieved
        c4v1 = "/Lotus/Language/EidolonPlains/DynamicDefendBonusObjective"
        c4v2 = { VALUE = 50 }
        c4v0(c4v1, c4v2)
        do return end
      end
    end
    c4v0 = false
    v28 = c4v0
    c4v0 = _T
    c4v1 = false
    c4v0.QualifiedForBountyBonus = c4v1
    c4v0 = v10
    c4v0 = c4v0.SetBountyBonusFailed
    c4v1 = "/Lotus/Language/EidolonPlains/DynamicDefendBonusObjective"
    c4v2 = { VALUE = 50 }
    c4v0(c4v1, c4v2)
    do return end
  end
  v43 = function()
    local c5v0, c5v1, c5v2, c5v3, c5v4
    c5v0 = v17
    c5v0 = c5v0:GetNumRegisteredAgents()
    c5v1 = 3
    v31 = c5v1
    c5v2 = v34
    c5v1 = #c5v2
    if c5v0 <= c5v1 then
      c5v1 = 0
      v31 = c5v1
      do return end
    end
    c5v2 = v22
    c5v4 = v34
    c5v3 = #c5v4
    c5v1 = c5v2[c5v3]
    if c5v0 <= c5v1 then
      c5v1 = 1
      v31 = c5v1
    end
    do return end
  end
  v44 = function()
    local c6v0, c6v1, c6v2, c6v3
    c6v0 = v11
    c6v1 = v9
    c6v3 = v10
    c6v3 = c6v3.GetObjTime
    c6v3 = c6v3()
    c6v2 = math.ceil
    c6v2 = c6v2(c6v3)
    c6v0:SetNetPersistentVar(c6v1, c6v2)
    do return end
  end
  v45 = function()
    local c7v0, c7v1, c7v2, c7v3, c7v4, c7v5, c7v6, c7v7, c7v8, c7v9, c7v10, c7v11, c7v12, c7v13, c7v14, c7v15, c7v16, c7v17
    c7v0 = print
    c7v2 = "DynamicDefend - Num Registered Agents = "
    c7v3 = v17
    c7v3 = c7v3:GetNumRegisteredAgents()
    c7v1 = c7v2 .. c7v3
    c7v0(c7v1)
    c7v0 = v17
    c7v0 = c7v0:GetRegisteredAgents()
    c7v1 = ipairs
    c7v1, c7v2, c7v3 = c7v1(c7v0)
    for __renovice_for_0_0, __renovice_for_0_1 in c7v1, c7v2, c7v3 do
      c7v4 = __renovice_for_0_1:GetAvatar()
      c7v5 = IsNull
      c7v5 = c7v5(c7v4)
      if c7v5 then
        continue
      end
      c7v5 = c7v4:GetPosition()
      c7v6 = print
      c7v8 = c7v4:GetName()
      c7v9 = " - "
      c7v10 = c7v5.x
      c7v11 = " "
      c7v12 = c7v5.y
      c7v13 = " "
      c7v14 = c7v5.z
      c7v15 = " - Distance to hint: "
      c7v17 = v17
      c7v16 = c7v4:DistanceToEntity(c7v17)
      c7v7 = c7v8 .. c7v9 .. c7v10 .. c7v11 .. c7v12 .. c7v13 .. c7v14 .. c7v15 .. c7v16
      c7v6(c7v7)
      c7v6 = c7v4:IsOnNav()
      if c7v6 then
        continue
      end
      c7v6 = print
      c7v8 = c7v4:GetName()
      c7v9 = " is not on nav, teleporting to nav"
      c7v7 = c7v8 .. c7v9
      c7v6(c7v7)
      c7v6 = v11
      c7v6:TrackshipGS(c7v4)
    end
    do return end
  end
  v46 = function()
    local c8v0, c8v1, c8v2
    c8v0 = v13
    c8v0 = c8v0:GetEncounterStatus()
    c8v1 = 4
    if c8v0 < c8v1 then
      c8v0 = v13
      c8v2 = 4
      c8v0:SetEncounterStatus(c8v2)
    end
    do return end
  end
  v47 = function()
    local c9v0, c9v1, c9v2, c9v3, c9v4, c9v5, c9v6, c9v7, c9v8, c9v9, c9v10, c9v11, c9v12, c9v13
    c9v12 = v19
    c9v13 = 1
    local __renovice_local_0 = c9v12
    if __renovice_local_0 == c9v13 then
      c9v12 = v3
      c9v12 = c9v12.PlayGlobalTransmission
      c9v0 = v18
      c9v1 = Symbol
      c9v2 = "CampActivated"
      c9v1 = c9v1(c9v2)
      c9v2 = true
      c9v12(c9v0, c9v1, c9v2)
      do return end
    end
    c9v12 = v19
    c9v13 = 2
    __renovice_local_0 = c9v12
    if __renovice_local_0 == c9v13 then
      c9v12 = v10
      c9v12 = c9v12.SetPrimaryObjText
      c9v0 = "/Lotus/Language/EidolonPlains/DefendClearHostiles"
      c9v1 = 2
      c9v12(c9v0, c9v1)
      do return end
    end
    c9v12 = v19
    c9v13 = 3
    __renovice_local_0 = c9v12
    if __renovice_local_0 == c9v13 then
      c9v12 = v10
      c9v12 = c9v12.AddBountyBonus
      c9v0 = "/Lotus/Language/EidolonPlains/DynamicDefendBonusObjective"
      c9v1 = { VALUE = 50 }
      c9v12(c9v0, c9v1)
      c9v12 = v11
      c9v1 = v9
      c9v2 = v21
      c9v12 = c9v12:GetNetPersistentVar(c9v1, c9v2)
      c9v0 = gPromotedToHost
      if c9v0 then
        c9v1 = v21
        c9v0 = c9v1 - 10
        if c9v0 < c9v12 then
          c9v0 = v3
          c9v0 = c9v0.PlayGlobalTransmission
          c9v1 = v18
          c9v2 = Symbol
          c9v3 = "DefendStart"
          c9v0(c9v1, c9v2(c9v3))
        end
      else
        c9v0 = v3
        c9v0 = c9v0.PlayGlobalTransmission
        c9v1 = v18
        c9v2 = Symbol
        c9v3 = "DefendStart"
        c9v0(c9v1, c9v2(c9v3))
      end
      c9v0 = v27
      c9v2 = 1
      c9v3 = v42
      c9v4 = true
      c9v0 = c9v0:AddTimer(c9v2, c9v3, c9v4)
      v38 = c9v0
      c9v0 = v27
      c9v2 = 1
      c9v3 = v44
      c9v4 = true
      c9v0 = c9v0:AddTimer(c9v2, c9v3, c9v4)
      v37 = c9v0
      c9v0 = _T.AddHudTracker
      c9v1 = "DefendControl"
      c9v2 = v0
      c9v2 = c9v2.HT_LABEL
      c9v3 = 0
      c9v4 = 5
      c9v0 = c9v0(c9v1, c9v2, c9v3, c9v4)
      v23 = c9v0
      c9v0 = v10
      c9v0 = c9v0.GetPriorityOffset
      c9v0 = c9v0()
      c9v1 = v10
      c9v1 = c9v1.GetSubObjIndents
      c9v1, c9v2 = c9v1()
      c9v3 = v23
      c9v3 = c9v3.SetSortPriority
      c9v4 = c9v0 + 6
      c9v5 = false
      c9v3(c9v4, c9v5)
      c9v3 = v23
      c9v3 = c9v3.SetOffset
      c9v4 = c9v1 + 120
      c9v5 = c9v2 - 50
      c9v6 = true
      c9v3(c9v4, c9v5, c9v6)
      c9v3 = v17
      c9v5 = "OnAgentRegistered"
      c9v6 = Symbol
      c9v7 = "DefendRegistration"
      c9v6 = c9v6(c9v7)
      c9v7 = true
      c9v3:Name__800c0049(c9v5, c9v6, c9v7)
      c9v3 = v10
      c9v3 = c9v3.SetObjTimer
      c9v5 = false
      c9v6 = true
      c9v7 = false
      c9v8 = nil
      c9v9 = nil
      c9v10 = nil
      c9v11 = "/Lotus/Language/EidolonPlains/DefendCaptureTimer"
      c9v3(c9v12, c9v5, c9v6, c9v7, c9v8, c9v9, c9v10, c9v11)
      c9v3 = v10
      c9v3 = c9v3.SetObjProgressBar
      c9v4 = "/Lotus/Language/EidolonPlains/DefendEnemyPresence"
      c9v5 = 100
      c9v6 = 100
      c9v7 = nil
      c9v8 = true
      c9v3(c9v4, c9v5, c9v6, c9v7, c9v8)
      c9v3 = v10
      c9v3 = c9v3.SetPrimaryObjText
      c9v4 = "/Lotus/Language/EidolonPlains/DefendArea"
      c9v5 = 5
      c9v3(c9v4, c9v5)
      do return end
    end
    c9v12 = v19
    c9v13 = 4
    __renovice_local_0 = c9v12
    if __renovice_local_0 == c9v13 then
      c9v0 = v37
      c9v12 = IsNull
      c9v12 = c9v12(c9v0)
      if not c9v12 then
        c9v12 = v27
        c9v1 = v37
        c9v12:RemoveTimer(c9v1)
      end
      c9v0 = v38
      c9v12 = IsNull
      c9v12 = c9v12(c9v0)
      if not c9v12 then
        c9v12 = v27
        c9v1 = v38
        c9v12:RemoveTimer(c9v1)
      end
      c9v12 = v27
      c9v1 = 10
      c9v2 = v45
      c9v3 = true
      c9v12:AddTimer(c9v1, c9v2, c9v3)
      c9v12 = v27
      c9v1 = 30
      c9v2 = v46
      c9v12:AddTimer(c9v1, c9v2)
      c9v12 = v3
      c9v12 = c9v12.PlayGlobalTransmission
      c9v0 = v18
      c9v1 = Symbol
      c9v2 = "ClearRemainingEnemies"
      c9v12(c9v0, c9v1(c9v2))
      c9v12 = v10
      c9v12 = c9v12.SetPrimaryObjText
      c9v0 = "/Lotus/Language/EidolonPlains/ClearRemaining"
      c9v1 = 2
      c9v12(c9v0, c9v1)
      c9v12 = v10
      c9v12 = c9v12.RemoveObjProgressBar
      c9v12()
      c9v12 = false
      v25 = c9v12
      c9v12 = _T.RemoveHudTracker
      c9v0 = v23
      c9v12(c9v0)
      c9v12 = v1
      c9v12 = c9v12.UnregisterEnemiesOutsideRadius
      c9v0 = v17
      c9v1 = v15
      c9v12(c9v0, c9v1)
    end
    do return end
  end
  v20 = function(c10v0)
    local c10v1, c10v2, c10v3, c10v4
    c10v1 = v19
    if c10v1 ~= c10v0 then
      v19 = c10v0
      c10v1 = v11
      c10v3 = v7
      c10v1:SetNetPersistentVar(c10v3, c10v0)
      c10v1 = v47
      c10v1()
      c10v1 = print
      c10v3 = "DynamicDefend.lua::SetModeState - New State: "
      c10v4 = v19
      c10v2 = c10v3 .. c10v4
      c10v1(c10v2)
      do return end
    end
    c10v1 = print
    c10v2 = "DynamicDefend.lua::SetModeState - trying to set mode to state we're already in"
    c10v1(c10v2)
    do return end
  end
  v48 = function(c11v0)
    local c11v1, c11v2, c11v3, c11v4, c11v5, c11v6, c11v7, c11v8
    c11v1 = gGameRules
    v11 = c11v1
    c11v1 = c11v0:Name__82555728()
    v17 = c11v1
    c11v1 = gRegion
    c11v1 = c11v1:GetNpcMgr()
    c11v1 = c11v1:GetAiDirector()
    v12 = c11v1
    while true do
      c11v1 = v12
      c11v1 = c11v1:Name__a76d4ecc()
      if c11v1 then break end
      c11v1 = Sleep
      c11v2 = 0
      c11v1(c11v2)
    end
    v13 = c11v0
    c11v1 = c11v0:GetPosition()
    v14 = c11v1
    c11v1 = c11v0:GetActivationRadius()
    v15 = c11v1
    c11v1 = c11v0:GetDeactivationRadius()
    v16 = c11v1
    c11v1 = c11v0:Name__0b41bc7d()
    c11v2 = c11v1:GetTransmissionSet()
    v18 = c11v2
    c11v2 = v12
    c11v4 = false
    c11v2:InterludeENTRANCE(c11v4)
    c11v2 = gRegion
    c11v4 = "OnPlayersChanged"
    c11v2:Name__f3e0f198(c11v4)
    c11v2 = gRegion
    c11v2 = c11v2:GetHumanPlayers()
    v34 = c11v2
    c11v2 = isCrewShipEncounter
    if not c11v2 then
      c11v2 = v1
      c11v2 = c11v2.CreateReinforcementMgr
      c11v3 = v12
      c11v2 = c11v2(c11v3, c11v0)
      v26 = c11v2
    end
    c11v2 = v4
    c11v2 = c11v2.CreateTimerMgr
    c11v2 = c11v2()
    v27 = c11v2
    c11v2 = gRegion
    c11v4 = v5
    c11v5 = v14
    c11v6 = ZERO_ROTATION
    c11v2 = c11v2:CreateEntity(c11v4, c11v5, c11v6, c11v0)
    v24 = c11v2
    c11v2 = v24
    c11v4 = v16
    c11v2:SetRadius(c11v4)
    c11v2 = v24
    c11v4 = Range
    c11v5 = v16
    c11v6 = 5000
    c11v2:SetDisplayRange(c11v4(c11v5, c11v6))
    c11v4 = "PlayersLeaving"
    c11v5 = Symbol
    c11v6 = "LeavingCB"
    c11v0:Name__b2f41e3d(c11v4, c11v5(c11v6))
    c11v4 = "PlayersReturning"
    c11v5 = Symbol
    c11v6 = "ReturningCB"
    c11v0:AgnosticTest(c11v4, c11v5(c11v6))
    c11v2 = v11
    c11v4 = v8
    c11v5 = 100
    c11v2 = c11v2:GetNetPersistentVar(c11v4, c11v5)
    v30 = c11v2
    c11v2 = v13
    c11v2 = c11v2:Name__68bb2263()
    c11v7 = 0
    c11v8 = c11v2
    if c11v8 == c11v7 then
      c11v2 = v13
      c11v4 = 1
      c11v2:Name__27934b63(c11v4)
      c11v2 = v20
      c11v3 = 1
      c11v2(c11v3)
    else
      c11v2 = v20
      c11v3 = v11
      c11v5 = v7
      c11v6 = 1
      c11v2(c11v3:GetNetPersistentVar(c11v5, c11v6))
    end
    c11v2 = c11v0:GetEncounterStatus()
    c11v3 = 1
    if c11v2 == c11v3 then
      c11v4 = 2
      c11v0:SetEncounterStatus(c11v4)
    end
    do return end
  end
  v49 = function(c12v0)
    local c12v1, c12v2, c12v3, c12v4, c12v5, c12v6, c12v7, c12v8, c12v9, c12v10
    c12v1 = v48
    c12v1(c12v0)
    c12v1 = 0
    while true do
      c12v2 = c12v0:GetEncounterStatus()
      c12v3 = 4
      if not (c12v2 < c12v3) then break end
      c12v2 = Name__3b4b94b0
      c12v1 = c12v2()
      c12v2 = v19
      c12v9 = 1
      c12v10 = c12v2
      if c12v10 == c12v9 then
        repeat
          c12v2 = v17
          c12v2 = c12v2:GetEncounterStatus()
          c12v3 = 2
          if not (c12v3 <= c12v2) then
            c12v2 = v17
            c12v2 = c12v2:IsActive()
            if c12v2 then break end
          end
          c12v2 = v20
          c12v3 = 2
          c12v2(c12v3)
        until true
      else
        c12v2 = v19
        c12v9 = 2
        c12v10 = c12v2
        if c12v10 == c12v9 then
          c12v2 = v17
          c12v2 = c12v2:Name__48b3218f()
          c12v9 = 0
          c12v10 = c12v2
          if c12v10 == c12v9 then
            c12v2 = v20
            c12v3 = 3
            c12v2(c12v3)
          else
            c12v2 = v17
            c12v2 = c12v2:Name__48b3218f()
            c12v3 = 5
            if c12v2 <= c12v3 then
              c12v2 = v25
              if not c12v2 then
                c12v2 = v1
                c12v2 = c12v2.MarkRemainingEnemies
                c12v3 = v17
                c12v4 = v6
                c12v5 = v17
                c12v2(c12v3, c12v4, c12v5)
                c12v2 = true
                v25 = c12v2
              end
            end
          end
        else
          c12v2 = v19
          c12v9 = 3
          c12v10 = c12v2
          if c12v10 == c12v9 then
            c12v2 = v17
            c12v2 = c12v2:GetNumRegisteredAgents()
            c12v3 = 3
            v31 = c12v3
            c12v4 = v34
            c12v3 = #c12v4
            if c12v2 <= c12v3 then
              c12v3 = 0
              v31 = c12v3
            else
              c12v4 = v22
              c12v6 = v34
              c12v5 = #c12v6
              c12v3 = c12v4[c12v5]
              if c12v2 <= c12v3 then
                c12v3 = 1
                v31 = c12v3
              end
            end
            c12v2 = isCrewShipEncounter
            if not c12v2 then
              c12v2 = v26
              c12v2:Update(c12v1)
            end
            c12v2 = v40
            c12v2()
            c12v2 = ""
            c12v3 = v31
            c12v9 = 1
            c12v10 = c12v3
            if c12v10 == c12v9 then
              c12v2 = "/Lotus/Language/EidolonPlains/DefendCapRateLow"
            else
              c12v3 = v31
              c12v9 = 3
              c12v10 = c12v3
              if c12v10 == c12v9 then
                c12v2 = "/Lotus/Language/EidolonPlains/DefendCapRateHigh"
              else
                c12v2 = "/Lotus/Language/EidolonPlains/DefendCapRateNone"
              end
            end
            c12v3 = v10
            c12v3 = c12v3.SetObjProgressBar
            c12v4 = "/Lotus/Language/EidolonPlains/DefendEnemyPresence"
            c12v5 = v30
            c12v6 = 100
            c12v7 = nil
            c12v8 = true
            c12v3(c12v4, c12v5, c12v6, c12v7, c12v8)
            c12v2 = v36
            c12v3 = 0
            if c12v3 < c12v2 then
              c12v3 = v36
              c12v2 = c12v3 - c12v1
              v36 = c12v2
            else
              c12v2 = v23
              c12v2 = c12v2.SetLabel
              c12v3 = ""
              c12v2(c12v3)
              c12v2 = 0
              v35 = c12v2
            end
            c12v2 = v10
            c12v2 = c12v2.GetObjTime
            c12v2 = c12v2()
            c12v3 = 0
            if c12v2 <= c12v3 then
              c12v2 = v20
              c12v3 = 4
              c12v2(c12v3)
            else
              c12v2 = v30
              c12v3 = 0
              if c12v2 <= c12v3 then
                c12v4 = 5
                c12v0:SetEncounterStatus(c12v4)
              end
            end
            c12v2 = v30
            c12v3 = Name__7c50f03f
            if c12v2 <= c12v3 then
              c12v2 = v25
              if not c12v2 then
                c12v2 = v1
                c12v2 = c12v2.MarkRemainingEnemies
                c12v3 = v17
                c12v4 = v6
                c12v5 = v17
                c12v2(c12v3, c12v4, c12v5)
                c12v2 = true
                v25 = c12v2
              end
            else
              c12v2 = false
              v25 = c12v2
            end
          else
            c12v2 = v19
            c12v9 = 4
            c12v10 = c12v2
            if c12v10 == c12v9 then
              c12v2 = v17
              c12v2 = c12v2:Name__48b3218f()
              c12v9 = 0
              c12v10 = c12v2
              if c12v10 == c12v9 then
                c12v4 = 4
                c12v0:SetEncounterStatus(c12v4)
              else
                c12v2 = v17
                c12v2 = c12v2:Name__48b3218f()
                c12v3 = 5
                if c12v2 <= c12v3 then
                  c12v2 = v25
                  if not c12v2 then
                    c12v2 = v1
                    c12v2 = c12v2.MarkRemainingEnemies
                    c12v3 = v17
                    c12v4 = v6
                    c12v5 = v17
                    c12v2(c12v3, c12v4, c12v5)
                    c12v2 = true
                    v25 = c12v2
                  end
                end
              end
            end
          end
        end
      end
      c12v2 = v27
      c12v2:Update(c12v1)
      c12v2 = c12v0:ShouldShutDown()
      if c12v2 then
        c12v2 = v1
        c12v2 = c12v2.PlayersAbandonedObjective
        c12v2()
        c12v4 = 5
        c12v0:SetEncounterStatus(c12v4)
      end
      c12v2 = Sleep
      c12v3 = 0
      c12v2(c12v3)
    end
    c12v3 = v24
    c12v2 = IsNull
    c12v2 = c12v2(c12v3)
    if not c12v2 then
      c12v2 = v24
      c12v2:Destroy()
    end
    c12v2 = v1
    c12v2 = c12v2.CleanUpDynamicMission
    c12v3 = v17
    c12v2(c12v3)
    c12v2 = v12
    c12v4 = true
    c12v2:InterludeENTRANCE(c12v4)
    c12v2 = v10
    c12v2 = c12v2.RemoveBountyBonus
    c12v2()
    c12v2 = v10
    c12v2 = c12v2.ClearPrimaryObjText
    c12v2()
    c12v2 = v10
    c12v2 = c12v2.RemoveObjProgressBar
    c12v2()
    c12v2 = v10
    c12v2 = c12v2.RemoveObjTimer
    c12v2()
    c12v2 = _T.RemoveHudTracker
    c12v3 = v23
    c12v2(c12v3)
    c12v2 = v11
    c12v4 = v9
    c12v2:Name__a835d47c(c12v4)
    c12v2 = v11
    c12v4 = v8
    c12v2:Name__a835d47c(c12v4)
    c12v4 = Symbol
    c12v5 = "LeavingCB"
    c12v0:Name__8707bcec(c12v4(c12v5))
    c12v4 = Symbol
    c12v5 = "ReturningCB"
    c12v0:Name__9e4ee8e6(c12v4(c12v5))
    do return end
  end
  DefendStart = v49
  v49 = function()
    local c13v0
    c13v0 = gRegion
    c13v0 = c13v0:GetHumanPlayers()
    v34 = c13v0
    do return end
  end
  OnPlayersChanged = v49
  v49 = function(c14v0)
    local c14v1, c14v2, c14v3, c14v4, c14v5, c14v6, c14v7, c14v8, c14v9, c14v10, c14v11
    c14v1 = v19
    c14v10 = 3
    c14v11 = c14v1
    if c14v11 == c14v10 then
      c14v3 = v30
      c14v2 = c14v3 + 10
      c14v3 = 100
      c14v1 = math.min
      c14v1 = c14v1(c14v2, c14v3)
      v30 = c14v1
      c14v2 = v35
      c14v1 = c14v2 + 1
      v35 = c14v1
      c14v1 = 3
      v36 = c14v1
      c14v2 = v35
      c14v1 = c14v2 * 10
      c14v2 = v23
      c14v2 = c14v2.SetLabel
      c14v4 = "<p><font face=\"Noto Sans\" size=\"14\">"
      c14v7 = v23
      c14v7 = c14v7.Localize
      c14v8 = "/Lotus/Language/EidolonPlains/DefendControlTracker"
      c14v9 = { AMOUNT = nil }
      c14v9.AMOUNT = c14v1
      c14v5 = c14v7(c14v8, c14v9)
      c14v6 = "</font></p>"
      c14v3 = c14v4 .. c14v5 .. c14v6
      c14v2(c14v3)
    end
    do return end
  end
  OnKilled = v49
  v49 = function(c15v0)
    local c15v1, c15v2, c15v3, c15v4, c15v5, c15v6
    c15v1 = ObjectPortHandler
    c15v2 = c15v0:GetAvatar()
    c15v3 = "OnKilled"
    c15v1(c15v2, c15v3)
    c15v3 = v13
    c15v0:StormTarget(c15v3)
    c15v1 = v19
    c15v5 = 4
    c15v6 = c15v1
    if c15v6 == c15v5 then
      c15v1 = v17
      c15v1 = c15v1:GetNumRegisteredAgents()
      c15v2 = 5
      if c15v1 <= c15v2 then
        c15v1 = v1
        c15v1 = c15v1.MarkRemainingEnemies
        c15v2 = v17
        c15v3 = v6
        c15v4 = v17
        c15v1(c15v2, c15v3, c15v4)
      end
    end
    do return end
  end
  OnAgentRegistered = v49
  v49 = function()
    local c16v0, c16v1, c16v2
    c16v0 = v1
    c16v0 = c16v0.PlayersAbandoningObjective
    c16v1 = v13
    c16v2 = true
    c16v0(c16v1, c16v2)
    do return end
  end
  PlayersLeaving = v49
  v49 = function()
    local c17v0, c17v1, c17v2
    c17v0 = v1
    c17v0 = c17v0.PlayersAbandoningObjective
    c17v1 = v13
    c17v2 = false
    c17v0(c17v1, c17v2)
    do return end
  end
  PlayersReturning = v49
  do return end
