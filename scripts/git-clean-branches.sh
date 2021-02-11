#!/usr/bin/env sh
# Source: https://www.centare.com/blog/cleanup-git-branches/
if !(git rev-parse --is-inside-work-tree); then
    echo "Not inside a git repository, aborting"
    exit 0
fi

git remote prune origin

git branch -r --format "%(refname:lstrip=3)" > remotes
git branch --format "%(refname:lstrip=2)" > locals
cat locals | grep -xv -f remotes > branchesToDelete

# -w checks word counts to ignore blank lines
if [ $(wc -w < branchesToDelete) -gt 0 ];
then
    echo "$(wc -l < branchesToDelete) branches without matching remote found, outputting to editor"
    echo "Waiting for editor to close"
    code branchesToDelete -w
    for branch in `cat branchesToDelete`;
    do
        git branch -D $branch
    done
else
    echo "There are no branches to cleanup.";
fi

rm branchesToDelete remotes locals
