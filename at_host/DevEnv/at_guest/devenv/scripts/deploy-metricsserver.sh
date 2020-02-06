#!/bin/bash

CLUSTERNAME=$1

RELEASE='kube-metrics-r1'

echo "#"
echo "# Create namespace, service-accounts and role-bindings"
echo "#"

kubectl apply -f ~/devenv/config/kube-manifests/kube-system/metrics-server
echo ""

# reference: https://github.com/kubernetes-incubator/metrics-server
# reference: https://hub.helm.sh/charts/stable/metrics-server
echo "#"
echo "# Deploy metrics-server"
echo "#"

helm repo update stable

#helm fetch stable/metrics-server --prov --destination ~/devenv/config/helm-charts
helm fetch stable/metrics-server --destination ~/devenv/config/helm-charts
CHART=$( find ~/devenv/config/helm-charts/ -type f -name metrics-server*.tgz -mmin -0.5 )

cat <<EOF > ~/devenv/config/helm-charts/metrics-server-values-custom.yaml
nameOverride: kube-metrics
args:
  - --logtostderr
  - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
  - --kubelet-insecure-tls
EOF

#helm template $CHART \
#  --namespace kube-system \
#  --name $RELEASE \
#  --values ~/devenv/config/helm-charts/metrics-server-values-custom.yaml \
#> ~/devenv/config/helm-charts/metrics-server-manifest-rendered.yaml

if [ -f $CHART.prov ] ; then
    helm install $CHART --verify --dry-run --debug \
      --namespace kube-system \
      --name $RELEASE \
      --values ~/devenv/config/helm-charts/metrics-server-values-custom.yaml \
    > ~/devenv/logs/helm/metrics-server.log
fi

helm install $CHART \
  --namespace kube-system \
  --name $RELEASE \
  --values ~/devenv/config/helm-charts/metrics-server-values-custom.yaml
  
helm get manifest $RELEASE \
> ~/devenv/config/helm-charts/metrics-server-manifest-applied.yaml

echo ""

# taint
date > ~/devenv/taints/deployed-metricsserver
