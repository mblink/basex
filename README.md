# basex-webapp

This is a slightly tweaked version of the BaseX Database Admin web app. The current version is based on [BaseX v9.7](https://github.com/BaseXdb/basex/9.7/master/basex-api/src/main/webapp).

## Setup

To setup the repository for development and updating (more details below), run the following commands:

```bash
git clone git@github.com:mblink/basex-webapp.git
cd basex-webapp
git remote add upstream git@github.com:BaseXdb/basex
```

## Updating

To update to a newer version of BaseX, run the following commands:

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

# Checkout the webapp branch, merge upstream-webapp, and push to origin
git checkout webapp
git merge upstream-webapp # resolve conflicts and commit if necessary
git push origin webapp
```
