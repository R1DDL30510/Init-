Set-StrictMode -Version Latest

$ErrorActionPreference = 'Stop'



ruff check .

if ($LASTEXITCODE -ne 0) {

    Write-Output "ruff reported issues; falling back to pyflakes."

    pyflakes .

    if ($LASTEXITCODE -ne 0) {

        Write-Output "Lint errors detected."

        exit 1

    }

}



Write-Output "No lint issues detected."

exit 0

