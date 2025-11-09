# FIX_CHECKLIST.md

- [ ] Create backup snapshot under `.rescue/_quarantine/<UTC timestamp>` covering every file to be moved or edited (per `MOVE_PLAN.json`).
- [ ] Ensure target directories exist: `scripts/`, `.githooks/`, `.rescue/_quarantine/{aider,docs,scripts,githooks}`.
- [ ] Execute each MOVE operation in `MOVE_PLAN.json` (ordered), including quarantining `.aider.*`, legacy Makefile, and the numbered script folders; then remove the now-empty numbered directories.
- [ ] Overwrite `docs/WORKFLOW.md` with the curated copy after backing up the placeholder listed in the plan.
- [ ] Apply the patches in `DIFF_PLAN.udiff` (`scripts/lint.ps1`, `Makefile`, `.githooks/pre-commit`).
- [ ] Normalize line endings + permissions:
  - `*.sh` → LF, UTF-8, executable bit on.
  - `*.ps1` → CRLF, UTF-8, no executable bit.
  - `*.md` / configs → LF, UTF-8.
- [ ] Run `make check`; if it fails, restore from backup and report.
- [ ] Stage & commit with `feat(repo): rescue & normalize layout (scripts/docs/hooks, lint/makefile fixes)` once validation passes.
