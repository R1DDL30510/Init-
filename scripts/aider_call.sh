#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if command -v python3 >/dev/null 2>&1; then
  PYTHON_BIN=python3
elif command -v python >/dev/null 2>&1; then
  PYTHON_BIN=python
else
  echo 'python is required for scripts/aider_call.sh' >&2
  exit 127
fi

"$PYTHON_BIN" "$SCRIPT_DIR/aider_call_cli.py" "$@"
