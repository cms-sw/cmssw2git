#!/bin/sh

SLCversion=`grep Scientific /etc/redhat-release | sed 's/.*[rR]elease \([0-9]*\)\..*/\1/'`

if [ $SLCversion = 4 ]
then
 source /afs/cern.ch/cms/LCG/LCG-2/UI/cms_ui_env_3_1.sh
fi

if [ $SLCversion = 5 ]
then
  #source /afs/cern.ch/cms/LCG/LCG-2/UI/cms_ui_env_3_2.sh
  source /afs/cern.ch/cms/LCG/LCG-2/UI/cms_ui_env_3_2.11-1.sh
fi

