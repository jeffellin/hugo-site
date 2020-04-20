---
id: 28
title: Posting Data to GemFire Using Spring XD
date: 2014-09-18T21:15:36+00:00
author: ellinj
layout: post

permalink: /2014/09/18/posting-data-to-gemfire-using-spring-xd/
tags:
  - GemFire
  - SpringXD
  - Uncategorized
tags:
  - GemFire
  - springxd
---
[SpringXD](http://projects.spring.io/spring-xd/ "Srping XD") is a new project which simplifies the development of Big Data Applications. SpringXD&#8217;s ability to stream data between two different modules. In this example, we will use an HTTP module as a data source and a GemFire module as a data sink.

One Component of Big Data Applications is Pivotal&#8217;s GemFire. SpringXD has some built-in connections to GemFire which allow you to get up and running quickly.

Before reading this guide I would recommend that you have a working SpringXD install. The best place to get going with SpringXD is the [getting started guide over at spring.io](http://spring.io/guides/gs/spring-xd/ "getting started guide over at spring.io")

The data we will be posting is a Customer. The JSON that represents this customer looks like this.

<pre class="lang:default decode:true " >{"firstname":"BOB","lastname":"JONES"}
{"firstname":"JOE","lastname":"SMITH"}
{"firstname":"MARY","lastname":"JANE"}</pre>

**Start the Gemfire Server**

SpringXD comes with a scaled down GemFire server if you are on a Mac and installed SpringXD via BREW the command to start Gemfire server will already be on your path. The configuration file I supply has a CacheWriter that will log data placed into the server so that we can verify that our SpringXD stream is working correctly.

The GemFire instance will be booted using a simple context file.

<a href="https://github.com/ellinj/gemfire-boot/blob/master/gemfire-xd/config/xd-demo.xml" title="xd-demo.xml" target="_blank">xd-demo.xml</a>

  1. Create a temporary working directory for Gemfire in a location of your choosing.
  2. Copy the above xml file to your working directory
  3. Startup GemFire</li> 

<pre class="lang:default decode:true " >gemfire-server cq-demo.xml
</pre>

_Start the SpringXD Single Node instance_

Once your GemFire server starts up open another terminal window and startup your SpringXD server if it isn&#8217;t started already

<pre class="lang:default decode:true " >xd-singlenode
</pre>

_Start the SpringXD Shell_

Once your SpringXD instance starts up open another terminal window and start the SpringXD Shell.

<pre class="lang:default decode:true " >xd-shell
</pre>

_Starting a Stream in SpringXD_

Once connected to the SpringXD Shell, the next step is to start a stream to accept HTTP data and store it in GemFire.

SpringXD includes two modules that allow this to be done without writing any code.

  * The HTTP Module accepts data posted from an external source.
  * The GemFire-Json-Module accepts a JSON object, converts it to PDX and saves it in GemFire.

The SpringXD shell is used to connect these two modules into a Stream.

<pre class="lang:default decode:true " >stream create --name stocks --definition "http --port=9090 | gemfire-json-server --regionName=Customers --keyExpression=payload.getField(&#039;lastname&#039;)" --deploy
</pre>

The above stream pipes data from the http module to the GemFire server running on localhost[40404]

**Post data into GemFire using the following command**

<pre class="lang:default decode:true " >http post --target http://localhost:9090 --data {"firstname":"BOB","lastname":"JONES"}
</pre>

If everything is working properly you should see the posted data showing up in the terminal window for GemFire.