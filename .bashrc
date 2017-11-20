#!/usr/bin/env bash

# disable core dump generation
ulimit -c 0

# set default file permissions
umask 022

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
export HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# disable beeping
set bell-style none

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export HISTSIZE=1000
export HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
# shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# setup custom prompt
export PROMPT_COMMAND="${HOME}/bin/setup_prompt.sh"
export PS1="\[\033[1;33m\]-\[\033[1;34m\]>\[\033[0m\] "
export PS2="\[\033[1;33m\]-\[\033[1;34m\]>\[\033[0m\] "

# MATLAB SHELL
# export MATLAB_SHELL='/bin/tcsh -f'

# for GNUPLOT PNG font
# export GDFONTPATH=/usr/share/fonts/truetype/msttcorefonts

# Alias definitions.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# set emacs as editor
export EDITOR="emacs"

# setup custom application path.
export MY_APPLICATIONS=$(readlink -f ~/Applications)
if [ -f ${MY_APPLICATIONS}/.bashrc ]; then
    . ${MY_APPLICATIONS}/.bashrc
fi

# add custom scripts to path
export PATH="${HOME}/bin:${PATH}"

if [[ $(uname) == 'Darwin' ]]; then
    # MAC setup
    # enable color support of ls for macxs
    export CLICOLOR=1
    export LSCOLORS="ExGxBxDxCxEgEdxbxgxcxd"
else
    if grep -q Microsoft /proc/version; then
	# WSL setup
	# suppress accessbility-bus DBUS warnings
	export NO_AT_BRIDGE=1
	# set X11 display
	export DISPLAY=localhost:0.0
	# enable opengl acceleration for vcXsrv
	export LIBGL_ALWAYS_INDIRECT=1
    else
        # linux setup
	:
    fi
fi

# add additional site-specific customizations
if [ -f ${HOME}/.bashrc_custom ]; then
    . ${HOME}/.bashrc_custom
fi
