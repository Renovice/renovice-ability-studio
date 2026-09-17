  local v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37, v38, v39, v40, v41, v42, v43, v44, v45, v46, v47, v48, v49, v50, v51, v52, v53, v54, v55, v56, v57, v58, v59, v60, v61, v62, v63, v64, v65, v66, v67, v68, v69, v70, v71, v72
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
  v6 = require
  v7 = "Lotus.Scripts.Libs.ObjectiveText"
  v6 = v6(v7)
  v7 = require
  v8 = "Lotus.Scripts.Venus.NokkoColony.NokkoLib"
  v7 = v7(v8)
  v8 = Type
  v9 = "/Lotus/Types/Game/MarkerInfos/AreaMarkerDefend"
  v8 = v8(v9)
  v9 = Type
  v10 = "/Lotus/Types/Game/MarkerInfos/AreaKillMarker"
  v9 = v9(v10)
  v10 = Type
  v11 = "/Lotus/Types/Game/MarkerInfos/EnemyObjectiveMarkerInfo"
  v10 = v10(v11)
  v11 = Symbol
  v12 = "AreaDefenseProgress"
  v11 = v11(v12)
  v12 = Symbol
  v13 = "AreaDefenseTime"
  v12 = v12(v13)
  v13 = Symbol
  v14 = "AreaDefenseBonusCompleted"
  v13 = v13(v14)
  v14 = nil
  v15 = nil
  v16 = nil
  v17 = nil
  v18 = 0
  v19 = nil
  v20 = nil
  v21 = false
  v22 = false
  v23 = false
  v24 = false
  v25 = 0
  v26 = 0
  v27 = 0
  v28 = false
  v29 = { STARTED = 1, WAIT_FOR_CAMP_CLEARED = 2, WAIT_FOR_TIMER = 3, CLEAR_REMAINING = 4 }
  v31 = 5
  v32 = 6
  v33 = 6
  v34 = 7
  v30 = {v31, v32, v33, v34}
  v31 = Symbol
  v32 = "TENNO"
  v31 = v31(v32)
  v32 = 50
  v34 = 5
  v35 = 6
  v36 = 7
  v37 = 8
  v33 = {v34, v35, v36, v37}
  v35 = 15
  v36 = 17
  v37 = 20
  v38 = 25
  v34 = {v35, v36, v37, v38}
  v36 = 7
  v37 = 8
  v38 = 9
  v39 = 10
  v35 = {v36, v37, v38, v39}
  v37 = 15
  v38 = 17
  v39 = 20
  v40 = 25
  v36 = {v37, v38, v39, v40}
  v38 = 12
  v39 = 10
  v40 = 7
  v41 = 5
  v37 = {v38, v39, v40, v41}
  v39 = 7
  v40 = 8
  v41 = 9
  v42 = 10
  v38 = {v39, v40, v41, v42}
  v40 = 25
  v41 = 30
  v42 = 35
  v43 = 40
  v39 = {v40, v41, v42, v43}
  v41 = 9
  v42 = 10
  v43 = 11
  v44 = 12
  v40 = {v41, v42, v43, v44}
  v42 = 25
  v43 = 30
  v44 = 35
  v45 = 40
  v41 = {v42, v43, v44, v45}
  v43 = 10
  v44 = 9
  v45 = 6
  v46 = 5
  v42 = {v43, v44, v45, v46}
  v43 = nil
  v44 = nil
  v45 = false
  v46 = nil
  v47 = nil
  v48 = nil
  v49 = nil
  v50 = true
  v51 = 100
  v52 = 0
  v53 = {}
  v54 = 0
  v55 = 0
  v56 = nil
  v57 = nil
  v58 = nil
  v59 = nil
  v60 = 0
  v61 = false
  v62 = 0
  v63 = function()
    local c1v0, c1v1, c1v2, c1v3, c1v4, c1v5, c1v6
    c1v1 = 0
    c1v3 = v51
    c1v4 = v52
    c1v2 = c1v3 - c1v4
    c1v0 = math.max
    c1v0 = c1v0(c1v1, c1v2)
    v51 = c1v0
    c1v0 = v14
    c1v2 = v11
    c1v3 = v51
    c1v0:SetNetPersistentVar(c1v2, c1v3)
    c1v0 = v51
    c1v1 = 0
    if c1v1 < c1v0 then
      c1v0 = v25
      c1v1 = 0
      if c1v1 < c1v0 then
        c1v0 = v23
        if c1v0 then
          c1v0 = v6
          c1v0 = c1v0.PauseObjTimer
          c1v1 = false
          c1v0(c1v1)
          c1v0 = false
          v23 = c1v0
          c1v0 = false
          v21 = c1v0
        end
      end
    end
    c1v1 = gGameData
    c1v0 = IsNull
    c1v0 = c1v0(c1v1)
    if not c1v0 then
      c1v0 = gGameRules
      c1v2 = v13
      c1v3 = 1
      c1v0 = c1v0:GetNetPersistentVar(c1v2, c1v3)
      c1v5 = 0
      c1v6 = c1v0
      if c1v6 == c1v5 then
        c1v0 = false
        v50 = c1v0
      end
      c1v0 = v51
      c1v1 = Name__21cfe4f5
      if c1v1 < c1v0 then
        c1v0 = v50
        if c1v0 then
          c1v0 = _T
          c1v1 = true
          c1v0.QualifiedForBountyBonus = c1v1
          c1v0 = v6
          c1v0 = c1v0.SetBountyBonusAchieved
          c1v1 = "/Lotus/Language/EidolonPlains/DynamicDefendBonusObjective"
          c1v2 = { VALUE = nil }
          c1v3 = Name__21cfe4f5
          c1v2.VALUE = c1v3
          c1v3 = true
          c1v0(c1v1, c1v2, c1v3)
          c1v0 = gGameRules
          c1v2 = v13
          c1v3 = 1
          c1v0:SetNetPersistentVar(c1v2, c1v3)
          do return end
        end
      end
      c1v0 = false
      v50 = c1v0
      c1v0 = _T
      c1v1 = false
      c1v0.QualifiedForBountyBonus = c1v1
      c1v0 = v6
      c1v0 = c1v0.SetBountyBonusFailed
      c1v1 = "/Lotus/Language/EidolonPlains/DynamicDefendBonusObjective"
      c1v2 = { VALUE = nil }
      c1v3 = Name__21cfe4f5
      c1v2.VALUE = c1v3
      c1v3 = true
      c1v0(c1v1, c1v2, c1v3)
      c1v0 = gGameRules
      c1v2 = v13
      c1v3 = 0
      c1v0:SetNetPersistentVar(c1v2, c1v3)
    end
    do return end
  end
  v64 = function()
    local c2v0, c2v1, c2v2, c2v3, c2v4, c2v5
    c2v0 = v49
    c2v1 = v31
    c2v0 = c2v0:Name__7a86968a(c2v1)
    v25 = c2v0
    c2v4 = v49
    c2v4 = c2v4:GetNumAvatarsInside()
    c2v1 = v25
    c2v0 = c2v4 - c2v1
    c2v4 = 3
    v52 = c2v4
    c2v4 = Name__995796a0
    if c2v0 <= c2v4 then
      c2v4 = 0
      v52 = c2v4
    else
      c2v1 = v30
      c2v3 = v53
      c2v2 = #c2v3
      c2v4 = c2v1[c2v2]
      if c2v0 <= c2v4 then
        c2v4 = 1
        v52 = c2v4
      end
    end
    c2v4 = v25
    c2v5 = 0
    local __renovice_local_0 = c2v4
    if __renovice_local_0 == c2v5 then
      c2v4 = v52
      c2v5 = 0
      __renovice_local_0 = c2v4
      if __renovice_local_0 == c2v5 then
        c2v4 = 0.5
        v52 = c2v4
      end
    end
    do return end
  end
  v65 = function()
    local c3v0, c3v1, c3v2, c3v3
    c3v0 = v14
    c3v1 = v12
    c3v3 = v6
    c3v3 = c3v3.GetObjTime
    c3v3 = c3v3()
    c3v2 = math.ceil
    c3v2 = c3v2(c3v3)
    c3v0:SetNetPersistentVar(c3v1, c3v2)
    do return end
  end
  v66 = function()
    local c4v0, c4v1, c4v2, c4v3, c4v4, c4v5, c4v6, c4v7, c4v8, c4v9, c4v10, c4v11, c4v12, c4v13, c4v14, c4v15, c4v16, c4v17
    c4v0 = print
    c4v2 = "DynamicDefend - Num Registered Agents = "
    c4v3 = v19
    c4v3 = c4v3:GetNumRegisteredAgents()
    c4v1 = c4v2 .. c4v3
    c4v0(c4v1)
    c4v0 = v19
    c4v0 = c4v0:GetRegisteredAgents()
    c4v1 = ipairs
    c4v1, c4v2, c4v3 = c4v1(c4v0)
    for __renovice_for_0_0, __renovice_for_0_1 in c4v1, c4v2, c4v3 do
      c4v4 = __renovice_for_0_1:GetAvatar()
      c4v5 = IsNull
      c4v5 = c4v5(c4v4)
      if c4v5 then
        continue
      end
      c4v5 = c4v4:GetPosition()
      c4v6 = print
      c4v8 = c4v4:GetName()
      c4v9 = " - "
      c4v10 = c4v5.x
      c4v11 = " "
      c4v12 = c4v5.y
      c4v13 = " "
      c4v14 = c4v5.z
      c4v15 = " - Distance to hint: "
      c4v17 = v19
      c4v16 = c4v4:DistanceToEntity(c4v17)
      c4v7 = c4v8 .. c4v9 .. c4v10 .. c4v11 .. c4v12 .. c4v13 .. c4v14 .. c4v15 .. c4v16
      c4v6(c4v7)
      c4v6 = c4v4:IsOnNav()
      if c4v6 then
        continue
      end
      c4v6 = print
      c4v8 = c4v4:GetName()
      c4v9 = " is not on nav, teleporting to nav"
      c4v7 = c4v8 .. c4v9
      c4v6(c4v7)
      c4v6 = v14
      c4v6:TrackshipGS(c4v4)
    end
    do return end
  end
  v67 = function()
    local c5v0, c5v1, c5v2
    c5v0 = v16
    c5v0 = c5v0:GetEncounterStatus()
    c5v1 = 4
    if c5v0 < c5v1 then
      c5v0 = v16
      c5v2 = 4
      c5v0:SetEncounterStatus(c5v2)
    end
    do return end
  end
  v68 = function()
    local c6v0, c6v1, c6v2, c6v3, c6v4, c6v5, c6v6, c6v7, c6v8, c6v9, c6v10, c6v11, c6v12, c6v13
    local __renovice_local_0 = v48
    __renovice_local_0 = __renovice_local_0:GetModeState()
    c6v0 = 0
    v62 = c6v0
    c6v0 = v29
    c6v0 = c6v0.STARTED
    if __renovice_local_0 == c6v0 then
      c6v0 = v2
      c6v0 = c6v0.PlayGlobalTransmission
      c6v1 = v20
      c6v2 = Symbol
      c6v3 = "NokkoEncounter_Intro"
      c6v2 = c6v2(c6v3)
      c6v3 = true
      c6v0(c6v1, c6v2, c6v3)
      do return end
    end
    c6v0 = v29
    c6v0 = c6v0.WAIT_FOR_CAMP_CLEARED
    if __renovice_local_0 == c6v0 then
      c6v0 = v6
      c6v0 = c6v0.SetPrimaryObjText
      c6v1 = "/Lotus/Language/NokkoColony/AreaDefenseClearHostilesObj"
      c6v2 = 2
      c6v0(c6v1, c6v2)
      do return end
    end
    c6v0 = v29
    c6v0 = c6v0.WAIT_FOR_TIMER
    if __renovice_local_0 == c6v0 then
      c6v0 = v2
      c6v0 = c6v0.PlayGlobalTransmission
      c6v1 = v20
      c6v2 = Symbol
      c6v3 = "NokkoEncounter_WaveComplete"
      c6v0(c6v1, c6v2(c6v3))
      c6v1 = v44
      c6v0 = IsNull
      c6v0 = c6v0(c6v1)
      if not c6v0 then
        c6v0 = v44
        c6v0:Destroy()
      end
      c6v1 = nil
      c6v0 = IsNull
      c6v0 = c6v0(c6v1)
      if not c6v0 then
        c6v0 = nil
        c6v0:Destroy()
      end
      c6v0 = v5
      c6v0 = c6v0.CreateAreaMarker
      c6v1 = v8
      c6v2 = v59
      c6v3 = v32
      c6v0 = c6v0(c6v1, c6v2, c6v3)
      v44 = c6v0
      c6v1 = gGameData
      c6v0 = IsNull
      c6v0 = c6v0(c6v1)
      if not c6v0 then
        c6v0 = v6
        c6v0 = c6v0.AddBountyBonus
        c6v1 = "/Lotus/Language/EidolonPlains/DynamicDefendBonusObjective"
        c6v2 = { VALUE = nil }
        c6v3 = Name__21cfe4f5
        c6v2.VALUE = c6v3
        c6v3 = true
        c6v0(c6v1, c6v2, c6v3)
      end
      c6v0 = v14
      c6v2 = v12
      c6v3 = defendTime
      c6v0 = c6v0:GetNetPersistentVar(c6v2, c6v3)
      c6v1 = v47
      c6v3 = 1
      c6v4 = v63
      c6v5 = true
      c6v1 = c6v1:AddTimer(c6v3, c6v4, c6v5)
      v57 = c6v1
      c6v1 = v47
      c6v3 = 1
      c6v4 = v65
      c6v5 = true
      c6v1 = c6v1:AddTimer(c6v3, c6v4, c6v5)
      v56 = c6v1
      c6v1 = _T.AddHudTracker
      c6v2 = "DefendControl"
      c6v3 = v0
      c6v3 = c6v3.HT_LABEL
      c6v4 = 0
      c6v5 = 5
      c6v1 = c6v1(c6v2, c6v3, c6v4, c6v5)
      v43 = c6v1
      c6v1 = v6
      c6v1 = c6v1.GetPriorityOffset
      c6v1 = c6v1()
      c6v2 = v6
      c6v2 = c6v2.GetSubObjIndents
      c6v2, c6v3 = c6v2()
      c6v4 = v43
      c6v4 = c6v4.SetSortPriority
      c6v5 = c6v1 + 6
      c6v6 = false
      c6v4(c6v5, c6v6)
      c6v4 = v43
      c6v4 = c6v4.SetOffset
      c6v5 = c6v2 + 120
      c6v6 = c6v3 - 50
      c6v7 = true
      c6v4(c6v5, c6v6, c6v7)
      c6v4 = v6
      c6v4 = c6v4.SetObjTimer
      c6v6 = false
      c6v7 = true
      c6v8 = false
      c6v9 = nil
      c6v10 = nil
      c6v11 = nil
      c6v12 = "/Lotus/Language/NokkoColony/AreaDefenseCaptureTimer"
      c6v13 = true
      c6v4(c6v0, c6v6, c6v7, c6v8, c6v9, c6v10, c6v11, c6v12, c6v13)
      c6v4 = v6
      c6v4 = c6v4.SetObjProgressBar
      c6v5 = "/Lotus/Language/NokkoColony/AreaDefenseControlLevel"
      c6v6 = 100
      c6v7 = 100
      c6v8 = nil
      c6v9 = true
      c6v10 = nil
      c6v11 = true
      c6v4(c6v5, c6v6, c6v7, c6v8, c6v9, c6v10, c6v11)
      c6v4 = v6
      c6v4 = c6v4.SetPrimaryObjText
      c6v5 = "/Lotus/Language/NokkoColony/AreaDefenseDefendAreaObj"
      c6v6 = 5
      c6v4(c6v5, c6v6)
      do return end
    end
    c6v0 = v29
    c6v0 = c6v0.CLEAR_REMAINING
    if __renovice_local_0 == c6v0 then
      c6v1 = nil
      c6v0 = IsNull
      c6v0 = c6v0(c6v1)
      if not c6v0 then
        c6v0 = nil
        c6v0:Destroy()
      end
      c6v1 = v56
      c6v0 = IsNull
      c6v0 = c6v0(c6v1)
      if not c6v0 then
        c6v0 = v47
        c6v2 = v56
        c6v0:RemoveTimer(c6v2)
      end
      c6v1 = v57
      c6v0 = IsNull
      c6v0 = c6v0(c6v1)
      if not c6v0 then
        c6v0 = v47
        c6v2 = v57
        c6v0:RemoveTimer(c6v2)
      end
      c6v0 = v47
      c6v2 = 10
      c6v3 = v66
      c6v4 = true
      c6v0:AddTimer(c6v2, c6v3, c6v4)
      c6v0 = v47
      c6v2 = 30
      c6v3 = v67
      c6v0:AddTimer(c6v2, c6v3)
      c6v0 = v2
      c6v0 = c6v0.PlayGlobalTransmission
      c6v1 = v20
      c6v2 = Symbol
      c6v3 = "NokkoEncounter_ClearRemaining"
      c6v0(c6v1, c6v2(c6v3))
      c6v0 = v6
      c6v0 = c6v0.SetPrimaryObjText
      c6v1 = "/Lotus/Language/NokkoColony/AreaDefenseClearRemainingObj"
      c6v2 = 2
      c6v0(c6v1, c6v2)
      c6v0 = v6
      c6v0 = c6v0.RemoveObjProgressBar
      c6v0()
      c6v0 = false
      v45 = c6v0
      c6v0 = _T.RemoveHudTracker
      c6v1 = v43
      c6v0(c6v1)
      c6v0 = v1
      c6v0 = c6v0.UnregisterEnemiesOutsideRadius
      c6v1 = v19
      c6v2 = v18
      c6v0(c6v1, c6v2)
    end
    do return end
  end
  v69 = function(c7v0)
    local c7v1, c7v2, c7v3, c7v4, c7v5, c7v6, c7v7, c7v8, c7v9, c7v10, c7v11, c7v12, c7v13, c7v14
    c7v1 = Name__28a98c92
    Name__28a98c92 = c7v1
    c7v1 = gGameRules
    v14 = c7v1
    c7v1 = c7v0:Name__82555728()
    v19 = c7v1
    c7v1 = gRegion
    c7v1 = c7v1:GetNpcMgr()
    c7v1 = c7v1:GetAiDirector()
    v15 = c7v1
    while true do
      c7v1 = v15
      c7v1 = c7v1:Name__a76d4ecc()
      if c7v1 then break end
      c7v1 = Sleep
      c7v2 = 1
      c7v1(c7v2)
    end
    v16 = c7v0
    c7v1 = c7v0:GetPosition()
    v17 = c7v1
    c7v1 = c7v0:GetActivationRadius()
    v18 = c7v1
    c7v1 = c7v0:Name__0b41bc7d()
    c7v2 = c7v1:GetTransmissionSet()
    v20 = c7v2
    c7v2 = gRegion
    c7v4 = "OnPlayersChanged"
    c7v2:Name__f3e0f198(c7v4)
    c7v2 = gRegion
    c7v2 = c7v2:GetHumanPlayers()
    v53 = c7v2
    c7v2 = v14
    c7v4 = "OnDeath"
    c7v2:Name__05db1cbf(c7v4)
    c7v2 = v1
    c7v2 = c7v2.CreateReinforcementMgr
    c7v3 = v15
    c7v2 = c7v2(c7v3, c7v0)
    v46 = c7v2
    c7v2 = v46
    c7v4 = 100
    c7v2:SetActivationRadius(c7v4)
    c7v2 = v46
    c7v3 = v33
    c7v2.mMinNumAgents = c7v3
    c7v2 = v46
    c7v3 = v34
    c7v2.mMaxNumAgents = c7v3
    c7v2 = v46
    c7v4 = v37
    c7v6 = v53
    c7v5 = #c7v6
    c7v3 = c7v4[c7v5]
    c7v2.mReinforceDelay = c7v3
    c7v2 = gGameRules
    c7v2 = c7v2:GetMission()
    c7v2 = c7v2.tier
    c7v3 = 0
    if c7v3 < c7v2 then
      c7v2 = v46
      c7v3 = v38
      c7v2.mMinNumAgents = c7v3
      c7v2 = v46
      c7v3 = v39
      c7v2.mMaxNumAgents = c7v3
      c7v2 = v46
      c7v4 = v42
      c7v6 = v53
      c7v5 = #c7v6
      c7v3 = c7v4[c7v5]
      c7v2.mReinforceDelay = c7v3
    end
    c7v2 = v1
    c7v2 = c7v2.CreateModeMgr
    c7v3 = v68
    c7v4 = v16
    c7v6 = v12
    c7v7 = v11
    c7v8 = v13
    c7v5 = {c7v6, c7v7, c7v8}
    c7v2 = c7v2(c7v3, c7v4, c7v5)
    v48 = c7v2
    c7v2 = v3
    c7v2 = c7v2.CreateTimerMgr
    c7v2 = c7v2()
    v47 = c7v2
    c7v2 = v14
    c7v4 = v12
    c7v5 = defendTime
    c7v2 = c7v2:GetNetPersistentVar(c7v4, c7v5)
    c7v5 = defendTime
    c7v4 = c7v5 / 2
    c7v3 = c7v2 - c7v4
    v27 = c7v3
    c7v4 = defendTime
    c7v6 = defendTime
    c7v5 = c7v6 / 3
    c7v3 = c7v4 - c7v5
    v60 = c7v3
    c7v3 = v17
    v59 = c7v3
    c7v3 = v18
    v32 = c7v3
    c7v3 = v5
    c7v3 = c7v3.CreateAreaMarker
    c7v4 = v9
    c7v5 = v59
    c7v6 = v32
    c7v3 = c7v3(c7v4, c7v5, c7v6)
    v44 = c7v3
    c7v3 = gRegion
    c7v5 = defendTriggerType
    c7v6 = v59
    c7v7 = ZERO_ROTATION
    c7v3 = c7v3:CreateEntity(c7v5, c7v6, c7v7)
    v49 = c7v3
    c7v3 = v49
    c7v5 = v32
    c7v3:SetRadius(c7v5)
    c7v3 = gRegion
    c7v5 = Symbol
    c7v6 = "DefenseStartedSeq"
    c7v3 = c7v3:FindFirstTagged(c7v5(c7v6))
    v58 = c7v3
    c7v3 = v14
    c7v5 = v11
    c7v6 = 100
    c7v3 = c7v3:GetNetPersistentVar(c7v5, c7v6)
    v51 = c7v3
    c7v3 = v19
    c7v5 = "OnAgentRegistered"
    c7v6 = Symbol
    c7v7 = "DefendRegistration"
    c7v6 = c7v6(c7v7)
    c7v7 = true
    c7v3:Name__800c0049(c7v5, c7v6, c7v7)
    c7v3 = v19
    c7v3 = c7v3:GetRegisteredAgents()
    c7v4 = ipairs
    c7v4, c7v5, c7v6 = c7v4(c7v3)
    for __renovice_for_0_0, __renovice_for_0_1 in c7v4, c7v5, c7v6 do
      c7v11 = v16
      __renovice_for_0_1:StormTarget(c7v11)
    end
    c7v4 = gRegion
    c7v6 = gLotusNpcAvatarType
    c7v7 = v19
    c7v7 = c7v7:GetPosition()
    c7v8 = 0
    c7v9 = v19
    c7v4 = c7v4:FindAll(c7v6, c7v7, c7v8, c7v9:GetActivationRadius())
    c7v5 = ipairs
    c7v5, c7v6, c7v7 = c7v5(c7v4)
    for __renovice_for_1_0, __renovice_for_1_1 in c7v5, c7v6, c7v7 do
      c7v10 = __renovice_for_1_1:GetFaction()
      c7v11 = Symbol
      c7v12 = "Corpus"
      c7v11 = c7v11(c7v12)
      if c7v10 ~= c7v11 then
        continue
      end
      c7v10 = IsNull
      c7v10 = c7v10(__renovice_for_1_1:GetAgent())
      if c7v10 then
        continue
      end
      c7v10 = v19
      c7v10:RegisterAgent(__renovice_for_1_1:GetAgent())
      c7v10 = __renovice_for_1_1:GetAgent()
      c7v12 = true
      c7v10:Name__43138b0d(c7v12)
    end
    c7v5 = v16
    c7v5 = c7v5:Name__68bb2263()
    c7v6 = v48
    c7v8 = v4
    c7v8 = c7v8.Ternary
    c7v13 = 0
    c7v14 = c7v5
    if c7v14 ~= c7v13 then
      c7v9 = false
    else
      c7v9 = true
    end
    c7v10 = v29
    c7v10 = c7v10.STARTED
    c7v6:SetModeState(c7v8(c7v9, c7v10, c7v5))
    c7v6 = c7v0:GetEncounterStatus()
    c7v7 = 1
    if c7v6 == c7v7 then
      c7v8 = 2
      c7v0:SetEncounterStatus(c7v8)
    end
    c7v6 = _T
    c7v7 = true
    c7v6.NokkoObjectiveEncounterActive = c7v7
    do return end
  end
  v70 = function()
    local c8v0, c8v1, c8v2, c8v3
    c8v0 = v1
    c8v0 = c8v0.CleanUpDynamicMission
    c8v1 = v19
    c8v0(c8v1)
    c8v0 = v14
    c8v2 = "OnDeath"
    c8v0:Name__be0d05e0(c8v2)
    c8v0 = v15
    c8v2 = true
    c8v0:InterludeENTRANCE(c8v2)
    c8v1 = gGameData
    c8v0 = IsNull
    c8v0 = c8v0(c8v1)
    if not c8v0 then
      c8v0 = v6
      c8v0 = c8v0.RemoveBountyBonus
      c8v0()
    end
    c8v0 = v6
    c8v0 = c8v0.ClearPrimaryObjText
    c8v0()
    c8v0 = v6
    c8v0 = c8v0.RemoveObjProgressBar
    c8v0()
    c8v0 = v6
    c8v0 = c8v0.RemoveObjTimer
    c8v0()
    c8v0 = _T.RemoveHudTracker
    c8v1 = v43
    c8v0(c8v1)
    c8v0 = v19
    c8v2 = Symbol
    c8v3 = "DefendRegistration"
    c8v0:Name__9a661e27(c8v2(c8v3))
    c8v0 = v48
    c8v0:ShutDown()
    do return end
  end
  v71 = function()
    local c9v0, c9v1, c9v2, c9v3, c9v4, c9v5, c9v6, c9v7, c9v8, c9v9, c9v10, c9v11, c9v12
    c9v0 = print
    c9v1 = "All Tenno friendly avatars left defense area. Pause Timer."
    c9v0(c9v1)
    c9v0 = v6
    c9v0 = c9v0.PauseObjTimer
    c9v1 = true
    c9v0(c9v1)
    c9v0 = true
    v23 = c9v0
    c9v0 = ipairs
    c9v1 = v53
    c9v0, c9v1, c9v2 = c9v0(c9v1)
    for __renovice_for_0_0, __renovice_for_0_1 in c9v0, c9v1, c9v2 do
      c9v5 = v14
      c9v8 = "/Lotus/Language/EidolonPlains/AbandoningReturn"
      c9v9 = ""
      c9v10 = 0
      c9v11 = 3
      c9v12 = false
      c9v5:DisplayMessage(__renovice_for_0_1, c9v8, c9v9, c9v10, c9v11, c9v12)
    end
    c9v0 = v21
    if not c9v0 then
      c9v0 = gRegion
      c9v2 = Name__d3d94481
      c9v3 = ZERO_VECTOR
      c9v4 = false
      c9v5 = 0
      c9v6 = nil
      c9v7 = nil
      c9v8 = nil
      c9v9 = true
      c9v0:PlaySound(c9v2, c9v3, c9v4, c9v5, c9v6, c9v7, c9v8, c9v9)
      c9v0 = true
      v21 = c9v0
    end
    do return end
  end
  v72 = function(c10v0)
    local c10v1, c10v2, c10v3, c10v4, c10v5, c10v6, c10v7, c10v8, c10v9, c10v10, c10v11, c10v12, c10v13, c10v14, c10v15
    c10v1 = v69
    c10v1(c10v0)
    while true do
      c10v1 = c10v0:GetEncounterStatus()
      c10v2 = 4
      if not (c10v1 < c10v2) then break end
      c10v1 = Name__3b4b94b0
      c10v1 = c10v1()
      c10v2 = v48
      c10v2 = c10v2:GetModeState()
      c10v4 = v62
      c10v3 = c10v4 + c10v1
      v62 = c10v3
      c10v3 = v29
      c10v3 = c10v3.STARTED
      if c10v2 == c10v3 then
        repeat
          c10v3 = v19
          c10v3 = c10v3:GetEncounterStatus()
          c10v4 = 2
          if not (c10v4 <= c10v3) then
            c10v3 = v19
            c10v3 = c10v3:IsActive()
            if c10v3 then break end
          end
          c10v3 = v48
          c10v5 = v29
          c10v5 = c10v5.WAIT_FOR_CAMP_CLEARED
          c10v3:SetModeState(c10v5)
        until true
      else
        c10v3 = v29
        c10v3 = c10v3.WAIT_FOR_CAMP_CLEARED
        if c10v2 == c10v3 then
          c10v13 = -1
          c10v3 = v19
          c10v3 = c10v3:Name__48b3218f()
          c10v14 = 0
          c10v15 = c10v3
          if c10v15 == c10v14 then
            c10v13 = -1
          else
            c10v13 = 1
          end
          c10v14 = 1
          c10v15 = c10v13
          if c10v15 == c10v14 then
            c10v3 = v62
            c10v4 = Name__36d88e97
            if not (c10v4 < c10v3) then
              c10v13 = 2
            else
              c10v13 = -1
            end
          end
          c10v14 = 2
          c10v15 = c10v13
          if c10v15 == c10v14 then
            c10v3 = v19
            c10v3 = c10v3:Name__48b3218f()
            c10v4 = 5
            if not (c10v3 <= c10v4) then
              c10v13 = 5
            else
              c10v13 = 3
            end
          end
          c10v14 = 3
          c10v15 = c10v13
          if c10v15 == c10v14 then
            c10v3 = v45
            if c10v3 then
              c10v13 = 5
            else
              c10v13 = 4
            end
          end
          c10v14 = 4
          c10v15 = c10v13
          if c10v15 == c10v14 then
            c10v3 = v1
            c10v3 = c10v3.MarkRemainingEnemies
            c10v4 = v19
            c10v5 = v10
            c10v6 = v19
            c10v3(c10v4, c10v5, c10v6)
            c10v3 = true
            v45 = c10v3
            c10v13 = 5
          end
          c10v14 = 5
          c10v15 = c10v13
          if c10v15 ~= c10v14 then
            c10v3 = gRegion
            c10v5 = Name__e9f7f778
            c10v6 = ZERO_VECTOR
            c10v7 = false
            c10v8 = 0
            c10v9 = nil
            c10v10 = nil
            c10v11 = nil
            c10v12 = true
            c10v3:PlaySound(c10v5, c10v6, c10v7, c10v8, c10v9, c10v10, c10v11, c10v12)
            c10v3 = v48
            c10v5 = v29
            c10v5 = c10v5.WAIT_FOR_TIMER
            c10v3:SetModeState(c10v5)
          end
        else
          c10v3 = v29
          c10v3 = c10v3.WAIT_FOR_TIMER
          if c10v2 == c10v3 then
            c10v4 = v60
            c10v3 = c10v4 - c10v1
            v60 = c10v3
            c10v3 = v60
            c10v4 = 0
            if c10v3 < c10v4 then
              c10v3 = v61
              c10v14 = false
              c10v15 = c10v3
              if c10v15 == c10v14 then
                c10v3 = v46
                c10v4 = v35
                c10v3.mMinNumAgents = c10v4
                c10v3 = v46
                c10v4 = v36
                c10v3.mMaxNumAgents = c10v4
                c10v3 = gGameRules
                c10v3 = c10v3:GetMission()
                c10v3 = c10v3.tier
                c10v4 = 0
                if c10v4 < c10v3 then
                  c10v3 = v46
                  c10v4 = v40
                  c10v3.mMinNumAgents = c10v4
                  c10v3 = v46
                  c10v4 = v41
                  c10v3.mMaxNumAgents = c10v4
                end
                c10v3 = true
                v61 = c10v3
              end
            end
            c10v3 = v49
            c10v5 = v31
            c10v3 = c10v3:Name__7a86968a(c10v5)
            v25 = c10v3
            c10v4 = v49
            c10v4 = c10v4:GetNumAvatarsInside()
            c10v5 = v25
            c10v3 = c10v4 - c10v5
            c10v4 = 3
            v52 = c10v4
            c10v4 = Name__995796a0
            if c10v3 <= c10v4 then
              c10v4 = 0
              v52 = c10v4
            else
              c10v5 = v30
              c10v7 = v53
              c10v6 = #c10v7
              c10v4 = c10v5[c10v6]
              if c10v3 <= c10v4 then
                c10v4 = 1
                v52 = c10v4
              end
            end
            c10v4 = v25
            c10v14 = 0
            c10v15 = c10v4
            if c10v15 == c10v14 then
              c10v4 = v52
              c10v14 = 0
              c10v15 = c10v4
              if c10v15 == c10v14 then
                c10v4 = 0.5
                v52 = c10v4
              end
            end
            c10v3 = v46
            c10v3:Update(c10v1)
            c10v3 = v6
            c10v3 = c10v3.SetObjProgressBar
            c10v4 = "/Lotus/Language/NokkoColony/AreaDefenseControlLevel"
            c10v5 = v51
            c10v6 = 100
            c10v7 = nil
            c10v8 = true
            c10v9 = nil
            c10v10 = true
            c10v3(c10v4, c10v5, c10v6, c10v7, c10v8, c10v9, c10v10)
            c10v3 = v55
            c10v4 = 0
            if c10v4 < c10v3 then
              c10v4 = v55
              c10v3 = c10v4 - c10v1
              v55 = c10v3
            else
              c10v3 = v43
              c10v3 = c10v3.SetLabel
              c10v4 = ""
              c10v3(c10v4)
              c10v3 = 0
              v54 = c10v3
            end
            c10v3 = v6
            c10v3 = c10v3.GetObjTime
            c10v3 = c10v3()
            c10v4 = 4
            if c10v3 <= c10v4 then
              c10v3 = v22
              c10v14 = false
              c10v15 = c10v3
              if c10v15 == c10v14 then
                c10v3 = v51
                c10v4 = Name__21cfe4f5
                if c10v3 < c10v4 then
                  c10v3 = gRegion
                  c10v5 = countdownSound
                  c10v6 = ZERO_VECTOR
                  c10v7 = false
                  c10v8 = 0
                  c10v9 = nil
                  c10v10 = nil
                  c10v11 = nil
                  c10v12 = true
                  c10v3:PlaySound(c10v5, c10v6, c10v7, c10v8, c10v9, c10v10, c10v11, c10v12)
                  c10v3 = true
                  v22 = c10v3
                end
              end
            end
            c10v3 = v6
            c10v3 = c10v3.GetObjTime
            c10v3 = c10v3()
            c10v4 = 0
            if c10v3 <= c10v4 then
              c10v3 = v48
              c10v5 = v29
              c10v5 = c10v5.CLEAR_REMAINING
              c10v3:SetModeState(c10v5)
              c10v3 = v51
              c10v4 = Name__21cfe4f5
              if c10v3 < c10v4 then
                c10v3 = gRegion
                c10v5 = Name__b1a3f685
                c10v6 = ZERO_VECTOR
                c10v7 = false
                c10v8 = 0
                c10v9 = nil
                c10v10 = nil
                c10v11 = nil
                c10v12 = true
                c10v3:PlaySound(c10v5, c10v6, c10v7, c10v8, c10v9, c10v10, c10v11, c10v12)
              else
                c10v3 = gRegion
                c10v5 = Name__9c99dd49
                c10v6 = ZERO_VECTOR
                c10v7 = false
                c10v8 = 0
                c10v9 = nil
                c10v10 = nil
                c10v11 = nil
                c10v12 = true
                c10v3:PlaySound(c10v5, c10v6, c10v7, c10v8, c10v9, c10v10, c10v11, c10v12)
              end
            else
              c10v3 = v51
              c10v4 = 0
              if c10v3 <= c10v4 then
                c10v3 = v23
                c10v14 = false
                c10v15 = c10v3
                if c10v15 == c10v14 then
                  c10v3 = v6
                  c10v3 = c10v3.PauseObjTimer
                  c10v4 = true
                  c10v3(c10v4)
                  c10v3 = true
                  v23 = c10v3
                  c10v3 = v21
                  if not c10v3 then
                    c10v3 = gRegion
                    c10v5 = Name__d3d94481
                    c10v6 = ZERO_VECTOR
                    c10v7 = false
                    c10v8 = 0
                    c10v9 = nil
                    c10v10 = nil
                    c10v11 = nil
                    c10v12 = true
                    c10v3:PlaySound(c10v5, c10v6, c10v7, c10v8, c10v9, c10v10, c10v11, c10v12)
                    c10v3 = true
                    v21 = c10v3
                  end
                end
              end
              c10v3 = v25
              c10v14 = 0
              c10v15 = c10v3
              if c10v15 == c10v14 then
                c10v3 = v24
                c10v14 = false
                c10v15 = c10v3
                if c10v15 == c10v14 then
                  c10v3 = true
                  v24 = c10v3
                  c10v3 = v47
                  c10v5 = v26
                  c10v6 = 5
                  c10v7 = v71
                  c10v8 = false
                  c10v3 = c10v3:AddOrReplaceTimer(c10v5, c10v6, c10v7, c10v8)
                  v26 = c10v3
                  c10v3 = print
                  c10v5 = "Add/Replace Player Leaving Timer: "
                  c10v6 = v26
                  c10v4 = c10v5 .. c10v6
                  c10v3(c10v4)
                end
              end
              c10v3 = v25
              c10v4 = 0
              if c10v4 < c10v3 then
                c10v3 = v24
                c10v14 = true
                c10v15 = c10v3
                if c10v15 == c10v14 then
                  c10v3 = false
                  v24 = c10v3
                  c10v3 = v47
                  c10v5 = v26
                  c10v3:RemoveTimer(c10v5)
                  c10v3 = print
                  c10v5 = "Remove Player Leaving Timer: "
                  c10v6 = v26
                  c10v4 = c10v5 .. c10v6
                  c10v3(c10v4)
                end
              end
              c10v3 = v6
              c10v3 = c10v3.GetObjTime
              c10v3 = c10v3()
              c10v4 = v27
              if c10v3 < c10v4 then
                c10v3 = v28
                c10v14 = false
                c10v15 = c10v3
                if c10v15 == c10v14 then
                  c10v3 = v2
                  c10v3 = c10v3.PlayGlobalTransmission
                  c10v4 = v20
                  c10v5 = Symbol
                  c10v6 = "NokkoEncounter_Halfway"
                  c10v3(c10v4, c10v5(c10v6))
                  c10v3 = true
                  v28 = c10v3
                end
              end
            end
          else
            c10v3 = v29
            c10v3 = c10v3.CLEAR_REMAINING
            if c10v2 == c10v3 then
              c10v3 = v19
              c10v3 = c10v3:Name__48b3218f()
              c10v14 = 0
              c10v15 = c10v3
              if c10v15 == c10v14 then
                c10v3 = _T.QualifiedForBountyBonus
                c10v14 = true
                c10v15 = c10v3
                if c10v15 == c10v14 then
                  c10v3 = v7
                  c10v3 = c10v3.IncrementBonusCompletionCount
                  c10v3()
                end
                c10v5 = 4
                c10v0:SetEncounterStatus(c10v5)
              else
                c10v3 = v19
                c10v3 = c10v3:Name__48b3218f()
                c10v4 = 5
                if c10v3 <= c10v4 then
                  c10v3 = v45
                  if not c10v3 then
                    c10v3 = v1
                    c10v3 = c10v3.MarkRemainingEnemies
                    c10v4 = v19
                    c10v5 = v10
                    c10v6 = v19
                    c10v3(c10v4, c10v5, c10v6)
                    c10v3 = true
                    v45 = c10v3
                  end
                end
              end
            end
          end
        end
      end
      c10v3 = v47
      c10v3:Update(c10v1)
      c10v3 = Sleep
      c10v4 = 0
      c10v3(c10v4)
    end
    c10v2 = v44
    c10v1 = IsNull
    c10v1 = c10v1(c10v2)
    if not c10v1 then
      c10v1 = v44
      c10v1:Destroy()
    end
    c10v2 = nil
    c10v1 = IsNull
    c10v1 = c10v1(c10v2)
    if not c10v1 then
      c10v1 = nil
      c10v1:Destroy()
    end
    c10v2 = v58
    c10v1 = IsNull
    c10v1 = c10v1(c10v2)
    if not c10v1 then
      c10v1 = v58
      c10v1:Destroy()
    end
    c10v2 = v49
    c10v1 = IsNull
    c10v1 = c10v1(c10v2)
    if not c10v1 then
      c10v1 = v49
      c10v1:Destroy()
    end
    c10v1 = v16
    c10v1 = c10v1:GetEncounterStatus()
    c10v2 = 4
    if c10v1 == c10v2 then
      c10v1 = _T.QualifiedForBountyBonus
      if c10v1 then
        c10v1 = v2
        c10v1 = c10v1.PlayGlobalTransmission
        c10v2 = v20
        c10v3 = Symbol
        c10v4 = "NokkoEncounter_Bonus"
        c10v1(c10v2, c10v3(c10v4))
      else
        c10v1 = v2
        c10v1 = c10v1.PlayGlobalTransmission
        c10v2 = v20
        c10v3 = Symbol
        c10v4 = "NokkoEncounter_Completed"
        c10v1(c10v2, c10v3(c10v4))
      end
    end
    c10v1 = Sleep
    c10v2 = 3
    c10v1(c10v2)
    c10v1 = v70
    c10v1()
    do return end
  end
  DefendStart = v72
  v72 = function()
    local c11v0, c11v1, c11v2, c11v3, c11v4
    c11v0 = gRegion
    c11v0 = c11v0:GetHumanPlayers()
    v53 = c11v0
    c11v0 = v46
    c11v2 = v37
    c11v4 = v53
    c11v3 = #c11v4
    c11v1 = c11v2[c11v3]
    c11v0.mReinforceDelay = c11v1
    c11v0 = gGameRules
    c11v0 = c11v0:GetMission()
    c11v0 = c11v0.tier
    c11v1 = 0
    if c11v1 < c11v0 then
      c11v0 = v46
      c11v2 = v42
      c11v4 = v53
      c11v3 = #c11v4
      c11v1 = c11v2[c11v3]
      c11v0.mReinforceDelay = c11v1
    end
    do return end
  end
  OnPlayersChanged = v72
  v72 = function(c12v0)
    local c12v1, c12v2, c12v3, c12v4, c12v5, c12v6, c12v7, c12v8, c12v9, c12v10, c12v11, c12v12, c12v13, c12v14
    c12v1 = c12v0:GetVictim()
    c12v2 = IsNull
    c12v2 = c12v2(c12v1)
    if c12v2 then
      do return end
    end
    c12v2 = c12v1:GetOriginalFaction()
    c12v3 = v48
    c12v3 = c12v3:GetModeState()
    c12v4 = v29
    c12v4 = c12v4.WAIT_FOR_TIMER
    if c12v3 == c12v4 then
      c12v12 = 3
      c12v3 = Symbol
      c12v4 = "Corpus"
      c12v3 = c12v3(c12v4)
      if c12v2 == c12v3 then
        c12v12 = 5
      else
        c12v12 = 4
      end
      c12v13 = 4
      c12v14 = c12v12
      if c12v14 == c12v13 then
        c12v3 = Symbol
        c12v4 = "Infested"
        c12v3 = c12v3(c12v4)
        if c12v2 ~= c12v3 then
        else
          c12v12 = 5
        end
      end
      c12v13 = 5
      c12v14 = c12v12
      if c12v14 == c12v13 then
        c12v3 = IsNull
        c12v3 = c12v3(c12v1:GetAgent())
        if c12v3 then
        else
          c12v12 = 6
        end
      end
      c12v13 = 6
      c12v14 = c12v12
      if c12v14 == c12v13 then
        c12v5 = v51
        c12v6 = Name__28a98c92
        c12v4 = c12v5 + c12v6
        c12v5 = 100
        c12v3 = math.min
        c12v3 = c12v3(c12v4, c12v5)
        v51 = c12v3
        c12v4 = v54
        c12v3 = c12v4 + 1
        v54 = c12v3
        c12v3 = 3
        v55 = c12v3
        c12v4 = v54
        c12v5 = Name__28a98c92
        c12v3 = c12v4 * c12v5
        c12v4 = v43
        c12v4 = c12v4.SetLabel
        c12v6 = "<p><font face=\"Noto Sans\" size=\"14\">"
        c12v9 = v43
        c12v9 = c12v9.Localize
        c12v10 = "/Lotus/Language/EidolonPlains/DefendControlTracker"
        c12v11 = { AMOUNT = nil }
        c12v11.AMOUNT = c12v3
        c12v7 = c12v9(c12v10, c12v11)
        c12v8 = "</font></p>"
        c12v5 = c12v6 .. c12v7 .. c12v8
        c12v4(c12v5)
      end
    end
    do return end
  end
  OnDeath = v72
  v72 = function(c13v0)
    local c13v1, c13v2, c13v3, c13v4, c13v5, c13v6
    c13v5 = 0
    c13v3 = v16
    c13v0:StormTarget(c13v3)
    c13v1 = v48
    c13v1 = c13v1:GetModeState()
    c13v2 = v29
    c13v2 = c13v2.CLEAR_REMAINING
    if c13v1 == c13v2 then
      c13v5 = 2
    else
      c13v5 = 1
    end
    c13v6 = 1
    local __renovice_local_0 = c13v5
    if __renovice_local_0 == c13v6 then
      c13v1 = v48
      c13v1 = c13v1:GetModeState()
      c13v2 = v29
      c13v2 = c13v2.WAIT_FOR_CAMP_CLEARED
      if c13v1 ~= c13v2 then
        c13v5 = 4
      else
        c13v5 = 2
      end
    end
    c13v6 = 2
    __renovice_local_0 = c13v5
    if __renovice_local_0 == c13v6 then
      c13v1 = v19
      c13v1 = c13v1:GetNumRegisteredAgents()
      c13v2 = 5
      if not (c13v1 <= c13v2) then
        c13v5 = 4
      else
        c13v5 = 3
      end
    end
    c13v6 = 3
    __renovice_local_0 = c13v5
    if __renovice_local_0 == c13v6 then
      c13v1 = v1
      c13v1 = c13v1.MarkRemainingEnemies
      c13v2 = v19
      c13v3 = v10
      c13v4 = v19
      c13v1(c13v2, c13v3, c13v4)
      c13v5 = 4
    end
    c13v6 = 4
    __renovice_local_0 = c13v5
    if __renovice_local_0 == c13v6 then
      do return end
    end
    do return end
  end
  OnAgentRegistered = v72
  v72 = function()
    local c14v0, c14v1, c14v2
    c14v0 = v1
    c14v0 = c14v0.PlayersAbandoningObjective
    c14v1 = v16
    c14v2 = true
    c14v0(c14v1, c14v2)
    do return end
  end
  PlayersLeaving = v72
  v72 = function()
    local c15v0, c15v1, c15v2
    c15v0 = v1
    c15v0 = c15v0.PlayersAbandoningObjective
    c15v1 = v16
    c15v2 = false
    c15v0(c15v1, c15v2)
    do return end
  end
  PlayersReturning = v72
  do return end
