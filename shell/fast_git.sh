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

# fast git checkout
function fco() {
    git checkout $@
    git pull
}

# fast git checkout main
function fmain() {
    git stash
    git stash clear
    git checkout main
    git pull
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

function fbranches() {
    local base_default=""
    if git show-ref --verify --quiet refs/heads/main; then
        base_default="main"
    elif git show-ref --verify --quiet refs/heads/master; then
        base_default="master"
    fi

    git for-each-ref refs/heads \
  --sort=-committerdate \
  --format='%(committeremail)	%(refname:short)	%(committerdate:format:%Y-%m-%d %H:%M:%S)	%(committername)	%(upstream:short)' \
| while IFS=$'\t' read -r email branch date author upstream; do
        if [ "$branch" = "main" ]; then
            continue
        fi
        if [ "${email:l}" = "<ammonx9@gmail.com>" ]; then
            printf "%s\t%s\t%s\n" "$branch" "$date" "$author"
            continue
        fi

        base="${upstream:-$base_default}"
        if [ -n "$base" ] && git rev-parse --verify --quiet "$base" >/dev/null; then
            if [ "$(git rev-list --count "$branch" --not "$base")" -eq 0 ]; then
                printf "%s\t%s\t%s\n" "$branch" "$date" "$author"
            fi
        fi
    done \
| column -t -s $'\t' \
| bat --plain
}

# git diff utility 
function fgd() {
    git add -N .

    if [ $# -eq 2 ]; then
        if [[ "$1" == "dev" && "$2" == "prod" ]] || [[ "$1" == "prod" && "$2" == "dev" ]]; then
            echo "diffing dev -> prod"
            git tag -d dev prod > /dev/null 2>&1 || true
            git fetch --tags --force > /dev/null 2>&1
            git diff prod dev
            return 0
        fi
    elif [ $# -eq 1 ]; then
        if [ "$1" = "dev" ]; then
            echo "diffing local branch -> dev"
            git tag -d dev > /dev/null 2>&1 || true
            git fetch --tags --force > /dev/null 2>&1
            git diff dev
            return 0
        elif [ "$1" = "prod" ]; then
            echo "diffing local branch -> prod"
            git tag -d prod > /dev/null 2>&1 || true
            git fetch --tags --force > /dev/null 2>&1
            git diff prod
            return 0
        fi
    fi

    git diff
}
