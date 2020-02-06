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
echo "# generate a token"
echo "#"

kubectl create -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: $SERVICEACCOUNT-$USERNAME-token
  namespace: $NAMESPACE
  annotations:
    kubernetes.io/service-account.name: $SERVICEACCOUNT
type: kubernetes.io/service-account-token
EOF
TOKEN=$( kubectl -n $NAMESPACE describe secret $SERVICEACCOUNT-$USERNAME-token | grep 'token:' | awk '{print $2}' )
echo $TOKEN > ~/.certs/$USERNAME/$FILENAME.token 
echo ""

echo "#"
echo "# secure config"
echo "#"

chmod 700 ~/.certs
chmod 700 ~/.certs/$USERNAME
chmod 600 ~/.certs/$USERNAME/$FILENAME.token

if getent passwd $USERNAME >/bin/null ; then
    if ! [ -d /home/$USERNAME/.certs/$USERNAME ] ; then
        mkdir -p /home/$USERNAME/.certs/$USERNAME
    fi
    chown $USERNAME:$USERNAME /home/$USERNAME/.certs
    chown $USERNAME:$USERNAME /home/$USERNAME/.certs/$USERNAME
    chmod 700 /home/$USERNAME/.certs
    chmod 700 /home/$USERNAME/.certs/$USERNAME
	
    cp -f ~/.certs/$USERNAME/$FILENAME.token /home/$USERNAME/.certs/$USERNAME
    chown $USERNAME:$USERNAME /home/$USERNAME/.certs/$USERNAME/$FILENAME.token
fi
echo ""