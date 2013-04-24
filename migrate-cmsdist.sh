#!/bin/sh -ex
export PYTHONPATH=/build/ge/test-git/sw/usr/lib/python2.4/site-packages:.
export PATH=/build/ge/test-git/sw/usr/bin:$PATH
LANG=C

mkdir -p tmp/cvs/CMSSW/COMP/CMSDIST/
time rsync -av /afs/cern.ch/project/cvs/reps/CMSSW/CVSROOT/ /build/ge/test-git/tmp/cvs/CMSSW/CVSROOT/ || true
time rsync -av --delete --delete-excluded --prune-empty-dirs \
              --exclude "**/BuildScripts" \
              --exclude "**/geant4-g4e-and-g4tubs*" \
              --exclude "**/valgrind-V11425.patch*" \
              --exclude "**/py2-sqlalchemy_patch_0.4.4_0.4.5*" \
              --exclude "**/monalisa*" \
              --exclude "**/prodrequest*" \
              --exclude "**/root-5.22*" \
              --exclude "**/Attic/*" \
              --exclude "**/seal*" \
              --exclude "**/iguana*" \
              --exclude "**/clarens*" \
              --exclude "**/pool*" \
              --exclude "**/POOL*" \
              --exclude "#*" \
        /afs/cern.ch/project/cvs/reps/CMSSW/COMP/CMSDIST/ tmp/cvs/CMSSW/COMP/CMSDIST/
perl -p -i -e 's/^/#/' tmp/cvs/CMSSW/CVSROOT/config
# Take care of CMSSW.
if [ ! -f cmssw_users_map.py ]; then
  ./generate-fake-emails.sh tmp/cvs/CMSSW/CMSSW > cmssw_users_map.py
fi
time /build/ge/test-git/sw/usr/bin/cvs2git \
                       --options=CMSDIST.options \
                       --fallback-encoding="ascii" \
                       --pass=1:16
rm -rf CMSDIST.git
git init --bare CMSDIST.git
cd CMSDIST.git
cat ../tmp/cvs2git-CMSDIST-tmp/git-blob.dat ../tmp/cvs2git-CMSDIST-tmp/git-dump.dat | git fast-import
git branch -D  lcgaa_for120p6_branch lcg47branch unlabeled-1.1.2
git branch import-HEAD master
git update-ref refs/heads/master dmendezl_20130418_1710-62X
git gc --prune=now
git gc --prune=now --aggressive
# Avoid having a fake origin remote by specifing a url.
git push git@github.com:cms-sw/cmsdist.git --mirror
