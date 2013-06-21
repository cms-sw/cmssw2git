#!/bin/sh -e
# Generates users info with real CERN email and full name. To
# be used by private repositories hosted at CERN/GIT.
CVS_PROJECT=$1
if [ X$CVS_PROJECT = X ]; then
  echo "Please specify a project."
  exit 1
fi

PROJECT=`basename $1`
WORKDIR=tmp/$PROJECT
mkdir -p $WORKDIR

grep -r author $CVS_PROJECT | grep :date | cut -f 3 | sed -e 's/author //g;s/;//' | sort -u > $WORKDIR/users.txt

echo "${PROJECT}_USERS = {"
for x in `cat $WORKDIR/users.txt`; do 
  REAL_NAME="`phonebook --login $x -t firstname -t surname | tr ';' ' '`"
  if [ "X$REAL_NAME" = X ]; then
    REAL_NAME=$x
  fi
  echo \"$x\": \"$REAL_NAME \<$x\@cern.ch\>\",
done
echo "}"
