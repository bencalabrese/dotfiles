#!/usr/bin/env bash

_bootstrap_homebrew() {
  if ! command -v brew >/dev/null 2>&1; then
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  local brew_bin
  for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [[ -x "$candidate" ]]; then
      brew_bin="$candidate"
      break
    fi
  done

  if [[ -z "${brew_bin:-}" ]]; then
    echo "Error: Homebrew binary not found after install." >&2
    exit 1
  fi

  eval "$("$brew_bin" shellenv)"
}

install_packages_mac() {
  _bootstrap_homebrew
  echo "==> Updating Homebrew..."
  brew update

  for formula in nvm starship fzf gh tmux bat; do
    if command -v "$formula" >/dev/null 2>&1; then
      echo "==> $formula already installed, skipping."
    else
      brew install "$formula"
    fi
  done

  export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

  if ! command -v node >/dev/null 2>&1; then
    nvm install --lts
  fi
}

install_gui_mac() {
  local casks_to_install=()
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
      app_name=$(brew info --cask "$cask" 2>/dev/null | grep " (App)" | sed 's/ (App)//')
      if [ -n "$app_name" ] && [ -d "/Applications/$app_name" ]; then
        echo "==> $cask already installed (not via Homebrew), skipping."
      else
        casks_to_install+=("$cask")
      fi
    fi
  done

  [ ${#casks_to_install[@]} -gt 0 ] && brew install --cask "${casks_to_install[@]}"
}
