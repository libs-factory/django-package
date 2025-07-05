#!/bin/bash

# Post-create script for devcontainer
# This script runs once when the container is first created

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} ${CYAN}[INFO]${NC} $1"
}

log_success() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} ${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} ${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} ${RED}[ERROR]${NC} $1"
}

echo -e "${PURPLE}========================================${NC}"
echo -e "${PURPLE}     POST-CREATE SCRIPT EXECUTION${NC}"
echo -e "${PURPLE}========================================${NC}"

# ========================================
# SYSTEM PACKAGES INSTALLATION
# ========================================

# Update package lists
log_info "Updating package lists..."
sudo apt-get update

# ----------------------------------------
# Core System Utilities
# ----------------------------------------
log_info "Installing core system utilities..."
sudo apt-get install -y --no-install-recommends \
    curl \
    wget \
    ca-certificates \
    gnupg \
    lsb-release \
    locales \
    sudo

# ----------------------------------------
# Text Editors
# ----------------------------------------
log_info "Installing text editors..."
sudo apt-get install -y --no-install-recommends \
    vim \
    nano

# ----------------------------------------
# Archive Tools
# ----------------------------------------
log_info "Installing archive tools..."
sudo apt-get install -y --no-install-recommends \
    unzip \
    zip

# ----------------------------------------
# Development Tools
# ----------------------------------------
log_info "Installing development tools..."
sudo apt-get install -y --no-install-recommends \
    git \
    build-essential \
    cmake \
    pkg-config

# ----------------------------------------
# Code Quality Tools
# ----------------------------------------
log_info "Installing code quality tools..."
sudo apt-get install -y --no-install-recommends \
    clang-format \
    shellcheck

# ----------------------------------------
# Python Development
# ----------------------------------------
log_info "Installing Python runtime and development packages..."
sudo apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev

log_info "Installing Python build dependencies..."
sudo apt-get install -y --no-install-recommends \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev

# ----------------------------------------
# Shell and Terminal Tools
# ----------------------------------------
log_info "Installing shell environment..."
sudo apt-get install -y --no-install-recommends \
    zsh \
    tmux

log_info "Installing system monitoring tools..."
sudo apt-get install -y --no-install-recommends \
    htop \
    tree

log_info "Installing modern CLI tools..."
sudo apt-get install -y --no-install-recommends \
    jq \
    ripgrep \
    fd-find \
    bat \
    fzf

# ----------------------------------------
# Network Tools
# ----------------------------------------
log_info "Installing network utilities..."
sudo apt-get install -y --no-install-recommends \
    net-tools \
    iputils-ping \
    dnsutils

log_info "Installing SSH server..."
sudo apt-get install -y --no-install-recommends \
    openssh-server

# ----------------------------------------
# Database Clients
# ----------------------------------------
log_info "Installing database clients..."
sudo apt-get install -y --no-install-recommends \
    postgresql-client \
    mysql-client \
    redis-tools

# ========================================
# POST-INSTALLATION CONFIGURATION
# ========================================

# ----------------------------------------
# Fix Command Aliases
# ----------------------------------------
# Fix bat command if installed as batcat
if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
    log_info "Creating bat symlink..."
    sudo ln -sf /usr/bin/batcat /usr/local/bin/bat
    log_success "bat command configured"
fi

# ========================================
# DEVELOPMENT ENVIRONMENT SETUP
# ========================================

# ----------------------------------------
# Python Version Management
# ----------------------------------------
# Install pyenv
log_info "Installing pyenv..."
if ! command -v pyenv &> /dev/null; then
    curl https://pyenv.run | bash

    # Add pyenv to shell profiles
    PYENV_CONFIG='
# Pyenv configuration
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv &> /dev/null; then
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi
'
    echo "$PYENV_CONFIG" >> ~/.bashrc
    echo "$PYENV_CONFIG" >> ~/.zshrc

    log_success "pyenv installed and configured"
else
    log_info "pyenv already installed"
fi

# ----------------------------------------
# Node.js Tools
# ----------------------------------------
# Update npm
log_info "Updating npm to the latest version..."
if command -v npm &> /dev/null; then
    npm install -g npm@latest
    log_success "npm updated successfully"
else
    log_warning "npm not found, skipping npm update"
fi

# Install Claude Code globally if npm is available
if command -v npm &> /dev/null; then
    log_info "Installing Claude Code globally..."
    npm install -g @anthropic-ai/claude-code
    log_success "Claude Code installed globally"
fi

# ========================================
# USER AND AUTHENTICATION SETUP
# ========================================

# ----------------------------------------
# User Configuration
# ----------------------------------------
# Set default password for vscode user
log_info "Setting up user authentication..."
echo "vscode:vscode" | sudo chpasswd
log_success "Default password set for vscode user (password: vscode)"

# ----------------------------------------
# SSH Configuration
# ----------------------------------------
# Configure SSH daemon
log_info "Configuring SSH daemon..."
sudo sed -i 's/^#*ListenAddress .*/ListenAddress 0.0.0.0/' /etc/ssh/sshd_config
sudo sed -i 's/^#*PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/^#*PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#*PubkeyAuthentication .*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#*Port .*/Port 22/' /etc/ssh/sshd_config

# Add SSH performance optimizations
if ! grep -q "Performance and keep-alive settings" /etc/ssh/sshd_config; then
    sudo tee -a /etc/ssh/sshd_config > /dev/null << 'EOF'

# Performance and keep-alive settings
ClientAliveInterval 60
ClientAliveCountMax 3
TCPKeepAlive yes
UseDNS no
Compression yes
EOF
    log_success "SSH configuration updated"
fi

# Generate SSH host keys
log_info "Generating SSH host keys..."
sudo ssh-keygen -A
log_success "SSH host keys generated"

# ========================================
# SHELL CUSTOMIZATION
# ========================================

# ----------------------------------------
# Zsh Plugins and Themes
# ----------------------------------------
# Install Zsh plugins and themes
log_info "Installing Zsh customizations..."
if [ -d ~/.oh-my-zsh ]; then
    ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

    # Install Powerlevel10k theme
    if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
        log_success "Powerlevel10k theme installed"
    fi

    # Install Zsh plugins
    plugins=(
        "zsh-users/zsh-autosuggestions:zsh-autosuggestions"
        "zsh-users/zsh-syntax-highlighting:zsh-syntax-highlighting"
        "zdharma-continuum/fast-syntax-highlighting:fast-syntax-highlighting"
        "marlonrichert/zsh-autocomplete:zsh-autocomplete"
        "fdellwing/zsh-bat:zsh-bat"
        "MichaelAquilina/zsh-you-should-use:you-should-use"
    )

    for plugin_spec in "${plugins[@]}"; do
        plugin_repo="${plugin_spec%%:*}"
        plugin_name="${plugin_spec##*:}"
        if [ ! -d "$ZSH_CUSTOM/plugins/$plugin_name" ]; then
            git clone --depth=1 "https://github.com/$plugin_repo" "$ZSH_CUSTOM/plugins/$plugin_name" 2>/dev/null
        fi
    done
    log_success "Zsh plugins installed"

    # Configure .zshrc
    sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
    sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting zsh-bat you-should-use)/' ~/.zshrc

    # Add shell configurations
    if ! grep -q "Plugin configurations" ~/.zshrc; then
        cat >> ~/.zshrc << 'EOF'

# Plugin configurations
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#666666"
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
export YSU_MESSAGE_POSITION="after"
export YSU_MODE=ALL
export FORGIT_NO_ALIASES=1

# Python development
export PYTHONDONTWRITEBYTECODE=1
export PYTHONUNBUFFERED=1

# Node.js development
export NVM_DIR="/usr/local/share/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# AWS CLI
export AWS_CLI_AUTO_PROMPT=on-partial

# Better history
export HISTSIZE=100000
export SAVEHIST=100000
export HISTFILE=~/.zsh_history
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt SHARE_HISTORY
EOF
        log_success "Zsh configuration updated"
    fi
fi

# ----------------------------------------
# Shell Configuration Files
# ----------------------------------------
# Copy Powerlevel10k configuration
if [ -f .devcontainer/configs/.p10k.zsh ]; then
    cp .devcontainer/configs/.p10k.zsh ~/.p10k.zsh
    log_success "Powerlevel10k configuration copied"

    # Add p10k sourcing to .zshrc if not already present
    if ! grep -q "\.p10k\.zsh" ~/.zshrc; then
        echo '' >> ~/.zshrc
        echo '# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.' >> ~/.zshrc
        echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >> ~/.zshrc
        log_success "Added Powerlevel10k sourcing to .zshrc"
    fi
else
    log_warning "Powerlevel10k config file not found at .devcontainer/configs/.p10k.zsh"
fi

# ========================================
# CLEANUP
# ========================================

# Clean up apt cache to reduce image size
log_info "Cleaning up package cache..."
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/*

echo -e "${PURPLE}========================================${NC}"
echo -e "${GREEN}Post-create script completed!${NC}"
echo -e "${PURPLE}========================================${NC}"