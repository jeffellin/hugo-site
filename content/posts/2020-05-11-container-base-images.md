+++
title =  "Choosing a Base Image"
date = 2020-05-10T13:35:15-04:00
tags = ["kubernetes"]
featured_image = ""
description = "Containers, along with orchestration tools such as Kubernetes, are all the rage.  Choosing the base image to build your organization's containers introduces a new challenge. The choice of the base container can affect many things, including your security posture and the performance of your application."
draft = "false"
+++


# Choosing a Base Image

Containers, along with orchestration tools such as Kubernetes, are all the rage.  Choosing the base image to build your organization's containers introduces a new challenge. The choice of the base container can affect many things, including your security posture and the performance of your application.

## What is a base image?

A base image is a foundation for which your applications run on.  The file system for a Docker container is based.  These layers are typically a stack of software starting with an o/s image and adding dependencies on top such as Java, an application server, and finally your app. By ordering the layers appropriately, the topmost layer can be replaced without rebuilding the entire image.

Ideally, you would want to have a foundation that matches the size of your app.  You don't want to have a base image that contains more utility than is needed to run your application. You also don't want to have one that is too small to run your application.  

There are quite many choices of base images out there, and the choice while not permanent becomes more challenging to change down the road.

This post will discuss the various options available and provide some guidance for making a decision.

## Container Provenance

An important factor in choosing the base image is the security posture that they provide. Containers provide new security challenges.  Even though they run independently, a compromised container could threaten the host itself or other containers that run on the same host.

It is essential to ensure that the image comes from a trusted source. If the source is untrusted, you can't be sure what software has been preloaded onto the image.  At the very least, you want to review the source for the image to verify that there is no malware present within the image. Tools such as [Clair](https://github.com/quay/clair) can be used to scan the image for known vulnerabilities. Essential questions such as who is maintaining this image, are they trusted must be answered.   How often are updates applied? Is support available?

Many third-party images available on public repositories have no governance on how they are built and what base image was used. If the provenance of the image can not be assured, you may want to create your own container instead of using what is available from public sources. Many images on Dockerhub are "official," and third parties contribute many more.  Official images often provide drop-in solutions for common programming languages and data sources. They also can be used as a way to exemplify Docker best practices.  Also, Docker will ensure that updates are applied in a timely manner
 
## Image footprint

Consider image size. Ideally, you want to use minimal images. Not only do smaller images start faster, but they are also faster to transfer from the registry to the container host. Smaller size reduces the operational overhead of dynamically scaling your system in response to demand. Also, a smaller footprint reduces the attack surface of the container by excluding unnecessary software. 

In a traditional server deployment, large Linux distributions are used, such as Redhat, Centos or Ubuntu.  Not only do these large distributions have a large disk footprint they also include a ton of pre-installed libraries and programs. Rather than being designed for a single application, they are meant to run a wide variety of software simultaneously. Much of these dependencies are not required for the application deployed on them to function.  These extras can often increase the surface area for bad actors to attack.  All these extra utilities must be patched and maintained.  Therefore when developing a container-based application, it is advisable to have the smallest possible base image as possible.  A Small image reduces the number of patches that need to be deployed; it also reduces the footprint of the image itself, so fewer resources are wasted to deploy them.


## Choices

Three popular choices are outlined below.

### Alpine

One of the most often cited container base images is Alpine Linux.  This distribution is a tiny version of Linux. It can be as small as 3mb on disk. It also has a built-in package repository that allows additional tools to be installed. In many cases, Alpine is an ideal choice due to its ecosystem of available packages. Applications that don't require a lot to run are well suited for Apline.  Spring Boot application utilizing OpenJDK is one such example.

One drawback of Alpine is that it uses  `musl libc` instead of the more popular `glibc`. This choice of libc means that if you need a package not available via the Alpine package manager, you must build it yourself.  Binaries built with glibc are not compatible with Linux's based on musl.

Another drawback is that older package libraries often disappear from the Alpine distribution library.  Although the package manager supports version pinning, the lack of availability of old packages effectively means it may be impossible to rebuild containers from scratch in a repeatable manner. 
 
### Ubuntu Minimal

Ubuntu minimal is a small version of the popular Debian based Linux. The base image is 29mb in size. Since it's based on Ubuntu, all packages you can typically obtain via `apt` are available.

Many of the public Docker containers use this o/s as their base container. 

In addition, support is available via Canonical.

### Redhat UBI

Redhat recently released the Redhat Universal Base Image (UBI). At 72mb, this is one of the larger base images available.  The UBI is meant to be a base layer for use in containerized applications.  Unlike Redhat itself, this container is freely redistributable and is maintained and updated frequently by Redhat.  

One drawback to UBI is that available packages are limited to what is curated by Redhat for UBI.  In order to access non-UBI packages, a subscription is required, and you must run the container on a Redhat host O/S such as RHEL or Openshift.


## Conclustion

Which base image to choose is usually based on the specific scenario. 

If you are a RedHat shop and are running on a system based on RHEL, such as OpenShift, UBI would be an ideal choice. If you are not deploying to RHEL or you plan to distribute your containers to other parties, it is not ideal to use UBI.  You may run into a situation where the UBI repository packages are not sufficient for your needs.

If you o/s needs are minimal and you can do with a relatively pared-down O/S Alpine would be a good choice.

Ubuntu Minimal provides a balance between these two. In addition, it is well supported in the open-source community. Many open-source containers base their images on this O/S.

## Learn more.


[Alpine and Version Pinning](https://medium.com/@stschindler/the-problem-with-docker-and-alpines-package-pinning-18346593e891)

[Redhat Universal Base Images](https://developers.redhat.com/products/rhel/ubi/#assembly-field-sections-18555)

[UBI Faq](https://developers.redhat.com/articles/ubi-faq/)



