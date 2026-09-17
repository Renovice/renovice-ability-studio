[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $AuditPath,

    [Parameter(Mandatory = $true)]
    [string] $OutputPath,

    [ValidateRange(1, 100000)]
    [int] $ExpectedScripts = 360
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Get-Sha256([string] $Path) {
    return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash
}

function Get-TextSha256([string] $Text) {
    $bytes = [Text.Encoding]::UTF8.GetBytes($Text)
    $hash = [Security.Cryptography.SHA256]::HashData($bytes)
    return [Convert]::ToHexString($hash)
}

$auditFile = [IO.Path]::GetFullPath($AuditPath)
$outputFile = [IO.Path]::GetFullPath($OutputPath)
if (-not (Test-Path -LiteralPath $auditFile -PathType Leaf)) {
    throw "Corpus audit is missing: $auditFile"
}
$audit = Get-Content -LiteralPath $auditFile -Raw | ConvertFrom-Json
if ([int] $audit.summary.schema_version -ne 4 -or
    [string] $audit.summary.format -ne 'RENOVICE_SEMANTIC_VIEW_CORPUS360_COVERAGE_V4') {
    throw 'API callsite aggregation requires a schema-4 six-artifact corpus audit.'
}
if ([int] $audit.summary.corpus_files -ne $ExpectedScripts -or
    [int] $audit.summary.semantic_view_accepted_files -ne $ExpectedScripts -or
    [int] $audit.summary.semantic_view_rejected_files -ne 0) {
    throw "Expected $ExpectedScripts accepted scripts and zero rejects."
}

$auditRoot = Split-Path -Parent $auditFile
$callMaps = @($audit.evaluated_results | Where-Object pass | ForEach-Object {
    $stem = [IO.Path]::GetFileNameWithoutExtension([string] $_.file)
    $path = Join-Path $auditRoot "$stem.calls.tsv"
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Accepted script is missing its API callsite map: $path"
    }
    Get-Item -LiteralPath $path
} | Sort-Object Name)
if ($callMaps.Count -ne $ExpectedScripts) {
    throw "Expected $ExpectedScripts call maps; found $($callMaps.Count)."
}

$allRows = [Collections.Generic.List[object]]::new()
$scriptsWithCalls = 0
$scriptsWithoutCalls = 0
$manifestLines = [Collections.Generic.List[string]]::new()
foreach ($map in $callMaps) {
    $hash = Get-Sha256 $map.FullName
    $manifestLines.Add("$($map.Name)`t$hash")
    $rows = @(Import-Csv -LiteralPath $map.FullName -Delimiter "`t")
    if ($rows.Count -eq 0) { $scriptsWithoutCalls++ } else { $scriptsWithCalls++ }
    $identities = @($rows | ForEach-Object { "$($_.prototype):$($_.instruction):$($_.source_occurrence)" } | Sort-Object -Unique)
    if ($identities.Count -ne $rows.Count) {
        throw "Duplicate (prototype, instruction, source_occurrence) identity in $($map.Name)."
    }
    foreach ($identityGroup in @($rows | Group-Object prototype, instruction)) {
        $occurrences = @($identityGroup.Group | ForEach-Object { [int] $_.source_occurrence } | Sort-Object)
        for ($index = 0; $index -lt $occurrences.Count; $index++) {
            if ($occurrences[$index] -ne $index) {
                throw "Non-contiguous source occurrences in $($map.Name), group=$($identityGroup.Name)."
            }
        }
    }
    foreach ($row in $rows) {
        if ([string] $row.schema_version -ne '2') {
            throw "Unsupported callsite row schema in $($map.Name)."
        }
        if ([string] $row.contract_match -eq 'CONFIRMED_MISMATCH') {
            throw "Confirmed contract violation in $($map.Name), prototype=$($row.prototype), instruction=$($row.instruction)."
        }
        $registered = -not [string]::IsNullOrEmpty([string] $row.descriptor)
        $descriptorlessMatch = [string] $row.contract_match -in @('UNREGISTERED', 'AMBIGUOUS')
        if ($registered -eq $descriptorlessMatch) {
            throw "Descriptor/contract-match state disagrees in $($map.Name)."
        }
        $allRows.Add($row)
    }
}

$rowsArray = @($allRows)
$callsiteRows = @($rowsArray | Where-Object { [int] $_.source_occurrence -eq 0 })
$registeredRows = @($callsiteRows | Where-Object { -not [string]::IsNullOrEmpty([string] $_.descriptor) })
$unregisteredRows = @($callsiteRows | Where-Object { [string]::IsNullOrEmpty([string] $_.descriptor) })
$group = {
    param([object[]] $Rows, [string] $Property)
    return @($Rows | Group-Object $Property | Sort-Object `
        @{ Expression = 'Count'; Descending = $true }, `
        @{ Expression = 'Name'; Descending = $false } | ForEach-Object {
        [ordered]@{ value = $_.Name; count = $_.Count }
    })
}
$summary = [ordered]@{
    schema_version = 2
    format = 'RENOVICE_API_CALLSITE_CORPUS360_AGGREGATE_V2'
    corpus_audit = $auditFile
    corpus_audit_sha256 = Get-Sha256 $auditFile
    call_map_manifest_sha256 = Get-TextSha256 (($manifestLines -join "`n") + "`n")
    scripts = $callMaps.Count
    scripts_with_calls = $scriptsWithCalls
    scripts_without_calls = $scriptsWithoutCalls
    callsites = $callsiteRows.Count
    call_expressions = $rowsArray.Count
    registered_callsites = $registeredRows.Count
    confirmed_callsites = @($callsiteRows | Where-Object contract_status -eq 'CONFIRMED').Count
    unresolved_callsites = @($callsiteRows | Where-Object contract_status -eq 'UNRESOLVED').Count
    unregistered_callsites = $unregisteredRows.Count
    ambiguous_callsites = @($callsiteRows | Where-Object contract_match -eq 'AMBIGUOUS').Count
    observed_contract_mismatches = @($callsiteRows | Where-Object contract_match -eq 'OBSERVED_MISMATCH').Count
    receiver_typed_joins = @($callsiteRows | Where-Object descriptor_join -eq 'RECEIVER_TYPE').Count
    unique_method_name_candidates = @($callsiteRows | Where-Object descriptor_join -eq 'UNIQUE_METHOD_NAME').Count
    receiver_type_conflicts = @($callsiteRows | Where-Object descriptor_join -eq 'RECEIVER_TYPE_CONFLICT').Count
    confirmed_contract_violations = 0
    unique_descriptors = @($registeredRows.descriptor | Sort-Object -Unique).Count
    unique_static_names = @($callsiteRows | Where-Object name | Select-Object -ExpandProperty name | Sort-Object -Unique).Count
    kind_counts = & $group $callsiteRows 'kind'
    descriptor_join_counts = & $group $callsiteRows 'descriptor_join'
    contract_match_counts = & $group $callsiteRows 'contract_match'
    contract_status_counts = & $group $registeredRows 'contract_status'
    contract_confidence_counts = & $group $registeredRows 'contract_confidence'
}

$parent = Split-Path -Parent $outputFile
if ($parent) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
$temporary = "$outputFile.tmp"
$summary | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $temporary -Encoding utf8NoBOM
Move-Item -LiteralPath $temporary -Destination $outputFile -Force
$summary | Format-List
Get-FileHash -Algorithm SHA256 -LiteralPath $outputFile | Format-List
