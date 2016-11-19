#!/bin/bash

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

echo -e "\033[2m"
# Build the project.
hugo
echo -e "\033[0m"

# Go To Public folder
cd public
# Add changes to git.
git add -A

# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
    then msg="$1"
else
    echo -e "\033[1mCommit message: "
    read newmsg
    echo -e "\033[0m"
    msg=newmsg
fi

git commit -m "$msg"

# Push source and build repos.
git push origin master

# Come Back
cd ..