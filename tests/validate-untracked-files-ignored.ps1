$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$fixturePath = Join-Path $repoRoot 'tests/.untracked-placeholder-fixture.md'

try {
    Set-Content -LiteralPath $fixturePath -Value ('T' + 'BD: this untracked draft must not affect package validation.') -Encoding UTF8

    $output = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'validate-package.ps1') 2>&1
    if ($LASTEXITCODE -ne 0) {
        $output | ForEach-Object { Write-Output $_ }
        throw 'Package validation must ignore untracked draft files.'
    }

    Write-Output 'UNTRACKED_FILES_IGNORED_OK'
}
finally {
    if (Test-Path -LiteralPath $fixturePath) {
        Remove-Item -LiteralPath $fixturePath -Force
    }
}
