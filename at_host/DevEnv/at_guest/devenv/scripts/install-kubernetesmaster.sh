#!/bin/bash

CLUSTERNAME=$1
CIDR_NETWORK=$2

echo "#"
echo "# !!! master node is also a worker !!!"
echo "#"
echo ""

echo "#"
echo "# Add kubernetes to /etc/hosts"
echo "#"

if ! cat /etc/hosts | grep $CLUSTERNAME >/bin/null ; then
    sed -i "s/$HOSTNAME.*/&   $CLUSTERNAME $CLUSTERNAME.localdomain/" /etc/hosts
fi
echo ""

# reference: https://kubernetes.io/docs/setup/independent/install-kubeadm//#check-required-ports
# reference: https://stackoverflow.com/questions/24729024/open-firewall-port-on-centos-7
# reference: https://github.com/coreos/flannel/blob/master/Documentation/troubleshooting.md#firewalls
echo "#"
echo "# Open firewall ports for master node"
echo "# (master node will also be a worker)"
echo "#"

firewall-cmd --permanent --zone=public --add-port=6443/tcp      # kube-apiserver
firewall-cmd --permanent --zone=public --add-port=2379-2380/tcp # etcd
firewall-cmd --permanent --zone=public --add-port=10251/tcp     # kube-scheduler
firewall-cmd --permanent --zone=public --add-port=10252/tcp     # kube-controller-manager
firewall-cmd --reload
echo ""

# reference: https://kubernetes.io/docs/setup/independent/install-kubeadm
echo "#"
echo "# Install kubectl"
echo "#"

yum install -y kubectl --disableexcludes=kubernetes
echo ""

echo "#"
echo "# Reset previous kubernetes initialization (if there was one)"
echo "#"

kubeadm reset -f 
rm ~/.kube/*     
echo ""

echo "#"
echo "# Generate a CA certificte for the kubernetes service"
echo "#"

echo ""
~/devenv/scripts/generate-certificate-ca.sh $CLUSTERNAME default kubernetes kubernetes

if ! [ -d /etc/kubernetes/pki ] ; then
    mkdir -p /etc/kubernetes/pki
fi
chmod 700 /etc/kubernetes/pki
cp -f ~/.pki/kubernetes/ca@kubernetes.$CLUSTERNAME.crt /etc/kubernetes/pki/ca.crt
cp -f ~/.pki/kubernetes/ca@kubernetes.$CLUSTERNAME.key /etc/kubernetes/pki/ca.key
echo ""

# reference: https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm
echo "#"
echo "# Initialize Kubernetes"
echo "#"

kubeadm config images pull

kubeadm config print init-defaults | grep -A 99 -e '---' | sed \
  -e "s|apiServer:.*|&\n\
  certSANs:\n\
  - $HOSTNAME.localdomain\n\
  - $CLUSTERNAME\n\
  - $CLUSTERNAME.localdomain\
  |" \
  -e "s|clusterName: kubernetes|clusterName: $CLUSTERNAME|" \
  -e "s|dnsDomain: cluster.local|dnsDomain: $CLUSTERNAME.localdomain|" \
  -e "s|podSubnet: \"\"|podSubnet: $CIDR_NETWORK|" \
> ./cluster-config.yaml

kubeadm init \
  --config ./cluster-config.yaml
  
#  --apiserver-cert-extra-sans "$HOSTNAME.localdomain,$CLUSTERNAME,$CLUSTERNAME.localdomain" \
#  --pod-network-cidr $CIDR_NETWORK \
#  --service-dns-domain $CLUSTERNAME.localdomain \

rm -f ./cluster-config.yaml
cp /etc/kubernetes/manifests/* ~/devenv/config/kube-manifests/

echo "Subject Alternative Names for apiserver certificate:"
openssl x509 -text -noout -in /etc/kubernetes/pki/apiserver.crt | grep 'DNS' | sed 's/ //g' |  tr ',' '\n' | sort
echo ""

# reference: https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm
echo "#"
echo "# Make kubectl work persistently for root"
echo "#"

mkdir -p /root/.kube
cp -f /etc/kubernetes/admin.conf /root/.kube/kubernetes-admin@kubernetes.$CLUSTERNAME.conf
cp -f /etc/kubernetes/admin.conf /root/.kube/config

# create local profile
if ! [ -f /root/.kube/profile ] ; then 
    cat <<EOF > /root/.kube/profile
export KUBECONFIG="/root/.kube/config"
EOF
fi
. /root/.kube/profile
echo ""

echo "#"
echo "# Extract certificate and key of root from kubernetes-admin.conf"
echo "#"

if ! [ -d ~/.certs/kubernetes-admin ] ; then
    mkdir -p ~/.certs/kubernetes-admin
fi
cp -f ~/.pki/kubernetes/ca@kubernetes.$CLUSTERNAME.crt ~/.certs/kubernetes-admin
grep 'client-certificate-data' ~/.kube/kubernetes-admin@kubernetes.$CLUSTERNAME.conf \
| head -n 1 \
| awk '{print $2}' \
| base64 -d \
> ~/.certs/kubernetes-admin/kubernetes-admin@kubernetes.$CLUSTERNAME.crt
grep 'client-key-data' ~/.kube/kubernetes-admin@kubernetes.$CLUSTERNAME.conf \
| head -n 1 \
| awk '{print $2}' \
| base64 -d \
> ~/.certs/kubernetes-admin/kubernetes-admin@kubernetes.$CLUSTERNAME.key
echo ""

chmod 700 ~/.certs
chmod 700 ~/.certs/kubernetes-admin
chmod 600 ~/.certs/kubernetes-admin/*
chmod 644 ~/.certs/kubernetes-admin/*.crt
echo ""

# reference: https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm
# reference: https://github.com/coreos/flannel
echo "#"
echo "# Install Flannel POD-network"
echo "#"

curl -L https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml \
> ~/devenv/config/kube-manifests/kube-flannel.yaml

kubectl apply -f ~/devenv/config/kube-manifests/kube-flannel.yaml
echo ""

# reference: https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm
echo "#"
echo "# Control plane node isolation - allow master node to run pods"
echo "#"

kubectl taint nodes --all node-role.kubernetes.io/master-
echo ""

# taint
date > ~/devenv/taints/installed-kubernetesmaster
