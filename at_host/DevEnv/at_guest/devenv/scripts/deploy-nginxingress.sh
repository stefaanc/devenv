#!/bin/bash

CLUSTERNAME=$1

NAMESPACE='kube-ingress'

# TEMPLATE v0.0.1
#
# **DEVIATING FROM TEMPLATE:** the RELEASE_BASENAME is different from the SERVICE_BASENAME
# **DEVIATING FROM TEMPLATE:** adding default ingress with the load-balancer's IP as host

# reference: https://github.com/kubernetes/ingress-nginx
# reference: https://hub.helm.sh/charts/stable/nginx-ingress
# reference: https://kubernetes.github.io/ingress-nginx/

CLUSTER=$CLUSTERNAME
SERVER='apps'

SERVICE_BASENAME='apps'
SERVICE_QUALIFIER='r1'
SERVICE="$SERVICE_BASENAME-$SERVICE_QUALIFIER"

BACKEND_PROTOCOL='HTTP'
BACKEND_SERVICE=''
BACKEND_PORT='http'

LBIP=$( nslookup $SERVER.$CLUSTERNAME.localdomain | grep -A 1 "Name:" | grep "Address:" | awk '{print $2}' )

REPO_NAME='stable'
CHART_NAME='nginx-ingress'

if [ $REPO_NAME = 'config' ] ; then 
    CHART=~/devenv/config/helm-charts/$CHART_NAME-0.0.1
else
    helm repo update $REPO_NAME
    #helm fetch $REPO_NAME/$CHART_NAME --prov --destination ~/devenv/config/helm-charts # uncomment when using provenance
    helm fetch $REPO_NAME/$CHART_NAME --destination ~/devenv/config/helm-charts        # uncomment when not using provenance
    CHART=$( find ~/devenv/config/helm-charts/ -type f -name $CHART_NAME*.tgz -mmin -0.1 )
fi;

RELEASE_BASENAME="kube-ingress-nginx"
RELEASE="$RELEASE_BASENAME-$SERVICE_QUALIFIER"

cat <<EOF > ~/devenv/config/helm-charts/$CHART_NAME-values-custom.yaml
nameOverride: $RELEASE_BASENAME
controller:
  config: 
    location-snippet: |
    
      # for debugging 
      more_set_headers 'X-Ingress-Nginx-Namespace: \$namespace';
      more_set_headers 'X-Ingress-Nginx-Ingress-Name: \$ingress_name';
      more_set_headers 'X-Ingress-Nginx-Ingress-Host: \$host';
      more_set_headers 'X-Ingress-Nginx-Ingress-Location: \$location_path';
      more_set_headers 'X-Ingress-Nginx-Service-Name: \$service_name';
      more_set_headers 'X-Ingress-Nginx-Service-Port: \$service_port';
      
      # perform redirect defined in location's configuration-snippet
      if ( \$redirect_always ) {
          return 308 \$redirect_always;
      }
    
  service:
#    annotations: 
#      metallb.universe.tf/allow-shared-ip: "true"
    loadBalancerIP: $LBIP
  stats:
    enabled: true
  extraArgs:
    default-ssl-certificate: $NAMESPACE/$SERVICE_BASENAME-tls-server-certs
tcp: {}
#udp: 
#  53: kube-system/kube-dns:53
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

    cat ~/devenv/config/kube-manifests/kube-ingress/nginx-ingress/Ingress_default.yaml-sed | sed \
      -e "s/{cluster}/$CLUSTER/g" \
      -e "s/{server}/$SERVER/g" \
    | kubectl apply -f -
fi
echo ""

echo "#"
echo "# Deploy $CHART_NAME chart"
echo "#"

if [ -f $CHART.prov ] ; then
    helm install $CHART --verify --dry-run --debug \
      --namespace $NAMESPACE \
      --name $RELEASE \
      --values ~/devenv/config/helm-charts/$CHART_NAME-values-custom.yaml \
    > ~/devenv/logs/helm/nginx-ingress.log
fi

helm install $CHART \
  --namespace $NAMESPACE \
  --name $RELEASE \
  --values ~/devenv/config/helm-charts/$CHART_NAME-values-custom.yaml

# to verify the data stored in the kubernetes DB doesn't expose data that shouldn't be exposed
helm get manifest $RELEASE \
> ~/devenv/config/helm-charts/$CHART_NAME-manifest-applied.yaml

echo ""

# taint
date > ~/devenv/taints/deployed-$CHART_NAME
