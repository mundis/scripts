#!/bin/bash

STATUS=0
if ! [ $3 ] || ! [ $2 ] || ! [ $1 ];then
	echo -e "SYNTAX:create_patch folder.orig folder.modified patchname"
	STATUS=1
fi
if ! [ -d $1 ] || ! [ -d $2 ];then
	echo -e "directories don't exist"
	STATUS=1
fi
if ! [ $STATUS -eq 1 ];then
	diff -Naru $1 $2 > $3
fi
