+++
title =  "Using Spring Boot Data Geode"
date = 2019-04-10T13:35:15-04:00
tags = ["geode"]
featured_image = ""
description = "One aspect of creating good CI/CD pipelines is the management of passwords and other credentials required for deployment. A typical concourse pipeline will poll for updates in a git repo, do a build and then push the results to a PaaS such as Kubernetes or Cloud Foundry."
draft = "false"
+++
<meta charset="utf-8" />

<link rel="stylesheet" href="https://unpkg.com/markdown-core@1.1.0/dist/index.bundle.css" />

<link rel="stylesheet" href="https://cdn.jsdelivr.net/mermaid/6.0.0/mermaid.css" />
<article class="markdown-body"> 

<p data-source-line="3">
  Spring Boot Data Geode is a new project aimed at simplifying the use of Geode/Gemfire/PivotalCloudCache. Its primary goal is to extend Spring Boot with auto-configuration support as well as streamline the programmer&#8217;s experience while working in the spring ecosystem.
</p>

<p data-source-line="5">
  The project has the following primary goals.
</p>

<ul data-source-line="7">
  <li>
    Auto Configure the ClientCache automatically when the project&#8217;s starter is on the classpath.
  </li>
</ul>

```xml
<dependency>
    <groupId>org.springframework.geode</groupId>
    <artifactId>spring-gemfire-starter</artifactId>
    <version>1.0.0.M4</version>
</dependency>
```
    

<p data-source-line="15">
  or
</p>

```xml
<dependency>
    <groupId>org.springframework.geode</groupId>
    <artifactId>spring-geode-starter</artifactId>
    <version>1.0.0.M4</version>
</dependency>
```    

<ul data-source-line="25">
  <li>
    Auto Configure Spring&#8217;s Cache Abstraction
  </li>
</ul>

```java
@Cacheable({"books", "isbns"})
public Book findBook(ISBN isbn) {...}
```    

<ul data-source-line="31">
  <li>
    Provide automatic connectivity to a cache when the application is deployed to Pivotal Cloud Foundry and bound to a Pivotal Cloud Cache.
  </li>
</ul>

<h2 id="getting-started" data-source-line="34">
  <a class="anchor" href="#getting-started"><span class="octicon octicon-link"></span></a>Getting Started
</h2>

<p data-source-line="36">
  All code for this article can be found on <a href="https://github.com/jeffellin/gemfire-test-demo">Github</a>
</p>

<p data-source-line="38">
  The easiest way to get started is to use Docker to start a local cache on your laptop.
</p>

```bash
docker run -ti -p 40404:40404 -p 10334:10334 apachegeode/geode:1.6.0 bash
```    

<p data-source-line="44">
  Running this command will drop you into a GFSH shell that you can use to start the locator, server and create some regions.
</p>

```bash
start locator --name locator
start server --name server1
create region --name /restrictionRegion --type=REPLICATE
```    

<p data-source-line="52">
  Since the <code>ClientCache</code> is already registered by spring boot, all you need to do is define a <code>ClientRegionFactoryBean</code> in your configuration.
</p>

```java
@Bean("restrictionRegion")
public ClientRegionFactoryBean<String, Boolean> restrictionRegion(GemFireCache cache) {
    ClientRegionFactoryBean<String, Boolean> region = new ClientRegionFactoryBean<>();
    region.setCache(cache);
    region.setShortcut(ClientRegionShortcut.PROXY);
    return region;
}
```
    

<p data-source-line="64">
  You can then inject this region into your code and do Cache Get/Put Operations.
</p>

```java
@Resource(name = "restrictionRegion")
Region<String,Boolean> restrictionRegion;

public  boolean checkRestriction(String key){
    return restrictionRegion.get(key);
}
    
```
<p data-source-line="75">
  Upon starting the app, Spring Boot will automatically connect to the Cache cluster running on your machine. It will use the locator address of localhost[10334]. If you wish to connect to a different Cache, you can use the following spring properties.
</p>

```java
    #Comma-delimited list of Locator endpoints formatted as: locator1[port1],...,locatorN[portN]
    spring.data.gemfire.locators=localhost[10334]
    
    #Configures the username used to authenticate with the servers.
    spring.data.gemfire.security.username
    
    #Configures the user password used to authenticate with the servers.
    spring.data.gemfire.security.password
```    

<h2 id="testing" data-source-line="88">
  <a class="anchor" href="#testing"><span class="octicon octicon-link"></span></a>Testing
</h2>

<p data-source-line="90">
  Testing can be done in two ways.
</p>

<ul data-source-line="92">
  <li>
    Unit Testing with Mockito Mocks
  </li>
  <li>
    Integration Tests using a real server.
  </li>
</ul>

<h3 id="mocks" data-source-line="96">
  <a class="anchor" href="#mocks"><span class="octicon octicon-link"></span></a>Mocks
</h3>

<p data-source-line="98">
  By far the easiest way to test Gemfire code is with mocks. The Gemfire region can easily be mocked using Mockito.
</p>

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

<h3 id="integration-testing" data-source-line="114">
  <a class="anchor" href="#integration-testing"><span class="octicon octicon-link"></span></a>Integration Testing
</h3>

<p data-source-line="116">
  There is a new project called<br /> <a href="https://github.com/spring-projects/spring-test-data-geode">Spring Geode Test</a>
</p>

<p data-source-line="119">
  This project makes it trivial to spin up a test Locator and Server for use during an integration test.
</p>

<ul data-source-line="121">
  <li>
    Extend ForkingClientServerIntegrationTestsSupport
  </li>
  <li>
    Add a Spring boot configuration class to bootstrap a server and configure your test regions.
  </li>
</ul>

<p data-source-line="124">
  To start, add the following dependency to your project.
</p>

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
    

<p data-source-line="142">
  Implement a <code>@CacheServerAppliction</code> to bootstrap the test server.
</p>

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

<p data-source-line="174">
  you can then run your service code as required.
</p>

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
    }</code></pre>
```
<p data-source-line="194">
  The full test code can be found here.
</p>

<p data-source-line="196">
  <a href="https://github.com/jeffellin/gemfire-test-demo/blob/master/src/test/java/com/example/gftestdemo/GemFireTests.java">https://github.com/jeffellin/gemfire-test-demo/blob/master/src/test/java/com/example/gftestdemo/GemFireTests.java</a>
</p></article>