# Aider Wrapper Verification

## Evidence (POSIX shell)
```
$ command -v aider
/home/akrin/.local/bin/aider

$ type -a aider
aider is /home/akrin/.local/bin/aider
aider is /home/akrin/.local/bin/aider

$ alias | grep -i '^alias aider='
# (no output)

$ env | grep -E '^(AIDER_ARGS|AIDER_FLAGS)='
# (no output)

$ git ls-files -z | xargs -0 grep -n -- '--profiles='
docs/WORKFLOW.md:101:Use `docs/TEST.md` as the safe fixture for wrapper dry-runs. Both wrappers pin `OLLAMA_API_BASE` to `http://172.23.176.1:11434`, sanitize stdout to ASCII, log to `.logs/aider/aider-*.{out,err,meta}.txt/json`, and propagate aider's exit code. NOTE: `.aider.conf.yml` must define `profiles:` as a YAML mapping (see repo root), and injecting `--profiles=...` via CLI aliases is invalid—use `/profile review` or `--profile review` inside aider instead.
```

## Evidence (PowerShell)
`pwsh` is not available in this environment, so the Windows-specific queries could not be executed.

## Session Neutralization
```
$ unalias aider 2>/dev/null || true
$ unset AIDER_ARGS AIDER_FLAGS
$ hash -r || true
```

## Baseline CLI Smoke Test
`HOME=$PWD/.sandbox-home OLLAMA_API_BASE=http://172.23.176.1:11434 aider --message "ping" --yes --no-git --no-check-update`  
→ Exit 0 with the interactive reply “Pong! How can I assist you today?” confirming aider now accepts clean argv outside the wrappers.

## POSIX Wrapper Runs
All wrapper invocations reuse the sandbox HOME plus `OLLAMA_API_BASE=http://172.23.176.1:11434`. Each produced synchronized `.logs/aider/aider-20251109-0908xx.*` artifacts.

### Run 1: `bash scripts/aider_call.sh --Prompt "Echo ok" --Files docs/TEST.md`
- Exit 0 with the usual `Ok.` acknowledgement.
- Logs for `.logs/aider/aider-20251109-090812`:
  - `out.txt` first line `(blank/ASCII padding)`, last line `Tokens: 3.1k sent, 2 received.`
  - `err.txt` first/last line `Warning: Input is not a terminal (fd=0).`
  - `meta.json` captured `durationMs: 15391`, `files:["/mnt/c/Users/garvis.G1MVP/myfiles/node1/docs/TEST.md"]`, `exitCode:0`.

### Run 2: `make aider MSG="Echo ok" FILES="docs/TEST.md"`
- Exit 0; aider prints the same `Ok.` response while the Makefile wrapper captures stdout/err.
- Logs for `.logs/aider/aider-20251109-090833` mirror Run 1 with `durationMs: 5528` and identical first/last line patterns.

### Run 3: `make aider-json MSG="Echo ok" FILES="docs/TEST.md"`
- Exit 0 and emitted:
  ```
  {"startedAt":"2025-11-09T09:08:43Z","endedAt":"2025-11-09T09:08:48Z","durationMs":5801,"repoPath":"/mnt/c/Users/garvis.G1MVP/myfiles/node1","model":"ollama_chat/qwen2.5-coder:14b","weakModel":"ollama_chat/qwen3:4b","editFormat":"udiff","exitCode":0,"stdoutFile":"/mnt/c/Users/garvis.G1MVP/myfiles/node1/.logs/aider/aider-20251109-090843.out.txt","stderrFile":"/mnt/c/Users/garvis.G1MVP/myfiles/node1/.logs/aider/aider-20251109-090843.err.txt","output":"                                                                                \nAider v0.86.1\n...\nOk.                                                                              \n\nTokens: 3.1k sent, 2 received."}
  ```
- Logs for `.logs/aider/aider-20251109-090843` again show a blank `out.txt` first line, `Tokens: 3.1k sent, 2 received.` as the last line, and only the pseudo-TTY warning in `err.txt`.

## Diagnosis / Mitigation / Persistent Fix
- **Root cause:** aider 0.86.1 treats unknown YAML keys as positional args. The former `profiles:` mapping in `.aider.conf.yml` became a literal `--profiles={'architect':…}` entry, which then failed `os.stat`.
- **Fix:** `.aider.conf.yml` now keeps only supported keys while the canonical profile definitions live in `docs/AIDER_PROFILES.yml`. Wrappers still allow `/profile` commands inside aider.
- **Environment:** Both POSIX and PowerShell wrappers default `OLLAMA_API_BASE` to `http://172.23.176.1:11434`, pointing WSL at the Windows-hosted Ollama daemon, and `scripts/aider_call_cli.py` always passes `--no-check-update` to avoid sandbox home writes.

## Commit Checklist
1. All `127.0.0.1`/`localhost` references removed or replaced with `http://172.23.176.1:11434`.
2. `.aider.conf.yml` contains only supported keys (no `profiles:` section).
3. `docs/AIDER_PROFILES.yml` exists and is referenced from the workflow docs.
4. Wrapper scripts (`scripts/aider_call_cli.py`, `scripts/aider_call.sh`, `scripts/aider_call.ps1`) default to the Windows-hosted endpoint.
5. Latest successful log artifacts (`.logs/aider/aider-20251109-0908xx.*`) are present and cited above.
6. Smoke tests / verification commands succeed against the new endpoint (rerun if models or hosts change).
