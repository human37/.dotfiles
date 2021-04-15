# Path to your oh-my-zsh installation.
export ZSH="/home/ammont/.oh-my-zsh"

# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="false"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="false"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Which plugins would you like to load?
plugins=(git)

# Runs my oh-my-zsh
source $ZSH/oh-my-zsh.sh

# uses lsd instead of ls
alias ls="lsd"

# uses open instead of xdg-open
alias open="xdg-open"

# shortcut for apt install
alias install="sudo apt install"

# adds cargo to path
export PATH="/home/ammont/.cargo/bin:$PATH"

# adds spotifyd to path
alias spotifyd="/home/ammont/Documents/pers/spotifyd/target/release/spotifyd"

# makes spt launch spotifyd if not running
alias spt="/home/ammont/.scripts/launchspt"

# ~/.zshrc
eval "$(starship init zsh)"
