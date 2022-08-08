---
id: 675
title: Spring Developers guide to Starting with Pivotal Cloud Cache and Gemfire
date: 2018-04-14T00:33:32+00:00
author: ellinj
layout: post

permalink: /2018/04/14/spring-developers-guide-to-starting-with-pivotal-cloud-cache-and-gemfire/
tags:
  - GemFire
  - spring
---

>This page was converted from my old blog and hasn't been reviewed. If you see an error please let me know in the comments.


The following article will help the Spring developer complete the following steps.

## This article has been updated. Latest content is <a href=/2019/04/10/update-spring-developers-guide-to-starting-with-pivotal-cloud-cache-and-gemfire/>here</a>

  1. Create a local GemFire Server for testing.
  2. Create a cache client application.
  3. Create a Pivotal Cloud Cache service instance in Pivotal Cloud Foundry (PCF)
  4. Deploy client application to PCF

The complete code is [here](https://github.com/jeffellin/pcc_demo).

## Cache Server for local development {#toc_0}

Use Spring Boot

<div>
  <pre><code class="language-none">@SpringBootApplication
@CacheServerApplication(name = "SpringBootGemFireServer")
@EnableLocator
@EnableManager
public class SpringBootGemFireServer {

    public static void main(String[] args) {
        SpringApplication.run(SpringBootGemFireServer.class);
    }</code></pre>
</div>

This code will start up a single node Gemfire Server with both a locator and a cache node. Once you have the cache server running, you will need to create a region in which to store data. 

<div>
  <pre><code class="language-none">    @Bean(name = "Persons")
    ReplicatedRegionFactoryBean personsRegion(Cache gemfireCache) {

        ReplicatedRegionFactoryBean person = new ReplicatedRegionFactoryBean&lt;&gt;();

        person.setCache(gemfireCache);
        person.setClose(false);
        person.setPersistent(false);

        return person;

    }</code></pre>
</div>

The `Customer` region will store Customer objects with a Long type used as the key.

Start the cache server by running the main class.

<div>
  <pre><code class="language-none">[info 2018/04/12 12:16:10.786 EDT &lt;main&gt; tid=0x1] Initializing region Customers
[info 2018/04/12 12:16:10.786 EDT &lt;main&gt; tid=0x1] Initialization of region Customers completed
Cache server connection listener bound to address 0.0.0.0/0.0.0.0:40404</code></pre>
</div>

### Simple Client {#toc_1}

Next, we will create a simple client also using Spring Boot which will do most of the heavy lifting for us.

<div>
  <pre><code class="language-none">@SpringBootApplication
@ClientCacheApplication(name = "AccessingDataGemFireApplication", logLevel = "error")
@EnableEntityDefinedRegions(basePackages = {"com.example.demogemfire.model"},
        clientRegionShortcut = ClientRegionShortcut.CACHING_PROXY)
@EnableGemfireRepositories
@EnablePdx()
public class DemoGemfireApplication {
...
}</code></pre>
</div>

  1. This class is a SpringBootApplication
  2. This application requires a client cache
  3. Automatically define client regions based on Repositories found on the classpath
  4. Make Repositories found, GemFire repositories
  5. Enable PDX Serialization.

We then can define a typical Spring Data Repository.

<div>
  <pre><code class="language-none">interface PersonRepository extends CrudRepository&lt;Person, String&gt; {

    Person findByName(String name);
 
    ...
}    </code></pre>
</div>

Lastly, we need to tell Spring where to find the cache locator by adding a property to application.properties. The correct host and port should be visible in your CacheServer startup log.

<div>
  <pre><code class="language-none">spring.data.gemfire.pool.locators=localhost[10334]</code></pre>
</div>

When you run the application, you should see output indicating data was placed in the cache and subsequently retrieved from the cache.

## Using Pivotal Cloud Cache (PCC) {#toc_2}

PCC is a cloud-based cache that can be deployed to Cloud Foundry. Assuming your PCF instance has PCC already installed you can efficiently utilize the `cf` command line to create and maintain your cache.

### Create the cache {#toc_3}

  1. Verify that PCC is available.
    
    <div>
      <pre><code class="language-none">cf marketplace</code></pre>
    </div>
    
    Look for `p-cloudcache`. If it isn&rsquo;t available, you will need to work with your cloud operator to have them install the tile.

  2. Create the service
    
    <div>
      <pre><code class="language-none">cf create-service p-cloudcache dev-plan pcc</code></pre>
    </div>
    
    Create a service instance of the cloud cache called `pcc` This may take some time to complete so you can monitor its progress with
    
    <div>
      <pre><code class="language-none">cf service pcc</code></pre>
    </div>

  3. Service Key
    
    Once the instance creation succeeds, we will need a service key. The service key will provide the required credentials for working with the cache. By default, you will have two users one with `developer` access and one with `operator` access. This information will also be exposed via `VCAP_SERVICES` to allow applications in other deployed containers to connect.
    
    <div>
      <pre><code class="language-none">cf create-service-key pcc pcc-key</code></pre>
    </div>
    
    <div>
      <pre><code class="language-none">cf service-key pcc pcc-key                                                         
Getting key pcc-key for service instance pcc as jellin@pivotal.io...

{
 "distributed_system_id": "12",
 "locators": [
  "192.168.12.186[55221]"
 ],
 "urls": {
  "gfsh": "https://cloudcache-yourserver.io/gemfire/v1",
  "pulse": "https://cloudcache-yourserver.io/pulse"
 },
 "users": [
  {
   "password": "**********",
   "roles": [
    "developer"
   ],
   "username": "developer_*******"
  },
  {
   "password": "***********",
   "roles": [
    "cluster_operator"
   ],
   "username": "cluster_operator_*******"
  }
 ],
 "wan": {
  "sender_credentials": {
   "active": {
    "password": "**********",
    "username": "gateway_sender_*******"
   }
  }
 }
}</code></pre>
    </div>

  4. Create the Using GFSH
    
    Create a Region in PCC to hold the data. Use the locator URL and GFSH operator credentials from above.
    
    Load the GFSH utility included with the GemFire distribution.
    
    <div>
      <pre><code class="language-none">./gfsh</code></pre>
    </div>
    
    Connect to the cache
    
    <div>
      <pre><code class="language-none">gfsh&gt;connect --use-http --url https://cloudcache-yourserver.io/gemfire/v1 --user=cluster_operator_DnrQ139FKwjTaLpBJsuQ --password=OxKlo8GXHGgWcRNGPx6nw
Successfully connected to: GemFire Manager HTTP service @ org.apache.geode.management.internal.web.http.support.HttpRequester@a34930a

Cluster-12 gfsh&gt;</code></pre>
    </div>
    
    Create the region
    
    <div>
      <pre><code class="language-none">Cluster-12 gfsh&gt;create region --name=Person --type=REPLICATE
                     Member                      | Status
------------------------------------------------ | ------------------------------------------------------------------------
cacheserver-3418fce1-13dd-4104-97ba-083b11b7a936 | Region "/Person" created on "cacheserver-3418fce1-13dd-4104-97ba-083b1..</code></pre>
    </div>

### Service Discovery {#toc_4}

When binding a service to an application container in PCF, we can expose connection information such as URLs and credentials that may change over time. Spring Cloud for Gemfire can automate the retrieval of these credentials.

<div class="alert alert-success">
  **NOTE**: While it would be ideal to use Spring Cloud Gemfire to automate the connection we can&rsquo;t currently extend additional configuration parameters such as PDX Serialization. This is because the connector creates the `ClientCache` before the `@ClientCacheApplication` annotation. In order to work around this add the `@EnableSecurity` annotation and the following config properties.
</div>

<div>
  <pre><code class="language-none">spring.data.gemfire.pool.locators=192.168.12.185[55221]
spring.data.gemfire.security.username=cluster_operator_****
spring.data.gemfire.security.password=****</code></pre>
</div>

_This is being addressed in a future release of [Spring Boot Starter for Gemfire/Geode](https://github.com/spring-projects/spring-boot-data-geode). Until then here is a possible work around._

If you manually create the ClientCache you have more control but you will lose the benefit of using the annotations. 

<div>
  <pre><code class="language-none">@Bean
   ClientCache clientCache() throws IOException, URISyntaxException {


       Properties props = new Properties();
       props.setProperty("security-client-auth-init", "com.example.demogemfire.config.ClientAuthInitialize.create");
       ClientCacheFactory ccf = new ClientCacheFactory(props);
       ccf.setPdxSerializer(new MappingPdxSerializer());
       List&lt;URI&gt; locatorList = EnvParser.getInstance().getLocators();

       for (URI locator : locatorList) {
           ccf.addPoolLocator(locator.getHost(), locator.getPort());
       }

       return ccf.create();

   }</code></pre>
</div>

In the above example the EnvParser is responsible for gathering the required data out of VCAP_SERVICES.

[Working Code on this branch](https://github.com/jeffellin/pcc_demo/tree/PCFEnvParsing/client/src/main/java/com/example/demogemfire/config)

Create a PCF manifest to bind the cache to your application

<div>
  <pre><code class="language----">applications:
- name: client
  path: target/gs-accessing-data-gemfire-0.1.0.jar
  no-hostname: true
  no-route: true
  health-check-type: none
  services:
  - pcc
</code></pre>
</div>

Push your app as normal

<div>
  <pre><code class="language-none">cf push</code></pre>
</div>

use `cf` client to view the results

<div>
  <pre><code class="language-none">cf logs client</code></pre>
</div>