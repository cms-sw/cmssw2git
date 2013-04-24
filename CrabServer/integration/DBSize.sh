#!/bin/bash

#This script will run as a crontab on daily basis and get the DB size and insert into db.csv file. The db.csv file keeps the 4 weeks (28 days) record

# Get the PRODAGENT_WORKDIR in order to get the database file path
source /home/crab/BeforeStart.sh
workdir=`echo $PRODAGENT_WORKDIR`

#Set DB file path
DBdir2=$workdir"/mysqldata/ibdata2"

#Get DB size
DBSize2=`ls -l $DBdir2 | awk '{print $5}'`

#Get current date to insert DB size datewise
today=`eval date +%Y/%m/%d`


#Add Db size in a db.csv file alongwith the date
echo $today","$DBSize2  >> /home/crab/integration/db.csv

#Get total line in a csv file
#linenumber=`cat db.csv | wc -l`

#In order to keep only the last 28 days record, we check the line number, if record exceed 30 then delete the first/oldest record from the file
#if [ $linenumber -ge 28 ]
#then
#	sed -i '1d' /home/crab/integration/db.csv
#fi
