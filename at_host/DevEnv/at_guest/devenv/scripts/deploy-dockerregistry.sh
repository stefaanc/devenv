#!/bin/bash

CLUSTERNAME=$1

RELEASE='terminal-r1'

# reference: https://hub.helm.sh/charts/stable/docker-registry
echo "#"
echo "# Create service-accounts and role-bindings"
echo "#"

kubectl apply -f ~/devenv/config/kube-manifests/terminal
kubectl apply -f ~/devenv/config/kube-manifests/terminal/dockerregistry
echo ""

# reference: https://docs.docker.com/registry/deploying/#get-a-certificate
echo "#"
echo "# Generate a CA certificate for terminal server"
echo "# Generate TLS certificates for terminal server"
echo "#"

echo ""
~/devenv/scripts/generate-certificate-ca.sh $CLUSTERNAME terminal terminal terminal
~/devenv/scripts/generate-certificate-server.sh $CLUSTERNAME terminal terminal terminal "192.168.0.121"

kubectl patch secret terminal-tls-server-certs -n terminal --patch "
data:
  tls.crt: |-
    $( cat /root/.pki/kubernetes/terminal/terminal@terminal.$CLUSTERNAME.crt /root/.pki/kubernetes/terminal/ca@terminal.$CLUSTERNAME.crt | base64 -w 0 )
  tls.key: |-
    $( base64 -w 0 /root/.pki/kubernetes/terminal/terminal@terminal.$CLUSTERNAME.key )
"
echo ""

echo "#"
echo "# Generate TLS certificates for terminal client"
echo "#"

echo ""
~/devenv/scripts/generate-certificate-client.sh $CLUSTERNAME terminal terminal terminal docker

mkdir -p /etc/docker/certs.d/terminal.$CLUSTERNAME.localdomain
cp /root/.pki/kubernetes/docker/ca@terminal.$CLUSTERNAME.crt /etc/docker/certs.d/terminal.$CLUSTERNAME.localdomain/ca.crt
cp /root/.pki/kubernetes/docker/docker@terminal.$CLUSTERNAME.crt /etc/docker/certs.d/terminal.$CLUSTERNAME.localdomain/docker.cert
cp /root/.pki/kubernetes/docker/docker@terminal.$CLUSTERNAME.key /etc/docker/certs.d/terminal.$CLUSTERNAME.localdomain/docker.key

chmod 700 /etc/docker/certs.d 
find   /etc/docker/certs.d   -mindepth 1 -type d -print0 | xargs -0r chmod 700
find   /etc/docker/certs.d   -mindepth 1 -type f -print0 | xargs -0r chmod 600
find   /etc/docker/certs.d   -mindepth 1 -type f   -name *.crt     -print0 | xargs -0r chmod 644
find   /etc/docker/certs.d   -mindepth 1 -type f   -name *.cert     -print0 | xargs -0r chmod 644
echo ""

echo "#"
echo "# Deploy dockerregistry"
echo "#"

helm repo update stable

#helm fetch stable/docker-registry --prov --destination ~/devenv/config/helm-charts
helm fetch stable/docker-registry --destination ~/devenv/config/helm-charts
CHART=$( find ~/devenv/config/helm-charts/ -type f -name docker-registry*.tgz -mmin -0.5 )

cat <<EOF > ~/devenv/config/helm-charts/docker-registry-values-custom.yaml
nameOverride: terminal
tlsSecretName: terminal-tls-server-certs
persistence:
  enabled: true
  accessMode: ReadWriteMany
  storageClass: nfs-terminal
securityContext:
  runAsUser: $( getent passwd terminal | awk  -F ":" '{print $3}' )
  fsGroup: $( getent group terminal | awk  -F ":" '{print $3}' )
EOF

#helm template $CHART \
#  --namespace terminal \
#  --name $RELEASE \
#  --values ~/devenv/config/helm-charts/docker-registry-values-custom.yaml \
#> ~/devenv/config/helm-charts/docker-registry-manifest-rendered.yaml

if [ -f $CHART.prov ] ; then
    helm install $CHART --verify --dry-run --debug \
      --namespace terminal \
      --name $RELEASE \
      --values ~/devenv/config/helm-charts/docker-registry-values-custom.yaml \
    > ~/devenv/logs/helm/docker-registry.log
fi

helm install $CHART \
  --namespace terminal \
  --name $RELEASE \
  --values ~/devenv/config/helm-charts/docker-registry-values-custom.yaml
  
helm get manifest $RELEASE \
> ~/devenv/config/helm-charts/docker-registry-manifest-applied.yaml

echo ""

echo "#"
echo "# Apply patches"
echo "#"

kubectl patch persistentvolumeclaim $RELEASE -n terminal --patch "
metadata:
  labels:
    app: terminal
"
echo ""

# taint
date > ~/devenv/taints/deployed-dockerregistry
