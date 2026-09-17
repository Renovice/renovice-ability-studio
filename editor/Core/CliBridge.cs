using System.Diagnostics;
using System.Text;

namespace Renovice.AbilityEditor.Core;

public sealed record CliResult(int ExitCode, string Output)
{
    public bool Success => ExitCode == 0;
}

public static class CliBridge
{
    public static async Task<CliResult> RunAsync(
        WorkspacePaths workspace,
        IEnumerable<string> arguments,
        CancellationToken cancellationToken = default)
    {
        if (!File.Exists(workspace.CliPath))
        {
            throw new FileNotFoundException(
                "The authoritative C++ CLI is missing. Run build_editor.bat first.", workspace.CliPath);
        }

        var start = new ProcessStartInfo
        {
            FileName = workspace.CliPath,
            WorkingDirectory = workspace.EditorRoot,
            UseShellExecute = false,
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            CreateNoWindow = true,
        };
        foreach (var argument in arguments) start.ArgumentList.Add(argument);
        start.ArgumentList.Add("--editor-root");
        start.ArgumentList.Add(workspace.EditorRoot);

        using var process = new Process { StartInfo = start };
        var output = new StringBuilder();
        process.OutputDataReceived += (_, eventArgs) => { if (eventArgs.Data is not null) output.AppendLine(eventArgs.Data); };
        process.ErrorDataReceived += (_, eventArgs) => { if (eventArgs.Data is not null) output.AppendLine(eventArgs.Data); };
        if (!process.Start()) throw new InvalidOperationException("Failed to start the ability-editor CLI");
        process.BeginOutputReadLine();
        process.BeginErrorReadLine();
        await process.WaitForExitAsync(cancellationToken);
        return new CliResult(process.ExitCode, output.ToString());
    }
}
