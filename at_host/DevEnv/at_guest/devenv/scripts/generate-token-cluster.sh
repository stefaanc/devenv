#!/bin/bash

# reference: https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#join-nodes
echo "#"
echo "# generate a token & hash, to be used by worker nodes to join the cluster"
echo "#"

if ! [ -d ~/.certs ] ; then
    mkdir -p ~/.certs
fi
chmod 700 ~/.certs
kubeadm token create > ~/.certs/cluster.token
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt \
| openssl rsa -pubin -outform der 2>/dev/null \
| openssl dgst -sha256 -hex | sed 's/^.* //' \
> ~/.certs/cluster.hash
echo ""

# taint
date > ~/devenv/taints/generated-token-cluster
