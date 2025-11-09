import unittest
import os
import sys
import io
import contextlib
from types import SimpleNamespace
from unittest.mock import patch

from src.cli import load_plugin, run_plugin

class TestPluginLoading(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        # Create a temporary plugin without execute function
        cls.tmp_plugin_path = os.path.join(os.path.dirname(__file__), '..', 'plugins', 'tmp_plugin.py')
        with open(cls.tmp_plugin_path, 'w', encoding='utf-8') as f:
            f.write('# Plugin ohne execute\n')

    @classmethod
    def tearDownClass(cls):
        os.remove(cls.tmp_plugin_path)

    def test_load_existing_plugin(self):
        module = load_plugin('hello_plugin')
        self.assertTrue(hasattr(module, 'execute'))

    def test_load_missing_plugin(self):
        with self.assertRaises(FileNotFoundError):
            load_plugin('nonexistent_plugin')

    @patch('utils.helper.log')
    def test_run_plugin_with_execute(self, mock_log):
        captured = io.StringIO()
        with contextlib.redirect_stdout(captured):
            run_plugin(SimpleNamespace(name='hello_plugin'))
        output = captured.getvalue().strip()
        self.assertIn('Hallo aus dem Plugin!', output)
        mock_log.assert_called_with('Hallo aus dem Plugin!')

    @patch('utils.helper.log')
    def test_run_plugin_without_execute(self, mock_log):
        captured = io.StringIO()
        with contextlib.redirect_stdout(captured):
            run_plugin(SimpleNamespace(name='tmp_plugin'))
        output = captured.getvalue().strip()
        expected_error = "Fehler beim Ausführen des Plugins 'tmp_plugin': Plugin 'tmp_plugin' hat keine execute() Funktion."
        self.assertIn(expected_error, output)
        mock_log.assert_called_with(expected_error)

if __name__ == '__main__':
    unittest.main()
