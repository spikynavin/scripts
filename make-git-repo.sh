#!/bin/bash

echo -e "Git repo making script...!"

curl -u "$1" https://api.github.com/user/repos -d '{"name":"'$2'"}' --oauth2-bearer $(openssl enc -aes-256-cbc -a -d -pbkdf2 -in .pass.enc)
