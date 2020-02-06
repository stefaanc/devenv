#!/bin/bash

CLUSTERNAME=$1
NAMESPACE=$2
SERVICE=$3
SERVERNAME=$4
USERNAME=$5
PASSWORD=$6
GROUP="$7"

if ! [ -d ~/.certs/$USERNAME ] ; then
    mkdir -p ~/.certs/$USERNAME
fi

FILENAME=$USERNAME@$SERVERNAME.$CLUSTERNAME

echo "#"
echo "# copy CA certificates"
echo "#"

cp ~/.pki/kubernetes/ca@$SERVERNAME.$CLUSTERNAME.crt ~/.certs/$USERNAME
echo ""

echo "#"
echo "# generate a private key"
echo "#"

#openssl genrsa -aes256 -passout pass:$PASSWORD   # go (used by kubernetes) doesn't support encrypted keys
openssl genrsa -passout pass:$PASSWORD \
  -out ~/.certs/$USERNAME/$FILENAME.key \
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
  -key ~/.certs/$USERNAME/$FILENAME.key \
  -passin pass:$PASSWORD \
  -subj "/CN=$USERNAME/O=kubernetes/OU=clusters:$CLUSTERNAME/OU=namespaces:$NAMESPACE/OU=services:$SERVICE/O=$GROUP" \
  -out ~/.certs/$USERNAME/$FILENAME.csr
echo ""

echo "#"
echo "# approve certificate sign request and generate certificate"
echo "#"

cat <<EOF > ~/.pki/kubernetes/user.ext
basicConstraints       = critical,CA:FALSE
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always,issuer:always
keyUsage               = critical,digitalSignature,keyEncipherment
extendedKeyUsage       = critical,clientAuth
EOF

openssl x509 -req \
  -in ~/.certs/$USERNAME/$FILENAME.csr \
  -CA ~/.pki/kubernetes/ca@$SERVERNAME.$CLUSTERNAME.crt \
  -CAkey ~/.pki/kubernetes/ca@$SERVERNAME.$CLUSTERNAME.key \
  -CAcreateserial \
  -passin pass:kubekube \
  -days 365 \
  -extfile ~/.pki/kubernetes/user.ext \
  -out ~/.certs/$USERNAME/$FILENAME.crt
rm ~/.certs/$USERNAME/$FILENAME.csr
echo ""

echo "#"
echo "# secure keys and certificates"
echo "#"

chmod 700 ~/.certs
chmod 700 ~/.certs/$USERNAME
chmod 600 ~/.certs/$USERNAME/*
chmod 644 ~/.certs/$USERNAME/*.crt

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