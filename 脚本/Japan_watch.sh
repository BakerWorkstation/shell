#!/bin/bash
# program
#------------------------------------------------------------
#       这个脚本用来检测日本项目的病毒库升级是否成功
#
#        2015/04/08 Burning First Beta 1
#------------------------------------------------------------
PATH=/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
export PATH    
export LANG="zh_CN.utf8"

while [ 1 ]
do
#scp test@10.255.64.197:/home/test/engine/IIS/input/* /opt/sdc/update/

ssh antiy@10.255.64.32 "cd /home/antiy/japan_lib_update/avldb-update && git log | head -5 >/tmp/zz.txt"
sleep 2s
scp antiy@10.255.64.32:/tmp/zz.txt /opt/sdc
sleep 2s
ssh antiy@10.255.64.32  rm -f /tmp/zz.txt

date=`cat /opt/sdc/zz.txt | awk 'NR==5{print $1}'`
today=`date +"%Y%m%d"`
z=`ls /opt/sdc/update | wc -l`
echo -e  "\n共增加了$z个更新\n" >> /opt/sdc/zz.txt
sed -i  '1i 更新信息如下:' /opt/sdc/zz.txt
        if [ $date = $today ]
        then
                mail -v -s '日本项目-升级成功'  songdancheng@antiy.cn  guoxin@antiy.cn  hanwenqi@antiy.cn   < /opt/sdc/zz.txt
                let i=1
                rm -f /opt/sdc/zz.txt
		rm -f /opt/sdc/update/*
                break
        fi
rm -f /opt/sdc/zz.txt
sleep 1h
done
