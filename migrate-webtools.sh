#!/bin/sh -ex
# This script migrates the old webtools framework from cvs to git

rm -rf WEBTOOLS-*
cvs -Q export -r SiteDBv1-slc5-v3 -d WEBTOOLS-SiteDBv1  WEBTOOLS
cvs -Q export -r V01-03-47        -d WEBTOOLS-V01-03-47 WEBTOOLS

rm -rf webtools; mkdir webtools; cd webtools
git init
rsync -av --exclude .git ../WEBTOOLS-V01-03-47/ ./
git add -A .
git commit -m "Import V01-03-47 cvs tag as master."
git tag V01-03-47

git checkout -b SiteDBv1
rsync -av --exclude .git ../WEBTOOLS-SiteDBv1/ ./
git add -A .
git commit -m "Import SiteDBv1-slc5-v3 cvs tag as the SiteDBv1 branch."
git tag SiteDBv1-slc5-v3

# We are not going to push it to the dmwm organization
# because the webtools is about to retire.
# Just pushing it to some private account to make sure
# we have it in case it turns out to be needed.
git remote add github git@github.com:geneguvo/webtools.git
git push --mirror github
