#!/bin/bash

# reference: https://gist.github.com/grenade/6318301
echo "#"
echo "# chmod devenv directories and files"
echo "#"

if [ -d ~/.certs >/etc/bin ] ; then
    chmod 700 ~/.certs 
    find   ~/.certs   -mindepth 1 -type d -print0 | xargs -0r chmod 700
    find   ~/.certs   -mindepth 1 -type f -print0 | xargs -0r chmod 600
    find   ~/.certs   -mindepth 1 -type f   -name *.crt     -print0 | xargs -0r chmod 644
    find   ~/.certs   -mindepth 1 -type f   -name ca@*.p12   -print0 | xargs -0r chmod 644
fi

if [ -d ~/.kube >/etc/bin ] ; then
    chmod 700 ~/.kube
    find   ~/.kube   -mindepth 1 -type d -print0 | xargs -0r chmod 755
    find   ~/.kube   -mindepth 1 -type f -print0 | xargs -0r chmod 644
    find   ~/.kube   -mindepth 1 -type f   -name config   -print0 | xargs -0r chmod 600
    find   ~/.kube   -mindepth 1 -type f   -name *.conf   -print0 | xargs -0r chmod 600
fi

if [ -d ~/.pki >/etc/bin ] ; then
    chmod 700 ~/.pki
    find   ~/.pki   -mindepth 1 -type d -print0 | xargs -0r chmod 700
    find   ~/.pki   -mindepth 1 -type f -print0 | xargs -0r chmod 600
    find   ~/.pki   -mindepth 1 -type f   -name *.crt     -print0 | xargs -0r chmod 644
    find   ~/.pki   -mindepth 1 -type f   -name ca@*.p12   -print0 | xargs -0r chmod 644
fi

if [ -d ~/.ssh >/etc/bin ] ; then
    chmod 700 ~/.ssh 
    find   ~/.ssh   -mindepth 1 -type d -print0 | xargs -0r chmod 755
    find   ~/.ssh   -mindepth 1 -type f -print0 | xargs -0r chmod 644
    find   ~/.ssh   -mindepth 1 -type f   -name *.key   -print0 | xargs -0r chmod 600
fi

chmod 755 ~/devenv
find   ~/devenv   -mindepth 1 -type d -print0 | xargs -0r chmod 755
find   ~/devenv   -mindepth 1 -type f -print0 | xargs -0r chmod 644
find   ~/devenv   -mindepth 1 -type f   -name *.sh   -print0 | xargs -0r chmod 744
echo ""
