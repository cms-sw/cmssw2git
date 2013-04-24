#!/bin/bash

list=`hostname`
home_dir=`echo $HOME`
working_dir="$home_dir/integration"

if [ $list == "glidein-2.t2.ucsd.edu" ]; then
  DB_STORAGEPATH="/data/CSstoragePath/DBSize"
else
  source $home_dir/BeforeStart.sh
  DB_STORAGEPATH="/crabprod/CSstoragePath/DBSize"
fi

mkdir -p $working_dir/DBSize
mkdir -p $DB_STORAGEPATH 
echo $DB_STORAGEPATH
# Get the PRODAGENT_WORKDIR in order to get the database file path

workdir=`echo $PRODAGENT_WORKDIR`

#Set DB file path
DBdir2=$workdir"/mysqldata/ibdata2"

#Get DB size
DBSize2=`ls -l $DBdir2 | awk '{print $5}'`

#Get current date to insert DB size datewise
today=`eval date +%Y/%m/%d`


#Add Db size in a db.csv file alongwith the date
echo $today","$DBSize2  >> $working_dir/db.csv

#Get total line in a csv file
#linenumber=`cat db.csv | wc -l`

echo "list is $list"

for cs in $list
do

 name=`echo $cs|awk -F '.' '{print $1}'`
 
HTML_FILE=$working_dir/DBSize/$name.html
echo $HTML_FILE
echo '<html lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>Simple Test</title>
<link rel="stylesheet" type="text/css" href="../graphFiles/jquery.jqplot.css" />
<link rel="stylesheet" type="text/css" href="/graphFiles/examples.css" />
<script language="javascript" type="text/javascript" src="../graphFiles/jquery.js"></script>
<script language="javascript" type="text/javascript" src="../graphFiles/jquery.jqplot.js"></script>
<script language="javascript" type="text/javascript" src="../graphFiles/plugins/jqplot.dateAxisRenderer.js"></script>
<script language="javascript" type="text/javascript" src="../graphFiles/plugins/jqplot.barRenderer.js"></script>
<script language="javascript" type="text/javascript" src="../graphFiles/plugins/jqplot.categoryAxisRenderer.js"></script>
<style type="text/css" media="screen">
.jqplot-axis {   font-size: 0.85em;  } 
 </style>
<script type="text/javascript" language="javascript">' > $HTML_FILE

echo '$(document).ready(function(){   $.jqplot.config.enablePlugins = true;' >> $HTML_FILE
DB=$working_dir/db.csv
tail -28 $DB > $working_dir/last.csv
INPUT=$working_dir/last.csv
OLDIFS=$IFS
IFS=,
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
count=1
totalline=0
rows=0;
firstdate=""
lastdate=""
linenum=1
flag=0
let rows+=`wc $INPUT | awk '{print $1}'`
rem=$(($rows%7))
quot=$(($rows/7))
nline=0
if [ $rem  -eq 0 ]
then
	totalline=$quot
else
	totalline=$(($quot+1))
fi	
last=7
#echo "total line : $totalline"
dem=$((1024*1024*1024))

for (( c=1;c<=$rows;c++ ))
do
	read date1 size1
	if [ $c -eq 1 ]
	then
		firstdate=$date1
        elif [ $c -eq $rows ]
	then
		lastdate=$date1
	fi
	size=`echo $size1/$dem | bc -l`

	r=$(($count%7))

	if [ $r -eq 1 ]
	then
		nline=$(($nline+1))
	fi
#	echo "nline : $nline"
	if [ $nline -eq $totalline ] 
	then
		if [ $rem -eq 0 ]
		then
			last=7
		else
			last=$rem
		fi
	fi		
#	echo "last : $last"	
#	echo "count : $count"	
	
	if [ $rows -eq 1 ]
	then
		line="[["$count","$size"]];"
		flag=1
	elif [ $rows -eq 2 ] 
	then
		if [ $count -eq 1 ]
		then
			line="[["$count","$size"],"
		else
			line=$line"["$count","$size"]];"
			flag=1
		fi
	else
		if [ $nline -eq $totalline ]
		then
			if [ $rem -eq 1 ]
			then
				 line="[["$count","$size"]];"
		                 flag=1
			elif [ $rem -eq 2 ]
			then
				 if [ $count -eq 1 ]
		                then
                		        line="[["$count","$size"],"
                		else
		                        line=$line"["$count","$size"]];"
                		        flag=1
		                fi
			else
				 if [ $count -eq 1 ]
		        	 then
                	        	line="[[$count,$size],"
		                elif [ $count -eq $last ]
                		then
		                        line=$line"["$count","$size"]];"
                		        flag=1
		                else
                		        line=$line"["$count","$size"],"
		                fi
			fi
		else
			if [ $count -eq 1 ]
			then
				line="[[$count,$size],"
			elif [ $count -eq $last ]
			then
				line=$line"["$count","$size"]];"
				flag=1
			else
				line=$line"["$count","$size"],"
			fi
		fi
	fi
	count=$(($count+1))
	if [ $count -eq 8 ]
	then
		count=1
	fi

if [ $flag -eq 1 ]
then
	goog="var line"$linenum"="

	echo "$goog $line" >> $HTML_FILE
	flag=0
linenum=$(($linenum+1))

fi
done < $INPUT
IFS=$OLDIFS

while [ $linenum -le 4 ]
do
 goog="var line"$linenum"= []"
 echo "$goog" >> $HTML_FILE
 linenum=$(($linenum+1))
done

echo "var label= '';
var series = '';
if ((line2.length)==0) {
label= ['week1'];
series=[line1];
}
else if ((line3.length)==0) {
label= ['week1', 'week2'];
series=[line1, line2];
}
else if ((line4.length)==0) {
label= ['week1', 'week2', 'week3'];
series=[line1, line2, line3];
}
else {
label=['week1', 'week2', 'week3', 'week4'];
series=[line1, line2, line3, line4]
}" >> $HTML_FILE
 
echo "plot1 = $.jqplot('chart', series, {
    seriesDefaults:{renderer:$.jqplot.BarRenderer, rendererOptions:{barPadding:10, barMargin:10}},
    legend: {show:true, 
             location: 'nw',
             labels:label
  },
   axes:{xaxis:{renderer:$.jqplot.CategoryAxisRenderer, rendererOptions:{sortMergedLabels:true}}, yaxis:{min:0, max:10, numberTicks:10}}

//    axes:{xaxis:{renderer:$.jqplot.CategoryAxisRenderer, rendererOptions:{sortMergedLabels:true}}}
    });
 });
 </script>" >> $HTML_FILE
echo '</head>
 <body>
<table border=0>
<tr>
<td width="5%" align=right><font face verdana size=2 color=green><b></b></font></td>
<td align=center><font face verdana size=2 color=green><b>From '$firstdate' to ' $lastdate'</b></font></td>
</tr>

<tr>
<td width="5%" align=right><font face verdana size=2 color=green><b>Gb</b></font></td>
<td align=center><div id="chart" style="margin-top:20px; margin-left:20px; width:80%; height:300px;"></div></td>
</tr>
<tr>
<td width="5%">
</td>
<td align=center><font face=verdana size=2 color=green><b>Days in a Week</></font></td></tr>
<tr>
<td width="5%">
</td>
<td align=center><font face=verdana size= color=black><b>'$name'</></font></td></tr>

</table>
 </body>
</html>' >> $HTML_FILE

cp $HTML_FILE $DB_STORAGEPATH

done
