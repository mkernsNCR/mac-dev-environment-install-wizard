
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
echo "📦 Installing packages from Brewfile..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ ! -f "$SCRIPT_DIR/Brewfile" ]]; then
  echo "❌ Brewfile not found at $SCRIPT_DIR/Brewfile"
  exit 1
fi
brew bundle --file="$SCRIPT_DIR/Brewfile"

echo "✅ All done! Your Mac dev environment is ready."
