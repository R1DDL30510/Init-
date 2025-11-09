#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "$1" >&2
  exit 1
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    fail "$1 is required."
  fi
}

require_cmd docker
require_cmd python
require_cmd curl

if ! docker compose version >/dev/null 2>&1; then
  fail 'docker compose is required.'
fi

compose_json=$(docker compose ps --format json) || fail 'docker compose ps failed.'
json_file=$(mktemp)
map_file=$(mktemp)
trap 'rm -f "$json_file" "$map_file"' EXIT

printf '%s\n' "$compose_json" > "$json_file"

python <<'PY' "$json_file" > "$map_file"
import json
import sys

path = sys.argv[1]
try:
    with open(path, 'r', encoding='utf-8') as handle:
        data = json.load(handle)
except Exception as exc:  # pylint: disable=broad-except
    print(f'Failed to parse docker compose output: {exc}', file=sys.stderr)
    sys.exit(1)

prefixes = ['supabase-db', 'supabase-api', 'supabase-storage', 'n8n']
lines = []
for prefix in prefixes:
    match = None
    for item in data:
        name = item.get('Name') or ''
        if prefix in name:
            match = item
            break
    if match is None:
        print(f'Container with prefix {prefix} not found.', file=sys.stderr)
        sys.exit(1)
    state = (match.get('State') or '').lower()
    status = (match.get('Status') or '').lower()
    if state != 'running' and 'up' not in status:
        label = match.get('Name') or prefix
        print(f'{label} is not running.', file=sys.stderr)
        sys.exit(1)
    lines.append(f"{prefix}:{match.get('Name', '')}")

for entry in lines:
    print(entry)
PY

declare -A containers=()
while IFS= read -r pair; do
  [ -z "$pair" ] && continue
  prefix=${pair%%:*}
  name=${pair#*:}
  containers["$prefix"]="$name"
done < "$map_file"

prefixes=(supabase-db supabase-api supabase-storage n8n)
for prefix in "${prefixes[@]}"; do
  name=${containers[$prefix]:-}
  if [ -z "$name" ]; then
    fail "Container lookup failed for $prefix."
  fi
  health_status=''
  if health_status=$(docker inspect -f '{{.State.Health.Status}}' "$name" 2>/dev/null); then
    trimmed=$(printf '%s' "$health_status" | tr -d '\r')
    if [ "$trimmed" = '<nil>' ] || [ "$trimmed" = 'null' ]; then
      trimmed=''
    fi
    if [ -n "$trimmed" ] && [ "$trimmed" != 'healthy' ]; then
      fail "$name health is $trimmed."
    fi
  fi
done

if ! n8n_response=$(curl -sS -o - -w 'HTTPSTATUS:%{http_code}' http://localhost:5678/rest/health); then
  fail 'n8n health endpoint unreachable.'
fi
n8n_http=${n8n_response##*HTTPSTATUS:}
n8n_body=${n8n_response%HTTPSTATUS:*}
if [ "$n8n_http" != '200' ]; then
  fail "n8n health returned HTTP $n8n_http."
fi
if ! printf '%s' "$n8n_body" | grep -Fq '"status":"ok"'; then
  fail 'n8n health payload missing status ok.'
fi

if ! supabase_response=$(curl -sS -o - -w 'HTTPSTATUS:%{http_code}' http://localhost:8000/health); then
  fail 'Supabase API health endpoint unreachable.'
fi
supabase_http=${supabase_response##*HTTPSTATUS:}
if [ "$supabase_http" != '200' ]; then
  fail "Supabase API health returned HTTP $supabase_http."
fi

postgres_container=${containers['supabase-db']}
if ! docker exec "$postgres_container" pg_isready -U postgres >/dev/null 2>&1; then
  fail "pg_isready failed inside $postgres_container."
fi

printf 'CHECK_OK'
