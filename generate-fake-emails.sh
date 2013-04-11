#!/bin/sh -e
CVS_PROJECT=$1
if [ X$CVS_PROJECT = X ]; then
  echo "Please specify project $CVS_PROJECT"
  exit 1
fi

PROJECT=`basename $1`
WORKDIR=tmp/$CVS_PROJECT
mkdir -p $WORKDIR

CVS_ROOT_DIR=/afs/cern.ch/project/cvs/reps/CMSSW/
grep -r author $CVS_ROOT_DIR/$CVS_PROJECT | grep :date | cut -f 3 | sed -e 's/author //g;s/;//' | sort -u > $WORKDIR/users.txt

echo "${PROJECT}_USERS = {"
for x in `cat $WORKDIR/users.txt`; do 
  REAL_NAME="`phonebook --login $x -t firstname -t surname | tr ';' ' '`"
  FAKE_EMAIL=`echo $x | sha1sum | cut -d\  -f1`
  echo \"$x\": \"$REAL_NAME \<sha1-$FAKE_EMAIL\@cern.ch\>\", | grep -v -e '[:][ ]["][ ][<]' || true
done
echo "}"
