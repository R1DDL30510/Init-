import argparse
import os
import sys

# Ensure utils package is importable
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from utils.helper import log

def hello(args):
    name = args.name if args.name else "World"
    log(f"Hello, {name}!")

def sum_cmd(args):
    total = sum(args.numbers)
    log(f"Sum: {total}")

def info(args):
    log("This is a minimal CLI application.")

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

    args = parser.parse_args()
    args.func(args)

if __name__ == "__main__":
    main()
