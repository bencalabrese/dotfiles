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

# Prompt
eval "$(starship init zsh)"

# Your common helpers (guarded)
source "$DOTFILES_DIR/zsh/.aliases.sh"
source "$DOTFILES_DIR/zsh/.functions.sh"

# ----- per-machine/work overrides -----
# Put anything machine- or job-specific in ~/.zshrc.local (untracked)
[ -f "$HOME/.zshrc.local" ] && . "$HOME/.zshrc.local"
