read -r -p "Check that the terminal app has 'Privacy and Security > App Management' permissions first. Press any key to continue..."

# Install Homebrew itself
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

# Make sure we can also get fonts
brew tap homebrew/cask-fonts

# First install stow so we can get our various configs in place. We want these established before we
# install applications that might write to them.
brew install stow

# Set up our symlinks
# This overwrites the symlinks dir in this repository with existing files on the machine if they're
# already present. `git restore .` then undoes the overwrite but maintains the symlink.
stow --adopt symlinks
git restore .

# Finally, use Homebrew to install other utils
brew install \
  iterm2 \
  nvm \
  starship \
  raycast \
  elgato-stream-deck \
  elgato-control-center \
  logi-options-plus \
  mutedeck \
  visual-studio-code \
  hiddenbar \
  displaylink \
  font-meslo-lg-nerd-font

touch ~/.machine_specific_zshrc

# This is a repeat of what's happening in our RC but we need to run it so that we can actually use
# nvm below and sourcing the whole RC here has been problematic.
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh" # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" # This loads nvm bash_completion

nvm install node