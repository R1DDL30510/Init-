#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

make test lint
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}
