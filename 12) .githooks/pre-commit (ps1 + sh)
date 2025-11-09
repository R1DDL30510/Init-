@if ($IsWindows) { .\scripts\run_tests_and_lint.ps1 } else { ./scripts/run_tests_and_lint.sh }
if ($LASTEXITCODE -ne 0) {
    Write-Output "Commit blocked due to failed tests or linting."
    exit 1
}
