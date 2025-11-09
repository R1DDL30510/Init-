#!/bin/bash
make test && make lint
if [ $? -ne 0 ]; then
    echo "Commit blocked due to failed tests or linting."
    exit 1
fi
echo "All checks passed. Proceeding with commit."
