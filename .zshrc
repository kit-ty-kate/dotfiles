function git_fork {
    local username=$(echo "$1" | cut -d: -f1)
    local branch=$(echo "$1" | cut -d: -f2)
    local repository=$(basename "$(git rev-parse --show-toplevel)")
    if ! (git remote | grep -q "^$username\$"); then
        git remote add "$username" "git@github.com:$username/$repository.git"
    fi
    git fetch "$username" "$branch"
    if ! git switch -c "$branch" "$username/$branch"; then
      git switch "$branch"
      git pull --ff-only "$username" "$branch"
    fi
}

function git_mine {
    local repository=$(basename "$(git rev-parse --show-toplevel)")
    git remote add mine "git@github.com:kit-ty-kate/$repository.git"
}

function git_pr {
    test "$#" -lt 1 && echo 'usage: git_pr <commit msg>' && return
    msg=$1
    shift

    local main_branch=$(git ls-remote --symref origin HEAD | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}')
    local already_existing_branches=$(git branch | grep -E '^((\*?)| ) fix-[0-9]+$' | sed 's/^..//')
    local repository=$(basename "$(git rev-parse --show-toplevel)")
    local i=0
    while echo "$already_existing_branches" | grep -q "^fix-$i\$"; do
        i=$(echo "$i + 1" | bc)
    done
    git fetch origin "$main_branch"
    git add -p $@
    git stash push --keep-index
    git switch -c "fix-$i" "origin/$main_branch"
    git commit -m "$msg"
    git push mine "fix-$i"
    open "https://github.com/kit-ty-kate/$repository/pull/new/fix-$i"
    git stash pop
}

# opam configuration
source /Users/kit_ty_kate/.opam/opam-init/init.zsh
autoload -Uz compinit
compinit
source /Users/kit_ty_kate/.opam/opam-init/complete.zsh
