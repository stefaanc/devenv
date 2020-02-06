#!/bin/bash

CLUSTERNAME=$1

RELEASE='kube-metallb-r1'

# reference: https://github.com/google/metallb
# reference: https://hub.helm.sh/charts/stable/metallb
# reference: https://metallb.universe.tf/
echo "#"
echo "# Create namespace, service-accounts and role-bindings"
echo "#"

kubectl apply -f ~/devenv/config/kube-manifests/kube-ingress
kubectl apply -f ~/devenv/config/kube-manifests/kube-ingress/metallb
echo ""

echo "#"
echo "# Deploy metallb"
echo "#"

helm repo update stable

#helm fetch stable/metallb --prov --destination ~/devenv/config/helm-charts
helm fetch stable/metallb --destination ~/devenv/config/helm-charts
CHART=$( find ~/devenv/config/helm-charts/ -type f -name metallb*.tgz -mmin -0.5 )

if [ $CLUSTERNAME = 'repository' ] ; then 
    LB_DEFAULT='192.168.0.125-192.168.0.129'  # auto-assigned ingress-IPs
    LB_SYSTEM='192.168.0.29-192.168.0.29'     # ingress-IPs for system services
    LB_PUBLIC='192.168.0.120-192.168.0.124'   # ingress-IPs for public services
elif [ $CLUSTERNAME = 'development' ] ; then 
    LB_DEFAULT='192.168.0.155-192.168.0.159'  # auto-assigned ingress-IPs
    LB_SYSTEM='192.168.0.59-192.168.0.59'     # ingress-IPs for system services
    LB_PUBLIC='192.168.0.150-192.168.0.154'   # ingress-IPs for public services
fi

cat <<EOF > ~/devenv/config/helm-charts/metallb-values-custom.yaml
nameOverride: kube-metallb
configInline:
  address-pools:
  - name: default
    protocol: layer2
    addresses:
    - $LB_DEFAULT
  - name: reserved
    protocol: layer2
    addresses:
    - $LB_SYSTEM
    - $LB_PUBLIC
    auto-assign: false
EOF

#helm template $CHART \
#  --namespace kube-ingress \
#  --name $RELEASE \
#  --values ~/devenv/config/helm-charts/metallb-values-custom.yaml \
#> ~/devenv/config/helm-charts/metallb-manifest-rendered.yaml

if [ -f $CHART.prov ] ; then
    helm install $CHART --verify --dry-run --debug \
      --namespace kube-ingress \
      --name $RELEASE \
      --values ~/devenv/config/helm-charts/metallb-values-custom.yaml \
    > ~/devenv/logs/helm/metallb.log
fi

helm install $CHART \
  --namespace kube-ingress \
  --name $RELEASE \
  --values ~/devenv/config/helm-charts/metallb-values-custom.yaml
  
helm get manifest $RELEASE \
> ~/devenv/config/helm-charts/metallb-manifest-applied.yaml

echo ""

# taint
date > ~/devenv/taints/deployed-metallb
