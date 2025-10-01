# ----- zsh base -----
autoload -U compinit; compinit -i -C

DOTFILES_DIR="$HOME/dotfiles"

# PATH (keep both Homebrew Intel/ARM + /usr/local fallbacks)
export PATH="$HOME/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/local/sbin:$PATH"

# Homebrew env (no-op if not installed)
if command -v brew >/dev/null 2>&1; then
  eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || true)"
fi

# nvm (Homebrew layout)
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# Prompt
eval "$(starship init zsh)"

# Your common helpers (guarded)
source "$DOTFILES_DIR/zsh/.aliases.sh"
source "$DOTFILES_DIR/zsh/.functions.sh"

# Just run this on every shell startup to try to keep the list updated
record_extensions

# ----- per-machine/work overrides -----
# Put anything machine- or job-specific in ~/.zshrc.local (untracked)
[ -f "$HOME/.zshrc.local" ] && . "$HOME/.zshrc.local"