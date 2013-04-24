#!/bin/sh

day=`date +%F`
tim=`date +%H`

string=`echo $day ${tim}:`

export HOSTNAME=`/bin/hostname`
export global=0
export csw=-1
export wk=""
export file=CommandManager/ComponentStatus.txt
export HOME_CRAB=`echo $HOME`

####################################################################
#Get the PRODAGENT_WORKDIR in order to get the Component directories
####################################################################
source $HOME_CRAB/BeforeStart.sh
cd $PRODAGENT_WORKDIR

echo "Starting the Log parsing for the components for `/bin/hostname`" > $file
echo "========================================================================" >> $file

for i in `echo JobTracking  GetOutput  CrabJobCreator  CrabServerWorker  ErrorHandler  AdminControl  Notification  TaskTracking  TaskRegister  TaskLifeManager`
do
  ####################################################################
  #Checking ComponentLog of each component for current hour
  ####################################################################
  grep -il "$string" ${i}/ComponentLog >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    export global=1
    echo "$i - WARNING NOT OK: Please check the ${i}/ComponentLog - Last check = $string" >> $file
  else
    ###################################################################
    #Check CSW for lost workers threads for this hour
    ###################################################################
    if [ "$i" == "CrabServerWorker" ]; then
      for j in 0 1 2 3 4
      do
        export wk=`cat ${i}/ComponentLog | grep -P "\b$string\b" | grep -P "\bworker_$j\b" | tail -1`
#        echo $wk
        if [ "$wk" != "" ]; then
          csw=`expr $csw + 1`
        else
          export csw=0
        fi
      done
    else
      echo "$i - OK" >> $file
    fi
  fi
done

###########################################################################
#If a component is stuck the send an email to CS experts and restart it
###########################################################################
if [ $global -ne 0 ]; then
  
  export var=`crabMysql status | grep error`
  for k in 0 1 2 3
  do
    if [ $k -eq 3 ]; then
        SUBJECT="Check the crabserver on `/bin/hostname`"
        EMAIL="jletts@ucsd.edu, Sanjay.Padhi@cern.ch, stefano.belforte@c.ch, Federica.Fanzago@cern.ch , lolass@cern.ch"
        echo "There is a problem with the database. Restart did not work " | /bin/mail -s "$SUBJECT" "$EMAIL"
        sleep 240
        break
    fi

    crabMysql status
    cmd=$?
    
    if [ !  -z "$var"] || [ "$cmd" -ne 0 ]; then
      crabMysqlStart
      sleep 240
    else
      SUBJEC="Check the crabserver on `/bin/hostname`"
      EMAIL="jletts@ucsd.edu, Sanjay.Padhi@cern.ch, stefano.belforte@cern.ch, Federica.Fanzago@cern.ch, lolass@cern.ch"
      EMAILMESSAGE=$file
      /bin/mail -s "$SUBJECT" "$EMAIL" < $EMAILMESSAGE
      sleep 240
      break
    fi
  done
fi

for i in `grep NOT $file | awk '{print $1}'`
do
  crabServerd --component $i --shut
  crabServerd --component $i --start
  sleep 120
done

##########################################################################
#If all workers of CSW are lost then restart it
##########################################################################
if [ "$csw" -eq 0 ]; then
 
  export var=`crabMysql status | grep error`
  for k in 0 1 2 3
  do
    if [ $k -eq 3 ]; then
        SUBJECT="Check the crabserver on `/bin/hostname`"
        EMAIL="jletts@ucsd.edu, Sanjay.Padhi@cern.ch, stefano.belforte@cern.ch, Federica.Fanzago@cern.ch, lolass@cern.ch"
        echo "There is a problem with the database. Restart did not work " | /bin/mail -s "$SUBJECT" "$EMAIL"
        sleep 240
        break
    fi

    crabMysql status
    cmd=$?
    
    if [ !  -z "$var"] || [ "$cmd" -ne 0 ]; then
      crabMysqlStart
      sleep 240
    else
      crabServerd --component CrabServerWorker --shut
      crabServerd --component CrabServerWorker --start 
      sleep 120
      break
    fi
  done
fi


#########################################################################
#Check CS components through CrabServerd --status command and if any
#component is not running then restart it
#########################################################################
for i in `crabServerd --status | grep NOT | awk '{print $2}'`
do
  export var=`crabMysql status | grep error`
  for k in 0 1 2 3
  do
    if [ $k -eq 3 ]; then
        SUBJECT="Check the crabserver on `/bin/hostname`"
        EMAIL="Sanjay.Padhi@cern.ch, stefano.belforte@cern.ch, Federica.Fanzago@cern.ch, lolass@cern.ch, jletts@ucsd.edu"
        echo "There is a problem with the database. Restart did not work " | /bin/mail -s "$SUBJECT" "$EMAIL"
        sleep 240
        break
    fi

    crabMysql status
    cmd=$?
    
    if [ !  -z "$var"] || [ "$cmd" -ne 0 ]; then
      echo "restart crabMysqlStart"
    else
      crabServerd --component $i --shut
      crabServerd --component $i --start
      sleep 120
      break
    fi
  done
done

                                                
