  local v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19
  v0 = Name__9ff10ded
  v1 = "Lotus.Powersuits.PowersuitAbilities.PVPLib"
  v0 = v0(v1)
  v1 = Name__9ff10ded
  v2 = "Lotus.Scripts.Libs.AbilitiesLib"
  v1 = v1(v2)
  v2 = Name__9ff10ded
  v3 = "Lotus.Interface.SequencerUtilities"
  v2 = v2(v3)
  v3 = Name__9ff10ded
  v4 = "EE.Interface.Utilities"
  v3 = v3(v4)
  v4 = 5
  v5 = 5
  v6 = 15
  v7 = 0.3
  v8 = Name__3df6d685
  v9 = "extrudeLength"
  v8 = v8(v9)
  v9 = Name__3df6d685
  v10 = "UnlitAtten"
  v9 = v9(v10)
  v11 = Name__3df6d685
  v12 = "waveOne"
  v11 = v11(v12)
  v12 = Name__3df6d685
  v13 = "waveTwo"
  v12 = v12(v13)
  v13 = Name__3df6d685
  v14 = "waveThree"
  v13 = v13(v14)
  v14 = Name__3df6d685
  v15 = "waveFour"
  v10 = {v11, v12, v13, v14(v15)}
  v11 = Name__3df6d685
  v12 = "uvOffset"
  v11 = v11(v12)
  v12 = Name__3df6d685
  v13 = "extrudeScales"
  v12 = v12(v13)
  v13 = function(c1v0)
    local c1v1
    c1v1 = v0
    c1v1 = c1v1.Name__4369ab26
    c1v1 = c1v1()
    if not c1v1 then
      if c1v0 == 1 then
        c1v1 = 1
        v4 = c1v1
        c1v1 = 5
        v5 = c1v1
        c1v1 = 8
        v6 = c1v1
        do return end
      end
      if c1v0 == 2 then
        c1v1 = 1.5
        v4 = c1v1
        c1v1 = 6
        v5 = c1v1
        c1v1 = 12
        v6 = c1v1
        do return end
      end
      if c1v0 == 3 then
        c1v1 = 2
        v4 = c1v1
        c1v1 = 8
        v5 = c1v1
        c1v1 = 16
        v6 = c1v1
        do return end
      end
      c1v1 = 2.5
      v4 = c1v1
      c1v1 = 10
      v5 = c1v1
      c1v1 = 20
      v6 = c1v1
      do return end
    end
    c1v1 = v0
    c1v1 = c1v1.Name__a34fa566
    c1v1 = c1v1()
    if c1v1 then
      c1v1 = 4
      v5 = c1v1
      c1v1 = 6
      v6 = c1v1
      do return end
    end
    if c1v0 == 1 then
      c1v1 = 0.04
      v4 = c1v1
      c1v1 = 1
      v5 = c1v1
      c1v1 = 14
      v6 = c1v1
      do return end
    end
    if c1v0 == 2 then
      c1v1 = 0.06
      v4 = c1v1
      c1v1 = 2
      v5 = c1v1
      c1v1 = 16
      v6 = c1v1
      do return end
    end
    if c1v0 == 3 then
      c1v1 = 0.08
      v4 = c1v1
      c1v1 = 3
      v5 = c1v1
      c1v1 = 18
      v6 = c1v1
      do return end
    end
    c1v1 = 0.1
    v4 = c1v1
    c1v1 = 4
    v5 = c1v1
    c1v1 = 20
    v6 = c1v1
    do return end
  end
  v14 = function(c2v0)
    local c2v1, c2v2, c2v3, c2v4, c2v5, c2v6, c2v7, c2v8, c2v9
    c2v1 = Name__5ebaa8da.Name__b78c546f
    c2v2 = v4
    c2v1 = c2v1(c2v2)
    c2v2 = v5
    c2v3 = v6
    c2v4 = Name__6514b208
    c2v4 = c2v4(c2v0)
    if not c2v4 then
      c2v4 = c2v0:Name__682cbf57()
      c2v5 = c2v4:Name__b2e22fcd()
      c2v6 = Name__6514b208
      c2v6 = c2v6(c2v5)
      if not c2v6 then
        c2v8 = 10
        c2v9 = c2v5:Name__bab6c411()
        c2v4:Name__7101e8b5(c2v1, c2v8, c2v9, c2v5)
        c2v7 = v5
        c2v8 = 9
        c2v9 = c2v5:Name__bab6c411()
        c2v2 = c2v4:Name__d7d71bec(c2v7, c2v8, c2v9, c2v5)
        c2v7 = v6
        c2v8 = 3
        c2v9 = c2v5:Name__bab6c411()
        c2v3 = c2v4:Name__d7d71bec(c2v7, c2v8, c2v9, c2v5)
      end
    end
    do return c2v1, c2v2, c2v3 end
  end
  v15 = function(c3v0, c3v1)
    local c3v2
    c3v2 = 1
    if c3v1 == c3v2 then
      if c3v0 == 1 then
        c3v2 = 0.35
        v7 = c3v2
        do return end
      end
      if c3v0 == 2 then
        c3v2 = 0.5
        v7 = c3v2
        do return end
      end
      if c3v0 == 3 then
        c3v2 = 0.65
        v7 = c3v2
        do return end
      end
      c3v2 = 0.8
      v7 = c3v2
    end
    do return end
  end
  v16 = function(c4v0)
    local c4v1, c4v2, c4v3, c4v4, c4v5, c4v6, c4v7, c4v8, c4v9
    c4v1 = Name__9828c6d9.AbilityLevelQueryParms.Avatar
    c4v2 = Name__6514b208
    c4v2 = c4v2(c4v1)
    if c4v2 then
      do return end
    end
    c4v2 = c4v1:Name__682cbf57()
    c4v3 = c4v2:Name__b2e22fcd()
    c4v4 = Name__6514b208
    c4v4 = c4v4(c4v3)
    if c4v4 then
      do return end
    end
    local __renovice_local_0 = Name__9828c6d9.AbilityLevelQueryParms.Ability
    c4v4 = c4v3:Name__58012efc(__renovice_local_0)
    local __renovice_local_1 = c4v3:Name__83aa2c02()
    if __renovice_local_1 <= c4v4 then
      do return end
    end
    __renovice_local_1 = c4v3:Name__c7fc329f(c4v4)
    __renovice_local_0 = 0
    if __renovice_local_1 <= __renovice_local_0 then
      do return end
    end
    __renovice_local_0 = c4v3:Name__9dfce5ad(c4v4)
    c4v5 = 1
    if __renovice_local_0 == c4v5 then
      if __renovice_local_1 == 1 then
        c4v5 = 0.35
        v7 = c4v5
      else
        if __renovice_local_1 == 2 then
          c4v5 = 0.5
          v7 = c4v5
        else
          if __renovice_local_1 == 3 then
            c4v5 = 0.65
            v7 = c4v5
          else
            c4v5 = 0.8
            v7 = c4v5
          end
        end
      end
    end
    c4v5 = 1
    if __renovice_local_0 == c4v5 then
      c4v6 = { Label = "/Lotus/Language/Suits/BardMusicAbilityAugment1Name", Title = true }
      c4v5 = Name__6e962203.Name__c614a8c6
      c4v5(c4v0, c4v6)
      c4v6 = { Label = "/Lotus/Language/Game/ABILITY_RADIUS", Value = nil, ValueUnit = "/Lotus/Language/Game/UNIT_PERCENT" }
      c4v9 = v7
      c4v8 = c4v9 * 100
      c4v7 = Name__b6e30ca3.Name__d4f2b58e
      c4v7 = c4v7(c4v8)
      c4v6.Value = c4v7
      c4v5 = Name__6e962203.Name__c614a8c6
      c4v5(c4v0, c4v6)
    end
    do return end
  end
  v17 = function()
    local c5v0, c5v1, c5v2, c5v3, c5v4, c5v5, c5v6, c5v7
    c5v0 = Name__9828c6d9.AbilityLevelQueryParms.Level
    c5v1 = v13
    c5v1(c5v0)
    c5v1 = Name__9828c6d9.AbilityLevelQueryParms.Modded
    if c5v1 == true then
      c5v1 = v14
      c5v2 = Name__9828c6d9.AbilityLevelQueryParms.Avatar
      c5v1, c5v2, c5v3 = c5v1(c5v2)
      v4 = c5v1
      v5 = c5v2
      v6 = c5v3
      c5v1 = v4
      c5v1 = c5v1:Name__8a0e346e()
      v4 = c5v1
      c5v2 = Name__9828c6d9.AbilityLevelQueryParms.Avatar
      c5v1 = Name__6514b208
      c5v1 = c5v1(c5v2)
      if not c5v1 then
        c5v2 = Name__9828c6d9.AbilityLevelQueryParms.Ability
        c5v1 = Name__6514b208
        c5v1 = c5v1(c5v2)
        if not c5v1 then
          c5v1 = Name__9828c6d9.AbilityLevelQueryParms.Avatar
          c5v1 = c5v1:Name__682cbf57()
          c5v1 = c5v1:Name__b2e22fcd()
          c5v2 = Name__6514b208
          c5v2 = c5v2(c5v1)
          if not c5v2 then
            c5v4 = Name__9828c6d9.AbilityLevelQueryParms.Ability
            c5v2 = c5v1:Name__58012efc(c5v4)
            c5v5 = c5v2
            c5v3 = c5v1:Name__c7fc329f(c5v5)
            c5v4 = c5v1:Name__9dfce5ad(c5v2)
            c5v5 = 0
            if c5v5 < c5v3 then
              c5v5 = 1
              if c5v4 == c5v5 then
                c5v5 = 1
                if c5v4 == c5v5 then
                  if c5v3 == 1 then
                    c5v5 = 0.35
                    v7 = c5v5
                  else
                    if c5v3 == 2 then
                      c5v5 = 0.5
                      v7 = c5v5
                    else
                      if c5v3 == 3 then
                        c5v5 = 0.65
                        v7 = c5v5
                      else
                        c5v5 = 0.8
                        v7 = c5v5
                      end
                    end
                  end
                end
                c5v6 = v5
                c5v7 = v7
                c5v5 = c5v6 * c5v7
                v5 = c5v5
              end
            end
          end
        end
      end
    end
    c5v1 = {}
    c5v4 = { Label = "/Lotus/Language/Game/DAMAGE_MULTIPLIER", Value = nil, ValueIcon = "<DT_EXPLOSION>", ValueUnit = "/Lotus/Language/Game/UNIT_MULTIPLIER" }
    c5v5 = v4
    c5v4.Value = c5v5
    c5v2 = Name__6e962203.Name__c614a8c6
    c5v2(c5v1, c5v4)
    c5v4 = { Label = "/Lotus/Language/Game/ABILITY_RADIUS", Value = nil, ValueUnit = "/Lotus/Language/Game/UNIT_METER" }
    c5v5 = v5
    c5v4.Value = c5v5
    c5v2 = Name__6e962203.Name__c614a8c6
    c5v2(c5v1, c5v4)
    c5v4 = { Label = "/Lotus/Language/Game/ABILITY_DURATION", Value = nil, ValueUnit = "/Lotus/Language/Game/UNIT_SECOND" }
    c5v5 = v6
    c5v4.Value = c5v5
    c5v2 = Name__6e962203.Name__c614a8c6
    c5v2(c5v1, c5v4)
    c5v2 = v16
    c5v2(c5v1)
    c5v2 = Name__9828c6d9.AbilityLevelQueryParms.Modded
    c5v1.Modded = c5v2
    Name__9828c6d9.AbilityUpgradeLevelInfo = c5v1
    do return end
  end
  GetAbilityUpgradeLevelInfo = v17
  v17 = function(c6v0, c6v1)
    local c6v2, c6v3, c6v4, c6v5, c6v6, c6v7
    c6v2 = {}
    c6v3 = 1
    if c6v1 == c6v3 then
      if c6v0 == 1 then
        c6v3 = 0.35
        v7 = c6v3
      else
        if c6v0 == 2 then
          c6v3 = 0.5
          v7 = c6v3
        else
          if c6v0 == 3 then
            c6v3 = 0.65
            v7 = c6v3
          else
            c6v3 = 0.8
            v7 = c6v3
          end
        end
      end
    end
    c6v3 = 1
    if c6v1 == c6v3 then
      c6v3 = { RANGE = nil }
      c6v4 = v3
      c6v4 = c6v4.Name__55daaf26
      c6v7 = v7
      c6v6 = 1 - c6v7
      c6v5 = c6v6 * 100
      c6v6 = 0
      c6v4 = c6v4(c6v5, c6v6)
      c6v3.RANGE = c6v4
      c6v2 = c6v3
    end
    c6v3 = Name__3990010e.Name__84eaa3ce
    do return c6v3(c6v2) end
  end
  GetAugmentDescriptionInfo = v17
  v17 = function(c7v0)
    local c7v1, c7v2, c7v3, c7v4, c7v5, c7v6
    c7v1 = c7v0:Name__402a3166()
    while true do
      c7v2 = Name__20bbc0cd
      c7v2 = c7v2:Name__f0e7e5d7()
      if not c7v2 then break end
      c7v2 = c7v0:Name__decc89f9()
      if c7v2 then break end
      c7v2 = c7v1:Name__a10c08e1()
      if c7v2 then break end
      c7v2 = false
      c7v3 = Name__d06efad8
      c7v4 = Name__ab152174
      c7v3, c7v4, c7v5 = c7v3(c7v4)
      for __renovice_for_0_0, __renovice_for_0_1 in c7v3, c7v4, c7v5 do
        c7v6 = c7v0:Name__b2f7a84f(__renovice_for_0_1)
        if not c7v6 then
          continue
        end
        c7v2 = true
        break
      end
      if not c7v2 then break end
      c7v3 = Name__daf81ef9
      c7v4 = 0
      c7v3(c7v4)
    end
    do return end
  end
  EvalBusyLoop = v17
  v17 = function(c8v0, c8v1)
    local c8v2, c8v3, c8v4, c8v5
    c8v4 = Name__3df6d685
    c8v5 = "EvalBusyLoop"
    c8v4 = c8v4(c8v5)
    c8v5 = true
    c8v1:Name__55aca91b(c8v4, c8v5)
    c8v3 = c8v1:Name__decc89f9()
    c8v2 = not c8v3
    if c8v2 then
      c8v3 = c8v1:Name__a10c08e1()
      c8v2 = not c8v3
    end
    do return c8v2 end
  end
  EvaluateAbility = v17
  v17 = function(c9v0, c9v1)
    local c9v2, c9v3, c9v4, c9v5
    c9v2 = c9v1:Name__b7f5db56()
    c9v2 = c9v2:Name__4c941539()
    c9v3 = c9v2.visible
    if c9v3 then
      c9v4 = c9v2.avatar
      c9v3 = Name__6514b208
      c9v3 = c9v3(c9v4)
      if not c9v3 then
        c9v3 = c9v2.avatar
        c9v3 = c9v3:Name__a10c08e1()
        if not c9v3 then
          c9v3 = c9v2.distanceToTarget
          c9v4 = 1
          if c9v4 <= c9v3 then
            c9v3 = c9v2.distanceToTarget
            c9v4 = 10
            if c9v3 < c9v4 then
              c9v5 = c9v2.avatar
              c9v0:Name__78c4d922(c9v5)
              c9v3 = 1
              do return c9v3 end
            end
          end
        end
      end
    end
    c9v3 = 0
    do return c9v3 end
  end
  NpcEvaluateAbility = v17
  v17 = function(c10v0, c10v1)
    local c10v2, c10v3
    c10v2 = v0
    c10v2 = c10v2.Name__a34fa566
    c10v2 = c10v2()
    if c10v2 then
      c10v2 = Name__20bbc0cd
      c10v3 = Name__d7e3ec85
      c10v2:Name__722de996(c10v3:Name__95ce4bc4())
    end
    do return end
  end
  InitializeAbility = v17
  v17 = function(c11v0)
    local c11v1, c11v2, c11v3, c11v4, c11v5, c11v6, c11v7, c11v8, c11v9
    local __renovice_state_0 = 0
    c11v1 = c11v0:Name__af065794()
    c11v2 = Name__6514b208
    c11v2 = c11v2(c11v1)
    if c11v2 then
      __renovice_state_0 = 10
    else
      __renovice_state_0 = 1
    end
    if __renovice_state_0 == 1 then
      c11v2 = c11v1:Name__decc89f9()
      if c11v2 then
        __renovice_state_0 = 10
      else
        __renovice_state_0 = 2
      end
    end
    if __renovice_state_0 == 2 then
      c11v2 = c11v1:Name__35302b3f()
      if c11v2 then
        __renovice_state_0 = 5
      else
        __renovice_state_0 = 3
      end
    end
    if __renovice_state_0 == 3 then
      c11v2 = Name__b364fd20
      c11v2 = c11v2:Name__ce228771()
      if not c11v2 then
        __renovice_state_0 = 10
      else
        __renovice_state_0 = 4
      end
    end
    if __renovice_state_0 == 4 then
      c11v2 = c11v1:Name__5727319d()
      if c11v2 then
        __renovice_state_0 = 10
      else
        __renovice_state_0 = 5
      end
    end
    if __renovice_state_0 == 5 then
      c11v2 = c11v1:Name__682cbf57()
      c11v2 = c11v2:Name__b2e22fcd()
      c11v3 = Name__6514b208
      c11v3 = c11v3(c11v2)
      if c11v3 then
        __renovice_state_0 = 10
      else
        __renovice_state_0 = 6
      end
    end
    if __renovice_state_0 == 6 then
      c11v5 = 0
      c11v3 = c11v2:Name__298d0f97(c11v5)
      c11v4 = v1
      c11v4 = c11v4.Name__a7cc5781
      c11v4 = c11v4(c11v2, c11v3)
      c11v5 = Name__6514b208
      c11v5 = c11v5(c11v4)
      if c11v5 then
        __renovice_state_0 = 10
      else
        __renovice_state_0 = 7
      end
    end
    if __renovice_state_0 == 7 then
      c11v5 = c11v4.projectile
      if c11v5 == c11v0 then
        __renovice_state_0 = 9
      else
        __renovice_state_0 = 8
      end
    end
    if __renovice_state_0 == 8 then
      c11v5 = c11v4.secondProjectile
      if c11v5 ~= c11v0 then
        __renovice_state_0 = 10
      else
        __renovice_state_0 = 9
      end
    end
    if __renovice_state_0 == 9 then
      c11v5 = Name__aaca68d0.Name__0d2e4aa5
      c11v6 = true
      c11v5 = c11v5(c11v6)
      c11v5:Name__fac6cc3d(c11v0:Name__3ca198c7())
      c11v7 = Name__5d59c07d
      c11v5:Name__fac6cc3d(c11v7(c11v0:Name__c92bc52f()))
      c11v7 = c11v4.damageMult
      c11v5:Name__7500d9d5(c11v7)
      c11v7 = c11v4.radius
      c11v5:Name__47d28077(c11v7)
      c11v7 = c11v4.duration
      c11v5:Name__47d28077(c11v7)
      c11v8 = Name__3df6d685
      c11v9 = "SpawnBox"
      c11v8 = c11v8(c11v9)
      c11v2:Name__8d608664(c11v3, c11v8, c11v5)
      __renovice_state_0 = 10
    end
    if __renovice_state_0 == 10 then
      c11v0:Name__9c6a9ac9()
      do return end
    end
    do return end
  end
  v18 = function(c12v0, c12v1, c12v2, c12v3)
    local c12v4, c12v5, c12v6, c12v7, c12v8, c12v9, c12v10, c12v11, c12v12, c12v13, c12v14, c12v15, c12v16, c12v17, c12v18, c12v19
    c12v4 = v13
    c12v4(c12v3)
    c12v4 = v14
    c12v4, c12v5, c12v6 = c12v4(c12v1)
    local __renovice_local_0 = c12v0:Name__c7fc329f()
    c12v7 = c12v0:Name__9dfce5ad()
    c12v8 = false
    c12v9 = 0
    if c12v9 < __renovice_local_0 then
      c12v9 = 1
      if c12v7 ~= c12v9 then
        c12v8 = false
      else
        c12v8 = true
      end
    end
    if c12v8 then
      c12v9 = 1
      if c12v7 == c12v9 then
        if __renovice_local_0 == 1 then
          c12v9 = 0.35
          v7 = c12v9
        else
          if __renovice_local_0 == 2 then
            c12v9 = 0.5
            v7 = c12v9
          else
            if __renovice_local_0 == 3 then
              c12v9 = 0.65
              v7 = c12v9
            else
              c12v9 = 0.8
              v7 = c12v9
            end
          end
        end
      end
      c12v9 = v7
      c12v5 = c12v5 * c12v9
    end
    c12v9 = c12v1:Name__682cbf57()
    c12v12 = false
    c12v9:Name__e08648d9(c12v12)
    c12v9:Name__8604cb09()
    c12v12 = 0
    c12v13 = 2
    c12v9:Name__952864aa(c12v12, c12v13)
    c12v10 = c12v1:Name__35302b3f()
    if c12v10 then
      c12v12 = Name__4fd34ab0
      c12v1:Name__b86b2b63(c12v12)
    end
    c12v12 = true
    c12v0:Name__3982680e(c12v12)
    c12v12 = Name__388ba784
    c12v13 = Name__3df6d685
    c12v14 = "GAME_R1_WEAPON1"
    c12v13 = c12v13(c12v14)
    c12v14 = Name__3f3779af
    c12v15 = Name__3b0d8a4c
    c12v1:Name__f275c3f8(c12v12, c12v13, c12v14, c12v15, c12v0)
    c12v10 = c12v1:Name__eec0b118()
    if c12v10 then
      c12v10 = v1
      c12v10 = c12v10.Name__dcbe841c
      c12v12 = Name__f8261964
      c12v13 = "MusicCast"
      c12v14 = false
      c12v15 = 2
      c12v16 = 1
      c12v17 = false
      c12v10(c12v0, c12v12, c12v13, c12v14, c12v15, c12v16, c12v17)
    else
      c12v10 = v1
      c12v10 = c12v10.Name__3afe111e
      c12v12 = Name__f8261964
      c12v13 = "MusicCast"
      c12v14 = false
      c12v15 = 2
      c12v16 = 1
      c12v17 = false
      c12v10(c12v0, c12v12, c12v13, c12v14, c12v15, c12v16, c12v17)
    end
    c12v12 = false
    c12v0:Name__3982680e(c12v12)
    c12v10 = c12v1:Name__35302b3f()
    if c12v10 then
      c12v12 = Name__4fd34ab0
      c12v1:Name__33f05f33(c12v12)
    end
    c12v10 = c12v1:Name__682cbf57()
    c12v10 = c12v10:Name__6aa78c8f()
    c12v13 = Name__3df6d685
    c12v14 = "GAME_R1_WEAPON1"
    c12v11 = c12v1:Name__ae65b98a(c12v13(c12v14))
    c12v12 = Name__3c831418
    c12v12 = c12v12(c12v11, c12v10)
    c12v13 = Name__f6b1946a
    c12v14 = c12v10 - c12v11
    c12v15 = Name__5d59c07d
    c12v13 = c12v13(c12v14, c12v15(c12v1:Name__d8e31809()))
    if c12v13 then
      c12v12 = c12v1:Name__d8e31809()
    end
    c12v13 = v0
    c12v13 = c12v13.Name__a34fa566
    c12v13 = c12v13()
    if c12v13 then
      c12v13 = Name__22dd887b
      Name__f3602342 = c12v13
    end
    c12v13 = Name__b364fd20
    c12v15 = Name__f3602342
    c12v13 = c12v13:Name__86603178(c12v15, c12v11, c12v12, c12v1)
    c12v14 = Name__6514b208
    c12v14 = c12v14(c12v13)
    if not c12v14 then
      c12v13:Name__a22f3ac5(c12v1)
      c12v13:Name__439095b8(c12v0)
      c12v16 = 0
      c12v13:Name__533b530c(c12v16)
      c12v16 = Name__3df6d685
      c12v17 = "GrenadeOverride"
      c12v14 = c12v0:Name__f88aefc6(c12v16(c12v17))
      c12v15 = Name__6514b208
      c12v15 = c12v15(c12v14)
      if not c12v15 then
        c12v18 = false
        c12v19 = false
        c12v13:Name__6355e65f(c12v14, c12v18, c12v19)
        c12v16 = c12v14:Name__323c0e92()
        c12v17 = c12v14:Name__ea21ea6a()
        c12v15 = c12v16 - c12v17
        c12v16 = Name__39273653
        c12v16 = c12v16(c12v15)
        c12v17 = 1
        if c12v17 < c12v16 then
          c12v18 = 0.25
          c12v19 = true
          c12v13:Name__9f3d68a0(c12v18, c12v19)
        end
      end
      c12v15 = c12v0:Name__7c449953()
      c12v15:Name__9beda067()
      c12v15:Name__d0554610(c12v13)
    end
    c12v14 = v1
    c12v14 = c12v14.Name__a7cc5781
    c12v16 = Name__20bbc0cd
    c12v14 = c12v14(c12v0, c12v16)
    c12v15 = Name__6514b208
    c12v15 = c12v15(c12v14)
    if c12v15 then
      c12v14 = {}
    else
      c12v16 = c12v14.projectile
      c12v15 = Name__6514b208
      c12v15 = c12v15(c12v16)
      if not c12v15 then
        if c12v8 then
          c12v16 = c12v14.secondProjectile
          c12v15 = Name__6514b208
          c12v15 = c12v15(c12v16)
          if not c12v15 then
            c12v15 = c12v14.secondProjectile
            c12v15:Name__9c6a9ac9()
          end
          c12v15 = c12v14.projectile
          c12v14.secondProjectile = c12v15
        else
          c12v15 = c12v14.projectile
          c12v15:Name__9c6a9ac9()
        end
      end
    end
    c12v14.projectile = c12v13
    c12v14.damageMult = c12v4
    c12v14.radius = c12v5
    c12v14.duration = c12v6
    c12v14.augmentOne = c12v8
    c12v15 = v1
    c12v15 = c12v15.Name__6e44af97
    c12v17 = Name__20bbc0cd
    c12v15(c12v0, c12v17, c12v14)
    c12v0:Name__3cf2e9c6()
    c12v17 = 0
    c12v18 = 2
    c12v9:Name__952864aa(c12v17, c12v18)
    c12v15 = v0
    c12v15 = c12v15.Name__a34fa566
    c12v15 = c12v15()
    if c12v15 then
      c12v15 = v17
      c12v15(c12v13)
    end
    while true do
      c12v15 = Name__6514b208
      c12v15 = c12v15(c12v1)
      if c12v15 then break end
      c12v17 = Name__f8261964
      c12v15 = c12v1:Name__b2f7a84f(c12v17)
      if not c12v15 then break end
      c12v15 = Name__daf81ef9
      c12v16 = 0
      c12v15(c12v16)
    end
    c12v15 = Name__daf81ef9
    c12v16 = 0.3
    c12v15(c12v16)
    do return end
  end
  ActivateAbility = v18
  v18 = function(c13v0, c13v1, c13v2, c13v3)
    local c13v4, c13v5, c13v6, c13v7, c13v8, c13v9
    c13v4 = c13v1:Name__35302b3f()
    if c13v4 then
      c13v6 = Name__4fd34ab0
      c13v1:Name__33f05f33(c13v6)
    end
    c13v4 = false
    c13v7 = 0
    c13v5 = 3
    c13v6 = 1
    for __renovice_for_0_0 = c13v7, c13v5, c13v6 do
      c13v8 = c13v0:Name__298d0f97(__renovice_for_0_0)
      c13v9 = Name__6514b208
      c13v9 = c13v9(c13v8)
      if c13v9 then
        continue
      end
      c13v9 = Name__20bbc0cd
      if c13v8 == c13v9 then
        continue
      end
      c13v9 = c13v8:Name__e95aeb3c()
      if not c13v9 then
        continue
      end
      c13v9 = c13v8:Name__ba23b450()
      if c13v9 then
        continue
      end
      c13v4 = true
      break
    end
    if not c13v4 then
      c13v5 = c13v1:Name__682cbf57()
      c13v8 = true
      c13v5:Name__e08648d9(c13v8)
      c13v8 = 0
      c13v9 = 0
      c13v5:Name__952864aa(c13v8, c13v9)
    end
    do return end
  end
  DeactivateAbility = v18
  v18 = function(c14v0)
    local c14v1
    c14v1 = v17
    c14v1(c14v0)
    do return end
  end
  ProjectileStopped = v18
  v18 = function(c15v0, c15v1)
    local c15v2, c15v3
    c15v3 = Name__33db0255
    c15v2 = c15v1:Name__2888fc5c(c15v3)
    if c15v2 then
      c15v2 = v1
      c15v2 = c15v2.Name__c260986f
      c15v2 = c15v2(c15v1)
      if c15v2 then
        c15v0:Name__052f50da()
      end
    end
    do return end
  end
  ProjectileContact = v18
  v18 = function(c16v0, c16v1, c16v2, c16v3, c16v4, c16v5)
    local c16v6, c16v7, c16v8, c16v9, c16v10, c16v11, c16v12, c16v13, c16v14, c16v15, c16v16, c16v17, c16v18, c16v19
    c16v6 = Name__20bbc0cd
    c16v9 = c16v6:Name__bab6c411()
    c16v7 = c16v0:Name__2801ef9c(c16v9)
    c16v8 = c16v7[1]
    c16v9 = Name__3c831418
    c16v10 = Name__3f3779af
    c16v9 = c16v9(c16v10, c16v3)
    c16v10 = c16v0:Name__8c362f50()
    c16v11 = c16v2
    c16v12 = v0
    c16v12 = c16v12.Name__a34fa566
    c16v12 = c16v12()
    if c16v12 then
      c16v12 = Name__ab9007b3
      Name__39c7cb1d = c16v12
      c16v12 = Name__76c01753
      c16v13 = 0
      c16v14 = 0.7
      c16v15 = 1
      c16v12 = c16v12(c16v13, c16v14, c16v15)
      c16v11 = c16v11 - c16v12
    else
      c16v12 = Name__76c01753
      c16v13 = 0
      c16v14 = 1
      c16v15 = 0
      c16v12 = c16v12(c16v13, c16v14, c16v15)
      c16v11 = c16v11 + c16v12
    end
    c16v12 = Name__b364fd20
    c16v14 = Name__39c7cb1d
    c16v12 = c16v12:Name__86603178(c16v14, c16v11, c16v9, c16v10)
    c16v13 = Name__6514b208
    c16v13 = c16v13(c16v12)
    if c16v13 then
      do return end
    end
    c16v13 = Name__20bbc0cd
    c16v13:Name__e1a37b54(c16v12)
    c16v13 = Name__b364fd20
    c16v15 = Name__c38b57ef
    c16v13:Name__86603178(c16v15, c16v2, c16v9, c16v0)
    c16v13 = v1
    c16v13 = c16v13.Name__8e8dc7ef
    c16v16 = Name__76c01753
    c16v17 = 0
    c16v18 = 0.5
    c16v19 = 0
    c16v16 = c16v16(c16v17, c16v18, c16v19)
    c16v15 = c16v11 + c16v16
    c16v13(c16v12, c16v15)
    c16v12:Name__6dbfbce7(c16v10:Name__8805e3ee())
    c16v13 = c16v12:Name__bef01360()
    c16v13:Name__409a3949(c16v9)
    c16v12:Name__ce5c1f6d(c16v9)
    c16v15 = 27
    c16v16 = true
    c16v12:Name__d13d07b0(c16v15, c16v16)
    c16v12:Name__6ea376d1(c16v10)
    c16v12:Name__1ba7a438(c16v10)
    c16v13 = Name__aaca68d0.Name__0d2e4aa5
    c16v14 = true
    c16v15 = true
    c16v13 = c16v13(c16v14, c16v15)
    c16v13:Name__123cf112(c16v12)
    c16v13:Name__7500d9d5(c16v8)
    c16v13:Name__47d28077(c16v4)
    c16v13:Name__47d28077(c16v5)
    c16v16 = Name__20bbc0cd
    c16v17 = Name__3df6d685
    c16v18 = "SpawnSequencer"
    c16v17 = c16v17(c16v18)
    c16v0:Name__8d608664(c16v16, c16v17, c16v13)
    do return end
  end
  SpawnBox = v18
  v18 = nil
  v19 = function(c17v0)
    local c17v1, c17v2, c17v3, c17v4, c17v5, c17v6, c17v7, c17v8, c17v9, c17v10, c17v11, c17v12, c17v13, c17v14, c17v15, c17v16, c17v17, c17v18, c17v19, c17v20, c17v21, c17v22, c17v23, c17v24, c17v25, c17v26, c17v27, c17v28, c17v29, c17v30, c17v31, c17v32, c17v33, c17v34, c17v35, c17v36, c17v37, c17v38, c17v39, c17v40
    local __renovice_state_0 = 0
    c17v1 = c17v0:Name__7107e6c8()
    c17v2 = c17v1:Name__8c362f50()
    c17v3 = c17v0:Name__3ca198c7()
    c17v4 = v18
    c17v5 = v1
    c17v5 = c17v5.Name__a7cc5781
    c17v7 = Name__20bbc0cd
    c17v5 = c17v5(c17v1, c17v7)
    c17v6 = Name__6514b208
    c17v6 = c17v6(c17v5)
    if not c17v6 then
      __renovice_state_0 = 2
    else
      __renovice_state_0 = 1
    end
    if __renovice_state_0 == 1 then
      c17v5 = {}
      __renovice_state_0 = 2
    end
    if __renovice_state_0 == 2 then
      c17v6 = c17v5.augmentOne
      if not c17v6 then
        __renovice_state_0 = 9
      else
        __renovice_state_0 = 3
      end
    end
    if __renovice_state_0 == 3 then
      c17v7 = c17v5.secondSequencer
      c17v6 = Name__6514b208
      c17v6 = c17v6(c17v7)
      if c17v6 then
        __renovice_state_0 = 6
      else
        __renovice_state_0 = 4
      end
    end
    if __renovice_state_0 == 4 then
      c17v8 = c17v5.secondSequencer
      c17v6 = c17v0:Name__0ad57287(c17v8)
      c17v7 = v5
      if not (c17v6 <= c17v7) then
        __renovice_state_0 = 6
      else
        __renovice_state_0 = 5
      end
    end
    if __renovice_state_0 == 5 then
      c17v6 = nil
      c17v5.secondSequencer = c17v6
      __renovice_state_0 = 6
    end
    if __renovice_state_0 == 6 then
      c17v7 = c17v5.sequencer
      c17v6 = Name__6514b208
      c17v6 = c17v6(c17v7)
      if c17v6 then
        __renovice_state_0 = 9
      else
        __renovice_state_0 = 7
      end
    end
    if __renovice_state_0 == 7 then
      c17v8 = c17v5.sequencer
      c17v6 = c17v0:Name__0ad57287(c17v8)
      c17v7 = v5
      if not (c17v7 < c17v6) then
        __renovice_state_0 = 9
      else
        __renovice_state_0 = 8
      end
    end
    if __renovice_state_0 == 8 then
      c17v6 = c17v5.sequencer
      c17v5.secondSequencer = c17v6
      __renovice_state_0 = 9
    end
    if __renovice_state_0 == 9 then
      c17v5.sequencer = c17v0
      c17v6 = v1
      c17v6 = c17v6.Name__6e44af97
      c17v8 = Name__20bbc0cd
      c17v6(c17v1, c17v8, c17v5)
      c17v1:Name__c9c04883(c17v4)
      c17v8 = Name__59d7702f
      c17v9 = Name__f6aba2d9
      c17v10 = Name__3f3779af
      c17v11 = Name__3b0d8a4c
      c17v4:Name__f275c3f8(c17v8, c17v9, c17v10, c17v11, c17v1)
      c17v8 = Name__c2b9afe2
      c17v9 = Name__f6aba2d9
      c17v10 = Name__3f3779af
      c17v11 = Name__3b0d8a4c
      c17v6 = c17v4:Name__f275c3f8(c17v8, c17v9, c17v10, c17v11, c17v1)
      c17v7 = nil
      c17v8 = c17v2:Name__7f7b27a9()
      if c17v8 then
        __renovice_state_0 = 13
      else
        __renovice_state_0 = 10
      end
    end
    if __renovice_state_0 == 10 then
      c17v8 = Name__b364fd20
      c17v8 = c17v8:Name__ce228771()
      if not c17v8 then
        __renovice_state_0 = 12
      else
        __renovice_state_0 = 11
      end
    end
    if __renovice_state_0 == 11 then
      c17v8 = c17v2:Name__5727319d()
      if not c17v8 then
        __renovice_state_0 = 13
      else
        __renovice_state_0 = 12
      end
    end
    if __renovice_state_0 == 12 then
      c17v8 = v0
      c17v8 = c17v8.Name__4369ab26
      c17v8 = c17v8()
      if not c17v8 then
        __renovice_state_0 = 14
      else
        __renovice_state_0 = 13
      end
    end
    if __renovice_state_0 == 13 then
      c17v10 = Name__8817237d
      c17v11 = Name__f6aba2d9
      c17v12 = Name__3f3779af
      c17v13 = Name__3b0d8a4c
      c17v7 = c17v4:Name__f275c3f8(c17v10, c17v11, c17v12, c17v13, c17v1)
      __renovice_state_0 = 15
    end
    if __renovice_state_0 == 14 then
      c17v10 = Name__00a86b78
      c17v11 = Name__f6aba2d9
      c17v12 = Name__3f3779af
      c17v13 = Name__3b0d8a4c
      c17v7 = c17v4:Name__f275c3f8(c17v10, c17v11, c17v12, c17v13, c17v1)
      __renovice_state_0 = 15
    end
    if __renovice_state_0 == 15 then
      c17v8 = Name__6514b208
      c17v8 = c17v8(c17v7)
      if c17v8 then
        __renovice_state_0 = 17
      else
        __renovice_state_0 = 16
      end
    end
    if __renovice_state_0 == 16 then
      c17v11 = v5
      c17v10 = c17v11 / 1.25
      c17v7:Name__9f3d68a0(c17v10)
      __renovice_state_0 = 17
    end
    if __renovice_state_0 == 17 then
      c17v8 = v0
      c17v8 = c17v8.Name__4369ab26
      c17v8 = c17v8()
      if not c17v8 then
        __renovice_state_0 = 23
      else
        __renovice_state_0 = 18
      end
    end
    if __renovice_state_0 == 18 then
      c17v8 = v0
      c17v8 = c17v8.Name__a34fa566
      c17v8 = c17v8()
      if not c17v8 then
        __renovice_state_0 = 22
      else
        __renovice_state_0 = 19
      end
    end
    if __renovice_state_0 == 19 then
      c17v10 = Name__3cfa8577
      c17v11 = Name__f6aba2d9
      c17v12 = Name__3f3779af
      c17v13 = Name__3b0d8a4c
      c17v8 = c17v4:Name__f275c3f8(c17v10, c17v11, c17v12, c17v13, c17v2)
      c17v10 = c17v5.radius
      c17v9 = Name__6514b208
      c17v9 = c17v9(c17v10)
      if not c17v9 then
        __renovice_state_0 = 21
      else
        __renovice_state_0 = 20
      end
    end
    if __renovice_state_0 == 20 then
      c17v11 = v5
      c17v8:Name__77b38e3a(c17v11)
      __renovice_state_0 = 26
    end
    if __renovice_state_0 == 21 then
      c17v11 = c17v5.radius
      c17v8:Name__77b38e3a(c17v11)
      __renovice_state_0 = 26
    end
    if __renovice_state_0 == 22 then
      c17v10 = Name__cf534c62
      c17v11 = Name__f6aba2d9
      c17v12 = Name__3f3779af
      c17v13 = Name__3b0d8a4c
      c17v4:Name__f275c3f8(c17v10, c17v11, c17v12, c17v13, c17v2)
      __renovice_state_0 = 26
    end
    if __renovice_state_0 == 23 then
      c17v8 = c17v2:Name__5727319d()
      if c17v8 then
        __renovice_state_0 = 26
      else
        __renovice_state_0 = 24
      end
    end
    if __renovice_state_0 == 24 then
      c17v10 = Name__b364fd20
      c17v8 = c17v2:Name__b17a29c2(c17v10:Name__5a9eabca())
      if c17v8 then
        __renovice_state_0 = 26
      else
        __renovice_state_0 = 25
      end
    end
    if __renovice_state_0 == 25 then
      c17v10 = Name__4eec2ebc
      c17v11 = Name__f6aba2d9
      c17v12 = Name__3f3779af
      c17v13 = Name__3b0d8a4c
      c17v4:Name__f275c3f8(c17v10, c17v11, c17v12, c17v13, c17v2)
      __renovice_state_0 = 26
    end
    if __renovice_state_0 == 26 then
      c17v8 = 0
      c17v9 = c17v0:Name__23918e00()
      c17v10 = {}
      c17v13 = 0
      c17v11 = c17v9 - 1
      c17v12 = 1
      local __renovice_fornprep_zero_0 = 0
      if __renovice_fornprep_zero_0 < c17v12 then
        if c17v11 < c17v13 then
          __renovice_state_0 = 28
        else
          __renovice_state_0 = 27
        end
      else
        __renovice_fornprep_zero_0 = 0
        if c17v12 < __renovice_fornprep_zero_0 then
          if c17v13 < c17v11 then
            __renovice_state_0 = 28
          else
            __renovice_state_0 = 27
          end
        else
          __renovice_state_0 = 27
        end
      end
    end
    if __renovice_state_0 == 27 then
      c17v19 = 2
      c17v14 = Name__6e962203.Name__c614a8c6
      c17v14(c17v10, c17v0:Name__77c64c26(c17v13, c17v19))
      c17v15 = c17v13 + 1
      c17v14 = c17v10[c17v15]
      c17v8 = c17v8 + c17v14
      __renovice_state_0 = 28
    end
    if __renovice_state_0 == 28 then
      c17v11 = c17v2:Name__cfd1d8a9()
      c17v12 = c17v2:Name__5f09eaee()
      if not c17v12 then
        __renovice_state_0 = 32
      else
        __renovice_state_0 = 29
      end
    end
    if __renovice_state_0 == 29 then
      c17v13 = 0
      if c17v13 < c17v8 then
        __renovice_state_0 = 31
      else
        __renovice_state_0 = 30
      end
    end
    if __renovice_state_0 == 30 then
      c17v12 = false
      __renovice_state_0 = 32
    end
    if __renovice_state_0 == 31 then
      c17v12 = true
      __renovice_state_0 = 32
    end
    if __renovice_state_0 == 32 then
      c17v13 = Name__daf81ef9
      c17v14 = 0
      c17v13(c17v14)
      c17v13 = nil
      c17v14 = Name__6514b208
      c17v14 = c17v14(c17v4)
      if c17v14 then
        __renovice_state_0 = 35
      else
        __renovice_state_0 = 33
      end
    end
    if __renovice_state_0 == 33 then
      c17v13 = c17v4:Name__402a3166()
      c17v14 = v0
      c17v14 = c17v14.Name__a34fa566
      c17v14 = c17v14()
      if c17v14 then
        __renovice_state_0 = 35
      else
        __renovice_state_0 = 34
      end
    end
    if __renovice_state_0 == 34 then
      c17v16 = true
      c17v13:Name__383fe093(c17v16)
      __renovice_state_0 = 35
    end
    if __renovice_state_0 == 35 then
      c17v15 = Name__9828c6d9.bardMusic
      c17v14 = Name__6514b208
      c17v14 = c17v14(c17v15)
      if not c17v14 then
        __renovice_state_0 = 37
      else
        __renovice_state_0 = 36
      end
    end
    if __renovice_state_0 == 36 then
      c17v14 = Name__9828c6d9
      c17v15 = {}
      c17v14.bardMusic = c17v15
      __renovice_state_0 = 37
    end
    if __renovice_state_0 == 37 then
      c17v14 = Name__9828c6d9.bardMusic
      c17v15 = { radius = nil, box = nil }
      c17v16 = v5
      c17v15.radius = c17v16
      c17v15.box = c17v4
      c17v14[c17v11] = c17v15
      c17v14 = Name__20bbc0cd
      c17v14 = c17v14:Name__bab6c411()
      c17v15 = c17v0:Name__2118f705()
      c17v16 = 0
      c17v17 = 0
      c17v18 = {}
      c17v19 = 1
      c17v20 = 0
      c17v21 = 0
      c17v22 = Name__3df6d685
      c17v23 = "SetThreatLevel"
      c17v22 = c17v22(c17v23)
      c17v23 = v6
      c17v24 = v1
      c17v24 = c17v24.Name__f5fa92b7
      c17v24 = c17v24()
      c17v25 = 0
      if not (c17v25 < c17v23) then
      else
        __renovice_state_0 = 38
      end
    end
    if __renovice_state_0 == 38 then
      c17v25 = Name__6514b208
      c17v25 = c17v25(c17v2)
      if c17v25 then
      else
        __renovice_state_0 = 39
      end
    end
    if __renovice_state_0 == 39 then
      c17v25 = c17v2:Name__decc89f9()
      if c17v25 then
      else
        __renovice_state_0 = 40
      end
    end
    if __renovice_state_0 == 40 then
      c17v25 = Name__6514b208
      c17v25 = c17v25(c17v1)
      if c17v25 then
      else
        __renovice_state_0 = 41
      end
    end
    if __renovice_state_0 == 41 then
      c17v25 = Name__6514b208
      c17v25 = c17v25(c17v4)
      if c17v25 then
      else
        __renovice_state_0 = 42
      end
    end
    if __renovice_state_0 == 42 then
      c17v25 = c17v5.sequencer
      if c17v25 == c17v0 then
        __renovice_state_0 = 44
      else
        __renovice_state_0 = 43
      end
    end
    if __renovice_state_0 == 43 then
      c17v25 = c17v5.secondSequencer
      if c17v25 ~= c17v0 then
      else
        __renovice_state_0 = 44
      end
    end
    if __renovice_state_0 == 44 then
      c17v25 = Name__9828c6d9.AddAbilityTimer
      c17v25(c17v14, c17v2, c17v23, c17v24)
    end
    c17v25 = 0
    c17v25 = Name__6514b208
    c17v25 = c17v25(c17v2)
    c17v25 = c17v2:Name__decc89f9()
    c17v25 = Name__6514b208
    c17v25 = c17v25(c17v1)
    c17v25 = Name__6514b208
    c17v25 = c17v25(c17v4)
    c17v25 = c17v5.sequencer
    c17v25 = c17v5.secondSequencer
    c17v3 = c17v0:Name__3ca198c7()
    c17v25 = 0
    c17v26 = Name__d7e3ec85
    c17v25 = Name__6514b208
    c17v25 = c17v25(c17v26)
    c17v25 = Name__d7e3ec85
    c17v25 = c17v25:Name__e265c3f2(c17v2, c17v3)
    c17v17 = 0.25
    c17v25 = c17v0:Name__60a26b33()
    local __renovice_local_0 = v8
    c17v28 = 1
    c17v4:Name__c9537147(__renovice_local_0, c17v28)
    __renovice_local_0 = v9
    c17v29 = 1
    c17v30 = c17v25 * 0.8
    c17v28 = c17v29 + c17v30
    c17v4:Name__c9537147(__renovice_local_0, c17v28)
    c17v26 = c17v0:Name__2118f705()
    c17v27 = v5
    __renovice_local_0 = Name__327588f0
    c17v28 = Name__9828c6d9.bardAmplify
    __renovice_local_0, c17v28, c17v29 = __renovice_local_0(c17v28)
    for __renovice_for_0_0, __renovice_for_0_1 in __renovice_local_0, c17v28, c17v29 do
      c17v31 = __renovice_for_0_1.pos
      c17v31 = Name__8f6983e5
      c17v33 = __renovice_for_0_1.pos
      c17v31 = c17v31(c17v3, c17v33)
      c17v32 = __renovice_for_0_1.radius
      c17v27 = c17v27 * 2
      c17v19 = 1.5
      c17v19 = 1
      __renovice_for_0_0 = 1 / c17v29
      c17v31 = c17v29 - 1
      __renovice_for_0_1 = c17v31 * 4
      c17v31 = __renovice_for_0_1 + 1
      c17v34 = c17v29 * c17v29
      c17v33 = c17v34 + 5
      c17v34 = Name__b6e30ca3.Name__19517a64
      c17v35 = 1
      c17v36 = 3
      c17v34 = c17v34(c17v35, c17v36)
      c17v32 = c17v33 + c17v34
      c17v18[c17v31] = c17v32
      c17v31 = __renovice_for_0_1 + 2
      c17v33 = Name__2510ee3d
      c17v34 = 0.15
      c17v35 = 0.25
      c17v33 = c17v33(c17v34, c17v35)
      c17v32 = __renovice_for_0_0 * c17v33
      c17v18[c17v31] = c17v32
      c17v31 = __renovice_for_0_1 + 3
      c17v32 = Name__2510ee3d
      c17v33 = -3
      c17v34 = 3
      c17v32 = c17v32(c17v33, c17v34)
      c17v18[c17v31] = c17v32
      c17v31 = __renovice_for_0_1 + 4
      c17v32 = Name__2510ee3d
      c17v33 = -1
      c17v34 = 1
      c17v32 = c17v32(c17v33, c17v34)
      c17v18[c17v31] = c17v32
      c17v31 = Name__87803f1b
      c17v33 = 4
      c17v34 = Name__975a761b
      c17v36 = Name__753fcbe8
      c17v37 = Name__caedfd1d
      c17v36 = c17v36(c17v37())
      c17v35 = c17v29 * c17v36
      c17v34 = c17v34(c17v35)
      c17v32 = c17v33 * c17v34
      c17v33 = 0.75
      c17v34 = 1
      c17v31 = c17v31(c17v32, c17v33, c17v34)
      c17v32 = Name__6514b208
      c17v32 = c17v32(c17v7)
      if not c17v32 then
        c17v34 = v10[c17v29]
        c17v36 = __renovice_for_0_1 + 1
        c17v35 = c17v18[c17v36]
        c17v39 = 1
        c17v38 = Name__b6e30ca3.Name__5ce6de7d
        c17v38 = c17v38(c17v39, c17v25)
        c17v37 = c17v31 * c17v38
        c17v39 = __renovice_for_0_1 + 2
        c17v38 = c17v18[c17v39]
        c17v36 = c17v37 * c17v38
        c17v38 = c17v31 * 12
        c17v40 = __renovice_for_0_1 + 3
        c17v39 = c17v18[c17v40]
        c17v37 = c17v38 + c17v39
        c17v39 = __renovice_for_0_1 + 4
        c17v38 = c17v18[c17v39]
        c17v7:Name__c9537147(c17v34, c17v35, c17v36, c17v37, c17v38)
      end
      __renovice_local_0 = Name__9828c6d9.bardVisualizer
      c17v27 = Name__6514b208
      c17v27 = c17v27(__renovice_local_0)
      if not c17v27 then
        c17v28 = Name__9828c6d9.bardVisualizer
        __renovice_local_0 = c17v28[c17v11]
        c17v27 = Name__6514b208
        c17v27 = c17v27(__renovice_local_0)
        if not c17v27 then
          __renovice_local_0 = Name__9828c6d9.bardVisualizer
          c17v27 = __renovice_local_0[c17v11]
          c17v27 = c17v27.music
          c17v28 = 0
          c17v27:Name__ed8f69d4(c17v28)
          c17v28 = v12
          __renovice_for_0_0 = Name__9828c6d9.bardVisualizer
          c17v29 = __renovice_for_0_0[c17v11]
          c17v29 = c17v29.music
          c17v29 = c17v29:Name__8a396a3e()
          c17v31 = Name__9828c6d9.bardVisualizer
          __renovice_for_0_1 = c17v31[c17v11]
          __renovice_for_0_1 = __renovice_for_0_1.piper
          __renovice_for_0_1 = __renovice_for_0_1:Name__8a396a3e()
          __renovice_for_0_0 = __renovice_for_0_1 * 2.5
          c17v32 = Name__9828c6d9.bardVisualizer
          c17v31 = c17v32[c17v11]
          c17v31 = c17v31.piper
          c17v31 = c17v31:Name__8a396a3e()
          __renovice_for_0_1 = c17v31 * 2
          c17v33 = Name__9828c6d9.bardVisualizer
          c17v32 = c17v33[c17v11]
          c17v32 = c17v32.jam
          c17v32 = c17v32:Name__8a396a3e()
          c17v31 = c17v32 * 3.5
          c17v4:Name__c9537147(c17v28, c17v29, __renovice_for_0_0, __renovice_for_0_1, c17v31)
        end
      end
      c17v27 = Name__daf81ef9
      __renovice_local_0 = 0
      c17v27(__renovice_local_0)
      c17v27 = Name__b420c85a
      c17v27 = c17v27()
      c17v23 = c17v23 - c17v27
      c17v27 = Name__b420c85a
      c17v27 = c17v27()
      c17v17 = c17v17 - c17v27
      __renovice_local_0 = Name__9828c6d9.bardMusic
      if __renovice_local_0 == nil then
        __renovice_local_0 = Name__9828c6d9
        c17v28 = {}
        __renovice_local_0.bardMusic = c17v28
      end
      c17v28 = Name__9828c6d9.bardMusic
      __renovice_local_0 = c17v28[c17v11]
      if __renovice_local_0 == nil then
        __renovice_local_0 = Name__9828c6d9.bardMusic
        c17v28 = { radius = nil, box = nil }
        c17v28.radius = c17v27
        c17v28.box = c17v4
        __renovice_local_0[c17v11] = c17v28
      else
        c17v28 = Name__9828c6d9.bardMusic
        __renovice_local_0 = c17v28[c17v11]
        __renovice_local_0 = __renovice_local_0.box
        if __renovice_local_0 == c17v4 then
          c17v28 = Name__9828c6d9.bardMusic
          __renovice_local_0 = c17v28[c17v11]
          __renovice_local_0.radius = c17v27
        end
      end
      __renovice_local_0 = Name__6514b208
      __renovice_local_0 = __renovice_local_0(c17v7)
      if not __renovice_local_0 then
        c17v29 = c17v27 / 1.25
        c17v7:Name__9f3d68a0(c17v29)
      end
      __renovice_local_0 = Name__6514b208
      __renovice_local_0 = __renovice_local_0(c17v6)
      if not __renovice_local_0 then
        c17v28 = c17v25 - c17v20
        __renovice_local_0 = c17v28 * 40
        __renovice_for_0_0 = Name__cef5d9d1
        c17v6:Name__6a5971b2(__renovice_for_0_0(__renovice_local_0, __renovice_local_0))
      end
      c17v20 = c17v25
      c17v28 = Name__9828c6d9.bardVisualizer
      __renovice_local_0 = Name__6514b208
      __renovice_local_0 = __renovice_local_0(c17v28)
      if not __renovice_local_0 then
        c17v29 = Name__9828c6d9.bardVisualizer
        c17v28 = c17v29[c17v11]
        __renovice_local_0 = Name__6514b208
        __renovice_local_0 = __renovice_local_0(c17v28)
        if not __renovice_local_0 then
          c17v28 = Name__9828c6d9.bardVisualizer
          __renovice_local_0 = c17v28[c17v11]
          __renovice_local_0 = __renovice_local_0.music
          __renovice_local_0:Name__fe4188cf(c17v25)
        end
      end
      c17v29 = 1
      __renovice_for_0_0 = v10
      __renovice_local_0 = #__renovice_for_0_0
      c17v28 = 1
      c17v29 = v11
      __renovice_for_0_0 = Name__2eacab09
      __renovice_for_0_0 = __renovice_for_0_0()
      __renovice_for_0_1 = Name__2eacab09
      c17v4:Name__c9537147(c17v29, __renovice_for_0_0, __renovice_for_0_1())
      if c17v12 then
        c17v28 = c17v13:Name__d9f84b1b()
        c17v28 = c17v28:Name__03545fc0()
        c17v28 = c17v28:Name__8a0e346e()
        c17v29 = v4
        c17v29 = c17v29:Name__df33cc3d()
        __renovice_local_0 = c17v28 * c17v29
        c17v16 = c17v16 + __renovice_local_0
        __renovice_local_0 = 0
        if __renovice_local_0 < c17v16 then
          c17v28 = c17v26 + 1
          __renovice_local_0 = c17v10[c17v28]
          c17v28 = 0
          if c17v28 < __renovice_local_0 then
            __renovice_local_0 = v0
            __renovice_local_0 = __renovice_local_0.Name__a34fa566
            __renovice_local_0 = __renovice_local_0()
            if not __renovice_local_0 then
              c17v29 = true
              c17v13:Name__383fe093(c17v29)
            end
            c17v28 = 1
            c17v32 = c17v26 + 1
            c17v31 = c17v10[c17v32]
            __renovice_for_0_1 = c17v16 * c17v31
            __renovice_for_0_0 = __renovice_for_0_1 / c17v8
            c17v29 = Name__b6e30ca3.Name__d4f2b58e
            c17v29 = c17v29(__renovice_for_0_0)
            __renovice_local_0 = Name__b6e30ca3.Name__4042c2a4
            __renovice_local_0 = __renovice_local_0(c17v28, c17v29)
            c17v28 = 0
            if c17v28 < __renovice_local_0 then
              c17v16 = c17v16 - __renovice_local_0
              c17v28 = Name__5ebaa8da.Name__337afdb0
              c17v28 = c17v28()
              c17v28:Name__a3f45f18(c17v2)
              c17v28:Name__9efafcef(c17v3)
              c17v29 = nil
              __renovice_for_0_0 = Name__5ebaa8da.Name__9e09bac8
              __renovice_for_0_0 = __renovice_for_0_0()
              if __renovice_for_0_0 then
                __renovice_for_0_0 = Name__5ebaa8da.Name__b78c546f
                __renovice_for_0_1 = __renovice_local_0 * 32
                c17v29 = __renovice_for_0_0(__renovice_for_0_1)
              else
                __renovice_for_0_0 = Name__5ebaa8da.Name__b78c546f
                c17v29 = __renovice_for_0_0(c17v16)
              end
              c17v31 = v4
              c17v29:Name__2218f0ef(c17v31)
              c17v28:Name__f8ac5a33(c17v29)
              c17v28.radius = c17v27
              __renovice_for_0_0 = 100
              c17v28.horizontalImpulse = __renovice_for_0_0
              __renovice_for_0_0 = 33.333333333333336
              c17v28.verticalImpulse = __renovice_for_0_0
              c17v31 = 7
              c17v32 = 1
              c17v28:Name__4f67a88c(c17v31, c17v32)
              c17v28.ignoreEntity = c17v4
              c17v28:Name__47cb1af5(c17v1)
              __renovice_for_0_0 = true
              c17v28.checkForCover = __renovice_for_0_0
              __renovice_for_0_0 = true
              c17v28.staticCoverOnly = __renovice_for_0_0
              __renovice_for_0_0 = 0
              c17v28.fallOff = __renovice_for_0_0
              __renovice_for_0_0 = Name__b364fd20
              __renovice_for_0_0:Name__ba9b0b7b(c17v28)
            end
          end
        end
        c17v28 = Name__006ceedf
        c17v29 = 5
        __renovice_for_0_0 = 0
        c17v31 = 1
        c17v32 = c17v16 / 1500
        __renovice_for_0_1 = Name__b6e30ca3.Name__5ce6de7d
        __renovice_for_0_1 = __renovice_for_0_1(c17v31, c17v32)
        c17v28 = c17v28(c17v29, __renovice_for_0_0, __renovice_for_0_1)
        __renovice_local_0 = Name__b6e30ca3.Name__d4f2b58e
        __renovice_local_0 = __renovice_local_0(c17v28)
        if __renovice_local_0 ~= c17v21 then
          c17v21 = __renovice_local_0
          c17v28 = Name__aaca68d0.Name__0d2e4aa5
          c17v29 = true
          c17v28 = c17v28(c17v29)
          c17v28:Name__47d28077(c17v21)
          c17v1:Name__920a3c5b(c17v14, c17v22, c17v28)
        end
      end
      c17v15 = c17v26
    end
    c17v25 = Name__9828c6d9.AddAbilityTimer
    __renovice_local_0 = 0
    c17v25(c17v14, c17v2, __renovice_local_0, c17v24)
    c17v26 = Name__9828c6d9.bardMusic
    c17v25 = Name__6514b208
    c17v25 = c17v25(c17v26)
    if not c17v25 then
      c17v27 = Name__9828c6d9.bardMusic
      c17v26 = c17v27[c17v11]
      c17v25 = Name__6514b208
      c17v25 = c17v25(c17v26)
      if not c17v25 then
        c17v26 = Name__9828c6d9.bardMusic
        c17v25 = c17v26[c17v11]
        c17v25 = c17v25.box
        if c17v25 == c17v4 then
          c17v25 = Name__9828c6d9.bardMusic
          c17v26 = nil
          c17v25[c17v11] = c17v26
          c17v25 = Name__41bc84cf
          c17v26 = Name__9828c6d9.bardMusic
          c17v25 = c17v25(c17v26)
          if c17v25 == nil then
            c17v25 = Name__9828c6d9
            c17v26 = nil
            c17v25.bardMusic = c17v26
          end
        end
      end
    end
    c17v25 = Name__b364fd20
    c17v27 = Name__fe51f3fa
    c17v28 = Name__3b0d8a4c
    c17v25:Name__86603178(c17v27, c17v3, c17v28, c17v1)
    c17v25 = Name__6514b208
    c17v25 = c17v25(c17v7)
    if not c17v25 then
      c17v7:Name__2364ecf0()
    end
    c17v25 = Name__6514b208
    c17v25 = c17v25(c17v4)
    if not c17v25 then
      c17v4:Name__9c6a9ac9()
    end
    c17v0:Name__9c6a9ac9()
    do return end
  end
  BoxLoop = v19
  v19 = function(c18v0, c18v1, c18v2, c18v3, c18v4)
    local c18v5, c18v6, c18v7, c18v8, c18v9, c18v10, c18v11, c18v12, c18v13, c18v14, c18v15
    c18v5 = Name__6514b208
    c18v5 = c18v5(c18v2)
    if c18v5 then
      do return end
    end
    c18v5 = Name__20bbc0cd
    c18v8 = c18v5:Name__bab6c411()
    c18v6 = c18v0:Name__2801ef9c(c18v8)
    c18v7 = c18v6[1]
    v4 = c18v7
    v5 = c18v3
    v6 = c18v4
    v18 = c18v2
    c18v8 = Name__cf534c62
    c18v8 = Name__4eec2ebc
    c18v8 = Name__3cfa8577
    c18v9 = Name__b364fd20
    c18v11 = Name__9e194dd0
    c18v12 = v18
    c18v12 = c18v12:Name__3ca198c7()
    c18v13 = Name__3b0d8a4c
    c18v9 = c18v9:Name__86603178(c18v11, c18v12, c18v13, c18v0)
    c18v10 = Name__6514b208
    c18v10 = c18v10(c18v9)
    if not c18v10 then
      c18v12 = v18
      c18v13 = Name__3df6d685
      c18v9:Name__1d1bbf9c(c18v12, c18v13())
      c18v10 = c18v0:Name__7c449953()
      c18v12 = 0
      c18v10 = c18v10:Name__6de554ba(c18v12)
      c18v13 = 0
      c18v11 = 3
      c18v12 = 1
      for __renovice_for_0_0 = c18v13, c18v11, c18v12 do
        c18v14 = c18v10:Name__583402b4(__renovice_for_0_0)
        if not c18v14 then
          continue
        end
        c18v15 = Name__20f6d1c9
        c18v9:Name__dc25533c(__renovice_for_0_0, c18v15(c18v10:Name__1d0c7abd(__renovice_for_0_0)))
      end
      c18v11 = c18v10.mHasFingerPrint
      if c18v11 then
        c18v13 = c18v10.mFingerPrint
        c18v9:Name__aa6a48cb(c18v13)
      end
      c18v13 = 0
      c18v14 = true
      c18v9:Name__292d9b6b(c18v13, c18v14)
      c18v13 = 1
      c18v14 = true
      c18v9:Name__292d9b6b(c18v13, c18v14)
      c18v11 = v2
      c18v11 = c18v11.Name__f2eec829
      c18v11(c18v9)
      c18v13 = Name__3df6d685
      c18v14 = "BoxLoop"
      c18v13 = c18v13(c18v14)
      c18v14 = false
      c18v9:Name__55aca91b(c18v13, c18v14)
    end
    do return end
  end
  SpawnSequencer = v19
  v19 = function(c19v0, c19v1, c19v2)
    local c19v3, c19v4, c19v5, c19v6
    c19v3 = c19v0:Name__8c362f50()
    c19v3 = c19v3:Name__cfd1d8a9()
    c19v5 = Name__9828c6d9.bardMusic
    c19v4 = Name__6514b208
    c19v4 = c19v4(c19v5)
    if not c19v4 then
      c19v6 = Name__9828c6d9.bardMusic
      c19v5 = c19v6[c19v3]
      c19v4 = Name__6514b208
      c19v4 = c19v4(c19v5)
      if not c19v4 then
        c19v6 = Name__9828c6d9.bardMusic
        c19v5 = c19v6[c19v3]
        c19v5 = c19v5.box
        c19v4 = Name__6514b208
        c19v4 = c19v4(c19v5)
        if not c19v4 then
          c19v5 = Name__9828c6d9.bardMusic
          c19v4 = c19v5[c19v3]
          c19v4 = c19v4.box
          c19v4:Name__dded29df(c19v2)
        end
      end
    end
    do return end
  end
  SetThreatLevel = v19
  v19 = function(c20v0, c20v1)
    local c20v2, c20v3, c20v4, c20v5
    c20v2 = Name__b364fd20
    c20v2 = c20v2:Name__ce228771()
    if c20v2 then
      c20v2 = Name__6514b208
      c20v2 = c20v2(c20v1)
      if not c20v2 then
        c20v2 = c20v1:Name__decc89f9()
        if not c20v2 then
          c20v2 = c20v0:Name__7107e6c8()
          if c20v1 == c20v2 then
            c20v2 = c20v1:Name__682cbf57()
            c20v3 = 326
            c20v4 = 3
            c20v5 = 0.5
            c20v2:Name__0a2d4eee(c20v3, c20v4, c20v5)
          end
        end
      end
    end
    do return end
  end
  GiveFightingUpgrades = v19
  v19 = function(c21v0, c21v1)
    local c21v2, c21v3, c21v4, c21v5
    c21v2 = Name__b364fd20
    c21v2 = c21v2:Name__ce228771()
    if c21v2 then
      c21v2 = Name__6514b208
      c21v2 = c21v2(c21v1)
      if not c21v2 then
        c21v2 = c21v1:Name__decc89f9()
        if not c21v2 then
          c21v2 = c21v0:Name__7107e6c8()
          if c21v1 == c21v2 then
            c21v2 = c21v1:Name__682cbf57()
            c21v3 = 326
            c21v4 = 3
            c21v5 = 0.5
            c21v2:Name__9c579e64(c21v3, c21v4, c21v5)
          end
        end
      end
    end
    do return end
  end
  RemoveFightingUpgrades = v19
  do return end
