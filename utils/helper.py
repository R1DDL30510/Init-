import json
import logging
import os

from core.config import LOG_FILE

# Configure logging to write to the log file
logging.basicConfig(
    filename=LOG_FILE,
    level=logging.INFO,
    format='%(asctime)s %(levelname)s: %(message)s',
    filemode='a'
)

def log(message):
    """Schreibt eine Nachricht in die Logdatei."""
    try:
        logging.info(message)
    except Exception as e:
        # Falls Logging fehlschlägt, geben wir eine Warnung aus
        print(f"Logging error: {e}")

def read_json(path):
    """Liest JSON aus einer Datei und gibt ein Python-Objekt zurück."""
    if not os.path.isfile(path):
        raise FileNotFoundError(f"JSON-Datei nicht gefunden: {path}")
    try:
        with open(path, 'r', encoding='utf-8') as f:
            return json.load(f)
    except json.JSONDecodeError as e:
        raise ValueError(f"Ungültiges JSON in {path}: {e}") from e
    except Exception as e:
        raise RuntimeError(f"Fehler beim Lesen von {path}: {e}") from e

def write_json(path, data):
    """Schreibt ein Python-Objekt als JSON in eine Datei."""
    try:
        with open(path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2)
    except Exception as e:
        raise RuntimeError(f"Fehler beim Schreiben von {path}: {e}") from e
