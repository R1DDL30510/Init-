# Repository Guidelines

## Project Structure & Module Organization
`src/` hosts the CLI entry points (`main.py` for the demo, `cli.py` for the plugin-aware dispatcher), which delegate into `core/cli.py` and `core/task_manager.py`. Long-lived configuration, logging helpers, and orchestration utilities sit in `core/`, while shared helper functions belong in `utils/`. Optional plugins live in `plugins/` and must expose `execute()`. Documentation artifacts live in `docs/`, sample data or fixtures sit in `data/`, and persistent logs always write to `logs/app.log`. Tests reside under `tests/` using the `test_*.py` naming pattern.

## Build, Test, and Development Commands
Create and activate a virtual environment, then install dependencies with `pip install -r requirements.txt`. Run the CLI locally via `python -m src.cli hello --name Ada` to confirm wiring. `make test` (or `python -m unittest discover -s tests`) runs the full suite, while `python -m unittest tests.test_task_manager` targets the task manager module. `make lint` executes `ruff check .` with a `pyflakes .` fallback, and `make check` chains lint plus tests to mirror CI.

## Coding Style & Naming Conventions
Target Python 3.10+, use 4-space indents, and add type hints to public functions. Keep docstrings short, imperative, and consistent with the tone already used in `core/` and `utils/`. Follow `snake_case` for files, modules, CLI subcommands, and plugin names (`hello_plugin`). Whenever output is user-visible, call both `print()` and `utils.helper.log()` so stdout and logs remain synchronized.

## Testing Guidelines
All tests rely on `unittest` and should live in `tests/test_*.py`. Mirror `tests/test_cli_functions.py` by mocking `utils.helper.log` and using `types.SimpleNamespace` for lightweight fixtures. For plugin flows, adapt the temporary-file approach in `tests/test_plugin_loading.py`. Cover every new CLI path, including failure modes (e.g., unknown plugin names), before running `python -m unittest discover -s tests` or `make test` to verify the full suite.

## Commit & Pull Request Guidelines
Commits follow emoji-flavored Conventional Commits such as `:sparkles: feat: add new plugin hook` or `fix: correct log format`, with subjects under ~72 characters. Pull requests should summarize motivation, list verification commands (`make lint`, `make test`), link any tickets, and include screenshots or CLI transcripts when behavior changes. Explicitly flag anything that impacts security, plugin loading, or filesystem writes.

## Security & Configuration Tips
Plugins load dynamically via `importlib.util`, so review contributions carefully and never run unvetted code. Keep secrets out of `logs/app.log`, and rotate or truncate the file if large runs are expected. Prefer `.env` files or runtime arguments for environment-specific settings rather than editing `core/config.py`, and avoid committing environment secrets.
