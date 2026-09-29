using System.Text;
using System.Text.Json;
using System.Globalization;

namespace Renovice.AbilityEditor.Core;

public sealed record CardStatEntry(string Label, string Evidence, StockNumericValue? Input);
public sealed record LinkedCardControl(string Label, string Unit, string Evidence,
    double Minimum, double Maximum, IReadOnlyList<StockNumericValue> Inputs, string Operation = "set")
{
    public double InitialValue => Operation == "scale" ? 1 : Inputs.Count > 0 ? Inputs[0].OriginalValue : 0;
    public string StockCaption => Operation == "scale"
        ? "Base values: " + string.Join(" / ", Inputs.Select(i => i.OriginalValue).Distinct().Order().Select(v => v.ToString("G6", CultureInfo.InvariantCulture)))
        : Inputs.Count > 0 ? "Stock: " + InitialValue.ToString("G6", CultureInfo.InvariantCulture) : "Gameplay binding not yet verified";
    public IReadOnlyList<StockNumericValue> Edits(double value)
    {
        if (Inputs.Count == 0 || !double.IsFinite(value) || value < Minimum || value > Maximum)
            throw new InvalidDataException($"{Label}: no verified link or value outside {Minimum}–{Maximum}.");
        if (Operation is not ("set" or "scale")) throw new InvalidDataException("Unknown linked edit operation");
        var edits = Inputs.Select(input => input with { Value = Operation == "scale" ? input.OriginalValue * value : value }).ToList();
        if (edits.Any(e => !double.IsFinite(e.Value))) throw new InvalidDataException("Scaled value is not finite");
        return edits;
    }
}

public static class CardStatDiscovery
{
    private static async Task<string> DiscoverJsonAsync(
        WorkspacePaths workspace, string bodyKey, string source)
    {
        var directory = Path.Combine(workspace.WorkspaceRoot, "work", "card-stat-discovery");
        Directory.CreateDirectory(directory);
        var path = Path.Combine(directory, Guid.NewGuid().ToString("N") + ".luau");
        try
        {
            await File.WriteAllTextAsync(path, source, new UTF8Encoding(false));
            var result = await CliBridge.RunAsync(workspace,
                ["card-stats", "--source", path, "--body-key", bodyKey, "--names", workspace.LocalizedNamesPath]);
            if (!result.Success) throw new InvalidDataException(result.Output);
            return result.Output;
        }
        finally { File.Delete(path); }
    }

    public static async Task<IReadOnlyList<CardStatEntry>> DiscoverAsync(WorkspacePaths workspace, string bodyKey, string source) =>
        Parse(await DiscoverJsonAsync(workspace, bodyKey, source), bodyKey, source);

    public static async Task<IReadOnlyList<LinkedCardControl>> DiscoverLinkedAsync(WorkspacePaths workspace, string bodyKey, string source) =>
        ParseLinked(await DiscoverJsonAsync(workspace, bodyKey, source), bodyKey, source);

    public static IReadOnlyList<LinkedCardControl> ParseLinked(string json, string bodyKey, string source)
    {
        _ = Parse(json, bodyKey, source);
        var bytes = Encoding.UTF8.GetBytes(source);
        using var document = JsonDocument.Parse(json);
        var root = document.RootElement;
        var controls = new List<LinkedCardControl>();
        var used = new HashSet<int>();
        var verifiedTags = new HashSet<string>();
        if (root.TryGetProperty("controls", out var linked))
        foreach (var control in linked.EnumerateArray())
        {
            var inputs = new List<StockNumericValue>();
            foreach (var input in control.GetProperty("inputs").EnumerateArray())
            {
                var byteOffset = input.GetProperty("offset").GetInt32();
                var length = input.GetProperty("length").GetInt32();
                if (byteOffset < 0 || length <= 0 || byteOffset > bytes.Length - length) throw new InvalidDataException("Linked input span out of range");
                var offset = Encoding.UTF8.GetCharCount(bytes.AsSpan(0, byteOffset));
                var original = input.GetProperty("original").GetDouble();
                if (!double.IsFinite(original) || !double.TryParse(source.AsSpan(offset, length), NumberStyles.Float, CultureInfo.InvariantCulture, out var actual) || actual != original || !used.Add(offset))
                    throw new InvalidDataException("Stale or overlapping linked input");
                var match = new StockNumericValue(offset, length, input.GetProperty("line").GetInt32(), input.GetProperty("variable").GetString()!,
                    control.GetProperty("label").GetString()!, control.GetProperty("evidence").GetString()!, original, original);
                inputs.Add(match);
            }
            var roles = control.GetProperty("assignments").EnumerateArray().Select(a => a.GetProperty("role").GetString()).ToHashSet();
            if (!roles.Contains("card") || !roles.Contains("gameplay") || inputs.Count < 1)
                throw new InvalidDataException("A control must link card and gameplay assignments");
            controls.Add(new(control.GetProperty("label").GetString()!, control.GetProperty("unit").GetString()!,
                control.GetProperty("evidence").GetString()!, control.GetProperty("minimum").GetDouble(),
                control.GetProperty("maximum").GetDouble(), inputs,
                control.TryGetProperty("operation", out var operation) ? operation.GetString()! : "set"));
            verifiedTags.Add(control.GetProperty("label_tag").GetString()!);
            if (control.TryGetProperty("label_tags", out var tags)) foreach (var tag in tags.EnumerateArray()) verifiedTags.Add(tag.GetString()!);
        }
        foreach (var row in root.GetProperty("rows").EnumerateArray().DistinctBy(r => r.GetProperty("label_tag").GetString()))
        {
            if (verifiedTags.Contains(row.GetProperty("label_tag").GetString()!)) continue;
            controls.Add(new(row.GetProperty("label").GetString()!, "", "Read-only: the native card label is known, but a linked gameplay edit has not been verified for this exact source.", 0, 0, []));
        }
        return controls;
    }

    public static IReadOnlyList<CardStatEntry> Parse(string json, string bodyKey, string source)
    {
        using var document = JsonDocument.Parse(json);
        var root = document.RootElement;
        if (root.GetProperty("format").GetString() != "RENOVICE_CARD_STATS_V1"
            || root.GetProperty("body_key").GetString() != bodyKey)
            throw new InvalidDataException("Card stat identity mismatch");
        var bytes = Encoding.UTF8.GetBytes(source);
        var entries = new List<CardStatEntry>();
        foreach (var row in root.GetProperty("rows").EnumerateArray())
        {
            var label = row.GetProperty("label").GetString()!;
            var evidence = row.GetProperty("label_tag").GetString() + " · "
                + row.GetProperty("evidence").GetString();
            if (row.GetProperty("inputs").GetArrayLength() == 0)
            {
                entries.Add(new(label, evidence + " Expression: " + row.GetProperty("expression").GetString(), null));
                continue;
            }
            foreach (var input in row.GetProperty("inputs").EnumerateArray())
            {
                var offset = Encoding.UTF8.GetCharCount(bytes.AsSpan(0, input.GetProperty("offset").GetInt32()));
                var length = input.GetProperty("length").GetInt32();
                var original = input.GetProperty("original").GetDouble();
                if (offset < 0 || length <= 0 || offset > source.Length - length
                    || !double.IsFinite(original)
                    || !double.TryParse(source.AsSpan(offset, length), NumberStyles.Float,
                        CultureInfo.InvariantCulture, out var actual) || actual != original)
                    throw new InvalidDataException("Card input no longer matches the supplied source");
                entries.Add(new(label, evidence, new StockNumericValue(offset, length,
                    input.GetProperty("line").GetInt32(), input.GetProperty("variable").GetString()!,
                    label, evidence, original, original)));
            }
        }
        // One source number can feed several rows. Edit it once and show all labels.
        var merged = entries.Where(e => e.Input is not null).GroupBy(e => e.Input!.Offset).Select(group =>
        {
            var label = string.Join(" / ", group.Select(e => e.Label).Distinct());
            var first = group.First();
            return first with { Label = label, Input = first.Input! with { Label = label } };
        });
        return merged.Concat(entries.Where(e => e.Input is null).DistinctBy(e => (e.Label, e.Evidence))).ToList();
    }
}
