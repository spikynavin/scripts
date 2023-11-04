#!/bin/bash

process=$1

#declare -a pd=$(ps -xj | grep ${process} | awk '{print $2}')

declare -a pd=$(pgrep ${process})

for pid in "${pd[@]}"
do
	if [[ "${pid}" -gt "0" ]];then
		echo "$1 process killed by user! and the process pid id: $pid" && kill -9 $pid
	else
		echo -e "$1 process not running"
	fi
done
