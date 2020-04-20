---
id: 723
title: '[Update] Spring Developers guide to Starting with Pivotal Cloud Cache and Gemfire'
date: 2019-04-10T18:45:00+00:00
author: ellinj
layout: post
description:   "An update to an older post which was based on older versions of Spring/Spring Data Geode.&nbsp; In this article, you will learn how to complete the following steps."

permalink: /2019/04/10/update-spring-developers-guide-to-starting-with-pivotal-cloud-cache-and-gemfire/
tags:
  - geode
---
</p> 

<p data-source-line="1">
  The following article is an update to an older post which was based on older versions of Spring/Spring Data Geode.&nbsp; In this article, you will learn how to complete the following steps.
</p>

<ul data-source-line="3">
  <li>
    Create a local GemFire Server for testing.
  </li>
  <li>
    Create a cache client application.
  </li>
  <li>
    Create a Pivotal Cloud Cache service instance in Pivotal Cloud Foundry (PCF)
  </li>
  <li>
    Deploy client application to PCF
  </li>
</ul>

<p data-source-line="8">
  The complete code is on <a href="https://github.com/jeffellin/pcc_demo">Github</a>.
</p>

<h2 id="cache-server-for-local-development" data-source-line="11">
  <a class="anchor" href="#cache-server-for-local-development"><span class="octicon octicon-link"></span></a>Cache Server for local development
</h2>

<p data-source-line="12">
  Use Spring Boot
</p>

```java
@SpringBootApplication
@CacheServerApplication(name = "SpringBootGemFireServer")
@EnableLocator
@EnableManager
public class SpringBootGemFireServer {

    public static void main(String[] args) {
        SpringApplication.run(SpringBootGemFireServer.class);
    }
This code will start up a single node Gemfire Server with both a locator and a cache node. Once you have the cache server running, you will need to create a region in which to store data.

    @Bean(name = "Persons")
    ReplicatedRegionFactoryBean personsRegion(Cache gemfireCache) {

        ReplicatedRegionFactoryBean person = new ReplicatedRegionFactoryBean<>();

        person.setCache(gemfireCache);
        person.setClose(false);
        person.setPersistent(false);

        return person;

    }
```

The Customer region will store Customer objects with a Long type used as the key.

Start the cache server by running the main class.

```bash
[info 2018/04/12 12:16:10.786 EDT <main> tid=0x1] Initializing region Customers
[info 2018/04/12 12:16:10.786 EDT <main> tid=0x1] Initialization of region Customers completed
Cache server connection listener bound to address 0.0.0.0/0.0.0.0:40404
```    

<p data-source-line="47">
  Alternatively, you can use a docker image to achieve the same result.
</p>

```bash
    docker run -ti -p 40404:40404 -p 10334:10334 apachegeode/geode:1.6.0 bash
```    

<p data-source-line="54">
  Running this command will drop you into a GFSH shell that you can use to start the locator, server and create some regions.
</p>
```bash
start locator --name locator
start server --name server1
create region --name /restrictionRegion --type=REPLICATE
 ```   

<h2 id="simple-client" data-source-line="63">
  <a class="anchor" href="#simple-client"><span class="octicon octicon-link"></span></a>Simple Client
</h2>

<p data-source-line="64">
  Next, we will create a simple client also using Spring Boot which will do most of the heavy lifting for us.
</p>

```java
@SpringBootApplication
@ClientCacheApplication(name = "AccessingDataGemFireApplication", logLevel = "error")
@EnableEntityDefinedRegions(basePackages = {"com.example.demogemfire.model"},
        clientRegionShortcut = ClientRegionShortcut.CACHING_PROXY)
@EnableGemfireRepositories
@EnablePdx()
public class DemoGemfireApplication {
...
}
```    

<ul data-source-line="78">
  <li>
    This class is a SpringBootApplication
  </li>
  <li>
    This application requires a client cache
  </li>
  <li>
    Automatically define client regions based on Repositories found on the classpath
  </li>
  <li>
    Make Repositories found, GemFire repositories
  </li>
  <li>
    Enable PDX Serialization.
  </li>
  <li>
    We then can establish a typical Spring Data Repository.
  </li>
</ul>

```java
interface PersonRepository extends CrudRepository<Person, String> {

    Person findByName(String name);
  
    ...
}  
```    

<p data-source-line="93">
  Lastly, we need to tell Spring where to find the cache locator by adding a property to application.properties. The correct host and port should be visible in your CacheServer startup log.
</p>

```java
spring.data.gemfire.pool.locators=localhost[10334]
```    

<p data-source-line="99">
  When you run the application, you should see output indicating data was placed in the cache and subsequently retrieved from the cache.
</p>

<h2 id="using-pivotal-cloud-cache-pcc" data-source-line="101">
  <a class="anchor" href="#using-pivotal-cloud-cache-pcc"><span class="octicon octicon-link"></span></a>Using Pivotal Cloud Cache (PCC)
</h2>

<p data-source-line="102">
  PCC is a cloud-based cache that can be deployed to Cloud Foundry. Assuming your PCF instance has PCC already installed you can efficiently utilize the cf command line to create and maintain your cache.
</p>

<h3 id="create-the-cache" data-source-line="104">
  <a class="anchor" href="#create-the-cache"><span class="octicon octicon-link"></span></a>Create the cache
</h3>

<p data-source-line="106">
  Verify that PCC is available.
</p>

```bash
cf marketplace
```    

<p data-source-line="112">
  Look for p-cloudcache. If it isn’t available, you will need to work with your cloud operator to have them install the tile.
</p>

<h3 id="create-the-service" data-source-line="114">
  <a class="anchor" href="#create-the-service"><span class="octicon octicon-link"></span></a>Create the service
</h3>

```bash
cf create-service p-cloudcache dev-plan pcc
```    

<p data-source-line="118">
  Create a service instance of the cloud cache called pcc This may take some time to complete so you can monitor its progress with
</p>

```bash
cf service pcc
```    

<h3 id="service-key" data-source-line="124">
  <a class="anchor" href="#service-key"><span class="octicon octicon-link"></span></a>Service Key
</h3>

<p data-source-line="126">
  Once the instance creation succeeds, we will need a service key. The service key will provide the required credentials for working with the cache. By default, you will have two users one with developer access and one with operator access. This information will also be exposed via VCAP_SERVICES to allow applications in other deployed containers to connect.
</p>

```bash
cf create-service-key pcc pcc-key
cf service-key pcc pcc-key                                       

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
}
```

<h3 id="create-regions-using-gfsh" data-source-line="170">
  <a class="anchor" href="#create-regions-using-gfsh"><span class="octicon octicon-link"></span></a>Create Regions Using GFSH
</h3>

<p data-source-line="172">
  Create a Region in PCC to hold the data. Use the locator URL and GFSH operator credentials from above.
</p>

<p data-source-line="174">
  Load the GFSH utility included with the GemFire distribution.
</p>

```bash
./gfsh
```    

<p data-source-line="179">
  Connect to the cache to create the region.
</p>

```bash
gfsh>connect --use-http --url https://cloudcache-yourserver.io/gemfire/v1 --user=cluster_operator_DnrQ139FKwjTaLpBJsuQ --password=OxKlo8GXHGgWcRNGPx6nw
Successfully connected to: GemFire Manager HTTP service @ org.apache.geode.management.internal.web.http.support.HttpRequester@a34930a


Cluster-12 gfsh>create region --name=Person --type=REPLICATE
                      Member                      | Status
------------------------------------------------ | ------------------------------------------------------------------------
cacheserver-3418fce1-13dd-4104-97ba-083b11b7a936 | Region "/Person" created on "cacheserver-3418fce1-13dd-4104-97ba-083b1..
```


## Service Discovery

When binding a service to an application container in PCF, we can expose connection information such as URLs and credentials that may change over time. Spring Cloud for Gemfire can automate the retrieval of these credentials.


<p data-source-line="194">
  In a previous <a href="/2018/04/14/spring-developers-guide-to-starting-with-pivotal-cloud-cache-and-gemfire/">post</a> I talked about manually creating the ClientCache bean to customize it. This procedure is no longer necessary with Spring Boot Data Gemfire. When pushing an app to cloud foundry as long as it is bound to PCC the credentials will automatically be loaded from VCAP_SERVICES.
</p>

<p data-source-line="196">
  If you are running your application outside of PCC you can manually set this information via spring properties.
</p>

```java
spring.data.gemfire.pool.locators=192.168.12.185[55221]
spring.data.gemfire.security.username=cluster_operator_****
spring.data.gemfire.security.password=****
```    

Create a PCF manifest to bind the cache to your application


```yaml
applications:
- name: client
  path: target/gs-accessing-data-gemfire-0.1.0.jar
  no-hostname: true
  no-route: true
  health-check-type: none
  services:
  - pcc
```    

<p data-source-line="214">
  Push your app as normal
</p>

<h3 id="customizing-region-and-cache-configuration" data-source-line="216">
  <a class="anchor" href="#customizing-region-and-cache-configuration"><span class="octicon octicon-link"></span></a>Customizing Region and Cache Configuration.
</h3>

<p data-source-line="218">
  With Spring Boot Data G the Region and Client Cache are automatically configured. Sometimes the settings need adjustments. In the past version of this post, I advocated just creating these beans manually. In Spring Boot Data G there is an interface that can be used to customize these beans before their creation.
</p>

```java
@Bean
public RegionConfigurer regionConfigurer(){
    return new RegionConfigurer() {
        @Override
        public void configure(String beanName, ClientRegionFactoryBean<?, ?> bean) {
            if(beanName.equals("Person")){
            //bean.setCacheListeners(...);
            }
          }
    };
}

@Bean
public ClientCacheConfigurer cacheConfigurer(){
    return new ClientCacheConfigurer() {
        @Override
        public void configure(String beanName, ClientCacheFactoryBean clientCacheFactoryBean) {
            //customize the cache
        clientCacheFactoryBean.setSubscriptionEnabled(false);
            }
          }
    };
}
```
    

</body></html>