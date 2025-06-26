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
.DEFAULT_GOAL := help

# Alias
PROJECT_NAME := {{cookiecutter.project_slug}}
PYTHON_VERSION ?= 3.12.8


# Display help
.PHONY: help
help:
	@echo "============================================================================"
	@echo "                         ${GREEN}$(PROJECT_NAME) Makefile${NC}"
	@echo "============================================================================"
	@echo ""
	@echo "${YELLOW}Development Setup:${NC}"
	@echo "  ${GREEN}make ${YELLOW}dev${NC}           - Complete development setup (init + sync)"
	@echo "  ${GREEN}make ${YELLOW}dev-init${NC}      - Create/activate virtualenv"
	@echo "  ${GREEN}make ${YELLOW}dev-sync${NC}      - Install dependencies and sync"
	@echo "  ${GREEN}make ${YELLOW}dev-compile${NC}   - Compile and sync requirements"
	@echo ""
	@echo "${YELLOW}Django Commands:${NC}"
	@echo "  ${GREEN}make ${YELLOW}runserver${NC}     - Run Django development server"
	@echo "  ${GREEN}make ${YELLOW}shell_plus${NC}    - Django shell with auto-imports"
	@echo "  ${GREEN}make ${YELLOW}migrate${NC}       - Run Django migrations"
	@echo "  ${GREEN}make ${YELLOW}makemigrations${NC}- Create new migrations"
	@echo "  ${GREEN}make ${YELLOW}collectstatic${NC} - Collect static files"
	@echo "  ${GREEN}make ${YELLOW}createsuperuser${NC}- Create Django superuser"
	@echo ""
	@echo "${YELLOW}Testing:${NC}"
	@echo "  ${GREEN}make ${YELLOW}test${NC}          - Run unit tests with coverage"
	@echo "  ${GREEN}make ${YELLOW}test-fast${NC}     - Run tests without coverage"{% if cookiecutter.use_cypress == 'y' %}
	@echo "  ${GREEN}make ${YELLOW}e2e-install${NC}   - Install E2E test dependencies"
	@echo "  ${GREEN}make ${YELLOW}e2e-open${NC}      - Open Cypress interactive mode"
	@echo "  ${GREEN}make ${YELLOW}e2e-run${NC}       - Run E2E tests headlessly"
	@echo "  ${GREEN}make ${YELLOW}e2e-test${NC}      - Run server and E2E tests together"{% endif %}
	@echo ""
	@echo "${YELLOW}Code Quality:${NC}"
	@echo "  ${GREEN}make ${YELLOW}lint${NC}          - Run all linters"
	@echo "  ${GREEN}make ${YELLOW}format${NC}        - Format code with black"
	@echo "  ${GREEN}make ${YELLOW}typecheck${NC}     - Run type checking with mypy"
	@echo ""
	@echo "${YELLOW}Utilities:${NC}"
	@echo "  ${GREEN}make ${YELLOW}clean${NC}         - Clean up compiled files"
	@echo "  ${GREEN}make ${YELLOW}clean-all${NC}     - Clean everything including node_modules"


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
	@echo "${INFO} Cleaned up compiled files${NC}"

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
	@pip install -r requirements.txt
	@pip-sync
	@pre-commit install

# dev-compile
.PHONY: dev-compile
dev-compile: dev-pip
	@pip-compile
	@pip-sync

# dev
.PHONY: dev
dev: dev-init dev-sync
	@echo "Done!"

# test
.PHONY: test
test:
	@coverage run -m pytest --create-db -v && coverage report -m
	@echo "Done!"

# shell_plus
.PHONY: shell_plus
shell_plus:
	@python manage.py shell_plus

# runserver
.PHONY: runserver
runserver:
	@python manage.py runserver_plus

# Django Commands
.PHONY: migrate
migrate:
	@echo "${INFO} Running migrations...${NC}"
	@python manage.py migrate

.PHONY: makemigrations
makemigrations:
	@echo "${INFO} Creating migrations...${NC}"
	@python manage.py makemigrations

.PHONY: collectstatic
collectstatic:
	@echo "${INFO} Collecting static files...${NC}"
	@python manage.py collectstatic --noinput

.PHONY: createsuperuser
createsuperuser:
	@echo "${INFO} Creating superuser...${NC}"
	@python manage.py createsuperuser

# Test variations
.PHONY: test-fast
test-fast:
	@pytest --create-db -v
	@echo "Done!"

# Code Quality
.PHONY: lint
lint:
	@echo "${INFO} Running linters...${NC}"
	@ruff check .
	@echo "${SUCCESS} Linting complete${NC}"

.PHONY: format
format:
	@echo "${INFO} Formatting code...${NC}"
	@black .
	@ruff check --fix .
	@echo "${SUCCESS} Formatting complete${NC}"

.PHONY: typecheck
typecheck:
	@echo "${INFO} Running type checks...${NC}"
	@mypy .
	@echo "${SUCCESS} Type checking complete${NC}"

{% if cookiecutter.use_cypress == 'y' %}
# E2E Testing
.PHONY: e2e-install
e2e-install:
	@echo "${INFO} Installing E2E test dependencies...${NC}"
	@cd tests/e2e && npm install && \
	echo "${INFO} Installing Cypress binary...${NC}" && \
	npx cypress install && \
	echo "${INFO} Verifying Cypress installation...${NC}" && \
	npx cypress verify && \
	echo "${SUCCESS} E2E dependencies and Cypress binary installed${NC}"

.PHONY: e2e-open
e2e-open:
	@echo "${INFO} Opening Cypress...${NC}"
	@cd tests/e2e && npm run cy:open

.PHONY: e2e-run
e2e-run:
	@echo "${INFO} Running E2E tests...${NC}"
	@cd tests/e2e && npm run cy:run

.PHONY: e2e-test
e2e-test:
	@echo "${INFO} Starting Django server and running E2E tests...${NC}"
	@python manage.py runserver --noreload & \
	SERVER_PID=$$!; \
	sleep 3; \
	cd tests/e2e && npm run cy:run; \
	TEST_EXIT_CODE=$$?; \
	kill $$SERVER_PID; \
	exit $$TEST_EXIT_CODE
{% endif %}

# Clean all (including node_modules)
.PHONY: clean-all
clean-all: clean
{% if cookiecutter.use_cypress == 'y' %}
	@rm -rf tests/e2e/node_modules
	@rm -rf tests/e2e/screenshots
	@rm -rf tests/e2e/videos
	@rm -rf tests/e2e/downloads
	@echo "${INFO} Cleaned E2E test artifacts${NC}"
{% endif %}
	@echo "${SUCCESS} All cleaned${NC}"

# Next
