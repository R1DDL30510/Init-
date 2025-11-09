try {
    ruff check . -ErrorAction Stop
} catch {
    pyflakes .
    if ($LASTEXITCODE -ne 0) {
        Write-Output "Линтерские ошибки обнаружены."
        exit 1
    }
}
