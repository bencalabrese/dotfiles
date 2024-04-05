# Manual install list
#
# DisplayLink
# Divvy
# MuteDeck
# Stream Deck
# Control Center
# LogiOptions+
# HiddenBar
# VS Code
#   - Login to sync settings

# Install Homebrew itself
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# First install stow so we can get our various configs in place. We want these established before we
# install applications that might write to them.
brew install stow

# Set up our symlinks
# This overwrites the symlinks dir in this repository with existing files on the machine if they're
# already present. `git restore .` then undoes the overwrite but maintains the symlink.
stow --adopt symlinks
git restore .


# MesloLG Nerd Font
wget -P ~/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.0/Meslo.zip \
  && cd ~/.local/share/fonts \
  && unzip Meslo.zip \
  && rm Meslo.zip \
  && fc-cache -fv

# Finally, use Homebrew to install other utils
brew install \
  nvm \
  starship

touch ~/.additional_machine_specific_zshrc
source ~/.zshrc

nvm install node