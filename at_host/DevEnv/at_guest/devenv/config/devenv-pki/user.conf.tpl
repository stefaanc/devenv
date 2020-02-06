apiVersion: v1
kind: Config
clusters:
- name: <clustername>
  cluster:
    certificate-authority: <ca-crt>
    server: https://<clustername>.localdomain:6443
contexts:
- name: <username>@<namespace>.<clustername>
  context:
    cluster: <clustername>
    namespace: <namespace>
    user: <username>@<namespace>.<clustername>
current-context: <username>@<namespace>.<clustername>
preferences: {}
users:
- name: <username>@<namespace>.<clustername>
  user:
    client-certificate: <client-crt>
    client-key: <client-key>
