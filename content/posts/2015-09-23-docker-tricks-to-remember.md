---
id: 110
title: Docker Tricks to Remember
date: 2015-09-23T09:26:05+00:00
author: ellinj
layout: post

permalink: /2015/09/23/docker-tricks-to-remember/
tags:
  - Uncategorized
---
Chances are if you have been working with docker for a while you may have noticed that removing containers does not free up the disk space associated with that container.  When removing the container the -v flag can be used to remove the volumes associated with that container.

[code language=&#8221;bash&#8221;]docker rm -v webapp[/code]

If it&#8217;s too late and you have a lot of orphaned containers you can use the <a href="https://github.com/cpuguy83/docker-volumes" target="_blank">docker-volume</a> script to clean up your machine. https://github.com/cpuguy83/docker-volumes

## Backing up Data in a Container

Backing up a docker volume may seem to be tricky since the data is buried on your filesystem.  But it&#8217;s actually easy to do by mapping a temporary container to your postgres volume and a local backup volume.

[code language=&#8221;bash&#8221;]

#Backup data in a volume  
#remove it no need to keep it around.

$ docker run &#8211;rm &#8211;volumes-from dbdata -v $(pwd):/backup busybox&nbsp;tar cvf /backup/backup.tar /var/lib/postgresql/data

[/code]

## Upgrading a container

Upgrading a container to a newer version can use a similar technique.  Stopping a container does not remove a volume.

[code language=&#8221;bash&#8221;]

$docker stop dbdata

$docker run &#8211;name newdbdata &#8211;volumes-from dbdata postgres:latest

$docker rm dbdata

[/code]

## Accessing a shell in your container.

[code language=&#8221;bash&#8221;]

$docker excec -rm -ti web bash

[/code]