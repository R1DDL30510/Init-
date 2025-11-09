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

foreach ($path in @('AGENTS.md', 'docs/WORKFLOW.md')) {
    if (-not (Test-Path $path -PathType Leaf)) {
        Fail "$path is missing."
    }
}

Write-Output 'Plan checklist:'
Write-Output '  - Review AGENTS.md for scope rules.'
Write-Output '  - Follow docs/WORKFLOW.md for commands.'
Write-Output 'Staged footprint:'
git status -sb
