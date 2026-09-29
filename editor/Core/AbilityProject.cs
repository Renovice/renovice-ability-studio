using System.Globalization;
using System.Text.Json;
using System.Text.Json.Nodes;
using System.Text.RegularExpressions;

namespace Renovice.AbilityEditor.Core;

public enum EditorMode
{
    Addon,
    Replacement,
}

public sealed record StatDefinition(
    string Id,
    string Label,
    string Kind,
    double Base,
    double? Minimum,
    double? Maximum,
    string ModifierFamily,
    string? ModifierBinding,
    bool ShowOnCard,
    string? Unit,
    int Order);

public sealed class AbilityProject
{
    private static readonly JsonSerializerOptions WriteOptions = new() { WriteIndented = true };
    private readonly JsonObject root;

    private AbilityProject(JsonObject root, string? filePath)
    {
        this.root = root;
        FilePath = filePath;
    }

    public string? FilePath { get; private set; }
    public string ProjectId { get => String("id"); set => root["id"] = value; }
    public string Status { get => String("status"); set => root["status"] = value; }
    public string AuthoringMode { get => String("authoring_mode"); set => root["authoring_mode"] = value; }
    public string ModeSelection { get => String("mode_selection"); set => root["mode_selection"] = value; }
    public string ModeReason { get => String("mode_reason"); set => root["mode_reason"] = value; }
    public EditorMode Mode => AuthoringMode is "NATIVE_REPLACEMENT" or "QUICK_NATIVE_PATCH" or "MANAGED_MISSION_EXACT_REPLACEMENT"
        ? EditorMode.Replacement
        : EditorMode.Addon;
    public string Warframe { get => TargetString("warframe"); set => Target()["warframe"] = value; }
    public string Ability { get => TargetString("ability"); set => Target()["ability"] = value; }
    public string AbilityIdentifier { get => TargetString("ability_identifier"); set => Target()["ability_identifier"] = value; }
    public string AbilityLocalizeTag { get => TargetString("ability_localize_tag"); set => Target()["ability_localize_tag"] = value; }
    public string ModulePath { get => TargetString("module_path"); set => Target()["module_path"] = value; }
    public string ModuleBodyKey { get => TargetString("module_body_key"); set => Target()["module_body_key"] = value; }
    public string InstalledBuild { get => TargetString("installed_build"); set => Target()["installed_build"] = value; }
    public string EffectSummary { get => EffectString("summary"); set => Effect()["summary"] = value; }
    public string Hook { get => EffectString("hook"); set { Effect()["hook"] = value; EnsureObject("addon_generation")["hook_binding"] = value; } }
    public string DescriptionText
    {
        get => EnsureObject("description")["text"]?.GetValue<string>() ?? string.Empty;
        set
        {
            var description = EnsureObject("description");
            description["enabled"] = !string.IsNullOrWhiteSpace(value);
            description["text"] = string.IsNullOrWhiteSpace(value) ? null : value;
        }
    }

    public static AbilityProject Load(string path)
    {
        var parsed = JsonNode.Parse(File.ReadAllText(path)) as JsonObject
            ?? throw new InvalidDataException("Ability project root must be a JSON object");
        return new AbilityProject(parsed, Path.GetFullPath(path));
    }

    public static AbilityProject CreateFromTemplate(string templatePath, EditorMode mode)
    {
        var project = Load(templatePath);
        project.FilePath = null;
        project.ProjectId = mode == EditorMode.Addon ? "new.addon.project" : "new.replacement.project";
        project.Status = "DRAFT";
        project.SetMode(mode);
        if (mode == EditorMode.Replacement)
        {
            project.ModeSelection = "MANUAL";
            project.ModeReason = "Edit the exact body-keyed native module source and pass replacement verification before staging.";
        }
        return project;
    }

    public void ClearAbilityLocalizeTag() => Target()["ability_localize_tag"] = null;

    public IReadOnlyList<StatDefinition> ReadStats()
    {
        var result = new List<StatDefinition>();
        if (root["stats"] is not JsonArray stats)
        {
            return result;
        }
        foreach (var node in stats.OfType<JsonObject>())
        {
            var modifier = node["modifier"] as JsonObject;
            var card = node["card"] as JsonObject;
            result.Add(new StatDefinition(
                GetString(node, "id"),
                GetString(node, "label"),
                GetString(node, "kind"),
                GetDouble(node, "base"),
                GetNullableDouble(node, "minimum"),
                GetNullableDouble(node, "maximum"),
                modifier is null ? "NONE" : GetString(modifier, "family"),
                modifier?["binding"]?.GetValue<string>(),
                card?["enabled"]?.GetValue<bool>() ?? false,
                card?["unit"]?.GetValue<string>(),
                card?["order"]?.GetValue<int>() ?? 0));
        }
        return result;
    }

    public void ReplaceStats(IEnumerable<StatDefinition> definitions)
    {
        var oldStats = root["stats"] as JsonArray;
        var oldById = oldStats?.OfType<JsonObject>()
            .Where(item => item["id"] is not null)
            .ToDictionary(item => GetString(item, "id"), item => item, StringComparer.Ordinal)
            ?? new Dictionary<string, JsonObject>(StringComparer.Ordinal);
        var replacement = new JsonArray();
        foreach (var definition in definitions)
        {
            JsonObject item;
            if (oldById.TryGetValue(definition.Id, out var existing))
            {
                item = (JsonObject)existing.DeepClone();
            }
            else
            {
                item = NewStat(definition);
            }
            item["id"] = definition.Id;
            item["label"] = definition.Label;
            item["kind"] = definition.Kind;
            item["base"] = definition.Base;
            item["minimum"] = definition.Minimum;
            item["maximum"] = definition.Maximum;
            var modifier = item["modifier"] as JsonObject ?? new JsonObject();
            modifier["family"] = definition.ModifierFamily;
            modifier["binding"] = definition.ModifierFamily == "NONE" ? null : definition.ModifierBinding;
            if (!modifier.ContainsKey("evidence_id")) modifier["evidence_id"] = null;
            item["modifier"] = modifier;
            var card = item["card"] as JsonObject ?? new JsonObject();
            card["enabled"] = definition.ShowOnCard;
            card["ability"] = AbilityIdentifier;
            card["unit"] = definition.Unit;
            card["order"] = definition.Order;
            if (!card.ContainsKey("icon")) card["icon"] = null;
            if (!card.ContainsKey("base_expression")) card["base_expression"] = null;
            if (!card.ContainsKey("modded_expression")) card["modded_expression"] = null;
            item["card"] = card;
            replacement.Add(item);
        }
        root["stats"] = replacement;
    }

    public void SetMode(EditorMode mode)
    {
        var deployment = EnsureObject("deployment");
        var effect = Effect();
        if (AuthoringMode == "MANAGED_MISSION_METADATA_PATCH" && mode == EditorMode.Addon)
        {
            effect["owner"] = "NATIVE_MODULE";
            effect["hook"] = null;
            deployment["requires_addon"] = false;
            deployment["requires_card_extension"] = false;
            deployment["requires_native_module"] = false;
            return;
        }
        if (mode == EditorMode.Addon)
        {
            root.Remove("replacement_generation");
            if (AuthoringMode is not ("MANAGED_ADDON" or "MANAGED_ADDON_CARD_EXTENSION" or "HYBRID_ADDON_CARD" or "MANAGED_LUA_CALL_ADDON" or "MANAGED_MISSION_ADDON"))
            {
                AuthoringMode = "MANAGED_ADDON_CARD_EXTENSION";
            }
            effect["owner"] = "ADDON";
            deployment["requires_addon"] = true;
            deployment["requires_card_extension"] = AuthoringMode == "MANAGED_ADDON_CARD_EXTENSION";
            deployment["requires_native_module"] = AuthoringMode == "HYBRID_ADDON_CARD";
        }
        else
        {
            var inheritedAddonMetadata = root["addon_generation"] is not null
                || !string.IsNullOrWhiteSpace(EffectString("hook"));
            var managedExactReplacement = AuthoringMode == "MANAGED_MISSION_EXACT_REPLACEMENT";
            if (!managedExactReplacement) AuthoringMode = "NATIVE_REPLACEMENT";
            effect["owner"] = "NATIVE_MODULE";
            effect["hook"] = null;
            if (!managedExactReplacement)
            {
                effect["hook_evidence_id"] = null;
                effect["stacking"] = null;
            }
            root.Remove("addon_generation");
            if (inheritedAddonMetadata && !managedExactReplacement)
            {
                effect["authority"] = "UNKNOWN";
                effect["lifetime"] = "Owned by the exact body-keyed native module loaded from the replacement artifact.";
                effect["cleanup"] = "Rollback restores the previously captured native module artifact.";
            }
            deployment["requires_addon"] = false;
            deployment["requires_card_extension"] = false;
            deployment["requires_native_module"] = true;
        }
    }

    public void ConfigureSurvivalTimerLuaCallAddon(
        double rewardIntervalSeconds,
        double lifeSupportPerPickupSeconds,
        double rewardProgressPerPickupSeconds)
    {
        if (!double.IsFinite(rewardIntervalSeconds) || rewardIntervalSeconds < 1)
            throw new InvalidDataException("Reward rotation interval must be finite and at least one second.");
        if (!double.IsFinite(lifeSupportPerPickupSeconds) || lifeSupportPerPickupSeconds < 0)
            throw new InvalidDataException("Life-support refill per pickup must be finite and nonnegative.");
        if (!double.IsFinite(rewardProgressPerPickupSeconds) || rewardProgressPerPickupSeconds < 0)
            throw new InvalidDataException("Reward-clock progress per pickup must be finite and nonnegative.");

        AuthoringMode = "MANAGED_LUA_CALL_ADDON";
        var effect = Effect();
        effect["owner"] = "ADDON";
        effect["hook"] = "renovice.target.lua_call";
        effect["hook_evidence_id"] = "WF-SURVIVAL-PROTO64-CAPTURES-2026-09-09";
        effect["authority"] = "OWNER";
        effect["lifetime"] = "Exact body-keyed target-module generation; reapplied on the next natural module load or F9 refresh.";
        effect["cleanup"] = "Restores the captured stock pickupTimeAdded and reward interval fields when this generation still owns them.";
        effect["stacking"] = "Pickup reward progress consumes only the positive delta of the stock PickupCollection batch.";
        root["addon_generation"] = new JsonObject
        {
            ["template"] = "MISSION_SURVIVAL_TIMERS_LUA_CALL",
            ["hook_binding"] = "renovice.target.lua_call",
            ["prototype"] = 64,
            ["elapsed_reward_upvalue"] = 19,
            ["pickup_config_upvalue"] = 22,
            ["reward_config_upvalue"] = 70,
            ["reward_interval_seconds"] = rewardIntervalSeconds,
            ["life_support_per_pickup_seconds"] = lifeSupportPerPickupSeconds,
            ["reward_progress_per_pickup_seconds"] = rewardProgressPerPickupSeconds,
        };
        var deployment = EnsureObject("deployment");
        deployment["requires_addon"] = true;
        deployment["requires_card_extension"] = false;
        deployment["requires_native_module"] = false;
    }

    public void ConfigureMobileDefenseTimerReplacement(double minimumTotalSeconds, double maximumTotalSeconds)
    {
        ValidateExactLoadnSeconds(minimumTotalSeconds, "Minimum Mobile Defense time");
        ValidateExactLoadnSeconds(maximumTotalSeconds, "Maximum Mobile Defense time");
        if (minimumTotalSeconds > maximumTotalSeconds)
            throw new InvalidDataException("Mobile Defense minimum total time cannot exceed maximum total time.");

        AuthoringMode = "MANAGED_MISSION_EXACT_REPLACEMENT";
        ModeSelection = "AUTOMATIC_RECOMMENDATION";
        ModeReason = "The stock DefenseStage calculation owns the 180-to-240-second total as two exact LOADN operands; Ability Studio patches only those operands.";
        var effect = Effect();
        effect["owner"] = "NATIVE_MODULE";
        effect["hook"] = null;
        effect["hook_evidence_id"] = "WF-MOBILE-DEFENSE-PROTO22-LERP-OPERANDS-2026-09-12";
        effect["authority"] = "OWNER";
        effect["lifetime"] = "Exact body-keyed replacement loaded through the existing replacement pipeline for the mission module generation.";
        effect["cleanup"] = "Rollback removes or restores the exact previous body-keyed replacement artifact.";
        effect["stacking"] = "Two authoritative LOADN operand edits in stock DefenseStage; datamass, terminal, console-health, mission-override, and progression bytecode remain stock.";
        root.Remove("addon_generation");
        root["replacement_generation"] = new JsonObject
        {
            ["template"] = "MISSION_MOBILE_DEFENSE_TIMERS_EXACT_REPLACEMENT",
            ["stock_corpus_file"] = "Lotus_Scripts_MobileDefense.lua_B",
            ["stock_sha256"] = "E9CBBEF4B6BECA2AC61EC741F3F9A22BA45DF06878708C429176843222B47541",
            ["stock_minimum_total_seconds"] = 180,
            ["stock_maximum_total_seconds"] = 240,
            ["minimum_prototype"] = 22,
            ["minimum_instruction"] = 120,
            ["minimum_loadn_occurrence"] = 9,
            ["maximum_prototype"] = 22,
            ["maximum_instruction"] = 121,
            ["maximum_loadn_occurrence"] = 10,
            ["minimum_total_seconds"] = minimumTotalSeconds,
            ["maximum_total_seconds"] = maximumTotalSeconds,
        };
        var deployment = EnsureObject("deployment");
        deployment["requires_addon"] = false;
        deployment["requires_card_extension"] = false;
        deployment["requires_native_module"] = true;
    }

    public void ConfigureInterceptionTimerAddon(double scoringSpeedMultiplier)
    {
        if (!double.IsFinite(scoringSpeedMultiplier) || scoringSpeedMultiplier < 0.01 || scoringSpeedMultiplier > 100)
            throw new InvalidDataException("Interception scoring multiplier must be finite and between 0.01 and 100.");

        ConfigureMissionAddonEffect(
            "renovice.target.lua_call",
            "WF-TERRITORY-PROTO35-SCORE-RATE-2026-09-09",
            "Changes the stock scoreRatePerSecond scalar once when the exact Territory mission closure starts; native mission and quest multipliers run afterward.",
            "Cleanup restores the stock global only while the current generation still owns its expected value.",
            "One prototype-entry scalar edit; no score polling or repeated setters.");
        root["addon_generation"] = new JsonObject
        {
            ["template"] = "MISSION_INTERCEPTION_SCORING_TARGET",
            ["hook_binding"] = "renovice.target.lua_call",
            ["prototype"] = 35,
            ["stock_score_rate"] = 1,
            ["scoring_speed_multiplier"] = scoringSpeedMultiplier,
        };
    }

    public void ConfigureExcavationTimerReplacement(
        double standardDigSeconds,
        double oldWorldSalvageDigSeconds,
        double eliteAlertDigSeconds)
    {
        ValidateExcavationSeconds(standardDigSeconds, "Standard Excavation duration");
        ValidateExcavationSeconds(oldWorldSalvageDigSeconds, "Old World Salvage duration");
        ValidateExcavationSeconds(eliteAlertDigSeconds, "Elite Alert duration");

        AuthoringMode = "MANAGED_MISSION_EXACT_REPLACEMENT";
        ModeSelection = "AUTOMATIC_RECOMMENDATION";
        ModeReason = "The stock Excavation module owns all three duration variants as exact LOADN assignments; Ability Studio patches only those operands.";
        var effect = Effect();
        effect["owner"] = "NATIVE_MODULE";
        effect["hook"] = null;
        effect["hook_evidence_id"] = "WF-EXCAVATION-STOCK-DURATION-ASSIGNMENTS-2026-09-11";
        effect["authority"] = "OWNER";
        effect["lifetime"] = "Exact body-keyed replacement loaded through the existing replacement pipeline for the mission module generation.";
        effect["cleanup"] = "Rollback removes or restores the exact previous body-keyed replacement artifact.";
        effect["stacking"] = "Three authoritative LOADN operand edits; no Lua-call hook, polling, repeated setter, or coroutine callback.";
        root.Remove("addon_generation");
        root["replacement_generation"] = new JsonObject
        {
            ["template"] = "MISSION_EXCAVATION_TIMERS_EXACT_REPLACEMENT",
            ["stock_corpus_file"] = "Lotus_Scripts_Modes_ExcavationMission.lua_B",
            ["stock_sha256"] = "A2326FD92DDC2075E03CAB08300744BFA15ED8BDEC7C13FA98DD5071EEEC20C2",
            ["stock_standard_seconds"] = 100,
            ["stock_old_world_salvage_seconds"] = 60,
            ["stock_elite_alert_seconds"] = 140,
            ["standard_prototype"] = 49,
            ["standard_instruction"] = 76,
            ["standard_loadn_occurrence"] = 33,
            ["old_world_salvage_prototype"] = 32,
            ["old_world_salvage_instruction"] = 81,
            ["old_world_salvage_loadn_occurrence"] = 5,
            ["elite_alert_prototype"] = 32,
            ["elite_alert_instruction"] = 102,
            ["elite_alert_loadn_occurrence"] = 6,
            ["standard_dig_seconds"] = standardDigSeconds,
            ["old_world_salvage_dig_seconds"] = oldWorldSalvageDigSeconds,
            ["elite_alert_dig_seconds"] = eliteAlertDigSeconds,
        };
        var deployment = EnsureObject("deployment");
        deployment["requires_addon"] = false;
        deployment["requires_card_extension"] = false;
        deployment["requires_native_module"] = true;
    }

    public void ConfigureControlAreaPlainsTimerReplacement(double durationSeconds)
    {
        ConfigureControlAreaTimerReplacement(
            durationSeconds,
            "Plains Control Area duration",
            "MISSION_CONTROL_AREA_PLAINS_TIMER_EXACT_REPLACEMENT",
            "Lotus_Scripts_Eidolon_Encounters_DynamicDefend.lua_B",
            "ECC204753DB9BDED69F6A764C919DF5DD2240B5EE907E35C046E99C624D23386",
            17,
            44,
            3,
            new JsonObject
            {
                ["timer_argument_prototype"] = 8,
                ["timer_argument_instruction"] = 100,
                ["timer_argument_move_occurrence"] = 0,
            },
            "WF-CONTROL-AREA-PLAINS-ROOT-DURATION-LOADN-2026-09-11");
    }

    public void ConfigureControlAreaDeimosTimerReplacement(double durationSeconds)
    {
        ConfigureControlAreaTimerReplacement(
            durationSeconds,
            "Deimos Control Area duration",
            "MISSION_CONTROL_AREA_DEIMOS_TIMER_EXACT_REPLACEMENT",
            "Lotus_Scripts_InfestedMicroplanet_Encounters_DynamicAreaDefense.lua_B",
            "ECBED12E85416CE5FBB25995D9252F4AD29042F1AE7DAA3C2E4C8A2F25AEDF49",
            15,
            56,
            1,
            new JsonObject
            {
                ["persistent_result_prototype"] = 7,
                ["persistent_result_instruction"] = 63,
                ["persistent_result_getupval_occurrence"] = 15,
            },
            "WF-CONTROL-AREA-DEIMOS-ROOT-DURATION-LOADN-2026-09-11");
    }

    private void ConfigureControlAreaTimerReplacement(
        double durationSeconds,
        string label,
        string template,
        string stockCorpusFile,
        string stockSha256,
        int durationPrototype,
        int durationInstruction,
        int durationLoadnOccurrence,
        JsonObject consumerSites,
        string evidenceId)
    {
        ValidateExactLoadnSeconds(durationSeconds, label);

        AuthoringMode = "MANAGED_MISSION_EXACT_REPLACEMENT";
        ModeSelection = "AUTOMATIC_RECOMMENDATION";
        ModeReason = "The stock Control Area module owns linked pacing at its root and consumes a possibly persisted mission duration later; Ability Studio patches both verified points in the same native module.";
        var effect = Effect();
        effect["owner"] = "NATIVE_MODULE";
        effect["hook"] = null;
        effect["hook_evidence_id"] = evidenceId;
        effect["authority"] = "OWNER";
        effect["lifetime"] = "Exact body-keyed replacement loaded through the existing replacement pipeline for the mission module generation.";
        effect["cleanup"] = "Rollback removes or restores the exact previous body-keyed replacement artifact.";
        effect["stacking"] = "Authoritative duration and consumer edits in the stock module; no Lua-call hook, polling, repeated setter, or parallel pacing system.";
        root.Remove("addon_generation");
        var replacementGeneration = new JsonObject
        {
            ["template"] = template,
            ["stock_corpus_file"] = stockCorpusFile,
            ["stock_sha256"] = stockSha256,
            ["stock_duration_seconds"] = 90,
            ["duration_prototype"] = durationPrototype,
            ["duration_instruction"] = durationInstruction,
            ["duration_loadn_occurrence"] = durationLoadnOccurrence,
            ["duration_seconds"] = durationSeconds,
        };
        foreach (var site in consumerSites)
            replacementGeneration[site.Key] = site.Value?.DeepClone();
        root["replacement_generation"] = replacementGeneration;
        var deployment = EnsureObject("deployment");
        deployment["requires_addon"] = false;
        deployment["requires_card_extension"] = false;
        deployment["requires_native_module"] = true;
    }

    public void ConfigureControlAreaNokkoTimerReplacement(double durationSeconds)
    {
        ValidateExactLoadnSeconds(durationSeconds, "Venus/Nokko Control Area duration");
        if ((int)durationSeconds % 6 != 0)
            throw new InvalidDataException("Venus/Nokko Control Area duration must be divisible by 6 so the stock halfway and two-thirds thresholds remain exact.");

        AuthoringMode = "MANAGED_MISSION_EXACT_REPLACEMENT";
        ModeSelection = "AUTOMATIC_RECOMMENDATION";
        ModeReason = "The mission resource remains stock; the exact native module changes its SetObjTimer argument and the two linked threshold results at their verified consumers.";
        var effect = Effect();
        effect["owner"] = "NATIVE_MODULE";
        effect["hook"] = null;
        effect["hook_evidence_id"] = "WF-CONTROL-AREA-NOKKO-TIMER-CONSUMER-AND-THRESHOLDS-2026-09-11";
        effect["authority"] = "OWNER";
        effect["lifetime"] = "Exact body-keyed replacement loaded through the existing replacement pipeline for the mission module generation.";
        effect["cleanup"] = "Rollback removes or restores the exact previous body-keyed replacement artifact.";
        effect["stacking"] = "One SetObjTimer argument and two linked threshold results in stock code; no addon, polling, repeated setter, or parallel timer.";
        root.Remove("addon_generation");
        root["replacement_generation"] = new JsonObject
        {
            ["template"] = "MISSION_CONTROL_AREA_NOKKO_TIMER_EXACT_REPLACEMENT",
            ["stock_corpus_file"] = "Lotus_Scripts_Venus_NokkoColony_Encounters_AreaDefense.lua_B",
            ["stock_sha256"] = "E5048C7A1F9AE04DA38BA5AAE18D749A946172A61E67F6D56853BC719246C3F5",
            ["timer_argument_prototype"] = 5,
            ["timer_argument_instruction"] = 118,
            ["timer_argument_move_occurrence"] = 0,
            ["halfway_result_prototype"] = 6,
            ["halfway_result_instruction"] = 107,
            ["halfway_sub_occurrence"] = 0,
            ["two_thirds_result_prototype"] = 6,
            ["two_thirds_result_instruction"] = 112,
            ["two_thirds_sub_occurrence"] = 1,
            ["duration_seconds"] = durationSeconds,
        };
        var deployment = EnsureObject("deployment");
        deployment["requires_addon"] = false;
        deployment["requires_card_extension"] = false;
        deployment["requires_native_module"] = true;
    }

    private void ConfigureMissionAddonEffect(
        string hook,
        string evidenceId,
        string lifetime,
        string cleanup,
        string stacking)
    {
        AuthoringMode = "MANAGED_MISSION_ADDON";
        var effect = Effect();
        effect["owner"] = "ADDON";
        effect["hook"] = hook;
        effect["hook_evidence_id"] = evidenceId;
        effect["authority"] = "OWNER";
        effect["lifetime"] = lifetime;
        effect["cleanup"] = cleanup;
        effect["stacking"] = stacking;
        var deployment = EnsureObject("deployment");
        deployment["requires_addon"] = true;
        deployment["requires_card_extension"] = false;
        deployment["requires_native_module"] = false;
    }

    private static void ValidateMissionSeconds(double value, string label)
    {
        if (!double.IsFinite(value) || value < 1 || value > 86400)
            throw new InvalidDataException($"{label} must be finite and between 1 and 86400 seconds.");
    }

    private static void ValidateExcavationSeconds(double value, string label)
    {
        ValidateExactLoadnSeconds(value, label);
    }

    private static void ValidateExactLoadnSeconds(double value, string label)
    {
        ValidateMissionSeconds(value, label);
        if (value != Math.Truncate(value) || value > 32767)
            throw new InvalidDataException($"{label} must be a whole number between 1 and 32767 seconds for the exact LOADN replacement.");
    }

    public void ConfigureMissionBuildProfile(string id, IReadOnlyDictionary<string, double> values, string editorRoot)
    {
        using var profile = MissionBuildProfile.Read(editorRoot);
        var binding = profile.RootElement.GetProperty("missions").GetProperty(id);
        ModuleBodyKey = binding.GetProperty("body_key").GetString()!;
        ModulePath = binding.GetProperty("module_path").GetString()!;
        InstalledBuild = MissionBuildProfile.Build;
        var parameters = new JsonObject();
        foreach (var (key, value) in values) parameters[key] = value;
        root["mission_profile"] = new JsonObject { ["build"] = MissionBuildProfile.Build, ["id"] = id, ["values"] = parameters };
        if (binding.TryGetProperty("metadata", out _) || id is "void_cascade" or "descendia_excavation" or "archimedea")
        {
            AuthoringMode = binding.TryGetProperty("metadata", out _) ? "MANAGED_MISSION_METADATA_PATCH" : "MANAGED_MISSION_EXACT_REPLACEMENT";
            root.Remove("addon_generation");
            root["replacement_generation"] = new JsonObject { ["template"] = "PROFILE_MISSION_DURATION" };
            Effect()["owner"] = "NATIVE_MODULE";
            Effect()["hook"] = null;
            Effect()["authority"] = "OWNER";
        }
    }

    public IReadOnlyList<string> ValidateForSave()
    {
        var errors = new List<string>();
        if (!Regex.IsMatch(ProjectId, "^[a-z0-9][a-z0-9._-]*$")) errors.Add("Project ID must use lowercase letters, numbers, dots, underscores, or hyphens.");
        if (string.IsNullOrWhiteSpace(Warframe)) errors.Add("Warframe is required.");
        if (string.IsNullOrWhiteSpace(Ability)) errors.Add("Ability is required.");
        if (!Regex.IsMatch(ModuleBodyKey, "^[0-9a-fA-F]{16}$")) errors.Add("Module body key must contain exactly 16 hexadecimal characters.");
        if (string.IsNullOrWhiteSpace(ModulePath)) errors.Add("Module path is required.");
        var stats = ReadStats();
        if (stats.Select(stat => stat.Id).Distinct(StringComparer.Ordinal).Count() != stats.Count) errors.Add("Stat IDs must be unique.");
        foreach (var stat in stats)
        {
            if (!Regex.IsMatch(stat.Id, "^[a-z0-9][a-z0-9._-]*$")) errors.Add($"Invalid stat ID: {stat.Id}");
            if (stat.Minimum is not null && stat.Base < stat.Minimum) errors.Add($"{stat.Label}: base is below minimum.");
            if (stat.Maximum is not null && stat.Base > stat.Maximum) errors.Add($"{stat.Label}: base is above maximum.");
        }
        return errors;
    }

    public void Save(string path)
    {
        var errors = ValidateForSave();
        if (errors.Count > 0) throw new InvalidDataException(string.Join(Environment.NewLine, errors));
        var absolute = Path.GetFullPath(path);
        Directory.CreateDirectory(Path.GetDirectoryName(absolute)!);
        var temporary = absolute + ".tmp";
        File.WriteAllText(temporary, root.ToJsonString(WriteOptions) + Environment.NewLine);
        File.Move(temporary, absolute, true);
        FilePath = absolute;
    }

    public string ToJson() => root.ToJsonString(WriteOptions) + Environment.NewLine;

    private JsonObject Target() => EnsureObject("target");
    private JsonObject Effect() => EnsureObject("effect");
    private string String(string key) => GetString(root, key);
    private string TargetString(string key) => GetString(Target(), key);
    private string EffectString(string key) => GetString(Effect(), key);

    private JsonObject EnsureObject(string key)
    {
        if (root[key] is JsonObject value) return value;
        value = new JsonObject();
        root[key] = value;
        return value;
    }

    private static string GetString(JsonObject value, string key) => value[key]?.GetValue<string>() ?? string.Empty;
    private static double GetDouble(JsonObject value, string key) => value[key]?.GetValue<double>() ?? 0;
    private static double? GetNullableDouble(JsonObject value, string key) => value[key] is null ? null : value[key]!.GetValue<double>();

    private static JsonObject NewStat(StatDefinition definition) => new()
    {
        ["id"] = definition.Id,
        ["label"] = definition.Label,
        ["kind"] = definition.Kind,
        ["base"] = definition.Base,
        ["minimum"] = definition.Minimum,
        ["maximum"] = definition.Maximum,
        ["modifier"] = new JsonObject
        {
            ["family"] = definition.ModifierFamily,
            ["binding"] = definition.ModifierBinding,
            ["evidence_id"] = null,
        },
        ["gameplay"] = new JsonObject
        {
            ["consumer"] = "USER_AUTHORED",
            ["expression"] = "$stat." + definition.Id,
        },
        ["card"] = new JsonObject
        {
            ["enabled"] = definition.ShowOnCard,
            ["ability"] = string.Empty,
            ["unit"] = definition.Unit,
            ["icon"] = null,
            ["order"] = definition.Order,
            ["base_expression"] = null,
            ["modded_expression"] = null,
        },
    };
}
