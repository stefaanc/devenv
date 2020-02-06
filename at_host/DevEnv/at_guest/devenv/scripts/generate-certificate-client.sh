#!/bin/bash

CLUSTERNAME=$1
NAMESPACE=$2
SERVICE=$3
SERVERNAME=$4
CLIENTNAME=$5

if ! [ -d ~/.pki/kubernetes/$CLIENTNAME ] ; then
    mkdir -p ~/.pki/kubernetes/$CLIENTNAME
fi

FILENAME=$CLIENTNAME@$SERVERNAME.$CLUSTERNAME

echo "#"
echo "# copy CA certificates"
echo "#"

cp ~/.pki/kubernetes/ca@$SERVERNAME.$CLUSTERNAME.crt ~/.pki/kubernetes/$CLIENTNAME
echo ""

echo "#"
echo "# generate a private key"
echo "#"

#openssl genrsa -aes256 -passout pass:$PASSWORD   # go (used by kubernetes) doesn't support encrypted keys
openssl genrsa -passout pass:x \
  -out ~/.pki/kubernetes/$CLIENTNAME/$FILENAME.key \
  2048
echo ""

echo "#"
echo "# generate a certificate sign request"
echo "#"

if [ -z $GROUP ] ; then
    GROUP="none"
else
    GROUP=$( echo $GROUP | sed 's+,+/O=+g' )
fi
openssl req -new -sha256 \
  -key ~/.pki/kubernetes/$CLIENTNAME/$FILENAME.key \
  -subj "/CN=$CLIENTNAME/O=kubernetes/OU=clusters:$CLUSTERNAME/OU=namespaces:$NAMESPACE/OU=services:$SERVICE" \
  -out ~/.pki/kubernetes/$CLIENTNAME/$FILENAME.csr
echo ""

echo "#"
echo "# approve certificate sign request and generate certificate"
echo "#"

cat <<EOF > ~/.pki/kubernetes/client.ext
basicConstraints       = critical,CA:FALSE
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always,issuer:always
keyUsage               = critical,digitalSignature,keyEncipherment
extendedKeyUsage       = critical,clientAuth
EOF

openssl x509 -req \
  -in ~/.pki/kubernetes/$CLIENTNAME/$FILENAME.csr \
  -CA ~/.pki/kubernetes/ca@$SERVERNAME.$CLUSTERNAME.crt \
  -CAkey ~/.pki/kubernetes/ca@$SERVERNAME.$CLUSTERNAME.key \
  -CAcreateserial \
  -passin pass:kubekube \
  -days 365 \
  -extfile ~/.pki/kubernetes/client.ext \
  -out ~/.pki/kubernetes/$CLIENTNAME/$FILENAME.crt
rm ~/.pki/kubernetes/$CLIENTNAME/$FILENAME.csr
echo ""

echo "#"
echo "# secure keys and certificates"
echo "#"

chmod 700 ~/.pki
chmod 700 ~/.pki/kubernetes
chmod 700 ~/.pki/kubernetes/$CLIENTNAME
chmod 600 ~/.pki/kubernetes/$CLIENTNAME/*
chmod 644 ~/.pki/kubernetes/$CLIENTNAME/*.crt
echo ""