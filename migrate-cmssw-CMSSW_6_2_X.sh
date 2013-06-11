#!/bin/sh -ex
echo "Updates the git repository with the last IB"
IB_PATH=/afs/cern.ch/cms/sw/ReleaseCandidates/vol*/slc5_amd64_gcc472/cms/cmssw
rm -rf cmssw-ib
git clone -b CMSSW_6_2_X git@github.com:cms-sw/cmssw-ib.git
pushd cmssw-ib
  CMSSWIB=$PWD
  for x in `find $IB_PATH -mindepth 1 -maxdepth 1 -name "CMSSW_6_2_*" -type d | sort -t / -k 10`; do
    RELEASE_NAME=`echo $x | sed -e 's|.*/||'`
    echo $RELEASE_NAME
    # If it's already there, do not import it again.
    RELEASE_PRESENT=`git tag -l | grep $RELEASE_NAME || true`
    echo $RELEASE_PRESENT
    if [ "X$RELEASE_PRESENT" = X ]; then
      echo "PackageList.cmssw" > ../exclude-file.txt
      set +e
      find $x/src -name __init__.py -exec grep -m 5 -H "#Automatically created by SCRAM" {} \; | sed -e 's|:.*||;s|.*/src/||' >> ../exclude-file.txt
      rsync -a --delete --exclude ".git" --exclude "PackageList.cmssw" --exclude "*.pyc" --exclude ".glimpse*" $x/src/ ./
      cat ../exclude-file.txt | xargs -n 20 rm -f
      git add -A .
      git commit -m "$RELEASE_NAME" || true
      rsync -a --delete --exclude ".git" --exclude "PackageList.cmssw" --exclude "*.pyc" --exclude ".glimpse*" $x/src/ ./ 
      cat ../exclude-file.txt | xargs -n 20 rm -f
      set -e
      git tag $RELEASE_NAME
    fi
  done
  git gc --aggressive --prune=now
  git push origin --mirror
popd
./migrate-tagsets.py
