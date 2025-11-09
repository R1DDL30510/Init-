import json
import logging
import sys
import os

from core.config import LOG_FILE

# Configure logging to write to the log file
logging.basicConfig(
    filename=LOG_FILE,
    level=logging.INFO,
    format='%(message)s',
    filemode='a'
)

def log(message):
    logging.info(message)

def read_json(path):
    with open(path, 'r', encoding='utf-8') as f:
        return json.load(f)

def write_json(path, data):
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2)
