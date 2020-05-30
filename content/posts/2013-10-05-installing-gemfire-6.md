---
id: 23
title: Installing GemFire 6
date: 2013-10-05T20:54:20+00:00
author: ellinj
layout: post

permalink: /2013/10/05/installing-gemfire-6/
original_post_id:
  - "8"
tags:
  - GemFire
  - Uncategorized
tags:
  - GemFire
---

>This page was converted from my old blog and hasn't been reviewed. If you see an error please let me know in the comments.

While it isn&#8217;t the latest and greatest recently I had to install GemFire 6 on my Mac in order to test some development code. Some day I will write a post that explains what GemFire is and what its used for, but for now I will provide the steps to get a simple stand alone cluster up and running.

Installing GemFire 6 is a rather simple process.

From a terminal window ensure that Java is in your path and run the following command

<pre class="lang:java decode:true " >java -jar vFabric_GemFire_6649_Installer.jar</pre>

The installer will prompt you for the destination location. I chose to install it in my local user directory under.

<pre class="lang:java decode:true " >/users/jellin/pivotal/gemfire</pre>

Once you have Gemfire installed you can begin to setup your environment to start up your first cluster.

Underneath the home directory for your cluster you will need

  * shell script for configuring your GemFire environment
  * a directory for each node in the cluster e.g. Server1 and Locator, these directories contain node specific information such as log files and statistics.
  * a directory to store the configuration for the cluster.
  * a properties file to configure GemFire </ul> 
    <pre>CLUSTER_HOME
|--server1
|--locator
|--xml
|--gfconfig.sh
|--gemfire.properties</pre>
    
    gfconfig.sh
    
    <pre class="lang:java decode:true " >export JAVA_HOME=`/usr/libexec/java_home -v 1.6`
export GEMFIRE=/Users/jellin/pivotal/gemfire/vFabric_GemFire_6649
</pre>
    
    gemfire.properties
    
    <pre class="lang:java decode:true " >log-level=warning
locators=localhost[41111]
mcast-port=0
cache-xml-file=../xml/serverCache.xml
</pre>
    
    xml/serverCache.xml
    
    <pre class="lang:java decode:true " >&lt;cache&gt;
   &lt;region name="Customers" refid="PARTITION"&gt;
   &lt;/region&gt;
&lt;/cache&gt;
</pre>
    
    once you have created the shell script you can load by running.
    
    <pre class="lang:java decode:true " >. ./gfconfig.sh</pre>
    
    ### Starting your Cluster
    
    You can then start the locator
    
    <pre class="lang:java decode:true " >gemfire start-locator -port=41111 -dir=locator -properties=../gemfire.properties -Xmx50m -Xms50m</pre>
    
    followed by the cacheserver
    
    <pre class="lang:java decode:true " >cacheserver start locators=localhost[41111] -server-port=41116 -J-DgemfirePropertyFile=../gemfire.properties -dir=server1 -J-Xms50m -J-Xmx50m
</pre>
    
    ### Stopping your Cluster
    
    First Stop the CacheServer
    
    <pre class="lang:java decode:true " >cacheserver stop -dir=server1
</pre>
    
    Second Stop the locator
    
    <pre class="lang:java decode:true " >gemfire stop-locator -dir=locator -port=41111
</pre>
    
    A sample of a simple gemfire setup can be found on [GitHub](https://github.com/ellinj/gemfire/tree/master/gemfire6/simpleserver)