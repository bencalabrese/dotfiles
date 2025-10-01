#!/usr/bin/env bash

DOTFILES_DIR="$HOME/dotfiles"

record_extensions() {
  cursor --list-extensions > "$DOTFILES_DIR/cursor_extensions.txt"
}

install_extensions() {
  while IFS= read -r extension; do
    cursor --install-extension "$extension"
  done < "$DOTFILES_DIR/cursor_extensions.txt"
}
