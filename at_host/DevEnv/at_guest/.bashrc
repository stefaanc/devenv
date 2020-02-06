# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi
if [ -f /etc/profile.d/bash_completion.sh ]; then
    . /etc/profile.d/bash_completion.sh
fi

# Source development environment

if [ -f ~/.devenvrc ]; then
    . ~/.devenvrc
fi

# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias la='ls -laF --color=auto'
alias mail='mailx'

alias kube='kubectl'
complete -o default -o nospace -F __start_kubectl kube

alias kube-info='/root/devenv/scripts/get-kube-info.sh -v'
