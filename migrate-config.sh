#!/bin/sh -ex
export PYTHONPATH=/build/ge/test-git/sw/usr/lib/python2.4/site-packages
export PATH=/build/ge/test-git/sw/bin:$PATH
# Take care of config
mkdir -p cvs2git-config-tmp/tmp
cat << \EOF > cvs2git-config-tmp/tmp/config-hints.txt
. forBinLess_SCRAM branch . .
. forXML_SCRAM branch . .
. SCRAM_V2_0 branch . .
. COMMON_BUILD_CONFIG branch . .
EOF
time rsync -av --delete --delete-excluded \
                        --delete-excluded \
                        --exclude "#*" \
                        --exclude "POOL*" \
                        --exclude "SEAL*" \
                        --exclude "IGNOMINY*" \
                        --exclude "config/site/Attic/" \
                        --exclude "*.tmpl,v" \
                        --exclude ".admin" \
                        --exclude "Attic/Makefile*" \
      /afs/cern.ch/project/cvs/reps/CMSSW/config/ /build/ge/test-git/cvs/CMSSW/config/

time /build/ge/test-git/sw/usr/bin/cvs2git --blobfile=cvs2git-config-tmp/git-blob.dat \
                                        --dumpfile=cvs2git-config-tmp/git-dump.dat \
                                        /build/ge/test-git/cvs/CMSSW/config \
                                        --use-external-blob-generator \
                                        --symbol-transform="(.*)/:\1-" \
                                        --symbol-hints=cvs2git-config-tmp/tmp/config-hints.txt \
                                        --username cmsbuild \
                                        --exclude "[^V].*" \
                                        --exclude "V00.*" \
                                        --exclude "V01.*" \
                                        --fallback-encoding "UTF8" \
                                        --tmpdir=cvs2git-config-tmp/tmp \
                                        --pass 1:16
rm -rf config.git
git init --bare config.git
perl -p -i -e 's/committer eulisse/committer ktf/g;s/^committer muzaffar/committer smuzaffar/g;s/committer ([^<]*)<>/committer \1<cmsbuild\@cern.ch>/g' cvs2git-config-tmp/git-dump.dat
pushd config.git
  cat ../cvs2git-config-tmp/git-blob.dat ../cvs2git-config-tmp/git-dump.dat | git fast-import
  git gc --prune=now --aggressive
  git remote add origin git@github.com:cms-sw/cmssw-config.git
  git push --mirror origin
popd
