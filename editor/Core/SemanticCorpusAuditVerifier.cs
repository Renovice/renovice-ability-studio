using System.Security.Cryptography;
using System.Text.Json;

namespace Renovice.AbilityEditor.Core;

public sealed record SemanticCorpusAuditResult(
    int CorpusFiles,
    int BaselinePassFiles,
    int BaselineFailFiles,
    int SemanticViewAcceptedFiles,
    int SemanticViewRejectedFiles,
    int TotalCorpusVerifiedFiles,
    int TotalCorpusUnverifiedFiles,
    int RetainedArtifacts,
    long TokenCount,
    long AliasOccurrences,
    long MappedOccurrences,
    long NamingRows,
    long ClosureSites,
    long ClosureCaptures,
    long ExactExports,
    int ApiDescriptors,
    long ApiIdentityRows,
    long LiveConfirmedApiRows,
    long StockBytecodeApiRows,
    long CatalogOnlyApiRows,
    long UnresolvedApiRows,
    long ApiCallsites,
    long ApiCallExpressions,
    long RegisteredApiCallsites,
    long ConfirmedApiCallsites,
    long UnresolvedApiCallsites,
    long UnregisteredApiCallsites,
    long AmbiguousApiCallsites,
    long ObservedContractMismatches);

public static class SemanticCorpusAuditVerifier
{
    private static readonly string[] LegacyArtifactSuffixes =
    [
        ".luau",
        ".fidelity.luau",
        ".names.tsv",
        ".closures.tsv",
        ".semantic-view.json",
    ];

    private static readonly string[] CallsiteArtifactSuffixes =
    [
        ".luau",
        ".fidelity.luau",
        ".names.tsv",
        ".calls.tsv",
        ".closures.tsv",
        ".semantic-view.json",
    ];

    public static SemanticCorpusAuditResult Verify(string auditPath)
    {
        var fullAuditPath = Path.GetFullPath(auditPath);
        if (!File.Exists(fullAuditPath))
            throw new FileNotFoundException("Semantic corpus audit report is missing.", fullAuditPath);
        var directory = Path.GetDirectoryName(fullAuditPath)
            ?? throw new InvalidDataException("Semantic corpus audit has no parent directory.");
        var raw = File.ReadAllText(fullAuditPath);
        using var document = JsonDocument.Parse(raw, new JsonDocumentOptions
        {
            AllowTrailingCommas = false,
            CommentHandling = JsonCommentHandling.Disallow,
        });
        var root = RequireObject(document.RootElement, "audit root");
        var summary = RequireObjectProperty(root, "summary");
        var schemaVersion = RequireNonNegativeInt(summary, "schema_version");
        if (schemaVersion == 2)
            RequireString(summary, "format", "RENOVICE_SEMANTIC_VIEW_CORPUS360_COVERAGE_V2");
        else if (schemaVersion == 3)
            RequireString(summary, "format", "RENOVICE_SEMANTIC_VIEW_CORPUS360_COVERAGE_V3");
        else if (schemaVersion == 4)
            RequireString(summary, "format", "RENOVICE_SEMANTIC_VIEW_CORPUS360_COVERAGE_V4");
        else
            throw new InvalidDataException(
                $"Semantic corpus audit schema {schemaVersion} is unsupported; expected 2, 3, or 4.");
        var artifactSuffixes = schemaVersion >= 4 ? CallsiteArtifactSuffixes : LegacyArtifactSuffixes;
        if (!RequireBoolean(summary, "ability_cli_stable") || !RequireBoolean(summary, "derecomp_stable"))
            throw new InvalidDataException("Semantic corpus audit binaries were not stable for the complete run.");
        if (schemaVersion >= 3 && !RequireBoolean(summary, "inventory_stable"))
            throw new InvalidDataException("Semantic corpus audit inventory changed during the complete run.");
        RequireInt(summary, "global_temporary_files", 0);

        var corpusFiles = RequireNonNegativeInt(summary, "corpus_files");
        if (corpusFiles != 360)
            throw new InvalidDataException(
                $"Semantic corpus audit covers {corpusFiles} scripts; the authoritative corpus contains 360.");
        var baselinePassFiles = RequireNonNegativeInt(summary, "baseline_pass_files");
        var baselineFailFiles = RequireNonNegativeInt(summary, "baseline_fail_files");

        var inventoryPath = Path.GetFullPath(RequireStringProperty(summary, "inventory"));
        if (!File.Exists(inventoryPath))
            throw new FileNotFoundException("Semantic corpus audit inventory is missing.", inventoryPath);
        var inventoryHash = RequireStringProperty(summary, "inventory_sha256");
        if (!string.Equals(inventoryHash, Sha256(inventoryPath), StringComparison.Ordinal))
            throw new InvalidDataException("Semantic corpus audit inventory hash is stale.");
        using var inventoryDocument = JsonDocument.Parse(
            File.ReadAllText(inventoryPath),
            new JsonDocumentOptions
            {
                AllowTrailingCommas = false,
                CommentHandling = JsonCommentHandling.Disallow,
            });
        var inventoryRoot = RequireObject(inventoryDocument.RootElement, "inventory root");
        if (schemaVersion >= 3)
        {
            var inventoryMode = RequireStringProperty(summary, "inventory_decompile_mode");
            var manifestMode = RequireStringProperty(inventoryRoot, "decompile_mode");
            if (string.IsNullOrWhiteSpace(inventoryMode)
                || !string.Equals(inventoryMode, manifestMode, StringComparison.Ordinal))
                throw new InvalidDataException(
                    "Semantic corpus audit decompile mode disagrees with the authoritative inventory.");
            var inventoryBinary = RequireSha256(summary, "inventory_binary_sha256");
            var manifestBinary = RequireSha256(inventoryRoot, "binary_sha256");
            var auditBinary = RequireSha256(summary, "derecomp_sha256");
            if (!string.Equals(inventoryBinary, manifestBinary, StringComparison.Ordinal)
                || !string.Equals(inventoryBinary, auditBinary, StringComparison.Ordinal))
                throw new InvalidDataException(
                    "Semantic corpus audit compiler hash disagrees with the authoritative inventory.");
        }
        var inventoryCycle = RequireArrayProperty(inventoryRoot, "cycle2");
        if (inventoryCycle.GetArrayLength() != corpusFiles)
            throw new InvalidDataException(
                $"Semantic corpus inventory contains {inventoryCycle.GetArrayLength()} rows, expected {corpusFiles}.");
        var inventoryRows = new Dictionary<string, (int Index, bool Passed)>(StringComparer.OrdinalIgnoreCase);
        var inventoryPassFiles = 0;
        var inventoryIndex = 0;
        foreach (var inventoryElement in inventoryCycle.EnumerateArray())
        {
            var inventoryRow = RequireObject(inventoryElement, "inventory row");
            var file = RequireStringProperty(inventoryRow, "file");
            var inventoryPassed = RequireBoolean(inventoryRow, "passed");
            if (!string.Equals(file, Path.GetFileName(file), StringComparison.Ordinal)
                || !inventoryRows.TryAdd(file, (inventoryIndex, inventoryPassed)))
                throw new InvalidDataException(
                    $"Semantic corpus inventory has an invalid or repeated file row '{file}'.");
            if (inventoryPassed) inventoryPassFiles++;
            inventoryIndex++;
        }
        if (inventoryPassFiles != baselinePassFiles
            || corpusFiles - inventoryPassFiles != baselineFailFiles)
            throw new InvalidDataException(
                "Semantic corpus audit baseline partition disagrees with the authoritative inventory.");

        var results = RequireArrayProperty(root, "evaluated_results");
        var excludedBaselineFailures = RequireArrayProperty(root, "excluded_baseline_failures");
        if (results.GetArrayLength() != baselinePassFiles
            || excludedBaselineFailures.GetArrayLength() != baselineFailFiles
            || baselinePassFiles + baselineFailFiles != corpusFiles)
            throw new InvalidDataException("Semantic corpus coverage partitions do not match the complete corpus.");

        var rowFiles = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        var corpusIndexes = new HashSet<int>();
        var expectedDirectoryFiles = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            Path.GetFileName(fullAuditPath),
            Path.GetFileNameWithoutExtension(fullAuditPath) + ".tsv",
        };
        var passed = 0;
        var rejected = 0;
        var retainedArtifacts = 0;
        long tokenCount = 0;
        long aliases = 0;
        long mapped = 0;
        long namingRows = 0;
        long closureSites = 0;
        long closureCaptures = 0;
        long exactExports = 0;
        var apiDescriptors = new HashSet<string>(StringComparer.Ordinal);
        long apiIdentityRows = 0;
        long liveConfirmedApiRows = 0;
        long stockBytecodeApiRows = 0;
        long catalogOnlyApiRows = 0;
        long unresolvedApiRows = 0;
        long apiCallsites = 0;
        long apiCallExpressions = 0;
        long registeredApiCallsites = 0;
        long confirmedApiCallsites = 0;
        long unresolvedApiCallsites = 0;
        long unregisteredApiCallsites = 0;
        long ambiguousApiCallsites = 0;
        long observedContractMismatches = 0;

        foreach (var resultElement in results.EnumerateArray())
        {
            var result = RequireObject(resultElement, "audit result");
            var corpusIndex = RequireNonNegativeInt(result, "corpus_index");
            var file = RequireStringProperty(result, "file");
            if (!string.Equals(file, Path.GetFileName(file), StringComparison.Ordinal)
                || corpusIndex >= corpusFiles
                || !rowFiles.Add(file)
                || !corpusIndexes.Add(corpusIndex))
                throw new InvalidDataException($"Semantic corpus audit has an invalid or repeated file row '{file}'.");
            if (!inventoryRows.TryGetValue(file, out var inventoryRow)
                || inventoryRow.Index != corpusIndex
                || !inventoryRow.Passed)
                throw new InvalidDataException(
                    $"Evaluated row '{file}' does not match a baseline-PASS inventory identity.");
            var stem = Path.GetFileNameWithoutExtension(file);
            var pass = RequireBoolean(result, "pass");
            var artifactsComplete = RequireBoolean(result, "artifacts_complete");
            var resultCode = RequireStringProperty(result, "result_code");
            if (pass != artifactsComplete || pass != string.Equals(resultCode, "PASS", StringComparison.Ordinal))
                throw new InvalidDataException($"Semantic corpus audit acceptance fields disagree for '{file}'.");
            if (pass) passed++; else rejected++;

            var artifacts = RequireArrayProperty(result, "artifacts");
            if (artifacts.GetArrayLength() != artifactSuffixes.Length)
                throw new InvalidDataException($"Semantic corpus audit does not contain {artifactSuffixes.Length} artifact rows for '{file}'.");
            var expectedNames = artifactSuffixes.Select(suffix => stem + suffix).ToHashSet(StringComparer.Ordinal);
            var observedNames = new HashSet<string>(StringComparer.Ordinal);
            foreach (var artifactElement in artifacts.EnumerateArray())
            {
                var artifact = RequireObject(artifactElement, "audit artifact");
                var name = RequireStringProperty(artifact, "name");
                if (!expectedNames.Contains(name) || !observedNames.Add(name))
                    throw new InvalidDataException($"Semantic corpus audit has an unexpected artifact '{name}' for '{file}'.");
                var exists = RequireBoolean(artifact, "exists");
                if (exists != pass)
                    throw new InvalidDataException(
                        $"Fail-closed transaction artifact state disagrees with acceptance for '{name}'.");
                var artifactPath = ContainedPath(directory, name);
                if (!exists)
                {
                    if (File.Exists(artifactPath))
                        throw new InvalidDataException($"Rejected transaction retained unreported artifact '{name}'.");
                    continue;
                }

                if (!File.Exists(artifactPath))
                    throw new FileNotFoundException("Accepted transaction artifact is missing.", artifactPath);
                var declaredBytes = RequireNonNegativeLong(artifact, "bytes");
                if (new FileInfo(artifactPath).Length != declaredBytes)
                    throw new InvalidDataException($"Accepted artifact byte count is stale for '{name}'.");
                var declaredHash = RequireStringProperty(artifact, "sha256");
                if (!string.Equals(declaredHash, Sha256(artifactPath), StringComparison.Ordinal))
                    throw new InvalidDataException($"Accepted artifact hash is stale for '{name}'.");
                expectedDirectoryFiles.Add(name);
                retainedArtifacts++;
            }
            if (!observedNames.SetEquals(expectedNames))
                throw new InvalidDataException($"Semantic corpus audit artifact set is incomplete for '{file}'.");
            if (!pass) continue;

            var readablePath = ContainedPath(directory, stem + ".luau");
            var fidelityPath = ContainedPath(directory, stem + ".fidelity.luau");
            var namesPath = ContainedPath(directory, stem + ".names.tsv");
            var callsPath = schemaVersion >= 4
                ? ContainedPath(directory, stem + ".calls.tsv")
                : null;
            var closuresPath = ContainedPath(directory, stem + ".closures.tsv");
            var proofPath = ContainedPath(directory, stem + ".semantic-view.json");
            var namingMap = SemanticNamingMap.Load(namesPath);
            var closureMap = ClosureOwnershipMap.Load(closuresPath);
            var proof = SemanticVerificationDocument.Load(
                proofPath,
                readablePath,
                fidelityPath,
                namesPath,
                closuresPath,
                callsPath,
                namingMap,
                closureMap);
            tokenCount += proof.TokenCount;
            aliases += proof.AliasOccurrenceCount;
            mapped += proof.AliasOccurrenceCount + proof.CanonicalRetainedCount;
            namingRows += proof.NamingRowCount;
            closureSites += proof.ClosureSiteCount;
            closureCaptures += proof.ClosureCaptureCount;
            exactExports += proof.ExportCount;
            var apiIndex = SemanticApiEvidenceIndex.Build(namingMap, proof);
            foreach (var contract in apiIndex.Contracts) apiDescriptors.Add(contract.Descriptor);
            apiIdentityRows += apiIndex.IdentityRows;
            liveConfirmedApiRows += apiIndex.LiveConfirmedRows;
            stockBytecodeApiRows += apiIndex.StockBytecodeRows;
            catalogOnlyApiRows += apiIndex.CatalogOnlyRows;
            unresolvedApiRows += apiIndex.UnresolvedRows;
            apiCallsites += proof.ApiCallsiteCount;
            apiCallExpressions += proof.ApiCallExpressionCount;
            registeredApiCallsites += proof.RegisteredApiCallsiteCount;
            confirmedApiCallsites += proof.ConfirmedApiCallsiteCount;
            unresolvedApiCallsites += proof.UnresolvedApiCallsiteCount;
            unregisteredApiCallsites += proof.UnregisteredApiCallsiteCount;
            ambiguousApiCallsites += proof.AmbiguousApiCallsiteCount;
            observedContractMismatches += proof.ObservedContractMismatchCount;
        }

        foreach (var excludedElement in excludedBaselineFailures.EnumerateArray())
        {
            var excluded = RequireObject(excludedElement, "excluded baseline failure");
            var corpusIndex = RequireNonNegativeInt(excluded, "corpus_index");
            var file = RequireStringProperty(excluded, "file");
            if (!string.Equals(file, Path.GetFileName(file), StringComparison.Ordinal)
                || corpusIndex >= corpusFiles
                || !rowFiles.Add(file)
                || !corpusIndexes.Add(corpusIndex))
                throw new InvalidDataException(
                    $"Semantic corpus audit has an invalid or repeated excluded file row '{file}'.");
            if (!inventoryRows.TryGetValue(file, out var inventoryRow)
                || inventoryRow.Index != corpusIndex
                || inventoryRow.Passed)
                throw new InvalidDataException(
                    $"Excluded row '{file}' does not match a baseline-FAIL inventory identity.");
            RequireString(excluded, "status", "BASELINE_COMPILER_PARITY_REQUIRED");
            if (RequireBoolean(excluded, "bytecode_fixed_at_cycle_1")
                || RequireBoolean(excluded, "source_fixed_at_cycle_1")
                || RequireBoolean(excluded, "structural_fixed_at_cycle_1")
                || RequireBoolean(excluded, "stable_through_requested_cycle"))
                throw new InvalidDataException(
                    $"Excluded baseline file '{file}' unexpectedly claims a fixed-point PASS invariant.");
        }

        var totalVerified = RequireNonNegativeInt(summary, "total_corpus_verified_files");
        var totalUnverified = RequireNonNegativeInt(summary, "total_corpus_unverified_files");
        var reportedVerifiedPercent = RequireNonNegativeDouble(summary, "total_corpus_verified_percent");
        var expectedVerifiedPercent = Math.Round(100.0 * totalVerified / corpusFiles, 6);
        if (Math.Abs(reportedVerifiedPercent - expectedVerifiedPercent) > 0.0000005)
            throw new InvalidDataException(
                $"Semantic corpus audit coverage is {reportedVerifiedPercent}, expected {expectedVerifiedPercent}.");
        if (rowFiles.Count != RequireNonNegativeInt(summary, "unique_corpus_files")
            || rowFiles.Count != corpusFiles
            || corpusIndexes.Count != corpusFiles
            || passed != RequireNonNegativeInt(summary, "semantic_view_accepted_files")
            || rejected != RequireNonNegativeInt(summary, "semantic_view_rejected_files")
            || results.GetArrayLength() != RequireNonNegativeInt(summary, "semantic_view_evaluated_files")
            || totalVerified != passed
            || totalUnverified != baselineFailFiles + rejected
            || totalVerified + totalUnverified != corpusFiles
            || retainedArtifacts != RequireNonNegativeInt(summary, "retained_artifacts")
            || retainedArtifacts != RequireNonNegativeInt(summary, "expected_retained_artifacts"))
            throw new InvalidDataException("Semantic corpus audit aggregate counts are inconsistent.");

        var actualDirectoryFiles = Directory.EnumerateFiles(directory)
            .Select(Path.GetFileName)
            .Where(name => name is not null)
            .Cast<string>()
            .ToHashSet(StringComparer.OrdinalIgnoreCase);
        if (!actualDirectoryFiles.SetEquals(expectedDirectoryFiles))
        {
            var unexpected = actualDirectoryFiles.Except(expectedDirectoryFiles, StringComparer.OrdinalIgnoreCase);
            var missing = expectedDirectoryFiles.Except(actualDirectoryFiles, StringComparer.OrdinalIgnoreCase);
            throw new InvalidDataException(
                "Semantic corpus audit directory contents disagree with the report. "
                + $"Unexpected=[{string.Join(", ", unexpected)}], missing=[{string.Join(", ", missing)}].");
        }

        return new SemanticCorpusAuditResult(
            corpusFiles,
            baselinePassFiles,
            baselineFailFiles,
            passed,
            rejected,
            totalVerified,
            totalUnverified,
            retainedArtifacts,
            tokenCount,
            aliases,
            mapped,
            namingRows,
            closureSites,
            closureCaptures,
            exactExports,
            apiDescriptors.Count,
            apiIdentityRows,
            liveConfirmedApiRows,
            stockBytecodeApiRows,
            catalogOnlyApiRows,
            unresolvedApiRows,
            apiCallsites,
            apiCallExpressions,
            registeredApiCallsites,
            confirmedApiCallsites,
            unresolvedApiCallsites,
            unregisteredApiCallsites,
            ambiguousApiCallsites,
            observedContractMismatches);
    }

    private static string ContainedPath(string directory, string file)
    {
        var combined = Path.GetFullPath(Path.Combine(directory, file));
        if (!string.Equals(Path.GetDirectoryName(combined), directory, StringComparison.OrdinalIgnoreCase))
            throw new InvalidDataException($"Semantic corpus audit artifact escapes its evidence directory: {file}");
        return combined;
    }

    private static string Sha256(string path)
    {
        using var stream = File.OpenRead(path);
        return Convert.ToHexString(SHA256.HashData(stream));
    }

    private static JsonElement RequireObject(JsonElement element, string context)
    {
        if (element.ValueKind != JsonValueKind.Object)
            throw new InvalidDataException($"Semantic corpus audit {context} is not an object.");
        return element;
    }

    private static JsonElement RequireObjectProperty(JsonElement owner, string name)
    {
        if (!owner.TryGetProperty(name, out var value) || value.ValueKind != JsonValueKind.Object)
            throw new InvalidDataException($"Semantic corpus audit is missing object '{name}'.");
        return value;
    }

    private static JsonElement RequireArrayProperty(JsonElement owner, string name)
    {
        if (!owner.TryGetProperty(name, out var value) || value.ValueKind != JsonValueKind.Array)
            throw new InvalidDataException($"Semantic corpus audit is missing array '{name}'.");
        return value;
    }

    private static string RequireStringProperty(JsonElement owner, string name)
    {
        if (!owner.TryGetProperty(name, out var value) || value.ValueKind != JsonValueKind.String)
            throw new InvalidDataException($"Semantic corpus audit is missing string '{name}'.");
        return value.GetString()!;
    }

    private static string RequireSha256(JsonElement owner, string name)
    {
        var value = RequireStringProperty(owner, name);
        if (value.Length != 64 || value.Any(character => !Uri.IsHexDigit(character)))
            throw new InvalidDataException($"Semantic corpus audit has invalid SHA-256 '{name}'.");
        return value.ToUpperInvariant();
    }

    private static void RequireString(JsonElement owner, string name, string expected)
    {
        var actual = RequireStringProperty(owner, name);
        if (!string.Equals(actual, expected, StringComparison.Ordinal))
            throw new InvalidDataException(
                $"Semantic corpus audit '{name}' is '{actual}', expected '{expected}'.");
    }

    private static bool RequireBoolean(JsonElement owner, string name)
    {
        if (!owner.TryGetProperty(name, out var value)
            || value.ValueKind is not (JsonValueKind.True or JsonValueKind.False))
            throw new InvalidDataException($"Semantic corpus audit is missing boolean '{name}'.");
        return value.GetBoolean();
    }

    private static int RequireNonNegativeInt(JsonElement owner, string name)
    {
        if (!owner.TryGetProperty(name, out var value) || !value.TryGetInt32(out var result) || result < 0)
            throw new InvalidDataException($"Semantic corpus audit has invalid integer '{name}'.");
        return result;
    }

    private static long RequireNonNegativeLong(JsonElement owner, string name)
    {
        if (!owner.TryGetProperty(name, out var value) || !value.TryGetInt64(out var result) || result < 0)
            throw new InvalidDataException($"Semantic corpus audit has invalid integer '{name}'.");
        return result;
    }

    private static double RequireNonNegativeDouble(JsonElement owner, string name)
    {
        if (!owner.TryGetProperty(name, out var value)
            || !value.TryGetDouble(out var result)
            || !double.IsFinite(result)
            || result < 0)
            throw new InvalidDataException($"Semantic corpus audit has invalid number '{name}'.");
        return result;
    }

    private static void RequireInt(JsonElement owner, string name, int expected)
    {
        if (RequireNonNegativeInt(owner, name) != expected)
            throw new InvalidDataException($"Semantic corpus audit '{name}' is not {expected}.");
    }
}
