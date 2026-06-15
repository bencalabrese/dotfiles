#!/usr/bin/env bash

install_packages_linux() {
  sudo apt-get update -qq

  if ! command -v zsh >/dev/null 2>&1; then
    sudo apt-get install -y zsh
    sudo chsh "$(id -un)" --shell "$(which zsh)"
  fi

  if ! command -v fzf >/dev/null 2>&1; then
    sudo apt-get install -y fzf
  fi

  if ! command -v bat >/dev/null 2>&1; then
    sudo apt-get install -y bat
  fi

  if ! command -v tmux >/dev/null 2>&1; then
    sudo apt-get install -y tmux
  fi

  if ! command -v figlet >/dev/null 2>&1; then
    sudo apt-get install -y figlet
  fi

  if ! command -v gh >/dev/null 2>&1; then
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
    sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
    sudo apt-get update -qq
    sudo apt-get install -y gh
  fi

  if ! command -v starship >/dev/null 2>&1; then
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
  fi

  if ! command -v nvm >/dev/null 2>&1 && ! command -v node >/dev/null 2>&1; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/HEAD/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    nvm install --lts
  fi
}

install_gui_linux() {
  echo "WARNING: headed Linux GUI installs are not yet supported." >&2
  return 0
}
