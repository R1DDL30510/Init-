#!/usr/bin/env bash
set -euo pipefail

./scripts/test.sh
./scripts/lint.sh

echo "All checks passed."
