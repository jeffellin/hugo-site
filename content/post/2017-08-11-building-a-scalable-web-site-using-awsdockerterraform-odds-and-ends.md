---
id: 429
title: 'Building a scalable web site using AWS/Docker/Terraform: odds and ends'
date: 2017-08-11T13:30:42+00:00
author: ellinj
layout: post
series: scalable-website

permalink: /2017/08/11/building-a-scalable-web-site-using-awsdockerterraform-odds-and-ends/
tags:
  - aws
  - docker
---

In this final post I would like to cover some of the odds and ends we didn&#8217;t cover in previous posts.  There are still some additional tasks you can complete to improve availability, elasticity and security.

&nbsp;

<img class="aligncenter size-full wp-image-450" src="/wp-content/uploads/2017/08/secure.jpg" alt="" width="841" height="952" srcset="/wp-content/uploads/2017/08/secure.jpg 841w, /wp-content/uploads/2017/08/secure-265x300.jpg 265w, /wp-content/uploads/2017/08/secure-768x869.jpg 768w" sizes="(max-width: 841px) 100vw, 841px" /> 

#### Redundant NAT Gateways

The NAT Gateway Service that Amazon provides is highly available within the availability zone  / subnet that it is deployed within, however if that AZ goes down you will loose your outbound internet.  If your application requires continuous internet access in the face of an availability zone failure it is best to deploy a second NAT Gateway in a subnet in an alternate availability zone.

#### Rewrite URLs without a redirect.

Currently we are using a redirect for traffic to the CDN.  This means clients still need to hit the origin server before they are redirected to the CDN.  This is an unnecessary roundtrip.

We can alleviate this by utilizing one of many CDN plugins for WordPress.  These plugins will generate the proper URLs directly without needing the additional roundtrip.  Also many WordPress themes can be easily modified where they import CSS to alter the URL of the static content.

#### Improving database Access.

If you have a very busy site it may make sense to lessen the load on your RDS.  Read replicas can be made in multiple availability zones.  They decrease the number of read operations on your database.

Unfortunately WordPress does not support read replicas. There are a couple of ways to deal with this and still improve the efficiency of your reads.

  * There are a handful of split db plugins available for WordPress that will allow you to use different connections for reads versus writes.
  * Use Amazon Aurora rather than plain RDS. Aurora provides much better optimizations for reads.
  * Introduce AWS Elasticache.  There are several plugins that allow you a read through cache setup.

#### Bastion

Currently all of our web servers are accessible via SSH on port 22.  This isn&#8217;t the most ideal setup.  The Security Groups for the web servers could be configured to only allow SSH access from your office.  A better approach is to use a Bastion.  This will allow you to move your web server tier into a private subnet.  All access via HTTP/HTTPs will be done via the ELB placed in the public subnet. In order to ssh into your web tier you must first access your hardened Bastion server that allows access on port 22.

#### Network ACLs

A good approach to AWS security is applying a multi level approach.  Security Groups as talked about so far are great at preventing ingress however they are only one line of defense.  A user could forget to apply the correct security group or make a change to the group.  Network ACLs are stateless rules that can be applied at the subnet level. This will provide an additional layer of security in case someone makes a mistake with a configuration.

**SSL**

SSL or Secure Socket Layer is a protocol commonly used to encrypt HTTP traffic.  Amazon ELB&#8217;s support SSL/TLS encryption termination.  By decrypting traffic on the Load Balancer you simplify your configuration in that all SSL certificate maintenance is done in one spot.  You need not distribute the tickets to your ever changing fleet of web nodes.

#### Cleaning up

<pre class="lang:default decode:true">terraform destroy</pre>

Terraform allows you to delete your resources as easily as you created them.  The destroy command will remove everything we have created over the last few posts.  Although most resources we created are covered under the AWS free tier. ELBs and NAT Gateways are not. So be sure and clean up after yourself if you wish to reduce costs.