#!/bin/bash

set -e

# ------------------------
# LOGGING
# ------------------------
LOG_FILE="$HOME/setup.log"
exec > >(tee -a "$LOG_FILE") 2>&1
echo "[$(date)] Starting Mac dev environment setup..."

# ------------------------
# 1. Prerequisites
# ------------------------

install_xcode_cli() {
  echo "📦 Checking Xcode CLI tools..."
  xcode-select --install 2>/dev/null || echo "✅ Xcode CLI tools already installed."
}

install_homebrew() {
  echo "🍺 Checking Homebrew..."
  if ! command -v brew &> /dev/null; then
    echo "📥 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    echo "✅ Homebrew already installed."
  fi
}

install_homebrew_packages() {
  echo "🔄 Updating Homebrew..."
  brew update
  echo "📦 Installing packages from Brewfile..."
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  if [[ ! -f "$SCRIPT_DIR/Brewfile" ]]; then
    echo "❌ Brewfile not found at $SCRIPT_DIR/Brewfile"
    exit 1
  fi
  brew bundle --file="$SCRIPT_DIR/Brewfile"
}

# ------------------------
# 2. Git & SSH Key Setup
# ------------------------

configure_git() {
  echo "📝 Configuring Git user..."
  git config --global user.name "Your Name"
  git config --global user.email "your_email@example.com"
}

generate_ssh_key() {
  if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    echo "🔐 Generating SSH key..."
    ssh-keygen -t ed25519 -C "your_email@example.com" -f "$HOME/.ssh/id_ed25519" -N ""
    eval "$(ssh-agent -s)"
    mkdir -p ~/.ssh
    cat <<EOF >> ~/.ssh/config

Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
EOF
    ssh-add --apple-use-keychain ~/.ssh/id_ed25519
    echo "🔑 SSH key generated. Public key:"
    cat ~/.ssh/id_ed25519.pub

    echo "🌐 Uploading SSH key to GitHub..."
    echo "Enter GitHub personal access token (or leave blank to skip):"
    read -s GH_TOKEN
    if [ -n "$GH_TOKEN" ]; then
      echo "Enter a name for this SSH key (e.g., MacBook-Pro):"
      read KEY_TITLE
      PUB_KEY=$(cat ~/.ssh/id_ed25519.pub)
      curl -s -H "Authorization: token $GH_TOKEN"            --data "{"title":"$KEY_TITLE","key":"$PUB_KEY"}"            https://api.github.com/user/keys
      echo "✅ SSH key uploaded to GitHub."
    else
      echo "⏩ Skipped GitHub upload (no token provided)."
    fi
  else
    echo "✅ SSH key already exists."
  fi
}

# ------------------------
# 3. Shell and Dotfiles
# ------------------------

install_oh_my_zsh() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "🎀 Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  else
    echo "✅ Oh My Zsh already installed."
  fi
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
  echo "🔗 Linking dotfiles from GitHub..."
  DOTFILES_REPO="https://github.com/yourusername/dotfiles.git"
  git clone "$DOTFILES_REPO" "$HOME/dotfiles" || echo "⚠️ Skipping clone (already exists?)"
  ln -sf "$HOME/dotfiles/.gitconfig" "$HOME/.gitconfig"
  ln -sf "$HOME/dotfiles/.zshrc" "$HOME/.zshrc"
}

# ------------------------
# 4. Development Environments
# ------------------------

setup_node() {
  mkdir -p ~/.nvm
  echo "📥 Installing latest LTS version of Node.js..."
  source ~/.zshrc
  nvm install --lts
}

setup_python() {
  if command -v pyenv &>/dev/null; then
    echo "🐍 Installing Python 3.12.2 with pyenv..."
    pyenv install 3.12.2 || echo "⚠️ Python 3.12.2 may already be installed."
    pyenv global 3.12.2
    echo "✅ Python setup complete."
  else
    echo "⚠️ pyenv not found. Skipping Python setup."
  fi
}

# ------------------------
# 5. GUI App Installations
# ------------------------

download_apps() {
  echo "🌐 Downloading apps to ~/Downloads..."
  curl -L -o ~/Downloads/pycharm.dmg "https://download.jetbrains.com/python/pycharm-professional.dmg"
  curl -L -o ~/Downloads/ChatGPT.dmg "https://chat.openai.com/apps/mac/latest"
  curl -L -o ~/Downloads/GoogleChrome.dmg "https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg"
  echo "📥 Download link for Windsurf (please install manually): https://windsurf.dev"
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
