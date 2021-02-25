#!/bin/bash
# program
#------------------------------------------------------------
#       
#        对存储trans的结果的检测
#        2015/06/9 sdc First Beta 1
#------------------------------------------------------------
PATH=/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
export PATH

export LANG="zh_CN.utf8"

function check_result {
    ssh 172.16.1.178 "/bin/bash  /opt/watch/check.sh"
    scp 172.16.1.178:/opt/watch/178_check.txt /opt/sdc/
    if [ -e /opt/sdc/178_check.txt -a ! -s /opt/sdc/178_check.txt ]
    then
	rm -f /opt/sdc/178_check.txt
        exit 10
    fi
   # ssh -p 25813 172.16.1.250 "/bin/bash  /opt/watch/check.sh"
   # scp -P 25813 172.16.1.250:/opt/watch/check250.txt /opt/sdc/

   # ssh 172.16.1.161 "/bin/bash  /opt/watch/check.sh"
   # scp 172.16.1.161:/opt/watch/check161.txt /opt/sdc/

   # ssh 172.16.1.166 "/bin/bash  /opt/watch/check.sh"
   # scp 172.16.1.166:/opt/watch/check166.txt /opt/sdc/

   # ssh 172.16.1.170 "/bin/bash  /opt/watch/check.sh"
   # scp 172.16.1.170:/opt/watch/check170.txt /opt/sdc/

   # ssh 172.16.1.171 "/bin/bash  /opt/watch/check.sh"
   # scp 172.16.1.171:/opt/watch/check171.txt /opt/sdc/

   # ssh  172.16.1.165 "/bin/bash  /opt/watch/check.sh"
   # scp  172.16.1.165:/opt/watch/check165.txt /opt/sdc/

   # ssh  172.16.1.173 "/bin/bash  /opt/watch/check.sh"
   # scp  172.16.1.173:/opt/watch/173check.txt /opt/sdc/

   # ssh  172.16.1.174 "/bin/bash  /opt/watch/check.sh"
   # scp  172.16.1.174:/opt/watch/174check.txt /opt/sdc/
}


check_result

echo "check information:" > /opt/sdc/check.csv
cat /opt/sdc/*_check.txt   >> /opt/sdc/check.csv

echo -e "\n-------------总计------------"  >> /opt/sdc/check.csv 
grep "total" /opt/sdc/*_check.txt  | awk -F': ' '{sum+=$NF};END{printf "total:%d\n",sum}' >> /opt/sdc/check.csv
grep "success" /opt/sdc/*_check.txt  | awk -F': ' '{sum+=$NF};END{printf "success:%d\n",sum}' >> /opt/sdc/check.csv
grep "error" /opt/sdc/*_check.txt  | awk -F': ' '{sum+=$NF};END{printf "error:%d\n",sum}' >> /opt/sdc/check.csv
grep "fail" /opt/sdc/*_check.txt  | awk -F': ' '{sum+=$NF};END{printf "fail:%d\n",sum}' >> /opt/sdc/check.csv
echo -e "-----------------------------------------------------------------\n"        >> /opt/sdc/check.csv
#count_total=`grep  "total" check.csv |  awk -F': ' '{print $2}' | wc -l`
#let count_total=$count_total-1
#echo $count_total
#sum_total=0
#for i in `seq 0 $count_total`
#do
#    let sum_total=${total[$i]}+$sum_total
#done
#echo "总数:" $sum_total >> /opt/sdc/total1.csv
cat /opt/sdc/check.csv | mail -s "deriv_check结果"   guoxin@antiy.cn  hanwenqi@antiy.cn  guanjinzhong@antiy.cn
rm -f /opt/sdc/check.csv
rm -f /opt/sdc/*_check.txt
