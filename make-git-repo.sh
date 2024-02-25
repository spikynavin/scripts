#!/bin/bash

case $1 in
	create)
		shift 1
		echo -e "Git repo create using command line script...!\n"
		curl \
			-u "$1" \
			https://api.github.com/user/repos \
			-d '{"name":"'$2'"}' \
			--oauth2-bearer $(openssl enc -aes-256-cbc -a -d -pbkdf2 -in .token.enc)
		
		;;
	enc)
		shift 1
		read -rep $'\nEnter content to encrypt : ' inputstring
		echo -n ${inputstring} | openssl enc -aes-256-cbc -a -pbkdf2 -out .token.enc
		;;
	dec)
		shift 1
		echo -e "\nDecrypted Github token : $(openssl enc -aes-256-cbc -a -d -pbkdf2 -in token.enc)"
		;;

	*)
		echo "No option Passed..!"
		echo -e "\nUsage :\n${0##*/} create github-username repository-name | ${0##*/} enc Enter-token-content | ${0##*/} dec Enter-password"
		;;
esac
