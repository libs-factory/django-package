#!/bin/bash

# Verification script for devcontainer setup
# This script checks if all installed tools and configurations are working properly

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

# Counters
PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

# Helper functions
check_pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASS_COUNT++))
}

check_fail() {
    echo -e "${RED}✗${NC} $1"
    ((FAIL_COUNT++))
}

check_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARN_COUNT++))
}

check_command() {
    local cmd=$1
    local name=${2:-$1}
    if command -v "$cmd" &> /dev/null; then
        # Use timeout to prevent hanging on version checks
        local version=$(timeout 2s $cmd --version 2>&1 | head -n1 || echo "version unknown")
        check_pass "$name is installed: $version"
        return 0
    else
        check_fail "$name is not installed"
        return 1
    fi
}

check_command_simple() {
    local cmd=$1
    local name=${2:-$1}
    if command -v "$cmd" &> /dev/null; then
        check_pass "$name is installed"
        return 0
    else
        check_fail "$name is not installed"
        return 1
    fi
}

check_file() {
    local file=$1
    local desc=$2
    if [ -f "$file" ]; then
        check_pass "$desc exists"
        return 0
    else
        check_fail "$desc not found"
        return 1
    fi
}

check_dir() {
    local dir=$1
    local desc=$2
    if [ -d "$dir" ]; then
        check_pass "$desc exists"
        return 0
    else
        check_fail "$desc not found"
        return 1
    fi
}

echo -e "${PURPLE}========================================${NC}"
echo -e "${PURPLE}    DEVCONTAINER SETUP VERIFICATION${NC}"
echo -e "${PURPLE}========================================${NC}"
echo ""

# ========================================
# SYSTEM INFORMATION
# ========================================
echo -e "${CYAN}=== System Information ===${NC}"
echo "User: $(whoami)"
echo "Home: $HOME"
echo "Shell: $SHELL"
echo "OS: $(lsb_release -d | cut -f2)"
echo "Project: Django Package Cookiecutter"
echo ""

# ========================================
# CORE SYSTEM UTILITIES
# ========================================

# ----------------------------------------
# Basic System Tools
# ----------------------------------------
echo -e "${CYAN}=== Basic System Tools ===${NC}"
check_command curl
check_command wget
check_command sudo
check_command locale "Locale tools"
echo ""

# ----------------------------------------
# Text Editors
# ----------------------------------------
echo -e "${CYAN}=== Text Editors ===${NC}"
check_command vim
check_command nano
echo ""

# ----------------------------------------
# Archive Tools
# ----------------------------------------
echo -e "${CYAN}=== Archive Tools ===${NC}"
check_command_simple unzip
check_command_simple zip
echo ""

# ========================================
# DEVELOPMENT TOOLS
# ========================================

# ----------------------------------------
# Version Control
# ----------------------------------------
echo -e "${CYAN}=== Version Control ===${NC}"
check_command git
echo ""

# ----------------------------------------
# Build Tools
# ----------------------------------------
echo -e "${CYAN}=== Build Tools ===${NC}"
check_command gcc "GCC compiler"
check_command g++ "G++ compiler"
check_command make
check_command cmake
check_command pkg-config
echo ""

# ----------------------------------------
# Code Quality Tools
# ----------------------------------------
echo -e "${CYAN}=== Code Quality Tools ===${NC}"
check_command clang-format "Clang Format"
check_command shellcheck "ShellCheck"
echo ""

# ========================================
# PROGRAMMING ENVIRONMENTS
# ========================================

# ----------------------------------------
# Python Development
# ----------------------------------------
echo -e "${CYAN}=== Python Environment ===${NC}"
check_command python3
check_command pip3 "pip"

# Source pyenv before checking if it exists
if [ -f "$HOME/.pyenv/bin/pyenv" ]; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)" 2>/dev/null || true
fi

check_command pyenv

if command -v pyenv &> /dev/null; then
    echo "Pyenv versions available:"
    pyenv versions 2>/dev/null | sed 's/^/  /'
fi
echo ""

# ----------------------------------------
# Node.js Development
# ----------------------------------------
echo -e "${CYAN}=== Node.js Environment ===${NC}"
check_command node
check_command npm

if [ -d "$NVM_DIR" ]; then
    check_pass "NVM directory exists at $NVM_DIR"
else
    check_warn "NVM directory not found at $NVM_DIR"
fi
echo ""

# ========================================
# SHELL AND TERMINAL TOOLS
# ========================================

# ----------------------------------------
# Shell Environment
# ----------------------------------------
echo -e "${CYAN}=== Shell Environment ===${NC}"
check_command zsh
check_command tmux
echo ""

# ----------------------------------------
# System Monitoring
# ----------------------------------------
echo -e "${CYAN}=== System Monitoring Tools ===${NC}"
check_command htop
check_command tree
echo ""

# ----------------------------------------
# Modern CLI Tools
# ----------------------------------------
echo -e "${CYAN}=== Modern CLI Tools ===${NC}"
check_command jq "jq (JSON processor)"
check_command rg "ripgrep"
check_command fdfind "fd-find" || check_command fd "fd-find"
check_command batcat "bat" || check_command bat
check_command fzf "fzf (fuzzy finder)"
echo ""

# ========================================
# NETWORK AND CONNECTIVITY
# ========================================

# ----------------------------------------
# Network Tools
# ----------------------------------------
echo -e "${CYAN}=== Network Tools ===${NC}"
check_command_simple ping
check_command_simple netstat "netstat" || check_command_simple ss "ss (netstat alternative)"
check_command_simple nslookup
check_command_simple dig
echo ""

# ----------------------------------------
# SSH Configuration
# ----------------------------------------
echo -e "${CYAN}=== SSH Configuration ===${NC}"
check_command ssh "SSH client"
check_command sshd "SSH server"

check_file /etc/ssh/sshd_config "SSH daemon config"
check_dir ~/.ssh "SSH directory"

if [ -d ~/.ssh ]; then
    # Check permissions
    ssh_perm=$(stat -c %a ~/.ssh 2>/dev/null || stat -f %Lp ~/.ssh 2>/dev/null)
    if [ "$ssh_perm" = "700" ]; then
        check_pass "SSH directory permissions are correct (700)"
    else
        check_warn "SSH directory permissions are $ssh_perm (should be 700)"
    fi

    # Check for keys
    if ls ~/.ssh/*.pub &> /dev/null; then
        check_pass "SSH public keys found"
    else
        check_warn "No SSH public keys found"
    fi

    check_file ~/.ssh/authorized_keys "SSH authorized_keys"
fi

# Check if SSH service is running
if sudo service ssh status &> /dev/null; then
    check_pass "SSH service is running"
    if sudo ss -tlnp | grep :22 &> /dev/null || sudo netstat -tlnp | grep :22 &> /dev/null; then
        check_pass "SSH is listening on port 22"
    else
        check_fail "SSH service running but not listening on port 22"
    fi
else
    check_fail "SSH service is not running"
fi
echo ""

# ========================================
# DATABASE CLIENTS
# ========================================
echo -e "${CYAN}=== Database Clients ===${NC}"
check_command psql "PostgreSQL client"
check_command mysql "MySQL client"
check_command redis-cli "Redis client"
echo ""

# ========================================
# CONTAINER TOOLS
# ========================================

# ----------------------------------------
# Docker Configuration
# ----------------------------------------
echo -e "${CYAN}=== Docker ===${NC}"
if [ -S /var/run/docker.sock ]; then
    check_pass "Docker socket exists"
    if [ -r /var/run/docker.sock ] && [ -w /var/run/docker.sock ]; then
        check_pass "Docker socket is accessible"
        if command -v docker &> /dev/null; then
            if docker version &> /dev/null; then
                check_pass "Docker is working"
                echo "Docker version:"
                docker version --format 'Client: {{.Client.Version}}, Server: {{.Server.Version}}' 2>/dev/null | sed 's/^/  /'
            else
                check_fail "Docker command exists but not working"
            fi
        else
            check_warn "Docker command not found (install docker-ce package if needed)"
        fi
    else
        check_fail "Docker socket exists but not accessible"
    fi
else
    check_warn "Docker socket not found (Docker-outside-of-Docker may not be configured)"
fi

# Check if user is in docker group
if groups | grep -q docker; then
    check_pass "User is in docker group"
else
    check_warn "User is not in docker group (may need to restart shell)"
fi
echo ""

# ========================================
# SHELL CUSTOMIZATION
# ========================================

# ----------------------------------------
# Zsh Configuration
# ----------------------------------------
echo -e "${CYAN}=== Zsh Configuration ===${NC}"
check_dir ~/.oh-my-zsh "Oh My Zsh"
check_file ~/.zshrc "Zsh config"

if [ -d ~/.oh-my-zsh ]; then
    # Check theme
    if [ -d ~/.oh-my-zsh/custom/themes/powerlevel10k ]; then
        check_pass "Powerlevel10k theme installed"
    else
        check_fail "Powerlevel10k theme not found"
    fi

    # Check all plugins from post-create.sh
    echo ""
    echo "Checking Zsh plugins:"
    plugins=(
        "zsh-autosuggestions"
        "zsh-syntax-highlighting"
        "fast-syntax-highlighting"
        "zsh-autocomplete"
        "zsh-bat"
        "you-should-use"
    )
    for plugin in "${plugins[@]}"; do
        if [ -d ~/.oh-my-zsh/custom/plugins/$plugin ]; then
            check_pass "  Plugin $plugin installed"
        else
            check_fail "  Plugin $plugin not found"
        fi
    done
fi

check_file ~/.p10k.zsh "Powerlevel10k config"
echo ""

# ========================================
# ENVIRONMENT VARIABLES
# ========================================
echo -e "${CYAN}=== Environment Variables ===${NC}"
if [ -n "$GITHUB_USERNAME" ]; then
    check_pass "GITHUB_USERNAME is set: $GITHUB_USERNAME"
else
    check_warn "GITHUB_USERNAME is not set"
fi

if [ -n "$PYENV_ROOT" ]; then
    check_pass "PYENV_ROOT is set: $PYENV_ROOT"
else
    check_warn "PYENV_ROOT is not set"
fi

if [ -n "$NVM_DIR" ]; then
    check_pass "NVM_DIR is set: $NVM_DIR"
else
    check_warn "NVM_DIR is not set"
fi
echo ""

# ========================================
# VERIFICATION SUMMARY
# ========================================
echo -e "${PURPLE}========================================${NC}"
echo -e "${PURPLE}              SUMMARY${NC}"
echo -e "${PURPLE}========================================${NC}"
echo -e "Passed: ${GREEN}$PASS_COUNT${NC}"
echo -e "Failed: ${RED}$FAIL_COUNT${NC}"
echo -e "Warnings: ${YELLOW}$WARN_COUNT${NC}"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    if [ $WARN_COUNT -eq 0 ]; then
        echo -e "${GREEN}All checks passed! Your devcontainer is fully configured.${NC}"
    else
        echo -e "${GREEN}Setup is functional with some warnings.${NC}"
        echo -e "${YELLOW}Review the warnings above for optional improvements.${NC}"
    fi
else
    echo -e "${RED}Some checks failed. Please review the errors above.${NC}"
    echo -e "${YELLOW}You may need to rebuild the container or run the setup scripts again.${NC}"
fi

# ========================================
# WELCOME BANNER
# ========================================
echo ""
echo -e "${PURPLE}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║${NC}            ${WHITE}🚀 DJANGO PACKAGE COOKIECUTTER DEVELOPMENT ENVIRONMENT${NC}             ${PURPLE}║${NC}"
echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo

# ----------------------------------------
# System Information
# ----------------------------------------
echo -e "${CYAN}📋 System Information:${NC}"
echo -e "   ${GRAY}•${NC} OS: $(lsb_release -ds 2>/dev/null || cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo -e "   ${GRAY}•${NC} Kernel: $(uname -r)"
echo -e "   ${GRAY}•${NC} Architecture: $(uname -m)"
echo

# ----------------------------------------
# Development Tools Status
# ----------------------------------------
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
elif [ -f "$HOME/.pyenv/bin/pyenv" ]; then
    echo -e "   ${YELLOW}⚠${NC} Pyenv installed but not in PATH (restart shell)"
fi

# Node.js
if command -v node &> /dev/null; then
    echo -e "   ${GREEN}✓${NC} Node.js $(node --version)"
fi

# NPM
if command -v npm &> /dev/null; then
    echo -e "   ${GREEN}✓${NC} NPM $(npm --version)"
fi

# Claude Code CLI
if command -v claude &> /dev/null || [ -f "/home/vscode/.claude/local/claude" ]; then
    echo -e "   ${GREEN}✓${NC} Claude Code CLI"
fi

# Docker
if command -v docker &> /dev/null && docker version &> /dev/null; then
    echo -e "   ${GREEN}✓${NC} Docker $(docker --version | awk '{print $3}' | sed 's/,$//')"
fi

# Cookiecutter
if command -v cookiecutter &> /dev/null; then
    echo -e "   ${GREEN}✓${NC} Cookiecutter $(cookiecutter --version | awk '{print $2}')"
fi

echo

# ----------------------------------------
# Shell Environment Info
# ----------------------------------------
echo -e "${CYAN}🐚 Shell Environment:${NC}"
echo -e "   ${GRAY}•${NC} Shell: $SHELL"
if command -v zsh &> /dev/null; then
    echo -e "   ${GRAY}•${NC} Zsh: $(zsh --version | awk '{print $2}')"
fi
if [ -d ~/.oh-my-zsh ]; then
    echo -e "   ${GRAY}•${NC} Oh My Zsh: ${GREEN}✓${NC} Installed"
    if [ -d ~/.oh-my-zsh/custom/themes/powerlevel10k ]; then
        echo -e "   ${GRAY}•${NC} Theme: Powerlevel10k"
    fi
fi
echo

# ----------------------------------------
# Quick Commands
# ----------------------------------------
echo -e "${CYAN}⚡ Quick Commands:${NC}"
echo -e "   ${GRAY}•${NC} ${YELLOW}cookiecutter .${NC} - Generate a new Django package"
echo -e "   ${GRAY}•${NC} ${YELLOW}make test${NC} - Run tests"
echo -e "   ${GRAY}•${NC} ${YELLOW}verify-setup${NC} - Run this verification script"
echo -e "   ${GRAY}•${NC} ${YELLOW}alias${NC} - List all available shortcuts"
echo

# ----------------------------------------
# SSH Access Information
# ----------------------------------------
echo -e "${CYAN}🔐 SSH Access:${NC}"
echo -e "   ${GRAY}•${NC} Port: 22 (mapped to host port 2222)"
echo -e "   ${GRAY}•${NC} Username: vscode"
echo -e "   ${GRAY}•${NC} Password: vscode"
echo -e "   ${GRAY}•${NC} Connect: ${YELLOW}ssh -p 2222 vscode@localhost${NC}"
echo

echo -e "${PURPLE}────────────────────────────────────────────────────────────────────────────────${NC}"
echo -e "${WHITE}Happy coding! 🎉${NC}"
echo

# Exit with appropriate code
if [ $FAIL_COUNT -gt 0 ]; then
    exit 1
else
    exit 0
fi