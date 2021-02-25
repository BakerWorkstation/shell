#!/bin/bash
# program
#----------------------------------------------------------------------------------
#       这个项目是当在周五时，整理出2000个样本的md5.crc32的名字，发送给10.255.32.99
#
#        2015/03/31 Burning First Beta 1
#----------------------------------------------------------------------------------
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:usr/local/sbin:~/bin:~/sbin
export PATH

/usr/bin/python /opt/gx/to_yiyan/do_query.py # 生成当天日期的目录，在to_yiyan/下

today=`date +"%Y%m%d"`  #  今天的日期
day=`date -d '-'$i' day' +"%Y%m%d"`  # 0代表今天的日期  1代表昨天的日期  2代表前天的日期 。。。。
mulu="/opt/gx/to_yiyan"           
sum=0			# 样本的总和
for i in `seq 0 4`	# i=0时为周五  i=4时为周一 ，五天之内有一天休息，就应该让那天跳过，continue
do			# 这个循环统计出5天之内kingsoft.txt和vds.txt的总和
	day=`date -d '-'$i' day' +"%Y%m%d"`  # 0代表今天的日期  1代表昨天的日期  2代表前天的日期 。。。。
	cd $mulu/$day/
	a=`cat kingsoft.txt | wc -l`
	b=`cat vds.txt      | wc -l`
	let sum=$a+$b+$sum  # 要求总数为2000
       
	if [ $sum -ge 2000 ]  # 总和如果大于等于2000,就进入if的判断
        then
        	echo -e "more than 2000 when handle the dir : $mulu/$day\n" # 输出是在哪个目录累加之后使总和达到2000
        	echo -e "kingsoft.txt = "  $a  # 输出：这个目录下kingsoft.txt的行数
        	echo -e "vbs.txt = "  $b       # 输出：这个目录下vds.txt的行数
		let cha=$sum-2000
        	#cha=` expr $sum-2000`          # 
		echo -e "2000 more than "$cha  # 输出：比2000多打印了多少行
                let pd=$a-$cha          # 计算出最后一个目录下的kingsoft.txt 比$cha（超过2000的数量）多出多少 
		#echo "pd="$pd
		if [ $pd -gt 0 ]   # 如果kingsoft.txt总行数大于$cha,从kingsoft.txt中剪切掉多余的行
                then
                        tail -$pd $mulu/$day/kingsoft.txt > $mulu/kingsoft_$day.txt
                        cp $mulu/$day/vds.txt $mulu/vds_$day.txt
                elif [ $pd -eq 0 ] # 如果kingsoft.txt总行数等于$cha，就舍弃掉kingsoft.txt，只保留vds.txt
		then
                        cp $mulu/$day/vds.txt $mulu/vds_$day.txt
		else   # 如果kingsoft.txt总行数小于$cha，不仅舍弃掉kingsoft.txt,还要从vds.txt剪切一部分
			let cha=$a+$b-$cha
			tail -$cha $mulu/$day/vds.txt > $mulu/vds_$day.txt
		fi
		#day=`date -d '-'$i' day' +"%Y%m%d"`  # 0代表今天的日期  1代表昨天的日期  2代表前天的日期 。。。。
		#echo $day
		scp $mulu/*_$day.txt  10.255.49.42:/opt/sdc/$today/list/ # 把超行数的一对文件修改正常发送给32.99
		rm -f $mulu/*_$day.txt
	let i=$i-1
        break   # 跳出for的整个循环
        fi
done

z=0			#  以下变量的定义及更新，适用于在总和不超过2000的情况下
echo "sum=" $sum
let cha=2000-$sum	#  定义变量cha，表示和目标2000差了多少
rm -f $mulu/$today/1.txt #  删除可能影响到环境的文件，文件可能不存在
while [ $sum -lt 2000 ]  
do
	z_day=`date -d '-'$z' day' +"%Y%m%d"`  # 为了避免进入while循环后，可能影响到i的值，所以用z替换i作新的变量 
	echo -e "the total less than 2000! \n We should fill the gap from the virustotal.txt ! \n"
	head -$cha $mulu/$z_day/virustotal.txt >> $mulu/$today/1.txt   
	hangshu=`cat $mulu/$z_day/virustotal.txt | wc -l ` # 统计文件实际的行数
	if [ $hangshu -lt $cha ]
	then
		let cha=$cha-$hangshu
	fi	
	let sum=$sum+$hangshu     
	echo -e "the total is :\n" $sum
	if [ $sum -ge 2000 ]   # 如果总和达到了2000以上，就把这个文件发送给32.99
	then
		scp  $mulu/$today/1.txt  10.255.49.42:/opt/sdc/$today/list/virustotal.txt
	fi
	let z=$z+1
done  
while [ $i -ge 0 ]     # 按i的值来发送对应天数的文本
do
	mulu="/opt/gx/to_yiyan"           
	day=`date -d '-'$i' day' +"%Y%m%d"`  # 0代表今天的日期  1代表昨天的日期  2代表前天的日期 。。。。
	scp  $mulu/$day/vds.txt  10.255.49.42:/opt/sdc/$today/list/vds_$day.txt
	scp  $mulu/$day/kingsoft.txt  10.255.49.42:/opt/sdc/$today/list/kingsoft_$day.txt
	echo $i
	echo $day
	let i=$i-1
done
scp  $mulu/$today/source_*.txt  10.255.49.42:/opt/sdc/$today/source/
