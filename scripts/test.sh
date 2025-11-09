#!/usr/bin/env bash
set -euo pipefail

python -m unittest -q

printf 'TEST_OK'
