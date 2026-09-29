namespace Renovice.AbilityEditor.Core;

public sealed record MissionTimerValue(
    string Id,
    string Label,
    double? StockValue,
    double Value,
    double RecommendedValue,
    string Unit,
    string Explanation,
    string? StockDescription = null,
    string Group = "");

public sealed record MissionTimerPreset(
    string Id,
    string DisplayName,
    string ModulePath,
    string CorpusFile,
    string ModuleBodyKey,
    string AbilityIdentifier,
    string Summary,
    string Mechanic,
    IReadOnlyList<MissionTimerValue> Values,
    string Section = "Regular missions",
    string Lane = "")
{
    public static IReadOnlyList<MissionTimerPreset> All { get; } =
    [
        new(
            "survival",
            "Survival",
            "Lotus.Scripts.Modes.SurvivalMission",
            "Lotus_Scripts_Modes_SurvivalMission.lua_B",
            "1e3647332a578b78",
            "SURVIVAL_TIMER_PATCH",
            "Controls reward rotations and life-support pickup behavior.",
            "The reward clock is elapsed mission time. Pickup life support and optional reward-clock progress are separate values.",
            [
                new("reward_interval", "Reward rotation interval", 300, 300, 150, "seconds",
                    "Elapsed mission time required for each A/B/C reward rotation."),
                new("pickup_life_support", "Life-support refill per pickup", 7, 7, 7, "seconds",
                    "Existing stock refill added to the life-support reserve for each enemy pickup."),
                new("pickup_reward_progress", "Reward-clock progress per pickup", 0, 0, 5, "seconds",
                    "Additional elapsed reward time per pickup. This is independent of life-support refill."),
            ]),
        new(
            "mobile_defense",
            "Mobile Defense",
            "Lotus.Scripts.MobileDefense",
            "Lotus_Scripts_MobileDefense.lua_B",
            "89329f85c8575b84",
            "MOBILE_DEFENSE_TIMER_PATCH",
            "Controls the total defense time chosen from mission difficulty.",
            "The game interpolates between the minimum and maximum, then divides that total across the active consoles.",
            [
                new("minimum_total_time", "Minimum total defense time", 180, 180, 90, "seconds",
                    "Total time at the low end of mission difficulty, divided across active consoles."),
                new("maximum_total_time", "Maximum total defense time", 240, 240, 120, "seconds",
                    "Total time at the high end of mission difficulty, divided across active consoles."),
            ]),
        new(
            "interception",
            "Interception",
            "Lotus.Scripts.Modes.TerritoryMission",
            "Lotus_Scripts_Modes_TerritoryMission.lua_B",
            "a51e98a1833bd8c1",
            "INTERCEPTION_SCORING_PATCH",
            "Controls how quickly owned towers generate round score.",
            "Interception has no fixed round timer: ownership changes scoring. A 2× multiplier roughly halves scoring time while the same side controls the same towers.",
            [
                new("scoring_speed_multiplier", "Tower scoring speed", 1, 1, 2, "multiplier",
                    "Multiplies the native score gained per second. Existing mission and quest-specific multipliers still apply afterward."),
            ]),
        new(
            "excavation",
            "Excavation",
            "Lotus.Scripts.Modes.ExcavationMission",
            "Lotus_Scripts_Modes_ExcavationMission.lua_B",
            "303f809a05c1fbaa",
            "EXCAVATION_TIMER_PATCH",
            "Controls how long a powered excavator must dig.",
            "Standard Excavation, Old World Salvage, and Elite Alert variants own separate native durations. Reward score and battery behavior remain unchanged.",
            [
                new("standard_dig_time", "Standard excavator duration", 100, 100, 50, "seconds",
                    "Native dig duration for ordinary Excavation missions."),
                new("old_world_salvage_dig_time", "Old World Salvage duration", 60, 60, 30, "seconds",
                    "Variant override used only by the Old World Salvage location."),
                new("elite_alert_dig_time", "Elite Alert duration", 140, 140, 70, "seconds",
                    "Variant override used by the two Elite Alert periodic mission tags."),
            ]),
        new(
            "control_area_plains",
            "Control Area (Plains)",
            "Lotus.Scripts.Eidolon.Encounters.DynamicDefend",
            "Lotus_Scripts_Eidolon_Encounters_DynamicDefend.lua_B",
            "bf3c901cb4058c47",
            "CONTROL_AREA_PLAINS_TIMER_PATCH",
            "Controls the Plains and inherited Narmer bounty defend-area clock.",
            "The stock module owns a 90-second pacing value but can read a persisted 90-second mission value later. The exact replacement sets the root pacing owner and the SetObjTimer argument to the selected duration.",
            [
                new("control_area_duration", "Control-area duration", 90, 90, 30, "seconds",
                    "Total time shown by the Control Area objective; the stock reinforcement pacing remains proportional to the selected duration."),
            ]),
        new(
            "control_area_deimos",
            "Control Area (Deimos)",
            "Lotus.Scripts.InfestedMicroplanet.Encounters.DynamicAreaDefense",
            "Lotus_Scripts_InfestedMicroplanet_Encounters_DynamicAreaDefense.lua_B",
            "d9541341dfd466a3",
            "CONTROL_AREA_DEIMOS_TIMER_PATCH",
            "Controls the Cambion Drift dynamic area-defense clock.",
            "The stock module owns a 90-second pacing value but can read a persisted 90-second mission value later. The exact replacement sets both before stock derives the halfway threshold.",
            [
                new("control_area_duration", "Control-area duration", 90, 90, 30, "seconds",
                    "Total time shown by the Control Area objective; the stock two-thirds enemy-pacing threshold is recalculated from this value."),
            ]),
        new(
            "control_area_nokko",
            "Control Area (Venus/Nokko)",
            "Lotus.Scripts.Venus.NokkoColony.Encounters.AreaDefense",
            "Lotus_Scripts_Venus_NokkoColony_Encounters_AreaDefense.lua_B",
            "e192d5cc2f37056e",
            "CONTROL_AREA_NOKKO_TIMER_PATCH",
            "Controls the Venus/Nokko area-defense clock while retaining its pause-when-empty behavior.",
            "This variant reads defendTime from mission-resource data that is not exposed as an ordinary addon global. The exact replacement changes the stock SetObjTimer consumer and its linked halfway and two-thirds threshold results.",
            [
                new("control_area_duration", "Control-area duration", null, 90, 30, "seconds",
                    "Total configured defend time. Use a multiple of 6 so the linked one-half and two-thirds thresholds are represented exactly.",
                    "mission-resource value (not fixed in Lua)"),
            ]),
    ];
}

public static partial class MissionTimerPatcher
{
    private const string Marker = "-- RENOVICE_MISSION_TIMER_PATCH";

    public static string Apply(
        MissionTimerPreset preset,
        string moduleBodyKey,
        string source,
        IReadOnlyDictionary<string, double> values)
    {
        if (!string.Equals(moduleBodyKey, preset.ModuleBodyKey, StringComparison.OrdinalIgnoreCase))
            throw new InvalidDataException(
                $"Timer binding {preset.Id} is locked to body key {preset.ModuleBodyKey}; received {moduleBodyKey}.");
        if (source.Contains(Marker, StringComparison.Ordinal))
            throw new InvalidDataException("This source already contains a RENOVICE mission timer patch. Start from exact stock source.");

        var normalized = source.Replace("\r\n", "\n", StringComparison.Ordinal);
        normalized = preset.Id switch
        {
            "survival" => ApplySurvival(normalized, values),
            "mobile_defense" => ApplyMobileDefense(normalized, values),
            "interception" => ApplyInterception(normalized, values),
            "excavation" => ApplyExcavation(normalized, values),
            "control_area_plains" or "control_area_deimos" or "control_area_nokko" => ApplyControlArea(normalized, values),
            _ => throw new InvalidDataException($"Unsupported mission timer preset: {preset.Id}"),
        };
        return Marker + " body_key=" + preset.ModuleBodyKey + " preset=" + preset.Id + "\n" + normalized;
    }

    private static string ApplySurvival(string source, IReadOnlyDictionary<string, double> values)
    {
        _ = source;
        _ = Required(values, "reward_interval", minimum: 1);
        _ = Required(values, "pickup_life_support", minimum: 0);
        _ = Required(values, "pickup_reward_progress", minimum: 0);
        throw new InvalidDataException(
            "Survival full-replacement generation is retired: it can disturb the stock keypad/start lifecycle, "
            + "and reward progress belongs to proto64 elapsed-time capture 19. Generate the exact Survival target addon instead.");
    }

    private static string ApplyMobileDefense(string source, IReadOnlyDictionary<string, double> values)
    {
        _ = source;
        var minimum = Required(values, "minimum_total_time", minimum: 1);
        var maximum = Required(values, "maximum_total_time", minimum: 1);
        if (minimum > maximum)
            throw new InvalidDataException("Mobile Defense minimum total time cannot exceed maximum total time.");
        throw new InvalidDataException(
            "Mobile Defense source-recompile generation is retired. Generate the hash-pinned exact DefenseStage LOADN replacement instead.");
    }

    private static string ApplyInterception(string source, IReadOnlyDictionary<string, double> values)
    {
        _ = source;
        _ = Required(values, "scoring_speed_multiplier", minimum: 0.01, maximum: 100, unit: "multiplier");
        throw new InvalidDataException(
            "Interception full-replacement generation is retired. Generate the exact Territory prototype-35 addon instead.");
    }

    private static string ApplyExcavation(string source, IReadOnlyDictionary<string, double> values)
    {
        _ = source;
        _ = Required(values, "standard_dig_time", minimum: 1);
        _ = Required(values, "old_world_salvage_dig_time", minimum: 1);
        _ = Required(values, "elite_alert_dig_time", minimum: 1);
        throw new InvalidDataException(
            "Excavation source-recompile generation is retired. Generate the hash-pinned exact LOADN replacement instead.");
    }

    private static string ApplyControlArea(string source, IReadOnlyDictionary<string, double> values)
    {
        _ = source;
        _ = Required(values, "control_area_duration", minimum: 1);
        throw new InvalidDataException(
            "Control Area source-recompile generation is retired. Generate the verified exact stock-body replacement for the selected world variant.");
    }

    private static double Required(IReadOnlyDictionary<string, double> values, string id, double minimum,
        double maximum = 86400, string unit = "seconds")
    {
        if (!values.TryGetValue(id, out var value))
            throw new InvalidDataException($"Missing timer value: {id}");
        if (!double.IsFinite(value) || value < minimum || value > maximum)
            throw new InvalidDataException($"Mission value {id} must be finite and between {minimum} and {maximum} {unit}.");
        return value;
    }

}
