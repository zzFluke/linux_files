#! /usr/bin/env bash

# standard aliases
if [ "$(uname -s)" == "Darwin" ]; then
    alias l.='ls -d .*'
    alias la='ls -a'
    alias lt='ls -ltr'
else
    alias ls='ls --color=auto'
    alias l.='ls --color=auto -d .*'
    alias la='ls --color=auto -a'
    alias lt='ls --color=auto -ltr'
fi
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'
alias ssh='ssh -XY'
alias so='source'

# utility aliases
alias gitlso='git ls-files --others --exclude-standard'
alias mycfg='git --git-dir=${HOME}/.mycfg --work-tree=${HOME}'

# add additional site-specific aliases
if [ -f ${HOME}/.bash_aliases_custom ]; then
    . ${HOME}/.bash_aliases_custom
fi
