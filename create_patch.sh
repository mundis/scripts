#!/bin/bash

STATUS=0
if ! [ $3 ] || ! [ $2 ] || ! [ $1 ];then
	echo -e "SYNTAX:create_patch folder1 folder2 patchname"
	STATUS=1
fi
if ! [ -d $1 ] || ! [ -d $2 ];then 
	echo -e "directories don't exist"
	STATUS=1
fi
if ! [ $STATUS -eq 1 ];then
	diff -crB $1 $2 > $3	
fi
