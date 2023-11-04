#!/bin/bash

sudo apt-get update

mail="spikynavin@gmail.com"

git config --global user.name "$(echo ${mail} | cut -d @ -f 1)"
git config --global user.email "${mail}"
git config --global credential.helper store
git config --global core.editor vim

curl https://storage.googleapis.com/git-repo-downloads/repo > repo
chmod a+x repo
sudo mv repo /usr/bin/repo

declare -a python_pkg=(python-dev-is-python2 python-dev-is-python3 rclone)

for pkg in "${python_pkg[@]}"
do
	echo -e "\n Installing package: ${pkg}"
	sudo apt-get install -y ${pkg}
done

sudo update-alternatives --install /usr/bin/python python /usr/bin/python2.7 10
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.8 20
