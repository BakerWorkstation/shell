#! /bin/bash

count=0
function func(){

for file in `ls $1`
	do
		if [ -d $1"/"$file ]; then
			func $1'/'$file
		else
			local path=$1"/"$file
			item=`ls -lh $path`
			echo $item
			if test -x $path ; then
				item=$item$xx
			fi
			let count+=1
		fi
	done
}

cd $1

func "."
