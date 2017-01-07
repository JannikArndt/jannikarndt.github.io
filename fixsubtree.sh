#!/bin/bash

echo -e "\033[31mReally delete public folder and recreate subtree? (y/n)\033[0m"
read reallyCont
if [ $reallyCont != "y" ]
    then echo "Nothing changed, exiting."
    exit
fi

# delete public folder
rm -r public

# delete folder from stage, if it is already staged
git rm --cached public

git submodule add --force -b master git@github.com:JannikArndt/jannikarndt.github.io.git public 