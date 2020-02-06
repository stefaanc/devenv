#!/bin/bash

# reference: https://github.com/chartmuseum/helm-push
echo "#"
echo "# Install helm-push plugin for root"
echo "#"

helm plugin install https://github.com/chartmuseum/helm-push
echo ""

echo "#"
echo "# Waiting until atlas-pod is ready"
echo "#"

JSONPATH='{range .items[*]}{@.metadata.name} {range @.status.conditions[*]}{@.type}={@.status} {end}{end}'
while true; do 
    #kubectl get pods --namespace atlas --selector "app=atlas" -o jsonpath="$JSONPATH" 2>/bin/null | grep " Ready=True " && break 
    kubectl get pods --namespace atlas --selector "app=atlas" -o jsonpath="$JSONPATH" | grep " Ready=True " && break 
    echo "No resources found."
    sleep 5
done
sleep 5   # some extra time, needed for cm://atlas.repository.localdomain:8080 to be available
echo ""

echo "#"
echo "# Add repo to helm repos for root"
echo "#"

cat <<EOF >> ~/.helm/profile
export HELM_REPO_USE_HTTP="true"
EOF
. ~/.helm/profile

#alias helm-push='helm push'

helm repo add atlas cm://atlas.repository.localdomain:8080

# using kubectl for atlas
#     export HELM_REPO_CA_FILE="/root/.certs/kubernetes-admin/ca@kubernetes.repository.crt"
#     export HELM_REPO_CERT_FILE="/root/.certs/kubernetes-admin/kubernetes-admin@kubernetes.repository.crt"
#     export HELM_REPO_KEY_FILE="/root/.certs/kubernetes-admin/kubernetes-admin@kubernetes.repository.key"
#     export HELM_REPO_CONTEXT_PATH="/api/v1/namespaces/atlas/services/http:atlas:http/proxy"
#     helm repo add atlas cm://repository:6443$HELM_REPO_CONTEXT_PATH

# using kubectl forwarding proxy for atlas
#     export POD=$( kubectl get pods --namespace atlas --selector "app=atlas" -o jsonpath="{.items[0].metadata.name}" )
#     kubectl --namespace atlas port-forward $POD 8080:8080 &
#     export HELM_REPO_USE_HTTP="true"
#     helm repo add atlas cm://localhost:8080/

# not (yet) using variable
#     export HELM_REPO_ACCESS_TOKEN="<token>"

helm repo update atlas
echo ""

# taint
date > ~/devenv/taints/installed-helmpush
