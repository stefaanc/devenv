#!/bin/bash

CLUSTERNAME=$1

echo "#"
echo "# create role-bindings"
echo "#"

kubectl apply -f ~/devenv/config/kube-manifests/default
kubectl apply -f ~/devenv/config/kube-manifests/kube-public
kubectl apply -f ~/devenv/config/kube-manifests/kube-system
echo ""

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
~/devenv/scripts/generate-certificate-user.sh $CLUSTERNAME default kubernetes kubernetes $USER $USER$USER "$GROUP"
~/devenv/scripts/generate-certificate-browserca.sh $CLUSTERNAME default kubernetes kubernetes $USER $USER$USER
~/devenv/scripts/generate-certificate-browseruser.sh $CLUSTERNAME default kubernetes kubernetes $USER $USER$USER
~/devenv/scripts/generate-config-user.sh $CLUSTERNAME default kubernetes $USER

# create local config
~/devenv/scripts/generate-config-user.sh $CLUSTERNAME default kubernetes $USER local
rm -f ~/.certs/$USER/$USER@kubernetes.conf
mv -f /home/$USER/.certs/$USER/$USER@kubernetes.conf /home/$USER/.kube/
cp /home/$USER/.kube/$USER@kubernetes.conf /home/$USER/.kube/config
chown $USER:$USER /home/$USER/.kube/config

# create local profile
if ! [ -f /home/$USER/.kube/profile ] ; then 
    cat <<EOF > /home/$USER/.kube/profile
export KUBECONFIG="/home/$USER/.kube/config"
EOF
    chown $USER:$USER /home/$USER/.kube/profile
fi
if ! ( grep 'KUBECONFIG' /home/$USER/.kube/profile | grep ".kube/$USER@kubernetes.$CLUSTERNAME.conf" ) >/bin/null ; then
    sed -i -e 's+"[ ]*$++g' -e "/KUBECONFIG/s+$+:/home/$USER/.kube/$USER@kubernetes.$CLUSTERNAME.conf\"+g" /home/$USER/.kube/profile
fi
echo ""

USER=chaz
GROUP=system:admins
echo "# ----------"
echo "# user: $USER"
echo "# ----------"
echo ""
~/devenv/scripts/generate-certificate-user.sh $CLUSTERNAME default kubernetes kubernetes $USER $USER$USER "$GROUP"
~/devenv/scripts/generate-certificate-browserca.sh $CLUSTERNAME default kubernetes kubernetes $USER $USER$USER
~/devenv/scripts/generate-certificate-browseruser.sh $CLUSTERNAME default kubernetes kubernetes $USER $USER$USER
~/devenv/scripts/generate-config-user.sh $CLUSTERNAME default kubernetes $USER

# create local config
~/devenv/scripts/generate-config-user.sh $CLUSTERNAME default kubernetes $USER local
rm -f ~/.certs/$USER/$USER@kubernetes.conf
mv -f /home/$USER/.certs/$USER/$USER@kubernetes.conf /home/$USER/.kube/
cp /home/$USER/.kube/$USER@kubernetes.conf /home/$USER/.kube/config
chown $USER:$USER /home/$USER/.kube/config

# create local profile
if ! [ -f /home/$USER/.kube/profile ] ; then 
    cat <<EOF > /home/$USER/.kube/profile
export KUBECONFIG="/home/$USER/.kube/config"
EOF
    chown $USER:$USER /home/$USER/.kube/profile
fi
if ! ( grep 'KUBECONFIG' /home/$USER/.kube/profile | grep ".kube/$USER@kubernetes.$CLUSTERNAME.conf" ) >/bin/null ; then
    sed -i -e 's+"[ ]*$++g' -e "/KUBECONFIG/s+$+;~/.kube/$USER@kubernetes.$CLUSTERNAME.conf\"+g" /home/$USER/.kube/profile
fi
echo ""

USER=will
GROUP=system:editors
echo "# ----------"
echo "# user: $USER"
echo "# ----------"
echo ""
~/devenv/scripts/generate-certificate-user.sh $CLUSTERNAME default kubernetes kubernetes $USER $USER$USER "$GROUP"
~/devenv/scripts/generate-certificate-browserca.sh $CLUSTERNAME default kubernetes kubernetes $USER $USER$USER
~/devenv/scripts/generate-certificate-browseruser.sh $CLUSTERNAME default kubernetes kubernetes $USER $USER$USER
~/devenv/scripts/generate-config-user.sh $CLUSTERNAME default kubernetes $USER

# create local config
~/devenv/scripts/generate-config-user.sh $CLUSTERNAME default kubernetes $USER local
rm -f ~/.certs/$USER/$USER@kubernetes.conf
mv -f /home/$USER/.certs/$USER/$USER@kubernetes.conf /home/$USER/.kube/
cp /home/$USER/.kube/$USER@kubernetes.conf /home/$USER/.kube/config
chown $USER:$USER /home/$USER/.kube/config

# create local profile
if ! [ -f /home/$USER/.kube/profile ] ; then 
    cat <<EOF > /home/$USER/.kube/profile
export KUBECONFIG="/home/$USER/.kube/config"
EOF
    chown $USER:$USER /home/$USER/.kube/profile
fi
if ! ( grep 'KUBECONFIG' /home/$USER/.kube/profile | grep ".kube/$USER@kubernetes.$CLUSTERNAME.conf" ) >/bin/null ; then
    sed -i -e 's+"[ ]*$++g' -e "/KUBECONFIG/s+$+;~/.kube/$USER@kubernetes.$CLUSTERNAME.conf\"+g" /home/$USER/.kube/profile
fi
echo ""

USER=hari
GROUP=system:viewers
echo "# ----------"
echo "# user: $USER"
echo "# ----------"
echo ""
~/devenv/scripts/generate-certificate-user.sh $CLUSTERNAME default kubernetes kubernetes $USER $USER$USER "$GROUP"
~/devenv/scripts/generate-certificate-browserca.sh $CLUSTERNAME default kubernetes kubernetes $USER $USER$USER
~/devenv/scripts/generate-certificate-browseruser.sh $CLUSTERNAME default kubernetes kubernetes $USER $USER$USER
~/devenv/scripts/generate-config-user.sh $CLUSTERNAME default kubernetes $USER

# create local config
~/devenv/scripts/generate-config-user.sh $CLUSTERNAME default kubernetes $USER local
rm -f ~/.certs/$USER/$USER@kubernetes.conf
mv -f /home/$USER/.certs/$USER/$USER@kubernetes.conf /home/$USER/.kube/
cp /home/$USER/.kube/$USER@kubernetes.conf /home/$USER/.kube/config
chown $USER:$USER /home/$USER/.kube/config

# create local profile
if ! [ -f /home/$USER/.kube/profile ] ; then 
    cat <<EOF > /home/$USER/.kube/profile
export KUBECONFIG="/home/$USER/.kube/config"
EOF
    chown $USER:$USER /home/$USER/.kube/profile
fi
if ! ( grep 'KUBECONFIG' /home/$USER/.kube/profile | grep ".kube/$USER@kubernetes.$CLUSTERNAME.conf" ) >/bin/null ; then
    sed -i -e 's+"[ ]*$++g' -e "/KUBECONFIG/s+$+;~/.kube/$USER@kubernetes.$CLUSTERNAME.conf\"+g" /home/$USER/.kube/profile
fi
echo ""

# taint
date > ~/devenv/taints/created-users-cluster
