#! /bin/bash

export ARCHFLAGS='-arch x86_64'
export PATH="/usr/local/bin:$PATH"

if [ -f ~/.bashrc ]; then . ~/.bashrc; fi
