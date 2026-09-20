$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$errors = [System.Collections.Generic.List[string]]::new()

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { $script:errors.Add($Message) }
}

function Read-Required {
    param([string]$RelativePath)
    $path = Join-Path $repoRoot $RelativePath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        $script:errors.Add("Missing required file: $RelativePath")
        return ''
    }
    return Get-Content -LiteralPath $path -Raw -Encoding UTF8
}

$router = Read-Required 'plugins/mingkon-idea-to-project/skills/orchestrating-multi-model-work/references/model-routing.md'
$child = Read-Required 'plugins/mingkon-idea-to-project/skills/orchestrating-multi-model-work/SKILL.md'
$parent = Read-Required 'plugins/mingkon-idea-to-project/skills/turning-ideas-into-projects/SKILL.md'
$receipt = Read-Required 'plugins/mingkon-idea-to-project/skills/orchestrating-multi-model-work/references/handoff-contract.md'
$readme = Read-Required 'README.md'

foreach ($profile in @('推荐适配', '质量优先', '省额度/速度优先', '自定义每个角色')) {
    Assert-True ($router.Contains($profile)) "Model selector missing profile: $profile"
    Assert-True ($readme.Contains($profile)) "README missing model selector profile: $profile"
}

foreach ($field in @('platform:', 'subscription_mode:', 'route_profile:', 'selection_source:', 'extra_cost_authorized:', 'model_requested:', 'model_actual:')) {
    Assert-True ($receipt.Contains($field)) "Routing receipt missing field: $field"
}

foreach ($phrase in @(
    'GPT-6 Astra',
    'Terra',
    'Sol',
    'Luna',
    'Claude Pro',
    'Fable 5',
    'Opus 5',
    'Sonnet 5',
    'Kimi-K3',
    'GLM-5.3',
    'Kimi-K2.7-Code',
    'DeepSeek-V4-Flash',
    'future model'
)) {
    Assert-True ($router.Contains($phrase)) "Routing reference missing required capability or model: $phrase"
}

Assert-True ($router.Contains('explicit') -and $router.Contains('extra cost')) 'Extra-cost models must require explicit user authorization.'
Assert-True ($router.Contains('observed') -and $router.Contains('unknown')) 'Future and actual models must be observation-gated.'
Assert-True ($child.Contains('[references/model-routing.md](references/model-routing.md)')) 'Child Skill must load the model-routing reference.'
Assert-True ($parent.Contains('推荐适配') -and $parent.Contains('自定义每个角色')) 'Parent adoption notice must expose the selector.'
Assert-True (-not ($child -match 'Sol reviews|use fresh Sol|fresh Sol to')) 'Shared research rules must use the selected platform reviewer.'
Assert-True ($router.Contains('cost is unknown')) 'Unknown cost must stop paid dispatch.'
Assert-True ($router.Contains('allowance is exhausted')) 'Routing must handle included-allowance exhaustion.'
Assert-True ($router.Contains('before launch') -and $router.Contains('after launch')) 'Preflight checks and runtime identity readback must be distinct.'
Assert-True ($router.Contains('wait for the structured UI response') -and $router.Contains('end the reply')) 'First-time selection must offer an actual response window.'
Assert-True ($parent.Contains("current host and installed manifest") -and $parent.Contains('direct GitHub marketplace installs')) 'Raw source must resolve the host namespace without ZIP rewriting.'
$marketplace = (Read-Required '.claude-plugin/marketplace.json') | ConvertFrom-Json
$publicPlugin = @($marketplace.plugins) | Where-Object name -eq 'turning-ideas-into-projects'
Assert-True ($null -ne $publicPlugin) 'Claude marketplace must expose the public plugin.'
if ($publicPlugin) {
    $sourceRoot = ([string]$publicPlugin.source).TrimStart('.', '/')
    $manifest = (Read-Required "$sourceRoot/.claude-plugin/plugin.json") | ConvertFrom-Json
    Assert-True ($manifest.name -eq $publicPlugin.name) 'Claude direct-source plugin namespace must match marketplace.'
    $directParent = Read-Required "$sourceRoot/skills/turning-ideas-into-projects/SKILL.md"
    foreach ($sibling in @('leader', 'orchestrating-multi-model-work')) {
        Assert-True ($directParent.Contains("$($manifest.name):$sibling")) "Claude direct-source parent cannot resolve sibling: $sibling"
        Assert-True (Test-Path -LiteralPath (Join-Path $repoRoot "$sourceRoot/skills/$sibling/SKILL.md")) "Missing Claude bundled sibling: $sibling"
    }
}

$adapterRequirements = @{
    'platforms/claude-code/platform-adapter.md' = @('Fable 5', 'Opus 5', 'Sonnet 5', 'pay-as-you-go')
    'platforms/claude-desktop/platform-adapter.md' = @('Fable 5', 'Opus 5', 'Sonnet 5', 'pay-as-you-go')
    'platforms/workbuddy/platform-adapter.md' = @('Kimi-K3', 'GLM-5.3', 'Kimi-K2.7-Code', 'DeepSeek-V4-Flash')
    'platforms/uniclaw/platform-adapter.md' = @('observed', 'capability')
}
foreach ($path in $adapterRequirements.Keys) {
    $text = Read-Required $path
    foreach ($phrase in $adapterRequirements[$path]) {
        Assert-True ($text.Contains($phrase)) "$path missing routing requirement: $phrase"
    }
}

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { [Console]::Error.WriteLine("ERROR: $_") }
    exit 1
}

Write-Output 'MODEL_ROUTING_VALIDATION_OK'
