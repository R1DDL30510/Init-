 ruff check . || pyflakes .
if ($LASTEXITCODE -ne 0) {
    Write-Output "Линтерские ошибки обнаружены."
    exit 1
}
Write-Output "Нет линтерских ошибок."
