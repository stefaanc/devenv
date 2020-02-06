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
~/devenv/scripts/generate-certificate-user.sh $CLUSTERNAME atlas chartmuseum-ui chartmuseum-ui $USER $USER$USER "$GROUP"
~/devenv/scripts/generate-certificate-browserca.sh $CLUSTERNAME atlas chartmuseum-ui chartmuseum-ui $USER $USER$USER
~/devenv/scripts/generate-certificate-browseruser.sh $CLUSTERNAME atlas chartmuseum-ui chartmuseum-ui $USER $USER$USER

# taint
date > ~/devenv/taints/created-users-chartmuseumui
