+++
title = "Wildfly and K8s."
date = 2021-01-14T00:35:15-04:00
category = ["tech"]
description = "Wildfly and K8s"
draft = "false"
+++

Dockerfile
```
from jboss/wildfly
run /opt/jboss/wildfly/bin/add-user.sh admin redhat --silent
add configuration/config-server.cli /opt/jboss/
run /opt/jboss/wildfly/bin/jboss-cli.sh --file=config-server.cli
run rm -rf /opt/jboss/wildfly/standalone/configuration/standalone_xml_history/*
add application/cluster.war /opt/jboss/wildfly/standalone/deployments/
env kubernetes_labels isession
expose 8080 9990 7600 8888

```

config-server.cli
```
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

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      serviceAccountName: build-robot
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
```

```
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

