#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import List, Tuple

DEFAULT_MODEL = "ollama_chat/qwen2.5-coder:14b"
DEFAULT_WEAK_MODEL = "ollama_chat/qwen3:4b"
DEFAULT_EDIT_FORMAT = "udiff"
ASCII_ALLOWED = {9, 10, 13}
ASCII_ALLOWED.update(range(32, 127))


def to_ascii(text: str) -> str:
    return "".join(ch if ord(ch) in ASCII_ALLOWED else " " for ch in text)


def read_prompt(prompt: str | None, prompt_file: str | None) -> Tuple[str, str]:
    if prompt_file:
        path = Path(prompt_file).expanduser().resolve()
        if not path.is_file():
            raise SystemExit(f"PromptFile not found: {path}")
        return to_ascii(path.read_text(encoding="utf-8")), str(path)
    if prompt:
        return to_ascii(prompt), "inline"
    raise SystemExit("Provide --Prompt or --PromptFile.")


def resolve_files(repo: Path, files: List[str] | None) -> List[str]:
    if not files:
        return []
    resolved: List[str] = []
    for entry in sorted(files):
        target = (repo / entry).expanduser().resolve()
        if not target.exists():
            raise SystemExit(f"Missing file: {target}")
        resolved.append(str(target))
    return resolved


def build_command(
    files: List[str],
    model: str,
    weak_model: str | None,
    edit_format: str,
    prompt: str,
    aider_args: List[str],
) -> List[str]:
    cmd: List[str] = [shutil.which("aider") or ""]
    if not cmd[0]:
        raise SystemExit("aider binary not found in PATH.")
    cmd.extend(files)
    cmd.extend(["--model", model])
    if weak_model:
        cmd.extend(["--weak-model", weak_model])
    cmd.extend(
        [
            "--edit-format",
            edit_format,
            "--no-show-model-warnings",
            "--no-check-update",
            "--message",
            prompt,
        ]
    )
    if aider_args:
        cmd.extend(to_ascii(arg) for arg in aider_args if arg)
    return cmd


def write_ascii(path: Path, contents: str) -> None:
    path.write_text(to_ascii(contents), encoding="ascii")


def time_marker() -> Tuple[str, str]:
    now = datetime.now(timezone.utc)
    timestamp = now.strftime("%Y%m%d-%H%M%S")
    iso = now.replace(microsecond=0).isoformat().replace("+00:00", "Z")
    return timestamp, iso


def apply_prefix(text: str, branch: str | None, save: bool) -> str:
    chunks: List[str] = []
    if branch:
        chunks.append(f"/branch {branch}")
    if save:
        chunks.append("/save")
    if chunks:
        text = "\n".join(chunks) + "\n" + text
    return to_ascii(text)


def main(argv: List[str] | None = None) -> int:
    parser = argparse.ArgumentParser(add_help=False, allow_abbrev=False)
    parser.add_argument("--Prompt", dest="prompt")
    parser.add_argument("--PromptFile", dest="prompt_file")
    parser.add_argument("--Files", dest="files", nargs="+")
    parser.add_argument("--ReturnJson", dest="return_json", action="store_true")
    parser.add_argument("--Branch", dest="branch")
    parser.add_argument("--Save", dest="save", action="store_true")
    parser.add_argument("--Model", dest="model", default=DEFAULT_MODEL)
    parser.add_argument("--WeakModel", dest="weak_model", default=DEFAULT_WEAK_MODEL)
    parser.add_argument(
        "--EditFormat",
        dest="edit_format",
        choices=["udiff", "whole"],
        default=DEFAULT_EDIT_FORMAT,
    )
    parser.add_argument("--RepoPath", dest="repo_path", default=".")
    parser.add_argument(
        "--AiderArgs", dest="aider_args", nargs=argparse.REMAINDER, default=[]
    )
    args = parser.parse_args(argv)

    prompt, prompt_source = read_prompt(args.prompt, args.prompt_file)
    prompt = apply_prefix(prompt, args.branch, args.save)

    repo = Path(args.repo_path).expanduser().resolve()
    log_dir = repo / ".logs" / "aider"
    log_dir.mkdir(parents=True, exist_ok=True)

    files = resolve_files(repo, args.files)
    cmd = build_command(
        files, args.model, args.weak_model, args.edit_format, prompt, args.aider_args
    )

    env = os.environ.copy()
    env.setdefault("OLLAMA_API_BASE", "http://172.23.176.1:11434")

    timestamp, started_at = time_marker()
    stdout_path = log_dir / f"aider-{timestamp}.out.txt"
    stderr_path = log_dir / f"aider-{timestamp}.err.txt"
    meta_path = log_dir / f"aider-{timestamp}.meta.json"

    start_time = datetime.now(timezone.utc)
    result = subprocess.run(cmd, cwd=repo, env=env, capture_output=True, text=True)
    end_time = datetime.now(timezone.utc)
    duration_ms = max(0, int((end_time - start_time).total_seconds() * 1000))
    ended_at = end_time.replace(microsecond=0).isoformat().replace("+00:00", "Z")

    stdout_text = to_ascii(result.stdout)
    stderr_text = to_ascii(result.stderr)
    write_ascii(stdout_path, stdout_text)
    write_ascii(stderr_path, stderr_text)

    meta = {
        "startedAt": started_at,
        "endedAt": ended_at,
        "durationMs": duration_ms,
        "repoPath": str(repo),
        "model": args.model,
        "weakModel": args.weak_model,
        "editFormat": args.edit_format,
        "branch": args.branch,
        "save": bool(args.save),
        "files": files,
        "promptSource": prompt_source,
        "stdoutFile": str(stdout_path),
        "stderrFile": str(stderr_path),
        "exitCode": result.returncode,
    }
    meta_path.write_text(
        json.dumps(meta, separators=(",", ":"), ensure_ascii=True) + "\n",
        encoding="ascii",
    )

    if args.return_json:
        summary = {
            "startedAt": started_at,
            "endedAt": ended_at,
            "durationMs": duration_ms,
            "repoPath": str(repo),
            "model": args.model,
            "weakModel": args.weak_model,
            "editFormat": args.edit_format,
            "exitCode": result.returncode,
            "stdoutFile": str(stdout_path),
            "stderrFile": str(stderr_path),
            "output": stdout_text.rstrip("\r\n"),
        }
        sys.stdout.write(json.dumps(summary, separators=(",", ":")))
    else:
        if stdout_text:
            sys.stdout.write(stdout_text)
    return result.returncode


if __name__ == "__main__":
    raise SystemExit(main())
