# zioxide for cd
alias cd=z

# lazy docker
alias lzd=lazydocker

# open file in zed
alias zed="open -a /Applications/Zed.app -n"

# uses lsd instead of ls
alias ls="lsd"
# uses eza for tree structure
alias la="eza -T -L 3"

# use lg instead of lazygit
alias lg=lazygit

# ls aliases
alias l="ls"
alias ll="ls -la"

# uses bat instead of cat
alias cat="bat"

alias pip="pip3"

# curl with jq
curlj() {
  curl "$@" | jq .
}

alias code=cursor

# git aliases
alias gd=fgd

alias rl="source ~/.zshrc"

alias vim="nvim"
