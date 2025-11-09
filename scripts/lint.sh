#!/usr/bin/env bash
set -euo pipefail

has_ruff_config() {
  if [ -f "ruff.toml" ] || [ -f ".ruff.toml" ]; then
    return 0
  fi

  if [ -f "pyproject.toml" ] && grep -Fq "[tool.ruff]" pyproject.toml; then
    return 0
  fi

  return 1
}

pyflakes_available() {
  python - <<'PY' >/dev/null 2>&1
import importlib.util
import sys

spec = importlib.util.find_spec('pyflakes')
sys.exit(0 if spec else 1)
PY
}

if has_ruff_config; then
  if ! command -v ruff >/dev/null 2>&1; then
    echo 'ruff configuration detected but ruff is not installed.' >&2
    exit 1
  fi
  ruff check .
elif pyflakes_available; then
  python -m pyflakes .
else
  printf 'LINT_SKIPPED'
fi
