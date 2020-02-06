#!/bin/bash

echo "#"
echo "# Create local groups"
echo "#"

if ! getent group kubernetes >/bin/null ; then
    # create group
    groupadd kubernetes
fi

echo ""
USER=beth
echo "# ----------"
echo "# user: $USER"
echo "# ----------"
if ! getent group kubernetes | grep $USER >/bin/null ; then
    # make user a kubernetes user
    usermod $USER -aG kubernetes
fi
getent passwd $USER
groups $USER
getent group kubernetes

echo ""
USER=chaz
echo "# ----------"
echo "# user: $USER"
echo "# ----------"
if ! getent group kubernetes | grep $USER >/bin/null ; then
    # make user a kubernetes user
    usermod $USER -aG kubernetes
fi
getent passwd $USER
groups $USER
getent group kubernetes

echo ""
USER=will
echo "# ----------"
echo "# user: $USER"
echo "# ----------"
if ! getent group kubernetes | grep $USER >/bin/null ; then
    # make user a kubernetes user
    usermod $USER -aG kubernetes
fi
getent passwd $USER
groups $USER
getent group kubernetes

echo ""
USER=hari
echo "# ----------"
echo "# user: $USER"
echo "# ----------"
if ! getent group kubernetes | grep $USER >/bin/null ; then
    # make user a kubernetes user
    usermod $USER -aG kubernetes
fi
getent passwd $USER
groups $USER
getent group kubernetes

echo ""

# taint
date > ~/devenv/taints/created-users-workernode
