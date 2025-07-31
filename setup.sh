#!/bin/bash

# Improved Mac Development Environment Setup Script
# Exit on any error, undefined variables, and pipe failures
set -euo pipefail

# ------------------------
# CONFIGURATION
# ------------------------
readonly SCRIPT_VERSION="2.0.0"
readonly PYTHON_VERSION="3.12.7"
readonly DOTFILES_REPO="https://github.com/mkernsNCR/my-dotfiles.git"

# Progress tracking
readonly TOTAL_STEPS=6
CURRENT_STEP=0
DRY_RUN=false

# Check for dry-run mode
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
    echo "🔍 Running in dry-run mode - no changes will be made"
fi

# ------------------------
# LOGGING AND UTILITIES
# ------------------------
LOG_FILE="$HOME/setup.log"

# Initialize logging
init_logging() {
    if [[ "$DRY_RUN" != "true" ]]; then
        exec > >(tee -a "$LOG_FILE") 2>&1
    fi
    log_info "Starting Mac dev environment setup v$SCRIPT_VERSION"
    log_info "Setup log will be saved to: $LOG_FILE"
}

# Logging functions
log() {
    local level="$1"
    shift
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*"
}

log_info() { log "INFO" "$@"; }
log_warn() { log "WARN" "$@"; }
log_error() { log "ERROR" "$@"; }

# Progress tracking
progress() {
    ((CURRENT_STEP++))
    echo "📊 Progress: $CURRENT_STEP/$TOTAL_STEPS - $1"
}

# Safe command execution
safe_execute() {
    local cmd="$1"
    log_info "Executing: $cmd"
    if [[ "$DRY_RUN" != "true" ]]; then
        eval "$cmd"
    else
        echo "  [DRY-RUN] Would execute: $cmd"
    fi
}

# Input validation functions
validate_email() {
    local email="$1"
    [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]
}

validate_name() {
    local name="$1"
    [[ -n "$name" && ${#name} -le 100 && "$name" =~ ^[a-zA-Z0-9\ \.\-\']+$ ]]
}

validate_token() {
    local token="$1"
    [[ -n "$token" && ${#token} -ge 20 && ${#token} -le 100 && "$token" =~ ^[a-zA-Z0-9_]+$ ]]
}

# Get validated user input
get_user_input() {
    local prompt="$1"
    local validation_type="$2"
    local input=""
    local attempts=0
    local max_attempts=3
    
    while [[ $attempts -lt $max_attempts ]]; do
        echo "$prompt"
        read -r input
        
        case "$validation_type" in
            "email")
                if validate_email "$input"; then
                    echo "$input"
                    return 0
                fi
                log_warn "Invalid email format. Please try again."
                ;;
            "name")
                if validate_name "$input"; then
                    echo "$input"
                    return 0
                fi
                log_warn "Invalid name format. Use only letters, numbers, spaces, dots, and hyphens (max 100 chars)."
                ;;
            *)
                if [[ -n "$input" ]]; then
                    echo "$input"
                    return 0
                fi
                log_warn "Input cannot be empty."
                ;;
        esac
        
        ((attempts++))
    done
    
    log_error "Maximum attempts reached. Exiting."
    exit 1
}

# Cleanup function
cleanup_and_exit() {
    local exit_code="${1:-1}"
    log_info "Cleaning up..."
    
    # Unmount any mounted volumes
    for volume in $(mount | grep -o '/Volumes/[^[:space:]]*' 2>/dev/null || true); do
        if [[ "$volume" =~ ^/Volumes/(ChatGPT|PyCharm|GoogleChrome) ]]; then
            log_info "Unmounting $volume"
            hdiutil detach "$volume" -quiet 2>/dev/null || true
        fi
    done
    
    # Remove temporary files
    rm -f /tmp/setup_temp_* 2>/dev/null || true
    
    if [[ $exit_code -eq 0 ]]; then
        log_info "Setup completed successfully!"
    else
        log_error "Setup failed with exit code $exit_code"
    fi
    
    exit "$exit_code"
}

# Set up trap for cleanup
trap 'cleanup_and_exit 1' ERR INT TERM

# ------------------------
# 1. Prerequisites
# ------------------------

install_xcode_cli() {
    log_info "Checking for Xcode Command Line Tools..."
    
    if xcode-select -p &>/dev/null; then
        echo "✅ Xcode Command Line Tools already installed."
        return 0
    fi
    
    echo "📥 Installing Xcode Command Line Tools..."
    echo "⚠️  A dialog will appear - please click 'Install' to continue"
    
    if [[ "$DRY_RUN" != "true" ]]; then
        xcode-select --install
        
        echo "⏳ Waiting for Xcode CLI tools installation to complete..."
        local timeout=300  # 5 minutes timeout
        local elapsed=0
        
        while ! xcode-select -p &>/dev/null; do
            if [[ $elapsed -ge $timeout ]]; then
                log_error "Xcode CLI tools installation timed out"
                return 1
            fi
            sleep 5
            elapsed=$((elapsed + 5))
        done
    fi
    
    echo "✅ Xcode Command Line Tools installation complete!"
}

install_homebrew() {
    log_info "Checking for Homebrew installation..."
    
    if command -v brew &>/dev/null; then
        echo "✅ Homebrew already installed."
        return 0
    fi
    
    echo "📥 Installing Homebrew package manager..."
    echo "⚠️  You may be prompted for your password during installation"
    
    if [[ "$DRY_RUN" != "true" ]]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ "$(uname -m)" == "arm64" ]]; then
            log_info "Adding Homebrew to PATH for Apple Silicon Mac..."
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    fi
    
    echo "✅ Homebrew installation complete!"
}

install_homebrew_packages() {
    log_info "Updating Homebrew to latest version..."
    safe_execute "brew update"
    
    echo "📦 Installing packages from Brewfile..."
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local brewfile="$script_dir/Brewfile"
    
    if [[ -f "$brewfile" ]]; then
        log_info "Found Brewfile at: $brewfile"
        safe_execute "brew bundle --file=\"$brewfile\""
    else
        log_warn "No Brewfile found at $brewfile"
        echo "📝 Creating a basic Brewfile with essential development tools..."
        
        if [[ "$DRY_RUN" != "true" ]]; then
            cat > "$brewfile" <<EOF
# Essential development tools
brew "git"
brew "node"
brew "python@3.12"
brew "pyenv"
brew "nvm"
brew "wget"
brew "curl"
brew "tree"
brew "jq"
brew "defaultbrowser"

# Development applications
cask "visual-studio-code"
cask "iterm2"
cask "docker"
EOF
        fi
        
        echo "📦 Installing basic development packages..."
        safe_execute "brew bundle --file=\"$brewfile\""
    fi
    
    echo "✅ Homebrew packages installation complete!"
}

# ------------------------
# 2. GIT & SSH KEY SETUP
# ------------------------

configure_git() {
    log_info "Configuring Git user information..."
    
    local git_name git_email
    
    # Configure Git user name
    if [[ -z "$(git config --global user.name 2>/dev/null || true)" ]]; then
        git_name=$(get_user_input "👤 Please enter your full name for Git commits:" "name")
        safe_execute "git config --global user.name \"$git_name\""
        echo "✅ Git user name set to: $git_name"
    else
        echo "✅ Git user name already configured: $(git config --global user.name)"
    fi
    
    # Configure Git email
    if [[ -z "$(git config --global user.email 2>/dev/null || true)" ]]; then
        git_email=$(get_user_input "📧 Please enter your email address for Git commits:" "email")
        safe_execute "git config --global user.email \"$git_email\""
        echo "✅ Git email set to: $git_email"
    else
        echo "✅ Git email already configured: $(git config --global user.email)"
    fi
    
    # Set useful Git defaults
    safe_execute "git config --global init.defaultBranch main"
    safe_execute "git config --global pull.rebase false"
    echo "🔧 Git configuration complete!"
}

generate_ssh_key() {
    log_info "Setting up SSH key for Git authentication..."
    
    local ssh_key_path="$HOME/.ssh/id_ed25519"
    
    if [[ -f "$ssh_key_path" ]]; then
        echo "✅ SSH key already exists at ~/.ssh/id_ed25519"
        echo "🔑 Your public key is:"
        cat "$ssh_key_path.pub"
        return 0
    fi
    
    # Get email for SSH key
    local ssh_email
    ssh_email=$(git config --global user.email 2>/dev/null || true)
    if [[ -z "$ssh_email" ]]; then
        ssh_email=$(get_user_input "📧 Please enter your email address for the SSH key:" "email")
    fi
    
    log_info "Generating new ED25519 SSH key..."
    
    if [[ "$DRY_RUN" != "true" ]]; then
        # Create .ssh directory if it doesn't exist
        mkdir -p ~/.ssh
        chmod 700 ~/.ssh
        
        # Generate SSH key with no passphrase for automation
        ssh-keygen -t ed25519 -C "$ssh_email" -f "$ssh_key_path" -N ""
        
        # Start SSH agent and add key
        log_info "Configuring SSH agent..."
        eval "$(ssh-agent -s)"
        
        # Create or update SSH config for macOS keychain integration
        local ssh_config="$HOME/.ssh/config"
        if [[ ! -f "$ssh_config" ]] || ! grep -q "UseKeychain yes" "$ssh_config"; then
            log_info "Updating SSH config for macOS keychain integration..."
            cat <<EOF >> "$ssh_config"

# macOS keychain integration
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
EOF
        fi
        
        # Add key to SSH agent and macOS keychain
        sleep 1  # Brief pause for agent to start
        ssh-add --apple-use-keychain "$ssh_key_path"
    fi
    
    echo "✅ SSH key generated successfully!"
    echo "🔑 Your public key (copy this to GitHub/GitLab):"
    echo "----------------------------------------"
    if [[ "$DRY_RUN" != "true" ]]; then
        cat "$ssh_key_path.pub"
    else
        echo "[DRY-RUN] SSH public key would be displayed here"
    fi
    echo "----------------------------------------"
    
    # Optional GitHub integration
    echo ""
    echo "🌐 Would you like to automatically upload this key to GitHub? (y/n)"
    read -r upload_choice
    
    if [[ "$upload_choice" =~ ^[Yy]$ ]]; then
        upload_ssh_key_to_github
    else
        echo "📋 Please manually add the public key above to your Git hosting service"
    fi
}

upload_ssh_key_to_github() {
    echo "🔑 Enter your GitHub personal access token (with 'write:public_key' scope):"
    echo "💡 Create one at: https://github.com/settings/tokens"
    
    local gh_token
    read -s gh_token
    
    if ! validate_token "$gh_token"; then
        log_warn "Invalid token format. Skipping GitHub upload."
        return 1
    fi
    
    if [[ -n "$gh_token" && "$DRY_RUN" != "true" ]]; then
        local key_title
        key_title=$(get_user_input "📝 Enter a name for this SSH key (e.g., 'MacBook-Pro-$(date +%Y)'):" "")
        
        local pub_key
        pub_key=$(cat ~/.ssh/id_ed25519.pub)
        
        local response http_code
        response=$(curl -s -w "\n%{http_code}" -H "Authorization: token $gh_token" \
             --data "{\"title\":\"$key_title\",\"key\":\"$pub_key\"}" \
             https://api.github.com/user/keys)
        
        http_code=$(echo "$response" | tail -n1)
        if [[ "$http_code" == "201" ]]; then
            echo "✅ SSH key successfully uploaded to GitHub!"
        else
            log_warn "Failed to upload SSH key to GitHub (HTTP $http_code)"
            echo "📋 Please manually add the key shown above to GitHub"
        fi
    else
        echo "⏩ Skipping GitHub upload"
    fi
    
    # Clear token from memory
    unset gh_token
}

# ------------------------
# 3. SHELL AND DOTFILES CONFIGURATION
# ------------------------

install_oh_my_zsh() {
    log_info "Setting up Oh My Zsh framework..."
    
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        echo "✅ Oh My Zsh already installed."
        return 0
    fi
    
    echo "📥 Installing Oh My Zsh..."
    echo "⚠️  The installer may change your shell - this is normal"
    
    if [[ "$DRY_RUN" != "true" ]]; then
        # Install Oh My Zsh with unattended mode
        RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        
        # Install useful Oh My Zsh plugins
        log_info "Installing additional Zsh plugins..."
        
        # zsh-autosuggestions plugin
        if [[ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]]; then
            git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
        fi
        
        # zsh-syntax-highlighting plugin
        if [[ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]]; then
            git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
        fi
    fi
    
    echo "✅ Oh My Zsh installation complete!"
}

configure_zshrc() {
    log_info "Configuring .zshrc..."
    
    if [[ "$DRY_RUN" != "true" ]]; then
        cat > ~/.zshrc <<'EOF'
# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

plugins=(
  git
  npm
  node
  yarn
  zsh-autosuggestions
  history-substring-search
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# NVM Setup
export NVM_DIR="$HOME/.nvm"
[ -s "$(brew --prefix nvm)/nvm.sh" ] && \. "$(brew --prefix nvm)/nvm.sh"

# pyenv setup
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
EOF
    fi
    
    echo "✅ .zshrc configuration complete!"
}

link_dotfiles() {
    log_info "Linking dotfiles from GitHub..."
    
    local dotfiles_dir="$HOME/dotfiles"
    
    if [[ -d "$dotfiles_dir" ]]; then
        log_info "Dotfiles directory already exists, pulling latest changes..."
        if [[ "$DRY_RUN" != "true" ]]; then
            cd "$dotfiles_dir"
            git pull origin main || git pull origin master || true
            cd - > /dev/null
        fi
    else
        log_info "Cloning dotfiles repository..."
        if [[ "$DRY_RUN" != "true" ]]; then
            if ! git clone "$DOTFILES_REPO" "$dotfiles_dir"; then
                log_warn "Failed to clone dotfiles repository, skipping dotfiles setup"
                return 0
            fi
        fi
    fi
    
    # Link dotfiles if they exist
    if [[ "$DRY_RUN" != "true" ]]; then
        [[ -f "$dotfiles_dir/.gitconfig" ]] && ln -sf "$dotfiles_dir/.gitconfig" "$HOME/.gitconfig"
        [[ -f "$dotfiles_dir/.zshrc" ]] && ln -sf "$dotfiles_dir/.zshrc" "$HOME/.zshrc"
    fi
    
    echo "✅ Dotfiles linking complete!"
}

# ------------------------
# 4. DEVELOPMENT ENVIRONMENTS
# ------------------------

setup_node() {
    log_info "Setting up Node.js development environment..."
    
    # Ensure NVM directory exists
    [[ "$DRY_RUN" != "true" ]] && mkdir -p ~/.nvm
    
    # Load NVM if available
    export NVM_DIR="$HOME/.nvm"
    local nvm_script=""
    
    if [[ -s "$(brew --prefix)/share/nvm/nvm.sh" ]]; then
        nvm_script="$(brew --prefix)/share/nvm/nvm.sh"
    elif [[ -s "$NVM_DIR/nvm.sh" ]]; then
        nvm_script="$NVM_DIR/nvm.sh"
    fi
    
    if [[ -z "$nvm_script" ]]; then
        log_error "NVM not found. Please ensure it's installed via Homebrew."
        return 1
    fi
    
    if [[ "$DRY_RUN" != "true" ]]; then
        # shellcheck source=/dev/null
        source "$nvm_script"
        
        # Install latest LTS version of Node.js
        log_info "Installing latest LTS version of Node.js..."
        nvm install --lts
        nvm use --lts
        nvm alias default node
        
        # Verify installation
        log_info "Node.js setup complete!"
        echo "📋 Installed versions:"
        echo "   Node.js: $(node --version)"
        echo "   NPM: $(npm --version)"
        
        # Install useful global packages
        log_info "Installing useful global NPM packages..."
        npm install -g yarn typescript nodemon create-react-app
    fi
    
    echo "🟢 Node.js development environment ready!"
}

setup_python() {
    log_info "Setting up Python development environment..."
    
    if ! command -v pyenv &>/dev/null; then
        log_error "pyenv not found. Please ensure it's installed via Homebrew."
        return 1
    fi
    
    if [[ "$DRY_RUN" != "true" ]]; then
        # Initialize pyenv in current shell
        eval "$(pyenv init -)"
        
        # Install Python version
        log_info "Installing Python $PYTHON_VERSION with pyenv..."
        
        if pyenv versions | grep -q "$PYTHON_VERSION"; then
            log_info "Python $PYTHON_VERSION already installed"
        else
            log_info "This may take a few minutes..."
            if ! pyenv install "$PYTHON_VERSION"; then
                log_warn "Failed to install Python $PYTHON_VERSION, trying latest available Python 3.12.x..."
                local latest_312
                latest_312=$(pyenv install --list | grep -E '^\s*3\.12\.[0-9]+$' | tail -1 | xargs)
                if [[ -n "$latest_312" ]]; then
                    pyenv install "$latest_312"
                    PYTHON_VERSION="$latest_312"
                else
                    log_error "Failed to install any Python 3.12.x version"
                    return 1
                fi
            fi
        fi
        
        # Set as global Python version
        log_info "Setting Python $PYTHON_VERSION as global default..."
        pyenv global "$PYTHON_VERSION"
        
        # Verify installation
        log_info "Python setup complete!"
        echo "📋 Installed version: $(python --version)"
        echo "📋 Pip version: $(pip --version)"
        
        # Upgrade pip and install useful packages
        log_info "Installing useful Python packages..."
        pip install --upgrade pip
        pip install virtualenv black flake8 pytest requests
    fi
    
    echo "🐍 Python development environment ready!"
}

# ------------------------
# 5. GUI APPLICATIONS INSTALLATION
# ------------------------

# Download with integrity verification (simplified - in production you'd have real checksums)
download_with_verification() {
    local url="$1"
    local output="$2"
    local description="$3"
    
    log_info "Downloading $description..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "  [DRY-RUN] Would download: $url -> $output"
        return 0
    fi
    
    if curl -L --progress-bar --fail -o "$output" "$url"; then
        log_info "$description downloaded successfully"
        return 0
    else
        log_error "Failed to download $description"
        return 1
    fi
}

download_apps() {
    log_info "Downloading GUI applications to ~/Downloads..."
    
    # Create Downloads directory if it doesn't exist
    [[ "$DRY_RUN" != "true" ]] && mkdir -p ~/Downloads
    
    # Download applications with error handling
    download_with_verification \
        "https://download.jetbrains.com/python/pycharm-professional.dmg" \
        "$HOME/Downloads/pycharm.dmg" \
        "PyCharm Professional" || true
    
    download_with_verification \
        "https://persistent.oaistatic.com/sidekick/public/ChatGPT_Desktop_public_latest.dmg" \
        "$HOME/Downloads/ChatGPT.dmg" \
        "ChatGPT" || true
    
    download_with_verification \
        "https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg" \
        "$HOME/Downloads/GoogleChrome.dmg" \
        "Google Chrome" || true
    
    echo "💡 Additional recommended downloads:"
    echo "   • Windsurf: https://windsurf.dev"
    echo "   • Docker Desktop: https://www.docker.com/products/docker-desktop"
    echo "✅ Download phase complete!"
}

install_dmg_app() {
    local dmg_path="$1"
    local app_name="$2"
    
    if [[ ! -f "$dmg_path" ]]; then
        log_warn "$app_name DMG not found at $dmg_path, skipping installation"
        return 0
    fi
    
    log_info "Installing $app_name..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "  [DRY-RUN] Would install: $dmg_path"
        return 0
    fi
    
    local volume app_path
    
    # Mount the DMG
    log_info "Mounting $app_name..."
    if ! hdiutil attach "$dmg_path" -nobrowse -quiet; then
        log_error "Failed to mount $app_name DMG"
        return 1
    fi
    
    # Find the mounted volume and app
    volume=$(hdiutil info | grep "/Volumes/" | tail -1 | awk '{$1=$1;print}' | cut -f3- -d' ')
    app_path=$(find "$volume" -maxdepth 1 -name "*.app" | head -1)
    
    if [[ -d "$app_path" ]]; then
        log_info "Installing $app_name to /Applications..."
        echo "🔐 Administrator access needed to install $app_name"
        echo "   You may be prompted for your password"
        
        if sudo cp -R "$app_path" /Applications/; then
            log_info "$app_name installed successfully"
        else
            log_error "Failed to install $app_name"
        fi
    else
        log_error "Could not find app in $app_name DMG"
    fi
    
    # Unmount the DMG
    log_info "Unmounting $app_name..."
    hdiutil detach "$volume" -quiet || log_warn "Failed to unmount $volume cleanly"
}

install_gui_apps() {
    install_dmg_app "$HOME/Downloads/pycharm.dmg" "PyCharm"
    install_dmg_app "$HOME/Downloads/ChatGPT.dmg" "ChatGPT"
    install_dmg_app "$HOME/Downloads/GoogleChrome.dmg" "Google Chrome"
}

# ------------------------
# 6. System Configuration
# ------------------------

set_default_browser() {
    if ! command -v defaultbrowser &>/dev/null; then
        log_info "Installing 'defaultbrowser' CLI tool..."
        safe_execute "brew install defaultbrowser"
    fi
    
    log_info "Setting Google Chrome as the default browser..."
    safe_execute "defaultbrowser chrome"
}

# ------------------------
# MAIN EXECUTION FLOW
# ------------------------

main() {
    echo "🚀 Starting optimized Mac dev environment setup v$SCRIPT_VERSION..."
    echo ""
    
    # Initialize logging
    init_logging
    
    # 1. Prerequisites
    progress "Installing Prerequisites"
    install_xcode_cli
    install_homebrew
    install_homebrew_packages
    echo "✅ Prerequisites complete!"
    echo ""
    
    # 2. Git & SSH Setup
    progress "Setting up Git & SSH"
    configure_git
    generate_ssh_key
    echo "✅ Git & SSH setup complete!"
    echo ""
    
    # 3. Shell & Dotfiles
    progress "Configuring Shell & Dotfiles"
    install_oh_my_zsh
    configure_zshrc
    link_dotfiles
    echo "✅ Shell & Dotfiles complete!"
    echo ""
    
    # 4. Development Environments
    progress "Setting up Development Environments"
    setup_node
    setup_python
    echo "✅ Development environments complete!"
    echo ""
    
    # 5. GUI Applications
    progress "Installing GUI Applications"
    download_apps
    install_gui_apps
    echo "✅ GUI applications complete!"
    echo ""
    
    # 6. System Configuration
    progress "Final System Configuration"
    set_default_browser
    echo "✅ System configuration complete!"
    echo ""
    
    cleanup_and_exit 0
}

# Run main function
main "$@"