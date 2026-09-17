using System.Globalization;

namespace Renovice.AbilityEditor.Core;

public sealed record SemanticNameEntry(
    int Prototype,
    int Web,
    string Canonical,
    string Readable,
    string Confidence,
    string Evidence,
    string SemanticType,
    string TypeConfidence,
    string TypeEvidence)
{
    public string DisplayName => string.IsNullOrWhiteSpace(Readable) ? Canonical : Readable;

    public string SearchText => string.Join('\n',
        Prototype.ToString(CultureInfo.InvariantCulture),
        Web.ToString(CultureInfo.InvariantCulture),
        Canonical,
        Readable,
        Confidence,
        Evidence,
        SemanticType,
        TypeConfidence,
        TypeEvidence);
}

public sealed class SemanticNamingMap
{
    private static readonly string[] RequiredColumns =
    [
        "prototype",
        "web",
        "canonical",
        "readable",
        "confidence",
        "evidence",
        "semantic_type",
        "type_confidence",
        "type_evidence",
    ];

    private SemanticNamingMap(string path, IReadOnlyList<SemanticNameEntry> entries)
    {
        Path = path;
        Entries = entries;
    }

    public string Path { get; }

    public IReadOnlyList<SemanticNameEntry> Entries { get; }

    public int PrototypeCount => Entries.Select(entry => entry.Prototype).Distinct().Count();

    public int AliasCount => Entries.Count(entry =>
        !string.IsNullOrWhiteSpace(entry.Readable)
        && !string.Equals(entry.Readable, entry.Canonical, StringComparison.Ordinal));

    public int TypedWebCount => Entries.Count(entry => !string.IsNullOrWhiteSpace(entry.SemanticType));

    public static SemanticNamingMap Load(string path)
    {
        if (!File.Exists(path)) throw new FileNotFoundException("Semantic naming map is missing.", path);

        using var reader = new StreamReader(path);
        var headerLine = reader.ReadLine();
        if (headerLine is null) throw new InvalidDataException($"Semantic naming map is empty: {path}");

        var header = headerLine.Split('\t');
        if (header.Length != 0) header[0] = header[0].TrimStart('\uFEFF');
        var columns = new Dictionary<string, int>(StringComparer.Ordinal);
        for (var index = 0; index < header.Length; index++)
        {
            if (string.IsNullOrWhiteSpace(header[index]))
                throw new InvalidDataException($"Semantic naming map has an empty header at column {index + 1}: {path}");
            if (!columns.TryAdd(header[index], index))
                throw new InvalidDataException($"Semantic naming map repeats column '{header[index]}': {path}");
        }
        foreach (var required in RequiredColumns)
        {
            if (!columns.ContainsKey(required))
                throw new InvalidDataException($"Semantic naming map is missing required column '{required}': {path}");
        }

        var entries = new List<SemanticNameEntry>();
        var identities = new HashSet<(int Prototype, int Web)>();
        var lineNumber = 1;
        while (reader.ReadLine() is { } line)
        {
            lineNumber++;
            if (string.IsNullOrWhiteSpace(line)) continue;
            var fields = line.Split('\t');
            if (fields.Length != header.Length)
                throw new InvalidDataException(
                    $"Semantic naming map line {lineNumber} has {fields.Length} fields; expected {header.Length}: {path}");

            string Field(string name) => fields[columns[name]];
            if (!int.TryParse(Field("prototype"), NumberStyles.None, CultureInfo.InvariantCulture, out var prototype)
                || prototype < 0)
                throw new InvalidDataException($"Semantic naming map line {lineNumber} has an invalid prototype: {path}");
            if (!int.TryParse(Field("web"), NumberStyles.None, CultureInfo.InvariantCulture, out var web)
                || web < 0)
                throw new InvalidDataException($"Semantic naming map line {lineNumber} has an invalid value web: {path}");
            if (!identities.Add((prototype, web)))
                throw new InvalidDataException(
                    $"Semantic naming map repeats identity prototype={prototype}, web={web}: {path}");

            var canonical = Field("canonical");
            if (string.IsNullOrWhiteSpace(canonical))
                throw new InvalidDataException($"Semantic naming map line {lineNumber} has no canonical identity: {path}");

            entries.Add(new SemanticNameEntry(
                prototype,
                web,
                canonical,
                Field("readable"),
                Field("confidence"),
                Field("evidence"),
                Field("semantic_type"),
                Field("type_confidence"),
                Field("type_evidence")));
        }

        return new SemanticNamingMap(path, entries);
    }
}
