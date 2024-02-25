# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

if [ -f "/etc/profile.d/bash_completion.sh" ];then
	bold=$(tput bold)
	reset=$(tput sgr0)
	red=$(tput setaf 1)
	green=$(tput setaf 2)
	yellow=$(tput setaf 3)
	blue=$(tput setaf 4)
	purple=$(tput setaf 5)
	cyan=$(tput setaf 6)
	white=$(tput setaf 7)
	export PS1="\[${bold}${green}\]custom\[${reset}\]:\[${yellow}\]\w\[${reset}\]\\$ "
	source /etc/profile.d/bash_completion.sh
fi

