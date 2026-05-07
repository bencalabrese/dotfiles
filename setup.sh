#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR

DOTFILES_HEADED=false
for arg in "$@"; do
  [[ "$arg" == "--headed" ]] && DOTFILES_HEADED=true
done
export DOTFILES_HEADED

DOTFILES_OS="$(uname -s)"
export DOTFILES_OS

if [[ "$DOTFILES_HEADED" == "false" ]]; then
  echo "No --headed flag — running headless install. Re-run with --headed for GUI apps."
elif [[ "$DOTFILES_OS" == "Linux" ]]; then
  echo "NOTE: GUI app installs are not yet supported on Linux. Continuing with headless tooling and headed config."
elif [[ "$DOTFILES_OS" == "Darwin" ]]; then
  echo "Reminder: check 'System Settings → Privacy & Security → App Management' permissions for Terminal before casks install."
fi

# SC1091: ShellCheck won't follow dynamic source paths without -x, which the VS Code extension doesn't pass
# shellcheck source=lib/install.sh disable=SC1091
source "$DOTFILES_DIR/lib/install.sh"
install_all

# shellcheck source=lib/config.sh disable=SC1091
source "$DOTFILES_DIR/lib/config.sh"
configure_zsh
configure_git
configure_ghostty_terminfo
configure_ghostty_config
configure_vscode
configure_macos_defaults

echo "Setup complete."
