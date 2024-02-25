#!/bin/bash

export underline="\e[4m"
export reset="\e[0m"
export bold="\e[1m"

function cleanup()
{
	rm -rf *.csv
}

cleanup;

export csvfile="package-status.csv"
echo "#Package-name,Package-version,Package-status" > ${csvfile}

echo -e "\nThe PID of this ${0##*/} script is: $$"

function update()
{
	function source_update()
	{
		echo -e "\n" && echo -n "Updating source list "
		(sudo apt-get update > /dev/null) &

		while kill -0 $! 2>/dev/null
		do 
			echo -n "."
			sleep 1
		done

		return 0
	}

	source_update;

	if [ $? -eq 0 ];then
		echo -e "\nSource list update successfully!"
	else
		echo -e "\nSource list update failed!"
		exit 1
	fi
}

update;

package_list=($(printf "%s\n" $(cat packages.txt)))

function python_install()
{
	distro_version=$(lsb_release -rs | awk '{print $1}')

	if [ "${distro_version}" == "22.04" ];then
		python_version=(3.8 3.10 3.11)
	elif [ "${distro_version}" == "20.04" ];then
		python_version=(3.6 3.8 3.10)
	elif [ "${distro_version}" == "18.04" ];then
		python_version=(3.4 3.6 3.8)
	fi

}

function package_status()
{
	local status="$1"

	if [ "${status}" == "0" ];then
		STATUS="Installed successfully"
	elif [ "${status}" == "1" ];then
		STATUS="Package install error"
	fi
}

function package_version()
{
	local packages="$1" 

	version=$(dpkg -l | grep -E "^ii\s+${packages}\s+" | awk '{print $3}' | sed 's/-1ubuntu.*//')

	echo "${packages},${version},${STATUS}" >> ${csvfile}
}

function package_config()
{
	local packages="$1"

	case ${packages} in
		vim)
			if [ -d ${HOME}/.vim ];then
				echo -e "\nVim already configured!"
			else
				curl -sLf https://spacevim.org/install.sh | bash
			fi
			;;
		git)
			if [ -f ${HOME}/.gitconfig ];then
				echo -e "\nAlready git is config"
			else
				read -rep $'\nEnter Github username: ' name && read -rep $'\nEnter Github email: ' email
				git config --global user.name ${name}
				git config --global user.email ${email}
				git config --global core.editor vim
				git config --global core.autocrlf input
				git config --global alias.ch checkout
				git config --global alias.br branch
				git config --global alias.co commit
				git config --global color.ui auto
				git config --global credential.helper store
				openssl enc -aes-256-cbc -d -pbkdf2 -in ${HOME}/.token.enc -out ${HOME}/dec.ini
				TOKEN=$(cat ${HOME}/dec.ini) && rm -rf ${HOME}/dec.ini
				echo "https://spikynavin:${TOKEN}@github.com" > ${HOME}/.git-credentials
			fi
			;;
		tldr)
			if [ -d ${HOME}/.local/share/tldr ];then
				tldr -v
			else
				mkdir -p ${HOME}/.local/share/tldr
				tldr -u
			fi
			;;
	esac
}

function package_install()
{
	local packages=("$@")

	for package in ${packages[@]}
	do 
		echo -e "\n${bold}${underline}Installing package${reset}:${package}"
		sudo apt-get install -y ${package} > /dev/null

		if [ $? -eq 0 ];then
			echo -e "\n${package} installed successfully..!"
			package_status "0"
			package_version ${package}
		else
			echo -e "\n${package} has error...!"
			package_status "1"
			package_version ${package}
			#exit 1;
		fi
		package_config ${package}
	done
}

package_install ${package_list[@]}

