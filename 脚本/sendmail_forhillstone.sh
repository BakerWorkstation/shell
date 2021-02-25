#!/bin/bash

PATH=/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
export PATH    
export LANG="zh_CN.utf8"

testok=`grep -c  "没有问题"  /opt/sdc/md5_value.txt`
pcapok=`grep -c  "pcap包剩余量"  /opt/sdc/md5_value.txt`
if [ $testok -eq 3 ] && [ $pcapok -eq 1 ]
then
	cat /opt/sdc/md5_value.txt | mail -s "给山石的PCAP包校验结果"  songdancheng@antiy.cn   guoxin@antiy.cn   hanwenqi@antiy.cn   tongzhiming@antiy.cn   supeiwang@antiy.cn
	rm -f /opt/sdc/md5_value.txt
else
	echo "pcap包检验存在问题，请查看"  | mail -s "给山石的PCAP包校验结果"  songdancheng@antiy.cn
fi
