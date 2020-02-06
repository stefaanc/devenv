#!/bin/bash

CLUSTERNAME=$1

RELEASE='kube-influxdb-r1'

echo "#"
echo "# Create namespace, service-accounts and role-bindings"
echo "#"

kubectl apply -f ~/devenv/config/kube-manifests/kube-dashboard/influxdb
echo ""

# reference: https://github.com/influxdata/influxdb
# reference: https://hub.helm.sh/charts/stable/influxdb
echo "#"
echo "# Deploy influxdb"
echo "#"

helm repo update stable

#helm fetch stable/influxdb --prov --destination ~/devenv/config/helm-charts
helm fetch stable/influxdb --destination ~/devenv/config/helm-charts
CHART=$( find ~/devenv/config/helm-charts/ -type f -name influxdb*.tgz -mmin -0.5 )

cat <<EOF > ~/devenv/config/helm-charts/influxdb-values-custom.yaml
nameOverride: kubernetes-influxdb
fullnameOverride: $RELEASE
EOF

#helm template $CHART \
#  --namespace kube-dashboard \
#  --name $RELEASE \
#  --values ~/devenv/config/helm-charts/influxdb-values-custom.yaml \
#> ~/devenv/config/helm-charts/influxdb-manifest-rendered.yaml

if [ -f $CHART.prov ] ; then
    helm install $CHART --verify --dry-run --debug \
      --namespace kube-dashboard \
      --name $RELEASE \
      --values ~/devenv/config/helm-charts/influxdb-values-custom.yaml \
    > ~/devenv/logs/helm/influxdb.log
fi

helm install $CHART \
  --namespace kube-dashboard \
  --name $RELEASE \
  --values ~/devenv/config/helm-charts/influxdb-values-custom.yaml
  
helm get manifest $RELEASE \
> ~/devenv/config/helm-charts/influxdb-manifest-applied.yaml

echo ""

echo "#"
echo "# Apply patches"
echo "#"

RESOURCE=$( kubectl get deployment -l "app=kube-heapster-r1-x" -n kube-dashboard -o name )
ARGS=$( kubectl get $RESOURCE -n kube-dashboard -o jsonpath='{.spec.template.spec.containers[0].args}' | sed -e 's/--/\n/g' )
SINK=$( echo "$ARGS" | awk '/sink=/ {print NR-2}' )
if ! [ $SINK ] ; then
    OP='add'
    SINK='-'
else
    OP='replace'
fi

kubectl patch $RESOURCE -n kube-dashboard --type json --patch "
- op: $OP
  path: /spec/template/spec/containers/0/args/$SINK
  value: --sink=influxdb:http://$RELEASE.kube-dashboard.svc.$CLUSTERNAME.localdomain:8086
"

echo ""

# taint
date > ~/devenv/taints/deployed-influxdb
