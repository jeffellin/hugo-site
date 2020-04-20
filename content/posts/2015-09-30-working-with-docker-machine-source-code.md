---
id: 127
title: Working with Docker Machine Source Code
date: 2015-09-30T18:01:09+00:00
author: ellinj
layout: post

permalink: /2015/09/30/working-with-docker-machine-source-code/
geo_public:
  - "0"
publicize_linkedin_url:
  - 'https://www.linkedin.com/updates?discuss=&scope=20835048&stype=M&topic=6055048561471602688&type=U&a=Y5ZP'
tags:
  - docker
  - Go
  - Uncategorized
---
Recently I dived into creating a <a href="https://github.com/docker/machine/pull/1905" target="_blank">pull request</a> for docker-machine.  Unfortunately when creating EC2 instances docker-machine did not provide an option for specifying an EBS optimized instance.  EBS Optimized instances provide much better disk i/o performance to an EBS Volume.

Downloading and following the <a href="https://github.com/docker/machine/blob/master/CONTRIBUTING.md" target="_blank">build directions </a>were fairly straightforward.  A docker container is provided with a complete GO dev environment to compile the binary.

<pre class="lang:text decode:true" >git clone git@github.com:docker/machine.git
cd machine
export USE_CONTAINER=true
make

</pre>

However when reading the contribution guide it mentions that integration test cannot be run in a container. Most likely this is due to some of the drivers requiring local access to a virtualization product such as VirtualBox or VMWare fusion.  Probably remote access drivers like DigitalOcean or EC2 would work fine.

Being completely unfamiliar with Go I blindly followed the advice of the guide and did

<pre class="lang:text decode:true" >unset USE_CONTAINER
make
</pre>

boom this ended up leading me down a rabbit hole of figuring out how Go dependencies work.  My first attempt was to follow the various warning messages from the compiler output and use go get to to install missing libraries.  Eventually I got stuck on some dependencies that could not be downloaded or I was getting code errors regarding illegal assignment.

The docker machine library contains Godeps, so I tried installing Godeps and restoring dependencies.  No luck on that front either.

Here is what finally worked for me. I am not 100% sure this is the best way to do things in Go yet, but it worked for me.

&nbsp;

<pre class="lang:text decode:true" >export GOROOT=/usr/local/go
export GOPATH=/tmp/go/work
git clone https://github.com/docker/machine.git /tmp/go/machine
#copy the contents of the cloned repo to the correct package in your $GOPATH
mkdir -p $GOPATH/src/github.com/docker
cp -R /tmp/go/machine $GOPATH/src/github/com/docker
cd $GOPATH/src/github/com/docker/machine
make build

</pre>