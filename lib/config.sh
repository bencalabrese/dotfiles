# Markers delimiting the dotfiles-managed block inside a generated config file.
DOTFILES_BEGIN_MARKER="# >>> dotfiles_setup_begin >>>"
DOTFILES_END_MARKER="# <<< dotfiles_setup_end <<<"

# Idempotently write the dotfiles-managed block into $1, reading the block body
# from stdin. An existing block is replaced where it sits, otherwise the block is
# appended. Creates the file if needed.
#
# NOTE: the block body (stdin) must not contain literal '$' characters. sd treats
# '$1'/'${name}' in the replacement as capture-group references, so a future caller
# passing a '$' would need to escape it as '$$'. Current callers pass none.
write_managed_block() {
  local file="$1"
  local body
  body="$(cat)"
  mkdir -p "$(dirname "$file")"
  touch "$file"

  local block="$DOTFILES_BEGIN_MARKER"$'\n'"$body"$'\n'"$DOTFILES_END_MARKER"
  if grep -Fq "$DOTFILES_BEGIN_MARKER" "$file"; then
    sd "(?s)$DOTFILES_BEGIN_MARKER.*$DOTFILES_END_MARKER" "$block" "$file"
  else
    printf '%s\n' "$block" >> "$file"
  fi
}

configure_zsh() {
  local zshrc="$HOME/.zshrc"

  write_managed_block "$zshrc" <<EOF
if [ -f "$DOTFILES_DIR/zsh/.zshrc" ]; then
  source "$DOTFILES_DIR/zsh/.zshrc"
fi
EOF
  echo "wrote dotfiles source block to $zshrc (DOTFILES_DIR=$DOTFILES_DIR)"

  if [[ "$DOTFILES_OS" == "Linux" ]]; then
    local bashrc="$HOME/.bashrc"
    touch "$bashrc"
    if ! grep -Fq 'exec zsh' "$bashrc"; then
      cat >> "$bashrc" <<'EOF'

# Switch to zsh for interactive shells (chsh is ignored by Ona SSH sessions)
if [[ $- == *i* ]] && command -v zsh >/dev/null 2>&1; then
  exec zsh
fi
EOF
      echo "Appended zsh exec block to $bashrc"
    fi
  fi
}

configure_git() {
  local home_gitconfig="$HOME/.gitconfig"
  local home_local="$HOME/.gitconfig.local"
  local home_work="$HOME/.gitconfig.work"

  # Remove broken symlinks left over from a previous stow-based setup
  if [ -L "$home_gitconfig" ] && [ ! -e "$home_gitconfig" ]; then
    rm "$home_gitconfig"
  fi
  if [ -L "$home_local" ] && [ ! -e "$home_local" ]; then
    rm "$home_local"
  fi
  if [ -L "$home_work" ] && [ ! -e "$home_work" ]; then
    rm "$home_work"
  fi

  write_managed_block "$home_gitconfig" <<EOF
# Base config tracked in your repo:
[include]
  path = $DOTFILES_DIR/git/.gitconfig.common

# Personal identity via remote-based matching (also tracked in your repo).
[includeIf "hasconfig:remote.*.url:git@github.com:bencalabrese/**"]
  path = $DOTFILES_DIR/git/.gitconfig.personal
[includeIf "hasconfig:remote.*.url:https://github.com/bencalabrese/**"]
  path = $DOTFILES_DIR/git/.gitconfig.personal

# Per-machine overrides (untracked):
[include]
  path = ~/.gitconfig.local
EOF
  echo "wrote managed git includes to $home_gitconfig (DOTFILES_DIR=$DOTFILES_DIR)"

  if [ ! -f "$home_local" ]; then
    cat > "$home_local" <<'EOF'
# Machine-specific overrides & secrets — DO NOT TRACK.

# Work context via remote URL (uncomment & set your org):
# [includeIf "hasconfig:remote.*.url:git@github.com:<your-company-org>/**"]
#   path = ~/.gitconfig.work
# [includeIf "hasconfig:remote.*.url:https://github.com/<your-company-org>/**"]
#   path = ~/.gitconfig.work
EOF
    echo "created $home_local"
  else
    echo "$home_local exists — leaving as-is"
  fi

  if [ ! -f "$home_work" ]; then
    cat > "$home_work" <<'EOF'
# ~/.gitconfig.work
# Work identity — DO NOT TRACK. Uncomment and edit to enable.

# [user]
#   name = Ben Calabrese
#   email = you@company.com

# [commit]
#   gpgsign = true

# [gpg]
#   format = ssh
EOF
    echo "created $home_work template"
  else
    echo "$home_work exists — leaving as-is"
  fi
}

configure_ghostty_terminfo() {
  if infocmp xterm-ghostty &>/dev/null 2>&1; then
    return 0
  fi

  local terminfo_src="$DOTFILES_DIR/ghostty/ghostty.terminfo"
  if [ ! -f "$terminfo_src" ]; then
    echo "warning: $terminfo_src not found — skipping terminfo install" >&2
    return 0
  fi

  tic -x "$terminfo_src"
  echo "installed xterm-ghostty terminfo"
}

configure_ghostty_config() {
  [[ "$DOTFILES_HEADED" != "true" ]] && return 0

  if [ "$DOTFILES_OS" = "Darwin" ]; then
    local ghostty_config_dir="$HOME/Library/Application Support/com.mitchellh.ghostty"
  else
    local ghostty_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty"
  fi

  mkdir -p "$ghostty_config_dir"
  cat > "$ghostty_config_dir/config" <<EOF
config-file = $DOTFILES_DIR/ghostty/config
EOF
  echo "wrote Ghostty config shim to $ghostty_config_dir/config"
}

configure_vscode() {
  [[ "$DOTFILES_HEADED" != "true" ]] && return 0

  if [ "$DOTFILES_OS" = "Darwin" ]; then
    local vscode_user_dir="$HOME/Library/Application Support/Code/User"
  else
    local vscode_user_dir="${XDG_CONFIG_HOME:-$HOME/.config}/Code/User"
  fi

  local editor_export_dir="$DOTFILES_DIR/editors/shared"
  if [ ! -d "$editor_export_dir" ]; then
    return 0
  fi

  mkdir -p "$vscode_user_dir/snippets"

  if [ -f "$editor_export_dir/settings.json" ]; then
    cp "$editor_export_dir/settings.json" "$vscode_user_dir/settings.json"
    echo "imported VS Code settings"
  fi

  if [ -f "$editor_export_dir/keybindings.json" ]; then
    cp "$editor_export_dir/keybindings.json" "$vscode_user_dir/keybindings.json"
    echo "imported VS Code keybindings"
  fi

  if [ -d "$editor_export_dir/snippets" ]; then
    cp -R "$editor_export_dir/snippets/." "$vscode_user_dir/snippets/"
    echo "imported VS Code snippets"
  fi

  if [ -f "$editor_export_dir/extensions.txt" ] && command -v code >/dev/null 2>&1; then
    while IFS= read -r extension; do
      [ -n "$extension" ] || continue
      code --install-extension "$extension"
    done < "$editor_export_dir/extensions.txt"
    echo "installed VS Code extensions from shared export"
  fi
}

configure_tmux() {
  local tmux_conf="$HOME/.tmux.conf"

  write_managed_block "$tmux_conf" <<EOF
source-file $DOTFILES_DIR/tmux/tmux.conf
EOF
  echo "wrote tmux source line to $tmux_conf (DOTFILES_DIR=$DOTFILES_DIR)"
}

configure_macos_defaults() {
  [[ "$DOTFILES_OS" != "Darwin" || "$DOTFILES_HEADED" != "true" ]] && return 0

  osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to true'
}
