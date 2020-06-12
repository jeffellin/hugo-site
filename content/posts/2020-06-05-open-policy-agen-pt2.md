+++
title = "Open Policy Agent w Kubernetes Part 2"
date = 2020-06-07T13:35:15-04:00
tags = ["kubernetes"]
featured_image = ""
description = "Open Policy Agent w Kubernetes Part 2"
draft = "true"
+++

# Open Policy Agent (OPA) and Kubernetes Part 2

This post continues the discussion of OPA. It is designed to illustrate how to integrate the OPA Gatekeeper with Kubernetes. For details on what the OPA is, see my [previous](/2020/06/06/open-policy-agent-w-Kubernetes) post. 

We will be implementing a rule which will validate that the domain used within a given namespace is allowed.

In other words: 

The QA namespace URLs should always match the following regular expression:

`*.qa.acmecorp.com,*.internal.acmecorp.com`

The prod namespace URLs should always match the following regular expression:

`"*.acmecorp.com"`

## The Video


<iframe width="560" height="315" src="https://www.youtube.com/embed/ZJgaGJm9NJE" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## Installation

All of the YAML required to install the OPA is available on [Github](https://github.com/jeffellin/opa)

* Create the OPA namespace

* Create an SSL Certificate For OPA

* Install the OPA

* Create the admission controller

* Create the ValidatingWebhookConfiguration

* Create a Policy

Detailed steps are provided in the [OPA Docs](https://www.openpolicyagent.org/docs/latest/kubernetes-tutorial/) as well as the attached video. For your convenience, I have added everything you need to a Git repository.

```
# clone the git repo
git clone https://github.com/jeffellin/opa
cd opa
```
Create a namespace for Opa
```
kubectl create namespace opa
kubectl config set-context opa-tutorial --user minikube --namespace opa
kubectl config use-context opa-tutorial
```
Create a CA for OPA
```
openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -days 100000 -out ca.crt -subj "/CN=admission_ca"
penssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr -subj "/CN=opa.opa.svc" -config server.conf
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 100000 -extensions v3_req -extfile server.conf
```
Put the new Cert into a secret.
```
kubectl create secret tls opa-server --cert=server.crt --key=server.key
```
create the admission controller
```
kubectl apply -f admission-controller.yaml
```
set no policy flag for the `opa` and `kube-system` namespaces
```
kubectl label ns kube-system openpolicyagent.org/webhook=ignore
kubectl label ns opa openpolicyagent.org/webhook=ignore
```
register opa as an admission controller
```
kubectl apply -f webhook-configuration.yaml
# apply the policy
kubectl create configmap ingress-whitelist --from-file=ingress-whitelist.rego
```

## Test out your policy

Create a `prod` and `qa` namespace with a label.

```
to indicate valid domains
kubectl create -f qa-namespace.yaml
kubectl create -f production-namespace.yaml
```

Create an valid ingress for the production namespace.
```
kubectl create -f ingress-ok.yaml -n production
```
create a bad ingress for the qa namespace.
```
kubectl create -f ingress-bad.yaml -n qa
```

## References

The below two videos from [TGIK](http://tgik.io) provides some more detail on how to use the OPA with Kubernetes.

<iframe width="560" height="315" src="https://www.youtube.com/embed/QU9BGPf0hBw" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

<iframe width="560" height="315" src="https://www.youtube.com/embed/ZJgaGJm9NJE" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>