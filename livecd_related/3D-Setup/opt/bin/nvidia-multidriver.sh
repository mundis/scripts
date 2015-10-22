#!/bin/bash

DRIVERS=(305 341 356)
MASK_FILE=/etc/portage/package.unmask
DIR=/opt/nvidia

############################################################################################################################################################################
delete_mask() {
	sed -i '/nvidia-drivers/d' ${MASK_FILE}
}
############################################################################################################################################################################
get_version() {
	VERSION=`ls /usr/share/doc | grep nvidia-drivers | sed 's/nvidia-drivers-//g'`
}
############################################################################################################################################################################
move_driver() {
	mkdir ${DIR}/${VERSION}
	equery -C f nvidia-drivers > ${DIR}/${VERSION}/${VERSION}-query
	count=1;while read line; do DRIVERFILES[count]=$line;count=$[count+1]; done < ${DIR}/${VERSION}/${VERSION}-query
	for i in $(seq 1 $[count-1]);do
		if !		[ -d ${DRIVERFILES[i]} ];then echo ${DRIVERFILES[i]} >> ${DIR}/${VERSION}/${VERSION}-files
		elif 		[ -d ${DRIVERFILES[i]} ];then echo ${DRIVERFILES[i]} >> ${DIR}/${VERSION}/${VERSION}-folders
		fi
	done
	count=1;while read line; do DRIVERFOLDERS[count]=$line;count=$[count+1]; done < ${DIR}/${VERSION}/${VERSION}-folders
	for i in $(seq 1 $[count-1]);do
		mkdir -p ${DIR}/${VERSION}${DRIVERFOLDERS[i]}
	done
	DRIVERFILES=()
	count=1;while read line; do DRIVERFILES[count]=$line;count=$[count+1]; done < ${DIR}/${VERSION}/${VERSION}-files
	for i in $(seq 1 $[count-1]);do
		mv ${DRIVERFILES[i]} ${DIR}/${VERSION}${DRIVERFILES[i]}
	done
}
############################################################################################################################################################################
#			MAIN
############################################################################################################################################################################
rm -rf ${DIR}/*
grep nvidia-drivers /etc/portage/package.mask/package.mask
if ! [ $? -eq 0 ];then echo x11-drivers/nvidia-drivers >> /etc/portage/package.mask/package.mask;fi
for i in $(seq 0 $((${#DRIVERS[*]} -1 )));do
	DRIVER=${DRIVERS[i]}
	delete_mask
	echo "<x11-drivers/nvidia-drivers-${DRIVER}" >> ${MASK_FILE}
	if [ ${DRIVER} == latest ];then delete_mask;fi
	emerge nvidia-drivers
	dispatch-conf
	get_version
	move_driver
done
emerge -C nvidia-drivers

