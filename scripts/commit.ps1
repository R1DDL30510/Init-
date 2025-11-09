#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Fail([string]$Message) {
    Write-Error $Message
    exit 1
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Fail 'git is required.'
}

git diff --cached --quiet | Out-Null
if ($LASTEXITCODE -eq 0) {
    Fail 'No staged changes to commit.'
}
if ($LASTEXITCODE -ne 1) {
    Fail 'git diff --cached failed.'
}

Write-Output 'Staged files ready for commit:'
git status -sb
Write-Output "Use emoji-flavored Conventional Commits, e.g., ':sparkles: feat: refine workflow'."
