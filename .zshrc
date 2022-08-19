# Path to your oh-my-zsh installation.
export ZSH="/home/$USER/.oh-my-zsh"

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

# shortcut for apt install
alias install="sudo apt install"

# reinit database and make rabbit dir
function fullclean() {
    make down
    sudo rm -rf .docker-storage
    sudo mkdir -p .docker-storage/rabbitmq/logs/; sudo chmod -R 777 .docker-storage/rabbitmq/logs/
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
#
# starts pref-gw and pref-ui on specific branch, default develop 
function runpref() {
    cd ~/vasion/pref-gw
    make down
    sudo make up-d
    cd ~/vasion/pref-ui
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

# fast update vscode
function update-code() {
    wget 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' -O /tmp/code_latest_amd64.deb
    sudo dpkg -i /tmp/code_latest_amd64.deb
}

# adds cargo to path
export PATH="/home/$USER/.cargo/bin:$PATH"

# adds golang to path
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH

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

# ~/.zshrc
eval "$(starship init zsh)"

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# add vasion CLI to path
export PATH="$HOME/.vasion/bin:$PATH"

