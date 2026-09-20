[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Path,

    [Parameter(Mandatory = $true)]
    [ValidateSet('turning-ideas-into-projects', 'orchestrating-multi-model-work')]
    [string]$ExpectedName
)

$ErrorActionPreference = 'Stop'
$errors = [System.Collections.Generic.List[string]]::new()
$resolvedArchive = [System.IO.Path]::GetFullPath($Path)

if (-not (Test-Path -LiteralPath $resolvedArchive -PathType Leaf)) {
    [Console]::Error.WriteLine("ERROR: Missing Claude Desktop archive: $resolvedArchive")
    exit 1
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [System.IO.Compression.ZipFile]::OpenRead($resolvedArchive)
try {
    $entries = @($archive.Entries | ForEach-Object { $_.FullName.Replace('\', '/') })
    $rootFiles = @($entries | Where-Object { $_ -notmatch '/' })
    $topLevelNames = @($entries | ForEach-Object { ($_ -split '/', 2)[0] } | Select-Object -Unique)
    $skillPath = "$ExpectedName/SKILL.md"
    $rootSkill = $archive.Entries | Where-Object { $_.FullName.Replace('\', '/') -eq $skillPath } | Select-Object -First 1

    if ($rootFiles.Count -gt 0) {
        $errors.Add('Import archive must not contain files directly at the ZIP root.')
    }
    if ($topLevelNames.Count -ne 1 -or $topLevelNames[0] -ne $ExpectedName) {
        $errors.Add("Import archive must contain exactly one top-level folder named $ExpectedName.")
    }
    if (-not $rootSkill) {
        $errors.Add("Archive must contain $skillPath.")
    }
    else {
        $reader = [System.IO.StreamReader]::new($rootSkill.Open(), [System.Text.Encoding]::UTF8)
        try { $skillText = $reader.ReadToEnd() }
        finally { $reader.Dispose() }

        $frontmatterMatch = [regex]::Match($skillText, '\A---\r?\n(?<frontmatter>.*?)\r?\n---(?:\r?\n|\z)', [System.Text.RegularExpressions.RegexOptions]::Singleline)
        $nameMatch = if ($frontmatterMatch.Success) {
            [regex]::Match($frontmatterMatch.Groups['frontmatter'].Value, '(?m)^name:\s*["'']?(?<name>[a-z0-9-]+)["'']?\s*$')
        }
        else {
            [regex]::Match('', '^$')
        }
        if (-not $nameMatch.Success -or $nameMatch.Groups['name'].Value -ne $ExpectedName) {
            $errors.Add("$skillPath frontmatter name must be $ExpectedName.")
        }
    }

    if ($entries | Where-Object { $_ -match '^(?i:skills)/' }) {
        $errors.Add('Import archive must not use a sibling skills/ collection root.')
    }

    $requiredEntries = if ($ExpectedName -eq 'turning-ideas-into-projects') {
        @(
            'references/platform-adapter.md',
            'references/existing-project-upgrade.md',
            'references/stage-receipts.md',
            'references/bundled-skills/brainstorming/SKILL.md',
            'references/bundled-skills/writing-plans/SKILL.md',
            'references/bundled-skills/leader/SKILL.md',
            'references/bundled-skills/orchestrating-multi-model-work/SKILL.md'
        )
    }
    else {
        @('references/platform-adapter.md', 'references/handoff-contract.md')
    }

    foreach ($entry in $requiredEntries) {
        $requiredPath = "$ExpectedName/$entry"
        if ($entries -notcontains $requiredPath) {
            $errors.Add("Archive missing required entry: $requiredPath")
        }
    }
}
finally {
    $archive.Dispose()
}

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { [Console]::Error.WriteLine("ERROR: $_") }
    exit 1
}

Write-Output "CLAUDE_DESKTOP_ARCHIVE_OK name=$ExpectedName"
