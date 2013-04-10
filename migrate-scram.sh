#!/bin/sh -ex
rm -rf tmp
mkdir tmp
cd tmp

cvs -Q export -r V2_2_5_pre2 -d SCRAM-V2_2_5_pre2 SCRAM
cvs -Q co -r V2_2_5_pre2 -d SCRAM-IMPORT_HEAD SCRAM
pushd SCRAM-IMPORT_HEAD
  cvs update -A
  find . -name CVS -type d | xargs rm -rf
popd

git init SCRAM
cd SCRAM
for x in V2_2_5_pre2 IMPORT_HEAD; do
  rsync -av --exclude .git ../SCRAM-$x/ ./
  git add -A .
  git commit -m "Import $x"
  git tag $x
done
git remote add github git@github.com:cms-sw/SCRAM.git
git push --mirror github
