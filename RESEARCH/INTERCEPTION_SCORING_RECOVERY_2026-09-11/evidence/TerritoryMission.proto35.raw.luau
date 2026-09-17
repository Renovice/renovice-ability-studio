function proto_35()
  local v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31
  v15 = tutorialMode
  v17 = nil
  v20 = #v17
  local __renovice_state_0 = 5
  v20 = u31
  v20 = v20.GetObjTime
  v20 = v20()
  __renovice_state_0 = 0
  v20 = _T.gStalkerActive
  v20 = _T.gVorBossActive
  v20 = _T.gVoidTearActive
  __renovice_state_0 = _T.gActiveDropshipCount
  v20 = IsNull
  v20 = v20(__renovice_state_0)
  v20 = _T.gActiveDropshipCount
  __renovice_state_0 = 0
  v20 = u4
  v20 = #v17
  __renovice_state_0 = 0
  v21 = nil
  v22 = v17[v21]
  local __renovice_local_0 = IsNull
  __renovice_local_0 = __renovice_local_0(v22)
  __renovice_local_0 = table.remove
  __renovice_local_0(v17, v21)
  __renovice_local_0 = v22:GetAttachParent()
  local __renovice_local_1 = IsNull
  __renovice_local_1 = __renovice_local_1(__renovice_local_0)
  v24 = gAvatarType
  __renovice_local_1 = __renovice_local_0:IsA(v24)
  __renovice_local_1 = __renovice_local_0:IsKilled()
  __renovice_local_1 = IsNull
  __renovice_local_1 = __renovice_local_1(__renovice_local_0:GetAgent())
  v22:Destroy()
  __renovice_local_1 = table.remove
  __renovice_local_1(v17, v21)
  v20 = u4
  v20 = #v17
  v20 = u4
  v20 = #v17
  __renovice_state_0 = 5
  v18 = true
  v20 = u4
  v20 = u31
  v20 = v20.SetObjTimer
  __renovice_state_0 = roundEndTimer
  v21 = false
  v22 = true
  __renovice_local_0 = false
  __renovice_local_1 = 3
  v20(__renovice_state_0, v21, v22, __renovice_local_0, __renovice_local_1)
  v20 = u0
  v21 = u17
  v20 = v20:GetMissionTimeLeft(v21)
  __renovice_state_0 = u0
  v22 = u17
  __renovice_state_0:SetNetPersistentVar(v22, v20)
  v21 = _T.gStalkerActive
  v21 = _T.gVorBossActive
  v21 = _T.gVoidTearActive
  v22 = _T.gActiveDropshipCount
  v21 = IsNull
  v21 = v21(v22)
  v21 = _T.gActiveDropshipCount
  v22 = 0
  v21 = Sleep
  v22 = 1
  v21(v22)
  v21 = string.find
  __renovice_local_0 = gGameRules
  __renovice_local_0 = __renovice_local_0:GetMission()
  __renovice_local_0 = __renovice_local_0.activeMissionTag
  v22 = tostring
  v22 = v22(__renovice_local_0)
  __renovice_local_0 = "Void"
  v21 = v21(v22, __renovice_local_0)
  v22 = 10
  __renovice_local_0 = u33
  __renovice_local_0 = __renovice_local_0.IsTransmissionPlaying
  __renovice_local_0 = __renovice_local_0()
  __renovice_local_0 = DeltaTime
  __renovice_local_0 = __renovice_local_0()
  v22 = v22 - __renovice_local_0
  __renovice_local_0 = 0
  __renovice_local_0 = Sleep
  __renovice_local_1 = 0
  __renovice_local_0(__renovice_local_1)
  v20 = 0
  u21 = v20
  v20 = 0
  u22 = v20
  v20 = u0
  v21 = u19
  v22 = u21
  v20:SetNetPersistentVar(v21, v22)
  v20 = u0
  v21 = u20
  v22 = u22
  v20:SetNetPersistentVar(v21, v22)
  v20 = u0
  v21 = u18
  v22 = 0
  v20:SetNetPersistentVar(v21, v22)
  v20 = u0
  v20 = v20:MissionCompleted()
  if v20 then
    do return end
  end
  __renovice_local_0 = gGameRules
  v24 = u23
  v23 = v24 - 1
  v24 = false
  __renovice_local_0 = __renovice_local_0:OpenVoidProjectionRewardScreen(v23, v24)
  __renovice_local_1 = IsNull
  __renovice_local_1 = __renovice_local_1(__renovice_local_0)
  if not __renovice_local_1 then
    v20 = true
    while true do
      __renovice_local_1 = IsNull
      __renovice_local_1 = __renovice_local_1(__renovice_local_0)
      if __renovice_local_1 then break end
      __renovice_local_1 = Sleep
      v23 = 0
      __renovice_local_1(v23)
    end
    __renovice_local_1 = gGameRules
    __renovice_local_1:CloseVoidProjectionRewardScreen()
  end
  v20 = false
  v21 = _T.StalkerPlayer
  __renovice_state_0 = IsNull
  __renovice_state_0 = __renovice_state_0(v21)
  if not __renovice_state_0 then
    while true do
      v21 = _T.StalkerPlayer
      __renovice_state_0 = IsNull
      __renovice_state_0 = __renovice_state_0(v21)
      if __renovice_state_0 then break end
      __renovice_state_0 = Sleep
      v21 = 1
      __renovice_state_0(v21)
    end
    __renovice_state_0 = _T
    v21 = false
    __renovice_state_0.gStalkerActive = v21
  end
  v21 = u0
  v21 = v21:Name__bb87d4ff()
  __renovice_state_0 = not v21
  if not __renovice_state_0 then
    v21 = u2
    v21 = v21.PlayGlobalTransmission
    v22 = _T.MissionTransmissionSet
    __renovice_local_0 = Symbol
    __renovice_local_1 = "ClaimScreen"
    v21(v22, __renovice_local_0(__renovice_local_1))
    v21 = Sleep
    v22 = 10
    v21(v22)
  end
  v20 = Sleep
  __renovice_state_0 = 0
  v20(__renovice_state_0)
  v20 = u4
  v20 = u16
  v20 = v20.FindEnemyAvatars
  __renovice_state_0 = Vector
  __renovice_state_0 = __renovice_state_0()
  v21 = 0
  v20 = v20(__renovice_state_0, v21)
  __renovice_state_0 = ipairs
  __renovice_state_0, v21, v22 = __renovice_state_0(v20)
  for __renovice_for_0_0, __renovice_for_0_1 in __renovice_state_0, v21, v22 do
    v23 = __renovice_for_0_1:GetAgent()
    v24 = IsNull
    v24 = v24(v23)
    if v24 then
      continue
    end
    v26 = enemyObjectiveMarkerType
    v24 = __renovice_for_0_1:HasAttachment(v26)
    if v24 then
      continue
    end
    v19 = nil
    if not v19 then
      v24 = u2
      v24 = v24.PlayGlobalTransmission
      v25 = _T.MissionTransmissionSet
      v26 = Symbol
      v27 = "Exterminate"
      v24(v25, v26(v27))
      v24 = Engine.IsMobile
      v24 = v24()
      if v24 then
        v24 = u31
        v24 = v24.SetPrimaryObjText
        v25 = "/Lotus/Language/Objectives/KillRemainingEnemies"
        v26 = 2
        v24 = v24(v25, v26)
        v25 = v24.SetOffset
        v26 = 4
        v27 = nil
        v28 = true
        v25(v26, v27, v28)
      else
        v24 = u31
        v24 = v24.SetPrimaryObjText
        v25 = "/Lotus/Language/Objectives/KillRemainingEnemies"
        v26 = 2
        v24(v25, v26)
      end
      v19 = true
    end
    v26 = enemyObjectiveMarkerType
    v27 = EMPTY_SYMBOL
    v28 = Vector
    v29 = 0
    v30 = 1.5
    v31 = 0
    v24 = __renovice_for_0_1:Attach(v26, v27, v28(v29, v30, v31))
    v25 = table.insert
    v25(v17, v24)
    v25 = gRegion
    v27 = gTerritoryTriggerType
    v25 = v25:FindNearest(v27, __renovice_for_0_1:GetPosition())
    v28 = u32
    v30 = 5
    v23:AddOrder(v28, v25, v30)
  end
  for __renovice_for_1_0, __renovice_for_1_1 in __renovice_state_0, v21, v22 do
  end
  v21 = #v17
  v20 = 1
  __renovice_state_0 = -1
  v20 = Engine.IsMobile
  v20 = v20()
  if v20 then
    v20 = u31
    v20 = v20.SetPrimaryObjText
    __renovice_state_0 = "/Lotus/Language/Objectives/InterceptionMain"
    v21 = 0
    v20 = v20(__renovice_state_0, v21)
    __renovice_state_0 = v20.SetOffset
    v21 = 4
    v22 = nil
    __renovice_local_0 = true
    __renovice_state_0(v21, v22, __renovice_local_0)
  else
    v20 = u31
    v20 = v20.SetPrimaryObjText
    __renovice_state_0 = "/Lotus/Language/Objectives/InterceptionMain"
    v21 = 0
    v20(__renovice_state_0, v21)
  end
  __renovice_state_0 = u4
  if __renovice_state_0 then
    __renovice_state_0 = u7
    v22 = false
    __renovice_state_0:SetEnableAutoSpawns(v22)
    __renovice_state_0 = _T
    v21 = false
    __renovice_state_0.ShowTerritoryProgress = v21
    __renovice_state_0 = _T
    v21 = true
    __renovice_state_0.JadeShadowsStage4Done = v21
    v20 = true
  else
    v20 = false
  end
  if v20 then
    do return end
  end
  v20 = u23
  __renovice_state_0 = nil
  v21 = 1
  if v20 <= v21 then
    v7 = u26
  else
    v20 = v20 - 1
    v21 = u0
    v21 = v21:GetMission()
    v22 = Lerp
    __renovice_local_0 = 1.2
    __renovice_local_1 = 1.05
    v23 = v21.difficulty
    v22 = v22(__renovice_local_0, __renovice_local_1, v23)
    v23 = u26
    v24 = math.pow
    v24 = v24(v22, v20)
    __renovice_local_1 = v23 * v24
    __renovice_local_0 = math.ceil
    __renovice_state_0 = __renovice_local_0(__renovice_local_1)
    v7 = __renovice_state_0
  end
  __renovice_state_0 = u27
  v20 = v7 + __renovice_state_0
  __renovice_state_0 = u26
  v8 = v20 - __renovice_state_0
  v20 = u7
  v21 = math.floor
  v21 = v21(v7)
  v22 = math.floor
  v22 = v22(v8)
  v20:Name__5d811272(v21, v22)
  __renovice_state_0 = u23
  v21 = __renovice_state_0 - 1
  v20 = v21 / 2
  v6 = nil
  v6.tierBoost = v20
  v20 = print
  __renovice_state_0 = "Players won - rewarding items"
  v20(__renovice_state_0)
  v21 = gGameRules
  v21 = v21:GetMission()
  v21 = v21.maxWaveNum
  __renovice_local_0 = gGameRules
  __renovice_local_0 = __renovice_local_0:GetMission()
  v22 = true
  __renovice_local_1 = __renovice_local_0.alertId
  if __renovice_local_1 == "" then
    v22 = true
    __renovice_local_1 = __renovice_local_0.invasionId
    if __renovice_local_1 == "" then
      __renovice_local_1 = __renovice_local_0.syndicateTag
      v22 = __renovice_local_1:IsValid()
      if not v22 then
        v22 = true
        __renovice_local_1 = __renovice_local_0.goalId
        if __renovice_local_1 == "" then
          v22 = __renovice_local_0.nightmare
        end
      end
    end
  end
  if (v22 and v21 == 0) then
    v21 = 2
  end
  __renovice_state_0 = v21
  if __renovice_state_0 ~= 0 then
    v20 = false
  else
    v20 = true
  end
  v2 = nil
  if v2 then
    v22 = u2
    v22 = v22.PlayGlobalTransmission
    __renovice_local_0 = _T.MissionTransmissionSet
    __renovice_local_1 = Symbol
    v23 = "EventMissionRestate"
    v22(__renovice_local_0, __renovice_local_1(v23))
    v22 = u0
    __renovice_local_1 = nil
    v22:OpenMissionContinueDialog(__renovice_local_1)
  else
    v22 = u2
    v22 = v22.PlayGlobalTransmission
    __renovice_local_0 = _T.MissionTransmissionSet
    __renovice_local_1 = Symbol
    v23 = "NewRound"
    v22(__renovice_local_0, __renovice_local_1(v23))
    v22 = u0
    __renovice_local_1 = nil
    v22:OpenMissionContinueDialog(__renovice_local_1)
  end
  v22 = u0
  __renovice_local_1 = u18
  v23 = 1
  v22:SetNetPersistentVar(__renovice_local_1, v23)
  v22 = u7
  __renovice_local_1 = true
  v22:Name__ebc34d78(__renovice_local_1)
  while true do
    v22 = u0
    v22 = v22:Name__bb87d4ff()
    if v22 then break end
    v22 = Sleep
    __renovice_local_0 = 0
    v22(__renovice_local_0)
  end
  if v20 then
    __renovice_state_0 = u0
    __renovice_state_0 = __renovice_state_0:Name__dc5c723c()
    if __renovice_state_0 then
      __renovice_state_0 = u0
      v22 = u8
      __renovice_local_0 = 1
      __renovice_state_0:SetNetPersistentVar(v22, __renovice_local_0)
      __renovice_state_0 = u0
      v22 = false
      __renovice_state_0 = __renovice_state_0:OpenVoidProjectionSelectionScreen(v22)
      v21 = IsNull
      v21 = v21(__renovice_state_0)
      if not v21 then
        while true do
          v21 = IsNull
          v21 = v21(__renovice_state_0)
          if v21 then break end
          v21 = Sleep
          v22 = 0
          v21(v22)
        end
        v21 = u0
        __renovice_local_0 = u8
        __renovice_local_1 = 0
        v21:SetNetPersistentVar(__renovice_local_0, __renovice_local_1)
      end
    end
  end
  __renovice_state_0 = u7
  v22 = false
  __renovice_state_0:Name__ebc34d78(v22)
  v15 = tutorialMode
  if v15 then
    v15 = grabModuleForwarder
    v17 = "TriggerPort"
    v15:FirePort(v17)
    v15 = gRegion
    v15 = v15:GetLocalPlayerAvatar()
    v16 = IsNull
    v16 = v16(v15)
    if not v16 then
      v18 = grabModule
      v19 = true
      v15:GiveItem(v18, v19)
    end
    do return end
  end
  v15 = u22
  v16 = scoreGoal
  if v16 <= v15 then
    v16 = scoreReachedSound
    v15 = IsNull
    v15 = v15(v16)
    if not v15 then
      v15 = gRegion
      v17 = scoreReachedSound
      v18 = ZERO_VECTOR
      v19 = false
      v20 = 1
      __renovice_state_0 = nil
      v21 = nil
      v22 = nil
      __renovice_local_0 = true
      v15:PlaySound(v17, v18, v19, v20, __renovice_state_0, v21, v22, __renovice_local_0)
    end
    v15 = u2
    v15 = v15.PlayGlobalTransmission
    v16 = _T.MissionTransmissionSet
    v17 = Symbol
    v18 = "MissionFailed"
    v15(v16, v17(v18))
    v15 = Sleep
    v16 = 10
    v15(v16)
    v15 = u0
    v17 = 0
    v18 = 0
    v15:EndGame(v17, v18)
  end
  v9 = false
  v16 = scoreReachedSound
  v15 = IsNull
  v15 = v15(v16)
  if not v15 then
    v15 = gRegion
    v17 = scoreReachedSound
    v18 = ZERO_VECTOR
    v19 = false
    v20 = 1
    __renovice_state_0 = nil
    v21 = nil
    v22 = nil
    __renovice_local_0 = true
    v15:PlaySound(v17, v18, v19, v20, __renovice_state_0, v21, v22, __renovice_local_0)
  end
  v16 = "R"
  v18 = u23
  v17 = tostring
  v17 = v17(v18)
  v15 = v16 .. v17
  v16 = u2
  v16 = v16.PlayConditionalTransmission
  v17 = _T.MissionTransmissionSet
  v18 = Symbol
  v19 = "RoundComplete"
  v18 = v18(v19)
  v16(v17, v18, v15)
  v14 = nil
  if v14 then
    v17 = u23
    v16 = v17 + 1
    u23 = v16
  end
  v16 = u0
  v18 = u24
  v19 = u23
  v16:SetNetPersistentVar(v18, v19)
  v16 = u16
  v16 = v16.FindEnemyAvatars
  v17 = Vector
  v17 = v17()
  v18 = 0
  v16 = v16(v17, v18)
  v17 = {}
  v18 = _T.gVorBossActive
  if v18 then
    v18 = WeakResource
    v19 = "/Lotus/Types/Enemies/Grineer/Vip/VorTwo/VorTwoBossAvatar"
    v18 = v18(v19)
    v19 = gRegion
    v19 = v19:FindAll(v18)
    v20 = IsNull
    v20 = v20(v19)
    if not v20 then
      v20 = #v19
      __renovice_state_0 = 0
      if __renovice_state_0 < v20 then
        v21 = v19[1]
        v20 = table.insert
        v20(v16, v21)
      end
    end
  end
  v18 = #v16
  v19 = 0
  v18 = u2
  v18 = v18.PlayGlobalTransmission
  v19 = _T.MissionTransmissionSet
  v20 = Symbol
  __renovice_state_0 = "Exterminate"
  v18(v19, v20(__renovice_state_0))
  v18 = Engine.IsMobile
  v18 = v18()
  if v18 then
    v18 = u31
    v18 = v18.SetPrimaryObjText
    v19 = "/Lotus/Language/Objectives/KillRemainingEnemies"
    v20 = 2
    v18 = v18(v19, v20)
    v19 = v18.SetOffset
    v20 = 4
    __renovice_state_0 = nil
    v21 = true
    v19(v20, __renovice_state_0, v21)
  else
    v18 = u31
    v18 = v18.SetPrimaryObjText
    v19 = "/Lotus/Language/Objectives/KillRemainingEnemies"
    v20 = 2
    v18(v19, v20)
  end
  v18 = ipairs
  v18, v19, v20 = v18(v16)
  for __renovice_for_2_0, __renovice_for_2_1 in v18, v19, v20 do
    v22 = __renovice_for_2_1:GetAgent()
    __renovice_local_0 = IsNull
    __renovice_local_0 = __renovice_local_0(v22)
    if __renovice_local_0 then
      continue
    end
    v23 = enemyObjectiveMarkerType
    __renovice_local_0 = __renovice_for_2_1:HasAttachment(v23)
    if __renovice_local_0 then
      continue
    end
    v23 = enemyObjectiveMarkerType
    v24 = EMPTY_SYMBOL
    v25 = Vector
    v26 = 0
    v27 = 1.5
    v28 = 0
    __renovice_local_0 = __renovice_for_2_1:Attach(v23, v24, v25(v26, v27, v28))
    __renovice_local_1 = table.insert
    __renovice_local_1(v17, __renovice_local_0)
    __renovice_local_1 = gRegion
    v24 = gTerritoryTriggerType
    __renovice_local_1 = __renovice_local_1:FindNearest(v24, __renovice_for_2_1:GetPosition())
    v25 = u32
    v27 = 5
    v22:AddOrder(v25, __renovice_local_1, v27)
  end
  for __renovice_for_3_0, __renovice_for_3_1 in v18, v19, v20 do
  end
  v18 = false
  v20 = #v16
  __renovice_state_0 = 0
  do
    local __renovice_unused_condition_0 = __renovice_state_0 < v20
  end
  __renovice_state_0 = gGameRules
  __renovice_state_0 = __renovice_state_0:GetMission()
  __renovice_state_0 = __renovice_state_0.maxWaveNum
  v22 = gGameRules
  v22 = v22:GetMission()
  v21 = true
  __renovice_local_0 = v22.alertId
  if __renovice_local_0 == "" then
    v21 = true
    __renovice_local_0 = v22.invasionId
    if __renovice_local_0 == "" then
      __renovice_local_0 = v22.syndicateTag
      v21 = __renovice_local_0:IsValid()
      if not v21 then
        v21 = true
        __renovice_local_0 = v22.goalId
        if __renovice_local_0 == "" then
          v21 = v22.nightmare
        end
      end
    end
  end
  if (v21 and __renovice_state_0 == 0) then
    __renovice_state_0 = 2
  end
  v20 = __renovice_state_0
  __renovice_state_0 = u23
  v21 = v20 / 2
  if v21 < __renovice_state_0 then
    __renovice_state_0 = u34
    if __renovice_state_0 == false then
      __renovice_state_0 = true
      u34 = __renovice_state_0
      __renovice_state_0 = u2
      __renovice_state_0 = __renovice_state_0.PlayGlobalTransmission
      v21 = _T.MissionTransmissionSet
      v22 = Symbol
      __renovice_local_0 = "MissionHalfway"
      __renovice_state_0(v21, v22(__renovice_local_0))
    end
  end
  __renovice_state_0 = u23
  if v20 < __renovice_state_0 then
    __renovice_state_0 = u3
    if __renovice_state_0 then
      __renovice_state_0 = u2
      __renovice_state_0 = __renovice_state_0.WaitForTransmissionsToComplete
      __renovice_state_0()
    end
    __renovice_state_0 = u2
    __renovice_state_0 = __renovice_state_0.PlayConditionalTransmission
    v21 = _T.MissionTransmissionSet
    v22 = Symbol
    __renovice_local_0 = "MissionCompleted"
    v22 = v22(__renovice_local_0)
    __renovice_state_0(v21, v22, v15)
    __renovice_state_0 = gGameRules
    __renovice_state_0 = __renovice_state_0:GetMission()
    __renovice_state_0 = __renovice_state_0.faction
    v21 = 6
    if __renovice_state_0 == v21 then
      __renovice_state_0 = u2
      __renovice_state_0 = __renovice_state_0.PlayGlobalTransmission
      v21 = _T.MissionTransmissionSet
      v22 = Symbol
      __renovice_local_0 = "MissionCompleted"
      __renovice_state_0(v21, v22(__renovice_local_0))
      __renovice_state_0 = u2
      __renovice_state_0 = __renovice_state_0.PlayGlobalTransmission
      v21 = _T.MissionTransmissionSet
      v22 = Symbol
      __renovice_local_0 = "MissionCompletedExtra"
      __renovice_state_0(v21, v22(__renovice_local_0))
      __renovice_state_0 = u2
      __renovice_state_0 = __renovice_state_0.WaitForTransmissionsToComplete
      __renovice_state_0()
    end
    __renovice_state_0 = Sleep
    v21 = 2
    __renovice_state_0(v21)
    __renovice_state_0 = u0
    __renovice_state_0:Name__7179def4()
    while true do
      __renovice_state_0 = Sleep
      v21 = 1000
      __renovice_state_0(v21)
    end
  end
  __renovice_state_0 = u0
  v22 = true
  __renovice_state_0:HideGameSession(v22)
  __renovice_state_0 = Sleep
  v21 = 4
  __renovice_state_0(v21)
  __renovice_state_0 = u2
  __renovice_state_0 = __renovice_state_0.PlayGlobalTransmission
  v21 = _T.MissionTransmissionSet
  v22 = Symbol
  __renovice_local_0 = "NewRound"
  __renovice_state_0(v21, v22(__renovice_local_0))
  v8 = 0
  local __renovice_local_2 = u11
  v9 = #__renovice_local_2
  v6 = v9 - 1
  v7 = 1
  for __renovice_for_4_0 = v8, v6, v7 do
    v9 = 0
    __renovice_local_2 = ipairs
    v10 = u11
    v11 = nil
    __renovice_local_2, v10, v11 = __renovice_local_2(v10)
    for __renovice_for_5_0, __renovice_for_5_1 in __renovice_local_2, v10, v11 do
      v14 = __renovice_for_5_1:GetLabel()
      if v14 ~= __renovice_for_4_0 then
        continue
      end
      v9 = v9 + 1
    end
    __renovice_local_2 = 1
    if not (__renovice_local_2 < v9) then
      continue
    end
    v5 = true
  end
  v6 = gPromotedToHost
  v9 = u11
  v8 = #v9
  v6 = 1
  v7 = -1
  for __renovice_for_6_0 = v8, v6, v7 do
    v9 = u11[__renovice_for_6_0]
    v9 = v9:GetObjectiveMarker()
    __renovice_local_2 = v9:IsEnabled()
    if __renovice_local_2 then
      continue
    end
    __renovice_local_2 = table.remove
    v10 = u11
    __renovice_local_2(v10, __renovice_for_6_0)
  end
  v0 = nil
  v6 = v0.levelOverride
  v5 = IsNull
  v5 = v5(v6)
  v5 = v0.levelOverride
  v5 = v5:GetFullName()
  v6 = string.find
  v7 = tostring
  v7 = v7(v5)
  v8 = "Protea"
  v6 = v6(v7, v8)
  v4 = true
  v4 = false
  u3 = v4
  v5 = u0
  v5 = v5:GetMission()
  v6 = IsNull
  v6 = v6(v5)
  v6 = v5.goalTag
  v7 = u5
  v7 = v7.QUEST_GOAL_TAG
  v4 = true
  v4 = false
  v8 = u11
  v7 = #v8
  v5 = 1
  v6 = -1
  for __renovice_for_7_0 = v7, v5, v6 do
    v8 = u11[__renovice_for_7_0]
    v8 = v8:GetObjectiveMarker()
    v9 = u11[__renovice_for_7_0]
    v9 = v9:GetTag()
    __renovice_local_2 = Symbol
    v10 = "ProteaQuestPoint"
    __renovice_local_2 = __renovice_local_2(v10)
    if v9 == __renovice_local_2 then
      continue
    end
    v9 = IsNull
    v9 = v9(v8)
    if not v9 then
      v8:Disable()
    end
    v9 = table.remove
    __renovice_local_2 = u11
    v9(__renovice_local_2, __renovice_for_7_0)
  end
  v0 = u0
  v0 = v0:GetMission()
  v1 = v0.location
  v3 = Symbol
  v4 = "EventNode2"
  v3 = v3(v4)
  if v1 ~= v3 then
    v2 = false
  else
    v2 = true
  end
  v4 = tutorialInitForwarder
  v3 = IsNull
  v3 = v3(v4)
  if not v3 then
    v3 = tutorialInitForwarder
    v5 = "TriggerPort"
    v3:FirePort(v5)
  end
  v3 = gRegion
  v5 = Symbol
  v6 = "TerritoryTileSetup"
  v3 = v3:FindTagged(v5(v6))
  v4 = ipairs
  v4, v5, v6 = v4(v3)
  for __renovice_for_8_0, __renovice_for_8_1 in v4, v5, v6 do
    v10 = "TriggerPort"
    __renovice_for_8_1:FirePort(v10)
  end
  v4 = _T
  v5 = false
  v4.gTerritorySwitchActivated = v5
  v4 = false
  u1 = v4
  v4 = u2
  v4 = v4.SetupMissionTransmissionSet
  v5 = transmissionSet
  v4(v5)
  v5 = IsNull
  v5 = v5(v0)
  u4 = v4
  v4 = u3
  if v4 then
    v5 = scoreRatePerSecond
    v4 = v5 * 4
    scoreRatePerSecond = v4
  end
  v4 = u4
  if v4 then
    v5 = scoreRatePerSecond
    v4 = v5 * 2.25
    u6 = v4
    v4 = u7
    v6 = true
    v4:SetLevelAlert(v6)
  end
  v4 = nil
  v5 = tutorialMode
  if v5 then
    v5 = u7
    v7 = true
    v5:SetEnableAutoSpawns(v7)
    v5 = u7
    v7 = 5
    v5:SetMaxAI(v7)
    v5 = u0
    v7 = Symbol
    v8 = "StopNormalTransmissions"
    v7 = v7(v8)
    v8 = 1
    v5:SetNetPersistentVar(v7, v8)
    v5 = gRegion
    v5 = v5:GetLocalPlayerAvatar()
    v6 = IsNull
    v6 = v6(v5)
    if not v6 then
      v4 = v5:GetPlayer()
      v8 = tutorialMissionIntro
      v9 = true
      v5:GiveItem(v8, v9)
      v6 = false
      while not v6 do
        v5 = v4:GetAvatar()
        v7 = IsNull
        v7 = v7(v5)
        if not v7 then
          v9 = tutorialInitForwarder
          v7 = v5:DistanceToEntity(v9)
          v8 = 30
          do
            local __renovice_unused_condition_1 = v7 < v8
          end
        end
        v7 = Sleep
        v8 = 0
        v7(v8)
      end
    end
  end
  v5 = isInSpace
  if not v5 then
    v5 = gPromotedToHost
    if v5 then
      v7 = gGameRules
      v7 = v7:GetMission()
      v7 = v7.maxWaveNum
      v9 = gGameRules
      v9 = v9:GetMission()
      v8 = true
      __renovice_local_2 = v9.alertId
      if __renovice_local_2 == "" then
        v8 = true
        __renovice_local_2 = v9.invasionId
        if __renovice_local_2 == "" then
          __renovice_local_2 = v9.syndicateTag
          v8 = __renovice_local_2:IsValid()
          if not v8 then
            v8 = true
            __renovice_local_2 = v9.goalId
            if __renovice_local_2 == "" then
              v8 = v9.nightmare
            end
          end
        end
      end
      if (v8 and v7 == 0) then
        v7 = 2
      end
      v6 = v7
      if v6 ~= 0 then
        v5 = false
      else
        v5 = true
      end
      if v5 then
        v5 = u0
        v7 = u8
        v5 = v5:GetNetPersistentVar(v7)
        if v5 == 1 then
          v5 = u0
          v7 = true
          v5 = v5:OpenVoidProjectionSelectionScreen(v7)
          v6 = IsNull
          v6 = v6(v5)
          if not v6 then
            while true do
              v6 = IsNull
              v6 = v6(v5)
              if v6 then break end
              v6 = Sleep
              v7 = 0
              v6(v7)
            end
          end
          v6 = u0
          v8 = u8
          v9 = 0
          v6:SetNetPersistentVar(v8, v9)
        end
      end
    end
  end
  v5 = u0
  v7 = u9
  v8 = scoreGoal
  v5:SetNetPersistentVar(v7, v8)
  v5 = u10
  v5()
  v5 = u3
  v5 = false
  v7 = u11
  v6 = #v7
  v7 = 4
  if not v6 then
    while true do
      v7 = u11
      v6 = #v7
      v7 = 4
      if not (v7 < v6) then break end
      v6 = table.remove
      v7 = u11
      v8 = 1
      v6(v7, v8)
    end
  end
  v5 = true
  v6 = ipairs
  v7 = u11
  v6, v7, v8 = v6(v7)
  for __renovice_for_9_0, __renovice_for_9_1 in v6, v7, v8 do
    if v5 then
      v10 = gPromotedToHost
      if not v10 then
        v12 = __renovice_for_9_0 - 1
        __renovice_for_9_1:SetLabel(v12)
      end
    end
    v10 = ObjectPortHandler
    v12 = "OnPlayerCaptured"
    v10(__renovice_for_9_1, v12)
    v10 = ObjectPortHandler
    v12 = "OnEnemyCaptured"
    v10(__renovice_for_9_1, v12)
    v10 = ObjectPortHandler
    v12 = "OnNeutralized"
    v10(__renovice_for_9_1, v12)
    v10 = ObjectPortHandler
    v12 = "OnTouched"
    v10(__renovice_for_9_1, v12)
    v10 = __renovice_for_9_1:GetState()
    v11 = 2
    if v10 == v11 then
      v11 = u12
      v10 = table.insert
      v10(v11, __renovice_for_9_1)
    else
      v10 = __renovice_for_9_1:GetState()
      v11 = 0
      if v10 == v11 then
        v11 = u13
        v10 = table.insert
        v10(v11, __renovice_for_9_1)
      else
        v11 = u14
        v10 = table.insert
        v10(v11, __renovice_for_9_1)
      end
    end
    v10 = tutorialMode
    if not v10 then
      v10 = gPromotedToHost
      if not v10 then
        v10 = __renovice_for_9_1:GetObjectiveMarker()
        v10:Enable()
        v11 = isInSpace
        if v11 then
          v13 = contextIcons[__renovice_for_9_0]
          v10:SetContextIcon(v13)
        end
      end
    end
    v10 = u7
    v10:Name__7fccb7d5(__renovice_for_9_1)
  end
  v6 = u7
  v8 = u11[1]
  v6:SetObjective(v8)
  v6 = u15
  v6(v2)
  v6 = u16
  v6 = v6.GetInfo
  v6 = v6()
  v7 = u0
  v9 = u17
  __renovice_local_2 = Symbol
  __renovice_local_2 = __renovice_local_2()
  v10 = 0
  v11 = false
  v12 = false
  v13 = true
  v7:SetMissionTimer(v9, __renovice_local_2, v10, v11, v12, v13)
  v7 = gPromotedToHost
  if not v7 then
    if v2 then
      v7 = u2
      v7 = v7.PlayGlobalTransmission
      v8 = _T.MissionTransmissionSet
      v9 = Symbol
      __renovice_local_2 = "EventMissionIntro"
      v7(v8, v9(__renovice_local_2))
    else
      v7 = tutorialMode
      if not v7 then
        v7 = u2
        v7 = v7.PlayGlobalTransmission
        v8 = _T.MissionTransmissionSet
        v9 = Symbol
        __renovice_local_2 = "MissionIntro"
        v7(v8, v9(__renovice_local_2))
        v7 = u2
        v7 = v7.PlayGlobalTransmission
        v8 = _T.MissionTransmissionSet
        v9 = Symbol
        __renovice_local_2 = "MissionIntroExtra"
        v7(v8, v9(__renovice_local_2))
      end
    end
  else
    v7 = u0
    v8 = gPromotedToHost
    if v8 then
      __renovice_local_2 = u18
      v8 = v7:GetNetPersistentVar(__renovice_local_2)
      if v8 ~= 0 then
        __renovice_local_2 = u19
        v10 = 0
        v7:SetNetPersistentVar(__renovice_local_2, v10)
        __renovice_local_2 = u20
        v10 = 0
        v7:SetNetPersistentVar(__renovice_local_2, v10)
        __renovice_local_2 = u18
        v10 = 0
        v7:SetNetPersistentVar(__renovice_local_2, v10)
      end
    end
    v7 = u0
    v9 = u17
    v7 = v7:GetNetPersistentVar(v9)
    v8 = u0
    __renovice_local_2 = u17
    v8:Name__bb656394(__renovice_local_2, v7)
    v8 = print
    __renovice_local_2 = "TerritoryMission: Host migration init timer restarted: "
    v11 = " seconds elapsed."
    v9 = __renovice_local_2 .. v7 .. v11
    v8(v9)
  end
  v7 = u0
  v9 = u19
  __renovice_local_2 = 0
  v7 = v7:GetNetPersistentVar(v9, __renovice_local_2)
  u21 = v7
  v7 = u0
  v9 = u20
  __renovice_local_2 = 0
  v7 = v7:GetNetPersistentVar(v9, __renovice_local_2)
  u22 = v7
  v7 = u0
  v9 = u24
  __renovice_local_2 = 1
  v7 = v7:GetNetPersistentVar(v9, __renovice_local_2)
  u23 = v7
  v8 = u23
  v9 = v8 - 1
  v7 = v9 / 2
  v6.tierBoost = v7
  v7 = u25
  v8 = u0
  __renovice_local_2 = u17
  v8 = v8:GetNetPersistentVar(__renovice_local_2)
  __renovice_local_2 = u21
  v10 = scoreGoal
  v9 = __renovice_local_2 / v10
  v7 = v7(v8, v9, v0)
  v6.leaderChance = v7
  v8 = u23
  v9 = nil
  __renovice_local_2 = 1
  if v8 <= __renovice_local_2 then
    v7 = u26
  else
    v8 = v8 - 1
    __renovice_local_2 = u0
    __renovice_local_2 = __renovice_local_2:GetMission()
    v10 = Lerp
    v11 = 1.2
    v12 = 1.05
    v13 = __renovice_local_2.difficulty
    v10 = v10(v11, v12, v13)
    v13 = u26
    v14 = math.pow
    v14 = v14(v10, v8)
    v12 = v13 * v14
    v11 = math.ceil
    v9 = v11(v12)
    v7 = v9
  end
  __renovice_local_2 = u27
  v9 = v7 + __renovice_local_2
  __renovice_local_2 = u26
  v8 = v9 - __renovice_local_2
  v9 = u7
  v10 = math.floor
  v10 = v10(v7)
  v11 = math.floor
  v11 = v11(v8)
  v9:Name__5d811272(v10, v11)
  v9 = tutorialMode
  for __renovice_for_10_0, __renovice_for_10_1 in v6, v7, v8 do
    __renovice_for_10_0 = gRegion
    __renovice_for_10_0 = __renovice_for_10_0:GetLocalPlayerAvatar()
    while true do
      __renovice_for_10_1 = IsNull
      __renovice_for_10_1 = __renovice_for_10_1(__renovice_for_10_0)
      if not __renovice_for_10_1 then break end
      __renovice_for_10_1 = Sleep
      v10 = 0
      __renovice_for_10_1(v10)
      __renovice_for_10_0 = v4:GetAvatar()
    end
    v11 = useConsole
    v12 = true
    __renovice_for_10_0:GiveItem(v11, v12)
    while true do
      __renovice_for_10_1 = _T.gTerritorySwitchActivated
      if __renovice_for_10_1 then break end
      __renovice_for_10_1 = Sleep
      v10 = 0
      __renovice_for_10_1(v10)
    end
    while true do
      __renovice_for_10_1 = IsNull
      __renovice_for_10_1 = __renovice_for_10_1(__renovice_for_10_0)
      if not __renovice_for_10_1 then break end
      __renovice_for_10_1 = Sleep
      v10 = 0
      __renovice_for_10_1(v10)
      __renovice_for_10_0 = v4:GetAvatar()
    end
    v11 = territoryStart
    v12 = true
    __renovice_for_10_0:GiveItem(v11, v12)
    __renovice_for_10_1 = ipairs
    v10 = u11
    __renovice_for_10_1, v10, v11 = __renovice_for_10_1(v10)
    for __renovice_for_11_0, __renovice_for_11_1 in __renovice_for_10_1, v10, v11 do
      v16 = pillarType
      v14 = __renovice_for_11_1:GetAttachment(v16)
      v17 = Lotus_Game.UNLIT_ATTEN
      v18 = 0
      v14:SetMaterialParam(v17, v18)
      v17 = Lotus_Game.TINT_COLOR
      v18 = 1
      v19 = 1
      v20 = 1
      __renovice_state_0 = 0
      v14:SetMaterialParam(v17, v18, v19, v20, __renovice_state_0)
      v17 = true
      v18 = true
      v14:SetVisibility(v17, v18)
      v15 = __renovice_for_11_1:GetObjectiveMarker()
      v15:Enable()
      v16 = 0
      while true do
        v17 = 1
        if not (v16 < v17) then break end
        v17 = Sleep
        v18 = 0
        v17(v18)
        v17 = DeltaTime
        v17 = v17()
        v16 = v16 + v17
        v19 = Lotus_Game.UNLIT_ATTEN
        v20 = Lerp
        __renovice_state_0 = 0
        v21 = 1
        v14:SetMaterialParam(v19, v20(__renovice_state_0, v21, v16))
      end
    end
    __renovice_for_10_1 = u7
    v11 = true
    __renovice_for_10_1:SetLevelAlert(v11)
    __renovice_for_10_1 = u7
    v11 = 0
    __renovice_for_10_1:Name__f2101814(v11)
    __renovice_for_10_1 = _T
    v10 = endOfTutorialMissionWav
    __renovice_for_10_1.EndOfMissionVoiceOverride = v10
  end
  v9 = true
  if not v9 then
    do return end
  end
  __renovice_local_2 = Sleep
  v10 = 0
  __renovice_local_2(v10)
  __renovice_local_2 = _T
  v10 = true
  __renovice_local_2.ShowTerritoryProgress = v10
  __renovice_local_2 = ipairs
  v10 = u11
  __renovice_local_2, v10, v11 = __renovice_local_2(v10)
  for __renovice_for_12_0, __renovice_for_12_1 in __renovice_local_2, v10, v11 do
    __renovice_for_12_1:Enable()
  end
  __renovice_local_2 = -1
  v10 = startupTimeout
  v11 = 0
  if v11 < v10 then
    __renovice_local_2 = startupTimeout
  end
  v10 = false
  v11 = false
  v12 = 0
  v14 = math.random
  v15 = 40
  v16 = 80
  v14 = v14(v15, v16)
  v13 = v14 * 0.01
  v14 = false
  v15 = u22
  v16 = scoreGoal
  v15 = u21
  v16 = scoreGoal
  v14 = true
  v15 = u0
  v15 = v15:IsPauseMenuShowing()
  v15 = u0
  v15 = v15:Name__0616c35d()
  v15 = Sleep
  v16 = 0
  v15(v16)
  v19 = v6.highPriorityObjective
  v18 = IsNull
  v18 = v18(v19)
  v19 = v6.nextPriorityObjective
  v18 = IsNull
  v18 = v18(v19)
  v18 = v6.IsObjectiveComplete
  v19 = v6.nextPriorityObjective
  v20 = {}
  v18 = v18(v19, v20)
  v18 = u0
  v20 = u30
  __renovice_state_0 = 1
  v18:SetNetPersistentVar(v20, __renovice_state_0)
  v18 = tutorialMode
  v20 = scoreRatePerSecond
  v19 = v16 * v20
  v20 = Name__3b4b94b0
  v20 = v20()
  v18 = v19 * v20
  v20 = u22
  v19 = v20 + v18
  u22 = v19
  v18 = nil
  v20 = u21
  __renovice_state_0 = scoreGoal
  v19 = v20 / __renovice_state_0
  v20 = 0.25
  v20 = vorTaunt
  v19 = IsNull
  v19 = v19(v20)
  v18 = vorTaunt
  v19 = nil
  vorTaunt = v19
  v18 = u0
  v20 = u19
  __renovice_state_0 = u21
  v18:SetNetPersistentVar(v20, __renovice_state_0)
  v18 = u0
  v20 = u20
  __renovice_state_0 = u22
  v18:SetNetPersistentVar(v20, __renovice_state_0)
  v18 = u0
  v20 = u17
  v18 = v18:GetMissionTimeLeft(v20)
  v19 = u0
  __renovice_state_0 = u17
  v19:SetNetPersistentVar(__renovice_state_0, v18)
  v20 = u21
  __renovice_state_0 = scoreGoal
  v19 = v20 / __renovice_state_0
  v20 = 0.75
  if v20 <= v19 then
    v20 = lotusEncourage
    v19 = IsNull
    v19 = v19(v20)
    if not v19 then
      v18 = lotusEncourage
      v19 = nil
      lotusEncourage = v19
    end
  end
  v18 = u4
  if v18 then
    v19 = u21
    v21 = u6
    __renovice_state_0 = v17 * v21
    v21 = Name__3b4b94b0
    v21 = v21()
    v20 = __renovice_state_0 * v21
    v18 = v19 + v20
    u21 = v18
  else
    v19 = u21
    v21 = scoreRatePerSecond
    __renovice_state_0 = v17 * v21
    v21 = Name__3b4b94b0
    v21 = v21()
    v20 = __renovice_state_0 * v21
    v18 = v19 + v20
    u21 = v18
  end
  v18 = nil
  v6.nextPriorityObjective = v18
  v18 = v6.FindObjective
  v19 = nil
  __renovice_state_0 = true
  v21 = true
  v18 = v18(v19, v17, __renovice_state_0, v21)
  v6.nextPriorityObjective = v18
  v19 = v6.nextPriorityObjective
  v18 = IsNull
  v18 = v18(v19)
  if v18 then
    v12 = 10
  else
    v18 = u1
    if v18 then
      v18 = print
      v20 = "Planning assault on "
      __renovice_state_0 = u29
      v21 = v6.nextPriorityObjective
      __renovice_state_0 = __renovice_state_0(v21)
      v19 = v20 .. __renovice_state_0
      v18(v19)
    end
    v18 = u7
    v20 = v6.nextPriorityObjective
    v18:Name__4a133811(v20)
  end
  v19 = IsNull
  v19 = v19(v18)
  if not v19 then
    while true do
      v19 = IsNull
      v19 = v19(v4:GetAvatar())
      if not v19 then break end
      v19 = Sleep
      v20 = 0
      v19(v20)
    end
    v19 = v4:GetAvatar()
    v21 = true
    v19:GiveItem(v18, v21)
  end
  v15 = Sleep
  v16 = 0
  v15(v16)
  v16 = u7
  v15 = IsNull
  v15 = v15(v16)
  if v15 then
    do return end
  end
  v15 = u7
  v15 = v15:GetLevelAlert()
  if not v15 then
    v15 = u7
    v15 = v15:Name__bd6074f0()
    if v15 then
      v15 = u7
      v17 = true
      v15:SetLevelAlert(v17)
    end
  end
  v16 = u21
  v17 = scoreGoal
  v15 = v16 / v17
  v16 = u0
  v18 = u17
  v16 = v16:GetNetPersistentVar(v18)
  v17 = u25
  v17 = v17(v16, v15, v0)
  v6.leaderChance = v17
  if (v13 ~= nil and v13 < v15) then
    v17 = true
    v6.spawnBoss = v17
    v13 = nil
  end
  if not v11 then
    v17 = tutorialMode
    if not v17 then
      v17 = 0.6
      if v17 < v15 then
        v17 = u0
        v19 = true
        v17:HideGameSession(v19)
        v11 = true
      end
    end
  end
  v17 = u28
  v17 = v17()
  v18 = u16
  v18 = v18.Update
  v18(v17, v15)
  v18 = Name__3b4b94b0
  v18 = v18()
  v12 = v12 - v18
  v18 = 0
  v15 = gRegion
  v15 = v15:GetNumHumanPlayers()
  v16 = 0
  v16 = ipairs
  v17 = u11
  v16, v17, v18 = v16(v17)
  for __renovice_for_13_0, __renovice_for_13_1 in v16, v17, v18 do
    __renovice_local_0 = numPlayersCaptureScale
    v25 = numPlayersCaptureScale
    v24 = #v25
    __renovice_local_1 = math.min
    __renovice_local_1 = __renovice_local_1(v15, v24)
    v22 = __renovice_local_0[__renovice_local_1]
    __renovice_for_13_1:SetCaptureScale(v22)
  end
  for __renovice_for_14_0, __renovice_for_14_1 in v16, v17, v18 do
  end
  v18 = 0
  v19 = 0
  v20 = u13
  v18 = #v20
  v20 = u12
  v19 = #v20
  v16 = v18
  v17 = v19
  v19 = u12
  v18 = #v19
  v19 = 0
  if v19 < v18 then
    v10 = true
  else
    if not v10 then
      v18 = 0
      if v18 < __renovice_local_2 then
        v18 = Name__3b4b94b0
        v18 = v18()
        __renovice_local_2 = __renovice_local_2 - v18
        v18 = 0
        if __renovice_local_2 <= v18 then
          v10 = true
        end
      end
    end
  end
  v15 = u0
  v17 = u30
  v18 = 0
  v15:SetNetPersistentVar(v17, v18)
  v15 = ipairs
  v16 = u11
  v15, v16, v17 = v15(v16)
  for __renovice_for_15_0, __renovice_for_15_1 in v15, v16, v17 do
    v20 = tutorialMode
    if not v20 then
      v21 = -1
      __renovice_for_15_1:SetCaptureProgress(v21)
    end
    __renovice_for_15_1:Disable()
  end
  v15 = u21
  v16 = scoreGoal
  do return end
end

