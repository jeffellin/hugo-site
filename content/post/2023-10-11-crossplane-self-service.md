+++
title = "Crossplane and Developer Self Service"
date = 2023-11-05T13:35:15-04:00
tags = ["kubernetes","crossplane"]
featured_image = ""
description = "Crossplane and Developer Self Service"
draft = "false"
series = "Crossplane Intro"
featureImage = "/wp-content/uploads/2023/crossplane-og.jpg"
codeLineNumbers = true

+++

In an era where cloud computing has become the backbone of modern IT infrastructure, the need for efficient and secure resource management is paramount. Crossplane, a dynamic and versatile tool, has emerged as a game-changer in this space. It offers a comprehensive solution for orchestrating cloud resources and handling associated credentials. By abstracting away the complexities of provisioning resources in the cloud, we can enable a self service platform which allows Developers to provision the things they need with the guardrails imposed by a platform team.

If you missed it:

* [Part1: Intro to Crossplane](/2023/11/04/introduction-to-crossplane/)
* [Part2: Crossplane Connection Details](/2023/11/05/crossplane-connection-details/)

## Self Service Provisioning

In the last post of our Crossplane series, we offered a broad overview of Crossplane and underscored its importance. Yet, we omitted a crucial aspect: credential binding. Provisioning a resource extends beyond creating the resource; it also involves ensuring that the essential credentials are readily available for seamless access within the consuming application.

![Self Service Resources](/wp-content/uploads/2023/crossplane-selfservice.png)

The diagram illustrates how a Developer can request a database using a resource, fulfilled by Crossplane, which then provides the resource connection details. The Developer is shielded from the intricacies of resource creation. With the platform team setting guardrails and defaults, standardization is achieved. If the platform team decides to switch from Amazon RDS to another provider or even self-hosted databases provisioned by a Kubernetes operator, this change is easily implementable. The only contract between the developer and the platform team is the input to the composite resource, ensuring flexibility and adaptability.


## Kubernetes Service Binding Specification

If you have been in the cloud native space for a while you may be familiar with Cloud Foundry.  Cloud Foundry  introduced the conecpt of service bindings which in of itself was initially implemented at Heroku. 
In Cloud Foundry, a service binding is the process of connecting an application to a service instance. A service instance is a running instantiation of a service, such as a database or a message queue. When you bind a service to an application, it establishes a connection and provides the necessary credentials or connection information for the application to interact with that service.

The Kubernetes Service Binding Specification brings the same functionality to Kubernetes. 

1. Application Developer - expects secrets to be exposed consistently and predictably
2. Service Provider -  expects secrets to be collected consistently and predictably
3. Application Operator - expects secrets to be transferred from services to workloads consistently and predictably

The spec assumes three roles.

### Application Developer

The service binding specification operates on the assumption that developers will retrieve credentials by reading from a predetermined location within the container. Each bound resource is named within a subdirectory of $SERVICE_BINDING_ROOT. Within this subdirectory, a straightforward text file contains the value corresponding to the key, simplifying the retrieval process.

```
$SERVICE_BINDING_ROOT
├── account-database
│   ├── type
│   ├── provider
│   ├── uri
│   ├── username
│   └── password
└── transaction-event-stream
    ├── type
    ├── connection-count
    ├── uri
    ├── certificates
    └── private-key
```

The service binding spec presribes a set of well known keys that can be used for binding.  As long as this well known key is populated with the expected value the application should be able to connect to the resource.


| <div style="width:190px">Key</div>            | Description | 
| :---        | :----   |           
| host           | A DNS-resolvable host name or IP address |
| uri            | A valid URI as defined by RFC3986 |
| username       | A string-based username credential |
| password       | A string-based password credential|
| certificates   | A collection of PEM-encoded X.509 certificates, representing a certificate chain used in mTLS client authentication |
| private-key	   |A PEM-encoded private key used in mTLS client authentication|

A binding can typically be directly consumed with features available in any programming language. However, opting for a language-specific library often enhances the code by adding semantic meaning. While there's no universally "correct" method for interacting with a binding, here's a partial list of available libraries you might consider using:

- .Net
- Go
- Java
  1. Quarkus
  2. Spring Boot
- NodeJS
- Python
- Ruby 
- Rust

See [Language Libraries](https://servicebinding.io/application-developer/) for a current list of languages and links to libraries that implement the service binding spec.

```
public static void main(String[] args) {
    Binding[] bindings = Bindings.fromServiceBindingRoot();
    bindings = Bindings.filter(bindings, "postgresql");
    if (bindings.length != 1) {
        System.err.printf("Incorrect number of PostgreSQL drivers: %d\n", bindings.length);
        System.exit(1);
    }

    String url = bindings[0].get("url");
    if (url == null) {
        System.err.println("No URL in binding");
        System.exit(1);
    }

    Connection conn;
    try {
        conn = DriverManager.getConnection(url);
    } catch (SQLException e) {
        System.err.printf("Unable to connect to database: %s", e);
        System.exit(1);
    }

    // ...
}
```
The code snippet above demonstrates utilizing the Java library to automatically construct a database connection using the details from the secret.

### Service Provider

Service providers expose bindings through a Secret resource with data required for connectivity. In order to support binding the service must expose a field called **status.binding.name**. This field contains the name of the secret that contains the connectionDetails.

```
apiVersion: example.dev/v1beta1
kind: Database
metadata:
  name: database-service
...
status:
  binding:
    name: production-db-secret
```

Implementing the provisioned service contract frees the **ServiceBinding** creator from needing to know about the name of the Secret holding the credentials. The service can update the secret name exposed over time.

Our Crossplane composition definition exposes the name of this secret for us. It is copied from the **writeConnectionSecretToRef.name**  Due to some limitations within Crossplane this field must be temporarily stored within the labels of the **CompositeResource**. We will see how to simplify this using [Composition Functions](https://docs.crossplane.io/latest/concepts/composition-functions/) in a later post. 

```yaml {hl_lines=["2","7"]}
# copy the secret to the Compisition
- type: FromCompositeFieldPath
  fromFieldPath: "spec.writeConnectionSecretToRef.name"
  toFieldPath: "metadata.labels['binding']"
# copy the secret to the status.binding.name field
# this is needed for the the service binding spec
- type: ToCompositeFieldPath
  fromFieldPath: "metadata.labels['binding']"
  toFieldPath: "status.binding.name"
```

### Application Operator

Application operators bind application workloads with services by creating ServiceBinding resources. The specification’s Service Binding section describes this in detail. The ServiceBinding resource need to specify the service and workload details.

```yaml
apiVersion: servicebinding.io/v1beta1
kind: ServiceBinding
metadata:
  name: account-service
spec:
  service:
    apiVersion: com.example/v1alpha1
    kind: AccountService
    name: prod-account-service
  workload:
    apiVersion: apps/v1
    kind: Deployment
    name: online-banking
```

You can also match the workload by label selectors.

```yaml
apiVersion: servicebinding.io/v1beta1
kind: ServiceBinding
metadata:
  name: online-banking-frontend-to-account-service
spec:
  name: account-service
  service:
    apiVersion: com.example/v1alpha1
    kind: AccountService
    name: prod-account-service
  workload:
    apiVersion: apps/v1
    kind: Deployment
    selector:
      matchLabels:
        app.kubernetes.io/part-of: online-banking
        app.kubernetes.io/component: frontend
```
## An Implementation

For learning sake I have [commited](https://github.com/jeffellin/crossplane-experiments/tree/main/helm) a complete example of using Crossplane to provision the Postgres Helm Chart and binding that resource to the Spring Pet Clinic automatically with Spring Boots binding implementation. The custom resource is called **XMyHelmishDataStore** and exposes the **service.binding.name** field with the name of the connection. 

In addition the service binding and deployment are shown [here](https://github.com/jeffellin/crossplane-experiments/tree/main/service-bindings).


## Conclusion. 

In summary, Crossplane is a versatile and powerful tool for simplifying the provisioning and management of cloud resources and credentials. Passing credentials automatically to an application using a service binding specification allows for decoupling applications from their deployment configuration.

**Dynamic Configuration:** Services often need configuration information (e.g., connection strings, API keys) to interact with other services. The service binding specification facilitates the dynamic injection of these configurations into an application.

**Abstraction of Service Dependencies:** The specification can abstract  away the specifics of service dependencies, making it easier to manage and update those dependencies without requiring changes to the application code.

**Consistent Configuration:** Enforcing a standard way to bind services can help maintain uniformity across different applications, making it easier to manage and troubleshoot.

**Security:** With a standardized configuration, securely managing credentials and sensitive information required for service-to-service communication becomes much simpler.  Multiple applications can bind to the same service and credentials will automatically updated when they are rotated. 

**Ease of Deployment:** With a standardized service binding approach, deploying and scaling applications that depend on various services becomes more straightforward, as the configuration can be managed consistently.

