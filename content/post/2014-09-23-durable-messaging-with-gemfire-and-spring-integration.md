+++
draft = true
+++

>This page was converted from my old blog and hasn't been reviewed. If you see an error please let me know in the comments.


In my last two posts I discussed using GemFire as a data source for Spring Integration. In both of these examples the client application receives events from GemFire as they occur.

If the client is offline for any reason it will miss these messages. If reliable event delivery is crucial to your application GemFire Durable Client/Server communication can be enabled.

## _Configuring the Spring Integration Client as Durable_

  * Enable durability on client interest by adding the durable=&#8221;true&#8221; flag.

[code lang=text]  
<gfe:client-region id="region" name="Customers" cache-ref="client-cache" pool-name="client-pool"  
shortcut="CACHING_PROXY">  
<gfe:cache-listener ref="cacheListener"/>  
<gfe:regex-interest pattern=".*" receive-values="true" durable="true"/>  
</gfe:client-region>  
[/code]

  * Add durablity settings to gemfire.properties in your classpath

[code lang=text]  
durable-client-id=31  
durable-client-timeout=200  
[/code]

    each gemfire client must have a unique durable-client-id.  The GemFire server will use this unique id to determine which client to queue messages for.
    
    The durable-client-timeout indicates how many seconds the server should hold messsages for a client. If the client does not recconect in this number of seconds the queue and its messages are discarded.
    

## Configuring the Spring Integration Continuous Query client as Durable

  * Enable durability on the CQ Container by adding the durable=&#8221;true&#8221; flag.

[code lang=text]  
<int-gfe:cq-inbound-channel-adapter id="cqInputChannel"  
cq-listener-container="queryListenerContainer"  
query="select * from /Customers" durable="true"/>  
[/code]

  * As before make sure you add a gemfire.properties to your classpath that contains your client id and client timeout values. 

Test the setup by starting all components and publishing some messages. Shutdown the client application and publish some more messages. The client should receive the remaining messages upon reconnect.

## Tuning

It is important to be aware that each client queue will consume memory on the server. Since memory resources are finite in a GemFire node it is important to take into consideration the number of durable clients, the volume of messages you expect to receive and the length of possible disconnect time to ensure you will not run out of memory.

Other tuning options are availble such as message conflation, setting maximum message size, overflow to disk, etc. More details can be found in the [GemFire documentation](http://pubs.vmware.com/vfabric5/index.jsp#events/conflate_server_subscription_queue.html).