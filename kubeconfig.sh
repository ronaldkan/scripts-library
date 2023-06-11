#! /bin/bash
# name of kubecontext
name=""
# k8s api server url
server=""
# k8s api server token
token="<TOKEN>"
# k8s api server ca
ca="<CA>"
echo "Generating Kubeconfig in current path"
echo "
apiVersion: v1
kind: Config
clusters:
- name: ${name}-cluster
  cluster:
    certificate-authority-data: ${ca}
    server: ${server}
contexts:
- name: ${name}-context
  context:
    cluster: ${name}-cluster
    namespace: default
    user: ${name}-user
current-context: ${name}-context
users:
- name: ${name}-user
  user:
    token: ${token}
" >> config