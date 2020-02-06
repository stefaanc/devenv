kubectl create -f ~/devenv/config/kubectl-manifests/tools/Pod_busybox.yaml

kubectl exec -ti busybox -- nslookup kubernetes.default
kubectl exec busybox cat /etc/resolv.conf
