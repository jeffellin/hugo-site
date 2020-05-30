---
id: 462
title: IoT with Amazon Kinesis and Spark Streaming
date: 2017-08-20T13:18:51+00:00
author: ellinj
layout: post

permalink: /2017/08/20/iot-with-amazon-kinesis-and-spark-streaming/
tags:
  - aws
  - IoT
  - spark
---


>This page was converted from my old blog and hasn't been reviewed. If you see an error please let me know in the comments.


The Internet of Things (IoT) is increasingly becoming an important topic in the world of application development. This is because these devices are constantly sending a high velocity of data that needs to be processed and analyzed.  Amazon Kinesis and Amazon IoT are a perfect pair for receiving and analyzing this data. Spark Streaming can be used to process the data as it arrives.

Today we will be looking at Amazon IoT, Kinesis and Spark and build a streaming pipeline.

Amazon provides an IOT data generator called [Simple Beer Simulator](https://github.com/awslabs/sbs-iot-data-generator). (SBS) The simulator generates random JSON data that represents what might be coming from a IoT device hooked up to a beer dispenser. Data such as temperature, humidity, and flow rate are returned via the simulator.

<pre class="lang:default decode:true ">{"deviceParameter": "Sound", "deviceValue": 109, "deviceId": "SBS03", "dateTime": "2017-08-19 23:57:26"}
{"deviceParameter": "Temperature", "deviceValue": 35, "deviceId": "SBS04", "dateTime": "2017-08-19 23:57:27"}
{"deviceParameter": "Temperature", "deviceValue": 23, "deviceId": "SBS03", "dateTime": "2017-08-19 23:57:28"}
{"deviceParameter": "Humidity", "deviceValue": 86, "deviceId": "SBS01", "dateTime": "2017-08-19 23:57:29"}</pre>

The sample data above will be streamed into Amazon IOT and passed via rule to Kinesis.

#### Creating the Kinesis Stream

Log into the AWS console and click on Kinesis and create a Kinesis stream called **iot-stream.**

<img class="aligncenter size-full wp-image-463" src="/wp-content/uploads/2017/08/Amazon_Kinesis_Streams_Management_Console.png" alt="" width="1560" height="1178" srcset="/wp-content/uploads/2017/08/Amazon_Kinesis_Streams_Management_Console.png 1560w, /wp-content/uploads/2017/08/Amazon_Kinesis_Streams_Management_Console-300x227.png 300w, /wp-content/uploads/2017/08/Amazon_Kinesis_Streams_Management_Console-768x580.png 768w, /wp-content/uploads/2017/08/Amazon_Kinesis_Streams_Management_Console-1024x773.png 1024w" sizes="(max-width: 1560px) 100vw, 1560px" /> 

One shard is plenty for this example as we won&#8217;t be doing any stressing the application with a large volume of devices and data.  In a real world scenario increasing the number of shards in a Kinesis streams will improve application scalability.

#### Create an IoT Rule

Log into the AWS console and head over to IOT.  Click on create a new rule.

## IoT Rule {.tablepress-table-name.tablepress-table-name-id-1}

<table id="tablepress-1" class="tablepress tablepress-id-1">
  <tr class="row-1 odd">
    <td class="column-1">
      Name
    </td>
    
    <td class="column-2">
      /sbs/devicedata/#
    </td>
  </tr>
  
  <tr class="row-2 even">
    <td class="column-1">
      Attribute
    </td>
    
    <td class="column-2">
      *
    </td>
  </tr>
  
  <tr class="row-3 odd">
    <td class="column-1">
      Topic Filter
    </td>
    
    <td class="column-2">
      /sbs/devicedata/#
    </td>
  </tr>
  
  <tr class="row-4 even">
    <td class="column-1">
    </td>
    
    <td class="column-2">
    </td>
  </tr>
  
  <tr class="row-5 odd">
    <td class="column-1">
    </td>
    
    <td class="column-2">
    </td>
  </tr>
</table>

<!-- #tablepress-1 from cache -->

#### Create an IoT Action

<img class="aligncenter wp-image-468 size-medium" src="/wp-content/uploads/2017/08/AWS_IoT-300x246.png" alt="" width="300" height="246" srcset="/wp-content/uploads/2017/08/AWS_IoT-300x246.png 300w, /wp-content/uploads/2017/08/AWS_IoT-768x629.png 768w, /wp-content/uploads/2017/08/AWS_IoT.png 1014w" sizes="(max-width: 300px) 100vw, 300px" /> 

Select Kinesis as a destination for your messages.

On the next screen you will need to create a rule to publish to Kinesis.

<img class="aligncenter size-medium wp-image-469" src="/wp-content/uploads/2017/08/AWS_IoT-1-300x214.png" alt="" width="300" height="214" srcset="/wp-content/uploads/2017/08/AWS_IoT-1-300x214.png 300w, /wp-content/uploads/2017/08/AWS_IoT-1-768x549.png 768w, /wp-content/uploads/2017/08/AWS_IoT-1-1024x731.png 1024w, /wp-content/uploads/2017/08/AWS_IoT-1.png 1330w" sizes="(max-width: 300px) 100vw, 300px" /> 

Click Create Role to automatically create a role with the correct policies. Click through to complete creating the rule. If you are using an existing role you may want to click the update role button.  This will add the correct Kinesis stream to the role policy.

### Create IAM User

In order for the SBS to be able to publish messages to Amazon IoT it uses boto3 and as such requires  permission to the appropriate resources.

Create a user with AWSIoTFullAccess and generate an access key and secret.

In the sbs directory there is a credentials file that should be updated with your access key and secret.

<pre class="lang:default decode:true">[default]
aws_access_key_id = &lt;your access key&gt;
aws_secret_access_key = &lt;your secret access key&gt;
</pre>

build the docker container for the SBS

<pre class="lang:default decode:true">docker build -t sbs .</pre>

Run the Docker container

<pre class="lang:default decode:true ">docker run -ti sbs</pre>

At this point you should now have data being sent to Kinesis via Amazon IOT

#### Spark Streaming

The Scala app I created reads data off of Kinesis and simply saves the result to a CSV file.

You will need to create a user that has access to read off of the Kinesis stream.  This credential would be different than the one used for the SBS.  Here I am just using my key which has admin access to everything in the account. In a real world scenario you should restrict this key to only being able to read the iot-stream.

<pre class="lang:default decode:true">val awsAccessKeyId = "your access key"
  val awsSecretKey = "your secret"
</pre>

Define a case class to use as a holder for the JSON data we receive from Kinesis.

<pre class="lang:scala decode:true ">case class Beer(deviceParameter:String, deviceValue:Int, deviceId:String,dateTime:String);
</pre>

Connect to the Kinesis stream.

<pre class="lang:default decode:true ">// Creata a Kinesis stream
    val kinesisStream = KinesisUtils.createStream(ssc,
      kinesisAppName, kinesisStreamName,
      kinesisEndpointUrl, RegionUtils.getRegionMetadata.getRegionByEndpoint(kinesisEndpointUrl).getName(),
      InitialPositionInStream.LATEST, Seconds(kinesisCheckpointIntervalSeconds),
      StorageLevel.MEMORY_AND_DISK_SER_2, awsAccessKeyId, awsSecretKey)
</pre>

At each batch interval we will receive multiple RDDs from the IoT DStream. We will iterate over these parsing the JSON into our case class.  Once we have a RDD with our Beer class we can write the data out to disk.

<pre class="lang:default decode:true">iot.foreachRDD { rdd =&gt;

      val sqlContext = new SQLContext(SparkContext.getOrCreate())

      import sqlContext.implicits._
      
      val jobs = rdd.map(jstr =&gt; {

        implicit val formats = DefaultFormats

        val parsedJson = parse(jstr)
        val j = parsedJson.extract[Beer]
        j
      })

      //output the rdd to csv
      jobs.toDF()
        .write.mode(SaveMode.Append).csv("/tmp/data/csv")

    }</pre>

The complete code listing is below.

<pre class="lang:sass decode:true ">package example

import com.amazonaws.regions.RegionUtils
import com.amazonaws.services.kinesis.clientlibrary.lib.worker.InitialPositionInStream
import org.apache.spark._
import org.apache.spark.sql.{SQLContext, SaveMode}
import org.apache.spark.storage._
import org.apache.spark.streaming._
import org.apache.spark.streaming.kinesis._
import org.json4s.jackson.JsonMethods.parse;
import org.json4s.{DefaultFormats}
/**
  * Created by jellin on 8/18/17.
  */
object SBSStreamingReader {

  def main(args: Array[String]) {

    // Get or create a streaming context.
    val ssc = StreamingContext.getActiveOrCreate(creatingFunc)

    // This starts the streaming context in the background.
    ssc.start()
    ssc.awaitTermination;

  }
  val awsAccessKeyId = "your access key" 
  val awsSecretKey = "your secret"
  val kinesisStreamName = "sbs-data"
  val kinesisEndpointUrl = "kinesis.us-east-1.amazonaws.com"
  val kinesisAppName = "SBSStreamingReader"
  val kinesisCheckpointIntervalSeconds = 1
  val batchIntervalSeconds = 1


  case class Beer(deviceParameter:String, deviceValue:Int, deviceId:String,dateTime:String);


  def creatingFunc(): StreamingContext = {

    val sparkConf = new SparkConf().setAppName("SBSStreamingReader")

    // Create a StreamingContext
    val ssc = new StreamingContext(sparkConf, Seconds(batchIntervalSeconds))


    // Creata a Kinesis stream
    val kinesisStream = KinesisUtils.createStream(ssc,
      kinesisAppName, kinesisStreamName,
      kinesisEndpointUrl, RegionUtils.getRegionMetadata.getRegionByEndpoint(kinesisEndpointUrl).getName(),
      InitialPositionInStream.LATEST, Seconds(kinesisCheckpointIntervalSeconds),
      StorageLevel.MEMORY_AND_DISK_SER_2, awsAccessKeyId, awsSecretKey)

    // Convert the byte array to a string
    val iot = kinesisStream.map { byteArray =&gt; new String(byteArray)}


    // Create output csv file at every batch interval
    iot.foreachRDD { rdd =&gt;

      val sqlContext = new SQLContext(SparkContext.getOrCreate())

      import sqlContext.implicits._

      val jobs = rdd.map(jstr =&gt; {

        implicit val formats = DefaultFormats

        val parsedJson = parse(jstr)
        val j = parsedJson.extract[Beer]
        j
      })

      //output the rdd to csv
      jobs.toDF()
        .write.mode(SaveMode.Append).csv("/tmp/data/csv")

    }

    println("Creating function called to create new StreamingContext")
    ssc
  }
}
</pre>

Compile the jar using sbt

<pre class="lang:default decode:true">sbt assembly
</pre>

Copy the jar to the container

<pre class="lang:default decode:true">cp target/scala-2.11/MyProject-assembly-0.1.jar &lt;project_home&gt;/docker-spark/data</pre>

#### Running Spark

In order to facilitate running spark we again turn to Docker.  My Docker image is based on the work by  [Getty Images](https://github.com/gettyimages/docker-sparkhttps://github.com/gettyimages/docker-spark).  I did have to make some minor adjustments to their spark image to upgrade to Hadoop 2.8 as well as remove an AWS library from the Hadoop class path.

<pre class="lang:default mark:2,11 decode:true "># HADOOP
ENV HADOOP_VERSION 2.8.0
ENV HADOOP_HOME /usr/hadoop-$HADOOP_VERSION
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV PATH $PATH:$HADOOP_HOME/bin
RUN curl -sL --retry 3 \
  "http://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz" \
  | gunzip \
  | tar -x -C /usr/ \
 && rm -rf $HADOOP_HOME/share/doc \
 && rm -rf $HADOOP_HOME/share/hadoop/tools/lib/aws* \
 && chown -R root:root $HADOOP_HOME</pre>

Build the container

<pre class="lang:default decode:true">docker build -t spark:kinesis .</pre>

Run both the worker and the slave with docker compose

<pre class="lang:default decode:true">docker-compose up -d</pre>

exec into the container to run spark-submit

<pre class="lang:default decode:true">docker exec -ti dockerspark_master_1 bash
spark-submit --class example.SBSStreamingReader  --master local[8] /tmp/data/MyProject-assembly-0.1.jar</pre>

Let the spark job run for a few minutes. Eventually you should see some csv files in the **<project_root>/spark/data/data/csv** directory

<img class="aligncenter size-medium wp-image-471" src="/wp-content/uploads/2017/08/docker-spark-300x214.png" alt="" width="300" height="214" srcset="/wp-content/uploads/2017/08/docker-spark-300x214.png 300w, /wp-content/uploads/2017/08/docker-spark-768x547.png 768w, /wp-content/uploads/2017/08/docker-spark-1024x729.png 1024w, /wp-content/uploads/2017/08/docker-spark.png 1056w" sizes="(max-width: 300px) 100vw, 300px" /> 

The complete code for this post can be found on [GitHub](https://github.com/jeffellin/spark-kinesis)

In reality this entire exercise could have been done with Kinesis firehose.  Firehose would output the data to s3 directly without using Spark.  However, I did want to illustrate the use of Spark with Kinesis as in future posts I would like to show you how to do something interesting with your IoT data.