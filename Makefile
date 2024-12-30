.ONESHELL:

# Màu sắc cho output
GREEN = \033[0;32m
YELLOW = \033[1;33m
RED = \033[0;31m
NC = \033[0m # No Color

# Target mặc định
.DEFAULT_GOAL := help

# Alias
PROJECT_NAME := django-package
PYTHON_VERSION ?= 3.12.8


# Hiển thị help
.PHONY: help
help:
	@echo "Usage:"
	@echo "  ${GREEN}make${NC}               - Show this help"
	@echo "  ${GREEN}make ${YELLOW}clean${NC}         - Clean up compiled files"
	@echo "  ${GREEN}make ${YELLOW}dev-init${NC}      - Create/activate virtualenv"


# Clean python
.PHONY: clean
clean:
	@find . -type d -name "__pycache__" -exec rm -rf {} +
	@find . -type f -name "*.pyc" -delete
	@find . -type f -name "*.pyo" -delete
	@find . -type f -name "*.pyd" -delete
	@find . -type f -name ".coverage" -delete
	@find . -type d -name "*.egg-info" -exec rm -rf {} +
	@find . -type d -name "*.egg" -exec rm -rf {} +
	@find . -type d -name ".pytest_cache" -exec rm -rf {} +
	@find . -type d -name ".ruff_cache" -exec rm -rf {} +
	@find . -type d -name ".coverage" -exec rm -rf {} +
	@rm -rf build/
	@rm -rf dist/
	@rm -rf .tox/
	@rm -rf htmlcov/


# dev-init
.PHONY: dev-init
dev-init:
	@pyenv install --skip-existing ${PYTHON_VERSION}
	@pyenv virtualenv --force ${PYTHON_VERSION} ${PROJECT_NAME}
	@pyenv local ${PYTHON_VERSION}/envs/${PROJECT_NAME}

# dev-pip
.PHONY: dev-pip
dev-pip:
	@pip install --upgrade pip
	@pip install --upgrade pip-tools

# dev-sync
.PHONY: dev-sync
dev-sync: dev-pip
	@pip-sync
	@pre-commit install

# dev-compile
.PHONY: dev-compile
dev-compile: dev-pip
	@pip-compile --generate-hashes
	@pip-sync

# dev
.PHONY: dev
dev: dev-init dev-sync
	@echo "Done!"

# Next
