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

#rm -f /opt/sdc/trans.csv &> /dev/null
function trans_result {
   # ssh 172.16.1.159 "/bin/bash  /opt/watch/trans.sh"
   # scp 172.16.1.159:/opt/watch/172_deriv.txt /opt/sdc/

    ssh 172.16.1.178 "/bin/bash  /opt/watch/trans.sh"
    scp 172.16.1.178:/opt/watch/178_deriv.txt /opt/sdc/
    if [ -e /opt/sdc/178_deriv.txt -a ! -s /opt/sdc/178_deriv.txt ]
    then
        rm /opt/sdc/178_deriv.txt -f
        exit 10
    fi

   # ssh 172.16.1.161 "/bin/bash  /opt/watch/1.sh"
   # scp 172.16.1.161:/opt/watch/161avml.txt /opt/sdc/

   # ssh 172.16.1.165 "/bin/bash  /opt/watch/1.sh"
   # scp 172.16.1.165:/opt/watch/165.txt /opt/sdc/

   # ssh 172.16.1.166 "/bin/bash  /opt/watch/1.sh"
   # scp 172.16.1.166:/opt/watch/166.txt /opt/sdc/

   # ssh 172.16.1.173 "/bin/bash  /opt/watch/1.sh"
   # scp 172.16.1.173:/opt/watch/173deriv.txt /opt/sdc/

   # ssh 172.16.1.174 "/bin/bash  /opt/watch/1.sh"
   # scp 172.16.1.174:/opt/watch/174deriv.txt /opt/sdc/

   # ssh 172.16.1.170 "/bin/bash  /opt/watch/1.sh"
   # scp 172.16.1.170:/opt/watch/170.txt /opt/sdc/

   # ssh 172.16.1.171 "/bin/bash  /opt/watch/1.sh"
   # scp 172.16.1.171:/opt/watch/171.txt /opt/sdc/
}

trans_result

echo "trans information:" > /opt/sdc/trans.csv
cat /opt/sdc/*_deriv.txt >> /opt/sdc/trans.csv
#cp /opt/sdc/trans.csv  /opt/sdc/total1.csv
#rm -f /opt/sdc/*.txt
echo -e "\n-------------总计------------"  >> /opt/sdc/trans.csv 
grep "total" /opt/sdc/trans.csv  | awk -F': ' '{sum+=$NF};END{printf "total:%d\n",sum}' >> /opt/sdc/trans.csv
grep "success" /opt/sdc/trans.csv  | awk -F': ' '{sum+=$NF};END{printf "success:%d\n",sum}' >> /opt/sdc/trans.csv
grep "error" /opt/sdc/trans.csv  | awk -F': ' '{sum+=$NF};END{printf "error:%d\n",sum}' >> /opt/sdc/trans.csv
grep "fail" /opt/sdc/trans.csv  | awk -F': ' '{sum+=$NF};END{printf "fail:%d\n",sum}' >> /opt/sdc/trans.csv
echo -e "-----------------------------------------------------------------\n"        >> /opt/sdc/trans.csv

#count_total=`grep  "total" trans.csv |  awk -F': ' '{print $2}' | wc -l`
#let count_total=$count_total-1
#echo $count_total
#sum_total=0
#for i in `seq 0 $count_total`
#do
#    let sum_total=${total[$i]}+$sum_total
#done
#echo "总数:" $sum_total >> /opt/sdc/total1.csv

cat /opt/sdc/trans.csv | mail -s "deriv_trans结果"   guoxin@antiy.cn  hanwenqi@antiy.cn  guanjinzhong@antiy.cn
rm -f /opt/sdc/trans.csv
rm -f /opt/sdc/*_deriv.txt
