using System.Globalization;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;

namespace Renovice.AbilityEditor.Core;

public sealed record SemanticSourceSpan(int ByteOffset, int ByteLength, int Line, int Column);

public sealed record SemanticValueOccurrence(
    int Token,
    string Rendering,
    SemanticSourceSpan Fidelity,
    SemanticSourceSpan Readable);

public sealed record SemanticExportEntry(
    string ExportedName,
    int Prototype,
    int Web,
    string Canonical,
    string Readable,
    string Confidence,
    string Evidence,
    int SourceOccurrenceCount);

public sealed record SemanticReceiverSemantics(
    string? Type,
    string? Confidence,
    string? Evidence);

public sealed record SemanticCallsiteContract(
    string? Descriptor,
    string? Confidence,
    string? Status,
    string? Evidence,
    string? Parameters,
    string? Returns,
    string Match,
    string JoinBasis);

public sealed record SemanticCallsiteEntry(
    int Prototype,
    int Block,
    int Instruction,
    int SourceOccurrence,
    int EffectOrder,
    string Kind,
    string? Name,
    string? NameHash,
    int? CalleeWeb,
    int? ReceiverWeb,
    SemanticReceiverSemantics ReceiverSemantics,
    IReadOnlyList<int?> ArgumentWebs,
    int? ExplicitArgumentCount,
    bool OpenArguments,
    IReadOnlyList<int?> ResultWebs,
    int? ResultCount,
    bool OpenResults,
    SemanticCallsiteContract Contract,
    SemanticSourceSpan ReadableSpan,
    SemanticSourceSpan FidelitySpan)
{
    public string DisplayCall => string.IsNullOrEmpty(Name) ? "<dynamic call>" : Name;
    public string ReceiverDisplay => ReceiverWeb is int web ? $"web {web}" : "—";
    public string ReceiverTypeDisplay => ReceiverSemantics.Type ?? "—";
    public string DescriptorJoin => Contract.JoinBasis;
    public string ArgumentDisplay => ArgumentWebs.Count == 0
        ? (OpenArguments ? "open" : "—")
        : string.Join(", ", ArgumentWebs.Select(web => web is int value ? value.ToString(CultureInfo.InvariantCulture) : "?"))
            + (OpenArguments ? ", …" : string.Empty);
    public string ResultDisplay => ResultWebs.Count == 0
        ? (OpenResults ? "open" : "—")
        : string.Join(", ", ResultWebs.Select(web => web is int value ? value.ToString(CultureInfo.InvariantCulture) : "?"))
            + (OpenResults ? ", …" : string.Empty);
    public string ContractStatus => Contract.Status ?? "UNREGISTERED";
    public string ContractConfidence => Contract.Confidence ?? "—";
}

public sealed class SemanticVerificationDocument
{
    private SemanticVerificationDocument(
        string path,
        string rawJson,
        int tokenCount,
        int aliasOccurrenceCount,
        int canonicalRetainedCount,
        int sidecarOnlyCount,
        int namingRowCount,
        int closureSiteCount,
        int closureCaptureCount,
        int exportCount,
        int fixedCommentCount,
        int schemaVersion,
        int apiCallsiteCount,
        int apiCallExpressionCount,
        int registeredApiCallsiteCount,
        int confirmedApiCallsiteCount,
        int unresolvedApiCallsiteCount,
        int unregisteredApiCallsiteCount,
        int ambiguousApiCallsiteCount,
        int observedContractMismatchCount,
        IReadOnlyDictionary<(int Prototype, int Web), IReadOnlyList<SemanticValueOccurrence>> occurrences,
        IReadOnlyList<SemanticExportEntry> exports,
        IReadOnlyList<SemanticCallsiteEntry> callsites)
    {
        Path = path;
        RawJson = rawJson;
        TokenCount = tokenCount;
        AliasOccurrenceCount = aliasOccurrenceCount;
        CanonicalRetainedCount = canonicalRetainedCount;
        SidecarOnlyCount = sidecarOnlyCount;
        NamingRowCount = namingRowCount;
        ClosureSiteCount = closureSiteCount;
        ClosureCaptureCount = closureCaptureCount;
        ExportCount = exportCount;
        FixedCommentCount = fixedCommentCount;
        SchemaVersion = schemaVersion;
        ApiCallsiteCount = apiCallsiteCount;
        ApiCallExpressionCount = apiCallExpressionCount;
        RegisteredApiCallsiteCount = registeredApiCallsiteCount;
        ConfirmedApiCallsiteCount = confirmedApiCallsiteCount;
        UnresolvedApiCallsiteCount = unresolvedApiCallsiteCount;
        UnregisteredApiCallsiteCount = unregisteredApiCallsiteCount;
        AmbiguousApiCallsiteCount = ambiguousApiCallsiteCount;
        ObservedContractMismatchCount = observedContractMismatchCount;
        Occurrences = occurrences;
        Exports = exports;
        Callsites = callsites;
    }

    public string Path { get; }
    public string RawJson { get; }
    public int TokenCount { get; }
    public int AliasOccurrenceCount { get; }
    public int CanonicalRetainedCount { get; }
    public int SidecarOnlyCount { get; }
    public int NamingRowCount { get; }
    public int ClosureSiteCount { get; }
    public int ClosureCaptureCount { get; }
    public int ExportCount { get; }
    public int FixedCommentCount { get; }
    public int SchemaVersion { get; }
    public int ApiCallsiteCount { get; }
    public int ApiCallExpressionCount { get; }
    public int RegisteredApiCallsiteCount { get; }
    public int ConfirmedApiCallsiteCount { get; }
    public int UnresolvedApiCallsiteCount { get; }
    public int UnregisteredApiCallsiteCount { get; }
    public int AmbiguousApiCallsiteCount { get; }
    public int ObservedContractMismatchCount { get; }
    public IReadOnlyDictionary<(int Prototype, int Web), IReadOnlyList<SemanticValueOccurrence>> Occurrences { get; }
    public IReadOnlyList<SemanticExportEntry> Exports { get; }
    public IReadOnlyList<SemanticCallsiteEntry> Callsites { get; }

    public string Summary =>
        $"VERIFIED PRESENTATION ONLY — tokens={TokenCount}, aliases={AliasOccurrenceCount}, "
        + $"canonical-retained={CanonicalRetainedCount}, sidecar-only={SidecarOnlyCount}, "
        + $"closures={ClosureSiteCount}/{ClosureCaptureCount} captures, exact-exports={ExportCount}, "
        + $"fixed-preamble-comments={FixedCommentCount}, API-calls={ApiCallsiteCount} "
        + $"projected-expressions={ApiCallExpressionCount} "
        + $"(registered={RegisteredApiCallsiteCount}, confirmed={ConfirmedApiCallsiteCount}, "
        + $"unresolved={UnresolvedApiCallsiteCount}, unregistered={UnregisteredApiCallsiteCount}, "
        + $"ambiguous={AmbiguousApiCallsiteCount}, observed-mismatch={ObservedContractMismatchCount}), "
        + "confirmed-contract-violations=0, unauthorized identifiers=0, non-identifier changes=0.";

    public static SemanticVerificationDocument Load(
        string path,
        string readableSourcePath,
        string fidelitySourcePath,
        string namingMapPath,
        string closureMapPath,
        SemanticNamingMap namingMap,
        ClosureOwnershipMap closureMap)
        => Load(
            path,
            readableSourcePath,
            fidelitySourcePath,
            namingMapPath,
            closureMapPath,
            null,
            namingMap,
            closureMap);

    public static SemanticVerificationDocument Load(
        string path,
        string readableSourcePath,
        string fidelitySourcePath,
        string namingMapPath,
        string closureMapPath,
        string? callMapPath,
        SemanticNamingMap namingMap,
        ClosureOwnershipMap closureMap)
    {
        if (!File.Exists(path)) throw new FileNotFoundException("Semantic verification document is missing.", path);
        var rawJson = File.ReadAllText(path);
        using var document = JsonDocument.Parse(rawJson, new JsonDocumentOptions
        {
            AllowTrailingCommas = false,
            CommentHandling = JsonCommentHandling.Disallow,
        });
        var root = RequireObject(document.RootElement, "root");
        var schemaVersion = RequireNonNegativeInt(root, "schema_version");
        if (schemaVersion is not (1 or 2 or 3))
            throw new InvalidDataException($"Semantic proof schema version {schemaVersion} is unsupported.");
        RequireString(root, "format", schemaVersion switch
        {
            1 => "RENOVICE_SEMANTIC_VIEW_V1",
            2 => "RENOVICE_SEMANTIC_VIEW_V2",
            _ => "RENOVICE_SEMANTIC_VIEW_V3",
        });
        RequireString(root, "status", "VERIFIED_PRESENTATION_ONLY");
        RequireString(root, "span_encoding", "UTF8_BYTE_OFFSET_WITH_ONE_BASED_LINE_COLUMN");

        var policy = RequireObjectProperty(root, "policy");
        if (RequireBoolean(policy, "baseline_compiler_mutated"))
            throw new InvalidDataException("Semantic proof claims the baseline compiler was mutated.");
        RequireString(policy, "readable_changes_permitted", "FIXED_PREAMBLE_AND_IDENTIFIER_ALIAS_ONLY");
        RequireString(policy, "identity_authority", "PROTOTYPE_VALUE_WEB");
        RequireString(policy, "unknown_policy", "PRESERVE_CANONICAL_OR_SIDECAR_ONLY");

        var inputs = RequireObjectProperty(root, "inputs");
        ValidateFileIdentity(inputs, "readable_source", readableSourcePath);
        ValidateFileIdentity(inputs, "fidelity_source", fidelitySourcePath);
        ValidateFileIdentity(inputs, "naming_map", namingMapPath);
        ValidateFileIdentity(inputs, "closure_map", closureMapPath);
        if (schemaVersion >= 2)
        {
            if (string.IsNullOrWhiteSpace(callMapPath))
                throw new InvalidDataException("Semantic proof V2 requires its API callsite map.");
            ValidateFileIdentity(inputs, "call_map", callMapPath);
        }

        var verification = RequireObjectProperty(root, "verification");
        if (!RequireBoolean(verification, "token_stream_aligned"))
            throw new InvalidDataException("Semantic proof does not assert aligned token streams.");
        var tokenCount = RequireNonNegativeInt(verification, "token_count");
        if (tokenCount == 0) throw new InvalidDataException("Semantic proof has no aligned tokens.");
        var fixedCommentCount = RequireNonNegativeInt(verification, "authorized_fixed_comment_insertions");
        if (fixedCommentCount is not (0 or 2))
            throw new InvalidDataException("Semantic proof has an unexpected fixed-preamble comment count.");
        var aliasOccurrenceCount = RequireNonNegativeInt(verification, "authorized_identifier_differences");
        RequireInt(verification, "unauthorized_identifier_differences", 0);
        RequireInt(verification, "non_identifier_differences", 0);
        var mappedOccurrenceCount = RequireNonNegativeInt(verification, "mapped_occurrences");
        var canonicalRetainedCount = RequireNonNegativeInt(verification, "canonical_retained_occurrences");
        var sidecarOnlyCount = RequireNonNegativeInt(verification, "sidecar_only_rows");
        var namingRowCount = RequireNonNegativeInt(verification, "naming_rows");
        var closureSiteCount = RequireNonNegativeInt(verification, "closure_sites");
        var closureCaptureCount = RequireNonNegativeInt(verification, "closure_captures");
        var exportCount = RequireNonNegativeInt(verification, "exact_exports");
        var apiCallsiteCount = schemaVersion >= 2
            ? RequireNonNegativeInt(verification, "api_callsites") : 0;
        var apiCallExpressionCount = schemaVersion >= 2
            ? RequireNonNegativeInt(verification, "api_call_expressions") : 0;
        var registeredApiCallsiteCount = schemaVersion >= 2
            ? RequireNonNegativeInt(verification, "registered_api_callsites") : 0;
        var confirmedApiCallsiteCount = schemaVersion >= 2
            ? RequireNonNegativeInt(verification, "confirmed_api_callsites") : 0;
        var unresolvedApiCallsiteCount = schemaVersion >= 2
            ? RequireNonNegativeInt(verification, "unresolved_api_callsites") : 0;
        var unregisteredApiCallsiteCount = schemaVersion >= 2
            ? RequireNonNegativeInt(verification, "unregistered_api_callsites") : 0;
        var ambiguousApiCallsiteCount = schemaVersion >= 2
            ? RequireNonNegativeInt(verification, "ambiguous_api_callsites") : 0;
        var observedContractMismatchCount = schemaVersion >= 2
            ? RequireNonNegativeInt(verification, "observed_contract_mismatches") : 0;
        if (schemaVersion >= 2)
            RequireInt(verification, "confirmed_contract_violations", 0);

        if (mappedOccurrenceCount != aliasOccurrenceCount + canonicalRetainedCount)
            throw new InvalidDataException("Semantic proof mapped-occurrence totals are inconsistent.");
        if (namingRowCount != namingMap.Entries.Count)
            throw new InvalidDataException("Semantic proof naming-row count disagrees with the validated naming map.");
        if (closureSiteCount != closureMap.Entries.Count || closureCaptureCount != closureMap.CaptureCount)
            throw new InvalidDataException("Semantic proof closure totals disagree with the validated closure map.");

        var occurrences = ValidateValues(
            root,
            namingMap,
            tokenCount,
            aliasOccurrenceCount,
            canonicalRetainedCount,
            sidecarOnlyCount);
        ValidateOccurrenceSourceSpans(
            readableSourcePath,
            fidelitySourcePath,
            namingMap,
            occurrences);
        var exports = ValidateExports(root, namingMap, exportCount, occurrences);
        ValidateClosures(root, closureMap);
        var callsites = schemaVersion >= 2
            ? ValidateCallsites(
                root,
                schemaVersion,
                callMapPath!,
                readableSourcePath,
                fidelitySourcePath,
                apiCallsiteCount,
                apiCallExpressionCount,
                registeredApiCallsiteCount,
                confirmedApiCallsiteCount,
                unresolvedApiCallsiteCount,
                unregisteredApiCallsiteCount,
                ambiguousApiCallsiteCount,
                observedContractMismatchCount)
            : Array.Empty<SemanticCallsiteEntry>();

        return new SemanticVerificationDocument(
            path,
            rawJson,
            tokenCount,
            aliasOccurrenceCount,
            canonicalRetainedCount,
            sidecarOnlyCount,
            namingRowCount,
            closureSiteCount,
            closureCaptureCount,
            exportCount,
            fixedCommentCount,
            schemaVersion,
            apiCallsiteCount,
            apiCallExpressionCount,
            registeredApiCallsiteCount,
            confirmedApiCallsiteCount,
            unresolvedApiCallsiteCount,
            unregisteredApiCallsiteCount,
            ambiguousApiCallsiteCount,
            observedContractMismatchCount,
            occurrences,
            exports,
            callsites);
    }

    private static void ValidateFileIdentity(JsonElement inputs, string propertyName, string expectedPath)
    {
        if (!File.Exists(expectedPath))
            throw new FileNotFoundException($"Semantic proof input '{propertyName}' is missing.", expectedPath);
        var identity = RequireObjectProperty(inputs, propertyName);
        RequireString(identity, "file", System.IO.Path.GetFileName(expectedPath));
        var bytes = new FileInfo(expectedPath).Length;
        if (RequireNonNegativeLong(identity, "bytes") != bytes)
            throw new InvalidDataException($"Semantic proof input '{propertyName}' has a stale byte count.");
        var actualHash = Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(expectedPath)));
        RequireString(identity, "sha256", actualHash);
    }

    private static IReadOnlyDictionary<(int Prototype, int Web), IReadOnlyList<SemanticValueOccurrence>> ValidateValues(
        JsonElement root,
        SemanticNamingMap namingMap,
        int tokenCount,
        int expectedAliases,
        int expectedRetained,
        int expectedSidecarOnly)
    {
        var values = RequireArrayProperty(root, "values");
        if (values.GetArrayLength() != namingMap.Entries.Count)
            throw new InvalidDataException("Semantic proof value rows disagree with the naming map.");
        var tokenOwners = new HashSet<int>();
        var aliases = 0;
        var retained = 0;
        var sidecarOnly = 0;
        var allOccurrences = new Dictionary<(int Prototype, int Web), IReadOnlyList<SemanticValueOccurrence>>();
        var index = 0;
        foreach (var value in values.EnumerateArray())
        {
            var entry = namingMap.Entries[index++];
            var item = RequireObject(value, "value row");
            var identity = RequireObjectProperty(item, "identity");
            RequireInt(identity, "prototype", entry.Prototype);
            RequireInt(identity, "web", entry.Web);
            RequireString(identity, "canonical", entry.Canonical);
            RequireString(item, "readable", entry.DisplayName);
            ValidateNullableString(item, "readable_alias", entry.Readable);
            RequireString(item, "alias_status", string.IsNullOrEmpty(entry.Readable)
                ? "UNKNOWN_CANONICAL_PRESERVED"
                : "EVIDENCE_BACKED_ALIAS");
            ValidateNullableString(item, "confidence", entry.Confidence);
            ValidateNullableString(item, "evidence", entry.Evidence);
            ValidateNullableString(item, "semantic_type", entry.SemanticType);
            ValidateNullableString(item, "type_confidence", entry.TypeConfidence);
            ValidateNullableString(item, "type_evidence", entry.TypeEvidence);

            var occurrences = RequireArrayProperty(item, "occurrences");
            var entryOccurrences = new List<SemanticValueOccurrence>();
            var isSidecarOnly = occurrences.GetArrayLength() == 0;
            RequireString(item, "source_state", isSidecarOnly ? "SIDECAR_ONLY" : "SOURCE_MAPPED");
            if (isSidecarOnly) sidecarOnly++;
            foreach (var occurrence in occurrences.EnumerateArray())
            {
                var occurrenceObject = RequireObject(occurrence, "value occurrence");
                var token = RequireNonNegativeInt(occurrenceObject, "token");
                if (token >= tokenCount || !tokenOwners.Add(token))
                    throw new InvalidDataException("Semantic proof has an invalid or multiply-owned token occurrence.");
                var rendering = RequireStringProperty(occurrenceObject, "rendering");
                if (rendering == "ALIAS_APPLIED")
                {
                    if (string.IsNullOrEmpty(entry.Readable))
                        throw new InvalidDataException("Semantic proof applies an alias that has no naming evidence.");
                    aliases++;
                }
                else if (rendering == "CANONICAL_RETAINED")
                {
                    retained++;
                }
                else
                {
                    throw new InvalidDataException($"Semantic proof has unknown rendering '{rendering}'.");
                }
                entryOccurrences.Add(new SemanticValueOccurrence(
                    token,
                    rendering,
                    ReadSpan(occurrenceObject, "fidelity"),
                    ReadSpan(occurrenceObject, "readable")));
            }
            if (!allOccurrences.TryAdd((entry.Prototype, entry.Web), entryOccurrences))
                throw new InvalidDataException("Semantic proof repeats a prototype/value-web occurrence owner.");
        }
        if (aliases != expectedAliases || retained != expectedRetained || sidecarOnly != expectedSidecarOnly)
            throw new InvalidDataException("Semantic proof value-row totals are inconsistent.");
        return allOccurrences;
    }

    private sealed record SpanExpectation(
        SemanticSourceSpan Span,
        string ExpectedToken,
        string Context);

    private static void ValidateOccurrenceSourceSpans(
        string readableSourcePath,
        string fidelitySourcePath,
        SemanticNamingMap namingMap,
        IReadOnlyDictionary<(int Prototype, int Web), IReadOnlyList<SemanticValueOccurrence>> occurrences)
    {
        var readable = new List<SpanExpectation>();
        var fidelity = new List<SpanExpectation>();
        foreach (var entry in namingMap.Entries)
        {
            var identity = (entry.Prototype, entry.Web);
            if (!occurrences.TryGetValue(identity, out var entryOccurrences))
                throw new InvalidDataException(
                    $"Semantic proof has no occurrence owner for prototype={entry.Prototype}, web={entry.Web}.");
            foreach (var occurrence in entryOccurrences)
            {
                var context = $"prototype={entry.Prototype}, web={entry.Web}, token={occurrence.Token}";
                fidelity.Add(new SpanExpectation(occurrence.Fidelity, entry.Canonical, context + ", fidelity"));
                var expectedReadable = occurrence.Rendering == "ALIAS_APPLIED"
                    ? entry.Readable
                    : entry.Canonical;
                readable.Add(new SpanExpectation(occurrence.Readable, expectedReadable, context + ", readable"));
            }
        }

        ValidateSpanSet(fidelitySourcePath, fidelity);
        ValidateSpanSet(readableSourcePath, readable);
    }

    private static void ValidateSpanSet(string sourcePath, IReadOnlyList<SpanExpectation> expectations)
    {
        var bytes = File.ReadAllBytes(sourcePath);
        var utf8 = new UTF8Encoding(encoderShouldEmitUTF8Identifier: false, throwOnInvalidBytes: true);
        var ordered = expectations.OrderBy(item => item.Span.ByteOffset).ToArray();
        var previousOffset = -1;
        var cursor = 0;
        var line = 1;
        var column = 1;

        foreach (var expectation in ordered)
        {
            var span = expectation.Span;
            if (span.ByteOffset < 0 || span.ByteLength <= 0
                || span.ByteOffset > bytes.Length - span.ByteLength)
                throw new InvalidDataException(
                    $"Semantic proof span is outside '{sourcePath}' for {expectation.Context}.");
            if (span.ByteOffset == previousOffset)
                throw new InvalidDataException(
                    $"Semantic proof repeats a source byte offset in '{sourcePath}' for {expectation.Context}.");
            previousOffset = span.ByteOffset;

            while (cursor < span.ByteOffset)
            {
                if (bytes[cursor] == (byte)'\r')
                {
                    cursor++;
                    if (cursor < span.ByteOffset && bytes[cursor] == (byte)'\n') cursor++;
                    line++;
                    column = 1;
                }
                else if (bytes[cursor] == (byte)'\n')
                {
                    cursor++;
                    line++;
                    column = 1;
                }
                else
                {
                    cursor++;
                    column++;
                }
            }

            if (span.Line != line || span.Column != column)
                throw new InvalidDataException(
                    $"Semantic proof line/column disagrees with UTF-8 offset in '{sourcePath}' for {expectation.Context}: "
                    + $"recorded={span.Line}:{span.Column}, actual={line}:{column}.");
            var actual = utf8.GetString(bytes, span.ByteOffset, span.ByteLength);
            if (!string.Equals(actual, expectation.ExpectedToken, StringComparison.Ordinal))
                throw new InvalidDataException(
                    $"Semantic proof span token disagrees with '{sourcePath}' for {expectation.Context}: "
                    + $"expected='{expectation.ExpectedToken}', actual='{actual}'.");
        }
    }

    private static IReadOnlyList<SemanticExportEntry> ValidateExports(
        JsonElement root,
        SemanticNamingMap namingMap,
        int expectedCount,
        IReadOnlyDictionary<(int Prototype, int Web), IReadOnlyList<SemanticValueOccurrence>> occurrences)
    {
        const string exportPrefix = "global store ";
        var expected = namingMap.Entries
            .Where(entry => string.Equals(entry.Confidence, "EXACT_EXPORT", StringComparison.Ordinal)
                && entry.Evidence.StartsWith(exportPrefix, StringComparison.Ordinal))
            .ToArray();
        var exports = RequireArrayProperty(root, "exports");
        if (exports.GetArrayLength() != expectedCount || expected.Length != expectedCount)
            throw new InvalidDataException("Semantic proof exact-export totals are inconsistent.");
        var validated = new List<SemanticExportEntry>();
        var index = 0;
        foreach (var export in exports.EnumerateArray())
        {
            var entry = expected[index++];
            var item = RequireObject(export, "export row");
            RequireString(item, "exported_name", entry.Evidence[exportPrefix.Length..]);
            var identity = RequireObjectProperty(item, "identity");
            RequireInt(identity, "prototype", entry.Prototype);
            RequireInt(identity, "web", entry.Web);
            RequireString(identity, "canonical", entry.Canonical);
            RequireString(item, "readable", entry.Readable);
            RequireString(item, "confidence", entry.Confidence);
            RequireString(item, "evidence", entry.Evidence);
            var sourceOccurrenceCount = RequireNonNegativeInt(item, "source_occurrence_count");
            if (!occurrences.TryGetValue((entry.Prototype, entry.Web), out var identityOccurrences)
                || sourceOccurrenceCount != identityOccurrences.Count)
                throw new InvalidDataException("Semantic proof export occurrence count disagrees with its verified identity spans.");
            validated.Add(new SemanticExportEntry(
                entry.Evidence[exportPrefix.Length..],
                entry.Prototype,
                entry.Web,
                entry.Canonical,
                entry.Readable,
                entry.Confidence,
                entry.Evidence,
                sourceOccurrenceCount));
        }
        return validated;
    }

    private sealed record CallMapRow(
        int Prototype,
        int Block,
        int Instruction,
        int SourceOccurrence,
        int EffectOrder,
        string Kind,
        string? Name,
        string? NameHash,
        int? CalleeWeb,
        int? ReceiverWeb,
        SemanticReceiverSemantics ReceiverSemantics,
        IReadOnlyList<int?> ArgumentWebs,
        int? ExplicitArgumentCount,
        bool OpenArguments,
        IReadOnlyList<int?> ResultWebs,
        int? ResultCount,
        bool OpenResults,
        SemanticCallsiteContract Contract,
        SemanticSourceSpan ReadableSpan,
        SemanticSourceSpan FidelitySpan);

    private static IReadOnlyList<CallMapRow> LoadCallMap(string path, int semanticSchemaVersion)
    {
        const string headerV1 = "schema_version\tprototype\tblock\tinstruction\tsource_occurrence\teffect_order\tkind\tname\tname_hash\tcallee_web\treceiver_web\targument_webs\texplicit_argument_count\topen_arguments\tresult_webs\tresult_count\topen_results\tdescriptor\tcontract_confidence\tcontract_status\tevidence\tparameters\treturns\tcontract_match\treadable_offset\treadable_length\treadable_line\treadable_column\tfidelity_offset\tfidelity_length\tfidelity_line\tfidelity_column";
        const string headerV2 = "schema_version\tprototype\tblock\tinstruction\tsource_occurrence\teffect_order\tkind\tname\tname_hash\tcallee_web\treceiver_web\treceiver_type\treceiver_type_confidence\treceiver_type_evidence\tdescriptor_join\targument_webs\texplicit_argument_count\topen_arguments\tresult_webs\tresult_count\topen_results\tdescriptor\tcontract_confidence\tcontract_status\tevidence\tparameters\treturns\tcontract_match\treadable_offset\treadable_length\treadable_line\treadable_column\tfidelity_offset\tfidelity_length\tfidelity_line\tfidelity_column";
        var extended = semanticSchemaVersion >= 3;
        var header = extended ? headerV2 : headerV1;
        var lines = File.ReadAllText(path).Replace("\r\n", "\n", StringComparison.Ordinal).Replace('\r', '\n').Split('\n');
        if (lines.Length == 0 || !string.Equals(lines[0].TrimStart('\uFEFF'), header, StringComparison.Ordinal))
            throw new InvalidDataException($"API callsite map header does not match schema {(extended ? 2 : 1)}.");
        var rows = new List<CallMapRow>();
        var identities = new HashSet<(int Prototype, int Instruction, int SourceOccurrence)>();
        var nextOccurrences = new Dictionary<(int Prototype, int Instruction), int>();
        var firstOccurrences = new Dictionary<(int Prototype, int Instruction), CallMapRow>();
        for (var lineIndex = 1; lineIndex < lines.Length; lineIndex++)
        {
            if (lines[lineIndex].Length == 0) continue;
            var columns = lines[lineIndex].Split('\t');
            var rowNumber = lineIndex + 1;
            var expectedColumns = extended ? 36 : 32;
            if (columns.Length != expectedColumns)
                throw new InvalidDataException($"API callsite map row {rowNumber} has {columns.Length} columns; expected {expectedColumns}.");
            if (!string.Equals(columns[0], extended ? "2" : "1", StringComparison.Ordinal))
                throw new InvalidDataException($"API callsite map row {rowNumber} has an unsupported schema.");
            int Unsigned(int index, string name)
            {
                if (!int.TryParse(columns[index], NumberStyles.None, CultureInfo.InvariantCulture, out var value) || value < 0)
                    throw new InvalidDataException($"API callsite map row {rowNumber} has an invalid {name}.");
                return value;
            }
            int? OptionalWeb(int index, string name)
            {
                if (!int.TryParse(columns[index], NumberStyles.AllowLeadingSign, CultureInfo.InvariantCulture, out var value)
                    || value < -1)
                    throw new InvalidDataException($"API callsite map row {rowNumber} has an invalid {name}.");
                return value < 0 ? null : value;
            }
            bool Boolean(int index, string name)
            {
                if (columns[index] == "true") return true;
                if (columns[index] == "false") return false;
                throw new InvalidDataException($"API callsite map row {rowNumber} has a non-canonical {name} flag.");
            }
            IReadOnlyList<int?> Webs(int index, string name)
            {
                if (columns[index].Length == 0) return Array.Empty<int?>();
                return columns[index].Split(';').Select((_, itemIndex) =>
                {
                    if (!int.TryParse(columns[index].Split(';')[itemIndex], NumberStyles.AllowLeadingSign, CultureInfo.InvariantCulture, out var value)
                        || value < -1)
                        throw new InvalidDataException($"API callsite map row {rowNumber} has an invalid {name} item.");
                    return value < 0 ? (int?)null : value;
                }).ToArray();
            }

            var kind = columns[6];
            if (kind is not ("method" or "global_function" or "dynamic_function"))
                throw new InvalidDataException($"API callsite map row {rowNumber} has unsupported kind '{kind}'.");
            var extra = extended ? 4 : 0;
            var match = columns[23 + extra];
            if (match is not ("MATCH" or "OPEN_ARGUMENTS" or "UNSPECIFIED" or "UNREGISTERED" or "AMBIGUOUS" or "OBSERVED_MISMATCH" or "CONFIRMED_MISMATCH"))
                throw new InvalidDataException($"API callsite map row {rowNumber} has unsupported contract match '{match}'.");
            if (match == "CONFIRMED_MISMATCH")
                throw new InvalidDataException($"API callsite map row {rowNumber} violates a confirmed API contract.");
            var receiverSemantics = extended
                ? new SemanticReceiverSemantics(
                    NullIfEmpty(columns[11]),
                    NullIfEmpty(columns[12]),
                    NullIfEmpty(columns[13]))
                : new SemanticReceiverSemantics(null, null, null);
            if ((receiverSemantics.Type is null)
                != (receiverSemantics.Confidence is null && receiverSemantics.Evidence is null))
                throw new InvalidDataException($"API callsite map row {rowNumber} has incomplete receiver type provenance.");
            var descriptorJoin = extended
                ? columns[14]
                : match == "AMBIGUOUS" ? "LEGACY_AMBIGUOUS"
                : kind == "global_function" ? "LEGACY_STATIC_NAME"
                : "LEGACY_UNRECORDED";
            if (extended && descriptorJoin is not ("NONE" or "STATIC_NAME" or "UNIQUE_METHOD_NAME"
                or "RECEIVER_TYPE" or "RECEIVER_TYPE_CONFLICT" or "AMBIGUOUS"))
                throw new InvalidDataException($"API callsite map row {rowNumber} has unsupported descriptor join '{descriptorJoin}'.");
            if (extended && descriptorJoin is ("RECEIVER_TYPE" or "RECEIVER_TYPE_CONFLICT")
                && receiverSemantics.Type is null)
                throw new InvalidDataException($"API callsite map row {rowNumber} has a receiver-based join without a receiver type.");
            var descriptor = NullIfEmpty(columns[17 + extra]);
            var contract = new SemanticCallsiteContract(
                descriptor,
                NullIfEmpty(columns[18 + extra]),
                NullIfEmpty(columns[19 + extra]),
                NullIfEmpty(columns[20 + extra]),
                NullIfEmpty(columns[21 + extra]),
                NullIfEmpty(columns[22 + extra]),
                match,
                descriptorJoin);
            if (descriptor is null)
            {
                if (contract.Confidence is not null || contract.Status is not null || contract.Evidence is not null
                    || contract.Parameters is not null || contract.Returns is not null
                    || match is not ("UNREGISTERED" or "AMBIGUOUS"))
                    throw new InvalidDataException($"Descriptor-less API callsite map row {rowNumber} carries unsupported contract claims.");
            }
            else if (contract.Confidence is null || contract.Status is null)
            {
                throw new InvalidDataException($"Registered API callsite map row {rowNumber} lacks confidence/status.");
            }

            var prototype = Unsigned(1, "prototype");
            var instruction = Unsigned(3, "instruction");
            var sourceOccurrence = Unsigned(4, "source occurrence");
            if (!identities.Add((prototype, instruction, sourceOccurrence)))
                throw new InvalidDataException($"API callsite map repeats prototype={prototype}, instruction={instruction}, source_occurrence={sourceOccurrence}.");
            var bytecodeIdentity = (prototype, instruction);
            nextOccurrences.TryGetValue(bytecodeIdentity, out var nextOccurrence);
            if (sourceOccurrence != nextOccurrence)
                throw new InvalidDataException($"API callsite map source occurrences are not contiguous from zero at row {rowNumber}.");
            nextOccurrences[bytecodeIdentity] = nextOccurrence + 1;
            var argumentWebs = Webs(11 + extra, "argument web");
            var explicitArgumentCount = OptionalWeb(12 + extra, "explicit argument count");
            var openArguments = Boolean(13 + extra, "open arguments");
            if (openArguments != (explicitArgumentCount is null)
                || (!openArguments && argumentWebs.Count != explicitArgumentCount))
                throw new InvalidDataException($"API callsite map row {rowNumber} has inconsistent argument width.");
            var resultWebs = Webs(14 + extra, "result web");
            var resultCount = OptionalWeb(15 + extra, "result count");
            var openResults = Boolean(16 + extra, "open results");
            if (openResults != (resultCount is null)
                || (!openResults && resultWebs.Count != resultCount))
                throw new InvalidDataException($"API callsite map row {rowNumber} has inconsistent result width.");
            var readableSpan = new SemanticSourceSpan(Unsigned(24 + extra, "readable offset"), Unsigned(25 + extra, "readable length"), Unsigned(26 + extra, "readable line"), Unsigned(27 + extra, "readable column"));
            var fidelitySpan = new SemanticSourceSpan(Unsigned(28 + extra, "fidelity offset"), Unsigned(29 + extra, "fidelity length"), Unsigned(30 + extra, "fidelity line"), Unsigned(31 + extra, "fidelity column"));
            if (readableSpan.ByteLength == 0 || readableSpan.Line == 0 || readableSpan.Column == 0
                || fidelitySpan.ByteLength == 0 || fidelitySpan.Line == 0 || fidelitySpan.Column == 0)
                throw new InvalidDataException($"API callsite map row {rowNumber} has an empty source span.");
            var row = new CallMapRow(
                prototype,
                Unsigned(2, "block"),
                instruction,
                sourceOccurrence,
                Unsigned(5, "effect order"),
                kind,
                NullIfEmpty(columns[7]),
                NullIfEmpty(columns[8]),
                OptionalWeb(9, "callee web"),
                OptionalWeb(10, "receiver web"),
                receiverSemantics,
                argumentWebs,
                explicitArgumentCount,
                openArguments,
                resultWebs,
                resultCount,
                openResults,
                contract,
                readableSpan,
                fidelitySpan);
            if (firstOccurrences.TryGetValue(bytecodeIdentity, out var first)
                && !SameCallsiteFacts(first, row))
                throw new InvalidDataException($"API callsite map source occurrences disagree on bytecode or contract facts at row {rowNumber}.");
            firstOccurrences.TryAdd(bytecodeIdentity, row);
            rows.Add(row);
        }
        return rows;
    }

    private static bool SameCallsiteFacts(CallMapRow left, CallMapRow right) =>
        left.Prototype == right.Prototype
        && left.Block == right.Block
        && left.Instruction == right.Instruction
        && left.EffectOrder == right.EffectOrder
        && left.Kind == right.Kind
        && left.Name == right.Name
        && left.NameHash == right.NameHash
        && left.CalleeWeb == right.CalleeWeb
        && left.ReceiverWeb == right.ReceiverWeb
        && left.ReceiverSemantics == right.ReceiverSemantics
        && left.ArgumentWebs.SequenceEqual(right.ArgumentWebs)
        && left.ExplicitArgumentCount == right.ExplicitArgumentCount
        && left.OpenArguments == right.OpenArguments
        && left.ResultWebs.SequenceEqual(right.ResultWebs)
        && left.ResultCount == right.ResultCount
        && left.OpenResults == right.OpenResults
        && left.Contract == right.Contract;

    private static IReadOnlyList<SemanticCallsiteEntry> ValidateCallsites(
        JsonElement root,
        int semanticSchemaVersion,
        string callMapPath,
        string readableSourcePath,
        string fidelitySourcePath,
        int expectedCount,
        int expectedExpressions,
        int expectedRegistered,
        int expectedConfirmed,
        int expectedUnresolved,
        int expectedUnregistered,
        int expectedAmbiguous,
        int expectedObservedMismatch)
    {
        var mapRows = LoadCallMap(callMapPath, semanticSchemaVersion);
        var calls = RequireArrayProperty(root, "callsites");
        if (calls.GetArrayLength() != expectedExpressions || mapRows.Count != expectedExpressions)
            throw new InvalidDataException("Semantic proof API call expression count disagrees with its callsite map.");
        var validated = new List<SemanticCallsiteEntry>(expectedExpressions);
        var readableSpans = new List<(SemanticSourceSpan Span, string? Name, string Kind, string Context)>();
        var fidelitySpans = new List<(SemanticSourceSpan Span, string? Name, string Kind, string Context)>();
        var index = 0;
        foreach (var call in calls.EnumerateArray())
        {
            var map = mapRows[index++];
            var item = RequireObject(call, "API callsite row");
            var identity = RequireObjectProperty(item, "identity");
            RequireInt(identity, "prototype", map.Prototype);
            RequireInt(identity, "block", map.Block);
            RequireInt(identity, "instruction", map.Instruction);
            RequireInt(identity, "source_occurrence", map.SourceOccurrence);
            RequireInt(identity, "effect_order", map.EffectOrder);
            RequireString(item, "kind", map.Kind);
            RequireNullableString(item, "name", map.Name);
            RequireNullableString(item, "name_hash", map.NameHash);
            var valueWebs = RequireObjectProperty(item, "value_webs");
            RequireNullableInt(valueWebs, "callee", map.CalleeWeb);
            RequireNullableInt(valueWebs, "receiver", map.ReceiverWeb);
            RequireNullableIntArray(valueWebs, "arguments", map.ArgumentWebs);
            RequireNullableIntArray(valueWebs, "results", map.ResultWebs);
            if (semanticSchemaVersion >= 3)
            {
                var receiverSemantics = RequireObjectProperty(item, "receiver_semantics");
                RequireNullableString(receiverSemantics, "type", map.ReceiverSemantics.Type);
                RequireNullableString(receiverSemantics, "confidence", map.ReceiverSemantics.Confidence);
                RequireNullableString(receiverSemantics, "evidence", map.ReceiverSemantics.Evidence);
            }
            var arity = RequireObjectProperty(item, "arity");
            RequireNullableInt(arity, "explicit_arguments", map.ExplicitArgumentCount);
            RequireBoolean(arity, "open_arguments", map.OpenArguments);
            RequireNullableInt(arity, "results", map.ResultCount);
            RequireBoolean(arity, "open_results", map.OpenResults);
            var contract = RequireObjectProperty(item, "contract");
            RequireNullableString(contract, "descriptor", map.Contract.Descriptor);
            RequireNullableString(contract, "confidence", map.Contract.Confidence);
            RequireNullableString(contract, "status", map.Contract.Status);
            RequireNullableString(contract, "evidence", map.Contract.Evidence);
            RequireNullableString(contract, "parameters", map.Contract.Parameters);
            RequireNullableString(contract, "returns", map.Contract.Returns);
            RequireString(contract, "match", map.Contract.Match);
            if (semanticSchemaVersion >= 3)
                RequireString(contract, "join_basis", map.Contract.JoinBasis);
            var spans = RequireObjectProperty(item, "spans");
            var readableSpan = ReadSpan(spans, "readable");
            var fidelitySpan = ReadSpan(spans, "fidelity");
            if (readableSpan != map.ReadableSpan || fidelitySpan != map.FidelitySpan)
                throw new InvalidDataException("Semantic proof API callsite span disagrees with its exact TSV row.");
            var context = $"prototype={map.Prototype}, instruction={map.Instruction}, source_occurrence={map.SourceOccurrence}";
            readableSpans.Add((readableSpan, map.Name, map.Kind, context + ", readable"));
            fidelitySpans.Add((fidelitySpan, map.Name, map.Kind, context + ", fidelity"));
            validated.Add(new SemanticCallsiteEntry(
                map.Prototype,
                map.Block,
                map.Instruction,
                map.SourceOccurrence,
                map.EffectOrder,
                map.Kind,
                map.Name,
                map.NameHash,
                map.CalleeWeb,
                map.ReceiverWeb,
                map.ReceiverSemantics,
                map.ArgumentWebs,
                map.ExplicitArgumentCount,
                map.OpenArguments,
                map.ResultWebs,
                map.ResultCount,
                map.OpenResults,
                map.Contract,
                readableSpan,
                fidelitySpan));
        }

        var distinct = validated.Where(call => call.SourceOccurrence == 0).ToArray();
        if (distinct.Length != expectedCount)
            throw new InvalidDataException("Semantic proof distinct API callsite count disagrees with its projected expressions.");
        var registered = distinct.Count(call => call.Contract.Descriptor is not null);
        var confirmed = distinct.Count(call => call.Contract.Status == "CONFIRMED");
        var unresolved = distinct.Count(call => call.Contract.Status == "UNRESOLVED");
        var unregistered = distinct.Count(call => call.Contract.Descriptor is null);
        var ambiguous = distinct.Count(call => call.Contract.Match == "AMBIGUOUS");
        var observedMismatch = distinct.Count(call => call.Contract.Match == "OBSERVED_MISMATCH");
        if (registered != expectedRegistered || confirmed != expectedConfirmed
            || unresolved != expectedUnresolved || unregistered != expectedUnregistered
            || ambiguous != expectedAmbiguous || observedMismatch != expectedObservedMismatch
            || registered + unregistered != expectedCount)
            throw new InvalidDataException("Semantic proof API callsite category totals are inconsistent.");
        ValidateCallSpanSet(readableSourcePath, readableSpans);
        ValidateCallSpanSet(fidelitySourcePath, fidelitySpans);
        return validated;
    }

    private static void ValidateCallSpanSet(
        string sourcePath,
        IReadOnlyList<(SemanticSourceSpan Span, string? Name, string Kind, string Context)> entries)
    {
        var bytes = File.ReadAllBytes(sourcePath);
        var utf8 = new UTF8Encoding(false, true);
        var intervals = entries
            .Select(entry => (entry.Span.ByteOffset, End: entry.Span.ByteOffset + entry.Span.ByteLength, entry.Context))
            .OrderBy(interval => interval.ByteOffset)
            .ThenByDescending(interval => interval.End)
            .ToArray();
        var parents = new Stack<(int Start, int End, string Context)>();
        foreach (var interval in intervals)
        {
            while (parents.Count != 0 && interval.ByteOffset >= parents.Peek().End) parents.Pop();
            if (parents.Count != 0 && interval.End > parents.Peek().End)
                throw new InvalidDataException($"Semantic proof API callsite spans cross in '{sourcePath}' between {parents.Peek().Context} and {interval.Context}.");
            parents.Push((interval.ByteOffset, interval.End, interval.Context));
        }

        foreach (var entry in entries)
        {
            var span = entry.Span;
            if (span.ByteOffset < 0 || span.ByteLength <= 0 || span.ByteOffset > bytes.Length - span.ByteLength)
                throw new InvalidDataException($"Semantic proof API callsite span is outside '{sourcePath}' for {entry.Context}.");
            var line = 1;
            var column = 1;
            for (var cursor = 0; cursor < span.ByteOffset; cursor++)
            {
                if (bytes[cursor] == (byte)'\r')
                {
                    if (cursor + 1 < span.ByteOffset && bytes[cursor + 1] == (byte)'\n') cursor++;
                    line++;
                    column = 1;
                }
                else if (bytes[cursor] == (byte)'\n')
                {
                    line++;
                    column = 1;
                }
                else column++;
            }
            if (span.Line != line || span.Column != column)
                throw new InvalidDataException($"Semantic proof API callsite line/column disagrees with its UTF-8 offset in '{sourcePath}' for {entry.Context}.");
            var text = utf8.GetString(bytes, span.ByteOffset, span.ByteLength);
            if (!text.Contains('('))
                throw new InvalidDataException($"Semantic proof API callsite span is not a call expression in '{sourcePath}' for {entry.Context}.");
            if (entry.Kind == "method"
                && (entry.Name is null || !ContainsIdentifier(text, entry.Name)))
                throw new InvalidDataException($"Semantic proof API callsite span lacks its exact name in '{sourcePath}' for {entry.Context}.");
        }
    }

    private static bool ContainsIdentifier(string text, string name)
    {
        static bool Continue(char value) => char.IsAsciiLetterOrDigit(value) || value == '_';
        var start = 0;
        while ((start = text.IndexOf(name, start, StringComparison.Ordinal)) >= 0)
        {
            var end = start + name.Length;
            if ((start == 0 || !Continue(text[start - 1])) && (end == text.Length || !Continue(text[end]))) return true;
            start++;
        }
        return false;
    }

    private static string? NullIfEmpty(string value) => value.Length == 0 ? null : value;

    private static void ValidateClosures(JsonElement root, ClosureOwnershipMap closureMap)
    {
        var closures = RequireArrayProperty(root, "closures");
        if (closures.GetArrayLength() != closureMap.Entries.Count)
            throw new InvalidDataException("Semantic proof closure rows disagree with the closure map.");
        var index = 0;
        foreach (var closure in closures.EnumerateArray())
        {
            var entry = closureMap.Entries[index++];
            var item = RequireObject(closure, "closure row");
            RequireInt(item, "parent_prototype", entry.ParentPrototype);
            RequireInt(item, "instruction", entry.Instruction);
            RequireString(item, "opcode", entry.Operation);
            RequireInt(item, "destination_register", entry.DestinationRegister);
            RequireString(item, "operand_namespace", entry.OperandNamespace);
            RequireInt(item, "operand_index", entry.OperandIndex);
            RequireInt(item, "target_prototype", entry.TargetPrototype);
            RequireInt(item, "target_params", entry.TargetParameters);
            RequireInt(item, "target_upvalues", entry.TargetUpvalues);
            RequireInt(item, "target_maxstack", entry.TargetMaxStack);
            RequireInt(item, "capture_count", entry.CaptureCount);
            RequireString(item, "captures", entry.Captures);
            RequireString(item, "status", entry.Status);
        }
    }

    private static SemanticSourceSpan ReadSpan(JsonElement occurrence, string propertyName)
    {
        var span = RequireObjectProperty(occurrence, propertyName);
        var offset = RequireNonNegativeInt(span, "offset");
        var length = RequireNonNegativeInt(span, "length");
        var line = RequireNonNegativeInt(span, "line");
        var column = RequireNonNegativeInt(span, "column");
        if (length == 0 || line == 0 || column == 0)
            throw new InvalidDataException($"Semantic proof {propertyName} span is empty or invalid.");
        return new SemanticSourceSpan(offset, length, line, column);
    }

    private static JsonElement RequireObject(JsonElement element, string description)
    {
        if (element.ValueKind != JsonValueKind.Object)
            throw new InvalidDataException($"Semantic proof {description} is not an object.");
        return element;
    }

    private static JsonElement RequireObjectProperty(JsonElement parent, string name)
    {
        if (!parent.TryGetProperty(name, out var value) || value.ValueKind != JsonValueKind.Object)
            throw new InvalidDataException($"Semantic proof property '{name}' is missing or not an object.");
        return value;
    }

    private static JsonElement RequireArrayProperty(JsonElement parent, string name)
    {
        if (!parent.TryGetProperty(name, out var value) || value.ValueKind != JsonValueKind.Array)
            throw new InvalidDataException($"Semantic proof property '{name}' is missing or not an array.");
        return value;
    }

    private static string RequireStringProperty(JsonElement parent, string name)
    {
        if (!parent.TryGetProperty(name, out var value) || value.ValueKind != JsonValueKind.String)
            throw new InvalidDataException($"Semantic proof property '{name}' is missing or not a string.");
        return value.GetString()!;
    }

    private static void RequireString(JsonElement parent, string name, string expected)
    {
        var actual = RequireStringProperty(parent, name);
        if (!string.Equals(actual, expected, StringComparison.Ordinal))
            throw new InvalidDataException($"Semantic proof property '{name}' expected '{expected}', found '{actual}'.");
    }

    private static bool RequireBoolean(JsonElement parent, string name)
    {
        if (!parent.TryGetProperty(name, out var value)
            || value.ValueKind is not (JsonValueKind.True or JsonValueKind.False))
            throw new InvalidDataException($"Semantic proof property '{name}' is missing or not Boolean.");
        return value.GetBoolean();
    }

    private static void RequireBoolean(JsonElement parent, string name, bool expected)
    {
        var actual = RequireBoolean(parent, name);
        if (actual != expected)
            throw new InvalidDataException($"Semantic proof property '{name}' expected {expected}, found {actual}.");
    }

    private static void RequireNullableString(JsonElement parent, string name, string? expected)
    {
        if (!parent.TryGetProperty(name, out var value))
            throw new InvalidDataException($"Semantic proof property '{name}' is missing.");
        if (expected is null)
        {
            if (value.ValueKind != JsonValueKind.Null)
                throw new InvalidDataException($"Semantic proof property '{name}' should be null.");
            return;
        }
        if (value.ValueKind != JsonValueKind.String || value.GetString() != expected)
            throw new InvalidDataException($"Semantic proof property '{name}' disagrees with its API callsite map.");
    }

    private static void RequireNullableInt(JsonElement parent, string name, int? expected)
    {
        if (!parent.TryGetProperty(name, out var value))
            throw new InvalidDataException($"Semantic proof property '{name}' is missing.");
        if (expected is null)
        {
            if (value.ValueKind != JsonValueKind.Null)
                throw new InvalidDataException($"Semantic proof property '{name}' should be null.");
            return;
        }
        if (value.ValueKind != JsonValueKind.Number || !value.TryGetInt32(out var actual) || actual != expected)
            throw new InvalidDataException($"Semantic proof property '{name}' disagrees with its API callsite map.");
    }

    private static void RequireNullableIntArray(
        JsonElement parent,
        string name,
        IReadOnlyList<int?> expected)
    {
        var values = RequireArrayProperty(parent, name);
        if (values.GetArrayLength() != expected.Count)
            throw new InvalidDataException($"Semantic proof property '{name}' has the wrong array width.");
        var index = 0;
        foreach (var value in values.EnumerateArray())
        {
            var expectedValue = expected[index++];
            if (expectedValue is null)
            {
                if (value.ValueKind != JsonValueKind.Null)
                    throw new InvalidDataException($"Semantic proof property '{name}' should retain an unknown web as null.");
            }
            else if (value.ValueKind != JsonValueKind.Number || !value.TryGetInt32(out var actual) || actual != expectedValue)
            {
                throw new InvalidDataException($"Semantic proof property '{name}' disagrees with its API callsite map.");
            }
        }
    }

    private static int RequireNonNegativeInt(JsonElement parent, string name)
    {
        if (!parent.TryGetProperty(name, out var value)
            || value.ValueKind != JsonValueKind.Number
            || !value.TryGetInt32(out var actual)
            || actual < 0)
            throw new InvalidDataException($"Semantic proof property '{name}' is missing or not a non-negative integer.");
        return actual;
    }

    private static long RequireNonNegativeLong(JsonElement parent, string name)
    {
        if (!parent.TryGetProperty(name, out var value)
            || value.ValueKind != JsonValueKind.Number
            || !value.TryGetInt64(out var actual)
            || actual < 0)
            throw new InvalidDataException($"Semantic proof property '{name}' is missing or not a non-negative integer.");
        return actual;
    }

    private static void RequireInt(JsonElement parent, string name, int expected)
    {
        var actual = RequireNonNegativeInt(parent, name);
        if (actual != expected)
            throw new InvalidDataException($"Semantic proof property '{name}' expected {expected}, found {actual}.");
    }

    private static void ValidateNullableString(JsonElement parent, string name, string expected)
    {
        if (!parent.TryGetProperty(name, out var value))
            throw new InvalidDataException($"Semantic proof property '{name}' is missing.");
        if (string.IsNullOrEmpty(expected))
        {
            if (value.ValueKind != JsonValueKind.Null)
                throw new InvalidDataException($"Semantic proof property '{name}' should preserve an unknown value as null.");
        }
        else if (value.ValueKind != JsonValueKind.String
            || !string.Equals(value.GetString(), expected, StringComparison.Ordinal))
        {
            throw new InvalidDataException($"Semantic proof property '{name}' disagrees with its validated sidecar.");
        }
    }
}
