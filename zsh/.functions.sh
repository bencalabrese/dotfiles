#!/usr/bin/env bash

DOTFILES_DIR="$(cd "$(dirname "${(%):-%N}")/.." && pwd)"
EDITOR_EXPORT_DIR="$DOTFILES_DIR/editors/shared"

get_editor_user_dir() {
  local editor="$1"

  case "$(uname -s)" in
    Darwin)
      case "$editor" in
        vscode)
          printf '%s\n' "$HOME/Library/Application Support/Code/User"
          ;;
        cursor)
          printf '%s\n' "$HOME/Library/Application Support/Cursor/User"
          ;;
        *)
          return 1
          ;;
      esac
      ;;
    Linux)
      case "$editor" in
        vscode)
          printf '%s\n' "${XDG_CONFIG_HOME:-$HOME/.config}/Code/User"
          ;;
        cursor)
          printf '%s\n' "${XDG_CONFIG_HOME:-$HOME/.config}/Cursor/User"
          ;;
        *)
          return 1
          ;;
      esac
      ;;
    *)
      return 1
      ;;
  esac
}

choose_editor() {
  local choice

  echo "Choose an editor to export from:" >&2
  select choice in "VS Code" "Cursor"; do
    case "$REPLY" in
      1)
        printf '%s\n' "vscode"
        return 0
        ;;
      2)
        printf '%s\n' "cursor"
        return 0
        ;;
      *)
        echo "Please choose 1 or 2." >&2
        ;;
    esac
  done
}

get_editor_cli() {
  local editor="$1"

  case "$editor" in
    vscode)
      printf '%s\n' "code"
      ;;
    cursor)
      printf '%s\n' "cursor"
      ;;
    *)
      return 1
      ;;
  esac
}

install_extensions() {
  local editor editor_cli extension_file extension

  editor="${1:-vscode}"
  editor_cli="$(get_editor_cli "$editor")" || {
    echo "Unknown editor: $editor"
    return 1
  }

  if ! command -v "$editor_cli" >/dev/null 2>&1; then
    echo "Editor CLI not found: $editor_cli"
    return 1
  fi

  extension_file="$EDITOR_EXPORT_DIR/extensions.txt"
  if [ ! -f "$extension_file" ]; then
    echo "No exported extensions file found: $extension_file"
    return 1
  fi

  while IFS= read -r extension; do
    [ -n "$extension" ] || continue
    "$editor_cli" --install-extension "$extension"
  done < "$extension_file"
}

export_editor_config() {
  "$DOTFILES_DIR/export_editor_config.sh" "$@"
}
