#!/bin/bash
export LANG="zh_CN.utf8"
#!/bin/bash


cd /home/bak_logs/avml/
#list=(`ls -d sd*`)
#count=`ls -d sd* | wc -l`
list=(`find ./ -type d  -daystart -mtime 1 | awk -F"/" '{print $2}' | grep -v "^$"`)
count=`find ./ -type d  -daystart -mtime 1 | awk -F"/" '{print $2}' | grep -v "^$" | wc -l`
> /opt/watch/160avml.txt
for i in `seq $count`
do
        let i=$i-1
        echo ${list[$i]}
        cd ${list[$i]}
        success=`tail -15 trans.log | grep "__main__     INFO     Success Processed:"  | awk -F: '{print $4}' | awk -F, '{print $1}'`
        error=`tail -15 trans.log | grep "__main__     INFO     Total Error:" | awk -F: '{print $4}' | awk -F, '{print $1}'`
        total=`tail -15 trans.log | grep "__main__     INFO     Total Processed:" | awk -F: '{print $4}' | awk -F, '{print $1}'`
        ip=`ifconfig em1:4 | grep "inet addr:" | awk -F":" '{print $2}' | awk '{print $1}'`
        node=`pwd | awk -F"/" '{print $5}'`
        fail=`cat fail_* | wc -l`
        speed=`tail -15 trans.log | grep "__main__     INFO     Success Processed:"  | awk -F: '{print $4}' | awk -F, '{print $2}'`

        echo -e "\nIP地址:" $ip     >> /opt/watch/160avml.txt
        echo "node节点:" $node >> /opt/watch/160avml.txt
        echo "total:" $total    >> /opt/watch/160avml.txt
        echo "success:" $success  >> /opt/watch/160avml.txt
        echo "error:" $error    >> /opt/watch/160avml.txt
        echo "fail:" $fail    >> /opt/watch/160avml.txt
        echo "speed:" $speed    >> /opt/watch/160avml.txt
        cd ..
done
