  local v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
  v0 = require
  v1 = "Lotus.Powersuits.PowersuitAbilities.PVPLib"
  v0 = v0(v1)
  v1 = require
  v2 = "Lotus.Scripts.Libs.AbilitiesLib"
  v1 = v1(v2)
  v2 = Symbol
  v3 = "Scalar2"
  v2 = v2(v3)
  v3 = Symbol
  v4 = "Scalar3"
  v3 = v3(v4)
  v4 = Symbol
  v5 = "FresnelGradientScale_FresnelGradientPan_FresnelGradientBaseStrength"
  v4 = v4(v5)
  v5 = 5
  v6 = 300
  v7 = 0.5
  v8 = 0.6
  v9 = 10
  v10 = 5
  v11 = 100
  v12 = 0.15
  v13 = WeakResource
  v14 = "/Lotus/Powersuits/Frost/VelimirNpcSuit"
  v13 = v13(v14)
  v14 = function(c1v0)
    local c1v1, c1v2, c1v3, c1v4
    c1v1 = _T.slamGlobe
    if c1v1 == nil then
      c1v1 = false
      do return c1v1 end
    end
    c1v2 = next
    c1v3 = _T.slamGlobe
    c1v2 = c1v2(c1v3)
    if c1v2 == nil then
      c1v1 = false
    else
      c1v1 = true
    end
    c1v2 = c1v1
    if c1v2 then
      c1v4 = v13
      c1v2 = c1v0:IsA(c1v4)
    end
    do return c1v2 end
  end
  v15 = function(c2v0)
    local c2v1
    c2v1 = 5
    v5 = c2v1
    if c2v0 == 1 then
      c2v1 = 1500
      v6 = c2v1
      c2v1 = 1
      v7 = c2v1
      c2v1 = 0.6
      v8 = c2v1
      c2v1 = 50
      v11 = c2v1
    else
      if c2v0 == 2 then
        c2v1 = 2500
        v6 = c2v1
        c2v1 = 2
        v7 = c2v1
        c2v1 = 0.5
        v8 = c2v1
        c2v1 = 100
        v11 = c2v1
      else
        if c2v0 == 3 then
          c2v1 = 3000
          v6 = c2v1
          c2v1 = 3
          v7 = c2v1
          c2v1 = 0.4
          v8 = c2v1
          c2v1 = 125
          v11 = c2v1
        else
          c2v1 = 3500
          v6 = c2v1
          c2v1 = 4
          v7 = c2v1
          c2v1 = 0.33
          v8 = c2v1
          c2v1 = 150
          v11 = c2v1
        end
      end
    end
    c2v1 = v0
    c2v1 = c2v1.IsPvpEnabled
    c2v1 = c2v1()
    if c2v1 then
      c2v1 = 1
      v5 = c2v1
      if c2v0 == 1 then
        c2v1 = 425
        v6 = c2v1
        c2v1 = 0.1
        v7 = c2v1
        c2v1 = 0.33
        v8 = c2v1
        do return end
      end
      if c2v0 == 2 then
        c2v1 = 450
        v6 = c2v1
        c2v1 = 0.1
        v7 = c2v1
        c2v1 = 0.33
        v8 = c2v1
        do return end
      end
      if c2v0 == 3 then
        c2v1 = 475
        v6 = c2v1
        c2v1 = 0.1
        v7 = c2v1
        c2v1 = 0.33
        v8 = c2v1
        do return end
      end
      c2v1 = 500
      v6 = c2v1
      c2v1 = 0.1
      v7 = c2v1
      c2v1 = 0.33
      v8 = c2v1
    end
    do return end
  end
  v16 = function(c3v0)
    local c3v1, c3v2, c3v3, c3v4, c3v5, c3v6, c3v7, c3v8, c3v9, c3v10
    c3v1 = v6
    c3v2 = v10
    c3v3 = v9
    c3v4 = Engine.UpgradedValue
    c3v5 = v11
    c3v4 = c3v4(c3v5)
    c3v5 = IsNull
    c3v5 = c3v5(c3v0)
    if not c3v5 then
      c3v5 = v6
      c3v7 = c3v0:DamageControl()
      c3v7 = c3v7:GetArmourRating()
      c3v8 = v5
      c3v6 = c3v7 * c3v8
      c3v1 = c3v5 + c3v6
      c3v5 = c3v0:InventoryControl()
      c3v6 = c3v5:GetActivePowerSuit()
      c3v7 = IsNull
      c3v7 = c3v7(c3v6)
      if not c3v7 then
        c3v7 = c3v6:GetType()
        c3v10 = 10
        c3v1 = c3v5:GetUpgradeModifiedValue(c3v1, c3v10, c3v7, c3v6)
        c3v9 = v10
        c3v10 = 9
        c3v2 = c3v5:GetUpgradeModifiedValue(c3v9, c3v10, c3v7, c3v6)
        c3v9 = v9
        c3v10 = 3
        c3v3 = c3v5:GetUpgradeModifiedValue(c3v9, c3v10, c3v7, c3v6)
        c3v10 = 10
        c3v5:ModifyValue(c3v4, c3v10, c3v7, c3v6)
      end
    end
    do return c3v1, c3v2, c3v3, c3v4 end
  end
  v17 = function(c4v0, c4v1)
    local c4v2
    c4v2 = 1
    if c4v1 == c4v2 then
      if c4v0 == 1 then
        c4v2 = 0.3
        v12 = c4v2
        do return end
      end
      if c4v0 == 2 then
        c4v2 = 0.35
        v12 = c4v2
        do return end
      end
      if c4v0 == 3 then
        c4v2 = 0.4
        v12 = c4v2
        do return end
      end
      c4v2 = 0.5
      v12 = c4v2
    end
    do return end
  end
  v18 = function(c5v0)
    local c5v1, c5v2, c5v3, c5v4, c5v5, c5v6, c5v7, c5v8, c5v9
    c5v1 = _T.AbilityLevelQueryParms.Avatar
    c5v2 = IsNull
    c5v2 = c5v2(c5v1)
    if c5v2 then
      do return end
    end
    c5v2 = c5v1:InventoryControl()
    c5v3 = c5v2:GetActivePowerSuit()
    c5v4 = IsNull
    c5v4 = c5v4(c5v3)
    if c5v4 then
      do return end
    end
    local __renovice_local_0 = _T.AbilityLevelQueryParms.Ability
    c5v4 = c5v3:Name__b1572999(__renovice_local_0)
    local __renovice_local_1 = c5v3:GetNumAbilities()
    if __renovice_local_1 <= c5v4 then
      do return end
    end
    __renovice_local_1 = c5v3:GetAbilityAugmentLevel(c5v4)
    __renovice_local_0 = 0
    if __renovice_local_1 <= __renovice_local_0 then
      do return end
    end
    __renovice_local_0 = c5v3:GetAbilityAugmentType(c5v4)
    c5v5 = 1
    if __renovice_local_0 == c5v5 then
      if __renovice_local_1 == 1 then
        c5v5 = 0.3
        v12 = c5v5
      else
        if __renovice_local_1 == 2 then
          c5v5 = 0.35
          v12 = c5v5
        else
          if __renovice_local_1 == 3 then
            c5v5 = 0.4
            v12 = c5v5
          else
            c5v5 = 0.5
            v12 = c5v5
          end
        end
      end
    end
    c5v5 = 1
    if __renovice_local_0 == c5v5 then
      c5v6 = { Label = "/Lotus/Language/Suits/SnowGlobeAbilityAugment1Name", Title = true }
      c5v5 = table.insert
      c5v5(c5v0, c5v6)
      c5v6 = { Label = "/Lotus/Language/Labels/WEAPON_PROC_CHANCE", Value = nil, ValueUnit = "/Lotus/Language/Game/UNIT_PERCENT" }
      c5v9 = v12
      c5v8 = c5v9 * 100
      c5v7 = math.floor
      c5v7 = c5v7(c5v8)
      c5v6.Value = c5v7
      c5v5 = table.insert
      c5v5(c5v0, c5v6)
    end
    do return end
  end
  v19 = function()
    local c6v0, c6v1, c6v2, c6v3, c6v4, c6v5
    c6v0 = v15
    c6v1 = _T.AbilityLevelQueryParms.Level
    c6v0(c6v1)
    c6v0 = _T.AbilityLevelQueryParms.Modded
    if c6v0 == true then
      c6v0 = v16
      c6v1 = _T.AbilityLevelQueryParms.Avatar
      c6v0, c6v1, c6v2, c6v3 = c6v0(c6v1)
      v6 = c6v0
      v10 = c6v1
      v9 = c6v2
      v11 = c6v3
      c6v0 = v11
      c6v0 = c6v0:GetModifiedValue()
      v11 = c6v0
    else
      c6v1 = _T.AbilityLevelQueryParms.Avatar
      c6v0 = IsNull
      c6v0 = c6v0(c6v1)
      if not c6v0 then
        c6v0 = _T.AbilityLevelQueryParms.Avatar
        c6v0 = c6v0:InventoryControl()
        c6v0 = c6v0:GetActivePowerSuit()
        c6v1 = IsNull
        c6v1 = c6v1(c6v0)
        if not c6v1 then
          c6v2 = v6
          c6v4 = c6v0:Name__ff0a0d5c()
          c6v5 = v5
          c6v3 = c6v4 * c6v5
          c6v1 = c6v2 + c6v3
          v6 = c6v1
        end
      end
    end
    c6v0 = {}
    c6v3 = { Label = "/Lotus/Language/Game/ABILITY_RADIUS", Value = nil, ValueUnit = "/Lotus/Language/Game/UNIT_METER" }
    c6v4 = v10
    c6v3.Value = c6v4
    c6v1 = table.insert
    c6v1(c6v0, c6v3)
    c6v3 = { Label = "/Lotus/Language/Suits/FreezePerSecond", Value = 0.3333333333333333, ValueIcon = "<DT_FREEZE>" }
    c6v1 = table.insert
    c6v1(c6v0, c6v3)
    c6v3 = { Label = "/Lotus/Language/Suits/FreezeDuration", Value = nil, ValueIcon = "<DT_FREEZE>", ValueUnit = "/Lotus/Language/Game/UNIT_SECOND" }
    c6v4 = v9
    c6v3.Value = c6v4
    c6v1 = table.insert
    c6v1(c6v0, c6v3)
    c6v3 = { Label = "/Lotus/Language/Game/HEALTH", Value = nil }
    c6v4 = v6
    c6v3.Value = c6v4
    c6v1 = table.insert
    c6v1(c6v0, c6v3)
    c6v3 = { Label = "/Lotus/Language/Game/INVULNERABILITY_DUARTION", Value = nil, ValueUnit = "/Lotus/Language/Game/UNIT_SECOND" }
    c6v4 = v7
    c6v3.Value = c6v4
    c6v1 = table.insert
    c6v1(c6v0, c6v3)
    c6v3 = { Label = "/Lotus/Language/Game/AOE_DAMAGE", Value = nil, ValueIcon = "<DT_FREEZE>" }
    c6v4 = v11
    c6v3.Value = c6v4
    c6v1 = table.insert
    c6v1(c6v0, c6v3)
    c6v1 = v18
    c6v1(c6v0)
    c6v1 = _T.AbilityLevelQueryParms.Modded
    c6v0.Modded = c6v1
    _T.AbilityUpgradeLevelInfo = c6v0
    do return end
  end
  GetAbilityUpgradeLevelInfo = v19
  v19 = function(c7v0, c7v1)
    local c7v2, c7v3, c7v4, c7v5, c7v6
    c7v2 = {}
    c7v3 = 1
    if c7v1 == c7v3 then
      if c7v0 == 1 then
        c7v3 = 0.3
        v12 = c7v3
      else
        if c7v0 == 2 then
          c7v3 = 0.35
          v12 = c7v3
        else
          if c7v0 == 3 then
            c7v3 = 0.4
            v12 = c7v3
          else
            c7v3 = 0.5
            v12 = c7v3
          end
        end
      end
    end
    c7v3 = 1
    if c7v1 == c7v3 then
      c7v3 = { FROZEN_PCT = nil, DURATION = nil }
      c7v6 = v12
      c7v5 = c7v6 * 100
      c7v4 = math.floor
      c7v4 = c7v4(c7v5)
      c7v3.FROZEN_PCT = c7v4
      c7v4 = v9
      c7v3.DURATION = c7v4
      c7v2 = c7v3
    end
    c7v3 = cjson.encode
    do return c7v3(c7v2) end
  end
  GetAugmentDescriptionInfo = v19
  v19 = function(c8v0, c8v1, c8v2)
    local c8v3, c8v4, c8v5, c8v6, c8v7
    c8v3 = c8v1:DamageControl()
    c8v3 = c8v3:Name__bce68b8b()
    c8v4 = c8v1:GetHealthPercentage()
    c8v5 = 0.25
    if c8v5 < c8v3 then
      c8v5 = 0.5
      if c8v5 < c8v4 then
        c8v5 = 0
        do return c8v5 end
      end
    end
    c8v5 = IsNull
    c8v5 = c8v5(c8v2)
    if c8v5 then
      c8v2 = 1
    end
    c8v5 = gRegion
    c8v7 = ShieldTypes[c8v2]
    c8v5 = c8v5:FindAll(c8v7)
    c8v6 = IsNull
    c8v6 = c8v6(c8v5)
    if not c8v6 then
      c8v6 = #c8v5
      c8v7 = 0
      if c8v7 < c8v6 then
        c8v6 = 0
        do return c8v6 end
      end
    end
    c8v6 = 1.5
    do return c8v6 end
  end
  NpcEvaluateAbility = v19
  v19 = function(c9v0, c9v1)
    local c9v2, c9v3, c9v4, c9v5, c9v6
    c9v2 = c9v1:GetCameraView()
    c9v3 = AngleToDirection
    c9v3 = c9v3(c9v2)
    c9v5 = c9v1:GetSimPosition()
    c9v4 = c9v3 + c9v5
    c9v6 = c9v4.y
    c9v5 = c9v6 + 1.1
    c9v4.y = c9v5
    c9v0:Name__95a49f26(c9v4)
    c9v5 = true
    do return c9v5 end
  end
  EvaluateAbility = v19
  v19 = function(c10v0, c10v1)
    local c10v2, c10v3, c10v4
    c10v2 = v0
    c10v2 = c10v2.IsFightingGame
    c10v2 = c10v2()
    if c10v2 then
      c10v2 = mOwner
      c10v4 = gGameRules
      c10v4 = c10v4:Name__7194a234()
      c10v3 = c10v4 + 100
      c10v2:Name__fd3aedec(c10v3)
    end
    do return end
  end
  InitializeAbility = v19
  v19 = function(c11v0, c11v1, c11v2, c11v3, c11v4, c11v5)
    local c11v6, c11v7, c11v8, c11v9, c11v10, c11v11, c11v12, c11v13, c11v14, c11v15
    if c11v1 == c11v3 then
      c11v10 = Symbol
      c11v11 = "IceShieldCast"
      c11v8 = c11v0:GetResType(c11v10(c11v11))
      c11v9 = EMPTY_SYMBOL
      c11v1:Attach(c11v8, c11v9)
      c11v8 = launchSound
      c11v9 = false
      c11v1:PlaySound(c11v8, c11v9)
    else
      c11v6 = gRegion
      c11v10 = Symbol
      c11v11 = "IceShieldCast"
      c11v8 = c11v0:GetResType(c11v10(c11v11))
      c11v6:CreateEntity(c11v8, c11v4, c11v5, c11v3)
      c11v6 = gRegion
      c11v8 = launchSound
      c11v10 = false
      c11v11 = 0
      c11v6:PlaySound(c11v8, c11v4, c11v10, c11v11)
    end
    c11v6 = gRegion
    c11v6 = c11v6:IsMaster()
    if c11v6 then
      c11v7 = ShieldTypes
      c11v12 = mOwner
      c11v8 = c11v2:GetAbilityLevel(c11v2:Name__b1572999(c11v12:GetType()))
      c11v6 = c11v7[c11v8]
      c11v7 = gRegion
      c11v7 = c11v7:CreateEntity(c11v6, c11v4, c11v5, c11v1)
      c11v8 = IsNull
      c11v8 = c11v8(c11v7)
      if not c11v8 then
        c11v8 = mOwner
        c11v8:AttachAbilityObject(c11v7)
        c11v8 = v1
        c11v8 = c11v8.AttachToMover
        c11v11 = c11v7:GetPosition()
        c11v12 = Vector
        c11v13 = 0
        c11v14 = 0.5
        c11v15 = 0
        c11v12 = c11v12(c11v13, c11v14, c11v15)
        c11v10 = c11v11 + c11v12
        c11v11 = true
        c11v8(c11v7, c11v10, c11v11)
      end
    end
    do return end
  end
  v20 = function(c12v0, c12v1, c12v2, c12v3, c12v4)
    local c12v5, c12v6, c12v7, c12v8, c12v9, c12v10, c12v11, c12v12, c12v13, c12v14, c12v15, c12v16, c12v17, c12v18, c12v19, c12v20
    c12v5 = v15
    c12v5(c12v3)
    c12v5 = v16
    c12v5, c12v6, c12v7, c12v8 = c12v5(c12v1)
    v6 = c12v5
    v10 = c12v6
    v9 = c12v7
    v11 = c12v8
    c12v5 = { maxHealth = nil, shieldRange = nil, invulnDuration = nil, shatterDamage = nil }
    c12v6 = v6
    c12v5.maxHealth = c12v6
    c12v6 = v10
    c12v5.shieldRange = c12v6
    c12v6 = v7
    c12v5.invulnDuration = c12v6
    c12v6 = v11
    c12v5.shatterDamage = c12v6
    c12v6 = c12v0:GetAbilityAugmentLevel()
    c12v7 = c12v0:GetAbilityAugmentType()
    c12v8 = 0
    if c12v8 < c12v6 then
      c12v8 = 1
      if c12v7 == c12v8 then
        c12v8 = 1
        if c12v7 == c12v8 then
          if c12v6 == 1 then
            c12v8 = 0.3
            v12 = c12v8
          else
            if c12v6 == 2 then
              c12v8 = 0.35
              v12 = c12v8
            else
              if c12v6 == 3 then
                c12v8 = 0.4
                v12 = c12v8
              else
                c12v8 = 0.5
                v12 = c12v8
              end
            end
          end
        end
      end
    end
    c12v8 = mOwner
    c12v8 = c12v8:GetUniquePowerIdentifier()
    c12v9 = c12v1:InventoryControl()
    c12v10 = gRegion
    c12v10 = c12v10:IsMaster()
    if c12v10 then
      c12v10 = c12v9:Name__158ab814(c12v8)
      if not c12v10 then
        c12v13 = 369
        c12v14 = 0
        c12v16 = v9
        c12v15 = c12v16 - 3
        c12v16 = mOwner
        c12v16 = c12v16:GetType()
        c12v17 = nil
        c12v18 = 25
        c12v19 = Symbol
        c12v20 = "FrozenSolid"
        c12v19 = c12v19(c12v20)
        c12v20 = 4
        c12v9:Name__90fde101(c12v8, c12v13, c12v14, c12v15, c12v16, c12v17, c12v18, c12v19, c12v20)
      end
    end
    c12v10 = v1
    c12v10 = c12v10.SetAbilityStats
    c12v12 = "IceShield"
    c12v10(c12v0, c12v12, c12v5)
    c12v10 = c12v1:GetCameraView()
    c12v11 = c12v1:MotionControl()
    c12v11:SetTorsoFromView(c12v10)
    c12v11 = v1
    c12v11 = c12v11.PlayAnimAndSuspendUntilEvent
    c12v13 = activateAnim
    c12v14 = "Shield"
    c12v15 = false
    c12v16 = 2
    c12v17 = 1
    c12v18 = true
    c12v11(c12v0, c12v13, c12v14, c12v15, c12v16, c12v17, c12v18)
    c12v11 = IsNull
    c12v11 = c12v11(c12v1:GetAgent())
    if not c12v11 then
      c12v11 = AngleToDirection
      c12v11 = c12v11(c12v10)
      c12v12 = c12v1:GetSimPosition()
      c12v4 = c12v11 + c12v12
      c12v13 = c12v4.y
      c12v12 = c12v13 + 1.1
      c12v4.y = c12v12
    end
    c12v11 = c12v1:GetCameraView()
    c12v12 = 0
    c12v11.pitch = c12v12
    c12v12 = v19
    c12v12(c12v0, c12v1, c12v0, c12v1, c12v4, c12v11)
    do return end
  end
  ActivateAbility = v20
  v20 = function()
    local c13v0, c13v1, c13v2, c13v3, c13v4, c13v5
    c13v0 = _T.CrewShipAbilityInfo.mAbility
    c13v1 = c13v0:GetSuit()
    c13v2 = v15
    c13v2(c13v1:GetAbilityLevel(c13v1:Name__b1572999(c13v0:GetType())))
    c13v2 = v16
    c13v2, c13v3 = c13v2(c13v1:GetAvatarOwner())
    v6 = c13v2
    v10 = c13v3
    c13v2 = _T.CrewShipAbilityInfo
    c13v3 = { Radius = nil, EnergyCost = nil }
    c13v4 = v10
    c13v3.Radius = c13v4
    c13v5 = true
    c13v4 = c13v0:GetActivationEnergyCost(c13v5)
    c13v3.EnergyCost = c13v4
    c13v2.mAbilityInfo = c13v3
    do return end
  end
  CrewShipInfo = v20
  v20 = function(c14v0, c14v1, c14v2, c14v3, c14v4, c14v5, c14v6)
    local c14v7, c14v8, c14v9, c14v10, c14v11, c14v12, c14v13, c14v14, c14v15
    c14v7 = mOwner
    c14v7 = c14v7:GetType()
    c14v7 = c14v7:GetName()
    c14v8 = v1
    c14v8 = c14v8.CrewShipAbilityLock
    c14v8 = c14v8(c14v7)
    if c14v8 then
      c14v8 = true
      do return c14v8 end
    end
    c14v8 = v15
    c14v8(c14v4)
    c14v8 = v16
    c14v8, c14v9, c14v10, c14v11 = c14v8(c14v3)
    v6 = c14v8
    v10 = c14v9
    v9 = c14v10
    v11 = c14v11
    c14v8 = { maxHealth = nil, shieldRange = nil, invulnDuration = nil, shatterDamage = nil }
    c14v9 = v6
    c14v8.maxHealth = c14v9
    c14v9 = v10
    c14v8.shieldRange = c14v9
    c14v9 = v7
    c14v8.invulnDuration = c14v9
    c14v9 = v11
    c14v8.shatterDamage = c14v9
    c14v9 = v1
    c14v9 = c14v9.SetAbilityStats
    c14v11 = "IceShield"
    c14v9(c14v1, c14v11, c14v8)
    c14v9 = v19
    c14v12 = Rotation
    c14v13 = Random
    c14v14 = 0
    c14v15 = 360
    c14v13 = c14v13(c14v14, c14v15)
    c14v14 = 0
    c14v15 = 0
    c14v9(c14v1, c14v0, c14v2, c14v3, c14v6, c14v12(c14v13, c14v14, c14v15))
    c14v9 = v1
    c14v9 = c14v9.CrewShipAbilityUnlock
    c14v9(c14v7)
    do return end
  end
  CrewShipActivate = v20
  v20 = function(c15v0, c15v1)
    local c15v2, c15v3, c15v4, c15v5
    c15v4 = 1
    c15v2 = #c15v1
    c15v3 = 1
    for __renovice_for_0_0 = c15v4, c15v2, c15v3 do
      c15v5 = c15v1[__renovice_for_0_0]
      if c15v5 ~= c15v0 then
        continue
      end
      c15v5 = true
      do return c15v5 end
    end
    c15v2 = false
    do return c15v2 end
  end
  v21 = function(c16v0, c16v1, c16v2)
    local c16v3, c16v4, c16v5, c16v6, c16v7, c16v8, c16v9, c16v10
    c16v3 = c16v0:GetCreator()
    c16v4 = IsNull
    c16v4 = c16v4(c16v3)
    if c16v4 then
      do return end
    end
    c16v4 = c16v3:InventoryControl()
    c16v4 = c16v4:GetActivePowerSuit()
    c16v5 = IsNull
    c16v5 = c16v5(c16v4)
    if c16v5 then
      do return end
    end
    c16v5 = gRegion
    c16v7 = iceShieldDestroy
    c16v8 = c16v0:GetPosition()
    c16v9 = c16v0:GetRotation()
    c16v5 = c16v5:CreateEntity(c16v7, c16v8, c16v9, c16v3)
    c16v5:SetMeshScale(c16v0:GetMeshScale())
    c16v6 = c16v3:ReplicaLocallyAuthoritative()
    if c16v6 then
      c16v6 = 0
      if c16v6 < c16v1 then
        c16v6 = Engine.RadialDamageData
        c16v6 = c16v6()
        c16v6:SetSource(c16v3)
        c16v6:SetOrigin(c16v0:GetPosition())
        c16v6:SetBaseAmount(c16v2)
        c16v7 = c16v1 * 1.3
        c16v6.radius = c16v7
        c16v9 = 4
        c16v10 = 1
        c16v6:SetDamagePct(c16v9, c16v10)
        c16v6.ignoreEntity = c16v0
        c16v6:SetSourceObject(c16v4)
        c16v9 = 20
        c16v10 = true
        c16v6:SetProc(c16v9, c16v10)
        c16v9 = 4
        c16v10 = 3
        c16v6:SetProcCount(c16v9, c16v10)
        c16v7 = false
        c16v6.checkForCover = c16v7
        c16v7 = false
        c16v6.staticCoverOnly = c16v7
        c16v7 = 0
        c16v6.fallOff = c16v7
        c16v7 = false
        c16v6.hostAuthoritative = c16v7
        c16v7 = gRegion
        c16v7:RadialDamage(c16v6)
      end
    end
    do return end
  end
  v22 = function(c17v0)
    local c17v1, c17v2, c17v3, c17v4, c17v5, c17v6, c17v7, c17v8, c17v9, c17v10, c17v11, c17v12, c17v13, c17v14, c17v15, c17v16, c17v17, c17v18, c17v19, c17v20, c17v21, c17v22, c17v23, c17v24, c17v25, c17v26, c17v27, c17v28, c17v29, c17v30, c17v31, c17v32, c17v33, c17v34, c17v35, c17v36, c17v37, c17v38, c17v39, c17v40, c17v41, c17v42
    c17v26 = 1
    c17v22 = nil
    c17v24 = #c17v22
    c17v25 = 1
    for __renovice_for_0_0 = c17v26, c17v24, c17v25 do
      c17v28 = c17v22[__renovice_for_0_0]
      c17v27 = IsNull
      c17v27 = c17v27(c17v28)
      if c17v27 then
        continue
      end
      c17v27 = v0
      c17v27 = c17v27.ApplyPvPSlow
      c17v28 = c17v22[__renovice_for_0_0]
      c17v29 = v8
      c17v30 = false
      c17v27(c17v28, c17v29, c17v30)
      c17v27 = c17v22[__renovice_for_0_0]
      c17v29 = freezeProjPvP
      c17v27 = c17v27:GetAttachment(c17v29)
      c17v28 = IsNull
      c17v28 = c17v28(c17v27)
      if c17v28 then
        continue
      end
      c17v27:Destroy()
    end
    c17v9 = 2
    c17v2 = nil
    c17v7 = c17v2:Name__06c22bff(c17v9)
    c17v7 = nil
    c17v10 = shieldCenterDeco
    c17v11 = EMPTY_SYMBOL
    c17v12 = ZERO_VECTOR
    c17v13 = ZERO_ROTATION
    c17v0:Attach(c17v10, c17v11, c17v12, c17v13, c17v2)
    c17v8 = v1
    c17v8 = c17v8.WaitForAbilityStats
    c17v10 = "IceShield"
    c17v11 = 2
    c17v12 = true
    c17v8 = c17v8(c17v2, c17v10, c17v11, c17v12)
    c17v9 = IsNull
    c17v9 = c17v9(c17v2)
    c17v9 = IsNull
    c17v1 = nil
    c17v9 = c17v9(c17v1)
    c17v9 = IsNull
    c17v9 = c17v9(c17v8)
    c17v13 = gRegion
    c17v15 = gTennoAvatarType
    local __renovice_state_0 = 0
    c17v4 = nil
    c17v13 = c17v13:FindAll(c17v15, c17v4, __renovice_state_0, c17v11)
    c17v16 = 1
    c17v14 = #c17v13
    c17v15 = 1
    for __renovice_for_1_0 = c17v16, c17v14, c17v15 do
      __renovice_state_0 = c17v13[__renovice_for_1_0]
      c17v17 = __renovice_state_0:Layertrackers()
      if not c17v17 then
        continue
      end
      c17v17 = v0
      c17v17 = c17v17.IsValidPvpTarget
      c17v17 = c17v17(c17v1, __renovice_state_0)
      if not c17v17 then
        continue
      end
      c17v17 = __renovice_state_0:MotionControl()
      c17v19 = 100
      c17v17:Name__3eb7a19c(c17v19)
      c17v18 = __renovice_state_0:GetPosition()
      c17v19 = c17v1:GetPosition()
      c17v17 = c17v18 - c17v19
      c17v18 = Length
      c17v18 = c17v18(c17v17)
      c17v19 = __renovice_state_0:MotionControl()
      c17v23 = c17v17 / c17v18
      c17v22 = c17v23 * 15
      c17v24 = 0.4
      c17v26 = c17v18 / c17v11
      c17v25 = 1 - c17v26
      c17v23 = math.max
      c17v23 = c17v23(c17v24, c17v25)
      c17v21 = c17v22 * c17v23
      c17v19:SetPushVelocity(c17v21)
    end
    c17v9 = v10
    c17v10 = c17v8.maxHealth
    c17v11 = c17v8.shieldRange
    c17v12 = c17v8.shatterDamage
    c17v13 = c17v8.invulnDuration
    v7 = c17v13
    c17v3 = nil
    if c17v3 then
      c17v0:MakeVulnerable()
      c17v15 = false
      c17v0:SetCanDie(c17v15)
      c17v15 = 1000000
      c17v16 = true
      c17v0:SetHealth(c17v15, c17v16)
    end
    c17v13 = v0
    c17v13 = c17v13.IsPvpEnabled
    c17v13 = c17v13()
    c17v3 = 1
    c17v0:SetDissolve(c17v3)
    c17v1 = c17v0:GetCreator()
    c17v2 = IsNull
    c17v2 = c17v2(c17v1)
    if c17v2 then
      c17v2 = gRegion
      c17v2 = c17v2:IsMaster()
      if c17v2 then
        c17v0:Destroy()
      end
      do return end
    end
    c17v2 = c17v1:InventoryControl()
    c17v2 = c17v2:GetActivePowerSuit()
    c17v3 = IsNull
    c17v3 = c17v3(c17v2)
    if c17v3 then
      c17v3 = gRegion
      c17v3 = c17v3:IsMaster()
      if c17v3 then
        c17v2:Destroy()
      end
      do return end
    end
    c17v2:ApplyEnergyColor(c17v0)
    c17v3 = gRegion
    c17v3 = c17v3:IsMaster()
    c17v4 = c17v0:GetPosition()
    c17v5 = c17v1:GetFaction()
    c17v8 = gCrewShipType
    c17v6 = c17v2:IsA(c17v8)
    if c17v7 then
      if c17v3 then
        c17v0:Destroy()
      end
      do return end
    end
    c17v13 = gRegion
    c17v15 = gLotusNpcAvatarType
    __renovice_state_0 = 0
    c17v13 = c17v13:FindAll(c17v15, c17v4, __renovice_state_0, c17v11)
    c17v14 = ipairs
    c17v14, c17v15, c17v16 = c17v14(c17v13)
    for __renovice_for_2_0, __renovice_for_2_1 in c17v14, c17v15, c17v16 do
      c17v18 = __renovice_for_2_1:IsFactionFriendly(c17v5)
      if c17v18 then
        continue
      end
      c17v18 = __renovice_for_2_1:IsKilled()
      if c17v18 then
        continue
      end
      c17v20 = 11
      c17v18 = __renovice_for_2_1:HasAbilityResistance(c17v20)
      if not c17v18 then
        c17v18 = __renovice_for_2_1:MotionControl()
        c17v20 = 100
        c17v18:Name__3eb7a19c(c17v20)
        c17v19 = __renovice_for_2_1:GetPosition()
        c17v20 = c17v0:GetPosition()
        c17v18 = c17v19 - c17v20
        c17v19 = Length
        c17v19 = c17v19(c17v18)
        c17v20 = __renovice_for_2_1:MotionControl()
        c17v25 = Vector
        c17v26 = 0
        c17v27 = 0.25
        c17v28 = 0
        c17v25 = c17v25(c17v26, c17v27, c17v28)
        c17v26 = c17v18 / c17v19
        c17v24 = c17v25 + c17v26
        c17v23 = c17v24 * 45
        c17v25 = 0.4
        c17v27 = c17v19 / c17v11
        c17v26 = 1 - c17v27
        c17v24 = math.max
        c17v24 = c17v24(c17v25, c17v26)
        c17v22 = c17v23 * c17v24
        c17v20:SetPushVelocity(c17v22)
      end
      c17v18 = Engine.DamageData
      c17v18 = c17v18()
      c17v18:SetSource(c17v1)
      c17v18:SetSourceObject(c17v2)
      c17v18:Name__2cc47071(c17v7)
      c17v19 = __renovice_for_2_1:DamageControl()
      c17v24 = 4
      c17v22 = c17v19:Name__30cbc02e(c17v24, c17v18)
      c17v25 = 4
      c17v23 = c17v19:Name__ff67e37d(c17v25)
      c17v21 = c17v22 - c17v23
      c17v22 = 0
      c17v20 = math.max
      c17v20 = c17v20(c17v21, c17v22)
      c17v23 = 4
      c17v18:SetProcCount(c17v23, c17v20)
      __renovice_for_2_1:DamageDD(c17v18)
    end
    for __renovice_for_3_0, __renovice_for_3_1 in c17v14, c17v15, c17v16 do
    end
    c17v13 = Sleep
    c17v14 = 0
    c17v13(c17v14)
    c17v13 = c17v10
    c17v14 = IsNull
    c17v14 = c17v14(c17v2)
    if not c17v14 then
      c17v15 = c17v0:GetMeshScale()
      c17v16 = c17v11 / c17v9
      c17v14 = c17v15 * c17v16
      c17v0:SetMeshScale(c17v14)
      c17v15 = Effects.Name__dfda2338
      __renovice_state_0 = Vector
      c17v17 = 5 * c17v14
      c17v18 = 5 * c17v14
      c17v19 = 5 * c17v14
      c17v15(c17v0, __renovice_state_0(c17v17, c17v18, c17v19))
      __renovice_state_0 = gDecorationType
      c17v15 = c17v0:GetAllAttachments(__renovice_state_0)
      c17v17 = 1
      c17v16 = #c17v15
      __renovice_state_0 = 1
      for __renovice_for_4_0 = c17v17, c17v16, __renovice_state_0 do
        c17v18 = c17v15[__renovice_for_4_0]
        c17v18:SetMeshScale(c17v14)
      end
    end
    c17v14 = c17v1:GetInstance()
    c17v16 = _T.frostShield
    c17v15 = IsNull
    c17v15 = c17v15(c17v16)
    if c17v15 then
      c17v15 = _T
      c17v16 = {}
      c17v15.frostShield = c17v16
    end
    __renovice_state_0 = _T.frostShield
    c17v16 = __renovice_state_0[c17v14]
    c17v15 = IsNull
    c17v15 = c17v15(c17v16)
    if c17v15 then
      c17v15 = _T.frostShield
      c17v16 = {}
      c17v15[c17v14] = c17v16
    end
    c17v18 = _T.frostShield
    c17v17 = c17v18[c17v14]
    __renovice_state_0 = #c17v17
    c17v15 = 1
    c17v16 = -1
    if not ((c17v16 > 0 and __renovice_state_0 > c17v15) or (c17v16 < 0 and __renovice_state_0 < c17v15)) then
      c17v19 = _T.frostShield
      c17v18 = c17v19[c17v14]
      c17v17 = c17v18[__renovice_state_0]
      c17v17 = c17v17.shield
      c17v18 = IsNull
      c17v18 = c17v18(c17v17)
      c17v18 = c17v17:GetHealth()
      c17v19 = 0
      c17v18 = table.remove
      c17v20 = _T.frostShield
      c17v19 = c17v20[c17v14]
      c17v18(c17v19, __renovice_state_0)
      if c17v3 then
        c17v18 = c17v17:DistanceToPoint(c17v4)
        if c17v18 <= c17v11 then
          c17v21 = _T.frostShield
          c17v20 = c17v21[c17v14]
          c17v19 = c17v20[__renovice_state_0]
          c17v19 = c17v19.reinforceHealth
          c17v18 = math.min
          c17v18 = c17v18(c17v19, c17v17:GetHealth())
          c17v10 = c17v10 + c17v18
          c17v20 = 0
          c17v17:SetHealth(c17v20)
          c17v18 = table.remove
          c17v20 = _T.frostShield
          c17v19 = c17v20[c17v14]
          c17v18(c17v19, __renovice_state_0)
        end
      end
    end
    if c17v3 then
      c17v15 = 4
      c17v16 = v0
      c17v16 = c17v16.IsPvpEnabled
      c17v16 = c17v16()
      if c17v16 then
        c17v15 = 1
      end
      while true do
        c17v17 = _T.frostShield
        __renovice_state_0 = c17v17[c17v14]
        c17v16 = #__renovice_state_0
        if not (c17v15 <= c17v16) then break end
        c17v17 = _T.frostShield
        __renovice_state_0 = c17v17[c17v14]
        c17v16 = __renovice_state_0[1]
        c17v16 = c17v16.shield
        c17v17 = 0
        c17v16:SetHealth(c17v17)
        c17v16 = table.remove
        c17v17 = _T.frostShield
        __renovice_state_0 = c17v17[c17v14]
        c17v17 = 1
        c17v16(__renovice_state_0, c17v17)
      end
    end
    __renovice_state_0 = _T.frostShield
    c17v16 = __renovice_state_0[c17v14]
    __renovice_state_0 = { shield = nil, reinforceHealth = nil, radius = nil }
    __renovice_state_0.shield = c17v0
    __renovice_state_0.reinforceHealth = c17v10
    __renovice_state_0.radius = c17v11
    c17v15 = table.insert
    c17v15(c17v16, __renovice_state_0)
    c17v15 = 0
    c17v16 = false
    __renovice_state_0 = IsNull
    __renovice_state_0 = __renovice_state_0(c17v2)
    if (not __renovice_state_0 and not c17v6) then
      c17v18 = 2
      __renovice_state_0 = c17v2:GetAbilityAugmentLevel(c17v18)
      c17v19 = 2
      c17v17 = c17v2:GetAbilityAugmentType(c17v19)
      c17v19 = _T.slamGlobe
      if c17v19 ~= nil then
        c17v20 = next
        c17v21 = _T.slamGlobe
        c17v20 = c17v20(c17v21)
        if c17v20 == nil then
          c17v19 = false
        else
          c17v19 = true
        end
        c17v18 = c17v19
        if c17v18 then
          c17v22 = v13
          c17v18 = c17v2:IsA(c17v22)
        end
      else
        c17v18 = false
      end
      if c17v18 then
        c17v15 = 0.5
        c17v16 = true
      else
        c17v18 = 0
        if c17v18 < __renovice_state_0 then
          c17v18 = 1
          if c17v17 == c17v18 then
            c17v18 = 1
            if c17v17 == c17v18 then
              if __renovice_state_0 == 1 then
                c17v18 = 0.3
                v12 = c17v18
              else
                if __renovice_state_0 == 2 then
                  c17v18 = 0.35
                  v12 = c17v18
                else
                  if __renovice_state_0 == 3 then
                    c17v18 = 0.4
                    v12 = c17v18
                  else
                    c17v18 = 0.5
                    v12 = c17v18
                  end
                end
              end
            end
            c17v15 = v12
            c17v16 = true
          end
        end
      end
      if c17v16 then
        c17v20 = augmentOneDeco
        c17v21 = EMPTY_SYMBOL
        c17v22 = Vector
        c17v23 = 0
        c17v24 = -0.5
        c17v25 = 0
        c17v22 = c17v22(c17v23, c17v24, c17v25)
        c17v23 = ZERO_ROTATION
        c17v18 = c17v0:Attach(c17v20, c17v21, c17v22, c17v23, c17v2)
        c17v19 = IsNull
        c17v19 = c17v19(c17v18)
        if not c17v19 then
          c17v22 = 4.4 * c17v11
          c17v21 = c17v22 / 5
          c17v18:SetMeshScale(c17v21)
        end
      end
    end
    __renovice_state_0 = 1
    while true do
      c17v17 = 0
      if not (c17v17 < __renovice_state_0) then break end
      c17v0:SetDissolve(__renovice_state_0)
      c17v18 = 0
      c17v21 = DeltaTime
      c17v21 = c17v21()
      c17v20 = c17v21 * 3.33
      c17v19 = __renovice_state_0 - c17v20
      c17v17 = math.max
      __renovice_state_0 = c17v17(c17v18, c17v19)
      c17v17 = Sleep
      c17v18 = 0
      c17v17(c17v18)
    end
    c17v19 = 0
    c17v0:SetDissolve(c17v19)
    c17v17 = false
    c17v18 = false
    c17v19 = 0
    c17v20 = false
    c17v21 = {}
    c17v22 = {}
    c17v23 = 0
    c17v24 = IsNull
    c17v24 = c17v24(c17v0)
    c17v24 = IsNull
    c17v24 = c17v24(c17v1)
    c17v24 = c17v1:IsKilled()
    c17v34 = nil
    c17v35 = c17v34.enemy
    c17v36 = IsNull
    c17v36 = c17v36(c17v35)
    c17v39 = 1
    c17v37 = #c17v27
    c17v38 = 1
    for __renovice_for_5_0 = c17v39, c17v37, c17v38 do
      c17v40 = c17v27[__renovice_for_5_0]
      if c17v40 == c17v35 then break end
    end
    c17v36 = true
    c17v36 = false
    c17v38 = 0
    c17v36 = c17v35:HasAbilityResistance(c17v38)
    c17v36 = table.insert
    c17v33 = nil
    c17v36(c17v29, c17v33)
    c17v32 = nil
    c17v34 = c17v22[c17v32]
    c17v33 = IsNull
    c17v33 = c17v33(c17v34)
    c17v34 = c17v22[c17v32]
    c17v35 = c17v28
    c17v38 = 1
    c17v36 = #c17v35
    c17v37 = 1
    c17v39 = c17v35[c17v38]
    c17v33 = true
    c17v33 = false
    c17v33 = c17v22[c17v32]
    c17v35 = 0
    c17v33 = c17v33:HasAbilityResistance(c17v35)
    c17v33 = c17v22[c17v32]
    c17v33 = c17v33:DamageControl()
    c17v35 = 4
    c17v33 = c17v33:IsProcActive(c17v35)
    c17v32 = 1
    c17v30 = #c17v28
    c17v31 = 1
    c17v33 = v0
    c17v33 = c17v33.IsValidPvpTarget
    c17v35 = c17v28[c17v32]
    c17v33 = c17v33(c17v1, c17v35)
    c17v33 = c17v28[c17v32]
    c17v33 = c17v33:DamageControl()
    c17v35 = 4
    c17v33 = c17v33:IsProcActive(c17v35)
    c17v34 = c17v28[c17v32]
    c17v37 = 1
    c17v35 = #c17v22
    c17v36 = 1
    c17v38 = c17v22[c17v37]
    c17v33 = true
    c17v33 = false
    c17v27 = Sleep
    c17v28 = 0
    c17v27(c17v28)
    c17v28 = v7
    c17v29 = DeltaTime
    c17v29 = c17v29()
    c17v27 = c17v28 - c17v29
    v7 = c17v27
    c17v27 = DeltaTime
    c17v27 = c17v27()
    c17v19 = c17v19 - c17v27
    if not c17v33 then
      c17v33 = v0
      c17v33 = c17v33.ApplyPvPSlow
      c17v34 = c17v28[c17v32]
      c17v35 = v8
      c17v36 = true
      c17v33(c17v34, c17v35, c17v36)
      c17v33 = c17v28[c17v32]
      c17v35 = freezeProjPvP
      c17v36 = EMPTY_SYMBOL
      c17v33:Attach(c17v35, c17v36)
      c17v35 = c17v28[c17v32]
      c17v33 = table.insert
      c17v33(c17v22, c17v35)
    end
    c17v27 = gRegion
    c17v29 = gLotusNpcAvatarType
    c17v31 = 0
    c17v27 = c17v27:FindAll(c17v29, c17v4, c17v31, c17v11)
    c17v28 = nil
    c17v29 = v0
    c17v29 = c17v29.IsPvpEnabled
    c17v29 = c17v29()
    if c17v29 then
      c17v29 = gRegion
      c17v31 = gTennoAvatarType
      c17v33 = 0
      c17v28 = c17v29:FindAll(c17v31, c17v4, c17v33, c17v11)
    end
    c17v29 = {}
    c17v30 = pairs
    c17v30, c17v31, c17v32 = c17v30(c17v21)
    c17v36 = c17v34.timer
    c17v37 = 0
    if c17v37 < c17v36 then
      c17v37 = c17v34.timer
      c17v38 = DeltaTime
      c17v38 = c17v38()
      c17v36 = c17v37 - c17v38
      c17v34.timer = c17v36
    end
    c17v36 = c17v34.timer
    c17v37 = 0
    if c17v36 <= c17v37 then
      c17v36 = c17v35:IsFrozenSolid()
      if not c17v36 then
        c17v36 = 3
        c17v34.timer = c17v36
        c17v36 = Engine.DamageData
        c17v36 = c17v36()
        c17v39 = 4
        c17v40 = true
        c17v36:SetProc(c17v39, c17v40)
        c17v36:SetSource(c17v1)
        c17v36:SetSourceObject(c17v2)
        c17v36:Name__2cc47071(c17v7)
        c17v37 = 7
        c17v36.hitType = c17v37
        c17v35:DamageDD(c17v36)
      end
    end
    c17v30 = ipairs
    c17v30, c17v31, c17v32 = c17v30(c17v29)
    for __renovice_for_6_0, __renovice_for_6_1 in c17v30, c17v31, c17v32 do
      c17v35 = nil
      c17v21[__renovice_for_6_1] = c17v35
    end
    c17v32 = #c17v22
    c17v30 = 1
    c17v31 = -1
    c17v34 = c17v22[c17v32]
    c17v33 = IsNull
    c17v33 = c17v33(c17v34)
    if not c17v33 then
      c17v33 = v0
      c17v33 = c17v33.ApplyPvPSlow
      c17v34 = c17v22[c17v32]
      c17v35 = v8
      c17v36 = false
      c17v33(c17v34, c17v35, c17v36)
      c17v33 = c17v22[c17v32]
      c17v35 = freezeProjPvP
      c17v33 = c17v33:GetAttachment(c17v35)
      c17v34 = IsNull
      c17v34 = c17v34(c17v33)
      if not c17v34 then
        c17v33:Destroy()
      end
    end
    c17v33 = table.remove
    c17v33(c17v22, c17v32)
    c17v26 = 1
    c17v27 = c17v24 / c17v13
    c17v25 = math.min
    c17v25 = c17v25(c17v26, c17v27)
    c17v26 = c17v1:Layertrackers()
    if (c17v26 and not c17v6) then
      c17v26 = _T.SetAbilityTimer
      c17v29 = c17v25 * 100
      c17v30 = true
      c17v26(c17v7, c17v1, c17v29, c17v30)
    end
    c17v28 = v3
    c17v31 = 1 - c17v25
    c17v32 = 1 - c17v25
    c17v30 = c17v31 * c17v32
    c17v29 = c17v30 * 2
    c17v0:SetMaterialParam(c17v28, c17v29)
    c17v27 = 1
    c17v28 = c17v25 / 0.3
    c17v26 = math.min
    c17v26 = c17v26(c17v27, c17v28)
    c17v29 = v4
    c17v30 = 1
    c17v31 = 0
    c17v0:SetMaterialParam(c17v29, c17v30, c17v31, c17v26)
    c17v25 = 0.25
    c17v27 = v7
    c17v28 = 0
    if c17v28 < c17v27 then
      c17v32 = Frac
      c17v33 = v7
      c17v32 = c17v32(c17v33)
      c17v31 = c17v32 * 3.141592653589793
      c17v30 = c17v31 * 2
      c17v29 = math.sin
      c17v29 = c17v29(c17v30)
      c17v28 = math.abs
      c17v28 = c17v28(c17v29)
      c17v27 = c17v28 * 1.5
      c17v25 = c17v25 + c17v27
    end
    c17v29 = v2
    c17v0:SetMaterialParam(c17v29, c17v25)
    c17v30 = ipairs
    c17v30, c17v31, c17v32 = c17v30(c17v27)
    for __renovice_for_7_0, __renovice_for_7_1 in c17v30, c17v31, c17v32 do
      c17v35 = __renovice_for_7_1:IsFactionFriendly(c17v5)
      if c17v35 then
        continue
      end
      c17v35 = __renovice_for_7_1:IsKilled()
      if c17v35 then
        continue
      end
      c17v36 = __renovice_for_7_1:GetInstance()
      c17v35 = c17v21[c17v36]
      if c17v35 ~= nil then
        continue
      end
      c17v37 = 0
      c17v35 = __renovice_for_7_1:HasAbilityResistance(c17v37)
      if c17v35 then
        if not c17v18 then
          __renovice_for_7_1:Name__8f4b89a1(c17v1)
          c17v18 = true
        end
        continue
      end
      c17v35 = __renovice_for_7_1:GetInstance()
      c17v36 = { enemy = nil, timer = 3 }
      c17v36.enemy = __renovice_for_7_1
      c17v21[c17v35] = c17v36
      c17v35 = __renovice_for_7_1:DamageControl()
      c17v36 = Engine.DamageData
      c17v36 = c17v36()
      c17v36:SetSource(c17v1)
      c17v36:SetSourceObject(c17v2)
      c17v36:Name__2cc47071(c17v7)
      c17v37 = 1
      c17v38 = math.random
      c17v38 = c17v38()
      if c17v38 < c17v15 then
        c17v41 = 4
        c17v39 = c17v35:Name__30cbc02e(c17v41, c17v36)
        c17v42 = 4
        c17v40 = c17v35:Name__ff67e37d(c17v42)
        c17v38 = c17v39 - c17v40
        c17v37 = c17v38
      end
      c17v40 = 4
      c17v36:SetProcCount(c17v40, c17v37)
      __renovice_for_7_1:DamageDD(c17v36)
    end
    c17v30 = v0
    c17v30 = c17v30.IsPvpEnabled
    c17v30 = c17v30()
    c17v24 = 0
    if c17v19 <= c17v24 then
      c17v25 = gGameRules
      c17v24 = IsNull
      c17v24 = c17v24(c17v25)
      if not c17v24 then
        c17v24 = gGameRules
        c17v27 = c17v0:GetPosition()
        c17v20 = c17v24:Name__85c02e25(c17v1, c17v27, c17v11)
        c17v19 = 0.2
      end
    end
    if ((c17v3 and c17v20) and c17v17) then
      c17v25 = c17v13 * 0.2
      c17v26 = DeltaTime
      c17v26 = c17v26()
      c17v24 = c17v25 * c17v26
      c17v29 = c17v0:GetHealth()
      c17v28 = c17v29 - c17v24
      c17v29 = 0
      c17v27 = math.max
      c17v27 = c17v27(c17v28, c17v29)
      c17v0:SetHealth(c17v27)
    end
    c17v24 = v7
    c17v25 = 0
    if c17v24 <= c17v25 then
      if not c17v17 then
        c17v24 = c17v0:GetHealth()
        c17v25 = 0
        if c17v25 < c17v24 then
          c17v26 = c17v10 + c17v23
          c17v27 = true
          c17v0:SetHealth(c17v26, c17v27)
        end
        c17v17 = true
        c17v26 = true
        c17v0:SetCanDie(c17v26)
      end
      c17v24 = c17v0:GetHealth()
      c17v25 = 1000000
      if c17v24 <= c17v25 then
        c17v24 = math.max
        c17v13 = c17v24(c17v13, c17v0:GetHealth())
      end
    else
      if c17v3 then
        c17v24 = c17v0:GetHealth()
        c17v25 = 0
        if c17v25 < c17v24 then
          if not c17v20 then
            c17v25 = c17v0:GetHealth()
            c17v24 = 1000000 - c17v25
            c17v23 = c17v23 + c17v24
          end
          c17v26 = 1000000
          c17v0:SetHealth(c17v26)
        end
      end
    end
    c17v24 = c17v0:GetHealth()
    c17v25 = 0
    c17v24 = IsNull
    c17v24 = c17v24(c17v1)
    if not c17v24 then
      c17v24 = c17v1:Layertrackers()
      if (c17v24 and not c17v6) then
        c17v24 = _T.SetAbilityTimer
        c17v27 = 0
        c17v28 = true
        c17v24(c17v7, c17v1, c17v27, c17v28)
      end
    end
    c17v24 = v21
    c17v24(c17v0, c17v11, c17v12)
    while true do
      c17v24 = 1
      if not (__renovice_state_0 < c17v24) then break end
      c17v24 = IsNull
      c17v24 = c17v24(c17v0)
      if c17v24 then break end
      c17v0:SetDissolve(__renovice_state_0)
      c17v25 = DeltaTime
      c17v25 = c17v25()
      c17v24 = c17v25 * 2
      __renovice_state_0 = __renovice_state_0 + c17v24
      c17v24 = Sleep
      c17v25 = 0
      c17v24(c17v25)
    end
    if c17v3 then
      c17v24 = IsNull
      c17v24 = c17v24(c17v0)
      if not c17v24 then
        c17v0:Destroy()
      end
    end
    do return end
  end
  Deploy = v22
  do return end
