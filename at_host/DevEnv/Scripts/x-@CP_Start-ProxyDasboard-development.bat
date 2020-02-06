kubectl get pods --namespace kube-system -l "app=kubernetes-dashboard" -o jsonpath="{.items[0].metadata.name}" > %HOMEDRIVE%%HOMEPATH%\DevEnv\Scripts\_temp
set /P POD=< %HOMEDRIVE%%HOMEPATH%\DevEnv\Scripts\_temp
del %HOMEDRIVE%%HOMEPATH%\DevEnv\Scripts\_temp
start "Dashboard Proxy" cmd /C "kubectl --kubeconfig=%HOMEDRIVE%%HOMEPATH%\.kube\beth@kubernetes.development.conf --namespace kube-system port-forward %POD% 58443:8443 & pause"
