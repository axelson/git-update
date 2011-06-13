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

source functions.sh

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
