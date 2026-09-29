  local v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28
  v4 = false
  v5 = false
  v6 = { IDLE = 1, STORMING = 2, CHANNELLING = 3, CORRUPTING = 4, COOLDOWN = 5 }
  v7 = Name__3df6d685
  v8 = "CorruptingCapsule"
  v7 = v7(v8)
  v8 = Name__3df6d685
  v9 = "CorruptionImmunity"
  v8 = v8(v9)
  v9 = Name__3df6d685
  v10 = "CleansedImmunity"
  v9 = v9(v10)
  v10 = Name__3df6d685
  v11 = "GhostMode"
  v10 = v10(v11)
  v11 = Name__9466a60b
  v12 = "/Lotus/Types/Enemies/Duviri/Avatars/DuviriMeleeAvatar"
  v11 = v11(v12)
  v12 = Name__9466a60b
  v13 = "/Lotus/Types/Enemies/Duviri/Avatars/DuviriRifleAvatar"
  v12 = v12(v13)
  v14 = Name__9466a60b
  v15 = "/Lotus/Powersuits/NpcPowersuits/NpcPowersuitAbilities/Zariman/DuviriMeleeTeleportAbility"
  v14 = v14(v15)
  v15 = Name__9466a60b
  v16 = "/Lotus/Powersuits/NpcPowersuits/NpcPowersuitAbilities/Zariman/DuviriRangeTeleportAbility"
  v13 = {v14, v15(v16)}
  v14 = Name__9ff10ded
  v15 = "Lotus.Scripts.Libs.TransmissionSet"
  v14 = v14(v15)
  v15 = function(c1v0)
    local c1v1, c1v2, c1v3
    c1v2 = Name__6514b208
    c1v2 = c1v2(c1v0)
    c1v1 = not c1v2
    if c1v1 then
      c1v3 = c1v0.object
      c1v2 = Name__6514b208
      c1v2 = c1v2(c1v3)
      c1v1 = not c1v2
      if c1v1 then
        c1v1 = true
        c1v2 = c1v0:Name__61dd1630()
        if c1v2 ~= 2 then
          c1v2 = c1v0:Name__61dd1630()
          if c1v2 ~= 3 then
            c1v1 = false
            do return c1v1 end
          end
          c1v1 = true
        end
      end
    end
    do return c1v1 end
  end
  v1 = nil
  v16 = function(c2v0, c2v1)
    local c2v2, c2v3, c2v4
    c2v2 = false
    c2v3 = 0
    if c2v3 < c2v1 then
      c2v3 = Name__6514b208
      c2v3 = c2v3(c2v0)
      c2v2 = not c2v3
      if c2v2 then
        c2v4 = c2v0.object
        c2v3 = Name__6514b208
        c2v3 = c2v3(c2v4)
        c2v2 = not c2v3
        if c2v2 then
          c2v2 = false
          c2v3 = c2v0:Name__61dd1630()
          if c2v3 == 1 then
            c2v4 = Name__9828c6d9.IsCapsuleInvulnerable
            c2v3 = Name__6514b208
            c2v3 = c2v3(c2v4)
            c2v2 = not c2v3
            if c2v2 then
              c2v3 = Name__9828c6d9.IsCapsuleInvulnerable
              c2v3 = c2v3(c2v1)
              c2v2 = not c2v3
              if c2v2 then
                c2v3 = c2v0.channelingWraiths
                c2v2 = not c2v3
                if not c2v2 then
                  c2v2 = true
                  c2v3 = c2v0.channelingWraiths
                  if c2v3 ~= 0 then
                    c2v3 = c2v0.currentWraithChannelling
                    c2v4 = v1
                    if c2v3 ~= c2v4 then
                      c2v2 = false
                      do return c2v2 end
                    end
                    c2v2 = true
                  end
                end
              end
            end
          end
        end
      end
    end
    do return c2v2 end
  end
  v17 = function(c3v0)
    local c3v1, c3v2, c3v3, c3v4
    c3v2 = Name__6514b208
    c3v2 = c3v2(c3v0)
    c3v1 = not c3v2
    if c3v1 then
      c3v3 = v11
      c3v1 = c3v0:Name__2888fc5c(c3v3)
      if c3v1 then
        c3v2 = c3v0:Name__a10c08e1()
        c3v1 = not c3v2
        if c3v1 then
          c3v2 = c3v0:Name__decc89f9()
          c3v1 = not c3v2
          if c3v1 then
            c3v2 = c3v0:Name__b7f5db56()
            c3v4 = v7
            c3v2 = c3v2:Name__7b4bbd23(c3v4)
            c3v1 = not c3v2
          end
        end
      end
    end
    do return c3v1 end
  end
  v18 = function(c4v0)
    local c4v1, c4v2, c4v3, c4v4, c4v5, c4v6, c4v7, c4v8, c4v9, c4v10
    c4v1 = v1
    c4v1 = c4v1:Name__682cbf57()
    c4v1 = c4v1:Name__b2e22fcd()
    c4v2 = Name__6514b208
    c4v2 = c4v2(c4v1)
    if not c4v2 then
      c4v2 = c4v1:Name__862ae959()
      c4v3 = Name__6514b208
      c4v3 = c4v3(c4v2)
      if not c4v3 then
        c4v3 = Name__d06efad8
        c4v3, c4v4, c4v5 = c4v3(c4v2)
        for __renovice_for_0_0, __renovice_for_0_1 in c4v3, c4v4, c4v5 do
          c4v8 = 1
          c4v9 = v13
          c4v6 = #c4v9
          c4v7 = 1
          for __renovice_for_1_0 = c4v8, c4v6, c4v7 do
            c4v9 = v13[__renovice_for_1_0]
            if __renovice_for_0_1 ~= c4v9 then
              continue
            end
            c4v10 = not c4v0
            __renovice_for_0_1:Name__048b50ab(c4v10)
          end
        end
      end
    end
    do return end
  end
  v19 = function(c5v0)
    local c5v1, c5v2, c5v3, c5v4, c5v5, c5v6
    c5v2 = v1
    c5v1 = Name__6514b208
    c5v1 = c5v1(c5v2)
    if not c5v1 then
      c5v1 = v1
      c5v1 = c5v1:Name__decc89f9()
      if not c5v1 then
        c5v1 = v1
        c5v1 = c5v1:Name__402a3166()
        if c5v0 then
          c5v2 = Name__6514b208
          c5v2 = c5v2(c5v1)
          if not c5v2 then
            c5v2 = c5v1:Name__b4008f25()
            c5v3 = c5v1:Name__6b58c4a6()
            c5v4 = c5v3 / c5v2
            c5v5 = 0.2
            if c5v4 < c5v5 then
              c5v6 = 0.2 * c5v2
              c5v1:Name__88f0aae7(c5v6)
              c5v4 = true
              do return c5v4 end
            end
          end
        else
          c5v2 = Name__6514b208
          c5v2 = c5v2(c5v1)
          if not c5v2 then
            c5v4 = 0
            c5v1:Name__88f0aae7(c5v4)
          end
        end
        do return end
      end
    end
    do return end
  end
  v3 = nil
  v20 = function(c6v0)
    local c6v1, c6v2, c6v3, c6v4, c6v5, c6v6, c6v7, c6v8, c6v9
    c6v1 = -1
    c6v2 = nil
    c6v3 = 3.4028234663852886e+38
    c6v4 = c6v3
    if c6v0 then
      c6v4 = c6v0 * c6v0
    end
    c6v5 = Name__d06efad8
    c6v6 = v3
    c6v5, c6v6, c6v7 = c6v5(c6v6)
    for __renovice_for_0_0, __renovice_for_0_1 in c6v5, c6v6, c6v7 do
      c6v8 = v16
      c6v8 = c6v8(__renovice_for_0_1, __renovice_for_0_0)
      if not c6v8 then
        continue
      end
      c6v8 = Name__6514b208
      c6v8 = c6v8(c6v2)
      if c6v8 then
        c6v8 = v1
        c6v9 = __renovice_for_0_1.object
        c6v3 = c6v8:Name__445c45c4(c6v9)
        if c6v3 <= c6v4 then
          c6v1 = __renovice_for_0_0
          c6v2 = __renovice_for_0_1
          continue
        end
        c6v3 = 3.4028234663852886e+38
        continue
      end
      c6v8 = v1
      c6v9 = __renovice_for_0_1.object
      c6v8 = c6v8:Name__445c45c4(c6v9)
      if not (c6v8 <= c6v3) then
        continue
      end
      c6v1 = __renovice_for_0_0
      c6v3 = c6v8
      c6v2 = __renovice_for_0_1
    end
    do return c6v1, c6v2 end
  end
  v21 = function(c7v0)
    local c7v1, c7v2, c7v3, c7v4, c7v5, c7v6, c7v7, c7v8, c7v9, c7v10
    c7v2 = 3.4028234663852886e+38
    c7v3 = c7v2
    if c7v0 then
      c7v3 = c7v0 * c7v0
    end
    c7v4 = Name__b364fd20
    c7v6 = Name__3df6d685
    c7v7 = "Duviri"
    c7v4 = c7v4:Name__fe650f83(c7v6(c7v7))
    c7v5 = #c7v4
    c7v6 = 0
    if c7v6 < c7v5 then
      c7v7 = #c7v4
      c7v5 = 1
      c7v6 = -1
      for __renovice_for_0_0 = c7v7, c7v5, c7v6 do
        c7v8 = c7v4[__renovice_for_0_0]
        c7v9 = v17
        c7v9 = c7v9(c7v8)
        if c7v9 then
          continue
        end
        c7v9 = Name__6e962203.Name__0d4f9c32
        c7v9(c7v4, __renovice_for_0_0)
      end
    end
    c7v5 = Name__d06efad8
    c7v5, c7v6, c7v7 = c7v5(c7v4)
    for __renovice_for_1_0, __renovice_for_1_1 in c7v5, c7v6, c7v7 do
      c7v10 = Name__6514b208
      c7v1 = nil
      c7v10 = c7v10(c7v1)
      if c7v10 then
        c7v10 = v1
        c7v2 = c7v10:Name__445c45c4(__renovice_for_1_1)
        if c7v2 <= c7v3 then
          c7v1 = __renovice_for_1_1
          continue
        end
        c7v2 = 3.4028234663852886e+38
        continue
      end
      c7v10 = v1
      c7v10 = c7v10:Name__445c45c4(__renovice_for_1_1)
      if not (c7v10 <= c7v2) then
        continue
      end
      c7v2 = c7v10
      c7v1 = __renovice_for_1_1
    end
    do return c7v1 end
  end
  v22 = function(c8v0)
    local c8v1, c8v2, c8v3, c8v4, c8v5, c8v6, c8v7, c8v8, c8v9, c8v10
    c8v1 = -1
    c8v2 = nil
    c8v3 = 3.4028234663852886e+38
    c8v4 = c8v3
    if c8v0 then
      c8v4 = c8v0 * c8v0
    end
    c8v5 = Name__d06efad8
    c8v6 = v3
    c8v5, c8v6, c8v7 = c8v5(c8v6)
    for __renovice_for_0_0, __renovice_for_0_1 in c8v5, c8v6, c8v7 do
      c8v8 = Name__6514b208
      c8v8 = c8v8(__renovice_for_0_1)
      if c8v8 then
        continue
      end
      c8v9 = __renovice_for_0_1.object
      c8v8 = Name__6514b208
      c8v8 = c8v8(c8v9)
      if c8v8 then
        continue
      end
      repeat
        c8v8 = __renovice_for_0_1:Name__61dd1630()
        if c8v8 ~= 2 then
          c8v8 = __renovice_for_0_1:Name__61dd1630()
          if c8v8 ~= 3 then break end
        end
        c8v8 = Name__6514b208
        c8v8 = c8v8(c8v2)
        if c8v8 then
          c8v8 = v1
          c8v10 = __renovice_for_0_1.object
          c8v3 = c8v8:Name__445c45c4(c8v10)
          if c8v3 <= c8v4 then
            c8v1 = __renovice_for_0_0
            c8v2 = __renovice_for_0_1
            continue
          end
          c8v3 = 3.4028234663852886e+38
          continue
        end
        c8v8 = v1
        c8v10 = __renovice_for_0_1.object
        c8v8 = c8v8:Name__445c45c4(c8v10)
        if c8v8 <= c8v3 then
          c8v1 = __renovice_for_0_0
          c8v3 = c8v8
          c8v2 = __renovice_for_0_1
        end
      until true
    end
    do return c8v1, c8v2 end
  end
  v23 = function(c9v0)
    local c9v1, c9v2, c9v3, c9v4, c9v5, c9v6, c9v7
    c9v2 = c9v0.object
    c9v1 = Name__6514b208
    c9v1 = c9v1(c9v2)
    if c9v1 then
      do return end
    end
    c9v1 = c9v0.object
    c9v3 = Name__bc068dbf
    c9v1 = c9v1:Name__b8f8a1e7(c9v3)
    c9v2 = Name__6514b208
    c9v2 = c9v2(c9v1)
    if not c9v2 then
      c9v2 = #c9v1
      c9v3 = 0
      if c9v3 < c9v2 then
        c9v4 = #c9v1
        c9v2 = 1
        c9v3 = -1
        for __renovice_for_0_0 = c9v4, c9v2, c9v3 do
          c9v5 = c9v1[__renovice_for_0_0]
          c9v6 = Name__6514b208
          c9v6 = c9v6(c9v5)
          if c9v6 then
            continue
          end
          c9v6 = c9v5:Name__4206477e()
          c9v7 = v1
          if c9v6 ~= c9v7 then
            continue
          end
          c9v5:Name__9c6a9ac9()
          do return end
        end
      end
    end
    do return end
  end
  v24 = function(c10v0)
    local c10v1, c10v2, c10v3, c10v4
    c10v1 = c10v0.channelingWraiths
    if not c10v1 then
      do return end
    end
    c10v3 = c10v0.channelingWraiths
    c10v2 = c10v3 - 1
    c10v3 = 0
    c10v1 = Name__b6e30ca3.Name__4042c2a4
    c10v1 = c10v1(c10v2, c10v3)
    c10v0.channelingWraiths = c10v1
    c10v1 = nil
    c10v0.currentWraithChannelling = c10v1
    c10v2 = c10v0.object
    c10v1 = Name__6514b208
    c10v1 = c10v1(c10v2)
    if c10v1 then
      do return end
    end
    c10v1 = c10v0.channelingWraiths
    c10v2 = 0
    if c10v1 <= c10v2 then
      c10v1 = c10v0.object
      c10v3 = Name__a98a2017
      c10v1 = c10v1:Name__efec1c81(c10v3)
      c10v2 = c10v0:Name__61dd1630()
      c10v3 = 2
      if c10v2 < c10v3 then
        c10v3 = Name__6514b208
        c10v3 = c10v3(c10v1)
        if not c10v3 then
          c10v4 = 63
          c10v1:Name__7880ed95(c10v4)
        end
      end
    end
    do return end
  end
  v2 = nil
  v25 = function()
    local c11v0, c11v1, c11v2, c11v3
    c11v1 = v2
    c11v0 = Name__6514b208
    c11v0 = c11v0(c11v1)
    if c11v0 then
      c11v0 = Name__0811edde
      c11v1 = "Updating wraith agent"
      c11v0(c11v1)
      c11v0 = v1
      c11v0 = c11v0:Name__b7f5db56()
      v2 = c11v0
    end
    c11v2 = v2
    c11v1 = Name__6514b208
    c11v1 = c11v1(c11v2)
    c11v0 = not c11v1
    if c11v0 then
      c11v1 = v2
      c11v3 = v10
      c11v1 = c11v1:Name__5c749aad(c11v3)
      if c11v1 ~= 1 then
        c11v0 = false
        do return c11v0 end
      end
      c11v0 = true
    end
    do return c11v0 end
  end
  v26 = function()
    local c12v0, c12v1, c12v2, c12v3, c12v4, c12v5, c12v6
    local __renovice_state_0 = 0
    c12v1 = v2
    c12v0 = Name__6514b208
    c12v0 = c12v0(c12v1)
    if not c12v0 then
      __renovice_state_0 = 2
    else
      __renovice_state_0 = 1
    end
    if __renovice_state_0 == 1 then
      c12v0 = Name__0811edde
      c12v1 = "Wraith Agaent is nil, cannot set Storm Nearest Player behaviour"
      c12v0(c12v1)
      do return end
    end
    if __renovice_state_0 == 2 then
      c12v0 = v2
      c12v0 = c12v0:Name__c5feb74a()
      c12v1 = Name__b364fd20
      c12v3 = v1
      c12v3 = c12v3:Name__65be499d()
      c12v4 = 3000
      c12v1 = c12v1:Name__7601f738(c12v3, c12v4)
      c12v3 = Name__6514b208
      c12v3 = c12v3(c12v1)
      if c12v3 then
        __renovice_state_0 = 4
      else
        __renovice_state_0 = 3
      end
    end
    if __renovice_state_0 == 3 then
      c12v2 = c12v1:Name__13bcf4ad()
      if c12v2 then
        __renovice_state_0 = 5
      else
        __renovice_state_0 = 4
      end
    end
    if __renovice_state_0 == 4 then
      c12v2 = nil
      __renovice_state_0 = 5
    end
    if __renovice_state_0 == 5 then
      c12v3 = Name__6514b208
      c12v3 = c12v3(c12v0)
      if (not c12v3 and c12v0 == c12v2) then
        __renovice_state_0 = 10
      else
        __renovice_state_0 = 7
      end
    end
    if __renovice_state_0 == 7 then
      c12v3 = Name__6514b208
      c12v3 = c12v3(c12v2)
      if c12v3 then
        __renovice_state_0 = 9
      else
        __renovice_state_0 = 8
      end
    end
    if __renovice_state_0 == 8 then
      c12v3 = v2
      c12v6 = 3
      c12v3:Name__a4f709b7(c12v2, c12v6)
      do return end
    end
    if __renovice_state_0 == 9 then
      c12v3 = Name__0811edde
      c12v5 = "Couldn't find a player close enough to "
      c12v6 = v1
      c12v6 = c12v6:Name__50b0e03d()
      c12v4 = c12v5 .. c12v6
      c12v3(c12v4)
      __renovice_state_0 = 10
    end
    if __renovice_state_0 == 10 then
      do return end
    end
    do return end
  end
  v0 = nil
  v27 = function(c13v0)
    local c13v1, c13v2, c13v3, c13v4, c13v5, c13v6, c13v7, c13v8, c13v9, c13v10, c13v11, c13v12, c13v13, c13v14, c13v15, c13v16, c13v17, c13v18, c13v19, c13v20, c13v21
    c13v1 = true
    v4 = c13v1
    c13v3 = Name__2e05e1bc[1]
    c13v4 = false
    c13v5 = 3
    c13v6 = 1
    c13v7 = true
    c13v0:Name__c9ffad55(c13v3, c13v4, c13v5, c13v6, c13v7)
    c13v3 = "TransitionToLoop"
    c13v4 = 2
    c13v0:Name__8057df75(c13v3, c13v4)
    c13v1 = false
    c13v2 = Name__6514b208
    c13v2 = c13v2(c13v0)
    if not c13v2 then
      c13v2 = c13v0:Name__decc89f9()
      if not c13v2 then
        c13v2 = c13v0:Name__a10c08e1()
        if not c13v2 then
          c13v2 = v0
          c13v3 = v6
          c13v3 = c13v3.CHANNELLING
          if c13v2 == c13v3 then
            local __renovice_state_0 = -1
            c13v2 = v1
            c13v4 = false
            c13v2:Name__33e52783(c13v4)
            c13v2 = v1
            c13v4 = 0
            c13v2:Name__dded29df(c13v4)
            c13v2 = v18
            c13v3 = false
            c13v2(c13v3)
            c13v3 = v1
            c13v2 = Name__6514b208
            c13v2 = c13v2(c13v3)
            if c13v2 then
              __renovice_state_0 = -1
            else
              __renovice_state_0 = 1
            end
            if __renovice_state_0 == 1 then
              c13v2 = v1
              c13v2 = c13v2:Name__decc89f9()
              if not c13v2 then
                __renovice_state_0 = 2
              else
                __renovice_state_0 = -1
              end
            end
            if __renovice_state_0 == 2 then
              c13v2 = v1
              c13v2 = c13v2:Name__402a3166()
              c13v3 = Name__6514b208
              c13v3 = c13v3(c13v2)
              if c13v3 then
                __renovice_state_0 = 5
              else
                __renovice_state_0 = 3
              end
            end
            if __renovice_state_0 == 3 then
              c13v3 = c13v2:Name__b4008f25()
              c13v4 = c13v2:Name__6b58c4a6()
              c13v5 = c13v4 / c13v3
              c13v6 = 0.2
              if not (c13v5 < c13v6) then
                __renovice_state_0 = 5
              else
                __renovice_state_0 = 4
              end
            end
            if __renovice_state_0 == 4 then
              c13v7 = 0.2 * c13v3
              c13v2:Name__88f0aae7(c13v7)
              c13v1 = true
              __renovice_state_0 = 6
            end
            if __renovice_state_0 == 5 then
              c13v1 = nil
              __renovice_state_0 = 6
            end
            if __renovice_state_0 ~= 6 then
              c13v1 = nil
            end
            c13v2 = v14
            c13v2 = c13v2.Name__954adc91
            c13v2 = c13v2()
            if not c13v2 then
              c13v2 = v14
              c13v2 = c13v2.Name__eda51d60
              c13v3 = Name__9828c6d9.MissionTransmissionSet
              c13v4 = Name__3df6d685
              c13v5 = "WraithCorruptingPillar"
              c13v2(c13v3, c13v4(c13v5))
            end
            c13v2 = Name__b364fd20
            c13v2 = c13v2:Name__f58c3f32()
            c13v3 = Name__d06efad8
            c13v3, c13v4, c13v5 = c13v3(c13v2)
            for __renovice_for_0_0, __renovice_for_0_1 in c13v3, c13v4, c13v5 do
              c13v8 = Name__d7e3ec85
              c13v11 = "/Lotus/Language/Zariman/VoidCascadeMissionPillarUnderAttack"
              c13v12 = ""
              c13v13 = 0
              c13v14 = 3
              c13v15 = false
              c13v16 = ""
              c13v17 = ""
              c13v18 = nil
              c13v19 = true
              c13v20 = 4
              c13v21 = "PillarUnderAttack"
              c13v8:Name__df85c3d7(__renovice_for_0_1, c13v11, c13v12, c13v13, c13v14, c13v15, c13v16, c13v17, c13v18, c13v19, c13v20, c13v21)
            end
          end
        end
      end
    end
    c13v3 = 23
    c13v4 = 20
    c13v5 = 15
    c13v6 = 27
    c13v7 = 29
    c13v8 = 12
    c13v9 = 6
    c13v10 = 13
    c13v2 = {c13v3, c13v4, c13v5, c13v6, c13v7, c13v8, c13v9, c13v10}
    while true do
      c13v3 = Name__6514b208
      c13v3 = c13v3(c13v0)
      if c13v3 then break end
      c13v3 = c13v0:Name__decc89f9()
      if c13v3 then break end
      c13v3 = c13v0:Name__a10c08e1()
      if c13v3 then break end
      c13v5 = v2
      c13v4 = Name__6514b208
      c13v4 = c13v4(c13v5)
      if c13v4 then
        c13v4 = Name__0811edde
        c13v5 = "Updating wraith agent"
        c13v4(c13v5)
        c13v4 = v1
        c13v4 = c13v4:Name__b7f5db56()
        v2 = c13v4
      end
      c13v5 = v2
      c13v4 = Name__6514b208
      c13v4 = c13v4(c13v5)
      c13v3 = not c13v4
      if c13v3 then
        c13v4 = v2
        c13v6 = v10
        c13v4 = c13v4:Name__5c749aad(c13v6)
        if c13v4 ~= 1 then
          c13v3 = false
        else
          c13v3 = true
        end
      end
      if c13v3 then break end
      c13v3 = v4
      if not c13v3 then break end
      c13v5 = 1
      c13v3 = #c13v2
      c13v4 = 1
      for __renovice_for_1_0 = c13v5, c13v3, c13v4 do
        c13v8 = c13v2[__renovice_for_1_0]
        c13v6 = c13v0:Name__eeede27b(c13v8)
        if not c13v6 then
          continue
        end
        c13v6 = false
        v4 = c13v6
        break
      end
      c13v3 = Name__daf81ef9
      c13v4 = 0
      c13v3(c13v4)
    end
    if c13v1 then
      c13v4 = v1
      c13v3 = Name__6514b208
      c13v3 = c13v3(c13v4)
      if not c13v3 then
        c13v3 = v1
        c13v3 = c13v3:Name__decc89f9()
        if c13v3 then
        else
          c13v3 = v1
          c13v3 = c13v3:Name__402a3166()
          c13v4 = Name__6514b208
          c13v4 = c13v4(c13v3)
          if not c13v4 then
            c13v6 = 0
            c13v3:Name__88f0aae7(c13v6)
          end
        end
      end
    end
    c13v3 = false
    v4 = c13v3
    c13v3 = Name__0811edde
    c13v4 = "Ended channelling"
    c13v3(c13v4)
    do return end
  end
  ChannellingAnimStartToLoop = v27
  v27 = function(c14v0)
    local c14v1, c14v2, c14v3, c14v4
    c14v1 = Name__6514b208
    c14v1 = c14v1(c14v0)
    if c14v1 then
      c14v1 = Name__0811edde
      c14v2 = "Wraith died/was destroyed before starting corruption.."
      c14v1(c14v2)
      do return end
    end
    c14v1 = Name__0811edde
    c14v3 = c14v0:Name__50b0e03d()
    c14v4 = " started corruption"
    c14v2 = c14v3 .. c14v4
    c14v1(c14v2)
    c14v1 = 0
    while true do
      c14v2 = 1.5
      if not (c14v1 <= c14v2) then break end
      c14v2 = Name__6514b208
      c14v2 = c14v2(c14v0)
      if c14v2 then break end
      c14v2 = c14v0:Name__a10c08e1()
      if c14v2 then break end
      c14v4 = c14v1 / 1.5
      c14v0:Name__0f2113b8(c14v4)
      c14v2 = Name__daf81ef9
      c14v3 = 0
      c14v2(c14v3)
      c14v2 = Name__f3c503f8
      c14v2 = c14v2()
      c14v1 = c14v1 + c14v2
    end
    c14v2 = Name__6514b208
    c14v2 = c14v2(c14v0)
    if not c14v2 then
      c14v2 = c14v0:Name__decc89f9()
      if not c14v2 then
        c14v2 = c14v0:Name__a10c08e1()
        if not c14v2 then
          c14v4 = 1
          c14v0:Name__0f2113b8(c14v4)
          c14v4 = false
          c14v0:Name__53462ebf(c14v4)
        end
      end
    end
    do return end
  end
  ChannelingAnimLoopToEnd = v27
  v27 = function(c15v0)
    local c15v1, c15v2, c15v3, c15v4, c15v5, c15v6, c15v7, c15v8, c15v9, c15v10, c15v11, c15v12
    c15v1 = Name__daf81ef9
    c15v2 = 0
    c15v1(c15v2)
    c15v1 = Name__6514b208
    c15v1 = c15v1(c15v0)
    if not c15v1 then
      c15v1 = c15v0:Name__402a3166()
      c15v3 = v9
      c15v1 = c15v1:Name__e76617b5(c15v3)
      if c15v1 then
        c15v1 = 1.5
        c15v2 = Name__b364fd20
        c15v4 = Name__3df6d685
        c15v5 = "WraithGhost"
        c15v4 = c15v4(c15v5)
        c15v2 = c15v2:Name__1bf05519(c15v4, c15v0:Name__65be499d())
        c15v3 = Name__6514b208
        c15v3 = c15v3(c15v2)
        if not c15v3 then
          c15v5 = Name__3df6d685
          c15v6 = "GAME_C1_ROOT"
          c15v3 = c15v2:Name__ae65b98a(c15v5(c15v6))
          c15v6 = Name__3df6d685
          c15v7 = "GAME_C1_ROOT"
          c15v4 = c15v2:Name__bf7fbb72(c15v6(c15v7))
          c15v5 = c15v2:Name__7d228e31()
          c15v6 = Name__b364fd20
          c15v6:Name__cbbc7941(c15v2)
          c15v0:Name__f689125c(c15v3, c15v4)
          c15v8 = Name__b6adf041
          c15v9 = false
          c15v10 = 3
          c15v11 = 1
          c15v12 = true
          c15v0:Name__c9ffad55(c15v8, c15v9, c15v10, c15v11, c15v12)
          c15v8 = true
          c15v0:Name__53462ebf(c15v8)
          c15v6 = Name__b364fd20
          c15v6 = c15v6:Name__df603d81()
          c15v6 = c15v6:Name__9f4a285b()
          c15v9 = 2.5 * c15v5
          c15v8 = c15v3 - c15v9
          c15v9 = 0
          c15v10 = 2.5
          c15v9 = c15v6:Name__30180d8f(c15v8, c15v9, c15v10)
          c15v11 = true
          c15v0:Name__ad069aa4(c15v9, c15v4, c15v11)
        end
        while true do
          c15v3 = Name__6514b208
          c15v3 = c15v3(c15v0)
          if c15v3 then break end
          c15v3 = 0
          if not (c15v3 < c15v1) then break end
          c15v5 = c15v1 / 1.5
          c15v0:Name__0f2113b8(c15v5)
          c15v3 = Name__daf81ef9
          c15v4 = 0
          c15v3(c15v4)
          c15v3 = Name__f3c503f8
          c15v3 = c15v3()
          c15v1 = c15v1 - c15v3
        end
        c15v3 = Name__6514b208
        c15v3 = c15v3(c15v0)
        if not c15v3 then
          c15v3 = c15v0:Name__402a3166()
          c15v5 = v9
          c15v3 = c15v3:Name__e76617b5(c15v5)
          if c15v3 then
            c15v5 = 0
            c15v0:Name__0f2113b8(c15v5)
            c15v3 = c15v0:Name__402a3166()
            c15v5 = v9
            c15v3:Name__1e8691a3(c15v5)
          end
        end
      end
    end
    do return end
  end
  IsCleansing = v27
  v27 = function(c16v0, c16v1)
    local c16v2, c16v3, c16v4, c16v5, c16v6, c16v7, c16v8, c16v9
    c16v3 = v1
    c16v2 = Name__6514b208
    c16v2 = c16v2(c16v3)
    if not c16v2 then
      c16v2 = v1
      c16v2:Name__33e52783(c16v1)
      c16v2 = v1
      if c16v1 then
        c16v4 = -10
      else
        c16v4 = 0
      end
      c16v2:Name__dded29df(c16v4)
      c16v2 = v1
      c16v4 = not c16v1
      c16v2:Name__b4e6c4f7(c16v4)
      c16v2 = v1
      c16v4 = not c16v1
      c16v2:Name__513438f5(c16v4)
      c16v2 = v1
      c16v2:Name__322a2c8b(c16v1)
      c16v2 = v1
      c16v4 = not c16v1
      c16v2:Name__7edd5e06(c16v4)
      if c16v1 then
        c16v2 = v1
        c16v4 = v6
        c16v4 = c16v4.CORRUPTING
        c16v2:Name__290551f4(c16v4)
        c16v2 = v1
        c16v4 = v1
        c16v2:Name__24b63d02(c16v4:Name__65be499d())
        c16v2 = v1
        c16v4 = Name__3df6d685
        c16v5 = "ChannelingAnimLoopToEnd"
        c16v4 = c16v4(c16v5)
        c16v5 = false
        c16v2:Name__55aca91b(c16v4, c16v5)
        c16v2 = v1
        c16v4 = Name__166b3fd6
        c16v2 = c16v2:Name__efec1c81(c16v4)
        c16v3 = Name__6514b208
        c16v3 = c16v3(c16v2)
        if not c16v3 then
          c16v2:Name__9c6a9ac9()
        end
        c16v3 = v1
        c16v3 = c16v3:Name__402a3166()
        c16v4 = Name__6514b208
        c16v4 = c16v4(c16v3)
        if not c16v4 then
          c16v6 = v8
          c16v3:Name__cb2fc150(c16v6)
          c16v4 = v1
          c16v4 = c16v4:Name__402a3166()
          c16v6 = v8
          c16v7 = 25
          c16v8 = 6
          c16v9 = 0
          c16v4:Name__c58029df(c16v6, c16v7, c16v8, c16v9)
          c16v4 = v1
          c16v6 = 0
          c16v7 = v8
          c16v4:Name__2e224f68(c16v6, c16v7)
        end
      else
        c16v2 = v1
        c16v4 = v6
        c16v4 = c16v4.IDLE
        c16v2:Name__290551f4(c16v4)
        c16v2 = v1
        c16v4 = Name__76c01753
        c16v5 = 0
        c16v6 = 0
        c16v7 = 0
        c16v2:Name__24b63d02(c16v4(c16v5, c16v6, c16v7))
        c16v2 = v1
        c16v4 = Name__166b3fd6
        c16v5 = Name__f6aba2d9
        c16v6 = Name__76c01753
        c16v7 = 0
        c16v8 = 0
        c16v9 = 0
        c16v6 = c16v6(c16v7, c16v8, c16v9)
        c16v7 = Name__3b0d8a4c
        c16v2 = c16v2:Name__f275c3f8(c16v4, c16v5, c16v6, c16v7)
        c16v3 = Name__6514b208
        c16v3 = c16v3(c16v2)
        if not c16v3 then
          c16v5 = Name__cef5d9d1
          c16v6 = 20
          c16v7 = 40
          c16v2:Name__2249d1c3(c16v5(c16v6, c16v7))
        end
        c16v3 = v1
        c16v3 = c16v3:Name__402a3166()
        c16v4 = Name__6514b208
        c16v4 = c16v4(c16v3)
        if not c16v4 then
          c16v6 = v8
          c16v3:Name__9698eecf(c16v6)
          c16v4 = v1
          c16v4 = c16v4:Name__402a3166()
          c16v6 = v8
          c16v4:Name__1e8691a3(c16v6)
          c16v4 = v1
          c16v4 = c16v4:Name__402a3166()
          c16v6 = v8
          c16v4:Name__9698eecf(c16v6)
        end
        c16v4 = v1
        c16v6 = 0
        c16v7 = v8
        c16v4:Name__1141e8d6(c16v6, c16v7)
        c16v4 = v1
        c16v4 = c16v4:Name__402a3166()
        c16v6 = v9
        c16v7 = 25
        c16v8 = 6
        c16v9 = 0
        c16v4:Name__c58029df(c16v6, c16v7, c16v8, c16v9)
      end
    end
    c16v3 = v2
    c16v2 = Name__6514b208
    c16v2 = c16v2(c16v3)
    if not c16v2 then
      c16v2 = v2
      c16v5 = v7
      c16v2:Name__a47a33c6(c16v1, c16v5)
      c16v2 = v2
      c16v4 = nil
      c16v5 = 1
      c16v2:Name__3a670028(c16v4, c16v5)
    end
    c16v2 = 1
    if c16v2 <= c16v0 then
      if c16v1 then
        c16v2 = Name__9828c6d9.CorruptCapsule
        if c16v2 then
          c16v2 = Name__9828c6d9.CorruptCapsule
          c16v4 = v1
          c16v2(c16v0, c16v4)
          do return end
        end
      end
      if not c16v1 then
        c16v2 = Name__9828c6d9.CleanseCapsule
        if c16v2 then
          c16v2 = Name__9828c6d9.CleanseCapsule
          c16v2(c16v0)
        end
      end
    end
    do return end
  end
  v28 = function(c17v0)
    local c17v1, c17v2, c17v3, c17v4, c17v5, c17v6, c17v7, c17v8, c17v9, c17v10, c17v11, c17v12, c17v13, c17v14, c17v15, c17v16
    local __renovice_state_0 = 0
    c17v1 = Name__d7e3ec85
    c17v1 = c17v1:Name__ce228771()
    if c17v1 then
      __renovice_state_0 = 2
    else
      __renovice_state_0 = 1
    end
    if __renovice_state_0 == 1 then
      c17v1 = Name__0811edde
      c17v2 = "Don't start corrupt behaviour on client. Bail..."
      c17v1(c17v2)
      do return end
    end
    if __renovice_state_0 == 2 then
      c17v1 = Name__0811edde
      c17v2 = "Wraith started Corrupt Behaviour"
      c17v1(c17v2)
      v1 = c17v0
      c17v1 = Name__9828c6d9.GetCapsules
      if c17v1 then
        __renovice_state_0 = 4
      else
        __renovice_state_0 = 3
      end
    end
    if __renovice_state_0 == 3 then
      c17v1 = Name__0811edde
      c17v2 = "No capsules error"
      c17v1(c17v2)
      do return end
    end
    if __renovice_state_0 == 4 then
      c17v1 = Name__9828c6d9.GetCapsules
      c17v1 = c17v1()
      v3 = c17v1
      c17v2 = v1
      c17v1 = Name__6514b208
      c17v1 = c17v1(c17v2)
      if c17v1 then
        __renovice_state_0 = 6
      else
        __renovice_state_0 = 5
      end
    end
    if __renovice_state_0 == 5 then
      c17v1 = v1
      c17v1 = c17v1:Name__decc89f9()
      if not c17v1 then
        __renovice_state_0 = 7
      else
        __renovice_state_0 = 6
      end
    end
    if __renovice_state_0 == 6 then
      c17v1 = Name__0811edde
      c17v2 = "Wraith is null or dead already"
      c17v1(c17v2)
      do return end
    end
    if __renovice_state_0 == 7 then
      c17v1 = v1
      c17v3 = v12
      c17v1 = c17v1:Name__2888fc5c(c17v3)
      v5 = c17v1
      c17v1 = v1
      c17v1 = c17v1:Name__b7f5db56()
      v2 = c17v1
      c17v1 = v6
      c17v1 = c17v1.IDLE
      v0 = c17v1
      c17v1 = -1
      c17v2 = nil
      c17v3 = -1
      c17v5 = v1
      c17v5 = c17v5:Name__18cd8d09()
      c17v6 = v6
      c17v6 = c17v6.CORRUPTING
      if c17v5 == c17v6 then
        __renovice_state_0 = 9
      else
        __renovice_state_0 = 8
      end
    end
    if __renovice_state_0 == 8 then
      c17v4 = false
      __renovice_state_0 = 10
    end
    if __renovice_state_0 == 9 then
      c17v4 = true
      __renovice_state_0 = 10
    end
    if __renovice_state_0 == 10 then
      if not c17v4 then
        __renovice_state_0 = 14
      else
        __renovice_state_0 = 11
      end
    end
    if __renovice_state_0 == 11 then
      c17v5 = Name__0811edde
      c17v6 = "POST MIGRATION: Wraith is corrupting a pillar: set it back to where it should be!"
      c17v5(c17v6)
      c17v5 = v6
      c17v5 = c17v5.CORRUPTING
      v0 = c17v5
      c17v5 = v1
      c17v5 = c17v5:Name__6f6f22f6()
      c17v6 = Name__76c01753
      c17v7 = 0
      c17v8 = 0
      c17v9 = 0
      c17v6 = c17v6(c17v7, c17v8, c17v9)
      if c17v5 == c17v6 then
        __renovice_state_0 = 13
      else
        __renovice_state_0 = 12
      end
    end
    if __renovice_state_0 == 12 then
      c17v6 = v1
      c17v9 = Name__3b0d8a4c
      c17v6:Name__f689125c(c17v5, c17v9)
      __renovice_state_0 = 13
    end
    if __renovice_state_0 == 13 then
      c17v6 = v22
      c17v7 = 12
      c17v1, c17v2 = c17v6(c17v7)
      c17v6 = v27
      c17v8 = true
      c17v6(c17v1, c17v8)
    end
    if __renovice_state_0 == 14 then
      c17v5 = v1
      c17v7 = v6
      c17v7 = c17v7.IDLE
      c17v5:Name__290551f4(c17v7)
      c17v5 = v1
      c17v5 = c17v5:Name__402a3166()
      c17v7 = v9
      c17v5 = c17v5:Name__e76617b5(c17v7)
      if not c17v5 then
        __renovice_state_0 = 20
      else
        __renovice_state_0 = 15
      end
    end
    if __renovice_state_0 == 15 then
      c17v6 = Name__0811edde
      c17v7 = "New wraith: purged out of a pillar!"
      c17v6(c17v7)
      c17v6 = v1
      c17v8 = Name__3df6d685
      c17v9 = "IsCleansing"
      c17v8 = c17v8(c17v9)
      c17v9 = true
      c17v6:Name__55aca91b(c17v8, c17v9)
      c17v6 = v6
      c17v6 = c17v6.COOLDOWN
      v0 = c17v6
      c17v3 = 10
      c17v7 = v1
      c17v6 = Name__6514b208
      c17v6 = c17v6(c17v7)
      if not c17v6 then
        __renovice_state_0 = 17
      else
        __renovice_state_0 = 16
      end
    end
    if __renovice_state_0 == 16 then
      c17v6 = v1
      c17v6 = c17v6:Name__decc89f9()
      if c17v6 then
      else
        __renovice_state_0 = 17
      end
    end
    if __renovice_state_0 == 17 then
      c17v7 = v2
      c17v6 = Name__6514b208
      c17v6 = c17v6(c17v7)
      if not c17v6 then
        __renovice_state_0 = 19
      else
        __renovice_state_0 = 18
      end
    end
    if __renovice_state_0 == 18 then
      c17v6 = Name__0811edde
      c17v7 = "Updating wraith agent"
      c17v6(c17v7)
      c17v6 = v1
      c17v6 = c17v6:Name__b7f5db56()
      v2 = c17v6
      __renovice_state_0 = 19
    end
    if __renovice_state_0 == 19 then
      c17v6 = v26
      c17v6()
    end
    if __renovice_state_0 == 20 then
      c17v6 = Name__0811edde
      c17v7 = "New wraith: just spawned"
      c17v6(c17v7)
    end
    while true do
      c17v5 = Name__d7e3ec85
      c17v5 = c17v5:Name__ce228771()
      if not c17v5 then break end
      c17v6 = v1
      c17v5 = Name__6514b208
      c17v5 = c17v5(c17v6)
      if c17v5 then break end
      c17v5 = v1
      c17v5 = c17v5:Name__decc89f9()
      if c17v5 then break end
      c17v5 = Name__9828c6d9.isStreamingLevel
      if c17v5 then break end
      c17v5 = v0
      c17v6 = v6
      c17v6 = c17v6.STORMING
      c17v5 = v0
      c17v6 = v6
      c17v6 = c17v6.CHANNELLING
      c17v5 = v4
      c17v5 = v16
      c17v5 = c17v5(c17v2, c17v1)
      c17v5 = v1
      c17v7 = c17v2.object
      c17v5 = c17v5:Name__445c45c4(c17v7)
      c17v6 = 225
      c17v5 = false
      v4 = c17v5
      c17v3 = 10
      c17v5 = v6
      c17v5 = c17v5.COOLDOWN
      v0 = c17v5
      c17v5 = v1
      c17v7 = nil
      c17v8 = false
      c17v5:Name__c9ffad55(c17v7, c17v8)
      c17v5 = v1
      c17v7 = false
      c17v5:Name__33e52783(c17v7)
      c17v5 = v1
      c17v7 = 0
      c17v5:Name__dded29df(c17v7)
      c17v5 = v26
      c17v5()
      c17v5 = v2
      c17v5:Name__297c7bbf()
      c17v5 = v18
      c17v6 = true
      c17v5(c17v6)
      c17v5 = v23
      c17v5(c17v2)
      c17v5 = v24
      c17v5(c17v2)
      c17v5 = Name__daf81ef9
      c17v6 = 0
      c17v5(c17v6)
      c17v5 = Name__f3c503f8
      c17v5 = c17v5()
      c17v3 = c17v3 - c17v5
      c17v5 = 0
      if c17v3 <= c17v5 then
        c17v3 = -1
        c17v5 = v6
        c17v5 = c17v5.CORRUPTING
        v0 = c17v5
        c17v5 = v23
        c17v5(c17v2)
        c17v5 = v24
        c17v5(c17v2)
        c17v5 = v27
        c17v7 = true
        c17v5(c17v1, c17v7)
      end
      c17v6 = v2
      c17v5 = Name__6514b208
      c17v5 = c17v5(c17v6)
      if c17v5 then
        c17v5 = Name__0811edde
        c17v6 = "Updating wraith agent"
        c17v5(c17v6)
        c17v5 = v1
        c17v5 = c17v5:Name__b7f5db56()
        v2 = c17v5
      end
      c17v5 = v0
      c17v6 = v6
      c17v6 = c17v6.IDLE
      c17v5 = v0
      c17v6 = v6
      c17v6 = c17v6.CORRUPTING
      if c17v5 == c17v6 then
        c17v6 = c17v2
        c17v7 = Name__6514b208
        c17v7 = c17v7(c17v6)
        c17v5 = not c17v7
        if c17v5 then
          c17v8 = c17v6.object
          c17v7 = Name__6514b208
          c17v7 = c17v7(c17v8)
          c17v5 = not c17v7
          if c17v5 then
            c17v5 = true
            c17v7 = c17v6:Name__61dd1630()
            if c17v7 ~= 2 then
              c17v7 = c17v6:Name__61dd1630()
              if c17v7 ~= 3 then
                c17v5 = false
              else
                c17v5 = true
              end
            end
          end
        end
        if not c17v5 then
          c17v5 = v27
          c17v7 = false
          c17v5(c17v1, c17v7)
          c17v1 = -1
          c17v2 = nil
          c17v3 = 20
          c17v5 = v6
          c17v5 = c17v5.COOLDOWN
          v0 = c17v5
          c17v5 = v26
          c17v5()
          c17v5 = v2
          c17v5:Name__297c7bbf()
          c17v5 = v18
          c17v6 = true
          c17v5(c17v6)
          c17v5 = v1
          c17v7 = Name__3df6d685
          c17v8 = "IsCleansing"
          c17v7 = c17v7(c17v8)
          c17v8 = false
          c17v5:Name__55aca91b(c17v7, c17v8)
          c17v5 = Name__daf81ef9
          c17v6 = 0
          c17v5(c17v6)
        else
          c17v5 = Name__daf81ef9
          c17v6 = 0.1
          c17v5(c17v6)
        end
      else
        c17v5 = Name__f3c503f8
        c17v5 = c17v5()
        c17v3 = c17v3 - c17v5
        c17v5 = 0
        if c17v3 <= c17v5 then
          c17v3 = -1
          c17v5 = v6
          c17v5 = c17v5.IDLE
          v0 = c17v5
        end
        c17v5 = Name__daf81ef9
        c17v6 = 0
        c17v5(c17v6)
      end
      c17v7 = v2
      c17v6 = Name__6514b208
      c17v6 = c17v6(c17v7)
      if c17v6 then
        c17v6 = Name__0811edde
        c17v7 = "Updating wraith agent"
        c17v6(c17v7)
        c17v6 = v1
        c17v6 = c17v6:Name__b7f5db56()
        v2 = c17v6
      end
      c17v7 = v2
      c17v6 = Name__6514b208
      c17v6 = c17v6(c17v7)
      c17v5 = not c17v6
      if c17v5 then
        c17v6 = v2
        c17v8 = v10
        c17v6 = c17v6:Name__5c749aad(c17v8)
        if c17v6 ~= 1 then
          c17v5 = false
        else
          c17v5 = true
        end
      end
      if c17v5 then
        c17v5 = Name__daf81ef9
        c17v6 = 3
        c17v5(c17v6)
      else
        c17v5 = v5
        if c17v5 then
          c17v5 = v21
          c17v6 = 20
          c17v2 = c17v5(c17v6)
          c17v5 = Name__6514b208
          c17v5 = c17v5(c17v2)
          if not c17v5 then
            c17v5 = v2
            c17v8 = 2
            c17v5:Name__3a670028(c17v2, c17v8)
            c17v5 = v6
            c17v5 = c17v5.STORMING
            v0 = c17v5
            c17v5 = Name__daf81ef9
            c17v6 = 0
            c17v5(c17v6)
          else
            c17v5 = v26
            c17v5()
            c17v5 = Name__daf81ef9
            c17v6 = 3
            c17v5(c17v6)
          end
        else
          c17v5 = v20
          c17v6 = nil
          c17v1, c17v2 = c17v5(c17v6)
          c17v5 = v16
          c17v5 = c17v5(c17v2, c17v1)
          if c17v5 then
            c17v5 = v2
            c17v7 = c17v2.object
            c17v8 = 3
            c17v5:Name__3a670028(c17v7, c17v8)
            c17v5 = v1
            c17v7 = true
            c17v5:Name__33e52783(c17v7)
            c17v5 = v1
            c17v7 = -10
            c17v5:Name__dded29df(c17v7)
            c17v6 = c17v2.channelingWraiths
            c17v5 = c17v6 or 0
            c17v2.channelingWraiths = c17v5
            c17v5 = v6
            c17v5 = c17v5.STORMING
            v0 = c17v5
            c17v5 = Name__daf81ef9
            c17v6 = 0
            c17v5(c17v6)
          else
            c17v5 = v26
            c17v5()
            c17v5 = Name__daf81ef9
            c17v6 = 3
            c17v5(c17v6)
          end
        end
      end
      c17v5 = v5
      if c17v5 then
        c17v5 = v17
        c17v5 = c17v5(c17v2)
        if c17v5 then
          c17v5 = Name__daf81ef9
          c17v6 = 0.25
          c17v5(c17v6)
          continue
        end
        c17v2 = nil
        c17v5 = v26
        c17v5()
        c17v3 = 10
        c17v5 = v6
        c17v5 = c17v5.COOLDOWN
        v0 = c17v5
        c17v5 = Name__daf81ef9
        c17v6 = 0
        c17v5(c17v6)
        continue
      end
      c17v5 = v16
      c17v5 = c17v5(c17v2, c17v1)
      if not c17v5 then
        c17v5 = Name__0811edde
        c17v6 = "Capsule target is not valid anymore!"
        c17v5(c17v6)
        c17v5 = v26
        c17v5()
        c17v5 = v1
        c17v7 = false
        c17v5:Name__33e52783(c17v7)
        c17v5 = v1
        c17v7 = 0
        c17v5:Name__dded29df(c17v7)
        c17v5 = v6
        c17v5 = c17v5.IDLE
        v0 = c17v5
        c17v5 = Name__daf81ef9
        c17v6 = 0
        c17v5(c17v6)
        continue
      end
      c17v5 = v1
      c17v7 = c17v2.object
      c17v5 = c17v5:Name__445c45c4(c17v7)
      c17v6 = 16
      if c17v5 < c17v6 then
        c17v6 = c17v2:Name__61dd1630()
        if c17v6 == 1 then
          c17v3 = 10
          c17v6 = v6
          c17v6 = c17v6.CHANNELLING
          v0 = c17v6
          c17v6 = v1
          c17v6 = c17v6:Name__65be499d()
          c17v7 = Name__3c831418
          c17v9 = c17v2.object
          c17v9 = c17v9:Name__3ca198c7()
          c17v10 = v1
          c17v7 = c17v7(c17v6, c17v9, c17v10:Name__c823bed7())
          c17v8 = v1
          c17v8:Name__f689125c(c17v6, c17v7)
          c17v8 = v2
          c17v10 = c17v2.object
          c17v11 = false
          c17v8:Name__69d9ec81(c17v10, c17v11)
          c17v8 = v2
          c17v10 = c17v2.object
          c17v11 = Name__76c01753
          c17v12 = 0
          c17v13 = 0
          c17v14 = 0
          c17v8:Name__103057f4(c17v10, c17v11(c17v12, c17v13, c17v14))
          c17v8 = v1
          c17v10 = Name__3df6d685
          c17v11 = "ChannellingAnimStartToLoop"
          c17v10 = c17v10(c17v11)
          c17v11 = false
          c17v8:Name__55aca91b(c17v10, c17v11)
          c17v8 = c17v2.object
          c17v10 = Name__a98a2017
          c17v8 = c17v8:Name__efec1c81(c17v10)
          c17v9 = Name__6514b208
          c17v9 = c17v9(c17v8)
          if not c17v9 then
            c17v9 = c17v8:Name__7fb853cb()
            c17v10 = 40
            if c17v9 ~= c17v10 then
              c17v8:Name__9c6a9ac9()
              c17v9 = c17v2.object
              c17v11 = Name__95f65cc4
              c17v12 = Name__f6aba2d9
              c17v13 = Name__76c01753
              c17v14 = 0
              c17v15 = 1
              c17v16 = 0
              c17v13 = c17v13(c17v14, c17v15, c17v16)
              c17v14 = Name__3b0d8a4c
              c17v15 = nil
              c17v16 = 1
              c17v9 = c17v9:Name__f275c3f8(c17v11, c17v12, c17v13, c17v14, c17v15, c17v16)
              c17v12 = 40
              c17v9:Name__7880ed95(c17v12)
            end
          end
          c17v9 = c17v2.object
          c17v11 = Name__bc068dbf
          c17v12 = Name__f6aba2d9
          c17v13 = Name__76c01753
          c17v14 = 0
          c17v15 = 1
          c17v16 = 0
          c17v13 = c17v13(c17v14, c17v15, c17v16)
          c17v14 = Name__3b0d8a4c
          c17v15 = nil
          c17v16 = 1
          c17v9 = c17v9:Name__f275c3f8(c17v11, c17v12, c17v13, c17v14, c17v15, c17v16)
          c17v10 = Name__6514b208
          c17v10 = c17v10(c17v9)
          if not c17v10 then
            c17v12 = v1
            c17v13 = 2
            c17v9:Name__59ff48e0(c17v12, c17v13)
          end
          c17v11 = c17v2.channelingWraiths
          c17v10 = c17v11 + 1
          c17v2.channelingWraiths = c17v10
          c17v10 = v1
          c17v2.currentWraithChannelling = c17v10
        end
      end
      c17v6 = Name__daf81ef9
      c17v7 = 0.25
      c17v6(c17v7)
    end
    c17v5 = Name__b364fd20
    c17v5 = c17v5:Name__ce228771()
    if c17v5 then
      c17v5 = Name__9828c6d9.isStreamingLevel
      if not c17v5 then
        c17v5 = Name__6514b208
        c17v5 = c17v5(c17v2)
        if not c17v5 then
          c17v5 = -1
          if c17v5 < c17v1 then
            c17v5 = v23
            c17v5(c17v2)
            c17v5 = v24
            c17v5(c17v2)
          end
        end
        c17v6 = c17v2
        c17v7 = Name__6514b208
        c17v7 = c17v7(c17v6)
        c17v5 = not c17v7
        if c17v5 then
          c17v8 = c17v6.object
          c17v7 = Name__6514b208
          c17v7 = c17v7(c17v8)
          c17v5 = not c17v7
          if c17v5 then
            c17v5 = true
            c17v7 = c17v6:Name__61dd1630()
            if c17v7 ~= 2 then
              c17v7 = c17v6:Name__61dd1630()
              if c17v7 ~= 3 then
                c17v5 = false
              else
                c17v5 = true
              end
            end
          end
        end
        if c17v5 then
          c17v5 = v27
          c17v7 = false
          c17v5(c17v1, c17v7)
        end
        c17v6 = v2
        c17v5 = Name__6514b208
        c17v5 = c17v5(c17v6)
        if not c17v5 then
          c17v5 = v2
          c17v7 = nil
          c17v8 = 1
          c17v5:Name__3a670028(c17v7, c17v8)
        end
      end
    end
    do return end
  end
  CorruptBehaviour = v28
  do return end
