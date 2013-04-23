#!/bin/sh -ex
export PYTHONPATH=/build/ge/test-git/sw/usr/lib/python2.4/site-packages:.
export PATH=/build/ge/test-git/sw/usr/bin:$PATH

mkdir -p tmp/cvs/CMSSW/COMP/CMSDIST/
time rsync -av /afs/cern.ch/project/cvs/reps/CMSSW/CVSROOT/ /build/ge/test-git/tmp/cvs/CMSSW/CVSROOT/ || true
time rsync -av --delete --delete-excluded --prune-empty-dirs \
              --exclude "**/BuildScripts" \
              --exclude "**/geant4-g4e-and-g4tubs*" \
              --exclude "**/valgrind-V11425.patch*" \
              --exclude "**/root-5.22-00d-fireworks*" \
              --exclude "**/Attic/*" \
              --exclude "**/seal*" \
              --exclude "**/iguana*" \
              --exclude "**/clarens*" \
              --exclude "**/pool*" \
              --exclude "**/POOL*" \
              --exclude "#*" \
        /afs/cern.ch/project/cvs/reps/CMSSW/COMP/CMSDIST/ tmp/cvs/CMSSW/COMP/CMSDIST/
# Take care of CMSSW.
if [ ! -f cmssw_users_map.py ]; then
  ./generate-fake-emails.sh tmp/cvs/CMSSW/CMSSW > cmssw_users_map.py
fi
time /build/ge/test-git/sw/usr/bin/cvs2git \
                       --options=CMSDIST.options \
                       --fallback-encoding="ascii" \
                       --pass=1:16
git init --bare CMSDIST.git
cd CMSDIST.git
cat ../tmp/cvs2git-CMSDIST-tmp/git-blob.dat ../tmp/cvs2git-CMSDIST-tmp/git-dump.dat | git fast-import
git branch -D  lcgaa_for120p6_branch lcg47branch unlabeled-1.1.2
git gc --prune=now --aggressive
git remote add origin git@github.com:cms-sw/cmsdist.git
