apiVersion: v1
kind: Config
clusters:
- name: <clustername>
  cluster:
    certificate-authority: <ca-crt>
    server: https://<clustername>.localdomain:6443
contexts:
- name: <username>@default.<clustername>
  context:
    cluster: <clustername>
    namespace: default
    user: <username>@kubernetes.<clustername>
- name: <username>@kube-public.<clustername>
  context:
    cluster: <clustername>
    namespace: kube-public
    user: <username>@kubernetes.<clustername>
- name: <username>@kube-system.<clustername>
  context:
    cluster: <clustername>
    namespace: kube-system
    user: <username>@kubernetes.<clustername>
- name: <username>@kube-tiller.<clustername>
  context:
    cluster: <clustername>
    namespace: kube-tiller
    user: <username>@kubernetes.<clustername>
- name: <username>@kube-dashboard.<clustername>
  context:
    cluster: <clustername>
    namespace: kube-dashboard
    user: <username>@kubernetes.<clustername>
- name: <username>@depot.<clustername>
  context:
    cluster: <clustername>
    namespace: depot
    user: <username>@kubernetes.<clustername>
- name: <username>@terminal.<clustername>
  context:
    cluster: <clustername>
    namespace: terminal
    user: <username>@kubernetes.<clustername>
- name: <username>@atlas.<clustername>
  context:
    cluster: <clustername>
    namespace: atlas
    user: <username>@kubernetes.<clustername>
current-context: <username>@<namespace>.<clustername>
preferences: {}
users:
- name: <username>@kubernetes.<clustername>
  user:
    client-certificate: <client-crt>
    client-key: <client-key>
