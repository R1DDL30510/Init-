from utils.helper import log

def hello(args):
    name = args.name if args.name else "World"
    log(f"Hello, {name}!")

def sum_cmd(args):
    total = sum(args.numbers)
    log(f"Sum: {total}")

def info(args):
    log("This is a minimal CLI application.")
