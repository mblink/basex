#!/usr/bin/env bash

set -eo pipefail

if [ -z "$1" ] || [ -z "$2" ]; then
  echo 'Usage: update-version.sh <old-version> <new-version>'
  exit 1
fi

oldVersion="$1"
oldBranch="webapp-$oldVersion"

newVersion="$2"
newBranch="webapp-$newVersion"

log() {
  echo -e "\n[$(date +"%Y-%m-%dT%H:%M:%S")] $1\n"
}

log "Checking out and pulling upstream-master"
git checkout upstream-master
git pull --ff-only origin upstream-master

log "Fetching changes from the upstream repo"
git fetch upstream
git fetch upstream --tags

log "Resetting to upstream version $newVersion"
git reset --hard "$newVersion"


read -p "Push changes to upstream-master branch? (y/n) " -n 1 -r
echo ""

if [ "$REPLY" = 'y' ]; then
  git push origin upstream-master
else
  log "Aborting due to reply '$REPLY'"
  exit 1
fi

log "Splitting webapp subtree onto upstream-webapp"
git subtree split --prefix basex-api/src/main/webapp --onto upstream-webapp -b upstream-webapp

read -p "Push changes to upstream-webapp branch? (y/n) " -n 1 -r
echo ""

if [ "$REPLY" = 'y' ]; then
  git checkout upstream-webapp
  git push origin upstream-webapp
else
  log "Aborting due to reply '$REPLY'"
  exit 1
fi

log "Checking out and pulling $oldBranch"
git checkout "$oldBranch"
git pull --ff-only origin "$oldBranch"

log "Creating new branch $newBranch"
git checkout -b "$newBranch"

set +e

log "Merging upstream-webapp into $newBranch"
git merge --no-commit upstream-webapp

log '

To complete the update:

  1. Resolve any conflicts that were a result of merging upstream-webapp into '$newBranch'
  2. Run `git commit` to complete the merge
  3. Run `git push origin '$newBranch'`
'
