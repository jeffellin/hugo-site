+++
title = "Customizing Ingress Extension for TKG"
date = 2021-04-14T00:35:15-04:00
tags = ["kubernetes","contour"]
category = ["tech"]
featured_image = ""
description = "Customizing Ingress Extension for TKG"
draft = "false"
+++

# Updating TKG Extensions using YTT

[TKG Extension install here](https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.2/vmware-tanzu-kubernetes-grid-12/GUID-extensions-index.html)

Add the following configuration to the countour config map.
name of the file doesn't matter just use the yaml extension.

The kapp controller will reconcile the app approximately every 5 minutes.


### Update the ingress class
```yaml
#@ load("@ytt:overlay", "overlay")

#@overlay/match by=overlay.subset({"kind": "Deployment","metadata": {"name": "contour"}})
---
spec:
  template:
    spec:
      containers:
      #@overlay/match by=overlay.subset({"name": "contour"})
      - args:
        #@overlay/append
        - --ingress-class-name=myingress
```

### Tell AWS to make this an internal load balancer

```yaml
#@ load("@ytt:overlay", "overlay")
#@overlay/match by=overlay.subset({"kind": "Service", "metadata":{"name": "envoy"}})
---
metadata:
  annotations:
    #@overlay/match missing_ok=True
    service.beta.kubernetes.io/aws-load-balancer-internal: "true"

```