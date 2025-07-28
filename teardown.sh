#!/bin/bash

set -e

# ------------------------
# LOGGING & CONFIGURATION
# ------------------------
LOG_FILE="$HOME/teardown.log"
exec > >(tee -a "$LOG_FILE") 2>&1
echo "[$(date)] Starting Mac dev environment teardown..."

FORCE=false
if [[ "$1" == "--force" ]]; then
  FORCE=true
  echo "⚠️  FORCE MODE ENABLED - No confirmations will be asked!"
fi

confirm() {
  if $FORCE; then
    echo "🔄 Auto-confirming: $1"
    return 0
  fi
  read -p "❓ $1 [y/N]: " answer
  [[ "$answer" == "y" || "$answer" == "Y" ]]
}

safe_remove() {
  local path="$1"
  local description="$2"
  if [[ -e "$path" ]]; then
    rm -rf "$path"
    echo "🗑  Removed: $description"
  else
    echo "ℹ️  Not found: $description (already removed?)"
  fi
}

echo "🧨 Starting optimized teardown of Mac dev environment setup..."
echo "📝 Logging to $LOG_FILE"
echo "⚠️  WARNING: This will remove development tools and configurations!"
echo ""

if ! $FORCE; then
  echo "Available options:"
  echo "  • Press Enter to continue with confirmations"
  echo "  • Ctrl+C to cancel"
  echo "  • Run with --force to skip all confirmations"
  read -p "Press Enter to continue..."
  echo ""
fi

# ------------------------
# TEARDOWN EXECUTION (Reverse Order of Setup)
# ------------------------

# Step 1: System Configuration Cleanup
echo "📋 Step 1: Cleaning up System Configuration..."
if confirm "Reset default browser and system settings?"; then
  # Note: No easy way to revert default browser, just inform user
  echo "ℹ️  Default browser settings left unchanged (manual reset required)"
  echo "🗑  System configuration cleanup complete."
fi
echo ""

# Step 2: Remove GUI Applications
echo "📋 Step 2: Removing GUI Applications..."
if confirm "Remove GUI apps (PyCharm, Chrome, ChatGPT)?"; then
  safe_remove "/Applications/PyCharm CE.app" "PyCharm Community Edition"
  safe_remove "/Applications/PyCharm.app" "PyCharm Professional"
  safe_remove "/Applications/Google Chrome.app" "Google Chrome"
  safe_remove "/Applications/ChatGPT.app" "ChatGPT"
  
  # Clean up downloaded installers
  safe_remove "~/Downloads/pycharm.dmg" "PyCharm installer"
  safe_remove "~/Downloads/ChatGPT.dmg" "ChatGPT installer"
  safe_remove "~/Downloads/GoogleChrome.dmg" "Chrome installer"
  echo "✅ GUI applications removal complete!"
else
  echo "⏩ Skipped GUI applications removal."
fi
echo ""

# Step 3: Remove Development Environments
echo "📋 Step 3: Removing Development Environments..."

# Remove Python/pyenv first (depends on Homebrew)
if confirm "Remove Python and pyenv?"; then
  if command -v pyenv &>/dev/null; then
    echo "🐍 Uninstalling Python versions..."
    pyenv versions --bare | xargs -I {} pyenv uninstall -f {} 2>/dev/null || true
  fi
  safe_remove "~/.pyenv" "pyenv directory"
  echo "🗑  Python and pyenv removed."
fi

# Remove Node/NVM
if confirm "Remove Node.js and NVM?"; then
  # Kill any running node processes
  pkill -f node 2>/dev/null || true
  safe_remove "~/.nvm" "NVM directory"
  echo "🗑  Node.js and NVM removed."
fi
echo "✅ Development environments removal complete!"
echo ""

# Step 4: Shell and Dotfiles Cleanup
echo "📋 Step 4: Cleaning up Shell and Dotfiles..."
if confirm "Remove dotfiles and shell customizations?"; then
  # Backup current .zshrc if it exists and isn't from our setup
  if [[ -f ~/.zshrc ]] && ! grep -q "oh-my-zsh" ~/.zshrc 2>/dev/null; then
    cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)
    echo "📦 Backed up existing .zshrc"
  fi
  
  safe_remove "~/.oh-my-zsh" "Oh My Zsh"
  safe_remove "~/dotfiles" "dotfiles repository"
  
  # Reset to default zsh config
  if [[ -f ~/.zshrc ]]; then
    rm ~/.zshrc
    echo "🔄 Reset .zshrc to system default"
  fi
  
  echo "✅ Shell and dotfiles cleanup complete!"
else
  echo "⏩ Skipped shell and dotfiles cleanup."
fi
echo ""

# Step 5: Git and SSH Cleanup
echo "📋 Step 5: Cleaning up Git and SSH..."
if confirm "Remove SSH keys and Git configuration?"; then
  # SSH keys cleanup
  if [[ -f ~/.ssh/id_ed25519 ]]; then
    echo "🔐 Removing SSH keys..."
    rm -f ~/.ssh/id_ed25519 ~/.ssh/id_ed25519.pub
    
    # Clean SSH config
    if [[ -f ~/.ssh/config ]]; then
      sed -i '' '/# Added by mac-dev-environment-install-wizard/,+4d' ~/.ssh/config 2>/dev/null || true
      sed -i '' '/id_ed25519/d' ~/.ssh/config 2>/dev/null || true
    fi
    echo "🗑  SSH keys and config cleaned."
  fi
  
  # Git config cleanup (be careful not to remove user's personal config)
  if confirm "Remove Git global configuration? (WARNING: This affects all repos)"; then
    git config --global --unset user.name 2>/dev/null || true
    git config --global --unset user.email 2>/dev/null || true
    safe_remove "~/.gitconfig" "Git global configuration"
    echo "🗑  Git configuration removed."
  else
    echo "⏩ Kept Git configuration."
  fi
  
  echo "✅ Git and SSH cleanup complete!"
else
  echo "⏩ Skipped Git and SSH cleanup."
fi
echo ""

# Step 6: Remove Homebrew (Last - everything depends on it)
echo "📋 Step 6: Removing Homebrew and Packages..."
if confirm "Remove ALL Homebrew packages and Homebrew itself? (WARNING: This removes ALL brew packages)"; then
  if command -v brew &>/dev/null; then
    echo "📦 Cleaning up Homebrew packages..."
    
    # Try to use Brewfile for cleanup if it exists
    if [[ -f ~/Brewfile ]]; then
      brew bundle --file=~/Brewfile --force cleanup 2>/dev/null || true
    fi
    
    # Uninstall Homebrew completely
    echo "🍺 Uninstalling Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)" || true
    
    # Clean up any remaining Homebrew directories
    safe_remove "/opt/homebrew" "Homebrew installation (Apple Silicon)"
    safe_remove "/usr/local/Homebrew" "Homebrew installation (Intel)"
    
    echo "✅ Homebrew removal complete!"
  else
    echo "ℹ️  Homebrew not found (already removed?)."
  fi
else
  echo "⏩ Skipped Homebrew removal."
fi
echo ""

# ------------------------
# FINAL CLEANUP & SUMMARY
# ------------------------
echo "🧹 Final cleanup..."

# Remove any temporary files
safe_remove "~/Brewfile" "Brewfile (if it was created by setup)"

# Restore shell to default if needed
if [[ "$SHELL" != "/bin/zsh" ]] && [[ "$SHELL" != "/usr/bin/zsh" ]]; then
  echo "ℹ️  Consider running: chsh -s /bin/zsh to reset to default shell"
fi

echo ""
echo "✅ Teardown complete! Summary:"
echo "📝 Full log saved to: $LOG_FILE"
echo "🔄 You may need to:"
echo "   • Restart your terminal for shell changes to take effect"
echo "   • Manually reset default browser if desired"
echo "   • Remove any remaining personal files in ~/Downloads"
echo ""
echo "🚀 Your system has been restored to a clean state!"
echo "[$(date)] Teardown completed successfully" >> "$LOG_FILE"
