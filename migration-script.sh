#!/bin/sh -ex
export PYTHONPATH=/build/ge/test-git/sw/usr/lib/python2.4/site-packages
export PATH=/build/ge/test-git/sw/bin:$PATH
# Take care of CMSSW.
time rsync -a --delete --delete-excluded \
                       --exclude "**/Vis*/" --exclude "**/Ig*" --exclude "**/data/*.out,v" \
                       --exclude "**/data/*.txt,v" --exclude "**/Attic" \
                       --exclude "*.dat,v" --exclude "**/*.root,v" --exclude "**/.admin" \
                       --exclude "**/*.gz,v" --exclude "**/*.tgz,v" --exclude "**/doc/" \
                       --exclude "Release.conf" \
                       --exclude "*.db,v" \
                       --exclude "*.slha,v" \
                       --exclude "*.jar,v" \
                       --exclude "*.pev,v" \
                       --exclude "**/ISpy" \
                       --exclude "**/SimG4Validation" \
                       --exclude "*.so,v" \
                       --exclude "**/UserCode" \
                       --exclude "**/OpticalAlignment" \
                       --exclude "**/Utilities/Threads" \
                       --exclude "**/SWDevTools" \
                       --exclude "**/UserCode" \
                       --exclude "Utilities/BuildScripts" \
                       --exclude "HiggsAnalysis/HiggsToZZ4Leptons" \
                       --exclude "ElectroWeakAnalysis/VPlusJets" \
                       --exclude "HeavyFlavorAnalysis/Bs2MuMu" \
                       --exclude "HiggsAnalysis/HiggsToWW2Leptons" \
                       --exclude "TauAnalysis/TauIdEfficiency" \
                       --exclude "DQM/Integration" \
                       --exclude "Configuration/GenProduction" \
                       --exclude "Validation/VstQuaero" \
                       --exclude "TESTSubSystem" \
                       --exclude "OnlineDB/ESCondDB/sql/create_ES_fe_daq_config.sql" \
                       --exclude "#*" \
      /afs/cern.ch/project/cvs/reps/CMSSW/CMSSW/ /build/ge/test-git/cvs/CMSSW/CMSSW/
mkdir -p cvs2git-tmp/
cp -f hints.txt hints-final.txt
#curl -k https://cmstags.cern.ch/tc/public/ReleasesXML | grep -e "CMSSW_[56]" | perl -p -e 's/.*(CMSSW_[56][^"]+).*/. \1 tag . ./' >> hints-final.txt
time /build/ge/test-git/sw/usr/bin/cvs2git --blobfile=cvs2git-tmp/git-blob.dat \
                                        --dumpfile=cvs2git-tmp/git-dump.dat \
                                        /build/ge/test-git/cvs/CMSSW/CMSSW \
                                        --use-external-blob-generator \
                                        --symbol-transform="(.*)/:\1-" \
                                        --username cmsbuild \
                                        --exclude "V[0-9]+-[0-9]+-[0-9]+" \
                                        --exclude ".*" \
                                        --fallback-encoding "UTF8" \
                                        --symbol-hints=hints-final.txt \
                                        --tmpdir=foo1 \
                                        --pass 1:16
rm -rf CMSSW.git
mkdir -p CMSSW.git
pushd CMSSW.git
  git init --bare
  cat ../cvs2git-tmp/git-blob.dat ../cvs2git-tmp/git-dump.dat | git fast-import
#  git repack -a -d -f --depth=125000 --window=1250
  git gc --prune=now --aggressive
  git remote add origin git@github.com:cms-sw/cmssw.git
  git remote add cern https://:@git.cern.ch/kerberos/CMSSW.git
  git push origin -f master --tags
  git push cern -f master --tags
popd

# Take care of CMSDIST 
time rsync -av --delete --delete-excluded \
                        --exclude "#*" \
      /afs/cern.ch/project/cvs/reps/CMSSW/COMP/CMSDIST/ /build/ge/test-git/cvs/CMSSW/CMSDIST/
cat << \EOF > cmsdist-hints.txt
. ecb428slhc_branch branch . .
EOF
mkdir -p cvs2git-cmsdist-tmp/
time /build/ge/test-git/sw/usr/bin/cvs2git --blobfile=cvs2git-cmsdist-tmp/git-blob.dat \
                                        --dumpfile=cvs2git-cmsdist-tmp/git-dump.dat \
                                        /build/ge/test-git/cvs/CMSSW/CMSDIST \
                                        --use-external-blob-generator \
                                        --symbol-transform="(.*)/:\1-" \
                                        --username cmsbuild \
                                        --symbol-hints=cmsdist-hints.txt \
                                        --exclude "[^C][^M][^S].*" \
                                        --fallback-encoding "UTF8" \
                                        --tmpdir=foo1 \
                                        --pass 1:16
rm -rf CMSDIST.git
mkdir -p CMSDIST.git
pushd CMSDIST.git
  git init --bare
  cat ../cvs2git-cmsdist-tmp/git-blob.dat ../cvs2git-cmsdist-tmp/git-dump.dat | git fast-import
#  git repack -a -d -f --depth=125000 --window=1250
  git gc --prune=now --aggressive
  git remote add origin git@github.com:cms-sw/cmsdist.git
  git remote add cern https://:@git.cern.ch/kerberos/CMSDIST.git
  git push origin -f master --tags
  git push cern -f master --tags
popd

