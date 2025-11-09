Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

python -m unittest discover -s tests
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

exit 0
