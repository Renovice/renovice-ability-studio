param(
    [Parameter(Mandatory = $true)]
    [string] $AuditPath,

    [Parameter(Mandatory = $true)]
    [string] $DerecompPath,

    [Parameter(Mandatory = $true)]
    [string] $CorpusRoot,

    [Parameter(Mandatory = $true)]
    [string] $SemanticSdkPath,

    [Parameter(Mandatory = $true)]
    [string] $OutputDirectory,

    [string] $ExpectedAuditSha256 = '',
    [string] $ExpectedDerecompSha256 = '',
    [int] $ExpectedRejectedFiles = -1,
    [ValidateRange(1, 32)]
    [int] $ThrottleLimit = 4
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Resolve-ExistingFile([string] $Path, [string] $Label) {
    $resolved = Resolve-Path -LiteralPath $Path -ErrorAction Stop
    if (-not (Test-Path -LiteralPath $resolved.Path -PathType Leaf)) {
        throw "$Label is not a file: $($resolved.Path)"
    }
    return $resolved.Path
}

function Resolve-ExistingDirectory([string] $Path, [string] $Label) {
    $resolved = Resolve-Path -LiteralPath $Path -ErrorAction Stop
    if (-not (Test-Path -LiteralPath $resolved.Path -PathType Container)) {
        throw "$Label is not a directory: $($resolved.Path)"
    }
    return $resolved.Path
}

function Get-Sha256([string] $Path) {
    return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToUpperInvariant()
}

$auditFile = Resolve-ExistingFile $AuditPath 'Semantic coverage audit'
$derecomp = Resolve-ExistingFile $DerecompPath 'derecomp'
$corpus = Resolve-ExistingDirectory $CorpusRoot 'Corpus root'
$semanticSdk = Resolve-ExistingFile $SemanticSdkPath 'Semantic SDK symbols'
$toolchainRoot = Split-Path -Parent (Split-Path -Parent $derecomp)
$auditHashBefore = Get-Sha256 $auditFile
$derecompHashBefore = Get-Sha256 $derecomp

if ($ExpectedAuditSha256 -and $auditHashBefore -ne $ExpectedAuditSha256.ToUpperInvariant()) {
    throw "Audit SHA-256 mismatch: expected $ExpectedAuditSha256, found $auditHashBefore"
}
if ($ExpectedDerecompSha256 -and $derecompHashBefore -ne $ExpectedDerecompSha256.ToUpperInvariant()) {
    throw "derecomp SHA-256 mismatch: expected $ExpectedDerecompSha256, found $derecompHashBefore"
}

$audit = Get-Content -LiteralPath $auditFile -Raw | ConvertFrom-Json
if (-not $audit.summary -or -not $audit.evaluated_results) {
    throw 'Audit is missing summary or evaluated_results.'
}
if ([string] $audit.summary.derecomp_sha256 -ne $derecompHashBefore) {
    throw "Audit derecomp identity does not match the selected binary."
}

$rejected = @($audit.evaluated_results | Where-Object { -not [bool] $_.pass })
if ($ExpectedRejectedFiles -ge 0 -and $rejected.Count -ne $ExpectedRejectedFiles) {
    throw "Expected $ExpectedRejectedFiles rejected rows; found $($rejected.Count)."
}
if (@($rejected | Where-Object {
    $_.result_code -ne 'BASELINE_READABLE_RENDER' -and
    $_.result_code -ne 'POST_RECOMPILE_PLAN'
}).Count -ne 0) {
    throw 'Rejected rows include a result code this diagnostic probe does not understand.'
}

$output = [IO.Path]::GetFullPath($OutputDirectory)
if (Test-Path -LiteralPath $output) {
    if (@(Get-ChildItem -LiteralPath $output -Force).Count -ne 0) {
        throw "Output directory is not empty: $output"
    }
} else {
    New-Item -ItemType Directory -Path $output | Out-Null
}
$probeRoot = Join-Path $output '.probe'
New-Item -ItemType Directory -Path $probeRoot | Out-Null

$indexed = for ($index = 0; $index -lt $rejected.Count; $index++) {
    [pscustomobject]@{
        index = $index
        file = [string] $rejected[$index].file
        audit_result_code = [string] $rejected[$index].result_code
    }
}
$startedUtc = [DateTime]::UtcNow.ToString('o')

$rows = @($indexed | ForEach-Object -Parallel {
    function Invoke-CapturedProcess(
        [string] $Executable,
        [string[]] $Arguments,
        [string] $WorkingDirectory
    ) {
        $start = [Diagnostics.ProcessStartInfo]::new()
        $start.FileName = $Executable
        $start.WorkingDirectory = $WorkingDirectory
        $start.UseShellExecute = $false
        $start.CreateNoWindow = $true
        $start.RedirectStandardOutput = $true
        $start.RedirectStandardError = $true
        foreach ($argument in $Arguments) {
            [void] $start.ArgumentList.Add($argument)
        }

        $process = [Diagnostics.Process]::new()
        $process.StartInfo = $start
        try {
            if (-not $process.Start()) {
                throw "Process did not start: $Executable"
            }
            $stdoutTask = $process.StandardOutput.ReadToEndAsync()
            $stderrTask = $process.StandardError.ReadToEndAsync()
            $process.WaitForExit()
            return [pscustomobject]@{
                exit_code = [int] $process.ExitCode
                stdout = $stdoutTask.GetAwaiter().GetResult()
                stderr = $stderrTask.GetAwaiter().GetResult()
            }
        } finally {
            $process.Dispose()
        }
    }

    $item = $_
    $name = $item.file
    $stem = [IO.Path]::GetFileNameWithoutExtension($name)
    $input = Join-Path $using:corpus $name
    $fidelity = Join-Path $using:probeRoot "$stem.fidelity.luau"
    $readable = Join-Path $using:probeRoot "$stem.luau"
    $mapping = Join-Path $using:probeRoot "$stem.names.tsv"
    $verify = Join-Path $using:probeRoot "$stem.readable-verify.lua_B"
    $temporary = @($fidelity, $readable, $mapping, $verify)

    $probeStage = 'RENDER'
    $probeExit = -1
    $roundtripExit = $null
    $diagnosticParts = [Collections.Generic.List[string]]::new()
    $signalLines = [Collections.Generic.List[string]]::new()

    try {
        if (-not (Test-Path -LiteralPath $input -PathType Leaf)) {
            throw "Corpus input is missing: $input"
        }
        $render = Invoke-CapturedProcess $using:derecomp @(
            'semantic-ir-render-module-readable',
            $input,
            $fidelity,
            $readable,
            $mapping,
            '--semantic-sdk',
            $using:semanticSdk
        ) $using:toolchainRoot
        $probeExit = $render.exit_code
        [void] $diagnosticParts.Add(($render.stderr + $render.stdout).Trim())
        foreach ($line in @(($render.stderr + "`n" + $render.stdout) -split "`r?`n")) {
            if ($line -match '^FAIL\b') { [void] $signalLines.Add($line.Trim()) }
        }

        if ($render.exit_code -eq 0 -and $item.audit_result_code -eq 'POST_RECOMPILE_PLAN') {
            $probeStage = 'RECOMPILE'
            $compile = Invoke-CapturedProcess $using:derecomp @('recompile', $readable, $verify) $using:toolchainRoot
            $probeExit = $compile.exit_code
            [void] $diagnosticParts.Add(($compile.stderr + $compile.stdout).Trim())

            if ($compile.exit_code -eq 0) {
                $probeStage = 'DE_ROUNDTRIP'
                $roundtrip = Invoke-CapturedProcess $using:derecomp @('de-roundtrip', $verify) $using:toolchainRoot
                $roundtripExit = $roundtrip.exit_code
                $probeExit = $roundtrip.exit_code
                [void] $diagnosticParts.Add(($roundtrip.stderr + $roundtrip.stdout).Trim())
            }
            if ($compile.exit_code -eq 0 -and $roundtripExit -eq 0) {
                $probeStage = 'PLAN_VERIFY'
                $plan = Invoke-CapturedProcess $using:derecomp @('plan-verify', $verify) $using:toolchainRoot
                $probeExit = $plan.exit_code
                [void] $diagnosticParts.Add(($plan.stderr + $plan.stdout).Trim())
                foreach ($line in @(($plan.stderr + "`n" + $plan.stdout) -split "`r?`n")) {
                    if ($line -match '^FAIL\b' -or $line -match 'status=MANIFEST_FAILED') {
                        [void] $signalLines.Add($line.Trim())
                    }
                }
            }
        }
    } catch {
        [void] $diagnosticParts.Add("PROBE_EXCEPTION $($_.Exception.Message)")
    } finally {
        foreach ($path in $temporary) {
            Remove-Item -LiteralPath $path -Force -ErrorAction SilentlyContinue
        }
    }

    $signals = @($signalLines | Select-Object -Unique)
    $joinedSignals = $signals -join ' | '
    $category = if ($joinedSignals -match 'RENDER_NAME_METADATA_MIXED_NAME') {
        'MIXED_NAME_METADATA'
    } elseif ($joinedSignals -match 'FIDELITY_RENDER_ORPHAN_PROTOTYPE_PENDING') {
        'ORPHAN_PROTOTYPE'
    } elseif ($joinedSignals -match 'FIDELITY_RENDER_LOOP_PREDICATE_AS_BRANCH' -and
        $joinedSignals -match 'FIDELITY_RENDER_BLOCK_COVERAGE') {
        'LOOP_BLOCK_COVERAGE'
    } elseif ($joinedSignals -match 'READABLE_SOURCE_COMPILE') {
        'READABLE_SOURCE_SYNTAX'
    } elseif ($joinedSignals -match 'LOOP_REGION_ROLE_ALIAS') {
        'POST_RECOMPILE_LOOP_ROLE_ALIAS'
    } else {
        'UNCLASSIFIED'
    }
    $confirmed = $category -ne 'UNCLASSIFIED' -and $probeExit -ne 0
    if ($item.audit_result_code -eq 'BASELINE_READABLE_RENDER') {
        $confirmed = $confirmed -and $probeStage -eq 'RENDER'
    } else {
        $confirmed = $confirmed -and $probeStage -eq 'PLAN_VERIFY' -and $roundtripExit -eq 0
    }

    [pscustomobject]@{
        index = [int] $item.index
        file = $name
        audit_result_code = $item.audit_result_code
        category = $category
        probe_stage = $probeStage
        probe_exit_code = [int] $probeExit
        de_roundtrip_exit_code = $roundtripExit
        confirmed = [bool] $confirmed
        signals = $signals
        diagnostic = @($diagnosticParts | Where-Object { $_ }) -join "`n"
    }
} -ThrottleLimit $ThrottleLimit | Sort-Object index)

Remove-Item -LiteralPath $probeRoot -Force

$auditHashAfter = Get-Sha256 $auditFile
$derecompHashAfter = Get-Sha256 $derecomp
$categories = @($rows | Group-Object category | Sort-Object Name | ForEach-Object {
    [pscustomobject]@{ category = $_.Name; count = $_.Count }
})
$summary = [ordered]@{
    schema_version = 1
    format = 'RENOVICE_SEMANTIC_VIEW_REJECTION_DIAGNOSTICS_V1'
    audit = $auditFile
    audit_sha256 = $auditHashBefore
    audit_stable = $auditHashBefore -eq $auditHashAfter
    derecomp = $derecomp
    derecomp_sha256 = $derecompHashBefore
    derecomp_stable = $derecompHashBefore -eq $derecompHashAfter
    rejected_files = $rows.Count
    confirmed_files = @($rows | Where-Object confirmed).Count
    unconfirmed_files = @($rows | Where-Object { -not $_.confirmed }).Count
    categories = $categories
    started_utc = $startedUtc
    completed_utc = [DateTime]::UtcNow.ToString('o')
}
$report = [ordered]@{
    summary = $summary
    rows = $rows
}
$jsonPath = Join-Path $output 'semantic-view-rejection-diagnostics.json'
$tsvPath = Join-Path $output 'semantic-view-rejection-diagnostics.tsv'
$report | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $jsonPath -Encoding utf8NoBOM
$rows | Select-Object index,file,audit_result_code,category,probe_stage,probe_exit_code,
    de_roundtrip_exit_code,confirmed,@{Name='signals';Expression={$_.signals -join ' | '}} |
    Export-Csv -LiteralPath $tsvPath -Delimiter "`t" -NoTypeInformation -Encoding utf8NoBOM

Write-Output "SEMANTIC_VIEW_REJECTION_DIAGNOSTICS rejected=$($summary.rejected_files) confirmed=$($summary.confirmed_files) unconfirmed=$($summary.unconfirmed_files)"
foreach ($entry in $categories) {
    Write-Output "CATEGORY $($entry.category)=$($entry.count)"
}
Write-Output "JSON $jsonPath SHA256=$(Get-Sha256 $jsonPath)"
Write-Output "TSV  $tsvPath SHA256=$(Get-Sha256 $tsvPath)"

if (-not $summary.audit_stable -or -not $summary.derecomp_stable) {
    throw 'An immutable input changed while rejection diagnostics were running.'
}
if ($summary.unconfirmed_files -ne 0) {
    throw "$($summary.unconfirmed_files) rejected rows did not reproduce with a recognized exact signal."
}
