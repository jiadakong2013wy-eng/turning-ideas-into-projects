[CmdletBinding()]
param(
    [string]$Version = '0.3.1',
    [string]$OutputDirectory
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
if (-not $OutputDirectory) { $OutputDirectory = Join-Path $repoRoot 'release' }
$releaseRoot = [System.IO.Path]::GetFullPath($OutputDirectory)
$tempRoot = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
$stageRoot = Join-Path $tempRoot ("turning-ideas-platforms-" + [guid]::NewGuid().ToString('N'))
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)

function Copy-DirectoryContents {
    param([string]$Source, [string]$Destination)
    New-Item -ItemType Directory -Path $Destination -Force | Out-Null
    Get-ChildItem -LiteralPath $Source -Force | ForEach-Object {
        Copy-Item -LiteralPath $_.FullName -Destination $Destination -Recurse -Force
    }
}

function Write-Utf8NoBom {
    param([string]$Path, [string]$Text)
    $parent = Split-Path -Parent $Path
    if ($parent) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
    [System.IO.File]::WriteAllText($Path, $Text, $script:utf8NoBom)
}

function Get-PortableRelativePath {
    param([string]$BasePath, [string]$TargetPath)
    $baseFull = [System.IO.Path]::GetFullPath($BasePath).TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
    $targetFull = [System.IO.Path]::GetFullPath($TargetPath)
    $baseUri = [System.Uri]::new($baseFull)
    $targetUri = [System.Uri]::new($targetFull)
    return [System.Uri]::UnescapeDataString($baseUri.MakeRelativeUri($targetUri).ToString()).Replace('/', [System.IO.Path]::DirectorySeparatorChar)
}

function Get-FrontmatterValue {
    param([string]$Text, [string]$Field)
    $match = [regex]::Match($Text, "(?m)^$([regex]::Escape($Field)):\s*(?<value>.+?)\s*$")
    if (-not $match.Success) { return '' }
    return $match.Groups['value'].Value.Trim().Trim('"').Trim("'")
}

function ConvertTo-YamlSingleQuoted {
    param([string]$Value)
    return "'" + $Value.Replace("'", "''") + "'"
}

function Set-FrontmatterField {
    param([string]$Text, [string]$Field, [string]$Value)
    $match = [regex]::Match($Text, '(?s)\A---\r?\n(?<front>.*?)\r?\n---(?<body>\r?\n.*)\z')
    if (-not $match.Success) { throw "Invalid SKILL.md frontmatter while setting ${Field}." }
    $front = $match.Groups['front'].Value
    $line = "${Field}: $(ConvertTo-YamlSingleQuoted $Value)"
    if ([regex]::IsMatch($front, "(?m)^$([regex]::Escape($Field)):\s*.*$")) {
        $front = [regex]::Replace($front, "(?m)^$([regex]::Escape($Field)):\s*.*$", $line, 1)
    }
    else {
        $front = $front.TrimEnd() + "`n" + $line
    }
    return "---`n$front`n---" + $match.Groups['body'].Value
}

function Add-PlatformDirective {
    param([string]$Text)
    $directive = '> Platform adapter: before dependency, goal, child-task, model, Deep Research, or review checks, read [references/platform-adapter.md](references/platform-adapter.md).'
    if ($Text.Contains($directive)) { return $Text }
    $match = [regex]::Match($Text, '(?s)\A---\r?\n.*?\r?\n---\r?\n')
    if (-not $match.Success) { throw 'Invalid SKILL.md frontmatter while adding platform directive.' }
    return $Text.Insert($match.Length, "`n$directive`n")
}

function Convert-GeneratedSkills {
    param(
        [string]$SkillsRoot,
        [ValidateSet('claude-code','workbuddy','uniclaw')][string]$Platform,
        [pscustomobject]$Adapter,
        [System.Collections.Generic.HashSet[string]]$SuperpowersNames,
        [bool]$AddDirective = $true
    )
    $skillFiles = Get-ChildItem -LiteralPath $SkillsRoot -Recurse -File -Filter 'SKILL.md'
    foreach ($file in $skillFiles) {
        $text = [System.IO.File]::ReadAllText($file.FullName)
        if ($Platform -eq 'claude-code') {
            $text = $text.Replace('mingkon-idea-to-project:', 'turning-ideas-into-projects:')
        }
        else {
            $text = $text.Replace('mingkon-idea-to-project:', '').Replace('superpowers:', '')
        }

        $name = Get-FrontmatterValue $text 'name'
        if ($AddDirective -and $name -in @('turning-ideas-into-projects','orchestrating-multi-model-work')) {
            $text = Add-PlatformDirective $text
        }

        if ($Platform -eq 'workbuddy') {
            $description = Get-FrontmatterValue $text 'description'
            $descriptionZh = if ($SuperpowersNames.Contains($name)) { ([string]$Adapter.defaultDescriptionZh).Replace('{name}', $name) } else { $description }
            $descriptionEn = $description
            $localized = $Adapter.descriptions.PSObject.Properties[$name]
            if ($localized) {
                $descriptionZh = [string]$localized.Value.zh
                $descriptionEn = [string]$localized.Value.en
            }
            $sourceVersion = if ($SuperpowersNames.Contains($name)) { '6.3.0' } else { $Version }
            $author = if ($SuperpowersNames.Contains($name)) { 'Jesse Vincent' } else { 'Mingkon' }
            $text = Set-FrontmatterField $text 'description_zh' $descriptionZh
            $text = Set-FrontmatterField $text 'description_en' $descriptionEn
            $text = Set-FrontmatterField $text 'version' $sourceVersion
            $text = Set-FrontmatterField $text 'author' $author
        }
        Write-Utf8NoBom $file.FullName $text
    }
}

function Add-AdapterReference {
    param([string]$SkillsRoot, [string]$AdapterPath)
    foreach ($skillName in @('turning-ideas-into-projects','orchestrating-multi-model-work')) {
        $destination = Join-Path $SkillsRoot "$skillName/references/platform-adapter.md"
        New-Item -ItemType Directory -Path (Split-Path -Parent $destination) -Force | Out-Null
        Copy-Item -LiteralPath $AdapterPath -Destination $destination -Force
    }
}

function New-DeterministicZip {
    param([string]$SourceDirectory, [string]$DestinationPath)
    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $destinationFull = [System.IO.Path]::GetFullPath($DestinationPath)
    if (-not $destinationFull.StartsWith($script:releaseRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "ZIP target must stay inside release directory: $destinationFull"
    }
    if (Test-Path -LiteralPath $destinationFull -PathType Leaf) { Remove-Item -LiteralPath $destinationFull -Force }
    $fileStream = [System.IO.File]::Open($destinationFull, [System.IO.FileMode]::CreateNew)
    try {
        $archive = [System.IO.Compression.ZipArchive]::new($fileStream, [System.IO.Compression.ZipArchiveMode]::Create, $false)
        try {
            [string[]]$paths = @(Get-ChildItem -LiteralPath $SourceDirectory -Recurse -File | ForEach-Object { $_.FullName })
            [System.Array]::Sort($paths, [System.StringComparer]::Ordinal)
            foreach ($path in $paths) {
                $relative = (Get-PortableRelativePath $SourceDirectory $path).Replace('\', '/')
                $entry = $archive.CreateEntry($relative, [System.IO.Compression.CompressionLevel]::Optimal)
                $entry.LastWriteTime = [datetimeoffset]'2020-01-01T00:00:00Z'
                $input = [System.IO.File]::OpenRead($path)
                try {
                    $output = $entry.Open()
                    try { $input.CopyTo($output) }
                    finally { $output.Dispose() }
                }
                finally { $input.Dispose() }
            }
        }
        finally { $archive.Dispose() }
    }
    finally { $fileStream.Dispose() }
}

function Copy-ReleaseDocs {
    param([string]$Platform, [string]$Destination)
    Copy-Item -LiteralPath (Join-Path $repoRoot "docs/install-$Platform.md") -Destination (Join-Path $Destination 'README.md') -Force
    Copy-Item -LiteralPath (Join-Path $repoRoot 'LICENSE') -Destination (Join-Path $Destination 'LICENSE') -Force
    $licenseRoot = Join-Path $Destination 'third_party/licenses'
    New-Item -ItemType Directory -Path $licenseRoot -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $repoRoot 'third_party/NOTICE.md') -Destination (Join-Path $Destination 'third_party/NOTICE.md') -Force
    Copy-Item -LiteralPath (Join-Path $repoRoot 'third_party/licenses/superpowers-MIT.txt') -Destination $licenseRoot -Force
    Copy-Item -LiteralPath (Join-Path $repoRoot 'third_party/licenses/khazix-skills-MIT.txt') -Destination $licenseRoot -Force
}

New-Item -ItemType Directory -Path $releaseRoot -Force | Out-Null
New-Item -ItemType Directory -Path $stageRoot -Force | Out-Null

try {
    $superpowersNames = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    Get-ChildItem -LiteralPath (Join-Path $repoRoot 'plugins/superpowers/skills') -Directory | ForEach-Object { [void]$superpowersNames.Add($_.Name) }

    $codexStage = Join-Path $stageRoot 'codex'
    New-Item -ItemType Directory -Path $codexStage -Force | Out-Null
    Copy-DirectoryContents (Join-Path $repoRoot '.agents') (Join-Path $codexStage '.agents')
    Copy-DirectoryContents (Join-Path $repoRoot 'plugins') (Join-Path $codexStage 'plugins')
    New-Item -ItemType Directory -Path (Join-Path $codexStage 'scripts') -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $repoRoot 'scripts/install.ps1') -Destination (Join-Path $codexStage 'scripts/install.ps1')
    Copy-ReleaseDocs 'codex' $codexStage
    New-DeterministicZip $codexStage (Join-Path $releaseRoot "turning-ideas-into-projects-codex-$Version.zip")

    $claudeStage = Join-Path $stageRoot 'claude-code'
    New-Item -ItemType Directory -Path $claudeStage -Force | Out-Null
    Copy-DirectoryContents (Join-Path $repoRoot '.claude-plugin') (Join-Path $claudeStage '.claude-plugin')
    $packagedClaudeMarketplace = Join-Path $claudeStage '.claude-plugin/marketplace.json'
    $packagedClaudeMarketplaceText = [System.IO.File]::ReadAllText($packagedClaudeMarketplace)
    $packagedClaudeMarketplaceText = $packagedClaudeMarketplaceText.Replace('./plugins/mingkon-idea-to-project', './plugins/turning-ideas-into-projects')
    Write-Utf8NoBom $packagedClaudeMarketplace $packagedClaudeMarketplaceText
    Copy-DirectoryContents (Join-Path $repoRoot 'plugins/superpowers') (Join-Path $claudeStage 'plugins/superpowers')
    $claudePlugin = Join-Path $claudeStage 'plugins/turning-ideas-into-projects'
    Copy-DirectoryContents (Join-Path $repoRoot 'plugins/mingkon-idea-to-project/skills') (Join-Path $claudePlugin 'skills')
    Copy-DirectoryContents (Join-Path $repoRoot 'plugins/mingkon-idea-to-project/.claude-plugin') (Join-Path $claudePlugin '.claude-plugin')
    Copy-Item -LiteralPath (Join-Path $repoRoot 'LICENSE') -Destination (Join-Path $claudePlugin 'LICENSE')
    Add-AdapterReference (Join-Path $claudePlugin 'skills') (Join-Path $repoRoot 'platforms/claude-code/platform-adapter.md')
    $claudeAdapterPath = Join-Path $repoRoot 'platforms/claude-code/adapter.json'
    $claudeAdapter = [System.IO.File]::ReadAllText($claudeAdapterPath, $utf8NoBom) | ConvertFrom-Json
    Convert-GeneratedSkills (Join-Path $claudePlugin 'skills') 'claude-code' $claudeAdapter $superpowersNames
    Copy-ReleaseDocs 'claude-code' $claudeStage
    New-DeterministicZip $claudeStage (Join-Path $releaseRoot "turning-ideas-into-projects-claude-code-$Version.zip")

    $workBuddyAdapterPath = Join-Path $repoRoot 'platforms/workbuddy/adapter.json'
    $workBuddyAdapter = [System.IO.File]::ReadAllText($workBuddyAdapterPath, $utf8NoBom) | ConvertFrom-Json
    $workBuddyStage = Join-Path $stageRoot 'workbuddy'
    $workBuddySkills = Join-Path $workBuddyStage 'skills'
    Copy-DirectoryContents (Join-Path $repoRoot 'plugins/superpowers/skills') $workBuddySkills
    Get-ChildItem -LiteralPath (Join-Path $repoRoot 'plugins/mingkon-idea-to-project/skills') -Directory | ForEach-Object {
        Copy-Item -LiteralPath $_.FullName -Destination $workBuddySkills -Recurse -Force
    }
    Add-AdapterReference $workBuddySkills (Join-Path $repoRoot 'platforms/workbuddy/platform-adapter.md')
    Convert-GeneratedSkills $workBuddySkills 'workbuddy' $workBuddyAdapter $superpowersNames
    Copy-ReleaseDocs 'workbuddy' $workBuddyStage
    New-DeterministicZip $workBuddyStage (Join-Path $releaseRoot "turning-ideas-into-projects-workbuddy-$Version.zip")

    $uniClawAdapterPath = Join-Path $repoRoot 'platforms/uniclaw/adapter.json'
    $uniClawAdapter = [System.IO.File]::ReadAllText($uniClawAdapterPath, $utf8NoBom) | ConvertFrom-Json
    $uniClawPlatformAdapterPath = Join-Path $repoRoot 'platforms/uniclaw/platform-adapter.md'

    $uniClawMainStage = Join-Path $stageRoot 'uniclaw-main'
    Copy-DirectoryContents (Join-Path $repoRoot 'plugins/mingkon-idea-to-project/skills/turning-ideas-into-projects') $uniClawMainStage
    New-Item -ItemType Directory -Path (Join-Path $uniClawMainStage 'references') -Force | Out-Null
    Copy-Item -LiteralPath $uniClawPlatformAdapterPath -Destination (Join-Path $uniClawMainStage 'references/platform-adapter.md') -Force
    Convert-GeneratedSkills $uniClawMainStage 'uniclaw' $uniClawAdapter $superpowersNames

    $bundledSkills = Join-Path $uniClawMainStage 'references/bundled-skills'
    Copy-DirectoryContents (Join-Path $repoRoot 'plugins/superpowers/skills') $bundledSkills
    foreach ($skillName in @('leader','orchestrating-multi-model-work')) {
        Copy-Item -LiteralPath (Join-Path $repoRoot "plugins/mingkon-idea-to-project/skills/$skillName") -Destination $bundledSkills -Recurse -Force
    }
    Convert-GeneratedSkills $bundledSkills 'uniclaw' $uniClawAdapter $superpowersNames $false
    Copy-ReleaseDocs 'uniclaw' $uniClawMainStage
    New-DeterministicZip $uniClawMainStage (Join-Path $releaseRoot "turning-ideas-into-projects-uniclaw-$Version.zip")

    $uniClawChildStage = Join-Path $stageRoot 'uniclaw-child'
    Copy-DirectoryContents (Join-Path $repoRoot 'plugins/mingkon-idea-to-project/skills/orchestrating-multi-model-work') $uniClawChildStage
    New-Item -ItemType Directory -Path (Join-Path $uniClawChildStage 'references') -Force | Out-Null
    Copy-Item -LiteralPath $uniClawPlatformAdapterPath -Destination (Join-Path $uniClawChildStage 'references/platform-adapter.md') -Force
    Convert-GeneratedSkills $uniClawChildStage 'uniclaw' $uniClawAdapter $superpowersNames
    Copy-ReleaseDocs 'uniclaw' $uniClawChildStage
    New-DeterministicZip $uniClawChildStage (Join-Path $releaseRoot "orchestrating-multi-model-work-uniclaw-$Version.zip")

    $checksumLines = foreach ($name in @(
        "turning-ideas-into-projects-codex-$Version.zip",
        "turning-ideas-into-projects-claude-code-$Version.zip",
        "turning-ideas-into-projects-workbuddy-$Version.zip",
        "turning-ideas-into-projects-uniclaw-$Version.zip",
        "orchestrating-multi-model-work-uniclaw-$Version.zip"
    )) {
        $hash = (Get-FileHash -LiteralPath (Join-Path $releaseRoot $name) -Algorithm SHA256).Hash.ToLowerInvariant()
        "$hash  $name"
    }
    Write-Utf8NoBom (Join-Path $releaseRoot 'SHA256SUMS.txt') (($checksumLines -join "`n") + "`n")
    Write-Output "Built four platform packages in $releaseRoot"
}
finally {
    $stageFull = [System.IO.Path]::GetFullPath($stageRoot)
    if ($stageFull.StartsWith($tempRoot, [System.StringComparison]::OrdinalIgnoreCase) -and (Test-Path -LiteralPath $stageFull)) {
        Remove-Item -LiteralPath $stageFull -Recurse -Force
    }
}
