using System.Text.Json;
using System.Text.Json.Serialization;

namespace Renovice.AbilityEditor.Core;

public sealed class AbilityCatalog
{
    [JsonPropertyName("format")] public string Format { get; set; } = "";
    [JsonPropertyName("metadata_snapshot")] public string MetadataSnapshot { get; set; } = "";
    [JsonPropertyName("counts")] public CatalogCounts Counts { get; set; } = new();
    [JsonPropertyName("warframes")] public List<WarframeCatalogEntry> Warframes { get; set; } = [];

    public static AbilityCatalog Load(string path)
    {
        var catalog = JsonSerializer.Deserialize<AbilityCatalog>(File.ReadAllText(path), JsonOptions)
            ?? throw new InvalidDataException("Ability catalog deserialized as null");
        if (catalog.Format != "RENOVICE_ABILITY_CATALOG_V1")
            throw new InvalidDataException($"Unsupported ability catalog format: {catalog.Format}");
        foreach (var warframe in catalog.Warframes)
        {
            foreach (var ability in warframe.Abilities)
                ability.Owner = warframe;
        }
        return catalog;
    }

    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNameCaseInsensitive = false,
    };
}

public sealed class CatalogCounts
{
    [JsonPropertyName("warframes")] public int Warframes { get; set; }
    [JsonPropertyName("abilities")] public int Abilities { get; set; }
    [JsonPropertyName("resolved_body_keys")] public int ResolvedBodyKeys { get; set; }
    [JsonPropertyName("unresolved_modules")] public int UnresolvedModules { get; set; }
}

public sealed class WarframeCatalogEntry
{
    [JsonPropertyName("name")] public string Name { get; set; } = "";
    [JsonPropertyName("name_source")] public string NameSource { get; set; } = "";
    [JsonPropertyName("warframe_asset_path")] public string AssetPath { get; set; } = "";
    [JsonPropertyName("warframe_localize_tag")] public string LocalizeTag { get; set; } = "";
    [JsonPropertyName("abilities")] public List<AbilityCatalogEntry> Abilities { get; set; } = [];
    [JsonIgnore] public string DisplayName => $"{Name}  ({Abilities.Count})";
}

public sealed class AbilityCatalogEntry
{
    [JsonPropertyName("slot")] public int Slot { get; set; }
    [JsonPropertyName("name")] public string Name { get; set; } = "";
    [JsonPropertyName("name_source")] public string NameSource { get; set; } = "";
    [JsonPropertyName("ability_asset_path")] public string AssetPath { get; set; } = "";
    [JsonPropertyName("ability_localize_tag")] public string LocalizeTag { get; set; } = "";
    [JsonPropertyName("ability_description_tag")] public string DescriptionTag { get; set; } = "";
    [JsonPropertyName("ability_identifier")] public string Identifier { get; set; } = "";
    [JsonPropertyName("module_path")] public string ModulePath { get; set; } = "";
    [JsonPropertyName("entry_function")] public string EntryFunction { get; set; } = "";
    [JsonPropertyName("module_body_key")] public string BodyKey { get; set; } = "";
    [JsonPropertyName("stock_bytecode_path")] public string StockBytecodePath { get; set; } = "";
    [JsonPropertyName("resolution_status")] public string ResolutionStatus { get; set; } = "";
    [JsonIgnore] public WarframeCatalogEntry? Owner { get; set; }
    [JsonIgnore] public HelminthAbilityDefinition? HelminthDefinition { get; set; }
    [JsonIgnore] public string DisplayName => $"{Slot}. {Name}" + (HelminthDefinition is null ? "" : "  [HELMINTH]");
}
