#!/bin/bash
# program
#------------------------------------------------------------
#	This program for  exchange of samples. 
#
#	 2015/04/07 Burning First Beta 1
#------------------------------------------------------------
PATH=/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
export PATH    

day=`date +"%Y%m%d"`      # 当天的日期 


cd /opt/sdc/$day/list/
mv 1.txt virustotal.txt
unix2dos source_*
mv source_* ../source/
cp virustotal.txt /opt/sdc/

cd /opt/sdc
awk '{print $1}' virustotal.txt > sample.txt


python download_sample.py sample.txt 

rm -f  status.txt error.txt sample.txt virustotal.txt

ls sample_1/* | awk -F"." '{a=$0;b=$1;system("mv "a" "b"")}'

cd sample_1
ls * > /opt/sdc/$day/1.txt

cd /opt/sdc/$day/
mv 1.txt $day"_sample".txt
unix2dos $day"_sample".txt
mv /opt/sdc/sample_1 ./$day"_sample"

echo -e "\n\t开始上传到ftp服务器，请等待......\n"
lftp  << FI
open ftp://test:O44Zag4vaKQfIawLvdlX@10.255.49.50
cd /VTsample/sample
lcd /opt/sdc/
mirror -R $day
close
bye
FI

echo -e "\n\t上传已完成！\n"
# 验证
cd /opt/sdc/$day/
z=`cat "$day"_sample.txt | wc -l`
x=`ls "$day"_sample/ | wc -l`
c=`cat list/*.txt | wc -l`
echo -e "$day'_sample.txt': 有$z行\n"
echo -e "$day'_sample/':  有$x个样本\n"
echo -e "list/*.txt':  有$c个行\n"
