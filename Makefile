.ONESHELL:

# Colors for output
GREEN = \033[0;32m
YELLOW = \033[1;33m
RED = \033[0;31m

SUCCESS = \033[0;32m [SUCCESS]:
WARNING = \033[1;33m [WARNING]:
ERROR = \033[0;31m [ERROR]:
INFO = \033[1;37m [INFO]:
HINT = \033[3;37m

NC = \033[0m # No Color

# Default target
.DEFAULT_GOAL := init

# Alias
PROJECT_NAME := django-package-cookiecutter
PYTHON_VERSION ?= 3.12.8

# init
.PHONY: init
init:
	@pyenv install --skip-existing ${PYTHON_VERSION}
	@pyenv virtualenv --force ${PYTHON_VERSION} ${PROJECT_NAME}
	@pyenv local ${PYTHON_VERSION}/envs/${PROJECT_NAME}
	@pip install cookiecutter
	@npm install -g @anthropic-ai/claude-code


