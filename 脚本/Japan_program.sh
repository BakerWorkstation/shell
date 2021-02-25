#!/bin/bash
# program
#------------------------------------------------------------
#	This program for  Japan_program
#
#	 2015/10/22 Burning First Beta 1
#------------------------------------------------------------

#PATH=/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
#export PATH 
week=`date | awk '{print $1}'`
today=`date +"%Y%m%d"`
#echo "$week"


export LANG="en_US.UTF-8"
echo 't' | /usr/bin/svn update /opt/sdc/RIIS_data_new/ > /opt/sdc/newadd.txt

export LANG="zh_CN.utf8"

ssh test@10.255.64.197 "/bin/rm -f /home/test/engine/IIS/input/*"
rm -f /opt/sdc/update/*
echo "已清空"
while [ 1 ]  # 更新每日增量
do
	#list=(`find /opt/sdc/RIIS_data_new/ -type f  -daystart  -ctime 0   -exec ls -lh {} \; | grep -v ".svn" | awk -F/ '{print $5}'`)
	#
	echo "查看newadd.txt文件"
	list=(`grep "avl*.*dat"  /opt/sdc/newadd.txt | awk -F/ '{print $5}' | awk -F"'" '{print $1}' | awk -F'"' '{print $1}'`)
	if [  $list ]
	then
		break
	else
		exit 0
	fi		
done

mkdir /tmp/Japan_program/  -pv &> /dev/null


sleep 30
while [ 1 ] # 挂载input目录到本地
do
	mount //10.255.64.197/test/input /tmp/Japan_program/   -ouser=test,pass=000000
	if [ $? -eq 0 ]
	then
		break
	fi
	sleep 300
done

count=`echo ${#list[@]}` #增量个数

echo "一共获取更新$count个"
for i in `seq $count`
do
	let i=$i-1
	cp /opt/sdc/RIIS_data_new/${list[$i]}  /tmp/Japan_program/
	cp /opt/sdc/RIIS_data_new/${list[$i]}  /opt/sdc/update/
	cp /opt/sdc/RIIS_data_new/${list[$i]}  /opt/sdc/Data
done

umount //10.255.64.197/test/input

# 先去19.220上执行update.sh
ssh test@10.255.64.197 "sh /home/test/engine/IIS/update.sh  > /tmp/update.txt"
sleep 2s
scp test@10.255.64.197:/tmp/update.txt /opt/sdc/
sleep 2s
ssh test@10.255.64.197 "rm -f /tmp/update.txt"
sleep 2s

# 更新成功就执行testavl.sh
grep '.*Update\ sucess\!!\ and\ exit.*' /opt/sdc/update.txt
if [ $? -eq 0 ]
then
	ssh test@10.255.64.197 "sh /home/test/engine/IIS/testavl.sh  > /tmp/testavl.txt"
	sleep 2s
	scp test@10.255.64.197:/tmp/testavl.txt /opt/sdc/
	sleep 2s
	ssh test@10.255.64.197 "rm -f /tmp/testavl.txt"
	sleep 2s
fi

# 扫描成功就执行pack.sh
grep '.*TEST\ FINISHED\ SUCCESSFULLY.*' /opt/sdc/testavl.txt
if [ $? -eq 0 ]
then
	ssh test@10.255.64.197 "sh /home/test/engine/IIS/pack.sh  > /tmp/pack.txt"
	sleep 2s
	scp test@10.255.64.197:/tmp/pack.txt /opt/sdc/
	sleep 2s
	ssh test@10.255.64.197 "rm -f /tmp/pack.txt"
	sleep 2s
fi

# 打包成功就去64.32上执行uplib.sh
grep '.*PACK\ SUCCESSFULLY.*' /opt/sdc/pack.txt
if [ $? -eq 0 ]
then
ssh -tt antiy@10.255.64.32 <<eof 
ssh-agent bash
cd /home/antiy/japan_lib_update/
ssh-add /home/antiy/japan_lib_update/andy
sh /home/antiy/japan_lib_update/uplib.sh
cd /home/antiy/japan_lib_update/backup_git_server && ./bak_git_up.sh
exit
exit
eof
fi

rm -f /opt/sdc/update.txt
rm -f /opt/sdc/testavl.txt
rm -f /opt/sdc/pack.txt

echo -e "\nweek = $week\n"

function upload2vt {
today=`date +"%Y%m%d"`
tar  zcvf  /opt/sdc/$today.tar.gz   /opt/sdc/Data
if [ $? -eq 0 ]
then
lftp  << EOF
open ftp://vsup:xiaoxin2012up@1.62.255.203
cd /mobile/
put /opt/sdc/$today.tar.gz
bye
EOF
fi
}

jugge=`grep -n ERROR /opt/sdc/vt_log.txt`
if [ $? -eq 0 ]
then
   echo $jugge | mail -s '日本库升级失败，请检查' songdancheng@anity.cn
else
    bash /opt/sdc/Japan_watch.sh &
fi

case $week in
	"Mon" )
	upload2vt ;
	;;
	"Tue" )
	upload2vt ;
	;;
	"Wed" )
	upload2vt ;
	;;
	"Thu" )
	upload2vt ;
	;;
	"Fri" )
	upload2vt ;
	;;
	* )
	;;
esac
#count=`/usr/local/bin/zabbix_get -s 172.16.1.179 -p 10050 -k upload_fail`
#yesterday=`date +"%Y-%m-%d" -d "-1 day"`
#echo -e "昨天日期 : $yesterday\n失败个数 : $count" | mail -s "昨日incoming上传失败个数"  songdancheng@antiy.cn guoxin@antiy.cn
