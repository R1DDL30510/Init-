#!/usr/bin/env pwsh
[CmdletBinding()]
param(
    [string]$Prompt,
    [string]$PromptFile,
    [string[]]$Files,
    [switch]$ReturnJson,
    [string]$Branch,
    [switch]$Save,
    [string]$Model = 'ollama_chat/qwen2.5-coder:14b',
    [string]$WeakModel = 'ollama_chat/qwen3:4b',
    [ValidateSet('udiff','whole')][string]$EditFormat = 'udiff',
    [string]$RepoPath = (Get-Location).Path,
    [string[]]$AiderArgs = @()
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [Text.Encoding]::ASCII
[Console]::InputEncoding = [Text.Encoding]::ASCII
function To-Ascii {
    param([string]$Text)
    if (-not $Text) { return '' }
    return [Text.Encoding]::ASCII.GetString([Text.Encoding]::ASCII.GetBytes($Text))
}
function Resolve-RepoItem {
    param([string]$Root,[string]$Child)
    if (-not $Child) { return $null }
    $full = Join-Path -Path $Root -ChildPath $Child
    return (Resolve-Path -LiteralPath $full).Path
}
if ($PromptFile) { $Prompt = To-Ascii (Get-Content -LiteralPath $PromptFile -Raw) }
if (-not $Prompt) { throw 'Provide -Prompt or -PromptFile.' }
$promptSource = if ($PromptFile) { (Resolve-Path -LiteralPath $PromptFile).Path } else { 'inline' }
if (-not $env:OLLAMA_API_BASE) { $env:OLLAMA_API_BASE = 'http://172.23.176.1:11434' }
$repo = (Resolve-Path -LiteralPath $RepoPath).Path
$logDir = Join-Path -Path $repo -ChildPath '.logs/aider'
if (-not (Test-Path -LiteralPath $logDir)) { New-Item -ItemType Directory -Path $logDir | Out-Null }
$startTime = Get-Date -AsUTC
$stamp = $startTime.ToString('yyyyMMdd-HHmmss')
$startedAt = $startTime.ToString('s') + 'Z'
$base = Join-Path -Path $logDir -ChildPath "aider-$stamp"
$stdoutPath = "$base.out.txt"
$stderrPath = "$base.err.txt"
$metaPath = "$base.meta.json"
$filesResolved = @()
if ($Files) {
    foreach ($f in ($Files | Where-Object { $_ } | Sort-Object -Culture 'en-US')) {
        $filesResolved += Resolve-RepoItem -Root $repo -Child $f
    }
}
$prefix = ''
if ($Branch) { $prefix += "/branch $Branch`n" }
if ($Save) { $prefix += "/save`n" }
$Prompt = To-Ascii ($prefix + $Prompt)
$argList = @('--model',$Model)
if ($WeakModel) { $argList += @('--weak-model',$WeakModel) }
$argList += @('--edit-format',$EditFormat,'--message',$Prompt)
if ($filesResolved) { $argList = $filesResolved + $argList }
if ($AiderArgs) {
    foreach ($extra in ($AiderArgs | Where-Object { $_ })) {
        $argList += (To-Ascii $extra)
    }
}
$cmd = (Get-Command -Name 'aider' -ErrorAction Stop).Path
$exitCode = 0
Push-Location -LiteralPath $repo
try {
    $proc = Start-Process -FilePath $cmd -ArgumentList $argList -WorkingDirectory $repo -NoNewWindow -RedirectStandardOutput $stdoutPath -RedirectStandardError $stderrPath -Wait -PassThru
    $exitCode = $proc.ExitCode
} finally {
    Pop-Location
}
$outText = (Test-Path -LiteralPath $stdoutPath) ? (To-Ascii (Get-Content -LiteralPath $stdoutPath -Raw)) : ''
$errText = (Test-Path -LiteralPath $stderrPath) ? (To-Ascii (Get-Content -LiteralPath $stderrPath -Raw)) : ''
[System.IO.File]::WriteAllText($stdoutPath, $outText, [Text.Encoding]::ASCII)
[System.IO.File]::WriteAllText($stderrPath, $errText, [Text.Encoding]::ASCII)
$endTime = Get-Date -AsUTC
$endedAt = $endTime.ToString('s') + 'Z'
$durationMs = [Math]::Max(0, [int][Math]::Floor(($endTime - $startTime).TotalMilliseconds))
$meta = [ordered]@{
    startedAt = $startedAt
    endedAt = $endedAt
    durationMs = $durationMs
    repoPath = $repo
    model = $Model
    weakModel = $WeakModel
    editFormat = $EditFormat
    branch = $Branch
    save = [bool]$Save
    files = $filesResolved
    promptSource = $promptSource
    stdoutFile = $stdoutPath
    stderrFile = $stderrPath
    exitCode = $exitCode
}
Set-Content -LiteralPath $metaPath -Value ((ConvertTo-Json $meta -Depth 4 -Compress)) -Encoding ASCII
if ($ReturnJson) {
    $summary = [ordered]@{
        startedAt = $startedAt
        endedAt = $endedAt
        durationMs = $durationMs
        repoPath = $repo
        model = $Model
        weakModel = $WeakModel
        editFormat = $EditFormat
        exitCode = $exitCode
        stdoutFile = $stdoutPath
        stderrFile = $stderrPath
        output = $outText.TrimEnd()
    }
    [Console]::Out.Write(($summary | ConvertTo-Json -Depth 4 -Compress))
} else {
    if ($outText) { [Console]::Out.Write($outText) }
}
exit $exitCode
