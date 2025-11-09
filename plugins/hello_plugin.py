def execute():
    """Beispielplugin, das eine Nachricht loggt und ausgibt."""
    from utils.helper import log
    message = "Hallo aus dem Plugin!"
    log(message)
    print(message)
