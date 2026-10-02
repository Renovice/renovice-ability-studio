# Bootstrapper-side gates for the Octavia and Frost packages (2026-09-30).
# Read-only against the bootstrapper repository: each pinned revision is
# exported with `git archive` into -Out, and the stock gate scripts run from
# that export, so the checkers are built from an exact revision. Nothing is
# written to the bootstrapper checkout, the game folder or the OpenWF server.
#
#   -Packages  staged Packages folder (from tests/run_gates.py)
#   -Examples  settings-example folder (Octavia.json, Frost.json)
#   -Out       evidence/work folder. Keep it SHORT (for example
#              %LOCALAPPDATA%\Temp\scg): the exported stock gates build and
#              scan nested CustomScripts trees under it, and std::filesystem
#              and cl.exe fail on paths beyond MAX_PATH (260).
param(
    [Parameter(Mandatory = $true)][string]$Packages,
    [Parameter(Mandatory = $true)][string]$Examples,
    [Parameter(Mandatory = $true)][string]$Out,
    # ADDON_SETTINGS_V1 revision (main DLL d2f22650 was built from c6ceec4;
    # 7028479 changes documentation and the probe bridge only).
    [string]$SettingsRevision = '7028479',
    # Revision of the currently installed DLL 6f100ebc (script packages, no settings).
    [string]$InstalledRevision = '3ca9564'
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$note = Split-Path -Parent $PSScriptRoot
$workspace = $PSScriptRoot
while (-not (Test-Path (Join-Path $workspace 'WORKSPACE.json'))) { $workspace = Split-Path -Parent $workspace }
$bootstrapper = Join-Path $workspace 'repos\runtime\bootstrapper-runtime'
$derecomp = Join-Path $workspace 'repos\toolchains\de-luau-toolchain\bin\derecomp.head.exe'
$Packages = [IO.Path]::GetFullPath($Packages)
$Examples = [IO.Path]::GetFullPath($Examples)
$Out = [IO.Path]::GetFullPath($Out)
New-Item -ItemType Directory -Force -Path $Out | Out-Null

function Export-Revision([string]$Revision, [string[]]$Paths) {
    $root = Join-Path $Out "r$Revision"
    $repo = Join-Path $root 'repos\runtime\bootstrapper-runtime'
    if (Test-Path $root) { Remove-Item -LiteralPath $root -Recurse -Force }
    New-Item -ItemType Directory -Force -Path $repo | Out-Null
    $tar = Join-Path $Out "r$Revision.tar"
    & git -C $bootstrapper archive --format=tar -o $tar $Revision @Paths
    if ($LASTEXITCODE) { throw "git archive $Revision failed" }
    & tar -xf $tar -C $repo
    if ($LASTEXITCODE) { throw "tar $Revision failed" }
    Remove-Item -LiteralPath $tar
    # The gate scripts resolve ..\..\toolchains\de-luau-toolchain\bin\derecomp.exe;
    # provide the committed U44 build (0299da9, c1672d8d...).
    $bin = Join-Path $root 'repos\toolchains\de-luau-toolchain\bin'
    New-Item -ItemType Directory -Force -Path $bin | Out-Null
    Copy-Item -LiteralPath $derecomp -Destination (Join-Path $bin 'derecomp.exe')
    Copy-Item -LiteralPath (Join-Path (Split-Path -Parent $derecomp) 'luau-compile.exe') -Destination $bin
    $full = (& git -C $bootstrapper rev-parse $Revision).Trim()
    return @{ Repo = $repo; Commit = $full }
}

function Invoke-Logged([string]$Name, [scriptblock]$Body) {
    $log = Join-Path $Out "$Name.log"
    # Child stderr (e.g. VsDevCmd's benign vswhere PATH notice) is captured as
    # text; the exit code decides.
    $ErrorActionPreference = 'Continue'
    $output = & $Body 2>&1 | ForEach-Object { $_.ToString() }
    $code = $LASTEXITCODE
    $output | Set-Content -LiteralPath $log -Encoding utf8
    $tail = ($output | Select-Object -Last 1)
    Write-Host ("{0}`t{1}`texit={2}`t{3}" -f $(if ($code -eq 0) { 'PASS' } else { 'FAIL' }), $Name, $code, $tail)
    return $code
}

$failures = 0
$settings = Export-Revision $SettingsRevision @('renovice', 'main.cpp', 'owf_console.hpp',
    'RENOVICE_TOOLCHAIN/settings', 'RENOVICE_TOOLCHAIN/injection')
$installed = Export-Revision $InstalledRevision @('renovice', 'main.cpp', 'owf_console.hpp',
    'RENOVICE_TOOLCHAIN/injection')
Write-Output "INFO`tsettings revision $($settings.Commit)"
Write-Output "INFO`tinstalled revision $($installed.Commit)"

# 1. Stock ADDON_SETTINGS_V1 gate (122 checks, phase2i fixtures) at the settings revision.
$failures += [int](0 -ne (Invoke-Logged 'verify_addon_settings' {
    & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $settings.Repo 'RENOVICE_TOOLCHAIN\settings\verify_addon_settings.ps1')
}))

# 2. verify_script_packages --admit, per package, at both revisions.
foreach ($revision in @(@{ Tag = 'settings'; Export = $settings }, @{ Tag = 'installed'; Export = $installed })) {
    foreach ($package in @('Octavia', 'Frost')) {
        $script = Join-Path $revision.Export.Repo 'RENOVICE_TOOLCHAIN\injection\verify_script_packages.ps1'
        $folder = Join-Path $Packages $package
        $failures += [int](0 -ne (Invoke-Logged "verify_script_packages_admit_$($package)_$($revision.Tag)" {
            & powershell -NoProfile -ExecutionPolicy Bypass -File $script -AdmitPackage $folder
        }))
    }
}

# 3. This note's package gate, compiled against the settings revision's exact sources.
$gateSource = Join-Path $PSScriptRoot 'settings_package_gate.cpp'
$gateBinary = Join-Path $Out 'settings_package_gate.exe'
$gateObjects = Join-Path $Out 'settings-package-gate-obj'
New-Item -ItemType Directory -Force -Path $gateObjects | Out-Null
$compile = @"
`$ErrorActionPreference = 'Stop'
`$vswhere = "`${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
`$vsPath = (& `$vswhere -latest -version "[17.0,18.0)" -products "*" -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath).Trim()
`$vsId = (& `$vswhere -latest -version "[17.0,18.0)" -products "*" -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property instanceId).Trim()
Import-Module (Join-Path `$vsPath "Common7\Tools\Microsoft.VisualStudio.DevShell.dll")
Enter-VsDevShell -VsInstanceId `$vsId -SkipAutomaticLocation -Arch amd64 -HostArch amd64 | Out-Null
Set-Location '$gateObjects'
& cl /nologo /std:c++20 /O2 /W4 /WX /EHsc /DRENOVICE_PACKAGES_OFFLINE_GATE /I '$($settings.Repo)' /Fe:'$gateBinary' '$gateSource' '$(Join-Path $settings.Repo 'renovice\packages.cpp')'
exit `$LASTEXITCODE
"@
$compileScript = Join-Path $Out 'compile_settings_package_gate.ps1'
Set-Content -LiteralPath $compileScript -Value $compile -Encoding utf8
$failures += [int](0 -ne (Invoke-Logged 'settings_package_gate_compile' {
    & powershell -NoProfile -ExecutionPolicy Bypass -File $compileScript
}))
$failures += [int](0 -ne (Invoke-Logged 'settings_package_gate' {
    & $gateBinary (Join-Path $Out 'settings-package-gate-work') $Packages $Examples
}))

if ($failures) { Write-Output "BOOTSTRAPPER GATES FAILED ($failures)"; exit 1 }
Write-Output 'BOOTSTRAPPER GATES PASS'
