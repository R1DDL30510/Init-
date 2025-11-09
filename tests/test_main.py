import unittest
import subprocess
import sys
import os

class TestCLI(unittest.TestCase):
    def run_cli(self, args):
        cmd = [sys.executable, os.path.join('src', 'main.py')] + args
        result = subprocess.run(cmd, capture_output=True, text=True)
        return result.stdout.strip(), result.stderr.strip(), result.returncode

    def test_hello_default(self):
        out, err, code = self.run_cli(['hello'])
        self.assertEqual(code, 0)
        self.assertIn('Hello, World!', out)

    def test_hello_name(self):
        out, err, code = self.run_cli(['hello', '--name', 'Alice'])
        self.assertEqual(code, 0)
        self.assertIn('Hello, Alice!', out)

    def test_sum(self):
        out, err, code = self.run_cli(['sum', '1', '2', '3'])
        self.assertEqual(code, 0)
        self.assertIn('Sum: 6', out)

    def test_info(self):
        out, err, code = self.run_cli(['info'])
        self.assertEqual(code, 0)
        self.assertIn('This is a minimal CLI application.', out)

if __name__ == '__main__':
    unittest.main()
