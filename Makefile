.PHONY: run test clean lint

run:
	python -m src.cli

test:
	python -m unittest discover -s tests

clean:
	rm -rf logs/*.log
	rm -rf __pycache__ src/__pycache__ core/__pycache__ tests/__pycache__

lint:
	@echo "Lint placeholder – no linting performed."
	@exit 0
