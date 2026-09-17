using System.Globalization;

namespace Renovice.AbilityEditor.Core;

public sealed record ModifierBindingDefinition(
    string BindingId,
    string Status,
    string Family,
    string TargetModuleBodyKey,
    string TargetAbilityIdentifier,
    string Notes);

public sealed class ModifierBindingRegistry
{
    private readonly Dictionary<string, ModifierBindingDefinition> bindings;

    private ModifierBindingRegistry(Dictionary<string, ModifierBindingDefinition> bindings)
    {
        this.bindings = bindings;
    }

    public IReadOnlyCollection<ModifierBindingDefinition> Bindings => bindings.Values;

    public static ModifierBindingRegistry Load(string path)
    {
        var lines = File.ReadAllLines(path);
        if (lines.Length < 2) throw new InvalidDataException($"Modifier registry is empty: {path}");
        var headers = lines[0].Split('\t');
        var indexes = headers.Select((header, index) => (header, index))
            .ToDictionary(pair => pair.header, pair => pair.index, StringComparer.Ordinal);
        string Required(string name)
        {
            if (!indexes.ContainsKey(name)) throw new InvalidDataException($"Modifier registry is missing column: {name}");
            return name;
        }
        Required("binding_id");
        Required("status");
        Required("family");
        Required("target_module_body_key");
        Required("target_ability_identifier");
        Required("notes");

        var parsed = new Dictionary<string, ModifierBindingDefinition>(StringComparer.Ordinal);
        for (var lineIndex = 1; lineIndex < lines.Length; lineIndex++)
        {
            if (string.IsNullOrWhiteSpace(lines[lineIndex])) continue;
            var values = lines[lineIndex].Split('\t');
            string Value(string name)
            {
                var index = indexes[name];
                return index < values.Length ? values[index].Trim() : string.Empty;
            }
            var binding = new ModifierBindingDefinition(
                Value("binding_id"), Value("status"), Value("family"),
                Value("target_module_body_key"), Value("target_ability_identifier"), Value("notes"));
            if (binding.BindingId.Length == 0)
                throw new InvalidDataException($"Modifier registry line {lineIndex + 1} has no binding_id");
            if (!parsed.TryAdd(binding.BindingId, binding))
                throw new InvalidDataException($"Duplicate modifier binding: {binding.BindingId}");
        }
        return new ModifierBindingRegistry(parsed);
    }

    public bool TryResolve(
        string? bindingId,
        string family,
        string moduleBodyKey,
        string abilityIdentifier,
        out ModifierBindingDefinition? binding,
        out string reason)
    {
        binding = null;
        if (string.Equals(family, "NONE", StringComparison.Ordinal))
        {
            reason = "No modifier";
            return string.IsNullOrWhiteSpace(bindingId);
        }
        if (string.IsNullOrWhiteSpace(bindingId) || !bindings.TryGetValue(bindingId, out binding))
        {
            reason = "Select a registered modifier binding";
            return false;
        }
        if (!string.Equals(binding.Family, family, StringComparison.Ordinal))
        {
            reason = $"Binding family is {binding.Family}, not {family}";
            return false;
        }
        if (binding.Status is not ("LIVE_CONFIRMED" or "IMPLEMENTATION_VERIFIED"))
        {
            reason = $"Binding status {binding.Status} does not authorize generation";
            return false;
        }
        if (binding.TargetModuleBodyKey != "*"
            && !string.Equals(binding.TargetModuleBodyKey, moduleBodyKey, StringComparison.OrdinalIgnoreCase))
        {
            reason = "Binding belongs to another module body key";
            return false;
        }
        if (binding.TargetAbilityIdentifier != "*"
            && !string.Equals(binding.TargetAbilityIdentifier, abilityIdentifier, StringComparison.Ordinal))
        {
            reason = "Binding belongs to another ability identifier";
            return false;
        }
        reason = binding.Status;
        return true;
    }
}

public sealed record StatPreview(
    string Label,
    double GameplayValue,
    string DisplayValue,
    string ModifierState);

public static class StatUnits
{
    public static string DisplayName(string? value) => value switch
    {
        "/Lotus/Language/Game/UNIT_PERCENT" => "Percent",
        "/Lotus/Language/Game/UNIT_SECONDS" => "Seconds",
        "/Lotus/Language/Game/UNIT_METERS" => "Meters",
        "/Lotus/Language/Game/UNIT_MULTIPLIER" => "Multiplier",
        null or "" => "None",
        _ => value,
    };

    public static string? Path(string value) => value.Trim() switch
    {
        "Percent" => "/Lotus/Language/Game/UNIT_PERCENT",
        "Seconds" => "/Lotus/Language/Game/UNIT_SECONDS",
        "Meters" => "/Lotus/Language/Game/UNIT_METERS",
        "Multiplier" => "/Lotus/Language/Game/UNIT_MULTIPLIER",
        "None" or "" => null,
        var custom => custom,
    };
}

public static class StatProjector
{
    public static StatPreview Project(
        StatDefinition definition,
        double powerStrengthPercent,
        bool showBaseStats,
        ModifierBindingRegistry registry,
        string moduleBodyKey,
        string abilityIdentifier)
    {
        if (!double.IsFinite(powerStrengthPercent) || powerStrengthPercent < 0)
            throw new InvalidDataException("Power Strength preview must be a finite non-negative percentage.");

        var value = definition.Base;
        var modifierState = "BASE";
        if (!showBaseStats && definition.ModifierFamily != "NONE")
        {
            if (!registry.TryResolve(definition.ModifierBinding, definition.ModifierFamily,
                    moduleBodyKey, abilityIdentifier, out _, out var reason))
                throw new InvalidDataException($"{definition.Label}: {reason}.");

            value = definition.ModifierFamily switch
            {
                "STRENGTH" => definition.Base * powerStrengthPercent / 100.0,
                _ => throw new InvalidDataException(
                    $"{definition.Label}: {definition.ModifierFamily} preview semantics are not implemented."),
            };
            modifierState = $"MODDED {powerStrengthPercent.ToString("G6", CultureInfo.InvariantCulture)}%";
        }
        if (definition.Minimum is not null) value = Math.Max(definition.Minimum.Value, value);
        if (definition.Maximum is not null) value = Math.Min(definition.Maximum.Value, value);

        return new StatPreview(
            definition.Label,
            value,
            FormatCardValue(definition, value),
            modifierState);
    }

    public static string FormatCardValue(StatDefinition definition, double value)
    {
        var formatted = value.ToString("0.##", CultureInfo.InvariantCulture);
        if (definition.Kind == "FRACTION" || definition.Unit == "/Lotus/Language/Game/UNIT_PERCENT")
            return (value * 100.0).ToString("0.##", CultureInfo.InvariantCulture) + "%";
        return definition.Unit switch
        {
            "/Lotus/Language/Game/UNIT_SECONDS" => formatted + "s",
            "/Lotus/Language/Game/UNIT_METERS" => formatted + "m",
            "/Lotus/Language/Game/UNIT_MULTIPLIER" => formatted + "x",
            _ => formatted,
        };
    }
}
