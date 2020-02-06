apiVersion: v1
kind: Config
clusters:
- name: <clustername>
  cluster:
    server: https://<clustername>.localdomain:6443
contexts:
- name: <serviceaccount>@<namespace>.<clustername>
  context:
    cluster: <clustername>
    namespace: <namespace>
    user: <serviceaccount>@<namespace>.<clustername>
current-context: <serviceaccount>@<namespace>.<clustername>
preferences: {}
users:
- name: <serviceaccount>@<namespace>.<clustername>
  user:
    token: <token>
