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

FILENAME=$USERNAME@$SERVERNAME.$CLUSTERNAME

echo "#"
echo "# generate a personal certificate for the browser"
echo "#"

openssl pkcs12 -export -clcerts -passout pass:$PASSWORD \
  -in ~/.certs/$USERNAME/$FILENAME.crt \
  -inkey ~/.certs/$USERNAME/$FILENAME.key \
  -passin pass:$PASSWORD \
  -name $USERNAME@$SERVERNAME.$CLUSTERNAME.localdomain \
  -caname ca@$SERVERNAME.$CLUSTERNAME.localdomain \
  -out ~/.certs/$USERNAME/$FILENAME.p12
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