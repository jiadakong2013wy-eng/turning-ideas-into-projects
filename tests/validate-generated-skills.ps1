$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$validator = 'D:\CodexData\.codex\skills\.system\skill-creator\scripts\quick_validate.py'
$tempBase = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
$tempRoot = Join-Path $tempBase ('tip-skill-validation-' + [guid]::NewGuid().ToString('N'))
$targets = [System.Collections.Generic.List[string]]::new()
$previousPythonUtf8 = $env:PYTHONUTF8

if (-not (Get-Command python -ErrorAction SilentlyContinue)) { throw 'python is required for Skill quick validation.' }
if (-not (Test-Path -LiteralPath $validator -PathType Leaf)) { throw "Skill validator is missing: $validator" }

New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
try {
    $env:PYTHONUTF8 = '1'
    Get-ChildItem -LiteralPath (Join-Path $repoRoot 'plugins/mingkon-idea-to-project/skills') -Directory | ForEach-Object {
        $targets.Add($_.FullName)
    }

    foreach ($platform in @('claude-code','uniclaw')) {
        $zip = Join-Path $repoRoot "release/turning-ideas-into-projects-$platform-0.3.0.zip"
        if (-not (Test-Path -LiteralPath $zip -PathType Leaf)) { throw "Missing package: $zip" }
        $destination = Join-Path $tempRoot $platform
        Expand-Archive -LiteralPath $zip -DestinationPath $destination -Force
        $skillRoot = if ($platform -eq 'claude-code') {
            Join-Path $destination 'plugins/turning-ideas-into-projects/skills'
        }
        else {
            Join-Path $destination 'skills'
        }
        Get-ChildItem -LiteralPath $skillRoot -Directory | ForEach-Object { $targets.Add($_.FullName) }
    }

    $failures = 0
    foreach ($target in $targets) {
        $output = & python $validator $target 2>&1
        if ($LASTEXITCODE -ne 0) {
            [Console]::Error.WriteLine("Skill validation failed: $target")
            [Console]::Error.WriteLine(($output -join "`n"))
            $failures++
        }
    }
    if ($failures -gt 0) { exit 1 }
    Write-Output "GENERATED_SKILL_VALIDATION_OK count=$($targets.Count)"
}
finally {
    if ($null -eq $previousPythonUtf8) { Remove-Item Env:PYTHONUTF8 -ErrorAction SilentlyContinue }
    else { $env:PYTHONUTF8 = $previousPythonUtf8 }
    $resolvedTemp = [System.IO.Path]::GetFullPath($tempRoot)
    if (-not $resolvedTemp.StartsWith($tempBase, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to remove non-temporary path: $resolvedTemp"
    }
    if (Test-Path -LiteralPath $resolvedTemp) { Remove-Item -LiteralPath $resolvedTemp -Recurse -Force }
}
