#!/bin/bash

CLUSTERNAME=$1
NAMESPACE=$2
SERVICE=$3
SERVERNAME=$4
IPADDRESS="$5"

if ! [ -d ~/.pki/kubernetes/$SERVERNAME ] ; then
    mkdir -p ~/.pki/kubernetes/$SERVERNAME
fi

FILENAME=$SERVICE@$SERVERNAME.$CLUSTERNAME

echo "#"
echo "# copy CA certificates"
echo "#"

cp ~/.pki/kubernetes/ca@$SERVERNAME.$CLUSTERNAME.crt ~/.pki/kubernetes/$SERVERNAME
echo ""

echo "#"
echo "# generate a private key"
echo "#"

#openssl genrsa -aes256 -passout pass:$PASSWORD   # go (used by kubernetes) doesn't support encrypted keys
openssl genrsa -passout pass:x \
  -out ~/.pki/kubernetes/$SERVERNAME/$FILENAME.key \
  2048
echo ""

echo "#"
echo "# generate a certificate sign request"
echo "#"

openssl req -new -sha256 \
  -key ~/.pki/kubernetes/$SERVERNAME/$FILENAME.key \
  -subj "/CN=$SERVERNAME.$CLUSTERNAME.localdomain/O=kubernetes/OU=clusters:$CLUSTERNAME/OU=namespaces:$NAMESPACE/OU=services:$SERVICE" \
  -out ~/.pki/kubernetes/$SERVERNAME/$FILENAME.csr
echo ""

echo "#"
echo "# approve certificate sign request and generate certificate"
echo "#"

SAN="\
DNS:$SERVICE\
,DNS:$SERVICE.$NAMESPACE\
,DNS:$SERVICE.$NAMESPACE.svc\
,DNS:$SERVICE.$NAMESPACE.svc.$CLUSTERNAME.localdomain\
,DNS:$SERVICE.localdomain\
,DNS:$SERVICE.$CLUSTERNAME\
,DNS:$SERVICE.$CLUSTERNAME.localdomain\
,IP:127.0.0.1\
"

if ! echo $SAN | grep $SERVERNAME >/bin/null ; then
    SAN="$SAN\
,DNS:$SERVERNAME\
"
fi
if ! echo $SAN | grep $SERVERNAME.localdomain >/bin/null ; then
    SAN="$SAN\
,DNS:$SERVERNAME.localdomain\
"
fi
if ! echo $SAN | grep $SERVERNAME.$CLUSTERNAME >/bin/null ; then
    SAN="$SAN\
,DNS:$SERVERNAME.$CLUSTERNAME\
"
fi
if ! echo $SAN | grep $SERVERNAME.$CLUSTERNAME.localdomain >/bin/null ; then
    SAN="$SAN\
,DNS:$SERVERNAME.$CLUSTERNAME.localdomain\
"
fi
if ! [ -z $IPADDRESS ] ; then
    SAN="$SAN\
,IP:$IPADDRESS\
"
fi

cat <<EOF > ~/.pki/kubernetes/server.ext
basicConstraints       = critical,CA:FALSE
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always,issuer:always
keyUsage               = critical,digitalSignature,keyEncipherment
extendedKeyUsage       = critical,serverAuth
subjectAltName         = $SAN
EOF

openssl x509 -req \
  -in ~/.pki/kubernetes/$SERVERNAME/$FILENAME.csr \
  -CA ~/.pki/kubernetes/ca@$SERVERNAME.$CLUSTERNAME.crt \
  -CAkey ~/.pki/kubernetes/ca@$SERVERNAME.$CLUSTERNAME.key \
  -CAcreateserial \
  -passin pass:kubekube \
  -days 365 \
  -extfile ~/.pki/kubernetes/server.ext \
  -out ~/.pki/kubernetes/$SERVERNAME/$FILENAME.crt
rm ~/.pki/kubernetes/$SERVERNAME/$FILENAME.csr
echo ""

echo "#"
echo "# secure keys and certificates"
echo "#"

chmod 700 ~/.pki
chmod 700 ~/.pki/kubernetes
chmod 700 ~/.pki/kubernetes/$SERVERNAME
chmod 600 ~/.pki/kubernetes/$SERVERNAME/*
chmod 644 ~/.pki/kubernetes/$SERVERNAME/*.crt
echo ""