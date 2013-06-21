#!/bin/sh -ex
export PYTHONPATH=/build/diego/gitcmsdist/cvs2svn/cvs2svn-2.4.0/build/lib:.
export PATH=/build/diego/gitcmsdist/cvs2svn/cvs2svn-2.4.0/build/scripts-2.4:$PATH
LANG=C

rm -rf tmp/cvs/CMSSW/COMP/COMPPROJECT; mkdir -p tmp/cvs/CMSSW/COMP/COMPPROJECT
time rsync -av /afs/cern.ch/project/cvs/reps/CMSSW/CVSROOT/ tmp/cvs/CMSSW/CVSROOT/ || true
time rsync -av /afs/cern.ch/project/cvs/reps/CMSSW/COMP/JOBROBOT/ tmp/cvs/CMSSW/COMP/COMPPROJECT/
perl -p -i -e 's/^/#/' tmp/cvs/CMSSW/CVSROOT/config
./generate-cern-emails.sh tmp/cvs/CMSSW/COMP/ > comp_users_map.py
rm -rf tmp/cvs2git-COMPPROJECT-tmp
cvs2git \
    --options=COMP.options \
    --fallback-encoding="ascii" \
    --pass=1:16
rm -rf JOBROBOT.git
git init --bare JOBROBOT.git
cd JOBROBOT.git
cat ../tmp/cvs2git-COMPPROJECT-tmp/git-blob.dat ../tmp/cvs2git-COMPPROJECT-tmp/git-dump.dat | git fast-import
git branch import-HEAD master
git gc --prune=now
git gc --prune=now --aggressive

git config http.postBuffer 209715200

# Avoid having a fake origin remote by specifing a url.
git push https://:@git.cern.ch/kerberos/jobrobot --mirror
