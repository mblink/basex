# basex-webapp

This is a slightly tweaked version of the BaseX Database Admin web app. The current version is based on [BaseX v10.6](https://github.com/BaseXdb/basex/tree/10.6/basex-api/src/main/webapp).

## Setup

To setup the repository for development and updating (more details below), run the following commands:

```bash
git clone git@github.com:mblink/basex-webapp.git
cd basex-webapp
git remote add upstream git@github.com:BaseXdb/basex
```

## Updating

To update to a newer version of BaseX, find the branch named after the current latest version, e.g. `basex-10.6`,
then run the following commands:

```bash
# Checkout the upstream-master branch and pull to make sure it's up to date
git checkout upstream-master
git pull

# Fetch from the upstream remote
git fetch upstream
git fetch upstream --tags

# Reset the current state to the desired version tag
git reset --hard <x.y.z>

# Push the upstream-master branch to origin
git push origin upstream-master

# Split the webapp subtree and apply the commits to the upstream-webapp branch
git subtree split --prefix basex-api/src/main/webapp --onto upstream-webapp -b upstream-webapp

# Checkout and push the upstream-webapp branch to origin
git checkout upstream-webapp
git push origin upstream-webapp

# Replace with version from the latest branch
currBranch='basex-10.6'
# Replace with the version you're updating to
updBranch='basex-10.7'

git checkout "$currBranch"
git pull origin "$currBranch"
# Checkout a new branch with the updated version
git checkout -b "$updBranch"
# Merge upstream-webapp, resolve conflicts and commit if necessary
git merge upstream-webapp
# Push the new branch to origin
git push origin "$updBranch"
```
