---
id: 64
title: Connecting Spring Integration to GemFire
date: 2014-09-21T16:55:05+00:00
author: ellinj
layout: post

permalink: /2014/09/21/connecting-spring-integration-to-gemfire/
publicize_facebook_url:
  - https://facebook.com/10205012392934952
publicize_linkedin_url:
  - 'https://www.linkedin.com/updates?discuss=&scope=20835048&stype=M&topic=5919559269480415232&type=U&a=pP0E'
tags:
  - GemFire
  - spring
  - Uncategorized
tags:
  - GemFire
  - spring
---
Spring Integration is an appication integration framework that builds upon the core Spring framework. It allows for a high level of abstraction between the actual messaging infrastructure and the implementation logic. This allows the devloper to focus on adding value via buesiness logic without having to implement boiler plate code.

Spring Integration provides a number of adapters that can be used by a developer out of the box. One such out of the box adapter is for connections to GemFire.

This post will focus on Gemfire data sources. A later post will talk about GemFire data sinks.

  * Inbound Channel Adapter, produces Events based on region operations, such as creats, updates, deletes, etc.</p> 
  * Continuous Query Channel adapter, This adapter will read events from a region using GemFire&#8217;s continuous query functionality. The continuos query will act as an event source.</p> 

In addition I will be using Spring Boot to build the framework for the demo project. I will also be using Spring XD to load data into GemFire for demonstration purposes.

## Prequisistes

Both of the examples I will be showing use a remote GemFire instance. Before trying out these samples make sure you have a running GemFire instance and can add data to a GemFire region. I will be using the [Spring XD Demo](2014/09/18/posting-data-to-gemfire-using-spring-xd/) to post data into a Customer Region.

## Continuous Query Channel adapter

Using Spring Integration we will define an input channel, a transformer and a an outbound channel.

![Integration](http://www.ellin.com/blogimages/Spring_-_demo_src_main_resources_Integration_xml_-_Spring_Tool_Suite_-__Users_jellin_Documents_workspace-sts-3_6_1_RELEASE_19CF6BC2.png) 

The _cqInputChannel_ will be a source of data. This source will use a GemFire continuous query to receive data from the Customer region as it is updated. The data store in this region will be a PDX Serialized JSON object.

A transform in the middle will convert the PDX Instance into a String representation.

_files_ will be an outbound data sink and will write the data as it is received to a flat file. In this case a file called HelloWorld in /Users/jellin

[code lang=&#8221;xml&#8221;]  
<gfe:client-cache id=&quot;client-cache&quot; pool-name=&quot;client-pool&quot;/>

<gfe:pool id=&quot;client-pool&quot; subscription-enabled=&quot;true&quot;>  
<gfe:server host=&quot;localhost&quot; port=&quot;40404&quot; />  
</gfe:pool>

<gfe:cq-listener-container id=&quot;queryListenerContainer&quot; cache=&quot;client-cache&quot;  
pool-name=&quot;client-pool&quot;/>

<int-gfe:cq-inbound-channel-adapter id=&quot;cqInputChannel&quot;  
cq-listener-container=&quot;queryListenerContainer&quot;  
query=&quot;select * from /Customers&quot; />

<gfe:pool id=&quot;client-pool&quot; subscription-enabled=&quot;true&quot;>  
<gfe:server host=&quot;localhost&quot; port=&quot;40404&quot; />  
</gfe:pool>

<file:outbound-channel-adapter id=&quot;files&quot;  
mode=&quot;APPEND&quot;  
charset=&quot;UTF-8&quot;  
directory=&quot;/Users/jellin/&quot;  
filename-generator-expression=&quot;'HelloWorld'&quot;  
/>

<int:transformer input-channel=&quot;cqInputChannel&quot; output-channel=&quot;files&quot; method=&quot;toString&quot;>  
<bean class=&quot;demo.transformer.JsonStringToObjectTransformer&quot;/>  
</int:transformer>  
[/code]

  1. First we define a client cache.
  2. The cqListener container which references the cache and the pool
  3. the _cqInputChannel_ defines the query and a reference to the listener container
  4. the _files_ defines the outbound channel which is the file data will be appended to.
  5. the _transformer_ uses a simple Java POJO to map PDXInstances to a String.

Since we are using a continuous query we don&#8217;t need to define the Customers region on the client.

Since we will be using Spring Boot there is very little additional work we need to do other than defining the above Integration.xml file.

The Spring Configuration class uses AutoConfiguration to bootstrap Spring.

[code lang=&#8221;java&#8221;]  
@Configuration  
@ComponentScan  
@EnableAutoConfiguration  
@ImportResource(&quot;integration.xml&quot;)  
public class Application {

public static void main(String[] args) {  
SpringApplication.run(Application.class, args);  
}  
}  
[/code]

## Running the Demo

Start GemFire

[code lang=&#8221;bash&#8221;]  
gemfire-server cq-demo.xml  
[/code]

Start Spring XD

[code lang=&#8221;bash&#8221;]  
xd-singlenode  
[/code]

Start xd-shell

[code lang=&#8221;bash&#8221;]  
xd-shell  
[/code]

Start your Spring Boot application by running Application.java in your IDE

Start a stream in the XD Shell to pipe data posted via http to GemFire

[code lang=&#8221;text&#8221;]  
http | gemfire-json-server –regionName=Customers –keyExpression=payload.getField(‘lastname’) –host localhost –port 40404 –deploy  
[/code]

Post data to Gemfire using the XD Shell

[code lang=&#8221;text&#8221;]  
http post &#8211;target http://localhost:9090 &#8211;data {&quot;firstname&quot;:&quot;BOB&quot;,&quot;lastname&quot;:&quot;JONES&quot;}  
[/code]

if everything was setup correctly you should see a new line of data in your HelloWorld file each time data is added to the Customers region.

[Source Code](https://github.com/ellinj/gemfire-boot/tree/v1.0/gemfire-integration) is available here.