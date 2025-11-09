import json
import logging
import os
from typing import Any

from core.config import LOG_FILE

# Configure logging to write to the log file only once
if not logging.getLogger().hasHandlers():
    logging.basicConfig(
        filename=LOG_FILE,
        level=logging.INFO,
        format='%(asctime)s %(levelname)s: %(message)s',
        filemode='a'
    )

def log(message: str) -> None:
    """
    Schreibt eine Nachricht in die Logdatei.

    Args:
        message (str): Text, der geloggt werden soll.

    Side Effects:
        Schreibt in LOG_FILE. Bei Fehlern wird eine Warnung auf stdout ausgegeben.
    """
    try:
        logging.info(message)
    except Exception as e:
        # Falls Logging fehlschlägt, geben wir eine Warnung aus
        print(f"Logging error: {e}")

def read_json(path: str) -> Any:
    """
    Liest JSON aus einer Datei und gibt ein Python-Objekt zurück.

    Args:
        path (str): Pfad zur JSON-Datei.

    Returns:
        Any: Das geladene Python-Objekt.

    Raises:
        FileNotFoundError: Wenn die Datei nicht existiert.
        ValueError: Wenn der Inhalt kein gültiges JSON ist.
        RuntimeError: Bei anderen Lese-Fehlern.
    """
    if not os.path.isfile(path):
        raise FileNotFoundError(f"JSON-Datei nicht gefunden: {path}")
    try:
        with open(path, 'r', encoding='utf-8') as f:
            return json.load(f)
    except json.JSONDecodeError as e:
        raise ValueError(f"Ungültiges JSON in {path}: {e}") from e
    except Exception as e:
        raise RuntimeError(f"Fehler beim Lesen von {path}: {e}") from e

def write_json(path: str, data: Any) -> None:
    """
    Schreibt ein Python-Objekt als JSON in eine Datei.

    Args:
        path (str): Zielpfad.
        data (Any): Daten, die serialisiert werden sollen.

    Raises:
        RuntimeError: Bei Schreibfehlern.
    """
    try:
        with open(path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2)
    except Exception as e:
        raise RuntimeError(f"Fehler beim Schreiben von {path}: {e}") from e
