# Gets the name of the local branch, prompting the user if necessary
SAVE_BRANCH="git_update_tmp_save_branch";
function get-config-branch() {
    local branchType=$1
    local branch=$(git config update.${branchType})
    if [ -z "$branch" ]; then
        echoerr "Existing branches:";
        git branch 1>&2;
        echoerr -n "What is the name of your ${branchType} branch? ";
        read branchName
        echoerr "You entered $branchName"
        echoerr -n "Going to store ${branchType} branch name in your git config, continue? [y/N]: ";
        read ans
        case $ans in
            y|Y|yes|Yes) echoerr "Writing to config" ;;
            *) echoerr "Exiting. Cannot run without knowing the ${branchType} branch"; exit 1 ;;
        esac
        git config update.${branchType} $branchName
        branch=$(git config update.branch)
    fi
    echo $branch
}


# Gets the update from the upstream branch (typically origin/master)
function get-update() {
    local LOCAL_BRANCH=$1
    local UPSTREAM_BRANCH=$2
    run git fetch --all
    run git checkout $LOCAL_BRANCH
    echoerr "checkout $?"
    run git branch $SAVE_BRANCH
    if [ $? -eq 128 ]; then
        run git branch -D $SAVE_BRANCH;
        run git branch $SAVE_BRANCH;
    fi

    run git rebase origin/$UPSTREAM_BRANCH
    if [ $? -ge 1 ]; then
        echoerr "Rebase not successful, aborting";
        run git rebase --abort;
        run git branch -d $SAVE_BRANCH;
        exit 1;
    fi

    run git checkout $UPSTREAM_BRANCH
    if [ $? -ne 0 ]; then
        echoerr "Error";
        exit 1;
    fi

    run git merge --ff-only origin/$UPSTREAM_BRANCH
    if [ $? -ne 0 ]; then
        echoerr "Error: Could not fastforward, trying a rebase";
        sleep 3;
        echoerr "Trying now";
        run git rebase origin/$UPSTREAM_BRANCH
        if [ $? -ge 1 ]; then
            echoerr "Rebase not successful, aborting";
            run git rebase --abort;
            exit 1;
        fi
    fi

    run git checkout $LOCAL_BRANCH
    if [ $? -ne 0 ]; then
        echoerr "Error";
        exit 1;
    fi

    run git branch -D $SAVE_BRANCH;
    if [ $? -ne 0 ]; then
        echoerr "Error";
        exit 1;
    fi
}


# Pushes updates to upstream branch
function push-update() {
    local LOCAL_BRANCH=$1
    local UPSTREAM_BRANCH=$2
    run git checkout $UPSTREAM_BRANCH;
    if [ $? -ne 0 ]; then
        echoerr "Error";
        exit 1;
    fi

    tig $UPSTREAM_BRANCH origin/$UPSTREAM_BRANCH $LOCAL_BRANCH;
    if [ $? -ne 0 ]; then
        echoerr "Tig returned error, exiting";
        exit 1;
    fi


    echoerr -n "Sleeping if you want to abort..."
    sleep 4;
    echoerr "Done"

    run git checkout $LOCAL_BRANCH;
    if [ $? -ne 0 ]; then
        echoerr "Error";
        exit 1;
    fi

    run git branch $SAVE_BRANCH
    if [ $? -eq 128 ]; then
        run git branch -D $SAVE_BRANCH;
        run git branch $SAVE_BRANCH;
    fi

    run git rebase $UPSTREAM_BRANCH
    if [ $? -ge 1 ]; then
        echoerr "Rebase not successful, resetting";
        run git reset --hard $SAVE_BRANCH;
        run git branch -d $SAVE_BRANCH;
        exit 1;
    fi

    run git branch -D $SAVE_BRANCH;
    if [ $? -ne 0 ]; then
        echoerr "Error";
        exit 1;
    fi

    run git push origin $UPSTREAM_BRANCH
    if [ $? -ne 0 ]; then
        echoerr "Error pushing $UPSTREAM_BRANCH branch";
        exit 1;
    fi
}

function push-local-branch() {
    local LOCAL_BRANCH=$1
    run git push -f origin $LOCAL_BRANCH
    if [ $? -ne 0 ]; then
        echoerr "Error pushing local branch";
        exit 1;
    fi
}

function echoerr() { echo "$@" 1>&2; }
