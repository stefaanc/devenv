#!/bin/bash

CLUSTERNAME=$1

# reference: https://docs.helm.sh/using_helm/#from-script
echo "#"
echo "# Install helm"
echo "#"

curl https://raw.githubusercontent.com/helm/helm/master/scripts/get > ~/devenv/scripts/get_helm.sh
chmod 755 ~/devenv/scripts/get_helm.sh
~/devenv/scripts/get_helm.sh
echo ""

echo "#"
echo "# Initialize helm"
echo "#"

helm init --client-only

cat <<EOF > ~/.helm/profile
export HELM_TLS_VERIFY="true"
export HELM_TLS_CA_CERT="/root/.certs/kubernetes-admin/ca@kube-tiller.$CLUSTERNAME.crt"
export HELM_TLS_CERT="/root/.certs/kubernetes-admin/kubernetes-admin@kube-tiller.$CLUSTERNAME.crt"
export HELM_TLS_KEY="/root/.certs/kubernetes-admin/kubernetes-admin@kube-tiller.$CLUSTERNAME.key"
export TILLER_NAMESPACE="kube-apps"
EOF
. ~/.helm/profile

#alias helm-create='helm create'
#alias helm-delete='helm --tls delete'
#alias helm-dependency='helm dependency'
#alias helm-fetch='helm fetch'
#alias helm-get='helm --tls get'
#alias helm-history='helm --tls history'
#alias helm-home='helm home'
#alias helm-inspect='helm inspect'
#alias helm-install='helm --tls install'
#alias helm-lint='helm lint'
#alias helm-list='helm --tls list'
#alias helm-package='helm package'
#alias helm-plugin='helm plugin'
#alias helm-repo='helm repo'
#alias helm-rollback='helm --tls rollback'
#alias helm-search='helm search'
#alias helm-serve='helm serve'
#alias helm-status='helm --tls status'
#alias helm-template='helm template'
#alias helm-test='helm --tls test'
#alias helm-upgrade='helm --tls upgrade'
#alias helm-verify='helm verify'
#alias helm-version='helm --tls version'

echo ""

# reference: https://docs.helm.sh/using_helm/#installing-tiller
echo "#"
echo "# create namespace, service-accounts and role-bindings"
echo "#"

kubectl apply -f ~/devenv/config/kube-manifests/kube-apps
kubectl apply -f ~/devenv/config/kube-manifests/kube-apps/kubernetes-tiller
echo ""

# reference: https://docs.helm.sh/using_helm/#generating-certificates
echo "#"
echo "# Generate a CA certificte for kubernetes-tiller service,"
echo "# Generate TLS certificates for tiller and tiller-client/helm-user kubernetes-admin"
echo "#"

echo ""
~/devenv/scripts/generate-certificate-ca.sh $CLUSTERNAME kube-apps kube-tiller kube-tiller
~/devenv/scripts/generate-certificate-server.sh $CLUSTERNAME kube-apps kube-tiller kube-tiller
~/devenv/scripts/generate-certificate-user.sh $CLUSTERNAME kube-apps kube-tiller kube-tiller kubernetes-admin rootroot system:masters

echo "#"
echo "# Create secrets"
echo "#"

kubectl create secret generic kube-tiller-tls-server-certs -n kube-apps \
  --from-file ca.crt=/root/.pki/kubernetes/kube-tiller/ca@kube-tiller.$CLUSTERNAME.crt \
  --from-file tls.crt=/root/.pki/kubernetes/kube-tiller/kube-tiller@kube-tiller.$CLUSTERNAME.crt \
  --from-file tls.key=/root/.pki/kubernetes/kube-tiller/kube-tiller@kube-tiller.$CLUSTERNAME.key
echo ""

# reference: https://docs.helm.sh/using_helm/#installing-tiller
# reference: https://docs.helm.sh/using_helm/#securing-your-helm-installation
echo "#"
echo "# Deploy tiller"
echo "#"

cat <<EOF > _empty
EOF

helm init --output yaml \
  --tiller-namespace kube-apps \
  --override 'spec.template.spec.containers[0].command'='{/tiller,--storage=secret}' \
  --tiller-tls \
  --tiller-tls-verify \
  --tls-ca-cert /root/.pki/kubernetes/kube-tiller/ca@kube-tiller.$CLUSTERNAME.crt \
  --tiller-tls-cert _empty \
  --tiller-tls-key _empty \
  --service-account kube-tiller \
> ~/devenv/config/kube-manifests/kubernetes-tiller.yaml

rm -f _empty

kubectl apply -f ~/devenv/config/kube-manifests/kubernetes-tiller.yaml

echo ""

echo "#"
echo "# Apply patches"
echo "#"

kubectl patch deployment tiller-deploy -n kube-apps --type json --patch "
- op: replace
  path: /spec/template/spec/volumes/0/secret/secretName
  value: kube-tiller-tls-server-certs
"
kubectl delete secret tiller-secret -n kube-apps
echo ""

echo "#"
echo "# Waiting until tiller-pod is running"
echo "#"

while true; do 
    #kubectl get pods --namespace kube-apps --selector "app=helm,name=tiller" --field-selector "status.phase=Running" 2>/bin/null | grep Running &&break
    kubectl get pods --namespace kube-apps --selector "app=helm,name=tiller" --field-selector "status.phase=Running" | grep Running && break 
    sleep 5
done
echo ""

# taint
date > ~/devenv/taints/installed-helm
