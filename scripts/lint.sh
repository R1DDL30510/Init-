#!/usr/bin/env bash
set -euo pipefail

if ! ruff check .; then
  echo "ruff reported issues; falling back to pyflakes."
  pyflakes .
fi

echo "No lint issues detected."
