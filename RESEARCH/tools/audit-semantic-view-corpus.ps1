[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $ProjectRoot,

    [Parameter(Mandatory = $true)]
    [string] $OutputRoot,

    [Parameter(Mandatory = $true)]
    [string] $InventoryPath,

    [ValidateRange(1, 16)]
    [int] $ThrottleLimit = 4,

    [ValidateRange(1, 100000)]
    [int] $ExpectedCorpusFiles = 360,

    [ValidateRange(-1, 100000)]
    [int] $ExpectedBaselinePassFiles = -1,

    [string] $ExpectedInventorySha256 = '',

    [string] $ExpectedCompilerSha256 = '',

    [string] $ExpectedAbilityCliSha256 = ''
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Get-Sha256([string] $Path) {
    return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash
}

$project = [IO.Path]::GetFullPath($ProjectRoot)
$output = [IO.Path]::GetFullPath($OutputRoot)
$abilityRepo = Join-Path $project 'repos\apps\ability-editor'
$toolchain = Join-Path $project 'repos\toolchains\de-luau-toolchain'
$compiler = Join-Path $toolchain 'bin\derecomp.exe'
$abilityCli = Join-Path $project 'work\builds\ability-editor\current\bin\renovice_ability_editor_cli.exe'
$corpus = Join-Path $project 'shared\corpus\de-luau-stock'
$inventoryFile = [IO.Path]::GetFullPath($InventoryPath)

foreach ($required in @($abilityRepo, $toolchain, $compiler, $abilityCli, $corpus, $inventoryFile)) {
    if (-not (Test-Path -LiteralPath $required)) {
        throw "Required audit input is missing: $required"
    }
}

if (Test-Path -LiteralPath $output) {
    $existing = @(Get-ChildItem -LiteralPath $output -Force)
    if ($existing.Count -ne 0) {
        throw "Audit output must be absent or empty; refusing to mix evidence: $output"
    }
} else {
    New-Item -ItemType Directory -Path $output | Out-Null
}

$abilityCliPre = Get-Sha256 $abilityCli
$compilerPre = Get-Sha256 $compiler
$inventoryPre = Get-Sha256 $inventoryFile
if ($ExpectedAbilityCliSha256 -and $abilityCliPre -ne $ExpectedAbilityCliSha256.ToUpperInvariant()) {
    throw "Ability CLI hash mismatch. Expected $ExpectedAbilityCliSha256, found $abilityCliPre."
}
if ($ExpectedCompilerSha256 -and $compilerPre -ne $ExpectedCompilerSha256.ToUpperInvariant()) {
    throw "Compiler hash mismatch. Expected $ExpectedCompilerSha256, found $compilerPre."
}
if ($ExpectedInventorySha256 -and $inventoryPre -ne $ExpectedInventorySha256.ToUpperInvariant()) {
    throw "Inventory hash mismatch. Expected $ExpectedInventorySha256, found $inventoryPre."
}

$inventory = Get-Content -LiteralPath $inventoryFile -Raw | ConvertFrom-Json
$inventoryRows = @($inventory.cycle2)
$rows = @($inventoryRows | Where-Object passed)
$baselineFailures = @($inventoryRows | Where-Object { -not $_.passed })
$inventoryBinary = ([string] $inventory.binary_sha256).ToUpperInvariant()
$inventoryMode = [string] $inventory.decompile_mode
if ($inventoryBinary -notmatch '^[0-9A-F]{64}$') {
    throw "Pinned inventory does not contain a valid binary_sha256: $inventoryFile"
}
if ($inventoryBinary -ne $compilerPre) {
    throw "Pinned inventory was produced by $inventoryBinary, but the current compiler is $compilerPre."
}
if ([string]::IsNullOrWhiteSpace($inventoryMode)) {
    throw "Pinned inventory does not declare decompile_mode: $inventoryFile"
}
if ($inventoryRows.Count -ne $ExpectedCorpusFiles) {
    throw "Expected corpus=$ExpectedCorpusFiles; found corpus=$($inventoryRows.Count)."
}
if ($ExpectedBaselinePassFiles -ge 0 -and $rows.Count -ne $ExpectedBaselinePassFiles) {
    throw "Expected baseline-pass=$ExpectedBaselinePassFiles; found pass=$($rows.Count), fail=$($baselineFailures.Count)."
}
if (([int] $inventory.cycle2_summary.files) -ne $inventoryRows.Count -or
    ([int] $inventory.cycle2_summary.passed) -ne $rows.Count -or
    ([int] $inventory.cycle2_summary.errors) -ne 0) {
    throw "Pinned inventory cycle2 summary disagrees with its rows or contains errors."
}
$uniqueFiles = @($inventoryRows.file | Sort-Object -Unique)
if ($uniqueFiles.Count -ne $inventoryRows.Count) {
    throw "Pinned inventory contains duplicate file names: rows=$($inventoryRows.Count), unique=$($uniqueFiles.Count)."
}

$corpusIndexes = @{}
for ($index = 0; $index -lt $inventoryRows.Count; $index++) {
    $corpusIndexes.Add([string] $inventoryRows[$index].file, $index)
}
$indexedRows = for ($index = 0; $index -lt $rows.Count; $index++) {
    $file = [string] $rows[$index].file
    [pscustomobject]@{
        Index = $index
        CorpusIndex = [int] $corpusIndexes[$file]
        File = $file
    }
}
$excludedBaselineFailures = @(for ($index = 0; $index -lt $inventoryRows.Count; $index++) {
    $row = $inventoryRows[$index]
    if ($row.passed) { continue }
    [pscustomobject]@{
        corpus_index = $index
        file = [string] $row.file
        status = 'BASELINE_COMPILER_PARITY_REQUIRED'
        bytecode_fixed_at_cycle_1 = [bool] $row.bytecode_fixed_at_cycle_1
        source_fixed_at_cycle_1 = [bool] $row.source_fixed_at_cycle_1
        structural_fixed_at_cycle_1 = [bool] $row.structural_fixed_at_cycle_1
        stable_through_requested_cycle = [bool] $row.stable_through_requested_cycle
    }
})
$startedUtc = [DateTime]::UtcNow.ToString('o')

$results = @($indexedRows | ForEach-Object -Parallel {
    $row = $_
    $inputPath = Join-Path $using:corpus $row.File
    $stem = [IO.Path]::GetFileNameWithoutExtension($row.File)
    $readablePath = Join-Path $using:output "$stem.luau"
    $arguments = @(
        'render-source',
        '--toolchain', $using:toolchain,
        '--bytecode', $inputPath,
        '--output', $readablePath,
        '--editor-root', $using:abilityRepo
    )
    $lines = @(& $using:abilityCli @arguments 2>&1 | ForEach-Object { $_.ToString() })
    $exitCode = $LASTEXITCODE
    $diagnostic = $lines -join "`n"

    # Keep these as six explicit strings. An earlier ad-hoc audit accidentally
    # concatenated an expression array and falsely reported successful renders.
    $artifactNames = @(
        "$stem.luau",
        "$stem.fidelity.luau",
        "$stem.names.tsv",
        "$stem.calls.tsv",
        "$stem.closures.tsv",
        "$stem.semantic-view.json"
    )
    $artifacts = @(foreach ($name in $artifactNames) {
        $path = Join-Path $using:output $name
        $exists = Test-Path -LiteralPath $path
        [pscustomobject]@{
            name = $name
            exists = $exists
            bytes = if ($exists) { (Get-Item -LiteralPath $path).Length } else { 0 }
            sha256 = if ($exists) { (Get-FileHash -Algorithm SHA256 -LiteralPath $path).Hash } else { $null }
        }
    })
    $artifactsComplete = @($artifacts | Where-Object { -not $_.exists }).Count -eq 0
    $resultCode = if ($exitCode -eq 0 -and $artifactsComplete) {
        'PASS'
    } elseif ($diagnostic.Contains('semantic-ir-render-module-readable failed', [StringComparison]::Ordinal)) {
        'BASELINE_READABLE_RENDER'
    } elseif (
        $diagnostic.Contains('LOOP_REGION_ROLE_ALIAS', [StringComparison]::Ordinal) -or
        $diagnostic.Contains('failed semantic plan verification', [StringComparison]::OrdinalIgnoreCase) -or
        $diagnostic.Contains('plan verification failed', [StringComparison]::OrdinalIgnoreCase) -or
        $diagnostic.Contains('plan-verify', [StringComparison]::OrdinalIgnoreCase)
    ) {
        'POST_RECOMPILE_PLAN'
    } elseif ($exitCode -eq 0 -and -not $artifactsComplete) {
        'INCOMPLETE_ARTIFACT_SET'
    } else {
        'TRANSACTION_REJECTED'
    }

    [pscustomobject]@{
        index = [int] $row.Index
        corpus_index = [int] $row.CorpusIndex
        file = [string] $row.File
        input_sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $inputPath).Hash
        pass = ($resultCode -eq 'PASS')
        exit_code = [int] $exitCode
        result_code = $resultCode
        artifacts_complete = $artifactsComplete
        artifacts = $artifacts
        diagnostic = $diagnostic
    }
} -ThrottleLimit $ThrottleLimit | Sort-Object index)

$abilityCliPost = Get-Sha256 $abilityCli
$compilerPost = Get-Sha256 $compiler
$inventoryPost = Get-Sha256 $inventoryFile
$temporaryFiles = @(Get-ChildItem -LiteralPath $output -File | Where-Object {
    $_.Name -match '\.(tmp|bak)(\.|$)' -or $_.Name -match '\.transaction-'
})
$retainedArtifacts = @($results.artifacts | Where-Object exists)
$codes = @($results | Group-Object result_code | Sort-Object Name | ForEach-Object {
    [pscustomobject]@{ code = $_.Name; count = $_.Count }
})

$summary = [ordered]@{
    schema_version = 4
    format = 'RENOVICE_SEMANTIC_VIEW_CORPUS360_COVERAGE_V4'
    inventory = $inventoryFile
    inventory_sha256 = $inventoryPre
    inventory_stable = $inventoryPre -eq $inventoryPost
    inventory_decompile_mode = $inventoryMode
    inventory_binary_sha256 = $inventoryBinary
    corpus_files = $inventoryRows.Count
    unique_corpus_files = $uniqueFiles.Count
    baseline_pass_files = $rows.Count
    baseline_fail_files = $excludedBaselineFailures.Count
    semantic_view_evaluated_files = $results.Count
    semantic_view_accepted_files = @($results | Where-Object pass).Count
    semantic_view_rejected_files = @($results | Where-Object { -not $_.pass }).Count
    total_corpus_verified_files = @($results | Where-Object pass).Count
    total_corpus_unverified_files = $excludedBaselineFailures.Count + @($results | Where-Object { -not $_.pass }).Count
    total_corpus_verified_percent = [Math]::Round(100.0 * @($results | Where-Object pass).Count / $inventoryRows.Count, 6)
    result_codes = $codes
    retained_artifacts = $retainedArtifacts.Count
    expected_retained_artifacts = 6 * @($results | Where-Object pass).Count
    ability_cli_sha256 = $abilityCliPre
    ability_cli_stable = $abilityCliPre -eq $abilityCliPost
    derecomp_sha256 = $compilerPre
    derecomp_stable = $compilerPre -eq $compilerPost
    global_temporary_files = $temporaryFiles.Count
    started_utc = $startedUtc
    completed_utc = [DateTime]::UtcNow.ToString('o')
}
$report = [ordered]@{
    summary = $summary
    evaluated_results = $results
    excluded_baseline_failures = $excludedBaselineFailures
}
$reportPath = Join-Path $output 'corpus360-coverage-audit.json'
$reportTemp = "$reportPath.tmp"
$tsvPath = Join-Path $output 'corpus360-coverage-audit.tsv'
$tsvTemp = "$tsvPath.tmp"
$report | ConvertTo-Json -Depth 9 | Set-Content -LiteralPath $reportTemp -Encoding utf8NoBOM
$coverageRows = @(
    $results | ForEach-Object {
        [pscustomobject]@{
            corpus_index = $_.corpus_index
            file = $_.file
            baseline_status = 'PASS'
            semantic_view_status = if ($_.pass) { 'VERIFIED' } else { 'REJECTED' }
            result_code = $_.result_code
            input_sha256 = $_.input_sha256
            diagnostic = $_.diagnostic
        }
    }
    $excludedBaselineFailures | ForEach-Object {
        [pscustomobject]@{
            corpus_index = $_.corpus_index
            file = $_.file
            baseline_status = 'FAIL'
            semantic_view_status = 'NOT_EVALUATED'
            result_code = $_.status
            input_sha256 = ''
            diagnostic = 'Excluded before semantic-view rendering because the baseline compiler fixed-point gate failed.'
        }
    }
)
$coverageRows | Sort-Object corpus_index |
    Export-Csv -Delimiter "`t" -NoTypeInformation -LiteralPath $tsvTemp -Encoding utf8NoBOM
Move-Item -LiteralPath $reportTemp -Destination $reportPath
Move-Item -LiteralPath $tsvTemp -Destination $tsvPath

$summary | Format-List
'REPORT_HASHES'
Get-FileHash -Algorithm SHA256 -LiteralPath $reportPath, $tsvPath | Select-Object Path, Hash | Format-List

if (-not $summary.ability_cli_stable -or -not $summary.derecomp_stable -or -not $summary.inventory_stable) {
    throw 'Audit binaries or inventory changed during the run; the report is retained as invalid evidence.'
}
if ($summary.global_temporary_files -ne 0) {
    throw "Audit left $($summary.global_temporary_files) temporary files."
}
if ($summary.retained_artifacts -ne $summary.expected_retained_artifacts) {
    throw "Retained artifact count mismatch: expected $($summary.expected_retained_artifacts), found $($summary.retained_artifacts)."
}
