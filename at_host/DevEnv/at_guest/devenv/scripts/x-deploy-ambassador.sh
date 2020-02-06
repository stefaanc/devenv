#!/bin/bash

RELEASE='kube-ambassador-r1'

# reference: https://github.com/datawire/ambassador
# reference: https://hub.helm.sh/charts/stable/ambassador
# reference: https://www.getambassador.io/
echo "#"
echo "# Create namespace, service-accounts and role-bindings"
echo "#"

kubectl apply -f ~/devenv/config/kube-manifests/kube-ingress
kubectl apply -f ~/devenv/config/kube-manifests/kube-ingress/ambassador
echo ""

echo "#"
echo "# Deploy ambassador"
echo "#"

helm repo update stable

#helm fetch stable/ambassador --prov --destination ~/devenv/config/helm-charts
helm fetch stable/ambassador --destination ~/devenv/config/helm-charts
CHART=$( find ~/devenv/config/helm-charts/ -type f -name ambassador*.tgz -mmin -0.5 )

cat <<EOF > ~/devenv/config/helm-charts/ambassador-values-custom.yaml
nameOverride: kube-ambassador
fullnameOverride: $RELEASE
replicaCount: 1
EOF

#helm template $CHART \
#  --namespace kube-ingress \
#  --name $RELEASE \
#  --values ~/devenv/config/helm-charts/ambassador-values-custom.yaml \
#> ~/devenv/config/helm-charts/ambassador-manifest-rendered.yaml

if [ -f $CHART.prov ] ; then
    helm install $CHART --verify --dry-run --debug \
      --namespace kube-ingress \
      --name $RELEASE \
      --values ~/devenv/config/helm-charts/ambassador-values-custom.yaml \
    > ~/devenv/logs/helm/ambassador.log
fi

helm install $CHART \
  --namespace kube-ingress \
  --name $RELEASE \
  --values ~/devenv/config/helm-charts/ambassador-values-custom.yaml
  
helm get manifest $RELEASE \
> ~/devenv/config/helm-charts/ambassador-manifest-applied.yaml

echo ""

# taint
date > ~/devenv/taints/deployed-ambassador
