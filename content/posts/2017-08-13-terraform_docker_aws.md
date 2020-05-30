---
id: 454
title: Building a scalable web site using AWS/Docker/Terraform
date: 2017-08-13T16:27:28+00:00
author: ellinj
layout: post

permalink: /2017/08/13/terraform_docker_aws/
tags:
  - aws
  - docker
---

>This page was converted from my old blog and hasn't been reviewed. If you see an error please let me know in the comments.

In the past I have written posts about using infrastructure as code to deploy your web applications in a repeatable and controllable fashion using the concept of infrastructure as code. I will walk you through step by step in using Terraform to create your highly redundant and scalable website.

I will focus on techniques that illustrate AWS best practices and the use of Terraform. I will not focus on optimizing WordPress itself.  There are numerous plugins and hacks that you can do to WordPress to improve things even further but that is beyond the scope of this guide.

I have broken the article down into 5 parts.

  * [Setting up a VPC](/2017/08/10/building-a-scalabale-web-site-using-awsdockerterraform/)  
    In this part we will setup the basic amazon infrastructure including VPCs, Subnets, and NAT Gateways.
  * [Adding WordPress and RDS](/2017/08/11/building-a-scalable-web-site-using-awsdockerterraform-adding-rds-and-wordpress/)  
    In this part we will add our database and web tier
  * [Adding Redundancy  
    I](/2017/08/12/building-a-scalable-web-site-using-awsdockerterraform-adding-redundancy/)n this part we will work on improving the redundancy of our site.
  * [Adding Elasticity](/2017/08/13/building-a-scalable-web-site-using-awsdockerterraform-adding-elasticity/)  
    [I](/2017/08/12/building-a-scalable-web-site-using-awsdockerterraform-adding-redundancy/)n this part we will work on improving the elasticity of our site.
  * [Odds and Ends](/2017/08/11/building-a-scalable-web-site-using-awsdockerterraform-odds-and-ends/)  
    Miscellaneous odds and ends that didn&#8217;t fit anywhere else.

The below picture represents the complete architecture we will be implementing using Terraform.

<img class="aligncenter size-full wp-image-450" src="/wp-content/uploads/2017/08/secure.jpg" alt="" width="841" height="952" srcset="/wp-content/uploads/2017/08/secure.jpg 841w, /wp-content/uploads/2017/08/secure-265x300.jpg 265w, /wp-content/uploads/2017/08/secure-768x869.jpg 768w" sizes="(max-width: 841px) 100vw, 841px" /> 

In order to implement this in your own AWS account you will need to create an Administrative user with a setup of IAM keys.  You can place the keys directly in the aws.tpl file or reference a configuration in the ~/.aws directory.  See the the Terraform [AWS Provider](https://www.terraform.io/docs/providers/aws/) doc for details.

Terraform allows you to build your entire infrastructure using a code you can check into your source code repository.  For the most part everything I am going to show you can be accomplished using the free tier.  The notable exception to this is the NAT Gateways.  NAT Gateways are not included on the free tier and can run upwards of $30/month. If you are price sensitive you may wish to replace the NAT gateway in our examples with a t2.micro instance running the Amazon NAT AMI.

Reference:

#### [Modern Software Development: Infrastructure as Code](/2016/03/04/modern-software-development-infrastructure-as-code/)

&nbsp;