kubectl get pods --namespace kube-apps -l "app=kube-apps-r1" -o jsonpath="{.items[0].metadata.name}" > %HOMEDRIVE%%HOMEPATH%\DevEnv\Scripts\_temp
set /P POD=< %HOMEDRIVE%%HOMEPATH%\DevEnv\Scripts\_temp
del %HOMEDRIVE%%HOMEPATH%\DevEnv\Scripts\_temp
start "Kubeapps Proxy" cmd /C "kubectl --kubeconfig=%HOMEDRIVE%%HOMEPATH%\.kube\beth@kubernetes.development.conf --namespace kube-apps port-forward %POD% 58080:8080 & pause"