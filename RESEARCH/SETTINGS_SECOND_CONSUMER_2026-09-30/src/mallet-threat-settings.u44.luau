  local v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17
  -- Threat level forced at the SetThreatLevel handoff (see v11/v12 below).
  -- Compiled default 5 until activate(context) recomputes it.
  local forcedThreatLevel = 5
  v0 = require
  v1 = "Lotus.Scripts.Libs.AbilitiesLib"
  v0 = v0(v1)
  v1 = function(c1v0)
    do return c1v0:IsKilled() end
  end
  v2 = function(c2v0)
    do return c2v0:GetHealth() end
  end
  v3 = function(c3v0)
    local c3v1, c3v2, c3v3, c3v4, c3v5, c3v6, c3v7, c3v8, c3v9, c3v10, c3v11
    c3v1 = false
    c3v2 = false
    c3v3 = false
    c3v4 = -1
    c3v5 = IsNull
    c3v5 = c3v5(c3v0)
    if c3v5 then
      do return c3v1, c3v2, c3v3, c3v4 end
    end
    c3v5 = pcall
    c3v6 = v1
    c3v5, c3v6 = c3v5(c3v6, c3v0)
    if c3v5 then
      c3v7 = type
      c3v7 = c3v7(c3v6)
      c3v10 = "boolean"
      c3v11 = c3v7
      if c3v11 == c3v10 then
        c3v1 = true
        c3v2 = c3v6
      end
    end
    c3v7 = pcall
    c3v8 = v2
    c3v7, c3v8 = c3v7(c3v8, c3v0)
    if c3v7 then
      c3v9 = type
      c3v9 = c3v9(c3v8)
      c3v10 = "number"
      c3v11 = c3v9
      if c3v11 == c3v10 then
        c3v3 = true
        c3v4 = c3v8
      end
    end
    do return c3v1, c3v2, c3v3, c3v4 end
  end
  v4 = function(c4v0, c4v1, c4v2, c4v3, c4v4, c4v5, c4v6, c4v7)
    do return c4v0, c4v1, c4v2, c4v3, c4v4, c4v5, c4v6, c4v7 end
  end
  v5 = function(c5v0)
    local c5v1, c5v2, c5v3, c5v4
    c5v1 = IsNull
    c5v1 = c5v1(c5v0)
    if c5v1 then
      c5v1 = false
      do return c5v1 end
    end
    c5v2 = c5v0:GetLocalizeTag()
    c5v2 = c5v2:c_str()
    c5v3 = "/Lotus/Language/Suits/BardMusicAbilityName"
    c5v4 = c5v2
    if c5v4 ~= c5v3 then
      c5v1 = false
      do return c5v1 end
    end
    c5v1 = true
    do return c5v1 end
  end
  v6 = function(c6v0, c6v1)
    local c6v2, c6v3, c6v4, c6v5, c6v6
    c6v2 = IsNull
    c6v2 = c6v2(c6v0)
    if c6v2 then
      do return c6v1 end
    end
    c6v2 = c6v0:InventoryControl()
    c6v3 = c6v2:GetActivePowerSuit()
    c6v4 = IsNull
    c6v4 = c6v4(c6v3)
    if c6v4 then
      do return c6v1 end
    end
    c6v5 = 10
    c6v6 = c6v3:GetType()
    do return c6v2:GetUpgradeModifiedValue(c6v1, c6v5, c6v6, c6v3) end
  end
  v7 = function(c7v0)
    local c7v1, c7v2, c7v3, c7v4, c7v5, c7v6
    c7v2 = 0.05
    c7v4 = 0
    c7v5 = v6
    c7v6 = 0.01
    c7v3 = math.max
    c7v1 = math.min
    do return c7v1(c7v2, c7v3(c7v4, c7v5(c7v0, c7v6))) end
  end
  v8 = function(c8v0)
    local c8v1, c8v2, c8v3, c8v4
    c8v2 = 0
    c8v3 = v6
    c8v4 = 15000
    c8v1 = math.max
    do return c8v1(c8v2, c8v3(c8v0, c8v4)) end
  end
  v9 = function(c9v0, c9v1, c9v2, c9v3, c9v4)
    local c9v5, c9v6, c9v7, c9v8, c9v9, c9v10, c9v11, c9v12, c9v13, c9v14, c9v15, c9v16, c9v17, c9v18
    c9v5 = IsNull
    c9v5 = c9v5(c9v0)
    if c9v5 then
      c9v5 = v4
      c9v6 = "mallet.c9v57.skip-source"
      c9v10 = false
      c9v11 = false
      c9v12 = false
      c9v13 = -1
      do return c9v5(c9v6, c9v4, c9v2, c9v1, c9v10, c9v11, c9v12, c9v13) end
    end
    c9v5 = 0
    if c9v1 <= c9v5 then
      c9v5 = v4
      c9v6 = "mallet.c9v57.skip-nonpositive"
      c9v10 = false
      c9v11 = false
      c9v12 = false
      c9v13 = -1
      do return c9v5(c9v6, c9v4, c9v2, c9v1, c9v10, c9v11, c9v12, c9v13) end
    end
    c9v5 = v3
    c9v5, c9v6, c9v7, c9v8 = c9v5(c9v2)
    if c9v6 then
      c9v9 = v4
      c9v10 = "mallet.c9v57.skip-killed-target"
      do return c9v9(c9v10, c9v4, c9v2, c9v1, c9v5, c9v6, c9v7, c9v8) end
    end
    if c9v7 then
      c9v9 = 0
      if c9v8 <= c9v9 then
        c9v9 = v4
        c9v10 = "mallet.c9v57.skip-zero-health-target"
        do return c9v9(c9v10, c9v4, c9v2, c9v1, c9v5, c9v6, c9v7, c9v8) end
      end
    end
    c9v9 = c9v0:GetAvatarOwner()
    c9v10 = IsNull
    c9v10 = c9v10(c9v9)
    if c9v10 then
      c9v10 = v4
      c9v11 = "mallet.c9v57.skip-caster"
      do return c9v10(c9v11, c9v4, c9v2, c9v1, c9v5, c9v6, c9v7, c9v8) end
    end
    c9v10 = c9v9:DamageControl()
    c9v11 = IsNull
    c9v11 = c9v11(c9v10)
    if c9v11 then
      c9v11 = v4
      c9v12 = "mallet.c9v57.skip-damage-control"
      do return c9v11(c9v12, c9v4, c9v2, c9v1, c9v5, c9v6, c9v7, c9v8) end
    end
    c9v11 = v8
    c9v11 = c9v11(c9v9)
    c9v12 = c9v10:GetOverguardAmount()
    if c9v11 <= c9v12 then
      c9v13 = v4
      c9v14 = "mallet.c9v57.skip-cap"
      do return c9v13(c9v14, c9v4, c9v2, c9v1, c9v5, c9v6, c9v7, c9v8) end
    end
    c9v14 = v7
    c9v14 = c9v14(c9v9)
    c9v13 = c9v1 * c9v14
    c9v16 = c9v12 + c9v13
    c9v14 = math.min
    c9v14 = c9v14(c9v11, c9v16)
    if c9v12 < c9v14 then
      c9v10:SetOverguardAmount(c9v14)
      c9v17 = c9v9:GetPlayer()
      c9v18 = c9v14 - c9v12
      c9v9:NotifyOverguardGain(c9v17, c9v18)
      c9v15 = v0
      c9v15 = c9v15.NotifyGaveOverguard
      c9v15(c9v9, c9v9)
      c9v15 = v4
      c9v16 = "mallet.c9v57.grant"
      do return c9v15(c9v16, c9v4, c9v2, c9v1, c9v5, c9v6, c9v7, c9v8) end
    end
    c9v15 = v4
    c9v16 = "mallet.c9v57.skip-zero-grant"
    do return c9v15(c9v16, c9v4, c9v2, c9v1, c9v5, c9v6, c9v7, c9v8) end
  end
  v10 = function(c10v0, c10v1)
    local c10v2, c10v3, c10v4, c10v5, c10v6, c10v7, c10v8
    c10v2 = 15000
    c10v3 = 1
    c10v4 = c10v1.Modded
    c10v7 = true
    c10v8 = c10v4
    if c10v8 == c10v7 then
      c10v4 = v8
      c10v5 = c10v1.Avatar
      c10v2 = c10v4(c10v5)
      c10v4 = v7
      c10v5 = c10v1.Avatar
      c10v4 = c10v4(c10v5)
      c10v3 = c10v4 * 100
    end
    c10v6 = { Label = "Overguard Cap", Value = nil }
    c10v6.Value = c10v2
    c10v4 = table.insert
    c10v4(c10v0, c10v6)
    c10v6 = { Label = "Overguard From Damage", Value = nil, ValueUnit = "/Lotus/Language/Game/UNIT_PERCENT" }
    c10v6.Value = c10v3
    c10v4 = table.insert
    c10v4(c10v0, c10v6)
    do return c10v0 end
  end
  -- Stock BoxLoop creates SecondaryScriptArgs for SetThreatLevel here.
  -- Intercept its authoritative argument before the engine invokes that script.
  -- The runtime reports the NAMECALL that names PushFloatArg (44.0.2 p16 i596),
  -- not the following CALL (i597); see RESEARCH/MALLET_THREAT_CALLSITE_FIX_2026-09-29.
  -- forcedThreatLevel == nil means stock: the game's own dynamic level is kept.
  v11 = function(prototype, instruction, stockValue)
    if prototype == 16 and instruction == 596 then
      local level = forcedThreatLevel
      if level ~= nil then
        return level
      end
    end
    return stockValue
  end
  -- ADDON_SETTINGS_V1 (package "Octavia", value "mallet.threat_level").
  -- context.settings exists only when this file is a package member whose
  -- package.json declares the value:
  --   * no context / no context.settings (loose file, older DLL): compiled 5,
  --     exactly the behaviour of the loose addon;
  --   * context.settings without an applicable entry: stock (dynamic level);
  --   * enabled entry, declared stock 5, whole number 0..5: that level.
  -- Every activate call recomputes the level (F9, Scripts, settings commit).
  v12 = function(context)
    local level = 5
    if type(context) == "table" and type(context.settings) == "table" then
      level = nil
      local entry = context.settings["mallet.threat_level"]
      if type(entry) == "table" and entry.enabled == true and entry.stock == 5 then
        local value = entry.value
        if type(value) == "number" and value == value and value >= 0 and value <= 5 and math.floor(value) == value then
          level = value
        end
      end
    end
    forcedThreatLevel = level
    do return end
  end
  v13 = function()
    do return end
  end
  v14 = { activate = nil, cleanup = nil, hooks = nil }
  v14.activate = v12
  v14.cleanup = v13
  v15 = { matchesAbility = nil, afterAbilityCard = nil, afterDamage = nil, transformFloatArgument = nil }
  v15.matchesAbility = v5
  v15.afterAbilityCard = v10
  v15.afterDamage = v9
  v15.transformFloatArgument = v11
  v14.hooks = v15
  do return v14 end
