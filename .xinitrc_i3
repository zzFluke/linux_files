#!/bin/bash

eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
export SSH_AUTH_SOCK

xmodmap ${HOME}/.Xmodmap
export XKL_XMODMAP_DISABLE=1

# start XRandR before I3, so I3 uses XRandR and thus will pick up
# VNC window size changes. got this answer from stack-overflow.
xrandr
exec i3
