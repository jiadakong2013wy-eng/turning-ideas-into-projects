$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$errors = [System.Collections.Generic.List[string]]::new()

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { $script:errors.Add($Message) }
}

function Read-JsonFile {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        $script:errors.Add("Missing JSON file: $Path")
        return $null
    }
    try { return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json }
    catch { $script:errors.Add("Invalid JSON file: $Path - $($_.Exception.Message)"); return $null }
}

function Get-TreeDigest {
    param([string]$Root)
    [string[]]$lines = @(Get-ChildItem -LiteralPath $Root -Recurse -File | ForEach-Object {
        $relative = [System.IO.Path]::GetRelativePath($Root, $_.FullName).Replace([System.IO.Path]::DirectorySeparatorChar, '/')
        Assert-True (-not $relative.Contains('\')) "Tree digest path was not normalized: $relative"
        $hash = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
        "$relative`0$hash"
    })
    [System.Array]::Sort($lines, [System.StringComparer]::Ordinal)
    $payload = [System.Text.Encoding]::UTF8.GetBytes(($lines -join "`n"))
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try { return ([System.BitConverter]::ToString($sha.ComputeHash($payload))).Replace('-', '').ToLowerInvariant() }
    finally { $sha.Dispose() }
}

$marketplacePath = Join-Path $repoRoot '.agents/plugins/marketplace.json'
$mingkonManifestPath = Join-Path $repoRoot 'plugins/mingkon-idea-to-project/.codex-plugin/plugin.json'
$superpowersManifestPath = Join-Path $repoRoot 'plugins/superpowers/.codex-plugin/plugin.json'
$lockPath = Join-Path $repoRoot 'third_party/LOCK.json'
$installerPath = Join-Path $repoRoot 'scripts/install.ps1'

$marketplace = Read-JsonFile $marketplacePath
$mingkonManifest = Read-JsonFile $mingkonManifestPath
$superpowersManifest = Read-JsonFile $superpowersManifestPath
$lock = Read-JsonFile $lockPath

if ($marketplace) {
    Assert-True ($marketplace.name -eq 'mingkon-skills') 'Marketplace name must be mingkon-skills.'
    $entries = @($marketplace.plugins)
    Assert-True ($entries.Count -eq 2) 'Marketplace must expose exactly two plugins.'
    foreach ($name in @('superpowers', 'mingkon-idea-to-project')) {
        $entry = $entries | Where-Object name -eq $name
        Assert-True ($null -ne $entry) "Marketplace entry missing: $name"
        if ($entry) {
            Assert-True ($entry.source.source -eq 'local') "$name source must be local to the Git marketplace snapshot."
            Assert-True ($entry.source.path -eq "./plugins/$name") "$name source path is wrong."
            Assert-True ($entry.policy.installation -eq 'AVAILABLE') "$name installation policy must be AVAILABLE."
            Assert-True ($entry.policy.authentication -eq 'ON_INSTALL') "$name authentication policy must be ON_INSTALL."
        }
    }
}

if ($mingkonManifest) {
    Assert-True ($mingkonManifest.name -eq 'mingkon-idea-to-project') 'Mingkon plugin name mismatch.'
    Assert-True ($mingkonManifest.version -match '^0\.3\.0\+codex\.\d{14}$') 'Mingkon plugin version must be a cache-busted 0.3.0 local build.'
    Assert-True ($mingkonManifest.skills -eq './skills/') 'Mingkon plugin must expose ./skills/.'
    Assert-True ($mingkonManifest.interface.displayName -eq 'turning-ideas-into-projects') 'Plugin display name must match the slash-menu search command.'
    Assert-True ($mingkonManifest.homepage -eq 'https://github.com/jiadakong2013wy-eng/turning-ideas-into-projects#readme') 'Plugin homepage must open the public usage guide.'
    Assert-True ($mingkonManifest.repository -eq 'https://github.com/jiadakong2013wy-eng/turning-ideas-into-projects') 'Plugin repository must point to the public GitHub source.'
    Assert-True ($mingkonManifest.interface.websiteURL -eq 'https://github.com/jiadakong2013wy-eng/turning-ideas-into-projects#readme') 'Plugin details must expose the public usage guide.'
    Assert-True ($mingkonManifest.interface.longDescription.Contains('/turning-ideas-into-projects')) 'Plugin details must explain how to start.'
    Assert-True ($mingkonManifest.interface.longDescription.Contains('GO、PIVOT、HOLD 或 STOP')) 'Plugin details must explain the decision flow.'
    Assert-True ($mingkonManifest.interface.longDescription.Contains('更换或禁用模型')) 'Plugin details must explain model choice.'
    Assert-True (@($mingkonManifest.interface.defaultPrompt).Count -eq 3) 'Plugin details must expose three starter prompts.'
}
if (Test-Path -LiteralPath $installerPath -PathType Leaf) {
    $installer = Get-Content -LiteralPath $installerPath -Raw
    Assert-True ($installer.Contains('turning-ideas-into-projects 0.3.0')) 'Installer output must report the public plugin name and version 0.3.0.'
    Assert-True ($installer.Contains('https://github.com/jiadakong2013wy-eng/turning-ideas-into-projects.git')) 'Installer must default to the public GitHub repository.'
}

if ($superpowersManifest) {
    Assert-True ($superpowersManifest.name -eq 'superpowers') 'Vendored Superpowers plugin name mismatch.'
    Assert-True ($superpowersManifest.version -eq '6.3.0') 'Vendored Superpowers version must be 6.3.0.'
}

$requiredFiles = @(
    'plugins/mingkon-idea-to-project/skills/turning-ideas-into-projects/SKILL.md',
    'plugins/mingkon-idea-to-project/skills/turning-ideas-into-projects/references/project-pack.md',
    'plugins/mingkon-idea-to-project/skills/orchestrating-multi-model-work/SKILL.md',
    'plugins/mingkon-idea-to-project/skills/orchestrating-multi-model-work/agents/openai.yaml',
    'plugins/mingkon-idea-to-project/skills/orchestrating-multi-model-work/references/handoff-contract.md',
    'plugins/mingkon-idea-to-project/skills/leader/SKILL.md',
    'plugins/mingkon-idea-to-project/skills/leader/references/anatomy.md',
    'plugins/mingkon-idea-to-project/skills/leader/references/style.md',
    'plugins/superpowers/LICENSE',
    'third_party/licenses/superpowers-MIT.txt',
    'third_party/licenses/khazix-skills-MIT.txt',
    'third_party/NOTICE.md',
    'scripts/install.ps1'
)
foreach ($relative in $requiredFiles) {
    Assert-True (Test-Path -LiteralPath (Join-Path $repoRoot $relative) -PathType Leaf) "Missing required file: $relative"
}

$orchestratorPath = Join-Path $repoRoot 'plugins/mingkon-idea-to-project/skills/turning-ideas-into-projects/SKILL.md'
$orchestratorUiPath = Join-Path $repoRoot 'plugins/mingkon-idea-to-project/skills/turning-ideas-into-projects/agents/openai.yaml'
if (Test-Path -LiteralPath $orchestratorPath -PathType Leaf) {
    $orchestrator = Get-Content -LiteralPath $orchestratorPath -Raw
    Assert-True ($orchestrator.Contains('immediate post-brainstorming handoff')) 'Orchestrator must reconcile brainstorming with writing-plans.'
    Assert-True ($orchestrator.Contains('must not use a generic `leader` installation')) 'Plugin mode must not mask a missing bundled leader.'
    Assert-True ($orchestrator.Contains('must not invoke package-external optional skills')) 'Qualified execution must not acquire optional Skill dependencies outside the package.'
    Assert-True (-not $orchestrator.Contains('when available, otherwise `leader`')) 'Core spine must not contain a generic leader fallback.'
    Assert-True ($orchestrator.Contains('record the selected option as contract input')) 'Writing-plans execution choice must return to governed orchestration.'
}
if (Test-Path -LiteralPath $orchestratorUiPath -PathType Leaf) {
    $orchestratorUi = Get-Content -LiteralPath $orchestratorUiPath -Raw
    Assert-True ($orchestratorUi.Contains('display_name: "turning-ideas-into-projects"')) 'Skill slash-menu display name must match turning-ideas-into-projects.'
}

$multiModelPath = Join-Path $repoRoot 'plugins/mingkon-idea-to-project/skills/orchestrating-multi-model-work/SKILL.md'
$multiModelUiPath = Join-Path $repoRoot 'plugins/mingkon-idea-to-project/skills/orchestrating-multi-model-work/agents/openai.yaml'
$receiptPath = Join-Path $repoRoot 'plugins/mingkon-idea-to-project/skills/orchestrating-multi-model-work/references/handoff-contract.md'
if (Test-Path -LiteralPath $multiModelPath -PathType Leaf) {
    $multiModel = Get-Content -LiteralPath $multiModelPath -Raw
    foreach ($requiredPhrase in @(
        'approved phase',
        'frozen contract',
        'model_requested',
        'model_actual',
        'external_handoff_required',
        'fresh Sol context',
        'must not change product direction',
        'must not write central governance files'
    )) {
        Assert-True ($multiModel.Contains($requiredPhrase)) "Multi-model Skill missing required contract phrase: $requiredPhrase"
    }
}
if (Test-Path -LiteralPath $multiModelUiPath -PathType Leaf) {
    $multiModelUi = Get-Content -LiteralPath $multiModelUiPath -Raw
    Assert-True ($multiModelUi.Contains('display_name: "orchestrating-multi-model-work"')) 'Multi-model Skill slash-menu display name mismatch.'
}
if (Test-Path -LiteralPath $receiptPath -PathType Leaf) {
    $receipt = Get-Content -LiteralPath $receiptPath -Raw
    foreach ($field in @('task_id:', 'role:', 'model_requested:', 'model_actual:', 'contract_version:', 'status:', 'next_action:')) {
        Assert-True ($receipt.Contains($field)) "Receipt reference missing required field: $field"
    }
}

$runtimeSkillFiles = Get-ChildItem -LiteralPath (Join-Path $repoRoot 'plugins') -Recurse -File -Filter 'SKILL.md'
$qualifiedRefs = foreach ($file in $runtimeSkillFiles) {
    $content = Get-Content -LiteralPath $file.FullName -Raw
    foreach ($match in [regex]::Matches($content, '`(?<prefix>[a-z0-9-]+):(?<skill>[a-z0-9-]+)`', 'IgnoreCase')) {
        [pscustomobject]@{ Prefix = $match.Groups['prefix'].Value; Skill = $match.Groups['skill'].Value; File = $file.FullName }
    }
}
foreach ($ref in $qualifiedRefs) {
    if ($ref.Prefix -eq 'superpowers') {
        Assert-True (Test-Path -LiteralPath (Join-Path $repoRoot "plugins/superpowers/skills/$($ref.Skill)/SKILL.md") -PathType Leaf) "Unbundled Superpowers Skill reference: $($ref.Skill)"
    }
    elseif ($ref.Prefix -eq 'mingkon-idea-to-project') {
        Assert-True ($ref.Skill -in @('leader', 'orchestrating-multi-model-work')) "Unexpected Mingkon Skill reference: $($ref.Skill)"
        Assert-True (Test-Path -LiteralPath (Join-Path $repoRoot "plugins/mingkon-idea-to-project/skills/$($ref.Skill)/SKILL.md") -PathType Leaf) "Unbundled Mingkon Skill reference: $($ref.Skill)"
    }
    elseif ($ref.Prefix -eq 'elements-of-style') {
        Assert-True ($ref.Skill -eq 'writing-clearly-and-concisely') "Unexpected external optional Skill reference: $($ref.Prefix):$($ref.Skill)"
        Assert-True ($orchestrator.Contains('must not invoke package-external optional skills')) 'External optional Skill reference lacks a qualified-execution prohibition.'
    }
    else {
        Assert-True $false "Unbundled qualified Skill reference: $($ref.Prefix):$($ref.Skill)"
    }
}

if ($lock) {
    Assert-True ($lock.superpowers.commit -eq 'b36e0829c6d0140e93cfef2ca599b1b07d4a7797') 'Superpowers peeled commit pin mismatch.'
    Assert-True ($lock.superpowers.tag_object -eq '86babb696875227929e85420f287d6309374b93f') 'Superpowers tag object pin mismatch.'
    Assert-True ($lock.leader.commit -eq '7a5c4934be4106ac740ffdb95280bb81b3f4b83c') 'leader commit pin mismatch.'
    $superDigest = Get-TreeDigest (Join-Path $repoRoot 'plugins/superpowers')
    $leaderDigest = Get-TreeDigest (Join-Path $repoRoot 'plugins/mingkon-idea-to-project/skills/leader')
    Assert-True ($lock.superpowers.tree_sha256 -eq $superDigest) 'Vendored Superpowers tree digest mismatch.'
    Assert-True ($lock.leader.tree_sha256 -eq $leaderDigest) 'Vendored leader tree digest mismatch.'
}

$textFiles = Get-ChildItem -LiteralPath $repoRoot -Recurse -File | Where-Object {
    $_.FullName -notmatch '[\\/]\.git[\\/]' -and
    $_.FullName -notmatch '[\\/]plugins[\\/]superpowers[\\/]' -and
    $_.FullName -ne $PSCommandPath -and
    $_.Extension -in @('.md', '.json', '.yaml', '.yml', '.ps1')
}
$placeholderHits = $textFiles | Select-String -Pattern '\[TODO:|\bTBD\b|implement later|fill in details' -CaseSensitive:$false
Assert-True (@($placeholderHits).Count -eq 0) 'Unfinished placeholders remain in package files.'

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Output 'PACKAGE_VALIDATION_OK'
