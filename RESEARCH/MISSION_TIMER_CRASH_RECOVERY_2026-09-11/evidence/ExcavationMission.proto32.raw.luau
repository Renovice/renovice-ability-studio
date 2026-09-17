function proto_32()
  local v0, v1, v2, v3, v4
  while true do
    v1 = gGameRules
    v0 = IsNull
    v0 = v0(v1)
    if not v0 then break end
    v0 = Sleep
    v1 = 0
    v0(v1)
  end
  repeat
    v0 = _T
    v1 = false
    v0.extractionAvailable = v1
    v0 = gGameRules
    v0 = v0:GetMission()
    v2 = v0.levelOverride
    v1 = IsNull
    v1 = v1(v2)
    if not v1 then
      v1 = v0.goalId
      if v1 ~= "" then break end
    end
    v1 = false
    u0 = v1
  until true
  v1 = string.find
  v3 = v0.activeMissionTag
  v2 = tostring
  v2 = v2(v3)
  v3 = "Void"
  v1 = v1(v2, v3)
  u1 = v1
  v2 = string.find
  v4 = v0.levelOverride
  v3 = tostring
  v3 = v3(v4:GetFullName())
  v4 = "Duviri"
  v2 = v2(v3, v4)
  if v2 == nil then
    v1 = false
  else
    v1 = true
  end
  local __renovice_state_0 = -1
  u2 = v1
  v1 = v0.alertId
  if v1 ~= "" then
    __renovice_state_0 = -1
  else
    __renovice_state_0 = 1
  end
  if __renovice_state_0 == 1 then
    v1 = v0.invasionId
    if v1 ~= "" then
      __renovice_state_0 = -1
    else
      __renovice_state_0 = 2
    end
  end
  if __renovice_state_0 == 2 then
    v1 = v0.syndicateTag
    v1 = v1:IsValid()
    if v1 then
      __renovice_state_0 = -1
    else
      __renovice_state_0 = 3
    end
  end
  if __renovice_state_0 == 3 then
    v1 = v0.sortieId
    if v1 ~= "" then
      __renovice_state_0 = -1
    else
      __renovice_state_0 = 4
    end
  end
  if __renovice_state_0 == 4 then
    v1 = v0.nightmare
    if v1 then
      __renovice_state_0 = -1
    else
      __renovice_state_0 = 5
    end
  end
  if __renovice_state_0 == 5 then
    v1 = v0.maxWaveNum
    v2 = 0
    if v2 < v1 then
      __renovice_state_0 = -1
    else
      __renovice_state_0 = 6
    end
  end
  if __renovice_state_0 == 6 then
    v1 = u2
    if not v1 then
      __renovice_state_0 = 7
    else
      __renovice_state_0 = -1
    end
  end
  if __renovice_state_0 ~= 7 then
    v1 = true
    u3 = v1
    v1 = 600
    u4 = v1
    v1 = 600
    u5 = v1
  end
  v1 = v0.goalTag
  v2 = Symbol
  v3 = "OldWorldSalvage"
  v2 = v2(v3)
  if v1 == v2 then
    v1 = v0.location
    v2 = u6
    if v1 == v2 then
      v1 = true
      u7 = v1
      v1 = 10
      u8 = v1
      v1 = 60
      u9 = v1
      do return end
    end
  end
  v1 = true
  v2 = gGameRules
  v2 = v2:GetMission()
  v2 = v2.periodicMissionTag
  v3 = u10
  v3 = v3.ELITE_ALERT_PERIODIC_MISSION_TAG
  if v2 ~= v3 then
    v2 = gGameRules
    v2 = v2:GetMission()
    v2 = v2.periodicMissionTag
    v3 = u10
    v3 = v3.ELITE_ALERT_PERIODIC_MISSION_TAG_ALT
    if v2 ~= v3 then
      v1 = false
    else
      v1 = true
    end
  end
  if v1 then
    v1 = 140
    u9 = v1
    do return end
  end
  v1 = u2
  if v1 then
    v1 = 3
    u11 = v1
  end
  do return end
end

