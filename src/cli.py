import argparse
import importlib.util
import os
import sys
from types import ModuleType
from typing import Any

# Ensure root package is importable
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from core.cli import hello, sum_cmd, info
from utils.helper import log

def load_plugin(name: str) -> ModuleType:
    """
    Lädt ein Plugin aus dem plugins/ Verzeichnis.

    Args:
        name (str): Name des Plugins ohne Dateiendung.

    Returns:
        ModuleType: Das geladene Plugin-Modul.

    Raises:
        ValueError: Wenn der Name leer oder kein String ist.
        FileNotFoundError: Wenn die Plugin-Datei nicht existiert.
        RuntimeError: Bei Fehlern beim Ausführen des Moduls.
    """
    if not name or not isinstance(name, str) or not name.strip():
        raise ValueError("Plugin-Name darf nicht leer sein.")
    plugin_dir = os.path.join(os.path.dirname(__file__), '..', 'plugins')
    if not os.path.isdir(plugin_dir):
        raise FileNotFoundError(f"Plugin-Verzeichnis '{plugin_dir}' nicht gefunden.")
    plugin_file = os.path.join(plugin_dir, f'{name}.py')
    if not os.path.isfile(plugin_file):
        raise FileNotFoundError(f"Plugin '{name}' nicht gefunden.")
    spec = importlib.util.spec_from_file_location(name, plugin_file)
    module = importlib.util.module_from_spec(spec)
    try:
        spec.loader.exec_module(module)  # type: ignore
    except Exception as e:
        raise RuntimeError(f"Fehler beim Laden des Plugins '{name}': {e}") from e
    return module

def run_plugin(args: argparse.Namespace) -> None:
    """
    Führt ein Plugin aus, das über die CLI aufgerufen wurde.

    Args:
        args (argparse.Namespace): Enthält das Plugin-Argument 'name'.

    Side Effects:
        Loggt Fehler und gibt sie auf stdout aus.
    """
    try:
        module = load_plugin(args.name)
        if hasattr(module, 'execute'):
            module.execute()
        else:
            raise AttributeError(f"Plugin '{args.name}' hat keine execute() Funktion.")
    except Exception as e:
        error_msg = f"Plugin '{args.name}' konnte nicht ausgeführt werden: {e}"
        log(error_msg)
        print(error_msg)

def main() -> None:
    """
    Hauptfunktion der CLI. Verarbeitet Subkommandos und ruft die jeweiligen
    Funktionen auf. Bei unerwarteten Fehlern wird ein Log-Eintrag erstellt
    und der Prozess mit Exit-Code 1 beendet.
    """
    parser = argparse.ArgumentParser(description="Minimal CLI")
    subparsers = parser.add_subparsers(dest='command', required=True)

    # hello command
    parser_hello = subparsers.add_parser('hello', help='Say hello')
    parser_hello.add_argument('-n', '--name', help='Name to greet')
    parser_hello.set_defaults(func=hello)

    # sum command
    parser_sum = subparsers.add_parser('sum', help='Sum numbers')
    parser_sum.add_argument('numbers', nargs='+', type=int, help='Numbers to sum')
    parser_sum.set_defaults(func=sum_cmd)

    # info command
    parser_info = subparsers.add_parser('info', help='Show info')
    parser_info.set_defaults(func=info)

    # plugin command
    parser_plugin = subparsers.add_parser('plugin', help='Execute a plugin')
    parser_plugin.add_argument('name', help='Plugin name')
    parser_plugin.set_defaults(func=run_plugin)

    args = parser.parse_args()
    try:
        args.func(args)
    except Exception as e:
        error_msg = f"Unbehandelter Fehler: {e}"
        log(error_msg)
        print(error_msg)
        sys.exit(1)

if __name__ == "__main__":
    main()
