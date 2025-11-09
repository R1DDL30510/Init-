#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

python -m unittest -q
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

[Console]::Out.Write('TEST_OK')
