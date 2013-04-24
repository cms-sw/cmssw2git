#!/bin/sh -ex
rm -rf analysisops
mkdir analysisops
cd analysisops
for x in Crab CrabServer UI Utils; do
  cvs export -r HEAD -d $x COMP/ANALYSISOPS/$x
  pushd $x
    git init
    git add .
    git commit -m 'First import.'
    git push git@github.com:cms-analysis-ops/$x.git --mirror
  popd
done
