using System.Security.Cryptography;
using System.Text;
using System.Text.Json;

namespace Renovice.AbilityEditor.Core;

public sealed class VerifiedSemanticSource
{
    private VerifiedSemanticSource(
        string readablePath,
        string source,
        SemanticNamingMap namingMap,
        ClosureOwnershipMap closureMap,
        SemanticVerificationDocument verification)
    {
        ReadablePath = readablePath;
        Source = source;
        NamingMap = namingMap;
        ClosureMap = closureMap;
        Verification = verification;
    }

    public string ReadablePath { get; }
    public string Source { get; }
    public SemanticNamingMap NamingMap { get; }
    public ClosureOwnershipMap ClosureMap { get; }
    public SemanticVerificationDocument Verification { get; }
    public string SourceSha256 => StructuralRebaseResult.Hash(Source);

    public static VerifiedSemanticSource Load(string readablePath)
    {
        var fullPath = Path.GetFullPath(readablePath);
        if (!File.Exists(fullPath))
            throw new FileNotFoundException("Verified readable source is missing.", fullPath);
        var fidelity = Companion(fullPath, ".fidelity.luau");
        var names = Companion(fullPath, ".names.tsv");
        var calls = Companion(fullPath, ".calls.tsv");
        var closures = Companion(fullPath, ".closures.tsv");
        var proof = Companion(fullPath, ".semantic-view.json");
        foreach (var required in new[] { fidelity, names, closures, proof })
        {
            if (!File.Exists(required))
                throw new FileNotFoundException("Verified semantic source companion is missing.", required);
        }

        var namingMap = SemanticNamingMap.Load(names);
        var closureMap = ClosureOwnershipMap.Load(closures);
        var verification = SemanticVerificationDocument.Load(
            proof, fullPath, fidelity, names, closures, File.Exists(calls) ? calls : null, namingMap, closureMap);
        return new VerifiedSemanticSource(
            fullPath,
            Normalize(File.ReadAllText(fullPath)),
            namingMap,
            closureMap,
            verification);
    }

    public static void CopyBundle(string sourceReadablePath, string destinationReadablePath)
    {
        _ = Load(sourceReadablePath);
        if (!string.Equals(
                Path.GetFileName(sourceReadablePath),
                Path.GetFileName(destinationReadablePath),
                StringComparison.Ordinal))
            throw new InvalidDataException(
                "A semantic bundle must keep its readable filename because the proof records every companion filename.");
        var destinationDirectory = Path.GetDirectoryName(Path.GetFullPath(destinationReadablePath))
            ?? throw new InvalidDataException("Semantic source destination has no parent directory.");
        Directory.CreateDirectory(destinationDirectory);
        AtomicCopy(sourceReadablePath, destinationReadablePath);
        foreach (var suffix in new[]
                 {
                     ".fidelity.luau", ".names.tsv", ".closures.tsv", ".semantic-view.json",
                 })
            AtomicCopy(Companion(sourceReadablePath, suffix), Companion(destinationReadablePath, suffix));
        var sourceCalls = Companion(sourceReadablePath, ".calls.tsv");
        if (File.Exists(sourceCalls))
            AtomicCopy(sourceCalls, Companion(destinationReadablePath, ".calls.tsv"));
        _ = Load(destinationReadablePath);
    }

    public static string Companion(string readablePath, string suffix)
    {
        var directory = Path.GetDirectoryName(Path.GetFullPath(readablePath))
            ?? throw new InvalidDataException($"Source path has no parent directory: {readablePath}");
        return Path.Combine(directory, Path.GetFileNameWithoutExtension(readablePath) + suffix);
    }

    private static void AtomicCopy(string source, string destination)
    {
        var temporary = destination + ".tmp";
        try
        {
            File.Copy(source, temporary, overwrite: true);
            File.Move(temporary, destination, overwrite: true);
        }
        finally
        {
            if (File.Exists(temporary)) File.Delete(temporary);
        }
    }

    internal static string Normalize(string source) =>
        source.Replace("\r\n", "\n", StringComparison.Ordinal).Replace('\r', '\n');
}

public sealed record StructuralRebaseAnchor(
    string Key,
    int Prototype,
    string Kind,
    int BaseLine,
    int GeneratedLine);

public sealed record StructuralRebaseHunk(
    int Index,
    int BaseStartLine,
    int BaseLineCount,
    int UserStartLine,
    int UserLineCount,
    int? GeneratedStartLine,
    int Prototype,
    string Status,
    string? ConflictCode,
    string? ConflictMessage,
    StructuralRebaseAnchor? LeftAnchor,
    StructuralRebaseAnchor? RightAnchor);

public sealed record StructuralRebaseConflict(
    int Hunk,
    string Code,
    string Message);

public static class StructuralRebaseWorkspace
{
    private const string BindingFormat = "RENOVICE_STRUCTURAL_REBASE_BINDING_V1";

    public static string? FindBaseline(string projectPath, string moduleBodyKey)
    {
        var projectDirectory = ProjectDirectory(projectPath);
        var bindingPath = Path.Combine(projectDirectory, "source", "rebase-binding.json");
        if (!File.Exists(bindingPath)) return null;
        using var document = JsonDocument.Parse(File.ReadAllText(bindingPath), new JsonDocumentOptions
        {
            AllowTrailingCommas = false,
            CommentHandling = JsonCommentHandling.Disallow,
        });
        var root = document.RootElement;
        if (root.GetProperty("schema_version").GetInt32() != 1
            || root.GetProperty("format").GetString() != BindingFormat)
            throw new InvalidDataException($"Unsupported structural rebase binding: {bindingPath}");
        var boundBodyKey = root.GetProperty("module_body_key").GetString();
        if (!string.Equals(boundBodyKey, moduleBodyKey, StringComparison.OrdinalIgnoreCase))
            throw new InvalidDataException(
                $"Structural rebase baseline is bound to body key {boundBodyKey}; project now requests {moduleBodyKey}.");
        var relative = root.GetProperty("baseline_relative_path").GetString();
        if (string.IsNullOrWhiteSpace(relative))
            throw new InvalidDataException("Structural rebase binding has no baseline path.");
        var sourceRoot = Path.GetFullPath(Path.Combine(projectDirectory, "source")) + Path.DirectorySeparatorChar;
        var baseline = Path.GetFullPath(Path.Combine(projectDirectory, relative));
        if (!baseline.StartsWith(sourceRoot, StringComparison.OrdinalIgnoreCase))
            throw new InvalidDataException("Structural rebase baseline escapes the project source directory.");
        var bundle = VerifiedSemanticSource.Load(baseline);
        var expectedHash = root.GetProperty("baseline_sha256").GetString();
        if (!string.Equals(expectedHash, bundle.SourceSha256, StringComparison.OrdinalIgnoreCase))
            throw new InvalidDataException("Structural rebase baseline hash no longer matches its binding.");
        return baseline;
    }

    public static string CaptureBaseline(
        string projectPath,
        string moduleBodyKey,
        string verifiedReadablePath,
        bool promote = false)
    {
        if (!promote && FindBaseline(projectPath, moduleBodyKey) is { } existing) return existing;
        var source = VerifiedSemanticSource.Load(verifiedReadablePath);
        var readableStem = Path.GetFileNameWithoutExtension(source.ReadablePath);
        if (!string.Equals(readableStem, moduleBodyKey, StringComparison.OrdinalIgnoreCase)
            && !readableStem.EndsWith("-" + moduleBodyKey, StringComparison.OrdinalIgnoreCase))
            throw new InvalidDataException(
                $"Verified source filename does not match project body key {moduleBodyKey}: {source.ReadablePath}");
        var projectDirectory = ProjectDirectory(projectPath);
        var baselineDirectory = Path.Combine(
            projectDirectory, "source", "generated-bases", source.SourceSha256[..12]);
        var baseline = Path.Combine(baselineDirectory, Path.GetFileName(source.ReadablePath));
        VerifiedSemanticSource.CopyBundle(source.ReadablePath, baseline);

        var relative = Path.GetRelativePath(projectDirectory, baseline).Replace('\\', '/');
        var binding = JsonSerializer.Serialize(new
        {
            schema_version = 1,
            format = BindingFormat,
            module_body_key = moduleBodyKey,
            baseline_relative_path = relative,
            baseline_sha256 = source.SourceSha256,
            proof_schema_version = source.Verification.SchemaVersion,
            proof_status = "HASH_VALIDATED",
        }, new JsonSerializerOptions { WriteIndented = true }) + "\n";
        AtomicWrite(Path.Combine(projectDirectory, "source", "rebase-binding.json"), binding);
        return baseline;
    }

    public static string CandidatePath(string projectPath, string moduleBodyKey) =>
        Path.Combine(ProjectDirectory(projectPath), "source", "rebase-candidate", moduleBodyKey + ".luau");

    public static string PreviewPath(string projectPath) =>
        Path.Combine(ProjectDirectory(projectPath), "source", "rebased.preview.luau");

    public static string ReportPath(string projectPath) =>
        Path.Combine(ProjectDirectory(projectPath), "source", "rebase-report.json");

    public static void AtomicWrite(string path, string value)
    {
        var directory = Path.GetDirectoryName(Path.GetFullPath(path))
            ?? throw new InvalidDataException("Output path has no parent directory.");
        Directory.CreateDirectory(directory);
        var temporary = path + ".tmp";
        try
        {
            File.WriteAllText(temporary, value, new UTF8Encoding(false));
            File.Move(temporary, path, overwrite: true);
        }
        finally
        {
            if (File.Exists(temporary)) File.Delete(temporary);
        }
    }

    private static string ProjectDirectory(string projectPath) =>
        Path.GetDirectoryName(Path.GetFullPath(projectPath))
        ?? throw new InvalidDataException("Project path has no parent directory.");
}

public sealed class StructuralRebaseResult
{
    internal StructuralRebaseResult(
        string baselineHash,
        string userHash,
        string generatedHash,
        string? mergedSource,
        IReadOnlyList<StructuralRebaseHunk> hunks,
        IReadOnlyList<StructuralRebaseConflict> conflicts,
        int generatorChangeCount)
    {
        BaselineSha256 = baselineHash;
        UserSha256 = userHash;
        GeneratedSha256 = generatedHash;
        MergedSource = mergedSource;
        Hunks = hunks;
        Conflicts = conflicts;
        GeneratorChangeCount = generatorChangeCount;
    }

    public string Status => Conflicts.Count == 0 ? "SAFE_TO_APPLY" : "CONFLICT";
    public bool Success => Conflicts.Count == 0;
    public string BaselineSha256 { get; }
    public string UserSha256 { get; }
    public string GeneratedSha256 { get; }
    public string? MergedSource { get; }
    public IReadOnlyList<StructuralRebaseHunk> Hunks { get; }
    public IReadOnlyList<StructuralRebaseConflict> Conflicts { get; }
    public int GeneratorChangeCount { get; }

    public string ToJson()
    {
        var document = new
        {
            schema_version = 1,
            format = "RENOVICE_STRUCTURAL_SOURCE_REBASE_V1",
            status = Status,
            policy = new
            {
                edit_ownership = "HASH_BOUND_PROTOTYPE_VALUE_WEB_OR_CALLSITE",
                module_structure = "CANONICAL_VALUE_WEBS_CLOSURES_EXPORTS_AND_AVAILABLE_CALLS_MUST_MATCH",
                overlapping_generator_changes = "CONFLICT",
                missing_or_ambiguous_anchors = "CONFLICT",
                output_on_conflict = false,
            },
            hashes = new
            {
                baseline_sha256 = BaselineSha256,
                user_sha256 = UserSha256,
                generated_sha256 = GeneratedSha256,
                merged_sha256 = MergedSource is null ? null : Hash(MergedSource),
            },
            counts = new
            {
                user_hunks = Hunks.Count,
                applied_hunks = Hunks.Count(hunk => hunk.Status == "APPLIED"),
                generator_hunks = GeneratorChangeCount,
                conflicts = Conflicts.Count,
            },
            hunks = Hunks,
            conflicts = Conflicts,
        };
        return JsonSerializer.Serialize(document, new JsonSerializerOptions
        {
            WriteIndented = true,
            PropertyNamingPolicy = JsonNamingPolicy.SnakeCaseLower,
        }) + "\n";
    }

    public void WriteReport(string path)
    {
        var directory = Path.GetDirectoryName(Path.GetFullPath(path))
            ?? throw new InvalidDataException("Rebase report path has no parent directory.");
        Directory.CreateDirectory(directory);
        var temporary = path + ".tmp";
        try
        {
            File.WriteAllText(temporary, ToJson(), new UTF8Encoding(false));
            File.Move(temporary, path, overwrite: true);
        }
        finally
        {
            if (File.Exists(temporary)) File.Delete(temporary);
        }
    }

    internal static string Hash(string source) =>
        Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(source))).ToLowerInvariant();
}

public static class StructuralSourceRebaser
{
    private sealed record LineHunk(int BaseStart, int BaseCount, int VariantStart, int VariantCount);
    private sealed record Evidence(string Key, int Prototype, string Kind, int Line);
    private sealed record PrototypeRange(int Prototype, int FirstLine, int LastLine);

    public static StructuralRebaseResult Rebase(
        VerifiedSemanticSource baseline,
        string userSource,
        VerifiedSemanticSource generated)
    {
        var normalizedUser = VerifiedSemanticSource.Normalize(userSource);
        var baseLines = SplitLines(baseline.Source);
        var userLines = SplitLines(normalizedUser);
        var generatedLines = SplitLines(generated.Source);
        var userChanges = Diff(baseLines, userLines);
        var generatorChanges = Diff(baseLines, generatedLines);
        if (CompatibilityMismatch(baseline, generated) is { } compatibilityError)
        {
            var count = Math.Max(userChanges.Count, 1);
            var compatibilityConflicts = Enumerable.Range(0, count)
                .Select(index => new StructuralRebaseConflict(
                    userChanges.Count == 0 ? -1 : index,
                    "STRUCTURAL_PROOF_MISMATCH",
                    compatibilityError))
                .ToArray();
            var compatibilityHunks = userChanges.Select((change, index) => new StructuralRebaseHunk(
                index,
                change.BaseStart + 1,
                change.BaseCount,
                change.VariantStart + 1,
                change.VariantCount,
                null,
                -1,
                "CONFLICT",
                "STRUCTURAL_PROOF_MISMATCH",
                compatibilityError,
                null,
                null)).ToArray();
            return new StructuralRebaseResult(
                StructuralRebaseResult.Hash(baseline.Source),
                StructuralRebaseResult.Hash(normalizedUser),
                StructuralRebaseResult.Hash(generated.Source),
                null,
                compatibilityHunks,
                compatibilityConflicts,
                generatorChanges.Count);
        }
        var baseEvidence = EvidenceRows(baseline.Verification);
        var generatedEvidence = EvidenceRows(generated.Verification);
        var baseRanges = PrototypeRanges(baseEvidence);
        var generatedRanges = PrototypeRanges(generatedEvidence)
            .ToDictionary(range => range.Prototype);
        var generatedEvidenceByKey = generatedEvidence.ToDictionary(row => row.Key, StringComparer.Ordinal);

        var output = generatedLines.ToList();
        var reports = new List<StructuralRebaseHunk>(userChanges.Count);
        var conflicts = new List<StructuralRebaseConflict>();
        var pending = new List<(LineHunk Hunk, int GeneratedStart, int Prototype,
            StructuralRebaseAnchor? Left, StructuralRebaseAnchor? Right)>();

        for (var index = 0; index < userChanges.Count; index++)
        {
            var change = userChanges[index];
            var baseStartLine = change.BaseStart + 1;
            var owner = FindOwner(change, baseRanges, baseEvidence);
            string? conflictCode = null;
            string? conflictMessage = null;
            int? generatedStart = null;
            StructuralRebaseAnchor? leftReport = null;
            StructuralRebaseAnchor? rightReport = null;

            if (owner is null)
            {
                conflictCode = "NO_STRUCTURAL_OWNER";
                conflictMessage =
                    "The edited region cannot be assigned uniquely to a hash-bound prototype. No automatic rebase was attempted.";
            }
            else if (!generatedRanges.TryGetValue(owner.Value, out var generatedOwner))
            {
                conflictCode = "PROTOTYPE_MISSING";
                conflictMessage = $"Prototype {owner.Value} is absent from the fresh generated proof.";
            }
            else if (generatorChanges.Any(generator => Overlaps(change, generator)))
            {
                conflictCode = "OVERLAPPING_GENERATOR_CHANGE";
                conflictMessage =
                    "The fresh generator changed the same baseline region as the user edit. Manual resolution is required.";
            }
            else
            {
                var mappedStart = MapBoundary(change.BaseStart, generatorChanges);
                var mappedEnd = MapBoundary(change.BaseStart + change.BaseCount, generatorChanges);
                if (mappedStart is null || mappedEnd is null || mappedEnd < mappedStart)
                {
                    conflictCode = "UNMAPPABLE_GENERATED_REGION";
                    conflictMessage = "The edited baseline lines do not map to one unchanged region in the fresh generated source.";
                }
                else
                {
                    generatedStart = mappedStart.Value;
                    var left = baseEvidence
                        .Where(row => row.Prototype == owner.Value && row.Line < change.BaseStart)
                        .OrderByDescending(row => row.Line)
                        .ThenBy(row => row.Key, StringComparer.Ordinal)
                        .FirstOrDefault();
                    var rightBoundary = change.BaseStart + Math.Max(change.BaseCount, 1);
                    var right = baseEvidence
                        .Where(row => row.Prototype == owner.Value && row.Line >= rightBoundary)
                        .OrderBy(row => row.Line)
                        .ThenBy(row => row.Key, StringComparer.Ordinal)
                        .FirstOrDefault();

                    Evidence? generatedLeft = null;
                    Evidence? generatedRight = null;
                    if (left is not null) generatedEvidenceByKey.TryGetValue(left.Key, out generatedLeft);
                    if (right is not null) generatedEvidenceByKey.TryGetValue(right.Key, out generatedRight);
                    if (left is null && right is null)
                    {
                        conflictCode = "NO_BOUNDARY_ANCHORS";
                        conflictMessage = $"Prototype {owner.Value} has no proven structural evidence outside the edited lines.";
                    }
                    else if (left is not null && generatedLeft is null || right is not null && generatedRight is null)
                    {
                        conflictCode = "ANCHOR_MISSING";
                        conflictMessage = $"A structural boundary anchor for prototype {owner.Value} is absent from the fresh proof.";
                    }
                    else if (mappedStart.Value < generatedOwner.FirstLine
                             || Math.Max(mappedStart.Value, mappedEnd.Value - 1) > generatedOwner.LastLine)
                    {
                        conflictCode = "PROTOTYPE_BOUNDARY_MISMATCH";
                        conflictMessage = $"The mapped edit falls outside fresh prototype {owner.Value}'s proven source range.";
                    }
                    else if (generatedLeft is not null && generatedLeft.Line >= mappedStart.Value
                             || generatedRight is not null && generatedRight.Line < mappedEnd.Value)
                    {
                        conflictCode = "ANCHOR_ORDER_MISMATCH";
                        conflictMessage = $"Prototype {owner.Value}'s boundary anchors no longer surround the mapped edit.";
                    }
                    else
                    {
                        var baseSegment = baseLines.Skip(change.BaseStart).Take(change.BaseCount);
                        var generatedSegment = generatedLines.Skip(mappedStart.Value).Take(mappedEnd.Value - mappedStart.Value);
                        if (!baseSegment.SequenceEqual(generatedSegment, StringComparer.Ordinal))
                        {
                            conflictCode = "TARGET_CONTEXT_MISMATCH";
                            conflictMessage = "The mapped generated lines differ from the baseline even though no safe generator hunk explains them.";
                        }
                        else
                        {
                            if (left is not null && generatedLeft is not null)
                                leftReport = Anchor(left, generatedLeft);
                            if (right is not null && generatedRight is not null)
                                rightReport = Anchor(right, generatedRight);
                            pending.Add((change, mappedStart.Value, owner.Value, leftReport, rightReport));
                        }
                    }
                }
            }

            if (conflictCode is not null)
            {
                conflicts.Add(new StructuralRebaseConflict(index, conflictCode, conflictMessage!));
                reports.Add(new StructuralRebaseHunk(
                    index, baseStartLine, change.BaseCount, change.VariantStart + 1, change.VariantCount,
                    generatedStart is null ? null : generatedStart + 1, owner ?? -1, "CONFLICT",
                    conflictCode, conflictMessage, leftReport, rightReport));
            }
            else
            {
                reports.Add(new StructuralRebaseHunk(
                    index, baseStartLine, change.BaseCount, change.VariantStart + 1, change.VariantCount,
                    generatedStart!.Value + 1, owner!.Value, "APPLIED", null, null, leftReport, rightReport));
            }
        }

        if (conflicts.Count == 0)
        {
            foreach (var item in pending.OrderByDescending(item => item.GeneratedStart))
            {
                output.RemoveRange(item.GeneratedStart, item.Hunk.BaseCount);
                output.InsertRange(item.GeneratedStart,
                    userLines.Skip(item.Hunk.VariantStart).Take(item.Hunk.VariantCount));
            }
        }

        return new StructuralRebaseResult(
            StructuralRebaseResult.Hash(baseline.Source),
            StructuralRebaseResult.Hash(normalizedUser),
            StructuralRebaseResult.Hash(generated.Source),
            conflicts.Count == 0 ? string.Join('\n', output) : null,
            reports,
            conflicts,
            generatorChanges.Count);
    }

    private static StructuralRebaseAnchor Anchor(Evidence baseline, Evidence generated) =>
        new(baseline.Key, baseline.Prototype, baseline.Kind, baseline.Line + 1, generated.Line + 1);

    private static string? CompatibilityMismatch(
        VerifiedSemanticSource baseline,
        VerifiedSemanticSource generated)
    {
        static string ValueKey(SemanticNameEntry row) =>
            $"{row.Prototype}\t{row.Web}\t{row.Canonical}";
        var baselineValues = baseline.NamingMap.Entries.Select(ValueKey).Order(StringComparer.Ordinal).ToArray();
        var generatedValues = generated.NamingMap.Entries.Select(ValueKey).Order(StringComparer.Ordinal).ToArray();
        if (baselineValues.Except(generatedValues, StringComparer.Ordinal).Any())
            return "The fresh proof does not preserve every canonical prototype/value-web identity from the baseline.";

        static string ClosureKey(ClosureOwnershipEntry row) => string.Join('\t',
            row.ParentPrototype, row.Instruction, row.Operation, row.DestinationRegister,
            row.OperandNamespace, row.OperandIndex, row.TargetPrototype, row.TargetParameters,
            row.TargetUpvalues, row.TargetMaxStack, row.CaptureCount, row.Captures, row.Status);
        var baselineClosures = baseline.ClosureMap.Entries.Select(ClosureKey).Order(StringComparer.Ordinal).ToArray();
        var generatedClosures = generated.ClosureMap.Entries.Select(ClosureKey).Order(StringComparer.Ordinal).ToArray();
        if (!baselineClosures.SequenceEqual(generatedClosures, StringComparer.Ordinal))
            return "The baseline and fresh proof do not contain the same closure ownership graph.";

        static string ExportKey(SemanticExportEntry row) => string.Join('\t',
            row.ExportedName, row.Prototype, row.Web, row.Canonical);
        var baselineExports = baseline.Verification.Exports.Select(ExportKey).Order(StringComparer.Ordinal).ToArray();
        var generatedExports = generated.Verification.Exports.Select(ExportKey).Order(StringComparer.Ordinal).ToArray();
        if (!baselineExports.SequenceEqual(generatedExports, StringComparer.Ordinal))
            return "The baseline and fresh proof do not contain the same exact module exports.";

        if (baseline.Verification.SchemaVersion >= 2 && generated.Verification.SchemaVersion >= 2)
        {
            static string CallKey(SemanticCallsiteEntry row) => string.Join('\t',
                row.Prototype, row.Block, row.Instruction, row.SourceOccurrence, row.EffectOrder,
                row.Kind, row.Name ?? "", row.NameHash ?? "", row.CalleeWeb?.ToString() ?? "",
                row.ReceiverWeb?.ToString() ?? "", string.Join(',', row.ArgumentWebs),
                row.ExplicitArgumentCount?.ToString() ?? "", row.OpenArguments,
                string.Join(',', row.ResultWebs), row.ResultCount?.ToString() ?? "", row.OpenResults);
            var baselineCalls = baseline.Verification.Callsites.Select(CallKey).Order(StringComparer.Ordinal).ToArray();
            var generatedCalls = generated.Verification.Callsites.Select(CallKey).Order(StringComparer.Ordinal).ToArray();
            if (baselineCalls.Except(generatedCalls, StringComparer.Ordinal).Any())
                return "The fresh proof does not preserve every instruction-addressed callsite from the baseline.";
        }
        return null;
    }

    private static int? FindOwner(
        LineHunk hunk,
        IReadOnlyList<PrototypeRange> ranges,
        IReadOnlyList<Evidence> evidence)
    {
        var first = hunk.BaseStart;
        var last = hunk.BaseStart + Math.Max(hunk.BaseCount, 1) - 1;
        var directlyTouched = evidence
            .Where(row => row.Line >= first && row.Line <= last)
            .Select(row => row.Prototype)
            .Distinct()
            .ToArray();
        if (directlyTouched.Length > 1) return null;
        var containing = ranges
            .Where(range => range.FirstLine <= first && range.LastLine >= last)
            .Where(range => directlyTouched.Length == 0 || range.Prototype == directlyTouched[0])
            .OrderBy(range => range.LastLine - range.FirstLine)
            .ThenBy(range => range.Prototype)
            .ToArray();
        if (containing.Length == 0) return null;
        var smallestWidth = containing[0].LastLine - containing[0].FirstLine;
        var smallest = containing.Where(range => range.LastLine - range.FirstLine == smallestWidth).ToArray();
        if (smallest.Length != 1) return null;
        var owner = smallest[0].Prototype;
        var distance = evidence.Where(row => row.Prototype == owner)
            .Min(row => row.Line < first ? first - row.Line : row.Line > last ? row.Line - last : 0);
        return distance <= 3 ? owner : null;
    }

    private static IReadOnlyList<PrototypeRange> PrototypeRanges(IReadOnlyList<Evidence> evidence) =>
        evidence.GroupBy(row => row.Prototype)
            .Select(group => new PrototypeRange(group.Key, group.Min(row => row.Line), group.Max(row => row.Line)))
            .OrderBy(range => range.Prototype)
            .ToArray();

    private static IReadOnlyList<Evidence> EvidenceRows(SemanticVerificationDocument proof)
    {
        var result = new List<Evidence>();
        foreach (var pair in proof.Occurrences.OrderBy(pair => pair.Key.Prototype).ThenBy(pair => pair.Key.Web))
        {
            var ordinal = 0;
            foreach (var occurrence in pair.Value.OrderBy(row => row.Readable.ByteOffset))
            {
                result.Add(new Evidence(
                    $"VALUE:p{pair.Key.Prototype}:w{pair.Key.Web}:o{ordinal}",
                    pair.Key.Prototype,
                    "VALUE_WEB",
                    occurrence.Readable.Line - 1));
                ordinal++;
            }
        }
        foreach (var call in proof.Callsites)
            result.Add(new Evidence(
                $"CALL:p{call.Prototype}:i{call.Instruction}:o{call.SourceOccurrence}",
                call.Prototype,
                "CALLSITE",
                call.ReadableSpan.Line - 1));
        var duplicates = result.GroupBy(row => row.Key, StringComparer.Ordinal)
            .Where(group => group.Count() != 1)
            .Select(group => group.Key)
            .ToArray();
        if (duplicates.Length != 0)
            throw new InvalidDataException("Semantic proof produces duplicate structural rebase anchors: "
                                           + string.Join(", ", duplicates));
        return result.OrderBy(row => row.Line).ThenBy(row => row.Key, StringComparer.Ordinal).ToArray();
    }

    private static bool Overlaps(LineHunk left, LineHunk right)
    {
        var leftEnd = left.BaseStart + left.BaseCount;
        var rightEnd = right.BaseStart + right.BaseCount;
        if (left.BaseCount == 0 && right.BaseCount == 0)
            return left.BaseStart == right.BaseStart;
        if (left.BaseCount == 0)
            return left.BaseStart > right.BaseStart && left.BaseStart < rightEnd;
        if (right.BaseCount == 0)
            return right.BaseStart > left.BaseStart && right.BaseStart < leftEnd;
        return left.BaseStart < rightEnd && right.BaseStart < leftEnd;
    }

    private static int? MapBoundary(int boundary, IReadOnlyList<LineHunk> generatedChanges)
    {
        var delta = 0;
        foreach (var change in generatedChanges)
        {
            var end = change.BaseStart + change.BaseCount;
            if (change.BaseCount > 0 && boundary > change.BaseStart && boundary < end) return null;
            if (end <= boundary)
                delta += change.VariantCount - change.BaseCount;
        }
        return boundary + delta;
    }

    private static IReadOnlyList<LineHunk> Diff(IReadOnlyList<string> baseline, IReadOnlyList<string> variant)
    {
        var baseCounts = baseline.GroupBy(line => line, StringComparer.Ordinal)
            .ToDictionary(group => group.Key, group => group.Count(), StringComparer.Ordinal);
        var variantCounts = variant.GroupBy(line => line, StringComparer.Ordinal)
            .ToDictionary(group => group.Key, group => group.Count(), StringComparer.Ordinal);
        var variantIndex = new Dictionary<string, int>(StringComparer.Ordinal);
        for (var index = 0; index < variant.Count; index++)
        {
            if (variantCounts[variant[index]] == 1) variantIndex[variant[index]] = index;
        }
        var pairs = new List<(int Base, int Variant)>();
        for (var index = 0; index < baseline.Count; index++)
        {
            var line = baseline[index];
            if (baseCounts[line] == 1 && variantCounts.TryGetValue(line, out var count) && count == 1)
                pairs.Add((index, variantIndex[line]));
        }

        var anchors = LongestIncreasingSubsequence(pairs);
        var withSentinels = new List<(int Base, int Variant)> { (-1, -1) };
        withSentinels.AddRange(anchors);
        withSentinels.Add((baseline.Count, variant.Count));
        var hunks = new List<LineHunk>();
        for (var index = 1; index < withSentinels.Count; index++)
        {
            var previous = withSentinels[index - 1];
            var current = withSentinels[index];
            var baseStart = previous.Base + 1;
            var variantStart = previous.Variant + 1;
            var baseCount = current.Base - baseStart;
            var variantCount = current.Variant - variantStart;
            while (baseCount > 0 && variantCount > 0
                   && baseline[baseStart] == variant[variantStart])
            {
                baseStart++;
                variantStart++;
                baseCount--;
                variantCount--;
            }
            while (baseCount > 0 && variantCount > 0
                   && baseline[baseStart + baseCount - 1] == variant[variantStart + variantCount - 1])
            {
                baseCount--;
                variantCount--;
            }
            if (baseCount != 0 || variantCount != 0)
                hunks.Add(new LineHunk(baseStart, baseCount, variantStart, variantCount));
        }
        return hunks;
    }

    private static IReadOnlyList<(int Base, int Variant)> LongestIncreasingSubsequence(
        IReadOnlyList<(int Base, int Variant)> pairs)
    {
        if (pairs.Count == 0) return [];
        var tails = new List<int>();
        var previous = Enumerable.Repeat(-1, pairs.Count).ToArray();
        for (var index = 0; index < pairs.Count; index++)
        {
            var low = 0;
            var high = tails.Count;
            while (low < high)
            {
                var middle = (low + high) / 2;
                if (pairs[tails[middle]].Variant < pairs[index].Variant) low = middle + 1;
                else high = middle;
            }
            if (low > 0) previous[index] = tails[low - 1];
            if (low == tails.Count) tails.Add(index);
            else tails[low] = index;
        }
        var result = new List<(int Base, int Variant)>(tails.Count);
        for (var cursor = tails[^1]; cursor >= 0; cursor = previous[cursor]) result.Add(pairs[cursor]);
        result.Reverse();
        return result;
    }

    private static string[] SplitLines(string source) => source.Split('\n');
}
