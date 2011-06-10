#!/bin/bash
LOCAL_BRANCH=${GIT_LOCAL_BRANCH};

command=$1;

function usage() {
cat <<EOF
usage: git update operation

Operation can be one of the following:
    get: Get updates from the master branch
    push: Push updates from the master branch (requires tig)
EOF
}

if [ -z $LOCAL_BRANCH ]; then
    echo "Error: LOCAL_BRANCH not set";
    exit 1;
elif [ $LOCAL_BRANCH = "default" ]; then
    echo "Error: LOCAL_BRANCH needs to be changed from default";
    exit 1;
fi

function run() {
    echo;
    echo $@;
    eval $@;
}

cd $HOME/config

run git diff --exit-code >/dev/null
if [ $? -ne 0 ]; then
    echo "Error: git diff reports non-clean directory";
    exit 1;
fi

# Gets the update from the origin master
function get-update() {
    run git fetch --all
    run git checkout $LOCAL_BRANCH
    echo "checkout $?"
    run git branch save
    if [ $? -eq 128 ]; then
        run git branch -D save;
        run git branch save;
    fi

    run git rebase origin/master
    if [ $? -ge 1 ]; then
        echo "Rebase not successful, aborting";
        run git rebase --abort;
        run git branch -d save;
        exit 1;
    fi

    run git checkout master
    if [ $? -ne 0 ]; then
        echo "Error";
        exit 1;
    fi

    run git merge --ff-only origin/master
    if [ $? -ne 0 ]; then
        echo "Error: Could not fastforward, trying a rebase";
        sleep 3;
        echo "Trying now";
        run git rebase origin/master
        if [ $? -ge 1 ]; then
            echo "Rebase not successful, aborting";
            run git rebase --abort;
            exit 1;
        fi
    fi

    run git checkout $LOCAL_BRANCH
    if [ $? -ne 0 ]; then
        echo "Error";
        exit 1;
    fi

    run git branch -D save;
    if [ $? -ne 0 ]; then
        echo "Error";
        exit 1;
    fi

    run git push -f origin $LOCAL_BRANCH
    if [ $? -ne 0 ]; then
        echo "Error pushing local branch";
        exit 1;
    fi
}

# Pushes updates to origin master
function push-update() {
    run git checkout master;
    if [ $? -ne 0 ]; then
        echo "Error";
        exit 1;
    fi

    tig master origin/master $LOCAL_BRANCH;
    if [ $? -ne 0 ]; then
        echo "Tig returned error, exiting";
        exit 1;
    fi


    echo -n "Sleeping if you want to abort..."
    sleep 4;
    echo "Done"

    run git checkout $LOCAL_BRANCH;
    if [ $? -ne 0 ]; then
        echo "Error";
        exit 1;
    fi

    run git branch save
    if [ $? -eq 128 ]; then
        run git branch -D save;
        run git branch save;
    fi

    run git rebase master
    if [ $? -ge 1 ]; then
        echo "Rebase not successful, resetting";
        run git reset --hard save;
        run git branch -d save;
        exit 1;
    fi

    run git branch -D save;
    if [ $? -ne 0 ]; then
        echo "Error";
        exit 1;
    fi

    run git push origin master
    if [ $? -ne 0 ]; then
        echo "Error pushing master branch";
        exit 1;
    fi

    run git push -f origin $LOCAL_BRANCH
    if [ $? -ne 0 ]; then
        echo "Error pushing local branch";
        exit 1;
    fi
}

case "$command" in
    push) echo "Going to push";
        push-update;
        ;;
    get) echo "Going to update";
        get-update;
        ;;
    *) echo "Didn't understand command \"$command\"";
        usage;
        ;;
esac
