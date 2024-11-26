# fast git add, commit, and push
function fgit() {
    git add -A
    # Escape single quotes and join all arguments with spaces
    local msg=$(printf "%s" "$*" | sed "s/'/'\\\''/g")
    git commit -m "$msg"
    git push
}

# fast git merge
function fmerge() {
    local cbranch=$(git branch | grep \* | cut -d ' ' -f2)
    if [ $# -eq 0 ]; then
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

# create a draft PR for the current branch
function fpr() {
    local cbranch=$(git branch --show-current)
    if [ -z "$1" ]; then
        echo "Usage: fdraftpr <PR name>"
        return 1
    fi
    gh pr create --title "$1" --draft --base main --head "$cbranch"
}

# git diff with untracked files
function fgd() {
    # Add untracked files first
    git add -N .
    # Run git diff
    git diff
}
