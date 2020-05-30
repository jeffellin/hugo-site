---
id: 267
title: Live Debugging with Docker
date: 2016-07-11T18:01:31+00:00
author: ellinj
layout: post

permalink: /2016/07/11/live-debugging-with-docker/
geo_latitude:
  - "41.937305099999996"
geo_longitude:
  - "-71.4324439"
tags:
  - docker
  - spring
---

>This page was converted from my old blog and hasn't been reviewed. If you see an error please let me know in the comments.


<article class="markdown-body"> 

## Live Debugging with Docker {#live-debugging-with-docker}

During the 2016 DockerCon keynote a demo was given of quickly on boarding a new developer with a Node.js app. In that demo a few simple docker commands were shown in order to get the developer up and running and productively making bug fixes.

[Live Debugging with Docker](https://blog.docker.com/2016/07/live-debugging-docker/)

I thought I would write up a quick HowTo on doing the same technique with a Spring Boot application.

## Getting up and Running {#getting-up-and-running}

Spring Boot has a [Developer Tools](http://docs.spring.io/spring-boot/docs/current/reference/html/using-boot-devtools.html) add on that allows for reloading a live application when a change is detected to the classpath. In order for this demo to work the following are required of the developer before beginning.

  * Git (To Retrieve the remote repository)
  * [Docker](http://www.docker.com/products/overview) for Mac or Windows

This will be a rather simple app so there will be no further downstream dependencies such as Redis or Postgres. However it would be relatively simple to add these via Dockerized containers in the included compose file.

### Clone the git Repository {#clone-the-git-repository}

    git clone https://github.com/jeffellin/springdebug

### Start the application {#start-the-application}

    docker-compose up

Now that the application is running you should be able to navigate to the following URL and see a result.

<http://localhost:8080/greeting?name=jeff>

### Making a change to a static resource. {#making-a-change-to-a-static-resource}

Using your favorite text editor make a change to one of the static resources such as greeting.html

<pre class="lang:default decode:true " >&lt;!DOCTYPE HTML&gt;
&lt;html xmlns:th=“http://www.thymeleaf.org”&gt;
&lt;head&gt;
&lt;title&gt;Getting Started: Serving Web Content&lt;/title&gt;
&lt;meta http-equiv=“Content-Type” content=“text/html; charset=UTF-8” /&gt;
&lt;/head&gt;
&lt;body&gt;
&lt;p th:text=“‘Hello there, ‘ + ${name} + ‘!'” /&gt;
&lt;/body&gt;
&lt;/html&gt;</pre>

Revisiting the application URL should result in the new page being displayed.

### Making a code change {#making-a-code-change}

If you want to make a code change to one of the .java files you must recompile the code. The change to the class path will result in the application automatically reloading.

Open your favorite text editor and make a change to the HelloWorldController.java <public class HelloWorldController { 

<pre class="lang:java decode:true " >@RequestMapping(“/greeting”)
public String greeting(@RequestParam(value=“name”, required=false, defaultValue=“World”) String name, Model model) {
model.addAttribute(“name”, name+“Smith”);
return “greeting”;
}
}</pre>

Rebuild the application

    ./gradlew build

At this point you should see the application redepoy in the docker-compose console. Refreshing the url above should show your change.

## Debugging {#debugging}

In addition to making changes to code you can also run your favorite debugger.

For intelliJ create a new Remote Debug configuration

<img src="/wp-content/uploads/2016/07/debugconfigurations.png" width="500" /> 

Run the new configuration and set the desired breakpoint.

    docker-compose <span class="hljs-_">-f</span> docker-compose-debug.yml up

<img src="/wp-content/uploads/2016/07/breakpoint_png.png" width="500" /> 

The application will not complete loading unless the debugger has been attached.</article> 

&nbsp;

&nbsp;