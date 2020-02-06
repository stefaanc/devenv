#!/bin/bash

CLUSTERNAME=$1
NAMESPACE=$2
SERVICE=$3
SERVERNAME=$4

if ! [ -d ~/.pki/kubernetes ] ; then
    mkdir -p ~/.pki/kubernetes
fi

FILENAME=ca@$SERVERNAME.$CLUSTERNAME

echo "#"
echo "# generate a private key for $FILENAME"
echo "#"

# openssl genrsa -aes256 -passout pass:x   # go (used by kubernetes) doesn't support encrypted keys
openssl genrsa -passout pass:x \
  -out ~/.pki/kubernetes/$FILENAME.key \
  2048
echo ""

echo "#"
echo "# generate a certificate for $FILENAME"
echo "#"

cat <<EOF > ~/.pki/kubernetes/ca.ext
basicConstraints       = critical,CA:true
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always,issuer:always
keyUsage               = critical,cRLSign,digitalSignature,keyCertSign,keyEncipherment
EOF
# remark that CA certificates shouldn't include KU=keyEncipherment, however looks like all kubernetes CAs do

openssl req -new -sha256 -nodes \
  -key ~/.pki/kubernetes/$FILENAME.key \
  -subj "/CN=$SERVERNAME.$CLUSTERNAME.localdomain/O=kubernetes/OU=clusters:$CLUSTERNAME/OU=namespaces:$NAMESPACE/OU=services:$SERVICE" \
| openssl x509 -req \
  -signkey ~/.pki/kubernetes/$FILENAME.key \
  -days 3652 \
  -extfile ~/.pki/kubernetes/ca.ext \
  -out ~/.pki/kubernetes/$FILENAME.crt
echo ""

#  -trustout
#  -setalias kubernetes
#  -addtrust "serverAuth"

echo "#"
echo "# secure keys and certificates"
echo "#"

chmod 700 ~/.pki
chmod 700 ~/.pki/kubernetes
chmod 600 ~/.pki/kubernetes/*
chmod 644 ~/.pki/kubernetes/*.crt
echo ""