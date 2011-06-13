# Gets the name of the local branch, prompting the user if necessary
function get-local-branch() {
}


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
