# Overview

git-update helps you keep your local branch rebased on top of your master branch. It is expected that most commits will be cherry-picked
into the master branch so that each of your long-lived local branches (on different computers) do not stray too far from the master.

# Dependencies
[tig](http://jonas.nitro.dk/tig/) is used to allow easy cherry-picking from the command-line. Install via the web page or by compiling.

# Installation
Add your git-update directory to your $PATH. For example: ```echo "export PATH=$HOME/git-update-dir/:$PATH"```

## First run

The first time you run git-update it will prompt you for the name of the local branch. This is the branch that you will be rebasing on top
of master. It is usually a branch that is specific to that machine, for example work-pc.

# Usage

Two operations are supported, getting updates and pushing updates.

First commit any current changes you have to your computer-specific branch. Next run:

```sh
git update get
```

This will get the latest changes from the master and rebase your computer-specific changes on top of them. Then run:

```sh
git update push
```

This will let you choose which commits on your computer-specific branch actually belong in master.

When tig launches cherry-pick the commits you want to move from the local branch to master by using ```j/k``` to navigate to the commit and
```C``` to cherry-pick. If a cherry-pick fails quit tig by pressing ```q``` and Ctrl-c to abort git update. Then do the cherry-pick
manually.

TODO
====
* Maybe include a script to copy git-update.sh into the git-exec directory (like git flow)
* Move the initial setup into a ```git update init``` command
