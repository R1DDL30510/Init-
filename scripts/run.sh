#!/usr/bin/env bash
set -euo pipefail

CMD=(python -m src.cli)
if [ "$#" -gt 0 ]; then
  CMD+=("$@")
else
  CMD+=(hello --name Workflow)
fi

if ! "${CMD[@]}" >/dev/null; then
  echo 'run failed' >&2
  exit 1
fi

printf 'RUN_OK'
