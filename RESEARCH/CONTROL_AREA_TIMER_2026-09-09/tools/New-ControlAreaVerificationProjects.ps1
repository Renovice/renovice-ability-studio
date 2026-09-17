param(
    [string]$EditorRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
)

$templatePath = Join-Path $EditorRoot 'EXAMPLES\mallet_linked_overguard_addon.json'
$outputRoot = Join-Path $PSScriptRoot '..\projects'
New-Item -ItemType Directory -Force -Path $outputRoot | Out-Null

$specifications = @(
    [ordered]@{
        Id = 'control_area_plains'
        DisplayName = 'Control Area (Plains)'
        Identifier = 'CONTROL_AREA_PLAINS_TIMER_PATCH'
        ModulePath = 'Lotus.Scripts.Eidolon.Encounters.DynamicDefend'
        BodyKey = 'bf3c901cb4058c47'
        Evidence = 'WF-CONTROL-AREA-PLAINS-DURATION-OWNERS-2026-09-09'
        Generation = [ordered]@{
            template = 'MISSION_CONTROL_AREA_PLAINS_TIMER_TARGET'
            hook_binding = 'renovice.target.lua_call'
            state_prototype = 8
            state_duration_upvalue = 7
            pacing_prototype = 1
            pacing_duration_upvalue = 5
            pacing_baseline_upvalue = 6
            stock_duration_seconds = 90
            duration_seconds = 45
        }
    },
    [ordered]@{
        Id = 'control_area_deimos'
        DisplayName = 'Control Area (Deimos)'
        Identifier = 'CONTROL_AREA_DEIMOS_TIMER_PATCH'
        ModulePath = 'Lotus.Scripts.InfestedMicroplanet.Encounters.DynamicAreaDefense'
        BodyKey = 'd9541341dfd466a3'
        Evidence = 'WF-CONTROL-AREA-DEIMOS-DURATION-OWNERS-2026-09-09'
        Generation = [ordered]@{
            template = 'MISSION_CONTROL_AREA_DEIMOS_TIMER_TARGET'
            hook_binding = 'renovice.target.lua_call'
            state_prototype = 7
            state_duration_upvalue = 12
            mission_prototype = 9
            pacing_threshold_upvalue = 14
            stock_duration_seconds = 90
            stock_pacing_threshold_seconds = 60
            duration_seconds = 45
        }
    },
    [ordered]@{
        Id = 'control_area_nokko'
        DisplayName = 'Control Area (Venus/Nokko)'
        Identifier = 'CONTROL_AREA_NOKKO_TIMER_PATCH'
        ModulePath = 'Lotus.Scripts.Venus.NokkoColony.Encounters.AreaDefense'
        BodyKey = 'e192d5cc2f37056e'
        Evidence = 'WF-CONTROL-AREA-NOKKO-DEFEND-TIME-OWNER-2026-09-09'
        Generation = [ordered]@{
            template = 'MISSION_CONTROL_AREA_NOKKO_TIMER_TARGET'
            hook_binding = 'renovice.target.lua_call'
            initialization_prototype = 6
            duration_global = 'defendTime'
            duration_seconds = 45
        }
    }
)

foreach ($specification in $specifications) {
    $project = Get-Content -Raw -LiteralPath $templatePath | ConvertFrom-Json
    $project.id = "mission.$($specification.Id).timers.addon"
    $project.authoring_mode = 'MANAGED_MISSION_ADDON'
    $project.mode_reason = 'Exact target addon changes the verified stock timer owner while retaining the native mission module and lifecycle.'
    $project.target.warframe = 'Mission'
    $project.target.ability = "$($specification.DisplayName) Timers"
    $project.target.ability_identifier = $specification.Identifier
    $project.target.ability_localize_tag = $null
    $project.target.module_path = $specification.ModulePath
    $project.target.module_body_key = $specification.BodyKey
    $project.target.installed_build = 'packages-bin-data-2026-07-01'
    $project.effect.summary = 'Set the Control Area duration to 45 seconds through its exact stock owner.'
    $project.effect.owner = 'ADDON'
    $project.effect.hook = 'renovice.target.lua_call'
    $project.effect.hook_evidence_id = $specification.Evidence
    $project.effect.authority = 'OWNER'
    $project.effect.lifetime = 'Exact body-keyed target-module generation.'
    $project.effect.cleanup = 'Restore owned mutable state when possible; referenced encounter captures are recreated on the next natural module load.'
    $project.effect.stacking = 'One authoritative duration edit; linked pacing state is changed only when stock code stores it separately.'
    $project.stats = @()
    $project.addon_generation = [pscustomobject]$specification.Generation
    $project.description.enabled = $false
    $project.description.localization_key = $null
    $project.description.text = $null
    $project.deployment.requires_addon = $true
    $project.deployment.requires_card_extension = $false
    $project.deployment.requires_native_module = $false
    $project.deployment.requires_description_override = $false
    $project.deployment.live_manifest = $null

    $outputPath = Join-Path $outputRoot "$($specification.Id).json"
    $project | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $outputPath -Encoding utf8NoBOM
    Write-Output $outputPath
}
