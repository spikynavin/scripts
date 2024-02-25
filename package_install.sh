#!/bin/bash

set -x

distro_version=$(lsb_release -rs)

echo -e "\nDistro version: $distro_version"

package_list=($(printf "%s\n" $(cat packages.txt)))

function docker_pkgconfig()
{
	sudo apt-get update

	declare -a docker_pre_packages_list=(ca-certificates curl gnupg)

	function docker_pre_requirements()
	{
		local packages=("$@")

		for pkg in "${packages[@]}"
		do
			echo -e "\nInstalling support package for docker: $pkg\n"
			sudo apt-get install -y $pkg
		done
	}

	docker_pre_requirements "${docker_pre_packages_list[@]}"

	if [ $? -eq 0 ]; then
		sudo install -m 0755 -d /etc/apt/keyrings
		curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
		sudo chmod a+r /etc/apt/keyrings/docker.gpg && sudo apt-get update

		docker_post_package_list=(docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin)

		function docker_post_requirements()
		{
			local packages=("$@")

			for pkg in "${packages[@]}"
			do
				echo -e "\nInstalling docker package: $pkg\n"
				sudo apt-get install -y $pkg
			done
		}

		echo \
			"deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
			"$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
			sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

		sudo apt-get update

		docker_post_requirements "${docker_post_package_list[@]}"

		if [ $? -eq 0 ]; then
			sudo usermod -aG docker ${USER}
		fi
	else
		echo -e "\nDocker pre-requirement or docker post function failed..!"
		exit 1
	fi
}

function pkgconfig()
{
	local pkg=$1

	case $pkg in
		git)
			read -rep $'\nEnter git username: ' name
			git config --global user.name "$name"
			read -rep $'\nEnter git email: ' email
			git config --global user.email "$email"
			git config --global core.editor "vim"
			git config --global credential.helper cache
			;;
		docker)
			docker_pkgconfig
			;;
		locales)
			sudo locale-gen en_US.UTF-8
			;;
	esac
}

function distro_installation()
{
	local package=("$@")

	for pkg in "${package[@]}"
	do
		if dpkg -s "$pkg" &> /dev/null; then
			echo -e "\n$pkg is already installed"
			generate_html "${package[@]}"
		else
			echo -e "\nInstalling package: $pkg\n"
			sudo apt-get install -y $pkg
			pkgconfig $pkg
		fi
	done
}

function distro_uninstallation()
{
	local package=("$@")

	rm -rf ${HOME}/.gitconfig

	for pkg in "${package[@]}"
	do
		sudo apt-get purge $pkg
	done
}

function generate_html()
{
	local pkg_name=("$@")

	output_file="install_package_info.html"

	if command -v dpkg &> /dev/null; then
		
		package_info=$(dpkg -l "${pkg_name[@]}" | awk '/^ii/ {printf "<tr><td>%s</td><td>%s</td>", $2, $3}')
		{
			echo "<html>"
			echo "<head><title>Package Information</title></head>"
			echo "<body>"
			echo "<h2>Installed Packages and Versions</h2>"
			echo "<table border='1'>"
			echo "<tr><th>Package Name</th><th>Version</th></tr>"
			echo "$package_info"
			echo "</table>"
			echo "</body>"
			echo "</html>"
		} > "$output_file"
		echo "Package information has been updated in $output_file"
		echo "Content has been appended to $html_file"
	else
		echo "Error: dpkg command not found. This script is designed for Debian-based systems."
	fi
}

function main()
{
	local options=$1

	case $options in
		distro)
			distro_installation "${package_list[@]}"
			;;
		uninstall)
			distro_uninstallation "${package_list[@]}"
			;;
		*)
			echo -e "\nInvalid option passed! check usage $0 distro"
			;;
	esac
}

main "$@"

set +x
