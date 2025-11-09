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

require_cmd git

for file in AGENTS.md docs/WORKFLOW.md; do
  if [ ! -f "$file" ]; then
    fail "$file is missing."
  fi
done

echo 'Plan checklist:'
echo '  - Review AGENTS.md for scope rules.'
echo '  - Follow docs/WORKFLOW.md for commands.'
echo 'Staged footprint:'
git status -sb
