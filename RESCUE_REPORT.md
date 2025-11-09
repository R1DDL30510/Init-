# RESCUE_REPORT.md

## Context (A1)
- Repo root: `C:/Users/garvis.G1MVP/myfiles/node1`
- Default branch: `main`
- Shell used: `pwsh`
- Scan timestamp (UTC): 2025-11-09T05:26Z
- Files indexed (excluding .git): 44, total 295,438 bytes (see `INVENTORY.json` for per-file hashes, encodings, and eol data).

## Key Findings (A2–A5)
1. **Layout drift & naming violations**
   - Numbered directories (`1) docs`, `4) scripts` … `12) .githooks`) break the kebab-case policy and hide the real assets. Scripts end up scattered across eight folders, and docs exist both in `docs/` and `1) docs/` with divergent content (`docs/WORKFLOW.md` is empty while `1) docs/WORKFLOW.md` has the authoritative 2,433-byte version).
   - Legacy `3) Makefile` hardcodes PowerShell in recipes, contradicting the “targets-only” rule and confusing the newer GNU Make file.
2. **Misplaced helper / noise files**
   - `.aider.chat.history.md` and `.aider.input.history` sit at repo root and should be quarantined per policy (#6 in prompt).
3. **Script hygiene gaps**
   - Bash wrappers (`run/test/lint/check.sh`) use CRLF endings and lack the executable bit, so they cannot run on Unix unless `bash` is invoked manually.
   - PowerShell equivalents do not exit with final codes (`run.ps1` / `test.ps1` only echo `$LASTEXITCODE`).
   - `lint.ps1` lives under `8) scripts/` and mixes localized strings; makefile references assume canonical `scripts/` paths that do not exist yet.
4. **Hook + automation issues**
   - `.githooks` directory is hidden under `12) .githooks` with a single file named `pre-commit (ps1 + sh)` that embeds conditional PowerShell/Bash logic and references non-existent `run_tests_and_lint` scripts.
   - No hook currently runs `make check`, so contributors can bypass the policy unintentionally.
5. **Line endings & permissions**
   - Inventory shows every `*.sh` file uses `CRLF` and lacks exec bits, while policy requires LF + executable. PS1 files already use CRLF with non-exec bits, which is compliant.

## Normalized Layout Proposal (A6)
- Create a single `scripts/` directory (plus `.githooks/` and `.rescue/_quarantine/…`). Move every numbered script there, keeping paired `.ps1/.sh` names (see `MOVE_PLAN.json`).
- Promote `1) docs/WORKFLOW.md` into `docs/WORKFLOW.md` after backing up the placeholder. Rename `2) .aider.conf.yml` into `.aider.conf.yml`.
- Quarantine noisy helper files and legacy automation (`3) Makefile`, `12) .githooks/pre-commit (ps1 + sh)`) under `.rescue/_quarantine` for traceability.

## Diff Plan Overview (A7)
- `scripts/lint.ps1`: rewrite to pure PowerShell flow—no Bash operators, clear messaging, explicit `exit 0/1`.
- `Makefile`: keep `.ONESHELL`/`SHELL := bash`, but point recipes to `./scripts/...` so the normalized layout works cross-platform.
- `.githooks/pre-commit`: add a simple Bash hook that runs `make check` with `set -euo pipefail`.
- See `DIFF_PLAN.udiff` for the exact hunks to apply post-move.

## Output Artifacts (A8)
- `INVENTORY.json` – file-level hashes, encoding, eol, exec bit snapshot.
- `MOVE_PLAN.json` – ordered list of directory creations, moves, and quarantine actions.
- `DIFF_PLAN.udiff` – unified diff covering lint script, Makefile, and hook creation.
- `FIX_CHECKLIST.md` – step-by-step list for APPLY phase.
- `RESCUE_REPORT.md` (this file).

## Next Step
Phase 1 ANALYZE is complete with no working-tree mutations beyond new artifacts. Await explicit token `APPROVE_APPLY` before executing the APPLY phase described in `FIX_CHECKLIST.md`.
