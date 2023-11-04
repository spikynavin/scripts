#!/bin/bash

case $1 in
	list)
		tar_file=$2
		read -rep $'\nEnter tar type: ' formate
		if [ "${formate}" == "gz" ];then
			echo -e "\nTar file contents: ${content}"
			content=$(tar -tjOf ${tar_file})
		elif [ "${formate}" == "bz2" ];then
			echo -e "\nTar file contents: ${content}"
			content=$(tar -tjOf ${tar_file})
		fi
		;;
	cat)
		tar_file=$2 file=$3
		tar -xOf ${tar_file} ${file} | cat
		;;
	*)
		echo "Usage $0 with list and cat coammnds"
		echo "$0 (list) tarfile"
		echo "$0 (cat) tarfile contentfile"
		;;
esac
