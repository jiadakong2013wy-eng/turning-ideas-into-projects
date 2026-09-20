$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$releaseVersion = '0.4.0'
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
    try { return Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | ConvertFrom-Json }
    catch { $script:errors.Add("Invalid JSON file: $Path - $($_.Exception.Message)"); return $null }
}

function Get-ZipEntryNames {
    param([string]$Path)
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $archive = [System.IO.Compression.ZipFile]::OpenRead($Path)
    try { return @($archive.Entries | ForEach-Object { $_.FullName.Replace('\', '/') }) }
    finally { $archive.Dispose() }
}

function Get-ZipEntryText {
    param([string]$Path, [string]$EntryName)
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $archive = [System.IO.Compression.ZipFile]::OpenRead($Path)
    try {
        $entry = $archive.Entries | Where-Object { $_.FullName.Replace('\', '/') -eq $EntryName } | Select-Object -First 1
        if (-not $entry) { return $null }
        $reader = [System.IO.StreamReader]::new($entry.Open(), [System.Text.Encoding]::UTF8)
        try { return $reader.ReadToEnd() }
        finally { $reader.Dispose() }
    }
    finally { $archive.Dispose() }
}

$claudeMarketplace = Read-JsonFile (Join-Path $repoRoot '.claude-plugin/marketplace.json')
$claudeManifest = Read-JsonFile (Join-Path $repoRoot 'plugins/mingkon-idea-to-project/.claude-plugin/plugin.json')
$codexManifest = Read-JsonFile (Join-Path $repoRoot 'plugins/mingkon-idea-to-project/.codex-plugin/plugin.json')
$claudeCodeAdapter = Read-JsonFile (Join-Path $repoRoot 'platforms/claude-code/adapter.json')
$workBuddyAdapter = Read-JsonFile (Join-Path $repoRoot 'platforms/workbuddy/adapter.json')
$uniClawAdapter = Read-JsonFile (Join-Path $repoRoot 'platforms/uniclaw/adapter.json')
$claudeDesktopAdapter = Read-JsonFile (Join-Path $repoRoot 'platforms/claude-desktop/adapter.json')

if ($claudeMarketplace) {
    Assert-True ($claudeMarketplace.name -eq 'mingkon-skills') 'Claude marketplace name must be mingkon-skills.'
    $claudeEntries = @($claudeMarketplace.plugins)
    Assert-True ($claudeEntries.Count -eq 2) 'Claude marketplace must expose exactly two plugins.'
    Assert-True ($null -ne ($claudeEntries | Where-Object name -eq 'superpowers')) 'Claude marketplace must expose superpowers.'
    Assert-True ($null -ne ($claudeEntries | Where-Object name -eq 'turning-ideas-into-projects')) 'Claude marketplace must expose the public lifecycle plugin name.'
}
if ($claudeManifest) {
    Assert-True ($claudeManifest.name -eq 'turning-ideas-into-projects') 'Claude plugin must not expose the internal Codex plugin ID.'
    Assert-True ($claudeManifest.version -eq $releaseVersion) 'Claude plugin version mismatch.'
}
if ($codexManifest) {
    Assert-True ($codexManifest.version -match '^0\.4\.0\+codex\.\d{14}$') 'Codex source manifest must be a cache-busted 0.4.0 build.'
}
foreach ($adapter in @($claudeCodeAdapter, $workBuddyAdapter, $uniClawAdapter, $claudeDesktopAdapter)) {
    if ($adapter) {
        Assert-True ($adapter.version -eq $releaseVersion) 'Platform adapter version mismatch.'
        Assert-True (-not [string]::IsNullOrWhiteSpace($adapter.platform)) 'Platform adapter must name its host.'
        Assert-True (-not [string]::IsNullOrWhiteSpace($adapter.skillRoot)) 'Platform adapter must define its ZIP skill root.'
    }
}

$artifactNames = @(
    "turning-ideas-into-projects-codex-$releaseVersion.zip",
    "turning-ideas-into-projects-claude-code-$releaseVersion.zip",
    "turning-ideas-into-projects-workbuddy-$releaseVersion.zip",
    "turning-ideas-into-projects-uniclaw-$releaseVersion.zip",
    "orchestrating-multi-model-work-uniclaw-$releaseVersion.zip",
    "turning-ideas-into-projects-claude-desktop-$releaseVersion.zip",
    "orchestrating-multi-model-work-claude-desktop-$releaseVersion.zip"
)
$checksumPath = Join-Path $repoRoot 'release/SHA256SUMS.txt'
$checksumText = if (Test-Path -LiteralPath $checksumPath -PathType Leaf) { Get-Content -LiteralPath $checksumPath -Raw -Encoding UTF8 } else { '' }
Assert-True (-not [string]::IsNullOrWhiteSpace($checksumText)) 'Missing release/SHA256SUMS.txt.'

foreach ($artifactName in $artifactNames) {
    $artifactPath = Join-Path $repoRoot "release/$artifactName"
    if (-not (Test-Path -LiteralPath $artifactPath -PathType Leaf)) {
        $errors.Add("Missing release artifact: $artifactName")
        continue
    }
    $hash = (Get-FileHash -LiteralPath $artifactPath -Algorithm SHA256).Hash.ToLowerInvariant()
    Assert-True ($checksumText -match "(?m)^$hash  $([regex]::Escape($artifactName))\r?$") "Checksum entry mismatch: $artifactName"
    $entries = Get-ZipEntryNames $artifactPath
    Assert-True ($entries.Count -gt 0) "ZIP is empty: $artifactName"
    $usageEntries = @($entries | Where-Object { $_ -eq 'USAGE.md' -or $_ -match '^[^/]+/USAGE\.md$' })
    Assert-True ($usageEntries.Count -eq 1) "ZIP must include one user guide: $artifactName"
    if ($usageEntries.Count -eq 1) {
        $usage = Get-ZipEntryText $artifactPath $usageEntries[0]
        Assert-True ($usage -eq (Get-Content -LiteralPath (Join-Path $repoRoot 'README.md') -Raw -Encoding UTF8)) "ZIP user guide differs from source README: $artifactName"
    }
    Assert-True (-not ($entries | Where-Object { $_ -match '(^|/)\.git(/|$)' })) "ZIP contains .git data: $artifactName"
    Assert-True (-not ($entries | Where-Object { $_ -match 'ACCEPTANCE\.md$|evidence/T5/final-clone' })) "ZIP contains protected user artifacts: $artifactName"
}

$codexZip = Join-Path $repoRoot "release/turning-ideas-into-projects-codex-$releaseVersion.zip"
if (Test-Path -LiteralPath $codexZip -PathType Leaf) {
    $entries = Get-ZipEntryNames $codexZip
    foreach ($required in @('.agents/plugins/marketplace.json','plugins/superpowers/.codex-plugin/plugin.json','plugins/mingkon-idea-to-project/.codex-plugin/plugin.json','scripts/install.ps1')) {
        Assert-True ($entries -contains $required) "Codex ZIP missing: $required"
    }
    foreach ($required in @('plugins/mingkon-idea-to-project/skills/turning-ideas-into-projects/references/existing-project-upgrade.md','plugins/mingkon-idea-to-project/skills/turning-ideas-into-projects/references/stage-receipts.md','plugins/mingkon-idea-to-project/skills/orchestrating-multi-model-work/references/model-routing.md')) {
        Assert-True ($entries -contains $required) "Codex lifecycle ZIP missing: $required"
    }
}

$claudeZip = Join-Path $repoRoot "release/turning-ideas-into-projects-claude-code-$releaseVersion.zip"
if (Test-Path -LiteralPath $claudeZip -PathType Leaf) {
    $entries = Get-ZipEntryNames $claudeZip
    foreach ($required in @('.claude-plugin/marketplace.json','plugins/superpowers/.claude-plugin/plugin.json','plugins/turning-ideas-into-projects/.claude-plugin/plugin.json','plugins/turning-ideas-into-projects/skills/turning-ideas-into-projects/references/platform-adapter.md')) {
        Assert-True ($entries -contains $required) "Claude ZIP missing: $required"
    }
    $mainSkill = Get-ZipEntryText $claudeZip 'plugins/turning-ideas-into-projects/skills/turning-ideas-into-projects/SKILL.md'
    $packagedMarketplaceText = Get-ZipEntryText $claudeZip '.claude-plugin/marketplace.json'
    $packagedMarketplace = if ($packagedMarketplaceText) { $packagedMarketplaceText | ConvertFrom-Json } else { $null }
    $packagedPublicPlugin = if ($packagedMarketplace) { @($packagedMarketplace.plugins) | Where-Object name -eq 'turning-ideas-into-projects' } else { $null }
    Assert-True ($packagedPublicPlugin -and $packagedPublicPlugin.source -eq './plugins/turning-ideas-into-projects') 'Claude ZIP marketplace source must match its renamed public plugin directory.'
    Assert-True ($mainSkill -and $mainSkill.Contains('turning-ideas-into-projects:leader')) 'Claude generated Skill must use the public plugin namespace.'
    Assert-True (-not ($mainSkill -and $mainSkill.Contains('mingkon-idea-to-project:'))) 'Claude generated Skill leaks the internal Codex namespace.'
    foreach ($required in @('plugins/turning-ideas-into-projects/skills/turning-ideas-into-projects/references/existing-project-upgrade.md','plugins/turning-ideas-into-projects/skills/turning-ideas-into-projects/references/stage-receipts.md','plugins/turning-ideas-into-projects/skills/orchestrating-multi-model-work/references/model-routing.md')) {
        Assert-True ($entries -contains $required) "Claude lifecycle ZIP missing: $required"
    }
}

$workBuddyZip = Join-Path $repoRoot "release/turning-ideas-into-projects-workbuddy-$releaseVersion.zip"
if (Test-Path -LiteralPath $workBuddyZip -PathType Leaf) {
    $entries = Get-ZipEntryNames $workBuddyZip
    foreach ($skillName in @('turning-ideas-into-projects','orchestrating-multi-model-work','leader','brainstorming','writing-plans')) {
        $entry = "skills/$skillName/SKILL.md"
        Assert-True ($entries -contains $entry) "WorkBuddy ZIP missing: $entry"
        $text = Get-ZipEntryText $workBuddyZip $entry
        foreach ($field in @('description:', 'description_zh:', 'description_en:', 'version:', 'author:')) {
            Assert-True ($text -and $text.Contains($field)) "WorkBuddy Skill $skillName missing frontmatter field $field"
        }
        Assert-True (-not ($text -and $text.Contains('mingkon-idea-to-project:'))) "WorkBuddy Skill $skillName leaks a Codex plugin namespace."
    }
    Assert-True ($entries -contains 'skills/turning-ideas-into-projects/references/platform-adapter.md') 'WorkBuddy ZIP missing its lifecycle adapter reference.'
    foreach ($required in @('skills/turning-ideas-into-projects/references/existing-project-upgrade.md','skills/turning-ideas-into-projects/references/stage-receipts.md')) {
        Assert-True ($entries -contains $required) "WorkBuddy lifecycle ZIP missing: $required"
    }
    Assert-True ($entries -contains 'skills/orchestrating-multi-model-work/references/model-routing.md') 'WorkBuddy ZIP missing model-routing reference.'
}

$uniClawArchives = @(
    @{
        File = "turning-ideas-into-projects-uniclaw-$releaseVersion.zip"
        Name = 'turning-ideas-into-projects'
        Required = @(
            'references/platform-adapter.md',
            'references/bundled-skills/brainstorming/SKILL.md',
            'references/bundled-skills/writing-plans/SKILL.md',
            'references/bundled-skills/leader/SKILL.md',
            'references/bundled-skills/orchestrating-multi-model-work/SKILL.md'
        )
    },
    @{
        File = "orchestrating-multi-model-work-uniclaw-$releaseVersion.zip"
        Name = 'orchestrating-multi-model-work'
        Required = @('references/platform-adapter.md','references/handoff-contract.md','references/model-routing.md')
    }
)
foreach ($expected in $uniClawArchives) {
    $uniClawZip = Join-Path $repoRoot "release/$($expected.File)"
    if (-not (Test-Path -LiteralPath $uniClawZip -PathType Leaf)) { continue }
    $entries = Get-ZipEntryNames $uniClawZip
    Assert-True ($entries -contains 'SKILL.md') "UniClaw ZIP must contain root SKILL.md: $($expected.File)"
    Assert-True (-not ($entries | Where-Object { $_ -like 'skills/*' })) "UniClaw ZIP must not contain a sibling skills/ collection: $($expected.File)"
    foreach ($required in $expected.Required) {
        Assert-True ($entries -contains $required) "UniClaw ZIP missing $required`: $($expected.File)"
    }
    $adapterText = Get-ZipEntryText $uniClawZip 'references/platform-adapter.md'
    Assert-True ($adapterText -and $adapterText.Contains('# China Unicom UniClaw platform mapping')) "UniClaw platform-adapter.md must contain Markdown guidance: $($expected.File)"
    Assert-True ($adapterText -and $adapterText.Contains('model_actual')) "UniClaw platform adapter must preserve model observability guidance: $($expected.File)"
    if ($expected.Name -eq 'turning-ideas-into-projects') {
        Assert-True ($adapterText -and $adapterText.Contains('references/bundled-skills/<skill-name>/SKILL.md')) 'UniClaw lifecycle adapter must explain bundled workflow resolution.'
    }
    $text = Get-ZipEntryText $uniClawZip 'SKILL.md'
    Assert-True ($text -match "(?m)^name:\s*$([regex]::Escape($expected.Name))\s*$") "UniClaw root Skill name mismatch: $($expected.File)"
    Assert-True (-not ($text -and $text.Contains('mingkon-idea-to-project:'))) "UniClaw root Skill leaks a Codex plugin namespace: $($expected.File)"
    if ($expected.Name -eq 'turning-ideas-into-projects') {
        foreach ($required in @('references/existing-project-upgrade.md','references/stage-receipts.md')) {
            Assert-True ($entries -contains $required) "UniClaw lifecycle ZIP missing: $required"
        }
    }
}

$claudeDesktopArchives = @(
    @{ File = "turning-ideas-into-projects-claude-desktop-$releaseVersion.zip"; Name = 'turning-ideas-into-projects' },
    @{ File = "orchestrating-multi-model-work-claude-desktop-$releaseVersion.zip"; Name = 'orchestrating-multi-model-work' }
)
foreach ($expected in $claudeDesktopArchives) {
    $archivePath = Join-Path $repoRoot "release/$($expected.File)"
    if (-not (Test-Path -LiteralPath $archivePath -PathType Leaf)) { continue }
    $entries = Get-ZipEntryNames $archivePath
    Assert-True ($entries -contains "$($expected.Name)/SKILL.md") "Claude Desktop ZIP missing SKILL.md: $($expected.File)"
    if ($expected.Name -eq 'turning-ideas-into-projects') {
        foreach ($required in @('references/existing-project-upgrade.md','references/stage-receipts.md')) {
            Assert-True ($entries -contains "$($expected.Name)/$required") "Claude Desktop lifecycle ZIP missing: $required"
        }
    }
    else {
        Assert-True ($entries -contains "$($expected.Name)/references/model-routing.md") "Claude Desktop orchestration ZIP missing model-routing reference: $($expected.File)"
    }
}

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { [Console]::Error.WriteLine("ERROR: $_") }
    exit 1
}

Write-Output 'PLATFORM_PACKAGE_VALIDATION_OK'
