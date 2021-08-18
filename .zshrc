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

# follow logs for admin_api_app
function radmin() {
    make up-d
    docker-compose logs -f admin-api
}

# adds cargo to path
export PATH="/home/$USER/.cargo/bin:$PATH"

# adds golang to path
export PATH="$PATH:/usr/local/go/bin"

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
# ~/.zshrc
eval "$(starship init zsh)"
