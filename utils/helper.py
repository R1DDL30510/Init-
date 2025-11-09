import json
import logging
import sys

logging.basicConfig(stream=sys.stdout, level=logging.INFO, format='%(message)s')

def log(message):
    logging.info(message)

def read_json(path):
    with open(path, 'r', encoding='utf-8') as f:
        return json.load(f)

def write_json(path, data):
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2)
