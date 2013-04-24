#!/bin/bash

source $HOME/BeforeStart.sh
if [ $HOSTNAME == "hcc-crabserver.unl.edu" ]; then
  datapath="/crab"
  export used=`df -h | grep $datapath | awk '{print $4}' | sed -e 's/%/ /g'`
else
  datapath=${STORAGEPATH}
  export used=`df -h | grep $datapath | awk '{print $5}' | sed -e 's/%/ /g'`
fi

echo $used

#echo "used is $used"

if [ "$used" -ge 90 ]; then
  crabServerd --shut
  crontab -l > $HOME/mycron
  sed -i '/component.sh/s/^/#/' $HOME/mycron
  crontab $HOME/mycron
  rm $HOME/mycron
  SUBJECT="CRAB server stopped in `/bin/hostname`: disk 90% full"
  EMAIL="jletts@ucsd.edu, stefano.belforte@cern.ch, lolass@cern.ch, Federica.Fanzago@cern.ch"
  #EMAIL="lolass@cern.ch"
  echo -e "Disk is 90% full. CRAB server has been stopped. Please do the following: \n \t-clean the disk \n\t-start CRAB server \n\t-uncomment in the cron list (crontab -e) the following line : 45 * * * * /home/crab/integration/component.sh >/dev/null 2>&1" | /bin/mail -s "$SUBJECT" "$EMAIL"
elif [ "$used" -ge 80  ]; then
  echo -e "Disk is 90% full. CRAB server has been stopped. Please do the following: \n \t-clean the disk \n\t-start CRAB server \n\t-uncomment in the cron list (crontab -e) the following line : 45 * * * * /home/crab/integration/component.sh >/dev/null 2>&1" | /bin/mail -s "$SUBJECT" "$EMAIL"
  SUBJECT="Disk 80% full on `/bin/hostname` crabserver"
  EMAIL="jletts@ucsd.edu, stefano.belforte@cern.ch, lolass@cern.ch, Federica.Fanzago@cern.ch"
  #EMAIL="lolass@cern.ch"
  echo "Disk is 80% full. Please clean the disk or the CRAB server will be stopped reached the 90% of used disk" | /bin/mail -s "$SUBJECT" "$EMAIL"
fi
