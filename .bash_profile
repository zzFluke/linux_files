if [[ $(uname) == 'Darwin' ]]; then
    # MAC specific setup
    # append /usr/local/bin to PATH, this way
    # programs installed by homebrew supercedes
    # default programs
    export PATH="/usr/local/bin:${PATH}"
fi

if [[ -f ~/.bashrc ]] ; then
    . ~/.bashrc
fi

