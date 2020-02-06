#!/bin/bash

# reference: https://docs.docker.com/install/linux/linux-postinstall#manage-docker-as-a-non-root-user
echo "#"
echo "# Create local groups"
echo "#"

if ! getent group docker >/bin/null ; then
    # create group
    groupadd docker
fi

echo ""
USER=beth
echo "# ----------"
echo "# user: $USER"
echo "# ----------"
if ! getent group docker | grep $USER >/bin/null ; then
    # make user a docker user
    usermod $USER -aG docker
fi
getent passwd $USER
groups $USER
getent group docker

echo ""

# taint
date > ~/devenv/taints/created-users-docker
