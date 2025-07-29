
#!/bin/bash

set -e

LOG_FILE="$HOME/setup.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "[`date`] Starting Mac dev environment setup..."
echo "📦 Starting optimized Mac dev environment setup..."

# 1. Installing prerequisites
echo "🧰 Step 1: Installing Prerequisites..."
xcode-select --install 2>/dev/null || echo "✅ Xcode CLI tools already installed."

# 2. Install Homebrew
if ! command -v brew &>/dev/null; then
  echo "🍺 Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "✅ Homebrew already installed."
fi

echo "🔄 Updating Homebrew..."
brew update

# 3. Install from Brewfile
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ ! -f "$SCRIPT_DIR/Brewfile" ]]; then
  echo "❌ Brewfile not found at $SCRIPT_DIR/Brewfile"
  exit 1
fi
brew bundle --file="$SCRIPT_DIR/Brewfile"

# 4. Install GUI apps (manual downloads)
echo "🖥️ Installing GUI apps..."
install_app() {
  local url="$1"
  local name="$2"
  echo "⬇️ Downloading $name..."
  curl -L "$url" -o "$HOME/Downloads/$name.dmg"
}
install_app "https://download.jetbrains.com/python/pycharm-professional-2024.1.2.dmg" "PyCharm"
install_app "https://windsurf.app/download" "Windsurf"
install_app "https://iterm2.com/downloads/stable/latest" "iTerm2"
install_app "https://chat.openai.com/apps/chatgpt-macos/download" "ChatGPT"
install_app "https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg" "Google Chrome"

# 5. Git config
echo "🔧 Setting up Git..."
read -p "Name: " name
read -p "Email: " email
read -p "Editor (default: nano): " editor
editor=${editor:-nano}
git config --global user.name "$name"
git config --global user.email "$email"
git config --global core.editor "$editor"
echo "✅ Dotfiles installed and Git configured!"

# 6. Oh My Zsh and dotfiles
echo "🔁 Installing Oh My Zsh and linking dotfiles..."
export RUNZSH=no
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
[ -d "$HOME/dotfiles" ] || git clone git@github.com:mkernsNCR/my-dotfiles.git "$HOME/dotfiles"
ln -sf "$HOME/dotfiles/.zshrc" "$HOME/.zshrc"

# 7. Python via pyenv
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
setup_python

echo "✅ All done! Your Mac dev environment is ready."
