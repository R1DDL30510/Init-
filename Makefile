.PHONY: help test lint check
.ONESHELL:
SHELL := bash

help: ## Show help
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS=":.*?## "}; {printf "  %-12s %s\n", $$1, $$2}'

test: ## Run tests
	@if [ -x ./scripts/test.sh ]; then \
	  ./scripts/test.sh; \\
	elif command -v pwsh >/dev/null 2>&1 && [ -f ./scripts/test.ps1 ]; then \
	  pwsh -NoLogo -NoProfile -File ./scripts/test.ps1; \
	else \
	  echo "No test script found (scripts/test.sh or scripts/test.ps1)"; exit 1; \
	fi

lint: ## Run linters
	@if [ -x ./scripts/lint.sh ]; then \
	  ./scripts/lint.sh; \\
	elif command -v pwsh >/dev/null 2>&1 && [ -f ./scripts/lint.ps1 ]; then \
	  pwsh -NoLogo -NoProfile -File ./scripts/lint.ps1; \
	else \
	  echo "No lint script found (scripts/lint.sh or scripts/lint.ps1)"; exit 1; \
	fi

check: ## Tests + Lint
	@set -euo pipefail; \
	  $(MAKE) test; \
	  $(MAKE) lint; \
	  echo "All checks passed."

