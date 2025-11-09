# Projektbericht

## Struktur
- src/
  - cli.py – Haupt-CLI mit Subkommandos
- core/
  - cli.py – Logik für hello, sum, info
  - task_manager.py – In‑Memory‑Queue
  - config.py – Basis‑ und Log‑Pfad
- utils/
  - helper.py – Logging, JSON‑I/O
- plugins/
  - hello_plugin.py – Beispiel‑Plugin
- tests/
  - test_main.py – Unit‑Tests
- docs/
  - REPORT.md – dieser Bericht
- Makefile, requirements.txt, data/README.md, logs/.gitkeep

## Module & Funktionen
- **core.cli**: `hello`, `sum_cmd`, `info`
- **src.cli**: `load_plugin`, `run_plugin`, `main`
- **plugins.hello_plugin**: `execute`
- **utils.helper**: `log`, `read_json`, `write_json`
- **core.task_manager**: `add_task`, `list_tasks`, `clear_tasks`

## Funktionsprüfung
| Befehl | Erwartete Ausgabe | Status |
|--------|-------------------|--------|
| `hello` | „Hello, World!“ | ✅ |
| `hello --name Alice` | „Hello, Alice!“ | ✅ |
| `sum 1 2 3` | „Sum: 6“ | ✅ |
| `info` | „This is a minimal CLI application.“ | ✅ |
| `plugin hello_plugin` | „Hallo aus dem Plugin!“ | ✅ |

## Probleme & Empfehlungen
- Viele Funktionen fehlen ausführliche Docstrings.
- Fehlerbehandlung in `load_plugin` ist minimal; ein fehlendes Plugin führt zu `FileNotFoundError`.
- `utils.helper.log` schreibt immer in die Logdatei; für Tests könnte ein Mock sinnvoll sein.
- Redundante `sys.path.append`‑Aufrufe in mehreren Modulen.
- `requirements.txt` listet `click` und `rich`, werden aber nicht genutzt.

## Testzusammenfassung
- 4 Unit‑Tests ausgeführt.
- 4/4 Tests bestanden.
- Keine Fehler oder Warnungen.
