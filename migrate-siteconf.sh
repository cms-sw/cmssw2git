#!/bin/sh -ex
# This script migrates the siteconf repository from cvs to git

rm -rf SITECONF-*
cvs -Q export -r HEAD -d SITECONF-HEAD SITECONF

rm -rf siteconf; mkdir siteconf; cd siteconf
git init

# Copy only site stuff that matches the CMS site name convention,
# filter out phedex password files
rsync -av --filter '-s DBParam***' --filter '-s ftspass***' --filter '+s T[0-3]_[A-Z][A-Z]_*/***' --filter '-rs ***' ../SITECONF-HEAD/ ./
git add -A .
git commit -m "Import SITECONF from CVS HEAD as master, filtering out secret files and sites which do not follow the CMS site naming convention."

git remote add origin https://:@git.cern.ch/kerberos/siteconf
git push --mirror origin
