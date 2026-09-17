using System.Globalization;

namespace Renovice.AbilityEditor.Core;

public sealed record ClosureOwnershipEntry(
    int ParentPrototype,
    int Instruction,
    string Operation,
    int DestinationRegister,
    string OperandNamespace,
    int OperandIndex,
    int TargetPrototype,
    int TargetParameters,
    int TargetUpvalues,
    int TargetMaxStack,
    int CaptureCount,
    string Captures,
    string Status);

public sealed class ClosureOwnershipMap
{
    private static readonly string[] RequiredColumns =
    [
        "parent_proto",
        "instruction",
        "op",
        "destination_register",
        "operand_namespace",
        "operand_index",
        "target_proto",
        "target_params",
        "target_upvalues",
        "target_maxstack",
        "capture_count",
        "captures",
        "status",
    ];

    private ClosureOwnershipMap(string path, IReadOnlyList<ClosureOwnershipEntry> entries)
    {
        Path = path;
        Entries = entries;
    }

    public string Path { get; }

    public IReadOnlyList<ClosureOwnershipEntry> Entries { get; }

    public int PrototypeCount => Entries
        .SelectMany(entry => new[] { entry.ParentPrototype, entry.TargetPrototype })
        .Distinct()
        .Count();

    public int CaptureCount => Entries.Sum(entry => entry.CaptureCount);

    public static ClosureOwnershipMap Load(string path)
    {
        if (!File.Exists(path)) throw new FileNotFoundException("Closure ownership map is missing.", path);

        using var reader = new StreamReader(path);
        var headerLine = reader.ReadLine();
        if (headerLine is null) throw new InvalidDataException($"Closure ownership map is empty: {path}");
        var header = headerLine.Split('\t');
        if (header.Length != 0) header[0] = header[0].TrimStart('\uFEFF');
        var columns = new Dictionary<string, int>(StringComparer.Ordinal);
        for (var index = 0; index < header.Length; index++)
        {
            if (string.IsNullOrWhiteSpace(header[index]))
                throw new InvalidDataException($"Closure ownership map has an empty header at column {index + 1}: {path}");
            if (!columns.TryAdd(header[index], index))
                throw new InvalidDataException($"Closure ownership map repeats column '{header[index]}': {path}");
        }
        foreach (var required in RequiredColumns)
        {
            if (!columns.ContainsKey(required))
                throw new InvalidDataException($"Closure ownership map is missing required column '{required}': {path}");
        }

        var entries = new List<ClosureOwnershipEntry>();
        var sites = new HashSet<(int Parent, int Instruction)>();
        var lineNumber = 1;
        while (reader.ReadLine() is { } line)
        {
            lineNumber++;
            if (string.IsNullOrWhiteSpace(line)) continue;
            var fields = line.Split('\t');
            if (fields.Length != header.Length)
                throw new InvalidDataException(
                    $"Closure ownership map line {lineNumber} has {fields.Length} fields; expected {header.Length}: {path}");

            string Field(string name) => fields[columns[name]];
            int Integer(string name)
            {
                if (!int.TryParse(Field(name), NumberStyles.None, CultureInfo.InvariantCulture, out var value)
                    || value < 0)
                    throw new InvalidDataException(
                        $"Closure ownership map line {lineNumber} has an invalid {name}: {path}");
                return value;
            }

            var parent = Integer("parent_proto");
            var instruction = Integer("instruction");
            if (!sites.Add((parent, instruction)))
                throw new InvalidDataException(
                    $"Closure ownership map repeats site parent={parent}, instruction={instruction}: {path}");

            var operation = Field("op");
            if (operation is not ("NEWCLOSURE" or "DUPCLOSURE"))
                throw new InvalidDataException(
                    $"Closure ownership map line {lineNumber} has unsupported operation '{operation}': {path}");
            var operandNamespace = Field("operand_namespace");
            if (operandNamespace is not ("child" or "const"))
                throw new InvalidDataException(
                    $"Closure ownership map line {lineNumber} has unsupported operand namespace '{operandNamespace}': {path}");
            var status = Field("status");
            if (!string.Equals(status, "PASS", StringComparison.Ordinal))
                throw new InvalidDataException(
                    $"Closure ownership map line {lineNumber} is not fail-closed PASS: {path}");

            var captureCount = Integer("capture_count");
            var captures = Field("captures");
            ValidateCaptures(captures, captureCount, lineNumber, path);
            entries.Add(new ClosureOwnershipEntry(
                parent,
                instruction,
                operation,
                Integer("destination_register"),
                operandNamespace,
                Integer("operand_index"),
                Integer("target_proto"),
                Integer("target_params"),
                Integer("target_upvalues"),
                Integer("target_maxstack"),
                captureCount,
                captures,
                status));
        }

        return new ClosureOwnershipMap(path, entries);
    }

    private static void ValidateCaptures(string captures, int expectedCount, int lineNumber, string path)
    {
        string[] fields = captures.Length == 0 ? [] : captures.Split(';');
        if (fields.Length != expectedCount)
            throw new InvalidDataException(
                $"Closure ownership map line {lineNumber} declares {expectedCount} captures but contains {fields.Length}: {path}");
        for (var index = 0; index < fields.Length; index++)
        {
            var expectedPrefix = index.ToString(CultureInfo.InvariantCulture) + "=";
            if (!fields[index].StartsWith(expectedPrefix, StringComparison.Ordinal))
                throw new InvalidDataException(
                    $"Closure ownership map line {lineNumber} has an out-of-order capture at index {index}: {path}");
            var source = fields[index][expectedPrefix.Length..];
            var separator = source.IndexOf(':');
            if (separator <= 0 || separator + 2 > source.Length)
                throw new InvalidDataException(
                    $"Closure ownership map line {lineNumber} has a malformed capture '{fields[index]}': {path}");
            var kind = source[..separator];
            var register = source[(separator + 1)..];
            var validPrefix = kind switch
            {
                "VAL" or "REF" => 'R',
                "UPVAL" => 'U',
                _ => '\0',
            };
            if (validPrefix == '\0' || register[0] != validPrefix
                || !int.TryParse(register[1..], NumberStyles.None, CultureInfo.InvariantCulture, out var value)
                || value < 0)
                throw new InvalidDataException(
                    $"Closure ownership map line {lineNumber} has a malformed capture '{fields[index]}': {path}");
        }
    }
}
