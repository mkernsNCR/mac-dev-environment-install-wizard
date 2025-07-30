#!/bin/bash

set -e

# ------------------------
# TEARDOWN LOGGING
# ------------------------
LOG_FILE="$HOME/teardown.log"
exec > >(tee -a "$LOG_FILE") 2>&1


confirm_teardown() {
  echo "⚠️  This will uninstall development tools, remove dotfiles, and undo setup changes."
  read -p "Are you sure you want to continue? (y/N): " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "❌ Teardown canceled."
    exit 1
  fi
}

remove_homebrew() {
  if command -v brew &>/dev/null; then
    echo "🧹 Uninstalling Homebrew packages..."
    brew bundle --file=~/Brewfile --force cleanup || echo "⚠️ Brew cleanup failed"
    echo "🧹 Uninstalling Homebrew itself..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)" || echo "⚠️ Failed to uninstall Homebrew"
  else
    echo "✅ Homebrew already removed."
  fi
}

remove_dotfiles() {
  echo "🗑 Removing dotfiles and links..."
  rm -rf ~/dotfiles
  rm -f ~/.gitconfig ~/.zshrc ~/.zprofile
}

remove_ssh_keys() {
  echo "🗑 Removing SSH keys..."
  rm -f ~/.ssh/id_ed25519 ~/.ssh/id_ed25519.pub
  sed -i '' '/IdentityFile ~/.ssh\/id_ed25519/d' ~/.ssh/config 2>/dev/null || true
}

remove_apps() {
  echo "🗑 Removing GUI apps (if found)..."
  sudo rm -rf /Applications/PyCharm.app
  sudo rm -rf /Applications/ChatGPT.app
  sudo rm -rf /Applications/Google\ Chrome.app
}

reset_shell() {
  echo "🔄 Resetting shell to default..."
  chsh -s /bin/bash
}

cleanup_zsh() {
  echo "🧹 Removing Oh My Zsh..."
  rm -rf ~/.oh-my-zsh
}

cleanup_python_node() {
  echo "🧹 Removing Python and Node.js environments..."
  rm -rf ~/.nvm ~/.node* ~/.npm ~/.pyenv
}

final_message() {
  echo "✅ Teardown complete. Log saved to $LOG_FILE"
  echo "🧼 Please restart your terminal session."
}

# ------------------------
# EXECUTION FLOW
# ------------------------
confirm_teardown
remove_homebrew
remove_dotfiles
remove_ssh_keys
remove_apps
reset_shell
cleanup_zsh
cleanup_python_node
final_message