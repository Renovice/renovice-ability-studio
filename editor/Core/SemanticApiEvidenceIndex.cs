namespace Renovice.AbilityEditor.Core;

public sealed record SemanticApiEvidenceContract(
    string Descriptor,
    string Kind,
    string Receiver,
    string Member,
    int IdentityRows,
    int PrototypeCount,
    int SourceMappedRows,
    int LiveConfirmedRows,
    int StockBytecodeRows,
    int CatalogOnlyRows,
    int UnresolvedRows,
    string StatusSummary,
    string Boundary)
{
    public string DisplayName => Kind == "method" ? $"{Receiver}:{Member}" : Member;
}

public sealed class SemanticApiEvidenceIndex
{
    private sealed record ParsedEvidence(
        SemanticNameEntry Entry,
        string Descriptor,
        string Kind,
        string Receiver,
        string Member,
        string ContractConfidence,
        string Status);

    private SemanticApiEvidenceIndex(IReadOnlyList<SemanticApiEvidenceContract> contracts, int identityRows)
    {
        Contracts = contracts;
        IdentityRows = identityRows;
    }

    public IReadOnlyList<SemanticApiEvidenceContract> Contracts { get; }
    public int IdentityRows { get; }
    public int LiveConfirmedRows => Contracts.Sum(contract => contract.LiveConfirmedRows);
    public int StockBytecodeRows => Contracts.Sum(contract => contract.StockBytecodeRows);
    public int CatalogOnlyRows => Contracts.Sum(contract => contract.CatalogOnlyRows);
    public int UnresolvedRows => Contracts.Sum(contract => contract.UnresolvedRows);

    public string Summary =>
        $"VERIFIED API EVIDENCE INDEX — descriptors={Contracts.Count}, bound identity rows={IdentityRows}, "
        + $"live-confirmed={LiveConfirmedRows}, stock-bytecode={StockBytecodeRows}, "
        + $"catalog-only={CatalogOnlyRows}, unresolved={UnresolvedRows}. "
        + "Rows are evidence bindings, not callsite counts or proof that every invocation was live-tested.";

    public static SemanticApiEvidenceIndex Build(
        SemanticNamingMap namingMap,
        SemanticVerificationDocument verification)
    {
        var parsed = namingMap.Entries
            .Where(entry => entry.Evidence.StartsWith("semantic-sdk:lua:", StringComparison.Ordinal))
            .Select(Parse)
            .ToArray();
        var contracts = parsed
            .GroupBy(item => item.Descriptor, StringComparer.Ordinal)
            .OrderBy(group => group.First().Kind, StringComparer.Ordinal)
            .ThenBy(group => group.First().Receiver, StringComparer.Ordinal)
            .ThenBy(group => group.First().Member, StringComparer.Ordinal)
            .Select(group => BuildContract(group, verification))
            .ToArray();
        return new SemanticApiEvidenceIndex(contracts, parsed.Length);
    }

    private static ParsedEvidence Parse(SemanticNameEntry entry)
    {
        var segments = entry.Evidence.Split(';');
        var descriptor = segments[0];
        var fields = descriptor.Split(':');
        if (fields.Length != 5
            || fields[0] != "semantic-sdk"
            || fields[1] != "lua"
            || fields[2] is not ("method" or "global_function")
            || string.IsNullOrWhiteSpace(fields[3])
            || string.IsNullOrWhiteSpace(fields[4]))
            throw new InvalidDataException(
                $"Malformed Semantic SDK descriptor for prototype={entry.Prototype}, web={entry.Web}: {descriptor}");
        if (fields[2] == "global_function" && fields[3] != "_GLOBAL")
            throw new InvalidDataException(
                $"Global Semantic SDK descriptor has non-global receiver '{fields[3]}': {descriptor}");

        var contractConfidence = SingleMetadata(segments, "confidence", entry);
        var status = SingleMetadata(segments, "status", entry);
        _ = SingleMetadata(segments, "evidence", entry, allowEmpty: true);
        return new ParsedEvidence(
            entry,
            descriptor,
            fields[2],
            fields[3],
            fields[4],
            contractConfidence,
            status);
    }

    private static string SingleMetadata(
        IEnumerable<string> segments,
        string key,
        SemanticNameEntry entry,
        bool allowEmpty = false)
    {
        var prefix = key + "=";
        var values = segments
            .Select(segment => segment.Trim())
            .Where(segment => segment.StartsWith(prefix, StringComparison.Ordinal))
            .Select(segment => segment[prefix.Length..])
            .ToArray();
        if (values.Length != 1 || (!allowEmpty && string.IsNullOrWhiteSpace(values[0])))
            throw new InvalidDataException(
                $"Semantic SDK evidence requires exactly one '{key}' value for "
                + $"prototype={entry.Prototype}, web={entry.Web}.");
        return values[0];
    }

    private static SemanticApiEvidenceContract BuildContract(
        IGrouping<string, ParsedEvidence> group,
        SemanticVerificationDocument verification)
    {
        var first = group.First();
        if (group.Any(item => item.Kind != first.Kind
            || item.Receiver != first.Receiver
            || item.Member != first.Member))
            throw new InvalidDataException($"Semantic SDK descriptor '{group.Key}' has inconsistent parsed fields.");
        var rows = group.ToArray();
        var sourceMapped = rows.Count(item =>
            verification.Occurrences.TryGetValue(
                (item.Entry.Prototype, item.Entry.Web), out var occurrences)
            && occurrences.Count != 0);
        var live = rows.Count(item => item.Status == "CONFIRMED" && item.ContractConfidence == "LIVE_CONFIRMED");
        var stock = rows.Count(item => item.Status == "CONFIRMED" && item.ContractConfidence == "STOCK_BYTECODE");
        var catalog = rows.Count(item => item.Status == "CATALOG_ONLY");
        var unresolved = rows.Count(item => item.Status == "UNRESOLVED");
        var classified = live + stock + catalog + unresolved;
        if (classified != rows.Length)
            throw new InvalidDataException(
                $"Semantic SDK descriptor '{group.Key}' contains an unsupported confidence/status combination.");
        var statuses = rows
            .GroupBy(item => $"{item.Status}/{item.ContractConfidence}", StringComparer.Ordinal)
            .OrderByDescending(statusGroup => statusGroup.Count())
            .ThenBy(statusGroup => statusGroup.Key, StringComparer.Ordinal)
            .Select(statusGroup => $"{statusGroup.Key}={statusGroup.Count()}");
        var boundary = unresolved != 0
            ? "Contains unresolved contract rows; do not infer a complete signature or behavior."
            : catalog != 0
                ? "Contains catalog-only rows; observed shape is not a confirmed runtime contract."
                : live != 0 && live == rows.Length
                    ? "All bound rows cite live-confirmed contract evidence; this is still not a per-callsite execution count."
                    : live != 0
                        ? "Some bound rows cite live evidence and others stock bytecode; inspect each identity before behavioral claims."
                        : "Confirmed from stock bytecode contracts; no live execution claim is added by this index.";
        return new SemanticApiEvidenceContract(
            group.Key,
            first.Kind,
            first.Receiver,
            first.Member,
            rows.Length,
            rows.Select(item => item.Entry.Prototype).Distinct().Count(),
            sourceMapped,
            live,
            stock,
            catalog,
            unresolved,
            string.Join(", ", statuses),
            boundary);
    }
}
