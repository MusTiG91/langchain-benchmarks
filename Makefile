.PHONY: all lint format test help

# Default target executed when no arguments are given to make.
all: help

######################
# TESTING AND COVERAGE
######################

# Define a variable for the test file path.
TEST_FILE ?= tests/unit_tests/

test:
	poetry run pytest --disable-socket --allow-unix-socket $(TEST_FILE)

test_watch:
	poetry run ptw . -- $(TEST_FILE)

build_docs:
	# Copy README.md to docs/index.md
	cp README.md ./docs/source/index.md
	# Append to the table of contents the contents of the file
	cat ./docs/source/toc.segment >> ./docs/source/index.md
	poetry run sphinx-build "./docs/source" "./docs/build"

clean_docs:
	rm -rf ./docs/build

######################
# LINTING AND FORMATTING
######################

# Define a variable for Python and notebook files.
lint format: PYTHON_FILES=.
lint_diff format_diff: PYTHON_FILES=$(shell git diff --relative=. --name-only --diff-filter=d master | grep -E '\.py$$|\.ipynb$$')

lint lint_diff:
	[ "$(PYTHON_FILES)" = "" ] ||	poetry run ruff format $(PYTHON_FILES) --diff
	# [ "$(PYTHON_FILES)" = "" ] || poetry run mypy $(PYTHON_FILES)

format format_diff:
	[ "$(PYTHON_FILES)" = "" ] || poetry run ruff format $(PYTHON_FILES)
	[ "$(PYTHON_FILES)" = "" ] || poetry run ruff --select I --fix $(PYTHON_FILES)

spell_check:
	poetry run codespell --toml pyproject.toml

spell_fix:
	poetry run codespell --toml pyproject.toml -w

######################
# HELP
######################

help:
	@echo '===================='
	@echo '-- LINTING --'
	@echo 'format                       - run code formatters'
	@echo 'lint                         - run linters'
	@echo 'spell_check                 	- run codespell on the project'
	@echo 'spell_fix                		- run codespell on the project and fix the errors'
	@echo '-- TESTS --'
	@echo 'coverage                     - run unit tests and generate coverage report'
	@echo 'test                         - run unit tests'
	@echo 'test TEST_FILE=<test_file>   - run all tests in file'
	@echo '-- DOCUMENTATION tasks are from the top-level Makefile --'
