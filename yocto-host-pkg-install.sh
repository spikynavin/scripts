#!/bin/bash

# Author Naveen raj
# Use this script to install yocto host pkg for selected distro
# script tested in kirkstone yocto version 4.0.13

# ubuntu-18.04 packages
declare -a PKG_1=(gawk wget git diffstat unzip texinfo gcc build-essential chrpath socat cpio python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev pylint3 xterm python3-subunit mesa-common-dev zstd liblz4-tool)

# ubuntu-20.04 packages
declare -a PKG_2=(gawk wget git diffstat unzip texinfo gcc build-essential chrpath socat cpio python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev python3-subunit mesa-common-dev zstd liblz4-tool file locales)

# enable this for debug
#printf "%s\n" "${PKG_1[@]}"

function install_pkg()
{
	local var=("$@")

	for pkg in "${var[@]}"
	do
		echo -e "\nInstalling package: $pkg\n"
		sudo apt-get install -y $pkg
	done

	if [[ $? -eq 0 ]];then
		echo -e "\nInstallation done successfully...!\n"
	else
		echo -e "\nInstallation error...!\n"
	fi
}

# main function
case $(lsb_release -sr) in
	18.04)
		echo -e "ubuntu 18.04 packages install\n"
		install_pkg "${PKG_1[@]}"
		;;
	20.04)
		echo -e "ubuntu 20.04 packages install\n"
		install_pkg "${PKG_2[@]}"
		;;
	*)
		echo "unsupported ubuntu distro"
		;;
esac
