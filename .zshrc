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
plugins=(git)

# Runs my oh-my-zsh
source $ZSH/oh-my-zsh.sh

# uses lsd instead of ls
alias ls="lsd"

# uses open instead of xdg-open
alias open="xdg-open"

# reinit database and make rabbit dir
function fullclean() {
    make down
    sudo rm -rf .docker-storage
    sudo mkdir -p .docker-storage/rabbitmq/logs/; sudo chmod -R 777 .docker-storage/rabbitmq/logs/
    sudo mkdir -p .docker-storage/rabbitmq/data/; sudo chmod -R 777 .docker-storage/rabbitmq/data/
    sudo mkdir -p .docker-storage/rabbitmq/mnesia/; sudo chmod -R 777 .docker-storage/rabbitmq/mnesia/
    sudo mkdir -p .docker-storage/mysql/; sudo chmod -R 777 .docker-storage/rabbitmq/logs/
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
export PATH="/home/$USER/.cargo/bin:$PATH"

# adds golang to path
export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

# adds spotifyd to path
alias spotifyd="/home/$USER/Documents/pers/spotifyd/target/release/spotifyd"

# makes spt launch spotifyd if not running
alias spt="/home/$USER/.scripts/launchspt"

# programatically switch day/night mode
export day() {
    gsettings set org.gnome.desktop.interface gtk-theme "Yaru-light"
}

export night() {
    gsettings set org.gnome.desktop.interface gtk-theme "Yaru-dark"
}

source <(/snap/starship/2049/bin/starship init zsh --print-full-init)

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# add vasion CLI to path
export PATH="$HOME/.vasion/bin:$PATH"


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
