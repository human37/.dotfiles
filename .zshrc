# add asdf
. /opt/homebrew/opt/asdf/libexec/asdf.sh

# add asdf to PATH
export PATH="$HOME/.asdf/shims:$HOME/.asdf/bin:$PATH"

# add scripts to PATH
export PATH="$HOME/bin:$PATH"

# add starship
eval "$(starship init zsh)"

# add zioxide
eval "$(zoxide init zsh)"

# load secrets into env
source ~/.dotfiles/secrets.sh

# add fzf
eval "$(fzf --zsh)"

# source all scripts in the .dotfiles directory
for script in ~/.dotfiles/scripts/*.sh; do
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
