namespace Renovice.AbilityEditor.Core;

public sealed record HelminthAbilityDefinition(
    string AbilityName,
    string Powersuit,
    string AbilityAssetPath,
    string Provenance,
    string RetrievedAt,
    string SourceUrl);

public sealed class HelminthRegistry
{
    private readonly Dictionary<string, HelminthAbilityDefinition> byAssetPath;

    private HelminthRegistry(Dictionary<string, HelminthAbilityDefinition> byAssetPath) => this.byAssetPath = byAssetPath;

    public int Count => byAssetPath.Count;

    public static HelminthRegistry Load(string path)
    {
        var lines = File.ReadAllLines(path);
        if (lines.Length < 2) throw new InvalidDataException($"Helminth registry is empty: {path}");
        var result = new Dictionary<string, HelminthAbilityDefinition>(StringComparer.OrdinalIgnoreCase);
        foreach (var line in lines.Skip(1).Where(line => !string.IsNullOrWhiteSpace(line)))
        {
            var values = line.Split('\t');
            if (values.Length != 6) throw new InvalidDataException($"Malformed Helminth registry row: {line}");
            var definition = new HelminthAbilityDefinition(values[0], values[1], values[2], values[3], values[4], values[5]);
            if (!result.TryAdd(definition.AbilityAssetPath, definition))
                throw new InvalidDataException($"Duplicate Helminth asset path: {definition.AbilityAssetPath}");
        }
        return new HelminthRegistry(result);
    }

    public HelminthAbilityDefinition? Find(string assetPath) => byAssetPath.GetValueOrDefault(assetPath);
}
