# Overview

git-update helps you keep your local branch rebased on top of your master branch. It is expected that most commits will be cherry-picked
into the master branch so that each of your long-lived local branches (on different computers) do not stray too far from the master.

# Dependencies
[tig](http://jonas.nitro.dk/tig/) is used to allow easy cherry-picking from the command-line. Install via the web page or by compiling.

# Installation
Add your git-update directory to your $PATH. For example: ```echo "export PATH=$HOME/git-update-dir/:$PATH"```

# Usage

Two operations are supported, getting updates and pushing updates.

## First run

The first time you run git-update it will prompt you for the name of the local branch. This is the branch that you will be rebasing on top
of master.

## Getting updates

```sh
git update get
```

## Pushing updates
```sh
git update push
```

TODO
====
* Maybe include a script to copy git-update.sh into the git-exec directory (like git flow)
* Move the initial setup into a ```git update init``` command
