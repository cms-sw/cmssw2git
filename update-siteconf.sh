#!/bin/sh -ex
# This script updates the siteconf/git repository from latest CVS revision
rm -rf SITECONF-*
cvs -Q export -r HEAD -d SITECONF-HEAD SITECONF

rm -rf siteconf
git clone https://:@git.cern.ch/kerberos/siteconf
cd siteconf

# Copy only site stuff that matches the CMS site name convention,
# filter out phedex secret files
rsync -av --filter '-s DBParam***' --filter '-s ftspass***' --filter '+s T[0-3]_[A-Z][A-Z]_*/***' --filter '-s ***' --filter '-r .git/***' --delete --delete-excluded ../SITECONF-HEAD/ ./

git add -A .
git commit -m "Update with latest changes from CVS HEAD."
git push origin master
