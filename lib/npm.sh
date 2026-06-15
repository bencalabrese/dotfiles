#!/usr/bin/env bash

_load_nvm_for_npm() {
  local nvm_script
  for nvm_script in \
    "${NVM_DIR:-$HOME/.nvm}/nvm.sh" \
    /opt/homebrew/opt/nvm/nvm.sh \
    /usr/local/opt/nvm/nvm.sh; do
    if [[ -s "$nvm_script" ]]; then
      # shellcheck disable=SC1090
      . "$nvm_script"
      return 0
    fi
  done
}

install_global_npm_packages() {
  local package_file="$DOTFILES_DIR/npm/global-packages.txt"
  [[ -f "$package_file" ]] || return 0

  _load_nvm_for_npm

  if ! command -v npm >/dev/null 2>&1; then
    if command -v nvm >/dev/null 2>&1; then
      nvm install --lts
    fi
  fi

  if ! command -v npm >/dev/null 2>&1; then
    echo "Error: npm is unavailable; cannot install global npm packages from $package_file." >&2
    return 1
  fi

  local packages=()
  local package
  while IFS= read -r package || [[ -n "$package" ]]; do
    [[ "$package" =~ ^[[:space:]]*$ ]] && continue
    [[ "$package" =~ ^[[:space:]]*# ]] && continue
    packages+=("$package")
  done < "$package_file"

  [[ ${#packages[@]} -gt 0 ]] || return 0

  echo "==> Installing global npm packages..."
  npm install --global "${packages[@]}"
}
