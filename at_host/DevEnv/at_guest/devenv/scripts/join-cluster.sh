#!/bin/bash

MASTERNODE=$1
CLUSTERNAME=$2

echo "#"
echo "# Add $CLUSTERNAME to /etc/hosts"
echo "#"

if ! cat /etc/hosts | grep $CLUSTERNAME >/bin/null ; then
    sed -i "s/$MASTERNODE.*/&   $CLUSTERNAME $CLUSTERNAME.localdomain/" /etc/hosts
fi
echo ""

echo "#"
echo "# Join the cluster"
echo "#"
token=$(cat ~/.certs/cluster.token)
hash=$(cat ~/.certs/cluster.hash)
kubeadm join --token $token $CLUSTERNAME:6443 --discovery-token-ca-cert-hash sha256:$hash
echo ""

# taint
date > ~/devenv/taints/joined-cluster
