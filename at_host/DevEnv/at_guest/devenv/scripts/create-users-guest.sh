#!/bin/bash

echo "#"
echo "# create local users and groups"
echo "#"

echo ""
echo "# ----------"
echo "# user: beth"
echo "# ----------"
if ! getent passwd beth >/bin/null ; then
    # create user
    useradd beth
    echo "beth:bethbeth" | chpasswd
fi
if ! getent group wheel | grep beth >/bin/null ; then
    # make user an administrator
    usermod beth -aG wheel
fi
getent passwd beth
groups beth
getent group beth
getent group wheel

cp ~/devenv/config/devenv-shells/.bash* /home/beth
cp ~/devenv/config/devenv-shells/.devenvrc /home/beth
chown beth:beth /home/beth/.bash*
chown beth:beth /home/beth/.devenvrc

echo ""
USER=chaz
echo "# ----------"
echo "# user: $USER"
echo "# ----------"
if ! getent passwd $USER >/bin/null ; then
    # create user
    useradd $USER
    echo "$USER:$USER$USER" | chpasswd
fi
getent passwd $USER
groups $USER
getent group $USER

cp ~/devenv/config/devenv-shells/.bash* /home/$USER
cp ~/devenv/config/devenv-shells/.devenvrc /home/$USER
chown $USER:$USER /home/$USER/.bash*
chown $USER:$USER /home/$USER/.devenvrc

echo ""
USER=will
echo "# ----------"
echo "# user: $USER"
echo "# ----------"
if ! getent passwd $USER >/bin/null ; then
    # create user
    useradd $USER
    echo "$USER:$USER$USER" | chpasswd
fi
getent passwd $USER
groups $USER
getent group $USER

cp ~/devenv/config/devenv-shells/.bash* /home/$USER
cp ~/devenv/config/devenv-shells/.devenvrc /home/$USER
chown $USER:$USER /home/$USER/.bash*
chown $USER:$USER /home/$USER/.devenvrc

echo ""
USER=hari
echo "# ----------"
echo "# user: $USER"
echo "# ----------"
if ! getent passwd $USER >/bin/null ; then
    # create user
    useradd $USER
    echo "$USER:$USER$USER" | chpasswd
fi
getent passwd $USER
groups $USER
getent group $USER

cp ~/devenv/config/devenv-shells/.bash* /home/$USER
cp ~/devenv/config/devenv-shells/.devenvrc /home/$USER
chown $USER:$USER /home/$USER/.bash*
chown $USER:$USER /home/$USER/.devenvrc

echo ""

# taint
date > ~/devenv/taints/created-users-guest
