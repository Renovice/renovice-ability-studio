using System.Globalization;
using System.Text;
using System.Text.RegularExpressions;

namespace Renovice.AbilityEditor.Core;

public sealed record StockNumericValue(
    int Offset,
    int Length,
    int Line,
    string Variable,
    string Label,
    string Evidence,
    double OriginalValue,
    double Value);

public sealed record StockValueBinding(
    string ModuleBodyKey,
    string Variable,
    string Label,
    string Family,
    string Status,
    string Evidence);

public sealed class StockValueBindingRegistry
{
    private readonly Dictionary<(string BodyKey, string Variable), StockValueBinding> bindings;

    private StockValueBindingRegistry(Dictionary<(string, string), StockValueBinding> bindings) => this.bindings = bindings;

    public static StockValueBindingRegistry Load(string path)
    {
        var parsed = new Dictionary<(string, string), StockValueBinding>();
        foreach (var line in File.ReadLines(path).Skip(1).Where(line => !string.IsNullOrWhiteSpace(line)))
        {
            var values = line.Split('\t');
            if (values.Length < 6) throw new InvalidDataException($"Malformed stock value binding row: {line}");
            var binding = new StockValueBinding(values[0], values[1], values[2], values[3], values[4], values[5]);
            if (!parsed.TryAdd((binding.ModuleBodyKey.ToLowerInvariant(), binding.Variable), binding))
                throw new InvalidDataException($"Duplicate stock value binding: {binding.ModuleBodyKey}/{binding.Variable}");
        }
        return new StockValueBindingRegistry(parsed);
    }

    public StockValueBinding? Find(string bodyKey, string variable) =>
        bindings.GetValueOrDefault((bodyKey.ToLowerInvariant(), variable));
}

public static partial class StockNumericEditor
{
    public static IReadOnlyList<StockNumericValue> Discover(
        string moduleBodyKey,
        string source,
        StockValueBindingRegistry registry)
    {
        var candidates = AssignmentRegex().Matches(source).Cast<Match>()
            .Select(match => new
            {
                Match = match,
                Variable = match.Groups["variable"].Value,
                Number = match.Groups["number"],
                Value = double.Parse(match.Groups["number"].Value, CultureInfo.InvariantCulture),
            })
            .ToList();

        var ladderVariables = candidates.GroupBy(item => item.Variable, StringComparer.Ordinal)
            .Where(group => group.Count() >= 3 && group.Select(item => item.Value).Distinct().Count() >= 2)
            .Select(group => group.Key)
            .ToHashSet(StringComparer.Ordinal);

        return candidates.Where(item => ladderVariables.Contains(item.Variable)).Select(item =>
        {
            var binding = registry.Find(moduleBodyKey, item.Variable);
            var line = 1 + source.AsSpan(0, item.Number.Index).Count('\n');
            var label = binding?.Label ?? $"Unlabeled stock ladder {item.Variable}";
            var evidence = binding is null
                ? "UNRESOLVED: exact assignment found; gameplay meaning is not yet bound"
                : $"{binding.Status} {binding.Family}: {binding.Evidence}";
            return new StockNumericValue(item.Number.Index, item.Number.Length, line, item.Variable,
                label, evidence, item.Value, item.Value);
        }).ToList();
    }

    public static string Apply(string source, IReadOnlyList<StockNumericValue> values)
    {
        var changed = values.Where(value => value.Value != value.OriginalValue)
            .OrderByDescending(value => value.Offset).ToList();
        var builder = new StringBuilder(source);
        foreach (var value in changed)
        {
            if (!double.IsFinite(value.Value))
                throw new InvalidDataException($"{value.Label} line {value.Line}: value must be finite.");
            var expected = value.OriginalValue.ToString("0.################", CultureInfo.InvariantCulture);
            var actual = builder.ToString(value.Offset, value.Length);
            if (!double.TryParse(actual, NumberStyles.Float, CultureInfo.InvariantCulture, out var actualNumber)
                || actualNumber != value.OriginalValue)
                throw new InvalidDataException(
                    $"Structural assignment at line {value.Line} changed after discovery. Expected {expected}, found '{actual}'.");
            builder.Remove(value.Offset, value.Length);
            builder.Insert(value.Offset, value.Value.ToString("0.################", CultureInfo.InvariantCulture));
        }
        return builder.ToString();
    }

    [GeneratedRegex("(?m)^(?<indent>\\s*)(?<variable>[A-Za-z_][A-Za-z0-9_]*(?:\\[[0-9]+\\])?)\\s*=\\s*(?<number>-?(?:[0-9]+(?:\\.[0-9]+)?|\\.[0-9]+))\\s*$")]
    private static partial Regex AssignmentRegex();
}
