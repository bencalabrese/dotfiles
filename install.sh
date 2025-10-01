#!/usr/bin/env bash
set -euo pipefail

read -r -p "Check 'System Settings → Privacy & Security → App Management' permissions for Terminal. Press Enter to continue..."

# --- Homebrew ---------------------------------------------------------------
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

brew update

# --- Core formulae BEFORE GUI apps (so configs exist first) -----------------
brew install stow nvm starship fzf gh

# --- Lay down ONLY the configs you want with stow ---------------------------
# repo layout assumed:
#   dotfiles/
#     config/starship/.config/starship.toml
#     config/raycast/.config/raycast/...
#     config/ghostty/.config/ghostty/...
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

stow -d "$DOTFILES_DIR/config" -t "$HOME" starship raycast ghostty


# --- GUI apps (pick up configs laid down above) -----------------------------
brew install --cask \
  raycast \
  elgato-stream-deck \
  elgato-control-center \
  logi-options-plus \
  mutedeck \
  visual-studio-code \
  hiddenbar \
  ghostty \
  font-meslo-lg-nerd-font

# --- Minimal nvm bootstrap so we can use it right away ----------------------
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# Install a Node version (choose your policy: latest/LTS/specific)
nvm install --lts

echo "✅ Install complete. Run ./bootstrap.sh next to wire zsh + gitconfig shims."
