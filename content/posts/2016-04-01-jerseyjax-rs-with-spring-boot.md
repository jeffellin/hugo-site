---
id: 251
title: Jersey/JAX-RS with Spring Boot
date: 2016-04-01T15:27:46+00:00
author: ellinj
layout: post

permalink: /2016/04/01/jerseyjax-rs-with-spring-boot/
geo_public:
  - "0"
publicize_linkedin_url:
  - 'https://www.linkedin.com/updates?discuss=&scope=20835048&stype=M&topic=6121698664172843008&type=U&a=kJJg'
tags:
  - spring
---
As a counterpoint to the last few posts where I show how to adapt DropWizard to work with Spring tech this post will focus on getting a popular feature from DropWizard working on Spring Boot.

Spring Boot is a framework to easily create Spring applications that &#8220;just run.&#8221; It is comprehensive framework for application development and provides an opinionated list of dependencies and default configuration. The idea is to provide enough sane defaults that a new developer can get their application running in a few minutes. However it is clever enough to recognize when a developer wants to use a framework not included in the defaults and backs off its automatic configuration.

Writing web services in Spring Boot generally requires the use of Spring MVC. This framework is a general purpose web framework developed for the creation of web applications. If your sole desire is to create a REST based web-service using MVC can be a bit cumbersome since it supports much more functionality than REST. Many developers prefer using Jersey which is an implementation of the JAX-RS standard. Fortunately this is very easy to do using Spring Boot.

By using Spring Boot you also inherit a first class dependency injection framework as well as easy integration with the dozens of sub projects within the Spring portfolio. Spring Boot has a concept of starters. Starters are an easy way to add a bunch of dependencies without worrying about selecting the correct versions. Starters have been tested to assure compatibility with other starters and libraries in the base Spring Boot platform. For using Jersey there is of course a starter.

If you have an existing Spring Boot project add the starter dependency for Jersey.

<pre>compile org.springframework.boot:spring-boot-starter-jersey 
</pre>

If you are creating a new Jax-RS project be sure to check out [start.spring.io](http://start.spring.io/). This site provides a wizard for creating skeleton projects with the desired functionality.  
Once you have added the Jersey dependencies all you need to do is add the Jersey resource configuration.

<pre>@Component
public class JerseyConfig extends ResourceConfig {
    public JerseyConfig {
        registerEndpoints();
    }

   private  void registerEndpoints() {
        register(HelloWorldResource.class);
    }
}</pre>

At startup Spring will instantiate this class and register all your endpoints. The registerEndpoints() method assumes that all endpoints are manually added but a bean lifecycle method combined with context scanning could be used to automatically register all endpoints.  
Once you have Jersey configured using Jersey to write a JAX-RS service is a simple task.

<pre>@GET
    public Saying sayHello(@QueryParam(value = "name") String name) {
        final String value = String.format(template,name);
        return new Saying(counter.incrementAndGet(), value);
    }
</pre>

More details including an example of adding swagger can be found [here](http://www.insaneprogramming.be/blog/2015/09/04/spring-jaxrs/).  
The source code for this post can be found on [GitHub](https://github.com/jeffellin/spring-jersey)  
</article>