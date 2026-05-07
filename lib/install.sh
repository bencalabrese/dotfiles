# shellcheck shell=bash

install_all() {
  if [[ "$DOTFILES_OS" == "Darwin" ]]; then
    # shellcheck source=lib/mac.sh disable=SC1091
    source "$DOTFILES_DIR/lib/mac.sh"
    install_packages_mac
    if [[ "$DOTFILES_HEADED" == "true" ]]; then
      install_gui_mac
    fi
  else
    # shellcheck source=lib/linux.sh disable=SC1091
    source "$DOTFILES_DIR/lib/linux.sh"
    install_packages_linux
    if [[ "$DOTFILES_HEADED" == "true" ]]; then
      install_gui_linux
    fi
  fi
}
