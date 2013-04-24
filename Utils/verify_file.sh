#!/bin/sh
#
# verify a file (LFN) at a remote site comparing with PhEDEx metadata
# check size via SRM and then Adler32 checksum both making a local copy
# and running a crab job at the remote site
#

# defaults for test:
#LFN=/store/mc/JobRobot/RelValProdTTbar/GEN-SIM-RECO/MC_42_V12_JobRobot-v1/0027/FE328FB6-09A2-E011-921D-002618943916.root 
#initial_site=T2_IT_Bari


if [ $# -ne 2 ]
then
    echo "usage: verify_file <LFN> <sitename>"
    exit
fi

LFN=$1
initial_site=$2
fileName=`basename $LFN`

#
# find out where I am
#
progname=$BASH_SOURCE
#echo progname = $progname

# find install directory, works also with symlinks, see
# http://stackoverflow.com/questions/192319/in-the-bash-script-how-do-i-know-the-script-file-name
thisProg=`test -L "$progname" && readlink "$progname" || echo "$progname"`
thisProgDir=`dirname $thisProg`
#echo thisProg    = $thisProg
echo thisProgDir = $thisProgDir


#
# get SURL and cheksum from PhEDEx
#
PhEDEx_data=`curl -sk "https://cmsweb.cern.ch/phedex/datasvc/json/prod/data?file=${LFN}"`
adler32_PhEDEx=`echo $PhEDEx_data|tr ',' '\n'|grep adler|cut -d ':' -f4`
bytes_PhEDEx=`echo $PhEDEx_data|tr ',' '\n'|grep size|cut -d: -f2|cut -d} -f1`
##adler32_PhEDEx=`curl -sk "https://cmsweb.cern.ch/phedex/datasvc/json/prod/data?file=${LFN}"|tr ',' '\n'|grep adler|cut -d ':' -f4`
PFN=`curl -sk "https://cmsweb.cern.ch/phedex/datasvc/json/prod/lfn2pfn?lfn=${LFN}&node=${initial_site}&protocol=srmv2"|tr ',' '\n'|grep pfn|grep -v lfn2pfn|cut -d '"' -f4`
echo "SURL(pfn for srmv2):" ${PFN}
echo "adler32 from PhEDEx:" ${adler32_PhEDEx}
echo "  bytes from PhEDEx:" ${bytes_PhEDEx}

#
# minimal check, file size from SRM
#
bytes_SRM=`lcg-ls -l -b -T srmv2 ${PFN}|awk '{print $5}'`
echo "  bytes from SRM   :" ${bytes_SRM}


if [ ${bytes_SRM} == ${bytes_PhEDEx} ]
  then
    good=1
    echo "file size at ${initial_site} is OK"
  else
    good=0
    echo "file size at  ${initial_site} is BAD"
    echo "more checks at this site are useless"
  fi
###

echo " Copy file to local /tmp and verify cheksum there [Y/n] ?"

read ANSWER
if [ "${ANSWER}" == "" ] ; then ANSWER="YES"; fi
case "${ANSWER}" in
  y | yes | Y | Yes | YES ) local_check=YES ;;
  * )                       local_check=NO ;;
esac

if [ ${local_check} == YES ]
then
  tmpfile=/tmp/${fileName}
  lcg-cp -v -b -T srmv2 ${PFN} ${tmpfile}
  echo "file copied to local" ${tmpfile}
  adler32_localcopy=`adler32 $tmpfile|cut -d' ' -f1`
  echo "adler32 from local :" ${adler32_localcopy}

  if [ ${adler32_localcopy} == ${adler32_PhEDEx} ]
  then
    good=1
    echo "local copy Adler32 checksum is correct"
  else
    good=0
    echo "local copy corrupted: Adler32 mismatch"
  fi
fi

###

echo "Prepare a crab job to verify checksum on remote site [Y/n] ?"

read ANSWER
if [ "${ANSWER}" == "" ] ; then ANSWER="YES"; fi
case "${ANSWER}" in
  y | yes | Y | Yes | YES ) crab_job=YES ;;
  * )                       crab_job=NO ;;
esac

if [ ${crab_job} == YES ]
then
  site=`echo ${initial_site}| sed -e "s/_Buffer//" | sed -e "s/_MSS//"`
  crabdir=crab_verify_file#${fileName}#${site}#`date +%F#%X`
  mkdir $crabdir
  pushd . > /dev/null
  cd $crabdir 
  ${thisProgDir}/prepare_crab_to_verifyEDMcksum.sh ${LFN} ${adler32_PhEDEx} ${site}
  echo "crab task created in ${crabdir}"

###
  echo "Submit crab job [Y/n] ?"

  read ANSWER
  if [ "${ANSWER}" == "" ] ; then ANSWER="YES"; fi
  case "${ANSWER}" in
    y | yes | Y | Yes | YES ) submit=YES ;;
    * )                       submit=NO ;;
  esac
  if [ ${submit} == YES ]
  then
    crab -submit
  fi
  popd > /dev/null
fi

###

replicas=`curl -sk "https://cmsweb.cern.ch/phedex/datasvc/json/prod/filereplicas?lfn=${LFN}&complete=y"|tr ',' '\n'|grep '"node":'|cut -d ':' -f2| tr -d '"'`

echo "All file replicas are at sites :"
echo $replicas

