using System.Text.Json;

namespace Renovice.AbilityEditor.Core;

public sealed record WorkspacePaths(
    string WorkspaceRoot,
    string EditorRoot,
    string CliPath,
    string StagingRoot,
    string ProjectsRoot,
    string ToolchainRoot,
    string CorpusRoot,
    string MetadataSnapshotsRoot,
    string CatalogPath,
    string LocalizedNamesPath,
    string RenderedSourceRoot,
    string ModifierRegistryPath,
    string StockValueRegistryPath,
    string HelminthRegistryPath);

public static class WorkspaceLocator
{
    public static WorkspacePaths Locate(string? start = null)
    {
        var candidates = new[]
        {
            start,
            AppContext.BaseDirectory,
            Environment.CurrentDirectory,
        }.Where(path => !string.IsNullOrWhiteSpace(path));

        foreach (var candidate in candidates)
        {
            var directory = new DirectoryInfo(Path.GetFullPath(candidate!));
            while (directory is not null)
            {
                var workspaceFile = Path.Combine(directory.FullName, "WORKSPACE.json");
                if (File.Exists(workspaceFile))
                {
                    return FromWorkspaceFile(workspaceFile);
                }
                directory = directory.Parent;
            }
        }

        throw new DirectoryNotFoundException(
            "Unable to locate WORKSPACE.json. Start the editor from inside the RENOVICE workspace.");
    }

    private static WorkspacePaths FromWorkspaceFile(string workspaceFile)
    {
        using var document = JsonDocument.Parse(File.ReadAllText(workspaceFile));
        var root = document.RootElement;
        var workspaceRoot = Path.GetDirectoryName(workspaceFile)!;
        var editorRelative = root.GetProperty("repos").GetProperty("ability_editor").GetString()
            ?? throw new InvalidDataException("WORKSPACE.json repos.ability_editor is null");
        var buildRelative = root.GetProperty("work").GetProperty("builds").GetString()
            ?? throw new InvalidDataException("WORKSPACE.json work.builds is null");
        var stagingRelative = root.GetProperty("work").GetProperty("staging").GetString()
            ?? throw new InvalidDataException("WORKSPACE.json work.staging is null");
        var toolchainRelative = root.GetProperty("repos").GetProperty("de_luau_toolchain").GetString()
            ?? throw new InvalidDataException("WORKSPACE.json repos.de_luau_toolchain is null");
        var corpusRelative = root.GetProperty("shared").GetProperty("de_luau_corpus").GetString()
            ?? throw new InvalidDataException("WORKSPACE.json shared.de_luau_corpus is null");
        var metadataRelative = root.GetProperty("shared").GetProperty("metadata_snapshots").GetString()
            ?? throw new InvalidDataException("WORKSPACE.json shared.metadata_snapshots is null");
        var editorRoot = Path.GetFullPath(Path.Combine(workspaceRoot, editorRelative));
        var buildRoot = Path.GetFullPath(Path.Combine(workspaceRoot, buildRelative, "ability-editor", "current"));
        return new WorkspacePaths(
            workspaceRoot,
            editorRoot,
            Path.Combine(buildRoot, "bin", "renovice_ability_editor_cli.exe"),
            Path.GetFullPath(Path.Combine(workspaceRoot, stagingRelative, "ability-editor")),
            Path.GetFullPath(Path.Combine(workspaceRoot, "work", "ability-projects")),
            Path.GetFullPath(Path.Combine(workspaceRoot, toolchainRelative)),
            Path.GetFullPath(Path.Combine(workspaceRoot, corpusRelative)),
            Path.GetFullPath(Path.Combine(workspaceRoot, metadataRelative)),
            Path.GetFullPath(Path.Combine(workspaceRoot, "work", "catalogs", "ability-catalog.json")),
            Path.GetFullPath(Path.Combine(workspaceRoot, "work", "catalogs", "Names.en.json")),
            Path.GetFullPath(Path.Combine(workspaceRoot, "work", "rendered-source", "ability-editor")),
            Path.Combine(editorRoot, "REGISTRIES", "modifier_bindings.tsv"),
            Path.Combine(editorRoot, "REGISTRIES", "stock_value_bindings.tsv"),
            Path.Combine(editorRoot, "REGISTRIES", "helminth_abilities.tsv"));
    }
}
