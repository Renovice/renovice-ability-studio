  local v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30
  v0 = 0
  v1 = function(c1v0)
    local c1v1, c1v2, c1v3, c1v4, c1v5, c1v6
    c1v1 = pcall
    c1v1, c1v2 = c1v1(c1v0)
    if c1v1 then
      c1v3 = type
      c1v3 = c1v3(c1v2)
      c1v5 = "number"
      c1v6 = c1v3
      if c1v6 == c1v5 then
        c1v4 = true
        do return c1v2, c1v4 end
      end
    end
    c1v3 = nil
    c1v4 = false
    do return c1v3, c1v4 end
  end
  v2 = function(c2v0)
    local c2v1, c2v2, c2v3, c2v4, c2v5, c2v6
    c2v1 = pcall
    c2v1, c2v2 = c2v1(c2v0)
    if c2v1 then
      c2v3 = type
      c2v3 = c2v3(c2v2)
      c2v5 = "boolean"
      c2v6 = c2v3
      if c2v6 == c2v5 then
        c2v4 = true
        do return c2v2, c2v4 end
      end
    end
    c2v3 = nil
    c2v4 = false
    do return c2v3, c2v4 end
  end
  v3 = function(c3v0)
    local c3v1, c3v2, c3v3, c3v4, c3v5, c3v6, c3v7, c3v8
    c3v1 = pcall
    c3v1, c3v2 = c3v1(c3v0)
    if not c3v1 then
      c3v3 = nil
      c3v4 = false
      do return c3v3, c3v4 end
    end
    if c3v2 == nil then
      c3v3 = false
      c3v4 = true
      do return c3v3, c3v4 end
    end
    c3v3 = pcall
    c3v4 = IsNull
    c3v3, c3v4 = c3v3(c3v4, c3v2)
    if c3v3 then
      c3v5 = type
      c3v5 = c3v5(c3v4)
      c3v7 = "boolean"
      c3v8 = c3v5
      if c3v8 == c3v7 then
        c3v5 = not c3v4
        c3v6 = true
        do return c3v5, c3v6 end
      end
    end
    c3v5 = nil
    c3v6 = false
    do return c3v5, c3v6 end
  end
  v4 = function(c13v0, c13v1)
    local c13v2, c13v3, c13v4, c13v5, c13v6, c13v7, c13v8, c13v9, c13v10, c13v11, c13v12, c13v13, c13v14, c13v15, c13v16, c13v17, c13v18, c13v19, c13v20
    c13v2 = v1
    c13v3 = function()
      local c4v0
      c4v0 = c13v0
      do return c4v0:GetHealth() end
    end
    c13v2, c13v3 = c13v2(c13v3)
    c13v4 = v1
    c13v5 = function()
      local c5v0
      c5v0 = c13v0
      do return c5v0:GetMaxHealth() end
    end
    c13v4, c13v5 = c13v4(c13v5)
    c13v6 = v1
    c13v7 = function()
      local c6v0
      c6v0 = c13v1
      do return c6v0:GetShield() end
    end
    c13v6, c13v7 = c13v6(c13v7)
    c13v8 = v1
    c13v9 = function()
      local c7v0
      c7v0 = c13v1
      do return c7v0:GetMaxShield() end
    end
    c13v8, c13v9 = c13v8(c13v9)
    c13v10 = v1
    c13v11 = function()
      local c8v0
      c8v0 = c13v1
      do return c8v0:GetOverguardAmount() end
    end
    c13v10, c13v11 = c13v10(c13v11)
    c13v12 = v1
    c13v13 = function()
      local c9v0
      c9v0 = c13v1
      do return c9v0:GetArmourRating() end
    end
    c13v12, c13v13 = c13v12(c13v13)
    c13v14 = v2
    c13v15 = function()
      local c10v0
      c10v0 = c13v0
      do return c10v0:IsKilled() end
    end
    c13v14, c13v15 = c13v14(c13v15)
    c13v16 = v2
    c13v17 = function()
      local c11v0
      c11v0 = c13v0
      do return c11v0:IsDead() end
    end
    c13v16, c13v17 = c13v16(c13v17)
    c13v18 = v3
    c13v19 = function()
      local c12v0
      c12v0 = c13v0
      do return c12v0:GetRagdoll() end
    end
    c13v18, c13v19 = c13v18(c13v19)
    c13v20 = { health = nil, healthOk = nil, maxHealth = nil, maxHealthOk = nil, shield = nil, shieldOk = nil, maxShield = nil, maxShieldOk = nil, overguard = nil, overguardOk = nil, armour = nil, armourOk = nil, killed = nil, killedOk = nil, dead = nil, deadOk = nil, ragdollPresent = nil, ragdollOk = nil }
    c13v20.health = c13v2
    c13v20.healthOk = c13v3
    c13v20.maxHealth = c13v4
    c13v20.maxHealthOk = c13v5
    c13v20.shield = c13v6
    c13v20.shieldOk = c13v7
    c13v20.maxShield = c13v8
    c13v20.maxShieldOk = c13v9
    c13v20.overguard = c13v10
    c13v20.overguardOk = c13v11
    c13v20.armour = c13v12
    c13v20.armourOk = c13v13
    c13v20.killed = c13v14
    c13v20.killedOk = c13v15
    c13v20.dead = c13v16
    c13v20.deadOk = c13v17
    c13v20.ragdollPresent = c13v18
    c13v20.ragdollOk = c13v19
    do return c13v20 end
  end
  v5 = function(c15v0)
    local c15v1, c15v2, c15v3, c15v4, c15v5, c15v6, c15v7, c15v8, c15v9, c15v10, c15v11, c15v12, c15v13, c15v14, c15v15, c15v16
    c15v1 = {}
    c15v2 = 0
    c15v3 = 0
    c15v6 = 0
    c15v4 = 19
    c15v5 = 1
    for __renovice_for_0_0 = c15v6, c15v4, c15v5 do
      c15v7 = v1
      c15v8 = function()
        local c14v0, c14v1
        c14v0 = c15v0
        c14v1 = __renovice_for_0_0
        do return c14v0:Name__ff67e37d(c14v1) end
      end
      c15v7, c15v8 = c15v7(c15v8)
      if c15v8 then
        c15v2 = c15v2 + 1
        c15v15 = 0
        c15v16 = c15v7
        if c15v16 ~= c15v15 then
          c15v10 = #c15v1
          c15v9 = c15v10 + 1
          c15v14 = tostring
          c15v11 = c15v14(__renovice_for_0_0)
          c15v12 = ":"
          c15v13 = tostring
          c15v13 = c15v13(c15v7)
          c15v10 = c15v11 .. c15v12 .. c15v13
          c15v1[c15v9] = c15v10
        end
        continue
      end
      c15v3 = c15v3 + 1
    end
    c15v4 = "none"
    c15v5 = #c15v1
    c15v6 = 0
    if c15v6 < c15v5 then
      c15v5 = table.concat
      c15v7 = ","
      c15v4 = c15v5(c15v1, c15v7)
    end
    c15v6 = "range=0-19;ok="
    c15v12 = tostring
    c15v7 = c15v12(c15v2)
    c15v8 = ";failed="
    c15v12 = tostring
    c15v9 = c15v12(c15v3)
    c15v10 = ";nonzero=index:count="
    c15v5 = c15v6 .. c15v7 .. c15v8 .. c15v9 .. c15v10 .. c15v4
    do return c15v5 end
  end
  v6 = function(c17v0, c17v1)
    local c17v2, c17v3, c17v4, c17v5, c17v6, c17v7, c17v8, c17v9, c17v10, c17v11, c17v12, c17v13, c17v14, c17v15, c17v16, c17v17, c17v18, c17v19
    c17v2 = {}
    c17v3 = 0
    c17v4 = 0
    c17v7 = 0
    c17v5 = 19
    c17v6 = 1
    for __renovice_for_0_0 = c17v7, c17v5, c17v6 do
      c17v8 = v1
      c17v9 = function()
        local c16v0, c16v1
        c16v0 = c17v0
        c16v1 = __renovice_for_0_0
        do return c16v0:GetDamagePct(c16v1) end
      end
      c17v8, c17v9 = c17v8(c17v9)
      if c17v9 then
        c17v3 = c17v3 + 1
        c17v18 = 0
        c17v19 = c17v8
        if c17v19 ~= c17v18 then
          c17v10 = "unavailable"
          c17v11 = type
          c17v11 = c17v11(c17v1)
          c17v18 = "number"
          c17v19 = c17v11
          if c17v19 == c17v18 then
            c17v12 = c17v1 * c17v8
            c17v11 = tostring
            c17v10 = c17v11(c17v12)
          end
          c17v12 = #c17v2
          c17v11 = c17v12 + 1
          c17v17 = tostring
          c17v13 = c17v17(__renovice_for_0_0)
          c17v14 = ":"
          c17v17 = tostring
          c17v15 = c17v17(c17v8)
          c17v16 = ":"
          c17v12 = c17v13 .. c17v14 .. c17v15 .. c17v16 .. c17v10
          c17v2[c17v11] = c17v12
        end
        continue
      end
      c17v4 = c17v4 + 1
    end
    c17v5 = "none"
    c17v6 = #c17v2
    c17v7 = 0
    if c17v7 < c17v6 then
      c17v6 = table.concat
      c17v8 = ","
      c17v5 = c17v6(c17v2, c17v8)
    end
    c17v7 = "range=0-19;ok="
    c17v13 = tostring
    c17v8 = c17v13(c17v3)
    c17v9 = ";failed="
    c17v13 = tostring
    c17v10 = c17v13(c17v4)
    c17v11 = ";nonzero=index:fraction:requested="
    c17v6 = c17v7 .. c17v8 .. c17v9 .. c17v10 .. c17v11 .. c17v5
    do return c17v6 end
  end
  v7 = function(c18v0, c18v1)
    local c18v2, c18v3
    c18v2 = type
    c18v2 = c18v2(c18v0)
    c18v3 = "number"
    local __renovice_local_0 = c18v2
    if __renovice_local_0 == c18v3 then
      c18v2 = type
      c18v2 = c18v2(c18v1)
      c18v3 = "number"
      __renovice_local_0 = c18v2
      if __renovice_local_0 == c18v3 then
        if c18v0 <= c18v1 then
          c18v2 = 0
          do return c18v2 end
        end
        c18v2 = c18v0 - c18v1
        do return c18v2 end
      end
    end
    c18v2 = nil
    do return c18v2 end
  end
  v8 = function(c19v0, ...)
    local c19v1
    c19v1 = pcall
    c19v1(c19v0, ...)
    do return end
  end
  v9 = function(c20v0, c20v1)
    local c20v2, c20v3, c20v4, c20v5, c20v6, c20v7, c20v8, c20v9, c20v10, c20v11, c20v12, c20v13, c20v14, c20v15, c20v16, c20v17, c20v18, c20v19, c20v20, c20v21, c20v22, c20v23, c20v24, c20v25, c20v26, c20v27, c20v28, c20v29, c20v30, c20v31, c20v32, c20v33, c20v34, c20v35, c20v36, c20v37, c20v38
    if c20v0 == nil then
      c20v2 = nil
      do return c20v2 end
    end
    c20v2 = type
    c20v2 = c20v2(c20v1)
    c20v37 = "table"
    c20v38 = c20v2
    if c20v38 ~= c20v37 then
      c20v2 = nil
      do return c20v2 end
    end
    c20v3 = v0
    c20v2 = c20v3 + 1
    v0 = c20v2
    c20v2 = v4
    c20v3 = c20v1.target
    c20v4 = c20v1.damageControl
    c20v2 = c20v2(c20v3, c20v4)
    c20v3 = v5
    c20v4 = c20v1.damageControl
    c20v3 = c20v3(c20v4)
    c20v4 = v6
    c20v5 = c20v1.damageData
    c20v6 = c20v1.requestedRaw
    c20v4 = c20v4(c20v5, c20v6)
    c20v5 = { id = nil, trace = nil, context = nil, before = nil, statusBefore = nil }
    c20v6 = v0
    c20v5.id = c20v6
    c20v5.trace = c20v0
    c20v5.context = c20v1
    c20v5.before = c20v2
    c20v5.statusBefore = c20v3
    c20v6 = v8
    c20v7 = c20v0
    c20v8 = "BATTLE_TX_BEGIN"
    c20v9 = c20v5.id
    c20v10 = c20v1.label
    c20v11 = c20v1.prototype
    c20v12 = c20v1.instruction
    c20v13 = c20v1.target
    c20v14 = c20v1.damageData
    c20v15 = "source"
    c20v16 = c20v1.source
    c20v18 = c20v1.sourceKnown
    c20v37 = true
    c20v38 = c20v18
    if c20v38 ~= c20v37 then
      c20v17 = false
    else
      c20v17 = true
    end
    c20v18 = "sourceAbility"
    c20v19 = c20v1.sourceAbility
    c20v21 = c20v1.sourceAbilityKnown
    c20v37 = true
    c20v38 = c20v21
    if c20v38 ~= c20v37 then
      c20v20 = false
    else
      c20v20 = true
    end
    c20v21 = "batch"
    c20v22 = c20v1.batchId
    c20v23 = c20v1.targetOrdinal
    c20v24 = c20v1.pendingDepth
    c20v25 = "calculation"
    c20v26 = c20v1.calculation
    c20v27 = "modifier"
    c20v28 = c20v1.modifierName
    c20v29 = c20v1.modifierValue
    c20v30 = "modifierScale"
    c20v31 = c20v1.modifierScaleName
    c20v32 = c20v1.modifierScaleValue
    c20v33 = "baseMultiplier"
    c20v34 = c20v1.baseMultiplier
    c20v35 = "bonusPerStack"
    c20v36 = c20v1.bonusPerStack
    c20v6(c20v7, c20v8, c20v9, c20v10, c20v11, c20v12, c20v13, c20v14, c20v15, c20v16, c20v17, c20v18, c20v19, c20v20, c20v21, c20v22, c20v23, c20v24, c20v25, c20v26, c20v27, c20v28, c20v29, c20v30, c20v31, c20v32, c20v33, c20v34, c20v35, c20v36)
    c20v6 = v8
    c20v8 = "BATTLE_STATE_BEGIN"
    c20v9 = c20v5.id
    c20v10 = c20v1.label
    c20v11 = "health"
    c20v12 = c20v2.health
    c20v13 = c20v2.healthOk
    c20v14 = c20v2.maxHealth
    c20v15 = c20v2.maxHealthOk
    c20v16 = "shield"
    c20v17 = c20v2.shield
    c20v18 = c20v2.shieldOk
    c20v19 = c20v2.maxShield
    c20v20 = c20v2.maxShieldOk
    c20v21 = "overguard"
    c20v22 = c20v2.overguard
    c20v23 = c20v2.overguardOk
    c20v24 = "armour"
    c20v25 = c20v2.armour
    c20v26 = c20v2.armourOk
    c20v6(c20v0, c20v8, c20v9, c20v10, c20v11, c20v12, c20v13, c20v14, c20v15, c20v16, c20v17, c20v18, c20v19, c20v20, c20v21, c20v22, c20v23, c20v24, c20v25, c20v26)
    c20v6 = v8
    c20v8 = "BATTLE_LIFE_BEGIN"
    c20v9 = c20v5.id
    c20v10 = c20v1.label
    c20v11 = "killed"
    c20v12 = c20v2.killed
    c20v13 = c20v2.killedOk
    c20v14 = "dead"
    c20v15 = c20v2.dead
    c20v16 = c20v2.deadOk
    c20v17 = "ragdollPresent"
    c20v18 = c20v2.ragdollPresent
    c20v19 = c20v2.ragdollOk
    c20v6(c20v0, c20v8, c20v9, c20v10, c20v11, c20v12, c20v13, c20v14, c20v15, c20v16, c20v17, c20v18, c20v19)
    c20v6 = v8
    c20v8 = "BATTLE_STATUS_BEGIN"
    c20v9 = c20v5.id
    c20v10 = c20v1.label
    c20v6(c20v0, c20v8, c20v9, c20v10, c20v3)
    c20v6 = v8
    c20v8 = "BATTLE_DAMAGE_INPUT"
    c20v9 = c20v5.id
    c20v10 = c20v1.label
    c20v11 = "stockRaw"
    c20v12 = c20v1.stockRaw
    c20v13 = "multiplier"
    c20v14 = c20v1.multiplier
    c20v15 = "requestedRaw"
    c20v16 = c20v1.requestedRaw
    c20v17 = "observedRaw"
    c20v18 = c20v1.observedRaw
    c20v6(c20v0, c20v8, c20v9, c20v10, c20v11, c20v12, c20v13, c20v14, c20v15, c20v16, c20v17, c20v18, c20v4)
    do return c20v5 end
  end
  v10 = function(c21v0, c21v1)
    local c21v2, c21v3, c21v4, c21v5, c21v6, c21v7, c21v8, c21v9, c21v10, c21v11, c21v12, c21v13, c21v14, c21v15, c21v16, c21v17, c21v18, c21v19, c21v20, c21v21, c21v22, c21v23, c21v24, c21v25, c21v26, c21v27, c21v28, c21v29, c21v30, c21v31, c21v32, c21v33, c21v34, c21v35, c21v36, c21v37
    if c21v0 == nil then
      do return end
    end
    c21v2 = type
    c21v2 = c21v2(c21v1)
    c21v37 = "table"
    local __renovice_local_0 = c21v2
    if __renovice_local_0 ~= c21v37 then
      c21v1 = {}
    end
    c21v2 = c21v0.context
    c21v3 = v4
    c21v4 = c21v2.target
    c21v5 = c21v2.damageControl
    c21v3 = c21v3(c21v4, c21v5)
    c21v4 = v7
    c21v5 = c21v0.before
    c21v5 = c21v5.health
    c21v6 = c21v3.health
    c21v4 = c21v4(c21v5, c21v6)
    c21v5 = v7
    c21v6 = c21v0.before
    c21v6 = c21v6.shield
    c21v7 = c21v3.shield
    c21v5 = c21v5(c21v6, c21v7)
    c21v6 = v7
    c21v7 = c21v0.before
    c21v7 = c21v7.overguard
    c21v8 = c21v3.overguard
    c21v6 = c21v6(c21v7, c21v8)
    c21v7 = 0
    c21v8 = true
    c21v9 = type
    c21v9 = c21v9(c21v4)
    c21v37 = "number"
    __renovice_local_0 = c21v9
    if __renovice_local_0 == c21v37 then
      c21v7 = c21v7 + c21v4
    else
      c21v8 = false
    end
    c21v9 = type
    c21v9 = c21v9(c21v5)
    c21v37 = "number"
    __renovice_local_0 = c21v9
    if __renovice_local_0 == c21v37 then
      c21v7 = c21v7 + c21v5
    else
      c21v8 = false
    end
    c21v9 = type
    c21v9 = c21v9(c21v6)
    c21v37 = "number"
    __renovice_local_0 = c21v9
    if __renovice_local_0 == c21v37 then
      c21v7 = c21v7 + c21v6
    else
      c21v8 = false
    end
    c21v9 = nil
    c21v10 = nil
    if c21v8 then
      c21v12 = c21v1.installedRaw
      c21v11 = type
      c21v11 = c21v11(c21v12)
      c21v37 = "number"
      __renovice_local_0 = c21v11
      if __renovice_local_0 == c21v37 then
        c21v11 = c21v1.installedRaw
        c21v9 = c21v11 - c21v7
        c21v11 = c21v1.installedRaw
        c21v12 = 0
        if c21v12 < c21v11 then
          c21v11 = c21v1.installedRaw
          c21v10 = c21v7 / c21v11
        end
      end
    end
    c21v11 = v5
    c21v12 = c21v2.damageControl
    c21v11 = c21v11(c21v12)
    c21v12 = v8
    c21v13 = c21v0.trace
    c21v14 = "BATTLE_STATE_END"
    c21v15 = c21v0.id
    c21v16 = c21v2.label
    c21v17 = "health"
    c21v18 = c21v0.before
    c21v18 = c21v18.health
    c21v19 = c21v3.health
    c21v21 = "shield"
    c21v22 = c21v0.before
    c21v22 = c21v22.shield
    c21v23 = c21v3.shield
    c21v25 = "overguard"
    c21v26 = c21v0.before
    c21v26 = c21v26.overguard
    c21v27 = c21v3.overguard
    c21v29 = "armour"
    c21v30 = c21v0.before
    c21v30 = c21v30.armour
    c21v31 = c21v3.armour
    c21v32 = "visiblePoolLoss"
    c21v12(c21v13, c21v14, c21v15, c21v16, c21v17, c21v18, c21v19, c21v4, c21v21, c21v22, c21v23, c21v5, c21v25, c21v26, c21v27, c21v6, c21v29, c21v30, c21v31, c21v32, c21v7, c21v8)
    c21v12 = v8
    c21v13 = c21v0.trace
    c21v14 = "BATTLE_LIFE_END"
    c21v15 = c21v0.id
    c21v16 = c21v2.label
    c21v17 = "killed"
    c21v18 = c21v0.before
    c21v18 = c21v18.killed
    c21v19 = c21v3.killed
    c21v20 = c21v3.killedOk
    c21v21 = "dead"
    c21v22 = c21v0.before
    c21v22 = c21v22.dead
    c21v23 = c21v3.dead
    c21v24 = c21v3.deadOk
    c21v25 = "ragdollPresent"
    c21v26 = c21v0.before
    c21v26 = c21v26.ragdollPresent
    c21v27 = c21v3.ragdollPresent
    c21v28 = c21v3.ragdollOk
    c21v12(c21v13, c21v14, c21v15, c21v16, c21v17, c21v18, c21v19, c21v20, c21v21, c21v22, c21v23, c21v24, c21v25, c21v26, c21v27, c21v28)
    c21v12 = v8
    c21v13 = c21v0.trace
    c21v14 = "BATTLE_STATUS_END"
    c21v15 = c21v0.id
    c21v16 = c21v2.label
    c21v17 = c21v0.statusBefore
    c21v12(c21v13, c21v14, c21v15, c21v16, c21v17, c21v11)
    c21v12 = v8
    c21v13 = c21v0.trace
    c21v14 = "BATTLE_MATH"
    c21v15 = c21v0.id
    c21v16 = c21v2.label
    c21v17 = "stockRaw"
    c21v18 = c21v2.stockRaw
    c21v19 = "multiplier"
    c21v20 = c21v2.multiplier
    c21v21 = "requestedRaw"
    c21v22 = c21v2.requestedRaw
    c21v23 = "installedRaw"
    c21v24 = c21v1.installedRaw
    c21v25 = "restoredRaw"
    c21v26 = c21v1.restoredRaw
    c21v27 = "reportedRaw"
    c21v28 = c21v1.reportedRaw
    c21v29 = "visiblePoolLoss"
    c21v31 = "visiblePoolLossComplete"
    c21v33 = "rawMinusVisiblePoolLoss"
    c21v34 = "visibleToInstalledRatio"
    c21v35 = "results"
    c21v36 = c21v1.results
    c21v12(c21v13, c21v14, c21v15, c21v16, c21v17, c21v18, c21v19, c21v20, c21v21, c21v22, c21v23, c21v24, c21v25, c21v26, c21v27, c21v28, c21v29, c21v7, c21v31, c21v8, c21v33, c21v9, c21v34, c21v10, c21v35, c21v36)
    do return end
  end
  v11 = function()
    local c22v0
    c22v0 = 0
    v0 = c22v0
    do return end
  end
  v12 = false
  v13 = nil
  v14 = {}
  v15 = 0
  v16 = function(c24v0)
    local c24v1, c24v2, c24v3, c24v4
    c24v1 = type
    c24v1 = c24v1(c24v0)
    c24v4 = "number"
    local __renovice_local_0 = c24v1
    if __renovice_local_0 == c24v4 then
      do return c24v0 end
    end
    c24v1 = IsNull
    c24v1 = c24v1(c24v0)
    if c24v1 then
      c24v1 = nil
      do return c24v1 end
    end
    c24v1 = pcall
    c24v2 = function()
      local c23v0
      c23v0 = c24v0
      do return c23v0:GetModifiedValue() end
    end
    c24v1, c24v2 = c24v1(c24v2)
    if c24v1 then
      c24v3 = type
      c24v3 = c24v3(c24v2)
      c24v4 = "number"
      __renovice_local_0 = c24v3
      if __renovice_local_0 == c24v4 then
        do return c24v2 end
      end
    end
    c24v3 = nil
    do return c24v3 end
  end
  v17 = function(c25v0)
    local c25v1, c25v2, c25v3, c25v4
    c25v1 = false
    c25v2 = type
    c25v2 = c25v2(c25v0)
    c25v3 = "number"
    c25v4 = c25v2
    if c25v4 == c25v3 then
      c25v1 = false
      if c25v0 == c25v0 then
        c25v1 = false
        c25v2 = 0
        if c25v2 < c25v0 then
          c25v2 = 1e+30
          if not (c25v0 < c25v2) then
            c25v1 = false
            do return c25v1 end
          end
          c25v1 = true
        end
      end
    end
    do return c25v1 end
  end
  v18 = function(c26v0)
    local c26v1, c26v2, c26v3, c26v4, c26v5, c26v6, c26v7
    c26v1 = IsNull
    c26v1 = c26v1(c26v0)
    if c26v1 then
      c26v1 = nil
      do return c26v1 end
    end
    c26v1 = c26v0:InventoryControl()
    c26v2 = IsNull
    c26v2 = c26v2(c26v1)
    if c26v2 then
      c26v2 = nil
      do return c26v2 end
    end
    c26v2 = c26v1:GetActivePowerSuit()
    c26v3 = IsNull
    c26v3 = c26v3(c26v2)
    if c26v3 then
      c26v3 = nil
      do return c26v3 end
    end
    c26v3 = Engine.UpgradedValue
    c26v4 = 1
    c26v3 = c26v3(c26v4)
    c26v5 = c26v3
    c26v6 = 10
    c26v7 = c26v2:GetType()
    c26v1:ModifyValue(c26v5, c26v6, c26v7, c26v2)
    c26v4 = v16
    do return c26v4(c26v3) end
  end
  v19 = function(c27v0)
    local c27v1, c27v2, c27v3, c27v4
    c27v1 = IsNull
    c27v1 = c27v1(c27v0)
    if c27v1 then
      c27v1 = false
      do return c27v1 end
    end
    c27v2 = c27v0:GetLocalizeTag()
    c27v2 = c27v2:c_str()
    c27v3 = "/Lotus/Language/Suits/IceWaveAbilityName"
    c27v4 = c27v2
    if c27v4 ~= c27v3 then
      c27v1 = false
      do return c27v1 end
    end
    c27v1 = true
    do return c27v1 end
  end
  v20 = function(c28v0, c28v1)
    local c28v2, c28v3, c28v4, c28v5, c28v6, c28v7, c28v8, c28v9, c28v10
    c28v9 = 0
    c28v2 = 1
    c28v3 = c28v1.Modded
    c28v7 = true
    c28v8 = c28v3
    if c28v8 ~= c28v7 then
      c28v9 = 6
    else
      c28v9 = 1
    end
    c28v10 = 1
    local __renovice_local_0 = c28v9
    if __renovice_local_0 == c28v10 then
      c28v3 = v18
      c28v4 = c28v1.Avatar
      c28v2 = c28v3(c28v4)
      c28v3 = type
      c28v3 = c28v3(c28v2)
      c28v7 = "number"
      c28v8 = c28v3
      if (c28v8 ~= c28v7 or c28v2 ~= c28v2) then
        c28v9 = 5
      else
        c28v9 = 3
      end
    end
    c28v10 = 3
    __renovice_local_0 = c28v9
    if __renovice_local_0 == c28v10 then
      c28v3 = 0
      if c28v2 < c28v3 then
        c28v9 = 5
      else
        c28v9 = 4
      end
    end
    c28v10 = 4
    __renovice_local_0 = c28v9
    if __renovice_local_0 == c28v10 then
      c28v3 = 1e+30
      if not (c28v3 <= c28v2) then
        c28v9 = 6
      else
        c28v9 = 5
      end
    end
    c28v10 = 5
    __renovice_local_0 = c28v9
    if __renovice_local_0 == c28v10 then
      c28v3 = error
      c28v4 = "ICE_WAVE_CARD_STRENGTH_UNAVAILABLE"
      c28v3(c28v4)
      c28v9 = 6
    end
    c28v10 = 6
    __renovice_local_0 = c28v9
    if __renovice_local_0 == c28v10 then
      c28v5 = { Label = "Cold Damage Multiplier", Value = nil, ValueUnit = "/Lotus/Language/Game/UNIT_MULTIPLIER" }
      c28v6 = 10 * c28v2
      c28v5.Value = c28v6
      c28v3 = table.insert
      c28v3(c28v0, c28v5)
      do return c28v0 end
    end
    do return end
  end
  v21 = function(c29v0, ...)
    local c29v1
    if c29v0 ~= nil then
      c29v1 = pcall
      c29v1(c29v0, ...)
    end
    do return end
  end
  v22 = function(c30v0, c30v1, c30v2, c30v3)
    local c30v4, c30v5, c30v6, c30v7, c30v8, c30v9, c30v10, c30v11, c30v12, c30v13, c30v14, c30v15, c30v16, c30v17, c30v18
    c30v4 = v12
    if not c30v4 then
      do return end
    end
    c30v17 = 7
    c30v18 = c30v0
    if c30v18 ~= c30v17 then
      do return end
    end
    c30v17 = 42
    c30v18 = c30v1
    if c30v18 ~= c30v17 then
      do return end
    end
    c30v4 = type
    c30v4 = c30v4(c30v2)
    c30v17 = "table"
    c30v18 = c30v4
    if c30v18 ~= c30v17 then
      do return end
    end
    c30v4 = c30v2[1]
    c30v5 = c30v2[2]
    c30v6 = IsNull
    c30v6 = c30v6(c30v4)
    if not c30v6 then
      c30v6 = IsNull
      c30v6 = c30v6(c30v5)
      if not c30v6 then
        c30v6 = v16
        c30v6 = c30v6(c30v5)
        c30v7 = v17
        c30v7 = c30v7(c30v6)
        if not c30v7 then
          do return end
        end
        c30v8 = v15
        c30v7 = c30v8 + 1
        v15 = c30v7
        c30v7 = { id = nil, damageData = nil, stockAmount = nil, stockRaw = nil, trace = nil, targetOrdinal = 0 }
        c30v8 = v15
        c30v7.id = c30v8
        c30v7.damageData = c30v4
        c30v7.stockAmount = c30v5
        c30v7.stockRaw = c30v6
        c30v7.trace = c30v3
        v13 = c30v7
        c30v7 = v21
        c30v9 = "ICE_WAVE_BASE_CAPTURE"
        c30v10 = v15
        c30v11 = "prototype"
        c30v12 = "instruction"
        c30v13 = "damageData"
        c30v14 = "stockRaw"
        c30v15 = "packetMode"
        c30v16 = "shared-per-target"
        c30v7(c30v3, c30v9, c30v10, c30v11, c30v0, c30v12, c30v1, c30v13, c30v4, c30v14, c30v6, c30v15, c30v16)
        do return end
      end
    end
    do return end
  end
  v23 = function(c31v0, c31v1, c31v2, c31v3)
    local c31v4, c31v5, c31v6, c31v7, c31v8, c31v9, c31v10, c31v11, c31v12, c31v13, c31v14, c31v15, c31v16, c31v17, c31v18, c31v19, c31v20, c31v21, c31v22, c31v23, c31v24, c31v25, c31v26
    c31v4 = v12
    if not c31v4 then
      do return end
    end
    c31v25 = 7
    c31v26 = c31v0
    if c31v26 ~= c31v25 then
      do return end
    end
    c31v25 = 65
    c31v26 = c31v1
    if c31v26 ~= c31v25 then
      do return end
    end
    c31v4 = type
    c31v4 = c31v4(c31v2)
    c31v25 = "table"
    c31v26 = c31v4
    if c31v26 ~= c31v25 then
      do return end
    end
    c31v4 = v13
    if c31v4 == nil then
      c31v5 = v21
      c31v7 = "ICE_WAVE_BASE_MISS"
      c31v8 = "prototype"
      c31v10 = "instruction"
      c31v12 = "reason"
      c31v13 = "no-pending-stock-write"
      c31v5(c31v3, c31v7, c31v8, c31v0, c31v10, c31v1, c31v12, c31v13)
      do return end
    end
    c31v5 = c31v2[1]
    c31v6 = c31v2[2]
    c31v7 = IsNull
    c31v7 = c31v7(c31v5)
    if not c31v7 then
      c31v7 = IsNull
      c31v7 = c31v7(c31v6)
      if not c31v7 then
        c31v7 = c31v4.damageData
        if c31v7 ~= c31v6 then
          c31v7 = v21
          c31v9 = c31v4.trace
          c31v8 = c31v9
          if not c31v8 then
            c31v8 = c31v3
          end
          c31v9 = "ICE_WAVE_BASE_MISS"
          c31v10 = c31v4.id
          c31v11 = "prototype"
          c31v13 = "instruction"
          c31v15 = "reason"
          c31v16 = "damage-data-mismatch"
          c31v17 = "captured"
          c31v18 = c31v4.damageData
          c31v19 = "received"
          c31v7(c31v8, c31v9, c31v10, c31v11, c31v0, c31v13, c31v1, c31v15, c31v16, c31v17, c31v18, c31v19, c31v6)
          do return end
        end
        c31v8 = c31v4.targetOrdinal
        c31v7 = c31v8 + 1
        c31v4.targetOrdinal = c31v7
        c31v7 = c31v4.strength
        if c31v7 ~= nil then
          c31v7 = IsNull
          c31v8 = c31v4.source
          c31v7 = c31v7(c31v8)
          if not c31v7 then
            c31v7 = c31v5:DamageControl()
            c31v8 = IsNull
            c31v8 = c31v8(c31v7)
            if c31v8 then
              do return end
            end
            c31v10 = 4
            c31v8 = c31v7:Name__ff67e37d(c31v10)
            c31v9 = type
            c31v9 = c31v9(c31v8)
            c31v25 = "number"
            c31v26 = c31v9
            if c31v26 == c31v25 then
              c31v9 = 0
              if not (c31v8 < c31v9) then
                c31v9 = 10
                if c31v9 < c31v8 then
                  c31v8 = 10
                end
                c31v9 = c31v6:GetBaseAmount()
                c31v10 = IsNull
                c31v10 = c31v10(c31v9)
                if c31v10 then
                  do return end
                end
                c31v10 = v16
                c31v10 = c31v10(c31v9)
                c31v11 = v17
                c31v11 = c31v11(c31v10)
                if not c31v11 then
                  do return end
                end
                c31v12 = 1
                c31v14 = c31v8 * 10
                c31v15 = c31v4.strength
                c31v13 = c31v14 * c31v15
                c31v11 = c31v12 + c31v13
                c31v13 = c31v4.stockRaw
                c31v12 = c31v13 * c31v11
                c31v13 = v17
                c31v13 = c31v13(c31v12)
                if not c31v13 then
                  do return end
                end
                c31v15 = v14
                c31v14 = #c31v15
                c31v13 = c31v14 + 1
                c31v14 = nil
                c31v15 = pcall
                c31v16 = v9
                c31v18 = { label = "FROST_ICE_WAVE_DAMAGE", prototype = nil, instruction = nil, target = nil, damageData = nil, damageControl = nil, source = nil, sourceKnown = true, sourceAbility = nil, sourceAbilityKnown = false, stockRaw = nil, multiplier = nil, requestedRaw = nil, observedRaw = nil, batchId = nil, targetOrdinal = nil, pendingDepth = nil, calculation = "stockRaw*(1+coldStacks*bonusPerStack*abilityStrength)", modifierName = "coldStacks", modifierValue = nil, modifierScaleName = "abilityStrength", modifierScaleValue = nil, baseMultiplier = 1, bonusPerStack = 10 }
                c31v18.prototype = c31v0
                c31v18.instruction = c31v1
                c31v18.target = c31v5
                c31v18.damageData = c31v6
                c31v18.damageControl = c31v7
                c31v19 = c31v4.source
                c31v18.source = c31v19
                c31v19 = c31v4.stockRaw
                c31v18.stockRaw = c31v19
                c31v18.multiplier = c31v11
                c31v18.requestedRaw = c31v12
                c31v18.observedRaw = c31v10
                c31v19 = c31v4.id
                c31v18.batchId = c31v19
                c31v19 = c31v4.targetOrdinal
                c31v18.targetOrdinal = c31v19
                c31v18.pendingDepth = c31v13
                c31v18.modifierValue = c31v8
                c31v19 = c31v4.strength
                c31v18.modifierScaleValue = c31v19
                c31v15, c31v16 = c31v15(c31v16, c31v3, c31v18)
                if c31v15 then
                  c31v14 = c31v16
                end
                c31v19 = Engine.UpgradedValue
                c31v6:SetBaseAmount(c31v19(c31v12))
                c31v17 = v16
                c31v17 = c31v17(c31v6:GetBaseAmount())
                c31v18 = v17
                c31v18 = c31v18(c31v17)
                if not c31v18 then
                  c31v20 = Engine.UpgradedValue
                  c31v21 = c31v4.stockRaw
                  c31v6:SetBaseAmount(c31v20(c31v21))
                  c31v18 = v21
                  c31v20 = c31v4.trace
                  c31v19 = c31v20
                  if not c31v19 then
                    c31v19 = c31v3
                  end
                  c31v20 = "ICE_WAVE_INSTALL_REJECTED"
                  c31v21 = c31v4.id
                  c31v22 = "targetOrdinal"
                  c31v23 = c31v4.targetOrdinal
                  c31v24 = "requestedRaw"
                  c31v18(c31v19, c31v20, c31v21, c31v22, c31v23, c31v24, c31v12)
                  do return end
                end
                c31v18 = v14
                c31v21 = v14
                c31v20 = #c31v21
                c31v19 = c31v20 + 1
                c31v20 = { damageData = nil, stockRaw = nil, trace = nil, captureId = nil, targetOrdinal = nil, meter = nil, installedRaw = nil }
                c31v20.damageData = c31v6
                c31v21 = c31v4.stockRaw
                c31v20.stockRaw = c31v21
                c31v22 = c31v4.trace
                c31v21 = c31v22
                if not c31v21 then
                  c31v21 = c31v3
                end
                c31v20.trace = c31v21
                c31v21 = c31v4.id
                c31v20.captureId = c31v21
                c31v21 = c31v4.targetOrdinal
                c31v20.targetOrdinal = c31v21
                c31v20.meter = c31v14
                c31v20.installedRaw = c31v17
                c31v18[c31v19] = c31v20
                do return end
              end
            end
            do return end
          end
        end
        c31v7 = v21
        c31v9 = "ICE_WAVE_STRENGTH_REJECTED"
        c31v10 = c31v4.id
        c31v11 = "reason"
        c31v12 = "no-verified-caster-strength"
        c31v7(c31v3, c31v9, c31v10, c31v11, c31v12)
        do return end
      end
    end
    do return end
  end
  v24 = function(c32v0, c32v1, c32v2, c32v3)
    local c32v4, c32v5, c32v6, c32v7, c32v8, c32v9, c32v10, c32v11, c32v12, c32v13, c32v14, c32v15, c32v16, c32v17, c32v18
    c32v4 = v12
    if c32v4 then
      c32v17 = 7
      c32v18 = c32v0
      if c32v18 == c32v17 then
        c32v17 = 53
        c32v18 = c32v1
        if c32v18 == c32v17 then
          c32v4 = type
          c32v4 = c32v4(c32v2)
          c32v17 = "table"
          c32v18 = c32v4
          if c32v18 ~= c32v17 then
            do return end
          end
          c32v4 = v13
          if c32v4 ~= nil then
            c32v5 = c32v4.damageData
            c32v6 = c32v2[1]
            if c32v5 == c32v6 then
              c32v5 = nil
              c32v4.source = c32v5
              c32v5 = nil
              c32v4.strength = c32v5
              c32v5 = c32v2[2]
              c32v6 = IsNull
              c32v6 = c32v6(c32v5)
              if c32v6 then
                c32v6 = v21
                c32v8 = "ICE_WAVE_STRENGTH_REJECTED"
                c32v9 = c32v4.id
                c32v10 = "reason"
                c32v11 = "null-stock-source"
                c32v6(c32v3, c32v8, c32v9, c32v10, c32v11)
                do return end
              end
              c32v6 = pcall
              c32v7 = v18
              c32v6, c32v7 = c32v6(c32v7, c32v5)
              if c32v6 then
                c32v8 = type
                c32v8 = c32v8(c32v7)
                c32v17 = "number"
                c32v18 = c32v8
                if (c32v18 == c32v17 and c32v7 == c32v7) then
                  c32v8 = 0
                  if not (c32v7 < c32v8) then
                    c32v8 = 1e+30
                    if not (c32v8 <= c32v7) then
                      c32v4.source = c32v5
                      c32v4.strength = c32v7
                      c32v8 = v21
                      c32v10 = "ICE_WAVE_STRENGTH_CAPTURE"
                      c32v11 = c32v4.id
                      c32v12 = "source"
                      c32v14 = "abilityStrength"
                      c32v15 = "bonusPerStack"
                      c32v16 = 10
                      c32v8(c32v3, c32v10, c32v11, c32v12, c32v5, c32v14, c32v7, c32v15, c32v16)
                      do return end
                    end
                  end
                end
              end
              c32v8 = v21
              c32v10 = "ICE_WAVE_STRENGTH_REJECTED"
              c32v11 = c32v4.id
              c32v12 = "reason"
              c32v13 = "stock-strength-query-unavailable"
              c32v14 = "queryOk"
              c32v8(c32v3, c32v10, c32v11, c32v12, c32v13, c32v14, c32v6)
              do return end
            end
          end
          do return end
        end
      end
    end
    do return end
  end
  v25 = function(c33v0, c33v1, c33v2, c33v3, c33v4)
    local c33v5, c33v6, c33v7, c33v8, c33v9, c33v10, c33v11, c33v12, c33v13, c33v14, c33v15, c33v16, c33v17
    c33v16 = 7
    c33v17 = c33v0
    if c33v17 ~= c33v16 then
      do return end
    end
    c33v16 = 65
    c33v17 = c33v1
    if c33v17 ~= c33v16 then
      do return end
    end
    c33v6 = v14
    c33v8 = v14
    c33v7 = #c33v8
    c33v5 = c33v6[c33v7]
    if c33v5 == nil then
      do return end
    end
    c33v6 = v14
    c33v8 = v14
    c33v7 = #c33v8
    c33v8 = nil
    c33v6[c33v7] = c33v8
    c33v6 = c33v5.damageData
    c33v8 = Engine.UpgradedValue
    c33v9 = c33v5.stockRaw
    c33v6:SetBaseAmount(c33v8(c33v9))
    c33v6 = v16
    c33v7 = c33v5.damageData
    c33v6 = c33v6(c33v7:GetBaseAmount())
    c33v7 = c33v5.stockRaw
    if c33v6 ~= c33v7 then
      c33v7 = v21
      c33v8 = c33v5.trace
      c33v9 = "ICE_WAVE_RESTORE_MISMATCH"
      c33v10 = c33v5.captureId
      c33v11 = "targetOrdinal"
      c33v12 = c33v5.targetOrdinal
      c33v13 = "expectedRaw"
      c33v14 = c33v5.stockRaw
      c33v15 = "restoredRaw"
      c33v7(c33v8, c33v9, c33v10, c33v11, c33v12, c33v13, c33v14, c33v15, c33v6)
    end
    c33v7 = c33v5.meter
    if c33v7 ~= nil then
      c33v7 = pcall
      c33v8 = v10
      c33v9 = c33v5.meter
      c33v10 = { results = nil, installedRaw = nil, restoredRaw = nil, reportedRaw = nil }
      c33v10.results = c33v3
      c33v11 = c33v5.installedRaw
      c33v10.installedRaw = c33v11
      c33v10.restoredRaw = c33v6
      c33v7(c33v8, c33v9, c33v10)
    end
    do return end
  end
  v26 = function()
    local c34v0
    c34v0 = nil
    v13 = c34v0
    c34v0 = {}
    v14 = c34v0
    c34v0 = 0
    v15 = c34v0
    c34v0 = v11
    c34v0()
    do return end
  end
  v27 = { activate = nil, cleanup = nil, hooks = nil }
  v28 = function()
    local c35v0
    c35v0 = true
    v12 = c35v0
    c35v0 = v26
    c35v0()
    do return end
  end
  v27.activate = v28
  v28 = function()
    local c36v0
    c36v0 = false
    v12 = c36v0
    c36v0 = v26
    c36v0()
    do return end
  end
  v27.cleanup = v28
  v28 = { matchesAbility = nil, afterAbilityCard = nil, nativeCalls = nil }
  v28.matchesAbility = v19
  v28.afterAbilityCard = v20
  v29 = { SetBaseAmount = nil, SetSource = nil, DamageDD = nil }
  v30 = { before = nil }
  v30.before = v22
  v29.SetBaseAmount = v30
  v30 = { before = nil }
  v30.before = v24
  v29.SetSource = v30
  v30 = { before = nil, after = nil }
  v30.before = v23
  v30.after = v25
  v29.DamageDD = v30
  v28.nativeCalls = v29
  v27.hooks = v28
  do return v27 end
