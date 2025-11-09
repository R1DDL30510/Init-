# scripts/lint.ps1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

ruff check .
if ($LASTEXITCODE -ne 0) {
    pyflakes .
    if ($LASTEXITCODE -ne 0) {
        Write-Output "Линтерские ошибки обнаружены."
        exit 1
    }
}

Write-Output "Нет линтерских ошибок."
