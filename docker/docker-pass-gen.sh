#!/bin/bash

function gen_groups()
{
	# generate basic group file for docker

	local group_file="dockergp"

	rm -rf groupids.txt

	getent group | grep root > ${group_file} 
	getent group | grep sudo >> ${group_file}
	getent group | grep ${USER} >> ${group_file}

	groups=(root _apt ${USER})

	for group in "${groups[@]}"
	do
		getent group | grep ${group} | awk -v user=${group} -F ':' '{printf $3 "\n"}' >> groupids.txt
	done
}

function gen_passwd()
{
	# generate basic passwd file for docker

	local passwd_file="dockerpwd"

	getent passwd | grep root > ${passwd_file}
	getent passwd | grep _apt >> ${passwd_file}
	getent passwd | grep ${USER} >> ${passwd_file}
}

function gen_user_passwd()
{
	local pass=$1 shadow_file="dockershd"

	read -rep $'\nEnter password for docker: ' pass

	enc_pass=$(openssl passwd -6 ${pass})

	echo "root:*:19478:0:99999:7:::" > ${shadow_file}
	echo "_apt:*:19478:0:99999:7:::" >> ${shadow_file}
	echo "${USER}:${enc_pass}:19686:0:99999:7:::" >> ${shadow_file}
}

function main()
{
	gen_groups && gen_passwd && gen_user_passwd;

	./run-docker.sh
}

main "$@"
