#!/bin/sh -ex
# This script migrates the old dbs2 client from cvs to git

rm -rf DBS2-CLIENT-*
cvs -Q export -r DBS_2_1_9        -d DBS2-CLIENT-DBS_2_1_9 DBS/Clients/Python

rm -rf dbs2-client; mkdir dbs2-client; cd dbs2-client
git init
rsync -av --exclude .git ../DBS2-CLIENT-DBS_2_1_9/ ./
git add -A .
git commit -m "Import DBS_2_1_9 cvs tag as master."
git tag DBS_2_1_9

# We are not going to push it to the dmwm organization
# because the dbs2-client is about to retire.
# Just pushing it to some private account to make sure
# we have it in case it turns out to be needed.
git remote add github git@github.com:geneguvo/dbs2-client.git
git push --mirror github
