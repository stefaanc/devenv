#!/bin/bash

CLUSTERNAME=$1
NAMESPACE=$2
SERVICEACCOUNT=$3
SERVERNAME=$4
USERNAME=$5

if ! [ -d ~/.certs/$USERNAME ] ; then
    mkdir -p ~/.certs/$USERNAME
fi

FILENAME=$USERNAME@$SERVERNAME.$CLUSTERNAME

echo "#"
echo "# create config"
echo "#"

cp ~/devenv/config/devenv-pki/serviceaccount.conf.tpl ~/.certs/$USERNAME/$FILENAME.conf

sed -i "s/<clustername>/${CLUSTERNAME}/g" ~/.certs/$USERNAME/$FILENAME.conf
sed -i "s/<serviceaccount>/${SERVICEACCOUNT}/g" ~/.certs/$USERNAME/$FILENAME.conf
sed -i "s/<namespace>/${NAMESPACE}/g" ~/.certs/$USERNAME/$FILENAME.conf

TOKEN=$( cat ~/.certs/$USERNAME/$FILENAME.token | sed -e "s/[\/&]/\\\\&/g" )
sed -i "s+<token>+${TOKEN}+" ~/.certs/$USERNAME/$FILENAME.conf
echo ""

echo "#"
echo "# secure config"
echo "#"

chmod 700 ~/.certs
chmod 700 ~/.certs/$USERNAME
chmod 600 ~/.certs/$USERNAME/$FILENAME.conf

if getent passwd $USERNAME >/bin/null ; then
    if ! [ -d /home/$USERNAME/.certs/$USERNAME ] ; then
        mkdir -p /home/$USERNAME/.certs/$USERNAME
    fi
    chown $USERNAME:$USERNAME /home/$USERNAME/.certs
    chown $USERNAME:$USERNAME /home/$USERNAME/.certs/$USERNAME
    chmod 700 /home/$USERNAME/.certs
    chmod 700 /home/$USERNAME/.certs/$USERNAME

    cp -f ~/.certs/$USERNAME/$FILENAME.conf /home/$USERNAME/.certs/$USERNAME
    chown $USERNAME:$USERNAME /home/$USERNAME/.certs/$USERNAME/$FILENAME.conf

    if ! [ -d /home/$USERNAME/.kube ] ; then
        mkdir -p /home/$USERNAME/.kube
    fi
    chown $USERNAME:$USERNAME /home/$USERNAME/.kube
    chmod 700 /home/$USERNAME/.kube

    cp -f ~/.certs/$USERNAME/$FILENAME.conf /home/$USERNAME/.kube
    chown $USERNAME:$USERNAME /home/$USERNAME/.kube/$FILENAME.conf
fi
echo ""