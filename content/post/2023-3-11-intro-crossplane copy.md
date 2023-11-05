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
Crossplane is an open-source Kubernetes add-on that extends the capabilities of Kubernetes to manage cloud infrastructure and other external resources in any cloud. It essentially enables the provisioning and management of infrastructure resources, such as databases, storage volumes, virtual machines, and more, directly through Kubernetes APIs, making it easier for organizations to adopt and manage cloud-native applications.

Key features and components of Crossplane include:


1. [Providers](#providers)
1. [Composite Resources](#composite-resources)
1. [Composite Resource Definitions](#composite-resource-definitions )


Crossplane simplifies the management of infrastructure resources in a Kubernetes environment, promoting a consistent and declarative approach to provisioning and maintaining infrastructure alongside application workloads. This unification of infrastructure and application management helps organizations streamline their cloud-native operations and maintain a more efficient, agile, and cost-effective IT environment.

## Providers

Crossplane supports various cloud providers and infrastructure services, known as "providers." These providers offer a set of controllers and APIs to interact with specific cloud platforms, enabling users to provision and manage resources across multiple clouds and on-premises environments.

A provider can be used to provision a resource that the provider implements.  For instance the [s3 AWS provider](https://marketplace.upbound.io/providers/upbound/provider-aws-s3/v0.43.1) can be used to provision a bucket in Amazon.  

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

Creating a bucket involves appling the resource `Bucket`. An operator familiar with Kubernetes can easily create as many buckets as they want using the `kubectl apply` command.  Similarly resources can be updated and deleted using the corresponding kubectl commands, `apply` and `delete`

The resources created by the crossplane provider are called Managed Resources.

![Managed Resources](/wp-content/uploads/2023/Crossplane-Managed-Resources.png)

## Composite Resources

Crossplane introduces the concept of composite resources, which enables users to define and compose complex infrastructure resources from simpler building blocks.

Since its common for a developer to need multiple Managed resources at once crossplane intrudes the idea of Composite Resources. This type allow multiple managed resources to be configured as a group.  In addition the creator of the composite resource can provide default options to pass to the provider. They also allow the operator to define which settings the devloper is allowed to override.

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

In the above example, the composite resource provisions two buckets. StorageBucketA and StorageBucketB.

You may notice that the above resource does not provide the `metadata.name` field for each bucket.  This is because the operator who created this composition has chosen to allow the developer to choose those names.  In order to populate the Bucket object correctly at creation time a series of patches will be needed.

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
The instance of the object  used to invoke the creation of the composition is as follows.

```yaml
apiVersion: ellin.net/v1alpha1
kind: XBucketBrigade
metadata:
  name: brigade
spec:
  bucketAName: foo
  bucketBName: bar
```

The inputs from `XBucketBridgade` are used to create the managed resources in the composition.

## Composite Resource Definitions
In order to create formality around a give composite resource a Kubernetes CRD is required to define the schema of the resource.

Crossplane defines Composite resource definitions (XRD)s for the purpose of scaffolding a CRD. This allows consumers of the composition to declare and managed these resources in a Kubernetes-native way.

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

Next up we will discuss the methods in which crossplane can publish connection information such as usernames and passwords to the developrs who provisioned them.