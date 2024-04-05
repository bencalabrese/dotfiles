# Manually set preferences
# Caps Lock -> Control for all keyboards
# Reverse scrolling direction

# Dark mode
osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to true'

# iTerm2 preferences
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "~/iterm2_preferences"
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
