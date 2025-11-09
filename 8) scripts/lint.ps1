try {
    ruff check . -ErrorAction Stop || pyflakes .
} catch {
    Write-Output "Линтерские ошибки обнаружены."
    exit 1
}
Write-Output "Нет линтерских ошибок."
