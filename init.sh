#!/bin/bash

# Check if source dotfiles directory exists
if [ ! -d ~/.dotfiles ]; then
  echo "Error: ~/.dotfiles directory not found"
  exit 1
fi

# Create ~/.config directory if it doesn't exist
mkdir -p ~/.config

# Home directory symlinks
[ ! -e ~/.zshrc ] && [ -f ~/.dotfiles/.zshrc ] && ln -s ~/.dotfiles/.zshrc ~/
[ ! -e ~/.vimrc ] && [ -f ~/.dotfiles/.vimrc ] && ln -s ~/.dotfiles/.vimrc ~/
[ ! -e ~/.tmux.conf ] && [ -f ~/.dotfiles/.tmux.conf ] && ln -s ~/.dotfiles/.tmux.conf ~/

# Config directory symlinks
[ ! -e ~/.config/starship.toml ] && [ -f ~/.dotfiles/starship.toml ] && ln -s ~/.dotfiles/starship.toml ~/.config/
[ ! -e ~/.config/aerospace.toml ] && [ -f ~/.dotfiles/.aerospace.toml ] && ln -s ~/.dotfiles/.aerospace.toml ~/.config/
[ ! -e ~/.config/nvim ] && [ -d ~/.dotfiles/nvim ] && ln -s ~/.dotfiles/nvim ~/.config/nvim
