---
id: 635
title: Spring Initializer
date: 2018-03-15T19:27:22+00:00
author: ellinj
layout: post

permalink: /2018/03/15/spring-intializer/
tags:
  - spring
  - til
---
>This page was converted from my old blog and hasn't been reviewed. If you see an error please let me know in the comments.

## What it is

The [Spring Initializer](http://start.spring.io) is one of the first places to go when starting a new Spring project as it greatly simplifies the process of starting a new Spring project.<figure>

![SpringIntializer](/wp-content/uploads/2018/03/spring-intializer.png) <figcaption>SpringIntializer</figcaption></figure> 

When visiting this page by filling in a few boxes you can select the components needed to start a new project.

  * Artifact coordinates
  * Dependencies
  * Build Tool
  * Language
  * Spring Boot Version

After selecting what you need in the tool a zip file is generated containing everything you need to import into your IDE to begin development. No more starting with an empty Maven pom or a Gradle build file. The directory structure is laid out for you based on an opinionated best practice.<figure>

![Spring Project](/wp-content/uploads/2018/03/spring-project.png) <figcaption>Spring Project</figcaption></figure> 

IDE’s like IntelliJ and STS even have it built in. Creating a new project couldn’t be any simpler.<figure>

![](/wp-content/uploads/2018/03/intellij2.png) </figure> 

## Today I learned:

### You can access the initializer via Curl.

If you find yourself repeatedly creating new projects, you may be surprised to learn that you can access the initializer from the command line with curl.

<pre class="lang:default decode:true ">curl start.spring.io
</pre>

Running the above command will give you a complete list of options for creating your next spring project.

    curl https://start.spring.io/starter.zip -o demo.zip
    

The above command is the simplest possible way to get started. This will create a blank project in demo.zip. There are a ton of other options available.

To create a web/data-jpa gradle project unpacked:

    curl https://start.spring.io/starter.tgz -d dependencies=web,data-jpa \\
               -d type=gradle-project -d baseDir=my-dir | tar -xzvf -
    

### You can fork the initializer

Just like everything Spring the source code for the initializer is on [GitHub](https://github.com/spring-io/initializr). If your company has a custom spring starter or component you can easily add it to the initializer and host your own.  
You can configure things like languages, packaging options, custom project types and additional dependencies.

To add your own `my-custom-starter` to the initializer clone the source code from git and update application.yml to suit your needs.

    initializr:
      dependencies:
        - name: Web
          content:
            - name: my-customer-starter
              id: my-custom-starter
              description: My orginizations custom starter
    

Once you have made your updates build the initializer using `./gradlew build` Once you package the app you can run it like any other Spring Boot application. Push the application somewhere that others on your team can consume it.

If you have Cloud Foundry PAS try using `cf push`

    cf push your-initializr -p target/initializr-service.jar
    

## References

[Source Code for the Initializer](https://github.com/spring-io/initializr)

[Spring Docs for the Intialzier](https://docs.spring.io/initializr/docs/current-SNAPSHOT/reference/htmlsingle/)