#!/bin/bash

docker run --rm --env-file=$(pwd)/docker_workspace_env.txt \
	-u $(id -u):$(id -g) \
	-v $(pwd):$(pwd) \
	-v ${HOME}:${HOME} \
	-v $(pwd)/dockergp:/etc/group \
	-v $(pwd)/dockerpwd:/etc/passwd \
	-v $(pwd)/dockershd:/etc/shadow $(awk '{printf "--group-add %s ", $1}' groupids.txt) \
	-e USER=${USER} \
	-e HOME=${HOME} \
	-e UID=$(id -u) \
	-e SHELL=/bin/bash \
	-e GID=$(id -g) \
	-it ubuntu:latest
