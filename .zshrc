# add asdf
. /opt/homebrew/opt/asdf/libexec/asdf.sh

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

# load in aliases
source ~/.dotfiles/alias.sh
