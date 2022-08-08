---
id: 164
title: 'Modern Software Development: Infrastructure as Code'
date: 2016-03-04T08:54:01+00:00
author: ellinj
layout: post

permalink: /2016/03/04/modern-software-development-infrastructure-as-code/
geo_public:
  - "0"
tags:
  - docker
---

>This page was converted from my old blog and hasn't been reviewed. If you see an error please let me know in the comments.

<h1 style="text-align:center;">
  Modern Software Development
</h1>

<h1 style="text-align:center;">
  Infrastructure as Code
</h1>

## Test Driven Development and Continuous Integration

In the last few years the methodologies for developing software have evolved as software development has become more complex. We have seen new methodologies evolve such as test driven development (TDD) and continuous integration (CI) become the norm.

## Test Driven Development

Test Driven Development is a software development paradigm born out of agile software principles. The Developer first writes an automated test case that proves that a small piece of software functionality works as it should. Initially this test case should fail. The developer then produces a minimal amount of code for the test to pass. If future edge cases are required, the tests are updated and the code refactored until the tests pass again. This allows the developer to make changes to the code while ensuring the code still functions.

One of the guiding principles of Agile software development is relentless refactoring and simplification of code. In the past, refactoring code was a loathed task for the software developer. They feared that they may break something unexpectedly. Having test cases that pass provide a reasonable sanity check that things are still working as they should.

In addition, TDD produces code which is generally simpler because the developer is focused on just what’s important. The developer can also easily implement negative tests that prove the software behaves correctly when the unexpected happens. The net result is that quality improves.

## Continuous Integration

Continuous integration is another tenet of modern software design. It builds upon the idea of TDD. CI tools such as Jenkins and TeamCity provide instant feedback to a developer after they commit their code. A good CI system will run all available automated tests, and will perform any static analysis checking that the team wants to enforce. A CI system will consider a check-in as a failure if not all tests pass. This helps to prevent the introduction of bad code into a release stream and can provide a starting point for a code review process.

When TDD and CI software development methodologies came into practice, many developers viewed them as time wasters. Many were convinced that TDD and CI added additional work and overhead and created an obstacle to completing coding tasks.

Studies have proven that TDD has made developers more productive. With TDD, developers write better quality code and spend less time chasing bugs. TDD is particularly helpful in preventing unexpected bugs that creep into the system when coding other indirect parts of the same system.

Today, the benefits of TDD have become clear. TDD is now considered by most software development professionals as a required component of good software development practice.

TDD continues to evolve with new frameworks. Adding the ability to test different types of code. We now have Behavior Driven Development which focuses on tests that describe behavior. Mocking frameworks allow for testing of codes in isolation.

## Infrastructure as Code

Modern software applications have become much more complex, In many cases, applications have many different tiers such as database, web, service, messaging, etc. The popularity of micro services has further multiplied the number of pieces within a production solution.

The idea of Infrastructure as Code attempts to tackle this problem.

Consider a typical software development scenario where the developer of a component must perform a basic level of testing before they can call their assignment complete. This testing will usually involve setting up a local development environment. In order to do a complete test it may require installation of a database, a messaging system, and/or any number of web components. When it’s time for the QA team to test the software, the whole process test setup process must be repeated. When the code goes to production, the process that the QA team and the developer setup must again be repeated exactly in order to guarantee the software works as expected.

Successful deployment requires all moving parts of the system to be deployed as built and tested. Software must be installed properly; correct versions of java, operating systems, libraries etc must be installed precisely as specified. If there is a deviation from the tested setup &#8211; from software, to third party libraries, to operating system &#8211; the software may not work as intended.

If the QA person is lucky, the developer has adequately documented the software’s requirements, such as software dependencies, order of installation, and changes made from standard configuration files. If not properly documented, well….good luck.

Infrastructure as code means that the steps required to build an environment are enumerated in a file that can be run in a repeatable fashion and can be stored and versioned in a source control repository like any other piece of code.

There are a number of tools that can make this process easier. Ansible, Puppet, Chef, Packer, etc.

Packer is a tool that allows creation of machine and container images for multiple platforms from a single configuration file. Consider the following Packer Script.

    {
        "type": "digitalocean",
        "api_token": "{{user `do_api_token`}}",
        "image": "ubuntu-14-04-x64",
        "region": "nyc3",
        "size": "512mb"
     }
    

This script creates an amazon AMI called packer-example with the redis server pre-installed. Creating an AMI programmatically in this case is not any more difficult than booting a machine and manually running the correct commands but it ensures that it is done correctly every time. If the development team decides they wish to support Digital Ocean an additional builder is added.

<!-- HTML generated using hilite.me -->

    {
        "type": "digitalocean",
        "api_token": "{{user `do_api_token`}}",
        "image": "ubuntu-14-04-x64",
        "region": "nyc3",
        "size": "512mb"
     }
    

Packer provides out of the box support for many popular cloud providers such as Amazon, Digital Ocean, Google Compute, OpenStack, Virtualbox, VMWare and many more.

Packer can be combined with other technologies such as containers or automation such as Ansible.

Ansible defines “plays.” Plays provide all the steps needed to install software on a machine in a repeatable fashion. Each Play is an idempotent operation and can be run repeatedly on the same machine. Ansible ensures that the machine is in the desired state.

<!-- HTML generated using hilite.me -->

    - hosts: server
    sudo: yes
    sudo_user: root
    
    tasks:
    
    - name: install redis
    apt: name=redis-server state=present update_cache=yes
    
    - name: Ensure redis is running
    service: name=redis state=started
    

A local install of a virtualization environment such as VirtualBox will provide developers a clean slate to run on. With these tools each developer will have an environment of their own and if changes are required they can be documented within the required script.

## Containers

Container deployments provide an additional layer of abstraction of an individual service. It helps eliminate the “compatibility matrix from hell.” What version of Java is required, which python libraries, etc.

One common misconception of containers: people sometimes describe and dismiss Docker containers as virtualization within virtualization or “doubly virtualized,” the implication being that performance suffers. This doesn’t actually mean what most people think it means. Traditional virtualization uses a hypervisor to carve out a slice of available hardware. On top of that slice, a full operating system is run. Containers assign resources to protected areas of an existing operating system. Two containers on the same host are shielded from each other by kernel name spacing but the resources running in that container have the same access to the resources on the host. Issuing the top command on a Docker host will reveal all the processes on the machine including those running inside a container.

If a container is not running an application, it does not consume any resources. When launching a container, it will start almost instantaneously as the entire operating system is not loaded. When shutting down a container, the process running inside the container is simply terminated. In contrast, a virtual machine will consume resources whenever it is running, even if it isn’t doing anything. It is conceivable to share a single docker host across multiple applications thus getting better utilization of virtual hardware.

Due to the design of containers, they each can have their own requirements, Java Version, Libraries, etc. without worrying about dependency clash. The developer can specify which versions they support and don’t have to worry about end users installing the wrong dependencies.

Containers are as easy to construct as writing a script. Consider the following Dockerfile that runs a drop wizard micro service.

<pre class="lang:default decode:true " >FROM java:8-jre
MAINTAINER jeff@ellin.com
WORKDIR /work
VOLUME /work
#This is the drop wizard jar.&lt;/span&gt;
ADD server.jar /work/
ADD app-settings.yml /work/

CMD ["java", "-jar" "server.jar" ,"server", "app-settings.yml"]</pre>

This file defines a container image that utilizes a specific version of Java. When the container is built, the commands in the Dockerfile are executed and cached. When running the container only, the CMD line is run resulting in near instantaneous startup. The container can be run from the image using the command:

> docker run -d -P dropwizard-container

Containers which exist in the docker registry can be used directly. If you need elasticsearch or postgres just run the appropriate container. If you have additional requirements you can extend an existing container. The above dropwizard container extends the official java 8 container.

> docker run -d -P elasticsearch:2.1.0

Containers can be shared within an organization and externally using a container repository. Best practice would dictate automatically publishing release candidates to QA into a container repository from your continuous integration environment. Consumers of the application can get the latest version by issuing a pull command from the repository.

Docker scripting can be combined easily with Ansible plays or similar technology to automatically build out an environment. Updating versions of containers is as simple as “pulling” the correct version from the repository.</code>  
Infrastructure

Up until this point, I have only talked about creating software stacks on existing hardware. There are many instances where we need to automate the creation of the hardware itself. Spinning up a new environment for integration testing, Quality Assurance, Field Engineering, etc. can be “coded” as well.

Cloud formation is a tool for use with Amazon EC2 to script the creation of “stacks.” A stack can contain any number of Amazon resources such as instances, load balancers, subnets, security groups, even entire VPCs.

The following Cloudformation template creates an Amazon instance, the installs docker and a few containers.

<!-- HTML generated using hilite.me -->

    {
       "AWSTemplateFormatVersion":"2010-09-09",
       "Resources":{
          "Instance":{
             "Type":"AWS::EC2::Instance",
             "Properties":{
                "ImageId":"ami-5f709f34",
                "KeyName":"FE-CI",
                "UserData":{
                   "Fn::Base64":{
                      "Fn::Join":[
                         "",
                [
                "#!/bin/bash -xe\n",
                "apt-get -y update\n",
                "apt-get -y install unattended-upgrades\n",
                "curl 'https://bootstrap.pypa.io/get-pip.py' -o 'get pip.py'\n",
                "python get-pip.py\n",
                "pip install awscli\n",
                "apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net  …\n",
                "echo 'deb https://apt.dockerproject.org/repo ubuntu-trusty …\n",
                "apt-get -y update\n",
                "apt-get -y install docker-engine\n",
                "docker run -d -p 5432:5432 --name db --restart=always …\n",
                "docker run -d -p 80:8080 -p 8081:8081 --restart=always -e…",                             
                "apt-get -y install fail2ban\n",
                ]
    

Changes to the infrastructure can be placed into source control.

Other tools are platform independent such as Vagrant or Terraform. Terraform even allows the orchestration of creating multiple resources across cloud providers.  
Conclusion

Software development is an ever-changing field. Just as code reviews, source control, and now Test Driven Development and Continuous Integration have become the norm, building the infrastructure that runs an environment within code will become the norm as well.  
With the ever-increasing number of parts to a software application, coding the infrastructure will become an essential tool for managing its complexity. .

For a SaaS operation infrastructure as code is absolutely critical. Scaling up infrastructure in a repeatable manner will ensure a successful operation and save a ton of time in heartache. If an instance is broken, simply spin up another one.

On premise operations can be more difficult as more varied Operating System and Cloud provider support will be required. At a minimum, support should be provided for the local development and QA environment and can serve as a template to production operations and any typically supported target platforms. The code used for infrastructure can act as a type of documentation on the steps required to run a platform.

Martin Fowler, a prominent software pattern architect coined a term to describe an anti-pattern called a “snowflake server.” A snowflake server is one that is built by hand. Just like a snowflake every one is unique. There is no standard. Is the dev server really the same as the QA server? Is the QA server really a representation of what will run in production? Infrastructure as code eliminates the snowflake server and allows for easy provisioning and automatic scaling.

Just as was once the case with Test Driven Development, developers may fear that adding an additional infrastructure coding requirement to their check-ins will slow them down. In fact, coding a setup is no more time consuming than running the setup by hand and will save time the next time it needs to be setup. Coding infrastructure will also directly improve the quality of the software as the QA team can be more effective at testing using the right configuration.

If you have time to type it into a terminal you have time to put it into a script!

### Additional Reading and References

https://www.thoughtworks.com/insights/blog/infrastructure-code-reason-smile

http://www.linuxjournal.com/content/docker-lightweight-linux-containers-consistent-development-and-deployment?page=0,1

http://martinfowler.com/bliki/SnowflakeServer.html