+++
title = "Highly available Wildfly Applications on Kubernetes"
date = 2021-03-11T13:35:15-04:00
tags = ["kubernetes","Wildfly"]
featured_image = ""
description = "Highly available Wildfly Applications on Kubernetes"
draft = "false"
+++

# Highly available Wildfly Applications on Kubernetes

Migrating existing applications to Kubernetes can be tricky, especially if your application uses session replication to enable high availability. In a multi-node cluster, each node must contain details about the users' session. Replication is used so that a user can be routed to any node in the cluster and not lose their place. 

WildFly/JBoss clusters use JGROUPS to manage cluster replication.
Cluster members discover each other using multicast networking. Unfortunately, this technique does not work in Kubernetes. WildFly has adopted a new communication strategy for JGROUPS to allow cluster members to discover each other by interrogating the Kubernetes API. It accomplishes this by looking for other WildFly pods in the same namespace. 

## Migrating Jboss Cluster Apps to Wildfly

KUBE_PING is the protocol used to achieve WildFly clustering in Kubernetes. 

The first step in configuring KUBE_PING is to create a WildFly CLI configuration file. This file is used to manipulate the standalone-full-ha.xml file during container creation. 

config-server.cli

```bash
embed-server --server-config=standalone-full-ha.xml --std-out=echo

###apply all configuration to the server
batch

/subsystem=jgroups/channel=ee: write-attribute(name=stack,value=tcp)

/subsystem=jgroups/stack=tcp: remove()
/subsystem=jgroups/stack=tcp: add()
/subsystem=jgroups/stack=tcp/transport=TCP: add(socket-binding="jgroups-tcp")
/subsystem=jgroups/stack=tcp/protocol=kubernetes.KUBE_PING: add()
/subsystem=jgroups/stack=tcp/protocol=kubernetes.KUBE_PING/property=namespace: add(value=${env.POD_NAMESPACE:default})
/subsystem=jgroups/stack=tcp/protocol=MERGE3: add()
/subsystem=jgroups/stack=tcp/protocol=FD_SOCK: add()
/subsystem=jgroups/stack=tcp/protocol=FD_ALL: add()
/subsystem=jgroups/stack=tcp/protocol=VERIFY_SUSPECT: add()
/subsystem=jgroups/stack=tcp/protocol=pbcast.NAKACK2: add()
/subsystem=jgroups/stack=tcp/protocol=UNICAST3: add()
/subsystem=jgroups/stack=tcp/protocol=pbcast.STABLE: add()
/subsystem=jgroups/stack=tcp/protocol=pbcast.GMS: add()
/subsystem=jgroups/stack=tcp/protocol=MFC: add()
/subsystem=jgroups/stack=tcp/protocol=FRAG2:add()

/interface=private: write-attribute(name=nic, value=eth0)
/interface=private: undefine-attribute(name=inet-address)

/socket-binding-group=standard-sockets/socket-binding=jgroups-mping: remove()
run-batch

###stop embedded server

stop-embedded-server
```

This script accomplishes a few things.

1. Adds the KUBE_PING configuration block.
2. Removes the MPING configuration block.ext
 
An environment variable called `POD_NAMESPACE` is used to locate additional cluster members. Any other pods in this namespace will be considered candidates to join the cluster. 
 
The "label" property of KUBE_PING can be used to subdivide clusters further. Only pods with this label will be used within the cluster. This is useful if you have multiple clusters in the same namespace or are running other non-WildFly pods in the namespace.

```
/subsystem=jgroups/stack=tcp/protocol=kubernetes.KUBE_PING/property=labels: add(value=${env.kubebernetes_labels:default})
```

### Configure Dockerfile

The following Dockerfile is used to reconfigure the standard WildFly using KUBE_PING. It also adds our application war. A little later on, I will provide a link to a sample application  I  used to test session replication.

```
FROM jboss/wildfly
RUN /opt/jboss/wildfly/bin/add-user.sh admin redhat --silent
ADD configuration/config-server.cli /opt/jboss/
RUN /opt/jboss/wildfly/bin/jboss-cli.sh --file=config-server.cli
RUN rm -rf /opt/jboss/wildfly/standalone/configuration/standalone_xml_history/*
ADD application/cluster.war /opt/jboss/wildfly/standalone/deployments/
EXPOSE 8080 9990 7600 8888
ENV POD_NAMESPACE default

```

#### RBAC

KUBE_PING uses the Kubernetes API to discover other nodes in the cluster. A Service account is required to allow this to occur as the default service account does not have enough privileges. The following bit of YAML creates a ServiceAccount and an associated ClusterRole and a ClusterRoleBinding that has the ability to list the pods within the default namespace.

```yaml
apiversion: v1
kind: ServiceAccount
metadata:
 name: jgroups-kubeping-service-account
 namespace: default
---
kind: ClusterRole
apiversion: rbac.authorization.k8s.io/v1
metadata:
 name: jgroups-kubeping-pod-reader
 namespace: default
rules:
- apigroups: [""]
 resources: ["pods"]
 verbs: ["get", "list"]
---
apiversion: rbac.authorization.k8s.io/v1beta1
kind: clusterrolebinding
metadata:
 name: jgroups-kubeping-api-access
roleref:
 apigroup: rbac.authorization.k8s.io
 kind: clusterrole
 name: jgroups-kubeping-pod-reader
subjects:
- kind: serviceaccount
 name: jgroups-kubeping-service-account
 namespace: default
```

### Deployment


```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
 name: wildfly
 labels:
 app: wildfly
 tier: devops
spec:
 selector:
 matchLabels:
 app: wildfly
 tier: devops
 replicas: 2
 template:
 metadata:
 labels:
 app: wildfly
 tier: devops
 spec:
 serviceAccountName: jgroups-kubeping-service-account
 containers:
 - name: kube-ping
 image: ellin.com/wildfly/demo:latest
 command: ["/opt/jboss/wildfly/bin/standalone.sh"]
 args: ["--server-config", "standalone-full-ha.xml", "-b", $(pod_ip), "-bmanagement", $(pod_ip) ,"-bprivate", $(pod_ip) ]
 imagePullPolicy: IfNotPresent
 ports:
 - containerPort: 8080
 - containerPort: 9990
 - containerPort: 7600
 - containerPort: 8888
 env:
 - name: pod_ip
 value: "0.0.0.0"
 - name: kubernetes_namespace
 valueFrom:
 fieldRef:
 apiVersion: v1
 fieldPath: metadata.namespace
 - name: kubernetes_labels
 value: app=wildfly
 - name: JAVA_OPTS
 value: -Djdk.tls.client.protocols=tlsv1.2
```

### Testing the configuration. 

For testing, I used a very simple [Stateful Web App](https://github.com/microsoft/stateful-java-web-app) available on GitHub. After building the war with `mvn build` I added it to a new docker container built using the sample Dockerfile.

After deploying the application, you can visit the page. A count of visits is kept on a per session basis. Returning to either pod will result in the same count.

1. Create a cluster ( I am using Kind)
 
 ```bash
 kind create cluster
 Creating cluster "kind" ...
 ✓ Ensuring node image (kindest/node:v1.18.2) 🖼
 ✓ Preparing nodes 📦
 ✓ Writing configuration 📜
 ⢎ ⠁ Starting control-plane 🕹️
 ```
2. Load image to Kind. 
 ```
 kind load docker-image ellin.com/wildfly/demo:latest
 ```
3. Apply RBAC
 
 ```bash
 kubectl apply -f rbac.yml
 ```
4. Apply the Deployment.
 ```
 kubectl apply -f deployment.yaml
 ```
5. Get Pods list
 ```
 kubectl get pods
 NAME READY STATUS RESTARTS AGE
 wildfly-6f4cf67765-gdrtl 1/1 Running 0 1s
 wildfly-6f4cf67765-wjkhf 1/1 Running 0 2s
 ```
6. Create a port forward to each pod.
 ```
 kubectl port-forward pod/wildfly-6f4cf67765-gdrtl 8888:8080
 ````
 and
 ```
 kubectl port-forward pod/wildfly-6f4cf67765-wjkhf 8889:8080
 ````
7. Visit
 
 http://localhost:8888/Stateful-Tracker-1.0.0-SNAPSHOT
 
 and

 http://localhost:8889/Stateful-Tracker-1.0.0-SNAPSHOT

At this point, the Number of Visits count should be in sync. Creating a new session in a private window should start a separate count for that new session.