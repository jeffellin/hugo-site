+++
draft = true
+++

>This page was converted from my old blog and hasn't been reviewed. If you see an error please let me know in the comments.


In my last post, [IoT with Amazon Kinesis and Spark Streaming](/2017/08/20/iot-with-amazon-kinesis-and-spark-streaming/) I discussed connecting Spark streaming with Amazon IoT and Kinesis.  Today I would like to show how to add Apache Zeppelin into the mix.

<img class="aligncenter size-full wp-image-504" src="/wp-content/uploads/2017/08/kinesis-2.jpg" alt="" width="618" height="297" srcset="/wp-content/uploads/2017/08/kinesis-2.jpg 618w, /wp-content/uploads/2017/08/kinesis-2-300x144.jpg 300w" sizes="(max-width: 618px) 100vw, 618px" /> Apache Zeppelin is a web based tool for running notebooks. It allows Data Scientists easy access to running Big Data tools such as Spark and Hive. It also provides an integration point for using javascript visualization tools such as D3 and Plotly via its Angular interpreter. In addition Zeppelin has some built in visualizations that can be leveraged for quick and dirty dashboards.

Notebooks make it possibly to build interactive visualizations without needing to deploy code onto a big data platform. In order to follow along with this demonstration please make sure you have setup your environment and are able to run the demo from my last post as we will again be using the [Simple Beer Simulator.](https://github.com/awslabs/simplebeerservice) (SBS).

The code for this demo is slightly different than the last example.   Instead of outputting the data to the file system we will load the data into a data frame that can be rendered using Spark Sql.

&nbsp;

<pre class="lang:default decode:true">val unionStreams =ssc.union(kinesisStream)

    val sqlContext = new SQLContext(SparkContext.getOrCreate())

    //Processing each RDD and storing it in temporary table
    unionStreams.foreachRDD ((rdd: RDD[Array[Byte]], time: Time) =&gt; {
     
    val rowRDD = rdd.map(jstr =&gt; new String(jstr))
    val df = sqlContext.read.json(rowRDD)
    df.createOrReplaceTempView("realTimeTable")
    z.run("20170821-222346_757022702")

</pre>

As data is received we will use Zeppelin&#8217;s run command to update the notebook paragraph containing our visualization.

<pre class="lang:default decode:true " title="Sample output of SBS">{"deviceParameter": "Sound", "deviceValue": 109, "deviceId": "SBS03", "dateTime": "2017-08-19 23:57:26"}
{"deviceParameter": "Temperature", "deviceValue": 35, "deviceId": "SBS04", "dateTime": "2017-08-19 23:57:27"}
{"deviceParameter": "Temperature", "deviceValue": 23, "deviceId": "SBS03", "dateTime": "2017-08-19 23:57:28"}
{"deviceParameter": "Humidity", "deviceValue": 86, "deviceId": "SBS01", "dateTime": "2017-08-19 23:57:29"}</pre>

&nbsp;

#### Update the interpreter dependencies.

In order to run our sample application we must add the Amazon client jars to the notebook class path.  This is done via the dependency section in the interpreter settings. Find the spark interperter and at the bottom you will find the Dependencies.

Add : **org.apache.spark:spark-streaming-kinesis-asl_2.11:2.1.0**

<img class="aligncenter wp-image-488 size-large" src="/wp-content/uploads/2017/08/Banners_and_Alerts_and_localhost_8080___interpreter-1024x205.png" alt="" width="1024" height="205" srcset="/wp-content/uploads/2017/08/Banners_and_Alerts_and_localhost_8080___interpreter-1024x205.png 1024w, /wp-content/uploads/2017/08/Banners_and_Alerts_and_localhost_8080___interpreter-300x60.png 300w, /wp-content/uploads/2017/08/Banners_and_Alerts_and_localhost_8080___interpreter-768x154.png 768w" sizes="(max-width: 1024px) 100vw, 1024px" /> 

<h4 style="text-align: left;">
  Run the SBS
</h4>

As before we will post sample data to Kinesis using the SBS

<pre class="lang:default decode:true ">docker run -ti sbs</pre>

#### Start Zeppelin

Today we will be using a integrated docker container that contains both Zeppelin and Spark.

<pre class="lang:default decode:true ">docker run -p 8080:8080 dylanmei/zeppelin   
</pre>

In a real world situation it would be better to use a distributed install of Zeppelin so as to leverage the capacity of a multiple node cluster.  Since we are only dealing with one Kinesis shard we can easily support this use case on a container running on a laptop.

##### Login to Zeppelin

http://localhost:8080

##### Import the notebook

If you wish to use my notebook import it into Zeppelin from the [GitHub](https://github.com/jeffellin/spark-kinesis) repo or copy the relevant sections into new paragraphs.

##### Run the notebook paragraphs.

The first time through I recommend running each paragraph step by step.  This way you can troubleshoot any issues before running the notebook top to bottom. The first paragraph you run may take a bit of time as the spark interperter for Zepplin is lazily started the first time it is needed.

##### Import the Dependencies

<pre class="lang:default decode:true">import com.amazonaws.regions.RegionUtils
import com.amazonaws.services.kinesis.clientlibrary.lib.worker.InitialPositionInStream
import org.apache.spark._
import org.apache.spark.rdd.RDD
import org.apache.spark.sql.types.{StringType, StructField, StructType}
import org.apache.spark.sql.{Row, SQLContext, SaveMode}
import org.apache.spark.storage._
import org.apache.spark.streaming._
import org.apache.spark.streaming.kinesis._
import org.json4s.jackson.JsonMethods.parse
import org.json4s.DefaultFormats
import org.json4s.jackson.JsonMethods.parse
import org.json4s.DefaultFormats
import org.apache.spark.sql.functions._</pre>

##### Set some variables

Make sure to add a valid AWS key and secret here.

<pre class="lang:default decode:true">val awsAccessKeyId = ""
 val awsSecretKey = ""
 val kinesisStreamName = "iot-stream"
 val kinesisEndpointUrl = "kinesis.us-east-1.amazonaws.com"
 val kinesisAppName = "SBSStreamingReader"
 val kinesisCheckpointIntervalSeconds = 1
 val batchIntervalSeconds = 60</pre>

##### Setup the streaming portion

<pre class="lang:default decode:true">val ssc = new StreamingContext(sc, Seconds(batchIntervalSeconds))


// Creata a Kinesis stream
val kinesisStream =  (0 until 1).map { i =&gt;
  KinesisUtils.createStream(ssc,
    kinesisAppName, kinesisStreamName,
    kinesisEndpointUrl, RegionUtils.getRegionMetadata.getRegionByEndpoint(kinesisEndpointUrl).getName(),
    InitialPositionInStream.LATEST, Seconds(kinesisCheckpointIntervalSeconds),
    StorageLevel.MEMORY_AND_DISK_SER_2, awsAccessKeyId, awsSecretKey)
}

val unionStreams =ssc.union(kinesisStream)

val sqlContext = new SQLContext(SparkContext.getOrCreate())

//Processing each RDD and storing it in temporary table
unionStreams.foreachRDD ((rdd: RDD[Array[Byte]], time: Time) =&gt; {
 

val rowRDD = rdd.map(jstr =&gt; new String(jstr))
val df = sqlContext.read.json(rowRDD)
df.createOrReplaceTempView("realTimeTable")
z.run("20170821-222346_757022702")
})</pre>

##### execute

<pre class="lang:default decode:true ">ssc.start()</pre>

##### Visualize

<img class="aligncenter size-large wp-image-495" src="/wp-content/uploads/2017/08/localhost_8080___notebook_2CSYX672R-4-1024x347.png" alt="" width="1024" height="347" srcset="/wp-content/uploads/2017/08/localhost_8080___notebook_2CSYX672R-4-1024x347.png 1024w, /wp-content/uploads/2017/08/localhost_8080___notebook_2CSYX672R-4-300x102.png 300w, /wp-content/uploads/2017/08/localhost_8080___notebook_2CSYX672R-4-768x260.png 768w" sizes="(max-width: 1024px) 100vw, 1024px" /> 

##### Update

Add a z.run() statement to the streaming portion to force the graph to refresh each time a new event set is processed. You can get the paragraphId for the graph by selecting the gear icon and copying the value to the clipboard.

<pre class="lang:default decode:true ">z.run("20170821-222346_757022702")</pre>

#### Conclusion

At the end of the day this illustrates how to use Zeppelin to visualize data as it is being retrieved by Spark streaming. It is a rather contrived example as you most likely would want to use some sort of persistent storage to save the results before they are queried.  With the above setup you can only query the data from the last batch interval. One possible solution is to drop the data from the streaming service into an elastic cache backed by Elastic Search or Redis and then query your chart over the desired time window.

&nbsp;

#### References

[Analyze Realtime Data from Amazon Kinesis Streams Using Zeppelin and Spark Streaming](https://aws.amazon.com/blogs/big-data/analyze-realtime-data-from-amazon-kinesis-streams-using-zeppelin-and-spark-streaming/)

[Querying Amazon Kinesis Streams Directly with SQL and Spark Streaming](https://aws.amazon.com/blogs/big-data/querying-amazon-kinesis-streams-directly-with-sql-and-spark-streaming/)

&nbsp;