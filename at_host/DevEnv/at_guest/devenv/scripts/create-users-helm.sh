#!/bin/bash

CLUSTERNAME=$1

echo "#"
echo "# Create local groups"
echo "#"

if ! getent group helm >/bin/null ; then
    # create group
    groupadd helm
fi

echo ""
USER=beth
echo "# ----------"
echo "# user: $USER"
echo "# ----------"
if ! getent group helm | grep $USER >/bin/null ; then
    # make user a helm user
    usermod $USER -aG helm
fi
getent passwd $USER
groups $USER
getent group helm

echo ""

echo "#"
echo "# create user credentials for tiller and configure helm"
echo "#"
echo ""

USER=beth
GROUP=system:masters
echo "# ----------"
echo "# user: $USER"
echo "# ----------"

echo ""
~/devenv/scripts/generate-certificate-user.sh $CLUSTERNAME kube-apps tiller-deploy kube-tiller $USER $USER$USER "$GROUP"

# create local home for helm
if ! [ -d /home/$USER/.helm ] ; then
    helm init --client-only --home /home/$USER/.helm
    find   /home/$USER/.helm   -print0 | xargs -0r chown $USER:$USER
fi

# create local profile
cp -f ~/.helm/profile /home/$USER/.helm/profile.$CLUSTERNAME
sed -i -e "s+/root+/home/$USER+g" -e "s+kubernetes-admin+$USER+g" /home/$USER/.helm/profile.$CLUSTERNAME
chown $USER:$USER /home/$USER/.helm/profile.$CLUSTERNAME

if ! [ -f /home/$USER/.helm/profile ] ; then
    cp /home/$USER/.helm/profile.$CLUSTERNAME /home/$USER/.helm/profile
    chown $USER:$USER /home/$USER/.helm/profile
fi
echo ""

# taint
date > ~/devenv/taints/created-users-helm
