# .bash_profile

# Get the aliases and functions

if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# Source development environment

if [ -f /root/.devenv_profile ]; then
    . /root/.devenv_profile
fi

# User specific environment and startup programs

export PATH=$PATH:$HOME/bin
