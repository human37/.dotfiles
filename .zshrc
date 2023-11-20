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
#    zsh-autosuggestions
)

#ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="#DCDCDC"


# Runs my oh-my-zsh
source $ZSH/oh-my-zsh.sh

# uses lsd instead of ls
alias ls="lsd"

# reinit database and make rabbit dir
function fullclean() {
    make down
    sudo rm -rf .docker-storage
    sudo mkdir -p .docker-storage/rabbitmq/logs/; sudo chmod -R 777 .docker-storage/rabbitmq/logs/
    sudo mkdir -p .docker-storage/rabbitmq/data/; sudo chmod -R 777 .docker-storage/rabbitmq/data/
    sudo mkdir -p .docker-storage/rabbitmq/mnesia/; sudo chmod -R 777 .docker-storage/rabbitmq/mnesia/
    sudo mkdir -p .docker-storage/redis-data/; sudo chmod -R 777 .docker-storage/redis-data/
    sudo mkdir -p .docker-storage/storage_efs/; sudo chmod -R 777 .docker-storage/storage_efs/
    sudo mkdir -p .docker-storage/mysql/; sudo chmod -R 777 .docker-storage/mysql/
    sudo mkdir -p .docker-storage/dev/; sudo chmod -R 777 .docker-storage/dev/
    sudo mkdir -p .docker-storage/db-identity/; sudo chmod -R 777 .docker-storage/db-identity/
    sudo mkdir -p .docker-storage/air/; sudo chmod -R 777 .docker-storage/air/
    sudo mkdir -p .docker-storage/camunda/; sudo chmod -R 777 .docker-storage/camunda/
    sudo mkdir -p .docker-storage/minio/config/; sudo chmod -R 777 .docker-storage/minio/config/
    sudo mkdir -p .docker-storage/minio/data/; sudo chmod -R 777 .docker-storage/minio/data/
    sudo mkdir -p .docker-storage/mongo/db/; sudo chmod -R 777 .docker-storage/mongo/db/
    sudo mkdir -p .docker-storage/api-server/certs/; sudo chmod -R 777 .docker-storage/api-server/certs/
    sudo mkdir -p .docker-storage/formio-pdf-server/certs/; sudo chmod -R 777 .docker-storage/formio-pdf-server/certs/
    sudo mkdir -p .docker-storage/formio-api-server/certs/; sudo chmod -R 777 .docker-storage/formio-api-server/certs/
    sudo chmod -R g+rw "$HOME/.docker"
} 

# starts admin-gw and admin-ui on specific branch, default develop 
function runadmin() {
    cd ~/vasion/admin-gw
    make down
    sudo make up-d
    cd ~/vasion/admin-ui
    if [ $# -eq 0 ]
    then
        git checkout develop
    else
        git checkout $1
    fi
    git pull
    npm run serve
}

# starts pref-gw and pref-ui on specific branch, default develop 
function runpref() {
    cd ~/vasion/preferences-gw
    make down
    sudo make up-d
    cd ~/vasion/preferences-ui
    git pull
    if [ $# -eq 0 ]
    then
        git checkout develop
    else
        git checkout $1
    fi
    git pull
    npm run serve
}

# fast git
function fgit() {
    git add -A 
    git commit -m "$1"
    git push
}

# fast git merge
function fmerge() {
    local cbranch=`git branch |grep \* | cut -d ' ' -f2`
    if [ $# -eq 0 ]
    then
        git checkout develop
        git pull
        git checkout $cbranch
        git merge develop
    else
        git checkout $1
        git pull
        git checkout $cbranch
        git merge $1
    fi
}

# fast update vscode
function update-code() {
    wget 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' -O /tmp/code_latest_amd64.deb
    sudo dpkg -i /tmp/code_latest_amd64.deb
}

# adds cargo to path
source "$HOME/.cargo/env"

# adds code to path
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

# adds golang to path
export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

# adds spotifyd to path
alias spotifyd="/home/$USER/Documents/pers/spotifyd/target/release/spotifyd"

# makes spt launch spotifyd if not running
alias spt="/home/$USER/.scripts/launchspt"

eval $(/opt/homebrew/bin/brew shellenv)

eval "$(starship init zsh)"

export PATH="$PATH:GOPRIVATE="github.com/PrinterLogic/*""

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

. "/opt/homebrew/opt/asdf/libexec/asdf.sh"

alias vim='/Users/ammon.taylor/.local/bin/lvim'
export EDITOR='nvim'

# loads secret env vars
source "$HOME/.env.sh"

# changes nvims default directory
export PATH=~/.npm-global/bin:$PATH


