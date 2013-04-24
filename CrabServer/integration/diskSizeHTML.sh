#!/bin/bash

name=`echo $HOSTNAME|awk -F '.' '{print $1}'`

if [[ $HOSTNAME == "submit-2.t2.ucsd.edu" ]]; then
  datapath=${STORAGEPATH}
  working_dir=$MYROOTDIR/integration
  export MYROOTDIR=/home/crab
elif [[ "$HOSTNAME" == submit-* ]]; then
  datapath="/home"
  working_dir=$MYROOTDIR/integration
  export MYROOTDIR=/home/crab
elif [ $HOSTNAME == "hcc-crabserver.unl.edu"  ]; then
  datapath="/crab"
  working_dir=$MYROOTDIR/integration
  export MYROOTDIR=/crab/crab
else
  export MYROOTDIR=/home/crab/integration
  working_dir=$MYROOTDIR
  export datapath="/data01"
fi

if [ $HOSTNAME == "submit-2.t2.ucsd.edu" ]; then
  export used=`df | grep $datapath | awk '{print $2}' | sed -e 's/%/ /g'`
else
  export used=`df | grep $datapath | awk '{print $3}' | sed -e 's/%/ /g'`
fi

mkdir -p $working_dir/diskSize

today=`eval date +%Y/%m/%d`
echo $today","$used  >> $working_dir/diskSize/diskSize.csv
