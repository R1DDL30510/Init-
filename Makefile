.PHONY: help plan run test lint check commit probe aider aider-json
.ONESHELL:
SHELL := bash
MSG ?=
FILES ?=
RETURNJSON ?=
BRANCH ?=
SAVE ?=0

WORKFLOW_ARTIFACTS = docs/WORKFLOW.md .aider.conf.yml Makefile docs/RESCUE_MAINTAINER.md \
	scripts/syntax_probe.sh scripts/syntax_probe.ps1 \
	scripts/run.sh scripts/run.ps1 \
	scripts/test.sh scripts/test.ps1 \
	scripts/lint.sh scripts/lint.ps1 \
	scripts/check.sh scripts/check.ps1 \
	.githooks/pre-commit .githooks/pre-commit.ps1

define RUN_STEP
	@token="$$($(MAKE) --no-print-directory probe)"; \
	if [ "$$token" = 'BASH_OK' ]; then \
	  ./scripts/$(1).sh; \
	elif [ "$$token" = 'PS_OK' ]; then \
	  if command -v pwsh >/dev/null 2>&1; then \
	    pwsh -NoLogo -NoProfile -File ./scripts/$(1).ps1; \
	  else \
	    echo 'pwsh is required for PowerShell workflows.' >&2; \
	    exit 1; \
	  fi; \
	else \
	  echo "Unknown probe token $$token." >&2; \
	  exit 1; \
	fi
endef

help: ## Show help
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS=":.*?## "}; {printf "  %-12s %s\n", $$1, $$2}'

plan: ## Print the seven-phase workflow
	@printf 'Plan -> Save -> Execute -> Test -> Lint -> Check -> Commit\n'
	@printf 'Scripts: run/test/lint/check in scripts/, hooks in .githooks/.\n'
	@printf 'Tokens to expect: RUN_OK, TEST_OK, LINT_SKIPPED, CHECK_OK.\n'

run: ## Execute the CLI without network access
	$(call RUN_STEP,run)

test: ## Run tests
	$(call RUN_STEP,test)

lint: ## Run lint checks
	$(call RUN_STEP,lint)

check: ## Validate local services
	$(call RUN_STEP,check)

commit: test lint check ## Stage workflow artifacts and optionally commit
	@set -euo pipefail; \
	files="$(WORKFLOW_ARTIFACTS)"; \
	for path in $$files; do \
	  if [ -e "$$path" ]; then git add "$$path"; fi; \
	done; \
	if [ -n "$(MSG)" ]; then \
	  git commit -m "$(MSG)"; \
	else \
	  echo 'Workflow artifacts staged. Provide MSG="..." to auto-commit.'; \
	fi

aider: ## Run aider via deterministic wrapper (PowerShell on Windows, Bash elsewhere)
	@set -euo pipefail; \
	msg="$(strip $(MSG))"; \
	if [ -z "$$msg" ]; then \
	  echo 'Set MSG="..." to describe the task.' >&2; \
	  exit 2; \
	fi; \
	files="$(strip $(FILES))"; \
	branch="$(strip $(BRANCH))"; \
	save_flag="$(strip $(SAVE))"; \
	return_json="$(strip $(RETURNJSON))"; \
	if [ "${OS:-}" = 'Windows_NT' ]; then \
	  runner=(pwsh -NoLogo -NoProfile -File scripts/aider_call.ps1 -Prompt "$$msg"); \
	  files_flag='-Files'; \
	  branch_flag='-Branch'; \
	  save_switch='-Save'; \
	  json_switch='-ReturnJson'; \
	else \
	  runner=(bash scripts/aider_call.sh --Prompt "$$msg"); \
	  files_flag='--Files'; \
	  branch_flag='--Branch'; \
	  save_switch='--Save'; \
	  json_switch='--ReturnJson'; \
	fi; \
	if [ -n "$$files" ]; then \
	  runner+=("$$files_flag"); \
	  for f in $$files; do runner+=("$$f"); done; \
	fi; \
	if [ -n "$$branch" ]; then \
	  runner+=("$$branch_flag" "$$branch"); \
	fi; \
	if [ "$$save_flag" = '1' ]; then \
	  runner+=("$$save_switch"); \
	fi; \
	if [ -n "$$return_json" ] && [ "$$return_json" != '0' ]; then \
	  runner+=("$$json_switch"); \
	fi; \
	"${runner[@]}"

aider-json: ## Run aider target and force JSON output
	@$(MAKE) --no-print-directory aider RETURNJSON=1

probe: ## Detect active scripting environment
	@if [ -x ./scripts/syntax_probe.sh ]; then \
	  ./scripts/syntax_probe.sh; \
	elif command -v pwsh >/dev/null 2>&1 && [ -f ./scripts/syntax_probe.ps1 ]; then \
	  pwsh -NoLogo -NoProfile -File ./scripts/syntax_probe.ps1; \
	else \
	  echo 'Missing syntax probe scripts.' >&2; exit 1; \
	fi
