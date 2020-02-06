#!/bin/bash

CLUSTERNAME=$1

echo "#"
echo "# create user credentials"
echo "#"
echo ""

USER=beth
GROUP=master
echo "# ----------"
echo "# user: $USER"
echo "# ----------"
echo ""
~/devenv/scripts/generate-certificate-user.sh $CLUSTERNAME kube-dashboard kube-dashboard kube-dashboard $USER $USER$USER "$GROUP"
~/devenv/scripts/generate-certificate-browserca.sh $CLUSTERNAME kube-dashboard kube-dashboard kube-dashboard $USER $USER$USER
~/devenv/scripts/generate-certificate-browseruser.sh $CLUSTERNAME kube-dashboard kube-dashboard kube-dashboard $USER $USER$USER

~/devenv/scripts/generate-token-user.sh $CLUSTERNAME kube-dashboard kube-dashboard-$GROUP kube-dashboard $USER
~/devenv/scripts/generate-config-serviceaccount.sh $CLUSTERNAME kube-dashboard kube-dashboard-$GROUP kube-dashboard $USER

USER=chaz
GROUP=admin
echo "# ----------"
echo "# user: $USER"
echo "# ----------"
echo ""
~/devenv/scripts/generate-token-user.sh $CLUSTERNAME kube-dashboard kube-dashboard-$GROUP kube-dashboard $USER
~/devenv/scripts/generate-config-serviceaccount.sh $CLUSTERNAME kube-dashboard kube-dashboard-$GROUP kube-dashboard $USER

USER=will
GROUP=editor
echo "# ----------"
echo "# user: $USER"
echo "# ----------"
echo ""
~/devenv/scripts/generate-token-user.sh $CLUSTERNAME kube-dashboard kube-dashboard-$GROUP kube-dashboard $USER
~/devenv/scripts/generate-config-serviceaccount.sh $CLUSTERNAME kube-dashboard kube-dashboard-$GROUP kube-dashboard $USER

USER=hari
GROUP=viewer
echo "# ----------"
echo "# user: $USER"
echo "# ----------"
echo ""
~/devenv/scripts/generate-token-user.sh $CLUSTERNAME kube-dashboard kube-dashboard-$GROUP kube-dashboard $USER
~/devenv/scripts/generate-config-serviceaccount.sh $CLUSTERNAME kube-dashboard kube-dashboard-$GROUP kube-dashboard $USER

# taint
date > ~/devenv/taints/created-users-kubernetesdashboard
