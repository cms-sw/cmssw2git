#!/bin/sh
#

if [ $# -ne 3 ]
then
    echo "usage: $0 <LFN> <expectedAdler32> <sitename>"
    exit -1
fi

LFN=$1
expectedAdler=$2
site=$3

#
# prepare a crab task to compute Adler32 cksum on remote copy
# of <LFN> at <sitename> and compare with <expectedAdler32>
#

cat<<EOF > dummyCMSSWconfig.py
import FWCore.ParameterSet.Config as cms
process = cms.Process('Dummy')
process.source = cms.Source("PoolSource")
EOF

cat<<EOF > locally_verify_EDM_file.sh
#!/bin/sh

set -x
edmFileUtil -adj ${LFN} | tee edmFU.json
adler32dec=\`cat edmFU.json |tr ',' '\n'|grep adler32sum|cut -d ':' -f2|tr -d }\`
adler32hex=\`echo "obase=16; \${adler32dec}" | bc -l | tr [A-Z] [a-z]\`

echo Computed Adler32 = \$adler32hex
echo Expected Adler32 = $expectedAdler

if [ \$adler32hex == $expectedAdler ]
then
  echo "FILE OK"
  exit 0
else
  echo "MISMATCH !"
  exit 66
fi
EOF

chmod +x locally_verify_EDM_file.sh

cat<<EOF > crab_verifyEDM.cfg
[CRAB]
jobtype=cmssw
scheduler=remoteGlidein
use_server=0

[CMSSW]
datasetpath=None
pset=dummyCMSSWconfig.py
number_of_jobs=1
events_per_job=1

[USER]
script_exe=locally_verify_EDM_file.sh
return_data=1

[GRID]
role= priorityuser
remove_default_blacklist=1
SE_white_list=${site}
EOF

crab -create -cfg crab_verifyEDM.cfg

echo crab configuration prepared in current directory, submit with
echo crab -submit
