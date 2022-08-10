---
id: 185
title: Spring Integration on Dropwizard
date: 2016-03-27T08:33:34+00:00
author: ellinj
layout: post

geo_public:
  - "0"
publicize_linkedin_url:
  - 'https://www.linkedin.com/updates?discuss=&scope=20835048&stype=M&topic=6120262983227629568&type=U&a=kMyj'

tags:
  - dropwizard
  - spring
---

>This page was converted from my old blog and hasn't been reviewed. If you see an error please let me know in the comments.


One of my favorite Spring sub projects is Spring Integration.  Spring integration is an implementation of the [Enterprise Integration Patterns](http://www.enterpriseintegrationpatterns.com/).

I can&#8217;t say it much better than the Spring team so I will quote the following from the [Spring Integration QuickStart](http://projects.spring.io/spring-integration/#quick-start)

> Using the [Spring Framework](http://projects.spring.io/spring-framework/) encourages developers to code using interfaces and use dependency injection (DI) to provide a Plain Old Java Object (POJO) with the dependencies it needs to perform its tasks. **Spring Integration** takes this concept one step further, where POJOs are wired together using a messaging paradigm and individual components may not be aware of other components in the application. Such an application is built by assembling fine-grained reusable components to form a higher level of functionality. With careful design, these flows can be modularized and also reused at an even higher level.
> 
> In addition to wiring together fine-grained components, Spring Integration provides a wide selection of channel adapters and gateways to communicate with external systems. Channel Adapters are used for one-way integration (send or receive); gateways are used for request/reply scenarios (inbound or outbound). For a full list of adapters and gateways, refer to the reference documentation.

The out of the box components include internal enterprise pattern components such as:

  * Router
  * Channel
  * Aggregator
  * Filter
  * Tranformer

It also includes many external system integration adapters such as:

  * ReST/HTTP
  * FTP/SFTP
  * Twitter
  * WebServices (SOAP and ReST)
  * TCP/UDP
  * JMS
  * RabbitMQ
  * Email
  * Kafka

And of course you can write your own.

The below code will introduce you to some of the Spring Integration components and in the spirit of my last post [Spring Security on Dropwizard.](2016/03/23/172/) i will implement the code on Dropwizard.

The full sample is available on [GitHub](https://github.com/jeffellin/dropwizard-spring/tree/springintegration)

In this example we will utilize a component approach to convert the temperature from Fahrenheit to Celsius.

<pre><code class="hljs">&lt;span class="hljs-meta">@MessagingGateway&lt;/span>
    &lt;span class="hljs-keyword">public&lt;/span> &lt;span class="hljs-class">&lt;span class="hljs-keyword">interface&lt;/span> &lt;span class="hljs-title">TempConverter&lt;/span> &lt;/span>{

        &lt;span class="hljs-meta">@Gateway&lt;/span>(requestChannel = &lt;span class="hljs-string">"convert.input"&lt;/span>)
        &lt;span class="hljs-function">&lt;span class="hljs-keyword">float&lt;/span> &lt;span class="hljs-title">fahrenheitToCelsius&lt;/span>&lt;span class="hljs-params">(&lt;span class="hljs-keyword">float&lt;/span> fahren)&lt;/span>&lt;/span>;

    }</code></pre>

The Messaging Gateway is the first part of our integration flow. It represents the contract that will be used when a caller wants to invoke the flow.  In this case it has a single method that takes a float as input and returns a float.

The Spring Integration DSL allows us to implement the data flow. In this case the flow performs the following steps.

  1. Transform the payload into an XML message.
  2. Enrich the header of the message with the SOAPAction header
  3. send the message outbound via HTTP
  4. transform the result by extracting the value in Celsius.

<pre><code class="hljs">@Bean
public IntegrationFlow convert() {
&lt;span class="hljs-function">&lt;span class="hljs-title">return&lt;/span> f -&gt;&lt;/span> f
 .&lt;span class="hljs-function">&lt;span class="hljs-title">transform&lt;/span>(payload -&gt;&lt;/span>
    &lt;span class="hljs-string">"&lt;FahrenheitToCelsius xmlns=\"&lt;/span>http:&lt;span class="hljs-comment">//www.w3schools.com/xml/\"&gt;"&lt;/span>
   + &lt;span class="hljs-string">"&lt;Fahrenheit&gt;"&lt;/span> + payload + &lt;span class="hljs-string">"&lt;/Fahrenheit&gt;"&lt;/span>
   + &lt;span class="hljs-string">"&lt;/FahrenheitToCelsius&gt;"&lt;/span>)
 .&lt;span class="hljs-function">&lt;span class="hljs-title">enrichHeaders&lt;/span>(h -&gt;&lt;/span> h
 .header(WebServiceHeaders.SOAP_ACTION,
   &lt;span class="hljs-string">"http://www.w3schools.com/xml/FahrenheitToCelsius"&lt;/span>))
 .handle(new SimpleWebServiceOutboundGateway(
    &lt;span class="hljs-string">"http://www.w3schools.com/xml/tempconvert.asmx"&lt;/span>))
.transform(Transformers.xpath(&lt;span class="hljs-string">"/*[local-name()=\"&lt;/span>FahrenheitToCe lsiusResponse\&lt;span class="hljs-string">"]"&lt;/span>
    + &lt;span class="hljs-string">"/*[local-name()=\"&lt;/span>FahrenheitToCelsiusResult\&lt;span class="hljs-string">"]"&lt;/span>));
}</code></pre>

The second part of the flow converts the payload to a web service call using the WebServiceOutboundGateway component. In this example the code is inline in our configuration class but it could just as easily be extracted out into another class so they can easily be reused.

<pre><code class="hljs">&lt;span class="hljs-keyword">final&lt;/span> &lt;span class="hljs-keyword">Float&lt;/span> tempc  =
    tempConverter.fahrenheitToCelsius(tempf.&lt;span class="hljs-keyword">or&lt;/span>(&lt;span class="hljs-number">0&lt;/span>f));</code></pre>

Now that we have the interface created we can simply call it to initiate our flow.

This is a very simplistic flow but Spring Integration can support many complex scenarios in a very modular fashion. In a recent project we used the outbound file gateway to save the output of a workflow to a file.

<pre><code class="hljs">&lt;int-&lt;span class="hljs-built_in">file&lt;/span>:outbound-channel-adapter 
    id=&lt;span class="hljs-string">"outboundJobRequestChannel"&lt;/span>
    channel=&lt;span class="hljs-string">"file"&lt;/span> 
    mode=&lt;span class="hljs-string">"APPEND"&lt;/span> 
    &lt;span class="hljs-built_in">directory&lt;/span>=&lt;span class="hljs-string">"${filesout}"&lt;/span>        
    auto-&lt;span class="hljs-built_in">create&lt;/span>-&lt;span class="hljs-built_in">directory&lt;/span>=&lt;span class="hljs-string">"true"&lt;/span>/&gt;</code></pre>

The outbound adapter is subscriber to the outboundJobRequestChannel and processes the data as it comes in.

Some weeks after the completion of this project the customer asked us to post the file to an http endpoint rather than a file.  If we had written this code from scratch, we would have quite a bit of work ahead of us to implement this change.  Fortunately, Spring provides an http outbound file adapter.  All we did was change the configuration to use it to post the record to the specified URL.

<pre><code class="hljs">&lt;&lt;span class="hljs-built_in">int&lt;/span>-http:outbound-gateway
    request-channel=&lt;span class="hljs-string">"outboundJobRequestChannel"&lt;/span>
    http-&lt;span class="hljs-keyword">method&lt;/span>=&lt;span class="hljs-string">"POST"&lt;/span>
    url=&lt;span class="hljs-string">"${clusterPublishURL}"&lt;/span>      
    mapped-request-headers=&lt;span class="hljs-string">"ContentType:application/json"&lt;/span>
/&gt;</code></pre>

We also had a request to look at possibly publishing to Kafka,  Again, Spring provided us with what we needed out of the box.

<pre><code class="hljs">&lt;&lt;span class="hljs-built_in">int&lt;/span>-kafka:outbound-channel-adapter&gt;
    &lt;kafka-producer-context-&lt;span class="hljs-keyword">ref&lt;/span>=&lt;span class="hljs-string">"kafkaProducerContext"&lt;/span>
        channel=&lt;span class="hljs-string">"file"&lt;/span>
        topic=&lt;span class="hljs-string">"foo"&lt;/span>
        message-key=&lt;span class="hljs-string">"bar"&lt;/span>&gt;
&lt;/&lt;span class="hljs-built_in">int&lt;/span>-kafka:outbound-channel-adapter&gt;</code></pre>

We could even easily switch between the different implementations using [Spring Profiles.](https://docs.spring.io/spring-boot/docs/current/reference/html/boot-features-profiles.html)

If Spring didn’t provide what needed we could easily implement our own channel adapters.

Another interesting example is the [Cafe Demo](http://docs.spring.io/spring-integration/docs/4.2.5.RELEASE/reference/html/samples.html#samples-cafe) example provided in the Spring documentation.

The purpose of the Cafe Demo application is to demonstrate how Enterprise Integration Patterns (EIP) can be used to delegate order processing to a parallel flow. With this application, we handle several drink orders &#8211; hot and iced. Cold drinks are prepared quicker than hot. However the delivery for the whole order is postponed until the hot drink is ready.

<pre><code class="hljs">&lt;&lt;span class="hljs-built_in">int&lt;/span>:channel id=&lt;span class="hljs-string">"coldDrinks"&lt;/span>&gt;
    &lt;&lt;span class="hljs-built_in">int&lt;/span>:queue capacity=&lt;span class="hljs-string">"10"&lt;/span>/&gt;
&lt;/&lt;span class="hljs-built_in">int&lt;/span>:channel&gt;
&lt;&lt;span class="hljs-built_in">int&lt;/span>😒ervice-activator
input-channel=&lt;span class="hljs-string">"coldDrinks"&lt;/span>
&lt;span class="hljs-keyword">ref&lt;/span>=&lt;span class="hljs-string">"barista"&lt;/span>
&lt;span class="hljs-keyword">method&lt;/span>=&lt;span class="hljs-string">"prepareColdDrink"&lt;/span>
output-channel=&lt;span class="hljs-string">"preparedDrinks"&lt;/span>/&gt;


&lt;&lt;span class="hljs-built_in">int&lt;/span>:channel id=&lt;span class="hljs-string">"hotDrinks"&lt;/span>&gt;
&lt;&lt;span class="hljs-built_in">int&lt;/span>:queue capacity=&lt;span class="hljs-string">"10"&lt;/span>/&gt;
&lt;/&lt;span class="hljs-built_in">int&lt;/span>:channel&gt;


&lt;&lt;span class="hljs-built_in">int&lt;/span>😒ervice-activator
input-channel=&lt;span class="hljs-string">"hotDrinks"&lt;/span>
&lt;span class="hljs-keyword">ref&lt;/span>=&lt;span class="hljs-string">"barista"&lt;/span>
&lt;span class="hljs-keyword">method&lt;/span>=&lt;span class="hljs-string">"prepareHotDrink"&lt;/span>
output-channel=&lt;span class="hljs-string">"preparedDrinks"&lt;/span>/&gt;
&lt;&lt;span class="hljs-built_in">int&lt;/span>:channel id=&lt;span class="hljs-string">"preparedDrinks"&lt;/span>/&gt;


&lt;&lt;span class="hljs-built_in">int&lt;/span>:aggregator
input-channel=&lt;span class="hljs-string">"preparedDrinks"&lt;/span>
&lt;span class="hljs-keyword">ref&lt;/span>=&lt;span class="hljs-string">"waiter"&lt;/span>
&lt;span class="hljs-keyword">method&lt;/span>=&lt;span class="hljs-string">"prepareDelivery"&lt;/span>
output-channel=&lt;span class="hljs-string">"deliveries"&lt;/span>/&gt;</code></pre>

The splitter splits the order into a hot drink queue and a cold drink queue. The order cannot be released to the waiter until the aggregator has the complete order.

For further inspiration on the power of Spring Integration see the [Samples](https://github.com/spring-projects/spring-integration-samples).