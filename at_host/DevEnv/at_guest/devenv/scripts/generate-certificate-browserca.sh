#!/bin/bash

CLUSTERNAME=$1
NAMESPACE=$2
SERVICE=$3
SERVERNAME=$4
USERNAME=$5
PASSWORD=$6

if ! [ -d ~/.certs/$USERNAME ] ; then
    mkdir -p ~/.certs/$USERNAME
fi

echo "#"
echo "# generate a CA certificate for the browser"
echo "#"

openssl pkcs12 -export -cacerts -passout pass:kubekube \
  -in ~/.pki/kubernetes/ca@$SERVERNAME.$CLUSTERNAME.crt \
  -inkey ~/.pki/kubernetes/ca@$SERVERNAME.$CLUSTERNAME.key \
  -name ca@$SERVERNAME.$CLUSTERNAME.localdomain \
  -out ~/.certs/$USERNAME/ca@$SERVERNAME.$CLUSTERNAME.p12
echo ""

echo "#"
echo "# secure keys and certificates"
echo "#"

chmod 700 ~/.certs
chmod 700 ~/.certs/$USERNAME
chmod 600 ~/.certs/$USERNAME/*
chmod 644 ~/.certs/$USERNAME/ca@*.p12

if getent passwd $USERNAME >/bin/null ; then
    mkdir -p /home/$USERNAME/.certs/$USERNAME
    chown $USERNAME:$USERNAME /home/$USERNAME/.certs
    chown $USERNAME:$USERNAME /home/$USERNAME/.certs/$USERNAME
    chmod 700 /home/$USERNAME/.certs
    chmod 700 /home/$USERNAME/.certs/$USERNAME

    cp -f ~/.certs/$USERNAME/* /home/$USERNAME/.certs/$USERNAME
    chown $USERNAME:$USERNAME /home/$USERNAME/.certs/$USERNAME/*
fi
echo ""