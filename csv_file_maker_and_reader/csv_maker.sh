#!/bin/bash

#set -x

new_package_file="need_packages.txt"

echo "Package-Name" > package.csv

pkgs=$(cat need_packages.txt | tr ' ' '\n')

for pkg in "${pkgs[@]}"; do
	echo "$pkg" >> package.csv
done

file="package.csv"

column_name="Package-Name"
#sudo apt update

package_names=($(awk -F ',' -v col="$column_name" 'NR==1 {for (i=1; i<=NF; i++) if ($i == col) col_num=i} NR>1 {print $col_num}' "$file"))

echo "Package-Name,Installed-Version,Action,Binary-Path" > installed_pkglist.csv

for package in "${package_names[@]}"; do
	if dpkg -l | grep -q "^ii  $package"; then
		version=$(dpkg-query -W -f='${Version}' "$package")
		bin_path=$(command -v $(dpkg-query -L $package | grep -E "/bin/|/sbin/" | xargs -I{} basename {}))
		echo "$package is already installed"
		echo "$package,$version,alreay installed,"$bin_path"" >> installed_pkglist.csv
	else
		pkg install "$package"
		echo "$package,$version,installed" >> installed_pkglist.csv
	fi
done

rm -rf package.csv

#set +x
