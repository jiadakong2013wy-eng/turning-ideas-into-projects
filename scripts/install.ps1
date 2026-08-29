[CmdletBinding()]
param(
    [string]$MarketplaceUrl = 'https://github.com/jiadakong2013wy-eng/turning-ideas-into-projects.git',
    [string]$MarketplaceRef = 'main',
    [string]$CodexCommand = 'codex'
)

$ErrorActionPreference = 'Stop'
$marketplaceName = 'mingkon-skills'
$plugins = @('superpowers', 'mingkon-idea-to-project')

function Stop-Install {
    param([string]$Message, [int]$Code = 1)
    [Console]::Error.WriteLine($Message)
    exit $Code
}

function Invoke-Codex {
    param([string[]]$Arguments)
    try {
        $output = & $CodexCommand @Arguments 2>&1
        $code = $LASTEXITCODE
    }
    catch {
        Stop-Install "Codex CLI could not run: $($_.Exception.Message)" 2
    }
    if ($code -ne 0) {
        Stop-Install "Codex CLI command failed ($code): codex $($Arguments -join ' ')`n$($output -join "`n")" $code
    }
    return @($output)
}

if ($CodexCommand -match '[\\/]') {
    if (-not (Test-Path -LiteralPath $CodexCommand -PathType Leaf)) {
        Stop-Install "Codex CLI was not found at: $CodexCommand" 2
    }
}
elseif (-not (Get-Command $CodexCommand -ErrorAction SilentlyContinue)) {
    Stop-Install "Codex CLI command was not found: $CodexCommand" 2
}

$marketplaces = Invoke-Codex @('plugin', 'marketplace', 'list')
if (($marketplaces -join "`n") -match "(?m)^$([regex]::Escape($marketplaceName))\b") {
    Invoke-Codex @('plugin', 'marketplace', 'upgrade', $marketplaceName) | Out-Null
}
else {
    Invoke-Codex @('plugin', 'marketplace', 'add', $MarketplaceUrl, '--ref', $MarketplaceRef) | Out-Null
}

foreach ($plugin in $plugins) {
    Invoke-Codex @('plugin', 'add', "$plugin@$marketplaceName") | Out-Null
}

$installed = Invoke-Codex @('plugin', 'list')
$installedText = $installed -join "`n"
foreach ($plugin in $plugins) {
    if ($installedText -notmatch [regex]::Escape("$plugin@$marketplaceName")) {
        Stop-Install "Codex CLI did not read back $plugin@$marketplaceName after installation." 3
    }
}

Write-Output 'Installed: Superpowers and Turning Ideas into Projects.'
Write-Output 'Restart Codex, create a new task, and enter: /turning-ideas-into-projects your idea'
