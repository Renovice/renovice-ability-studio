using Renovice.AbilityEditor.Core;
using System.Diagnostics;
using System.Text;
using System.Text.Json.Nodes;

var captureBaselineArgument = Array.FindIndex(args, argument =>
    string.Equals(argument, "--capture-rebase-baseline", StringComparison.Ordinal));
if (captureBaselineArgument >= 0)
{
    if (captureBaselineArgument + 3 >= args.Length)
    {
        Console.WriteLine("ERROR --capture-rebase-baseline requires PROJECT.json BODY_KEY VERIFIED_READABLE.luau");
        return 2;
    }
    try
    {
        var captured = StructuralRebaseWorkspace.CaptureBaseline(
            args[captureBaselineArgument + 1],
            args[captureBaselineArgument + 2],
            args[captureBaselineArgument + 3]);
        Console.WriteLine("PASS captured hash-validated replacement baseline " + captured);
        return 0;
    }
    catch (Exception exception)
    {
        Console.WriteLine("ERROR " + exception);
        return 1;
    }
}

if (args.Contains("--refresh-names", StringComparer.Ordinal))
{
    try
    {
        var paths = WorkspaceLocator.Locate(Environment.CurrentDirectory);
        var cache = InstalledGameData.RefreshEnglishNames(paths);
        Console.WriteLine(cache is null
            ? "ERROR no installed Cache.Windows was found"
            : $"PASS localized names extracted from {cache} to {paths.LocalizedNamesPath}");
        return cache is null ? 1 : 0;
    }
    catch (Exception exception)
    {
        Console.WriteLine("ERROR " + exception);
        return 1;
    }
}

var namingMapArgument = Array.FindIndex(args, argument =>
    string.Equals(argument, "--validate-naming-map", StringComparison.Ordinal));
if (namingMapArgument >= 0)
{
    if (namingMapArgument + 1 >= args.Length)
    {
        Console.WriteLine("ERROR --validate-naming-map requires a .names.tsv path");
        return 2;
    }
    try
    {
        var namingMap = SemanticNamingMap.Load(args[namingMapArgument + 1]);
        Console.WriteLine(
            $"PASS semantic naming map rows={namingMap.Entries.Count} prototypes={namingMap.PrototypeCount} "
            + $"aliases={namingMap.AliasCount} typed={namingMap.TypedWebCount} path={namingMap.Path}");
        return 0;
    }
    catch (Exception exception)
    {
        Console.WriteLine("ERROR " + exception);
        return 1;
    }
}

var closureMapArgument = Array.FindIndex(args, argument =>
    string.Equals(argument, "--validate-closure-map", StringComparison.Ordinal));
if (closureMapArgument >= 0)
{
    if (closureMapArgument + 1 >= args.Length)
    {
        Console.WriteLine("ERROR --validate-closure-map requires a .closures.tsv path");
        return 2;
    }
    try
    {
        var closureMap = ClosureOwnershipMap.Load(args[closureMapArgument + 1]);
        Console.WriteLine(
            $"PASS closure ownership map sites={closureMap.Entries.Count} prototypes={closureMap.PrototypeCount} "
            + $"captures={closureMap.CaptureCount} path={closureMap.Path}");
        return 0;
    }
    catch (Exception exception)
    {
        Console.WriteLine("ERROR " + exception);
        return 1;
    }
}

var corpusAuditArgument = Array.FindIndex(args, argument =>
    string.Equals(argument, "--validate-semantic-corpus", StringComparison.Ordinal));
if (corpusAuditArgument >= 0)
{
    if (corpusAuditArgument + 1 >= args.Length)
    {
        Console.WriteLine("ERROR --validate-semantic-corpus requires a corpus360-coverage-audit.json path");
        return 2;
    }
    try
    {
        var audit = SemanticCorpusAuditVerifier.Verify(args[corpusAuditArgument + 1]);
        Console.WriteLine(
            $"PASS semantic corpus coverage corpus={audit.CorpusFiles} baseline-pass={audit.BaselinePassFiles} "
            + $"baseline-fail={audit.BaselineFailFiles} semantic-accepted={audit.SemanticViewAcceptedFiles} "
            + $"semantic-rejected={audit.SemanticViewRejectedFiles} total-verified={audit.TotalCorpusVerifiedFiles} "
            + $"total-unverified={audit.TotalCorpusUnverifiedFiles} "
            + $"artifacts={audit.RetainedArtifacts} tokens={audit.TokenCount} aliases={audit.AliasOccurrences} "
            + $"mapped={audit.MappedOccurrences} naming={audit.NamingRows} "
            + $"closures={audit.ClosureSites}/{audit.ClosureCaptures} exports={audit.ExactExports} "
            + $"api-descriptors={audit.ApiDescriptors} api-identity-rows={audit.ApiIdentityRows} "
            + $"api-live={audit.LiveConfirmedApiRows} api-stock={audit.StockBytecodeApiRows} "
            + $"api-catalog={audit.CatalogOnlyApiRows} api-unresolved={audit.UnresolvedApiRows} "
            + $"calls={audit.ApiCallsites} call-expressions={audit.ApiCallExpressions} registered-calls={audit.RegisteredApiCallsites} "
            + $"confirmed-calls={audit.ConfirmedApiCallsites} unresolved-calls={audit.UnresolvedApiCallsites} "
            + $"unregistered-calls={audit.UnregisteredApiCallsites} ambiguous-calls={audit.AmbiguousApiCallsites} "
            + $"observed-contract-mismatches={audit.ObservedContractMismatches} confirmed-contract-violations=0");
        return 0;
    }
    catch (Exception exception)
    {
        Console.WriteLine("ERROR " + exception);
        return 1;
    }
}

var sourceRebaseArgument = Array.FindIndex(args, argument =>
    string.Equals(argument, "--rebase-source", StringComparison.Ordinal));
if (sourceRebaseArgument >= 0)
{
    string RequiredOption(string name)
    {
        var index = Array.FindIndex(args, argument => string.Equals(argument, name, StringComparison.Ordinal));
        if (index < 0 || index + 1 >= args.Length)
            throw new InvalidDataException($"--rebase-source requires {name} PATH");
        return args[index + 1];
    }

    try
    {
        var baseline = VerifiedSemanticSource.Load(RequiredOption("--base"));
        var userPath = RequiredOption("--user");
        var generated = VerifiedSemanticSource.Load(RequiredOption("--generated"));
        var outputPath = Path.GetFullPath(RequiredOption("--output"));
        var reportPath = Path.GetFullPath(RequiredOption("--report"));
        var result = StructuralSourceRebaser.Rebase(baseline, File.ReadAllText(userPath), generated);
        result.WriteReport(reportPath);
        if (!result.Success)
        {
            if (File.Exists(outputPath)) File.Delete(outputPath);
            Console.WriteLine(
                $"CONFLICT structural rebase user-hunks={result.Hunks.Count} conflicts={result.Conflicts.Count} "
                + $"generator-hunks={result.GeneratorChangeCount}");
            foreach (var conflict in result.Conflicts)
                Console.WriteLine($"ERROR {conflict.Code} hunk={conflict.Hunk}: {conflict.Message}");
            Console.WriteLine($"Report: {reportPath}");
            return 1;
        }

        StructuralRebaseWorkspace.AtomicWrite(outputPath, result.MergedSource!);
        Console.WriteLine(
            $"PASS structural rebase user-hunks={result.Hunks.Count} conflicts=0 "
            + $"generator-hunks={result.GeneratorChangeCount}");
        Console.WriteLine($"Output: {outputPath}");
        Console.WriteLine($"Report: {reportPath}");
        return 0;
    }
    catch (Exception exception)
    {
        Console.WriteLine("ERROR " + exception);
        return 1;
    }
}

var passed = 0;
var failed = 0;
void Check(bool condition, string name)
{
    if (condition)
    {
        passed++;
        Console.WriteLine($"PASS {name}");
    }
    else
    {
        failed++;
        Console.WriteLine($"FAIL {name}");
    }
}

bool Throws<TException>(Action action) where TException : Exception
{
    try
    {
        action();
        return false;
    }
    catch (TException)
    {
        return true;
    }
}

try
{
    var workspace = WorkspaceLocator.Locate(Environment.CurrentDirectory);
    Check(File.Exists(Path.Combine(workspace.EditorRoot, "WORKSPACE.json")) == false, "workspace distinguishes editor root from workspace root");
    Check(File.Exists(Path.Combine(workspace.WorkspaceRoot, "WORKSPACE.json")), "workspace authority resolves");
    Check(workspace.EditorRoot.EndsWith(Path.Combine("repos", "apps", "ability-editor"), StringComparison.OrdinalIgnoreCase), "ability editor route resolves");
    Check(workspace.CliPath.EndsWith(Path.Combine("bin", "renovice_ability_editor_cli.exe"), StringComparison.OrdinalIgnoreCase), "authoritative CLI route resolves");
    Check(
        VerifiedArtifactExporter.MissionReplacementFileName("1E3647332A578B78", "survival")
        == "1e3647332a578b78 (mission_survival_timers_replacement).lua_B",
        "mission replacement export filename is deterministic and exact-body-keyed");
    Check(Throws<InvalidDataException>(() =>
            VerifiedArtifactExporter.MissionReplacementFileName("not-a-body-key", "survival")),
        "mission replacement export filename rejects a non-body-key target");
    Check(
        VerifiedArtifactExporter.MissionTargetAddonFileName("1E3647332A578B78", "survival")
        == "1e3647332a578b78.SurvivalTimers.target.addon.lua_B",
        "mission target-addon export filename is deterministic and exact-body-keyed");
    Check(Throws<InvalidDataException>(() =>
            VerifiedArtifactExporter.MissionTargetAddonFileName("not-a-body-key", "survival")),
        "mission target-addon export filename rejects a non-body-key target");

    var exportTestRoot = Path.Combine(Path.GetTempPath(), "renovice-artifact-export-" + Guid.NewGuid().ToString("N"));
    Directory.CreateDirectory(exportTestRoot);
    try
    {
        var generation = Path.Combine(exportTestRoot, "generation");
        var artifactDirectory = Path.Combine(generation, "artifacts");
        Directory.CreateDirectory(artifactDirectory);
        var artifactPath = Path.Combine(artifactDirectory, "sample.lua_B");
        var artifactBytes = Encoding.UTF8.GetBytes("verified-de-bytecode-fixture");
        File.WriteAllBytes(artifactPath, artifactBytes);
        var artifactHash = Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(artifactBytes));
        var manifestPath = Path.Combine(generation, "BUILD_MANIFEST.json");
        File.WriteAllText(manifestPath, $$"""
        {
          "format": "RENOVICE_ABILITY_EDITOR_BUILD_V1",
          "status": "STAGED_PASS",
          "live_write_performed": false,
          "gates": [{"name":"recompile","pass":true,"exit_code":0}],
          "artifact": {"path":"artifacts/sample.lua_B","sha256":"{{artifactHash}}","size":{{artifactBytes.Length}}}
        }
        """);
        var destination = Path.Combine(exportTestRoot, "chosen", "replacement.lua_B");
        var firstExport = VerifiedArtifactExporter.Export(
            manifestPath, destination, Path.Combine(exportTestRoot, "rollbacks"));
        Check(File.ReadAllBytes(destination).SequenceEqual(artifactBytes)
              && firstExport.ArtifactSha256 == artifactHash
              && firstExport.RollbackPath is null,
            "verified artifact exporter writes the dialog-selected .lua_B after manifest, gate, size, and hash checks");
        File.WriteAllText(destination, "previous-user-file");
        var secondExport = VerifiedArtifactExporter.Export(
            manifestPath, destination, Path.Combine(exportTestRoot, "rollbacks"));
        Check(secondExport.RollbackPath is not null
              && File.ReadAllText(secondExport.RollbackPath) == "previous-user-file"
              && File.ReadAllBytes(destination).SequenceEqual(artifactBytes),
            "verified artifact exporter preserves an overwritten destination outside CustomScripts");
        var luaManifest = File.ReadAllText(manifestPath);
        Check(Throws<InvalidDataException>(() => VerifiedArtifactExporter.Export(manifestPath,
            Path.Combine(exportTestRoot, "wrong.txt"), Path.Combine(exportTestRoot, "rollbacks"))),
            "Lua manifests cannot be exported as metadata patches");
        var metadataManifest = JsonNode.Parse(luaManifest)!.AsObject();
        metadataManifest["package_type"] = "METADATA_PATCH";
        File.WriteAllText(manifestPath, metadataManifest.ToJsonString());
        var metadataExport = VerifiedArtifactExporter.Export(manifestPath,
            Path.Combine(exportTestRoot, "mission.txt"), Path.Combine(exportTestRoot, "rollbacks"));
        Check(File.ReadAllBytes(metadataExport.DestinationPath).SequenceEqual(artifactBytes), "metadata exports retain artifact integrity checks");
        Check(Throws<InvalidDataException>(() => VerifiedArtifactExporter.Export(manifestPath,
            Path.Combine(exportTestRoot, "wrong.lua_B"), Path.Combine(exportTestRoot, "rollbacks"))),
            "metadata manifests cannot masquerade as Lua bytecode");
        File.WriteAllText(manifestPath, luaManifest);
        var failedManifest = File.ReadAllText(manifestPath).Replace(
            "\"pass\":true", "\"pass\":false", StringComparison.Ordinal);
        File.WriteAllText(manifestPath, failedManifest);
        Check(Throws<InvalidDataException>(() => VerifiedArtifactExporter.Export(
                manifestPath, Path.Combine(exportTestRoot, "blocked.lua_B"), Path.Combine(exportTestRoot, "rollbacks"))),
            "verified artifact exporter rejects a failed build gate and emits no destination");
    }
    finally
    {
        Directory.Delete(exportTestRoot, recursive: true);
    }

    var namingMapDirectory = Path.Combine(Path.GetTempPath(), "renovice-semantic-map-" + Guid.NewGuid().ToString("N"));
    Directory.CreateDirectory(namingMapDirectory);
    try
    {
        const string namingHeader = "prototype\tweb\tcanonical\treadable\tconfidence\tevidence\tsemantic_type\ttype_confidence\ttype_evidence\n";
        var namingMapPath = Path.Combine(namingMapDirectory, "sample.names.tsv");
        File.WriteAllText(namingMapPath, namingHeader
            + "1\t4\tv1_4\tdamageControl\tAPI_CONTRACT\tWF-LIVE-MALLET\tDamageControl\tAPI_CONTRACT\tWF-LIVE-MALLET\n"
            + "2\t7\tv2_7\t\t\t\tboolean\tSTRUCTURAL\ttruthiness use\n");
        var namingMap = SemanticNamingMap.Load(namingMapPath);
        Check(namingMap.Entries.Count == 2 && namingMap.PrototypeCount == 2,
            "semantic naming map preserves prototype/value-web rows");
        Check(namingMap.AliasCount == 1 && namingMap.TypedWebCount == 2,
            "semantic naming map distinguishes aliases from typed-only identities");
        Check(namingMap.Entries[1].DisplayName == "v2_7",
            "semantic naming map falls back to canonical identity without inventing an alias");
        Check(namingMap.Entries[0].SearchText.Contains("WF-LIVE-MALLET", StringComparison.Ordinal),
            "semantic naming map exposes API evidence for editor filtering");

        var duplicateMapPath = Path.Combine(namingMapDirectory, "duplicate.names.tsv");
        File.WriteAllText(duplicateMapPath, namingHeader
            + "1\t4\tv1_4\tdamageControl\tAPI_CONTRACT\tevidence\tDamageControl\tAPI_CONTRACT\tevidence\n"
            + "1\t4\tv1_4\tdamageControl2\tSTRUCTURAL\tevidence\t\t\t\n");
        Check(Throws<InvalidDataException>(() => SemanticNamingMap.Load(duplicateMapPath)),
            "semantic naming map rejects duplicate IR identities");

        const string closureHeader = "parent_proto\tinstruction\top\tdestination_register\toperand_namespace\toperand_index\t"
            + "target_proto\ttarget_params\ttarget_upvalues\ttarget_maxstack\tcapture_count\tcaptures\tstatus\n";
        var closureMapPath = Path.Combine(namingMapDirectory, "sample.closures.tsv");
        File.WriteAllText(closureMapPath, closureHeader
            + "21\t43\tNEWCLOSURE\t13\tchild\t0\t0\t1\t2\t4\t2\t0=VAL:R0;1=REF:R4\tPASS\n"
            + "21\t69\tDUPCLOSURE\t17\tconst\t19\t6\t1\t0\t11\t0\t\tPASS\n");
        var closureMap = ClosureOwnershipMap.Load(closureMapPath);
        Check(closureMap.Entries.Count == 2 && closureMap.PrototypeCount == 3,
            "closure ownership map preserves parent and target prototype identities");
        Check(closureMap.CaptureCount == 2 && closureMap.Entries[0].Captures == "0=VAL:R0;1=REF:R4",
            "closure ownership map preserves ordered capture contracts");

        var invalidCapturePath = Path.Combine(namingMapDirectory, "invalid-capture.closures.tsv");
        File.WriteAllText(invalidCapturePath, closureHeader
            + "21\t43\tNEWCLOSURE\t13\tchild\t0\t0\t1\t2\t4\t2\t0=VAL:R0\tPASS\n");
        Check(Throws<InvalidDataException>(() => ClosureOwnershipMap.Load(invalidCapturePath)),
            "closure ownership map rejects incomplete capture contracts");
    }
    finally
    {
        Directory.Delete(namingMapDirectory, recursive: true);
    }

    var semanticEvidenceRoot = Path.Combine(
        workspace.EditorRoot,
        "RESEARCH",
        "SEMANTIC_SOURCE_WORKSPACE_2026-09-04",
        "GENERATED");
    var verifiedReadable = Path.Combine(semanticEvidenceRoot, "mallet.readable.luau");
    var verifiedFidelity = Path.Combine(semanticEvidenceRoot, "mallet.readable.fidelity.luau");
    var verifiedNames = Path.Combine(semanticEvidenceRoot, "mallet.readable.names.tsv");
    var verifiedClosures = Path.Combine(semanticEvidenceRoot, "mallet.readable.closures.tsv");
    var verifiedDocument = Path.Combine(semanticEvidenceRoot, "mallet.readable.semantic-view.json");
    Check(
        new[] { verifiedReadable, verifiedFidelity, verifiedNames, verifiedClosures, verifiedDocument }.All(File.Exists),
        "stock Mallet five-artifact semantic proof fixture is present");
    if (new[] { verifiedReadable, verifiedFidelity, verifiedNames, verifiedClosures, verifiedDocument }.All(File.Exists))
    {
        var verifiedNamingMap = SemanticNamingMap.Load(verifiedNames);
        var verifiedClosureMap = ClosureOwnershipMap.Load(verifiedClosures);
        var semanticVerification = SemanticVerificationDocument.Load(
            verifiedDocument,
            verifiedReadable,
            verifiedFidelity,
            verifiedNames,
            verifiedClosures,
            verifiedNamingMap,
            verifiedClosureMap);
        Check(
            semanticVerification.TokenCount > 15000
                && semanticVerification.AliasOccurrenceCount > 500
                && semanticVerification.ClosureSiteCount == verifiedClosureMap.Entries.Count,
            "stock Mallet semantic proof is hash-bound and cross-validates every sidecar family");
        var readableBytes = File.ReadAllBytes(verifiedReadable);
        var fidelityBytes = File.ReadAllBytes(verifiedFidelity);
        var exactSpans = verifiedNamingMap.Entries.All(entry =>
            semanticVerification.Occurrences[(entry.Prototype, entry.Web)].All(occurrence =>
            {
                var fidelityToken = Encoding.UTF8.GetString(
                    fidelityBytes,
                    occurrence.Fidelity.ByteOffset,
                    occurrence.Fidelity.ByteLength);
                var readableToken = Encoding.UTF8.GetString(
                    readableBytes,
                    occurrence.Readable.ByteOffset,
                    occurrence.Readable.ByteLength);
                var expectedReadable = occurrence.Rendering == "ALIAS_APPLIED"
                    ? entry.Readable
                    : entry.Canonical;
                return fidelityToken == entry.Canonical && readableToken == expectedReadable;
            }));
        Check(exactSpans, "every Mallet navigation span resolves to its exact canonical/readable identifier bytes");
        var prototypeGraph = SemanticPrototypeGraph.Build(
            verifiedNamingMap,
            verifiedClosureMap,
            semanticVerification);
        Check(
            prototypeGraph.Relations.Count == semanticVerification.ExportCount + verifiedClosureMap.Entries.Count
                && prototypeGraph.Nodes.Select(node => node.Prototype).Distinct().Count() == prototypeGraph.Nodes.Count,
            "verified prototype outline joins exact exports and closure ownership without duplicate nodes");
        Check(
            prototypeGraph.Relations.All(relation =>
                relation.Kind is "EXACT_EXPORT" or "CLOSURE_OWNERSHIP"),
            "verified prototype outline does not invent native call edges");
        Check(
            prototypeGraph.Nodes.Any(node => node.ExactExports.Contains("ActivateAbility", StringComparison.Ordinal))
                && prototypeGraph.Nodes.Any(node => node.IncomingClosures != 0),
            "verified prototype outline exposes exported and closure-target roles");
        var apiEvidenceIndex = SemanticApiEvidenceIndex.Build(verifiedNamingMap, semanticVerification);
        Check(
            apiEvidenceIndex.Contracts.Count != 0
                && apiEvidenceIndex.IdentityRows == verifiedNamingMap.Entries.Count(entry =>
                    entry.Evidence.StartsWith("semantic-sdk:lua:", StringComparison.Ordinal)),
            "verified API index parses every Semantic SDK identity descriptor");
        Check(
            apiEvidenceIndex.LiveConfirmedRows != 0
                && apiEvidenceIndex.Contracts.All(contract =>
                    contract.IdentityRows == contract.LiveConfirmedRows
                        + contract.StockBytecodeRows
                        + contract.CatalogOnlyRows
                        + contract.UnresolvedRows),
            "verified API index preserves live, stock, catalog-only, and unresolved evidence boundaries");

        var proofAttackDirectory = Path.Combine(
            Path.GetTempPath(),
            "renovice-semantic-proof-attack-" + Guid.NewGuid().ToString("N"));
        Directory.CreateDirectory(proofAttackDirectory);
        try
        {
            string CopyFixture(string source)
            {
                var destination = Path.Combine(proofAttackDirectory, Path.GetFileName(source));
                File.Copy(source, destination);
                return destination;
            }
            var attackReadable = CopyFixture(verifiedReadable);
            var attackFidelity = CopyFixture(verifiedFidelity);
            var attackNames = CopyFixture(verifiedNames);
            var attackClosures = CopyFixture(verifiedClosures);
            var attackDocument = CopyFixture(verifiedDocument);
            var attackNamingMap = SemanticNamingMap.Load(attackNames);
            var attackClosureMap = ClosureOwnershipMap.Load(attackClosures);
            _ = SemanticVerificationDocument.Load(
                attackDocument,
                attackReadable,
                attackFidelity,
                attackNames,
                attackClosures,
                attackNamingMap,
                attackClosureMap);

            File.AppendAllText(attackReadable, "\n");
            Check(
                Throws<InvalidDataException>(() => SemanticVerificationDocument.Load(
                    attackDocument,
                    attackReadable,
                    attackFidelity,
                    attackNames,
                    attackClosures,
                    attackNamingMap,
                    attackClosureMap)),
                "semantic proof rejects a stale readable-source hash");
            File.Copy(verifiedReadable, attackReadable, overwrite: true);

            var falsifiedDocument = File.ReadAllText(verifiedDocument).Replace(
                "\"unauthorized_identifier_differences\": 0",
                "\"unauthorized_identifier_differences\": 1",
                StringComparison.Ordinal);
            File.WriteAllText(attackDocument, falsifiedDocument);
            Check(
                Throws<InvalidDataException>(() => SemanticVerificationDocument.Load(
                    attackDocument,
                    attackReadable,
                    attackFidelity,
                    attackNames,
                    attackClosures,
                    attackNamingMap,
                    attackClosureMap)),
                "semantic proof rejects a falsified unauthorized-difference count");

            var falsifiedSpanRoot = JsonNode.Parse(File.ReadAllText(verifiedDocument))!.AsObject();
            var falsifiedValues = falsifiedSpanRoot["values"]!.AsArray();
            var sourceMapped = falsifiedValues
                .Select(value => value!.AsObject())
                .First(value => value["occurrences"]!.AsArray().Count != 0);
            var firstOccurrence = sourceMapped["occurrences"]!.AsArray()[0]!.AsObject();
            var readableSpan = firstOccurrence["readable"]!.AsObject();
            readableSpan["offset"] = readableSpan["offset"]!.GetValue<int>() + 1;
            File.WriteAllText(attackDocument, falsifiedSpanRoot.ToJsonString());
            Check(
                Throws<InvalidDataException>(() => SemanticVerificationDocument.Load(
                    attackDocument,
                    attackReadable,
                    attackFidelity,
                    attackNames,
                    attackClosures,
                    attackNamingMap,
                    attackClosureMap)),
                "semantic proof rejects a falsified navigation span");
        }
        finally
        {
            Directory.Delete(proofAttackDirectory, recursive: true);
        }
    }

    var callsiteEvidenceRoot = Path.Combine(
        workspace.EditorRoot,
        "RESEARCH",
        "API_CALLSITE_INTEGRATION_2026-09-06",
        "GENERATED");
    var callsiteReadable = Path.Combine(callsiteEvidenceRoot, "Anchor.luau");
    var callsiteFidelity = Path.Combine(callsiteEvidenceRoot, "Anchor.fidelity.luau");
    var callsiteNames = Path.Combine(callsiteEvidenceRoot, "Anchor.names.tsv");
    var callsiteCalls = Path.Combine(callsiteEvidenceRoot, "Anchor.calls.tsv");
    var callsiteClosures = Path.Combine(callsiteEvidenceRoot, "Anchor.closures.tsv");
    var callsiteProof = Path.Combine(callsiteEvidenceRoot, "Anchor.semantic-view.json");
    var callsiteArtifacts = new[]
    {
        callsiteReadable, callsiteFidelity, callsiteNames,
        callsiteCalls, callsiteClosures, callsiteProof,
    };
    Check(callsiteArtifacts.All(File.Exists),
        "Anchor six-artifact API callsite proof fixture is present");
    if (callsiteArtifacts.All(File.Exists))
    {
        var callsiteNamingMap = SemanticNamingMap.Load(callsiteNames);
        var callsiteClosureMap = ClosureOwnershipMap.Load(callsiteClosures);
        var callsiteDocument = SemanticVerificationDocument.Load(
            callsiteProof,
            callsiteReadable,
            callsiteFidelity,
            callsiteNames,
            callsiteClosures,
            callsiteCalls,
            callsiteNamingMap,
            callsiteClosureMap);
        Check(
            callsiteDocument.SchemaVersion == 3
                && callsiteDocument.ApiCallsiteCount == 54
                && callsiteDocument.ApiCallExpressionCount == 54
                && callsiteDocument.Callsites.Count == 54
                && callsiteDocument.RegisteredApiCallsiteCount == 4
                && callsiteDocument.ConfirmedApiCallsiteCount == 4
                && callsiteDocument.UnregisteredApiCallsiteCount == 50
                && callsiteDocument.AmbiguousApiCallsiteCount == 0
                && callsiteDocument.ObservedContractMismatchCount == 0,
            "managed verifier cross-validates every exact Anchor API callsite and evidence category");
        var callsiteReadableBytes = File.ReadAllBytes(callsiteReadable);
        Check(
            callsiteDocument.Callsites.Where(call => call.Kind == "method").All(call =>
                Encoding.UTF8.GetString(
                    callsiteReadableBytes,
                    call.ReadableSpan.ByteOffset,
                    call.ReadableSpan.ByteLength).Contains(call.Name!, StringComparison.Ordinal)),
            "every method callsite readable span contains its exact bytecode method name");
        var confirmedCall = callsiteDocument.Callsites.First(call => call.Contract.Status == "CONFIRMED");
        var confirmedPresentation = SemanticCallsitePresenter.Build(confirmedCall);
        Check(
            confirmedPresentation.MarkerKind == SemanticCallsiteMarkerKind.Information
                && confirmedPresentation.WarningCode is null
                && confirmedPresentation.Tooltip.Contains("Exact identity:", StringComparison.Ordinal)
                && confirmedPresentation.Tooltip.Contains(confirmedCall.Contract.Descriptor!, StringComparison.Ordinal),
            "confirmed callsite presentation remains informational and preserves exact evidence");
        var unregisteredCall = callsiteDocument.Callsites.First(call => call.Contract.Descriptor is null);
        var unregisteredPresentation = SemanticCallsitePresenter.Build(unregisteredCall);
        Check(
            unregisteredPresentation.MarkerKind == SemanticCallsiteMarkerKind.Information
                && unregisteredPresentation.WarningCode is null
                && unregisteredPresentation.Tooltip.Contains("No SDK contract is registered", StringComparison.Ordinal),
            "unregistered callsite is evidence absence rather than a false warning");
        var mismatchPresentation = SemanticCallsitePresenter.Build(confirmedCall with
        {
            Contract = confirmedCall.Contract with { Match = "OBSERVED_MISMATCH" },
        });
        Check(
            mismatchPresentation.MarkerKind == SemanticCallsiteMarkerKind.ObservedMismatch
                && mismatchPresentation.WarningCode == "OBSERVED CONTRACT MISMATCH"
                && mismatchPresentation.Tooltip.Contains("do not rewrite it automatically", StringComparison.Ordinal),
            "observed contract mismatch blocks automatic rewrite in its inline warning");
        var ambiguousPresentation = SemanticCallsitePresenter.Build(unregisteredCall with
        {
            Contract = unregisteredCall.Contract with { Match = "AMBIGUOUS" },
        });
        Check(
            ambiguousPresentation.MarkerKind == SemanticCallsiteMarkerKind.EvidenceWarning
                && ambiguousPresentation.WarningCode == "AMBIGUOUS CONTRACT",
            "ambiguous contract receives an evidence warning without choosing a descriptor");
        var receiverConflictPresentation = SemanticCallsitePresenter.Build(confirmedCall with
        {
            Contract = confirmedCall.Contract with { JoinBasis = "RECEIVER_TYPE_CONFLICT" },
        });
        Check(
            receiverConflictPresentation.MarkerKind == SemanticCallsiteMarkerKind.EvidenceWarning
                && receiverConflictPresentation.WarningCode == "RECEIVER TYPE CONFLICT"
                && receiverConflictPresentation.Tooltip.Contains("conflicts with descriptor ownership", StringComparison.Ordinal),
            "receiver type conflict stays visible as a provenance warning");

        var callsiteAttackRoot = Path.Combine(
            Path.GetTempPath(),
            "renovice-callsite-proof-attack-" + Guid.NewGuid().ToString("N"));
        Directory.CreateDirectory(callsiteAttackRoot);
        try
        {
            string CopyCallsiteFixture(string source)
            {
                var destination = Path.Combine(callsiteAttackRoot, Path.GetFileName(source));
                File.Copy(source, destination);
                return destination;
            }
            var attackReadable = CopyCallsiteFixture(callsiteReadable);
            var attackFidelity = CopyCallsiteFixture(callsiteFidelity);
            var attackNames = CopyCallsiteFixture(callsiteNames);
            var attackCalls = CopyCallsiteFixture(callsiteCalls);
            var attackClosures = CopyCallsiteFixture(callsiteClosures);
            var attackProof = CopyCallsiteFixture(callsiteProof);
            var attackNamingMap = SemanticNamingMap.Load(attackNames);
            var attackClosureMap = ClosureOwnershipMap.Load(attackClosures);
            var falsifiedCallProof = JsonNode.Parse(File.ReadAllText(attackProof))!.AsObject();
            var firstCall = falsifiedCallProof["callsites"]!.AsArray()[0]!.AsObject();
            var firstReadableSpan = firstCall["spans"]!["readable"]!.AsObject();
            firstReadableSpan["offset"] = firstReadableSpan["offset"]!.GetValue<int>() + 1;
            File.WriteAllText(attackProof, falsifiedCallProof.ToJsonString());
            Check(
                Throws<InvalidDataException>(() => SemanticVerificationDocument.Load(
                    attackProof,
                    attackReadable,
                    attackFidelity,
                    attackNames,
                    attackClosures,
                    attackCalls,
                    attackNamingMap,
                    attackClosureMap)),
                "managed semantic proof rejects a callsite span that disagrees with its TSV evidence");
        }
        finally
        {
            Directory.Delete(callsiteAttackRoot, recursive: true);
        }
    }

    var template = Path.Combine(workspace.EditorRoot, "EXAMPLES", "mallet_linked_overguard_addon.json");
    var addon = AbilityProject.Load(template);
    Check(addon.Mode == EditorMode.Addon, "Mallet template loads as addon");
    Check(addon.ReadStats().Count == 2, "Mallet linked stats load");
    Check(addon.ReadStats()[0].Base == 0.01, "canonical fraction preserved");
    var modifierRegistry = ModifierBindingRegistry.Load(workspace.ModifierRegistryPath);
    Check(modifierRegistry.Bindings.Count == 1, "modifier evidence registry loads deterministically");
    var fraction = addon.ReadStats()[0];
    var preview100 = StatProjector.Project(fraction, 100, false, modifierRegistry,
        addon.ModuleBodyKey, addon.AbilityIdentifier);
    var preview200 = StatProjector.Project(fraction, 200, false, modifierRegistry,
        addon.ModuleBodyKey, addon.AbilityIdentifier);
    var preview600 = StatProjector.Project(fraction, 600, false, modifierRegistry,
        addon.ModuleBodyKey, addon.AbilityIdentifier);
    var baseAt600 = StatProjector.Project(fraction, 600, true, modifierRegistry,
        addon.ModuleBodyKey, addon.AbilityIdentifier);
    Check(preview100.GameplayValue == 0.01 && preview100.DisplayValue == "1%", "100 percent Strength preview preserves linked 1 percent");
    Check(preview200.GameplayValue == 0.02 && preview200.DisplayValue == "2%", "200 percent Strength preview projects linked 2 percent");
    Check(preview600.GameplayValue == 0.05 && preview600.DisplayValue == "5%", "Strength preview clamps linked value at 5 percent");
    Check(baseAt600.GameplayValue == 0.01 && baseAt600.DisplayValue == "1%", "Show Base Stats bypasses modded projection");
    Check(!modifierRegistry.TryResolve(fraction.ModifierBinding, fraction.ModifierFamily,
        "0000000000000000", addon.AbilityIdentifier, out _, out _), "scoped modifier binding rejects another module");
    var capPreview = StatProjector.Project(addon.ReadStats()[1], 600, false, modifierRegistry,
        addon.ModuleBodyKey, addon.AbilityIdentifier);
    Check(capPreview.GameplayValue == 90000 && capPreview.DisplayValue == "90000", "raw cap preview applies the same Strength binding as gameplay and card output");
    Check(StatUnits.DisplayName(fraction.Unit) == "Percent", "DE percent key has a friendly editor label");
    Check(StatUnits.Path(StatUnits.DisplayName(fraction.Unit)) == fraction.Unit, "friendly unit round-trips to exact DE key");
    var gyre = AbilityProject.Load(Path.Combine(workspace.EditorRoot, "EXAMPLES", "gyre_movement_speed_addon.json"));
    gyre.SetMode(EditorMode.Addon);
    Check(gyre.AuthoringMode == "MANAGED_ADDON_CARD_EXTENSION", "broad Addon tab preserves specific addon architecture");

    var stockRegistry = StockValueBindingRegistry.Load(workspace.StockValueRegistryPath);
    const string stockSample = "v21_12 = 1\nv21_12 = 1.5\nv21_12 = 2\nv21_12 = 2.5\n";
    var discovered = StockNumericEditor.Discover("08faf07b504d058f", stockSample, stockRegistry);
    Check(discovered.Count == 4, "stock numeric discovery finds a repeated exact assignment ladder");
    Check(discovered.All(value => value.Label == "Mallet damage multiplier"), "verified stock binding supplies the exact Mallet label");
    var changedNumeric = discovered.ToList();
    changedNumeric[3] = changedNumeric[3] with { Value = 3.5 };
    var changedSource = StockNumericEditor.Apply(stockSample, changedNumeric);
    Check(changedSource.EndsWith("v21_12 = 3.5\n", StringComparison.Ordinal), "stock numeric edit changes only the selected token span");

    const string cardSource = "-- é\nlocal v9_1\nv9_1 = 100\n";
    var tokenIndex = cardSource.IndexOf("100", StringComparison.Ordinal);
    var cardInput = new { offset = Encoding.UTF8.GetByteCount(cardSource.AsSpan(0, tokenIndex)),
        length = 3, line = 3, variable = "v9_1", original = 100 };
    var cardJson = System.Text.Json.JsonSerializer.Serialize(new {
        format = "RENOVICE_CARD_STATS_V1", body_key = "card-test", rows = new[] {
            new { label = "Health", label_tag = "/HEALTH", evidence = "direct", expression = "v9_1", inputs = new object[] { cardInput } },
            new { label = "Capacity", label_tag = "/CAPACITY", evidence = "direct", expression = "v9_1", inputs = new object[] { cardInput } },
            new { label = "Damage", label_tag = "/DAMAGE", evidence = "computed", expression = "Compute()", inputs = Array.Empty<object>() }
        }
    });
    var cardEntries = CardStatDiscovery.Parse(cardJson, "card-test", cardSource);
    Check(cardEntries.Count == 2 && cardEntries[0].Label == "Health / Capacity", "card discovery merges shared inputs without duplicating edits");
    Check(cardEntries[0].Input!.Offset == tokenIndex && cardEntries[1].Input is null, "card discovery preserves UTF8 source offsets and calculated read-only rows");
    Check(StockNumericEditor.Apply(cardSource, [cardEntries[0].Input! with { Value = 200 }])
        == cardSource.Replace("100", "200", StringComparison.Ordinal), "named card edit changes only its exact base token");
    Check(Throws<InvalidDataException>(() => CardStatDiscovery.Parse(cardJson, "other", cardSource)), "card discovery rejects mismatched body identity");
    Check(Throws<InvalidDataException>(() => CardStatDiscovery.Parse(cardJson, "card-test", cardSource.Replace("100", "999", StringComparison.Ordinal))), "card discovery rejects stale source values");

    var currentMissions = MissionBuildProfile.Presets(workspace.EditorRoot);
    Check(currentMissions.Count == 12, "current build exposes all twelve mission presets");
    var archimedea = currentMissions.Single(p => p.Id == "archimedea");
    Check(archimedea.Section == "EDA / ETA" && archimedea.Values.Select(v => v.Group).Distinct().Count() == 6,
        "Archimedea has a separate section with six named event subsections");
    Check(currentMissions.Where(p => p.Id != "archimedea").All(p => p.Section == "Regular missions"),
        "existing mission controls retain their section");
    Check(archimedea.Values.Where(v => v.Id.EndsWith("survival_minutes", StringComparison.Ordinal)).All(v => v.StockValue == 10),
        "Deep and Temporal Survival completion stays distinct from reward rotations");
    Check(currentMissions.All(p => File.Exists(Path.Combine(MissionBuildProfile.CorpusRoot(workspace), p.CorpusFile))), "current mission profiles resolve their stock corpus");
    Check(currentMissions.Single(p => p.Id == "void_cascade").Values.Single().RecommendedValue == 2, "Void Cascade offers two-times completion speed");
    Check(MissionTimerPreset.All.All(old => currentMissions.Single(p => p.Id == old.Id).ModuleBodyKey != old.ModuleBodyKey), "all seven prior mission presets use current body identities");
    foreach (var id in new[] { "netracells", "descendia_shrine", "descendia_excavation", "archimedea" })
    {
        var preset = currentMissions.Single(p => p.Id == id);
        var missionProject = AbilityProject.CreateFromTemplate(Path.Combine(workspace.EditorRoot, "EXAMPLES", "mallet_linked_overguard_addon.json"), EditorMode.Addon);
        missionProject.ConfigureMissionBuildProfile(id, preset.Values.ToDictionary(v => v.Id, v => v.RecommendedValue), workspace.EditorRoot);
        var mode = missionProject.AuthoringMode;
        missionProject.SetMode(missionProject.Mode);
        Check(mode == missionProject.AuthoringMode, id + " preserves its artifact lane when the GUI saves it");
    }
    // Universal mission registry: build label, lanes and every metadata row are data-driven and exact.
    Check(MissionBuildProfile.Build(workspace.EditorRoot) == "2026.09.28.13.06", "mission build label is read from the 44.0.2 registry");
    Check(currentMissions.All(p => p.Lane is "EXACT_LITERAL" or "TARGET_ADDON" or "METADATA_PATCH"), "every mission preset carries a verified registry lane");
    Check(archimedea.ModuleBodyKey == "076a7b443af7fdb8", "EDA / ETA preset targets the re-registered 44.0.2 ConquestLib body");
    using (var missionRegistry = MissionBuildProfile.Read(workspace.EditorRoot))
    {
        var registryRoot = missionRegistry.RootElement;
        var snapshotPath = Path.Combine(MissionBuildProfile.CorpusRoot(workspace), registryRoot.GetProperty("metadata_snapshot").GetProperty("file").GetString()!);
        using var snapshot = System.Text.Json.JsonDocument.Parse(File.ReadAllText(snapshotPath));
        var metadataRows = registryRoot.GetProperty("tunables").EnumerateArray()
            .Where(row => row.GetProperty("backend").GetString() == "METADATA_PATCH").ToList();
        Check(metadataRows.Count > 0 && metadataRows.All(row =>
        {
            var owner = row.GetProperty("owner");
            var text = snapshot.RootElement.GetProperty("types").GetProperty(owner.GetProperty("type").GetString()!).GetProperty("text").GetString()!;
            var queryable = MetadataPatchEditor.Core.Extract.QueryableText(text);
            var paths = new List<string> { owner.GetProperty("field").GetString()! };
            if (owner.TryGetProperty("also", out var also))
                paths.AddRange(also.EnumerateArray().Select(entry => entry.GetProperty("field").GetString()!));
            // Every entry (primary plus every `also` Scripts entry) must resolve by the exact nested query path the
            // runtime patcher uses, and hold the registered stock value.
            return paths.All(path => queryable.Count(f => f.Path == path) == 1 &&
                double.Parse(queryable.Single(f => f.Path == path).Value, System.Globalization.CultureInfo.InvariantCulture)
                    == row.GetProperty("stock").GetDouble());
        }), "every registered metadata row (and every multi-entry path) resolves by exact nested query to its decoded 44.0.2 stock value");
        foreach (var (id, preset) in registryRoot.GetProperty("missions").EnumerateObject().Select(p => (p.Name, p.Value)))
        {
            var lane = preset.GetProperty("lane").GetString();
            // A root-table row routed to the addon lane keeps its exact literal form (literal_owner) for EXACT_LITERAL presets.
            Check(preset.GetProperty("parameters").EnumerateObject().All(parameter =>
            {
                var row = registryRoot.GetProperty("tunables").EnumerateArray().Single(candidate =>
                    candidate.GetProperty("tunable_id").GetString() == parameter.Value.GetProperty("tunable_id").GetString());
                return row.GetProperty("backend").GetString() == lane
                    || (lane == "EXACT_LITERAL" && row.TryGetProperty("literal_owner", out _));
            }), id + " preset parameters map to registry rows of one lane");
        }
    }
    var linkedSourcePath = Path.Combine(workspace.WorkspaceRoot, "work", "rendered-source", "ability-editor", "dc33836ea5685c89.luau");
    if (File.Exists(linkedSourcePath))
    {
        var source = File.ReadAllText(linkedSourcePath);
        var controls = CardStatDiscovery.DiscoverLinkedAsync(workspace, "dc33836ea5685c89", source).GetAwaiter().GetResult();
        Check(controls.Count(c => c.Inputs.Count > 0) == 8, "reviewed ability has eight linked rank controls");
        var damage = controls.Single(c => c.Label == "Damage · Ability rank 4");
        var edited = StockNumericEditor.Apply(source, damage.Edits(40000));
        var lines = edited.Split('\n');
        Check(new[] { 169, 313, 1671 }.All(line => lines[line - 1].Trim() == "v18_7 = 40000"), "one damage control changes shared, card and activation max-rank inputs together");
        Check(new[] { 174, 317, 1666 }.All(line => lines[line - 1].Trim() == "v18_7 = 25000"), "linked max-rank edit preserves adjacent ability ranks");
        Check(Throws<InvalidDataException>(() => damage.Edits(double.NaN)), "linked controls reject non-finite values");
        var stale = CardStatDiscovery.DiscoverLinkedAsync(workspace, "dc33836ea5685c89", source + "\n-- changed\n").GetAwaiter().GetResult();
        Check(stale.All(c => c.Inputs.Count == 0), "changed source cannot reuse stale gameplay bindings");
        var unknown = CardStatDiscovery.DiscoverLinkedAsync(workspace, "unknown", source).GetAwaiter().GetResult();
        Check(unknown.All(c => c.Inputs.Count == 0), "unresolved Cavalry operation stays read-only without reviewed binding");
    }
    foreach (var body in new[] { "2e32a50ec477c59e", "72e258069c32ff89", "b5da5e61b7843e20" })
    {
        var path = Path.Combine(workspace.WorkspaceRoot, "work", "rendered-source", "ability-editor", body + ".luau");
        if (!File.Exists(path)) continue;
        var source = File.ReadAllText(path);
        var controls = CardStatDiscovery.DiscoverLinkedAsync(workspace, body, source).GetAwaiter().GetResult();
        var scales = controls.Where(c => c.Operation == "scale" && c.Inputs.Count > 0).ToList();
        Check(scales.Count > 0, body + " automatically links native card and gameplay without a registry entry");
        Check(scales.All(c => c.InitialValue == 1 && c.Edits(1).All(e => e.Value == e.OriginalValue)), body + " base scale starts unchanged");
        Check(scales.All(c => c.Edits(2).All(e => e.Value == e.OriginalValue * 2)), body + " scale preserves relative rank and variant values");
        Check(scales.All(c => Throws<InvalidDataException>(() => c.Edits(double.PositiveInfinity))), body + " rejects nonfinite scale");
        var edits = scales.SelectMany(c => c.Edits(2)).ToList();
        Check(edits.Select(e => e.Offset).Distinct().Count() == edits.Count, body + " linked controls do not duplicate source edits");
        var changed = StockNumericEditor.Apply(source, edits);
        Check(changed != source, body + " linked scale creates an actual source edit");
    }
    var survival = MissionTimerPreset.All.Single(preset => preset.Id == "survival");
    const string survivalSample = "frame_76[15] = { lowSpawnThreshold = 0.05, pickupTimeAdded = 7, alertlsDropMult = 0.9 }\n"
        + "frame_76[16] = { interval = 300, alertInterval = 600 }\n"
        + "    frame_64[315].SurvivalTimeAdded = frame_64[317]\n"
        + "    frame_64[318] = _T\n"
        + "    frame_64[318].PickupCollection = 0\n";
    Check(Throws<InvalidDataException>(() => MissionTimerPatcher.Apply(
            survival,
            survival.ModuleBodyKey,
            survivalSample,
            new Dictionary<string, double>
            {
                ["reward_interval"] = 150,
                ["pickup_life_support"] = 7,
                ["pickup_reward_progress"] = 5,
            })),
        "Survival full replacement is rejected because the exact target addon owns these changes");

    var survivalAddon = AbilityProject.CreateFromTemplate(
        Path.Combine(workspace.EditorRoot, "EXAMPLES", "mallet_linked_overguard_addon.json"),
        EditorMode.Addon);
    survivalAddon.ProjectId = "mission.survival.timers.addon";
    survivalAddon.Warframe = "Mission";
    survivalAddon.Ability = "Survival Timers";
    survivalAddon.AbilityIdentifier = survival.AbilityIdentifier;
    survivalAddon.ClearAbilityLocalizeTag();
    survivalAddon.ModulePath = survival.ModulePath;
    survivalAddon.ModuleBodyKey = survival.ModuleBodyKey;
    survivalAddon.ConfigureSurvivalTimerLuaCallAddon(150, 7, 5);
    survivalAddon.SetMode(EditorMode.Addon);
    var survivalAddonJson = survivalAddon.ToJson();
    Check(survivalAddon.AuthoringMode == "MANAGED_LUA_CALL_ADDON"
          && survivalAddon.Hook == "renovice.target.lua_call",
        "Survival exact Lua-call addon mode survives the broad Addon selection");
    Check(survivalAddonJson.Contains("\"prototype\": 64", StringComparison.Ordinal)
          && survivalAddonJson.Contains("\"elapsed_reward_upvalue\": 19", StringComparison.Ordinal)
          && survivalAddonJson.Contains("\"pickup_config_upvalue\": 22", StringComparison.Ordinal)
          && survivalAddonJson.Contains("\"reward_config_upvalue\": 70", StringComparison.Ordinal),
        "Survival addon project locks the verified proto64 capture contract");
    Check(Throws<InvalidDataException>(() =>
            survivalAddon.ConfigureSurvivalTimerLuaCallAddon(0, 7, 5)),
        "Survival addon project rejects an invalid reward interval");

    var mobileDefense = MissionTimerPreset.All.Single(preset => preset.Id == "mobile_defense");
    const string mobileSample = "frame_22[113] = frame_22[109](180, 240, frame_22[112])\n";
    Check(Throws<InvalidDataException>(() => MissionTimerPatcher.Apply(
            mobileDefense, mobileDefense.ModuleBodyKey, mobileSample,
            new Dictionary<string, double> { ["minimum_total_time"] = 90, ["maximum_total_time"] = 120 })),
        "Mobile Defense source-recompile replacement is rejected because exact stock operands own the edit");
    var mobileReplacement = AbilityProject.CreateFromTemplate(
        Path.Combine(workspace.EditorRoot, "EXAMPLES", "mallet_linked_overguard_addon.json"), EditorMode.Replacement);
    mobileReplacement.ProjectId = "mission.mobile_defense.timers.exact-replacement";
    mobileReplacement.Warframe = "Mission";
    mobileReplacement.Ability = "Mobile Defense Timers";
    mobileReplacement.AbilityIdentifier = mobileDefense.AbilityIdentifier;
    mobileReplacement.ClearAbilityLocalizeTag();
    mobileReplacement.ModulePath = mobileDefense.ModulePath;
    mobileReplacement.ModuleBodyKey = mobileDefense.ModuleBodyKey;
    mobileReplacement.ReplaceStats([]);
    mobileReplacement.ConfigureMobileDefenseTimerReplacement(90, 120);
    mobileReplacement.SetMode(EditorMode.Replacement);
    var mobileReplacementJson = mobileReplacement.ToJson();
    Check(mobileReplacement.AuthoringMode == "MANAGED_MISSION_EXACT_REPLACEMENT"
          && string.IsNullOrEmpty(mobileReplacement.Hook)
          && mobileReplacementJson.Contains("\"minimum_instruction\": 120", StringComparison.Ordinal)
          && mobileReplacementJson.Contains("\"maximum_instruction\": 121", StringComparison.Ordinal),
        "Mobile Defense replacement locks the two stock DefenseStage Lerp operands");
    Check(Throws<InvalidDataException>(() => mobileReplacement.ConfigureMobileDefenseTimerReplacement(121, 120)),
        "Mobile Defense replacement rejects minimum greater than maximum");

    var interception = MissionTimerPreset.All.Single(preset => preset.Id == "interception");
    const string interceptionSample = "        elseif cfg_35 == 17 then\n"
        + "            frame_48[100] = frame_35[96]\n"
        + "            frame_35[97] = frame_48[99]\n";
    Check(Throws<InvalidDataException>(() => MissionTimerPatcher.Apply(
            interception, interception.ModuleBodyKey, interceptionSample,
            new Dictionary<string, double> { ["scoring_speed_multiplier"] = 2 })),
        "Interception full replacement is rejected because the exact scalar-owner addon owns the edit");
    var interceptionAddon = AbilityProject.CreateFromTemplate(
        Path.Combine(workspace.EditorRoot, "EXAMPLES", "mallet_linked_overguard_addon.json"), EditorMode.Addon);
    interceptionAddon.ProjectId = "mission.interception.timers.addon";
    interceptionAddon.Warframe = "Mission";
    interceptionAddon.Ability = "Interception Timers";
    interceptionAddon.AbilityIdentifier = interception.AbilityIdentifier;
    interceptionAddon.ClearAbilityLocalizeTag();
    interceptionAddon.ModulePath = interception.ModulePath;
    interceptionAddon.ModuleBodyKey = interception.ModuleBodyKey;
    interceptionAddon.ReplaceStats([]);
    interceptionAddon.ConfigureInterceptionTimerAddon(2);
    interceptionAddon.SetMode(EditorMode.Addon);
    var interceptionAddonJson = interceptionAddon.ToJson();
    Check(interceptionAddon.AuthoringMode == "MANAGED_MISSION_ADDON"
          && interceptionAddonJson.Contains("\"prototype\": 35", StringComparison.Ordinal)
          && interceptionAddonJson.Contains("\"stock_score_rate\": 1", StringComparison.Ordinal),
        "Interception addon locks prototype 35 and the stock score-rate owner");

    var excavation = MissionTimerPreset.All.Single(preset => preset.Id == "excavation");
    const string excavationSample = "frame_49[69] = 100\n"
        + "            frame_49[69] = 60\n"
        + "        frame_49[69] = 140\n"
        + "                frame_49[69] = 20\n";
    Check(Throws<InvalidDataException>(() => MissionTimerPatcher.Apply(
            excavation, excavation.ModuleBodyKey, excavationSample,
            new Dictionary<string, double>
            {
                ["standard_dig_time"] = 50,
                ["old_world_salvage_dig_time"] = 30,
                ["elite_alert_dig_time"] = 70,
            })),
        "Excavation source-level replacement is rejected because the exact byte-patch replacement owns the edit");
    var excavationReplacement = AbilityProject.CreateFromTemplate(
        Path.Combine(workspace.EditorRoot, "EXAMPLES", "mallet_linked_overguard_addon.json"), EditorMode.Addon);
    excavationReplacement.ProjectId = "mission.excavation.timers.exact-replacement";
    excavationReplacement.Warframe = "Mission";
    excavationReplacement.Ability = "Excavation Timers";
    excavationReplacement.AbilityIdentifier = excavation.AbilityIdentifier;
    excavationReplacement.ClearAbilityLocalizeTag();
    excavationReplacement.ModulePath = excavation.ModulePath;
    excavationReplacement.ModuleBodyKey = excavation.ModuleBodyKey;
    excavationReplacement.ReplaceStats([]);
    excavationReplacement.ConfigureExcavationTimerReplacement(50, 30, 70);
    var excavationReplacementJson = excavationReplacement.ToJson();
    Check(excavationReplacement.AuthoringMode == "MANAGED_MISSION_EXACT_REPLACEMENT"
          && excavationReplacement.Mode == EditorMode.Replacement
          && excavationReplacementJson.Contains("\"standard_instruction\": 76", StringComparison.Ordinal)
          && excavationReplacementJson.Contains("\"old_world_salvage_instruction\": 81", StringComparison.Ordinal)
          && excavationReplacementJson.Contains("\"elite_alert_instruction\": 102", StringComparison.Ordinal)
          && excavationReplacementJson.Contains("\"stock_standard_seconds\": 100", StringComparison.Ordinal)
          && !excavationReplacementJson.Contains("addon_generation", StringComparison.Ordinal),
        "Excavation replacement locks the three authoritative LOADN owners and removes the failed runtime hook");
    Check(Throws<InvalidDataException>(() => excavationReplacement.ConfigureExcavationTimerReplacement(49.5, 30, 70)),
        "Excavation exact replacement rejects fractional LOADN durations");

    var plainsControl = MissionTimerPreset.All.Single(preset => preset.Id == "control_area_plains");
    Check(plainsControl.ModuleBodyKey == "bf3c901cb4058c47"
          && plainsControl.Values.Single().StockValue == 90,
        "Plains Control Area preset is locked to the decoded 90-second stock owner");
    Check(Throws<InvalidDataException>(() => MissionTimerPatcher.Apply(
            plainsControl, plainsControl.ModuleBodyKey, "v21 = 90\n",
            new Dictionary<string, double> { ["control_area_duration"] = 45 })),
        "Plains Control Area source recompile is rejected in favor of its exact LOADN replacement");
    var plainsControlReplacement = AbilityProject.CreateFromTemplate(
        Path.Combine(workspace.EditorRoot, "EXAMPLES", "mallet_linked_overguard_addon.json"), EditorMode.Addon);
    plainsControlReplacement.ProjectId = "mission.control_area_plains.timers.exact-replacement";
    plainsControlReplacement.Warframe = "Mission";
    plainsControlReplacement.Ability = "Control Area (Plains) Timers";
    plainsControlReplacement.AbilityIdentifier = plainsControl.AbilityIdentifier;
    plainsControlReplacement.ClearAbilityLocalizeTag();
    plainsControlReplacement.ModulePath = plainsControl.ModulePath;
    plainsControlReplacement.ModuleBodyKey = plainsControl.ModuleBodyKey;
    plainsControlReplacement.ReplaceStats([]);
    plainsControlReplacement.ConfigureControlAreaPlainsTimerReplacement(45);
    var plainsControlJson = plainsControlReplacement.ToJson();
    Check(plainsControlReplacement.AuthoringMode == "MANAGED_MISSION_EXACT_REPLACEMENT"
          && plainsControlReplacement.Mode == EditorMode.Replacement
          && plainsControlJson.Contains("\"duration_prototype\": 17", StringComparison.Ordinal)
          && plainsControlJson.Contains("\"duration_instruction\": 44", StringComparison.Ordinal)
          && plainsControlJson.Contains("\"duration_loadn_occurrence\": 3", StringComparison.Ordinal)
          && plainsControlJson.Contains("\"timer_argument_instruction\": 100", StringComparison.Ordinal)
          && plainsControlJson.Contains("ECC204753DB9BDED69F6A764C919DF5DD2240B5EE907E35C046E99C624D23386", StringComparison.Ordinal)
          && !plainsControlJson.Contains("addon_generation", StringComparison.Ordinal),
        "Plains Control Area replacement locks its root pacing owner, SetObjTimer argument, and stock hash");
    Check(Throws<InvalidDataException>(() => plainsControlReplacement.ConfigureControlAreaPlainsTimerReplacement(45.5)),
        "Plains Control Area exact replacement rejects a fractional LOADN duration");

    var deimosControl = MissionTimerPreset.All.Single(preset => preset.Id == "control_area_deimos");
    Check(deimosControl.ModuleBodyKey == "d9541341dfd466a3"
          && deimosControl.Values.Single().StockValue == 90,
        "Deimos Control Area preset is locked to the decoded 90-second stock owner");
    var deimosControlReplacement = AbilityProject.CreateFromTemplate(
        Path.Combine(workspace.EditorRoot, "EXAMPLES", "mallet_linked_overguard_addon.json"), EditorMode.Addon);
    deimosControlReplacement.ProjectId = "mission.control_area_deimos.timers.exact-replacement";
    deimosControlReplacement.Warframe = "Mission";
    deimosControlReplacement.Ability = "Control Area (Deimos) Timers";
    deimosControlReplacement.AbilityIdentifier = deimosControl.AbilityIdentifier;
    deimosControlReplacement.ClearAbilityLocalizeTag();
    deimosControlReplacement.ModulePath = deimosControl.ModulePath;
    deimosControlReplacement.ModuleBodyKey = deimosControl.ModuleBodyKey;
    deimosControlReplacement.ReplaceStats([]);
    deimosControlReplacement.ConfigureControlAreaDeimosTimerReplacement(45);
    var deimosControlJson = deimosControlReplacement.ToJson();
    Check(deimosControlReplacement.AuthoringMode == "MANAGED_MISSION_EXACT_REPLACEMENT"
          && deimosControlReplacement.Mode == EditorMode.Replacement
          && deimosControlJson.Contains("\"duration_prototype\": 15", StringComparison.Ordinal)
          && deimosControlJson.Contains("\"duration_instruction\": 56", StringComparison.Ordinal)
          && deimosControlJson.Contains("\"duration_loadn_occurrence\": 1", StringComparison.Ordinal)
          && deimosControlJson.Contains("\"persistent_result_instruction\": 63", StringComparison.Ordinal)
          && deimosControlJson.Contains("ECBED12E85416CE5FBB25995D9252F4AD29042F1AE7DAA3C2E4C8A2F25AEDF49", StringComparison.Ordinal)
          && !deimosControlJson.Contains("addon_generation", StringComparison.Ordinal),
        "Deimos Control Area replacement locks its root pacing owner, persisted duration result, and stock hash");

    var nokkoControl = MissionTimerPreset.All.Single(preset => preset.Id == "control_area_nokko");
    Check(nokkoControl.ModuleBodyKey == "e192d5cc2f37056e"
          && nokkoControl.Values.Single().StockValue is null
          && nokkoControl.Values.Single().StockDescription?.Contains("mission-resource", StringComparison.Ordinal) == true,
        "Venus/Nokko Control Area preset reports its stock duration as resource-backed rather than inventing a number");
    var nokkoControlReplacement = AbilityProject.CreateFromTemplate(
        Path.Combine(workspace.EditorRoot, "EXAMPLES", "mallet_linked_overguard_addon.json"), EditorMode.Addon);
    nokkoControlReplacement.ProjectId = "mission.control_area_nokko.timers.exact-replacement";
    nokkoControlReplacement.Warframe = "Mission";
    nokkoControlReplacement.Ability = "Control Area (Venus/Nokko) Timers";
    nokkoControlReplacement.AbilityIdentifier = nokkoControl.AbilityIdentifier;
    nokkoControlReplacement.ClearAbilityLocalizeTag();
    nokkoControlReplacement.ModulePath = nokkoControl.ModulePath;
    nokkoControlReplacement.ModuleBodyKey = nokkoControl.ModuleBodyKey;
    nokkoControlReplacement.ReplaceStats([]);
    nokkoControlReplacement.ConfigureControlAreaNokkoTimerReplacement(30);
    var nokkoControlJson = nokkoControlReplacement.ToJson();
    Check(nokkoControlReplacement.AuthoringMode == "MANAGED_MISSION_EXACT_REPLACEMENT"
          && nokkoControlReplacement.Mode == EditorMode.Replacement
          && nokkoControlJson.Contains("\"timer_argument_instruction\": 118", StringComparison.Ordinal)
          && nokkoControlJson.Contains("\"halfway_result_instruction\": 107", StringComparison.Ordinal)
          && nokkoControlJson.Contains("\"two_thirds_result_instruction\": 112", StringComparison.Ordinal)
          && !nokkoControlJson.Contains("addon_generation", StringComparison.Ordinal),
        "Venus/Nokko Control Area replacement locks its timer consumer and both linked thresholds");
    Check(Throws<InvalidDataException>(() => nokkoControlReplacement.ConfigureControlAreaNokkoTimerReplacement(25)),
        "Venus/Nokko replacement rejects durations that cannot preserve both linked thresholds exactly");

    var helminth = HelminthRegistry.Load(workspace.HelminthRegistryPath);
    Check(helminth.Count >= 40, "pinned Wiki Helminth registry has a completeness floor");
    Check(helminth.Find("/Lotus/Powersuits/Bard/Abilities/BardCharmAbility")?.AbilityName == "Resonator",
        "Helminth registry identifies Octavia Resonator by exact InternalName");

    var replacement = AbilityProject.CreateFromTemplate(template, EditorMode.Replacement);
    Check(replacement.Mode == EditorMode.Replacement, "replacement mode switches deterministically");
    Check(replacement.AuthoringMode == "NATIVE_REPLACEMENT", "replacement authoring mode emitted");
    Check(replacement.ValidateForSave().Count == 0, "replacement project passes UI validation");

    var replacementRoot = JsonNode.Parse(replacement.ToJson())!.AsObject();
    var replacementEffect = replacementRoot["effect"]!.AsObject();
    Check(replacement.ModeSelection == "MANUAL"
          && replacement.ModeReason.Contains("exact body-keyed native module", StringComparison.Ordinal),
        "replacement template records replacement-specific mode evidence");
    Check(replacementEffect["hook"] is null && replacementEffect["hook_evidence_id"] is null
          && replacementEffect["stacking"] is null,
        "replacement template removes addon-only hook semantics");
    Check(!replacementRoot.ContainsKey("addon_generation"),
        "replacement template removes the Mallet addon generator");
    Check(replacementEffect["authority"]?.GetValue<string>() == "UNKNOWN"
          && replacementEffect["lifetime"]?.GetValue<string>()?.Contains("body-keyed native module", StringComparison.Ordinal) == true
          && replacementEffect["cleanup"]?.GetValue<string>()?.Contains("Rollback", StringComparison.Ordinal) == true,
        "replacement template replaces inherited addon ownership text");
    replacement.ClearAbilityLocalizeTag();
    Check(JsonNode.Parse(replacement.ToJson())!["target"]!["ability_localize_tag"] is null,
        "non-ability replacements can clear an inherited ability localization tag");

    var changedStats = replacement.ReadStats().ToList();
    changedStats[0] = changedStats[0] with { Base = 0.02, Label = "Changed Linked Stat" };
    replacement.ReplaceStats(changedStats);
    Check(replacement.ReadStats()[0].Base == 0.02, "stat base round-trips through editor model");
    Check(replacement.ReadStats()[0].Label == "Changed Linked Stat", "stat label round-trips through editor model");

    var testDirectory = Path.Combine(Path.GetTempPath(), "renovice-ability-studio-model-test");
    Directory.CreateDirectory(testDirectory);
    var testFile = Path.Combine(testDirectory, "ability_edit.json");
    replacement.Save(testFile);
    Check(File.Exists(testFile), "project saves atomically");
    Check(!File.Exists(testFile + ".tmp"), "atomic-save temporary is removed");
    var reloaded = AbilityProject.Load(testFile);
    Check(reloaded.Mode == EditorMode.Replacement, "saved replacement reloads");
    Check(reloaded.ReadStats()[0].Base == 0.02, "saved stat remains authoritative");
    File.Delete(testFile);
    Directory.Delete(testDirectory);

    if (File.Exists(verifiedReadable))
    {
        var verifiedBundle = VerifiedSemanticSource.Load(verifiedReadable);
        var unchangedRebase = StructuralSourceRebaser.Rebase(
            verifiedBundle, verifiedBundle.Source, verifiedBundle);
        Check(unchangedRebase.Success && unchangedRebase.Hunks.Count == 0
              && unchangedRebase.MergedSource == verifiedBundle.Source,
            "structural rebase accepts an unchanged user source without drift");

        const string stockLine = "            inventoryControl:ModifyValue(value3, 10, suit_type, suit)";
        const string editedLine = "            inventoryControl:ModifyValue(value3, 11, suit_type, suit)";
        Check(verifiedBundle.Source.Contains(stockLine, StringComparison.Ordinal),
            "structural rebase fixture contains its exact stock edit line");
        var editedSource = verifiedBundle.Source.Replace(stockLine, editedLine, StringComparison.Ordinal);
        var safeRebase = StructuralSourceRebaser.Rebase(verifiedBundle, editedSource, verifiedBundle);
        Check(safeRebase.Success && safeRebase.Hunks.Count == 1
              && safeRebase.Hunks[0].Prototype == 1
              && safeRebase.Hunks[0].LeftAnchor is not null
              && safeRebase.Hunks[0].RightAnchor is not null,
            "structural rebase binds a local user edit to prototype 1 and two hash-bound boundary anchors");
        Check(safeRebase.MergedSource?.Contains(editedLine, StringComparison.Ordinal) == true,
            "structural rebase preserves the user-owned line exactly when the generator region is unchanged");

        var unownedSource = "-- user header outside every prototype\n" + verifiedBundle.Source;
        var unownedRebase = StructuralSourceRebaser.Rebase(verifiedBundle, unownedSource, verifiedBundle);
        Check(!unownedRebase.Success && unownedRebase.MergedSource is null
              && unownedRebase.Conflicts.Any(conflict => conflict.Code == "NO_STRUCTURAL_OWNER"),
            "structural rebase rejects edits without a proven prototype owner and emits no merged source");

        var rebaseDirectory = Path.Combine(Path.GetTempPath(), "renovice-rebase-report-" + Guid.NewGuid().ToString("N"));
        Directory.CreateDirectory(rebaseDirectory);
        try
        {
            var reportPath = Path.Combine(rebaseDirectory, "rebase-report.json");
            safeRebase.WriteReport(reportPath);
            using var reportDocument = System.Text.Json.JsonDocument.Parse(File.ReadAllText(reportPath));
            Check(reportDocument.RootElement.GetProperty("status").GetString() == "SAFE_TO_APPLY"
                  && reportDocument.RootElement.GetProperty("counts").GetProperty("conflicts").GetInt32() == 0,
                "structural rebase report records hashes, anchors, hunk counts, and an explicit safe status");
        }
        finally
        {
            Directory.Delete(rebaseDirectory, recursive: true);
        }

        var currentMalletPath = Path.Combine(
            workspace.RenderedSourceRoot, "08faf07b504d058f.luau");
        if (File.Exists(currentMalletPath))
        {
            var currentMallet = VerifiedSemanticSource.Load(currentMalletPath);
            var presentationRebase = StructuralSourceRebaser.Rebase(
                verifiedBundle, editedSource, currentMallet);
            Check(presentationRebase.Success
                  && presentationRebase.GeneratorChangeCount > 0
                  && presentationRebase.MergedSource?.Contains(editedLine, StringComparison.Ordinal) == true,
                "structural rebase preserves a non-overlapping user edit across a real verified Mallet presentation change");

            const string overlappingStockLine = "    v15_14 = v15_13[1]";
            const string overlappingUserLine = "    v15_14 = v15_13[2]";
            Check(verifiedBundle.Source.Contains(overlappingStockLine, StringComparison.Ordinal),
                "structural rebase overlap fixture contains its exact old generated line");
            var overlappingUser = verifiedBundle.Source.Replace(
                overlappingStockLine, overlappingUserLine, StringComparison.Ordinal);
            var blockedRebase = StructuralSourceRebaser.Rebase(
                verifiedBundle, overlappingUser, currentMallet);
            Check(!blockedRebase.Success && blockedRebase.MergedSource is null
                  && blockedRebase.Conflicts.Any(conflict =>
                      conflict.Code == "OVERLAPPING_GENERATOR_CHANGE"),
                "structural rebase blocks a real overlapping generator/user edit and emits no merged source");

            var unrelatedPath = Directory.EnumerateFiles(
                    workspace.RenderedSourceRoot, "*.luau", SearchOption.TopDirectoryOnly)
                .Where(path => !path.EndsWith(".fidelity.luau", StringComparison.OrdinalIgnoreCase)
                               && !string.Equals(path, currentMalletPath, StringComparison.OrdinalIgnoreCase))
                .FirstOrDefault(path => File.Exists(
                    VerifiedSemanticSource.Companion(path, ".semantic-view.json")));
            if (unrelatedPath is not null)
            {
                var unrelated = VerifiedSemanticSource.Load(unrelatedPath);
                var unrelatedRebase = StructuralSourceRebaser.Rebase(
                    currentMallet, currentMallet.Source, unrelated);
                Check(!unrelatedRebase.Success && unrelatedRebase.MergedSource is null
                      && unrelatedRebase.Conflicts.All(conflict =>
                          conflict.Code == "STRUCTURAL_PROOF_MISMATCH"),
                    "structural rebase rejects an unrelated verified module before mapping text");
            }

            var workspaceDirectory = Path.Combine(
                Path.GetTempPath(), "renovice-rebase-workspace-" + Guid.NewGuid().ToString("N"));
            Directory.CreateDirectory(workspaceDirectory);
            try
            {
                var temporaryProject = Path.Combine(workspaceDirectory, "ability_edit.json");
                File.WriteAllText(temporaryProject, "{}\n");
                var captured = StructuralRebaseWorkspace.CaptureBaseline(
                    temporaryProject, "08faf07b504d058f", currentMalletPath);
                var resolved = StructuralRebaseWorkspace.FindBaseline(
                    temporaryProject, "08faf07b504d058f");
                Check(captured == resolved && VerifiedSemanticSource.Load(resolved!).SourceSha256 == currentMallet.SourceSha256,
                    "project rebase workspace keeps an immutable hash-addressed semantic baseline and validates its binding");
            }
            finally
            {
                Directory.Delete(workspaceDirectory, recursive: true);
            }
        }
    }
}
catch (Exception exception)
{
    failed++;
    Console.WriteLine($"FAIL unexpected exception: {exception}");
}

Console.WriteLine($"SUMMARY passed={passed} failed={failed}");
return failed == 0 ? 0 : 1;
