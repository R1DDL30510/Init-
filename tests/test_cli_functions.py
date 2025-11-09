import unittest
from types import SimpleNamespace
from unittest.mock import patch
import io
import contextlib

from src.cli import hello, sum_cmd, info
from core.cli import hello as core_hello, sum_cmd as core_sum_cmd, info as core_info

class TestCLIFunctions(unittest.TestCase):
    def setUp(self):
        self.log_calls = []

    def mock_log(self, message):
        self.log_calls.append(message)

    def capture_output(self, func, *args, **kwargs):
        captured = io.StringIO()
        with contextlib.redirect_stdout(captured):
            func(*args, **kwargs)
        return captured.getvalue().strip()

    @patch('utils.helper.log')
    def test_hello_default(self, mock_log):
        args = SimpleNamespace(name=None)
        output = self.capture_output(hello, args)
        self.assertIn('Hello, World!', output)
        mock_log.assert_called_with('Hello, World!')

    @patch('utils.helper.log')
    def test_hello_name(self, mock_log):
        args = SimpleNamespace(name='Alice')
        output = self.capture_output(hello, args)
        self.assertIn('Hello, Alice!', output)
        mock_log.assert_called_with('Hello, Alice!')

    @patch('utils.helper.log')
    def test_sum(self, mock_log):
        args = SimpleNamespace(numbers=[1, 2, 3])
        output = self.capture_output(sum_cmd, args)
        self.assertIn('Sum: 6', output)
        mock_log.assert_called_with('Sum: 6')

    @patch('utils.helper.log')
    def test_info(self, mock_log):
        args = SimpleNamespace()
        output = self.capture_output(info, args)
        self.assertIn('This is a minimal CLI application.', output)
        mock_log.assert_called_with('This is a minimal CLI application.')

    @patch('utils.helper.log')
    def test_core_hello(self, mock_log):
        args = SimpleNamespace(name='Bob')
        output = self.capture_output(core_hello, args)
        self.assertIn('Hello, Bob!', output)
        mock_log.assert_called_with('Hello, Bob!')

    @patch('utils.helper.log')
    def test_core_sum(self, mock_log):
        args = SimpleNamespace(numbers=[4, 5])
        output = self.capture_output(core_sum_cmd, args)
        self.assertIn('Sum: 9', output)
        mock_log.assert_called_with('Sum: 9')

    @patch('utils.helper.log')
    def test_core_info(self, mock_log):
        args = SimpleNamespace()
        output = self.capture_output(core_info, args)
        self.assertIn('This is a minimal CLI application.', output)
        mock_log.assert_called_with('This is a minimal CLI application.')

    def test_hello_invalid_name(self):
        args = SimpleNamespace(name='')
        with self.assertRaises(ValueError):
            hello(args)

    def test_sum_no_numbers(self):
        args = SimpleNamespace(numbers=[])
        with self.assertRaises(ValueError):
            sum_cmd(args)

if __name__ == '__main__':
    unittest.main()
