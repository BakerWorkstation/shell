#!/bin/bash
#-------------------------------------------------------------
#	校验每天提供给山石的PCAP包	beta1
#			--------> Burning.
#-------------------------------------------------------------

PATH=/usr/lib64/qt-3.3/bin:/opt/htt/temp_20140611/java/apache-maven-3.2.3/bin:/bin:/opt/htt/java/ant//bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/lib/jdk1.8.0_25/bin:/opt/htt/temp_20140611/software/node-v0.10.33-linux-x64/bin:/opt/htt/temp_20140611/java/scala-2.11.4/bin:/usr/local/redis/bin:/root/bin
export PATH    

export LANG="zh_CN.utf8"

today=`date +"%Y%m%d"`
#-----------------------------------------------------------
while [ 1 ]
do
a=`lftp  << FI
open ftp://antiy:antiy@release.hillstonenet.com
cd /PCAP/$today/
ls *.txt
close 
bye
FI
`
b=`echo $a | awk '{print $9}'`  #取病毒名文件
Virusname="$today""_VirusName.txt"
echo "$b"
echo "$Virusname"
if [ "$b" = "$Virusname" ]
then
	break
else
	sleep 600
fi
done
#-----------------------------------------------------------
list=(`ls /opt/shanshi/$today/ | grep -v "scr"`)
count=`ls /opt/shanshi/$today/ | grep -v "scr" | wc -l`

# 把上传给山石的PCAP包进行下载校验
mkdir /opt/work/from_hillstone_down/  &> /dev/null
lftp  << FI
open ftp://antiy:antiy@release.hillstonenet.com
cd /PCAP/
lcd /opt/work/from_hillstone_down/
mirror -c --parallel=number /PCAP/$today/  /opt/work/from_hillstone_down/
close
bye
FI

# 校验文件的md5值，进行比对
md5_key=1
echo "+++++++++++++++++++++++++++++++++++++"   >  /opt/work/md5_value.txt
echo "文件md5比较:" >> /opt/work/md5_value.txt
for i in `seq $count`
do
	let i=$i-1
	md5_value_local=`md5sum /opt/shanshi/$today/${list[$i]} | awk '{print $1}' | tr [[:lower:]] [[:upper:]]`
	md5_value_remote=`md5sum /opt/work/from_hillstone_down/$today/${list[$i]} | awk '{print $1}' | tr [[:lower:]] [[:upper:]]`
	if [ "$md5_value_local" != "$md5_value_remote" ]
	then
		echo "${list[$i]}" | mail -s "md5_value  not right"  songdancheng@antiy.cn
		let md5_key=0
	fi
	echo "file:${list[$i]}"  >>  /opt/work/md5_value.txt
	echo "local:$md5_value_local"   >>  /opt/work/md5_value.txt
	echo -e "remote:$md5_value_remote\n"  >>  /opt/work/md5_value.txt
done
echo "md5_key=$md5_key"
if [ $md5_key -eq 1 ]
then
	echo "结论：md5值校验没有问题"  >>  /opt/work/md5_value.txt
	echo "+++++++++++++++++++++++++++++++++++++"   >>  /opt/work/md5_value.txt
fi
# 检查上传文件的数量、后缀名和病毒名列表
cd /opt/work/from_hillstone_down/$today/
tar_list=(`ls /opt/work/from_hillstone_down/$today/*.tgz`)
tar_count=`ls /opt/work/from_hillstone_down/$today/*.tgz | wc -l`
sum=0
for j in `seq $tar_count`
do
	let j=$j-1
	tar zxvf ${tar_list[$j]}
	pcap_dir=`echo ${tar_list[$j]} | awk -F'.' '{print $1}'`
	pcap_count=`ls "$pcap_dir"/*.pcap|wc -l`
	let sum=$sum+$pcap_count
done

echo "sum=$sum"

# PCAP包数量校验
sum_key=1
if [ $sum -lt 3500 ]
then
	echo -e "\nPCAP包数量小于3500!!!!\n" | mail -s "PCAP_count problem" songdancheng@antiy.cn
	let sum_key=0
fi
echo -e "\n带有'.pcap'后缀的文件数:$sum个\n"  >>  /opt/work/md5_value.txt
if [ $sum_key -eq 1 ]
then
	echo "结论：PCAP包('.pcap'后缀)数量校验没有问题"  >>  /opt/work/md5_value.txt
fi
echo "+++++++++++++++++++++++++++++++++++++"   >>  /opt/work/md5_value.txt

# 病毒名列表数量校验
virusname_key=1
virusname_count=`cat "$today"_VirusName.txt | awk '{print $2}' | grep  -v "^$"|  wc -l`
if [ $virusname_count -lt 3500 ]
then
	echo -e "\n病毒名列表数量小于3500!!!!!\n" | mail -s "virusname_count problem" songdancheng@antiy.cn
	let virusname_key=0
fi
echo -e  "\n病毒名列表数量:$virusname_count个\n"  >>  /opt/work/md5_value.txt
if [ $virusname_key -eq 1 ]
then
	echo "结论：病毒名列表数量校验没有问题"  >>  /opt/work/md5_value.txt
fi
echo "+++++++++++++++++++++++++++++++++++++"   >>  /opt/work/md5_value.txt

#cat /opt/work/md5_value.txt | mail -s "给山石的PCAP包校验结果" songdancheng@antiy.cn
rm -rf /opt/work/from_hillstone_down  &> /dev/null

surplus=`ls /opt/shanshi/Network/ | grep "\.pcap$" |wc -l`
#echo "$surplus"  > /opt/work/pcap_surplus.txt
week=`echo "scale=0;$surplus/10500"|bc`

echo "$surplus"
echo "$week"
echo -e "pcap包剩余量:$surplus\n无供给前提下，还够$week周的数据"   >>  /opt/work/md5_value.txt

cat << EOF > /opt/work/send_md5value.exp
#!/usr/bin/expect -f
set timeout 30
spawn scp /opt/work/md5_value.txt 10.255.49.42:/opt/sdc/
expect "password:"
send "EyywL8QbMnGTyVEa8M3\r"
sleep 2
spawn ssh 10.255.49.42 "bash /opt/sdc/sendmail_forhillstone.sh"
expect "password:"
send "EyywL8QbMnGTyVEa8M3\r"
expect eof
EOF
expect -f /opt/work/send_md5value.exp
rm -f /opt/work/send_md5value.exp
rm -f /opt/work/md5_value.txt
