#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Test-RuffConfig {
    if (Test-Path 'ruff.toml' -PathType Leaf -or Test-Path '.ruff.toml' -PathType Leaf) {
        return $true
    }

    if (Test-Path 'pyproject.toml' -PathType Leaf) {
        if (Select-String -LiteralPath 'pyproject.toml' -Pattern '[tool.ruff]' -SimpleMatch -Quiet) {
            return $true
        }
    }

    return $false
}

function Test-Pyflakes {
    python -c "import importlib.util, sys; sys.exit(0 if importlib.util.find_spec('pyflakes') else 1)" | Out-Null
    return ($LASTEXITCODE -eq 0)
}

if (Test-RuffConfig) {
    if (-not (Get-Command ruff -ErrorAction SilentlyContinue)) {
        Write-Error 'ruff configuration detected but ruff is not installed.'
        exit 1
    }

    ruff check .
    exit $LASTEXITCODE
}

if (Test-Pyflakes) {
    python -m pyflakes .
    exit $LASTEXITCODE
}

[Console]::Out.Write('LINT_SKIPPED')
