-- Appended by run_gates.py after:
--   the require/IsNull prelude, `local addon = (function() <source> end)()`,
--   and `local BEATS = { {strength, og_before, og_next, class, {dmg...}}, ... }`.
-- Engine model: Overguard is an integer; SetOverguardAmount truncates
-- (44.0.2 live, 96/96 + 32/32 fully traced clean beats).
local hooks = addon.hooks
assert(type(hooks.afterDamage) == "function", "afterDamage missing")

local function world(strength, og)
	local w = { og = og, writes = 0, gains = 0, gained = 0, gave = 0 }
	local suit = { GetType = function() return "suit" end }
	local inventory = {
		GetActivePowerSuit = function() return suit end,
		GetUpgradeModifiedValue = function(_, value, operation, suitType, s)
			assert(operation == 10 and suitType == "suit" and s == suit, "strength channel")
			return value * strength
		end,
	}
	local control = {
		GetOverguardAmount = function() return w.og end,
		SetOverguardAmount = function(_, value)
			w.writes += 1
			w.og = value >= 0 and math.floor(value) or math.ceil(value)
		end,
	}
	local caster = {
		DamageControl = function() return control end,
		InventoryControl = function() return inventory end,
		GetPlayer = function() return "player" end,
		NotifyOverguardGain = function(_, player, amount)
			assert(player == "player")
			w.gains += 1
			w.gained += amount
		end,
	}
	w.source = { GetAvatarOwner = function() return caster end }
	w.caster = caster
	return w
end

local function target(killed, health)
	return { IsKilled = function() return killed end, GetHealth = function() return health end }
end

local function hit(w, damage, killed)
	return (hooks.afterDamage(w.source, damage, target(killed or false, killed and -1 or 1000), nil, 1))
end

local failures = 0
local function check(ok, message)
	if not ok then
		failures += 1
		print("FAIL " .. message)
	end
end

-- 1. Formula: r = min(0.05, 0.01 * strength), cap = 15000 * strength.
do
	local w = world(2.38, 0)
	check(hit(w, 4034) == "mallet.c9v57.grant" and w.og == 96, "2.38 x 4034 -> 96 (got " .. w.og .. ")")
	w = world(6, 0)
	hit(w, 1000)
	check(w.og == 50, "fraction clamps at 5% (got " .. w.og .. ")")
	w = world(1, 14990)
	hit(w, 100000)
	check(w.og == 15000, "cap 15000 at strength 1 (got " .. w.og .. ")")
end

-- 2. Fractional cap (live strength 2.4544012546539307 -> cap 36816.018...).
--    BASELINE documents the defect instead: it "grants" 0.018 at the cap.
if BASELINE then
	local w = world(2.4544012546539307, 36816)
	local label = hit(w, 5000)
	check(label == "mallet.c9v57.grant" and w.writes == 1 and w.gains == 1 and w.og == 36816,
		"baseline defect reproduced: write + notification with zero real gain at the cap")
	w = world(2.38, 1000)
	check(hit(w, 30) == "mallet.c9v57.grant" and w.writes == 1 and w.og == 1000,
		"baseline defect reproduced: sub-point hit writes and notifies")
else
	local w = world(2.4544012546539307, 36816)
	local label = hit(w, 5000)
	check(label == "mallet.c9v57.skip-cap", "at integer cap -> skip-cap (got " .. tostring(label) .. ")")
	check(w.writes == 0 and w.gains == 0, "no write/notification at cap")
	w = world(2.4544012546539307, 36800)
	hit(w, 100000)
	check(w.og == 36816 and w.gained == 16, "clamp to integer cap, notified gain equals real gain")
	-- 3. A hit worth less than one point writes nothing.
	w = world(2.38, 1000)
	label = hit(w, 30)
	check(label == "mallet.c9v57.skip-zero-grant" and w.writes == 0, "sub-point hit -> skip-zero-grant")
end

-- 4. Lethal hit is skipped (unchanged behaviour).
do
	local w = world(2.38, 0)
	check(hit(w, 5000, true) == "mallet.c9v57.skip-killed-target" and w.writes == 0, "killed target skipped")
end

-- 5. Live replay: every clean beat reproduces the observed Overguard; at-cap
--    beats keep the cap and (candidate) never write.
local clean, exact, capBeats, capWrites = 0, 0, 0, 0
for _, beat in BEATS do
	local w = world(beat[1], beat[2])
	for _, damage in beat[5] do
		hit(w, damage)
	end
	if beat[4] == "clean" then
		clean += 1
		if w.og == beat[3] then exact += 1 else print(("MISMATCH og0=%d want=%d got=%d"):format(beat[2], beat[3], w.og)) end
	elseif beat[4] == "at-cap" then
		capBeats += 1
		capWrites += w.writes
		check(w.og == beat[2], "at-cap beat keeps the cap")
	end
end
check(clean > 0 and exact == clean, ("replay %d/%d clean beats exact"):format(exact, clean))
print(("REPLAY clean=%d exact=%d at_cap_beats=%d at_cap_writes=%d"):format(clean, exact, capBeats, capWrites))
if EXPECT_NO_CAP_WRITES then
	check(capWrites == 0, "candidate performs no Overguard write at the cap")
end
if failures == 0 then
	print("PASS overguard contract")
else
	error(failures .. " contract failures")
end
