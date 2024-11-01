#!/bin/bash

if [ ! -e ~/.zshrc ]
then
    ln -s ~/.dotfiles/.zshrc ~/
fi

if [ ! -e ~/.vimrc ]
then
    ln -s ~/.dotfiles/.vimrc ~/
fi

if [ ! -e ~/.tmux.conf ]
then
    ln -s ~/.dotfiles/.tmux.conf ~/
fi

if [ ! -e ~/.config/starship.toml ]
then
    ln -s ~/.dotfiles/starship.toml ~/.config/
fi

if [ ! -e ~/.aerospace.toml ]
then
    ln -s ~/.dotfiles/.aerospace.toml ~/.config/
fi
