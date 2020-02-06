## Create Sandbox For Kubernetes

The steps are:

in short:


[Go back to Overview](../README.html#overview)


### Create Users And Groups

To clean-up and extend the currently defined user-set - trying to come to a simple and consistent situation.
- create linux users
- create linux groups and set default linux groups for each user
- create kubernetes cluster-roles
- create kubernetes cluster-role-bindings for the root and master accounts only
- create kubernetes:kube-system role-bindings for the others
- create ~/.kube and ~/.certs folders for each user and for host, secure them all with +600
- create certificates (.crt and .p12) and private keys (.key)
- create config files
- copy all to host
- replace the old kubernetes-admin config for the root user with his new config
- rename the old /etc/kubernetes/admin.conf to /etc/kubernetes/kubernetes-admin.conf (just in case we need it at some point)
- add the new configs to /etc/kubernetes

user   | password | linux groups (default first)   | k8s groups     | k8s clusterrole
-------|----------|--------------------------------|----------------|------------------
root   | rootroot | root                           | system:masters | cluster-admin
master | mastmast | masters, master, wheel, docker | system:masters | cluster-admin
admin  | admiadmi | admins, admin                  | system:admins  | admin
editor | editedit | editors, editor                | system:editors | edit
viewer | viewview | viewers, viewer                | system:viewers | view



### Create Sandbox Namespace


[Go to Top](#create-sandbox-for-kubernetes)
[Go back to Overview](../README.html#overview)



### What's Next?

- Go to previous step: [Test Cluster With Sonobuoy](test-cluster-with-sonobuoy.html)
- Go to next step: [Deploy Helm Package Manager For Kubernetes](deploy-helm-package-manager-for-kubernetes.html)

[Go to Top](#create-sandbox-for-kubernetes)
[Go back to Overview](../README.html#overview)



