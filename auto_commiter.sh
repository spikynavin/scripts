#!/bin/bash

export WORKSPACE=$(pwd)

function dest_source_fetch()
{
	local repo_branch=$1 repo_url=$2 repo_dest_name=$3

	pushd ${WORKSPACE}

	git clone -b ${repo_branch} ${repo_url} ${repo_dest_name}

	popd

	function create_commit()
	{
		local hash=$1

		export commit_file="commit.ini"

		echo -e "SFI binary update for space4 adv\n" >> ${WORKSPACE}/${commit_file}
		echo "Description:- SFI binary update for space4 adv" >> ${WORKSPACE}/${commit_file}
		echo "binary md5sum: ${hash}" >> ${WORKSPACE}/${commit_file}
		echo "Varient:- NA" >> ${WORKSPACE}/${commit_file}
		echo "ALM:- ALM-00" >> ${WORKSPACE}/${commit_file}
	}

	binary_file="test.txt"
	echo "Hello this for checking the git commiter script..!" > ${binary_file}

	file_hash=$(md5sum test.txt | awk '{printf $1}')

	create_commit "${file_hash}"

	pushd ${WORKSPACE}/${repo_dest_name} || exit
	cp -rf ${WORKSPACE}/${binary_file} . && git add ${binary_file} && git status && git commit -F ${WORKSPACE}/${commit_file}
	git log --oneline -5
	popd || exit
}

dest_source_fetch "main" "https://github.com/spikynavin/scripts" "script-repo"
