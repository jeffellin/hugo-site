+++
title = "Introduction to Crossplane"
date = 2023-11-04T13:35:15-04:00
tags = ["kubernetes","crossplane"]
featured_image = ""
description = "Introduction to Crossplane"
draft = "false"
series = ["Crossplane Intro"]
+++


Crossplane your infra API
## Intro
Crossplane is an open-source Kubernetes add-on that extends Kubernetes' capabilities to manage cloud infrastructure and other external resources across any cloud. It empowers organizations to provision and manage infrastructure resources like databases, storage volumes, virtual machines, and more through Kubernetes APIs, simplifying the adoption and management of cloud-native applications.


Key features and components of Crossplane include:


1. [Providers](#providers)
1. [Composite Resources](#composite-resources)
1. [Composite Resource Definitions](#composite-resource-definitions )


Crossplane streamlines the management of infrastructure resources in a Kubernetes environment, fostering a consistent and declarative approach for provisioning and maintaining infrastructure alongside application workloads. This integration of infrastructure and application management facilitates more efficient, agile, and cost-effective IT operations.


## Providers

Crossplane supports various cloud providers and infrastructure services known as "providers." These providers offer controllers and APIs to interact with specific cloud platforms, enabling users to provision and manage resources across multiple clouds and on-premises environments.

For instance the [s3 AWS provider](https://marketplace.upbound.io/providers/upbound/provider-aws-s3/v0.43.1) can be used to provision a bucket in Amazon.  

```yaml
apiVersion: s3.aws.upbound.io/v1beta1
kind: Bucket
metadata:
  annotations:
  name: bucket-name
spec:
  forProvider:
    region: us-west-1
```

Creating a bucket involves applying the resource Bucket. An operator familiar with Kubernetes can easily create as many buckets as needed using the kubectl apply command. Similarly, resources can be updated and deleted using the corresponding apply and delete kubectl commands.

The resources created by the Crossplane provider are referred to as Managed Resources.

![Managed Resources](/wp-content/uploads/2023/Crossplane-Managed-Resources.png)

## Composite Resources

Crossplane introduces the concept of composite resources, allowing users to define and compose complex infrastructure resources from simpler building blocks.

Since developers often require multiple Managed resources simultaneously, Crossplane introduces the concept of Composite Resources, which allows multiple managed resources to be configured as a group. The creator of the composite resource can provide default options to pass to the provider and define which settings developers are allowed to override.

```yaml
apiVersion: apiextensions.crossplane.io/v1
kind: Composition
metadata:
  name: bucket-composition
spec:
  compositeTypeRef:
    apiVersion: ellin.net/v1alpha1
    kind: XBucketBrigade
  resources:
    - name: StorageBucketA
      base:
        apiVersion: s3.aws.upbound.io/v1beta1
        kind: Bucket
        spec:
          forProvider:
            region: us-east-1
          providerConfigRef:
            name: aws-provider-266463974589
     - name: StorageBucketB
      base:
        apiVersion: s3.aws.upbound.io/v1beta1
        kind: Bucket
        spec:
          forProvider:
            region: us-east-1
          providerConfigRef:
            name: aws-provider-266463974589
        ...
   ```

In the example above, the composite resource provisions two buckets, StorageBucketA and StorageBucketB.

You may notice that the above resource does not provide the `metadata.name` field for each bucket. This is because the operator who created this composition has chosen to allow the developer to choose those names. To populate the Bucket object correctly at creation time, a series of patches will be needed.

```yaml
      patches:
        - fromFieldPath: "spec.bucketAName"
          toFieldPath: "metadata.name"
          policy:
            fromFieldPath: Required
```

```yaml
      patches:
        - fromFieldPath: "spec.bucketBName"
          toFieldPath: "metadata.name"
          policy:
            fromFieldPath: Required
```
The instance of the object used to invoke the creation of the composition is as follows:


```yaml
apiVersion: ellin.net/v1alpha1
kind: XBucketBrigade
metadata:
  name: brigade
spec:
  bucketAName: foo
  bucketBName: bar
```

The inputs from `XBucketBrigade` are used to create the managed resources in the composition.


## Composite Resource Definitions
To formalize a given composite resource, a Kubernetes CRD is required to define the schema of the resource.

Crossplane defines Composite Resource Definitions (XRDs) for scaffolding a CRD, allowing consumers of the composition to declare and manage these resources in a Kubernetes-native way.


```yaml
apiVersion: apiextensions.crossplane.io/v1
kind: CompositeResourceDefinition
metadata: 
  name: xbucketbrigades.ellin.net
spec:
  group: ellin.net
  names:
    kind: XBucketBrigade
    plural: xbucketbrigades
  versions:
  - name: v1alpha1
    served: true
    referenceable: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              bucketAName:
                type: string
              bucketBName:
                type: string
```

## Publishing Connection Details.

Next up we will discuss the methods in which crossplane can publish connection information such as usernames and passwords to the developers who provisioned them. We will also see how to pass these crewdentials easily using the Kubernetes [Service binding specification](https://servicebinding.io).