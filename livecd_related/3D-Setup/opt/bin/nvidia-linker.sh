#!/bin/bash

DIR=/opt/nvidia

#################################################################################################################################
link_delete() {
	count=1;while read line; do DRIVERFILES[count]=$line;count=$[count+1]; done < ${DIR}/${DRIVER}/${DRIVER}-files
	for m in $(seq 1 $[count-1]);do rm -f ${DRIVERFILES[m]};done
}
#################################################################################################################################
linker() {
	link_delete
	count=1;while read line; do DRIVERFOLDERS[count]=$line;count=$[count+1]; done < ${DIR}/${DRIVER}/${DRIVER}-folders
	for l in $(seq 1 $[count-1]);do mkdir -p ${DRIVERFOLDERS[l]};done
	count=1;while read line; do DRIVERFILES[count]=$line;count=$[count+1]; done < ${DIR}/${DRIVER}/${DRIVER}-files
	for l in $(seq 1 $[count-1]);do ln -s ${DIR}/$DRIVER${DRIVERFILES[l]} ${DRIVERFILES[l]};done
}
#################################################################################################################################
prepare_driver() {
	for ((i=${#DRIVERS[@]}-1; i>=0; i--));do
		DRIVER=${DRIVERS[i]}
#		echo $DRIVER
#		echo ${DIR}/${DRIVER}/${DRIVER}-folders
		linker
		modprobe -r nvidia
		modprobe nvidia 2>/dev/null
		if [ $? -eq 0 ];then
			echo Driver $DRIVER loaded;break
		else ((j++))
		fi
	done
	echo $j
}
##################################################################################################################################
#				MAIN
##################################################################################################################################
j=0
for i in ${DIR}/*;do DRIVERS[j]=${i##${DIR}/};echo ${DRIVERS[j]};((j++));done
if [ -z $1 ];then prepare_driver
elif [ $1 = "d" ];then
	for ((k=${#DRIVERS[@]}-1; k>=0; k--)); do DRIVER=${DRIVERS[k]};link_delete;done
fi
