#!/bin/bash

set -e

LOG_FILE="$HOME/teardown.log"
exec > >(tee -a "$LOG_FILE") 2>&1

FORCE=false
if [[ "$1" == "--force" ]]; then
  FORCE=true
fi

confirm() {
  if $FORCE; then
    return 0
  fi
  read -p "❓ $1 [y/N]: " answer
  [[ "$answer" == "y" || "$answer" == "Y" ]]
}

echo "🧨 Starting teardown of mac-dev-environment-install-wizard setup..."
echo "Logging to $LOG_FILE"

# 1. Uninstall GUI Apps
if confirm "Remove GUI apps (PyCharm, Chrome, ChatGPT)?"; then
  sudo rm -rf "/Applications/PyCharm.app"
  sudo rm -rf "/Applications/Google Chrome.app"
  sudo rm -rf "/Applications/ChatGPT.app"
  echo "🗑 Removed GUI apps."
fi

# 2. Remove Homebrew packages and uninstall Homebrew
if confirm "Remove Homebrew packages and uninstall Homebrew?"; then
  if command -v brew &>/dev/null; then
    brew bundle --file=~/Brewfile --force cleanup || true
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
    echo "🗑 Homebrew and packages removed."
  fi
fi

# 3. Remove SSH keys
if confirm "Delete SSH keys and clean config?"; then
  rm -f ~/.ssh/id_ed25519 ~/.ssh/id_ed25519.pub
  sed -i '' '/id_ed25519/d' ~/.ssh/config 2>/dev/null || true
  echo "🗑 SSH keys removed."
fi

# 4. Remove Git config and dotfiles
if confirm "Remove Git config and dotfiles?"; then
  rm -f ~/.gitconfig ~/.zshrc
  rm -rf ~/dotfiles
  echo "🗑 Git config and dotfiles removed."
fi

# 5. Remove Oh My Zsh
if confirm "Remove Oh My Zsh?"; then
  rm -rf ~/.oh-my-zsh
  echo "🗑 Oh My Zsh removed."
fi

# 6. Remove NVM and Node
if confirm "Remove Node and NVM?"; then
  rm -rf ~/.nvm
  echo "🗑 Node and NVM removed."
fi

# 7. Remove pyenv and Python
if confirm "Remove pyenv and Python install?"; then
  brew uninstall pyenv || true
  rm -rf ~/.pyenv
  echo "🗑 pyenv and Python removed."
fi

echo "✅ Teardown complete. Log saved to $LOG_FILE"
