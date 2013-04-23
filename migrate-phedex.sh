#!/bin/sh -ex
export PYTHONPATH=/build/ge/test-git/sw/usr/lib/python2.4/site-packages:.
export PATH=/build/ge/test-git/sw/bin:$PATH
BASE_PROJECT=COMP
PROJECT_NAME=PHEDEX
DESTDIR=/build/ge/test-git/cvs/CMSSW/$BASE_PROJECT/$PROJECT_NAME/
mkdir -p $DESTDIR

# Take care of $PROJECT_NAME
rm -rf cvs2git-$PROJECT_NAME-tmp/
mkdir -p cvs2git-$PROJECT_NAME-tmp/tmp
time rsync -av --delete --delete-excluded \
                        --exclude "Installation/" \
                        --exclude "Testing/" \
                        --exclude "cgi/" \
                        --exclude "configuration/" \
                        --exclude "doc/" \
                        --exclude "scripts/" \
                        --exclude "toolbox/" \
                        --exclude "Attic/" \
      /afs/cern.ch/project/cvs/reps/CMSSW/$BASE_PROJECT/$PROJECT_NAME/ $DESTDIR

time /build/ge/test-git/sw/usr/bin/cvs2git --options cvs2git-$PROJECT_NAME.options --pass 1:16
rm -rf $PROJECT_NAME.git
git init --bare $PROJECT_NAME.git
pushd $PROJECT_NAME.git
  cat ../cvs2git-$PROJECT_NAME-tmp/git-blob.dat ../cvs2git-$PROJECT_NAME-tmp/git-dump.dat | git fast-import
  git gc --prune=now --aggressive
  git remote add origin git@github.com:cms-sw/$PROJECT_NAME.git
  git push --mirror origin
popd
