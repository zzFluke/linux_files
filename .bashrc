#!/usr/bin/env bash

source ~/.bashrc_base

# set emacs as editor
export EDITOR="emacs"

if [[ $(uname) == 'Darwin' ]]; then
    # MAC setup
    :
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
