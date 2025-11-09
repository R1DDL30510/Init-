#!/usr/bin/env pwsh
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$RemainingArgs
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not $RemainingArgs -or $RemainingArgs.Count -eq 0) {
    $RemainingArgs = @('hello', '--name', 'Workflow')
}

python -m src.cli @RemainingArgs | Out-Null
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

[Console]::Out.Write('RUN_OK')
