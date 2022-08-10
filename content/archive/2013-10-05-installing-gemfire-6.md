+++
draft = true
+++

>This page was converted from my old blog and hasn't been reviewed. If you see an error please let me know in the comments.

While it isn&#8217;t the latest and greatest recently I had to install GemFire 6 on my Mac in order to test some development code. Some day I will write a post that explains what GemFire is and what its used for, but for now I will provide the steps to get a simple stand alone cluster up and running.

Installing GemFire 6 is a rather simple process.

From a terminal window ensure that Java is in your path and run the following command

```
java -jar vFabric_GemFire_6649_Installer.jar
```


The installer will prompt you for the destination location. I chose to install it in my local user directory under.

```
/users/jellin/pivotal/gemfire
```


Once you have Gemfire installed you can begin to setup your environment to start up your first cluster.

Underneath the home directory for your cluster you will need

  * shell script for configuring your GemFire environment
  * a directory for each node in the cluster e.g. Server1 and Locator, these directories contain node specific information such as log files and statistics.
  * a directory to store the configuration for the cluster.
  * a properties file to configure GemFire </ul> 

```
CLUSTER_HOME
|--server1
|--locator
|--xml
|--gfconfig.sh
|--gemfire.properties
```

gfenv.sh
    
```
export JAVA_HOME=`/usr/libexec/java_home -v 1.6`
export GEMFIRE=/Users/jellin/pivotal/gemfire/vFabric_GemFire_6649
```

    
gemfire.properties
    
```
log-level=warning
locators=localhost[41111]
mcast-port=0
cache-xml-file=../xml/serverCache.xml
```

    
xml/serverCache.xml
    
```
<cache>
   <region name="Customers" refid="PARTITION">
   </region>
</cache>
```

    
once you have created the shell script you can load by running.
    
```
. ./gfconfig.sh
```

    
### Starting your Cluster
    
You can then start the locator
    
```
gemfire start-locator -port=41111 -dir=locator -properties=../gemfire.properties -Xmx50m -Xms50m
```

    
followed by the cacheserver
    
```
cacheserver start locators=localhost[41111] -server-port=41116 -J-DgemfirePropertyFile=../gemfire.properties -dir=server1 -J-Xms50m -J-Xmx50m
```

    
### Stopping your Cluster
    
First Stop the CacheServer
    
```
cacheserver stop -dir=server1
```

    
Second Stop the locator
    
```
gemfire stop-locator -dir=locator -port=41111
```
    
A sample of a simple gemfire setup can be found on [GitHub](https://github.com/ellinj/gemfire/tree/master/gemfire6/simpleserver)