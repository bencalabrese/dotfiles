# ----- zsh base -----
autoload -U compinit; compinit -i -C

DOTFILES_DIR="$(cd "$(dirname "${(%):-%N}")/.." && pwd)"
export STARSHIP_CONFIG="$DOTFILES_DIR/starship/starship.toml"

DOTFILES_OS="$(uname -s)"
if [[ "$DOTFILES_OS" == "Darwin" ]] || [[ -n "${DISPLAY:-}" ]] || [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
  DOTFILES_HEADED=true
else
  DOTFILES_HEADED=false
fi
export DOTFILES_OS DOTFILES_HEADED

# PATH
if [[ "$DOTFILES_OS" == "Darwin" ]]; then
  export PATH="$HOME/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/local/sbin:$PATH"
  # Homebrew env (no-op if not installed)
  if command -v brew >/dev/null 2>&1; then
    eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || true)"
  fi
else
  export PATH="$HOME/bin:/usr/local/bin:/usr/local/sbin:$PATH"
fi

# nvm
export NVM_DIR="$HOME/.nvm"
if [[ "$DOTFILES_OS" == "Darwin" ]]; then
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
else
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
fi

export BAT_THEME="TwoDark"

# Ona workspace name + stable color/art derived from name
source "$DOTFILES_DIR/tmux/arts.zsh"
if [[ "${IS_ON_ONA:-}" == "true" ]]; then
  _ona_name="$(ona environment get --field=Name 2>/dev/null)"
  export ONA_WORKSPACE_NAME="${_ona_name:-(unnamed)}"
  unset _ona_name

  _ona_hash=$(printf '%s' "$ONA_WORKSPACE_NAME" | cksum | cut -d' ' -f1)
  _tmux_pick_theme "$_ona_hash"
  export ONA_WORKSPACE_COLOR="$TMUX_COLOR"
  unset _ona_hash
fi

# Warm page cache for the cwd's git repo once per devbox boot, so Starship
# doesn't time out on cold git status in large repos. /tmp is tmpfs, so the
# marker dies with the box.
if _repo_root=$(git rev-parse --show-toplevel 2>/dev/null); then
  _warm_marker="/tmp/.git_warm${_repo_root//\//_}"
  if [[ ! -f "$_warm_marker" ]]; then
    git -C "$_repo_root" status --porcelain >/dev/null 2>&1
    : > "$_warm_marker"
  fi
  unset _warm_marker _repo_root
fi

# Prompt
eval "$(starship init zsh)"

# Your common helpers (guarded)
source "$DOTFILES_DIR/zsh/.aliases.sh"
source "$DOTFILES_DIR/zsh/.functions.sh"

# Auto-attach to (or create) a tmux session on Ona
if [[ "${IS_ON_ONA:-}" == "true" ]] && [[ -z "${TMUX:-}" ]] && command -v tmux >/dev/null 2>&1; then
  exec tmux new-session -A -s main \
    -e "ONA_WORKSPACE_NAME=${ONA_WORKSPACE_NAME:-}" \
    -e "ONA_WORKSPACE_COLOR=${ONA_WORKSPACE_COLOR:-}" \
    -e "TMUX_COLOR=${TMUX_COLOR:-}" \
    -e "TMUX_ART_0=${TMUX_ART_0:-}" \
    -e "TMUX_ART_1=${TMUX_ART_1:-}" \
    -e "TMUX_ART_2=${TMUX_ART_2:-}"
fi

# ----- per-machine/work overrides -----
# Put anything machine- or job-specific in ~/.zshrc.local (untracked)
[ -f "$HOME/.zshrc.local" ] && . "$HOME/.zshrc.local"
