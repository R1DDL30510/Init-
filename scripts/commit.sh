#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "$1" >&2
  exit 1
}

if ! command -v git >/dev/null 2>&1; then
  fail 'git is required.'
fi

if git diff --cached --quiet; then
  fail 'No staged changes to commit.'
fi

echo 'Staged files ready for commit:'
git status -sb
echo "Use emoji-flavored Conventional Commits, e.g., ':sparkles: feat: refine workflow'."
