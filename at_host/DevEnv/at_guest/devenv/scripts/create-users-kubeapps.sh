#!/bin/bash

CLUSTERNAME=$1

echo "#"
echo "# create user credentials"
echo "#"
echo ""

USER=beth
GROUP=system:masters
echo "# ----------"
echo "# user: $USER"
echo "# ----------"
echo ""
~/devenv/scripts/generate-certificate-user.sh $CLUSTERNAME kube-apps kube-apps kube-apps $USER $USER$USER "$GROUP"
~/devenv/scripts/generate-certificate-browserca.sh $CLUSTERNAME kube-apps kube-apps kube-apps $USER $USER$USER
~/devenv/scripts/generate-certificate-browseruser.sh $CLUSTERNAME kube-apps kube-apps kube-apps $USER $USER$USER
~/devenv/scripts/generate-token-user.sh $CLUSTERNAME kube-apps kube-apps kube-apps $USER
# ~/devenv/scripts/generate-config-serviceaccount.sh $CLUSTERNAME kube-apps kube-apps kube-apps $USER

# taint
date > ~/devenv/taints/created-users-kubeapps
