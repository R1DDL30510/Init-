import unittest
from core.task_manager import TaskManager

class TestTaskManager(unittest.TestCase):
    def setUp(self):
        self.tm = TaskManager()

    def test_add_and_list(self):
        self.tm.add_task('task1')
        self.tm.add_task('task2')
        tasks = self.tm.list_tasks()
        self.assertEqual(tasks, ['task1', 'task2'])

    def test_clear(self):
        self.tm.add_task('task1')
        self.tm.clear_tasks()
        self.assertEqual(self.tm.list_tasks(), [])

    def test_add_none(self):
        with self.assertRaises(TypeError):
            self.tm.add_task(None)

if __name__ == '__main__':
    unittest.main()
