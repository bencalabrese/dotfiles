#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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

main() {
  local editor editor_user_dir editor_cli

  editor="${1:-}"
  if [ -z "$editor" ]; then
    editor="$(choose_editor)"
  fi

  editor_user_dir="$(get_editor_user_dir "$editor")" || {
    echo "Unsupported OS or editor for export: $editor" >&2
    exit 1
  }

  if [ ! -d "$editor_user_dir" ]; then
    echo "Editor user directory not found: $editor_user_dir" >&2
    exit 1
  fi

  editor_cli="$(get_editor_cli "$editor")" || {
    echo "Unknown editor: $editor" >&2
    exit 1
  }

  if ! command -v "$editor_cli" >/dev/null 2>&1; then
    echo "Editor CLI not found: $editor_cli" >&2
    exit 1
  fi

  mkdir -p "$EDITOR_EXPORT_DIR/snippets"

  if [ -f "$editor_user_dir/settings.json" ]; then
    cp "$editor_user_dir/settings.json" "$EDITOR_EXPORT_DIR/settings.json"
  fi

  if [ -f "$editor_user_dir/keybindings.json" ]; then
    cp "$editor_user_dir/keybindings.json" "$EDITOR_EXPORT_DIR/keybindings.json"
  fi

  printf '%s\n' "$editor" > "$EDITOR_EXPORT_DIR/source-editor.txt"

  rm -f "$EDITOR_EXPORT_DIR/extensions.txt"
  "$editor_cli" --list-extensions | sort > "$EDITOR_EXPORT_DIR/extensions.txt"

  rm -rf "$EDITOR_EXPORT_DIR/snippets"
  mkdir -p "$EDITOR_EXPORT_DIR/snippets"
  if [ -d "$editor_user_dir/snippets" ]; then
    cp -R "$editor_user_dir/snippets/." "$EDITOR_EXPORT_DIR/snippets/"
  fi

  echo "Exported editor config from $editor to $EDITOR_EXPORT_DIR"
}

main "$@"
