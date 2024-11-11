# zioxide for cd
alias cd=z

# lazy docker
alias lzd=lazydocker

# open file in zed
alias zed="open -a /Applications/Zed.app -n"

# uses lsd instead of ls
alias ls="lsd"

# uses bat instead of cat
alias cat="bat"

alias pip="pip3"

curlj() {
    curl "$@" | jq .
}

alias code=cursor
