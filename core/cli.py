from utils.helper import log

def hello(args):
    """Gibt einen Begrüßungstext aus."""
    name = args.name if args.name else "World"
    if not isinstance(name, str) or not name.strip():
        raise ValueError("Name muss ein nicht-leerer String sein.")
    message = f"Hello, {name}!"
    log(message)
    print(message)

def sum_cmd(args):
    """Berechnet die Summe der übergebenen Zahlen."""
    if not args.numbers:
        raise ValueError("Mindestens eine Zahl muss übergeben werden.")
    total = sum(args.numbers)
    message = f"Sum: {total}"
    log(message)
    print(message)

def info(args):
    """Gibt allgemeine Informationen aus."""
    message = "This is a minimal CLI application."
    log(message)
    print(message)
