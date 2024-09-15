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
