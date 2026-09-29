using System.Security.Cryptography;
using System.Text.Json;

namespace Renovice.AbilityEditor.Core;

public sealed record VerifiedArtifactExportResult(
    string DestinationPath,
    string ArtifactSha256,
    long ArtifactSize,
    string? RollbackPath,
    string? RollbackSha256);

public static class VerifiedArtifactExporter
{
    public static string MissionReplacementFileName(string moduleBodyKey, string presetId)
    {
        var bodyKey = moduleBodyKey.Trim().ToLowerInvariant();
        if (bodyKey.Length != 16 || bodyKey.Any(character => !Uri.IsHexDigit(character)))
            throw new InvalidDataException("A mission replacement filename requires one exact 16-hex body key.");
        var presetSlug = new string(presetId.Trim().ToLowerInvariant().Select(character =>
            char.IsLetterOrDigit(character) || character is '_' or '-' ? character : '_').ToArray()).Trim('_');
        if (presetSlug.Length == 0)
            throw new InvalidDataException("A mission replacement filename requires a non-empty preset ID.");
        return $"{bodyKey} (mission_{presetSlug}_timers_replacement).lua_B";
    }

    public static string MissionTargetAddonFileName(string moduleBodyKey, string presetId)
    {
        var bodyKey = moduleBodyKey.Trim().ToLowerInvariant();
        if (bodyKey.Length != 16 || bodyKey.Any(character => !Uri.IsHexDigit(character)))
            throw new InvalidDataException("A mission target-addon filename requires one exact 16-hex body key.");
        var presetSlug = new string(presetId.Trim().Select(character =>
            char.IsLetterOrDigit(character) ? character : '_').ToArray()).Trim('_');
        if (presetSlug.Length == 0)
            throw new InvalidDataException("A mission target-addon filename requires a non-empty preset ID.");
        var display = char.ToUpperInvariant(presetSlug[0]) + presetSlug[1..].ToLowerInvariant();
        return $"{bodyKey}.{display}Timers.target.addon.lua_B";
    }

    public static VerifiedArtifactExportResult Export(
        string buildManifestPath,
        string destinationPath,
        string rollbackRoot)
    {
        var manifestPath = Path.GetFullPath(buildManifestPath);
        if (!File.Exists(manifestPath))
            throw new FileNotFoundException("The staged build manifest is missing.", manifestPath);
        using var document = JsonDocument.Parse(File.ReadAllText(manifestPath));
        var root = document.RootElement;
        RequireString(root, "format", "RENOVICE_ABILITY_EDITOR_BUILD_V1");
        RequireString(root, "status", "STAGED_PASS");
        var extension = root.TryGetProperty("package_type", out var package) && package.GetString() == "METADATA_PATCH" ? ".txt" : ".lua_B";
        if (!string.Equals(Path.GetExtension(destinationPath), extension, StringComparison.OrdinalIgnoreCase))
            throw new InvalidDataException($"This verified artifact must use the {extension} extension.");
        if (root.GetProperty("live_write_performed").GetBoolean())
            throw new InvalidDataException("The staged manifest unexpectedly records a live write.");

        var gates = root.GetProperty("gates");
        if (gates.ValueKind != JsonValueKind.Array || gates.GetArrayLength() == 0)
            throw new InvalidDataException("The staged manifest contains no verification gates.");
        foreach (var gate in gates.EnumerateArray())
        {
            if (!gate.GetProperty("pass").GetBoolean() || gate.GetProperty("exit_code").GetInt32() != 0)
                throw new InvalidDataException(
                    $"The staged gate '{gate.GetProperty("name").GetString()}' did not pass.");
        }

        var artifact = root.GetProperty("artifact");
        var relativeArtifact = artifact.GetProperty("path").GetString();
        if (string.IsNullOrWhiteSpace(relativeArtifact))
            throw new InvalidDataException("The staged manifest artifact path is empty.");
        var generationRoot = Path.GetDirectoryName(manifestPath)
            ?? throw new InvalidDataException("The staged build manifest has no parent directory.");
        var generationPrefix = Path.GetFullPath(generationRoot) + Path.DirectorySeparatorChar;
        var artifactPath = Path.GetFullPath(Path.Combine(generationRoot, relativeArtifact));
        if (!artifactPath.StartsWith(generationPrefix, StringComparison.OrdinalIgnoreCase))
            throw new InvalidDataException("The staged artifact path escapes its generation directory.");
        if (!File.Exists(artifactPath))
            throw new FileNotFoundException("The staged artifact is missing.", artifactPath);

        var expectedSize = artifact.GetProperty("size").GetInt64();
        var expectedSha256 = artifact.GetProperty("sha256").GetString()
            ?? throw new InvalidDataException("The staged artifact SHA-256 is missing.");
        var actualSize = new FileInfo(artifactPath).Length;
        var actualSha256 = HashFile(artifactPath);
        if (actualSize != expectedSize)
            throw new InvalidDataException(
                $"The staged artifact size changed: manifest={expectedSize} actual={actualSize}.");
        if (!string.Equals(actualSha256, expectedSha256, StringComparison.OrdinalIgnoreCase))
            throw new InvalidDataException("The staged artifact SHA-256 no longer matches its manifest.");

        var destination = Path.GetFullPath(destinationPath);
        var destinationDirectory = Path.GetDirectoryName(destination)
            ?? throw new InvalidDataException("The export destination has no parent directory.");
        Directory.CreateDirectory(destinationDirectory);

        string? rollbackPath = null;
        string? rollbackSha256 = null;
        if (File.Exists(destination))
        {
            var rollbackDirectory = Path.Combine(
                Path.GetFullPath(rollbackRoot),
                DateTime.UtcNow.ToString("yyyyMMdd-HHmmss-fff") + "-" + Guid.NewGuid().ToString("N")[..8]);
            Directory.CreateDirectory(rollbackDirectory);
            rollbackPath = Path.Combine(rollbackDirectory, Path.GetFileName(destination));
            File.Copy(destination, rollbackPath, overwrite: false);
            rollbackSha256 = HashFile(rollbackPath);
        }

        var temporary = destination + ".renovice-export-" + Guid.NewGuid().ToString("N") + ".tmp";
        var destinationReplaced = false;
        try
        {
            File.Copy(artifactPath, temporary, overwrite: false);
            if (new FileInfo(temporary).Length != expectedSize
                || !string.Equals(HashFile(temporary), expectedSha256, StringComparison.OrdinalIgnoreCase))
                throw new IOException("The temporary exported artifact failed its size or SHA-256 check.");
            File.Move(temporary, destination, overwrite: true);
            destinationReplaced = true;
            if (new FileInfo(destination).Length != expectedSize
                || !string.Equals(HashFile(destination), expectedSha256, StringComparison.OrdinalIgnoreCase))
                throw new IOException("The final exported artifact failed its size or SHA-256 check.");
        }
        catch
        {
            if (destinationReplaced)
            {
                if (rollbackPath is not null)
                    File.Copy(rollbackPath, destination, overwrite: true);
                else if (File.Exists(destination))
                    File.Delete(destination);
            }
            throw;
        }
        finally
        {
            if (File.Exists(temporary)) File.Delete(temporary);
        }

        return new VerifiedArtifactExportResult(
            destination, actualSha256, actualSize, rollbackPath, rollbackSha256);
    }

    private static void RequireString(JsonElement root, string property, string expected)
    {
        var actual = root.GetProperty(property).GetString();
        if (!string.Equals(actual, expected, StringComparison.Ordinal))
            throw new InvalidDataException(
                $"The staged manifest '{property}' value is '{actual ?? "<null>"}', expected '{expected}'.");
    }

    private static string HashFile(string path) =>
        Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(path)));
}
