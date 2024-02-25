#!/bin/bash

set -x

function download_rsync()
{
	local down_src=$1
	local version_name=$2

	mkdir -p ${HOME}/yocto_mirrors/${version_name}
	rsync -avL ${down_src} ${HOME}/yocto_mirrors/${version_name}
	if [ $? -eq 0 ];then
		echo -e "Rsync completed..!"
	else
		echo -e "Rsync end with error..!"
		exit 1
	fi
}

function sstate_cache_rsync()
{
	local sstate_src=$1
	local version_name=$2

	mkdir -p ${HOME}/yocto_mirrors/${version_name}
	rsync -avL ${sstate_src} ${HOME}/yocto_mirrors/${version_name}
	if [ $? -eq 0 ];then
		echo -e "Rsync sstate-cache completed..!"
	else
		echo -e "Rsync end with error..!"
		exit 1
	fi
}

read -p "Enter yocto version: " userdata && read -p "Pass download-source path: " down_src && read -p "Pass sstate-cache source path: " sstate_src

declare -a version=(dunfell kirkstone)

function main_process()
{
        local down_src=$1
        local sstate_src=$2
	local version_name=$3

        download_rsync "${down_src}" "${version_name}"
        sstate_cache_rsync "${sstate_src}" "${version_name}"

}

function check()
{
	local userdata=$1

	for var in "${version[@]}"
	do
		if [ "${userdata}" == "${var}" ];then
			echo -e "data are matched"
			case ${userdata} in
				dunfell)
					echo "${userdata} version selected"
					main_process "${down_src}" "${sstate_src}" "${userdata}"
					break
					;;
				kirkstone)
					echo "${userdata} version selecetd"
					main_process "${down_src}" "${sstate_src}" "${userdata}"
					break
					;;
			esac
		fi
	done
}

check "${userdata}"

if [ "${userdata}" != "${var}" ];then
	echo -e "unsupported yocto version"
	exit 1
fi

set +x
