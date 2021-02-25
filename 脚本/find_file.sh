#!/bin/bash

function  deal_file(){
now_time=`date +'%Y-%m-%d %H:%M:%S'`

#find /var/ftp/pub/routingdata -type f  -daystart -mtime +2
list1=(`find /var/ftp/pub/routingdata -type f -mtime +2`)


list2=(`find /var/ftp/pub/keydata -type f  -mtime +3`)

list3=(`find /var/ftp/pub/readme -type f   -mtime +179`)


for filename1 in ${list1[*]}
do
	#echo $filename1
	size1=`ls -lh $filename1 |awk '{print $5}'`
	m_time1=`stat $filename1 |  grep "Modify" |awk '{print $2}'`
	len1=`expr length "$size1"`
	echo -ne "$now_time\t$m_time1\t$size1" >> /root/log/routingdata.log
	cha1=`expr 8 - $len1`
	for i in `seq $cha1`
	do
		echo -ne " " >> /root/log/routingdata.log
	done
	
	rm -f $filename1
	if [ $? -eq 0 ]
	then
		echo -e "$filename1" >> /root/log/routingdata.log
	fi
done

for filename2 in ${list2[*]}
do
	#echo $filename
	size2=`ls -lh $filename2 |awk '{print $5}'`
	m_time2=`stat $filename2 |  grep "Modify" |awk '{print $2}'`
	len2=`expr length "$size2"`
	echo -ne "$now_time\t$m_time2\t$size2" >> /root/log/keydata.log
	cha2=`expr 8 - $len2`
	for i in `seq $cha2`
	do
		echo -ne " " >> /root/log/keydata.log
	done
	
	rm -f $filename2
	if [ $? -eq 0 ]
	then
		echo -e "$filename2" >> /root/log/keydata.log
	fi
done

for filename3 in ${list3[*]}
do
	#echo $filename
	size3=`ls -lh $filename3 |awk '{print $5}'`
	m_time3=`stat $filename3 |  grep "Modify" |awk '{print $2}'`
	len3=`expr length "$size3"`
	echo -ne "$now_time\t$m_time3\t$size3" >> /root/log/readme.log
	cha3=`expr 8 - $len3`
	for i in `seq $cha3`
	do
		echo -ne " " >> /root/log/readme.log
	done
	
	rm -f $filename3
	if [ $? -eq 0 ]
	then
		echo -e "$filename3" >> /root/log/readme.log
	fi
done
}
deal_file
