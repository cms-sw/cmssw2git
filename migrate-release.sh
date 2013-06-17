#!/bin/sh -ex
if [ X$1 = X ]; then
  echo Please specify a release to import.
fi
if [ X$2 = X ]; then
  echo Please specify a destination queue.
fi
RELEASE_NAME=$1
QUEUE=$2
IS_IB=false
if [ `echo $RELEASE_NAME | grep _X_` ]; then
  IS_IB=true
fi

echo "Updates the git repository with the last IBs"
DEST_REPO=git@github.com:cms-sw/cmssw.git
rm -rf tmp/ib-repo
mkdir -p tmp/ib-repo
git clone $DEST_REPO tmp/ib-repo
cd tmp/ib-repo
git fetch origin $QUEUE:$QUEUE || git checkout --orphan $QUEUE
git checkout $QUEUE --
CMSSWIB=$PWD
# Different IBs have different architectures.
case $QUEUE-$IS_IB in
  CMSSW_5_3_X*-true)
    RELEASE_PATH=/afs/cern.ch/cms/sw/ReleaseCandidates/vol*/slc5_amd64_gcc462/cms/cmssw ;;
  CMSSW_6_*-true)
    RELEASE_PATH=/afs/cern.ch/cms/sw/ReleaseCandidates/vol*/slc5_amd64_gcc472/cms/cmssw ;;
  CMSSW_5_3_X*-false)
    RELEASE_PATH=/afs/cern.ch/cms/slc5_amd64_gcc462/cms/cmssw ;;
  CMSSW_6_*-false)
    RELEASE_PATH=/afs/cern.ch/cms/slc5_amd64_gcc472/cms/cmssw ;;
esac
echo $RELEASE_NAME
# If it's already there, do not import it again.
RELEASE_PRESENT=`git tag -l | grep $RELEASE_NAME || true`
echo $RELEASE_PRESENT
if [ "X$RELEASE_PRESENT" = X ]; then
  echo "PackageList.cmssw" > ../exclude-file.txt
  set +e
  find $RELEASE_PATH/$RELEASE_NAME/src -name __init__.py -exec grep -m 5 -H "#Automatically created by SCRAM" {} \; | sed -e 's|:.*||;s|.*/src/||' >> ../exclude-file.txt
  rsync -a --delete --exclude ".git" --exclude "PackageList.cmssw" --exclude "*.pyc" --exclude ".glimpse*" $RELEASE_PATH/$RELEASE_NAME/src/ ./
  cat ../exclude-file.txt | xargs -n 20 rm -f
  git add -A .
  git commit -m "$RELEASE_NAME" || true
  set -e
  git tag $RELEASE_NAME
fi
git gc --aggressive --prune=now
git push $DEST_REPO $QUEUE
#./migrate-tagsets.py
