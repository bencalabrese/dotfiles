# shellcheck shell=bash

install_all() {
  if [[ "$DOTFILES_OS" == "Darwin" ]]; then
    # shellcheck source=lib/mac.sh disable=SC1091
    source "$DOTFILES_DIR/lib/mac.sh"
    install_packages_mac
  else
    # shellcheck source=lib/linux.sh disable=SC1091
    source "$DOTFILES_DIR/lib/linux.sh"
    install_packages_linux
  fi

  # shellcheck source=lib/npm.sh disable=SC1091
  source "$DOTFILES_DIR/lib/npm.sh"
  install_global_npm_packages

  if [[ "$DOTFILES_HEADED" == "true" ]]; then
    if [[ "$DOTFILES_OS" == "Darwin" ]]; then
      install_gui_mac
    else
      install_gui_linux
    fi
  fi
}
