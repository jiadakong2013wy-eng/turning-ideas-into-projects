[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ArchivePath,

    [Parameter(Mandatory = $true)]
    [string]$ExpectedSkillName
)

$ErrorActionPreference = 'Stop'
$errors = [System.Collections.Generic.List[string]]::new()
$resolvedArchive = [System.IO.Path]::GetFullPath($ArchivePath)

if (-not (Test-Path -LiteralPath $resolvedArchive -PathType Leaf)) {
    [Console]::Error.WriteLine("ERROR: Missing UniClaw archive: $resolvedArchive")
    exit 1
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [System.IO.Compression.ZipFile]::OpenRead($resolvedArchive)
try {
    $entries = @($archive.Entries | ForEach-Object { $_.FullName.Replace('\', '/') })
    $rootSkill = $archive.Entries | Where-Object { $_.FullName.Replace('\', '/') -eq 'SKILL.md' } | Select-Object -First 1

    if (-not $rootSkill) {
        $errors.Add('Archive must contain a SKILL.md file at the skill root.')
    }
    else {
        $reader = [System.IO.StreamReader]::new($rootSkill.Open(), [System.Text.Encoding]::UTF8)
        try { $skillText = $reader.ReadToEnd() }
        finally { $reader.Dispose() }

        $nameMatch = [regex]::Match($skillText, '(?m)^name:\s*(?<name>[a-z0-9-]+)\s*$')
        if (-not $nameMatch.Success -or $nameMatch.Groups['name'].Value -ne $ExpectedSkillName) {
            $errors.Add("Root SKILL.md name must be $ExpectedSkillName.")
        }
    }

    if ($entries | Where-Object { $_ -like 'skills/*' }) {
        $errors.Add('Import archive must not use a sibling skills/ collection root.')
    }
}
finally {
    $archive.Dispose()
}

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { [Console]::Error.WriteLine("ERROR: $_") }
    exit 1
}

Write-Output "UNICLAW_IMPORT_ARCHIVE_OK name=$ExpectedSkillName"
