+++
title = "Crossplane Connection Details"
date = 2022-08-09T13:35:15-04:00
tags = ["kubernetes","crossplane"]
featured_image = ""
description = "Introduction to Crossplane"
draft = "false"
series = ["Crossplane Intro"]
+++

## Connection Details

In the last post of this series about Crossplane I gave a high level overview of what crossplane is and why you would want to use it.

One aspect I overlooked in the last post is the concept of credential binding. When provisioning a resource, it entails not only the resource itself but also a crucial set of credentials required for seamless access within the consuming application.

When you create or update a custom resource that requires credentials to access, Crossplane dynamically generates a ConnectionSecret. This secret contains the connection details (like access credentials) specific to that resource and is stored as a Kubernetes secret.

Each managed resource within a composition can write out a set of connectionDetails for a its resource type. 

An RDS database provides a host name, port, username, and password.  An AWSAccessKey would provide its SecretKey and AccessKey.  These secrets are writen to a ConnectionSecret. The author of the provider is the one that defines which credentials are written.  


![Credential Details](/wp-content/uploads/2023/rds-credentials.jpg)

## Connection Details for Compositions

When writing a composition it is possible to aggregate the credentials from the various managed resources into a secret for the composition. 

![Composite Secret](/wp-content/uploads/2023/composite-secret.jpg)

In addition to using values from the child managed resources we can use fields from the resource definition and the the composition itself.

```yaml
      connectionDetails:
       - name: type
         value: postgresql
       - fromConnectionSecretKey: port
       - name: host
         fromConnectionSecretKey: host
       - name: username
         value: postgres
       - fromConnectionSecretKey: password
       - name: database
         type: FromFieldPath
         fromFieldPath: spec.forProvider.values.auth.database
      patches:
```
This snippet for a composition that provisions a database publishes 5 fields from its managed resources.

1. *type*,  This value is fixed at Postgres as this RDS Instance is always postres.  
2. *port*,  This value is the port that the application must use to communicate with the database
3. *username*.  This value is the username that the application must use to connect.
4. *password*.  This value is the password that the application must use to connect.
5. database. The value that was specified for the database name in the CompositeResource. In this case that value is also used is used by the provider to create that schema within the provisioned database.

![Combined Secret](/wp-content/uploads/2023/combined-secret.jpg)

## Handing off credentials

Once the credentials are published they can they be handed off to the application that will be consuming them.   RBAC can be used to protect who has visibility to these resources. In a production environment it would only be the service account running the pod containing the application.

In addition to storing connectionDetails inside secrets,  Crossplane can also publish secrets to an external store such as Hashicorp's Vault.