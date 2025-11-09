# Aider Workflow Runbook

Deterministic, offline-first sequence for plan → save → execute → test → lint → check → commit. Works on Bash/zsh (macOS, Linux, WSL) and PowerShell (Windows) without touching external networks.
## Plan
- Bash/zsh:
  ```bash
  make plan
  ```
- PowerShell:
  ```powershell
  make plan
  ```

## Save
- Bash/zsh:
  ```bash
  git add -A && git status --porcelain
  ```
- PowerShell:
  ```powershell
  git add -A; git status --porcelain
  ```

## Execute
- Bash/zsh:
  ```bash
  make run
  ```
- PowerShell:
  ```powershell
  make run
  ```

## Test
- Bash/zsh:
  ```bash
  make test
  ```
- PowerShell:
  ```powershell
  make test
  ```

## Lint
- Bash/zsh:
  ```bash
  make lint
  ```
- PowerShell:
  ```powershell
  make lint
  ```

## Check
- Bash/zsh:
  ```bash
  make check
  ```
- PowerShell:
  ```powershell
  make check
  ```
Performs local-only health checks: `docker compose ps --format json`, `docker inspect` health probes, `curl http://localhost:5678/rest/health` for n8n, `curl http://localhost:8000/health` for the Supabase API, and `docker exec supabase-db pg_isready -U postgres`. Ends with `CHECK_OK`; never call `docker-compose` or remote URLs.

## Commit
- Bash/zsh:
  ```bash
  make commit MSG="workflow wired"
  ```
- PowerShell:
  ```powershell
  make commit MSG="workflow wired"
  ```

## Do Not Break Syntax
- English ASCII output only; local ports only; no external network requests.
- Use `docker compose` (never `docker-compose`).
- Bash scripts: `#!/usr/bin/env bash`, `set -euo pipefail`, quote variables, avoid process substitution, keep <120 lines.
- PowerShell scripts: `#!/usr/bin/env pwsh`, `Set-StrictMode -Version Latest`, `$ErrorActionPreference='Stop'`, prefer `Join-Path`, avoid backtick line breaks, keep <120 lines.

## Enable Hooks
- Bash/zsh:
  ```bash
  git config core.hooksPath .githooks
  ```
- PowerShell:
  ```powershell
  git config core.hooksPath .githooks
  ```
## Aider Call
- Windows (PowerShell): uses `scripts/aider_call.ps1`
- Linux/macOS/WSL: uses `scripts/aider_call.sh`
- Deterministic target:
  ```bash
  make aider MSG="Fix typos in README" FILES="docs/TEST.md"
  ```
- JSON summary (Codex monitoring):
  ```bash
  make aider MSG="Patch manifest" FILES="docs/TEST.md" RETURNJSON=1
  ```
Use `docs/TEST.md` as the safe fixture for wrapper dry-runs. Both wrappers pin `OLLAMA_API_BASE` to the Windows-hosted daemon at `http://172.23.176.1:11434`, sanitize stdout to ASCII, log to `.logs/aider/aider-*.{out,err,meta}.txt/json`, and propagate aider's exit code. NOTE: the canonical profile definitions now live in `docs/AIDER_PROFILES.yml`; do **not** reintroduce `profiles:` into `.aider.conf.yml`—select profiles at runtime via `/profile review` or `--profile review` inside aider instead.

> **Verification**
> POSIX (zsh/bash):
> ```bash
> bash scripts/aider_call.sh --Prompt "Echo ok" --Files docs/TEST.md || true
> make aider MSG="Echo ok" FILES="docs/TEST.md" || true
> make aider-json MSG="Echo ok" FILES="docs/TEST.md" || true
> ```
> Windows (PowerShell):
> ```powershell
> pwsh -File scripts/aider_call.ps1 -Prompt "Echo ok" -Files docs/TEST.md
> make aider MSG="Echo ok" FILES="docs/TEST.md"
> make aider-json MSG="Echo ok" FILES="docs/TEST.md"
> ```
> NOTE: If `aider` not found, restart the shell so PATH refreshes.

## Aider UI Run
```
/branch polish-workflow
/save
make plan
make run
make test
make lint
make check
/commit "workflow wired"
```

## Final Checklist
- Plan: `make plan` prints the seven-phase overview.
- Save: `git add -A` plus `git status --porcelain` only lists intended files.
- Execute: `make run` prints `RUN_OK`.
- Test: `make test` prints `TEST_OK`.
- Lint: `make lint` prints clean output or `LINT_SKIPPED`.
- Check: `make check` prints `CHECK_OK` after docker, HTTP, and `pg_isready` checks.
- Commit: `make commit MSG="..."` stages workflow artifacts and confirms hooks are active.
