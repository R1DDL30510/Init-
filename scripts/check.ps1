Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

pwsh -NoLogo -NoProfile -File (Join-Path $PSScriptRoot 'test.ps1')
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

pwsh -NoLogo -NoProfile -File (Join-Path $PSScriptRoot 'lint.ps1')
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

Write-Output "All checks passed."
exit 0
