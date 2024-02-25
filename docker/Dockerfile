FROM ubuntu:latest

RUN apt-get update && apt-get install -y sudo \
bash-completion && apt-get clean -y && \
rm -rf /var/lib/apt/lists/*

RUN echo "if [ -f /etc/bash_completion ]; then\n    . /etc/bash_completion\nfi" >> /root/.bashrc

COPY ./packages.txt /
COPY ./tarfile.sh  /
COPY ./wsl-linux-distro-init-setup.sh /
