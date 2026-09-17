[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $AuditPath,

    [Parameter(Mandatory = $true)]
    [string] $EvidenceTsvPath,

    [Parameter(Mandatory = $true)]
    [string] $SummaryJsonPath,

    [ValidateRange(1, 100000)]
    [int] $ExpectedScripts = 360,

    [ValidateRange(1, 100000)]
    [int] $ExpectedTargetRows = 189
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Get-Sha256([string] $Path) {
    return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash
}

function Get-GroupCounts([object[]] $Rows, [string] $Property) {
    return @($Rows | Group-Object $Property | Sort-Object `
        @{ Expression = 'Count'; Descending = $true }, `
        @{ Expression = 'Name'; Descending = $false } | ForEach-Object {
        [ordered]@{ value = $_.Name; count = $_.Count }
    })
}

$auditFile = [IO.Path]::GetFullPath($AuditPath)
$evidenceFile = [IO.Path]::GetFullPath($EvidenceTsvPath)
$summaryFile = [IO.Path]::GetFullPath($SummaryJsonPath)
if (-not (Test-Path -LiteralPath $auditFile -PathType Leaf)) {
    throw "Corpus audit is missing: $auditFile"
}
$audit = Get-Content -LiteralPath $auditFile -Raw | ConvertFrom-Json
if ([int] $audit.summary.schema_version -ne 4 -or
    [string] $audit.summary.format -ne 'RENOVICE_SEMANTIC_VIEW_CORPUS360_COVERAGE_V4' -or
    [int] $audit.summary.corpus_files -ne $ExpectedScripts -or
    [int] $audit.summary.semantic_view_accepted_files -ne $ExpectedScripts -or
    [int] $audit.summary.semantic_view_rejected_files -ne 0) {
    throw "Expected a complete schema-4 audit with $ExpectedScripts accepted scripts and zero rejects."
}

$observedShapes = [ordered]@{
    ApplyCustomization = @(1)
    SetPosition = @(1)
    PlaySound = @(2, 3, 4, 5, 6, 8)
    Execute = @(2)
    GetCustomization = @(0, 1)
    GetUpgradeModifiedValue = @(2, 4, 5)
}
$damageIdentities = @{
    'Lotus_Interface_LoadOutRedux|99|440' = $true
    'Lotus_Interface_LotusUtilities|493|29' = $true
    'Lotus_Interface_LotusUtilities|493|31' = $true
}

$auditRoot = Split-Path -Parent $auditFile
$evidenceRows = [Collections.Generic.List[object]]::new()
foreach ($result in @($audit.evaluated_results | Where-Object pass | Sort-Object file)) {
    $stem = [IO.Path]::GetFileNameWithoutExtension([string] $result.file)
    $callMap = Join-Path $auditRoot "$stem.calls.tsv"
    $readable = Join-Path $auditRoot "$stem.luau"
    foreach ($required in @($callMap, $readable)) {
        if (-not (Test-Path -LiteralPath $required -PathType Leaf)) {
            throw "Target-form audit input is missing: $required"
        }
    }
    $readableBytes = [IO.File]::ReadAllBytes($readable)
    foreach ($row in @(Import-Csv -LiteralPath $callMap -Delimiter "`t")) {
        if ([string] $row.schema_version -ne '2') {
            throw "Unsupported callsite row schema in $callMap."
        }
        if ([int] $row.source_occurrence -ne 0) { continue }
        $subject = $null
        $shapeClass = $null
        if ([string] $row.kind -eq 'method' -and $observedShapes.Contains([string] $row.name)) {
            $arity = [int] $row.explicit_argument_count
            if ($arity -lt 0 -or $arity -notin $observedShapes[[string] $row.name]) {
                $subject = [string] $row.name
                $shapeClass = if ($arity -lt 0) { 'OPEN_ARGUMENTS' } else { 'OUTSIDE_OBSERVED_EXACT_SET' }
            }
        }
        if (-not $subject -and
            ([string] $row.kind) -eq 'method' -and
            ([string] $row.contract_match) -eq 'OBSERVED_MISMATCH') {
            $subject = [string] $row.name
            $shapeClass = 'OUTSIDE_OBSERVED_EXACT_SET'
        }
        $damageKey = "$stem|$($row.prototype)|$($row.instruction)"
        if ([string] $row.name -eq 'DamageControl' -and $damageIdentities.ContainsKey($damageKey)) {
            if ($subject) { throw "DamageControl identity unexpectedly overlaps an outside-shape subject: $damageKey" }
            $subject = 'DamageControlResolution'
            $shapeClass = 'PREVIOUSLY_NAME_AMBIGUOUS'
        }
        if (-not $subject) { continue }

        $offset = [int] $row.readable_offset
        $length = [int] $row.readable_length
        if ($offset -lt 0 -or $length -le 0 -or $offset + $length -gt $readableBytes.Length) {
            throw "Invalid readable byte span in $callMap, prototype=$($row.prototype), instruction=$($row.instruction)."
        }
        $expression = [Text.Encoding]::UTF8.GetString($readableBytes, $offset, $length)
        if ([string]::IsNullOrWhiteSpace($expression)) {
            throw "Readable byte span is empty in $callMap, prototype=$($row.prototype), instruction=$($row.instruction)."
        }
        $evidenceRows.Add([pscustomobject][ordered]@{
            subject = $subject
            shape_class = $shapeClass
            module = $stem
            prototype = [int] $row.prototype
            instruction = [int] $row.instruction
            kind = [string] $row.kind
            name = [string] $row.name
            explicit_argument_count = [int] $row.explicit_argument_count
            open_arguments = [string] $row.open_arguments
            receiver_web = [int] $row.receiver_web
            receiver_type = [string] $row.receiver_type
            receiver_type_confidence = [string] $row.receiver_type_confidence
            receiver_type_evidence = [string] $row.receiver_type_evidence
            descriptor_join = [string] $row.descriptor_join
            descriptor = [string] $row.descriptor
            contract_confidence = [string] $row.contract_confidence
            contract_status = [string] $row.contract_status
            contract_match = [string] $row.contract_match
            readable_line = [int] $row.readable_line
            readable_column = [int] $row.readable_column
            readable_expression = $expression
        })
    }
}

$rows = @($evidenceRows | Sort-Object subject, module, prototype, instruction)
if ($rows.Count -ne $ExpectedTargetRows) {
    throw "Expected $ExpectedTargetRows target evidence rows; found $($rows.Count)."
}
$damageRows = @($rows | Where-Object subject -eq 'DamageControlResolution')
if ($damageRows.Count -ne 3 -or @($damageRows | Where-Object {
        $_.receiver_type -ne 'Avatar' -or
        $_.descriptor_join -ne 'RECEIVER_TYPE' -or
        $_.descriptor -ne 'lua:method:Avatar:DamageControl' -or
        $_.contract_match -ne 'MATCH'
    }).Count -ne 0) {
    throw 'The three pinned DamageControl calls were not all resolved to the confirmed Avatar contract by receiver evidence.'
}

$evidenceParent = Split-Path -Parent $evidenceFile
$summaryParent = Split-Path -Parent $summaryFile
if ($evidenceParent) { New-Item -ItemType Directory -Path $evidenceParent -Force | Out-Null }
if ($summaryParent) { New-Item -ItemType Directory -Path $summaryParent -Force | Out-Null }
$temporaryEvidence = "$evidenceFile.tmp"
$rows | Export-Csv -LiteralPath $temporaryEvidence -Delimiter "`t" -NoTypeInformation -Encoding utf8NoBOM
Move-Item -LiteralPath $temporaryEvidence -Destination $evidenceFile -Force

$reviewRows = @($rows | Where-Object subject -ne 'DamageControlResolution')
$mismatchRows = @($reviewRows | Where-Object shape_class -eq 'OUTSIDE_OBSERVED_EXACT_SET')
$openRows = @($reviewRows | Where-Object shape_class -eq 'OPEN_ARGUMENTS')
$summary = [ordered]@{
    schema_version = 1
    format = 'RENOVICE_TARGET_API_FORM_EVIDENCE_V1'
    corpus_audit = $auditFile
    corpus_audit_sha256 = Get-Sha256 $auditFile
    evidence_tsv = $evidenceFile
    evidence_tsv_sha256 = Get-Sha256 $evidenceFile
    scripts = $ExpectedScripts
    target_rows = $rows.Count
    reviewed_contract_rows = $reviewRows.Count
    observed_mismatch_rows = $mismatchRows.Count
    selected_open_argument_rows = $openRows.Count
    damagecontrol_resolution_rows = $damageRows.Count
    hypotheses = @(
        [ordered]@{
            hypothesis = 'The three pinned name-ambiguous DamageControl calls have an independently refined Avatar receiver.'
            result = 'TRUE'
            evidence_rows = $damageRows.Count
            limitation = 'This establishes the receiver and selects the existing confirmed zero-argument Avatar contract at those three instructions only.'
        },
        [ordered]@{
            hypothesis = 'Every observed mismatch or selected open-width call is sufficient evidence for a new deep API overload.'
            result = 'FALSE'
            evidence_rows = $reviewRows.Count
            limitation = 'The rows preserve exact stock call shape and receiver evidence; unique-name joins, receiver conflicts, and open arguments do not prove parameter meaning, return type, or side effects.'
        }
    )
    subject_counts = Get-GroupCounts $rows 'subject'
    shape_class_counts = Get-GroupCounts $rows 'shape_class'
    descriptor_join_counts = Get-GroupCounts $rows 'descriptor_join'
    contract_match_counts = Get-GroupCounts $rows 'contract_match'
    receiver_type_counts = Get-GroupCounts $rows 'receiver_type'
}
$temporarySummary = "$summaryFile.tmp"
$summary | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $temporarySummary -Encoding utf8NoBOM
Move-Item -LiteralPath $temporarySummary -Destination $summaryFile -Force
$summary | Format-List
Get-FileHash -Algorithm SHA256 -LiteralPath $evidenceFile, $summaryFile | Format-Table Path,Hash -AutoSize
