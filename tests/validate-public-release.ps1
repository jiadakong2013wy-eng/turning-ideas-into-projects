$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$publicUrl = 'https://github.com/jiadakong2013wy-eng/turning-ideas-into-projects.git'
$failures = [System.Collections.Generic.List[string]]::new()

foreach ($required in @('README.md', 'LICENSE', '.agents\plugins\marketplace.json', 'scripts\install.ps1')) {
    if (-not (Test-Path -LiteralPath (Join-Path $repoRoot $required) -PathType Leaf)) {
        $failures.Add("Missing public release file: $required")
    }
}

$manifestPath = Join-Path $repoRoot 'plugins\mingkon-idea-to-project\.codex-plugin\plugin.json'
if (Test-Path -LiteralPath $manifestPath -PathType Leaf) {
    $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
    if ($manifest.repository -ne $publicUrl) {
        $failures.Add("Plugin repository URL is not public GitHub: $($manifest.repository)")
    }
}

$allowedTopLevel = @('.agents', '.git', '.gitignore', 'LICENSE', 'README.md', 'plugins', 'scripts', 'tests', 'third_party')
foreach ($item in Get-ChildItem -Force -LiteralPath $repoRoot) {
    if ($item.Name -notin $allowedTopLevel) {
        $failures.Add("Unexpected public top-level item: $($item.Name)")
    }
}

$privatePatterns = @(
    ('58' + '\.251\.255\.19'),
    ('mk' + 'admin'),
    ('01a' + '[0-9a-f-]{20,}'),
    ('C:' + '\\Users\\'),
    ('D:' + '\\mingkonSKILL')
)
$publicFiles = Get-ChildItem -Recurse -File -LiteralPath $repoRoot | Where-Object {
    $_.FullName -notlike (Join-Path $repoRoot '.git\*') -and
    $_.FullName -notlike (Join-Path $repoRoot 'plugins\superpowers\*') -and
    $_.FullName -ne $PSCommandPath
}
foreach ($file in $publicFiles) {
    $content = Get-Content -LiteralPath $file.FullName -Raw -ErrorAction SilentlyContinue
    foreach ($pattern in $privatePatterns) {
        if ($content -match $pattern) {
            $relative = $file.FullName.Substring($repoRoot.Length).TrimStart('\')
            $failures.Add("Private-source marker found in $relative")
            break
        }
    }
}

$secretPattern = ('BEGIN ' + '(RSA |OPENSSH |EC )?' + 'PRIVATE KEY|gh[pousr]_[A-Za-z0-9_]+|AKIA[0-9A-Z]{16}|sk-[A-Za-z0-9]{20,}')
foreach ($file in $publicFiles) {
    $content = Get-Content -LiteralPath $file.FullName -Raw -ErrorAction SilentlyContinue
    if ($content -match $secretPattern) {
        $relative = $file.FullName.Substring($repoRoot.Length).TrimStart('\')
        $failures.Add("Possible secret found in $relative")
    }
}

$installer = Join-Path $repoRoot 'scripts\install.ps1'
$fakeCodex = Join-Path $repoRoot 'tests\fixtures\fake-codex.ps1'
if ((Test-Path -LiteralPath $installer -PathType Leaf) -and (Test-Path -LiteralPath $fakeCodex -PathType Leaf)) {
    $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("public-release-test-" + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
    $env:MINGKON_FAKE_CODEX_LOG = Join-Path $tempRoot 'codex.log'
    $env:MINGKON_FAKE_MARKETPLACE_PRESENT = '0'
    try {
        & pwsh -NoProfile -File $installer -CodexCommand $fakeCodex | Out-Null
        if ($LASTEXITCODE -ne 0) {
            $failures.Add("Public installer exited with $LASTEXITCODE")
        }
        else {
            $commands = Get-Content -LiteralPath $env:MINGKON_FAKE_CODEX_LOG -Raw
            $expectedAdd = "plugin marketplace add $publicUrl --ref main"
            if ($commands -notmatch [regex]::Escape($expectedAdd)) {
                $failures.Add('Public installer default did not use the GitHub repository.')
            }
        }
    }
    finally {
        Remove-Item Env:MINGKON_FAKE_CODEX_LOG -ErrorAction SilentlyContinue
        Remove-Item Env:MINGKON_FAKE_MARKETPLACE_PRESENT -ErrorAction SilentlyContinue
        [System.IO.Directory]::Delete($tempRoot, $true)
    }
}

if ($failures.Count -gt 0) {
    throw ($failures -join "`n")
}

Write-Output 'PUBLIC_RELEASE_VALIDATION_OK'
