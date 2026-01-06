#!/bin/bash

# Check if source dotfiles directory exists
if [ ! -d ~/.dotfiles ]; then
  echo "Error: ~/.dotfiles directory not found"
  exit 1
fi

# Create ~/.config directory if it doesn't exist
mkdir -p ~/.config
mkdir -p ~/.config/aerospace/

# Home directory symlinks
[ ! -e ~/.zshrc ] && [ -f ~/.dotfiles/.zshrc ] && ln -s ~/.dotfiles/.zshrc ~/
[ ! -e ~/.vimrc ] && [ -f ~/.dotfiles/.vimrc ] && ln -s ~/.dotfiles/.vimrc ~/
[ ! -e ~/.tmux.conf ] && [ -f ~/.dotfiles/.tmux.conf ] && ln -s ~/.dotfiles/.tmux.conf ~/
[ ! -e ~/.gitconfig ] && [ -f ~/.dotfiles/.gitconfig ] && ln -s ~/.dotfiles/.gitconfig ~/
[ ! -e ~/.zsh_plugins.txt ] && [ -f ~/.dotfiles/.zsh_plugins.txt ] && ln -s ~/.dotfiles/.zsh_plugins.txt ~/.zsh_plugins.txt

# Config directory symlinks
[ ! -e ~/.config/starship.toml ] && [ -f ~/.dotfiles/starship.toml ] && ln -s ~/.dotfiles/starship.toml ~/.config/
[ ! -e ~/.config/aerospace/aerospace.toml ] && [ -f ~/.dotfiles/aerospace.toml ] && ln -s ~/.dotfiles/aerospace.toml ~/.config/aerospace
[ ! -e ~/.config/nvim ] && [ -d ~/.dotfiles/nvim ] && ln -s ~/.dotfiles/nvim ~/.config/nvim
[ ! -e ~/.config/ghostty ] && [ -d ~/.dotfiles/ghostty ] && ln -s ~/.dotfiles/ghostty ~/.config/ghostty
