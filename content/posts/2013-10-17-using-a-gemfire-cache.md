---
id: 26
title: Using a Gemfire Cache
date: 2013-10-17T22:21:41+00:00
author: ellinj
layout: post

permalink: /2013/10/17/using-a-gemfire-cache/
original_post_id:
  - "23"
tags:
  - GemFire
  - Uncategorized
---

>This page was converted from my old blog and hasn't been reviewed. If you see an error please let me know in the comments.

Now that you have GemFire installed how doe you use it? The simplest use case is to store an object into the cache with a put and get operation using a key and value pair. The object must be serializable and the key must result in a unique object based on its hash code.

Before we can store anything in the cache we need an object.

A POGO to store in the cache

<pre class="lang:groovy decode:true " >@ToString
class Customer implements Serializable{
    String id;
    String name;
}
</pre>

Obtain an instance of the cache. 

<pre class="lang:groovy decode:true " >def cache = new ClientCacheFactory()
        .set("name", "ClientWorker")
        .set("cache-xml-file", "clientCache.xml")
        .create()
</pre>

Obtain a instance of the Customers region. 

<pre class="lang:groovy decode:true " >def assets = cache.getRegion("Customers");
</pre>

Create and store the customer.

<pre class="lang:groovy decode:true " >Customer c = new Customer(id:"1",name:"Jeff");
assets.put(c.id,c);
def out = assets.get("1")

println "****retrieved the object from the cache***"
println out
println "******************************************"
</pre>

close the cache

<pre class="lang:groovy decode:true " >cache.close()
</pre>

This script is available [here](https://github.com/ellinj/gemfire/blob/master/gemfire6/simplesclient/src/main/groovy/LoadCustomers.groovy)

Next up I will show you how to query for object using Gemfire&#8217;s OQL feature.