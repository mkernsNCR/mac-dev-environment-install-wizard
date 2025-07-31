# Mac Dev Environment Install Wizard 🚀

A comprehensive, interactive setup script that transforms a fresh macOS machine into a fully-configured development environment. Features robust error handling, input validation, security best practices, and extensive logging.

## 🌟 Key Features

- **🛡️ Production-Ready Security**: Input validation, safe command execution, and secure token handling
- **🔧 Robust Error Handling**: Comprehensive error recovery with automatic cleanup
- **🧪 Dry-Run Mode**: Test the script without making any changes (`--dry-run`)
- **🤝 Interactive Setup**: Smart prompts with validation for user preferences
- **📋 Auto-Configuration**: Creates missing config files with sensible defaults
- **🔄 Idempotent**: Safe to run multiple times - skips already installed components
- **🍎 Apple Silicon Ready**: Full support for M1/M2/M3 Macs
- **📝 Comprehensive Logging**: Complete setup log with timestamps saved to `~/setup.log`
- **🧹 Automatic Cleanup**: Proper cleanup on failure or interruption

## 📦 What's Included

### 🔧 Development Prerequisites
- ✅ **Xcode Command Line Tools** - Essential development tools (git, clang, make)
- ✅ **Homebrew** - Package manager with Apple Silicon support
- ✅ **Auto Brewfile Creation** - Creates essential package list if none exists

### 🐚 Shell & Environment
- ✅ **Oh My Zsh** - Enhanced Zsh framework with useful plugins
- ✅ **Custom .zshrc** - Optimized shell configuration with dev shortcuts
- ✅ **Zsh Plugins** - Auto-suggestions, syntax highlighting, history search
- ✅ **Optional Dotfiles** - Link your personal dotfiles repository

### 🔐 Git & SSH Setup
- ✅ **Interactive Git Config** - Validated prompts for name and email
- ✅ **SSH Key Generation** - ED25519 keys with macOS keychain integration
- ✅ **GitHub Integration** - Secure automatic SSH key upload with token validation
- ✅ **SSH Agent Setup** - Persistent SSH key management with proper timing

### 💻 Development Environments
- ✅ **Node.js via NVM** - Latest LTS with global packages (yarn, typescript, etc.)
- ✅ **Python via pyenv** - Python 3.12.x with essential packages and fallback versions
- ✅ **Version Verification** - Confirms successful installations with error handling

### 🖥️ GUI Applications
- ✅ **Secure Downloads** - Progress bars, integrity checks, and error handling
- ✅ **PyCharm Professional** - Full-featured Python IDE
- ✅ **Google Chrome** - Set as default browser
- ✅ **ChatGPT Desktop** - AI assistant app
- ✅ **Safe Installation** - Proper mounting, installation, and cleanup of DMG files
- ✅ **Windsurf & Docker** - Manual installation links provided

---

## ⚙️ How to Use

### 1. Clone this repository

```bash
git clone git@github.com:mkernsNCR/mac-dev-environment-install-wizard.git
cd mac-dev-environment-install-wizard
```

### 2. Run the setup script

```bash
chmod +x setup.sh
./setup.sh
```

### 3. Test first with dry-run mode (recommended)

```bash
./setup.sh --dry-run
```

> **💡 Pro Tip**: Always run with `--dry-run` first to see what the script will do. The script is completely interactive and will guide you through each step. You can safely run it multiple times - it will skip already installed components.

## 🔒 Security Features

### Input Validation
- **Email validation**: Proper regex pattern matching
- **Name validation**: Sanitized input with length limits
- **Token validation**: GitHub token format verification
- **Retry logic**: Maximum 3 attempts with clear error messages

### Safe Execution
- **Command injection protection**: All variables properly quoted
- **Privilege escalation warnings**: Clear notifications before sudo usage
- **Secure token handling**: Tokens cleared from memory after use
- **File permission checks**: Proper SSH key and directory permissions

### Error Handling
- **Comprehensive cleanup**: Automatic cleanup on script failure or interruption
- **Trap handlers**: Proper signal handling for clean exits
- **Timeout protection**: Prevents hanging on long operations
- **Rollback capability**: Can undo partial installations

## 📋 Interactive Setup Process

### What to Expect

The script provides a guided, step-by-step setup experience with enhanced security:

```bash
./setup.sh
```

**Sample Output:**
```
🚀 Starting optimized Mac dev environment setup v2.0.0...

📝 Setup log will be saved to: /Users/username/setup.log
[2024-07-31 09:42:55] [INFO] Starting Mac dev environment setup v2.0.0

📊 Progress: 1/6 - Installing Prerequisites
📦 Checking for Xcode Command Line Tools...
✅ Xcode Command Line Tools already installed.
🍺 Checking for Homebrew installation...
✅ Homebrew already installed.
📋 Found Brewfile at: /path/to/Brewfile
✅ Homebrew packages installation complete!
✅ Prerequisites complete!

📊 Progress: 2/6 - Setting up Git & SSH
📝 Configuring Git user information...
👤 Please enter your full name for Git commits:
> John Doe-Smith
✅ Git user name set to: John Doe-Smith
📧 Please enter your email address for Git commits:
> john.doe@example.com
✅ Git email set to: john.doe@example.com
🔧 Git configuration complete!

🔐 Setting up SSH key for Git authentication...
🔐 Generating new ED25519 SSH key...
✅ SSH key generated successfully!
🔑 Your public key (copy this to GitHub/GitLab):
----------------------------------------
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... john.doe@example.com
----------------------------------------

🌐 Would you like to automatically upload this key to GitHub? (y/n)
> y
🔑 Enter your GitHub personal access token (with 'write:public_key' scope):
💡 Create one at: https://github.com/settings/tokens
> [securely hidden - cleared from memory after use]
📝 Enter a name for this SSH key (e.g., 'MacBook-Pro-2024'):
> MacBook-Pro-2024
✅ SSH key successfully uploaded to GitHub!
✅ Git & SSH setup complete!

📊 Progress: 3/6 - Configuring Shell & Dotfiles
🎀 Setting up Oh My Zsh framework...
📥 Installing Oh My Zsh...
🔌 Installing additional Zsh plugins...
✅ Oh My Zsh installation complete!
⚙️ Configuring .zshrc...
✅ .zshrc configuration complete!
🔗 Linking dotfiles from GitHub...
✅ Dotfiles linking complete!
✅ Shell & Dotfiles complete!

📊 Progress: 4/6 - Setting up Development Environments
🟢 Setting up Node.js development environment...
📥 Installing latest LTS version of Node.js...
✅ Node.js setup complete!
📋 Installed versions:
   Node.js: v20.11.0
   NPM: 10.2.4
📦 Installing useful global NPM packages...
🟢 Node.js development environment ready!

🐍 Setting up Python development environment...
📥 Installing Python 3.12.7 with pyenv...
✅ Python 3.12.7 installed successfully!
🔧 Setting Python 3.12.7 as global default...
✅ Python setup complete!
📋 Installed version: Python 3.12.7
📋 Pip version: pip 24.0
📦 Installing useful Python packages...
🐍 Python development environment ready!
✅ Development environments complete!

📊 Progress: 5/6 - Installing GUI Applications
🌐 Downloading GUI applications to ~/Downloads...
📥 Downloading PyCharm Professional...
✅ PyCharm Professional downloaded successfully
📦 Installing PyCharm Professional...
🔐 Administrator access needed to install PyCharm Professional
   You may be prompted for your password
✅ PyCharm Professional installed successfully
📥 Downloading Google Chrome...
✅ Google Chrome downloaded successfully
📦 Installing Google Chrome...
✅ Google Chrome installed successfully
💡 Additional recommended downloads:
   • Windsurf: https://windsurf.dev
   • Docker Desktop: https://www.docker.com/products/docker-desktop
✅ GUI applications complete!

📊 Progress: 6/6 - Final System Configuration
🧭 Setting Google Chrome as the default browser...
✅ System configuration complete!

[2024-07-31 09:55:42] [INFO] Cleaning up...
[2024-07-31 09:55:42] [INFO] Setup completed successfully!
✅ All done! Setup log saved to /Users/username/setup.log
📎 Note: Windsurf must be installed manually from https://windsurf.dev
🚀 Restart your terminal or run: source ~/.zshrc
```

### 🔍 Dry-Run Mode

Test the script safely without making any changes:

```bash
./setup.sh --dry-run
```

**Dry-Run Output:**
```
🔍 Running in dry-run mode - no changes will be made
🚀 Starting optimized Mac dev environment setup v2.0.0...

📊 Progress: 1/6 - Installing Prerequisites
[2024-07-31 09:42:55] [INFO] Executing: brew update
  [DRY-RUN] Would execute: brew update
[2024-07-31 09:42:55] [INFO] Executing: brew bundle --file="/path/to/Brewfile"
  [DRY-RUN] Would execute: brew bundle --file="/path/to/Brewfile"
...
  [DRY-RUN] SSH public key would be displayed here
  [DRY-RUN] Would download: https://download.jetbrains.com/python/pycharm-professional.dmg -> /Users/username/Downloads/pycharm.dmg
  [DRY-RUN] Would install: /Users/username/Downloads/pycharm.dmg
...
```

### 🤔 Interactive Prompts You'll See

| Prompt | Purpose | Validation | Can Skip? |
|--------|---------|------------|----------|
| **Full Name** | Git commit author | Letters, numbers, spaces, dots, hyphens only (max 100 chars) | ❌ Required |
| **Email Address** | Git commit email & SSH key | Valid email format | ❌ Required |
| **GitHub Token** | Auto-upload SSH key | Token format validation | ✅ Optional |
| **SSH Key Name** | Identify key in GitHub | Any non-empty string | ✅ Optional |

### 📁 Files Created/Modified

| File/Directory | Purpose | Backup Created? | Safety Features |
|----------------|---------|----------------|----------------|
| `~/.zshrc` | Shell configuration | ✅ Yes (`.zshrc.backup`) | Validated content |
| `~/.ssh/id_ed25519` | SSH private key | ❌ N/A | Proper permissions (600) |
| `~/.ssh/id_ed25519.pub` | SSH public key | ❌ N/A | Proper permissions (644) |
| `~/.ssh/config` | SSH client config | ❌ Appends only | Validates existing content |
| `~/.gitconfig` | Git global settings | ✅ Yes (if dotfiles used) | Input validation |
| `~/dotfiles/` | Personal dotfiles repo | ❌ N/A | HTTPS clone for security |
| `~/setup.log` | Complete setup log | ❌ Appends | Timestamped entries |
| `./Brewfile` | Homebrew packages | ❌ Created if missing | Curated package list |

---

## 🚨 Error Handling & Recovery

### Automatic Cleanup
The script automatically cleans up on failure:
- Unmounts any mounted DMG files
- Removes temporary files
- Stops SSH agents if started
- Provides detailed error logs

### Recovery Features
- **Idempotent execution**: Safe to re-run after failures
- **State checking**: Detects existing installations
- **Partial completion**: Continues from where it left off
- **Detailed logging**: Easy to diagnose issues

### Common Issues & Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| **Xcode CLI tools timeout** | Slow download/installation | Script waits up to 5 minutes, then provides manual instructions |
| **Homebrew PATH issues** | Apple Silicon Mac setup | Script automatically detects and configures ARM64 PATH |
| **SSH key generation fails** | Existing keys or permissions | Script checks for existing keys and fixes permissions |
| **GitHub API fails** | Invalid token or network | Script continues without GitHub upload, shows manual instructions |
| **Python installation fails** | Missing dependencies | Script tries fallback to latest available 3.12.x version |
| **DMG mounting fails** | Corrupted download | Script logs error and continues with other applications |

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

### What Gets Removed:
- **GUI Applications**: PyCharm, Chrome, ChatGPT + their installers
- **Development Tools**: Node.js, NVM, Python, pyenv
- **Shell Customizations**: Oh My Zsh, custom .zshrc
- **Dotfiles**: Cloned dotfiles repository
- **SSH Keys**: Generated ed25519 keys and SSH config
- **Git Configuration**: Global user name/email settings
- **Homebrew**: All packages and Homebrew itself
- **Log Files**: Creates `~/teardown.log` with complete removal log

### Safety Features:
- **Backup Protection**: Existing .zshrc files are backed up before removal
- **Selective Removal**: Each category can be skipped individually
- **Process Cleanup**: Running Node processes are terminated safely
- **Error Handling**: Script continues even if some items are already removed

> ⚠️ **Warning**: The teardown script will remove ALL Homebrew packages, not just those installed by the setup script. Use with caution if you have other Homebrew packages you want to keep.

---

## 🗂 Dotfiles Configuration

The script can optionally clone and link your personal dotfiles repository. Update the `DOTFILES_REPO` variable in the script:

```bash
readonly DOTFILES_REPO="https://github.com/yourusername/dotfiles.git"
```

**Supported dotfiles:**
- `.zshrc` - Shell configuration
- `.gitconfig` - Git global settings

The script uses HTTPS cloning for security and automatically handles existing directories.

---

## 🛠️ Customization

### Modifying the Brewfile
Edit the auto-generated `Brewfile` to customize which packages are installed:

```ruby
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

# Add your preferred tools
brew "vim"
brew "tmux"
brew "ripgrep"

# Development applications
cask "visual-studio-code"
cask "iterm2"
cask "docker"

# Add your preferred apps
cask "slack"
cask "figma"
```

### Customizing Python/Node Versions
Modify the version constants at the top of the script:

```bash
readonly PYTHON_VERSION="3.11.8"  # Change to your preferred version
```

### Adding Custom Applications
Extend the `download_apps()` and `install_gui_apps()` functions to include additional applications.

---

## 🔧 Troubleshooting

### Enable Debug Mode
For verbose logging, modify the script to add debug output:

```bash
set -x  # Add after set -euo pipefail for command tracing
```

### Common Log Messages

| Log Level | Example | Meaning |
|-----------|---------|---------|
| `[INFO]` | `Executing: brew update` | Normal operation |
| `[WARN]` | `Failed to clone dotfiles repository, skipping` | Non-critical failure |
| `[ERROR]` | `Maximum attempts reached. Exiting.` | Critical failure requiring attention |

### Getting Help
If you encounter issues:
1. Check `~/setup.log` for detailed error messages
2. Run with `--dry-run` first to identify potential issues
3. Ensure you have admin privileges and internet connectivity
4. Verify your GitHub token has the correct permissions

---

## 📈 Version History

### v2.0.0 (Current)
- **Security**: Complete input validation and sanitization
- **Reliability**: Comprehensive error handling with cleanup
- **Features**: Dry-run mode, progress tracking, enhanced logging
- **Safety**: Automatic cleanup on failure, secure token handling

### v1.0.0 (Legacy)
- Basic functionality with limited error handling
- Hardcoded configurations
- Minimal input validation

---

## 🤝 Contributing

Contributions are welcome! Please:
1. Test changes with `--dry-run` mode
2. Ensure security best practices are maintained
3. Add appropriate logging and error handling
4. Update documentation for new features

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).