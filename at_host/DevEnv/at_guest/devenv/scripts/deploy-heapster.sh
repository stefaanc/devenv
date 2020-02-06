#!/bin/bash

CLUSTERNAME=$1

RELEASE='kube-heapster-r1'

echo "#"
echo "# Create namespace, service-accounts and role-bindings"
echo "#"

kubectl apply -f ~/devenv/config/kube-manifests/kube-dashboard/heapster
echo ""

# reference: https://github.com/kubernetes-retired/heapster
# reference: https://hub.helm.sh/charts/stable/heapster
# reference: https://github.com/kubernetes-retired/heapster/blob/master/docs/source-configuration.md
echo "#"
echo "# Deploy heapster"
echo "#"

helm repo update stable

#helm fetch stable/heapster --prov --destination ~/devenv/config/helm-charts
helm fetch stable/heapster --destination ~/devenv/config/helm-charts
CHART=$( find ~/devenv/config/helm-charts/ -type f -name heapster*.tgz -mmin -0.5 )

cat <<EOF > ~/devenv/config/helm-charts/heapster-values-custom.yaml
nameOverride: x
command:
- "/heapster"
- "--source=kubernetes.summary_api:https://kubernetes.default.svc.$CLUSTERNAME.localdomain?kubeletHttps=true&kubeletPort=10250&insecure=true"
service:
  nameOverride: $RELEASE
rbac:
  create: false
  serviceAccountName: kube-heapster
EOF

#helm template $CHART \
#  --namespace kube-dashboard \
#  --name $RELEASE \
#  --values ~/devenv/config/helm-charts/heapster-values-custom.yaml \
#> ~/devenv/config/helm-charts/heapster-manifest-rendered.yaml

if [ -f $CHART.prov ] ; then
    helm install $CHART --verify --dry-run --debug \
      --namespace kube-dashboard \
      --name $RELEASE \
      --values ~/devenv/config/helm-charts/heapster-values-custom.yaml \
    > ~/devenv/logs/helm/heapster.log
fi

helm install $CHART \
  --namespace kube-dashboard \
  --name $RELEASE \
  --values ~/devenv/config/helm-charts/heapster-values-custom.yaml
  
helm get manifest $RELEASE \
> ~/devenv/config/helm-charts/heapster-manifest-applied.yaml

echo ""

echo "#"
echo "# Apply patches"
echo "#"

RESOURCE=$( kubectl get deployment -l "app=kube-dashboard" -n kube-dashboard -o name )
ARGS=$( kubectl get $RESOURCE -n kube-dashboard -o jsonpath='{.spec.template.spec.containers[0].args}' | sed -e 's/--/\n/g' )
HEAPSTER_HOST=$( echo "$ARGS" | awk '/heapster-host=/ {print NR-2}' )
if ! [ $HEAPSTER_HOST ] ; then
    OP='add'
    HEAPSTER_HOST='-'
else
    OP='replace'
fi

kubectl patch $RESOURCE -n kube-dashboard --type json --patch "
- op: $OP
  path: /spec/template/spec/containers/0/args/$HEAPSTER_HOST
  value: --heapster-host=http://$RELEASE.kube-dashboard.svc.$CLUSTERNAME.localdomain:8082
"

echo ""

# taint
date > ~/devenv/taints/deployed-heapster
