param(
    [string]$OutputPath = (Join-Path $PSScriptRoot '..\..\REGISTRIES\helminth_abilities.tsv')
)

$ErrorActionPreference = 'Stop'
$sourceUrl = 'https://wiki.warframe.com/api.php?action=parse&page=Module%3AAbility%2Fdata&prop=wikitext&format=json&formatversion=2'
$response = Invoke-RestMethod -Uri $sourceUrl -Headers @{
    'User-Agent' = 'RENOVICE-Research/1.0 (private compatibility research)'
} -TimeoutSec 60
$text = [string]$response.parse.wikitext
if ([string]::IsNullOrWhiteSpace($text)) {
    throw 'The Wiki API returned no Module:Ability/data wikitext.'
}

$lines = $text -split "`r?`n"
$rows = [System.Collections.Generic.List[object]]::new()
for ($index = 0; $index -lt $lines.Length; $index++) {
    if ($lines[$index] -notmatch '^\s*\["(?<key>[^"\r\n]+)"\]\s*=\s*\{') {
        continue
    }
    $abilityKey = $Matches.key
    $block = [System.Collections.Generic.List[string]]::new()
    $depth = 0
    do {
        $line = $lines[$index]
        $block.Add($line)
        $depth += ([regex]::Matches($line, '\{')).Count
        $depth -= ([regex]::Matches($line, '\}')).Count
        $index++
    } while ($index -lt $lines.Length -and $depth -gt 0)
    $index--

    $joined = $block -join "`n"
    if ($joined -notmatch '(?m)^\s*Subsumable\s*=\s*true\s*,?\s*$') {
        continue
    }
    $name = if ($joined -match '(?m)^\s*Name\s*=\s*"(?<value>[^"]+)"') { $Matches.value } else { $abilityKey }
    $powersuit = if ($joined -match '(?m)^\s*Powersuit\s*=\s*"(?<value>[^"]+)"') { $Matches.value } else { '' }
    $internalName = if ($joined -match '(?m)^\s*InternalName\s*=\s*"(?<value>[^"]*)"') { $Matches.value } else { '' }
    if ([string]::IsNullOrWhiteSpace($internalName)) {
        continue
    }
    $rows.Add([pscustomobject]@{
        ability_name = $name
        powersuit = $powersuit
        ability_asset_path = $internalName
    })
}

$rows = $rows | Sort-Object ability_asset_path -Unique
if ($rows.Count -lt 40) {
    throw "Parsed only $($rows.Count) subsumable abilities; refusing to replace the registry."
}

$retrieved = [DateTimeOffset]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ')
$output = [System.Collections.Generic.List[string]]::new()
$output.Add("ability_name`tpowersuit`tability_asset_path`tprovenance`tretrieved_at`tsource_url")
foreach ($row in $rows) {
    $output.Add("$($row.ability_name)`t$($row.powersuit)`t$($row.ability_asset_path)`tWIKI_MODULE_ABILITY_DATA`t$retrieved`t$sourceUrl")
}

$absolute = [IO.Path]::GetFullPath($OutputPath)
[IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($absolute)) | Out-Null
$temporary = $absolute + '.tmp'
[IO.File]::WriteAllLines($temporary, $output, [Text.UTF8Encoding]::new($false))
[IO.File]::Move($temporary, $absolute, $true)
Write-Output "PASS wrote $($rows.Count) exact InternalName rows to $absolute"
