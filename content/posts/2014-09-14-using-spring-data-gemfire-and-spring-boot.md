---
id: 21
title: Using Spring Data Gemfire and Spring Boot
date: 2014-09-14T20:14:54+00:00
author: ellinj
layout: post

permalink: /2014/09/14/using-spring-data-gemfire-and-spring-boot/
sharing_disabled:
  - "1"
geo_public:
  - "0"
tags:
  - GemFire
  - spring
---
If you haven&#8217;t tried Spring boot yet,  you are really missing out.  Spring boot provides an incredibly easy way to get started with building a new Spring based application.

Normally when building a new Spring application you need to decide on a myriad of dependencies and their versions.  Spring Boot simplifies that process by providing a curated set of jars and configurations to get a new project off the ground quickly.

The easiest way to get started is to use the <a title="Spring Initializer" href="http://start.spring.io" target="_blank">Spring Initializer</a>. The Spring Initializer makes starting a new Maven or Gradle based project as easy as selecting a few check boxes.

For this Simple Spring Data GemFire / Spring Boot project all I need to select is GemFire under the data section.

Import the project into your favorite IDE and examine there results.

The below dependencies pull in everything you need to make a Gemfire Application.

<pre class="lang:xml decode:true " >&lt;dependencies&gt;
		&lt;dependency&gt;
			&lt;groupId&gt;org.springframework.boot&lt;/groupId&gt;
			&lt;artifactId&gt;spring-boot-starter-data-gemfire&lt;/artifactId&gt;
		&lt;/dependency&gt;
		&lt;dependency&gt;
			&lt;groupId&gt;org.springframework.boot&lt;/groupId&gt;
			&lt;artifactId&gt;spring-boot-starter-test&lt;/artifactId&gt;
			&lt;scope&gt;test&lt;/scope&gt;
		&lt;/dependency&gt;
	&lt;/dependencies&gt;
</pre>

I won&#8217;t attempt to cover everything about Spring Data GemFire here, but essentially this example uses the Spring Data Repository Abstraction to perform CRUD operations onto a GemFire Region.

Currently Spring Data GemFire does not do a good job of allowing us to use Spring configuration classes so an external Spring-Context file is created included to bootstrap a local cache.

The application can be run via the IDE by running the Application.class.

Alternatively you can package the jar using maven. During the packaging phase a fat/uber jar which will have all the dependencies bundled in. This jar can be run from the command line.

<pre class="lang:none decode:true " >java -jar target/gemfire-starter-0.0.1-SNAPSHOT.jartarget/gemfire-starter-0.1.1-SNAPSHOT.jar
</pre>

In the future I intend to modify this project to add in some additional components provided by Spring Boot.

Source Code is available <a>https://github.com/ellinj/gemfire-boot</a>