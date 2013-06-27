#!/bin/sh -ex
# This script migrates the old dls-client from cvs to git

rm -rf DLS-CLIENT-*
cvs -Q export -r DLS_1_1_3        -d DLS-CLIENT-DLS_1_1_3 DLS/Client

rm -rf dls-client; mkdir dls-client; cd dls-client
git init
rsync -av --exclude .git ../DLS-CLIENT-DLS_1_1_3/ ./
git add -A .
git commit -m "Import DLS_1_1_3 cvs tag as master."
git tag DLS_1_1_3

# We are not going to push it to the dmwm organization
# because the dls-client is about to retire.
# Just pushing it to some private account to make sure
# we have it in case it turns out to be needed.
git remote add github git@github.com:geneguvo/dls-client.git
git push --mirror github
