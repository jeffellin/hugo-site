---
id: 645
title: Secrets and ConfigMaps
date: 2018-03-16T01:11:19+00:00
author: ellinj
layout: post

permalink: /2018/03/16/secrets-and-configmaps/
tags:
  - kubernetes
---

One of the tenants of [Twelve Factor](https://12factor.net/) application design is the concept of externalizing configuration and secrets. In the past, you may have had your configuration externalized to a resource bundle or bundled directly into your application artifact. The problem with externalized resource bundles is that they tend to drift over time. Bundling the secret into the application artifact is even worse as it increases the barrier to regularly rotate the secret since you must rebuild and redeploy the application. While this can be automated in a build pipeline there is a better way.

Docker decouple configuration from the deployable container using environment variables.

```yaml
spec:
  containers:
  - image: mysql:5.6
    name: mysql
    env:
    - name: MYSQL_ROOT_PASSWORD
      value: "helloworld!"
    ports:
    - containerPort: 3306
      name: mysql
    volumeMounts:
    - name: mysql-persistent-storage
      mountPath: /var/lib/mysql
```    

Kubernetes provides a few ways to pass an environment variable to the running container.

### Secrets

The above spec for the MySQL container passes in the desired root password for the database via the environment. Since the YAML file used for this is stored in source control we have effectively reduced the overall security of our system because anyone who has access to the source control will potentially have access to your production secrets.

If you look closely at my last [kubernetes](/2018/03/11/kubernetes-and-google-cloud-sql/) post I made a small change to the password.

```yaml
env:
- name: MYSQL_ROOT_PASSWORD
  valueFrom:
    secretKeyRef:
      name: cloudsql-db-credentials
      key: password
```    

The above YAML decouples the credential further from the deployment configuration. Kubernetes allows us to set this credential using `kubectl`

    kubectl create secret generic cloudsql-db-credentials \
        --from-literal=password=[PASSWORD]
    

If we have different passwords for different environments such as dev and production they can be entered by the appropriate person who is allowed to know that information and not shared organization wide. In addition, changing the password can be done via `kubectl` rather than redeploying the entire application.

`kubectl` can also be used to import files that are passed to the container. This can be handy for things like SSL certificates or resource bundles with sensitive information within them.



    kubectl create secret generic cloudsql-instance-credentials \
      --from-file=credentials.json=\Users\jellin\credentials.json
    

The `credentials.json` file referenced above contains the SSL certificate used for the Cloud SQL Proxy. It can be referenced in the Yaml as show below.

```yaml
name: cloudsql-proxy
image: gcr.io/cloudsql-docker/gce-proxy:1.11
command: ["/cloud_sql_proxy",
          "-instances=labs-jellin:us-central1:wordpress=tcp:3306",
          "-credential_file=/secrets/cloudsql/jellin-e4ccff43f21b.json"]
volumeMounts:
  - name: cloudsql-instance-credentials
    mountPath: /secrets/cloudsql
    readOnly: true
```   

The credential file is extracted to /secrets/cloudsql via a volumeMount. The file can then be read by the container at startup as if it existed on the filesystem in that directory.

### ConfigMaps

Another handy feature of Kubernetes is Configuration Maps. ConfigMaps are combined with the Pod at runtime and can be used to set an environment that the application inside the container reads.

#### Creating the ConfigMap

ConfigMaps can be defined directly inside the YAML definition.

```yaml
apiVersion: v1
data:
  my-config.txt: |
    # This is a sample config file that I might use to configure an application
    parameter1 = value1
    parameter2 = value2
kind: ConfigMap
metadata:
  name: my-config
```   

Config Maps can also be created using `kubectl`

    kubectl create configmap my-config \
      --from-file=my-config.properties 
    

It is also possible to add bare values which can be read into the container environment.


     kubectl create configmap my-config \
      --from-literal=some-param=foo
    

#### Using ConfigMaps

The real magic happens when you try and use the values from the ConfigMap. Kubernetes provides two common ways to use a Config Map.

  * _Filesystem_
  
    If you have loaded a ConfigMap using a file. This file can then be placed mounted on the container file system. The application can then read the file directly.

    ```yaml
    containers:
        - name: test-container
          image: gcr.io/jeffellin/some-springboot-app
          volumeMounts:
            - name: config-volume
              mountPath: /config
    volumes:
        - name: config-volume
          configMap:
            name: my-config  
    ```

In the above example the `my-config.properties` file loaded previously is extracted to /config

  * Environment variable
  
    The container environment can also be set via a ConfigMap

    ```yaml
      - name: test-container
          image: gcr.io/jeffellin/some-springboot-app
          imagePullPolicy: Always
          env:
            - name: ENV_VAR
              valueFrom:
                configMapKeyRef:
                  name: my-config
                  key: some-param
                  volumeMounts:
            - name: config-volume
              mountPath: /config
      ```
   In the above example the previously set value for `some-param` is passed to the environment variable `ENV_VAR` as `foo`

### Updating Config and Secrets

Updating a secret is that it won’t automatically pass the new values to the running Pod. This can be accomplished with zero downtime with the rolling update feature of a Kubernetes deployment.

ConfigMaps, on the other hand, are updated without the need to restart the Pod. However, you will want to make sure the application that you deploy within the Container is sensitive to these changes and acts accordingly.