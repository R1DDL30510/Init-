#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Fail([string]$Message) {
    [Console]::Error.WriteLine($Message)
    exit 1
}

function Require-Command([string]$Name) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        Fail "$Name is required."
    }
}

Require-Command docker

try {
    docker compose version | Out-Null
} catch {
    Fail 'docker compose is required.'
}

$composeJson = docker compose ps --format json
if (-not $composeJson) {
    Fail 'docker compose ps returned no data.'
}

$services = @($composeJson | ConvertFrom-Json)
$prefixes = @('supabase-db', 'supabase-api', 'supabase-storage', 'n8n')
$containers = @{}

foreach ($prefix in $prefixes) {
    $match = $services | Where-Object { $_.Name -like "*$prefix*" } | Select-Object -First 1
    if (-not $match) {
        Fail "Container with prefix $prefix not found."
    }

    $state = ($match.State | ForEach-Object { $_.ToLowerInvariant() })
    $status = ($match.Status | ForEach-Object { $_.ToLowerInvariant() })
    if ($state -ne 'running' -and -not ($status -like '*up*')) {
        Fail "$($match.Name) is not running."
    }

    $containers[$prefix] = $match.Name
}

foreach ($prefix in $prefixes) {
    $name = $containers[$prefix]
    $health = ''
    try {
        $health = docker inspect -f '{{.State.Health.Status}}' $name 2>$null
    } catch {
        $health = ''
    }

    if ($health) {
        $trimmed = $health.Trim()
        if ($trimmed -eq '<nil>' -or $trimmed -eq 'null') {
            $trimmed = ''
        }
        if ($trimmed -and $trimmed -ne 'healthy') {
            Fail "$name health is $trimmed."
        }
    }
}

try {
    $n8nResponse = Invoke-WebRequest -Uri 'http://localhost:5678/rest/health' -UseBasicParsing -TimeoutSec 5
} catch {
    Fail 'n8n health endpoint unreachable.'
}
if ($n8nResponse.StatusCode -ne 200) {
    Fail "n8n health returned HTTP $($n8nResponse.StatusCode)."
}
if ($n8nResponse.Content -notmatch '"status":"ok"') {
    Fail 'n8n health payload missing status ok.'
}

try {
    $supabaseResponse = Invoke-WebRequest -Uri 'http://localhost:8000/health' -UseBasicParsing -TimeoutSec 5
} catch {
    Fail 'Supabase API health endpoint unreachable.'
}
if ($supabaseResponse.StatusCode -ne 200) {
    Fail "Supabase API health returned HTTP $($supabaseResponse.StatusCode)."
}

$postgresName = $containers['supabase-db']
try {
    docker exec $postgresName pg_isready -U postgres | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Fail "pg_isready failed inside $postgresName."
    }
} catch {
    Fail "pg_isready failed inside $postgresName."
}

[Console]::Out.Write('CHECK_OK')
