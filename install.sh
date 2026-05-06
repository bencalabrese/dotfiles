#!/usr/bin/env bash
set -euo pipefail

read -r -p "Check 'System Settings → Privacy & Security → App Management' permissions for Terminal. Press Enter to continue..."

# --- Homebrew ---------------------------------------------------------------
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

BREW_BIN="$(command -v brew || true)"
if [ -z "${BREW_BIN:-}" ]; then
  for candidate in /opt/homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew /usr/local/bin/brew; do
    if [ -x "$candidate" ]; then
      BREW_BIN="$candidate"
      break
    fi
  done
fi

if [ -z "${BREW_BIN:-}" ]; then
  echo "Error: Homebrew was not found after installation." >&2
  exit 1
fi

eval "$("$BREW_BIN" shellenv)"

echo "==> Updating Homebrew..."
"$BREW_BIN" update

# --- Packages ---------------------------------------------------------------
"$BREW_BIN" install nvm starship fzf gh

casks_to_install=()
for cask in \
  raycast \
  elgato-stream-deck \
  elgato-control-center \
  logi-options-plus \
  mutedeck \
  visual-studio-code \
  hiddenbar \
  ghostty \
  font-meslo-lg-nerd-font \
  polypane; do
  if brew list --cask "$cask" &>/dev/null; then
    echo "==> $cask already installed via Homebrew, skipping."
  else
    app_name=$("$BREW_BIN" info --cask "$cask" 2>/dev/null | grep " (App)" | sed 's/ (App)//')
    if [ -n "$app_name" ] && [ -d "/Applications/$app_name" ]; then
      echo "==> $cask already installed (not via Homebrew), skipping."
    else
      casks_to_install+=("$cask")
    fi
  fi
done

[ ${#casks_to_install[@]} -gt 0 ] && "$BREW_BIN" install --cask "${casks_to_install[@]}"

# --- Minimal nvm bootstrap so we can use it right away ----------------------
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# Install a Node version (choose your policy: latest/LTS/specific)
nvm install --lts

echo "✅ Install complete. Run ./bootstrap.sh next to wire zsh + gitconfig shims."
