---
id: 140
title: Using Docker Machine with Amazon Cloud Formation
date: 2015-11-20T19:27:24+00:00
author: ellinj
layout: post

permalink: /2015/11/20/using-docker-machine-with-amazon-cloud-formation/
geo_public:
  - "0"
draftfeedback_requests:
  - 'a:1:{s:13:"564f1f2ed1985";a:3:{s:3:"key";s:13:"564f1f2ed1985";s:4:"time";s:10:"1448025902";s:7:"user_id";s:6:"269853";}}'
publicize_linkedin_url:
  - 'https://www.linkedin.com/updates?discuss=&scope=20835048&stype=M&topic=6073627541657174016&type=U&a=Zez8'
tags:
  - docker
  - Uncategorized
---
## What is Docker Machine?

Docker Machine is a relatively new addition to the Docker toolbox that allows you to create docker hosts on your own computer, in your data center or in the cloud.

Docker Machine manages the creation of the host as well as automates things like starting, stopping or restarting a host,  upgrading the host and configuring your client to talk to the host.

To create a virtual machine, you use a driver to represent the desired virtual environment. Docker Machine has support for many drivers such as Amazon AWS, Google Compute, Microsoft Azure, Digital Ocean, Virtual Box and many more.

The AWS driver that ships with Docker Machine allows you to create a docker instance of a specific type. It even allows you to specify root volume sizes, instance type and some basic networking options.

Unfortunately after using the driver for a while the limitations of the driver became apparent.  You can&#8217;t create any resources besides a host.  If you need an entry in route53, a customized security group, load balancer or subnet you are on your own. These resources need to be created before or after using docker machine to create your instance. In addition when you are done with the host you must manually remove them.

## What is Cloud Formation

Cloud formation is a tool from Amazon that allows you to create groups of components that represent a cloud stack. This stack can include any Amazon resource including, EC2 instances, Networking Components and conditional tagging.

Cloud Formations are created using a visual tool within the AWS console and can be saved as JSON in an S3 bucket. In addition they can be stored in your source code repository.

When creating a stack all the components are created automatically in a transactional process.  If something fails during the creation process the components you created are all rolled back. In addition when you are done with the stack you can delete it. Deleting a stack removes all the components the stack created on your behalf.

<img class="" src="http://www.ellin.com/blogimages/docker-machine_cloudformation_png_1BFEB8A4.png" alt="" width="692" height="214" /> 

The above example is a cloud formation involving an EC2 instance, an elastic load balancer and a route 53 entry. The components are linked together so that they automatically are connected within the stack.

&nbsp;

## Cloud Formation Driver

I have taken the opportunity to create a driver for Docker Machine that allows you to initiate the creation of a stack using Cloud Formation.

You can interact with this driver in a similar manner that you are used to. Unlike the EC2 driver many of the configuration details are not options directly on the driver. Instead you pass the options that you need as parameters to the Cloud Formation template.

## Putting it Together

Templates can be parameterized using input parameters. These parameters can be entered at the time your stack is created.

<img class="alignnone" src="http://www.ellin.com/blogimages/AWS_CloudFormation_Designer_1BFFE940.png" alt="" /> 

The KeyName parameter is passed into the cloud formation script.  Its value is validated against existing EC2 key pairs.

<img class="alignnone" src="http://www.ellin.com/blogimages/AWS_CloudFormation_Designer_1BFFE9D3.png" alt="" /> 

The Cloud Formation template can also have outputs as a result of the configuration. Outputs can be object properties such as instance id or ip address.

<img class="alignnone" src="http://www.ellin.com/blogimages/AWS_CloudFormation_Designer_1BFFEA3B.png" alt="" width="463" height="211" /> 

In order for the docker machine driver to reference the created instance the formation must return a value of InstanceId.  This value must be the instance-id that docker-machine will manage.

The driver can be instantiated by issuing the following command.

> docker-machine create &#8211;driver amazoncf &#8211;cloudformation-url https://s3.amazonaws.com/cformation-jellin/template1 &#8211;cloudformation-keypairname jeff &#8211;cloudformation-keypath /Users/jellin/.ssh/id_rsa &#8211;cloudformation-use-private-address dockerdemo

The following parameters are required.

  * cloudformation-url &#8211; The S3 url of the cloud formation template.  This file must live in the same region as you will be executing the cloud formation against.
  * cloudformation-keypairname &#8211; This is the name of the keypair to be used.  This will be passed to the KeyName input parameter.  ( This option is required for now but ultimately I will likely remove it as some cloud formations might not require it and it can be passed in the additional parameters section
  * cloudformation-keypath &#8211; They private key path.  The key is required so that docker-machine can access the host and setup docker
  * cloudformation-use-private-address &#8211; use the private address only to communicate with the instance. (default is false)

> &#8211;cloudformation-parameters KeyName1=KeyValue1|KeyName2=KeyValue2

Once the docker machine is created you can interact with it as normal.  You can start the instance, stop the instance, rm the instance etc.

Full details on how to install and run the driver will be coming in a follow up post. In the meantime head over to <a href="https://github.com/jeffellin/machine-cloudformation/tree/vendorize" target="_blank">GitHub</a> to see the source code for the driver.