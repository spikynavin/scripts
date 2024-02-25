#!/bin/bash

CWD=$(pwd)

pushd ${CWD}/build/ > /dev/null
rm -rf yocto-download-kirkstone.tar.gz
sync
tar -czvf yocto-download-kirkstone.tar.gz downloads/
sync
dws=$(du -sh yocto-download-kirkstone.tar.gz | awk '{print $1}' 2> /dev/null)
popd > /dev/null

pushd ${CWD}/build/cache/ > /dev/null
rm -rf yocto-sstate-cache-kirkstone.tar.gz
sync
tar -czvf yocto-sstate-cache-kirkstone.tar.gz sstate-cache/
sync
sss=$(du -sh yocto-sstate-cache-kirkstone.tar.gz | awk '{print $1}' 2> /dev/null)
popd > /dev/null

echo -e "\nSize of the download backup: ${dws}"
echo -e "Size of the sstate-cache: ${sss}"
