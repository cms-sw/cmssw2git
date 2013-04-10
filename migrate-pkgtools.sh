#!/bin/sh -ex
for x in V00-16-XX V00-20-XX V00-21-XX V00-22-XX; do
  rm -rf PKGTOOLS-$x
done
rm -rf tmp
mkdir tmp
cd tmp

cvs -Q export -r V00-22-02 -d PKGTOOLS-V00-22-XX PKGTOOLS
cvs -Q export -r V00-21-07 -d PKGTOOLS-V00-21-XX PKGTOOLS 
cvs -Q export -r V00-20-37 -d PKGTOOLS-V00-20-XX PKGTOOLS
#cvs co -r V00-19-07 PKGTOOLS -d PKGTOOLS-V00-19-XX
#cvs co -r V00-18-04 PKGTOOLS -d PKGTOOLS-V00-18-XX
#cvs co -r V00-17-06 PKGTOOLS -d PKGTOOLS-V00-17-XX
cvs -Q export -r V00-16-21 -d PKGTOOLS-V00-16-XX PKGTOOLS

git init PKGTOOLS
cd PKGTOOLS
for x in V00-16-XX V00-20-XX V00-21-XX V00-22-XX; do
  rsync -av --exclude configs --exclude .git --exclude captor ../PKGTOOLS-$x/ ./
  git add -A .
  git commit -m "Import $x"
  git branch $x
done
git remote add github git@github.com:cms-sw/pkgtools.git
git push --mirror github
