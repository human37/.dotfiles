# zioxide for cd
alias cd=z

# lazy docker
alias lzd=lazydocker

# open file in zed
alias zed="open -a /Applications/Zed.app -n"

# uses lsd instead of ls
alias ls="lsd"

# ls aliases
alias l="ls"
alias ll="ls -la"

# uses bat instead of cat
alias cat="bat"

alias pip="pip3"

curlj() {
    curl "$@" | jq .
}

alias code=cursor
