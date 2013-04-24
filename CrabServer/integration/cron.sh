#!/bin/bash

export MYSTORAGENAME=${HOSTNAME}

if [ $MYSTORAGENAME == "submit-2.t2.ucsd.edu" ]; then
  export MYROOTDIR=/home/crab
  export MYSTORAGEPATH="/crabprod/remoteGlidein"
elif [ $MYSTORAGENAME == "submit-3.t2.ucsd.edu"  ]; then
  export MYROOTDIR=/home/crab
  export MYSTORAGEPATH="/crabprod/CSstoragePath"
elif [ $MYSTORAGENAME == "submit-4.t2.ucsd.edu"  ]; then
  export MYROOTDIR=/home/crab
  export MYSTORAGEPATH="/crabprod/CSstoragePath"
elif [ $MYSTORAGENAME == "glidein-2.t2.ucsd.edu"  ]; then
  export MYROOTDIR=/home/crab
  export MYSTORAGEPATH="/var/gftp_cache/CSstoragePath"  
elif [ $MYSTORAGENAME == "hcc-crabserver.unl.edu"  ]; then
  export MYROOTDIR=/crab/crab
  export MYSTORAGEPATH="/crab/crab/crabprod/CSstoragePath"
elif [[ "$MYSTORAGENAME" == *vocms* ]]; then
  export MYROOTDIR=/home/crab
  export MYSTORAGEPATH="/data01/CSstoragePath"
fi

echo -e `date` "\t Starting cleaning script\n" >> $MYROOTDIR/integration/disksize.log

source $MYROOTDIR/BeforeStart.sh
cd $PRODAGENT_WORKDIR

cd TaskLifeManager

for i in `ls deleteSB*.py`
do
# ls -l $i
# python $i local
 rm -rf $i
done

DAYS=20

possibleclean=`find $MYSTORAGEPATH -maxdepth 1 -type d -mtime +$DAYS -print`
exclude=`find $MYSTORAGEPATH -maxdepth 1 -type d -mtime +$DAYS \
  -exec find {} -type f -mtime -$DAYS \; | awk -F\/ '{print $6}' | sort | uniq`
echo -e `date` "\nPossible clean: \n $possibleclean \n Excluding: \n $exclude" >> $MYROOTDIR/integration/disksize.log
for dir in $possibleclean ; do
  basedir=`basename $dir`
  echo $exclude | grep $basedir 2>&1 >> /dev/null
  if [ $? -eq 1 ] ; then
    rm -rf $dir
    echo -e `date` "\t Removed directory $dir" >> $MYROOTDIR/integration/disksize.log
  fi
done
echo -e `date` "\t Finishing cleaning script\n" >> $MYROOTDIR/integration/disksize.log
exit 0 



