#! /usr/bin/env bash

# standard aliases
if [ "$(uname -s)" == "Darwin" ]; then
    export CLICOLOR=1
    export LSCOLORS="ExGxBxDxCxEgEdxbxgxcxd"
    alias l.='ls -d .*'
    alias la='ls -a'
    alias lt='ls -ltr'
else
    alias ls='ls --color=auto'
    alias l.='ls -d .* --color=auto'
    alias la='ls -a'
    alias lt='ls -ltr'
fi
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'
alias ssh='ssh -XY'
alias so='source'

# utility aliases
alias cdl='cd ${MYBAGGENDIR}'
alias gitlso='git ls-files --others --exclude-standard'
alias mycfg='git --git-dir=${HOME}/.mycfg --work-tree=${HOME}'
alias xmod='xmodmap ${HOME}/.Xmodmap'
alias ade='virtuoso &'
