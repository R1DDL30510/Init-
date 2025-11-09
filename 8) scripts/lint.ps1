ruff check . || pyflakes .
if ($LASTEXITCODE -ne 0) {
    Write-Output "Lint errors detected."
    exit 1
}
Write-Output "No lint errors."
