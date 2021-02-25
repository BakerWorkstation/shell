#!/bin/bash

PATH=/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
export PATH
export LANG="zh_CN.utf8"

echo "`date`"  >  /opt/sdc/log.txt
echo "159上情况统计"  >>  /opt/sdc/log.txt
list_159=(`/usr/local/bin/zabbix_get -s 172.16.1.159 -p 10050 -k diskfree`)

string=''
for i in `seq ${#list_159[@]}`
do
	let i=$i-1
	string=`echo -e "$string\t${list_159[$i]}"`
	last=`echo $[$i+1]%6 | bc`
	if [ $last -eq 0 ]
	then
		if [ $i -eq 0 ]
		then
			continue
		fi
		echo -e "$string" >> /opt/sdc/log.txt
		string=''
	fi
done

echo -e  "\n172上情况统计"  >>  /opt/sdc/log.txt
list_172=(`/usr/local/bin/zabbix_get -s 172.16.1.172 -p 10050 -k diskfree`)

string=''
for i in `seq ${#list_172[@]}`
do
	let i=$i-1
	string=`echo -e "$string\t${list_172[$i]}"`
	last=`echo $[$i+1]%6 | bc`
	if [ $last -eq 0 ]
	then
		if [ $i -eq 0 ]
		then
			continue
		fi
		echo -e "$string" >> /opt/sdc/log.txt
		string=''
	fi
done

echo -e "\n177上情况统计"  >>  /opt/sdc/log.txt
list_177=(`/usr/local/bin/zabbix_get -s 172.16.1.177 -p 10050 -k diskfree`)

string=''
for i in `seq ${#list_177[@]}`
do
	let i=$i-1
	string=`echo -e "$string\t${list_177[$i]}"`
	last=`echo $[$i+1]%6 | bc`
	if [ $last -eq 0 ]
	then
		if [ $i -eq 0 ]
		then
			continue
		fi
		echo -e "$string" >> /opt/sdc/log.txt
		string=''
	fi
done

echo -e "\n178上情况统计"  >>  /opt/sdc/log.txt
list_178=(`/usr/local/bin/zabbix_get -s 172.16.1.178 -p 10050 -k diskfree`)

string=''
for i in `seq ${#list_178[@]}`
do
	let i=$i-1

	string=`echo -e "$string\t${list_178[$i]}"`
	last=`echo $[$i+1]%6 | bc`
	if [ $last -eq 0 ]
	then
		if [ $i -eq 0 ]
		then
			continue
		fi
		echo -e "$string" >> /opt/sdc/log.txt
		string=''
	fi
done

echo -e "\n167上情况统计"  >>  /opt/sdc/log.txt
list_167=(`/usr/local/bin/zabbix_get -s 172.16.1.167 -p 10050 -k diskfree`)

string=''
for i in `seq ${#list_167[@]}`
do
	let i=$i-1

	string=`echo -e "$string\t${list_167[$i]}"`
	last=`echo $[$i+1]%6 | bc`
	if [ $last -eq 0 ]
	then
		if [ $i -eq 0 ]
		then
			continue
		fi
		echo -e "$string" >> /opt/sdc/log.txt
		string=''
	fi
done

echo -e "\n205上情况统计"  >>  /opt/sdc/log.txt
list_205=(`/usr/local/bin/zabbix_get -s 172.16.1.205 -p 10050 -k diskfree`)

string=''
for i in `seq ${#list_205[@]}`
do
	let i=$i-1

	string=`echo -e "$string\t${list_205[$i]}"`
	last=`echo $[$i+1]%6 | bc`
	if [ $last -eq 0 ]
	then
		if [ $i -eq 0 ]
		then
			continue
		fi
		echo -e "$string" >> /opt/sdc/log.txt
		string=''
	fi
done

cat /opt/sdc/log.txt | mail -s "存储服务器硬盘使用情况"  songdancheng@antiy.cn  guoxin@antiy.cn  hanwenqi@antiy.cn
rm -f /opt/sdc/log.txt

