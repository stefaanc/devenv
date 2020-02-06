kubectl get pods --namespace kube-tiller -l "app=tiller" -o jsonpath="{.items[0].metadata.name}" > %HOMEDRIVE%%HOMEPATH%\DevEnv\Scripts\_temp
set /P POD=< %HOMEDRIVE%%HOMEPATH%\DevEnv\Scripts\_temp
del %HOMEDRIVE%%HOMEPATH%\DevEnv\Scripts\_temp
start "Dashboard Proxy" cmd /C "kubectl --kubeconfig=%HOMEDRIVE%%HOMEPATH%\.kube\beth@kubernetes.development.conf --namespace kube-tiller port-forward %POD% 44134:44134 & pause"
