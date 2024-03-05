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
    zsh-autosuggestions
)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#808080,bg=none"


# Runs my oh-my-zsh
source $ZSH/oh-my-zsh.sh

# uses lsd instead of ls
alias ls="lsd"

# fast git add, commit, and push
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
        git checkout main
        git pull
        git checkout $cbranch
        git merge main
    else
        git checkout $1
        git pull
        git checkout $cbranch
        git merge $1
    fi
}

# light mode
function mlight() {
    osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to false'
}

# dark mode
function mdark() {
    osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to true'
}

# fast full clean docker
function fcdocker() {
    echo "stopping all docker containers..."
    docker stop $(docker ps -aq) 2>/dev/null
    echo "removing all stopped containers..."
    docker rm $(docker ps -a -q) 2>/dev/null
    echo "removing all dangling images..."
    docker rmi $(docker images -f "dangling=true" -q) 2>/dev/null
    echo "removing all unused images, not just dangling ones..."
    docker image prune -a --force 2>/dev/null
    echo "removing all unused volumes..."
    docker volume prune --force 2>/dev/null
    echo "removing all unused networks..."
    docker network prune --force 2>/dev/null
    echo "docker storage cleaned."
}

# fast docker compose up
function fdocker() {
    local localDir="${PWD}"
    local runningContainers=$(docker ps -q)
    
    if [[ -n "$runningContainers" ]]; then
        echo "stopping running containers..."
        docker stop $(docker ps -a -q)
    fi

    cd /Users/ammon/zonos/DockerResources
    for dir in "$@"; do
        if [[ -d "$dir" ]]; then
            echo "entering directory $dir"
            cd "$dir" || return # change to the directory or exit if it fails
      
            docker compose up -d
            echo "started container $dir"
            cd - || return # return to the previous directory
        else
            echo "directory $dir does not exist."
        fi
    done
    cd $localDir 
}

# Runs a gradle command while adding local.env vars
function grun() {
     # Start with an empty command string
    local command=""
    
    # Ensure the last line is processed by appending a newline to the input
    while IFS='=' read -r key value || [[ -n $key ]]; do
        # Check if key is non-empty to avoid appending uninitialized variables
        if [[ -n $key ]]; then
            # Properly quote the value to handle spaces and special characters
            # Note: Adjusting the syntax to ensure correct handling of special characters
            command+=" $key='$value'"
        fi
    done < "${PWD}/local.env"
    
    # Append the actual command to be executed
    command+=" ./gradlew $@"
    
    # Print the command to be executed (for debugging purposes)
    echo "executing command: $command"
    
    # Use eval to execute the constructed command
    eval "$command"
}

# Runs a gradle command while adding local.env vars in debug mode
function gdebug() {
     # Start with an empty command string
    local command=""
    
    # Ensure the last line is processed by appending a newline to the input
    while IFS='=' read -r key value || [[ -n $key ]]; do
        # Check if key is non-empty to avoid appending uninitialized variables
        if [[ -n $key ]]; then
            # Properly quote the value to handle spaces and special characters
            # Note: Adjusting the syntax to ensure correct handling of special characters
            command+=" $key='$value'"
        fi
    done < "${PWD}/local.env"
    
    # Append the actual command to be executed
    command+=" ./gradlew $@ --debug-jvm"
    
    # Print the command to be executed (for debugging purposes)
    echo "executing command: $command"
    
    # Use eval to execute the constructed command
    eval "$command"
}

eval "$(starship init zsh)"

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

alias zed="open -a /Applications/Zed.app -n"

eval "$(zoxide init zsh)"

alias cd=z

# add asdf
. /opt/homebrew/opt/asdf/libexec/asdf.sh

# set java home
. ~/.asdf/plugins/java/set-java-home.zsh
