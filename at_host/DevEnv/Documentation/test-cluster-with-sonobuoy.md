## Test Cluster With Sonobuoy

The steps are:
- [Test Cluster](#test-cluster)

in short:
- optionally follow [Test Cluster](#test-cluster)

[Go back to Overview](../README.html#overview)



### Test Cluster

> Reference: https://github.com/heptio/sonobuoy
> Reference: https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#optional-proxying-api-server-to-localhost

> **Remark:**
> Sonobuoy will only work if all nodes are "Ready" and all pods are "Running"**.  See [Test Cluster](create-cluster-for-kubernetes.html#test-cluster).

In File Explorer on the host, run `@ACP_Start-Proxy` as an administrator.
Alternatively, in a PowerShell on the host:
~~~
kubectl --kubeconfig $HOME\.kube\config proxy
~~~
You will get a message like `Starting to serve on 127.0.0.1:8001`.

In a browser on the host, go to page `https://scanner.heptio.com`

- Select "Scan your cluster".
- Copy the link (don't uncheck the RBAC option}.

In a terminal on `devenv0` (remark that you can also do this in a Powershell on the host, but this is rather slow), paste the link, and:
~~~
kubectl get pods --all-namespaces -o wide
~~~
Keep doing this until you have all sonobuoy-PODs in the "Running"-state, 

Your browser should start showing a "Your tests are running" message.  If it doesn't, then try to refresh the browser page.

When you received the report or the tests failed, and when Sonobuoy didn't clean up its PODs, clean-up the Kubernetes pods and namespaces.  You can also do this to interrupt the test  In a terminal for `devenv0`.
~~~
kubectl get pods --all-namespaces
kubectl delete namespace heptio-sonobuoy
kubectl get pods --all-namespaces
~~~

[Go to Top](#test-cluster-with-sonobuoy)
[Go back to Overview](../README.html#overview)



### What's Next?

- Go to previous step: [Create Cluster For Kubernetes](create-cluster-for-kubernetes.html)
- Go to next step: [Create Sandbox For Kubernetes](create-sandbox-for-kubernetes.html)

[Go to Top](#test-cluster-with-sonobuoy)
[Go back to Overview](../README.html#overview)



