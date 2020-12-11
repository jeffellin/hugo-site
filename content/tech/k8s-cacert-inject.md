+++
title = "Automatically injecting certs into containers."
date = 2020-07-14T00:35:15-04:00
category = ["tech"]
description = "Automatically injecting certs into containers."
draft = "true"
+++

## Create webook manifest

Customize the manifest

```
ytt -f ./deployments/k8s \
      -v pod_webhook_image=gcr.io/cf-build-service-public/cert-injection-webhook/pod-webhook \
      -v setup_ca_certs_image=gcr.io/cf-build-service-public/cert-injection-webhook/setup-ca-certs \
      --data-value-file ca_cert_data=/Users/jellin/dev/mkcert_development_CA_146457396271771716678352258984121938072.pem \
      --data-value-yaml labels="[app, image.kpack.io/image]" \
      > manifest.yaml
```