#!/bin/bash

# Check if branch is up-to-date
git fetch
if [[ "$(git rev-parse HEAD)" != "$(git rev-parse @{u})" ]]
	then echo -e "\033[31mCurrent branch is not up-to-date, please pull first!\033[0m"
	exit
fi

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

# Build the project.
echo -e "\033[2m"
hugooutput="$(hugo)"
echo -e "$hugooutput"
echo -e "\033[0m"
if echo "$hugooutput" | grep "ERROR"
  then echo -e "\033[31mError during build, cancelling deployment. 🙁\033[0m"
  exit
fi

# Get commit message
if [ $# -eq 1 ]
    then msg="$1"
else
    echo -e "\033[1mCommit message: "
    read "newmsg"
    echo -e "\033[0m"
    msg="$newmsg"
fi

# Push to submodule (master branch)
cd public
git add -A
git commit -m "$msg"
git push 
cd ..

# Push the source (source branch)
# the hash of the submodule has changed => commit that as well
git add -A
git commit -m "$msg"
git push 