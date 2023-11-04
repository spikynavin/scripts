#!/bin/bash

sudo apt-get update

declare -a depend_pkg=(ca-certificates curl gnupg)

function install_pkg()
{
	local var=("$@")

	for pkg in "${var[@]}"
	do
		echo -e "\nInstalling package: $pkg\n"
		sudo apt-get install -y $pkg
	done
}

declare -a docker_pkg=(docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin)

function docker_install_pkg()
{
	local var=("$@")

	for pkg in "${var[@]}"
	do
		echo -e "\nInstalling package: $pkg\n"
		sudo apt-get install -y $pkg
	done
}

function main()
{
	echo "Main function"
	sudo install -m 0755 -d /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
	sudo chmod a+r /etc/apt/keyrings/docker.gpg
	echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
		"$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
		sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
			
	sudo apt-get update
}

install_pkg "${depend_pkg[@]}" && main && docker_install_pkg "${docker_pkg[@]}"
