from typing import Any
from utils.helper import log

def hello(args: Any) -> None:
    """
    Gibt einen Begrüßungstext aus.

    Args:
        args (argparse.Namespace): Enthält das Argument 'name'.

    Raises:
        ValueError: Wenn der Name leer oder kein String ist.
    """
    name = args.name if args.name else "World"
    if not isinstance(name, str) or not name.strip():
        raise ValueError("Name muss ein nicht-leerer String sein.")
    message = f"Hello, {name}!"
    log(message)
    print(message)

def sum_cmd(args: Any) -> None:
    """
    Berechnet die Summe der übergebenen Zahlen.

    Args:
        args (argparse.Namespace): Enthält die Liste 'numbers'.

    Raises:
        ValueError: Wenn keine Zahlen übergeben wurden.
    """
    if not args.numbers:
        raise ValueError("Mindestens eine Zahl muss übergeben werden.")
    total = sum(args.numbers)
    message = f"Sum: {total}"
    log(message)
    print(message)

def info(args: Any) -> None:
    """
    Gibt allgemeine Informationen aus.

    Args:
        args (argparse.Namespace): Unverwendet.
    """
    message = "This is a minimal CLI application."
    log(message)
    print(message)
