$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$installer = Join-Path $repoRoot 'scripts/install.ps1'
$fakeCodex = Join-Path $PSScriptRoot 'fixtures/fake-codex.ps1'
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("mingkon-installer-test-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

try {
    if (-not (Test-Path -LiteralPath $installer -PathType Leaf)) { throw "Installer missing: $installer" }

    $missingOutput = & pwsh -NoProfile -File $installer -MarketplaceUrl 'ssh://example/repo.git' -CodexCommand (Join-Path $tempRoot 'missing-codex.exe') 2>&1
    if ($LASTEXITCODE -eq 0) { throw 'Installer must fail when the Codex command is missing.' }
    if (($missingOutput -join "`n") -notmatch 'Codex CLI') { throw 'Missing-Codex failure must name the Codex CLI.' }

    $env:MINGKON_FAKE_CODEX_LOG = Join-Path $tempRoot 'first-install.log'
    $env:MINGKON_FAKE_MARKETPLACE_PRESENT = '0'
    & pwsh -NoProfile -File $installer -MarketplaceUrl 'ssh://example/repo.git' -MarketplaceRef 'main' -CodexCommand $fakeCodex
    if ($LASTEXITCODE -ne 0) { throw 'Fresh install simulation failed.' }
    $first = Get-Content -LiteralPath $env:MINGKON_FAKE_CODEX_LOG -Raw
    foreach ($expected in @(
        'plugin marketplace add ssh://example/repo.git --ref main',
        'plugin add superpowers@mingkon-skills',
        'plugin add mingkon-idea-to-project@mingkon-skills',
        'plugin list'
    )) {
        if ($first -notmatch [regex]::Escape($expected)) { throw "Fresh install missed command: $expected" }
    }

    $env:MINGKON_FAKE_CODEX_LOG = Join-Path $tempRoot 'repeat-install.log'
    $env:MINGKON_FAKE_MARKETPLACE_PRESENT = '1'
    & pwsh -NoProfile -File $installer -MarketplaceUrl 'ssh://example/repo.git' -MarketplaceRef 'main' -CodexCommand $fakeCodex
    if ($LASTEXITCODE -ne 0) { throw 'Repeat install simulation failed.' }
    $repeat = Get-Content -LiteralPath $env:MINGKON_FAKE_CODEX_LOG -Raw
    if ($repeat -notmatch 'plugin marketplace upgrade mingkon-skills') { throw 'Repeat install must upgrade the existing marketplace.' }
    if ($repeat -match 'plugin marketplace add') { throw 'Repeat install must not add a duplicate marketplace.' }

    Write-Output 'INSTALLER_VALIDATION_OK'
}
finally {
    Remove-Item Env:MINGKON_FAKE_CODEX_LOG -ErrorAction SilentlyContinue
    Remove-Item Env:MINGKON_FAKE_MARKETPLACE_PRESENT -ErrorAction SilentlyContinue
    if (Test-Path -LiteralPath $tempRoot) { Remove-Item -LiteralPath $tempRoot -Recurse -Force }
}
