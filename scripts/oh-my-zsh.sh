# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

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
plugins=(
    git
    zsh-autosuggestions
)

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

# Runs my oh-my-zsh
source $ZSH/oh-my-zsh.sh
