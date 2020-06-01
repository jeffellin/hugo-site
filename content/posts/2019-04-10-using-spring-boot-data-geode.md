+++
title =  "Using Spring Boot Data Geode"
date = 2019-04-10T13:35:15-04:00
tags = ["geode"]
featured_image = ""
description = "One aspect of creating good CI/CD pipelines is the management of passwords and other credentials required for deployment. A typical concourse pipeline will poll for updates in a git repo, do a build and then push the results to a PaaS such as Kubernetes or Cloud Foundry."
draft = "false"
+++

Spring Boot Data Geode is a new project aimed at simplifying the use of Geode/Gemfire/PivotalCloudCache. Its primary goal is to extend Spring Boot with auto-configuration support as well as streamline the programmer's experience while working in the spring ecosystem.

The project has the following primary goals.

* Auto Configure the ClientCache automatically when the project's starter is on the classpath.
  


  ```xml
  <dependency>
      <groupId>org.springframework.geode</groupId>
      <artifactId>spring-gemfire-starter</artifactId>
      <version>1.0.0.M4</version>
  </dependency>
  ```
      

    or


  ```xml
  <dependency>
      <groupId>org.springframework.geode</groupId>
      <artifactId>spring-geode-starter</artifactId>
      <version>1.0.0.M4</version>
  </dependency>
  ```    


  
* Auto Configure Spring's Cache Abstraction
  


  ```java
  @Cacheable({"books", "isbns"})
  public Book findBook(ISBN isbn) {...}
  ```    


  
* Provide automatic connectivity to a cache when the application is deployed to Pivotal Cloud Foundry and bound to a Pivotal Cloud Cache.
  

## Getting Started

All code for this article can be found on [Github](https://github.com/jeffellin/gemfire-test-demo)

The easiest way to get started is to use Docker to start a local cache on your laptop.


```bash
docker run -ti -p 40404:40404 -p 10334:10334 apachegeode/geode:1.6.0 bash
```    


Running this command will drop you into a GFSH shell that you can use to start the locator, server and create some regions.


```bash
start locator --name locator
start server --name server1
create region --name /restrictionRegion --type=REPLICATE
```    


Since the `ClientCache` is already registered by spring boot, all you need to do is define a `ClientRegionFactoryBean` in your configuration.


```java
@Bean("restrictionRegion")
public ClientRegionFactoryBean<String, Boolean> restrictionRegion(GemFireCache cache) {
    ClientRegionFactoryBean<String, Boolean> region = new ClientRegionFactoryBean<>();
    region.setCache(cache);
    region.setShortcut(ClientRegionShortcut.PROXY);
    return region;
}
```
    
You can then inject this region into your code and do Cache Get/Put Operations.


```java
@Resource(name = "restrictionRegion")
Region<String,Boolean> restrictionRegion;

public  boolean checkRestriction(String key){
    return restrictionRegion.get(key);
}
    
```

Upon starting the app, Spring Boot will automatically connect to the Cache cluster running on your machine. It will use the locator address of localhost[10334]. If you wish to connect to a different Cache, you can use the following spring properties.


```java
  #Comma-delimited list of Locator endpoints formatted as: locator1[port1],...,locatorN[portN]
  spring.data.gemfire.locators=localhost[10334]
  
  #Configures the username used to authenticate with the servers.
  spring.data.gemfire.security.username
  
  #Configures the user password used to authenticate with the servers.
  spring.data.gemfire.security.password
```   


## Testing


Testing can be done in two ways.


* Unit Testing with Mockito Mocks
  
  
* Integration Tests using a real server.
  


## Mocks

By far the easiest way to test Gemfire code is with mocks. The Gemfire region can easily be mocked using Mockito.


```java
private Region restrictionRegion;

    @InjectMocks
    private RestrictionService restrictionService;

    @Test
    public void checkRestricted(){
        when(restrictionRegion.get("restricted")).thenReturn(true);

        assertTrue((restrictionService.checkRestriction("restricted")));
    }
```


## Integration Testing


There is a new project called [Spring Geode Test](https://github.com/spring-projects/spring-test-data-geode)



This project makes it trivial to spin up a test Locator and Server for use during an integration test.

Extend `ForkingClientServerIntegrationTestsSupport`
  
  
Add a Spring boot configuration class to bootstrap a server and configure your test regions.
  
 To start, add the following dependency to your project.


```xml
<dependency>
    <groupId>org.springframework.data</groupId>
    <artifactId>spring-data-gemfire-test</artifactId>
    <version>0.0.1.RC1</version>
    <scope>test</scope>
</dependency>

<repositories>
    <repository>
        <id>spring-snapshot</id>
        <url>https://repo.spring.io/libs-snapshot</url>
    </repository>
</repositories>
```    

Implement a `@CacheServerAppliction` to bootstrap the test server.


```java
@CacheServerApplication(name = "AutoConfiguredIntegrationTests", logLevel = GEMFIRE_LOG_LEVEL)
@EnablePdx
@EnableLocator
public static class GemFireServerConfiguration {
    public static void main(String[] args) {
        AnnotationConfigApplicationContext applicationContext =
                new AnnotationConfigApplicationContext(GemFireServerConfiguration.class);

        applicationContext.registerShutdownHook();


    }

    @Bean("restrictionRegion")
    public PartitionedRegionFactoryBean<String, Boolean> restrictionRegion(GemFireCache gemfireCache) {


        PartitionedRegionFactoryBean<String, Boolean> restrictionsRegion =
                new PartitionedRegionFactoryBean<>();

        restrictionsRegion.setCache(gemfireCache);
        restrictionsRegion.setClose(false);
        restrictionsRegion.setPersistent(false);
        return restrictionsRegion;
    }

}
```    

you can then run your service code as required.


```java
@Autowired
    private RestrictionService restrictionService;
 
    @Test
    public void checkRestricted(){

        assertTrue((restrictionService.checkRestriction("restricted")));
    }

    @Test
    public void checkNotRestricted(){

        assertFalse((restrictionService.checkRestriction("notrestricted")));
    }`</pre>
```

  The full test code can be found here.


  https://github.com/jeffellin/gemfire-test-demo/blob/master/src/test/java/com/example/gftestdemo/GemFireTests.java