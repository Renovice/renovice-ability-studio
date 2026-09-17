using System.Text.Json;
using MetadataPatchEditor.Core;

namespace Renovice.AbilityEditor.Core;

public static class InstalledGameData
{
    public static string? RefreshEnglishNames(WorkspacePaths workspace)
    {
        var workspaceParent = Directory.GetParent(workspace.WorkspaceRoot)?.FullName;
        var siblingCache = workspaceParent is null ? null : Path.Combine(workspaceParent, "Warframe", "Cache.Windows");
        var cache = siblingCache is not null && Cache.IsCacheWindows(siblingCache)
            ? siblingCache
            : Cache.FindCacheWindows(workspace.WorkspaceRoot);
        if (cache is null) return null;
        var workspaceOodle = Path.Combine(workspace.WorkspaceRoot, "repos", "apps", "metadata-editor", "editor", "lib", "oo2core_9.dll");
        var submoduleOodle = Path.Combine(workspace.EditorRoot, "external", "WarframeMetaDataEditor", "editor", "lib", "oo2core_9.dll");
        var bundledOodle = File.Exists(workspaceOodle) ? workspaceOodle : submoduleOodle;
        if (File.Exists(bundledOodle)) Oodle.DllPathOverride = bundledOodle;
        var names = LanguagesBin.Decode(Cache.ExtractLanguagesBin(cache, "en"));
        Directory.CreateDirectory(Path.GetDirectoryName(workspace.LocalizedNamesPath)!);
        var temporary = workspace.LocalizedNamesPath + ".tmp";
        File.WriteAllText(temporary, JsonSerializer.Serialize(names, new JsonSerializerOptions { WriteIndented = true }));
        File.Move(temporary, workspace.LocalizedNamesPath, true);
        return cache;
    }
}
