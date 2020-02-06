#!/bin/bash

CLUSTERNAME=$1

NAMESPACE='depot'

# TEMPLATE v0.0.1
#
# **DEVIATING FROM TEMPLATE:** no deviations from template

# reference: https://github.com/silverwind/droppy

CLUSTER=$CLUSTERNAME
SERVER='droppy'

SERVICE_BASENAME='droppy'
SERVICE_QUALIFIER='r1'
SERVICE="$SERVICE_BASENAME-$SERVICE_QUALIFIER"

BACKEND_PROTOCOL='HTTPS'
BACKEND_SERVICE="$SERVICE_BASENAME"
BACKEND_PORT='https'

LBIP=$( nslookup $SERVER.$CLUSTERNAME.localdomain | grep -A 1 "Name:" | grep "Address:" | awk '{print $2}' )

REPO_NAME='config'
CHART_NAME='droppy'

if [ $REPO_NAME = 'config' ] ; then 
    CHART=~/devenv/config/helm-charts/$CHART_NAME-0.0.1
else
    helm repo update $REPO_NAME
    #helm fetch $REPO_NAME/$CHART_NAME --prov --destination ~/devenv/config/helm-charts # uncomment when using provenance
    helm fetch $REPO_NAME/$CHART_NAME --destination ~/devenv/config/helm-charts        # uncomment when not using provenance
    CHART=$( find ~/devenv/config/helm-charts/ -type f -name $CHART_NAME*.tgz -mmin -0.1 )
fi;

RELEASE_BASENAME="$SERVICE_BASENAME"
RELEASE="$RELEASE_BASENAME-$SERVICE_QUALIFIER"

cat <<EOF > ~/devenv/config/helm-charts/$CHART_NAME-values-custom.yaml
nameOverride: $RELEASE_BASENAME
tlsSecretName: $SERVICE_BASENAME-tls-server-certs
persistence:
  enabled: true
  storageClass: nfs-depot
securityContext:
  runAsUser: $( getent passwd depot | awk  -F ":" '{print $3}' )
  fsGroup: $( getent group depot | awk  -F ":" '{print $3}' )
EOF

helm template $CHART \
  --namespace $NAMESPACE \
  --name $RELEASE \
  --values ~/devenv/config/helm-charts/$CHART_NAME-values-custom.yaml \
> ~/devenv/config/helm-charts/$CHART_NAME-manifest-rendered.yaml

echo "#"
echo "# Generate a CA certificate for $SERVER server"
echo "# Generate TLS certificates for $SERVER server"
echo "#"

echo ""
~/devenv/scripts/generate-certificate-ca.sh $CLUSTERNAME $NAMESPACE $SERVICE_BASENAME $SERVER
~/devenv/scripts/generate-certificate-server.sh $CLUSTERNAME $NAMESPACE $SERVICE_BASENAME $SERVER $LBIP

echo "#"
echo "# Create namespace, services, service-accounts and rbac-resources"
echo "#"

kubectl apply -f ~/devenv/config/kube-manifests/$NAMESPACE
kubectl apply -f ~/devenv/config/kube-manifests/$NAMESPACE/$CHART_NAME
echo ""

echo "#"
echo "# Create secrets"
echo "#"

kubectl create secret tls $SERVICE_BASENAME-root-tls-server-certs -n kube-ingress \
  --cert /root/.pki/kubernetes/$SERVER/$SERVICE_BASENAME@$SERVER.$CLUSTERNAME.crt \
  --key /root/.pki/kubernetes/$SERVER/$SERVICE_BASENAME@$SERVER.$CLUSTERNAME.key

kubectl create secret tls $SERVICE_BASENAME-tls-server-certs -n $NAMESPACE \
  --cert /root/.pki/kubernetes/$SERVER/$SERVICE_BASENAME@$SERVER.$CLUSTERNAME.crt \
  --key /root/.pki/kubernetes/$SERVER/$SERVICE_BASENAME@$SERVER.$CLUSTERNAME.key

kubectl create secret generic $SERVICE_BASENAME-tls-client-ca -n $NAMESPACE \
  --from-file ca.crt=/root/.pki/kubernetes/$SERVER/ca@$SERVER.$CLUSTERNAME.crt
echo ""

#
# Create ingresses
#
if ! [ -z $BACKEND_SERVICE ] ; then
    echo "#"
    echo "# Create ingresses"
    echo "#"

    cat ~/devenv/config/kube-manifests/kube-ingress/nginx-ingress/Ingress_template-root.yaml-sed | sed \
      -e "s/{cluster}/$CLUSTER/g" \
      -e "s/{server}/$SERVER/g" \
      -e "s/{service-namespace}/$NAMESPACE/g" \
      -e "s/{service}/$SERVICE/g" \
      -e "s/{service-basename}/$SERVICE_BASENAME/g" \
    | kubectl apply -f -

    cat ~/devenv/config/kube-manifests/kube-ingress/nginx-ingress/Ingress_template-qualified.yaml-sed | sed \
      -e "s/{cluster}/$CLUSTER/g" \
      -e "s/{server}/$SERVER/g" \
      -e "s/{service-namespace}/$NAMESPACE/g" \
      -e "s/{service}/$SERVICE_BASENAME/g" \
      -e "s/{service-basename}/$SERVICE_BASENAME/g" \
      -e "s/{service-qualifier}/-/g" \
      -e "s/{backend-protocol}/$BACKEND_PROTOCOL/g" \
      -e "s/{backend-service}/$BACKEND_SERVICE/g" \
      -e "s/{backend-port}/$BACKEND_PORT/g" \
    | kubectl apply -f -
    
    cat ~/devenv/config/kube-manifests/kube-ingress/nginx-ingress/Ingress_template-qualified.yaml-sed | sed \
      -e "s/{cluster}/$CLUSTER/g" \
      -e "s/{server}/$SERVER/g" \
      -e "s/{service-namespace}/$NAMESPACE/g" \
      -e "s/{service}/$SERVICE/g" \
      -e "s/{service-basename}/$SERVICE_BASENAME/g" \
      -e "s/{service-qualifier}/$SERVICE_QUALIFIER/g" \
      -e "s/{backend-protocol}/$BACKEND_PROTOCOL/g" \
      -e "s/{backend-service}/$BACKEND_SERVICE-$SERVICE_QUALIFIER/g" \
      -e "s/{backend-port}/$BACKEND_PORT/g" \
    | kubectl apply -f -

    cat ~/devenv/config/kube-manifests/kube-ingress/nginx-ingress/Ingress_template-alias.yaml-sed | sed \
      -e "s/{cluster}/$CLUSTER/g" \
      -e "s/{server}/$SERVER/g" \
      -e "s/{service-namespace}/$NAMESPACE/g" \
      -e "s/{service}/$SERVICE/g" \
      -e "s/{service-basename}/$SERVICE_BASENAME/g" \
    | kubectl apply -f -
    echo ""
fi

echo "#"
echo "# Deploy $CHART_NAME chart"
echo "#"

if [ -f $CHART.prov ] ; then
    helm install $CHART --verify --dry-run --debug \
      --namespace $NAMESPACE \
      --name $RELEASE \
      --values ~/devenv/config/helm-charts/$CHART_NAME-values-custom.yaml \
    > ~/devenv/logs/helm/$CHART_NAME.log
fi

helm install $CHART \
  --namespace $NAMESPACE \
  --name $RELEASE \
  --values ~/devenv/config/helm-charts/$CHART_NAME-values-custom.yaml

# to verify the data stored in the kubernetes DB doesn't expose data that shouldn't be exposed
helm get manifest $RELEASE \
> ~/devenv/config/helm-charts/$CHART_NAME-manifest-applied.yaml

echo ""

echo "#"
echo "# Waiting until $SERVICE pod is ready"
echo "#"

JSONPATH='{range .items[*]}{@.metadata.name} {range @.status.conditions[*]}{@.type}={@.status} {end}{end}'
while true; do 
    kubectl get pods --namespace $NAMESPACE --selector "app=$SERVICE_BASENAME" -o jsonpath="$JSONPATH" | grep " Ready=True " && break 
    echo "No resources found."
    sleep 5
done

# taint
date > ~/devenv/taints/deployed-$CHART_NAME
