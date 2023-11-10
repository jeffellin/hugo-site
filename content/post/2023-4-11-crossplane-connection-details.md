+++
title = "Crossplane Connection Details"
date = 2023-11-05T13:35:15-04:00
tags = ["kubernetes","crossplane"]
featured_image = ""
description = "Crossplane Connection Details"
draft = "false"
series = "Crossplane Intro"
featureImage = "/wp-content/uploads/2023/crossplane-og.jpg"

+++

In an era where cloud computing has become the backbone of modern IT infrastructure, the need for efficient and secure resource management is paramount. Crossplane, a dynamic and versatile tool, has emerged as a game-changer in this space. It offers a comprehensive solution for orchestrating cloud resources and handling associated credentials. In this exploration, we delve into the world of Crossplane, understanding its key functionalities, including dynamic credential generation, Role-Based Access Control (RBAC), and the seamless integration with external stores like HashiCorp's Vault. Join us on the second part of this journey to discover how Crossplane is transforming the way organizations manage their cloud resources and ensuring a more secure, streamlined, and efficient infrastructure.

If you missed [Part1: Intro to Crossplane](/2023/11/04/introduction-to-crossplane/)

## Connection Details

In the previous post of this Crossplane series, we provided a high-level overview of what Crossplane is and highlighted its significance. However, one important aspect that was overlooked is the concept of credential binding. When provisioning a resource, it's not just about creating the resource itself but also ensuring that the necessary credentials are available for seamless access within the consuming application.

When you create or update a custom resource that requires credentials for access, Crossplane takes care of generating a ConnectionSecret dynamically. This ConnectionSecret contains specific connection details, such as access credentials, relevant to that resource, and securely stores it as a Kubernetes secret.

Each managed resource within a composition can specify a set of connection details for its resource type. For example, an RDS database may provide a host name, port, username, and password, while an AWSAccessKey would offer its SecretKey and AccessKey. It's important to note that the provider's author is responsible for defining which credentials are written to the ConnectionSecret.


![Credential Details](/wp-content/uploads/2023/rds-credentials.jpg)

## Connection Details for Compositions

When writing a composition, you have the capability to consolidate the credentials from different managed resources into a single secret dedicated to that composition.

![Composite Secret](/wp-content/uploads/2023/composite-secret.jpg)

In addition to utilizing values from the child managed resources, we can also incorporate fields from both the resource definition and the composition itself.

```yaml
      connectionDetails:
       - name: type
         value: postgresql
       - fromConnectionSecretKey: port
       - fromConnectionSecretKey: host
       - name: username
         value: postgres
       - fromConnectionSecretKey: password
       - name: database
         type: FromFieldPath
         fromFieldPath: spec.forProvider.values.auth.database
      patches:
```
This snippet is for a composition that provisions a database publishes 5 fields from its managed resources.

Here's an improved presentation of the information you provided:

1. **Type**: This value remains fixed at "Postgres" since this RDS Instance is exclusively for PostgreSQL.

2. **Port**: This value represents the port number that the application must utilize to establish communication with the database.

3. **Username**: This value signifies the username that the application must employ for establishing a connection.

4. **Password**: This value corresponds to the password that the application needs for the connection.

5. **Database**: This value, initially specified as the database name in the CompositeResource, is also utilized by the provider to create the corresponding schema within the provisioned database.

6. **Host**:  This value, is the hostname that the client should use to connect.

![Combined Secret](/wp-content/uploads/2023/combined-secret.jpg)

Above you can see the combined secret that I created with my composition.  This is the secret we will want to hand off to your application teams.

## Handing off credentials

Once the credentials are made available, they can be securely provided to the application that will be using them. Role-Based Access Control (RBAC) can be effectively employed to restrict visibility to these resources. In a production environment, typically, only the service account running the pod containing the application should have access to these credentials.

Furthermore, besides storing connectionDetails within secrets, Crossplane offers the capability to publish secrets to an external store, such as HashiCorp's Vault, for enhanced security and centralized management of secrets.

## Conclusion. 

In summary, Crossplane is a versatile and powerful tool for simplifying the provisioning and management of cloud resources and credentials. Its dynamic generation of ConnectionSecrets, credential consolidation, and RBAC access control features enhance security and efficiency. Additionally, Crossplane's ability to integrate with external stores like HashiCorp's Vault adds an extra layer of security and centralized management. Crossplane's capabilities make it a valuable asset for organizations looking to streamline their resource management processes and enhance their overall cloud infrastructure.

