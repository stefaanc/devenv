## Deploy Helm Package Manager For Kubernetes

> **Remark:**
> **The following is based on the Helm version `2.12.1`.  The steps below and the scripts for the Hyper-V guests may need to be adapted when using a different version.**

The steps are:

in short:

[Go back to Overview](../README.html#overview)



### Configure Role-Based Access Control (RBAC) For Clients

> Reference: https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/
> Reference: https://kubernetes.io/docs/tasks/administer-cluster/namespaces-walkthrough/
> Reference: https://kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin/
> Reference: https://kubernetes.io/docs/reference/access-authn-authz/rbac/
> Reference: https://docs.bitnami.com/kubernetes/how-to/configure-rbac-in-your-kubernetes-cluster/
> Reference: https://github.com/helm/helm/blob/master/docs/rbac.md



https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/
https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/
https://kubernetes.io/docs/reference/kubectl/cheatsheet/#kubectl-context-and-configuration
`kubectl config view`


In File Explorer on the host, run `@ACP_Configure-RBAC-tiller-client` as an administrator.
Alternatively, in a PowerShell on the host:
~~~
Configure-RBAC devenv0 tiller-client
~~~


[Go to Top](#deploy-helm-package-manager-for-kubernetes)
[Go back to Overview](../README.html#overview)



### Install Helm Client And Deploy Tiller Server

> Reference: https://docs.helm.sh/using_helm


[Go to Top](#deploy-helm-package-manager-for-kubernetes)
[Go back to Overview](../README.html#overview)



### What's Next?

- Go to previous step: [Create Sandbox For Kubernetes](create-sandbox-for-kubernetes.html)
- Go to next step: [Deploy Dashboard For Kubernetes](deploy-dashboard-for-kubernetes.html)

[Go to Top](#deploy-helm-package-manager-for-kubernetes)
[Go back to Overview](../README.html#overview)



