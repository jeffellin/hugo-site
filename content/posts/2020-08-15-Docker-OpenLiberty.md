+++
title = "Using Open Liberty with Docker"
date = 2020-08-16T00:00:00-04:00
tags = ["docker","liberty"]
featured_image = ""
description = "Using Open Liberty with Docker"
draft = "false"
+++

# Open Liberty

Open Liberty is a lightweight Jave runtime that supports many modularized features. It is modularized and Docker friendly. It supports the full J2EE 8 Spec including, JNDI, JAX-WS/RS, and Spring Boot.

## Docker Images

There are several variants of Open Liberty Docker containers available on [DockerHub](https://hub.docker.com/_/open-liberty). The tags indicate what features are pre-installed. The `kernel` tag contains only the Liberty kernel; additional components are automatically downloaded from the online repository based on the contents of the `server.xml.` 

While the `kernel` image is recommended as the basis for custom images, several other tags are available. There is also a `full` tag that enables all available components.

The remainder of the available tags is various permutations of the base operating system and the JDK. A complete list can be found at this [location](https://hub.docker.com/_/open-liberty?tab=tags) on Dockerhub. For the most part, IBM Liberty and Open Liberty interchanged with each other with no code or configurations modifications.

### Setup Variables

* **MP_HEALTH_CHECK** - Monitor the server runtime environment and application metrics by using Liberty features mpMetrics-1.1
* **MP_MONITORING** Check the health of the environment using Liberty feature mpHealth-1.0
* **HTTP_ENDPOINT** - Add configuration properties for an HTTP endpoint.
* **TLS** - Enable Transport Security in Liberty by adding the transportSecurity-1.0 feature 
* **IIOP_ENDPOINT** - Add configuration properties for an IIOP endpoint.
* **JMS_ENDPOINT** - Add configuration properties for an JMS endpoint.
* **VERBOSE** - When set to true it outputs the commands and results to stdout from configure.sh

Complete [documentation](https://github.com/OpenLiberty/ci.docker) of these options is available on GitHub. 

### Creating the Image

The most straightforward possible image can be created by extending the `full` tag and adding your application to the `config/dropins` directory.

```yml
FROM open-liberty:full
EXPOSE 9080
EXPOSE 9443
ENV HTTP_ENDPOINT true
COPY --chown=1001:0 target/guide-rest-intro.war /config/dropins/guide-rest-intro.war
RUN configure.sh
```

This `Dockerfile` will create a Liberty server that uses the javaee-8 profile and will configure the application based on the settings that we pass in. 

The image runs the user as `10001`, so we have to make sure all files copied into the container have the proper permissions such that Liberty can read them.

### Server.xml

The server.xml used for the full profile is generated below based on the above `Dockerfile.`


```xml
<?xml version="1.0" encoding="UTF-8"?>
<server description="new server">

 <!-- Enable features -->
 <featureManager>
 <feature>javaee-8.0</feature>
 </featureManager>

 <!-- This template enables security. To get the full use of all the capabilities, a keystore and user registry are required. -->

 <!-- For the keystore, default keys are generated and stored in a keystore. To provide the keystore password, generate an
 encoded password using bin/securityUtility encode and add it below in the password attribute of the keyStore element.
 Then uncomment the keyStore element. -->
 <!--
 <keyStore password=""/>
 -->

 <!--For a user registry configuration, configure your user registry. For example, configure a basic user registry using the
 basicRegistry element. Specify your own user name below in the name attribute of the user element. For the password,
 generate an encoded password using bin/securityUtility encode and add it in the password attribute of the user element.
 Then uncomment the user element. -->
 <basicRegistry id="basic" realm="BasicRealm">
 <!-- <user name="yourUserName" password="" /> -->
 </basicRegistry>

 <!-- To access this server from a remote client add a host attribute to the following element, e.g. host="*" -->
 <httpEndpoint id="defaultHttpEndpoint"
 httpPort="9080"
 httpsPort="9443" />

 <!-- Automatically expand WAR files and EAR files -->
 <applicationManager autoExpand="true"/>

 <!-- Default SSL configuration enables trust for default certificates from the Java runtime -->
 <ssl id="defaultSSLConfig" trustDefaultCerts="true" />
```

If the out-of-the-box `server.xml` shown below is not adequate, you may customize it and add it to the container `config` directory.

```yml
FROM open-liberty:kernel
EXPOSE 8080
COPY --chown=1001:0 target/guide-rest-intro.war /config/dropins/guide-rest-intro.war
COPY --chown=1001:0 server.xml /config/
RUN configure.sh
```

In addition, you may compartmentalize your `server.xml` by including other XML files. Update the server.xml with an include block and `ADD` the file in your docker container.

```xml
<include optional="true" location="pathname filename"/>
```

You can also include environment variable references in your `server.xml`

```xml
<serverName>${env.SERVER_NAME}</serverName>
```

