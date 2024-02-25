#!/bin/bash

if [ "${DEBUG}" == "1" ];then
	set -x
fi

if ! [ -z "${CC}" ];then
	echo -e "\nCross-compiler-selected\n"
	GCC=${CC};
else
	echo -e "\nNative compiler-selected\n"
	GCC="gcc";
fi

echo -e "########### Compiler config ###########\n"
echo -e "Compiler name: $(echo ${GCC} | grep -oP '^\S+' | awk '{print $1}')"
echo -e "Compiler version: $(${GCC} --version | awk 'NR==1 {print $NF}')\n"
echo -e "#######################################"

workspace=$(pwd)

src_file="$1"
executable=$(echo ${src_file} | awk -F '.' '{print $1}')

declare -a options=("-c" "-E" "-S" "-M")

if ! [ -d ${workspace}/output ];then
	mkdir -p ${workspace}/output
fi

pushd ${workspace}/output > /dev/null || exit

for i in "${options[@]}"
do
	if [ "${i}" == "-c" ];then
		${GCC} ${i} ${workspace}/${src_file} -o ${executable}-obj.o
	elif [ "${i}" == "-E" ];then
		${GCC} ${i} ${workspace}/${src_file} -o ${executable}-preprocess.i
	elif [ "${i}" == "-S" ];then
		${GCC} ${i} ${workspace}/${src_file} -o ${executable}-assembly.s
	elif [ "${i}" == "-M" ];then
		${GCC} ${i} ${workspace}/${src_file} -o ${executable}-dependency.d
	fi	
done

${GCC} ${workspace}/${src_file} -o ${executable}
chmod a+x ${executable}

declare -a file_list=($(ls | tr '\n' ' '))

for list in "${file_list[@]}"
do
	if [ "${list}" == *.o ];then
		echo -e "Compiled obj file: ${list}"
	elif [ "${list}" == *.i ];then
		echo -e "Compiled preprocess file: ${list}"
	elif [ "${list}" == *.s ];then
                echo -e "Compiled assembly file: ${list}"
	elif [ "${list}" == *.d ];then
		echo -e "Compiled dependency file: ${list}"
	else
		echo -e "\nCompiled executable file: ${list}"
	fi
done 

popd > /dev/null || exit

set +x
