#!/bin/sh
while true;do
	if ( cat /proc/$$/status|grep '^PPid'|egrep -b '1' );then 
		exit 0
	else
		echo -ne "\0337\0338";sleep 60
	fi
done
