+++
title = "Spring Cloud Config"
date = 2020-07-14T00:35:15-04:00
tags = ["spring","config"]
category = ["tech"]
featured_image = ""
description = "Spring Cloud Config"
draft = "false"
+++

## Enabling Automagic config on TAS

Tested with `2.3.1.RELEASE`

Add the Config client

```xml
<dependency>
    <groupId>io.pivotal.spring.cloud</groupId>
    <artifactId>spring-cloud-services-starter-config-client</artifactId>
</dependency>
```

Downgrade the conflig starter to 2.3 to avoid using the new cfenv.  Make sure the `spring-cloud-starter-dependencies` is first in the list.

```xml
<dependencyManagement>
		<dependencies>
			<dependency>
				<groupId>io.pivotal.spring.cloud</groupId>
				<artifactId>spring-cloud-services-dependencies</artifactId>
				<version>2.2.1.RELEASE</version>
				<type>pom</type>
				<scope>import</scope>
			</dependency>
			<dependency>
				<groupId>org.springframework.cloud</groupId>
				<artifactId>spring-cloud-dependencies</artifactId>
				<version>${spring-cloud.version}</version>
				<type>pom</type>
				<scope>import</scope>
			</dependency>
		</dependencies>
	</dependencyManagement>
```

### References

* [https://docs.pivotal.io/spring-cloud-services/3-1/common/client-dependencies.html](https://docs.pivotal.io/spring-cloud-services/3-1/common/client-dependencies.html)