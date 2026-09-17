[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $OldAuditPath,

    [Parameter(Mandatory = $true)]
    [string] $NewAuditPath,

    [Parameter(Mandatory = $true)]
    [string] $OutputRoot,

    [string] $ExpectedOldAuditSha256 = '',

    [string] $ExpectedNewAuditSha256 = '',

    [ValidateRange(0, 100000)]
    [int] $ExpectedPreviouslyAcceptedFiles = 315,

    [ValidateRange(0, 100000)]
    [int] $ExpectedPriorRejectedFiles = 30,

    [ValidateRange(0, 100000)]
    [int] $ExpectedNewlyEligibleFiles = 5
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Get-Sha256([string] $Path) {
    return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash
}

function Get-CorpusStateMap([object] $Audit, [string] $Label) {
    $map = @{}
    foreach ($row in @($Audit.evaluated_results)) {
        $file = [string] $row.file
        if (-not $file -or $map.ContainsKey($file)) {
            throw "$Label audit has a missing or repeated evaluated file: $file"
        }
        $map.Add($file, [pscustomobject]@{
            file = $file
            corpus_index = [int] $row.corpus_index
            baseline_status = 'PASS'
            semantic_status = if ([bool] $row.pass) { 'VERIFIED' } else { 'REJECTED' }
            result_code = [string] $row.result_code
            input_sha256 = [string] $row.input_sha256
            diagnostic = [string] $row.diagnostic
        })
    }
    foreach ($row in @($Audit.excluded_baseline_failures)) {
        $file = [string] $row.file
        if (-not $file -or $map.ContainsKey($file)) {
            throw "$Label audit has a missing or repeated excluded file: $file"
        }
        $map.Add($file, [pscustomobject]@{
            file = $file
            corpus_index = [int] $row.corpus_index
            baseline_status = 'FAIL'
            semantic_status = 'NOT_EVALUATED'
            result_code = [string] $row.status
            input_sha256 = ''
            diagnostic = 'Excluded by the selected baseline compiler fixed-point gate.'
        })
    }
    $expected = [int] $Audit.summary.corpus_files
    if ($map.Count -ne $expected) {
        throw "$Label audit contains $($map.Count) corpus identities, expected $expected."
    }
    return $map
}

$oldPath = [IO.Path]::GetFullPath($OldAuditPath)
$newPath = [IO.Path]::GetFullPath($NewAuditPath)
$output = [IO.Path]::GetFullPath($OutputRoot)
foreach ($required in @($oldPath, $newPath)) {
    if (-not (Test-Path -LiteralPath $required -PathType Leaf)) {
        throw "Required semantic audit is missing: $required"
    }
}

$oldHash = Get-Sha256 $oldPath
$newHash = Get-Sha256 $newPath
if ($ExpectedOldAuditSha256 -and $oldHash -ne $ExpectedOldAuditSha256.ToUpperInvariant()) {
    throw "Old audit hash mismatch. Expected $ExpectedOldAuditSha256, found $oldHash."
}
if ($ExpectedNewAuditSha256 -and $newHash -ne $ExpectedNewAuditSha256.ToUpperInvariant()) {
    throw "New audit hash mismatch. Expected $ExpectedNewAuditSha256, found $newHash."
}

$oldAudit = Get-Content -LiteralPath $oldPath -Raw | ConvertFrom-Json
$newAudit = Get-Content -LiteralPath $newPath -Raw | ConvertFrom-Json
if ([int] $oldAudit.summary.corpus_files -ne 360 -or [int] $newAudit.summary.corpus_files -ne 360) {
    throw 'Transition comparison requires two complete 360-row coverage audits.'
}

$oldMap = Get-CorpusStateMap $oldAudit 'Old'
$newMap = Get-CorpusStateMap $newAudit 'New'
$oldNames = @($oldMap.Keys | Sort-Object)
$newNames = @($newMap.Keys | Sort-Object)
if (@(Compare-Object $oldNames $newNames).Count -ne 0) {
    throw 'Old and new semantic audits do not describe the same 360 corpus identities.'
}

$previouslyAccepted = @($oldMap.Values | Where-Object semantic_status -eq 'VERIFIED')
$priorRejected = @($oldMap.Values | Where-Object semantic_status -eq 'REJECTED')
$newlyEligible = @($oldMap.Values | Where-Object baseline_status -eq 'FAIL' | Where-Object {
    $newMap[$_.file].baseline_status -eq 'PASS'
})
$acceptedRegressions = @($previouslyAccepted | Where-Object {
    $newMap[$_.file].semantic_status -ne 'VERIFIED'
})

if ($previouslyAccepted.Count -ne $ExpectedPreviouslyAcceptedFiles) {
    throw "Expected $ExpectedPreviouslyAcceptedFiles previously accepted files, found $($previouslyAccepted.Count)."
}
if ($priorRejected.Count -ne $ExpectedPriorRejectedFiles) {
    throw "Expected $ExpectedPriorRejectedFiles prior semantic rejects, found $($priorRejected.Count)."
}
if ($newlyEligible.Count -ne $ExpectedNewlyEligibleFiles) {
    throw "Expected $ExpectedNewlyEligibleFiles newly eligible files, found $($newlyEligible.Count)."
}

$transitionNames = @(
    @($priorRejected.file)
    @($newlyEligible.file)
) | Sort-Object -Unique
$transitionRows = @($transitionNames | ForEach-Object {
    $file = $_
    $old = $oldMap[$file]
    $new = $newMap[$file]
    $transitionKind = if ($old.baseline_status -eq 'FAIL') {
        if ($new.semantic_status -eq 'VERIFIED') { 'NEWLY_ELIGIBLE_ACCEPTED' }
        else { 'NEWLY_ELIGIBLE_REJECTED' }
    } elseif ($new.semantic_status -eq 'VERIFIED') {
        'PRIOR_REJECT_NOW_ACCEPTED'
    } else {
        'PRIOR_REJECT_STILL_REJECTED'
    }
    [pscustomobject]@{
        corpus_index = [int] $new.corpus_index
        file = $file
        transition = $transitionKind
        old_baseline_status = $old.baseline_status
        old_semantic_status = $old.semantic_status
        old_result_code = $old.result_code
        new_baseline_status = $new.baseline_status
        new_semantic_status = $new.semantic_status
        new_result_code = $new.result_code
        new_input_sha256 = $new.input_sha256
        new_diagnostic = $new.diagnostic
    }
} | Sort-Object corpus_index)

$resultCodes = @($transitionRows | Group-Object new_result_code | Sort-Object Name | ForEach-Object {
    [pscustomobject]@{ code = $_.Name; count = $_.Count }
})
$summary = [ordered]@{
    schema_version = 1
    format = 'RENOVICE_SEMANTIC_VIEW_TRANSITION_V1'
    old_audit = $oldPath
    old_audit_sha256 = $oldHash
    old_compiler_sha256 = [string] $oldAudit.summary.derecomp_sha256
    new_audit = $newPath
    new_audit_sha256 = $newHash
    new_compiler_sha256 = [string] $newAudit.summary.derecomp_sha256
    corpus_files = 360
    old_baseline_pass_files = [int] $oldAudit.summary.baseline_pass_files
    new_baseline_pass_files = [int] $newAudit.summary.baseline_pass_files
    old_semantic_accepted_files = [int] $oldAudit.summary.semantic_view_accepted_files
    new_semantic_accepted_files = [int] $newAudit.summary.semantic_view_accepted_files
    previously_accepted_files = $previouslyAccepted.Count
    accepted_regressions = $acceptedRegressions.Count
    prior_semantic_rejected_files = $priorRejected.Count
    newly_eligible_files = $newlyEligible.Count
    transition_files = $transitionRows.Count
    transition_accepted_files = @($transitionRows | Where-Object new_semantic_status -eq 'VERIFIED').Count
    transition_rejected_files = @($transitionRows | Where-Object new_semantic_status -eq 'REJECTED').Count
    recovered_prior_rejects = @($transitionRows | Where-Object transition -eq 'PRIOR_REJECT_NOW_ACCEPTED').Count
    accepted_newly_eligible = @($transitionRows | Where-Object transition -eq 'NEWLY_ELIGIBLE_ACCEPTED').Count
    new_result_codes = $resultCodes
    completed_utc = [DateTime]::UtcNow.ToString('o')
}
$report = [ordered]@{
    summary = $summary
    accepted_regressions = @($acceptedRegressions | ForEach-Object { $newMap[$_.file] })
    transition_results = $transitionRows
}

if (Test-Path -LiteralPath $output) {
    $existing = @(Get-ChildItem -LiteralPath $output -Force)
    if ($existing.Count -ne 0) {
        throw "Transition output must be absent or empty; refusing to mix evidence: $output"
    }
} else {
    New-Item -ItemType Directory -Path $output | Out-Null
}

$jsonPath = Join-Path $output 'semantic-view-transition.json'
$jsonTemp = "$jsonPath.tmp"
$tsvPath = Join-Path $output 'semantic-view-transition.tsv'
$tsvTemp = "$tsvPath.tmp"
$report | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $jsonTemp -Encoding utf8NoBOM
$transitionRows | Export-Csv -Delimiter "`t" -NoTypeInformation -LiteralPath $tsvTemp -Encoding utf8NoBOM
Move-Item -LiteralPath $jsonTemp -Destination $jsonPath
Move-Item -LiteralPath $tsvTemp -Destination $tsvPath

$summary | Format-List
'REPORT_HASHES'
Get-FileHash -Algorithm SHA256 -LiteralPath $jsonPath, $tsvPath | Select-Object Path, Hash | Format-List

if ($acceptedRegressions.Count -ne 0) {
    throw "Transition audit found $($acceptedRegressions.Count) regressions among previously accepted scripts."
}
