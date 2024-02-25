#!/bin/bash

list=($(printf "%s\n" $(cat package.txt)))

for packages in "${list[@]}"
do
	echo -e "\nInstalling package: ${packages}\n"
	sudo apt-get install -y "${packages}"
done
