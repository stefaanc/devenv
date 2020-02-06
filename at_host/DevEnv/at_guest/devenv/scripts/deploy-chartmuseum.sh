#!/bin/bash

RELEASE='atlas-r1'

# reference: https://github.com/helm/chartmuseum
# reference: https://hub.helm.sh/charts/stable/chartmuseum
# reference: https://chartmuseum.com/docs/
echo "#"
echo "# Create namespace, service-accounts and role-bindings"
echo "#"

kubectl apply -f ~/devenv/config/kube-manifests/atlas
kubectl apply -f ~/devenv/config/kube-manifests/atlas/chartmuseum
echo ""

echo "#"
echo "# Deploy chartmuseum"
echo "#"

helm repo update stable

#helm fetch stable/chartmuseum --prov --destination ~/devenv/config/helm-charts
helm fetch stable/chartmuseum --destination ~/devenv/config/helm-charts
CHART=$( find ~/devenv/config/helm-charts/ -type f -name chartmuseum*.tgz -mmin -0.5 )

cat <<EOF > ~/devenv/config/helm-charts/chartmuseum-values-custom.yaml
nameOverride: atlas
fullnameOverride: $RELEASE
env:
  open:
    DISABLE_API: false
persistence:
  enabled: true
  accessMode: ReadWriteMany
  storageClass: nfs-atlas
securityContext:
  runAsUser: $( getent passwd atlas | awk  -F ":" '{print $3}' )
  fsGroup: $( getent group atlas | awk  -F ":" '{print $3}' )
serviceAccount:
  create: false
EOF

#helm template $CHART \
#  --namespace atlas \
#  --name $RELEASE \
#  --values ~/devenv/config/helm-charts/chartmuseum-values-custom.yaml \
#> ~/devenv/config/helm-charts/chartmuseum-manifest-rendered.yaml

if [ -f $CHART.prov ] ; then
    helm install $CHART --verify --dry-run --debug \
      --namespace atlas \
      --name $RELEASE \
      --values ~/devenv/config/helm-charts/chartmuseum-values-custom.yaml \
    > ~/devenv/logs/helm/chartmuseum.log
fi

helm install $CHART \
  --namespace atlas \
  --name $RELEASE \
  --values ~/devenv/config/helm-charts/chartmuseum-values-custom.yaml
  
helm get manifest $RELEASE \
> ~/devenv/config/helm-charts/chartmuseum-manifest-applied.yaml

echo ""

echo "#"
echo "# Apply patches"
echo "#"

kubectl patch persistentvolumeclaim $RELEASE -n atlas --patch "
metadata:
  labels:
    app: atlas
    chart: $( kubectl get deployment $RELEASE -n atlas -o yaml | grep 'chart:' | awk '{print $2}' )
    heritage: $( kubectl get deployment $RELEASE -n atlas -o yaml | grep 'heritage:' | awk '{print $2}' )
"
echo ""

# taint
date > ~/devenv/taints/deployed-chartmuseum
