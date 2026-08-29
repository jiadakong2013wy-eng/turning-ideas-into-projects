param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Arguments)

if (-not $env:MINGKON_FAKE_CODEX_LOG) { throw 'MINGKON_FAKE_CODEX_LOG is required.' }
Add-Content -LiteralPath $env:MINGKON_FAKE_CODEX_LOG -Value ($Arguments -join ' ')

$command = $Arguments -join ' '
if ($command -eq 'plugin marketplace list') {
    if ($env:MINGKON_FAKE_MARKETPLACE_PRESENT -eq '1') { Write-Output 'mingkon-skills  ssh://example/repo.git' }
    exit 0
}
if ($command -eq 'plugin list') {
    Write-Output 'superpowers@mingkon-skills 6.3.0'
    Write-Output 'mingkon-idea-to-project@mingkon-skills 0.1.1'
    exit 0
}
exit 0
