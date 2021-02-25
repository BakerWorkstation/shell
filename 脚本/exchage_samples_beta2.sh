#!/bin/bash
# program
#------------------------------------------------------------
#	This program for  exchange of samples. 
#
#	 2015/04/07 Burning First Beta 2
#------------------------------------------------------------
PATH=/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
export PATH    

day=`date +"%Y%m%d"`      # 当天的日期 
clear
cd /opt/sdc/  # 创建当天的目录
mkdir -p $day/{list,source} 

function Mon_to_Thu {
#-----------------------------------------
#编辑好需要在251上执行周一到周四的远程拷贝脚本
#-----------------------------------------
	ssh 10.255.32.251 "python  /opt/gx/to_yiyan/testsample_download.py  `date |awk '{print $1}'`"
	day=`date +"%Y%m%d"`      # 当天的日期 
	cd /opt/sdc/$day/list/
	count=`cat 1.txt | wc -l`   # 判断1.txt 是否是1000行，如果不是，中断并以5退出
	if [ $count -ne 1000 ]
	then
		exit 5
	fi
	mv 1.txt virustotal.txt
	unix2dos source_*
	mv source_* ../source/
#	rm -f /opt/sdc/*.txt
	cp virustotal.txt /opt/sdc/
}


function Friday {
#-----------------------------------------
#编辑好需要在251上执行周五的远程拷贝脚本
#-----------------------------------------
	ssh 10.255.32.251 "bash  /opt/gx/to_yiyan/Friday.sh"
	day=`date +"%Y%m%d"`      # 当天的日期 
	cd /opt/sdc/$day/list/
	count=`cat *.txt | wc -l`   # 判断1.txt 是否是2000行，如果不是，中断并以5退出
	if [ $count -ne 2000 ]
	then
		exit 5
	fi
#	rm -f /opt/gx/yiyan/*.txt  # 把文件复制到/opt/gx/yiyan/之前，先删除下昨天的日志文件。
	cat *.txt > /opt/sdc/virustotal.txt
	mv source_* ../source/
	unix2dos /opt/sdc/$day/source/source_*
}

week=`date | awk '{print $1}'`  #提取当天是星期几  Mon、Tue、Wed、Thu、Fri 代表 星期{1、2、3、4、5}
case $week in
    "Mon")
	Mon_to_Thu ;
	;;
    "Tue")
	Mon_to_Thu ;
	;;
    "Wed")
	Mon_to_Thu ;
	;;
    "Thu")
	Mon_to_Thu ;
	;;
#    "Fri")
#	Friday ;
#	;;
    *)
	exit 10
	;;
esac

cd /opt/sdc/
awk '{print $1}' virustotal.txt > sample.txt

python /opt/sdc/download_sample.py /opt/sdc/sample.txt 

rm -f status.txt  sample.txt virustotal.txt

ls sample_1/* | awk -F"." '{a=$0;b=$1;system("mv "a" "b"")}'
cd sample_1
ls * > /opt/sdc/$day/1.txt

cd /opt/sdc/$day/
mv 1.txt $day"_sample".txt
unix2dos $day"_sample".txt
mv /opt/sdc/sample_1 /opt/sdc/$day/$day"_sample"

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
echo -e "list/*.txt':  有$c行\n"
