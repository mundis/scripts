#!/bin/bash

# This mounts all possible linux partitions, luks devices and drives without partittions with a valid linux formated filesystem on it will be mounted
mount_all() {
        NOT_MOUNTABLE=()
        PARTITIONS=(`blkid | grep -v swap | grep -v vfat| grep -v ntfs | grep -v crypto_LUKS | grep -iv bios | grep PARTUUID | awk '{print $1}' | sed 's/://g'`)
        RAWDEVICES=(`blkid | grep -v mapper | grep -v PARTUUID | grep -v loop | awk '{print $1}' | sed 's/://g'`)
        CRYPTODEVS=(`blkid | grep crypto_LUKS | awk '{print $1}' | sed 's/[:]*$//'`)
        CRYPTONAMES=(`blkid | grep crypto_LUKS | awk '{print $1}' | sed 's/[:]*$//' | sed 's/\/dev\///g'`)
        ENCRYPDEVS=(`echo ${CRYPTODEVS[@]} | sed 's/dev/dev\/mapper/g'`)
        MOUNTDEVS=( ${PARTITIONS[@]} ${RAWDEVICES[@]} ${ENCRYPDEVS[@]})
        MOUNTPOINTS=(`echo ${MOUNTDEVS[@]}| sed 's/dev/mnt/g' | sed 's/\/mapper//g'`)
        for i in $(seq 0 $((${#CRYPTODEVS[*]} -1 )));do 
                cryptsetup luksOpen ${CRYPTODEVS[i]} ${CRYPTONAMES[i]}
        done
        mkdir `echo ${MOUNTPOINTS[@]}| sed 's/dev/mnt/g'`
        for i in $(seq 0 $((${#MOUNTDEVS[*]} -1 )));do
                mount ${MOUNTDEVS[i]} ${MOUNTPOINTS[i]} > /dev/null 2>&1
                if [ $? -ne 0 ];then NOT_MOUNTABLE+=( ${MOUNTPOINTS[i]} );MOUNTPOINTS[i]="";fi
        done
        rmdir ${NOT_MOUNTABLE[@]}
        MOUNTPOINTS=(`echo ${MOUNTPOINTS[@]}`)
}

# This detects all valid user directories on all mounted devices
valid_homedirs() {
        MAYBE_HOME=(`for i in $(seq 0 $((${#MOUNTPOINTS[*]} -1 )));do find ${MOUNTPOINTS[i]} -maxdepth 3 -type d -name .config;done`)
        for i in $(seq 0 $((${#MAYBE_HOME[*]} -1 )));do
                if [ `stat -c %u "${MAYBE_HOME[i]}"` -ge 1000 ];then
                        VALID_HOME+=(`echo ${MAYBE_HOME[i]} | sed 's/\/.config//g'`)
                fi
        done
}

my_home() {
	read -rep $'Make your choice\n\n' choice
	case "$choice" in
		''|*[!0-9]*)	echo -e "\n\ninvalid input\n\n";my_home;;
		*)		if [ $choice -lt ${#VALID_HOME[*]} ];then MYHOME=${VALID_HOME[choice]};fi;;
	esac
	TEMP=(`echo ${MYHOME} | sed 's/\//\ /g'`)
	TEMPMAX=$((${#TEMP[*]} -1 ))
	USERNAME=${TEMP[TEMPMAX]}
	mkdir /home/${USERNAME}
	mount --bind ${MYHOME} /home/${USERNAME}
	USERID=(`stat -c %u ${MYHOME}`)
	GROUPID=(`stat -c %g ${MYHOME}`)
	CREATE_OPTION="-d /home/${USERNAME} -u ${USERID} -U"
}

choose_homedir() {
	echo -e "choose one of the following home directories\n"
	for i in $(seq 0 $((${#VALID_HOME[*]} -1 )));do
		echo -e "\t$i\t${VALID_HOME[i]}"
	done
	echo
	my_home
}

ask_for_persistence() {
        echo -e "\n\n"
        read -rep $'Use existing home (y/n)?\n\n' choice
        case "$choice" in
                y|Y|n|N)	PERSISTENCE=$choice;;
                *)      	echo "invalid input";;
        esac
}

set_passwords() {
	echo -e "\n\n"
	passwd
        echo -e "\n\n"
	passwd ${USERNAME}
}

add_user() {
	USER_GROUPS="users,wheel,audio,cdrom,video,usb,plugdev,uucp,lp,lpadmin"
	useradd ${CREATE_OPTION} -G ${USER_GROUPS} -s /bin/bash ${USERNAME}
}

ask_for_persistence
case "$PERSISTENCE" in
	y|Y)    mount_all;valid_homedirs;choose_homedir;;
	n|N)    USERNAME=live;CREATE_OPTION="-m";;
	*)      ;;
esac
add_user
set_passwords
