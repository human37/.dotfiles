# add asdf
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# add scripts to PATH
export PATH="$HOME/bin:$HOME/.dotfiles/scripts:$PATH"

# add go to path
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# add starship
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

# add zioxide
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

# load secrets into env
if [ -f ~/.dotfiles/secrets.sh ]; then
    source ~/.dotfiles/secrets.sh
fi

# add fzf
if command -v fzf >/dev/null 2>&1; then
    eval "$(fzf --zsh)"
fi

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

# load zsh plugins (prefer precompiled, fallback to antidote)
if [ -f "${ZDOTDIR:-$HOME}/.zsh_plugins.zsh" ] && [ -d "$HOME/Library/Caches/antidote" ]; then
    source "${ZDOTDIR:-$HOME}/.zsh_plugins.zsh"
elif [ -f /opt/homebrew/opt/antidote/share/antidote/antidote.zsh ]; then
    source /opt/homebrew/opt/antidote/share/antidote/antidote.zsh
    if [ -f "${ZDOTDIR:-$HOME}/.zsh_plugins.txt" ]; then
        antidote load "${ZDOTDIR:-$HOME}/.zsh_plugins.txt"
    fi
fi

# load in aliases
if [ -f ~/.dotfiles/alias.sh ]; then
    source ~/.dotfiles/alias.sh
fi

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform

# default environment variables
export SYSTEM_THEME="dark"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/ammon/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/ammon/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/ammon/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/ammon/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

# Added by Antigravity
export PATH="/Users/ammontay/.antigravity/antigravity/bin:$PATH"
