import argparse
import importlib.util
import os
import sys

# Ensure root package is importable
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from core.cli import hello, sum_cmd, info

def load_plugin(name):
    """Lädt ein Plugin aus dem plugins/ Verzeichnis."""
    plugin_dir = os.path.join(os.path.dirname(__file__), '..', 'plugins')
    plugin_file = os.path.join(plugin_dir, f'{name}.py')
    if not os.path.isfile(plugin_file):
        raise FileNotFoundError(f"Plugin '{name}' nicht gefunden.")
    spec = importlib.util.spec_from_file_location(name, plugin_file)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module

def run_plugin(args):
    try:
        module = load_plugin(args.name)
        if hasattr(module, 'execute'):
            module.execute()
        else:
            print(f"Plugin '{args.name}' hat keine execute() Funktion.")
    except Exception as e:
        print(f"Fehler beim Ausführen des Plugins '{args.name}': {e}")

def main():
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
    args.func(args)

if __name__ == "__main__":
    main()
