---
id: 594
title: Kubernetes and Google Cloud SQL
date: 2018-03-11T01:15:28+00:00
author: ellinj
layout: post

permalink: /2018/03/11/kubernetes-and-google-cloud-sql/
tags:
  - gcp
  - kubernetes
---
Cloud SQL is a hosted SQL database similar to Amazon RDS for either Mysql or Postgres databases. It supports automated management including backup and deployment.  Since the database is created via the the GCP console it is very easy to create a scalable  and reliable database.

<img class="aligncenter size-large wp-image-606" src="/wp-content/uploads/2018/03/Screenshot-2018-03-10-at-08.10.57-PM-1024x791.png" alt="" width="1024" height="791" srcset="/wp-content/uploads/2018/03/Screenshot-2018-03-10-at-08.10.57-PM-1024x791.png 1024w, /wp-content/uploads/2018/03/Screenshot-2018-03-10-at-08.10.57-PM-300x232.png 300w, /wp-content/uploads/2018/03/Screenshot-2018-03-10-at-08.10.57-PM-768x593.png 768w, /wp-content/uploads/2018/03/Screenshot-2018-03-10-at-08.10.57-PM.png 1554w" sizes="(max-width: 1024px) 100vw, 1024px" /> 

To create a new Database use the GCP Console. If you wish to have failover make sure and enable that option while creating the database.

<img class="aligncenter size-full wp-image-595" src="/wp-content/uploads/2018/03/Screenshot-2018-03-08-at-08.37.38-PM.png" alt="" width="930" height="888" srcset="/wp-content/uploads/2018/03/Screenshot-2018-03-08-at-08.37.38-PM.png 930w, /wp-content/uploads/2018/03/Screenshot-2018-03-08-at-08.37.38-PM-300x286.png 300w, /wp-content/uploads/2018/03/Screenshot-2018-03-08-at-08.37.38-PM-768x733.png 768w" sizes="(max-width: 930px) 100vw, 930px" /> 

In order for clients to be able to access the database an ingress rule must be created. Unfortunately GCP only allows the configuration of external IP addresses for ingress into Cloud SQL.  In order to allow your Kubernetes cluster to be able to access the database you would need to assign routable external IPs and add them to the ingress rules for the database.

To get around this issue [Cloud SQL Proxy](https://cloud.google.com/sql/docs/mysql/sql-proxy) can be used. The **Cloud SQL Proxy** provides secure access to your Cloud SQL Second Generation instances without having to whitelist IP addresses or setup SSL tunneling.

The steps to setup the Cloud SQL Proxy are fairly straightforward and documented [here. ](https://cloud.google.com/sql/docs/mysql/connect-kubernetes-engine)

  1. Create a Service account to connect to the database.
  2. Create a new user to access the database
  3. Create the Secrets for the database
  4. Update the Pod configuration file.

<pre class="lang:yaml mark:42 decode:true " title="wordpress.yaml">apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: wordpress
  labels:
    app: wordpress
spec:
  template:
    metadata:
      labels:
        app: wordpress
    spec:
      containers:
        - name: web
          image: wordpress:4.8.2-apache
          ports:
            - containerPort: 80
          env:
            - name: WORDPRESS_DB_HOST
              value: 127.0.0.1:3306
            # These secrets are required to start the pod.
            # [START cloudsql_secrets]
            - name: WORDPRESS_DB_USER
              valueFrom:
                secretKeyRef:
                  name: cloudsql-db-credentials
                  key: username
            - name: WORDPRESS_DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: cloudsql-db-credentials
                  key: password
            # [END cloudsql_secrets]
        # Change &lt;INSTANCE_CONNECTION_NAME&gt; here to include your GCP
        # project, the region of your Cloud SQL instance and the name
        # of your Cloud SQL instance. The format is
        # $PROJECT:$REGION:$INSTANCE
        # [START proxy_container]
        - name: cloudsql-proxy
          image: gcr.io/cloudsql-docker/gce-proxy:1.11
          command: ["/cloud_sql_proxy",
                    "-instances=jeffellin-project:us-central1:wordpress=tcp:3306",
                    "-credential_file=/secrets/cloudsql/Labs-jellin-e4ccff43f21b.json"]
          volumeMounts:
            - name: cloudsql-instance-credentials
              mountPath: /secrets/cloudsql
              readOnly: true
        # [END proxy_container]
      # [START volumes]
      volumes:
        - name: cloudsql-instance-credentials
          secret:
            secretName: cloudsql-instance-credentials
        - name: cloudsql
          emptyDir:
      # [END volumes]
</pre>

This is one of the few cases where it makes sense to have more than one container within a Pod.  The **WordPress** client application and the **Cloud SQL proxy.**

Apply the changes and create a service to expose the app.

<pre class="lang:default decode:true ">kubectl expose deployment wordpress --port=8888 --target-port=80 --name=wordpress --type=LoadBalancer</pre>

Once the service has been created you should be able to access the WordPress blog at http://35.225.0.109:8888

<pre class="lang:default decode:true">Jeffreys-MacBook-Pro:wordpress jeff$ kubectl get services
NAME         TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)          AGE
kubernetes   ClusterIP      10.15.240.1    &lt;none&gt;         443/TCP          2h
wordpress    LoadBalancer   10.15.246.41   35.225.0.109   8888:31265/TCP   1m
</pre>

&nbsp;