from typing import List

class TaskManager:
    """
    Simple in-memory job queue.
    """

    def __init__(self) -> None:
        """
        Initialisiert die interne Aufgabenliste.
        """
        self._tasks: List[str] = []

    def add_task(self, task: str) -> None:
        """
        Fügt eine Aufgabe zur Warteschlange hinzu.

        Args:
            task (str): Beschreibung der Aufgabe.

        Raises:
            TypeError: Wenn task kein String ist.
            ValueError: Wenn die Aufgabe bereits existiert.
        """
        if not isinstance(task, str):
            raise TypeError("Task must be a string.")
        if task in self._tasks:
            raise ValueError("Task already exists.")
        self._tasks.append(task)

    def list_tasks(self) -> List[str]:
        """
        Gibt die aktuelle Aufgabenliste zurück.

        Returns:
            List[str]: Alle Aufgaben in der Reihenfolge ihrer Einfügung.
        """
        return list(self._tasks)

    def clear_tasks(self) -> None:
        """
        Löscht alle Aufgaben aus der Warteschlange.
        """
        self._tasks.clear()
