#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

clear

# Header
echo -e "${PURPLE}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║${NC}              ${WHITE}🚀 {{ cookiecutter.project_slug|upper }} DEVELOPMENT ENVIRONMENT${NC}              ${PURPLE}║${NC}"
echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo

# System Info
echo -e "${CYAN}📋 System Information:${NC}"
echo -e "   ${GRAY}•${NC} OS: $(lsb_release -ds 2>/dev/null || cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo -e "   ${GRAY}•${NC} Kernel: $(uname -r)"
echo -e "   ${GRAY}•${NC} Architecture: $(uname -m)"
echo

# Development Tools
echo -e "${CYAN}🛠️  Development Tools:${NC}"

# Git
if command -v git &> /dev/null; then
    echo -e "   ${GREEN}✓${NC} Git $(git --version | awk '{print $3}')"
fi

# Python
if command -v python3 &> /dev/null; then
    echo -e "   ${GREEN}✓${NC} Python $(python3 --version | awk '{print $2}')"
fi

# Pyenv
if command -v pyenv &> /dev/null; then
    echo -e "   ${GREEN}✓${NC} Pyenv $(pyenv --version | awk '{print $2}')"
fi

# Node.js
if command -v node &> /dev/null; then
    echo -e "   ${GREEN}✓${NC} Node.js $(node --version)"
fi

# NPM
if command -v npm &> /dev/null; then
    echo -e "   ${GREEN}✓${NC} NPM $(npm --version)"
fi

# Docker
if command -v docker &> /dev/null; then
    echo -e "   ${GREEN}✓${NC} Docker $(docker --version | awk '{print $3}' | sed 's/,$//')"
fi

# AWS CLI
if command -v aws &> /dev/null; then
    echo -e "   ${GREEN}✓${NC} AWS CLI $(aws --version | awk '{print $1}' | cut -d'/' -f2)"
fi

# Terraform
if command -v terraform &> /dev/null; then
    echo -e "   ${GREEN}✓${NC} Terraform $(terraform version | head -1 | awk '{print $2}')"
fi

# kubectl
if command -v kubectl &> /dev/null; then
    echo -e "   ${GREEN}✓${NC} kubectl $(kubectl version --client --short 2>/dev/null | awk '{print $3}')"
fi

# Helm
if command -v helm &> /dev/null; then
    echo -e "   ${GREEN}✓${NC} Helm $(helm version --short | cut -d':' -f2 | tr -d ' ')"
fi

echo

# Shell Environment
echo -e "${CYAN}🐚 Shell Environment:${NC}"
echo -e "   ${GRAY}•${NC} Shell: $SHELL"
echo -e "   ${GRAY}•${NC} Zsh: $(zsh --version | awk '{print $2}')"
echo -e "   ${GRAY}•${NC} Oh My Zsh: ${GREEN}✓${NC} Installed"
echo -e "   ${GRAY}•${NC} Theme: Powerlevel10k"
echo

# Project Info
echo -e "${CYAN}📁 Project Information:${NC}"
echo -e "   ${GRAY}•${NC} Project: {{ cookiecutter.project_name }}"
echo -e "   ${GRAY}•${NC} Slug: {{ cookiecutter.project_slug }}"
echo -e "   ${GRAY}•${NC} App: {{ cookiecutter.app_slug }}"
if [ -n "$GITHUB_USERNAME" ]; then
    echo -e "   ${GRAY}•${NC} GitHub: @$GITHUB_USERNAME"
fi
echo

# Quick Commands
echo -e "${CYAN}⚡ Quick Commands:${NC}"
echo -e "   ${GRAY}•${NC} ${YELLOW}alias${NC} - List all available shortcuts"
echo -e "   ${GRAY}•${NC} ${YELLOW}verify-setup${NC} - Verify devcontainer setup"
echo -e "   ${GRAY}•${NC} ${YELLOW}python manage.py${NC} - Django management commands"
echo -e "   ${GRAY}•${NC} ${YELLOW}make${NC} - View available make targets"
echo

{% if cookiecutter.devcontainer_ssh_port != "0" %}
# SSH Info
echo -e "${CYAN}🔐 SSH Access:${NC}"
echo -e "   ${GRAY}•${NC} Port: 22 (mapped to host port {{ cookiecutter.devcontainer_ssh_port }})"
echo -e "   ${GRAY}•${NC} Username: vscode"
echo -e "   ${GRAY}•${NC} Password: vscode"
echo -e "   ${GRAY}•${NC} Connect: ${YELLOW}ssh -p {{ cookiecutter.devcontainer_ssh_port }} vscode@localhost${NC}"
echo
{% endif %}

echo -e "${PURPLE}────────────────────────────────────────────────────────────────────────────────${NC}"
echo -e "${WHITE}Happy coding! 🎉${NC}"
echo

# Create alias for verify-setup if it doesn't exist
if ! command -v verify-setup &> /dev/null; then
    alias verify-setup='/bin/bash .devcontainer/scripts/verify-setup.sh'
fi