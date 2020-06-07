+++
title =  "Open Policy Agent w Kubernetes"
date = 2020-06-06T13:35:15-04:00
tags = ["kubernetes"]
featured_image = ""
description = "Open Policy Agent w Kubernetes"
draft = "false"
+++


# Open Policy Agent and Kubernetes

Ensuring application conformity in your Kubernetes environment requires vigilance. How do you make sure that applications are following your governance rules? How do you make sure something as simple as the proper tags are applied or that applications either maliciously or inadvertently taking over the main ingress point of your application? 

The [Open Policy Agent (OPA)](https://www.openpolicyagent.org/) is an incubating project from the Cloud Native Computing Foundation (CNCF). The design of the  OPA allows for a generic way to implement policies.  

The remainder of this post will walk through what the OPA is and how it integrates with Kubernetes.  The second in the series will walk you through the installation of OPA and the setup of some simple policies.

## What is Open Policy Agent (OPA)

OPA is a tool that can be used to implement fine-grained access control. In short, the OPA takes the request an application is being asked to perform and validates it against a set of rules.  OPA allows for the externalization of policy decisions from your application code. It provides a common framework for making policy decisions in a declarative fashion.

OPA can be used to authorize requests made to a microservice architecture to ensure conformity. It can also be used for fine-grained authorization.  It effectively decouples policy decision making from policy enforcement.  Once the OPA makes a decision, it is up to the consuming application to enforce that decision. 

### Architecture.

OPA can be distributed in a few different ways.
A Go library that can be imported directly within your application.
A Standalone application. 
The most common setup is as a standalone application.   When a client makes an API call to the microservice, the input is validated against a list of policies. 

{{<mermaid align="center">}}
graph TD;
    A[Client] -->|API Call| B[Microservice]
    B[Microservice] --> | ask | C{OPA}
    F[Policies] --> | input | C{OPA}
    C --> D[Deny]
    C --> E[Allow]
{{< /mermaid >}}

### Rego

Rego is the language used to define policies. Rego itself is an extension of Datalog.  The input parameter is a structured JSON document. Each rule is applied to that input document, and a decision is rendered.

#### An example policy: 

Is the User Allowed to Create a resource with a given property?

```
POST /widget
{
    "widget": {
        "color": "red",
        "shape": "square"
    }
}
```

OPA can be used to enforce widgets of shape *square* are not allowed to be created using the following policy.

```
package application.authz

default allow = true
deny {
    input.widget.color = ["square"]
}

```

### Another example policy

Given the following structured input

```
{
    "method": "PUT",
    "owner": "bob@hooli.com",
    "path": [
        "pets",
        "pet113-987"
    ],
    "user": "alice@hooli.com"
}
```

The following policy ensures that only the pet's owner can update information about the pet.

```
# Only owner can update the pet's information
# Ownership information is provided as part of OPA's input
default allow = false
allow {
    input.method == "PUT"
    some petid
    input.path = ["pets", petid]
    input.user == input.owner
}

```

## Deploying with Kubernetes

The OPA has a sub project called the [OPA Gatekeeper](https://www.openpolicyagent.org/docs/latest/kubernetes-introduction/#what-is-opa-gatekeeper) The Gatekeeper is a Kubernetes Admission controller that can validate that the supplied input is allowable by the policy.  When running Kubectl apply against a Kubernetes cluster, the YAML input is converted to JSON and invoked against the Kubernetes API endpoint. 

{{<mermaid align="center">}}
graph LR;
    A[Kubectl] -->|Apply | B[Kubernetes]
    B --> C[API Server]
    C --> D{Admission Controller Checks with OPA}
    D --> E[Allow]
    D --> F[Deny - reject install]
{{< /mermaid >}}

In addition, OPA for Kubernetes supports audit functionality. Periodically Kubernetes objects can be validated against OPA so that preexisting conditions are detected. 

### Kubernetes Example

Given a Kubernetes Deployment in JSON Format.

```javascript
{
  "apiVersion": "apps/v1",
  "kind": "Deployment",
  "metadata": {
    "name": "hop2-deployment",
    "labels": {
      "app": "hop2"
    }
  },
  "spec": {
    "replicas": 3,
    "selector": {
      "matchLabels": {
        "app": "hop2"
      }
    }
  }
}
```

The following policy validates that there are labels present. If no labels are present, the application of that Deployment is rejected.


```
package k8srequiredlabels

deny[{"msg": msg, "details": {"missing_labels": missing}}] {
    provided := {label | input.review.object.metadata.labels[label]}
    required := {label | label := input.parameters.labels[_]}
    missing := required - provided
    count(missing) > 0
    msg := sprintf("you must provide labels: %v", [missing])
```


The following policy denies images that come from untrusted registries.

```
 deny[msg] {
     input.request.kind.kind == "Pod"
     image := input.request.object.spec.containers[_].image
     not startswith(image, "hooli.com")
     msg := sprintf("image fails to come from trusted registry: %v", [image])
 }
```

There are a ton of options that can be implemented using OPA; the next post will outline how to install OPA into a Kubernetes cluster.
