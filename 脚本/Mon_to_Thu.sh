#!/bin/bash
# program
#----------------------------------------------------------------------------------
#       这个项目是当在周一到周四时，整理出1000个样本的md5.crc32的名字，发送给10.255.32.99
#
#        2015/03/31 Burning First Beta 2
#----------------------------------------------------------------------------------
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:usr/local/sbin:~/bin:~/sbin
export PATH

today=`date +"%Y%m%d"`      # 当天的日期 
/usr/bin/python /opt/gx/to_yiyan/do_query.py # 生成当天日期的目录，在to_yiyan/下
cd /opt/gx/to_yiyan/$today/
count=`tail -1000 virustotal.txt | wc -l`
if [ $count -ge 1000 ]
then
	tail -1000 virustotal.txt > 1.txt
	scp  /opt/gx/to_yiyan/$today/1.txt 10.255.49.42:/opt/sdc/$today/list
	scp  /opt/gx/to_yiyan/$today/source*  10.255.49.42:/opt/sdc/$today/list
fi
