#!/bin/sh -ex
export PYTHONPATH=/build/ge/test-git/sw/usr/lib/python2.4/site-packages
export PATH=/build/ge/test-git/sw/bin:$PATH
BASE_PROJECT=COMP
PROJECT_NAME=SCRAM
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

time /build/ge/test-git/sw/usr/bin/cvs2git --options cvs2git-scram.options --pass 1:16
rm -rf $PROJECT_NAME.git
git init --bare $PROJECT_NAME.git
perl -p -i -e 's/^committer cmsbuild <>/committer Giulio Eulisse <sha1-a598d8593b5db48d5829590a227bbe04f25460b4\@cern.ch>/; \
              s/^committer muzaffar <>/committer Shahzad Malik Muzaffar <sha1-dc0e3810c4d4d85d6295265f1fb210880ec3f132\@cern.ch>/; \
              s/^committer elmer <>/committer Peter Elmer <sha1-80460c2ac58e1aa0fd289ec2aa9d168a17bd6eb2\@cern.ch>/; \
              s/^committer sashby <>/committer Shaun Ashby <sha1-0665f252eb8e02afcb80198b20033a58c31fd1b3\@cern.ch>/; \
              s/^committer williamc <>/committer Christopher Williams <sha1-ebcb402bd5472f352dd1d1c7a94fa0cbb49cf4a3\@cern.ch>/;' \
              cvs2git-$PROJECT_NAME-tmp/git-dump.dat
pushd $PROJECT_NAME.git
  cat ../cvs2git-$PROJECT_NAME-tmp/git-blob.dat ../cvs2git-$PROJECT_NAME-tmp/git-dump.dat | git fast-import
  git gc --prune=now --aggressive
  git remote add origin git@github.com:cms-sw/$PROJECT_NAME.git
  git push --mirror origin
popd
