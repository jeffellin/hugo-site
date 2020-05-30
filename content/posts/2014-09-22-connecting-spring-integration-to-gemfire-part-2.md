---
id: 79
title: Connecting Spring Integration to GemFire part 2
date: 2014-09-22T22:00:00+00:00
author: ellinj
layout: post

permalink: /2014/09/22/connecting-spring-integration-to-gemfire-part-2/
publicize_facebook_url:
  - https://facebook.com/10205022489227353
publicize_linkedin_url:
  - 'https://www.linkedin.com/updates?discuss=&scope=20835048&stype=M&topic=5920025995296915456&type=U&a=HEWi'
tags:
  - GemFire
  - spring
  - spring-integration
---

>This page was converted from my old blog and hasn't been reviewed. If you see an error please let me know in the comments.


In my [last post](2014/09/21/connecting-spring-integration-to-gemfire/) we used a Continuous Query as a data source for Spring Integration. Another option to use a GemFire&#8217;s Event messaging.

This example will use a Client/Server topology. The client cache will be configured to respond to cache events on the remote server and feed them into Spring Integration.

![Integration](http://www.ellin.com/blogimages/Spring_-_demo_src_main_resources_Integration_xml_-_Spring_Tool_Suite_-__Users_jellin_Documents_workspace-sts-3_6_1_RELEASE_19CFB403.png) 

## GemFire Inbound Channel adapter

The setup is very similar to the last post with all changes in the Spring Context file.

The _inputChannel_ will be a source of data. This source will use a GemFire Event Messaging to receive cache events.

A transform in the middle will convert the PDX Instance into a String representation.

the _files_ will be an outbound data sink and will write the data as it is received to a flat file.

[code lang=&#8221;text&#8221;]  
<gfe:client-cache id=&quot;client-cache&quot; pool-name=&quot;client-pool&quot;/>

<gfe:pool id=&quot;client-pool&quot; subscription-enabled=&quot;true&quot;>  
<gfe:server host=&quot;localhost&quot; port=&quot;40404&quot;/>  
</gfe:pool>

<gfe:client-region id=&quot;region&quot; name=&quot;Customers&quot; cache-ref=&quot;client-cache&quot; pool-name=&quot;client-pool&quot;  
shortcut=&quot;CACHING_PROXY&quot;>  
<gfe:regex-interest pattern=&quot;.*&quot; receive-values=&quot;true&quot;/>  
</gfe:client-region>

<int-gfe:inbound-channel-adapter id=&quot;inputChannel&quot; region=&quot;region&quot;  
cache-events=&quot;CREATED,UPDATED&quot;/>

<gfe:pool id=&quot;client-pool&quot; subscription-enabled=&quot;true&quot;>  
<gfe:server host=&quot;localhost&quot; port=&quot;40404&quot;/>  
</gfe:pool>

<file:outbound-channel-adapter id=&quot;files&quot;  
mode=&quot;APPEND&quot;  
charset=&quot;UTF-8&quot;  
directory=&quot;/Users/jellin/&quot;  
filename-generator-expression=&quot;'HelloWorld'&quot;  
/>

<int:transformer input-channel=&quot;inputChannel&quot; output-channel=&quot;files&quot;  
method=&quot;toString&quot;>  
<bean class=&quot;demo.transformer.JsonStringToObjectTransformer&quot;/>  
</int:transformer>  
[/code]

  1. First we define a client cache.
  2. The above cache will use a pool connection in a remote server.
  3. The client region will be a CACHING_PROXY and will register in interest in CREATES and UPDATES in all key. 
  4. the _cqInputChannel_ defines the query and a reference to the listener container
  5. the _files_ defines the outbound channel which is the file data will be appended to.
  6. the _transformer_ uses a simple Java POJO to map PDXInstances to a String.

Run the sample Spring Boot Application as outlined in my [previous post](2014/09/21/connecting-spring-integration-to-gemfire/). Everytime a new event is posted into GemFire it will result in a new entry in the HelloWorld file.

Source code can be found [here](https://github.com/ellinj/gemfire-boot/tree/v2.0/gemfire-integration)