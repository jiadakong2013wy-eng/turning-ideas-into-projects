$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$errors = [System.Collections.Generic.List[string]]::new()
function Assert-True([bool]$Condition, [string]$Message) {
    if (-not $Condition) { $script:errors.Add($Message) }
}
function Read-Required([string]$Path) {
    Assert-True (Test-Path -LiteralPath $Path -PathType Leaf) "Missing file: $Path"
    if (Test-Path -LiteralPath $Path -PathType Leaf) { return Get-Content -LiteralPath $Path -Raw -Encoding UTF8 }
    return ''
}

$root = Join-Path $repoRoot 'plugins/mingkon-idea-to-project/skills/turning-ideas-into-projects'
$skill = Read-Required (Join-Path $root 'SKILL.md')
$upgrade = Read-Required (Join-Path $root 'references/existing-project-upgrade.md')
$receipts = Read-Required (Join-Path $root 'references/stage-receipts.md')

foreach ($phrase in @('new_project','existing_project_upgrade','定位','理解','定方向','定计划','定合同','执行验证','独立验收与下一步')) {
    Assert-True ($skill.Contains($phrase)) "Main Skill missing: $phrase"
}
foreach ($phrase in @('Priority','Optional','Excluded','Unresolved','static_understanding','BASELINE_CONFIRMATION','historical clues','unchecked scope')) {
    Assert-True ($upgrade.Contains($phrase)) "Upgrade reference missing: $phrase"
}
foreach ($phrase in @('第 <current>/7 阶段','已完成：','当前结果：','剩余任务：','**下一步计划：','**需要你处理：','**特别提醒：','**阻塞原因：')) {
    Assert-True ($receipts.Contains($phrase)) "Receipt reference missing: $phrase"
}
Assert-True ($skill.Contains('[references/existing-project-upgrade.md](references/existing-project-upgrade.md)')) 'Main Skill must route to existing-project guidance.'
Assert-True ($skill.Contains('[references/stage-receipts.md](references/stage-receipts.md)')) 'Main Skill must route to receipt guidance.'

if ($errors.Count) { $errors | ForEach-Object { [Console]::Error.WriteLine("ERROR: $_") }; exit 1 }
Write-Output 'EXISTING_PROJECT_LIFECYCLE_OK'
