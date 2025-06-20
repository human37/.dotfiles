# add asdf
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# add scripts to PATH
export PATH="$HOME/bin:$HOME/.dotfiles/scripts:$PATH"

# add go to path
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# add starship
eval "$(starship init zsh)"

# add zioxide
eval "$(zoxide init zsh)"

# load secrets into env
source ~/.dotfiles/secrets.sh

# add fzf
eval "$(fzf --zsh)"

# source all scripts in the .dotfiles directory
for script in ~/.dotfiles/shell/*.sh; do
    source "$script"
done

# enable vim mode
bindkey -v

# restore ctrl+f binding for autocompletion
bindkey '^F' forward-char

# enable case-insensitive tab completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
autoload -Uz compinit && compinit

# load antidote for plugins
source /opt/homebrew/opt/antidote/share/antidote/antidote.zsh
antidote load ${ZDOTDIR:-$HOME}/.zsh_plugins.txt

# load in aliases
source ~/.dotfiles/alias.sh

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform

# default environment variables
export SYSTEM_THEME="dark"
