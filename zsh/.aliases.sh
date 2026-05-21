#!/usr/bin/env bash

alias ..="cd .."
alias acl="claude --permission-mode auto"
# Linux GNU ls colorizes by default; match macOS behavior
[[ "$DOTFILES_OS" == "Linux" ]] && alias ls='ls --color=never'
