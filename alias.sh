# zioxide for cd
alias cd=z

# lazy docker
alias lzd=lazydocker

# open file in zed
alias zed="open -a /Applications/Zed.app -n"

# uses eza instead of ls
alias ls="eza --icons=always --git --group-directories-first"

# use lg instead of lazygit
alias lg=lazygit

# use ghd instead of gh dash
alias ghd="gh dash --config ~/.dotfiles/.gh-dash.yml"

# ls aliases
alias l="ls"
alias ll="ls -la"

alias pip="pip3"

# curl with jq
curlj() {
  curl "$@" | jq .
}

alias pgkill="pkill -f pgcli"

alias code=cursor

# git aliases
alias gd=fgd

alias rl="source ~/.zshrc"

alias vim="nvim"

alias td="gtodo"
