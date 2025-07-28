# Mac Dev Environment Install Wizard 🚀

This repository contains a fully automated setup script to configure a new macOS machine for development.

## 📦 What's Included

- ✅ Xcode Command Line Tools
- ✅ Homebrew install + package management via `Brewfile`
- ✅ Oh My Zsh + custom `.zshrc`
- ✅ Node.js via NVM
- ✅ SSH key generation + optional GitHub upload
- ✅ Git global config setup (interactive)
- ✅ GUI app installers for:
  - Google Chrome (set as default browser)
  - PyCharm
  - ChatGPT
- ✅ Windsurf install link (manual)
- ✅ Setup logging to `~/setup.log`

---

## ⚙️ How to Use

### 1. Clone this repo

```bash
git clone git@github.com:mkernsNCR/mac-dev-environment-install-wizard.git
cd mac-dev-environment-install-wizard
```

### 2. Run the setup script

```bash
chmod +x setup.sh
./setup.sh
```

## 📋 Setup Script Examples

### Basic Setup (Interactive)
The script will guide you through each step with confirmations:

```bash
./setup.sh
```

**Example Output:**
```
🚀 Starting optimized Mac dev environment setup...

📋 Step 1: Installing Prerequisites...
📦 Checking Xcode CLI tools...
✅ Xcode CLI tools already installed.
🍺 Checking Homebrew...
✅ Homebrew already installed.
✅ Prerequisites complete!

📋 Step 2: Setting up Git & SSH...
📝 Configuring Git user...
🔐 Generating SSH key...
Enter GitHub personal access token (or leave blank to skip):
✅ Git & SSH setup complete!

📋 Step 3: Configuring Shell & Dotfiles...
🎀 Installing Oh My Zsh...
⚙️ Configuring .zshrc...
🔗 Linking dotfiles from GitHub...
✅ Shell & Dotfiles complete!

📋 Step 4: Setting up Development Environments...
📥 Installing latest LTS version of Node.js...
🐍 Installing Python 3.12.2 with pyenv...
✅ Development environments complete!

📋 Step 5: Installing GUI Applications...
🌐 Downloading apps to ~/Downloads...
📦 Installing PyCharm to /Applications...
✅ GUI applications complete!

📋 Step 6: Final System Configuration...
🧭 Setting Google Chrome as the default browser...
✅ System configuration complete!

✅ All done! Setup log saved to ~/setup.log
```

### What You'll Be Asked During Setup:
- **Git Configuration**: Your name and email for commits
- **SSH Key**: Whether to upload your new SSH key to GitHub (requires personal access token)
- **GitHub Token**: Optional - for automatic SSH key upload

### Files Created/Modified:
- `~/.zshrc` - Shell configuration
- `~/.ssh/id_ed25519` - SSH private key
- `~/.ssh/id_ed25519.pub` - SSH public key
- `~/.gitconfig` - Git global configuration
- `~/dotfiles/` - Cloned dotfiles repository
- `~/setup.log` - Complete setup log

---

## 🧨 Teardown / Reset

If you ever want to completely undo what `setup.sh` did and start fresh, run:

```bash
chmod +x teardown.sh
./teardown.sh
```

## 🗑️ Teardown Script Examples

### Interactive Teardown (Recommended)
The script will ask for confirmation at each step:

```bash
./teardown.sh
```

**Example Output:**
```
🧨 Starting optimized teardown of Mac dev environment setup...
📝 Logging to ~/teardown.log
⚠️  WARNING: This will remove development tools and configurations!

Available options:
  • Press Enter to continue with confirmations
  • Ctrl+C to cancel
  • Run with --force to skip all confirmations
Press Enter to continue...

📋 Step 1: Cleaning up System Configuration...
❓ Reset default browser and system settings? [y/N]: y
ℹ️  Default browser settings left unchanged (manual reset required)

📋 Step 2: Removing GUI Applications...
❓ Remove GUI apps (PyCharm, Chrome, ChatGPT)? [y/N]: y
🗑  Removed: PyCharm Professional
🗑  Removed: Google Chrome
🗑  Removed: ChatGPT
✅ GUI applications removal complete!

📋 Step 3: Removing Development Environments...
❓ Remove Python and pyenv? [y/N]: y
🐍 Uninstalling Python versions...
🗑  Removed: pyenv directory
❓ Remove Node.js and NVM? [y/N]: y
🗑  Removed: NVM directory
✅ Development environments removal complete!

📋 Step 4: Cleaning up Shell and Dotfiles...
❓ Remove dotfiles and shell customizations? [y/N]: y
🗑  Removed: Oh My Zsh
🗑  Removed: dotfiles repository
🔄 Reset .zshrc to system default
✅ Shell and dotfiles cleanup complete!

📋 Step 5: Cleaning up Git and SSH...
❓ Remove SSH keys and Git configuration? [y/N]: y
🔐 Removing SSH keys...
🗑  SSH keys and config cleaned.
❓ Remove Git global configuration? (WARNING: This affects all repos) [y/N]: y
🗑  Git configuration removed.
✅ Git and SSH cleanup complete!

📋 Step 6: Removing Homebrew and Packages...
❓ Remove ALL Homebrew packages and Homebrew itself? (WARNING: This removes ALL brew packages) [y/N]: y
📦 Cleaning up Homebrew packages...
🍺 Uninstalling Homebrew...
✅ Homebrew removal complete!

🧹 Final cleanup...

✅ Teardown complete! Summary:
📝 Full log saved to: ~/teardown.log
🔄 You may need to:
   • Restart your terminal for shell changes to take effect
   • Manually reset default browser if desired
   • Remove any remaining personal files in ~/Downloads

🚀 Your system has been restored to a clean state!
```

### Force Mode (No Confirmations)
For automated teardown without any prompts:

```bash
./teardown.sh --force
```

**Example Output:**
```
🧨 Starting optimized teardown of Mac dev environment setup...
⚠️  FORCE MODE ENABLED - No confirmations will be asked!
📝 Logging to ~/teardown.log
⚠️  WARNING: This will remove development tools and configurations!

📋 Step 1: Cleaning up System Configuration...
🔄 Auto-confirming: Reset default browser and system settings?

📋 Step 2: Removing GUI Applications...
🔄 Auto-confirming: Remove GUI apps (PyCharm, Chrome, ChatGPT)?
🗑  Removed: PyCharm Professional
🗑  Removed: Google Chrome
...
```

### What Gets Removed:
- **GUI Applications**: PyCharm, Chrome, ChatGPT + their installers
- **Development Tools**: Node.js, NVM, Python, pyenv
- **Shell Customizations**: Oh My Zsh, custom .zshrc
- **Dotfiles**: Cloned dotfiles repository
- **SSH Keys**: Generated ed25519 keys and SSH config
- **Git Configuration**: Global user name/email settings
- **Homebrew**: All packages and Homebrew itself
- **Log Files**: `~/teardown.log` with complete removal log

### Safety Features:
- **Backup Protection**: Existing .zshrc files are backed up before removal
- **Selective Removal**: Each category can be skipped individually
- **Process Cleanup**: Running Node processes are terminated safely
- **Error Handling**: Script continues even if some items are already removed

> ⚠️ **Warning**: The teardown script will remove ALL Homebrew packages, not just those installed by the setup script. Use with caution if you have other Homebrew packages you want to keep.

---

## 🗂 Dotfiles

This setup assumes you have a dotfiles repo with a `.zshrc` and `.gitconfig`. The script automatically links them from:
```
https://github.com/yourusername/dotfiles.git
```
Update the script with your actual repo URL.

---