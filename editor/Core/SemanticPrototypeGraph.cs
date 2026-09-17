using System.Globalization;

namespace Renovice.AbilityEditor.Core;

public sealed record SemanticPrototypeNode(
    int Prototype,
    string EvidenceRole,
    string ExactExports,
    int IdentityRows,
    int SourceMappedIdentities,
    int FriendlyAliases,
    int TypedIdentities,
    int IncomingClosures,
    int OutgoingClosures,
    string ConfidenceSummary);

public sealed record SemanticPrototypeRelation(
    string Kind,
    string From,
    string To,
    int TargetPrototype,
    string Label,
    string Confidence,
    string Evidence);

public sealed class SemanticPrototypeGraph
{
    private SemanticPrototypeGraph(
        IReadOnlyList<SemanticPrototypeNode> nodes,
        IReadOnlyList<SemanticPrototypeRelation> relations,
        int exportCount,
        int closureCount)
    {
        Nodes = nodes;
        Relations = relations;
        ExportCount = exportCount;
        ClosureCount = closureCount;
    }

    public IReadOnlyList<SemanticPrototypeNode> Nodes { get; }
    public IReadOnlyList<SemanticPrototypeRelation> Relations { get; }
    public int ExportCount { get; }
    public int ClosureCount { get; }

    public string Summary => string.Create(
        CultureInfo.InvariantCulture,
        $"VERIFIED STRUCTURAL OUTLINE ONLY — prototypes={Nodes.Count}, exact exports={ExportCount}, "
        + $"closure edges={ClosureCount}. Native API call edges and complete function-body ownership are not inferred.");

    public static SemanticPrototypeGraph Build(
        SemanticNamingMap namingMap,
        ClosureOwnershipMap closureMap,
        SemanticVerificationDocument verification)
    {
        if (verification.ExportCount != verification.Exports.Count)
            throw new InvalidDataException("Semantic verification export count is inconsistent.");
        if (verification.ClosureSiteCount != closureMap.Entries.Count)
            throw new InvalidDataException("Semantic verification closure count is inconsistent.");

        var prototypeIds = namingMap.Entries.Select(entry => entry.Prototype)
            .Concat(closureMap.Entries.SelectMany(entry =>
                new[] { entry.ParentPrototype, entry.TargetPrototype }))
            .Concat(verification.Exports.Select(entry => entry.Prototype))
            .Distinct()
            .OrderBy(value => value)
            .ToArray();

        var nodes = new List<SemanticPrototypeNode>(prototypeIds.Length);
        foreach (var prototype in prototypeIds)
        {
            var identities = namingMap.Entries.Where(entry => entry.Prototype == prototype).ToArray();
            var exports = verification.Exports.Where(entry => entry.Prototype == prototype).ToArray();
            var incoming = closureMap.Entries.Count(entry => entry.TargetPrototype == prototype);
            var outgoing = closureMap.Entries.Count(entry => entry.ParentPrototype == prototype);
            var sourceMapped = identities.Count(entry =>
                verification.Occurrences.TryGetValue((entry.Prototype, entry.Web), out var occurrences)
                && occurrences.Count != 0);
            var confidences = identities
                .Where(entry => !string.IsNullOrWhiteSpace(entry.Confidence))
                .GroupBy(entry => entry.Confidence, StringComparer.Ordinal)
                .OrderByDescending(group => group.Count())
                .ThenBy(group => group.Key, StringComparer.Ordinal)
                .Select(group => $"{group.Key}={group.Count()}");
            var role = exports.Length != 0
                ? "EXPORTED"
                : incoming != 0
                    ? "CLOSURE_TARGET"
                    : "NO_INCOMING_CLOSURE_EVIDENCE";
            nodes.Add(new SemanticPrototypeNode(
                prototype,
                role,
                string.Join(", ", exports.Select(entry => entry.ExportedName).Distinct(StringComparer.Ordinal)),
                identities.Length,
                sourceMapped,
                identities.Count(entry => !string.IsNullOrWhiteSpace(entry.Readable)
                    && !string.Equals(entry.Readable, entry.Canonical, StringComparison.Ordinal)),
                identities.Count(entry => !string.IsNullOrWhiteSpace(entry.SemanticType)),
                incoming,
                outgoing,
                string.Join(", ", confidences)));
        }

        var relations = new List<SemanticPrototypeRelation>(verification.ExportCount + closureMap.Entries.Count);
        relations.AddRange(verification.Exports.Select(entry => new SemanticPrototypeRelation(
            "EXACT_EXPORT",
            "MODULE_EXPORTS",
            $"p{entry.Prototype}",
            entry.Prototype,
            entry.ExportedName,
            entry.Confidence,
            entry.Evidence)));
        relations.AddRange(closureMap.Entries.Select(entry => new SemanticPrototypeRelation(
            "CLOSURE_OWNERSHIP",
            $"p{entry.ParentPrototype}",
            $"p{entry.TargetPrototype}",
            entry.TargetPrototype,
            $"{entry.Operation} i{entry.Instruction} -> R{entry.DestinationRegister}",
            "EXACT_CLOSURE_MAP",
            $"{entry.OperandNamespace}[{entry.OperandIndex}], captures={entry.CaptureCount}: {entry.Captures}")));

        if (relations.Count != verification.ExportCount + closureMap.Entries.Count)
            throw new InvalidDataException("Semantic prototype relation count is inconsistent.");
        return new SemanticPrototypeGraph(nodes, relations, verification.ExportCount, closureMap.Entries.Count);
    }
}
