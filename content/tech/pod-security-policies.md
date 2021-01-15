+++
title = "Kubernetes on Ubuntu 20.04"
date = 2020-11-23T00:35:15-04:00
tags = ["kubernetes","ubuntu"]
category = ["tech"]
featured_image = ""
description = "Kubernetes Pod Security Policy"
draft = "false"
+++

# Enabling Pod Security Policies

Build Cluster with PSP enabled.

If using Kubeadm,  the following config can be used.

```yaml
apiServer:
  extraArgs:
    authorization-mode: Node,RBAC
    enable-admission-plugins: PodSecurityPolicy
  timeoutForControlPlane: 4m0s
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
networking:
  podSubnet: 10.20.0.0/16
```

Run kubeadm 

```bash
kubeadm init --config config.yaml
```

Create a PSP configuration

```yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: restrictive
spec:
  privileged: false
  hostNetwork: false
  allowPrivilegeEscalation: false
  defaultAllowPrivilegeEscalation: false
  hostPID: false
  hostIPC: false
  runAsUser:
    rule: RunAsAny
  fsGroup:
    rule: RunAsAny
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  volumes:
  - 'configMap'
  - 'downwardAPI'
  - 'emptyDir'
  - 'persistentVolumeClaim'
  - 'secret'
  - 'projected'
  allowedCapabilities:
  - '*'

---

apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: permissive
spec:
  privileged: true
  hostNetwork: true
  hostIPC: true
  hostPID: true
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  runAsUser:
    rule: RunAsAny
  fsGroup:
    rule: RunAsAny
  hostPorts:
  - min: 0
    max: 65535
  volumes:
  - '*'
```


Map the PSP to a service accounts, restrictive will be default,  permissive is required by certain base k8s objects

```yaml
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: psp-restrictive
rules:
- apiGroups:
  - extensions
  resources:
  - podsecuritypolicies
  resourceNames:
  - restrictive
  verbs:
  - use
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: psp-permissive
rules:
- apiGroups:
  - extensions
  resources:
  - podsecuritypolicies
  resourceNames:
  - permissive
  verbs:
  - use
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: psp-default
subjects:
- kind: Group
  name: system:serviceaccounts
  namespace: kube-system
roleRef:
  kind: ClusterRole
  name: psp-restrictive
  apiGroup: rbac.authorization.k8s.io
```
permissive role binding 

```yaml
rulesapiVersion: rbac.authorization.k8s.io/v1beta1
kind: RoleBinding
metadata:
  name: psp-permissive
  namespace: kube-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: psp-permissive
subjects:
- kind: ServiceAccount
  name: daemon-set-controller
  namespace: kube-system
- kind: ServiceAccount
  name: replicaset-controller
  namespace: kube-system
- kind: ServiceAccount
  name: job-controller
  namespace: kube-system
- kind: ServiceAccount
  name: cillium
  namespace: kube-system
- kind: ServiceAccount
  name: cillium-operator
  namespace: kube-system
```
