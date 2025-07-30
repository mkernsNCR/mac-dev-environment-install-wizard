#!/bin/bash

# Exit on any error, but handle specific cases gracefully
set -e

# ------------------------
# LOGGING SETUP
# ------------------------
# Create a log file in the user's home directory to track all setup activities
# This will capture both stdout and stderr for debugging purposes
LOG_FILE="$HOME/setup.log"
exec > >(tee -a "$LOG_FILE") 2>&1
echo "[$(date)] Starting Mac dev environment setup..."
echo "📝 Setup log will be saved to: $LOG_FILE"

# ------------------------
# 1. Prerequisites
# ------------------------

# Install Xcode Command Line Tools
# These provide essential development tools like git, make, clang compiler, etc.
install_xcode_cli() {
  echo "📦 Checking for Xcode Command Line Tools..."
  
  # Check if Xcode CLI tools are already installed
  if xcode-select -p &>/dev/null; then
    echo "✅ Xcode Command Line Tools already installed."
  else
    echo "📥 Installing Xcode Command Line Tools..."
    echo "⚠️  A dialog will appear - please click 'Install' to continue"
    xcode-select --install
    
    # Wait for installation to complete
    echo "⏳ Waiting for Xcode CLI tools installation to complete..."
    until xcode-select -p &>/dev/null; do
      sleep 5
    done
    echo "✅ Xcode Command Line Tools installation complete!"
  fi
}

# Install Homebrew package manager
# Homebrew is the most popular package manager for macOS
install_homebrew() {
  echo "🍺 Checking for Homebrew installation..."
  
  if ! command -v brew &> /dev/null; then
    echo "📥 Installing Homebrew package manager..."
    echo "⚠️  You may be prompted for your password during installation"
    
    # Install Homebrew using the official installation script
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == "arm64" ]]; then
      echo "🔧 Adding Homebrew to PATH for Apple Silicon Mac..."
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    
    echo "✅ Homebrew installation complete!"
  else
    echo "✅ Homebrew already installed."
  fi
}

# Install packages from Brewfile
# This reads a Brewfile and installs all specified packages, casks, and mas apps
install_homebrew_packages() {
  echo "🔄 Updating Homebrew to latest version..."
  brew update
  
  echo "📦 Installing packages from Brewfile..."
  # Get the directory where this script is located
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  
  # Check if Brewfile exists
  if [[ -f "$SCRIPT_DIR/Brewfile" ]]; then
    echo "📋 Found Brewfile at: $SCRIPT_DIR/Brewfile"
    brew bundle --file="$SCRIPT_DIR/Brewfile"
    echo "✅ Homebrew packages installation complete!"
  else
    echo "⚠️  No Brewfile found at $SCRIPT_DIR/Brewfile"
    echo "📝 Creating a basic Brewfile with essential development tools..."
    
    # Create a basic Brewfile if none exists
    cat > "$SCRIPT_DIR/Brewfile" <<EOF
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
    
    echo "📦 Installing basic development packages..."
    brew bundle --file="$SCRIPT_DIR/Brewfile"
    echo "✅ Basic Homebrew packages installation complete!"
  fi
}

# ------------------------
# 2. GIT & SSH KEY SETUP
# ------------------------
# Configure Git with user information and set up SSH keys for secure authentication

# Configure Git with user information
# This sets up your identity for Git commits
configure_git() {
  echo "📝 Configuring Git user information..."
  
  # Check if Git user name is already configured
  if [[ -z "$(git config --global user.name)" ]]; then
    echo "👤 Please enter your full name for Git commits:"
    read -r GIT_NAME
    git config --global user.name "$GIT_NAME"
    echo "✅ Git user name set to: $GIT_NAME"
  else
    echo "✅ Git user name already configured: $(git config --global user.name)"
  fi
  
  # Check if Git email is already configured
  if [[ -z "$(git config --global user.email)" ]]; then
    echo "📧 Please enter your email address for Git commits:"
    read -r GIT_EMAIL
    git config --global user.email "$GIT_EMAIL"
    echo "✅ Git email set to: $GIT_EMAIL"
  else
    echo "✅ Git email already configured: $(git config --global user.email)"
  fi
  
  # Set some useful Git defaults
  git config --global init.defaultBranch main
  git config --global pull.rebase false
  echo "🔧 Git configuration complete!"
}

# Generate SSH key for secure Git authentication
# SSH keys provide a secure way to authenticate with Git repositories
generate_ssh_key() {
  echo "🔐 Setting up SSH key for Git authentication..."
  
  # Check if SSH key already exists
  if [[ -f "$HOME/.ssh/id_ed25519" ]]; then
    echo "✅ SSH key already exists at ~/.ssh/id_ed25519"
    echo "🔑 Your public key is:"
    cat ~/.ssh/id_ed25519.pub
    return
  fi
  
  # Get email for SSH key (use Git email if configured)
  SSH_EMAIL=$(git config --global user.email)
  if [[ -z "$SSH_EMAIL" ]]; then
    echo "📧 Please enter your email address for the SSH key:"
    read -r SSH_EMAIL
  fi
  
  echo "🔐 Generating new ED25519 SSH key..."
  # Create .ssh directory if it doesn't exist
  mkdir -p ~/.ssh
  chmod 700 ~/.ssh
  
  # Generate SSH key with no passphrase for automation
  ssh-keygen -t ed25519 -C "$SSH_EMAIL" -f "$HOME/.ssh/id_ed25519" -N ""
  
  # Start SSH agent and add key
  echo "🔧 Configuring SSH agent..."
  eval "$(ssh-agent -s)"
  
  # Create or update SSH config for macOS keychain integration
  if [[ ! -f ~/.ssh/config ]] || ! grep -q "UseKeychain yes" ~/.ssh/config; then
    echo "📝 Updating SSH config for macOS keychain integration..."
    cat <<EOF >> ~/.ssh/config

# macOS keychain integration
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
EOF
  fi
  
  # Add key to SSH agent and macOS keychain
  ssh-add --apple-use-keychain ~/.ssh/id_ed25519
  
  echo "✅ SSH key generated successfully!"
  echo "🔑 Your public key (copy this to GitHub/GitLab):"
  echo "----------------------------------------"
  cat ~/.ssh/id_ed25519.pub
  echo "----------------------------------------"
  
  # Optional GitHub integration
  echo ""
  echo "🌐 Would you like to automatically upload this key to GitHub? (y/n)"
  read -r UPLOAD_TO_GITHUB
  
  if [[ "$UPLOAD_TO_GITHUB" =~ ^[Yy]$ ]]; then
    echo "🔑 Enter your GitHub personal access token (with 'write:public_key' scope):"
    echo "💡 Create one at: https://github.com/settings/tokens"
    read -s GH_TOKEN
    
    if [[ -n "$GH_TOKEN" ]]; then
      echo "📝 Enter a name for this SSH key (e.g., 'MacBook-Pro-$(date +%Y)'):"
      read -r KEY_TITLE
      
      PUB_KEY=$(cat ~/.ssh/id_ed25519.pub)
      RESPONSE=$(curl -s -w "\n%{http_code}" -H "Authorization: token $GH_TOKEN" \
           --data "{\"title\":\"$KEY_TITLE\",\"key\":\"$PUB_KEY\"}" \
           https://api.github.com/user/keys)
      
      HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
      if [[ "$HTTP_CODE" == "201" ]]; then
        echo "✅ SSH key successfully uploaded to GitHub!"
      else
        echo "❌ Failed to upload SSH key to GitHub (HTTP $HTTP_CODE)"
        echo "📋 Please manually add the key shown above to GitHub"
      fi
    else
      echo "⏩ No token provided - please manually add the key to GitHub"
    fi
  else
    echo "📋 Please manually add the public key above to your Git hosting service"
  fi
}

# ------------------------
# 3. SHELL AND DOTFILES CONFIGURATION
# ------------------------
# Set up Zsh with Oh My Zsh framework and configure dotfiles

# Install Oh My Zsh framework
# Oh My Zsh provides themes, plugins, and helpers for Zsh shell
install_oh_my_zsh() {
  echo "🎀 Setting up Oh My Zsh framework..."
  
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    echo "✅ Oh My Zsh already installed."
    return
  fi
  
  echo "📥 Installing Oh My Zsh..."
  echo "⚠️  The installer may change your shell - this is normal"
  
  # Install Oh My Zsh with unattended mode to prevent shell switching interruption
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  
  # Install useful Oh My Zsh plugins
  echo "🔌 Installing additional Zsh plugins..."
  
  # zsh-autosuggestions plugin
  if [[ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
  fi
  
  # zsh-syntax-highlighting plugin
  if [[ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
  fi
  
  echo "✅ Oh My Zsh installation complete!"
}

configure_zshrc() {
  echo "⚙️ Configuring .zshrc..."

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
}

link_dotfiles() {
  echo "🔗 Linking dotfiles from GitHub via SSH..."
  DOTFILES_REPO="git@github.com:mkernsNCR/my-dotfiles.git"
  git clone "$DOTFILES_REPO" "$HOME/dotfiles" || echo "⚠️ Skipping clone (already exists?)"
  ln -sf "$HOME/dotfiles/.gitconfig" "$HOME/.gitconfig"
  ln -sf "$HOME/dotfiles/.zshrc" "$HOME/.zshrc"
}

# ------------------------
# 4. DEVELOPMENT ENVIRONMENTS
# ------------------------
# Set up Node.js and Python development environments

# Set up Node.js development environment
# Install and configure Node.js using Node Version Manager (NVM)
setup_node() {
  echo "🟢 Setting up Node.js development environment..."
  
  # Ensure NVM directory exists
  mkdir -p ~/.nvm
  
  # Load NVM if available
  export NVM_DIR="$HOME/.nvm"
  if [[ -s "$(brew --prefix)/share/nvm/nvm.sh" ]]; then
    source "$(brew --prefix)/share/nvm/nvm.sh"
  elif [[ -s "$NVM_DIR/nvm.sh" ]]; then
    source "$NVM_DIR/nvm.sh"
  else
    echo "⚠️  NVM not found. Please ensure it's installed via Homebrew."
    return 1
  fi
  
  # Install latest LTS version of Node.js
  echo "📥 Installing latest LTS version of Node.js..."
  nvm install --lts
  nvm use --lts
  nvm alias default node
  
  # Verify installation
  echo "✅ Node.js setup complete!"
  echo "📋 Installed versions:"
  echo "   Node.js: $(node --version)"
  echo "   NPM: $(npm --version)"
  
  # Install useful global packages
  echo "📦 Installing useful global NPM packages..."
  npm install -g yarn typescript nodemon create-react-app
  
  echo "🟢 Node.js development environment ready!"
}

# Set up Python development environment
# Install and configure Python using pyenv for version management
setup_python() {
  echo "🐍 Setting up Python development environment..."
  
  # Check if pyenv is installed
  if ! command -v pyenv &>/dev/null; then
    echo "⚠️  pyenv not found. Please ensure it's installed via Homebrew."
    return 1
  fi
  
  # Initialize pyenv in current shell
  eval "$(pyenv init -)"
  
  # Install Python 3.12 (latest stable version)
  PYTHON_VERSION="3.12.7"
  echo "📥 Installing Python $PYTHON_VERSION with pyenv..."
  
  # Check if version is already installed
  if pyenv versions | grep -q "$PYTHON_VERSION"; then
    echo "✅ Python $PYTHON_VERSION already installed"
  else
    echo "⏳ This may take a few minutes..."
    if pyenv install "$PYTHON_VERSION"; then
      echo "✅ Python $PYTHON_VERSION installed successfully!"
    else
      echo "❌ Failed to install Python $PYTHON_VERSION"
      echo "🔧 Trying to install latest available Python 3.12.x version..."
      # Try to install any available 3.12.x version
      LATEST_312=$(pyenv install --list | grep -E '^\s*3\.12\.[0-9]+$' | tail -1 | xargs)
      if [[ -n "$LATEST_312" ]]; then
        pyenv install "$LATEST_312"
        PYTHON_VERSION="$LATEST_312"
      fi
    fi
  fi
  
  # Set as global Python version
  echo "🔧 Setting Python $PYTHON_VERSION as global default..."
  pyenv global "$PYTHON_VERSION"
  
  # Verify installation
  echo "✅ Python setup complete!"
  echo "📋 Installed version: $(python --version)"
  echo "📋 Pip version: $(pip --version)"
  
  # Upgrade pip and install useful packages
  echo "📦 Installing useful Python packages..."
  pip install --upgrade pip
  pip install virtualenv black flake8 pytest requests
  
  echo "🐍 Python development environment ready!"
}

# ------------------------
# 5. GUI APPLICATIONS INSTALLATION
# ------------------------
# Download and install essential GUI applications for development

# Download GUI applications to ~/Downloads
# This function downloads DMG files for manual or automated installation
download_apps() {
  echo "🌐 Downloading GUI applications to ~/Downloads..."
  
  # Create Downloads directory if it doesn't exist
  mkdir -p ~/Downloads
  
  # Download applications with progress indication
  echo "📥 Downloading PyCharm Professional..."
  if curl -L --progress-bar -o ~/Downloads/pycharm.dmg "https://download.jetbrains.com/python/pycharm-professional.dmg"; then
    echo "✅ PyCharm downloaded successfully"
  else
    echo "❌ Failed to download PyCharm"
  fi
  
  echo "📥 Downloading ChatGPT..."
  if curl -L --progress-bar -o ~/Downloads/ChatGPT.dmg "https://persistent.oaistatic.com/sidekick/public/ChatGPT_Desktop_public_latest.dmg"; then
    echo "✅ ChatGPT downloaded successfully"
  else
    echo "❌ Failed to download ChatGPT"
  fi
  
  echo "📥 Downloading Google Chrome..."
  if curl -L --progress-bar -o ~/Downloads/GoogleChrome.dmg "https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg"; then
    echo "✅ Google Chrome downloaded successfully"
  else
    echo "❌ Failed to download Google Chrome"
  fi
  
  echo "💡 Additional recommended downloads:"
  echo "   • Windsurf: https://windsurf.dev"
  echo "   • Docker Desktop: https://www.docker.com/products/docker-desktop"
  echo "✅ Download phase complete!"
}

install_dmg_app() {
  dmg_path="$1"
  app_name="$2"

  echo "📦 Mounting $app_name..."
  hdiutil attach "$dmg_path" -nobrowse -quiet
  volume=$(hdiutil info | grep "/Volumes/" | tail -1 | awk '{$1=$1;print}' | cut -f3- -d' ')
  app_path=$(find "$volume" -maxdepth 1 -name "*.app" | head -1)

  if [ -d "$app_path" ]; then
    echo "📥 Installing $app_name to /Applications..."
    sudo cp -R "$app_path" /Applications/
  fi

  echo "💨 Unmounting $app_name..."
  hdiutil detach "$volume" -quiet
}

install_gui_apps() {
  install_dmg_app ~/Downloads/pycharm.dmg "PyCharm"
  install_dmg_app ~/Downloads/ChatGPT.dmg "ChatGPT"
  install_dmg_app ~/Downloads/GoogleChrome.dmg "Google Chrome"
}

# ------------------------
# 6. System Configuration
# ------------------------

set_default_browser() {
  if ! command -v defaultbrowser &> /dev/null; then
    echo "⬇️ Installing 'defaultbrowser' CLI tool..."
    brew install defaultbrowser
  fi

  echo "🧭 Setting Google Chrome as the default browser..."
  defaultbrowser chrome
}


# ------------------------
# MAIN EXECUTION FLOW
# ------------------------

echo "🚀 Starting optimized Mac dev environment setup..."
echo ""

# 1. Prerequisites
echo "📋 Step 1: Installing Prerequisites..."
install_xcode_cli
install_homebrew
install_homebrew_packages
echo "✅ Prerequisites complete!"
echo ""

# 2. Git & SSH Setup (before dotfiles)
echo "📋 Step 2: Setting up Git & SSH..."
configure_git
generate_ssh_key
echo "✅ Git & SSH setup complete!"
echo ""

# 3. Shell & Dotfiles
echo "📋 Step 3: Configuring Shell & Dotfiles..."
install_oh_my_zsh
configure_zshrc
link_dotfiles
echo "✅ Shell & Dotfiles complete!"
echo ""

# 4. Development Environments
echo "📋 Step 4: Setting up Development Environments..."
setup_node
setup_python
echo "✅ Development environments complete!"
echo ""

# 5. GUI Applications
echo "📋 Step 5: Installing GUI Applications..."
download_apps
install_gui_apps
echo "✅ GUI applications complete!"
echo ""

# 6. System Configuration
echo "📋 Step 6: Final System Configuration..."
set_default_browser
echo "✅ System configuration complete!"
echo ""
echo "✅ All done! Setup log saved to $LOG_FILE"
echo "📎 Note: Windsurf must be installed manually from https://windsurf.dev"
echo "🚀 Restart your terminal or run: source ~/.zshrc"
