using System.Text.Json;

namespace Renovice.AbilityEditor.Core;

public static class MissionBuildProfile
{
    public const string Build = "2026.09.24.13.29";
    public static JsonDocument Read(string editorRoot) => JsonDocument.Parse(
        File.ReadAllText(Path.Combine(editorRoot, "REGISTRIES", "mission_build_u44.json")));

    public static string CorpusRoot(WorkspacePaths workspace)
    {
        using var profile = Read(workspace.EditorRoot);
        return Path.GetFullPath(Path.Combine(workspace.WorkspaceRoot, profile.RootElement.GetProperty("corpus").GetString()!));
    }

    public static IReadOnlyList<MissionTimerPreset> Presets(string editorRoot)
    {
        using var profile = Read(editorRoot);
        var bindings = profile.RootElement.GetProperty("missions");
        var presets = MissionTimerPreset.All.Select(preset => preset with
        {
            ModuleBodyKey = bindings.GetProperty(preset.Id).GetProperty("body_key").GetString()!,
            CorpusFile = bindings.GetProperty(preset.Id).GetProperty("file").GetString()!,
        }).ToList();
        var cascade = bindings.GetProperty("void_cascade");
        presets.Add(new MissionTimerPreset("void_cascade", "Void Cascade (Exolizers)",
            cascade.GetProperty("module_path").GetString()!, cascade.GetProperty("file").GetString()!,
            cascade.GetProperty("body_key").GetString()!, "VOID_CASCADE_EXOLIZER_SPEED",
            "Controls how quickly purified Exolizers finish.",
            "Native duration is 90 seconds: 2× finishes in 45 seconds. Both duration variants and their linked UI use the same stock configuration. Spawn timing and reward quantities are unchanged. Choose a speed that gives a whole-second duration.",
            [new MissionTimerValue("exolizer_speed_multiplier", "Purified Exolizer completion speed", 1, 1, 2,
                "multiplier", "90 seconds divided by this value. 1× = 90 seconds; 2× = 45 seconds; 3× = 30 seconds.")]));
        foreach (var (id, title, summary, mechanic, parameter, label, stock, recommended, unit) in new[] {
            ("netracells", "Netracells", "Power gained from qualifying kills.",
                "Edits the native metadata parameter used by gameplay and the progress display. Also affects the quest variant, which retains its additional ×8 factor. Search, drones and reward quantities are unchanged.",
                "power_per_kill", "Power per qualifying kill", 1d, 2d, "power"),
            ("descendia_shrine", "Descendia · Shrine offerings", "Time until a generated offering is ready to collect.",
                "Edits the native metadata timer. The same timer controls pickup readiness and the countdown. Overall phase deadlines are unchanged.",
                "offering_generation_time", "Offering generation time", 30d, 15d, "seconds"),
            ("descendia_excavation", "Descendia · Excavation", "Powered drilling time for one excavator.",
                "Updates the linked Lua completion threshold, remaining time, battery limit, host migration and partial progress. A completed dig still gives 25 progress. Whole seconds only.",
                "dig_duration", "Excavator completion time", 45d, 15d, "seconds"),
        }) {
            var binding = bindings.GetProperty(id);
            presets.Add(new MissionTimerPreset(id, title, binding.GetProperty("module_path").GetString()!,
                binding.GetProperty("file").GetString()!, binding.GetProperty("body_key").GetString()!,
                id.ToUpperInvariant(), summary, mechanic,
                [new MissionTimerValue(parameter, label, stock, stock, recommended, unit, mechanic)]));
        }
        var arch = bindings.GetProperty("archimedea");
        presets.Add(new MissionTimerPreset("archimedea", "EDA / ETA objectives",
            arch.GetProperty("module_path").GetString()!, arch.GetProperty("file").GetString()!,
            arch.GetProperty("body_key").GetString()!, "ARCHIMEDEA_OBJECTIVES",
            "Separate Survival duration and objective counts for Deep and Temporal Archimedea.",
            "These settings also apply to non-Elite Deep/Temporal Archimedea. Survival pickup refill and added-time settings still come from regular Survival; its rotation interval does not set the required completion time. Other regular timer presets do not target these objective counts. One file contains all six choices: export it again when changing either mode. Applies to newly generated mission chains; restart the game after installation. Extermination, Assassination and Legacyte Harvest are unchanged by this preset.",
            [
                new("eda_survival_minutes", "Required Survival time", 10, 10, 5, "minutes", "Required completion time, including its countdown. Whole minutes; 1–60. Native time-reduction events still apply.", Group: "EDA · Survival"),
                new("eda_mirror_defenses", "Targets to defend", 4, 4, 2, "defenses", "Number of individual target-defense phases before completion. Does not change each phase's duration. Whole numbers; 1–4.", Group: "EDA · Mirror Defense"),
                new("eda_alchemy_mixtures", "Mixtures to complete", 2, 2, 1, "mixtures", "Completed crucible mixtures required for extraction. Element collection and pressure mechanics are unchanged. Whole numbers; 1–2.", Group: "EDA · Alchemy"),
                new("eda_disruption_conduits", "Conduits to complete", 8, 8, 4, "conduits", "Native fixed-mission conduit-completion target; not eight reward rotations. Whole numbers; 1–8. Demolisher and failure rules remain stock.", Group: "EDA · Disruption"),
                new("eta_survival_minutes", "Required Survival time", 10, 10, 5, "minutes", "Required completion time, including its countdown. Whole minutes; 1–60. Native time-reduction events still apply.", Group: "ETA · Survival"),
                new("eta_defense_waves", "Waves to complete", 6, 6, 3, "waves", "Defense waves required for extraction. Enemy spawning and special enemies remain stock. Whole numbers; 1–6.", Group: "ETA · Defense"),
            ], "EDA / ETA"));
        return presets;
    }
}
