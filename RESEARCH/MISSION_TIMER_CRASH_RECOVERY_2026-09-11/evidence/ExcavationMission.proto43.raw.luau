function proto_43(v0)
  local v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37, v38, v39, v40, v41, v42, v43, v44, v45, v46, v47, v48, v49, v50, v51, v52, v53, v54, v55, v56, v57, v58, v59, v60, v61, v62, v63
  v44 = u32
  v44 = u30
  v39 = nil
  v44 = v39 % 2
  v45 = gRegion
  v45 = v45:GetHumanPlayers()
  v48 = 1
  v46 = #v45
  v47 = 1
  for __renovice_for_0_0 = v48, v46, v47 do
    v49 = u1
    v49 = v49.IsFirstTimeInNode
    v50 = v45[__renovice_for_0_0]
    v49 = v49(v50)
    if v49 then
      v44 = u36
      if v39 == 1 then
        v49 = Symbol
        v50 = "MissionExcavatorFirstPistolFound"
        v44 = v49(v50)
      end
    end
    v49 = u7
    v49 = v49.PlayLocalTransmission
    v50 = _T.MissionTransmissionSet
    v52 = v45[__renovice_for_0_0]
    v49(v50, v44, v52:GetAvatar())
  end
  v44 = true
  v45 = gGameRules
  v45 = v45:GetMission()
  v45 = v45.periodicMissionTag
  v46 = u1
  v46 = v46.ELITE_ALERT_PERIODIC_MISSION_TAG
  if v45 ~= v46 then
    v45 = gGameRules
    v45 = v45:GetMission()
    v45 = v45.periodicMissionTag
    v46 = u1
    v46 = v46.ELITE_ALERT_PERIODIC_MISSION_TAG_ALT
    do
      local __renovice_unused_condition_0 = v45 == v46
    end
  end
  v44 = u35
  v44()
  v44 = u36
  v46 = _T.lastSurvivalRewardStoreItem
  v45 = IsNull
  v45 = v45(v46)
  if not v45 then
    v45 = string.find
    v46 = _T.lastSurvivalRewardStoreItem
    v46 = v46:GetLocalizeTag()
    v46 = v46:c_str()
    v47 = "Rusty"
    v45 = v45(v46, v47)
    if v45 ~= nil then
      v45 = Symbol
      v46 = "MissionExcavatorPistolFound"
      v44 = v45(v46)
      v45 = gGameRules
      v47 = u37
      v48 = 1
      v45:SetNetPersistentVar(v47, v48)
    end
  end
  v45 = u30
  while true do
    v2 = gGameRules
    v1 = IsNull
    v1 = v1(v2)
    if not v1 then break end
    v1 = Sleep
    v2 = 0
    v1(v2)
  end
  v1 = gGameRules
  v3 = gLotusBaseGameRulesType
  v1 = v1:IsA(v3)
  if not v1 then
    do return end
  end
  v1 = gGameRules
  v1 = v1:GetMission()
  v2 = gRegion
  v2 = v2:GetNpcMgr()
  v2 = v2:GetAiDirector()
  v3 = v1.goalTag
  v4 = true
  v5 = Symbol
  v6 = "ShieldExcav"
  v5 = v5(v6)
  if v3 ~= v5 then
    v5 = Symbol
    v6 = "OldWorldSalvage"
    v5 = v5(v6)
    if v3 ~= v5 then
      v4 = false
    else
      v4 = true
    end
  end
  v5 = gPlayerProfileMgr
  v7 = 0
  v5 = v5:GetPlayerProfile(v7)
  v8 = 0
  v9 = shieldDrainExcavatorMat
  v0:SetOverrideMaterial(v8, v9)
  v8 = u0
  v6 = v0:GetAllAttachments(v8)
  v7 = ipairs
  v7, v8, v9 = v7(v6)
  for __renovice_for_1_0, __renovice_for_1_1 in v7, v8, v9 do
    v14 = 0
    v15 = shieldDrainPillarMat
    __renovice_for_1_1:SetOverrideMaterial(v14, v15)
  end
  v9 = shieldRingType
  v10 = EMPTY_SYMBOL
  v7 = v0:Attach(v9, v10)
  v10 = 0.6
  v11 = true
  v7:SetMeshScale(v10, v11)
  for __renovice_for_2_0, __renovice_for_2_1 in v7, v8, v9 do
  end
  v6 = u1
  v6 = v6.IsInGamePlay
  v6 = v6()
  if not v6 then
    do return end
  end
  v6 = u2
  v6()
  v6 = 20
  v7 = 0
  v8 = false
  v9 = 0
  v10 = u3
  v11 = 0
  v12 = false
  v14 = v1.goalId
  if v14 == "" then
    v13 = false
  else
    v13 = true
  end
  v14 = v1.levelOverride
  v15 = nil
  v16 = IsNull
  v16 = v16(v14)
  if (not v16 and v13) then
    local __renovice_state_0 = 20
    v15 = v14:GetFullName()
    v16 = string.find
    v18 = "Ice"
    v16 = v16(v15, v18)
    if not v16 then
      __renovice_state_0 = 22
    else
      __renovice_state_0 = 21
    end
    if __renovice_state_0 == 21 then
      v16 = 3
      u4 = v16
    end
    if __renovice_state_0 == 22 then
      v16 = string.find
      v18 = "Settlement"
      v16 = v16(v15, v18)
      if not v16 then
        __renovice_state_0 = 25
      else
        __renovice_state_0 = 23
      end
    end
    if __renovice_state_0 == 23 then
      v16 = string.find
      v18 = v1.goalTag
      v17 = tostring
      v17 = v17(v18)
      v18 = "Anniversary"
      v16 = v16(v17, v18)
      if v16 then
        __renovice_state_0 = 25
      else
        __renovice_state_0 = 24
      end
    end
    if __renovice_state_0 == 24 then
      v16 = 2
      u4 = v16
    end
    if __renovice_state_0 == 25 then
      v16 = 1
      u4 = v16
    end
  end
  v16 = gRegion
  v18 = cellItemPickup
  v16 = v16:Name__88f3b23b(v18)
  v17 = print
  v19 = "Flushed "
  v21 = " inactive power cells."
  v18 = v19 .. v16 .. v21
  v17(v18)
  v17 = gGameRules
  v19 = u5
  v20 = 2
  v17:SetNetPersistentVar(v19, v20)
  v17 = gGameRules
  v19 = u6
  v20 = 0
  v17 = v17:GetNetPersistentVar(v19, v20)
  if v17 == 0 then
    v18 = u7
    v18 = v18.PlayGlobalTransmission
    v19 = _T.MissionTransmissionSet
    v20 = Symbol
    v21 = "MissionExcavatorDeployedFirstTime"
    v18(v19, v20(v21))
  else
    v18 = u7
    v18 = v18.PlayGlobalTransmission
    v19 = _T.MissionTransmissionSet
    v20 = Symbol
    v21 = "MissionExcavatorDeployed"
    v18(v19, v20(v21))
  end
  v17 = v17 + 1
  v18 = gGameRules
  v20 = u6
  v18:SetNetPersistentVar(v20, v17)
  v18 = v2:GetMaxEnemyLevel()
  v20 = gRegion
  v20 = v20:Name__c988433c()
  v21 = Name__e7eb854d
  v22 = "Server.NumVirtualTestClients"
  v21 = v21(v22)
  v19 = v20 + v21
  v20 = sharedHealthPoolLevelPower
  if v19 == 1 then
    v20 = sharedHealthPoolLevelPowerSolo
  end
  v21 = gGameRules
  v23 = u8
  v24 = 0
  v21 = v21:GetNetPersistentVar(v23, v24)
  v22 = baseexcavatorHealth
  v23 = 0
  if v23 < v21 then
    v22 = v21
  end
  v25 = 1
  v27 = 0.025
  v28 = v18 ^ v20
  v26 = v27 * v28
  v24 = v25 + v26
  v23 = v22 * v24
  v25 = baseexcavatorShields
  v27 = 1
  v29 = 0.025
  v30 = v18 ^ v20
  v28 = v29 * v30
  v26 = v27 + v28
  v24 = v25 * v26
  v28 = true
  v0:SetMaxHealth(v23, v28)
  v25 = v0:IsKilled()
  if not v25 then
    v27 = v0:GetMaxHealth()
    v28 = false
    v0:SetHealth(v27, v28)
  end
  v25 = v0:DamageControl()
  v25:SetMaxShield(v24)
  v25 = v0:DamageControl()
  v27 = v0:DamageControl()
  v25:SetShield(v27:GetMaxShield())
  v25 = excavatorSpawnInvulnerabilityDuration
  v26 = 0
  if v26 < v25 then
    v25 = v0:DamageControl()
    v27 = excavatorSpawnInvulnerabilityDuration
    v28 = excavatorSpawnInvulnerabilityDuration
    v25:GiveTemporaryImmunity(v27, v28)
  end
  v25 = Sleep
  v26 = 0.1
  v25(v26)
  v0:SetLevel(v18)
  v25 = gRegion
  v27 = gLotusExcavationStateType
  v28 = v0:GetPosition()
  v29 = 5
  v25 = v25:FindNearest(v27, v28, v29)
  v26 = IsNull
  v26 = v26(v25)
  if v26 then
    v28 = excavatorAnim
    v29 = false
    v30 = 2
    v31 = 2
    v0:PlayAnimation(v28, v29, v30, v31)
    do return end
  end
  v2:SetObjective(v0)
  v2:Name__7fccb7d5(v0)
  v26 = print
  v28 = "SetObjective "
  v29 = v0:GetFullName()
  v27 = v28 .. v29
  v26(v27)
  v28 = excavatorAnim
  v29 = false
  v30 = 2
  v31 = 2
  v0:PlayAnimation(v28, v29, v30, v31)
  v28 = true
  v25:Enable(v28)
  v25:SetAvatar(v0)
  v25:SetInstanceNumber(v17)
  v28 = gParticleSysType
  v26 = v0:GetAllAttachments(v28)
  v29 = gSequencerType
  v27 = v0:GetAllAttachments(v29)
  v30 = pillarType
  v28 = v0:GetAttachment(v30)
  v29 = u9
  v33 = true
  v29(v28, v26, v27, v33)
  v29 = true
  v30 = false
  v31 = v0:DamageControl()
  v34 = excavatorMarkerTypes
  v33 = #v34
  v32 = v17 % v33
  if v32 == 0 then
    v33 = excavatorMarkerTypes
    v32 = #v33
  end
  v33 = gRegion
  v35 = u10
  v36 = v0:GetPosition()
  v37 = 0
  v38 = 5
  v33 = v33:FindFirstTaggedInRadius(v35, v36, v37, v38)
  v34 = IsNull
  v34 = v34(v33)
  if not v34 then
    v33:Disable()
  end
  v36 = excavatorMarkerTypes[v32]
  v37 = EMPTY_SYMBOL
  v38 = Vector
  v39 = 0
  v40 = 1.5
  v41 = 0
  v0:Attach(v36, v37, v38(v39, v40, v41))
  v34 = _T
  v35 = gGameRules
  v37 = u11
  v35 = v35:GetMissionTimeLeft(v37)
  v34.LastActivityTime = v35
  v35 = u12
  if v35 then
    v34 = gRegion
    v34 = v34:IsMaster()
    if v34 then
      v34 = u13
      v34 = v34.IsGameModeInProgress
      v34 = v34()
    end
  else
    v34 = gPromotedToHost
  end
  if v34 then
    v34 = v25:GetPower()
    if v34 ~= 0 then
      v6 = v34
      v35 = v25:GetTimer()
      v9 = v10 - v35
    end
  end
  v34 = Symbol
  v36 = "Excavator"
  v37 = math.random
  v37 = v37()
  v35 = v36 .. v37
  v34 = v34(v35)
  v35 = 0
  v36 = false
  v37 = false
  v39 = _T.ExcavatorHealthTransmissionState
  v38 = IsNull
  v38 = v38(v39)
  if v38 then
    v38 = _T
    v39 = {}
    v38.ExcavatorHealthTransmissionState = v39
  end
  v39 = _T.ExcavatorHealthTransmissionState
  v40 = v25:GetInstanceNumber()
  v41 = { heavyDamage = false, damaged = false }
  v38 = table.insert
  v38(v39, v40, v41)
  v38 = u15
  v38 = v38.CreateTimerMgr
  v38 = v38()
  u14 = v38
  v38 = u14
  v40 = 60
  v41 = u16
  v38:AddTimer(v40, v41)
  v38 = IsNull
  v38 = v38(v0)
  v38 = v0:IsKilled()
  v38 = IsNull
  v38 = v38(v25)
  v38 = gRegion
  v38 = v38:GetHumanPlayerAvatars()
  v39 = v0:GetPosition()
  v40 = u18
  v40 = v40.Round
  v40 = v40(v25:GetPower())
  v42 = v25:GetTimer()
  v41 = math.floor
  v41 = v41(v42)
  v42 = v31:GetShield()
  v43 = v31:GetMaxShield()
  v44 = ipairs
  v44, v45, v46 = v44(v38)
  for __renovice_for_3_0, __renovice_for_3_1 in v44, v45, v46 do
    v52 = gLotusVehicleAvatarType
    v50 = __renovice_for_3_1:IsA(v52)
    v50 = __renovice_for_3_1:IsHoverboard()
    v50 = __renovice_for_3_1:GetRider()
    v49 = __renovice_for_3_1:GetRider()
    v49 = __renovice_for_3_1
    v44 = v0:GetHealthPercentage()
    v46 = _T.ExcavatorHealthTransmissionState
    __renovice_for_3_0 = v25:GetInstanceNumber()
    v45 = v46[__renovice_for_3_0]
    v46 = 0.25
    v46 = v45.heavyDamage
    v46 = u7
    v46 = v46.PlayGlobalTransmission
    __renovice_for_3_0 = _T.MissionTransmissionSet
    __renovice_for_3_1 = Symbol
    v49 = "MissionExcavatorHeavyDamaged"
    v46(__renovice_for_3_0, __renovice_for_3_1(v49))
    v46 = true
    v45.heavyDamage = v46
    v46 = 0.75
    if v44 <= v46 then
      v46 = v45.damaged
      if not v46 then
        v46 = u7
        v46 = v46.PlayGlobalTransmission
        __renovice_for_3_0 = _T.MissionTransmissionSet
        __renovice_for_3_1 = Symbol
        v49 = "MissionExcavatorDamaged"
        v46(__renovice_for_3_0, __renovice_for_3_1(v49))
        v46 = true
        v45.damaged = v46
      end
    end
    if not v36 then
      v40 = 0.2
      if v40 < v35 then
        v40 = 0
        v41 = u17
        v40, v36 = v41(v38, v39, v34, v6, v9)
        v42 = v6 + v40
        v43 = u3
        v41 = math.min
        v6 = v41(v42, v43)
        v35 = 0
      else
        v40 = Name__3b4b94b0
        v40 = v40()
        v35 = v35 + v40
      end
      if v36 then
        v42 = shieldRingType
        v40 = v0:GetAttachment(v42)
        v41 = IsNull
        v41 = v41(v40)
        if not v41 then
          v40:Destroy()
        end
      end
    end
    v52 = cellItemType
    v50 = v49:HasItem(v52)
    if v50 then
      v51 = __renovice_for_3_1:DistanceToPoint(v39)
      v52 = 5
      if not (v51 < v52) then
        v50 = false
      else
        v50 = true
      end
      if v50 then
        v51 = __renovice_for_3_1:GetPlayer()
        v52 = v49:InventoryControl()
        v52 = v52:Name__4ee25a12()
        v53 = u18
        v53 = v53.Round
        v55 = 20 * v52
        v57 = u3
        v56 = v57 - v6
        v54 = math.min
        v54 = v54(v55, v56)
        v53 = v53(v54)
        v54 = gGameRules
        v57 = "/Lotus/Language/Game/GainedPower"
        v58 = ""
        v59 = 0
        v60 = 2
        v61 = true
        v62 = "AMOUNT"
        v63 = tostring
        v63 = v63(v53)
        v54:DisplayMessage(v51, v57, v58, v59, v60, v61, v62, v63)
        v6 = v6 + v53
        if (v41 < v6 and not v30) then
          v30 = true
          v54 = u7
          v54 = v54.PlayGlobalTransmission
          v55 = _T.MissionTransmissionSet
          v56 = Symbol
          v57 = "MissionExcavatorFull"
          v54(v55, v56(v57))
        end
        v56 = cellItemType
        v49:RemoveItem(v56)
        v56 = cellDeliverySound
        v57 = false
        __renovice_for_3_1:PlaySound(v56, v57)
        v54 = _T
        v55 = true
        v54.PlayerHasDeliveredCell = v55
        v54 = _T
        v55 = gGameRules
        v57 = u11
        v55 = v55:GetMissionTimeLeft(v57)
        v54.LastActivityTime = v55
        v54 = IsNull
        v54 = v54(v51)
        if not v54 then
          v54 = v51:GetStats()
          v55 = IsNull
          v55 = v55(v54)
          if not v55 then
            v54:Name__e6196dda()
          end
        end
        if v42 < v43 then
          v56 = shieldOverlayType
          v54 = v0:HasAttachment(v56)
          if not v54 then
            v56 = shieldOverlayType
            v57 = EMPTY_SYMBOL
            v0:Attach(v56, v57)
          end
        end
        v31:SetShield(v43)
        v56 = batteryBeamType
        v54 = __renovice_for_3_1:HasAttachment(v56)
        if not v54 then
          v54 = __renovice_for_3_1:DamageControl()
          v57 = 0
          v55 = v54:Name__b7c91969(v57)
          v58 = batteryBeamType
          __renovice_for_3_1:Attach(v58, v55)
        end
      end
    end
    v41 = _T.MissionDebug
    if v41 then
      v41 = _T.MissionDebug.FastDig
      if v41 then
        v10 = 20
      end
    end
    v41 = IsNull
    v41 = v41(v25)
    if not v41 then
      v25:SetPower(v6)
      v43 = v10 - v9
      v25:SetTimer(v43)
    end
    v41 = u12
    if v41 then
      v41 = gGameRules
      v43 = u19
      v41 = v41:GetNetPersistentVar(v43)
      if v41 == 1 then
        do return end
      end
    end
    v41 = u14
    v41:Update(v40)
    v41 = Sleep
    v42 = 0
    v41(v42)
    v40 = 0
    if (v6 <= v40 and v29) then
      v40 = u9
      v44 = false
      v40(v28, v26, v27, v44)
      v29 = false
      v37 = true
      v42 = nil
      v43 = false
      v44 = 2
      v45 = 2
      v0:PlayAnimation(v42, v43, v44, v45)
      if v4 then
        v40 = u7
        v40 = v40.PlayGlobalTransmission
        v41 = _T.MissionTransmissionSet
        v42 = Symbol
        v43 = "MissionExcavatorUnpoweredShield"
        v40(v41, v42(v43))
      else
        v40 = u7
        v40 = v40.PlayGlobalTransmission
        v41 = _T.MissionTransmissionSet
        v42 = Symbol
        v43 = "MissionExcavatorUnpowered"
        v40(v41, v42(v43))
      end
      v2:SetObjective(v0)
      v2:Name__7fccb7d5(v0)
    else
      v40 = 0
      if (v40 < v6 and not v29) then
        v40 = u9
        v44 = true
        v40(v28, v26, v27, v44)
        v29 = true
        v42 = excavatorAnim
        v43 = false
        v44 = 2
        v45 = 2
        v0:PlayAnimation(v42, v43, v44, v45)
      end
    end
    v40 = Name__3b4b94b0
    v40 = v40()
    v41 = 0
    if v41 < v6 then
      v9 = v9 + v40
    end
    v43 = v40 * 1
    v42 = v6 - v43
    v43 = 0
    v41 = math.max
    v6 = v41(v42, v43)
    v41 = IsNull
    v41 = v41(v5)
    if not v41 then
      v41 = v5:Settings()
      v41 = v41:EnableTutorialTransmissions()
      if v41 then
        v41 = 0
        if v6 <= v41 then
          if not v8 then
            v7 = v7 + v40
            v41 = 30
            if v41 <= v7 then
              v41 = _T.ShowImpactMessage
              if v41 then
                v41 = _T.PlayerHasDeliveredCell
                if not v41 then
                  v41 = _T.ShowImpactMessage
                  v42 = "/Lotus/Language/GameModes/ExcavatorOutOfPower"
                  v43 = 10
                  v41(v42, v43)
                end
              end
              v8 = true
            end
          end
        else
          v7 = 0
          v41 = _T.HintActive
          if v41 then
            v41 = _T.HideImpactMessage
            v41()
          end
        end
      end
    end
    v41 = v9 + 0.05
  end
  if not v1 then
    v12 = true
  end
  v38 = gGameRules
  v40 = u20
  v41 = 0
  v38 = v38:GetNetPersistentVar(v40, v41)
  v38 = v38 + 1
  v39 = gGameRules
  v41 = u20
  v39:SetNetPersistentVar(v41, v38)
  v39 = gGameRules
  v41 = u21
  v42 = 0
  v39 = v39:GetNetPersistentVar(v41, v42)
  if v12 then
    v11 = u22
    v40 = gGameRules
    v42 = u23
    v43 = 0
    v40 = v40:GetNetPersistentVar(v42, v43)
    v41 = gGameRules
    v43 = u24
    v41:SetNetPersistentVar(v43, v40)
    v39 = v39 + 1
    v41 = gGameRules
    v43 = u21
    v41:SetNetPersistentVar(v43, v39)
    if not v37 then
      v41 = gChallengeMgr
      v43 = Symbol
      v44 = "EXCAVATION_COMPLETED_WITHOUT_LOSING_POWER"
      v41:Name__ed305ebd(v43(v44))
    end
  else
    v40 = u18
    v40 = v40.Round
    v42 = u22
    v43 = v9 / v10
    v41 = v42 * v43
    v11 = v40(v41)
    v40 = u7
    v40 = v40.PlayGlobalTransmission
    v41 = _T.MissionTransmissionSet
    v42 = Symbol
    v43 = "MissionExcavatorDestroyed"
    v40(v41, v42(v43))
  end
  v40 = gRegion
  v40 = v40:GetHumanPlayerAvatars()
  v41 = ipairs
  v41, v42, v43 = v41(v40)
  for __renovice_for_4_0, __renovice_for_4_1 in v41, v42, v43 do
    v46 = u25
    v48 = beamType
    v46(__renovice_for_4_1, v48, v34)
  end
  for __renovice_for_5_0, __renovice_for_5_1 in v41, v42, v43 do
  end
  v42 = 1
  v40 = math.max
  v11 = v40(v11, v42)
  v40 = gGameRules
  v42 = u26
  v43 = 0
  v40 = v40:GetNetPersistentVar(v42, v43)
  v40 = v40 + v11
  v41 = gGameRules
  v43 = u26
  v41:SetNetPersistentVar(v43, v40)
  v41 = gGameRules
  v43 = u27
  v44 = 0
  v41 = v41:GetNetPersistentVar(v43, v44)
  v43 = u4
  v42 = v11 * v43
  v41 = v41 + v42
  v42 = gGameRules
  v44 = u27
  v42:SetNetPersistentVar(v44, v41)
  v42 = 500
  v43 = u28
  if not v43 then
    v43 = v1.maxWaveNum
  end
  v44 = 0
  if v44 < v43 then
    v44 = u22
    v42 = v43 * v44
  end
  v45 = _T.HasPlayedHalfwayTransmission
  v44 = IsNull
  v44 = v44(v45)
  if v44 then
    v44 = _T
    v45 = false
    v44.HasPlayedHalfwayTransmission = v45
  end
  v44 = v42 / 2
  if v44 < v41 then
    v44 = _T.HasPlayedHalfwayTransmission
    if not v44 then
      v44 = _T
      v45 = true
      v44.HasPlayedHalfwayTransmission = v45
      v44 = u7
      v44 = v44.PlayGlobalTransmission
      v45 = _T.MissionTransmissionSet
      v46 = Symbol
      v47 = "MissionHalfway"
      v44(v45, v46(v47))
    end
  end
  v44 = u29
  if v44 then
    v44 = _T
    v45 = true
    v44.extractionAvailable = v45
  else
    v44 = u30
    if v44 then
      v44 = false
      v45 = u31
      v45 = v45()
      if v45 then
        v46 = false
        if v43 <= v38 then
          v47 = 0
          if not (v47 < v39) then
            v46 = false
          else
            v46 = true
          end
        end
        v44 = v46
      else
        if not (v43 <= v38) then
          v44 = false
        else
          v44 = true
        end
      end
      _T.extractionAvailable = v44
    else
      v44 = u32
      if v44 then
        v44 = _T
        if not (v42 <= v40) then
          v45 = false
        else
          v45 = true
        end
        v44.extractionAvailable = v45
      else
        v44 = u33
        if v44 then
          v44 = _T
          v45 = false
          v46 = 200
          if v46 <= v41 then
            v46 = 0
            if not (v46 < v39) then
              v45 = false
            else
              v45 = true
            end
          end
          v44.extractionAvailable = v45
        else
          if v12 then
            v44 = _T
            v46 = true
            v47 = gGameRules
            v47 = v47:GetMission()
            v47 = v47.periodicMissionTag
            v48 = u1
            v48 = v48.ELITE_ALERT_PERIODIC_MISSION_TAG
            if v47 ~= v48 then
              v47 = gGameRules
              v47 = v47:GetMission()
              v47 = v47.periodicMissionTag
              v48 = u1
              v48 = v48.ELITE_ALERT_PERIODIC_MISSION_TAG_ALT
              if v47 ~= v48 then
                v46 = false
              else
                v46 = true
              end
            end
            v45 = not v46
            if not v45 then
              v46 = 1
              if not (v46 < v39) then
                v45 = false
              else
                v45 = true
              end
            end
            v44.extractionAvailable = v45
          end
        end
      end
    end
  end
  v44 = 0
  if v44 < v11 then
    v47 = u4
    v46 = v11 * v47
    v45 = v46 * 1
    v46 = 1
    v44 = math.max
    v44 = v44(v45, v46)
    v45 = u34
    v46 = u18
    v46 = v46.Ternary
    v47 = u30
    v48 = oldWorldSalvageResource
    v49 = cryoticResource
    v46 = v46(v47, v48, v49)
    v45(v46, v44)
    v45 = u18
    v45 = v45.Ternary
    v46 = u30
    v47 = "/Lotus/Language/Game/GainedOldWorldSalvage"
    v48 = "/Lotus/Language/Game/GainedCryotic"
    v45 = v45(v46, v47, v48)
    v46 = gRegion
    v46 = v46:GetHumanPlayerAvatars()
    v49 = 1
    v47 = #v46
    v48 = 1
    for __renovice_for_6_0 = v49, v47, v48 do
      v50 = gGameRules
      v52 = v46[__renovice_for_6_0]
      v52 = v52:GetPlayer()
      v54 = ""
      v55 = 0
      v56 = 2
      v57 = true
      v58 = "AMOUNT"
      v59 = tostring
      v59 = v59(v44)
      v50:DisplayMessage(v52, v45, v54, v55, v56, v57, v58, v59)
    end
  end
  if not v44 then
    v45 = u7
    v45 = v45.PlayGlobalTransmission
    v46 = _T.MissionTransmissionSet
    v45(v46, v44)
  end
  v44 = IsNull
  v44 = v44(v25)
  if not v44 then
    v46 = 0
    v25:SetPower(v46)
    v46 = 0
    v25:SetTimer(v46)
    v46 = false
    v25:Enable(v46)
  end
  v44 = IsNull
  v44 = v44(v0)
  if not v44 then
    v44 = gRegion
    v46 = destructionEffect
    v47 = v0:GetSimPosition()
    v48 = ZERO_ROTATION
    v44:CreateEntity(v46, v47, v48)
    v44 = Engine.DamageData
    v44 = v44()
    v47 = 0
    v48 = 1
    v44:SetDamagePct(v47, v48)
    v45 = 999999
    v44.baseAmount = v45
    v44:SetSource(v25)
    v0:DamageDD(v44)
    v0:Destroy()
  end
  do return end
end

