class TaskManager:
    """
    Simple in-memory job queue.
    """
    def __init__(self):
        self._tasks = []

    def add_task(self, task):
        """
        Add a task to the queue.
        """
        self._tasks.append(task)

    def list_tasks(self):
        """
        Return a list of all tasks.
        """
        return list(self._tasks)

    def clear_tasks(self):
        """
        Remove all tasks from the queue.
        """
        self._tasks.clear()
