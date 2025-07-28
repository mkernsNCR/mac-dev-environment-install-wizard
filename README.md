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

> 🔐 Your SSH key will be generated if one doesn’t exist, and you'll be prompted to upload it to GitHub.

> 📝 You'll also be prompted to enter your Git name, email, and preferred editor.

---

## 🗂 Dotfiles

This setup assumes you have a dotfiles repo with a `.zshrc` and `.gitconfig`. The script automatically links them from:
```
https://github.com/yourusername/dotfiles.git
```
Update the script with your actual repo URL.

---

## 🙏 Credits

Script generated with the help of OpenAI’s ChatGPT and lots of coffee ☕.
