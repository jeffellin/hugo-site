+++
title = "Tanzu Application Platform Quick Start Install on AWS"
date = 2022-08-09T13:35:15-04:00
tags = ["kubernetes","Tanzu","TAP","aws","eks"]
featured_image = ""
description = "Tanzu Application Platform Quick Start Install on AWS"
draft = "false"
series = ["Tap Intro"]
+++

Today's post will continue where we left off, discussing the Tanzu Application Platform.  Last time we discussed an overview of the various components of the platform. 

### The following topic will be covered in this article series.
* [What is the Tanzu Application Platform (TAP)](/2022/07/23/tanzu-application-platform/)
* [Creating a Workload Using Application Accelerators](/2022/08/05/tanzu-application-accelerators/)
* Installing the "full" profile on a single cluster in AWS
GitOps for TAP
* The Spring PetClinic Workload with Postgres SQL
* Learning Center
  
Today we will take a look at the one way to easily install the Tanzu Application Platform.


## AWS Quick Start

One of the easiest ways to get started with TAP is the AWS Quick Start template.  It deploys the entire 

The [Quick Start](https://aws.amazon.com/quickstart/architecture/vmware-tanzu-application-platform/) sets up the following:

A High available architecture that spans multiple Availablity Zones.

This includes: 

* A VPC configured with public and private subnets
* Route 53 hosted zone for DNS
* NAT Gateways 
* Bastion Host
* EKS
* TAP
* Elastic Container Registry.

The following video demonstrates the capability.

{{< youtube NF28rFXQk9E >}}

This process installs the **Full** TAP profile.  This means that all components will be installed in a single Kubernetes cluster.   While this is great for a Quick Start,  The next post will show you how to make use of TAP's multi cluster functionality.

References

* [TAP Documentation](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/index.html)


