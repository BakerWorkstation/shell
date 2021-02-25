#!/bin/bash

dir=$1
mkdir result
cd $1
list=(`ls *.log`) 
count=`ls *.log| wc -l`

j=0
echo -e "一共有$count个文件\n"
for i in `seq $count`
do
	let i=$i-1
	sed -i '/ WebSitePlatform/d '  ${list[$i]}
	name=`echo ${list[$i]} | awk -F'.' '{print  $1}'`
	lines=`cat ${list[$i]} | wc -l`

	if [ $lines -ge 100000 ]
	then	
		#echo "$lines"
		zhengshu=`expr $lines / 100000`
		xiaoshu=`expr $lines % 100000`
		#echo  "整数:$zhengshu"
		#echo  "小数:$xiaoshu"
		if [ $xiaoshu -ne 0 ]
		then
			let end=$zhengshu+1
			tail -$xiaoshu  ${list[$i]} | awk '{print $1}'  >  ../result/"$name"_"$end".txt
		fi
		for  a in `seq 1 $zhengshu`
		do 
			b=`expr $a \* 100000`
			head  -$b ${list[$i]} | tail -100000 | awk '{print $1}' >  ../result/"$name"_"$a".txt
			
		done


	else
		awk  '{print $1}'  ${list[$i]}  >  ../result/"$name".txt
	fi

	let j=$j+1
	echo "已处理$j个"
done
unix2dos ../result/*
