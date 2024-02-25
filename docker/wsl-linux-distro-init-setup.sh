#!/bin/bash

set -x

function useradd()
{
	local groups=$1

	read -rep $'\nenter username to create user: ' username && read -rep $'\nEnter password for the user: ' pass

	env_pass=$(openssl passwd -6 "${pass}")

	sudo useradd -s /bin/bash -r -m -G ${groups} -p ${env_pass} ${username}

	read -rep $'\nDo you want to update same password for root[Yes|No]: ' options

	case "${options}" in
		YES | Y | yes | y)
			sudo echo "root:${env_pass}" | chpasswd -e
			;;
		NO | N | no | n)
			echo ""
			;;
	esac
}

function python_setup()
{
	local count=10

	version=(python2.7 python3.10)

	for python in "${version[@]}"
	do
		count=$((count + 10))
		sudo update-alternatives --install /usr/bin/python python /usr/bin/${python} ${count}
	done
}

function package_install()
{
	package_list=($(printf "%s\n" $(cat packages.txt)))

	for pkg in "${package_list[@]}"
	do
		echo -e "\nInstalling package: ${pkg}"
		sudo apt-get install -y ${pkg}
	done
}

function git_config_backup()
{
	date=$(date +'%Y%m%d-%I%M%S')

	pushd ${HOME} > /dev/null || exit

	if [ -e .git-credentials ];then
		tar -cjSf gitconfig-${date}-backup.tar.bz2 .gitconfig .git-credentials
	else
		tar -cjSf gitconfig-${date}-backup.tar.bz2 .gitconfig
	fi

	if [ $? -eq 0 ];then
		if [ -e gitconfig-${date}-backup.tar.bz2 ];then
			rm -rf .gitconfig .git-credentials
		fi
	fi
	popd > /dev/null || exit
}

function git_setup()
{
	git_config_backup;

	read -rep $'\nEnter github username: ' username && read -rep $'\nEnter github E-mail: ' email

	git config --global user.name "${username}"
	git config --global user.email "${email}"
	git config --global core.editor vim

	read -rep $'\nDo you want to enable git password store[Yes|No]: ' options

	case "${options}" in
		YES | Y | yes | y)
			git config --global credential.helper store
			;;
		NO | N | no | n)
			exit 1
			;;
	esac
}

function main()
{
	package_install && git_setup
	
	sudo update-alternatives --query python
	
	if [ $? -eq 0 ];then
		echo -e  "\nPython alternatives already available!\n"
		sudo update-alternatives --query python
	else
		python_setup;
	fi

	useradd "sudo,docker"	
}

main "$@"

set +x
